--
-- Author: Qinyuanji
-- Date: 2016-05-20
-- This class is the login resource loader.

local QBaseLoader = import(".QBaseLoader")
local QLoginLoader = class("QLoginLoader", QBaseLoader)

local QStaticDatabase = import("..controllers.QStaticDatabase")
local QUserData = import("..utils.QUserData")
local QCrashLogUploader = import("..utils.QCrashLogUploader")
local QLoginHistory = import("..utils.QLoginHistory")
local QLogFile = import("..utils.QLogFile")
local QUIViewController = import("..ui.QUIViewController")
local QNavigationController = import("..controllers.QNavigationController")
local QTutorialDirector = import("..tutorial.QTutorialDirector")

-- local cachedPlists = {
    -- {"ui/common.plist"},
    -- {"ui/common2.plist"},
    -- {"ui/common3.plist"},
    -- {"ui/common4.plist"},
    -- {"ui/intro_bj.plist"},
    -- {"ui/intro_bj3.plist"},
    -- {"ui/intro_bj4.plist"},
    -- {"ui/intro_bj5.plist"},
    -- {"ui/Pagehome.plist"},
    -- {"ui/Pagehome2.plist"},
    -- {"ui/pagehome_effect.plist"},
    -- {"ui/pagehome_effect2.plist"},
-- }


function QLoginLoader:ctor(options)
	QLoginLoader.super.ctor(self)

    if not options then 
        options = {}
    end
	self._server = options.server
    self._loginErrorCallback = options.loginError

    self._mustLoadApiList = {}
    self._loadPercent = {totalCount = 0, currentCount = 0, totalPercent = 80}

    self._cachedList = {}
    self._cachePercent = {totalCount = 0, currentCount = 0, totalPercent = 20}
    self._cachedPic = {}

    if FinalSDK.isHXShenhe() then
        SKIP_TUTORIAL = true
        SKIP_FIRST_BATTLE_TUTORIAL = true
    end

    if ENABLE_CACHE_UI_PIC then
        --table.insert(self._cachedList, {path = "ui/intro_bj6.png", isPic = true, isRetain = true})
        table.insert(self._cachedList, {path = "ui/pagehome_effect2.plist", isPlist = true})
        table.insert(self._cachedList, {path = "ui/z_liuguang_1.plist", isPlist = true})
        table.insert(self._cachedList, {path = "ui/huodongtubiao_new.plist", isPlist = true})
        table.insert(self._cachedList, {path = "ui/Elite_normol.plist", isPlist = true})
        table.insert(self._cachedList, {path = "fca/zc_shuibo/png/zc_shuibo.plist", isPlist = true})
        table.insert(self._cachedList, {path = "fca/zhujiemian_tx/fuben_jian/png/fuben_jian.plist", isPlist = true})
        table.insert(self._cachedList, {path = "fca/zhujiemian_tx/zjm_rongjiang/png/zjm_rongjiang.plist", isPlist = true})
        table.insert(self._cachedList, {path = "fca/zhujiemian_tx/taohua/png/taohua.plist", isPlist = true})
        table.insert(self._cachedList, {path = "fca/zhujiemian_tx/fuben/png/fuben.plist", isPlist = true})
        table.insert(self._cachedList, {path = "fca/zhujiemian_tx/wuhundian_1/png/wuhundian_1.plist", isPlist = true})
        table.insert(self._cachedList, {path = "font/IntroName.fnt", isFont = true})
        table.insert(self._cachedList, {path = "font/IntroName_hui.fnt", isFont = true})
        table.insert(self._cachedList, {path = "font/FontTitleName.fnt", isFont = true})
        table.insert(self._cachedList, {path = "font/FontTitleName.fnt", isFont = true})
    end
end

function QLoginLoader:start()
	remote:readyLogin()

	-- CCMessageBox("connected", "")
    local function successFunc(data)
        print("laytest 10000")
        remote.user.isLoginFrist = true 
        if self._server ~= nil then
            app:getUserData():setValueForKey(QUserData.DEFAULT_SERVERID, self._server.zoneId)
        end

        -- @qinyuanji, serverEnv is the real server target
        -- @zhangnan, this line may crash under QUICK_LOGIN.isQuick = true, you may comment it to bypass
        if remote.selectServerInfo ~= nil then
            remote.selectServerInfo.serverId = data.serverEnv
        end

        remote:loginEnd()
        QDeliveryWrapper:setSandbox(remote.user.payIsSandbox)

        -- Set userId for bugly

        if buglySetUserId then
            local serverZoneID = ""
            if remote.selectServerInfo then
                serverZoneID = remote.selectServerInfo.zoneId or ""
            end
            buglySetUserId(serverZoneID.."_"..remote.user.userId)
        end

        if QNotification.setRemotePushAccount then
            QNotification:setRemotePushAccount(remote.user.userId)
        end
       

        --首次登录 减少api调用
        if data.firstLogin then
          
            local _value = table.formatString(app.tutorial:getStage(), "^", ";")
            remote.flag:set(remote.flag.FLAG_TUTORIAL_STAGE, _value)

            local _value = table.formatString(app.tip:getUnlockTutorial(), "^", ";")
            remote.flag:set(remote.flag.FLAG_UNLOCK_TUTORIAL, _value)

            app:getServerChatData():deserializePrivateChannel()
            app:getServerChatData():retrieveHistoryData()

            self:startLoading()

            app:sendGameEvent(GAME_EVENTS.GAME_EVENT_ENTER_GAME, true)

        else
            remote.flag:initGet(
            function(data)
    			if data.FLAG_TUTORIAL_LOCK ~= "" then
    				-- SKIP_TUTORIAL = true
    				local stage = app.tutorial:getStage()
    				stage.guideEnd = 1
    				app.tutorial:setStage(stage)
    			else
    				if data.FLAG_TUTORIAL_STAGE == "" then
    					local _value = table.formatString(app.tutorial:getStage(), "^", ";")
    					remote.flag:set(remote.flag.FLAG_TUTORIAL_STAGE, _value)
    				else
    					app.tutorial:initStage(data.FLAG_TUTORIAL_STAGE)
    				end 
    			end

    			if data.FLAG_UNLOCK_TUTORIAL == "" then
    				local _value = table.formatString(app.tip:getUnlockTutorial(), "^", ";")
    				remote.flag:set(remote.flag.FLAG_UNLOCK_TUTORIAL, _value)
    			else
    				app.tip:initUnlockTutorial(data.FLAG_UNLOCK_TUTORIAL)
    			end
                app.tip:initReduceUnlokState()

                if data.DYNAMIC_CONFIG_KEY == "" then
                    local dynamicConfig = remote.userDynamic:getCurrentUnlockDynamic()
                    if q.isEmpty(dynamicConfig) == false then
                        local _value = table.formatString(dynamicConfig, "^", ";")
                        remote.flag:set(remote.flag.DYNAMIC_CONFIG_KEY, _value)
                    end
                else
                    remote.userDynamic:updateServerDynamicStatus(data.DYNAMIC_CONFIG_KEY)
                end

    			app:getServerChatData():deserializePrivateChannel()
    			app:getServerChatData():retrieveHistoryData()

    			self:startLoading()

    			app:sendGameEvent(GAME_EVENTS.GAME_EVENT_ENTER_GAME, true)

    			end)
      	end
      
        -- start upload crash data
        printInfo("serverEnv = " .. tostring(data.serverEnv))
        printInfo("clientCrashLogUrl = " .. tostring(data.clientCrashLogUrl))
        remote.user.serverEnv = data.serverEnv
        remote.user.clientCrashLogUrl = data.clientCrashLogUrl
        -- if data.serverEnv ~= nil and data.clientCrashLogUrl ~= nil then
        --     local uploader = QCrashLogUploader:sharedCrashLogUploader()
        --     uploader:start(data.clientCrashLogUrl, data.serverEnv)
        -- end

        -- -- compress and upload log files
        -- QLogFile:compressOlderLogs()
        -- QLogFile:uploadLogs(data.clientCrashLogUrl, data.serverEnv)
    end

    local function success(data)
        self:setFakePercent(5)
        scheduler.performWithDelayGlobal(function()
            successFunc(data)
        end, 0)
    end

    local function fail(data)
        app:setIgnoreLoadingAnyway(false)
        app:hideLoading()

        local errorStr
        if data.error then
            local errorCode = QStaticDatabase:sharedDatabase():getErrorCode(data.error)
            if errorCode ~= nil then
                errorStr = errorCode.desc or data.error
            end
        end

        if not errorStr then
            errorStr = "连接服务器失败！"
        end 
        app:alert({content=errorStr,callback = function ( ... )
            -- body
            if self._loginErrorCallback then
                self._loginErrorCallback(data)
            end
        end}, false)


        -- app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
    end

    if QUICK_LOGIN.isQuick == true then
        print("quick login ", tostring(QUICK_LOGIN.gameArea))
        app:getClient():userQuickLoginRequest(QUICK_LOGIN.osdkUserId, QUICK_LOGIN.gameArea, QUICK_LOGIN.deviceModel, QUICK_LOGIN.deviceId, QUICK_LOGIN.channel, success, fail)
        return
    end
    if app:isDeliveryYwmb() or app:isDeliveryHX() then
        -- local accessToken = app:getUserData():getValueForKey(QUserData.USER_TOKEN)
        local accessToken = FinalSDK.getSessionId()
        print("yuewen login " .. accessToken)
        if FinalSDK.isHXShenhe() then
            app:getClient():dldlHxUserLogin(self._server.serverId, self._server.zoneId, accessToken, success, fail)
        else
            app:getClient():dldlUserLogin(self._server.serverId, self._server.zoneId, accessToken, success, fail)
        end
    elseif app:isDeliveryHJ() then
        local accessToken = FinalSDK.getSessionId()
        app:getClient():dldHJUserLogin(self._server.serverId, self._server.zoneId, accessToken, success, fail)
    else
        print("system login")
        -- printTable(self._server)
        app:getClient():userLogin(remote.user.userId, remote.user.session, self._server.serverId, self._server.zoneId, nil, success, fail)
        
    end

end

-- 登录 分拆接口
function QLoginLoader:_countLoadDataFromServer()
    -- body
    local client = app:getClient() 
    --model中登录的接口调用
    local loadApiDataModels = remote.dataModels or {}
    for _, value in ipairs(loadApiDataModels) do
        table.insert(self._mustLoadApiList, {apiFunc = handler(remote[value], remote[value].loginEnd)})
    end

    table.insert(self._mustLoadApiList, {apiFunc = handler(client, client.getRechargetHistory)})
    table.insert(self._mustLoadApiList, {apiFunc = handler(client, client.getShopGetAll)})
    -- 因为创角的时候，后端会给角色赠送item（比如武魂玉）。所以要拉一下数据
    table.insert(self._mustLoadApiList, {apiFunc = handler(client, client.getItemGet)})
    if QNotification.isRemotePushEnable then
        if QNotification:isRemotePushEnable() then
            table.insert(self._mustLoadApiList, {apiFunc = handler(client, client.getRemoteNotificationSetting)})
        end
    end

    --首次登陆 不拉去
    if not (app.tutorial:isTutorialFinished() == false and app.tutorial:getStage().forced == QTutorialDirector.Guide_Start) then
        -- table.insert(self._mustLoadApiList, {apiFunc = handler(client, client.getDungeonInfo)})
        table.insert(self._mustLoadApiList, {apiFunc = handler(remote.mails, remote.mails.mailGetRequest)})
        table.insert(self._mustLoadApiList, {apiFunc = handler(remote.tower, remote.tower.getTowerInfoByLogin)})
        table.insert(self._mustLoadApiList, {apiFunc = handler(remote.stormArena, remote.stormArena.getStormInfoByLogin)})
        table.insert(self._mustLoadApiList, {apiFunc = handler(remote.union, remote.union.getUnionInfoWhenLogin)})
        table.insert(self._mustLoadApiList, {apiFunc = handler(remote.union, remote.union.getUnionBossWhenLogin)})
        table.insert(self._mustLoadApiList, {apiFunc = handler(remote.thunder, remote.thunder.getThunderInfoWhenLogin)})   
    end

    local totalApi = #self._mustLoadApiList
    self._fakeCount = math.ceil(totalApi * self._fakePercent/self._loadPercent.totalPercent)
    self._loadPercent.totalCount = #self._mustLoadApiList + self._fakeCount
    self._loadPercent.currentCount = 1 + self._fakeCount
end

function QLoginLoader:_countLoadingForCacheCCB()
    self._cachePercent.totalCount = #self._cachedList
    self._cachePercent.currentCount = 1
end

function QLoginLoader:startLoading()
    self._isStartLoading = true
    --计算加载的数量
    self:_countLoadDataFromServer()
    self:_countLoadingForCacheCCB()

    --开始加载
    self:_sendApiRequest()
    self:_startLoadCache()
    app:disableTextureCacheScheduler()
end

function QLoginLoader:updatePercent()
    local cachePercent, loadPercent = 0
    if self._cachePercent.totalCount > 0 then
        cachePercent = (self._cachePercent.currentCount - 1) * self._cachePercent.totalPercent/self._cachePercent.totalCount
    else
        cachePercent = self._cachePercent.totalPercent
    end
    if self._loadPercent.totalCount > 0 then
        loadPercent = (self._loadPercent.currentCount - 1) * self._loadPercent.totalPercent/self._loadPercent.totalCount
    else
        loadPercent = self._loadPercent.totalPercent
    end
    self:setPercent(cachePercent + loadPercent)
end

--前面的20%留给widget缓存使用
function QLoginLoader:_startLoadCache()
    self:updatePercent()
    if self._cachePercent.currentCount <= self._cachePercent.totalCount then
        local v = self._cachedList[self._cachePercent.currentCount]
        if v.isPlist == true then
            singletons.spriteFrameCache:addSpriteFramesWithFile(v.path)
        elseif v.isFont == true then
            CCLabelBMFont:create("", v.path)
        elseif v.isPic == true then
            local tx = CCTextureCache:sharedTextureCache():addImage(v.path)
            if v.isRetain == true and tx then
                if self._cachedPic[v.path] == nil then
                    self._cachedPic[v.path] = tx
                    tx:retain()
                end
            end
        end

        self._cachePercent.currentCount = self._cachePercent.currentCount + 1
        scheduler.performWithDelayGlobal(handler(self, self._startLoadCache), 0)
    else
        self:finish()
    end
end

function QLoginLoader:finish()
    if self._loadPercent.currentCount <= self._loadPercent.totalCount then
        return
    end
    if self._cachePercent.currentCount <= self._cachePercent.totalCount then
        return
    end
    scheduler.performWithDelayGlobal(function()
        -- 保存 当前的历史登入信息
        QLoginHistory.changeLoginHistory()
        remote.redTips:initRedTips()
        app:setIgnoreLoadingAnyway(false)
        app:hideLoading()
        app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
        app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)

        if not SKIP_FIRST_BATTLE_TUTORIAL and app.tutorial:isTutorialFinished() == false and app.tutorial:getStage().forced == QTutorialDirector.Guide_Start then
        -- if true then
            --埋点 开始新手剧情
            remote:triggerBeforeStartGameBuriedPoint("10060")

            app:setMusicSound(1)
            app:getSystemSetting():setMusicState("on")
            app:getSystemSetting():setSoundState("on")
            app:getSystemSetting():reload()

            app.tutorial:startTutorial(QTutorialDirector.Stage_1_FirstBattle)

        else
            if FinalSDK.isHXShenhe() then
                if remote.thunder.thunderInfo == nil then
                    remote.thunder:thunderInfoRequest(function ()
                        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_PAGE, uiClass="QUIPageMainMenu"})
                        -- get user data when user is loaded
                        app:getSystemSetting():reload()
                        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogThunder"})
                    end)
                else
                    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_PAGE, uiClass="QUIPageMainMenu"})
                    -- get user data when user is loaded
                    app:getSystemSetting():reload()
                    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogThunder"})
                end
            else
                app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_PAGE, uiClass="QUIPageMainMenu"})
                -- get user data when user is loaded
                app:getSystemSetting():reload()
            end
        end
    end, 0)
end

function QLoginLoader:_sendApiRequest()
    self:updatePercent()

    local index = self._loadPercent.currentCount - self._fakeCount
    if self._mustLoadApiList[index] and self._loadPercent.currentCount <= self._loadPercent.totalCount then
        self._mustLoadApiList[index].apiFunc(function()
            self._loadPercent.currentCount = self._loadPercent.currentCount + 1;
            self:_sendApiRequest()
        end,function()
            printError(string.format("loadDataFromServer fail  curloadindex = %d",self._loadPercent.currentCount))
            self._loadPercent.currentCount = self._loadPercent.currentCount + 1;
            self:_sendApiRequest()
        end)
    else
        self:finish()
    end
end

function QLoginLoader:setFakePercent(percent)
    if self._isStartLoading ~= true then
        self._fakePercent = percent
        self:setPercent(percent)
    end
end

-- 等待加载完数据
-- function QLoginLoader:_waitForLoadDataFromServer( )
--     -- body
--     -- print("---111-------cur loadindex  ",self._curLoadIndex,self._totalLoadCount)
--     if self._curLoadIndex -1 == self._totalLoadCount then
--         self:finish()
--         return
--     end
--     scheduler.performWithDelayGlobal(handler(self, self._waitForLoadDataFromServer), 0)
-- end

return QLoginLoader
