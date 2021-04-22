-- @Author: Kai Wang
-- @Date:   2019-07-30 15:02:39
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-03-27 10:17:59
-- QDownloader下载代理器

local QUpdateBaseAdapter = import(".QUpdateBaseAdapter")
local QUpdateDownloaderAdapter = class("QUpdateDownloaderAdapter", QUpdateBaseAdapter)

local LOCAL_VERSION_FILE = "version"
local VERSION_FILE = "version"
local INDEX_FILE = "index" 
local TEMP_INDEX = "tempIndex"
local currentMinute = math.floor(q.time() / 60)
local currentVersion = "?ver=" .. tostring(currentMinute)

function QUpdateDownloaderAdapter:ctor(options)
    QUpdateDownloaderAdapter.super.ctor(self, options)
    self.fileutil = CCFileUtils:sharedFileUtils()
    self._downloader = QDownloader:new(self.fileutil:getWritablePath(), 1)
    self._downloader:registerScriptHandler(handler(self, self.callBackHandler))
end

function QUpdateDownloaderAdapter:isDisableDownload()
    -- return self._downloader:isDisableDownload()
    return false
end

function QUpdateDownloaderAdapter:downloadFile( ... )
    QUpdateDownloaderAdapter.super.downloadFile(self, ...)
    self._downloader:downloadFile( ... )
end

function QUpdateDownloaderAdapter:downloadContent( ... )
    QUpdateDownloaderAdapter.super.downloadContent(self, ...)
    return self._downloader:downloadContent(...)
end

function QUpdateDownloaderAdapter:checkIndex( indexDict, indexInAppDict, tempIndexDict, totalCount)
    QUpdateDownloaderAdapter.super.checkIndex(self, indexDict, indexInAppDict, tempIndexDict)
    local updateList = {}
    local totalSize = 0
    self._updateCount = 0

    local preCount = 300
    local currentCount = 0

    --移动所有的lua文件到可写目录下
    local moveLuaFile = function (fileName)
        if string.len(fileName) > 4 and string.sub(fileName, -4, -1) == ".lua" then
            local oldFilePath = self.fileutil:fullPathForFilename(fileName)
            local newFilePath = self.fileutil:getWritablePath() .. fileName
            local isExist = self.fileutil:isFileExist(oldFilePath)
            local isNewExist = self.fileutil:isFileExist(newFilePath)
            if oldFilePath ~= newFilePath and isExist and isNewExist == false then
                local data = self.fileutil:getFileData(oldFilePath)
                if createFileDir(fileName) == false then
                    print("create dir fail")
                end
                writeToBinaryFile(fileName, data)
            end
        end
    end

    local checkProgressCO = coroutine.create(function ()
        for k,v in pairs(indexInAppDict) do
            currentCount = currentCount + 1
            moveLuaFile(v.name)
            if currentCount%preCount == 0 then
                coroutine.yield(currentCount)
            end
        end
    end)

    local checkComplete = false
    self._checkHandler = scheduler.scheduleUpdateGlobal(function ()
        local isLive, count = coroutine.resume(checkProgressCO)
        if isLive then
            if count then
                self:dispatchEvent({name = self.EVENT_UPDATE_PROGRESS, percent = 100*count/totalCount})
            end
        else
            for k,v in pairs(indexDict) do
                currentCount = currentCount + 1
                if tempIndexDict[k] == nil and (indexInAppDict[k] == nil or v.md5 ~= indexInAppDict[k].md5) then
                    table.insert(updateList, v)
                    totalSize = totalSize + v.gz
                elseif tempIndexDict[k] ~= nil then
                    self._updateCount = self._updateCount + 1
                end
            end
            self:dispatchEvent({name = self.EVENT_UPDATE_PROGRESS, percent = 100})
            scheduler.unscheduleGlobal(self._checkHandler)
            self._checkHandler = nil
            self:dispatchEvent({name = self.EVENT_UPDATE_COMPLETE, list = updateList, percount = self._updateCount,  totalSize = totalSize})
        end
    end)
end

function QUpdateDownloaderAdapter:callBackHandler(evt)
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
        self:dispatchEvent({name = self.EVENT_UPDATE_COMPLETE, data = {str = eventStr, num = eventNum}})
    elseif eventId == QDownloader.kProgress then
        self:dispatchEvent({name = self.EVENT_UPDATE_PROGRESS, data = {str = eventStr, num = eventNum}})
    elseif eventId == QDownloader.kError then
        if eventNum == QDownloader.kNetwork or eventNum == QDownloader.kValidation then
            self._downloader:downloadFile(VERSION_URL .. VERSION_FILE .. currentVersion, "tmp/" .. LOCAL_VERSION_FILE)
            -- self:dispatchEvent({name = self.EVENT_UPDATE_ERROR, data = {str = eventStr, num = 0, error = eventNum}})
        else
            -- printError("event: error when download file: " .. eventStr .. " code: " .. eventNum)
            self:dispatchEvent({name = self.EVENT_UPDATE_ERROR, data = {str = eventStr, num = 0, error = eventNum}})
        end
    elseif eventId == QDownloader.kStart then
        -- print(eventStr, eventNum)
        self:dispatchEvent({name = self.EVENT_UPDATE_START, data = {str = eventStr, num = eventNum}})
    else
        printError("eventId not valid: " .. eventId)
    end
end

--[[
    执行下载
]]
function QUpdateDownloaderAdapter:confirmDownload(updateList, totalSize, version, verParams, verMd5)
    self:resetDownload()
    self._downloader:registerScriptHandler(handler(self, self.downloadCallBackHandler))
    self._indexDict = {}
    self._version = version
    self._verParams = verParams
    self._totalSize = totalSize
    self._verMd5 = verMd5
    self._currentSize = 0
    self._totalCount = 0
    self._completeCount = 0
    self:dispatchEvent({name = self.EVENT_UPDATE_START})
    self._totalCount = #updateList
    self:downloadByList(updateList, 0)
end

function QUpdateDownloaderAdapter:downloadByList(list, retry)
    for _, values in ipairs(list) do
        values.progress = 0
        values.retry = retry
        -- if string.find(values.name, "script") == nil then --todo暂时只下载非代码的资源
            self._indexDict[values.name .. "." .. self._verMd5] = values
            self._downloader:downloadFile(STATIC_URL .. self._version .. "/" .. values.name..self._verParams, values.name .. "." .. self._verMd5, values.md5, values.size, values.gz)
        -- end
    end
end

function QUpdateDownloaderAdapter:downloadCallBackHandler(eventPackage)
    local eventData = string.split(eventPackage, ',')
    local eventId = tonumber(eventData[1]);
    local eventStr = eventData[2];
    local eventNum = eventData[3];
    if eventNum == nil then
        eventNum = 0
    else
        eventNum = tonumber(eventNum)
    end
    -- if eventId ~= QDownloader.kProgress then
    --     print(eventId, eventStr, eventNum)
    -- end

    --[[
        返回格式为逗号“，”隔开的三个字段第一段是事件类型，有三种类型。
        - QDownloader:kSuccess：成功下载一个文件，这时第二个字段eventStr是文件名
        - QDownloader:kProgress：下载文件的进度，这时第二个字段eventStr是文件名，第三个字段eventNum是下载进度0 - 100
        - QDownloader:kError：出错，此时第二个字段eventStr是下载文件名或者为空，第三个字段eventNum是错误代码，QDownloader:kCreateFile/QDownloader:kNetwork
    --]]
    local curInfo = self._indexDict[eventStr]
    if eventId == QDownloader.kSuccess then
        if curInfo ~= nil then
            self._currentSize = self._currentSize + curInfo.gz * (100 - curInfo.progress)/100
            self._downloader:appendContent("tempIndex", curInfo.name.."\n")
        end
        self._completeCount = self._completeCount + 1
        -- print("更新中：", self._completeCount.."/"..self._totalCount, 100*self._currentSize/self._totalSize)
        self:dispatchEvent({name = self.EVENT_UPDATE_PROGRESS, curCount = self._completeCount, totalCount = self._totalCount, currentSize = self._currentSize, totalSize = self._totalSize})
        if self._completeCount == self._totalCount then
            -- print("下载完毕")
            self:downloadAllComplete()
        end
    elseif eventId == QDownloader.kProgress then
        if curInfo ~= nil then
            if eventNum > curInfo.progress then
                self._currentSize = self._currentSize + curInfo.gz*(eventNum - curInfo.progress)/100
                curInfo.progress = eventNum
            end
        end
        -- print("更新中：", curInfo.gz, self._completeCount.."/"..self._totalCount, 100*self._currentSize/self._totalSize)
        self:dispatchEvent({name = self.EVENT_UPDATE_PROGRESS, curCount = self._completeCount, totalCount = self._totalCount, currentSize = self._currentSize, totalSize = self._totalSize})
    elseif eventId == QDownloader.kError then
        if eventNum == QDownloader.kNetwork or eventNum == QDownloader.kValidation then
            if curInfo then
                if curInfo.progress > 0 then
                    self._currentSize = self._currentSize - curInfo.gz*curInfo.progress/100
                end
                curInfo.progress = 0
                self._downloader:downloadFile(STATIC_URL .. self._version .. "/" .. curInfo.name..self._verParams, curInfo.name .. "." .. self._verMd5, curInfo.md5, curInfo.size, curInfo.gz)
            else
                self:dispatchEvent({name = self.EVENT_UPDATE_ERROR, data = {info = curInfo, error = eventNum}})
            end
        else
            printError("event: error when download file: " .. eventStr .. " code: " .. eventNum)
            self:dispatchEvent({name = self.EVENT_UPDATE_ERROR, data = {info = curInfo, error = eventNum}})
        end
    elseif eventId == QDownloader.kStart then
        local startPos = string.find(eventStr,"version")
        local endPos = string.find(eventStr, "?ver=")
        if startPos and endPos then
            local fileName = string.sub(eventStr, startPos, endPos-1)
            self:dispatchEvent({name = self.EVENT_UPDATE_START, fileName = fileName})
        end
    end
end

function QUpdateDownloaderAdapter:downloadAllComplete( ... )
    self:dispatchEvent({name = self.EVENT_UPDATE_COMPLETE, count = (self._completeCount+self._updateCount)})
end

-- function QUpdateDownloaderAdapter:replaceWritableByExtension(filename, version, md5)
--     -- nzhang: 写回version串到本地的version文件，这样下次游戏启动就会从writable path下加载脚本
--     print(filename, version, md5)
--     self._downloader:writeContent(filename, version)
--     -- nzhang: 把version结尾的文件覆盖会目标文件
--     QDownloader:replaceWritableByExtension(md5)
-- end

function QUpdateDownloaderAdapter:resetDownload()
    if self._downloader.purge then
        self._downloader:purge()
    end
    self._downloader = QDownloader:new(CCFileUtils:sharedFileUtils():getWritablePath(), 16)
end

--[[
    销毁，移除时必须调用
]]
function QUpdateDownloaderAdapter:dispose( ... )
    if self._downloader.purge then
        self._downloader:purge()
    end
    self._downloader = nil
end

return QUpdateDownloaderAdapter