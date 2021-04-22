--[[
    用Luasocket实现的下载类，单线程，支持多url下载
    Example:
    local _downloader = QLuaSocketDownLoader.new()
    local url = "http://iso.mirrors.ustc.edu.cn/qtproject/archive/online_installers/3.0/qt-unified-mac-x64-3.0.6-online.dmg"
    local url2 = "http://update.dldl.joybest.com.cn/dldl/release/version-01-21-2019-19-15-44-1058d07fd26532b7a874f717150acb7b/db9e740b1ffb5b6914ef66acb4fdee03-1058d07fd26532b7a874f717150acb7b.zip"
    _downloader:addUrl(url2)
    _downloader:addUrl(url)
    _downloader:addCallback(function (event, params)
        print("event", event)
        if params then
            print(params.percent)
        end
    end)
    _downloader:start()
]]

local QLuaSocketDownLoader = class("QLuaSocketDownLoader")
local socket = require("socket")

QLuaSocketDownLoader.EVENT_PROGRESS = "EVENT_PROGRESS"
QLuaSocketDownLoader.EVENT_COMPLETE = "EVENT_COMPLETE"
QLuaSocketDownLoader.EVENT_ERROR = "EVENT_ERROR"

function QLuaSocketDownLoader:ctor(options)
    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._urlsList = {}
    self._currentUrlInfo = nil
    self._connect = nil
    self._output = nil

end

-- add url
function QLuaSocketDownLoader:addUrl(url)
    table.insert(self._urlsList, {url = url, current = 0, total = 1, percent = 0, pos = nil})
end

-- add callback
function QLuaSocketDownLoader:addCallback(callback)
    self._callback = callback
end

-- start download
function QLuaSocketDownLoader:start()
    self._schedulerHandler = scheduler.scheduleGlobal(handler(self, self.loopHandler), 0)
end

function QLuaSocketDownLoader:_dispatch(event, params)
    if self._callback then
        self._callback(event, params)
    end
    self:dispatchEvent({name = event, params = params})
end

function QLuaSocketDownLoader:_closedCurrent()
    if self._connect then
        self._connect:close()
    end
    if self._output then
        self._output:close()
    end
    self._output = nil
    self._connect = nil
    self._currentUrlInfo = nil
end

function QLuaSocketDownLoader:loopHandler( ... )
    if #self._urlsList > 0 or self._currentUrlInfo ~= nil then
        if self._currentUrlInfo == nil then
            self._currentUrlInfo = table.remove(self._urlsList)
            self:_downloadByUrl()
        else
            self:_receiveHandler()
        end
        self:_dispatch(self.EVENT_PROGRESS, self._currentUrlInfo)
    else
        scheduler.unscheduleGlobal(self._schedulerHandler)
        self._schedulerHandler = nil
        self:_dispatch(self.EVENT_COMPLETE)
    end
end


function QLuaSocketDownLoader:_downloadByUrl()
    -- print("_downloadByUrl")
    if self._currentUrlInfo == nil then
        return
    end
    local url = self._currentUrlInfo.url
    local infolist = string.split(url,"/")
    local cache_file = infolist[#infolist]

    local host = infolist[3]
    local pos = string.find(url, host)
    local file = nil
    if pos then
        file = string.sub(url, pos + #host)
    end
    pos = nil

    self._output = io.open(cache_file,"wb")
    self._connect = assert(socket.connect(host, 80))
    local count = 0
    local pos = nil
    local content = "GET " ..file .." HTTP/1.0\r\n"
    content = content .. "Host:"..host.."\r\n"
    content = content .. "Accept: :*/* \r\n"
    content = content .. "Accept-Language: zh-cn\r\n"
    content = content .. "Connection: Keep-Alive\r\n"
    content = content .. "\r\n"
    self._connect:send(content)
end

function QLuaSocketDownLoader:_receiveHandler()
    -- print("_receiveHandler")
    if self._connect == nil then
        return
    end
    self._connect:settimeout(0)
    local s, status, partial = self._connect:receive("*a") --if use 2^10 ,when cached data big than, while lose some data, so use "*a" receive all data
    local strs = string.split(partial, "\r\n")
    local tbl = {}
    if #strs > 1 then
        for i=1,#strs do
            local _str = strs[i]
            local _strs = string.split(_str, ":")
            if #_strs == 2 then
                tbl[_strs[1]] = _strs[2]
            end
        end
        local totalSize = tonumber(tbl["Content-Length"])
        if totalSize then
            self._currentUrlInfo.total = totalSize
        end
    end
    if status == 'timeout' then
        local data = s or partial
        if data then
            if self._currentUrlInfo.pos == nil then            --去除响应头
                self._currentUrlInfo.pos = string.find(data, "\r\n\r\n")
                if self._currentUrlInfo.pos then
                    local writeData = string.sub(data, self._currentUrlInfo.pos + #"\r\n\r\n")
                    self._output:write(writeData)
                    self._currentUrlInfo.current = self._currentUrlInfo.current+string.len(writeData)
                end
            else
                self._output:write(data)
                self._currentUrlInfo.current = self._currentUrlInfo.current+string.len(data)
            end
            if self._currentUrlInfo.total > 0 then
                self._currentUrlInfo.percent = self._currentUrlInfo.current/self._currentUrlInfo.total * 100
                self._currentUrlInfo.percent = self._currentUrlInfo.percent-self._currentUrlInfo.percent%0.01
            end
        end
        if self._currentUrlInfo.current == self._currentUrlInfo.total then
            self:_closedCurrent()
        end
    else
        if status == "closed" then 
            self:_dispatch(self.EVENT_ERROR, self._currentUrlInfo)
            self:_closedCurrent()
        end
    end
end

return QLuaSocketDownLoader