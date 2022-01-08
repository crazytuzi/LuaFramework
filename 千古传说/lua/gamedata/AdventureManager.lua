--[[
******奇遇玩法数据管理类*******

	-- by quanhuan
	-- 2016/3/14
	
]]

local AdventureManager = class("AdventureManager")

AdventureManager.openHomeLayerEvent = "AdventureManager.openHomeLayerEvent"
AdventureManager.refreshRandomEvent = "AdventureManager.refreshRandomEvent"
AdventureManager.refreshOtherPlayerInfo = "AdventureManager.refreshOtherPlayerInfo"
AdventureManager.refreshHomeLayer = "AdventureManager.refreshHomeLayer"
AdventureManager.talkEndMessage = "AdventureManager.talkEndMessage"
AdventureManager.fightEndMessage = "AdventureManager.fightEndMessage"
AdventureManager.unableToChallenge = "AdventureManager.unableToChallenge"
AdventureManager.adventureShopBuy = "AdventureManager.adventureShopBuy"
AdventureManager.enemyListData = "AdventureManager.enemyListData"
AdventureManager.fightType_0 = 20 --杀戮
AdventureManager.fightType_1 = 21 --复仇
AdventureManager.fightType_2 = 22 --排行榜挑战

AdventureManager.MapTalkIndex = 3

function AdventureManager:ctor(data)

    --请求奇遇主界面数据
    TFDirector:addProto(s2c.ADVENTURE_INTERFACE, self, self.onHomeLayerDataReceive) 

    --主线任务 或者 随机事件结果反馈
    TFDirector:addProto(s2c.ADVENTURE_EVENT, self, self.onEventComplete) 

    --查看杀戮信息
    TFDirector:addProto(s2c.ADVENTURE_MASSACRE, self, self.onAdventureMassacre) 

    --奇遇阵容信息
    TFDirector:addProto(s2c.ADVENTURE_FORMATION, self, self.onFightStrategyList)

    TFDirector:addProto(s2c.ADVENTURE_CHALLENGE_RESULT, self, self.onFightEnd)

    TFDirector:addProto(s2c.UNABLE_TO_CHALLENGE, self, self.onUnableToChallenge)
    
	TFDirector:addProto(s2c.ADVENTURE_SHOP_BUY, self, self.onShopBuy)

    TFDirector:addProto(s2c.ADVENTURE_ENEMY, self, self.onEnemyListData)

    TFDirector:addProto(s2c.ADVENTURE_BATTLE_LOG, self, self.onFightRecord)

    --清除玩家cd时间
    TFDirector:addProto(s2c.RESET_PLAYER_TIME, self, self.onResetPlayerTime)    
    
    self:restart()
end


function AdventureManager:restart()

    self.mainStructData = nil --包含 3个玩家信息 随机事件ID和刷新时间 玩家刷新倒计时
    self.fightStrategyList = {} -- 双阵容阵型
end

function AdventureManager:resetData_24()
    self:requestHomeLayerData()
end

function AdventureManager:reConnect()
	-- body
end

function AdventureManager:reLoad()
	-- body
end

function AdventureManager:requestHomeLayerData(dispatchMessage)

    self.homeLayerDispatchMessage = dispatchMessage
    TFDirector:send(c2s.ADVENTURE_INTERFACE,{})
    showLoading()

    --[[
        test code begin      
    ]]
    -- local event = {}
    -- event.data = {}

    -- --刷新到的玩家
    -- event.data.opponent = {}
    -- for i=1,3 do
    --     event.data.opponent[i] = {}
    --     event.data.opponent[i].id = i
    --     event.data.opponent[i].name = '测试玩家'..i
    --     event.data.opponent[i].level = i
    --     event.data.opponent[i].power = i*100
    --     event.data.opponent[i].icon = 77+i
    --     event.data.opponent[i].headPicFrame = i
    -- end
    -- event.data.experience = 1000

    -- event.data.eventId = 1

    -- --随机事件刷新时间
    -- event.data.refresheventTime = nil
    -- --玩家刷新时间
    -- event.data.refreshOpponentTime = MainPlayer:getNowtime()*1000

    -- self:onHomeLayerDataReceive(event)
    --[[
        test code end
    ]]
end

function AdventureManager:onHomeLayerDataReceive( event )
    hideLoading()

    self.mainStructData = event.data

    self:resetOtherPlayerRandomPos(event.data.opponent)

    print('onHomeLayerDataReceive event.data = ',event.data)
    if self.homeLayerDispatchMessage then
        TFDirector:dispatchGlobalEventWith(self.homeLayerDispatchMessage,{})
        self.homeLayerDispatchMessage = nil
    else
        TFDirector:dispatchGlobalEventWith(AdventureManager.refreshHomeLayer)    
    end
end

function AdventureManager:openHomeLayer()

    local openLevel = FunctionOpenConfigure:getOpenLevel(2203)
    local currLevel = MainPlayer:getLevel()
    if currLevel < openLevel then
        return
    end
    

    if self.openHomeLayerCallBack then
        TFDirector:removeMEGlobalListener(AdventureManager.openHomeLayerEvent, self.openHomeLayerCallBack)    
        self.openHomeLayerCallBack = nil
    end

    self.openHomeLayerCallBack = function (event)
        local layer = AlertManager:addLayerByFile("lua.logic.youli.AdventureHomeLayer")--require("lua.logic.youli.AdventureHomeLayer"):new()
        -- AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
        layer:setDataReady()
        AlertManager:show()

        TFDirector:removeMEGlobalListener(AdventureManager.openHomeLayerEvent, self.openHomeLayerCallBack)    
        self.openHomeLayerCallBack = nil
    end
    TFDirector:addMEGlobalListener(AdventureManager.openHomeLayerEvent, self.openHomeLayerCallBack)

    self:requestHomeLayerData(AdventureManager.openHomeLayerEvent)
end

function AdventureManager:getOtherPlayerInfo()
    
    --通过检测是否存在刷新时间 选择显示倒计时或者玩家头像    
    local cutDown = self.mainStructData.refreshOpponentTime
    -- print('self.mainStructData = ',self.mainStructData)
    if cutDown then
        cutDown = math.floor(cutDown/1000)
        local nowTime = MainPlayer:getNowtime()

        if nowTime >= cutDown then
            cutDown = 0
        else
            cutDown = cutDown - nowTime 
        end
    end
    return cutDown,self.mainStructData.opponent
end

function AdventureManager:getRandomEventInfo()
    
    --[[
        - 若refresheventTime 存在且不为0 则等待随机事件出现
        - 若eventId存在且不为0 则出现随机事件        
        - 若refresheventTime 和 eventId 均不存在则 今日随机事件任务已完成
    ]]
    local cutDown = self.mainStructData.refresheventTime
    if cutDown then
        cutDown = math.floor(cutDown/1000)
        local nowTime = MainPlayer:getNowtime()
        if nowTime >= cutDown then
            cutDown = 0
        else
            cutDown = cutDown - nowTime
        end        
    end
    return cutDown,self.mainStructData.eventId
end

function AdventureManager:requestEventComplete( eventId )

    print('eventId = ',eventId)
    self.requestEventCompleteID = eventId
    MissionManager.attackMissionId = eventId        
    local mission = AdventureMissionManager:getMissionById(eventId)
    MissionManager.isFirstTimesPass = false;
    if not mission.starLevel  or mission.starLevel < MissionManager.STARLEVEL1 then
        MissionManager.isFirstTimesPass = true;
    end
    if eventId >= AdventureMissionManager.randomMissionIndexStart then
        --随机事件
        TFDirector:send(c2s.ADVENTURE_EVENT,{eventId})
    else
        --主线任务        
        TFDirector:send(c2s.ADVENTURE_CHALLENGE,{eventId})
    end
    showLoading()
end

function AdventureManager:onEventComplete( event )
    hideLoading()
    if event.data.result == 0 then       
        self:requestHomeLayerData(AdventureManager.refreshHomeLayer)    
    else
        --失败
    end
end

function AdventureManager:onFightEnd(event)
    hideLoading()
    TFDirector:dispatchGlobalEventWith(AdventureManager.fightEndMessage, event.data)
end

function AdventureManager:onUnableToChallenge(event)
    hideLoading()
    TFDirector:dispatchGlobalEventWith(AdventureManager.unableToChallenge, event.data)
end

function AdventureManager:onShopBuy(event)
    hideLoading()
    TFDirector:dispatchGlobalEventWith(AdventureManager.adventureShopBuy, event.data)
end

function AdventureManager:onEnemyListData(event)
    hideLoading()
    print("onEnemyListData = ",event.data)
    self.enemyList = event.data.enemy
    TFDirector:dispatchGlobalEventWith(AdventureManager.enemyListData, self.enemyList)
    if self.isOpenEnemyLayer == true then
        local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.youli.AdventureEnemyLayer",AlertManager.BLOCK_AND_GRAY)
        AlertManager:show()
        self.isOpenEnemyLayer = false
    end
end

function AdventureManager:onFightRecord(event)
    hideLoading()
    print("onFightRecord = ",event.data)
    self.fightRecordInfo = event.data.log or {}
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.youli.ShaLuRecordLayer",AlertManager.BLOCK_AND_GRAY)
    layer:SetData(event.data.log or {})
    AlertManager:show()
end

function AdventureManager:openFightRecordByIndex( index )
    self.openNextRecordId = nil
    local data = self.fightRecordInfo[index]
    if data then
        self.openNextRecordId = data.secondRecordId
        showLoading()
        TFDirector:send(c2s.PLAY_ARENA_TOP_BATTLE_REPORT, {data.firstRecordId})
    end
end

function AdventureManager:getNextReportId()
    return self.openNextRecordId
end

function AdventureManager:openSecondFightReport( reprotId )
    showLoading()
    TFDirector:send(c2s.PLAY_ARENA_TOP_BATTLE_REPORT, {reprotId})
end

function AdventureManager:getEnemyList()
    return self.enemyList or {}
end

function AdventureManager:getEnemyPlayerInfoById( playerId )
    local enemyList = self:getEnemyList()
    for k,v in pairs(enemyList) do
        if v.id == playerId then
            return v
        end
    end
    return nil
end
--打开玩家杀戮界面
function AdventureManager:openShaNuLayer( playerId , callBack)
    local info = nil
    for k,v in pairs(self.mainStructData.opponent) do
        if v.id == playerId then
            info = clone(v)
            break;
        end
    end
    if info then
        local layer = require("lua.logic.youli.ShaLuNearbyInfoLayer"):new()
        AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1)
        layer:setInfo(info,callBack)
        AlertManager:show()
    else
        print('cannot find the player info by id = ',playerId)
    end
end

function AdventureManager:resetOtherPlayerRandomPos(opponent)
    opponent = opponent or {}
    local playerList = {}
    for k,v in pairs(opponent) do
        playerList[#playerList + 1] = v.id
    end
    -- print('playerList = ',playerList)
    self.otherPlayerRandomPos = self.otherPlayerRandomPos or {}

    local function checkNeedReset( tbl )
        for k,v in pairs(tbl) do
            if self.otherPlayerRandomPos[v] == nil then
                return true
            end
        end
        return false
    end
    
    if checkNeedReset(playerList) then
        self.otherPlayerRandomPos = {}
        math.randomseed(os.time())
        local posTemplete = {1,2,3,4,5,6}
        for k,v in pairs(playerList) do
            local len = table.getn(posTemplete)
            local pos = 1 + math.ceil(math.random()*100)%len
            self.otherPlayerRandomPos[v] = posTemplete[pos]
            table.remove(posTemplete, pos)
        end
    end
    print('self.otherPlayerRandomPos - ',self.otherPlayerRandomPos)
end

function AdventureManager:getOtherPlayerInfoPos(playerId)
    local index = self.otherPlayerRandomPos[playerId] or 1
    local pos = {}
    pos.x = localizable.youli_playerHead_xy[index].x
    pos.y = localizable.youli_playerHead_xy[index].y
    return pos
end

function AdventureManager:requestBattle( type,playerId )


    if self:checkIsDoubleStrategy() then
        local msg = {
            type,
            playerId
        }
        showLoading();
        if type == AdventureManager.fightType_2 then
            local data = {
                result = 1,
                playerId = playerId,
                type = type
            }
            TFDirector:dispatchGlobalEventWith(AdventureManager.fightEndMessage, data)
        elseif type == AdventureManager.fightType_1 then
            self.isFightingEnemy = true
        elseif type == AdventureManager.fightType_0 then
            local cdTime = ConstantData:objectByID("Kill.Search.ColdCD").value or 300
            self.mainStructData.refreshOpponentTime = (MainPlayer:getNowtime()+cdTime)*1000
        end
        TFDirector:send(c2s.ADVENTURE_PLAYER_BATTLE, msg)
    else
        toastMessage(localizable.youli_DoubleStrategyNo)
    end
end

function AdventureManager:requestEnemyList()
    showLoading();
    TFDirector:send(c2s.ADVENTURE_ENEMY, {});
end

function AdventureManager:requestFightRecord()
    showLoading();
    TFDirector:send(c2s.ADVENTURE_BATTLE_LOG, {});
end

function AdventureManager:buyTianShu(data,num)
    local msg = {
        data.type,
        data.id,
        num
    }
    showLoading();
    print('msg = ',msg)
    TFDirector:send(c2s.ADVENTURE_SHOP_BUY, msg);
end

function AdventureManager:onFightStrategyList( event )
    local data = event.data
    print('data = ',data)
    ZhengbaManager:qunHaoDefFormationSet(EnumFightStrategyType.StrategyType_DOUBLE_1, data.formation )
    ZhengbaManager:qunHaoDefFormationSet(EnumFightStrategyType.StrategyType_DOUBLE_2, data.secondFormation )
end

function AdventureManager:openShaluVsLayer(playerId, fightType)
    local LineUpType = {EnumFightStrategyType.StrategyType_DOUBLE_1,EnumFightStrategyType.StrategyType_DOUBLE_2}
    local armyRoleInfo = {}

    if fightType == AdventureManager.fightType_0 then
        --杀戮附近的玩家
        local playerInfo = self:getOtherPlayerInfoByPlayerId(playerId)
        if playerInfo == nil then
            print('cannot find the palyer info by id = ',playerId)
            return
        end
        armyRoleInfo.secondPower = playerInfo.secondPower
        armyRoleInfo.playerName = playerInfo.name
        armyRoleInfo.playerId = playerInfo.id
        armyRoleInfo.power = playerInfo.power
        armyRoleInfo.headIconId = playerInfo.icon
        armyRoleInfo.HeadFrameId = playerInfo.headPicFrame
        armyRoleInfo.role_list = {}
        for i=1,2 do
            armyRoleInfo.role_list[i] = {}
            local roleList = playerInfo.formation or {}
            if i == 2 then
                roleList = playerInfo.secondFormation or {}
            end
            for k,v in pairs(roleList) do
                armyRoleInfo.role_list[i][v.position+1] = {}
                armyRoleInfo.role_list[i][v.position+1].id = v.templateId
                armyRoleInfo.role_list[i][v.position+1].quality = v.quality
            end
        end
    elseif fightType == AdventureManager.fightType_1 then
        --复仇
        local playerInfo = self:getEnemyPlayerInfoById(playerId)
        if playerInfo == nil then
            print('cannot find the palyer info by id = ',playerId)
            return
        end
        armyRoleInfo.secondPower = playerInfo.secondPower
        armyRoleInfo.playerName = playerInfo.name
        armyRoleInfo.playerId = playerInfo.id
        armyRoleInfo.power = playerInfo.power
        armyRoleInfo.headIconId = playerInfo.icon
        armyRoleInfo.HeadFrameId = playerInfo.headPicFrame
        armyRoleInfo.role_list = {}
        for i=1,2 do
            armyRoleInfo.role_list[i] = {}
            local roleList = playerInfo.formation or {}
            if i == 2 then
                roleList = playerInfo.secondFormation or {}
            end
            for k,v in pairs(roleList) do
                armyRoleInfo.role_list[i][v.position+1] = {}
                armyRoleInfo.role_list[i][v.position+1].id = v.templateId
                armyRoleInfo.role_list[i][v.position+1].quality = v.quality
            end
        end
    elseif fightType == AdventureManager.fightType_2 then
        --排行榜挑战
        local playerInfo = RankManager:getPlayerInfoByTypePlayerID( RankListType.Rank_List_ShaLu,playerId )
        if playerInfo == nil then
            print('cannot find the palyer info by id = ',playerId)
            return
        end
        armyRoleInfo.playerName = playerInfo.name
        armyRoleInfo.playerId = playerInfo.playerId
        armyRoleInfo.power = playerInfo.power
        armyRoleInfo.secondPower = playerInfo.secondPower
        armyRoleInfo.headIconId = playerInfo.profession
        armyRoleInfo.HeadFrameId = playerInfo.headPicFrame
        armyRoleInfo.role_list = {}
        for i=1,2 do
            armyRoleInfo.role_list[i] = {}
            local roleList = playerInfo.formation or {}
            if i == 2 then
                roleList = playerInfo.secondFormation or {}
            end
            for k,v in pairs(roleList) do
                armyRoleInfo.role_list[i][v.position+1] = {}
                armyRoleInfo.role_list[i][v.position+1].id = v.templateId
                armyRoleInfo.role_list[i][v.position+1].quality = v.quality
            end
        end
    else
        print('cannot find the fightType = ',fightType)
        return 
    end

    local layer = require("lua.logic.youli.ShaLuArmyVSLayer"):new()
    AlertManager:addLayer(layer,AlertManager.BLOCK,AlertManager.TWEEN_1)
    layer:setData(LineUpType, armyRoleInfo, fightType)
    AlertManager:show()
end

function AdventureManager:openAdventureMissionDetailLayer(missionId)
    print('openAdventureMissionDetailLayer = ',missionId)
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.youli.AdventureMissionDetailLayer",AlertManager.BLOCK)
    layer:loadData(missionId)
    AlertManager:show()
end

function AdventureManager:openAdventureRandomDetailLayer(missionId)

    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.youli.AdventureRandomDetailLayer",AlertManager.BLOCK)
    layer:loadData(missionId)
    AlertManager:show()
end

function AdventureManager:openAdventureEnemyLayer()
    print('openAdventureEnemyLayer')
    self.isOpenEnemyLayer = true
    self.isFightingEnemy = false
    self:requestEnemyList()
end

function AdventureManager:openFightRecordLayer()
    AdventureManager:requestFightRecord()
end

function AdventureManager:getOtherPlayerInfoByPlayerId( playerId )
    for k,v in pairs(self.mainStructData.opponent) do
        if v.id == playerId then
            return v
        end
    end
    return nil
end

function AdventureManager:checkIsDoubleStrategy()

    local LineUpType = {EnumFightStrategyType.StrategyType_DOUBLE_1,EnumFightStrategyType.StrategyType_DOUBLE_2}
    local state = 0
    for k,v in pairs(LineUpType) do
        local fightList = ZhengbaManager:getFightList( v )
        for _,roleId in pairs(fightList) do
            local role = CardRoleManager:getRoleByGmid(roleId)
            if role then
            -- if roleId and roleId ~= 0 then
                state = state + 1
                break
            end 
        end
    end

    if state == 2 then
        return true
    end
    return false
end

function AdventureManager:requestResetPlayerTime()
    showLoading()
    TFDirector:send(c2s.RESET_PLAYER_TIME, {})
end

function AdventureManager:onResetPlayerTime(event)
    hideLoading()
    if event.data.result == 0 then
        --成功
        toastMessage(localizable.youli_otherplayer_text1)
        self:requestHomeLayerData()
    else
        --失败
    end
end

function AdventureManager:requestAdventureMassacre()
    showLoading()
    TFDirector:send(c2s.ADVENTURE_MASSACRE, {})
end

function AdventureManager:onAdventureMassacre( event )
    hideLoading()
    local layer = require("lua.logic.youli.ShaLuInfoLayer"):new()
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1)
    layer:setInfo(event.data)
    AlertManager:show()
end

function AdventureManager:openMissLayer()
    if AdventureMissionManager:getCurrAcrossMission() == nil then
        toastMessage(localizable.youli_openmission_text)
        return nil
    end
    local layer = require("lua.logic.youli.AdventureMissionLayer"):new()
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
    AlertManager:show()
    return layer
end

function AdventureManager:openAdventureMallLayer()
    local teamLev = MainPlayer:getLevel()
    local openLev = FunctionOpenConfigure:getOpenLevel(2203)
    if teamLev < openLev then
        toastMessage(stringUtils.format(localizable.common_function_openlevel,openLev))
    else
        MallManager:openMallLayerByType(EnumMallType.AdventureMall,1)
    end
    --local layer = require("lua.logic.mall.AdventureMallLayer"):new()
    --AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    --AlertManager:show()
end
function AdventureManager:startSecondBattle()
    showLoading()
    TFDirector:send(c2s.START_SECOND_BATTLE,{})
end
return AdventureManager:new()