local PlatformProxy = class("PlatformProxy")
local ReconnectLayer = require("app.scenes.common.ReconnectLayer")
local funLevelConst = require("app.const.FunctionLevelConst")


function PlatformProxy:ctor()
    if patchMe and patchMe("platform", self) then return end  

    self._server = nil
    self._token = ""
    self._wantAutoEnterGame = false
    self._opId = 0
    self._platform_uid = ""
    self._yzuid = ""

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_LOGIN_SUCCESS, handler(self, self._onLoginSuccess), self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECV_FLUSH_DATA, handler(self, self._onRecvFlushData), self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_NEED_CREATE_ROLE, handler(self, self._onNeedCreateRole), self)
    --uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_NEED_RELOGIN, handler(self, self._onNeedRelogin), self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_MAINTAIN, handler(self, self._onMaintain), self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CREATED_ROLE, handler(self, self._onCreatedRole), self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_USER_LEVELUP, handler(self, self._onLevelUp), self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_BAN_USER, handler(self, self._onBanUser), self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TOKEN_EXPIRED, handler(self, self._onTokenExpired), self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_NOT_ALLOWED, handler(self, self._onNotAllowed), self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_WRONG_VERSION, handler(self, self._onWrongVersion), self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_BLACKCARD_WARNING, self._onBlackCardWarning, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_BLACKCARD_USER, handler(self,self._onBlackCardUser), self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TIME_PRIVILEGE_GET_OPEN_SERVER_SUCC, self._onGetServerOpenTimeSucc, self)
    

    
    --服务器承载
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SERVER_CROWD, handler(self, self._onServerCrowd), self)

    
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ROLL_NOTICE,  self._onRollNotice, self)

    G_NativeProxy.registerNativeCallback(function(data)  

        local ret = self:_onNativeCallback(data) 
        if  ret == nil or ret == false then
            self:_defaultNativeCallback(data)
        end

    end)
end



function PlatformProxy:_onNativeCallback(data)

    return false
end

function PlatformProxy:_defaultNativeCallback(data)
    local event = data.event
    local ret = data.ret
    local paramStr = data.param
    print("## LUA-PLATFORM DEFAULT, " ..tostring(event) .. "," .. tostring(ret) .. "," .. tostring(info))

    
    if event == "onNetworkChanged" then
        local hasNetwork = G_NativeProxy.hasNetwork()
        trace("platform:network:" .. tostring(hasNetwork))
        if hasNetwork == false then
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_NETWORK_DEAD, nil, false, nil) 

        end

    elseif event == "mediaPlayFinish" then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_MEDIA_PLAY_FINISH, nil, false )
    end

end


function PlatformProxy:beforeLogin()
end



-- 登陆, 登陆全过程为:
-- 使用Proxy登陆platform, 然后登陆游族平台的统一verify接口取到token 然后使用token登陆游戏服务器
function PlatformProxy:loginPlatform()
    assert(nil, "PlatformProxy:login should be overwrite by specific platform proxy, such as TestProxy ")    
end

function PlatformProxy:enterGame()
    local server = self:getLoginServer()
    if server == nil or server.id == 0 then
        MessageBoxEx.showOkMessage("", G_Setting:get("no_server_txt") )


        return
    end

    -- GlobalFunc.uploadLog({{event_id="ClickEnterGame"}})
    if self:hasToken() then
        --self:connectGame()
        self:loginGame()

    else
        self._wantAutoEnterGame = true
        self:_loginPlatform()
    end
end




function PlatformProxy:_onGetToken(token)
    --print("got token ==========================")
    self._token = token
    if self._wantAutoEnterGame then
        self._wantAutoEnterGame = false
        self:loginGame()
    end
    
end





-- 连接上游戏服务器后开始登陆游戏,
function PlatformProxy:loginGame()
 
    G_NetworkManager:checkConnection()
end


function PlatformProxy:sendLoginGame()
    --required string channel_id = 3;
    --required string device_id = 4;
    local channel_id = self:getChanelId()
    local device_id = self:getDeviceId()
    local server = self:getLoginServer()
    G_HandlersManager.coreHandler:sendLoginGame(self._token, server.id, channel_id, device_id)
end


function PlatformProxy:getDeviceId()
    return  "test device"
end


function PlatformProxy:getChanelId()
    return  ""
end

--登陆游戏成功, 此时应该还没取到角色数据
function PlatformProxy:_onLoginSuccess()
    --此时保存成功登陆的服务器ID
    local server = self:getLoginServer()
    G_ServerList:setLastServerId(server.id)
    
    G_NetworkManager:startServerTimeService() 
    G_GameService:start()

    --这里我们不需要等对时返回,理论上来说这条协议是网关返回,所以肯定是第一条返回的
    G_HandlersManager.coreHandler:sendFlush() -- 获取基本数据
  
end

--create role just now
function PlatformProxy:_onCreatedRole()
    
  
end

--when level up
function PlatformProxy:_onLevelUp()
    
  
end

--取到了角色的基本数据, 详情参考C2S_FLASH_DATA
function PlatformProxy:_onRecvFlushData()
    if G_Me.isFlushDataReady then
        --这不是第一次刷新数据
        G_NetworkManager:onLoginedGame()
    else
        --这是第一刷新数据
        G_Me.isFlushDataReady = true
        
        
        
        --以下是不重要的数据, 数据没加载完不影响主界面显示,其实这块todo需要修改, 也是需要加载完才能进入主场景   
        G_HandlersManager.friendHandler:sendFriendList()
        G_HandlersManager.friendHandler:sendFriendsInfo()

        G_HandlersManager.wushHandler:sendQueryWushInfo()

        G_HandlersManager.dailytaskHandler:sendGetDailyMission()

        G_HandlersManager.fundHandler:sendGetFundInfo()
        G_HandlersManager.fundHandler:sendGetUserFund()

        -- 战宠护佑
        if G_moduleUnlock:isModuleUnlock(funLevelConst.PET_PROTECT1) then
            G_HandlersManager.fightResourcesHandler:sendGetPetProtect()
        end

        --请求月基金数据
        uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_MONTH_FUND_BASE_INFO, handler(self, self._onGetMonthFundBaseInfo), self)
        G_HandlersManager.monthFundHandler:sendGetMonthFundBaseInfo()
        --G_HandlersManager.monthFundHandler:sendGetMonthFundAwardInfo()

        --请求新手光环数据
        G_HandlersManager.rookieBuffHandler:sendGetRookieInfo()


        G_HandlersManager.activityHandler:sendGetRechargeBack()
        G_HandlersManager.shareHandler:sendShareState(2)
        -- G_HandlersManager.activityHandler:sendVipDiscountInfo()
        G_HandlersManager.activityHandler:sendVipDailyInfo()
        G_HandlersManager.activityHandler:sendVipWeekShopInfo()
        G_HandlersManager.activityHandler:sendInvitorGetRewardInfo()
        G_HandlersManager.activityHandler:sendInvitedGetDrawReward()

        --放到MainButtonLayer:enterSend里了
        --G_HandlersManager.wheelHandler:sendWheelInfo()
        --G_HandlersManager.richHandler:sendRichInfo()
        --G_HandlersManager.wheelHandler:sendWheelRankingList()
        --G_HandlersManager.richHandler:sendRichRankingList()
        
        --七日活动
        G_HandlersManager.daysActivityHandler:sendGetDaysActivityInfo()
        G_HandlersManager.daysActivityHandler:sendDaysActivitySellInfo()

        -- 获取挂机数据, 0表示我自己的数据
        G_HandlersManager.cityHandler:sendCityInfo(0)
        
        -- 请求分享信息数据
        G_HandlersManager.shareHandler:sendShareState(1)

        -- 中秋活动数据
        G_HandlersManager.specialActivityHandler:sendGetSpecialHolidayActivity()
        G_HandlersManager.specialActivityHandler:sendGetSpecialHolidaySales()

        -- 请求推送信息数据
        G_HandlersManager.coreHandler:sendPushSingleInfo()

        -- 请求更新团购配置信息
        G_HandlersManager.groupBuyHandler:sendGetGroupBuyConfig(G_Me.groupBuyData:getConfigMd5())
        G_HandlersManager.groupBuyHandler:sendGetGroupBuyTimeInfo()
        G_HandlersManager.groupBuyHandler:sendGetGroupBuyTaskAwardInfo()

        -- 老玩家回归
        G_HandlersManager.activityHandler:sendGetOldUserInfo()

        -- 开服七日战力榜
        G_HandlersManager.activityHandler:sendGetSevenDayCompInfo()

        -- 招财符信息
        if G_moduleUnlock:isModuleUnlock(funLevelConst.FORTUNE) then
            G_HandlersManager.activityHandler:sendGetFortuneInfo()
        end
        
        if G_moduleUnlock:isModuleUnlock(funLevelConst.LEGION) then 
            G_HandlersManager.legionHandler:sendGetCorpDetail()
            G_HandlersManager.legionHandler:sendGetCorpWorship()
            -- G_HandlersManager.legionHandler:sendGetCorpChapter()
            -- G_HandlersManager.legionHandler:sendGetDungeonAwardList()
            uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_CORP_DETAIL, function ( ... )
                if G_Me.legionData:hasCorp() then
                    G_HandlersManager.legionHandler:sendGetNewCorpChapter()
                    G_HandlersManager.legionHandler:sendGetNewDungeonAwardHint()

                    local corpCrossOpen = (G_Setting:get("corp_cross_open") == "1")
                    if G_Me.legionData:hasCorpCrossValid() and corpCrossOpen then 
                        if not G_Me.legionData:isBattleTimeReady() then 
                            G_HandlersManager.legionHandler:sendGetCorpCrossBattleTime()    
                        end

                        -- G_HandlersManager.legionHandler:sendGetCorpCrossBattleInfo()    
                    end
                    uf_eventManager:removeListenerWithEvent(self, G_EVENTMSGID.EVENT_GET_CORP_DETAIL)
                end
            end, self)
        end

        if G_moduleUnlock:isModuleUnlock(funLevelConst.CROSS_WAR) then
            uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_BATTLE_INFO, handler(self, self._onGetCrossWarInfo), self)
            G_HandlersManager.crossWarHandler:sendGetBattleInfo()
        end

        --百战沙场
        if G_moduleUnlock:isModuleUnlock(funLevelConst.CRUSADE) then
            uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CRUSADE_UPDATE_BATTLEFIELD_INFO, handler(self, self._onGetBattleFieldInfo), self)
            G_HandlersManager.crusadeHandler:sendGetBattleFieldInfo(1)
        end

        -- 限时优惠,不判断等级，直接拉数据
        G_HandlersManager.timePrivilegeHandler:sendShopTimeStartTime()
   
        -- 世界Boss
        unlockFlag = G_moduleUnlock:isModuleUnlock(funLevelConst.REBEL_BOSS)
        if unlockFlag then
            G_HandlersManager.moshenHandler:sendEnterRebelBossUI()
            G_HandlersManager.moshenHandler:sendRebelBossAwardInfo(1)
            G_HandlersManager.moshenHandler:sendRebelBossAwardInfo(2)
            G_HandlersManager.moshenHandler:sendRebelBossCorpAwardInfo()
        end

        -- 限时抽将
        if G_moduleUnlock:isModuleUnlock(funLevelConst.THEME_DROP) then
            G_HandlersManager.themeDropHandler:sendThemeDropZY()
        end

        -- 精英暴动
        if G_moduleUnlock:isModuleUnlock(funLevelConst.HARD_DUNGEON_RIOT) then
            if G_Me.hardDungeonData:isNeedRequestRiotChapterList() then
                -- 精英暴动拉取数据
                G_HandlersManager.hardDungeonHandler:sendGetRiotChapterList()
            end
        end

        -- 新版日常副本
        if G_moduleUnlock:isModuleUnlock(funLevelConst.VIP_SCENE) then
            G_HandlersManager.vipHandler:sendGetDungeonDailyInfo()
        end

        -- 战宠图鉴
        if G_moduleUnlock:isModuleUnlock(funLevelConst.PET) then
            G_HandlersManager.handBookHandler:sendGetHandbookInfo(require("app.const.HandBookConst").HandType.PET)
        end

        -- 过关斩将
        G_HandlersManager.expansionDungeonHandler:sendGetExpansiveDungeonChapterList()

        G_HandlersManager.dailyPvpHandler:sendTeamPVPGetUserInfo()

        -- 将灵系统
        if G_moduleUnlock:isModuleUnlock(funLevelConst.HERO_SOUL) then
            G_HandlersManager.heroSoulHandler:sendGetSoulInfo()
        end

        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ALL_DATA_READY, nil, false) 

        G_NetworkManager:onLoginedGame()

        self:_onFirstLoginedGame()


    end


    self:_onLoginedGame()

    G_Report:sendLocalReports()

end

function PlatformProxy:_onFirstLoginedGame()
    local tencentGiftUrl = G_Setting:get("open_tencent_gift_url")
    if tencentGiftUrl ~= nil and tencentGiftUrl ~= "" then
        local loginExtraData = G_PlatformProxy:getLoginExtraData()
        local server_id = G_PlatformProxy:getLoginServer().id
        if loginExtraData and server_id then
            local open_id = tostring(loginExtraData['open_id'])
            if not open_id then
                return
            end
            local url = string.format("%s?uuid=%s&serverId=%s",tencentGiftUrl,open_id,server_id)
           
            local request = uf_netManager:createHTTPRequestGet(url, function(event)
              
            end)
            request:start()
        end
    end
    -- http://s1.ng.tencent.uuzuonline.net/gift/UserServer.php?uuid=111&serverId=111&userId=111
end

function PlatformProxy:_onLoginedGame()
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FINISH_LOGIN, nil, false) 

    G_HandlersManager.coreHandler:sendGetBlackcardWarning()
    if G_NativeProxy.platform == "ios" then
        self:addLocalNotications()


    end  
   
    --每次登陆游戏都拉取活动
    G_HandlersManager.gmActivityHandler:sendCustomActivityInfo()  


    G_Job:onLoginedGame()

    self:checkGrayUser()
end

function PlatformProxy:checkGrayUser()
    if self.isGrayUser then
        G_HandlersManager.coreHandler:sendCDLevel(2)
    end
end


function PlatformProxy:_onBlackCardUser( ... )
    MessageBoxEx.showOkMessage(nil, G_lang:get("LANG_BLACK_CARD_USER"), true, function ( ... )
        if G_NativeProxy.openURL then
            G_NativeProxy.openURL("http://kf.youzu.com/djss")
        end
    end)
end

--缺少角色,
function PlatformProxy:_onNeedCreateRole() 
    local server = self:getLoginServer()
    
    local blocked_server_list = G_Setting:get("blocked_server_list")

    if blocked_server_list and blocked_server_list ~= "" then
        local blocks = string.split(blocked_server_list, ",")
        for i, v in ipairs(blocks) do 
            if tostring(v) == tostring(server.id) then
                --blocked
                G_NetworkManager:reset()
                --暂时不放lang, 避免更新包太大
                MessageBoxEx.showOkMessage("", "该服务器非常火爆, 请您选择其他服务器进入，可以获得更好的游戏体验。")

                return
            end
        end
    end
    
    if LANG == nil or LANG == "cn" then
        if server.openTimeRank ~= nil then
            local allowMaxOpenTimeRank = toint(G_Setting:get("allow_create_servers_n"))
            if server.openTimeRank > allowMaxOpenTimeRank then
                G_NetworkManager:reset()
                MessageBoxEx.showOkMessage("", "该服务器竞争过于激烈，已关闭注册，请前往最新服务器获得最优游戏体验！")
                return
            end
        end
    end
    

    G_ServerList:setLastServerId(server.id)



    if G_SceneObserver:getSceneName() ~= "CreateRoleScene"  then
        --uf_sceneManager:replaceScene(require("app.scenes.createrole.CreateRoleScene").new())

        local firstCaption = require("app.scenes.guide.CaptionsScene").new(nil, nil, "LANG_GUIDE_CAPTION_TEXT_1", function ( ... )
            local battleScene = require("app.scenes.guide.GuideBattleScene").new(0,1, nil, function ( ... )
                uf_sceneManager:replaceScene(require("app.scenes.createrole.CreateRoleScene").new())
            end)
            uf_sceneManager:replaceScene(battleScene)
        end)
        uf_sceneManager:replaceScene(firstCaption)
    else
       G_NetworkManager:onLoginedGame()     
    end
end

--角色在他处登陆
function PlatformProxy:_onNeedRelogin() 
    G_NetworkManager:reset()
    ReconnectLayer.show(G_lang:get("LANG_NEED_RELOGIN"),{reconnect=false})


end

--维护中
function PlatformProxy:_onMaintain() 

    G_NetworkManager:reset()
    ReconnectLayer.show(G_lang:get("LANG_MANTAIN"))

end




function PlatformProxy:setUid(uid)

    self._platform_uid = uid
  
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_UPDATE_UID, nil, true) 

end

function PlatformProxy:setYzuid(yzuid, fromServer)

    self._yzuid = yzuid
    if not fromServer then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_PLATFORM_LOGIN_OK, nil, true) 
    end
end


function PlatformProxy:getDefaultRoleName()
    return "role" .. tostring(os.time())
end


--获取推荐的服务器, 用于登陆显示
function PlatformProxy:getRecommendServer()
    --获取上次登陆的server id
    local lastServer = G_ServerList:getLastServer()
    local server 
    if lastServer ~= nil then
        server = lastServer
    end
    
    if server == nil then
        server = G_ServerList:getFirstServer()
    end

    return server
end


function PlatformProxy:setLoginServer(server)
  
    self._server = server
end

function PlatformProxy:getLoginServer()
    if self._server == nil then
        return self:getRecommendServer()
    end
    return self._server
end



function PlatformProxy:getLoginUserName()
    return ""
end

function PlatformProxy:hasToken()
    return self._token ~= ""
end

-- 平台的用户ID, (所有服务器上, 该用户都是这个ID,比如91账号)
function PlatformProxy:getPlatformUid()
    return self._platform_uid
end

function PlatformProxy:getYzuid()
    return self._yzuid
end

function PlatformProxy:clear()
    uf_eventManager:removeListenerWithTarget(self)
end

function PlatformProxy:returnToLogin()

    local function _returnToLogin() 
        G_Me  = require("app.data.Me").new()
        self._token = ""
        self._platform_uid = ""
        self._yzuid = ""
        G_WaitingLayer:show(false)

        --todo
        --需要清空notify layer 所有东西
        if G_GuideMgr then 
            G_GuideMgr:quitGuide( )
        end
        if G_moduleUnlock then 
            G_moduleUnlock:resetData()
        end
        G_NetworkManager:reset()
        uf_notifyLayer:clearAll(function ( ... )
            self:_onNotifyLayerClear()
        end)
        G_HandlersManager:unInitHandlers()
        local appId = require("upgrade.ComSdkUtils").getOpId()
        if tostring(appId) == "2155" then  --移动的特殊处理
            G_NativeProxy.native_call("restartGameActivity")
        else
            uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.login.LoginScene").new())
        end
    end
    
    --判断是不是搜狐  解决游戏内注销后再次登陆，然后弹出注销登陆的bug
    if tostring(require("upgrade.ComSdkUtils").getOpId()) == "2211" then
        _returnToLogin()
    else 
        --有些安卓SDK这个地方容易出现部分纹理丢失， 隔2帧再切场景吧
        uf_funcCallHelper:callAfterFrameCount(2, _returnToLogin )
    end 

end 



function PlatformProxy:_onNotifyLayerClear( ... )
    G_topLayer = nil
end

---real really exit game!!
function PlatformProxy:_exitGame()
    -- 
    if G_NativeProxy.platform == "android" then
        --退出游戏activity
        G_NativeProxy.native_call("onExitGame",{})
    else
        CCDirector:sharedDirector():endToLua()
    end
end
    
function PlatformProxy:_defaultExitGame()
    if LANG == "tw" and GAME_VERSION_NO >10568 then
        require("upgrade.ComSdkUtils").call("showExitDialog",{})
    else
        if not self._isShowAlert then
        MessageBoxEx.showYesNoMessage(nil, G_lang:get("LANG_EXIT_TIP"), true, function (  )
            self:_exitGame()
            self._isShowAlert = false
        end, function (  )
            self._isShowAlert = false
        end)
        self._isShowAlert = true
        end
    end
end

--玩家要退出游戏
function PlatformProxy:wantExitGame()
    self:_defaultExitGame()
end

--玩家被封禁
function PlatformProxy:_onBanUser()


    G_NetworkManager:reset()
    MessageBoxEx.showOkMessage(G_lang:get("LANG_TIPS"), G_lang:get("LANG_BAN_USER"))
end

--token 过期
function PlatformProxy:_onTokenExpired()

    G_NetworkManager:reset()
    MessageBoxEx.showOkMessage(G_lang:get("LANG_TIPS"), G_lang:get("LANG_TOKEN_EXPIRED"), nil , function() 
        G_PlatformProxy:returnToLogin()

    end )
end


--not allow
function PlatformProxy:_onNotAllowed()

    G_NetworkManager:reset()
    MessageBoxEx.showOkMessage(G_lang:get("LANG_TIPS"), G_lang:get("LANG_NOT_ALLOWED"), nil , function() 


    end )



end

function PlatformProxy:_onWrongVersion()

    G_NetworkManager:reset()
    MessageBoxEx.showOkMessage(G_lang:get("LANG_TIPS"),G_lang:get("LANG_WRONG_VERSION"), nil,function() 
        if G_NativeProxy.platform == "android" then
            self:_exitGame()
        end
    end  )
end

function PlatformProxy:_onServerCrowd()
    G_NetworkManager:reset()
    MessageBoxEx.showOkMessage(G_lang:get("LANG_TIPS"),G_lang:get("LANG_SERVER_CROWD"), nil,function() 
        G_PlatformProxy:returnToLogin()
        
    end  )
end

function PlatformProxy:_onBlackCardWarning( warning )
    if warning then 
        MessageBoxEx.showOkMessage(nil, G_lang:get("LANG_BLACK_CARD_WARNING"), true) 
    end
end


--系统公告
function PlatformProxy:_onRollNotice(decodeBuffer)
    
    

    G_RollNoticeLayer:show(decodeBuffer.msg)

end

--监听月基金基本信息
function PlatformProxy:_onGetMonthFundBaseInfo(data)

    if G_Me.monthFundData:dataReady() and G_Me.monthFundData:checkInAwardStage() then
        G_HandlersManager.monthFundHandler:sendGetMonthFundAwardInfo()
        uf_eventManager:removeListenerWithEvent(self, G_EVENTMSGID.EVENT_MONTH_FUND_BASE_INFO)
    end

end

function PlatformProxy:_onGetBattleFieldInfo()

    --通过情况下拉取宝藏信息
    if G_Me.crusadeData:hasPassStage() then
        G_HandlersManager.crusadeHandler:sendGetAwardInfo()
    end

    uf_eventManager:removeListenerWithEvent(self, G_EVENTMSGID.EVENT_CROSS_WAR_GET_BATTLE_INFO)

end


-- 跨服战状态
function PlatformProxy:_onGetCrossWarInfo()
    local data = G_Me.crossWarData
    local group = data:getGroup()

    if group > 0 and group <= 4 then
        G_HandlersManager.crossWarHandler:sendEnterScoreBattle()
        G_HandlersManager.crossWarHandler:sendGetWinsAwardInfo()
    end

    -- 如果在争霸赛阶段，拉取争霸信息
    if data:isChampionshipEnabled() and data:isScoreMatchEnd() then
        uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_ARENA_INFO, handler(self, self._onGetChampionshipInfo), self)
        G_HandlersManager.crossWarHandler:sendGetChampionshipInfo()
    end 

    -- 监听一次后，以后不再监听
    uf_eventManager:removeListenerWithEvent(self, G_EVENTMSGID.EVENT_CROSS_WAR_GET_BATTLE_INFO)
end

-- 争霸赛信息
function PlatformProxy:_onGetChampionshipInfo()
    -- 有资格参加争霸赛，且比赛没结束， 拉取邀请函信息
    if G_Me.crossWarData:isQualify() and not G_Me.crossWarData:isChampionshipEnd() then
        G_HandlersManager.crossWarHandler:sendGetInvitation()
    end

    -- 监听一次后，以后不再监听
    uf_eventManager:removeListenerWithEvent(self, G_EVENTMSGID.EVENT_CROSS_WAR_GET_ARENA_INFO)
end

function PlatformProxy:_onGetServerOpenTimeSucc()
    if G_Me.timePrivilegeData:isOpenFunction() then
        G_HandlersManager.timePrivilegeHandler:sendShopTimeRewardInfo()
        G_HandlersManager.timePrivilegeHandler:sendShopTimeInfo()
    end
    -- 监听一次后，以后不再监听
    uf_eventManager:removeListenerWithEvent(self, G_EVENTMSGID.EVENT_TIME_PRIVILEGE_GET_OPEN_SERVER_SUCC)
end

function PlatformProxy:registerLocalNotification(msg, seconds)
    if G_Setting:get("open_notification") ~= "1" then
        return
    end
    G_NativeProxy.native_call("registerLocalNotification", {{seconds=seconds}, {msg=msg}  })

end


function PlatformProxy:addLocalNotications()
    G_NotifycationManager:registerNotifycation()    
end

function PlatformProxy:getOpId()
    return self._opId
end

function PlatformProxy:getAppId()
    return G_Setting:get("appid")
end


function PlatformProxy:getTokenTicket()
    return self._token
end




function PlatformProxy:showGonggao(callback)
    local popupUrl =  G_Setting:get("popupUrl")

    if popupUrl and popupUrl ~= "" and string.find(popupUrl, "http") == 1 then
        print("show " .. tostring(popupUrl))
        require("app.scenes.login.LoginGonggaoLayer").create(popupUrl, callback)
        return true
    end
    return false
end


--点击了某个会触发SDK的按钮之后， 需要隔4帧调用， 而且需要避免期间重复调用
function PlatformProxy:createLockCall( call)
    local lastClickTick = 0
    return function()  
       local currentTick =  FuncHelperUtil:getTickCount()
        if currentTick - lastClickTick > 100 then
            lastClickTick = currentTick
            uf_funcCallHelper:callAfterFrameCount(4, call)
        end
    end
   
end

--有时候不适合创建闭包来调用，因为函数参数不是固定的，
local lockKeys = {}
function PlatformProxy:delayCall( lockKey, call)
    local currentTick =  FuncHelperUtil:getTickCount()
    if lockKeys[lockKey] and currentTick - lockKeys[lockKey] < 150 then
        
    else
        lockKeys[lockKey] = currentTick
        uf_funcCallHelper:callAfterFrameCount(4, call)
    end
 
end

return PlatformProxy
