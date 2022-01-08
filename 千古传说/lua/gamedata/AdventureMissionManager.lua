--[[
******奇遇玩法关卡管理类*******

	-- by quanhuan
	-- 2016/3/15	
]]

local AdventureMissionManager = class("AdventureMissionManager")

--奇遇关卡编号起点
AdventureMissionManager.missionIndexStart = 20000
--奇遇随机事件编号起点
AdventureMissionManager.randomMissionIndexStart = 30000

--第几阵容对战
AdventureMissionManager.fightRound_1 = 1
AdventureMissionManager.fightRound_2 = 2

AdventureMissionManager.singleFight = 3
AdventureMissionManager.doubleFight = 4

function AdventureMissionManager:ctor(data)

    self.missionList     = require("lua.table.t_s_adventure_copy");
    self.mapList         = require("lua.table.t_s_adventure_mapinfo");
    self.randomEventList         = require("lua.table.t_s_adventure_event");

    self:restart()
end


function AdventureMissionManager:restart()   

end

function AdventureMissionManager:resetData_24()
    
end

function AdventureMissionManager:reConnect()
	-- body
end

function AdventureMissionManager:reLoad()
	-- body
end

function AdventureMissionManager:onReceiveMissionList(data)

    local function getPlayerMissionByMissionId( missionId )
        if not data.missionlist then
           return nil
        end
        for index,playerMission in pairs(data.missionlist) do
           if playerMission.missionId == missionId then
             return playerMission;
           end
        end
        return nil
    end

    for mission in self.missionList:iterator() do
        local playerMission = getPlayerMissionByMissionId(mission.id)
        if playerMission then
            mission.challengeCount = playerMission.challengeCount
            mission.starLevel = playerMission.starLevel
            mission.resetCount = playerMission.resetCount or 0
        else
            mission.challengeCount = 0
            mission.starLevel = MissionManager.STARLEVEL0
            mission.resetCount = 0
        end
    end
end

--根据ID取得关卡
function AdventureMissionManager:getMissionById(missionId)
    if missionId < self.missionIndexStart then
        return nil
    elseif missionId >= AdventureMissionManager.randomMissionIndexStart then
        return AdventureRandomEventData:getInfoById(missionId);
    end
    return self.missionList:objectByID(missionId);
end

function AdventureMissionManager:getMapById(mapId)
    return self.mapList:objectByID(mapId);
end

function AdventureMissionManager:getMapList()
    return self.mapList;
end

function AdventureMissionManager:resetMissionData()
    -- 挑战次数重置
    for mission in self.missionList:iterator() do
        mission.challengeCount = 0;
        --add by wkdai,reset count per section
        mission.resetCount = 0;
    end
end

--下一个关卡的信息
function AdventureMissionManager:getNextMissionById(mapId,difficulty,missionId)
    local missionlist = self:getMissionListByMapIdAndDifficulty(mapId,difficulty);
    for mission in missionlist:iterator() do
        if mission.id > missionId then
            return mission;
        end
    end
    return nil;
end

--取得特定章节的关卡列表
function AdventureMissionManager:getMissionListByMapIdAndDifficulty(mapId,difficulty)
    local missionlist = TFArray:new();
    for mission in self.missionList:iterator() do
        if mission.map_id == mapId and ( mission.difficulty == difficulty or difficulty == nil ) then
              missionlist:push(mission);
        end
    end
    return missionlist;
end

--低等级的当前关卡
function AdventureMissionManager:getCurrentMission(difficulty)
    if difficulty == MissionManager.DIFFICULTY3 or difficulty == MissionManager.DIFFICULTY4 then
        local _mission = nil
        for mission in self.missionList:iterator() do
            if mission.difficulty == difficulty then
                if mission.starLevel == MissionManager.STARLEVEL0 then
                    return mission;
                end
                _mission = mission
            end
        end
        return _mission;
    end
    return nil    
end

function AdventureMissionManager:getDropItemByMissionId(missionId, round)
    local mission = self:getMissionById(missionId);
    if round == AdventureMissionManager.fightRound_1 then
        return DropGroupData:GetShowDropItemByIdsStr(mission.goods_drop)
    else
        return DropGroupData:GetShowDropItemByIdsStr(mission.second_goods_drop)
    end    
end

function AdventureMissionManager:getDropItemListByMissionId(missionId,round)
    local mission = self:getMissionById(missionId)
    if round == AdventureMissionManager.fightRound_1 then
        return DropGroupData:GetDropItemListByIdsStr(mission.goods_drop)
    else
        return DropGroupData:GetDropItemListByIdsStr(mission.second_goods_drop)
    end
end

function AdventureMissionManager:getCurrMission()
    for mission in self.missionList:iterator() do
        if mission.starLevel == MissionManager.STARLEVEL0 then
            return mission
        end
    end
end

function AdventureMissionManager:getCurrAcrossMission()
    local tempMiss = nil
    local curMiss = nil
    for mission in self.missionList:iterator() do
        tempMiss = curMiss
        curMiss = mission
        if mission.starLevel == MissionManager.STARLEVEL0 then
            return tempMiss
        end
    end
    return curMiss
end


function MissionManager:getMissionPassStatus(missionId)
    local mission = self:getMissionById(missionId);
    if mission == nil then
        print("mission == nil ,missionId =" , missionId)
        return
    end
    local missionlist = self:getMissionListByMapId(mission.map_id);
    local status = 1; --1\2\3 已通关、当前、未开放

    --初级难度
    if (mission.difficulty == MissionManager.DIFFICULTY0) then

        local currentMission = self:getCurrentMission(MissionManager.DIFFICULTY0)
        if not currentMission then
            status = 1;
        else
            --已通关
            if (missionId < currentMission.id) then
                status = 1;
            end
            --当前关
            if (missionId == currentMission.id) then
                status = 2;
            end
            --未开放
            if (missionId > currentMission.id) then
                status = 3; 
            end
        end
    end

    --初级难度
    if (mission.difficulty == MissionManager.DIFFICULTY1) then

        local currentMission0 = self:getCurrentMission(MissionManager.DIFFICULTY0)
        local currentMission  = self:getCurrentMission(MissionManager.DIFFICULTY1)

        -- print("-----------------")
        -- print("missionId = ", missionId)
        -- -- print("mission = ", mission)

        -- print("missionId = ", missionId)
        -- print("currentMission0 = ", currentMission0.id)
        -- print("currentMission = ", currentMission.id)
        -- print("currentMission0.mapid = ", currentMission0.mapid)
        -- print("mission.mapid = ", mission.mapid)
        -- print("currentMission0.mapid = ", currentMission0.mapid)
        -- if currentMission0 and  mission.mapid >= currentMission0.mapid then
        status = 3;
        if currentMission0 and  mission.mapid <= currentMission.mapid then
            status = 3; 
        -- elseif not currentMission then
        --     status = 1;
        -- else
            --已通关
            if (missionId < currentMission.id) then
                status = 1;
            end
            --当前关
            if (missionId == currentMission.id) then
                status = 2;
            end
            --未开放
            if (missionId > currentMission.id) then
                status = 3; 
            end
        end

    end

    -- print("status = ", status)

    return status;
end

return AdventureMissionManager:new()