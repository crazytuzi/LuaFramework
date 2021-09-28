require("app.const.FigureType")
require("app.cfg.basic_figure_info")
local FunctionLevelConst = require("app.const.FunctionLevelConst")
-- 服务器时间同步服务
local GameService =  class("GameService")



function GameService:ctor()

    self._activityController = require("app.scenes.activity.ActivityController").new()
    




end

function GameService:start()
    if self._timer == nil then
        local scheduler = require("framework.scheduler")   
        
        self._timer = scheduler.scheduleGlobal(handler(self, self._onTick), 1)    
    end


    self:_onTick()
end

function GameService:_checkSpeed(now)
    if G_NativeProxy.platform == "windows" then
        return true
    end
    
    if G_Setting:get("open_check_speed") == "1" then
        if self._oldTickTime == nil then
           self._oldTickTime = now
           self._oldTickCount = 0
           self._wrongSpeedCount = 0
        else
            self._oldTickCount = self._oldTickCount  + 1

            if self._oldTickCount == 5 then
                --理论上5个tick应该>=5秒, 就算给它20%的误差,  应该是>=4秒
                if (now - self._oldTickTime) < 4 then
                    --作弊计数+1
                    self._wrongSpeedCount = self._wrongSpeedCount + 1

                end 
                self._oldTickTime = now
                self._oldTickCount = 0
                --连续3次作弊
                if self._wrongSpeedCount >= 3 then
                    self._wrongSpeedCount  = 0 
                    
                    return false
                else 
                    return true    
                end
            end
           
        end 
        return true
    else
        return true
    end
end


local function _CurrValueNeedFresh(_type,refresh_time,currValue)

    local _info = basic_figure_info.get(_type)   
    local leftTime = G_ServerTime:getLeftSeconds(refresh_time)
    leftTime = leftTime - _info.unit_time*(_info.time_limit - currValue - 1)
    if currValue >= _info.time_limit then -- 超过上限值
        return false
    else
        if leftTime < 0 then
            return true
        else
            return false
        end
    end
    return false
end


function GameService:_onTick()
   

    if not G_Me.isFlushDataReady then
        --如果没登陆过游戏, 可能这个时候在登陆界面
        return
    end
    
    local serverTime = G_ServerTime:getTime()

    if not self:_checkSpeed(serverTime) then
        G_PlatformProxy:returnToLogin()
        MessageBoxEx.showOkMessage(G_lang:get("LANG_TIPS"),G_lang:get("LANG_WRONG_SPEED"), nil,function() 
        end  )
        return
    end
    

    --如果当前是主场景, 每2个小时刷新一下神秘商店
    if G_SceneObserver:getSceneName() == "MainScene" and math.fmod(serverTime, 7200 )  == 0 then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_MAINSCENE_SECRET_SHOP_UPDATED, nil, false)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_MAINSCENE_AWAKEN_SHOP_UPDATED, nil, false)
    end

    -- 精英暴动
    local unlockFlag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.HARD_DUNGEON_RIOT)
    if unlockFlag then
        local isAddShowChapter = G_Me.hardDungeonData:checkShowedChapterCountAdded()
        if G_SceneObserver:getSceneName() == "HardDungeonMainScene" and isAddShowChapter then
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HARD_RIOT_UPDATE_MAIN_LAYER, nil, false, decodeBuffer)
        end

        local isChangeDate = G_Me.hardDungeonData:isNeedRequestRiotChapterList()
        if G_SceneObserver:getSceneName() == "HardDungeonMainScene" and isChangeDate then
            G_HandlersManager.hardDungeonHandler:sendGetRiotChapterList()
        end
        if G_SceneObserver:getSceneName() == "HardDungeonGateScene" and isChangeDate then
            G_HandlersManager.hardDungeonHandler:sendGetRiotChapterList()
        end
    end

    -- 限时优惠
    if G_Me.timePrivilegeData:isOpenFunction() then
        local nowTime = G_ServerTime:getTime()
        local tab = G_ServerTime:getDateObject(nowTime)
        
        local refreshTime = 12*3600 + 1
        local t = tab.hour*3600 + tab.min*60 + tab.sec
        if t == refreshTime then
            if G_SceneObserver:getSceneName() == "TimePrivilegeMainScene" then
                -- 刷新物品
                -- __Log("--刷新物品--")
                G_HandlersManager.timePrivilegeHandler:sendShopTimeInfo()
                G_HandlersManager.shopHandler:sendShopInfo(SHOP_TYPE_TIME_PRIVILEGE)
            else
                G_Me.timePrivilegeData:setGoodsRefreshedMark(true)
            end

            if G_SceneObserver:getSceneName() == "MainScene" then
                --__Log("-- 刷新红点")
                uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TIME_PRIVILEGE_MAIN_SCENE_SHOW_ICON, nil, false)
            end
        end
    end

    -- 限时抽将, 并且隔天了
    if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.THEME_DROP) then
        if G_SceneObserver:getSceneName() ~= "ThemeDropMainScene" then
            if G_Me.themeDropData:isAnotherDay() then
            --    __Log(" -- 限时抽将, 并且隔天了")
                local function sendMsg()
            --        __Log("--------- sendMsg to refresh theme drop")
                    G_HandlersManager.themeDropHandler:sendThemeDropZY()
                end
                uf_funcCallHelper:callAfterDelayTime(5, nil, sendMsg, nil)
            end
        end
    end

    if not G_NetworkManager:isConnected() then
        return
    end

    G_Me.friendData:sugCountMM()
    G_Me.activityData.phone:countMM()

    G_Job:checkUpdate(serverTime)
        
    if G_SceneObserver:getSceneName() == "MainScene" or G_SceneObserver:getSceneName() == "ActivityMainScene"  or G_SceneObserver:getSceneName() == "PlayingScene" then
        self._activityController:oneTick()
    end
    
    G_Me.dailyPvpData:checkReadyTime()


    --恢复精力体力，征讨令
    if _CurrValueNeedFresh(TYPE_VIT,G_Me.userData.refresh_vit_time,G_Me.userData.vit) 
        or _CurrValueNeedFresh(TYPE_SPIRIT,G_Me.userData.refresh_spirit_time,G_Me.userData.spirit) 
        or _CurrValueNeedFresh(TYPE_CHUZHENG,G_Me.userData.battle_token_time,G_Me.userData.battle_token) then
        if self._lastSendFlushTime == nil or serverTime - self._lastSendFlushTime >= 5 then
            G_HandlersManager.coreHandler:sendFlushUser()
            self._lastSendFlushTime = serverTime
        end
        
    end
end



function GameService:clear()
    if self._timer ~= nil then
        local scheduler = require("framework.scheduler")   
        scheduler.unscheduleGlobal(self._timer)
        self._timer = nil
    end




end








return GameService
