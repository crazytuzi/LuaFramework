
local QUpdateStaticDatabase = class("QUpdateStaticDatabase")

local QStaticDatabase = import("..controllers.QStaticDatabase")
local QUIViewController = import("..ui.QUIViewController")
local QUIWidgetLoadingBar = import("..ui.widgets.QUIWidgetLoadingBar")
local QLogFile = import("..utils.QLogFile")
local QNavigationController = import("..controllers.QNavigationController")
local QErrorInfo = import("..utils.QErrorInfo")

QUpdateStaticDatabase.STATUS_PROGRESS = "STATUS_PROGRESS"
QUpdateStaticDatabase.STATUS_COMPLETED = "STATUS_COMPLETED"
QUpdateStaticDatabase.STATUS_FAILED = "STATUS_FAILED"

local LOCAL_VERSION_FILE = "version"
local VERSION_FILE = "version"

local INDEX_FILE = "index" 
--local INDEX_FILE = "static/index"

QUpdateStaticDatabase.EVENT_STATUS_UPDATE = "EVENT_STATUS_UPDATE"

QUpdateStaticDatabase.CHECK_FILE_PROGRESS_TOTAL = 0.2
QUpdateStaticDatabase.PROGRESS_MAX_SPEED = 1 / 1

local currentMinute = math.floor(q.time() / 60)
local currentVersion = "?ver=" .. tostring(currentMinute)

function QUpdateStaticDatabase:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self._downloader = QDownloader:new(CCFileUtils:sharedFileUtils():getWritablePath(), 1)

    self._loadingBar = QUIWidgetLoadingBar.new()
    self._loadingBar:retain()


    self._previousCompleted = 0
    self._previousTimestamp = 0
end 

--检查更新列表中是否有pkm或者alphapkm的文件，做匹配更新
function QUpdateStaticDatabase:checkPKMFile(downList, index)
    local size = 0
    local keyMap = {}
    for _, values in pairs(downList) do
        local name = values.name
        if name then
            local idx = name:match(".+()%.[%w_-]+$")
            if idx ~= nil then
                local extStr = name:sub(idx+1)
                local fileStr = name:sub(1, idx-1)
                if extStr == "pkm" or extStr == "pkm_alpha" then
                    if keyMap[fileStr] == nil then
                        keyMap[fileStr] = extStr
                    elseif keyMap[fileStr] ~= extStr then
                        keyMap[fileStr] = nil
                    end
                end
            end
        end
    end
    if next(keyMap) then
        for k,v in pairs(index) do
            local name = v.name
            if name then
                local idx = name:match(".+()%.[%w_-]+$")
                if idx ~= nil then
                    local extStr = name:sub(idx+1)
                    local fileStr = name:sub(1, idx-1)
                    if extStr == "pkm" or extStr == "pkm_alpha" then
                        if keyMap[fileStr] ~= nil and keyMap[fileStr] ~= extStr then
                            table.insert(downList, v)
                            size = size + (v.size or 0)
                        end
                    end
                end
            end
        end
    end
    return size
end

-- 返回值 -1：出错
-- 返回值 0：不需要更新
-- 返回值 > 0: 总共需要下载的内容的大小
function QUpdateStaticDatabase:update(tmp_disable) 
    if not self:isDisableDownload() then
        self:dispatchEvent({name = QUpdateStaticDatabase.STATUS_PROGRESS, progress = 0})
        app:topLayerView():addChild(self._loadingBar)
        self._loadingBar:setVisible(false)
        self._loadingBar:setPosition(ccp(display.cx, (display.height - display.cy) * 0.3))
        self._loadingBar:setPercent(0)
        self._loadingBar:setCheckingVisible(true)
        self._loadingBar:setUpdatingVisible(false)
    end

    local labelcaution = nil
    local labelcaution_end = false
    app:showLoading()
    scheduler.performWithDelayGlobal(function()
        if self:isDisableDownload() == false and labelcaution_end == false then
            labelcaution = CCLabelTTF:create("检查更新", global.font_default, 24)
            app._uiScene:addChild(labelcaution)
            labelcaution:setPosition(CONFIG_SCREEN_WIDTH / 2, CONFIG_SCREEN_HEIGHT / 2 - 70 - 30)
            labelcaution:retain()
            labelcaution:setVisible(false)
            -- self._loadingBar:setText("检查更新")
        end
    end, 0.2)

    local function removeLabelCaution()
        if labelcaution and labelcaution.removeFromParent then
            labelcaution:removeFromParent()
            labelcaution:release()
        end
        labelcaution = nil
        labelcaution_end = true
    end

    scheduler.performWithDelayGlobal(function()

        if self:isDisableDownload() then
            self:dispatchEvent({name = QUpdateStaticDatabase.STATUS_COMPLETED, total = 0, count = 0})
            if labelcaution and labelcaution.removeFromParent then
                labelcaution:removeFromParent()
                labelcaution:release()
            end
            labelcaution = nil
            return 0, 0
        end

        local fileutil = CCFileUtils:sharedFileUtils()
        -- nzhang: 下载服务器最新的version文件，如果version文件为空则表示服务器上没有任何更新
        --         不立即写回version文件，等全部下载完成之后再写回
        local function downloadStart(version, skipAll)
            if version == "error" then
                self:dispatchEvent({name = QUpdateStaticDatabase.STATUS_FAILED})
                removeLabelCaution()
                return -1, -1 
            elseif string.len(version) < 2 then self:dispatchEvent({name = QUpdateStaticDatabase.STATUS_COMPLETED, total = 0, count = 0}) 
                self:dispatchEvent({name = QUpdateStaticDatabase.STATUS_FAILED})
                removeLabelCaution()
                return 0, 0
            end

            local version_content = version.sub(version, 1, 60)
            local version_md5 = string.sub(version_content, string.len(version_content) - 32 + 1, string.len(version))

            -- nzhang: 检查本地的index文件是否存在并且是version文件所指的内容
            print(string.format("local content path %s, inapp path %s", fileutil:getWritablePath() .. INDEX_FILE, fileutil:fullPathForFilename(INDEX_FILE .. "inapp")))
            local local_content_exist = fileutil:isFileExist(fileutil:getWritablePath() .. INDEX_FILE)
            local local_content = (local_content_exist and fileutil:getFileData(fileutil:getWritablePath() .. INDEX_FILE)) or ""
            local local_content_md5 = (local_content_exist and crypto.md5file(fileutil:getWritablePath() .. INDEX_FILE)) or ""
            -- nzhang: inapp的index文件，作为inapp文件的背书，起到校验加速的作用
            local inapp_content_exist = fileutil:isFileExist(fileutil:fullPathForFilename(INDEX_FILE .. "inapp"))
            local inapp_content = (inapp_content_exist) and fileutil:getFileData(fileutil:fullPathForFilename(INDEX_FILE .. "inapp")) or ""
            local inapp_content_md5 = (inapp_content_exist) and crypto.md5file(fileutil:fullPathForFilename(INDEX_FILE .. "inapp")) or ""
            local local_md5_match = local_content_exist and (version_md5 == local_content_md5)
            local inapp_md5_match = inapp_content_exist and (version_md5 == inapp_content_md5)

            print(string.format("local_content_md5 %s, inapp_content_md5 %s, version_md5 %s", local_content_md5, inapp_content_md5, version_md5))

            local _percent = 0

            -- inapp_content可能为空或者空串，否则可起到加速校验的作用
            local function downloadFiles(content, skipAll, contentInApp, percentFrom)
                local total = 0 -- 记录总的字节大小
                local progress = 0 -- 记录当前进度字节大小
                local count = 0 -- 记录总的文件个数
                local completed = 0 -- 记录完成的文件个数
                local downloadStartTime = q.time() -- 开始下载的时间点，防止进度条走的过快

                if tmp_disable then
                    -- 临时屏蔽掉更新
                    self:dispatchEvent({name = QUpdateStaticDatabase.STATUS_COMPLETED, total = total, count = count})
                    removeLabelCaution()
                    return 0, 0
                end

                local start = q.time()

                -- local labeltip = nil
                local function onDownloadCompleted(current_percent)
                    local handle
                    handle = scheduler.scheduleGlobal(function(dt)
                            if current_percent < 1.0 then
                                current_percent = current_percent + dt * self.PROGRESS_MAX_SPEED
                                current_percent = current_percent > 1.0 and 1.0 or current_percent
                                self:dispatchEvent({name = QUpdateStaticDatabase.STATUS_PROGRESS, progress = current_percent * 100})
                            else
                                scheduler.unscheduleGlobal(handle)
                                -- 更新进度到100%
                                self:dispatchEvent({name = QUpdateStaticDatabase.STATUS_PROGRESS, progress = 100})

                                -- printInfo("================ total time: %.2f seconds", q.time() - start)
                                self:dispatchEvent({name = QUpdateStaticDatabase.STATUS_COMPLETED, total = total, count = count})

                                -- nzhang: 写回version串到本地的version文件，这样下次游戏启动就会从writable path下加载脚本
                                self._downloader:writeContent(LOCAL_VERSION_FILE, version_content)

                                -- nzhang: 把version结尾的文件覆盖会目标文件
                                QDownloader:replaceWritableByExtension(version_md5)

                                self._downloader:unregisterScriptHandler()

                                if count > 0 then
                                    -- app:sendGameEvent(GAME_EVENTS.GAME_EVENT_UPDATE_SUCCESS)
                                end
                            end
                        end, 0)
                end

                if skipAll then
                    onDownloadCompleted(1.0)
                    return
                end

                local index = QStaticDatabase.loadIndex(content)
                local indexInApp = (contentInApp == nil or contentInApp == "") and {} or QStaticDatabase.loadIndex(contentInApp)
                local function onDownloadEvent(eventPackage)
                    local eventData = string.split(eventPackage, ',')
                    local eventId = tonumber(eventData[1]);
                    local eventStr = eventData[2];
                    local eventNum = eventData[3];
                    if eventNum == nil then
                        eventNum = 0
                    else
                        eventNum = tonumber(eventNum)
                    end

                    --[[
                        返回格式为逗号“，”隔开的三个字段第一段是事件类型，有三种类型。
                        - QDownloader:kSuccess：成功下载一个文件，这时第二个字段eventStr是文件名
                        - QDownloader:kProgress：下载文件的进度，这时第二个字段eventStr是文件名，第三个字段eventNum是下载进度0 - 100
                        - QDownloader:kError：出错，此时第二个字段eventStr是下载文件名或者为空，第三个字段eventNum是错误代码，QDownloader:kCreateFile/QDownloader:kNetwork
                    --]]

                    if eventId == QDownloader.kSuccess or eventId == QDownloader.kProgress then
                        local cur = index[eventStr]
                        if cur == nil then
                            printError("file not found in index: " .. eventStr)
                            QErrorInfo:handleLocalError("C_ERROR_UPDATE_INDEX_NOT_FOUND")
                        else
                            if cur.progress == nil then
                                cur.progress = 0
                            end
                            -- 更新总体的progress
                            progress = progress + cur.gz * (eventNum - cur.progress) / 100
                            cur.progress = eventNum

                            local adjustProgress = (1 - QUpdateStaticDatabase.CHECK_FILE_PROGRESS_TOTAL) * progress / total
                            local deltaTime = q.time() - downloadStartTime
                            if deltaTime <= 0 then deltaTime = 0.001 end
                            if adjustProgress / deltaTime > QUpdateStaticDatabase.PROGRESS_MAX_SPEED then
                                adjustProgress = deltaTime * QUpdateStaticDatabase.PROGRESS_MAX_SPEED
                            end 

                            local percent = QUpdateStaticDatabase.CHECK_FILE_PROGRESS_TOTAL + adjustProgress
                            if percent > 1.0 then percent = 1.0 end
                            self:dispatchEvent({name = QUpdateStaticDatabase.STATUS_PROGRESS, progress = percent * 100})

                            if eventId == QDownloader.kSuccess then
                                completed = completed + 1
                                printInfo("completed %d/%d, %s", completed, count, eventStr)
                                -- if labeltip ~= nil and labeltip:getParent() == nil then
                                --     app._uiScene:addChild(labeltip)
                                -- end
                                -- labeltip:setString(string.format("更新客户端中：%d / %d", completed, count))
                                local updatepercent = math.ceil((completed / count) * 100)
                                if self._loadingBar then
                                    self._loadingBar:setPercent(updatepercent)
                                    self._loadingBar:setDownloadedSize(math.ceil((completed / count) * (total / 1024)))
                                end

                                if completed == count then
                                    onDownloadCompleted(percent)
                                end
                            end
                        end
                    elseif eventId == QDownloader.kError then
                        if eventNum == QDownloader.kNetwork or eventNum == QDownloader.kValidation then
                            local cur = index[eventStr]
                            if cur == nil then
                                printError("file not found in index: " .. eventStr)
                                QErrorInfo:handleLocalError("C_ERROR_UPDATE_INDEX_NOT_FOUND")
                            else
                                if cur.retry == 2 then
                                    -- 提示重新下载
                                    if DEBUG > 0 then
                                        CCMessageBox(string.format("redownload %s", cur.name), "")
                                    end
                                    cur.retry = 0
                                else
                                    cur.retry = cur.retry + 1
                                end
                                -- 重新下载cur
                                local values = cur
                                self._downloader:downloadFile(STATIC_URL .. version_content .. "/" .. values.name, values.name .. "." .. version_md5, values.md5, values.size, values.gz)
                            end
                        else
                            printError("event: error when download file: " .. eventStr .. " code: " .. eventNum)
                            self:dispatchEvent({name = QUpdateStaticDatabase.STATUS_FAILED})
                            -- app:sendGameEvent(GAME_EVENTS.GAME_EVENT_UPDATE_FAILED)
                        end
                    elseif eventId == QDownloader.kStart then
                        self._loadingBar:setFileUrl(eventStr)
                    else
                        printError("eventId not valid: " .. eventId)
                    end
                end

                local _count = 0 -- 需要更新的文件数量
                local _downloadIndex = {}
                local function requireDownload()
                    -- nzhang: 下载数量可能为0，则直接完成下载（服务器要么没有更新，要么更新已经下载过），这种情况就不能依赖setf._downloader发出事件
                    self:resetDownload()
                    if count == 0 then
                        QLogFile:debug("No update package is needed")
                        self._loadingBar:removeFromParent()
                        onDownloadCompleted(QUpdateStaticDatabase.CHECK_FILE_PROGRESS_TOTAL)
                    else
                        total = total + self:checkPKMFile(_downloadIndex, index)
                        local downloadSize = math.ceil(total / 1024)
                        self._loadingBar:setVisible(false)
                        self._loadingBar:setPercent(0)
                        self._loadingBar:setTotalSize(downloadSize)
                        local tipString = string.format("魂师大大，当前有%dKB更新，检测到您当前WLAN还未打开或连接，是否继续下载？", downloadSize)
                        local downloadText = string.format("%dKB", downloadSize)
                        if downloadSize > 1024 then
                            downloadSize = total / 1024 / 1024
                            tipString = string.format("魂师大大，当前有%.1fMB更新，检测到您当前WLAN还未打开或连接，是否继续下载？", downloadSize)
                            downloadText = string.format("%.1fMB", downloadSize)
                        end
                        QLogFile:debug(function ( ... )
                            return string.format("Detected an update package with size %d bytes", total)
                        end)

                        local confirmed = false
                        local function confirmDownload(visible)
                            self._loadingBar:setVisible(visible)
                            self._loadingBar:setCheckingVisible(false)
                            self._loadingBar:setUpdatingVisible(true)
                            
                            if confirmed == true then
                                return
                            else
                                confirmed = true
                            end

                            if self._speedDetector then
                                scheduler.unscheduleGlobal(self._speedDetector)
                                self._speedDetector = nil
                            end
                            self._speedDetector = scheduler.scheduleGlobal(function ( ... )
                                local speed = (completed - self._previousCompleted)/(q.serverTime() - self._previousTimestamp)
                                print("Download speed is ", speed, "completed", completed, "_previousComplete", self._previousCompleted, "time", (q.serverTime() - self._previousTimestamp))

                                if speed <= 1 then
                                    if not self._speedAlarmScheduler then
                                        self._speedAlarmScheduler = scheduler.performWithDelayGlobal(function ( ... )
                                            self._speedAlarm = app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFloatTip", 
                                                options = {words = "魂师大人，您的网络非常不稳定，建议更换网络环境哦>_<", time = 600}}, {isPopCurrentDialog = true})
                                        end, 60)
                                    end
                                else
                                    if self._speedAlarmScheduler then
                                        if self._speedAlarm then
                                            app:getNavigationManager():popViewController(app.topLayer, QNavigationController.POP_SPECIFIC_CONTROLLER, nil, self._speedAlarm)
                                        end
                                        scheduler.unscheduleGlobal(self._speedAlarmScheduler)
                                        self._speedAlarmScheduler = nil
                                    end
                                end

                                self._previousCompleted = completed
                                self._previousTimestamp = q.serverTime()
                            end, 1)

                            -- app:sendGameEvent(GAME_EVENTS.GAME_EVENT_UPDATE_START)
                            self._downloader:registerScriptHandler(onDownloadEvent)
                            for _, values in pairs(_downloadIndex) do
                                self._downloader:downloadFile(STATIC_URL .. version_content .. "/" .. values.name..currentVersion, values.name .. "." .. version_md5, values.md5, values.size, values.gz)
                                index[values.name .. "." .. version_md5] = index[values.name]
                            end

                            -- labeltip = CCLabelTTF:create()
                            -- -- labeltip:setString(string.format("更新客户端中：0 / %d", count))
                            -- labeltip:setString(string.format("下载中： 0%%"))
                            self._loadingBar:setUpdatingText(downloadText)
                            self._loadingBar:setDownloadedSize(0)
                            -- if labeltip ~= nil and labeltip:getParent() == nil then
                            --     app._uiScene:addChild(labeltip)
                            -- end
                            -- labeltip:setPosition(CONFIG_SCREEN_WIDTH / 2, CONFIG_SCREEN_HEIGHT / 2 - 70 - 30)
                            -- labeltip:setFontSize(24)
                            -- labeltip:retain()
                            -- labeltip:setVisible(false)

                            downloadStartTime = q.time()
                        end
                        
                        -- @qinyuanji, to prevent showing update dialog which only updates index file
                        if downloadSize > 1 then

                            if CCNetwork:isLocalWiFiAvailable() == true then
                                if self._loadingBar then
                                    self._loadingBar:setWifiTipsVisible(true)
                                end
                                confirmDownload(true)
                            else
                                app:alert({content=tipString, title="更新提示", 
                                    callback=function(state)
                                        if state == ALERT_TYPE.CONFIRM then
                                            confirmDownload(true)
                                        end
                                end, isAnimation = false}, false, true)
                            end
                         
                        else
                            confirmDownload(false)
                        end
                    end

                    removeLabelCaution()
                end

                self._loadingBar:setPercent(_percent)
                if self._downloader.checkFileAsync == nil then
                    -- nzhang: 检查需要更新的文件数量，分批QUpdateStaticDatabase.CHECK_FILE_PROGRESS_TOTAL批,同步分帧运行。
                    local _job = QUpdateStaticDatabase.CHECK_FILE_PROGRESS_TOTAL * 100
                    local _current = 1
                    local _index = {}
                    for _, values in pairs(index) do
                        table.insert(_index, values)
                    end
                    local _number = math.ceil(#_index / _job)
                    local handle_check
                    handle_check = scheduler.scheduleUpdateGlobal(function()
                        local i = _current
                        local j = _current + _number
                        j = j < #_index and j or #_index
                        while i <= j do
                            local values = _index[i]
                            if self._downloader:checkFile(STATIC_URL .. version_content .. "/" .. values.name, values.name, values.md5, values.size, values.gz, version_md5) then
                                total = total + values.gz
                                count = count + 1
                                table.insert(_downloadIndex, values)
                            end
                            i = i + 1
                        end
                        if j == #_index then
                            -- 更新进度到 10%
                            self._loadingBar:setPercent(100)
                            self:dispatchEvent({name = QUpdateStaticDatabase.STATUS_PROGRESS, progress = QUpdateStaticDatabase.CHECK_FILE_PROGRESS_TOTAL * 100})
                            scheduler.unscheduleGlobal(handle_check)
                            requireDownload()
                        else
                            -- 更新进度+1%
                            _percent = math.floor(_current / #_index * ((100 - percentFrom)/100) * 100) + percentFrom
                            self._loadingBar:setPercent(_percent)
                            self:dispatchEvent({name = QUpdateStaticDatabase.STATUS_PROGRESS, progress = _current / #_index * QUpdateStaticDatabase.CHECK_FILE_PROGRESS_TOTAL * 100})
                            _current = j + 1
                        end
                    end, 0)
                else
                    -- nzhang: 检查需要更新的文件数量，异步执行。
                    local checkCount = 0
                    local checkTotal = 0
                    for _, values in pairs(index) do
                        checkTotal = checkTotal + 1
                    end
                    local function onCheckFileEvent(eventPackage)
                        local eventData = string.split(eventPackage, ',')
                        local eventId = tonumber(eventData[1]);
                        local eventStr = eventData[2];
                        --[[
                            返回格式为逗号“，”隔开的三个字段第一段是事件类型，有三种类型。
                            - QDownloader.kCheckNeedUpdate： 该文件需要下载
                            - QDownloader.kCheckSkipUpdate： 该文件不需要下载
                        --]]

                        if eventId == QDownloader.kCheckNeedUpdate then
                            local file = eventStr
                            local values = index[file]
                            total = total + values.gz
                            count = count + 1
                            table.insert(_downloadIndex, values)
                            checkCount = checkCount + 1
                        elseif eventId == QDownloader.kCheckSkipUpdate then
                            -- nzhang: 防止因为存在"inapp-A|writable-B|remote-A"这样的情况导致不更新
                            local file = eventStr
                            local values = index[file]
                            local inappValue = indexInApp[values.name]
                            if fileutil:isFileExist(file) and fileutil:isFileExist(fileutil:getWritablePath() .. file) then
                                if inappValue and inappValue.md5 == values.md5 and inappValue.size == values.size then
                                    if crypto.md5file(fileutil:getWritablePath() .. file) ~= values.md5 then
                                        total = total + values.gz
                                        count = count + 1
                                        table.insert(_downloadIndex, values)
                                    end
                                end
                            end

                            checkCount = checkCount + 1
                        elseif eventId == QDownloader.kStart then
                            -- self._loadingBar:setFileName("开始更新: "..eventStr)
                            return
                        end

                        _percent = math.floor(checkCount / checkTotal * ((100 - percentFrom)/100) * 100) + percentFrom
                        self._loadingBar:setPercent(_percent)
                        self:dispatchEvent({name = QUpdateStaticDatabase.STATUS_PROGRESS, progress = checkCount / checkTotal * QUpdateStaticDatabase.CHECK_FILE_PROGRESS_TOTAL * 100})

                        if checkCount == checkTotal then
                            self._loadingBar:setPercent(100)
                            self:dispatchEvent({name = QUpdateStaticDatabase.STATUS_PROGRESS, progress = QUpdateStaticDatabase.CHECK_FILE_PROGRESS_TOTAL * 100})
                            requireDownload()
                        end
                    end
                    self._downloader:registerScriptHandler(onCheckFileEvent)
                    local isJIT64BIT = IS_64_BIT_CPU
                    for key, values in pairs(index) do
                        -- nzhang: 32位和64位的lua代码文件（不包括res_static下的lua静态量表），不用全检查
                        local ok = true
                        if string.sub(values.name, 1, 8) == ("scripts/") and isJIT64BIT then
                            ok = false
                        elseif string.sub(values.name, 1, 11) == ("scripts_64/") and not isJIT64BIT then
                            ok = false
                        end
                        if ok then
                            if self._downloader.checkFileAsyncWithInAppInfo then
                                local inappValue = indexInApp[values.name]
                                local inappMD5 = inappValue and inappValue.md5 or ""
                                local inappSize = inappValue and inappValue.size or 0
                                self._downloader:checkFileAsyncWithInAppInfo(STATIC_URL .. version_content .. "/" .. values.name, 
                                    values.name, values.md5, values.size, values.gz, version_md5,
                                    inappMD5, inappSize)
                            else
                                self._downloader:checkFileAsync(STATIC_URL .. version_content .. "/" .. values.name, 
                                    values.name, values.md5, values.size, values.gz, version_md5)
                            end
                        else
                            checkTotal = checkTotal - 1
                            index[key] = nil
                        end
                    end
                end
            end

            if skipAll then
                downloadFiles(nil, true, inapp_content, 0)
                return
            end

            -- nzhang: 如果本地index文件不符合version，则重新下载index。index文件下载后会保存在writable path下
            if local_md5_match or inapp_md5_match then
                local content = (local_md5_match and local_content) or (inapp_md5_match and inapp_content)
                downloadFiles(content, nil, inapp_content, 0) -- inapp_content作为inapp文件的索引起到加速校验的作用
            else
                print("Download file " .. STATIC_URL .. version_content .. "/" .. INDEX_FILE)
                self._downloader:downloadFile(STATIC_URL .. version_content .. "/" .. INDEX_FILE, INDEX_FILE, version_md5, -1, 0, false)
                self._loadingBar:setPercent(0)
                self._downloader:registerScriptHandler(function(evtPkg)
                    local eventData = string.split(evtPkg, ',')
                    local eventId = tonumber(eventData[1])
                    local eventStr = eventData[2]
                    local eventNum = eventData[3]
                    printInfo("===============================================")
                    print(evtPkg)

                    if eventNum == nil then
                        eventNum = 0
                    else
                        eventNum = tonumber(eventNum)
                    end

                    if eventId == QDownloader.kSuccess or eventId == QDownloader.kProgress then
                        if eventId == QDownloader.kSuccess then
                            _percent = 20
                            self._loadingBar:setPercent(20)
                            local content = fileutil:getFileData(fileutil:getWritablePath() .. INDEX_FILE)
                            downloadFiles(content, nil, inapp_content, 20) -- inapp_content作为inapp文件的索引起到加速校验的作用
                        else
                            _percent = _percent + 0.5
                            if _percent > 20 then
                                _percent = 20
                            end
                            self._loadingBar:setPercent(math.floor(_percent))
                        end
                    elseif eventId == QDownloader.kError then
                        if eventNum == QDownloader.kNetwork or eventNum == QDownloader.kValidation then
                            self._downloader:downloadFile(STATIC_URL .. version_content .. "/" .. INDEX_FILE, INDEX_FILE, version_md5, -1, 0, false)
                        else
                            printError("event: error when download file: " .. eventStr .. " code: " .. eventNum)
                            self:dispatchEvent({name = QUpdateStaticDatabase.STATUS_FAILED})
                        end
                    else
                        printError("eventId not valid: " .. eventId)
                    end
                end)
            end
        end

        QLogFile:debug(VERSION_URL .. VERSION_FILE .. currentVersion .. "    " .. "tmp/" .. LOCAL_VERSION_FILE)
        remote:triggerBeforeStartGameBuriedPoint("10021")
        self._downloader:downloadFile(VERSION_URL .. VERSION_FILE .. currentVersion, "tmp/" .. LOCAL_VERSION_FILE)
        self._downloader:registerScriptHandler(function(evtPkg)
            local eventData = string.split(evtPkg, ',')
            local eventId = tonumber(eventData[1])
            local eventStr = eventData[2]
            local eventNum = eventData[3]

            if eventNum == nil then
                eventNum = 0
            else
                eventNum = tonumber(eventNum)
            end

            if eventId == QDownloader.kSuccess or eventId == QDownloader.kProgress then
                if eventId == QDownloader.kSuccess then
                    local version = fileutil:getFileData(fileutil:getWritablePath() .. "tmp/" .. LOCAL_VERSION_FILE)
                    if version == nil then
                        --nzhang: i don't know y version is nil here, since it should be downloaded successfully.
                        QLogFile:debug(("QUpdateStaticDatabase: temp/version is nil, " .. tostring(eventId) .. " " .. tostring(eventStr) .. " " .. tostring(eventNum)))
                        if eventStr == "tmp/" .. LOCAL_VERSION_FILE then
                            version = self._downloader:downloadContent(VERSION_URL .. VERSION_FILE .. currentVersion, false)
                            if version == nil or version == "" or version == "error" then
                                self._downloader:downloadFile(VERSION_URL .. VERSION_FILE .. currentVersion, "tmp/" .. LOCAL_VERSION_FILE)
                                return
                            end
                        end
                    end
                    version = version.sub(version, 1, 60)
                    app.packageVersion = version -- 用来检查服务器返回的版本是否一致来强制用户登出 @qinyuanji

                    -- 检查本地version file是否一致，一致则跳过检查
                    if fileutil:isFileExist(fileutil:getWritablePath() .. LOCAL_VERSION_FILE) then
                        local localversion = fileutil:getFileData(fileutil:getWritablePath() .. LOCAL_VERSION_FILE)
                        if localversion == version then
                            -- 下载一个config
                            remote:triggerBeforeStartGameBuriedPoint("10022")
                            downloadStart(version, true)
                            return
                        end
                    end

                    app:hideLoading()
                    self._loadingBar:setVisible(true)
                    remote:triggerBeforeStartGameBuriedPoint("10023")
                    downloadStart(version)
                end
            elseif eventId == QDownloader.kError then
                if eventNum == QDownloader.kNetwork or eventNum == QDownloader.kValidation then
                    self._downloader:downloadFile(VERSION_URL .. VERSION_FILE .. currentVersion, "tmp/" .. LOCAL_VERSION_FILE)
                else
                    printError("event: error when download file: " .. eventStr .. " code: " .. eventNum)
                    self:dispatchEvent({name = QUpdateStaticDatabase.STATUS_FAILED})
                end
            else
                printError("eventId not valid: " .. eventId)
            end
        end)
    end, 0.2)
end

function QUpdateStaticDatabase:resetDownload()
    if self._downloader.purge then
        self._downloader:purge()
    end
    self._downloader = QDownloader:new(CCFileUtils:sharedFileUtils():getWritablePath(), 16)
end

function QUpdateStaticDatabase:changeConfigByServerConfig( )
    -- body
    if self._downloader:isDisableDownload() then
        return 
    end
    local data = self._downloader:downloadContent(VERSION_URL .. "config.json", false)
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

function QUpdateStaticDatabase:isDisableDownload()
    return self._downloader:isDisableDownload() or IS_DISABLE_UPDATE
end

function QUpdateStaticDatabase:updateIndex()
end

function QUpdateStaticDatabase:purge()
    if self._downloader.purge then
        self._downloader:purge()
    end

    if self._loadingBar then
        self._loadingBar:removeFromParent()
        self._loadingBar:release()
        self._loadingBar = nil
    end

    if self._speedAlarmScheduler then
        if self._speedAlarm then
            app:getNavigationManager():popViewController(app.topLayer, QNavigationController.POP_SPECIFIC_CONTROLLER, nil, self._speedAlarm)
        end
        scheduler.unscheduleGlobal(self._speedAlarmScheduler)
        self._speedAlarmScheduler = nil
    end

    if self._speedDetector then
        scheduler.unscheduleGlobal(self._speedDetector)
        self._speedDetector = nil
    end
end

return QUpdateStaticDatabase