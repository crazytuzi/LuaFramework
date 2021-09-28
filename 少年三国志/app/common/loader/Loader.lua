local Loader = class("Loader")

local loaderId = 1
local loaders = {}
local inited = false


--Loader类本身有缓存请求的功能， 也就是说同时请求2个一样的URL， 会先等第一个URL返回后， 再请求第2个， 
--如果本身不缓存请求， 直接把2个URL发给底层的DownloadUtil，会有问题产生， 因为第一个URL下载完成后， 移动临时文件的过程中会失败。。
--Loader另外需要支持本地文件缓存， 如果曾经下载成功过某个URL， 直接通过MD5拼接路径， 不要再重新下载

--[[
使用实例：
local Loader = require("app.common.loader.Loader")
Loader.create("http://upload.youzu.com/sg/2014/1219/193332055.jpg", function(loader, file)  
    local sp = CCSprite:create(file)
    if sp then
        self:addChild(sp)
        sp:setPosition(display.cx, display.cy)
    end
    loader:cancel()
end)

记得不使用loader的时候记得cancel()掉，不然下载完成后会回调回来，可能会导致出错（如果回调函数里有对老场景，Layer的引用的话）

]]
local function getLoaderSaveDir()
    local dir = CCFileUtils:sharedFileUtils():getWritablePath() .."/loader"
    -- local tmpDir = dir .. "/tmp"

    if not io.exists(dir) then
        FuncHelperUtil:createDirectory(dir)
    end


    return dir, tmpDir
end


--static functions
function Loader.init()
    FileDownloadUtil:getInstance():registerDownloadHandler(function ( eventName, ret, fileUrl, filePath, param1, param2  )
         if type(eventName) ~= "string" then 
             return 
         end

         local loader = Loader.findStartLoaderByUrl(fileUrl) 
         if loader then
            loader:onEvent(eventName, ret, fileUrl, filePath, param1, param2)
         end

      
    end)

end

function Loader.uninit()
    FileDownloadUtil:getInstance():unregisterDownloadHandler()
end

function Loader.findLoaderByUrl(url)
    for i,loader  in ipairs(loaders) do 
        if loader:isSameLoader(url) then
            return loader 
        end
    end
    return nil
end

function Loader.findStartLoaderByUrl(url)
    for i,loader  in ipairs(loaders) do 
        if loader.status ~= "wait" and loader:isSameLoader(url) then
            return loader 
        end
    end
    return nil
end

function Loader.removeLoader(rLoader)
    for i,loader  in ipairs(loaders) do 
        if loader ==  rLoader then
            table.remove(loaders, i, 1)
            break
        end
    end
    return nil
end

function Loader.loadNext()
    for i,loader  in ipairs(loaders) do 
        if loader.status == "wait" then
            loader:start()
            break
        elseif loader.status == "start" then
            --有任务还没完成呢
            break
        end
    end
end


function Loader.create(url,  callback)
    if inited == false then
        Loader.init()
        inited = true
    end

    -- local loader = Loader.findLoaderByUrl(fileUrl) 
    -- if loader ~= nil then
    --     return loader 
    -- end
    loader = Loader.new(loaderId, url,  callback)
    loaderId = loaderId + 1
    table.insert(loaders, loader)
    Loader.loadNext()
    return loader
end

-- 


--instance functions

function Loader:ctor(id, url,  callback)
    self._id = loaderId 
    self._url = url
    self._callback = callback
    self.status = "wait"
    

    local dir = getLoaderSaveDir()
    local savePath = dir .. "/" .. CCCrypto:MD5(url, false) .. "_" 
    --因为底层默认会从URL里取最右边一段做为文件名。。。所以这里也取一下
    local filename = string.match(url ,"([^%/]+)$")
    self._savePath = savePath
    self._saveFullPath = savePath .. filename
   
end


function Loader:start()
    self.status = "start"
    if io.exists(self._saveFullPath) then
        uf_funcCallHelper:callAfterFrameCount(1, function()
            self:_onLoaded()
        end)
    else
        --insert into queue
        FileDownloadUtil:getInstance():addDownloadTask(self._url, self._savePath, "", false)
    end
end

function Loader:isSameLoader(url)
    if self._url == url then
        return true
    end
    return false
end

function Loader:cancel()
    self:_destroy()
end

function Loader:_destroy()
    Loader.removeLoader(self)
    self._callback = nil
end

function Loader:_onLoaded()
    if self._callback ~= nil then
        self._callback(self, self._saveFullPath)
    end
    self._status = "finish"
    self:_destroy()
    Loader.loadNext()
end

function Loader:_onLoadedError()
    self._status = "error"
    self:_destroy()
    Loader.loadNext()
end


function Loader:onEvent( eventName, ret, fileUrl, filePath, param1, param2)
    if eventName == "start" then
    elseif eventName == "progress" then 
    elseif eventName == "success" then 
        self:_onLoaded()
    elseif eventName == "failed" then 
        self:_onLoadedError()
    elseif eventName == "inerrupt" then 
        self:_onLoadedError()
    elseif eventName == "finish" then 
    elseif eventName == "unzip" then 
    end
end


return Loader