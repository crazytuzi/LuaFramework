--[[
******跨服个人战数据管理器*******

	-- by quanhuan
	-- 2016/4/12
	
]]

local MultiServerFightManager = class("MultiServerFightManager")

MultiServerFightManager.ActivityState_0 = 0--活动未开启
MultiServerFightManager.ActivityState_1 = 1--资格赛展示阶段(本服8强)-第一场跨服积分赛开始
MultiServerFightManager.ActivityState_2 = 2--第一场跨服积分赛开始-第一场跨服积分赛结束
MultiServerFightManager.ActivityState_3 = 3--第一场跨服积分赛结果展示-第二场跨服积分赛开始
MultiServerFightManager.ActivityState_4 = 4--第二场跨服积分赛开始-第二场跨服积分赛结果展示
MultiServerFightManager.ActivityState_5 = 5--第二场跨服积分赛结果展示-16强对战开始
MultiServerFightManager.ActivityState_6 = 6--8强对战开始
MultiServerFightManager.ActivityState_7 = 7--4强对战开始
MultiServerFightManager.ActivityState_8 = 8--2强对战开始
MultiServerFightManager.ActivityState_9 = 9--跨服战结果展示

MultiServerFightManager.CrossBetUpdate = "MultiServerFightManager.CrossBetUpdate"
MultiServerFightManager.getGrandUpdate = "MultiServerFightManager.getGrandUpdate"
MultiServerFightManager.updateChampoinMsg = "MultiServerFightManager.updateChampoinMsg"
MultiServerFightManager.updatePreviousCrossInfo = "MultiServerFightManager.updatePreviousCrossInfo"
MultiServerFightManager.updateActivityState = "MultiServerFightManager.updateActivityState"
MultiServerFightManager.qualificationInfoBrush = "MultiServerFightManager.qualificationInfoBrush"
MultiServerFightManager.buyQualification = "MultiServerFightManager.buyQualification"


function MultiServerFightManager:ctor(data)
    self.personGrandList = TFArray:new()
    self.publicGrandList = TFArray:new()


    --当前状态 服务器推送
    TFDirector:addProto(s2c.CURRENT_STATE, self, self.onActivityUpdate)    
    --资格赛信息
    TFDirector:addProto(s2c.QUALIFICATION_INFOS, self, self.onQualificationInfos)
    --积分赛信息
    TFDirector:addProto(s2c.SCORE_RANK_INFOS, self, self.onScoreRankInfos)
    --争霸赛信息
    TFDirector:addProto(s2c.CROSS_CHAMPIONS_INFOS, self, self.onCrossChampionsInfos)
    --16强对阵信息
    TFDirector:addProto(s2c.CROSS_CHAMPIONS_WAR_INFOS, self, self.onCrossChampionInfosWar)
    --押注
    TFDirector:addProto(s2c.CROSS_CHAMPIONS_BET_SUCESS, self, self.onCrossBet)
    --个人战报
    TFDirector:addProto(s2c.CROSS_GRAND, self, self.grand)
    --上次跨服战信息
    TFDirector:addProto(s2c.PREVIOUS_CROSS_INFO_RESP, self, self.onPreviousCrossInfo)
    --购买跨服战资格
    TFDirector:addProto(s2c.APPLY_CROSS_CHAMPIONS_SUCESS, self, self.onBuyQualification)
    
    self:restart()
end

function MultiServerFightManager:restart()  
    self.lastActivityState = nil
    self.layerBuffer = {
        "lua.logic.multiServerFight.ScoreFightLayer",
        "lua.logic.multiServerFight.FightMainLayer",
        "lua.logic.multiServerFight.KuaFuFirstRoundLayer",
        "lua.logic.multiServerFight.KuaFuSecondRoundLayer",
        "lua.logic.multiServerFight.KuaFuThirdRoundLayer",
        "lua.logic.multiServerFight.KuaFuFourthRoundLayer",
        "lua.logic.multiServerFight.KuaFuResultLayer"        
    }
    self.personGrandList:clear()
    self.publicGrandList:clear()
    self.qualificationInfos = {}
    self.scoreRankInfos = {}
    self.crossChampionsInfos = {}
    self.ChampionInfosWarData = {}
    self.activityState = 0
    
    self.timeDataManager = {}
    --资格赛展示 -->> 第一场积分赛预览结束
    local i = 1
    self.timeDataManager[i] = {}
    self.timeDataManager[i].preFightTime = ConstantData:objectByID("MultiServerFightManager.ActivityState_1").value
    self.timeDataManager[i].fightTime = ConstantData:objectByID("MultiServerFightManager.ActivityState_2").value
    self.timeDataManager[i].endTime = ConstantData:objectByID("MultiServerFightManager.ActivityState_3").value
    self.timeDataManager[i].delayTime = ConstantData:objectByID("MultiServerFightManager.ActivityState_4").value

    --第一场积分赛结果展示 -->>第二场积分赛预览结束
    i = 2
    self.timeDataManager[i] = {}
    self.timeDataManager[i].preFightTime = ConstantData:objectByID("MultiServerFightManager.ActivityState_5").value
    self.timeDataManager[i].fightTime = ConstantData:objectByID("MultiServerFightManager.ActivityState_6").value
    self.timeDataManager[i].endTime = ConstantData:objectByID("MultiServerFightManager.ActivityState_7").value
    self.timeDataManager[i].delayTime = ConstantData:objectByID("MultiServerFightManager.ActivityState_8").value

    --积分赛排名结果预览--->>>16强对阵跳转
    self.switchLayerTime = ConstantData:objectByID("MultiServerFightManager.ActivityState_9").value

    --16强信息
    i = 5
    self.timeDataManager[i] = {}
    self.timeDataManager[i].fightTime = ConstantData:objectByID("MultiServerFightManager.ActivityState_10").value
    self.timeDataManager[i].endTime = ConstantData:objectByID("MultiServerFightManager.ActivityState_11").value
    self.timeDataManager[i].nextFightTime = ConstantData:objectByID("MultiServerFightManager.ActivityState_12").value
    --8强信息
    i = 6
    self.timeDataManager[i] = {}
    self.timeDataManager[i].fightTime = ConstantData:objectByID("MultiServerFightManager.ActivityState_13").value
    self.timeDataManager[i].endTime = ConstantData:objectByID("MultiServerFightManager.ActivityState_14").value
    self.timeDataManager[i].nextFightTime = ConstantData:objectByID("MultiServerFightManager.ActivityState_15").value
    --4强信息
    i = 7
    self.timeDataManager[i] = {}
    self.timeDataManager[i].fightTime = ConstantData:objectByID("MultiServerFightManager.ActivityState_16").value
    self.timeDataManager[i].endTime = ConstantData:objectByID("MultiServerFightManager.ActivityState_17").value
    self.timeDataManager[i].nextFightTime = ConstantData:objectByID("MultiServerFightManager.ActivityState_18").value
    --2强信息
    i = 8
    self.timeDataManager[i] = {}
    self.timeDataManager[i].fightTime = ConstantData:objectByID("MultiServerFightManager.ActivityState_19").value
    self.timeDataManager[i].endTime = ConstantData:objectByID("MultiServerFightManager.ActivityState_20").value
    self.timeDataManager[i].nextFightTime = ConstantData:objectByID("MultiServerFightManager.ActivityState_21").value

end

function MultiServerFightManager:onActivityUpdate( event )
    local state = event.data.state
    if self.lastActivityState == nil then
        self.activityState = state        
    elseif self.lastActivityState == state then
        if state == self.ActivityState_2 or state == self.ActivityState_4 then
            TFDirector:dispatchGlobalEventWith(MultiServerFightManager.getGrandUpdate,{})
        end
        return
    end
    self:setActivityState(state)
end

function MultiServerFightManager:setActivityState(state)    

    self.lastActivityState = self.activityState
    self.activityState = state
    local layerExsit = nil
    for k,v in pairs(self.layerBuffer) do
        layerExsit = AlertManager:getLayerByName(v)
        if layerExsit then
            break
        end
    end
    if layerExsit then
        self:openCurrLayer()
    else
        self:requestPreviousCrossInfo()
        TFDirector:dispatchGlobalEventWith(MultiServerFightManager.updateActivityState,{})
    end
end

function MultiServerFightManager:getActivityState()
    return self.activityState
end

function MultiServerFightManager:getCurrSecond()
    local date = os.date("*t", MainPlayer:getNowtime())
    if date.wday == 1 then
        date.wday = 8
    end
    local wday = date.wday - 2        
    local nowTime = wday*(24*60*60) + (date.hour*60 + date.min)*60 + date.sec
    return nowTime
end

-- function MultiServerFightManager:openCurrLayer()

--     local state = 3--self:getActivityState()
--     local timeInfo = self:getFightTimeByState( state )
--     local currTime = self:getCurrSecond()
--     if state == self.ActivityState_1 or state == self.ActivityState_3 then
--         local endTime = timeInfo.preFightTime
--         if endTime > currTime then
--             --进入展示界面
--             local layer = require("lua.logic.multiServerFight.FightMainLayer"):new()
--             AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
--             layer:setData(state)
--             AlertManager:show()
--         else
--             --进入武林大会界面
--             local layer = require("lua.logic.multiServerFight.ScoreFightLayer"):new()
--             AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
--             layer:setData(state)
--             AlertManager:show()
--         end
--     elseif state == self.ActivityState_2 or state == self.ActivityState_4 then
--         local layer = require("lua.logic.multiServerFight.ScoreFightLayer"):new()
--         AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
--         layer:setData(state)
--         AlertManager:show()
--     elseif state == self.ActivityState_5 then
--         --淘汰赛
--         if currTime >= self.switchLayerTime then
--             --显示16强对战信息
--             local layer = require("lua.logic.multiServerFight.FightMainLayer"):new()
--             AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
--             layer:setData(state)
--             AlertManager:show()
--         else
--             --显示16强列表信息
--             local layer = require("lua.logic.multiServerFight.KuaFuFirstRoundLayer"):new()
--             AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
--             AlertManager:show()
--         end
--     elseif state == self.ActivityState_6 then
--         --结果展示
--         local layer = require("lua.logic.multiServerFight.FightMainLayer"):new()
--         AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
--         AlertManager:show()
--     else
--         toastMessage('不在活动时间内')
--         return
--     end
-- end

--[[
--资格赛请求
MultiServerFightManager:requestQualificationInfos()
--积分赛信息请求
MultiServerFightManager:requestScoreRankInfos()
--争霸赛信息请求
MultiServerFightManager:requestCrossChampionsInfos()    
]]
function MultiServerFightManager:openCurrLayer()

    local state = self:getActivityState()
    local timeInfo = self:getFightTimeByState( state )
    local currTime = self:getCurrSecond()
    print('---------------------------------->>>>>>>',self.activityState)
    print('---------------------------------->>>>>>>',self.activityState)
    print('---------------------------------->>>>>>>',self.activityState)

    if state == self.ActivityState_1 or state == self.ActivityState_3 then
        if state == self.ActivityState_1 then
            self:requestQualificationInfos()
        else
            self:requestScoreRankInfos(state)
        end

        -- if currTime < timeInfo.preFightTime then
        --     --进入展示界面 资格赛请求
        --     if state == self.ActivityState_1 then
        --         self:requestQualificationInfos()
        --     else
        --         self:requestScoreRankInfos(state)
        --     end
        -- else
        --     --进入武林大会界面
        --     self:requestQualificationInfos(true)            
        -- end
    elseif state == self.ActivityState_2 or state == self.ActivityState_4 then
        self:requestCrossChampionsInfos(state)
    elseif state == self.ActivityState_5 then
        --淘汰赛
        if currTime >= self.switchLayerTime then
            --显示16强对战信息
            self:requestCrossChampionInfosWar(1)
        else
            --显示16强列表信息
            self:requestScoreRankInfos(state)
        end
    elseif (state == self.ActivityState_6 or state == self.ActivityState_7) or state == self.ActivityState_8 then
        timeInfo = self:getFightTimeByState( state-1 )
        local round = state - self.ActivityState_5
        if currTime >= timeInfo.nextFightTime then
            self:requestCrossChampionInfosWar(round+1)
        else
            self:requestCrossChampionInfosWar(round)
        end    
    elseif state == self.ActivityState_9 then
        --self.previousCrossInfo
        local lastTime = math.floor(self.previousCrossInfo.lastOpenTime/1000)
        local checkNowTime = MainPlayer:getNowtime()
        checkNowTime = checkNowTime - lastTime
        timeInfo = self:getFightTimeByState( state-1 )
        print('checkNowTime = ',checkNowTime)
        print('currTime = ',currTime)
        print('timeInfo.nextFightTime = ',timeInfo.nextFightTime)
        print('self.previousCrossInfo = ',self.previousCrossInfo)
        print('MainPlayer:getNowtime() = ',MainPlayer:getNowtime())
        if currTime >= timeInfo.nextFightTime or (checkNowTime >= (7*24*60*60-60)) then
            --请求结果
            self:requestPreviousCrossInfo(true)
        else
            self:requestCrossChampionInfosWar(4)
        end
    else
        toastMessage(localizable.FactionFightManager_not_in_avtivity)
        return
    end
end

function MultiServerFightManager:clossAllLayer()
    for k,v in pairs(self.layerBuffer) do
        layerExsit = AlertManager:getLayerByName(v)
        if layerExsit then
            AlertManager:closeAllToLayer(layerExsit)
        end
    end
end
--[[
    奖励界面
]]
function MultiServerFightManager:showAwardLayer()
    local layer = require("lua.logic.multiServerFight.FactionFightReward"):new()
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
    AlertManager:show()
end

--资格赛请求
function MultiServerFightManager:requestQualificationInfos(isSwitch,isBrush)
    self.qualificationInfoIsSwitch = isSwitch
    self.qualificationInfoIsBrush = isBrush
    showLoading()
    
    TFDirector:send(c2s.QUERY_QUALIFICATION_INFOS,{})        
end

function MultiServerFightManager:onQualificationInfos( event )
    self.qualificationInfos = event.data
    if self.qualificationInfos.atkFormation then
        local tbl = stringToNumberTable(self.qualificationInfos.atkFormation,',')
        ZhengbaManager:qunHaoDefFormationSet(EnumFightStrategyType.StrategyType_CHAMPIONS_ATK, tbl)
    end
    if self.qualificationInfos.defFromation then
        local tbl = stringToNumberTable(self.qualificationInfos.defFromation,',')
        ZhengbaManager:qunHaoDefFormationSet(EnumFightStrategyType.StrategyType_CHAMPIONS_DEF, tbl)
    end
    hideLoading()
    if self.qualificationInfoIsBrush then
        self.qualificationInfoIsBrush = nil
        TFDirector:dispatchGlobalEventWith(MultiServerFightManager.qualificationInfoBrush, {})
        return
    end
    self:clossAllLayer()
    if self.qualificationInfoIsSwitch then
        self.qualificationInfoIsSwitch = nil
        local layer = AlertManager:addLayerByFile("lua.logic.multiServerFight.ScoreFightLayer")
        layer:setData(self:getActivityState())
        AlertManager:show()
    else
        self:clossAllLayer()
        local layer = AlertManager:addLayerByFile("lua.logic.multiServerFight.FightMainLayer")
        layer:setData(1)
        AlertManager:show()
    end
end

--购买资格赛名额
function MultiServerFightManager:requestBuyQualification()
    showLoading()
    TFDirector:send(c2s.APPLY_CROSS_CHAMPIONS,{})        
end

function MultiServerFightManager:onBuyQualification( event )
    hideLoading()
    TFDirector:dispatchGlobalEventWith(MultiServerFightManager.buyQualification, {})
end
--积分赛信息请求
function MultiServerFightManager:requestScoreRankInfos(state)
    showLoading()
    self.dispatchScoreRankState = state
   
    TFDirector:send(c2s.QUERY_SCORE_RANK_INFOS,{})    
end

function MultiServerFightManager:onScoreRankInfos( event )
    self.scoreRankInfos = event.data
    hideLoading()
    if self.scoreRankInfos.atkFormation then
        local tbl = stringToNumberTable(self.scoreRankInfos.atkFormation,',')
        ZhengbaManager:qunHaoDefFormationSet(EnumFightStrategyType.StrategyType_CHAMPIONS_ATK, tbl)
    end
    if self.scoreRankInfos.defFromation then
        local tbl = stringToNumberTable(self.scoreRankInfos.defFromation,',')
        ZhengbaManager:qunHaoDefFormationSet(EnumFightStrategyType.StrategyType_CHAMPIONS_DEF, tbl)
    end


    self:clossAllLayer()
    local layer = AlertManager:addLayerByFile("lua.logic.multiServerFight.FightMainLayer")
    layer:setData(self.dispatchScoreRankState)
    AlertManager:show()
end

--争霸赛信息请求
function MultiServerFightManager:requestCrossChampionsInfos(state, disMsg)
    showLoading()
    self.dispatchCrossChampionsState = state
    self.dispatchCrossChampions = disMsg

    TFDirector:send(c2s.QUERY_CROSS_CHAMPIONS_INFOS,{})
end

function MultiServerFightManager:onCrossChampionsInfos( event )
    self.crossChampionsInfos = event.data
    print('onCrossChampionsInfos--积分战 = ',event.data)
    if self.crossChampionsInfos.atkFormation then
        local tbl = stringToNumberTable(self.crossChampionsInfos.atkFormation,',')
        ZhengbaManager:qunHaoDefFormationSet(EnumFightStrategyType.StrategyType_CHAMPIONS_ATK, tbl)
    end
    if self.crossChampionsInfos.defFromation then
        local tbl = stringToNumberTable(self.crossChampionsInfos.defFromation,',')
        ZhengbaManager:qunHaoDefFormationSet(EnumFightStrategyType.StrategyType_CHAMPIONS_DEF, tbl)
    end

    hideLoading()
    if self.dispatchCrossChampions then
        TFDirector:dispatchGlobalEventWith(self.dispatchCrossChampions, {})
        self.dispatchCrossChampions = nil
    else
        self:clossAllLayer()
        local layer = AlertManager:addLayerByFile("lua.logic.multiServerFight.ScoreFightLayer")
        layer:setData(self.dispatchCrossChampionsState)
        AlertManager:show()
    end
end

function MultiServerFightManager:getRankInfosByState( state )
    if state == self.ActivityState_1 then
        return self.qualificationInfos
    else        
        return self.scoreRankInfos
    end
end

function MultiServerFightManager:getRankInfosForChampions()
    return self.crossChampionsInfos
end

function MultiServerFightManager:getFightTimeByState( state )
    if state == MultiServerFightManager.ActivityState_1 or state == MultiServerFightManager.ActivityState_2 then
        return self.timeDataManager[1]
    elseif state == MultiServerFightManager.ActivityState_3 or state == MultiServerFightManager.ActivityState_4 then
        return self.timeDataManager[2]
    else
        return self.timeDataManager[state]
    end
end

function MultiServerFightManager:getFightDataByRound(round)
    -- body
    local data = {}
    for k,v in pairs(self.ChampionInfosWarData) do
        if v.round == round then
            table.insert(data, v)
        end
    end

    local function sort( a,b )
       return a.index < b.index
    end
    table.sort(data,sort)
    return data
end

function MultiServerFightManager:openRuleLayer()
    CommonManager:showRuleLyaer('kuafuwulindahui')
end
function MultiServerFightManager:openRewardLayer()
    local layer = AlertManager:addLayerByFile("lua.logic.multiServerFight.KuaFuRewardLayer")
    AlertManager:show()
end
function MultiServerFightManager:openReportLayer(round)
    local layer = AlertManager:addLayerByFile("lua.logic.multiServerFight.KuaFuRecordLayer")
    layer:setData(round)
    AlertManager:show()
end

function MultiServerFightManager:getRecordList(round)
    local recordList = {}
    if self.ChampionInfosWarData then
        for k,v in pairs(self.ChampionInfosWarData) do
            if v.round <= round and (v.winPlayerId and v.winPlayerId ~= 0) then
                local idx = #recordList
                recordList[idx+1] = v                        
            end
        end     
    end
    print('ChampionInfosWarData = ',self.ChampionInfosWarData)
    return recordList
end
--16强对阵信息
function MultiServerFightManager:requestCrossChampionInfosWar(round)
    
    showLoading()
    self.dispatchFightWarRound = round
    TFDirector:send(c2s.QUERY_CROSS_CHAMPIONS_WAR_INFOS,{})    
end

function MultiServerFightManager:onCrossChampionInfosWar( event )
    -- print('onCrossChampionInfosWar--争霸战 = ',event.data)
    self.ChampionInfosWarData = event.data.infos or {}
    hideLoading()
    self:clossAllLayer()
    self.dispatchFightWarRound = self.dispatchFightWarRound or 1
    local layerFile = {
        "lua.logic.multiServerFight.KuaFuFirstRoundLayer",
        "lua.logic.multiServerFight.KuaFuSecondRoundLayer",
        "lua.logic.multiServerFight.KuaFuSecondRoundLayer",
        "lua.logic.multiServerFight.KuaFuSecondRoundLayer"}
        -- "lua.logic.multiServerFight.KuaFuThirdRoundLayer",
        -- "lua.logic.multiServerFight.KuaFuFourthRoundLayer"}
        print('self.dispatchFightWarRound = ',self.dispatchFightWarRound)
    local layer = AlertManager:addLayerByFile(layerFile[self.dispatchFightWarRound])
    layer:setData(self.dispatchFightWarRound)
    AlertManager:show()
end

function MultiServerFightManager:getSwitchLayerTime()
    return self.switchLayerTime
end

function MultiServerFightManager:requestCrossBet(round, index, coin, playerId)
    
    self.crossBetMsg = nil

    local msg = {
        round,
        index,
        coin,
        playerId
    }
    -- print('msg = ',msg)
    AlertManager:close()
    self.crossBetMsg = {}
    self.crossBetMsg.round = round
    self.crossBetMsg.index = index
    self.crossBetMsg.betPlayerId = playerId
    self.crossBetMsg.coin = coin    
    showLoading()
    TFDirector:send(c2s.CROSS_CHAMPIONS_BET,msg)
end

function MultiServerFightManager:onCrossBet(event)
    hideLoading()
    for i=1,#self.ChampionInfosWarData do
        if self.ChampionInfosWarData[i].round == self.crossBetMsg.round and self.ChampionInfosWarData[i].index == self.crossBetMsg.index then
            self.ChampionInfosWarData[i].betPlayerId = self.crossBetMsg.betPlayerId
            self.ChampionInfosWarData[i].coin = self.crossBetMsg.coin
        end
    end

    TFDirector:dispatchGlobalEventWith(MultiServerFightManager.CrossBetUpdate, {})
end

function MultiServerFightManager:onBtnReportClick( replayId )
    showLoading()
    TFDirector:send(c2s.WATCH_CROSS_SERVER_BATTLE_REPLAY,{replayId})
end

function MultiServerFightManager:btnDefClick()
    ZhengbaManager:openArmyLayer(EnumFightStrategyType.StrategyType_CHAMPIONS_DEF)
end

function MultiServerFightManager:btnAtkClick()
    ZhengbaManager:openArmyLayer(EnumFightStrategyType.StrategyType_CHAMPIONS_ATK)
end

function MultiServerFightManager:grand(event)
    local data = event.data
    print("grand data , ==",data)
    local message = {}
    if data.type == 1 then
        message = self:getYouBeatGrand( data.msg )
        if self.personGrandList:length() >= 20 then
            self.personGrandList:popFront()
        end
        self.personGrandList:pushBack(message)
    elseif data.type == 2 then
        message = self:getYouFailGrand( data.msg )
        if self.personGrandList:length() >= 20 then
            self.personGrandList:popFront()
        end
        self.personGrandList:pushBack(message)
    elseif data.type == 3 then
        message = self:getBeatYouGrand( data.msg )
        if self.personGrandList:length() >= 20 then
            self.personGrandList:popFront()
        end
        self.personGrandList:pushBack(message)
    elseif data.type == 4 then
        message = self:getFailYouGrand( data.msg )
        if self.personGrandList:length() >= 20 then
            self.personGrandList:popFront()
        end
        self.personGrandList:pushBack(message)
    elseif data.type == 5 then
        message = self:getAttWinStreakGrand( data.msg )
        if self.publicGrandList:length() >= 20 then
            self.publicGrandList:popFront()
        end
        self.publicGrandList:pushBack(message)
    elseif data.type == 6 then
        message = self:getDefWinStreakGrand( data.msg )
        if self.publicGrandList:length() >= 20 then
            self.publicGrandList:popFront()
        end
        self.publicGrandList:pushBack(message)
    end
end

function MultiServerFightManager:getYouBeatGrand( _message )
    local info = stringToTable(_message,",")
    local message = {}
    message.message = stringUtils.format(localizable.ZhengbaManager_jibai_xxx, info[1]) --"你击败了"..info[1].."，"
    message.score = stringUtils.format(localizable.ZhengbaManager_jifen_add, info[3]) --"积分+"..info[3]
    -- self.championsInfo.atkWinStreak = tonumber(info[2])
    -- if self.championsInfo.atkWinStreak > self.championsInfo.atkMaxWinStreak then
    --  self.championsInfo.atkMaxWinStreak = self.championsInfo.atkWinStreak
    -- end
    return message
end

function MultiServerFightManager:getYouFailGrand( _message )
    local info = stringToTable(_message,",")
    local message = {}
    message.message = stringUtils.format(localizable.ZhengbaManager_tiaozhanshibai, info[1]) --"你挑战"..info[1].."失败"
    -- self.championsInfo.atkWinStreak = 0
    return message
end


function MultiServerFightManager:getBeatYouGrand( _message )
    local info = stringToTable(_message,",")
    local message = {}
    message.message = stringUtils.format(localizable.ZhengbaManager_xxx_jibai, info[1])  --info[1].."击败了你"
    -- if self.championsInfo ~= nil then
    --     self.championsInfo.defWinStreak = 0
    --     self.championsInfo.defLostCount = self.championsInfo.defLostCount + 1
    -- end
    return message
end

function MultiServerFightManager:getFailYouGrand( _message )
    local info = stringToTable(_message,",")
    local message = {}
    message.message =  stringUtils.format(localizable.ZhengbaManager_xxx_tiaozhan, info[1]) --info[1].."挑战你失败，"
    message.score = stringUtils.format(localizable.ZhengbaManager_jifen_add, info[2]) -- "积分+"..info[2]
    -- if self.championsInfo == nil then
    --     return message
    -- end
    -- self.championsInfo.defWinStreak = self.championsInfo.defWinStreak + 1
    -- if self.championsInfo.defWinStreak > self.championsInfo.defMaxWinSteak then
    --     self.championsInfo.defMaxWinSteak = self.championsInfo.defWinStreak
    -- end
    -- self.championsInfo.score = self.championsInfo.score + tonumber(info[2])
    -- self.championsInfo.defWinCount = self.championsInfo.defWinCount + 1
    return message
end

function MultiServerFightManager:getAttWinStreakGrand( _message )
    local info = stringToTable(_message,",")
    local message = {}
    local times = tonumber(info[2])

    -- if times == 5 then
    --  message.message = info[1].."取得了进攻"..times.."连胜，正在暴走状态！"
    -- elseif times == 6 then
    --  message.message = info[1].."取得了进攻"..times.."连胜，已经技压群雄！"
    -- elseif times == 7 then
    --  message.message = info[1].."取得了进攻"..times.."连胜，已经无人能挡！"
    -- elseif times == 8 then
    --  message.message = info[1].."取得了进攻"..times.."连胜，已经主宰大会！"
    -- elseif times >= 9 then
    --  message.message = info[1].."取得了进攻"..times.."连胜，犹如天神下凡！"
    -- end

    local descIndex = times
    if times >= 9 then
        descIndex = 9
    end
    message.message = stringUtils.format(localizable.ZhengbaManager_fight_desc[descIndex], info[1], times)

    if times >= 10 then
        message.showEffect = true
    end
    return message
end

function MultiServerFightManager:getDefWinStreakGrand( _message )
    local info = stringToTable(_message,",")
    local message = {}
    -- message.message = info[1].."取得了防守"..info[2].."连胜，已经无人能破！"
    message.message = stringUtils.format(localizable.ZhengbaManager_fight_desc2, info[1], info[2])
    if tonumber(info[2]) >= 10 then
        message.showEffect = true
    end
    return message
end

function MultiServerFightManager:getReport( message_type )
    if message_type == 1 then
        return self.personGrandList
    else
        return self.publicGrandList
    end
end

function MultiServerFightManager:requestPreviousCrossInfo(isShow)
    showLoading()
    self.showPreviousCrossInfo = isShow
    TFDirector:send(c2s.GAIN_PREVIOUS_CROSS_INFO,{})
end

function MultiServerFightManager:onPreviousCrossInfo(event)
    hideLoading()
    self.previousCrossInfo = event.data
    if self.showPreviousCrossInfo == true then
        self:clossAllLayer()
        self.showPreviousCrossInfo = false
        local layer = AlertManager:addLayerByFile("lua.logic.multiServerFight.KuaFuResultLayer")        
        layer:setInfo(event.data)
        AlertManager:show()
    else
        TFDirector:dispatchGlobalEventWith(MultiServerFightManager.updatePreviousCrossInfo, {})
    end
end
function MultiServerFightManager:getPreviousCrossInfo()
    return self.previousCrossInfo
end

function MultiServerFightManager:switchFightLayer()
    local state = self:getActivityState()
    local round = nil
    if (state == self.ActivityState_6 or state == self.ActivityState_7) or state == self.ActivityState_8 then
        timeInfo = self:getFightTimeByState( state-1 )
        currTime = self:getCurrSecond()
        round = state - self.ActivityState_5
        if currTime >= timeInfo.nextFightTime then
            round = round + 1
        end
    end
    if round then
        self:clossAllLayer()
        local layerFile = {
            "lua.logic.multiServerFight.KuaFuFirstRoundLayer",
            "lua.logic.multiServerFight.KuaFuSecondRoundLayer",
            "lua.logic.multiServerFight.KuaFuSecondRoundLayer",
            "lua.logic.multiServerFight.KuaFuSecondRoundLayer"}

        local layer = AlertManager:addLayerByFile(layerFile[round])
        layer:setData(round)
        AlertManager:show()
    end
end

return MultiServerFightManager:new()