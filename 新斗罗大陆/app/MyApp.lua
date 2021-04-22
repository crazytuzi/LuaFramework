
q = q or {}

GlobalVal = GlobalVal or {}
local __g = _G
setmetatable(GlobalVal, {
    __newindex = function(_, name, value)
        rawset(__g, name, value)
    end,

    __index = function(_, name)
        return rawget(__g, name)
    end
})
GetLuaLocalization = function (str)
    return str
end
-- test
-- cocos2d-x
require("feature")
require("config")
require("QRES")
require("framework.init")
require("framework.shortcodes")
require("framework.cc.init")
require("framework.toluaEx")

-- extentions
require("CCBReaderLoad")
require("frameworkExtend")
require("lib.UUID")
require("app.language.QLanguage")

-- game
require("app.utils.QFunctions")
require("app.utils.QValidation")
require("app.utils.QCCUtils")
require("app.utils.QCoroutine")
require("app.utils.QArchaeologyUtils")

require("version")
require("buildTime")
require("html")
require("videoPlayerEnum") 

local http = require 'socket.http'
local fca = require 'lib.fca.fca'

-- BATTLE_AREA.bottom = global.screen_margin_bottom * global.pixel_per_unit + (CONFIG_SCREEN_HEIGHT * (BATTLE_SCREEN_WIDTH / UI_DESIGN_WIDTH) - BATTLE_SCREEN_HEIGHT) * 0.5
-- BATTLE_AREA.top = BATTLE_AREA.bottom + BATTLE_AREA.height

BATTLE_SCENE_WIDTH = BATTLE_SCREEN_WIDTH
BATTLE_SCENE_HEIGHT = display.height / display.width * BATTLE_SCENE_WIDTH

-- SAVE_BATTLE_RECORD = SAVE_BATTLE_RECORD and device.platform == "windows"  -- 只在windows上保存战斗录像

CCTexture2D:PVRImagesHavePremultipliedAlpha(true)

QUtility:setScriptCodeVersion(GAME_VERSION:sub(0, GAME_VERSION:find("%(")-1))

local sharedFileUtils = CCFileUtils:sharedFileUtils()

local searchPathes = {
    "res/", 
    "res/ccb/",
    "res/actor/",
    "res/effect/",
}

local function AddSearchPath(isInWritablePath)
    local externPath = ""
    if isInWritablePath then
        externPath = sharedFileUtils:getWritablePath()
    end
    for _, path in ipairs(searchPathes) do
        sharedFileUtils:addSearchPath(externPath .. path)
    end
end


AddSearchPath(true)
AddSearchPath(false)

loadAllCustomShaders()

resetAudioFunctions(SKIP_PLAY_AUDIO)

local MyApp = class("MyApp", cc.mvc.AppBase)

-- editor
local _,currentModuleName = debug.getlocal(2, 1)
local function __import(moduleName)
    local mod = import(moduleName, currentModuleName)
    return mod
end


-- local QEditorController = import(".editor.QEditorController")
local QNavigationController = import(".controllers.QNavigationController")
local QNavigationManager = import(".controllers.QNavigationManager")
local QNotificationCenter = import(".controllers.QNotificationCenter")
local QStaticDatabase = import(".controllers.QStaticDatabase")

local QHeroModel-- = import(".models.QHeroModel")
local QNpcModel-- = import(".models.QNpcModel")
local QTotemChallengeActorModel-- = import(".models.QNpcModel")
-- local QVCRNpcModel = import(".vcr.models.QVCRNpcModel")
local QUserData = import(".utils.QUserData")
local QCCBNodeCache = import(".utils.QCCBNodeCache")
local QClient = import(".network.QClient")
local QRemote = import(".models.QRemote")
local QUpdateStaticDatabase = import(".network.QUpdateStaticDatabase")
-- local QPromptTips = import(".utils.QPromptTips")
local QTips = import(".utils.QTips")
local QSound = import(".utils.QSound")
local QMaster = import(".utils.QMaster")
local QSystemSetting = import(".controllers.QSystemSetting")
local QProtocol = import(".network.QProtocol")
local QBulletinData = import(".models.chatdata.QBulletinData")
local QServerChatData = import(".models.chatdata.QServerChatData")
local QNotice = import(".utils.QNotice")
local QUnlock = import(".utils.QUnlock")
local QLogFile = import(".utils.QLogFile")
local QMyAppUtils = import(".utils.QMyAppUtils")
local QBackdoor = import(".network.QBackdoor")
local QRecordUserOperate = import(".utils.QRecordUserOperate")
local QAlarmClock = import(".utils.QAlarmClock")
local QFunnyController = import(".funnyzone.QFunnyController")
local QVIPUtil = import(".utils.QVIPUtil")
local QGray = import(".utils.QGray") 
local QVideoPlayer = import(".video.QVideoPlayer")
local QTaskEvent = import(".utils.QTaskEvent")
local QUdpManager = import(".network.QUdpManager")
local QUpdateManager = import(".network.update.QUpdateManager")
local QUpdateDownloaderAdapter = import(".network.update.QUpdateDownloaderAdapter")
local QExtraProp = import(".models.QExtraProp")

-- 远程数据挂载点
remote = QRemote.new()

local QUIScene = import(".ui.QUIScene")
local QUIViewController = import(".ui.QUIViewController")
-- local QUIPageEmpty = import(".ui.pages.QUIPageEmpty")
local QUIWidgetLoading = import(".ui.widgets.QUIWidgetLoading")
-- local QUIDialogGameLogin = import(".ui.dialogs.QUIDialogGameLogin")
-- local QUIPageLogin = import(".ui.pages.QUIPageLogin")

-- tutorial
local QTutorialDirector = import(".tutorial.QTutorialDirector")

-- MyApp.BACKGROUND_TIME_BEFORE_RELAUNCH_WITHOUTDOWNLOAD = 30 * 60 -- 进入后台多久后(单位:秒)下次进入前台时relaunch game without download
MyApp.BACKGROUND_TIME_BEFORE_RELAUNCH = 60 * 60 -- 进入后台多久后(单位:秒)下次进入前台时relaunch game
-- assert(MyApp.BACKGROUND_TIME_BEFORE_RELAUNCH_WITHOUTDOWNLOAD < MyApp.BACKGROUND_TIME_BEFORE_RELAUNCH, "")

MyApp.APPLICATION_ENTER_FOREGROUND_ANDROID_EVENT = "APPLICATION_ENTER_FOREGROUND_ANDROID_EVENT"
MyApp.APPLICATION_ENTER_BACKGROUND_ANDROID_EVENT = "APPLICATION_ENTER_BACKGROUND_ANDROID_EVENT"
MyApp.APPLICATION_RECEIVE_MEMORY_WARNING_EVENT   = "APPLICATION_RECEIVE_MEMORY_WARNING_EVENT"
MyApp.APPLICATION_WILL_TERMINATE                 = "APPLICATION_WILL_TERMINATE"
MyApp.APPLICATION_OPEN_URL                       = "APPLICATION_OPEN_URL"
MyApp.APPLICATION_ENTER_RESUMEMUSIC_EVENT        = "APPLICATION_ENTER_RESUMEMUSIC_EVENT"

function MyApp:ctor()
    MyApp.super.ctor(self)

    display.ui_width = display.width
    display.ui_height = display.height

    QLogFile:init()
    self.vipUtil = QVIPUtil
    self.gray = QGray.new()
    self.udp = QUdpManager.new()

    self._protocol = QProtocol.new()
    table.merge(self, fca)
    self.FcaSetProto(function(data)
        return app:getProtocol():decodeBufferToMessage("anim.character", data)
    end)
 
    
    self:checkGlobalVariable()
    

    local notificationCenter = CCNotificationCenter:sharedNotificationCenter()
    notificationCenter:registerScriptObserver(nil, handler(self, self.onReceiveMemoryWarning), "APP_RECEIVE_MEMORY_WARNING_EVENT")
    notificationCenter:registerScriptObserver(nil, handler(self, self.onAppWillTerminate), "APP_WILL_TERMINATE")
    notificationCenter:registerScriptObserver(nil, handler(self, self.onAppOpenUrl), "APP_OPEN_URL")
    notificationCenter:registerScriptObserver(nil, handler(self, self.changeGLViewSize), "APP_CHANGE_GLVIEW_SIZE")
    notificationCenter:registerScriptObserver(nil, handler(self, self.onEnterResumeMusic), "APPLICATION_ENTER_RESUMEMUSIC_EVENT")

    self._battleLogs = {}
    self._battleRecordList = {}

    self._isSkipVideo = false --是否点击视频跳过了
end

function MyApp:_createUILayer()
    self._uiScene = QUIScene.new()
    display.replaceScene(self._uiScene)
    self._navigationManager = QNavigationManager.new(self._uiScene)
    self._navigationManager:createAndPushALayer("UI Main Navigation")
    self._topLayerPage = self._navigationManager:createAndPushALayer("Mid Layer Navigation")

    self.tutorialNode = CCNode:create()
    self.nociceNode = CCNode:create()
    self.floatForceNode = CCNode:create()
    self._uiScene:addChild(self.tutorialNode)
    self._uiScene:addChild(self.nociceNode)
    self._uiScene:addChild(QUIWidgetLoading.sharedLoading():getView())
    self._thirdLayerPage = self._navigationManager:createAndPushALayer("Third Layer Navigation", true)
    self._uiScene:addChild(self.floatForceNode)

    self:updateUIMaskLayer()

    self.mainUILayer = 1
    self.middleLayer = 2
    self.topLayer = 3
end

function MyApp:start()
    math.randomseed(q.OSTime())
    if DEBUG > 0 and CHECK_SKELETON_FILE == true then
        self:_checkResources()
    end
    if CURRENT_MODE == EDITOR_MODE then
        self:_startEditor()
    elseif CURRENT_MODE == GAME_MODE then
        self:_startGame() 
    elseif CURRENT_MODE == ANIMATION_MODE then
        self:_startEditor()
    end

    -- 考虑到复盘的性能，交换一下app.random和math.random的实现
    local _count = 0
    local _random = math.random
    self.random = function(...)
        local result = _random(...)
        _count = _count + 1
        return result
    end
    local _math_randomseed = math.randomseed
    self.randomseed = function(...)
        _count = 0
        return _math_randomseed(...)
    end
    app.randomseed(q.OSTime())
    self.randomCount = function()
        return _count
    end
    local random = createRandomGenerator(q.OSTime())
    math.random = random
    math.randomseed = random.setSeed

    if setAutoBatchNode then
        setAutoBatchNode(true)
    end
    if setSpriteCheckInCamera then
        setSpriteCheckInCamera(display.contentScaleFactor >= 1) --ipad下分辨率有问题，等两个版本之后再设置为true即可 --8月20日
    end
end

function MyApp:_checkResources()
    -- effect
    for _, effectId in ipairs(staticDatabase:getEffectIds()) do
        local frontFile, backFile = staticDatabase:getEffectFileByID(effectId)
        if frontFile ~= nil then
            printInfo("chack effect resource: " .. frontFile)
            local skeletonFile = frontFile .. ".json"
            local atlasFile = frontFile .. ".atlas"
            QSkeletonDataCache:sharedSkeletonDataCache():cacheSkeletonData(skeletonFile, atlasFile)
        end
        if backFile ~= nil then
            printInfo("chack effect resource: " .. backFile)
            local skeletonFile = backFile .. ".json"
            local atlasFile = backFile .. ".atlas"
            QSkeletonDataCache:sharedSkeletonDataCache():cacheSkeletonData(skeletonFile, atlasFile)
        end
    end
end

function MyApp:_exitForUpdate()
    printInfo("您的版本太低，请下载安装新版本")
    self:alert({content="您的版本太低，请下载安装新版本",title="系统提示",callBack=nil,comfirmBack=nil})
end

function MyApp:_startEditor()
    QStaticDatabase.sharedDatabase()

    -- editor
    local QEditorController = __import(".editor.QEditorController")

    self._objects = {}
    self._userData = QUserData.new()
    self._systemSetting = QSystemSetting.new()
    self.tutorial = QTutorialDirector.new()
    self.tip = QTips.new()
    self.sound = QSound.new()
    self.master = QMaster.new()
    self.notice = QNotice.new()
    self.unlock = QUnlock.new()
    self.editor = QEditorController.new()
    self.taskEvent = QTaskEvent.new()
    self.extraProp = QExtraProp.new()
    self.editor:start()
    -- self.notice:didappear()
end

function MyApp:_startGame()
    self:calculateUIViewSize()

    QLogFile:info("--------------------- Game Launched --------------------- ")
    QLogFile:info(function ( ... )
        return string.format("Version: %s Device: %s", GAME_VERSION, FinalSDK.getDeviceUUID() and FinalSDK.getDeviceUUID() or "")
    end)
    if DUMP_ALLOCATOR_INFO and CCDumpAllocatorInfo ~= nil then
        self._allocatorInfoUpdate = scheduler.scheduleGlobal(function ()
            CCDumpAllocatorInfo()
        end, 10.0)
    end

    --埋点 打开游戏
    remote:triggerBeforeStartGameBuriedPoint("10010")

    -- Set bugly version and channel
    if buglyLuaPutUserData then
        buglyLuaPutUserData("version", GAME_VERSION)
    end

    self:_createUILayer()
    self._ignoreLoadingAnyway = false

    GlobalVal.native_version = GAME_VERSION:match("%((.+)%)")
    if GlobalVal.native_version and QUtility:getNativeCodeVersion() and GlobalVal.native_version ~= QUtility:getNativeCodeVersion() then
        -- local n_version = string.split(GlobalVal.native_version, ".")
        -- local majorV, minorV, buildV = n_version[1], n_version[2], n_version[3]
        -- local n_version2 = string.split(QUtility:getNativeCodeVersion(), ".")
        -- local majorV2, minorV2, buildV2 = n_version2[1], n_version2[2], n_version2[3]

        -- if majorV ~= majorV2 then
        --     return self:_exitForUpdate()
        -- else
            QLogFile:info(function ( ... )
                return string.format("Native version is not consistent. %s : %s", GlobalVal.native_version, QUtility:getNativeCodeVersion())
            end)
        -- end
    end

    local _initializeFun = function ()
        self:checkPlayMp4(function()
            app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_PAGE, uiClass="QUIPageLogin", 
                options = {showEffect = true}})
            self:_initialize()
        end)
    end

    if device.platform == "ios" then 
        local ccbOwner = {}
        local logo 
        if CHANNEL_RES["useNewFlash"] then
            logo = CCBuilderReaderLoad("ccb/Dialog_health_tip.ccbi", CCBProxy:create(), ccbOwner)
        else
            logo = CCBuilderReaderLoad("ccb/Dialog_LogoIn.ccbi", CCBProxy:create(), ccbOwner)
        end
        
        self._uiScene:addChild(logo)
        logo:setPosition(display.cx, display.cy)
        logo:setVisible(false)
        -- end
        local actions = CCArray:create()
        if self:isDeliveryIntegrated() == true then
            local function _executeInitialize()
                if self:isDeliverySDKInitialzed() ~= true then
                    QDeliveryWrapper:startHandleError(handler(self, self._onReceiveDeliveryError))
                    FinalSDK:initialize(_initializeFun())
                else
                    _initializeFun()
                end
            end
            if CHANNEL_RES["useNewFlash"] then
                logo:setVisible(true)
                actions:addObject(CCDelayTime:create(1.6))
                actions:addObject(CCCallFunc:create(_executeInitialize))
            else
                local logo_path
                if CHANNEL_RES["flashPage"] then
                    logo_path = CHANNEL_RES["flashPage"]
                end
                if CHANNEL_RES and CHANNEL_RES["envName"] and CHANNEL_RES["envName"] == "whjx_239" then
                    logo_path = "ui/Login/dlxls.png"
                end
                if logo_path then -- 指定第二闪屏
                    local sprite = CCSprite:create(logo_path)
                    if sprite then
                        sprite:setAnchorPoint(ccp(0.5, 0.5))
                        ccbOwner.node_logo:removeAllChildren()
                        ccbOwner.node_logo:addChild(sprite)
                    end
                end
                if FinalSDK.showLogo() then
                    if CHANNEL_RES and CHANNEL_RES["envName"] and CHANNEL_RES["envName"] == "dljxol_238" and device.platform == "ios" then
                        _executeInitialize()
                    else
                        logo:setVisible(true)
                        actions:addObject(CCDelayTime:create(1.6))
                        actions:addObject(CCCallFunc:create(_executeInitialize))
                    end
                else
                    _executeInitialize()
                end
            end
        else
            logo:setVisible(true)
            actions:addObject(CCDelayTime:create(1.6))
            actions:addObject(CCCallFunc:create(_initializeFun))
        end
        actions:addObject(CCRemoveSelf:create(true))
        logo:runAction(CCSequence:create(actions))  
    elseif device.platform == "android" then
        local ccbOwner = {}
        local logo = CCBuilderReaderLoad("ccb/Dialog_health_tip.ccbi", CCBProxy:create(), ccbOwner)
        self._uiScene:addChild(logo)
        logo:setPosition(display.cx, display.cy)
        logo:setVisible(true)
        local actions = CCArray:create()

        if self:isDeliveryIntegrated() == true then
            -- local function _executeInitialize()
                -- if self:isDeliverySDKInitialzed() then
                --     QDeliveryWrapper:startHandleError(handler(self, self._onReceiveDeliveryError))
                --     _initializeFun()
                -- end
                --此处的scheduler别删除
                self._androidInitScheduler = scheduler.scheduleGlobal(function ( ... )
                    if self:isDeliverySDKInitialzed() then
                        QDeliveryWrapper:startHandleError(handler(self, self._onReceiveDeliveryError))
                        _initializeFun()
                        if self._androidInitScheduler then
                            scheduler.unscheduleGlobal(self._androidInitScheduler)
                            self._androidInitScheduler = nil
                        end
                    end
                end, 2)
            -- end
            actions:addObject(CCDelayTime:create(1.6))
            -- actions:addObject(CCCallFunc:create(_executeInitialize))
        else
            actions:addObject(CCDelayTime:create(1.6))
            actions:addObject(CCCallFunc:create(_initializeFun))
        end
        actions:addObject(CCRemoveSelf:create(true))
        logo:runAction(CCSequence:create(actions))   
    else
        local ccbOwner = {}
        local logo = CCBuilderReaderLoad("ccb/Dialog_health_tip.ccbi", CCBProxy:create(), ccbOwner)
        self._uiScene:addChild(logo)
        logo:setPosition(display.cx, display.cy)
        logo:setVisible(true)
        
        local actions = CCArray:create()
        if self:isDeliveryIntegrated() == true then
            QDeliveryWrapper:startHandleError(handler(self, self._onReceiveDeliveryError))

            actions:addObject(CCDelayTime:create(1.6))
            actions:addObject(CCCallFunc:create(function ()
                QDeliveryWrapper:initialize(function()
                    scheduler.performWithDelayGlobal(function()
                        _initializeFun()
                    end, 0.5)
                end)
            end))
        else
            actions:addObject(CCDelayTime:create(1.6))
            actions:addObject(CCCallFunc:create(_initializeFun))
        end
        actions:addObject(CCRemoveSelf:create(true))
        logo:runAction(CCSequence:create(actions))   
    end
end

function MyApp:calculateUIViewSize()
    if display.width > UI_VIEW_MIN_WIDTH then
        local width = display.width
        local height = display.height     
        if width > height * 2 then
            self:updateUIViewSize(CCSize(height * 2, height))
        else
            self:updateUIViewSize(CCSize(width, height))
        end
    else
        self:updateUIViewSize(CCSize(display.width, display.height))
    end
end

function MyApp:checkLuaVMLeaks()
    assert(#self.snapshots_ >= 2, "AppBase:checkLuaVMLeaks() - need least 2 snapshots")
    local s1 = self.snapshots_[1]
    local s2 = self.snapshots_[2]
    for k, v in pairs(s2) do
        if s1[k] == nil then
            trace(tostring(k).." ".. tostring(v))
        end
    end
    return self
end

function MyApp:_initialize()
    -- if self:isDeliveryIntegrated() == true then
    --     -- if self:isDeliverySDKInitialzed() ~= true then
    --     --     return
    --     -- else
    --     --     -- Move this call to inner-update completed to prevent sending event twice -- qinyuanji
    --     --     -- app:sendGameEvent(GAME_EVENTS.GAME_EVENT_INIT_ENDED)
    --     -- end

    --     -- if self:isDeliveryEnvAvailable() then
    --     --     if QDeliveryWrapper.getDeliveryExtend3 then
    --     --         local versionExtend = QDeliveryWrapper:getDeliveryExtend3()
    --     --         if versionExtend and versionExtend ~= "" and versionExtend ~= "0" then
    --     --             VERSION_URL = versionExtend
    --     --         end
    --     --     end
    --     -- end
    --     if self:isDeliveryYwmb() then
    --         if 
    --     end
    -- end


   

    QLogFile:info(function ( ... )
        return string.format("MyApp: delivery extend param: %s", QDeliveryWrapper:getDeliveryExtend())
    end)

    -- reload static database will cost more than 1 second or even more on android. 
    -- so popup a page before load database.
    if ENABLE_NEW_UPDATE then
        self.updateManager = QUpdateManager.new()
    else
        self._updater = QUpdateStaticDatabase.new()
    end
    
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogUpdate"})
    
    self._lastTimeEnterBackground = nil
    self._isClearSkeletonData = true

    self:enableTextureCacheScheduler()

    self._isLogin = false
    self._autoLogin = false


    scheduler.performWithDelayGlobal(function()
        if QDeliveryWrapper.closeLogo then
            QDeliveryWrapper:closeLogo()
        end
    end, 0)

    -- Check new version update is mandatory
    if self:isDeliveryIntegrated() and device.platform == "android" then
        local extend = QDeliveryWrapper:getDeliveryExtend()  
        if DEBUG_YOUZU_EXTEND then
            extend = DEBUG_YOUZU_EXTEND
        end
        local ids = string.split(extend, "|") -- ids[1] is opId, ids[2] is gameId, ids[3] is gameOpId

        local force, url = self:checkNewVersionUpdate(ids[1], ids[3], QUtility:getNativeCodeVersion())
        if force == true and url and url ~= "" then
            app:alert({content = "魂师大人，版本已更新，请重新下载客户端进入游戏，点击前往下载页面~", title = "系统提示", 
                    callback = function(state)
                        if state == ALERT_TYPE.CONFIRM then
                            if buglyReportLuaException then
                                buglyReportLuaException(string.format("Mandatory update package. OpId %s, gameOpId %s, url %s", ids[1], ids[3], url), "")
                            end

                            QUtility:openURL(url)
                        end
                    end, isAnimation = false}, true, true)          
        else
            self:_updatePreFun()
        end
    else
        self:_updatePreFun()
    end
end

function MyApp:checkNewVersionUpdate(opId, gameOpId, version)
    local param = string.format("/json_req?action=appUpdateVerify&opgameId=%s&opId=%s&appVersion=%s", gameOpId, opId, version)
    QLogFile:debug(function ( ... )
        return LOGINHISTORY_URL..param
    end)

    local response_body = {}  
    local res, code = http.request({  
      url = LOGINHISTORY_URL..param,  
      sink = ltn12.sink.table(response_body)  
    }) 

    response_body = table.concat(response_body)
    local data = json.decode(response_body)

    if data then 
        QLogFile:debug(function ( ... )
            return string.format("Found latest version %s, url %s, force %s", data.latestVersion, data.updateUrl, data.forceUpdate)
        end)

        return data.forceUpdate, data.updateUrl
    else
        QLogFile:info(function ( ... )
            return string.format("Can not get latest version information. OpId %s, gameOpId %s", opId, gameOpId)
        end)

        return false, nil
    end
end

function MyApp:afterSDKLogin(resetDisable)
    local callback = function ()
        if nil == resetDisable then resetDisable = false end
        self._isLogin = false
        if not resetDisable then
            self:_resetBeforeRelogin()
        end

        if QUICK_LOGIN.isQuick then
            self:loginByQuickUser()
            return
        end
        if self:isDeliverySDKInitialzed() then
            print("login with delivery Yuewen")
            self._client = QClient.new()
            self:_loginWithDelivery()
        else
            local serverLocation = string.split(SERVER_URL, ":")
            printTable(serverLocation)
            self._client = QClient.new(serverLocation[1], serverLocation[2])
            self._client:open(function()
                -- If there is any delivery integrated, do not show the login dialog of our own
                self:_loginWithoutDelivery()
            end, 

            function()

            end)
        end
    end

    if CHANNEL_RES and CHANNEL_RES["envName"] and CHANNEL_RES and CHANNEL_RES["envName"] and (CHANNEL_RES["envName"] == "dljxol_238" or CHANNEL_RES["envName"] == "dljxol_266" or CHANNEL_RES["envName"] == "dljxol_267") then
        -- post 一个idfa
        local client_id = "346"
        local timeStamp = math.floor(q.serverTime() * 1000)
        local idfa = ""
        if QUtility.getIDFA then
            idfa = QUtility:getIDFA()
        end

        local url = "http://open.douyouzhiyu.com/v2/douluoIdfa"
        local param = string.format("client_id=%s&timestamp=%s&idfa=%s",client_id, timeStamp, idfa)
        local respbody = httpPost(url,param,2)
   end

    if FinalSDK.isLenovo() then
        local data = self:getAccountStatus()
        if data then
            if data.status == 0 then
                local authorizeExpr = data.authorizeExpr
                local nums = string.split(authorizeExpr, ";")
                if #nums == 3 then
                    local num1 = tonumber(nums[1])
                    local num2 = tonumber(nums[3])
                    local caculate = tonumber(nums[2])
                    self._navigationManager:pushViewController(self.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogLoginVerify", options = {num1 = num1, num2 = num2, caculate = caculate, callback = callback}})
                end
            else
                callback()    
            end
        else
            callback()
        end
    else
        callback()
    end
    
end

function MyApp:getAccountStatus()
    local accountUrl = self:getAccountStatusUrl()
    local accountStatusJson = httpGet(accountUrl, 1)
    if accountStatusJson == nil then return end
    local data = json.decode(accountStatusJson)
    return data
    
end

function MyApp:getAccountStatusUrl()
    local channelId = FinalSDK.getChannelID()
    local userAccount = FinalSDK.getSessionId()
    local timestamp = math.floor(q.serverTime() * 1000)
    local sign = crypto.md5("opId="..channelId.."&timestamp="..timestamp.."&userAccount="..userAccount.."56M5RJWNLqCqPGxsFGfh")
    return LOGINHISTORY_URL..string.format("/account_status?userAccount=%s&timestamp=%s&opId=%s&sign=%s", userAccount,timestamp, channelId, sign)
end

--直接登陆区服
function MyApp:loginByQuickUser()
    local serverLocation = string.split(SERVER_URL, ":")
    self._client = QClient.new(QUICK_LOGIN.gameArea..".dldl.joybest.com.cn", 9228)
    self._client:open(function()
        self._isLogin = true
        remote.user:update({name = QUICK_LOGIN.osdkUserId})

        self._bulletinData = QBulletinData.new()
        self._serverChatData = QServerChatData.new(100)
        self._backdoor = QBackdoor.new()

        remote.user.isLoginFrist = false
        QDeliveryWrapper:openFloatWidget(0, 50)
        
        self._navigationManager:pushViewController(self.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogEnterGame", options={userName=self:getUserName()}})
    end)
end

function MyApp:_updatePreFun( ... )
    if ENABLE_NEW_UPDATE then
        self.updateManager:addEventListener(self.updateManager.EVENT_COMPLETE, handler(self, self.updateCompleteHandler))
        local updateAdapter = QUpdateDownloaderAdapter.new()
        self.updateManager:startWithAdapter(updateAdapter)
    else
        self:_updateAndLogin()
    end
end

function MyApp:_updateAndLogin()
    local updater = self._updater
    local updateProxy = cc.EventProxy.new(updater)
    updateProxy:addEventListener(QUpdateStaticDatabase.STATUS_COMPLETED, function(event)
        updateProxy:removeAllEventListeners()
        QUIWidgetLoading.sharedLoading():hide()
        QUIWidgetLoading.sharedLoading()._ccbOwner.node_text:setOpacity(255)

        -- 有新下载完成则重新启动
        if event.count > 0 then
            -- 所有下载已经完成，回收QDownload的资源
            print("ready relaunch")
            updater:purge()
            remote:triggerBeforeStartGameBuriedPoint("10020")
            app:relaunchGame(true)
            return
        else
            -- 所有下载已经完成，回收QDownload的资源
            --拉取 公告
            -- self:getAnnouncement() 
            updater:changeConfigByServerConfig()
            updater:purge()
        end

        QUIWidgetLoading.sharedLoading():Show()
        QUIWidgetLoading.sharedLoading():setCustomString("读取 0%")
        QStaticDatabase.setInitProgressFunc(function (progress)
            -- body
            QUIWidgetLoading.sharedLoading():setCustomString(string.format("读取 %d%%", math.floor(progress * 90)))
        end)
        app._database = nil
        local function loadStaticEnd()
            -- body
            -- pre-load files
            -- app:sendGameEvent(GAME_EVENTS.GAME_EVENT_INIT_ENDED)

            self._objects = {}
            self._userData = QUserData.new()
            self._systemSetting = QSystemSetting.new()
            self.tutorial = QTutorialDirector.new()
            if not ENABLE_CCB_TO_LUA then
                self.ccbNodeCache = QCCBNodeCache.new()
            end
            self.tip = QTips.new()
            self.sound = QSound.new()
            self.master = QMaster.new()
            self.notice = QNotice.new()
            self.unlock = QUnlock.new()
            self.notice:didappear()
            self.funny = QFunnyController.new()
            self.taskEvent = QTaskEvent.new()
            self.extraProp = QExtraProp.new()

            self._userData:setValueForKey("SERVER_URL", SERVER_URL)
            self._userData:setValueForKey("STATIC_URL", STATIC_URL)

            -- if device.platform == "ios" or device.platform == "android" then
            --     local normalQuit = self._userData:getValueForKey("NORMAL_QUIT")
            --     if normalQuit and tonumber(normalQuit) == 0 then
            --         QLogFile:error("Application has an unexpected quit")
            --         if buglyReportLuaException then
            --             buglyReportLuaException("Application has an unexpected quit", "")
            --         end
            --     end
            --     self._userData:setValueForKey("NORMAL_QUIT", 0)
            -- end

            self:setMusicSound()
            if FinalSDK.isHXShenhe() then
                self:getSystemSetting():setMusicState("off")
                self:getSystemSetting():setSoundState("off")
                self:setMusicSound(2)
            end


            QUIWidgetLoading.sharedLoading():Hide()
            QUIWidgetLoading.sharedLoading():setCustomString("加载中")
             
            QStaticDatabase.setInitProgressFunc(nil)
            QStaticDatabase.setLoadEndFunc(nil)

            local function initComponents( ... )
                local appProxy = cc.EventProxy.new(self)
                appProxy:addEventListener(self.APP_ENTER_BACKGROUND_EVENT, handler(self, self._onEnterBackground))
                appProxy:addEventListener(self.APP_ENTER_FOREGROUND_EVENT, handler(self, self._onEnterForeground))
                appProxy:addEventListener(self.APPLICATION_ENTER_BACKGROUND_ANDROID_EVENT, handler(self, self._onEnterBackground))
                appProxy:addEventListener(self.APPLICATION_ENTER_FOREGROUND_ANDROID_EVENT, handler(self, self._onEnterForeground))
                appProxy:addEventListener(self.APPLICATION_RECEIVE_MEMORY_WARNING_EVENT, handler(self, self._onReceiveMemoryWarning))

                self._appProxy = appProxy

                QUIWidgetLoading.sharedLoading():setCustomString("加载中", true)
                -- nie  加入lua 代码自动reload 工具 仅在开发使用

                if ENABLE_LOAD_DEVELOP_TOOLS then
                    local QAutoReloadChangeFile = require("app.developTools.QAutoReloadChangeFile")
                    QAutoReloadChangeFile.new()
                    
                end

            end

            -- app:sendGameEvent(GAME_EVENTS.GAME_EVENT_ENTER_LOGIN_PAGE)
            if self:isDeliveryIntegrated() == true then
                initComponents()
                QDeliveryWrapper:startHandleError(handler(self, self._onReceiveDeliveryError))
                self._navigationManager:pushViewController(self.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogEnterGame"})

                self._loginCallback = function ( ... )
                    QLogFile:debug("MyApp: loginCallback " .. tostring(self._isLogin))
                    remote:triggerBeforeStartGameBuriedPoint("10040")
                    self:showLoading()
                    self._navigationManager:popViewController(self.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
                    scheduler.performWithDelayGlobal(function()
                        self:afterSDKLogin()
                    end, 1.5)
                end
                remote:triggerBeforeStartGameBuriedPoint("10030")
                FinalSDK:login(self._loginCallback)
            else
                initComponents()
                self:afterSDKLogin(true)
            end
        end

        QStaticDatabase.setLoadEndFunc(loadStaticEnd)
        QStaticDatabase.sharedDatabase()

    end)
    
    updateProxy:addEventListener(QUpdateStaticDatabase.STATUS_FAILED, function()
        QUIWidgetLoading.sharedLoading():hide()
        self:alert({title = "网络错误", content = "无法下载最新的配置，请稍后重试", callBack = function()
            updater:update(false)
        end})
    end)

    local updateDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    updateDialog:enableStartGameButton(function ()
        updateDialog:disableStartGameButton()
        updater:update(false)
    end)
    
end

function MyApp:updateCompleteHandler(event)
    self.updateManager:removeAllEventListeners()
    QUIWidgetLoading.sharedLoading():hide()
    QUIWidgetLoading.sharedLoading()._ccbOwner.node_text:setOpacity(255)

    -- 有新下载完成则重新启动
    if event.count > 0 then
        -- 所有下载已经完成，回收QDownload的资源
        self.updateManager:removeAdapter()
        print("ready relaunch")
        remote:triggerBeforeStartGameBuriedPoint("10020")
        app:relaunchGame(true)
        return
    else
        -- 所有下载已经完成，回收QDownload的资源
        --拉取 公告
        -- self:getAnnouncement() 
        -- updater:changeConfigByServerConfig()
        self.updateManager:changeConfigByServerConfig()
        self.updateManager:removeAdapter()
    end


    QUIWidgetLoading.sharedLoading():Show()
    QUIWidgetLoading.sharedLoading():setCustomString("读取 0%")
    QStaticDatabase.setInitProgressFunc(function (progress)
        -- body
        QUIWidgetLoading.sharedLoading():setCustomString(string.format("读取 %d%%", math.floor(progress * 90)))
    end)
    app._database = nil
    local function loadStaticEnd()
        -- body
        -- pre-load files
        -- app:sendGameEvent(GAME_EVENTS.GAME_EVENT_INIT_ENDED)

        self._objects = {}
        self._userData = QUserData.new()
        self._systemSetting = QSystemSetting.new()
        self.tutorial = QTutorialDirector.new()
        if not ENABLE_CCB_TO_LUA then
            self.ccbNodeCache = QCCBNodeCache.new()
        end
        self.tip = QTips.new()
        self.sound = QSound.new()
        self.master = QMaster.new()
        self.notice = QNotice.new()
        self.unlock = QUnlock.new()
        self.notice:didappear()
        self.funny = QFunnyController.new()
        self.taskEvent = QTaskEvent.new()
        self.extraProp = QExtraProp.new()

        self._userData:setValueForKey("SERVER_URL", SERVER_URL)
        self._userData:setValueForKey("STATIC_URL", STATIC_URL)

        -- if device.platform == "ios" or device.platform == "android" then
        --     local normalQuit = self._userData:getValueForKey("NORMAL_QUIT")
        --     if normalQuit and tonumber(normalQuit) == 0 then
        --         QLogFile:error("Application has an unexpected quit")
        --         if buglyReportLuaException then
        --             buglyReportLuaException("Application has an unexpected quit", "")
        --         end
        --     end
        --     self._userData:setValueForKey("NORMAL_QUIT", 0)
        -- end

        self:setMusicSound()
        if FinalSDK.isHXShenhe() then
            self:getSystemSetting():setMusicState("off")
            self:getSystemSetting():setSoundState("off")
            self:setMusicSound(2)
        end


        QUIWidgetLoading.sharedLoading():Hide()
        QUIWidgetLoading.sharedLoading():setCustomString("加载中")
         
        QStaticDatabase.setInitProgressFunc(nil)
        QStaticDatabase.setLoadEndFunc(nil)

        local function initComponents( ... )
            local appProxy = cc.EventProxy.new(self)
            appProxy:addEventListener(self.APP_ENTER_BACKGROUND_EVENT, handler(self, self._onEnterBackground))
            appProxy:addEventListener(self.APP_ENTER_FOREGROUND_EVENT, handler(self, self._onEnterForeground))
            appProxy:addEventListener(self.APPLICATION_ENTER_BACKGROUND_ANDROID_EVENT, handler(self, self._onEnterBackground))
            appProxy:addEventListener(self.APPLICATION_ENTER_FOREGROUND_ANDROID_EVENT, handler(self, self._onEnterForeground))
            appProxy:addEventListener(self.APPLICATION_RECEIVE_MEMORY_WARNING_EVENT, handler(self, self._onReceiveMemoryWarning))

            self._appProxy = appProxy

            QUIWidgetLoading.sharedLoading():setCustomString("加载中", true)
            -- nie  加入lua 代码自动reload 工具 仅在开发使用

            if ENABLE_LOAD_DEVELOP_TOOLS then
                local QAutoReloadChangeFile = require("app.developTools.QAutoReloadChangeFile")
                QAutoReloadChangeFile.new()
                
            end

        end

        -- app:sendGameEvent(GAME_EVENTS.GAME_EVENT_ENTER_LOGIN_PAGE)
        if self:isDeliveryIntegrated() == true then
            initComponents()
            QDeliveryWrapper:startHandleError(handler(self, self._onReceiveDeliveryError))
            self._navigationManager:pushViewController(self.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogEnterGame"})

            self._loginCallback = function ( ... )
                QLogFile:debug("MyApp: loginCallback " .. tostring(self._isLogin))
                remote:triggerBeforeStartGameBuriedPoint("10040")
                self:showLoading()
                self._navigationManager:popViewController(self.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
                scheduler.performWithDelayGlobal(function()
                    self:afterSDKLogin()
                end, 1.5)
            end
            remote:triggerBeforeStartGameBuriedPoint("10030")
            FinalSDK:login(self._loginCallback)
        else
            initComponents()
            self:afterSDKLogin(true)
        end
    end

    QStaticDatabase.setLoadEndFunc(loadStaticEnd)
    QStaticDatabase.sharedDatabase()
end

function MyApp:login()
    local callback = function()
        self.sound:playMusic("main_interface")
        if self:isDeliverySDKInitialzed() then
            self._loginCallback = function ( ... )
                QLogFile:debug("MyApp: loginCallback " .. tostring(self._isLogin))
                remote:triggerBeforeStartGameBuriedPoint("10040")
                self:showLoading()
                self._navigationManager:popViewController(self.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
                scheduler.performWithDelayGlobal(function()
                    self:afterSDKLogin()
                end, 1.5)
            end
            remote:triggerBeforeStartGameBuriedPoint("10030")
            FinalSDK:login(self._loginCallback)
        end
    end

    callback()
end

function MyApp:_loginWithoutDelivery()
    local autoLogin = self._userData:getValueForKey(QUserData.AUTO_LOGIN)
    local my_acc = self:getUserName()
    local my_pass = self:getPassword()

    local callback = function()
        self.sound:playMusic("main_interface")
        if self:isDeliverySDKInitialzed() then
            print("********** MyApp _loginWithoutDelivery login yw ")
            self._loginCallback = function ( ... )
                QLogFile:debug("MyApp: loginCallback " .. tostring(self._isLogin))
                remote:triggerBeforeStartGameBuriedPoint("10040")
                self:showLoading()
                self._navigationManager:popViewController(self.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
                scheduler.performWithDelayGlobal(function()
                    self:afterSDKLogin()
                end, 1.5)
            end
            remote:triggerBeforeStartGameBuriedPoint("10030")
            FinalSDK:login(self._loginCallback)
        else
            if my_acc ~= nil and my_pass ~= nil and autoLogin and autoLogin == QUserData.STRING_TRUE then 
                -- 自动登入
                self:_login(my_acc, my_pass)
                self._autoLogin = true
            else
                self._navigationManager:pushViewController(self.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGameLogin"})
            end
        end
    end
    callback()
end

function MyApp:checkPlayMp4(callback)
    if not self._isPlayedMp4 then
        self._isPlayedMp4 = self._userData:getValueForKey(QUserData.SKIP_OP_VIDEO) or QUserData.STRING_FALSE
    end

    if self._isPlayedMp4 == QUserData.STRING_TRUE or not self:playOpVideoMp4(callback) then
        callback()
        return
    else
        self._isPlayedMp4 = QUserData.STRING_TRUE
        self._userData:setValueForKey(QUserData.SKIP_OP_VIDEO, self._isPlayedMp4)
    end
end

function MyApp:playOpVideoMp4(callback)
    if not VideoPlayer then
        return false
    end

    local src = "res/video/opvideo.mp4"
    local path = sharedFileUtils:fullPathForFilename(src)
    if sharedFileUtils:isFileExist(path) then
        self:playMp4( {src = src}, function()
                if self._isSkipVideo then
                    remote:triggerBeforeStartGameBuriedPoint("10041")
                else
                    remote:triggerBeforeStartGameBuriedPoint("10042")
                end
                if callback then
                    callback()
                end
            end )
        return true
    end
    return false
end

function MyApp:playMp4( cfg, callback )
    local tiaoguoBar, videoPlayer
    local endCallback = function()
        local arr = CCArray:create()
        arr:addObject(CCDelayTime:create(0.1))
        arr:addObject(CCCallFunc:create(function()
            if videoPlayer then   
                videoPlayer:stop()
                videoPlayer:removeFromParentAndCleanup(true)
                videoPlayer = nil
            end
            if callback then
                callback()
            end
        end))
        self._uiScene:runAction(CCSequence:create(arr))
    end

    videoPlayer = QVideoPlayer.new()
    videoPlayer:setPosition(ccp(0, 0))
    videoPlayer:setFullScreenEnabled(true)
    videoPlayer:setKeepAspectRatioEnabled(true)
    videoPlayer:setFileName(cfg.src)
    videoPlayer:setCompletedCallback(function()
        if self._isSkipVideo == true then return end
        if tiaoguoBar then
            tiaoguoBar:removeFromParentAndCleanup(true)
            tiaoguoBar = nil
        end
        endCallback()
    end)
    videoPlayer:play()
    self._isSkipVideo = false
    self._uiScene:addChild(videoPlayer)

    if device.platform == "mac" or device.platform == "windows" then
        local ccbOwner = {}
        ccbOwner.onClickTiaoguo = function()
            self._isSkipVideo = true
            if tiaoguoBar then
                tiaoguoBar:removeFromParentAndCleanup(true)
                tiaoguoBar = nil
            end
            endCallback()
        end
        tiaoguoBar = CCBuilderReaderLoad("Battle_But_Tiaoguo.ccbi", CCBProxy:create(), ccbOwner)
        tiaoguoBar:setPosition(ccp(display.width-60, 30))
        self._uiScene:addChild(tiaoguoBar)
    end
end

function MyApp:_loginWithDelivery()
    -- self._navigationManager:popViewController(self.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
    local callback = function ()
        -- body
        if self:isDeliveryYwmb() or self:isDeliveryHX() then
            self:_loginWithYuewenDelivery()
        elseif self:isDeliveryHJ() then
            --todo
            self:_loginWithHJDelivery()
        else
            -- waitting for connect and login game
            self._waitForClientReadyScheduler = scheduler.scheduleGlobal(function()
                if self:getClient():isReady() == true then

                    scheduler.unscheduleGlobal(self._waitForClientReadyScheduler)
                    self._waitForClientReadyScheduler = nil

                    local my_acc = FinalSDK.getAccoundID()
                    local my_pass = FinalSDK.getSessionId()
                    self:_login(my_acc, my_pass)
                else
                    printInfo("waitting for client ready!")
                end
            end, 0.1)
        end
    end
    callback()
end

function MyApp:_loginWithYouzuDelivery()
    local my_acc = FinalSDK.getAccoundID()
    local my_pass = FinalSDK.getSessionId()
    self:_login(my_acc, my_pass)
end

function MyApp:_loginWithYuewenDelivery()
    local my_acc = FinalSDK.getSessionId()
    local my_pass = "yuewen"
    self:_login(my_acc, my_pass)
end

function MyApp:_loginWithHJDelivery()
    local my_acc = FinalSDK.getAccoundID()
    local my_pass = FinalSDK.getSessionId()
    self:_login(my_acc, my_pass)
end

function MyApp:_resetBeforeRelogin()
    -- if app.battle then
    --     CCDirector:sharedDirector():popScene()
    -- end
    self._userOperateRecord = nil 
    self._isLogin = false
    if self._alarmClock then
        self._alarmClock:clean()
    end
    self._alarmClock = nil
    -- xurui: reset notice
    if self.notice then
        self.notice:disappear()
        self.notice = nil
    end

    -- 重置新手引导
    if self.tutorial then
        self.tutorial:ended()
        self.tutorial = nil
    end

    --xurui reset notificationCenter
    if self._notificationCenter ~= nil then
        self._notificationCenter:removeAllEventListeners()
        self._notificationCenter = nil
    end

    if self.tip then
        self.tip:resetTip()
    end
    if self.prompt then
        self.prompt = nil
    end

    --重置链接
    if self._client then
        self._client:close()
        self._client = nil
    end

    --重置UI层
    QUIWidgetLoading.sharedLoading():getView():retain()
    QUIWidgetLoading.sharedLoading():getView():removeFromParent()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    self._navigationManager:purge()

    if self.extraProp then
        self.extraProp:disappear()
    end
    --重置数据
    remote:disappear()
    self:resetRemote()

    if self.extraProp then
        self.extraProp:didappear()
    end

    self._uiScene:removeAllChildren()
    self._ly_mask_left = nil
    self._ly_mask_right = nil
    
    self._uiScene = QUIScene.new()
    display.replaceScene(self._uiScene)

    self._navigationManager = QNavigationManager.new(self._uiScene)
    self._navigationManager:createAndPushALayer("UI Main Navigation")
    self._topLayerPage = self._navigationManager:createAndPushALayer("Mid Layer Navigation")

    self.tutorialNode = CCNode:create()
    self.nociceNode = CCNode:create()
    self.floatForceNode = CCNode:create()
    self._uiScene:addChild(self.tutorialNode)
    self._uiScene:addChild(self.nociceNode)
    self._uiScene:addChild(QUIWidgetLoading.sharedLoading():getView())
    QUIWidgetLoading.sharedLoading():getView():release()
    self._thirdLayerPage = self._navigationManager:createAndPushALayer("Third Layer Navigation", true)
    self._uiScene:addChild(self.floatForceNode)

    self:updateUIMaskLayer()
    
    --设置非自动登陆
    self._userData:setValueForKey(QUserData.AUTO_LOGIN, QUserData.STRING_FALSE)

    self._hasEnterMainPageBefore = nil

    self.tutorial = QTutorialDirector.new()

    self.notice = QNotice.new()
    self.notice:didappear()

    
    collectgarbageCollect()

    app:cleanTextureCache()
    if HIBERNATE_TEXTURE and CCTextureCache.wakeupAllTextures then
        CCTextureCache:sharedTextureCache():wakeupAllTextures()
    end
    if HIBERNATE_TEXTURE_2 then
        wakeupUselessTextures(dungeonConfig)
    end

    -- 放个背景图在这里
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_PAGE, uiClass="QUIPageLogin"})
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogUpdate"})

    --预加载公告
    self:getAnnouncement()

end

-- Param: 
--      relogin: if logout needs to relogin
function MyApp:_logoutWithDelivery(relogin)
    QLogFile:debug("Logout with delivery, relogin " .. tostring(relogin))
    QLogFile:debug(debug.traceback())

    scheduler.performWithDelayGlobal(function()
        QDeliveryWrapper:closeFloatWidget()

        local function _doLogoutWithDelivery()
            self:_resetBeforeRelogin() 

            local updateDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
            local reloginCall = function ()
                self._navigationManager:pushViewController(self.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogEnterGame"})
                -- app:sendGameEvent(GAME_EVENTS.GAME_EVENT_ENTER_LOGIN_PAGE)
                
                if relogin then
                    self._loginCallback = function ( ... )
                        self:showLoading()
                        updateDialog:disableStartGameButton()
                        self._navigationManager:popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
                        scheduler.performWithDelayGlobal(function()
                            self:afterSDKLogin()
                        end, 1)
                    end
                    FinalSDK:login(self._loginCallback)
                end
            end

            updateDialog:enableStartGameButton(reloginCall)
        end

        if app.battle and self.tutorial and self.tutorial:getRuningStageId() == QTutorialDirector.Stage_1_FirstBattle then
            local runingStage = self.tutorial:getRuningStage()
            if runingStage ~= nil then
                runingStage:jumpFinished()
                scheduler.performWithDelayGlobal(function()
                    scheduler.performWithDelayGlobal(function()
                        _doLogoutWithDelivery()
                    end, 0)
                end, 0)
            end
        elseif app.scene then
            app.scene:setBattleEnded()
            app.scene:cancelMoveSchedule()
            app:exitFromBattleScene(false)
            _doLogoutWithDelivery()
        else
            _doLogoutWithDelivery()
        end

    end, 0.5)
end

function MyApp:_logoutWithYuewen()
    QLogFile:debug("Logout with yuewen, relogin " .. tostring(relogin))
    QLogFile:debug(debug.traceback())

    scheduler.performWithDelayGlobal(function()
        local function _doLogoutWithYuewen()
            self:_resetBeforeRelogin()
            local updateDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
                local reloginCall = function ()

                local serverLocation = string.split(SERVER_URL_GO, ":")
                self._client = QClient.new(serverLocation[1], serverLocation[2])
                self._client:open(function()
                    printInfo("connect success")
                    self._userData:setValueForKey(QUserData.AUTO_LOGIN, QUserData.STRING_FALSE)
                    self:_loginWithoutDelivery()
                end, 
                function() 
                end)
            end
            updateDialog:enableStartGameButton(reloginCall)
        end

        if app.battle and self.tutorial and self.tutorial:getRuningStageId() == QTutorialDirector.Stage_1_FirstBattle then
            local runingStage = self.tutorial:getRuningStage()
            if runingStage ~= nil then
                runingStage:jumpFinished()
                scheduler.performWithDelayGlobal(function()
                    scheduler.performWithDelayGlobal(function()
                        _doLogoutWithYuewen()
                    end, 0)
                end, 0)
            end
        elseif app.scene then
            app.scene:setBattleEnded()
            app.scene:cancelMoveSchedule()
            app:exitFromBattleScene(false)
            _doLogoutWithYuewen()
        else
            _doLogoutWithYuewen()
        end

    end, 0.5)
end

function MyApp:_logoutWithoutDelivery()

    local function _doLogoutWithoutDelivery()
        self:_resetBeforeRelogin()

        local updateDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
        local reloginCall = function ()
            self:showLoading()
            local serverLocation = string.split(SERVER_URL, ":")
            self._client = QClient.new(serverLocation[1], serverLocation[2])
            self._client:open(function()
                    printInfo("connect success")
                    self._userData:setValueForKey(QUserData.AUTO_LOGIN, QUserData.STRING_FALSE)
                    self:_loginWithoutDelivery()
                end, 
                function() 
                end)
            end

        updateDialog:enableStartGameButton(reloginCall)
    end

    if app.battle and self.tutorial and self.tutorial:getRuningStageId() == QTutorialDirector.Stage_1_FirstBattle then
        local runingStage = self.tutorial:getRuningStage()
        if runingStage ~= nil then
            runingStage:jumpFinished()
            scheduler.performWithDelayGlobal(function()
                scheduler.performWithDelayGlobal(function()
                    _doLogoutWithoutDelivery()
                end, 0)
            end, 0)
        end
    elseif app.scene then
        app.scene:setBattleEnded()
        app.scene:cancelMoveSchedule()
        app:exitFromBattleScene(false)
        _doLogoutWithoutDelivery()
    else
        _doLogoutWithoutDelivery()
    end
end

function MyApp:logout()
    scheduler.performWithDelayGlobal(function()
        self.sound:stopMusic()

        self:setIgnoreLoadingAnyway(false)
        if self:isDeliveryIntegrated() == true then
            self:_logoutWithDelivery(true)
        elseif self:isDeliveryYwmb() or self:isDeliveryHX() then
            self:_logoutWithYuewen()
        else
            self:_logoutWithoutDelivery()
        end
    end, 0)
end

function MyApp:relogin( ... )
    self:_resetBeforeRelogin()

    self._userData:setValueForKey(QUserData.AUTO_LOGIN, QUserData.STRING_TRUE)
    self:afterSDKLogin()

    QLogFile:info("MyApp: relogin successfully")
end


-- Each delivery has its own name except for "Default"
function MyApp:isDeliveryIntegrated()
    local deliveryName = DELIVERY_NAME;

    return deliveryName ~= "Default" and deliveryName ~= "";
end

-- This function is different from isDeliveryIntegrated
-- isDeliveryIntegrated is to indicate if this package is integrated with SDK
-- isDeliveryEnvAvailable is to indicate if this package is integrated with SDK except demo(mubao), which goes to formal procedure

function MyApp:isDeliveryEnvAvailable()
    return (self:isDeliveryIntegrated() and DELIVERY_NAME == "youzu" and QDeliveryWrapper:getDeliveryExtend() ~= "0") or DEBUG_YOUZU_EXTEND
end

function MyApp:isDeliveryYuewen()
    return (self:isDeliveryIntegrated() and DELIVERY_NAME == "yuewen")
end

function MyApp:isDeliveryYwmb()
    return (self:isDeliveryIntegrated() and DELIVERY_NAME == "ywmb")
end

function MyApp:isDeliveryHJ()
    return (self:isDeliveryIntegrated() and DELIVERY_NAME == "hj")
end

function MyApp:isDeliveryHX()
    return (self:isDeliveryIntegrated() and DELIVERY_NAME == "hx")
end

function MyApp:isDeliverySDKInitialzed()
    if self:isDeliveryIntegrated() then
        return QDeliveryWrapper:isSDKInitialzied()
    else
        return false
    end
end

function MyApp:getAccoundID(default)
    return QDeliveryWrapper:getUserId() or default
end

function MyApp:getUserId(default)
    return remote.user.userId or default
end

function MyApp:getUserLevel(default)
    return remote.user.level or default
end

function MyApp:getUserName()
    return self._userData:getValueForKey(QUserData.USER_NAME)
end

function MyApp:getSessionId()
    return QDeliveryWrapper:getSessionId() 
end

function MyApp:getDeviceUUID()
    return QDeliveryWrapper:getDeviceUUID() or ""
end

function MyApp:getChannelID( ... )
    -- body
    return QDeliveryWrapper:getChannelID() or YW_CHANNEL_ID
end
function MyApp:getSubChannelID( ... )
    -- body
    if QDeliveryWrapper.getSubChannelID == nil then
        return YW_SUB_CHANNEL_ID
    end
    return QDeliveryWrapper:getSubChannelID() or YW_SUB_CHANNEL_ID
end
function MyApp:getOpgameID( ... )
    return DEBUG_EXTEND_GAMEOPID or CHANNEL_RES.gameOpId
end

function MyApp:getPassword()
    local password = self._userData:getValueForKey(QUserData.PASSWORD)
    return password
end

function MyApp:getNickName(default)
    return remote.user.nickname or default
end

-- state: 0 - depends on settings
--        1 - all on
--        2 - all off
function MyApp:setMusicSound(state)
    if state == 1 then
        audio.setMusicVolume(global.music_volume)
        audio.setSoundsVolume(global.sound_volume)
    elseif state == 2 then
        audio.setMusicVolume(0)
        audio.setSoundsVolume(0)
    else
        audio.setMusicVolume(self._systemSetting:getMusicState() == "on" and global.music_volume or 0)
        audio.setSoundsVolume(self._systemSetting:getSoundState() == "on" and global.sound_volume or 0)
    end
end

-- For Tongbutui, account is userId, pass is sessionId
function MyApp:_login(account, pass)
    self.gray:setGrayId(account)
    if self:isDeliverySDKInitialzed() then
        print(string.format("QDeliveryYuewen Debug: MyApp:_login account:%s pass:%s", tostring(account), tostring(pass)))
        -- 阅文版本不登陆中心服
        if not self._isLogin then
            self._isLogin = true
            remote.user:update({name = account})
            self:_loginSucc(account)
        end
    else
        print("login account:" .. account .. " password:" .. pass)
        local uname = account
        local password = pass
        if FinalSDK.isHXShenhe() then
            -- env, zone, accessToken, success, fail, status)
            self._client:dldlHxUserLogin(nil, nil, uname, function(result)
                if not self._isLogin then
                    self._isLogin = true
                    remote.user:update({name = uname})
                    self:_loginSucc(uname)
                end
            end, function(err)

                if self:isDeliveryIntegrated() == false and self._autoLogin == true then
                    self._navigationManager:pushViewController(self.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGameLogin", options = {acc = account, rem = true}})
                end
            end)
        else
            self._client:ctUserLogin(uname, password, FinalSDK.getDeliveryName(), FinalSDK.getChannelID(), function(result)
                if not self._isLogin then
                    self._isLogin = true
                    remote.user:update({name = uname})
                    self:_loginSucc(uname)
                end
            end, function(err)

                if self:isDeliveryIntegrated() == false and self._autoLogin == true then
                    self._navigationManager:pushViewController(self.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGameLogin", options = {acc = account, rem = true}})
                end
            end)
        end
    end
end

-- 登录成功
function MyApp:_loginSucc(uname)
    -- self._loginCallback = function ( ... )
    --     QLogFile:debug("MyApp: loginCallback nil")
    -- end

    self:hideLoading()
    self:getUserData():setValueForKey(QUserData.USER_NAME, uname) -- 更新下拉框登入的帐号
    -- app:getUserOperateRecord():resetRecord()

    self._bulletinData = QBulletinData.new()
    self._serverChatData = QServerChatData.new(100)
    self._backdoor = QBackdoor.new()

    remote.user.isLoginFrist = false
    QDeliveryWrapper:openFloatWidget(0, 50)
    
    QUIWidgetLoading.sharedLoading():getView():setVisible(false)
    local _accessToken = self:getUserData():getValueForKey(QUserData.USER_TOKEN)

    self._navigationManager:pushViewController(self.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogEnterGame", options={userName=self:getUserName(),accessToken=_accessToken}})

    -- 通知App native code(iOS, Java) 用户登录了
    QUtility:notifyLogin(remote.user.name, remote.user.userId , remote.user.session) -- 似乎这个函数没啥用？？？
    
    -- remote.task:init()
    -- remote.achieve:init()
    -- remote.activity:init()
end

-- @deprecated
function MyApp:_createUser(uname, password)
    self._client:userCreate(uname, password, function(result)
        self:_loginSucc(uname)
    end, function(err)
        printError("user creation failed, not logged in. ")
        self._navigationManager:pushViewController(self.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSystemPrompt", options = {string = "帐号创建失败"} })
        dump(err)
    end)
end

function MyApp:getNavigationManager()
    return self._navigationManager
end

function MyApp:resetRemote()
    remote = QRemote.new()
end

function MyApp:setObject(id, object)
    -- assert(self._objects[id] == nil, "MyApp:setObject() - id " .. id .. " already exists")
    self._objects[id] = object
end

function MyApp:removeObject(id)
    self._objects[id] = nil
end

function MyApp:getObject(id)
    assert(self._objects[id] ~= nil, "MyApp:getObject() - id " .. id .. " already exists")
    return self._objects[id]
end

function MyApp:hasObject(id)
    return self._objects[id] ~= nil
end

function MyApp:getUserData()
    if self._userData == nil then
        self._userData = QUserData.new()
    end
    return self._userData
end

function MyApp:getSystemSetting()
    return self._systemSetting
end

function MyApp:createHero(heroInfo)  
    local hero = nil

    if heroInfo ~= nil then
        if self:hasObject(heroInfo.actorId) == true then
            hero = self:getObject(heroInfo.actorId)
        else
            if QHeroModel == nil then
                QHeroModel = __import(".models.QHeroModel")
            end
            hero = QHeroModel.new(heroInfo)
            self:setObject(heroInfo.actorId, hero)
        end
    end
    
    return hero
end

function MyApp:removeHero(actorId)
    if actorId ~= nil then
        if self:hasObject(actorId) then
            self:setObject(actorId, nil)
        end
    end
end

function MyApp:createHeroWithoutCache(heroInfo, isReplay, additionalInfos, isBattle, isSupport, isInStory, isInTotemChallenge, additional_skills, extraProp)
    if isInTotemChallenge then
        if QTotemChallengeActorModel == nil then
            QTotemChallengeActorModel = __import(".models.QTotemChallengeActorModel")
        end
        return QTotemChallengeActorModel.new(heroInfo, nil, nil, isReplay, additionalInfos, isBattle, isSupport, isInStory, additional_skills, extraProp)
    else
        if QHeroModel == nil then
            QHeroModel = __import(".models.QHeroModel")
        end
        return QHeroModel.new(heroInfo, nil, nil, isReplay, additionalInfos, isBattle, isSupport, isInStory, additional_skills, extraProp)
    end
end

function MyApp:createNpc(id, difficulty, level, additional_skills, dead_skill, isBattle, isInStory, skinId)
    if QNpcModel == nil then
        QNpcModel = __import(".models.QNpcModel")
    end
    return QNpcModel.new(id, difficulty, level, nil, nil, additional_skills, dead_skill, isBattle, isInStory, skinId)
end

function MyApp:getMonsterTotalLeftHp(npcshp, dungeonId)
    local dungeonConfig = db:getDungeonConfigByID(dungeonId)
    local total_hp_left = 0
    local total_hp_max = 0
    npcshp = npcshp or {}
    if dungeonConfig then
        local monster_id = dungeonConfig.monster_id
        local monsters = {}
        table.mergeForArray(monsters, db:getMonstersById(monster_id))
        local actor_cache = {}
        local function getNpcActor(monster)
            local cacheid = tostring(monster.npc_id)..tostring(monster.npc_difficulty)..tostring(monster.npc_level)
            local actor = actor_cache[cacheid]
            if actor == nil then
                actor = self:createNpc(monster.npc_id, monster.npc_difficulty, monster.npc_level)
                actor:setPropertyCoefficient(monster.attack_coefficient, monster.hp_coefficient, monster.damage_coefficient, monster.armor_coefficient)
                actor_cache[cacheid] = actor
            end
            return actor
        end
        for _, obj in ipairs(npcshp) do
            local index = obj.actorId
            local monster = monsters[index]
            if monster then
                if obj.currHp == -1 then
                    total_hp_max = total_hp_max + getNpcActor(monster):getMaxHp()
                elseif obj.currHp > 0 then
                    total_hp_left = total_hp_left + obj.currHp
                    total_hp_max = total_hp_max + getNpcActor(monster):getMaxHp()
                end
                monsters[index] = nil
            end
        end
        for _, monster in pairs(monsters) do
            if monster.wave > 0 then
                local hp_max = getNpcActor(monster):getMaxHp()
                total_hp_left = total_hp_left + hp_max
                total_hp_max = total_hp_max + hp_max
            end
        end
    end
    return total_hp_left, total_hp_max
end

-- @deprecated
function MyApp:createVCRNpc(id, udid, additional_skills, dead_skill)
    return QVCRNpcModel.new(id, udid, nil, nil, additional_skills, dead_skill)
end

function MyApp:promptTips()
    if self.prompt == nil then
        local QPromptTips = __import(".utils.QPromptTips")
        self.prompt = QPromptTips.new(self._thirdLayerPage:getView())
    end
    return self.prompt
end

function MyApp:topLayerView()
  return self._thirdLayerPage:getView()
end

--[[
    The function blew is some extension and utility function for AppBase
]]

function MyApp:createScene(sceneName, args)
    local scenePackageName = self.packageRoot .. ".scenes." .. sceneName
    local sceneClass = require(scenePackageName)
    return sceneClass.new(unpack(checktable(args)))
end

-- create controller at folder named controllers
function MyApp:createController(controllerName, args)
    local controllerPackageName = self.packageRoot .. ".controllers." .. controllerName
    local controllerClass = require(controllerPackageName)
    return controllerClass.new(unpack(checktable(args)))
end

function MyApp:setClient(client)
    self._client = client
end

-- get network client
function MyApp:getClient()
    return self._client
end

function MyApp:getProtocol()
    return self._protocol
end

function MyApp:getXMPPClient()
    return self._xmppClient
end

function MyApp:getXMPPData()
    return self._xmppData
end

function MyApp:getBulletinData()
    return self._bulletinData
end

function MyApp:getServerChatData()
    return self._serverChatData
end

-- 通用弹出框
-- options {content:"内容",title:"标题",callBack:关闭回调的响应函数,comfirmBack:确认回调按钮按下的响应函数，默认使用关闭按钮回调函数}
function MyApp:alert(options, isPopCurrentDialog, isTop)
    if isPopCurrentDialog == nil then
        isPopCurrentDialog = true
    end
    local layer = nil
    if isTop == true then
        options.canBackClick = false
        layer = self.topLayer
    else
        options.canBackClick = true
        layer = self.middleLayer
    end

    if layer == nil then
        return
    end

    options.layer = layer
    return self:getNavigationManager():pushViewController(layer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAlert", options = options}, {isPopCurrentDialog = isPopCurrentDialog})
end

-- 通用弹出框
-- options {content:"内容",callBack:关闭回调的响应函数,comfirmBack:确认回调按钮按下的响应函数，默认使用关闭按钮回调函数}
function MyApp:vipAlert(options, isPopCurrentDialog, isTop)
    if isPopCurrentDialog == nil then
        isPopCurrentDialog = true
    end
    local layer = nil
    if isTop == true then
        options.canBackClick = false
        layer = self.topLayer
    else
        options.canBackClick = true
        layer = self.middleLayer
    end

    if layer == nil then
        return
    end

    options.layer = layer
    return self:getNavigationManager():pushViewController(layer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVipAlert", options = options}, {isPopCurrentDialog = isPopCurrentDialog})
end

-- 通用弹出框
-- options {content:"内容",callBack:关闭回调的响应函数,comfirmBack:确认回调按钮按下的响应函数，默认使用关闭按钮回调函数}
function MyApp:alertAwards(options, isPopCurrentDialog, isTop)
    isPopCurrentDialog = isPopCurrentDialog or false
    
    local layer = nil
    if isTop == true then
        options.canBackClick = false
        layer = self.topLayer
    else
        options.canBackClick = true
        layer = self.middleLayer
    end

    if layer == nil then
        return
    end

    options.layer = layer
    return self:getNavigationManager():pushViewController(layer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAwardsAlert", options = options}, {isPopCurrentDialog = isPopCurrentDialog})
end

-- 通用弹出奖励框 自动读取luckydraw字段
function MyApp:luckyDrawAlert(luckyDrawId, tips, awardInfos, isShowRedpacketTips)
    local luckyDraw = QStaticDatabase:sharedDatabase():getLuckyDraw(luckyDrawId)
    local index = 1
    local awards = awardInfos or {}
    local isRandom = false
    if luckyDraw ~= nil and awardInfos == nil then
        while true do
            if luckyDraw["type_"..index] ~= nil then
                if luckyDraw["probability_"..index] == -1 then
                    if not db:checkItemShields(luckyDraw["id_"..index]) then
                        table.insert(awards, {id = luckyDraw["id_"..index], typeName = luckyDraw["type_"..index], count = luckyDraw["num_"..index]})
                    end
                else
                    isRandom = true
                end
            else
                break
            end
            index = index + 1
        end

        if isRandom then
            --当物品中有随机概率不是-1（即100%）的时候，则，不显示随机奖励，而统一用《神秘奖励》这个item代替所有。
            table.insert(awards, {id = 400, typeName = ITEM_TYPE.ITEM, count = 0})
        end
    end
    return app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsBoxAlert",
        options = {awards = awards, isGet = false, tips = tips, isShowRedpacketTips = isShowRedpacketTips}},{isPopCurrentDialog = false} )
end

-- 使用雲動畫
function MyApp:showCloudInterlude(closeCallBack, openCallBack)
    if closeCallBack then
        closeCallBack(function()end)
    end
    -- if self._cloudAniCcbView then
    --     self._cloudAniCcbView:removeFromParent()
    --     self._cloudAniCcbView = nil
    -- end
    -- if self._cloudAniManager then
    --     self._cloudAniManager = nil
    -- end

    -- local ccbFile = "ccb/effects/cloud_interlude.ccbi"
    -- local proxy = CCBProxy:create()
    -- local aniCcbOwner = {}
    -- self._cloudAniCcbView = CCBuilderReaderLoad(ccbFile, proxy, aniCcbOwner)
    -- self:topLayerView():addChild(self._cloudAniCcbView)
    -- self._cloudAniCcbView:setPosition(display.width/2, display.height/2)
    -- self._cloudAniManager = tolua.cast(self._cloudAniCcbView:getUserObject(), "CCBAnimationManager")
    -- self._cloudAniManager:runAnimationsForSequenceNamed("close")
    -- self._cloudAniManager:connectScriptHandler(function(str)
    --         if str == "close" then
    --             -- print(" MyApp:showCloudInterlude close ")
    --             local openFun = function()
    --                                 if self._cloudAniManager then
    --                                     self._cloudAniManager:runAnimationsForSequenceNamed("open")
    --                                 end
    --                             end
    --             if closeCallBack then
    --                 closeCallBack(openFun)
    --             end
    --         elseif str == "open" then
    --             -- print(" MyApp:showCloudInterlude open ")
    --             if openCallBack then
    --                 openCallBack()
    --             end
    --             if self._cloudAniCcbView then
    --                 self._cloudAniCcbView:removeFromParent()
    --                 self._cloudAniCcbView = nil
    --             end
    --             if self._cloudAniManager then
    --                 self._cloudAniManager = nil
    --             end 
    --         end
    --     end)
end

-- 获取该用户最大能连战的次数
function MyApp:getMaxQuickFightCount()
    return 10
end

-- 切换到战斗场景
function MyApp:enterIntoBattleScene(dungeonConfig, options)
    -- CCMessageBox("enter_before_collect " .. tostring(collectgarbage("count")*1024), "")
    
    collectgarbageCollect()
    if self.ccbNodeCache then
        self.ccbNodeCache:purgeCCBNodeCache()
    end
    app:cleanTextureCache()
    -- CCMessageBox("enter_after_collect " .. tostring(collectgarbage("count")*1024), "")
    if not ENABLE_CCB_TO_LUA then
        self.ccbNodeCache:cacheCCBNodeInOneFrame(true)
    end

    self._enterBattleOptions = options
    QDeliveryWrapper:setToolBarVisible(false) -- Hide delivery tool bar in battle scene

    -- 切换到战斗场景后，整个scene会切换成战斗的scene，需要吧loading和网络出错对话框的层加到战斗场景中，否则
    -- loading会弹不出来
    QUIWidgetLoading.sharedLoading():removeLoading()
    
    self._thirdLayerPage:getView():retain()
    self._thirdLayerPage:getView():removeFromParent()
    -- self._ly_mask_left:retain()
    -- self._ly_mask_left:removeFromParent()
    -- self._ly_mask_right:retain()
    -- self._ly_mask_right:removeFromParent()
    app.tip:refreshTip()

    local scene = app:createScene(dungeonConfig.isTutorial and "QTutorialBattleScene" or "QBattleScene", {dungeonConfig})
    CCDirector:sharedDirector():pushScene(scene)
    
    scene:addChild(self._thirdLayerPage:getView(), 10)
    -- scene:addChild(self._ly_mask_left, 11)
    -- scene:addChild(self._ly_mask_right, 11)
    -- self._ly_mask_right:release()
    -- self._ly_mask_left:release()
    self._thirdLayerPage:getView():release()
    scene:addChild(QUIWidgetLoading.sharedLoading():getView(), 10)


    scene:wakeup()
    self:getAlarmClock():pause()

    -- 版本过期提示
    if dungeonConfig.gameVersion ~= self:getBattleVersion() then
        app.tip:floatTip("因版本发生变化，可能导致战报与实际情况不一致，敬请谅解~")
    end

    if not options.enableFloatWidget then
        QDeliveryWrapper:closeFloatWidget()
    end
    QDeliveryWrapper:setBuglyTag(88172)
end

-- 从战斗场景中退出
function MyApp:exitFromBattleScene(isInBattle, isTutorialBattle, noFade)
    local isReplay = app.battle:isInReplay()
    local isQuick = app.battle:isInQuick()
    local isInSilvesArenaReplayBattleModule = app.battle:isInSilvesArenaReplayBattleModule()

    QDeliveryWrapper:setToolBarVisible(true)

    QUIWidgetLoading.sharedLoading():removeLoading()
    
    self._thirdLayerPage:getView():retain()
    self._thirdLayerPage:getView():removeFromParent()
    -- self._ly_mask_left:retain()
    -- self._ly_mask_left:removeFromParent()
    -- self._ly_mask_right:retain()
    -- self._ly_mask_right:removeFromParent()
    app.tip:refreshTip()
    
    CCDirector:sharedDirector():popScene()

    if isInBattle then
        app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_CURRENT_PAGE)
    end

    self._uiScene:addChild(self._thirdLayerPage:getView()) 
    self._thirdLayerPage:getView():release()
    self._uiScene:addChild(QUIWidgetLoading.sharedLoading():getView())
    -- self._uiScene:addChild(self._ly_mask_left)
    -- self._uiScene:addChild(self._ly_mask_right)
    -- self._ly_mask_right:release()
    -- self._ly_mask_left:release()
    self:showLoading()

    local dungeonConfig = app.battle:getDungeonConfig()
    app.scene:setOnExitCallback(function()
        if HIBERNATE_TEXTURE and CCTextureCache.wakeupAllTextures then
            CCTextureCache:sharedTextureCache():wakeupAllTextures()
            -- self.ccbNodeCache:wakeup()
            -- self._uiScene:wakeup()
        end
        if HIBERNATE_TEXTURE_2 then
            wakeupUselessTextures(dungeonConfig)
        end
    end)

    if isTutorialBattle and not noFade then
        local fadeScene = CCTransitionFade:create(2, self._uiScene)
        display.replaceScene(fadeScene)

        --埋点 结束新手剧情
        remote:triggerBeforeStartGameBuriedPoint("10070")
    end
    
    scheduler.performWithDelayGlobal(function()
        
    collectgarbageCollect()
        app:cleanTextureCache()
        self:getAlarmClock():resume()
        -- if not ENABLE_CCB_TO_LUA then
        --     self.ccbNodeCache:cacheCCBNodeInOneFrame()
        -- end
        self:hideLoading()
        if isInBattle then
            QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.EVENT_EXIT_FROM_BATTLE, options = {isReplay = isReplay, isQuick = isQuick, isInSilvesArenaReplayBattleModule = isInSilvesArenaReplayBattleModule}})
        end
        
    end, 0)

    -- 某些安卓机型会在因为在同一时间内大量调用pause或者stop而导致内存不足而崩溃，所以这里先注释掉
    -- audio.unloadAllSound()

    if isInBattle then
        QDeliveryWrapper:openFloatWidget(0, 50)
    end
    QDeliveryWrapper:setBuglyTag(88173)
end

-- 重启战斗场景
function MyApp:replaceBattleScene(dungeonConfig)
    QUIWidgetLoading.sharedLoading():getView():retain()
    QUIWidgetLoading.sharedLoading():getView():removeFromParent()
    
    self._thirdLayerPage:getView():retain()
    self._thirdLayerPage:getView():removeFromParent()
    app.tip:refreshTip()
    -- self._ly_mask_left:retain()
    -- self._ly_mask_left:removeFromParent()
    -- self._ly_mask_right:retain()
    -- self._ly_mask_right:removeFromParent()

    local scene = app:createScene("QBattleScene", {dungeonConfig})
    display.replaceScene(scene)

    scene:addChild(self._thirdLayerPage:getView(), 10)
    self._thirdLayerPage:getView():release()
    scene:addChild(QUIWidgetLoading.sharedLoading():getView(), 10)
    QUIWidgetLoading.sharedLoading():getView():release()
    -- scene:addChild(self._ly_mask_left)
    -- scene:addChild(self._ly_mask_right)
    -- self._ly_mask_right:release()
    -- self._ly_mask_left:release()
end

-- 保存战斗回放
function MyApp:saveBattleRecord(battleRecord)
    -- 由于2进制浮点数转换成10进制会有精度丢失，所以把这些浮点数都memory copy转换成uint32作为整数保存
    local recordTimeSlices = battleRecord.recordTimeSlices
    for i, v in ipairs(recordTimeSlices) do
        recordTimeSlices[i] = QUtility:float_to_uint32(v)
    end
    local timeGearChange = battleRecord.dungeonConfig.timeGearChange
    if timeGearChange then
        for k, v in pairs(timeGearChange) do
            timeGearChange[k] = QUtility:float_to_uint32(v)
        end
    end

    -- 保存为last.rep文件
    local json_string = json.encode(battleRecord)
    if json_string then
        writeToFile("last.rep", json_string)
    end
end

-- 载入战斗回放
function MyApp:loadBattleRecord()
    local fileutil = sharedFileUtils
    local filepath = fileutil:getWritablePath() .. "last.rep"
    if not fileutil:isFileExist(filepath) then
        return
    end

    local content = fileutil:getFileData(filepath)
    local raw_table = json.decode(content)
    self._battleRecord = raw_table

    -- 把uint32都memory copy转换成正常的浮点数
    local recordTimeSlices = self._battleRecord.recordTimeSlices
    for i, v in ipairs(recordTimeSlices) do
        recordTimeSlices[i] = QUtility:uint32_to_float(v)
    end
    local timeGearChange = self._battleRecord.dungeonConfig.timeGearChange
    if timeGearChange then
        for k, v in pairs(timeGearChange) do
            timeGearChange[k] = QUtility:uint32_to_float(v)
        end
    end
end

function MyApp:saveBattleRecordIntoProtobuf(battleRecordList)
    QMyAppUtils:saveBattleRecordIntoProtobuf(battleRecordList)
end

function MyApp:loadBattleRecordFromProtobuf(replay)
    local replayContent = nil
    if replay and replay:sub(-7) == ".reptxt" then
        replayContent = crypto.decodeBase64(readFromFile(replay))
        -- writeToBinaryFile("reptxt_out.reppb", replayContent)
    else
        replayContent = readFromBinaryFile(replay or "last.reppb")
    end
    self:parseBinaryBattleRecord(replayContent)
    -- local battleRecord = app:getProtocol():decodeBufferToMessage("cc.qidea.wow.client.battle.ReplayList", replayContent)
end

function MyApp:parseBinaryBattleRecord(replayContent)
    self._battleRecordList = {}
    local battleRecord = {}
    local status, record
    status, record = pcall(function()
            return app:getProtocol():decodeBufferToMessage("cc.qidea.wow.client.battle.ReplayList", replayContent)
        end)
    
    if not status then
        record = app:getProtocol():decodeBufferToMessage("cc.qidea.wow.client.battle.Replay", replayContent)
        battleRecord.replayList = {}
        table.insert(battleRecord.replayList, record)
    else
        battleRecord = record
    end

    if not battleRecord then
        printError("Can not recognize replay proto format")
        return 
    end

    for _, record in ipairs(battleRecord.replayList) do
        local replayCord = QMyAppUtils:loadBattleRecordFromProtobufContent(record)
        table.insert(self._battleRecordList, replayCord)
    end

    self._battleRecord = self._battleRecordList[1]
    return self._battleRecord
end

function MyApp:getBattleRecord()
    return self._battleRecord
end

function MyApp:getBattleRecordList()
    return self._battleRecordList
end

-- 开始记录战斗回放流
function MyApp:startBattleRecordStream(dungeonConfig, recordRandomSeed)
    -- 保存为临时流文件last.tmp.repx
    local t = {dungeonConfig = dungeonConfig, recordRandomSeed = recordRandomSeed}
    local json_string = json.encode(t)
    if json_string then
        writeToFile("last.tmp.repx", json_string)
    end
end

-- 添加战斗回放流的帧
function MyApp:appendBattleRecordStream(frame)
    local fileutil = sharedFileUtils
    local filepath = fileutil:getWritablePath() .. "last.tmp.repx"
    if not fileutil:isFileExist(filepath) then
        return
    end

    -- 由于2进制浮点数转换成10进制会有精度丢失，所以把这些浮点数都memory copy转换成uint32作为整数保存
    frame.dt = QUtility:float_to_uint32(frame.dt)
    if frame.timeGearChange then
        frame.timeGearChange = QUtility:float_to_uint32(frame.timeGearChange)
    end

    -- 添加到临时流文件last.tmp.repx
    local json_string = json.encode(frame)
    if json_string then
        appendToFile("last.tmp.repx", "!@#$\n" .. json_string)
    end
end

-- 战斗回放临时流文件另存为为last.repx
function MyApp:saveBattleRecordStream()
    local fileutil = sharedFileUtils
    local filepath = fileutil:getWritablePath() .. "last.tmp.repx"
    if not fileutil:isFileExist(filepath) then
        return
    end

    local content = fileutil:getFileData(filepath)
    writeToFile("last.repx", content)
end

-- 载入战斗回放流为普通战斗记录()
function MyApp:loadBattleRecordFromStream()
    self._battleRecord = QMyAppUtils:loadBattleRecordFromStream()
end

function MyApp:_enterBackground()
    QLogFile:info("Application enterBackground")
    -- if self._userData then
    --     self._userData:setValueForKey("NORMAL_QUIT", 1)
    -- end
     -- close socket 
    -- if self._client ~= nil then
    --     self._client:close()
    -- end

    self._lastTimeEnterBackground = q.time()
    self._systemSetting:enable()
end

function MyApp:_onEnterBackground(event)
    if event.name == self.APP_ENTER_BACKGROUND_EVENT then
        -- if device.platform == "ios" then
           self:_enterBackground()
        -- end
    -- elseif event.name == self.APPLICATION_ENTER_BACKGROUND_ANDROID_EVENT then
    --     if device.platform == "android" then
    --         self:_enterBackground()
    --     end
    end
end

function MyApp:_enterForeground()
    QLogFile:info("Application enterForeground")
    -- if self._userData then
    --     self._userData:setValueForKey("NORMAL_QUIT", 0)
    -- end
    if remote.user.pauseMusicFlag then
        app.sound:pauseMusic()
    end
    -- 进入background时间过长，则进入foreground的时候会去relaunch game
    if self._lastTimeEnterBackground and q.time() - self._lastTimeEnterBackground > MyApp.BACKGROUND_TIME_BEFORE_RELAUNCH then
        QLogFile:info("Too long time in the background, relaunch game")
        app:relaunchGame(true)
    -- elseif self._lastTimeEnterBackground and q.time() - self._lastTimeEnterBackground > MyApp.BACKGROUND_TIME_BEFORE_RELAUNCH_WITHOUTDOWNLOAD then
    --     app:relaunchGame(false)
    else
        self._lastTimeEnterBackground = nil

        -- cancel all notifications when application is active @qinyuanji
        self._systemSetting:disable()

        if self._client ~= nil and not self._client:checkConnection() then
            self._client:reopen()
        end
    end
end

function MyApp:_onEnterForeground(event)
    if event.name == self.APP_ENTER_FOREGROUND_EVENT then
        if device.platform == "ios" then
            self:_enterForeground()
        elseif device.platform == "android" then
            self:_reloadShader()
            self:_enterForeground()
        end
    -- elseif event.name == self.APPLICATION_ENTER_FOREGROUND_ANDROID_EVENT then
    --     if device.platform == "android" then
    --         self:_enterForeground()
    --     end
    end
end

-- registered at ctor
function MyApp:onReceiveMemoryWarning()
    QLogFile:error("Application did receive memory warning!")
    if buglyReportLuaException then
        -- buglyReportLuaException("Application did receive memory warning!", "")
    end
    self:dispatchEvent({name = MyApp.APPLICATION_RECEIVE_MEMORY_WARNING_EVENT})
end

local _lastTimeCleanOnMemoryWarning = nil
-- registered af download complete
function MyApp:_onReceiveMemoryWarning(event)
    if event.name == self.APPLICATION_RECEIVE_MEMORY_WARNING_EVENT then
        -- CCMessageBox("low memory warning!")
        if _lastTimeCleanOnMemoryWarning == nil or q.time() - _lastTimeCleanOnMemoryWarning > 15.0 then
            _lastTimeCleanOnMemoryWarning = q.time()
            scheduler.performWithDelayGlobal(function()
                
    collectgarbageCollect()
                if self.ccbNodeCache then
                    self.ccbNodeCache:purgeCCBNodeCache()
                end
                QSkeletonDataCache:sharedSkeletonDataCache():removeUnusedData()
                CCSpriteFrameCache:sharedSpriteFrameCache():removeUnusedSpriteFrames()
                CCTextureCache:sharedTextureCache():removeUnusedTextures()
            end, 0)
        end
    end
end

function MyApp:onEnterResumeMusic()
    remote.user.pauseMusicFlag = false
    if self.sound then
        self.sound:resumeMusic()
    end  
end

function MyApp:onAppWillTerminate()
    QLogFile:info("MyApp:onAppWillTerminate")

    -- if self._userData then
    --     self._userData:setValueForKey("NORMAL_QUIT", 1)
    -- end
    self:dispatchEvent({name = MyApp.APPLICATION_WILL_TERMINATE})
end

local QReplayUtil = import(".utils.QReplayUtil")
function MyApp:onAppOpenUrl(evtName, url_ccstring)
    if url_ccstring then
        local url = url_ccstring:getCString()
        self:dispatchEvent({name = MyApp.APPLICATION_OPEN_URL, url = url})
    end
end

function MyApp:changeGLViewSize()
    display.calculateDisplay()

    self:calculateUIViewSize()

    QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.EVENT_CHANGE_GLVIEW_SIZE})
end

function MyApp:_reloadShader()
    CCShaderCache:sharedShaderCache():reloadDefaultShaders()
    reloadAllCustomShaders()
end

function MyApp:setIgnoreLoadingAnyway(isHide)
    self._ignoreLoadingAnyway = isHide
end

-- show ju hua
function MyApp:showLoading(isForce, isShowBg)
    -- printInfoWithColor(PRINT_FRONT_COLOR_PURPLE, nil, "want showLoading")
    local loading = QUIWidgetLoading.sharedLoading()
    if loading ~= nil then
        if isForce == true then
            if loading.Show then
                loading:Show()
            end
        elseif self._ignoreLoadingAnyway == false then
            if loading.Show then
                loading:Show()
            end
        end
        if loading.setShowBlack and isShowBg then
            loading:setShowBlack(true)
        end
    end
end

-- hide ju hua
function MyApp:hideLoading(isForce, isHideBg)
    -- printInfoWithColor(PRINT_FRONT_COLOR_PURPLE, nil, "want hideLoading")
    if QUIWidgetLoading.sharedLoading() ~= nil and QUIWidgetLoading.sharedLoading().Hide then
        if isForce == true then
            -- printInfoWithColor(PRINT_FRONT_COLOR_PURPLE, nil, "do hideLoading")
            QUIWidgetLoading.sharedLoading():Hide()
        elseif self._ignoreLoadingAnyway == false then
            -- printInfoWithColor(PRINT_FRONT_COLOR_PURPLE, nil, "do hideLoading")
            QUIWidgetLoading.sharedLoading():Hide()
        end
        if QUIWidgetLoading.sharedLoading().setShowBlack and isHideBg then
            QUIWidgetLoading.sharedLoading():setShowBlack(false)
        end
    end
end

function MyApp:getUpdater()
    return self._updater
end

function MyApp:isLogin()
    return self._isLogin
end

function MyApp:recordNavigationStack()
    local stackInfo = ""
    local controller = self._navigationManager:getController(self.mainUILayer)
    if controller ~= nil then
        stackInfo = stackInfo .. controller:dumpControllerStack()
    end
    controller = self._navigationManager:getController(self.middleLayer)
    if controller ~= nil then
        stackInfo = stackInfo .. controller:dumpControllerStack()
    end
    controller = self._navigationManager:getController(self.topLayer)
    if controller ~= nil then
        stackInfo = stackInfo .. controller:dumpControllerStack()
    end
    QUtility:setUIStackInfo(stackInfo)
end

function MyApp:_getBattleRandomNumber(dungeon_id, npc_index)
    if self._battleRandomNumber == nil then
        self._battleRandomNumber = {}
    end

    if self._battleRandomNumber[dungeon_id] == nil then
        self._battleRandomNumber[dungeon_id] = {}
    end

    if self._battleRandomNumber[dungeon_id][npc_index] == nil then
        -- check user data
        local rand = app:getUserData():getUserValueForKey(dungeon_id .. "-" .. tostring(npc_index))
        if rand ~= nil and rand ~= "nil" then
            rand = tonumber(rand)
        else
            rand = math.random(1, 10000)
            app:getUserData():setUserValueForKey(dungeon_id .. "-" .. tostring(npc_index), tostring(rand))
        end
        self._battleRandomNumber[dungeon_id][npc_index] = rand
    end

    return self._battleRandomNumber[dungeon_id][npc_index]
end

function MyApp:getBattleRandomNumberByDungeonID(dungeon_id)
    local count = #QStaticDatabase:sharedDatabase():getMonstersById(dungeon_id)
    for i = 1, count do
        self:_getBattleRandomNumber(dungeon_id, i)
    end
    return clone(self._battleRandomNumber[dungeon_id])
end

function MyApp:_getBattleProbability(dungeon_id, npc_index)
    if self._battleProbability == nil then
        self._battleProbability = {}
    end

    if self._battleProbability[dungeon_id] == nil then
        self._battleProbability[dungeon_id] = {}
    end

    if self._battleProbability[dungeon_id][npc_index] == nil then
        self._battleProbability[dungeon_id][npc_index] = math.random(1, 100)
    end

    return self._battleProbability[dungeon_id][npc_index]
end

function MyApp:getBattleProbabilityByDungeonID(dungeon_id)
    local count = #QStaticDatabase:sharedDatabase():getMonstersById(dungeon_id)
    for i = 1, count do
        self:_getBattleProbability(dungeon_id, i)
    end
    return clone(self._battleProbability[dungeon_id])
end

function MyApp:resetBattleRandomNumber(dungeon_id)
    if self._battleRandomNumber == nil then
        self._battleRandomNumber = {}
    end

    if self._battleRandomNumber[dungeon_id] then
        for npc_index, rand in pairs(self._battleRandomNumber[dungeon_id]) do
            app:getUserData():setUserValueForKey(dungeon_id .. "-" .. tostring(npc_index), "nil")
        end
    end

    self._battleRandomNumber[dungeon_id] = nil
end

function MyApp:resetBattleNpcProbability(dungeon_id)
    if self._battleProbability == nil then
        self._battleProbability = {}
    end

    self._battleProbability[dungeon_id] = nil
end

function MyApp:getBattleRandomNpc(dungeon_id, npc_index, npc_id)
    local ids = string.split(npc_id, ";")
    if #ids == 1 then
        return 1, ids
    else
        local rand = self:_getBattleRandomNumber(dungeon_id, npc_index)
        local index = math.fmod(rand, #ids) + 1
        return index, ids
    end
end

function MyApp:getBattleRandomNpcID(dungeon_id, npc_index, npc_id)
    local index, ids = self:getBattleRandomNpc(dungeon_id, npc_index, npc_id)
    return ids[index]
end

function MyApp:getBattleNpcProbability(dungeon_id, npc_index)
    return self:_getBattleProbability(dungeon_id, npc_index)
end

function MyApp:cleanTextureCache(countLimit)
    if self.ccbNodeCache then
        self.ccbNodeCache:purgeCCBNodeCache(true)
    end
    CCSpriteFrameCache:sharedSpriteFrameCache():removeUnusedSpriteFrames()
    if self._isClearSkeletonData == true then
        QSkeletonDataCache:sharedSkeletonDataCache():removeUnusedData()
    end

    if countLimit == nil then
        countLimit = 0
    end

    if countLimit <= 0 then
        CCTextureCache:sharedTextureCache():removeUnusedTextures()
    else
        CCTextureCache:sharedTextureCache():removeUnusedTexturesWithLimit(countLimit)
    end
    -- CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
end

function MyApp:enableTextureCacheScheduler()
    if self._textureCacheScheduler ~= nil then
        return
    end

    self._textureCacheScheduler = scheduler.scheduleGlobal(handler(self, MyApp.onTextureCacheSchedule), 0.2)
end

function MyApp:disableTextureCacheScheduler()
    if self._textureCacheScheduler == nil then
        return
    end

    scheduler.unscheduleGlobal(self._textureCacheScheduler)
    self._textureCacheScheduler = nil
end

function MyApp:onTextureCacheSchedule(dt)
    if (self.battle and BATTLE_ENABLE_CLEAN_TEXTURE_SCHEDULER)
        or (self.battle == nil and UI_ENABLE_CLEAN_TEXTURE_SCHEDULER) then
        collectgarbage("step", 10)
        self:cleanTextureCache(5)
        QSkeletonDataCache:sharedSkeletonDataCache():removeUnusedData()
    end
end

if not ENABLE_CLEAN_TEXTURE_SCHDULER then

    function MyApp:enableTextureCacheScheduler()

    end

    function MyApp:disableTextureCacheScheduler()

    end
end

function MyApp:setIsClearSkeletonData(isClear)
    if isClear == nil then
        isClear = true 
    end

    self._isClearSkeletonData = isClear
end

function MyApp:relaunchGame(isDownload)
    -- if self._userData then
    --     self._userData:setValueForKey("NORMAL_QUIT", 1)
    -- end
    
    self:disableTextureCacheScheduler()

    if self._allocatorInfoUpdate then
        scheduler.unscheduleGlobal(self._allocatorInfoUpdate)
        self._allocatorInfoUpdate = nil
    end

    QDeliveryWrapper:stopHandleError()

    if self._appProxy ~= nil then
        self._appProxy:removeAllEventListeners()
    end

    if self._client ~= nil then
        self._client:close()
    end

    QCCBDataCache:sharedCCBDataCache():removeAllData()

    if isDownload == true then
        QUtility:relaunchGame()
    else
        QUtility:relaunchGameWithoutDownload()
    end
end

function MyApp:sendGameEventForJson(eventKey)
    FinalSDK:sendGameEventForJson(eventKey, nil)
end

function MyApp:tokenChangeEvent(eventKey, tokenNum)
    if device.platform == "ios" and FinalSDK.getChannelID() == "101" then
        FinalSDK:sendGameEventForJson(eventKey, tokenNum)
    end
end

function MyApp:sendGameEvent(event, isUpdateGameData)
    if event == nil then
        return
    end

    QLogFile:debug(function ( ... )
        return string.format("Send game event %s, %s", tostring(event), tostring(isUpdateGameData))
    end)

    isUpdateGameData = isUpdateGameData or false

    if isUpdateGameData == false then
        QDeliveryWrapper:onEvent(event)
    else
        self:sendGameEventForJson(event)
    end
end

function MyApp:_onReceiveDeliveryError(errorCode, type)
    QLogFile:debug(function ( ... )
        return "MyApp: receive delivery error: " .. errorCode .. " type: " .. type
    end)
    
    if  errorCode == SDK_ERRORS.SDK_ERROR_CODE_READ_SUPERSDK_PLATFORM_CONFIG_FAILED then
        self:alert({content = "平台框架初始化失败", title = "系统提示", comfirmBack = function( ... ) 
        end }, false, true)
        
    elseif  errorCode == SDK_ERRORS.SDK_ERROR_CODE_SUPERSDK_INITAILIZE_FAILED  then
        self:alert({content = "平台初始化失败", title = "系统提示", comfirmBack = function( ... ) 
        end }, false, true)

    elseif  errorCode == SDK_ERRORS.SDK_ERROR_CODE_NEW_VERSION_OF_GAME then
        self:alert({content = "检测到新版本! 请等待更新", title = "系统提示", comfirmBack = function( ... ) 
        end }, false, true)

    elseif  errorCode == SDK_ERRORS.SDK_ERROR_CODE_WITHOUT_VERSION_CHECK then
        if self.tip then
            self.tip:floatTip("没有新版本检测机制!")
        end

    elseif  errorCode == SDK_ERRORS.SDK_ERROR_CODE_CHECK_VERISON_FAILED then
        if self.tip then
            self.tip:floatTip("新版本检测失败!")
        end

    elseif  errorCode == SDK_ERRORS.SDK_ERROR_CODE_LOGOUT_FAILED then
        if self.tip then
            self.tip:floatTip("注销失败!")
        end

    elseif  errorCode == SDK_ERRORS.SDK_ERROR_CODE_YOUZU_LOGIN_FAILED  then
        if self.tip then
            -- self.tip:floatTip("游族服务器验证失败!")
        end

    elseif  errorCode == SDK_ERRORS.SDK_ERROR_CODE_PLATFORM_LOGIN_FAILED then
        if self.tip then
            -- self.tip:floatTip("平台服务器验证失败!")
        end

    elseif  errorCode == SDK_ERRORS.SDK_ERROR_CODE_LOGOUT_SUCCESS then 
        if self.sound then
            self.sound:stopMusic()
        end

        if type == SDK_EVENTS.LOGOUT_WITH_OPEN_LOGIN then
            self._loginCallback = function ( ... )
                self:showLoading()
                scheduler.performWithDelayGlobal(function()
                    self._navigationManager:popViewController(self.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
                    self:afterSDKLogin()
                end, 1)
            end
        end

        self:_logoutWithDelivery(type ~= SDK_EVENTS.LOGOUT_WITH_OPEN_LOGIN)       
    end
end

function MyApp:printLuaVMMemory(extra)
    if DEBUG > 0 then
        printInfo(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
        if extra then
            printInfo(extra)
        end
        printInfo(string.format("LUA VM MEMORY USED BEFORE GC: %0.2f KB", collectgarbage("count")))
        collectgarbageCollect()
        printInfo(string.format("LUA VM MEMORY USED AFTER GC: %0.2f KB", collectgarbage("count")))
        printInfo("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
    end
end

-- android only

function MyApp:registerBackButtonHandler( callback)
    -- body
    self._backButtonCallBack = callback
end
function MyApp:unRegisterBackButtonHandler( )
    -- body
    self._backButtonCallBack = nil
end

function MyApp:onClickBackButton()
    printInfo("click back button on android!")

    if app.battle ~= nil then
        return 
    end

    if self._backButtonCallBack then
        if self._backButtonCallBack() then
            return
        end
    end

    if self:isDeliveryIntegrated() == true then
        app:sendGameEvent(GAME_EVENTS.GAME_EVENT_EXIT_GAME, true)
        QDeliveryWrapper:terminate()
    else
        self:_doOnClickBackButton()
    end
end

function MyApp:_doOnClickBackButton()
    if self._exitDialog == nil then  
        self._exitDialog = self:alert({content = "真的要退出游戏吗?", title = "系统提示", callBack = function( ... )
            self._exitDialog = nil
        end, comfirmBack = function( ... ) 
            self:exit()
        end }, false, true)
    end
end

function MyApp:setSpeedGear(directorGear, battleGear)
    QUtility:setDirectorSpeedMultiplier(directorGear)
    CCDirector:sharedDirector():getScheduler():setTimeScale(battleGear)
    self._directorGear = directorGear
    self._battleGear = battleGear
end

function MyApp:getDirectorSpeedGear()
    return self._directorGear or 1
end

function MyApp:getBattleSpeedGear()
    return self._battleGear or 1
end

function MyApp:setBattleRound(round)
    self._battleRound = round
end

function MyApp:getBattleRound()
    return self._battleRound
end

function MyApp:pushBattleLog(battleLog)
    table.insert(self._battleLogs, battleLog)
end

function MyApp:clearBattleLogs()
    self._battleLogs = {}
end

function MyApp:getBattleLogs()
    return self._battleLogs
end

--"http://192.168.38.125/JSCallOC.html"
function MyApp:openURLIngame(url)
    if self:isNativeLargerEqualThan(1, 4, 5) == false then
        device.openURL(url)
        return
    end
    if QUtility.openIngameURL then
        QUtility:openIngameURL(url, CCRect(0,0,display.widthInPixels,display.heightInPixels))
        self:checkWebLoadComplete()
    end
end

function MyApp:checkWebLoadComplete()
    if self._webViewLoadhandler then
        scheduler.unscheduleGlobal(self._webViewLoadhandler)
    end
    self:showLoading(false, true)
    self._loadWebViewTime = q.serverTime()
    self._webViewLoadhandler = scheduler.scheduleGlobal(function ()
        if QUtility:isWebViewDidFinishLoad() then
            QUtility:setWebViewVisible(true)
            self:hideLoading(false, true)
            if self._webViewLoadhandler then
                scheduler.unscheduleGlobal(self._webViewLoadhandler)
            end
        else
            if q.serverTime() - self._loadWebViewTime > 10 then
                QUtility:closeIngameURL()
                self:hideLoading(false, true)
                if self._webViewLoadhandler then
                    scheduler.unscheduleGlobal(self._webViewLoadhandler)
                end
                app.tip:floatTip("网络太慢，加载失败！")
            end
        end
    end, 1)
end

function MyApp:getAnnouncementUrl()
    if ENVIRONMENT_NAME == "alpha" or ENVIRONMENT_NAME == "publish" or ENVIRONMENT_NAME == "testing" then
        if ANNOUNCEMENT_URL then
            return ANNOUNCEMENT_URL.."?gameId=dldl&platform=alpha&opId=10001"
        end
    else
        if ANNOUNCEMENT_URL then
            local channelId = FinalSDK.getChannelID()
            if nil == channelId or "" == channelId then
                if device.platform == "ios" then
                    channelId = "101"
                else
                    channelId = ""
                end
            end
            local opgameId = self:getOpgameID()
            if channelId == "28" then
                opgameId = "3006"
            end
            return ANNOUNCEMENT_URL..string.format("?v=%s&gameId=dldl&platform=%s&opId=%s", q.serverTime(), opgameId, channelId)
        end
    end
    return nil
end

function MyApp:prepareWebView(  )
    self._gameNotice = {}
    -- local downloader = QDownloader:new(CCFileUtils:sharedFileUtils():getWritablePath(), 1)
    local url = self:getAnnouncementUrl()
    print("----------getAnnouncementUrl------------")
    print(url)
    if url then
        -- local announcementJson = downloader:downloadContent(url, false)
        local announcementJson = httpGet(url, 1)
        if announcementJson == nil then return end
        announcementJson = QUtility:unzipBuffer(announcementJson, string.len(announcementJson))
        local data = json.decode(announcementJson)
        local curTime = q.serverTime()
        if data and data.data then
            for i, v in pairs(data.data) do
                local info = clone(v)
                info.start_time = startTime
                info.end_time = endTime
                info.isSelect = false
                self._gameNotice[#self._gameNotice+1] = info
            end
        end
    end
    return self._gameNotice
end

function MyApp:getAnnouncement() 
    --if device.platform == "android" or device.platform == "ios" then
        if ENABLE_HTML_ANNOUNCEMENT then
            if self._gameNotice then
                return self._gameNotice
            else
                return self:prepareWebView()
            end
        end
    --end
end

--[[
    触发埋点
    @param id，埋点的id
]]
function MyApp:triggerBuriedPoint(id)
    if self._client == nil then
        return
    end

    -- to implement
    if tonumber(id) then
        if self._buriedPoints == nil then
            self._buriedPoints = {}
        end
        if self._buriedPointScheduler == nil then
            self._buriedPointScheduler = scheduler.scheduleGlobal(function()
                if #self._buriedPoints > 0 then
                    local guideId = self._buriedPoints[1]
                    table.remove(self._buriedPoints, 1)
                    if self._client then
                        self._client:sendLogGuidePointRequest(guideId)
                    end
                end
            end, 0)
        end
        self._buriedPoints[#self._buriedPoints + 1] = tonumber(id)
    end
end

--[[
    xurui: 游戏开始前的数据埋点
    @param id，埋点的id
]]
function MyApp:triggerBeforeStartGameBuriedPoint(id)
    if id == nil then
        return
    end
    if self._maxBuriedPoints == nil then
        self._maxBuriedPoints = self:getUserData():getValueForKey("MAX_BURIED_POINT", tonumber(id)) or 0
    end

    -- to implement
    if tonumber(id) and tonumber(self._maxBuriedPoints) < tonumber(id) then 
        local responseFunc = function(event)
            local ok = (event.name == "completed")
            local request = event.request
            
            if not ok then
                -- 请求失败，显示错误代码和错误消息
                QLogFile:debug(function ( ... )
                    return string.format("Trigger Buried Point %s is Fialed !, Erroe code: %s, Erroe message: %s", id, request:getErrorCode(), request:getErrorMessage())
                end)
            else
                local code = request:getResponseStatusCode()
                if code ~= 200 then
                    print(code)
                else
                    -- 请求成功，显示服务端返回的内容
                    local response = request:getResponseString()
                    QLogFile:info(function ( ... )
                        return string.format("Trigger Buried Point %s is Success ! response: %s", id, response)
                    end)

                    self._maxBuriedPoints = tonumber(id)
                    self:getUserData():setValueForKey("MAX_BURIED_POINT", tonumber(id))
    
                end
            end
            -- request:release()
        end

        local extend = QDeliveryWrapper:getDeliveryExtend()  
        if DEBUG_YOUZU_EXTEND then
            extend = DEBUG_YOUZU_EXTEND
        end
        local ids = string.split(extend, "|") -- ids[1] is opId, ids[2] is gameId, ids[3] is gameOpId
        local opId = ids[1]

        local deviceId = FinalSDK.getDeviceUUID() and FinalSDK.getDeviceUUID() or ""
        if device.platform == "android" then
            deviceId = device.getOpenUDID() or ""
        end
        local param = crypto.md5(opId..deviceId..id.."xzjcvno08125yb9via8y329bvaw3r0sdatw35")

        param = string.format("/device_rcd?opId=%s&deviceId=%s&actionId=%s&verify=%s", opId, deviceId, id, param)
        local url = "http://loginrcd.mszx.joybest.com.cn"..param
        local pointRequest = network.createHTTPRequest(responseFunc, url, "GET")
        pointRequest:setTimeout(1)
        pointRequest:retain()
        pointRequest:start()
    end
end

function MyApp:checkDayNightTime()
    local times = QStaticDatabase:sharedDatabase():getConfigurationValue("DAY_NIGHT_SWITCH")
    times = string.split(times, ";")
    local dayTime = string.split(times[2], ":")
    local nightTime = string.split(times[1], ":")
    dayTime = q.getTimeForHMS(tonumber(dayTime[1]), tonumber(dayTime[2]), 0)
    nightTime = q.getTimeForHMS(tonumber(nightTime[1]), tonumber(nightTime[2]), 0)

    local serverTime = q.serverTime()
    local isDay = false
    if serverTime >= dayTime and serverTime < nightTime then
        isDay = true
    end

    return isDay
end

function MyApp:checkGlobalVariable( )
    -- body
    if ENABLE_CHECK_GLOBAL then
        GlobalVal._ = 1
        setmetatable(_G, {
            __newindex = function(_, name, value)
                rawset(__g, name, value)
                printError("============================GlobalVal==============================")
                printError(debug.traceback())
                printError(string.format("USE \" GlobalVal.%s = value \" INSTEAD OF SET GLOBAL VARIABLE", name), 0)
                printError("============================GlobalVal==============================")
            end
        })
    end
end


function MyApp:getUserOperateRecord( )
    -- body
    if not self._userOperateRecord then
        self._userOperateRecord = QRecordUserOperate.new()
    end
    return self._userOperateRecord
end

function MyApp:resetUserOperateRecord( )
    -- body
    self._userOperateRecord = nil
end

function MyApp:getAlarmClock( )
    -- body
    if not self._alarmClock then
        self._alarmClock = QAlarmClock.new()
    end
    return self._alarmClock
end

function MyApp:getBattleVersion()
    local DLDL_VERIFY_VERSION = GAME_VERSION:sub(0, GAME_VERSION:find("%(")-1)
    return DLDL_VERIFY_VERSION or "no_version"
end

function MyApp:isNativeLargerEqualThan(majorRequired, minorRequired, revisionRequired)
    local major, minor, revision = NATIVE_VERSION_CODE.major, NATIVE_VERSION_CODE.minor, NATIVE_VERSION_CODE.revision
    if major > majorRequired then
        return true
    elseif major < majorRequired then
        return false
    elseif minor > minorRequired then
        return true
    elseif minor < minorRequired then
        return false
    elseif revision > revisionRequired then
        return true
    elseif revision < revisionRequired then
        return false
    else
        return true
    end
end

if SHOW_STATS_WINDOW then
    if device.platform == "windows" then
        require("wxdebug.main")
    end
end

if UI_TEXTURE_RESOLUTION_HALF then
    setTextureResolutionHalf(true)
end

-- if TEXTURE_FORCE_RGBA4444 then
--     setTextureForceRGBA4444(true)
-- end

local function _ignore_resolution_half_(func) 
    local oldTextureResolutionHalf = isTextureResolutionHalf()
    setTextureResolutionHalf(false)
    func()
    setTextureResolutionHalf(oldTextureResolutionHalf)
end

local _QSkeletonView_setScissorEnabled = QSkeletonView.setScissorEnabled
function QSkeletonView:setScissorEnabled(...)
    local oldTextureResolutionHalf = isTextureResolutionHalf()
    setTextureResolutionHalf(false)
    _QSkeletonView_setScissorEnabled(self, ...)
    setTextureResolutionHalf(oldTextureResolutionHalf)
end
function QSkeletonActor:setScissorEnabled(...)
    local oldTextureResolutionHalf = isTextureResolutionHalf()
    setTextureResolutionHalf(false)
    _QSkeletonView_setScissorEnabled(self, ...)
    setTextureResolutionHalf(oldTextureResolutionHalf)
end

local _QSkeletonView_setScissorRects = QSkeletonView.setScissorRects
function QSkeletonView:setScissorRects(...)
    local oldTextureResolutionHalf = isTextureResolutionHalf()
    setTextureResolutionHalf(false)
    _QSkeletonView_setScissorRects(self, ...)
    setTextureResolutionHalf(oldTextureResolutionHalf)
end
function QSkeletonActor:setScissorRects(...)
    local oldTextureResolutionHalf = isTextureResolutionHalf()
    setTextureResolutionHalf(false)
    _QSkeletonView_setScissorRects(self, ...)
    setTextureResolutionHalf(oldTextureResolutionHalf)
end



function MyApp:createScanningScheduler()
    if self._scanningScheduler == nil then
        self._scanningSpeed = 0
        self._scanningScheduler = scheduler.scheduleGlobal(function()
            self._scanningSpeed = self._scanningSpeed + 0.008
            if self._scanningSpeed > 1 then
                self._scanningSpeed = 0
            end
        end, 0)
    end
end

function MyApp:getScanningSpeed()
    if self._scanningScheduler == nil then
        self:createScanningScheduler()
    end
    return self._scanningSpeed
end

function MyApp:updateUIViewSize(size)
    if size == nil or size.width == nil or size.height == nil then return end

    display.ui_width = size.width
    display.ui_height = size.height
    local dataCache = QCCBDataCache:sharedCCBDataCache()
    if dataCache and dataCache.setUIViewSize then
        QCCBDataCache:sharedCCBDataCache():setUIViewSize(CCSize(size.width, size.height))
    end
    QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.EVENT_UI_VIEW_SIZE_CAHNGE})

    if display.width > UI_VIEW_MIN_WIDTH then
        self:updateUIMaskLayer()
    end
end

function MyApp:saveUIViewSize()
    if display.ui_width >= UI_VIEW_MIN_WIDTH then

        display.ui_width = UI_VIEW_MIN_WIDTH
        local ui_view_size = tostring(display.ui_width)..";"..tostring(display.ui_height)
        self:getUserData():setValueForKey(QUserData.UI_VIEW_SIZE, ui_view_size)
    end
end


function MyApp:updateUIMaskLayer()
    -- if self._uiScene == nil then return end

    -- local gapWidth = display.width - display.ui_width
    -- local maskLayerWidth = 100
    -- if self._ly_mask_left == nil then
    --     self._ly_mask_left = CCLayerColor:create(ccc4(0, 0, 0, 255), maskLayerWidth, display.height)
    --     self._uiScene:addChild(self._ly_mask_left)
    -- end

    -- if self._ly_mask_right == nil then
    --     self._ly_mask_right = CCLayerColor:create(ccc4(0, 0, 0, 255), maskLayerWidth, display.height)
    --     self._uiScene:addChild(self._ly_mask_right)
    -- end

    -- self._ly_mask_left:setPositionX(gapWidth/2 - maskLayerWidth)
    -- self._ly_mask_right:setPositionX(display.ui_width + gapWidth/2)
end

return MyApp
