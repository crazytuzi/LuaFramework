-- @Author: Kai Wang
-- @Date:   2019-07-30 10:29:43
-- @Last Modified by:   Kai Wang
-- @Last Modified time: 2019-07-30 15:02:31
-- lua下载代理器
local QUpdateBaseHandler = import(".QUpdateBaseHandler")
local QUpdateLuaAdapter = class("QUpdateLuaAdapter", QUpdateBaseHandler)

function QUpdateLuaAdapter:ctor(options)
    QUpdateLuaAdapter.super.ctor(self, options)
    self.fileutil = CCFileUtils:sharedFileUtils()
    self._downloader = QDownloader:new(self.fileutil:getWritablePath(), 1)
    self._downloader:registerScriptHandler(handler(self, self.callBackHandler))
end

function QUpdateLuaAdapter:isDisableDownload()
    return self._downloader:isDisableDownload()
end

function QUpdateLuaAdapter:downloadFile(url, localPath)
    QUpdateLuaAdapter.super.downloadFile(self, url, localPath)
    self._downloader:downloadFile(url, localPath)
end

--[[
    销毁，移除时必须调用
]]
function QUpdateLuaAdapter:dispose( ... )
    if self._downloader.purge then
        self._downloader:purge()
    end
    self._downloader = nil
end

function QUpdateLuaAdapter:callBackHandler(evt)
    local eventData = string.split(evt, ',')
    local eventId = tonumber(eventData[1])
    local eventStr = eventData[2]
    local eventNum = eventData[3]
    if eventNum == nil then
        eventNum = 0
    else
        eventNum = tonumber(eventNum)
    end
    if eventId == QDownloader.kSuccess then
        self:dispatch({name = self.EVENT_UPDATE_COMPLETE, data = {str = eventStr, num = eventNum}})
    elseif eventId == QDownloader.kProgress then
        self:dispatch({name = self.EVENT_UPDATE_PROGRESS, data = {str = eventStr, num = eventNum}})
    elseif eventId == QDownloader.kError then
        if eventNum == QDownloader.kNetwork or eventNum == QDownloader.kValidation then
            -- self._downloader:downloadFile(VERSION_URL .. VERSION_FILE .. currentVersion, "tmp/" .. LOCAL_VERSION_FILE)
            self:dispatch({name = self.EVENT_UPDATE_ERROR, data = {str = eventStr, num = 0, error = eventNum}})
        else
            printError("event: error when download file: " .. eventStr .. " code: " .. eventNum)
            self:dispatch({name = self.EVENT_UPDATE_ERROR, data = {str = eventStr, num = 0, error = eventNum}})
        end
    else
        printError("eventId not valid: " .. eventId)
    end
end

return QUpdateLuaAdapter