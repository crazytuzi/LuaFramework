local QUpdateManager = class("QUpdateManager")
local QUpdateConfigHandler = import(".QUpdateConfigHandler")
local QUpdateIndexHandler = import(".QUpdateIndexHandler")
local QCheckIndexHandler = import(".QCheckIndexHandler")
local QDownloadHandler = import(".QDownloadHandler")
local QStaticDatabase = import("...controllers.QStaticDatabase")

QUpdateManager.EVENT_COMPLETE = "UPDATE_EVENT_COMPLETE"
QUpdateManager.EVENT_ERROR = "UPDATE_EVENT_ERROR"

QUpdateManager.EVENT_UI_UPDATE_PROGRESS = "EVENT_UI_UPDATE_PROGRESS"
QUpdateManager.EVENT_UI_UPDATE_STATE = "EVENT_UI_UPDATE_STATE"

QUpdateManager.STEP_NULL = 0 --初始阶段
QUpdateManager.STEP_VERSION = 1 --version阶段
QUpdateManager.STEP_INDEX = 2 --index文件阶段
QUpdateManager.STEP_CHECK = 3 --检查index文件阶段
QUpdateManager.STEP_FILE = 4 --下载更新阶段

local errorCode = {
    VERSION_NIL = 1
}

local LOCAL_VERSION_FILE = "version"
local VERSION_FILE = "version"
local INDEX_FILE = "index" 
local TEMP_INDEX = "tempIndex"

function QUpdateManager:ctor(options)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self.fileutil = CCFileUtils:sharedFileUtils()
end

function QUpdateManager:startWithAdapter(adapter)
    if not isImplement(adapter, "QUpdateBaseAdapter") then
        assert(false, "the adapter must extend by QUpdateBaseAdapter")
    end
    self:removeAdapter()
    self:addAdapter(adapter)
    self._status = QUpdateManager.STEP_NULL

    local currentMinute = math.floor(q.time() / 60)
    self._verParams = "?ver=" .. tostring(currentMinute)
    if self:isDisableDownload() then
        self:downloadComplete(0)
        return 
    end
    self:getUpdateVersion()
end

--[[
    移除之前的代理
]]
function QUpdateManager:removeAdapter()
    if self._adapter ~= nil then
        self._adapter:removeAllEventListeners()
        self._adapter:dispose()
        self._adapter = nil
    end
end

--[[
    添加新的代理
]]
function QUpdateManager:addAdapter(adapter)
    self._adapter = adapter
    self._adapter:addEventListener(self._adapter.EVENT_UPDATE_START, handler(self, self._adapterDownloadStart))
    self._adapter:addEventListener(self._adapter.EVENT_UPDATE_PROGRESS, handler(self, self._adapterDownloadProgress))
    self._adapter:addEventListener(self._adapter.EVENT_UPDATE_ERROR, handler(self, self._adapterDownloadError))
    self._adapter:addEventListener(self._adapter.EVENT_UPDATE_COMPLETE, handler(self, self._adapterDownloadComplete))
end

--[[
    获取下载代理
]]
function QUpdateManager:getAdapter( ... )
    return self._adapter
end

--[[
    获取更新的版本号和本地做对比
]]
function QUpdateManager:getUpdateVersion( ... )
    self._status = QUpdateManager.STEP_VERSION
    self:dispatchStatus("检查是否有新版本")
    local versionUrl = VERSION_URL..VERSION_FILE..self._verParams
    -- print("versionUrl", versionUrl)
    self._handler = QUpdateConfigHandler.new({manager = self})
    self._adapter:downloadFile(versionUrl, "tmp/" .. LOCAL_VERSION_FILE)
end

--[[
    读取下载的version检查是否需要更新
]]
function QUpdateManager:checkVersion( ... )
    self:dispatchStatus("获取到最新版本")
    local versionContent = self.fileutil:getFileData(self.fileutil:getWritablePath() .. "tmp/" .. LOCAL_VERSION_FILE)
    if versionContent == nil then
        self:downloadError(errorCode.VERSION_NIL)
        return
    end
    self._version = string.sub(versionContent, 1, 60)
    self._versionMd5 = string.sub(self._version, string.len(self._version) - 32 + 1, string.len(self._version))
    app.packageVersion = self._version -- 用来检查服务器返回的版本是否一致来强制用户登出 @qinyuanji

    -- 检查本地version file是否一致，一致则跳过检查
    local versionIsExist = self.fileutil:isFileExist(self.fileutil:getWritablePath() .. LOCAL_VERSION_FILE)
    -- print("check local version", versionIsExist)
    if versionIsExist then
        local localversion = self.fileutil:getFileData(self.fileutil:getWritablePath() .. LOCAL_VERSION_FILE)
        print("localversion: ", localversion, self._version)
        if localversion == self._version then
            self:dispatchStatus("当前已经最新版本无需更新")
            -- 下载一个config
            remote:triggerBeforeStartGameBuriedPoint("10022")
            -- downloadStart(version, true)
            self:downloadComplete(0)
            return
        end
    end
    remote:triggerBeforeStartGameBuriedPoint("10023")
    self:checkIndex()
end

--[[
    下载index文件
]]
function QUpdateManager:getIndex()
    self._status = self.STEP_INDEX
    self:clearTempIndex()
    self._handler = QUpdateIndexHandler.new({manager = self})
    self:downloadIndex()
end

function QUpdateManager:clearTempIndex( ... )
    writeToFile(TEMP_INDEX, "") --有最新的index则清楚本地缓存临时index
end

function QUpdateManager:downloadIndex( ... )
    self:dispatchStatus("开始下载文件列表")
    local indexurl = STATIC_URL .. self._version .. "/" .. INDEX_FILE
    self._adapter:downloadFile(indexurl, INDEX_FILE, self._versionMd5, -1, 0, false)
end

--[[
    检查index文件
]]

function QUpdateManager:checkIndex( ... )
    self._status = self.STEP_CHECK
    self:dispatchStatus("开始检查文件列表")
    self:dispatchProgress({percent = 0})
    --检查本地临时文件夹的index
    local indexLocalMd5 = nil
    if self.fileutil:isFileExist(self.fileutil:getWritablePath()..INDEX_FILE) then
        indexLocalMd5 = crypto.md5file(self.fileutil:getWritablePath()..INDEX_FILE)
    end
    --本地没有index文件
    if indexLocalMd5 == nil then
        self:getIndex()
        return
    end
    --本地index文件和线上不符
    if self._versionMd5 ~= indexLocalMd5 then
        self:getIndex()
        return
    end
    local content = self.fileutil:getFileData(self.fileutil:getWritablePath()..INDEX_FILE)
    local contentLocal = self:getLocalIndex()
    local indexDict, _, totalCount = QStaticDatabase.loadIndex(content)
    local inappContentExist = self.fileutil:isFileExist(self.fileutil:fullPathForFilename(INDEX_FILE .. "inapp"))
    local outappContentExist = self.fileutil:isFileExist(self.fileutil:getWritablePath()..INDEX_FILE .. "outapp")
    local contentInApp = ""
    if outappContentExist then
        contentInApp = self.fileutil:getFileData(self.fileutil:getWritablePath()..INDEX_FILE .. "outapp") or ""
    elseif inappContentExist then
        contentInApp = self.fileutil:getFileData(self.fileutil:fullPathForFilename(INDEX_FILE .. "inapp")) or ""
    end
    local indexInAppDict = {}
    local indexInAppDictCount = 0
    if (contentInApp == nil or contentInApp == "") then
        indexInAppDictCount = 0
    else
        indexInAppDict, _, indexInAppDictCount = QStaticDatabase.loadIndex(contentInApp)
    end
    local tempIndex = self:getTempIndex()
    self._handler = QCheckIndexHandler.new({manager = self})
    self._adapter:checkIndex(indexDict, indexInAppDict, tempIndex, indexInAppDictCount)
end

--[[
    读取本地的index文件
]]
function QUpdateManager:getLocalIndex( ... )
    if self.fileutil:isFileExist(self.fileutil:getWritablePath() .. INDEX_FILE) then
        return self.fileutil:getFileData(self.fileutil:getWritablePath()..INDEX_FILE)
    elseif self.fileutil:isFileExist(self.fileutil:getWritablePath() .. INDEX_FILE.."inapp") then
        return self.fileutil:getFileData(self.fileutil:getWritablePath()..INDEX_FILE.."inapp")
    else
        return nil
    end
end

--[[
    读取本地的临时index文件
]]
function QUpdateManager:getTempIndex( ... )
    local tempIndex = {}
    local tempIndexContent = nil
    if self.fileutil:isFileExist(self.fileutil:getWritablePath() .. TEMP_INDEX) then
        tempIndexContent = self.fileutil:getFileData(self.fileutil:getWritablePath()..TEMP_INDEX)
        local tempIndexList = string.split(tempIndexContent, "\n")
        for i,v in ipairs(tempIndexList) do
            tempIndex[v] = 1
        end
    end
    return tempIndex
end

--[[
    根据list下载
]]

function QUpdateManager:confirmDownload(updateList, totalSize)
    self._status = self.STEP_FILE
    self:dispatchStatus("开始下载文件")
    self:dispatchProgress({totalSize = totalSize, currentSize = 0})
    self._handler = QDownloadHandler.new({manager = self})
    self._adapter:confirmDownload(updateList, totalSize, self._version, self._verParams, self._versionMd5)
end

function QUpdateManager:isDisableDownload()
    return self._adapter:isDisableDownload() or IS_DISABLE_UPDATE
end

function QUpdateManager:downloadComplete(count)
    if count > 0 then
        -- self._adapter:replaceWritableByExtension(LOCAL_VERSION_FILE ,self._version, self._versionMd5)
        print(LOCAL_VERSION_FILE ,self._version, self._versionMd5)
        -- nzhang: 写回version串到本地的version文件，这样下次游戏启动就会从writable path下加载脚本
        writeToFile(LOCAL_VERSION_FILE, self._version)
        -- nzhang: 把version结尾的文件覆盖会目标文件
        QDownloader:replaceWritableByExtension(self._versionMd5)
        -- wkwang 把下载的index保存为最新的index作为下次对比
        if self.fileutil:isFileExist(self.fileutil:getWritablePath()..INDEX_FILE) then
            rename("", INDEX_FILE, INDEX_FILE.."outapp")
        end
    end
    self:dispatchEvent({name = QUpdateManager.EVENT_COMPLETE, count = count})
end

function QUpdateManager:downloadError(errorCode)
    self:dispatchEvent({name = self.EVENT_ERROR, errorCode = errorCode})
end

function QUpdateManager:dispatchStatus(text)
    self:dispatchEvent({name = self.EVENT_UI_UPDATE_STATE, status = self._status, data = {text = text}})
end

function QUpdateManager:dispatchProgress(data)
    self:dispatchEvent({name = self.EVENT_UI_UPDATE_PROGRESS, status = self._status, data = data})
end

------------------------------下载配置文件-----------------------------------
function QUpdateManager:changeConfigByServerConfig( ... )
    if self._adapter:isDisableDownload() then
        return 
    end
    local data = self._adapter:downloadContent(VERSION_URL .. "config.json", false)
    if data then
        local serverConfig = json.decode(data)
        printTable(serverConfig)
        if type(serverConfig) == "table" then 
            for k, v in pairs(serverConfig) do
                _G[k] = v  
            end 
        end
    end
end

------------------------------event handler--------------------------------

function QUpdateManager:_adapterDownloadStart(evt)
    self._handler:startHandler(evt)
end

function QUpdateManager:_adapterDownloadProgress(evt)
    self._handler:progressHandler(evt)
end

function QUpdateManager:_adapterDownloadError(evt)
    self._handler:errorHandler(evt)
end

function QUpdateManager:_adapterDownloadComplete(evt)
    self._handler:completeHandler(evt)
end

return QUpdateManager