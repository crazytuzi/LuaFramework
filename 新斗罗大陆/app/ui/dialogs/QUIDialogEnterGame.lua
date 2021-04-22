
local QUIDialog = import(".QUIDialog")
local QUIDialogEnterGame = class("QUIDialogEnterGame", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUserData = import("...utils.QUserData")
local QTutorialDirector = import("...tutorial.QTutorialDirector")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QLogFile = import("...utils.QLogFile")
local QLoginHistory = import("...utils.QLoginHistory")
local ByteArray =  import("....framework.cc.utils.ByteArray")
local http = require 'socket.http'
local QBaseLoader = import("...loader.QBaseLoader")
local QLoginLoader = import("...loader.QLoginLoader")
local QUIWidgetLoadBar = import("..widgets.QUIWidgetLoadBar")
local QNotificationCenter = import("...controllers.QNotificationCenter")

local STATE = {"推荐", "维护", "即将", "火爆"}

function QUIDialogEnterGame:ctor(options)
    local ccbFile = "ccb/Dialog_EnterGame.ccbi"
    local callbacks = {
        {ccbCallbackName = "onLogin", callback = handler(self, self._onLogin)},
        {ccbCallbackName = "onLogout", callback = handler(self, self._onLogout)},
        {ccbCallbackName = "onAnnouncement", callback = handler(self, self._onAnnouncement)},
        {ccbCallbackName = "onUserProtocol", callback = handler(self, self._onUserProtocol)},
        {ccbCallbackName = "onPlayVideo", callback = handler(self, self._onPlayVideo)},
    }
    QUIDialogEnterGame.super.ctor(self, ccbFile, callbacks, options)

    if FinalSDK.isAndroidLetter() then
        CHANNEL_RES["gameOpId"] = "3010"
    end
    q.setButtonEnableShadow(self._ccbOwner.btn_enter)
    q.setButtonEnableShadow(self._ccbOwner.btn_zhuxiao)
    q.setButtonEnableShadow(self._ccbOwner.btn_annouce)
    q.setButtonEnableShadow(self._ccbOwner.btn_user_protocol)
    q.setButtonEnableShadow(self._ccbOwner.btn_play_video)

    self._oldPosX = self:getView():getPositionX()
    self._oldGapWidth = display.width - display.ui_width
    self:_reloadCCB()

    self._isTouchSwallow = false
    self.gameOpId = nil
    --读取缓存的index
    self._getIndex = tonumber(app:getUserData():getValueForKey(QUserData.SERVER_LIST_URL_INDEX))
    if self._getIndex == nil or self._getIndex < 0 then
        self._getIndex = 0
    end
    if SERVER_URL_BACK == nil or self._getIndex > #SERVER_URL_BACK then
        self._getIndex = 0
    end
    if QUICK_LOGIN.isQuick == true then
        app:setIgnoreLoadingAnyway(true)
        -- app:showLoading(true)
        self:connected()
        return
    end
    self._ccbOwner.sp_hot_blood:setVisible(false)
    self._ccbOwner.label_areaname:setString("正在获取服务器列表")

    -- self._ccbOwner.LoginNode:setVisible(false)
    self._ccbOwner.node_user:setVisible(false)
    if self._ccbOwner.node_anniversary then
        self._ccbOwner.node_anniversary:setVisible(false)
    end
    local userName = options.userName
    if userName then
        print("userName = "..userName)
        self._loggedIn = true
        local str = string.format("欢迎  %s", userName)
        self._ccbOwner.label_welcome:setString(str)
        local nameBackLayer = self._ccbOwner.layerColor_welcome
        local backLayerScaleX = nameBackLayer:getScaleX()
        local layerWidth = 91 + 10 * 3 + self._ccbOwner.label_welcome:getContentSize().width + 25  + 60
        local size = nameBackLayer:getPreferredSize()
        size.width = layerWidth
        nameBackLayer:setPreferredSize(size)
        if app:isDeliverySDKInitialzed() then
            nameBackLayer:setVisible(false)
            self._ccbOwner.label_welcome:setVisible(false)
        end
        self._ccbOwner.shadow:setVisible(true)

        self._ccbOwner.node_panel:setVisible(true)
        self._ccbOwner.node_panel:setTouchEnabled(true)
        self._ccbOwner.node_panel:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
        self._ccbOwner.node_panel:setTouchSwallowEnabled(true)
        self._ccbOwner.node_panel:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QUIDialogEnterGame.onTouch))

        self._ccbOwner.btn_user_protocol:setVisible(false)
        if (CHANNEL_RES.gameOpId == "3004" and FinalSDK.getChannelID() == "5") or (CHANNEL_RES.gameOpId ~= "3006" and CHANNEL_RES.gameOpId ~= "3009") then
            self._ccbOwner.btn_user_protocol:setVisible(true)
        end

        self._userName = userName or ""
        self._server = {}
        self:showLogoutButton(true)
        if not FinalSDK.showLoginTip() then
            self._ccbOwner.node_tf:setVisible(false)
        end
        if CHANNEL_RES and CHANNEL_RES["envName"] and (CHANNEL_RES["envName"] == "dljxol_238" or CHANNEL_RES["envName"] == "whjx_239" or CHANNEL_RES["envName"] == "yuewen_yinwan") then
            self._ccbOwner.node_tf:setVisible(false)
        end
        if not self:pullServerList() then
            return 
        end

        local native_version = GAME_VERSION:match("%((.+)%)")
        local label = CCLabelTTF:create("v" .. GAME_VERSION, global.font_default, 22)
        if native_version and QUtility:getNativeCodeVersion() and native_version ~= QUtility:getNativeCodeVersion() then
            label = CCLabelTTF:create(string.format("v%s(%s*)", GAME_VERSION:sub(0, GAME_VERSION:find("%(")-1), 
                QUtility:getNativeCodeVersion()), global.font_default, 22)
        end
        label:setAnchorPoint(ccp(0.0, 0.5))
        label:setPosition(ccp(24, 15))
        self._ccbOwner.versionNode:addChild(label)
    else
        self._ccbOwner.node_user:setVisible(false)
        self._ccbOwner.node_panel:setVisible(false)
        self._ccbOwner.shadow:setVisible(false)
    end
    if not FinalSDK.showLoginTip() then
        self._ccbOwner.node_tf:setVisible(false)
    end
    if CHANNEL_RES and CHANNEL_RES["envName"] and (CHANNEL_RES["envName"] == "dljxol_238" or CHANNEL_RES["envName"] == "whjx_239" or CHANNEL_RES["envName"] == "yuewen_yinwan") then
        self._ccbOwner.node_tf:setVisible(false)
    end
end

function QUIDialogEnterGame:onTouch(event)
    if event.name == "began" then
        if remote.serverInfos and #remote.serverInfos >= 1 then
            app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogChooseServer",
                options = {servers = remote.serverInfos, defaultServer = self._server, loginHistory = self._loginHistory, callback = handler(self,self.setServer)}},{isPopCurrentDialog = false})
        end
    end
end


--拉取服务器列表
function QUIDialogEnterGame:pullServerList()
    if app:isDeliverySDKInitialzed() then
        if FinalSDK.getChannelID() == "28" then
            CHANNEL_RES.gameOpId = "3006"
        end
        self.gameOpId = DEBUG_EXTEND_GAMEOPID or CHANNEL_RES.gameOpId
        local url = SERVER_URL..self.gameOpId
        if self._getIndex > 0 and SERVER_URL_BACK and #SERVER_URL_BACK > 0 then
            if self._getIndex > #SERVER_URL_BACK then
                self._getIndex = 0
                self._ccbOwner.label_areaname:setString("未获取服务器")
                QLogFile:error("Failed to get server list")
                app:alert({content="获取游戏服务器列表失败,点击确定重试。", title="系统提示", 
                    callback=function(state)
                        if state == ALERT_TYPE.CONFIRM then
                            self:pullServerList()
                        elseif state == ALERT_TYPE.CANCEL then
                            -- app:relogin()
                        end
                    end, btnDesc = {"重试","取消"}, isAnimation = false}, false, true)
                return false
            else
                url = SERVER_URL_BACK[self._getIndex]..self.gameOpId
            end
        end
        self._getIndex = self._getIndex + 1
        app:showLoading()
        httpGetNonsync(url, function (data)
            app:hideLoading()
            if self:safeCheck() then
                local request = data.request
                local responseData = request:getResponseData()
                return self:_pullServerList(responseData)
            end
        end, 3)
    else
        return self:_pullServerList()
    end
end

function QUIDialogEnterGame:_pullServerList(data)
    -- 游族中心服列表拉取
    local group_id 
    local opId
    -- self._downloader = QDownloader:new(CCFileUtils:sharedFileUtils():getWritablePath(), 1)
    if data then
        local unzippedBody = QUtility:unzipBuffer(data, #data)
        local jsonstring = unzippedBody or {}
        local serverList = json.decode(jsonstring)
        if not serverList then
            serverList = {} 
        end
        remote.serverConfig = {}
        remote.serverConfig.status = serverList.status
        remote.serverConfig.showOpen = serverList.show_open
        remote.serverConfig.openMessage = serverList.open_message
        remote.serverConfig.maintainMessage = serverList.maintain_message
        
        remote.openSoonServer = serverList.pre_open_srv
        if serverList.status == 1 then
            --保存本次请求服务器列表的url序号
            app:getUserData():setValueForKey(QUserData.SERVER_LIST_URL_INDEX, self._getIndex-1)
            remote.serverInfos = {}
            local tempServerList = {}
            local headIndex = 1

            for _,v in ipairs(serverList.data or {}) do
                if v.is_recommend and tonumber(v.is_recommend) == 1 then
                    table.insert(tempServerList, headIndex, v)
                    headIndex = headIndex + 1
                else
                    table.insert(tempServerList, v)
                end
            end
            for _, youzuServerInfo in ipairs(tempServerList) do
                local serverInfo = {}
                serverInfo.address = {ipAddress = youzuServerInfo.server_url, port = youzuServerInfo.server_port or 8118}
               
                serverInfo.status = youzuServerInfo.status
                serverInfo.zoneId = youzuServerInfo.zone_id
                serverInfo.is_hot_blood = youzuServerInfo.is_hot_blood or false
                serverInfo.name = youzuServerInfo.name
                serverInfo.serverId = youzuServerInfo.server_id
                table.insert(remote.serverInfos, serverInfo)
            end
            group_id = self.gameOpId
        else
            self:pullServerList()
        end
    end

    remote.serverListGroupId = group_id or ENVIRONMENT_NAME
    remote.serverListOpId = opId
    if remote.serverInfos ~= nil then
        for _,serverInfo in pairs(remote.serverInfos) do
            if DEBUG_EXTEND_GAMEOPID then
                serverInfo.name = CHANNEL_RES.gameName
            end
        end
        local defaultServer = nil
        if remote.defaultServerInfo and defaultServer == nil then
            defaultServer = remote.defaultServerInfo
        end
        local latestId = app:getUserData():getValueForKey(QUserData.DEFAULT_SERVERID)
        print("latestId", latestId)
        --原来这里存的是serverId 现在改为zone_id，为了兼容来的serverId所有判断两边，优先判断zone_id
        if latestId ~= nil and not defaultServer then
            for _,serverInfo in pairs(remote.serverInfos) do
                if serverInfo.zoneId == latestId then
                    defaultServer = serverInfo
                    break
                end
            end
        end
        if latestId ~= nil and not defaultServer then
            for _,serverInfo in pairs(remote.serverInfos) do
                if serverInfo.serverId == latestId then
                    defaultServer = serverInfo
                    break
                end
            end
        end
        if not defaultServer then
            --优先推荐新服
            for _,serverInfo in pairs(remote.serverInfos) do
                if serverInfo.status and serverInfo.status == 2 then
                    defaultServer = serverInfo
                    break
                end
            end
        end
        --
        if #remote.serverInfos > 0 and defaultServer == nil then
            defaultServer = remote.serverInfos[1]
        end

        -- 检测是否存在历史登入信息
        self._loginHistory = QLoginHistory.getLoginHistoryFromServer()

        -- 第一次登陆不推荐
        local date = q.date("*t", q.serverTime())
        if not FinalSDK.isHx() and #self._loginHistory == 0 and 5 <= date.hour and date.hour < 10 then
            self._ccbOwner.label_areaname:setString("请选择服务器")
        else
            self:setServer(defaultServer or {})
        end
    end

    -- 拉取公告

    self._ccbOwner.LoginNode:setVisible(true)
    self._ccbOwner.node_user:setVisible(true)
    if self._ccbOwner.node_anniversary then
        self._ccbOwner.node_anniversary:setVisible(true)
    end
    local date = q.date("%Y/%m/%d",q.serverTime())
    local showAnniversary = false
    local startTime = QStaticDatabase:sharedDatabase():getConfigurationValue("main_scene_anniversary_start")
    local endTime = QStaticDatabase:sharedDatabase():getConfigurationValue("main_scene_anniversary_end")
    if date >= startTime and date <= endTime then
        showAnniversary = true
    end
    makeNodeOpacity(self._ccbOwner.LoginNode, 0)
    makeNodeOpacity(self._ccbOwner.node_user, 0)
    makeNodeOpacity(self._ccbOwner.node_anniversary, 0)

    local announce = app:getAnnouncement() 
    if announce and next(announce) then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAnnouncement",
            options = {confirmCallBack = function()
                makeNodeFadeToByTimeAndOpacity(self._ccbOwner.LoginNode, 0.2, 255)
                makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_user, 0.2, 255)
                if showAnniversary then
                    makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_anniversary, 0.2, 255)
                end
            end}}, {isPopCurrentDialog = false})
    else
        makeNodeFadeToByTimeAndOpacity(self._ccbOwner.LoginNode, 0.2, 255)
        makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_user, 0.2, 255)
        if showAnniversary then
            makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_anniversary, 0.2, 255)
        end
    end
    
    -- if self._downloader then
    --     if  self._downloader.purge then
    --         self._downloader:purge()
    --     end
    -- end

    return true
end

function QUIDialogEnterGame:connected()
    print("QUIDialogEnterGame:connected")
    -- self._ccbOwner.node_user:setVisible(false)
    self._ccbOwner.LoginNode:setVisible(false)
    self:_setButtonsVisible(false)

    self._loadBar = QUIWidgetLoadBar.new()
    self._loadBar:setPercentVisible(true)
    self._loadBar:setTipVisible(true)
    self._loadBar:setTip("游戏加载中，不消耗流量...")
    self._ccbOwner.node_loading:addChild(self._loadBar)
    CalculateUIBgSize(self._ccbOwner.node_loading , 1280)
    self._loader = QLoginLoader.new({loginError = handler(self,self.handleLoginError), server = self._server})
    self._loader:addEventListener(QBaseLoader.PROGRESSING, handler(self, self._onProgressing))
    self._loader:setFakePercent(0)
    RunActionDelayTime(self:getView(), function()
        self._loader:setFakePercent(2)
        self._loader:start()
    end, 0.2)
end

function QUIDialogEnterGame:handleLoginError(data)
    -- body
    if self._appear then
        -- self._ccbOwner.node_user:setVisible(true)
        self._ccbOwner.LoginNode:setVisible(true)
        if self._loadBar then
            self._loadBar:removeSelf()
        end
        self:_onFinish()
    end
    if data and data.error == "API_CHECK_SERVER_REGISTER_CLOSE" then
        -- 点击确认之后，选择推荐服务器
        self:_autoChooseServer()
    end
end

function QUIDialogEnterGame:_onProgressing(event)

    local progress = math.ceil(event.percent)
    if self:safeCheck() then
        self._loadBar:setPercent(progress / 100)
    end
end

function QUIDialogEnterGame:_onFinish( ... )
    if self._loader then 
        self._loader:removeAllEventListeners() 
        self._loader = nil
    end
end

-- 设置左侧三个按钮是否显示
function QUIDialogEnterGame:_setButtonsVisible(isShow)
    self._ccbOwner.btn_annouce:setVisible(isShow)
    self._ccbOwner.btn_user_protocol:setVisible(isShow)
    self._ccbOwner.btn_play_video:setVisible(isShow)
end

function QUIDialogEnterGame:showLogoutButton(visible)
    if app:isDeliveryIntegrated() then 

        if FinalSDK.isHXShenhe() then
            SKIP_TUTORIAL = true
            SKIP_FIRST_BATTLE_TUTORIAL = true
        end
        
        print("FinalSDK.isHasLogoutBtn()==",FinalSDK.isHasLogoutBtn())
        print("FinalSDK.isHXShenhe()==",FinalSDK.isHXShenhe())

        if not FinalSDK.isHasLogoutBtn() then
            self._ccbOwner.btn_logout:setVisible(false)
        else
            self._ccbOwner.btn_logout:setVisible(true)
        end
    else
        self._ccbOwner.btn_logout:setVisible(visible)
    end
end

function QUIDialogEnterGame:showControls(flag)
    self._ccbOwner.node_panel:setVisible(flag)
    self._ccbOwner.shadow:setVisible(flag)
end

function QUIDialogEnterGame:setServer(serverInfo)
    -- QPrintTable(serverInfo)
    -- print("serverInfo = ")
    -- printTable(serverInfo)
    self._server = serverInfo
    printTable(serverInfo)
    remote.selectServerInfo = serverInfo
    --设置区服后重置一下本地记录
    app:getUserOperateRecord():resetRecord()

    if self._server.name then
        -- self._ccbOwner.label_areaname:setString(string.format("%s(热血服)",self._server.name))
        self._ccbOwner.label_areaname:setString(self._server.name)
    end
    -- printTable(self._server)
    if not self._server.status then
        self._server.status = 11
    end
    if self._server.status == 2 then
        QSetDisplayFrameByPath(self._ccbOwner.sp_server_stated, QResPath("serverStateds")[1])
        self._ccbOwner.tf_state:setString(STATE[1])
        self._ccbOwner.tf_state:setColor(UNITY_COLOR_LIGHT.green)
    elseif self._server.status == 4 or self._server.status == 5 or self._server.status == 6 then
        --4 维护  5 停服  6 合服
        QSetDisplayFrameByPath(self._ccbOwner.sp_server_stated, QResPath("serverStateds")[2])
        self._ccbOwner.tf_state:setString(STATE[2])
        self._ccbOwner.tf_state:setColor(UNITY_COLOR_LIGHT.ash)
    elseif self._server.status == 9 or self._server.status == 10 or self._server.status == 11 then
        -- 10 待开启 11 待开服
        QSetDisplayFrameByPath(self._ccbOwner.sp_server_stated, QResPath("serverStateds")[3])
        self._ccbOwner.tf_state:setString(STATE[3])
        self._ccbOwner.tf_state:setColor(UNITY_COLOR_LIGHT.orange)
    else
        QSetDisplayFrameByPath(self._ccbOwner.sp_server_stated, QResPath("serverStateds")[4])
        self._ccbOwner.tf_state:setString(STATE[4])
        self._ccbOwner.tf_state:setColor(UNITY_COLOR_LIGHT.red)
    end

    self._ccbOwner.sp_hot_blood:setVisible(self._server.is_hot_blood or false)
end


function QUIDialogEnterGame:viewDidAppear()
    QUIDialogEnterGame.super.viewDidAppear(self) 
    self._logoutCallback = nil 

    QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_CHANGE_GLVIEW_SIZE, self._reloadCCB, self)
end

function QUIDialogEnterGame:viewWillDisappear()
    QUIDialogEnterGame.super.viewWillDisappear(self)  
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_CHANGE_GLVIEW_SIZE, self._reloadCCB, self)
end

function QUIDialogEnterGame:_reloadCCB(event)
    local gapWidth = display.width - display.ui_width
    local gapHeight = display.height - display.ui_height

    local offset = 0
    if event and event.name == "EVENT_CHANGE_GLVIEW_SIZE" then
        offset = display.ui_width/2 - self._oldPosX + self._oldGapWidth/2
    end
    self:getView():setPositionX(display.ui_width/2 - offset + gapWidth/2)

    self._ccbOwner.node_user:setPositionX(gapWidth/2 - gapWidth/2)
    self._ccbOwner.node_user:setPositionY(display.ui_height - gapHeight/2)

    self._ccbOwner.LoginNode:setPositionX(display.ui_width/2)
    self._ccbOwner.LoginNode:setPositionY(-gapHeight/2)

    self._ccbOwner.node_loading:setPositionX(display.ui_width/2)
    self._ccbOwner.node_loading:setPositionY(-gapHeight/2)

    self._ccbOwner.node_anniversary:setPositionX(display.ui_width)
    self._ccbOwner.node_anniversary:setPositionY(display.ui_height - gapHeight/2)

    self._ccbOwner.node_tf:setPositionX(display.ui_width)
    self._ccbOwner.node_tf:setPositionY(display.ui_height + gapHeight/2)
end


function QUIDialogEnterGame:_onAnnouncement(event)
    app.sound:playSound("common_close")
    local announce = app:getAnnouncement() 
    if announce and next(announce) then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAnnouncement"}, {isPopCurrentDialog = false})
    end
end

function QUIDialogEnterGame:_onUserProtocol(event)
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUserProtocol"}, {isPopCurrentDialog = false})
end

function QUIDialogEnterGame:_onPlayVideo(event)
    -- 播放视频时候屏蔽登录页面的其他输入
    if not self._touchMask then
        self._touchMask = CCNode:create()
        self._touchMask:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
        self._touchMask:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
        self._touchMask:setTouchSwallowEnabled(true)
        self:getView():addChild(self._touchMask)
    end

    self._touchMask:setTouchEnabled(true)
    local callback = function()
        self._touchMask:setTouchEnabled(false)
    end

    if not app:playOpVideoMp4(callback) then
        callback()
    end
end

function QUIDialogEnterGame:_onLogout()
    return app:alert({content = "是否确定注销", title = "系统提示", callback = function (state)
            if state == ALERT_TYPE.CONFIRM then
                self:logout()
            end
        end})
end
 

function QUIDialogEnterGame:logout()
    app.sound:playSound("common_small")
    -- app._announcementViewed = false

    --关闭服务器连接
    -- local xmpp =  app:getXMPPClient()
    -- if xmpp then
    --     xmpp:disconnect()
    -- end
    if app:isDeliverySDKInitialzed() then
        scheduler.performWithDelayGlobal(function()
                print("QDeliveryWrapper:logout()")
                -- QDeliveryWrapper:logout()
                if device.platform == "android" then
                    self._logoutCallback = function ( ... )
                        -- scheduler.performWithDelayGlobal(function()
                        --     app._isLogin = false
                        --     QLogFile:debug("MyApp: loginCallback " .. tostring(self._isLogin))
                        --     self:playEffectOut()
                        --     -- app:showLoading()
                        --     -- app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
                        --     app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG,
                        --         uiClass = "QUIDialogEnterGame", options={userName=nil} })
                        --     app:login()
                        -- end, 1)
                    end
                elseif device.platform == "ios" then
                    app._isLogin = false
                    self:playEffectOut()
                    self._logoutCallback = function ( ... )
                        QLogFile:debug("MyApp: loginCallback " .. tostring(self._isLogin))
                        app:showLoading()
                        -- app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
                        -- app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_PAGE, uiClass="QUIPageLogin"})
                        scheduler.performWithDelayGlobal(function()
                            app:afterSDKLogin()
                        end, 1.5)
                    end
                end
                FinalSDK:logout(self._logoutCallback)
                
        end, 1)
        
        -- 
    else
        app._isLogin = false
        app:getUserData():setValueForKey(QUserData.AUTO_LOGIN, QUserData.STRING_FALSE)
        app:getClient():close()
        local serverLocation = string.split(SERVER_URL, ":")
        app:getClient():reopen(serverLocation[1], serverLocation[2], function()
            app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
            return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG,
                uiClass = "QUIDialogGameLogin" })
        end)
    end

end

function QUIDialogEnterGame:_onLogin(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_enter) == false then return end

    app.sound:playSound("common_small")
    --埋点 点击进入游戏
    remote:triggerBeforeStartGameBuriedPoint("10050")

    if self._loggedIn then
        if FinalSDK.getSessionId() ~= nil and FinalSDK.getSessionId() ~= "" and self:_closeServer() then
            local openId = FinalSDK.getSessionId()
            local channel = FinalSDK.getChannelID()
            local response = remote.bindingPhone:getYWUserBindPhone(openId, channel)
            if response.code == -1 then
                app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBindingPhoneYW"}, {isPopCurrentDialog = false})
                return
            end
        end
        if remote.serverConfig then
            if remote.serverConfig.showOpen then
                app:alert({content=remote.serverConfig.openMessage or "", title="系统提示", nil})
                return
            end
        end
        -- if not app._announcementViewed then return end
        if self._server.serverId then
            local serverInfo = nil
            for _,value in pairs(remote.serverInfos) do
                if value.serverId == self._server.serverId then
                    serverInfo = value
                end
            end
           
            if  serverInfo then
                local errorCode
                if serverInfo.status then
                    if serverInfo.status == 4 or serverInfo.status == 5 or serverInfo.status == 6 then
                        errorCode = "SERVER_STATUS_4"
                    end
                end
                if errorCode then
                    -- local errorMsg = QStaticDatabase:sharedDatabase():getErrorCode(errorCode)
                    local errorStr = remote.serverConfig.maintainMessage or errorCode
                    -- if errorMsg then
                    --     errorStr = errorMsg.desc or errorCode
                    -- else
                    --     errorStr = errorCode
                    -- end
                 
                    app:alert({content=errorStr, title="系统提示", callback = function (state)
                        if state == ALERT_TYPE.CONFIRM then
                            -- 点击确认之后，选择推荐服务器
                            -- self:_autoChooseServer()
                        end
                    end})
                else
                    app:setIgnoreLoadingAnyway(true)
                    -- app:showLoading(true)
                    --关闭中心服务器链接
                    app:getClient():close()
                    app:getClient():reopen(serverInfo.address.ipAddress, serverInfo.address.port, handler(self, self.connected))
                    audio.stopBackgroundMusic()
                end
            else
                QLogFile:debug("error can not find current serverId from remote.serverInfos(1.self._server 2.remote.serverInfosremote.serverInfos)")
                QLogFile:debug(self._server)
                QLogFile:debug(remote.serverInfos)
                local errorMsg = QStaticDatabase:sharedDatabase():getErrorCode("SERVER_CANNOT_FIND") or "找不到服务器"
                app:alert({content = errorMsg.desc, title = "系统提示"})
            end
        else
            local errorMsg = "服务器为空"--QStaticDatabase:sharedDatabase():getErrorCode("SERVER_EMPTY") or "服务器为空"
            app:alert({content = errorMsg, title = "系统提示"})
        end
    else
        if app:isDeliveryIntegrated() then
            app._loginCallback = function ( ... )
                -- app:showLoading()
                app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
                scheduler.performWithDelayGlobal(function()
                    app:afterSDKLogin()
                end, 1.5)
            end 
            FinalSDK:login(app._loginCallback)
        else
            app:_loginWithoutDelivery()
        end
    end
end

function QUIDialogEnterGame:_autoChooseServer()
    -- QPrintTable(remote.serverInfos)
    for _, serverInfo in ipairs(remote.serverInfos) do
        if serverInfo.status == 2 then
            app.tip:floatTip("自动选择推荐服务器："..serverInfo.name)
            remote.defaultServerInfo = serverInfo
            self:setServer(serverInfo)
        end
    end
end

function QUIDialogEnterGame:_closeServer()
    local time = QStaticDatabase:sharedDatabase():getChannelCloseTime(FinalSDK.getChannelID())
    if time ~=nil then
        time = q.getDateTimeByStr(time)
		time = q.OSTime(time)
        if time <= q.serverTime() then
            return true
        end
    else
        return false
    end
end

return QUIDialogEnterGame


