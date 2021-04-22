
local QBattleMissionTracer = class("QBattleMissionTracer")

local QMissionBase = import(".mission.QMissionBase")
local QMissionBattleForceLimited = import(".mission.QMissionBattleForceLimited")
local QMissionDeathLimited = import(".mission.QMissionDeathLimited")
local QMissionHeroSelected = import(".mission.QMissionHeroSelected")
local QMissionKillEnemyTimeLimited = import(".mission.QMissionKillEnemyTimeLimited")
local QMissionVictory = import(".mission.QMissionVictory")
local QMissionVictoryTimeLimited = import(".mission.QMissionVictoryTimeLimited")

local QStaticDatabase = import("..controllers.QStaticDatabase")

function QBattleMissionTracer:ctor(dungeonId, options)
	self._dungeonTargetInfo = QStaticDatabase.sharedDatabase():getDungeonTargetByID(dungeonId)
	assert(self._dungeonTargetInfo ~= nil, "dungeon target infomation with dungeon id:" .. tostring(dungeonId) .. " is not exist!")

	self:_handlerDungeonMissions()
end

function QBattleMissionTracer:beginTracer()
	for _, mission in ipairs(self._missions) do
		mission:beginTrace()
	end
end

function QBattleMissionTracer:endTracer()
	for _, mission in ipairs(self._missions) do
		mission:endTrace()
	end
end

function QBattleMissionTracer:getCompleteMissionCount()
	local count = 0
	local compleltedId = "" -- 1;2;3; means three stars are achieve
	for k, mission in ipairs(self._missions) do
		if mission:isCompleted() == true then
			count = count + 1
			compleltedId = compleltedId .. k .. ";"
		end
	end
	return count, compleltedId
end

function QBattleMissionTracer:isMissionComplete(index)
	if index == nil then
		return false
	end

	if index > (#self._missions) then
		return false
	end 

	local mission = self._missions[index]
	if mission ~= nil then
		return mission:isCompleted()
	end

	return false
end

function QBattleMissionTracer:getMissionIndex(mission)
	if mission == nil then
		return nil
	end

	for i, m in ipairs(self._missions) do
		if m == mission then
			return i
		end
	end

	return nil
end

function QBattleMissionTracer:_handlerDungeonMissions()
	self._missions = {}
	if self._dungeonTargetInfo == nil then
		return
	end

	for i, targetInfo in ipairs(self._dungeonTargetInfo) do
		-- only three star
		if i > 3 then
			break
		end

		if targetInfo.target_type == QMissionBase.Type_Battle_Force_Limited then
			local numbers = self:_splitToNumbers(targetInfo.target_value_1, ";")
			local mission = QMissionBattleForceLimited.new(numbers[1], numbers[2], {description = targetInfo.target_text})
			table.insert(self._missions, mission)

		elseif targetInfo.target_type == QMissionBase.Type_Death_limited then
			local numbers = self:_splitToNumbers(targetInfo.target_value_1, ";")
			local mission = QMissionDeathLimited.new(numbers[1], numbers[2], {description = targetInfo.target_text})
			table.insert(self._missions, mission)

		elseif targetInfo.target_type == QMissionBase.Type_Hero_Selected then
			local strings = self:_splitToStrings(targetInfo.target_value_1, ";")
			local mission = QMissionHeroSelected.new(strings, {description = targetInfo.target_text})
			table.insert(self._missions, mission)

		elseif targetInfo.target_type == QMissionBase.Type_Kill_Enemy_Time_Limited then
			local mission = QMissionKillEnemyTimeLimited.new(targetInfo.target_value_1, tonumber(targetInfo.target_value_2), {description = targetInfo.target_text})
			table.insert(self._missions, mission)

		elseif targetInfo.target_type == QMissionBase.Type_Victory then
			local mission = QMissionVictory.new({description = targetInfo.target_text})
			table.insert(self._missions, mission)
		
		elseif targetInfo.target_type == QMissionBase.Type_Victory_Time_Limited then
			local numbers = self:_splitToNumbers(targetInfo.target_value_1, ";")
			local mission = QMissionVictoryTimeLimited.new(numbers[1], numbers[2], {description = targetInfo.target_text})
			table.insert(self._missions, mission)
		end

	end
end

function QBattleMissionTracer:_splitToNumbers(value, delimiter)
	local numbers = {}
	if value == nil or delimiter == nil then
		return numbers
	end

	for _, value in ipairs(string.split(value, delimiter)) do
		if value ~= nil and string.len(value) > 0 then
			table.insert(numbers, tonumber(value))
		end
	end

	return numbers
end

function QBattleMissionTracer:_splitToStrings(value, delimiter)
	local strings = {}
	if value == nil or delimiter == nil then
		return strings
	end

	for _, value in ipairs(string.split(value, delimiter)) do
		if value ~= nil and string.len(value) > 0 then
			table.insert(strings, tostring(value))
		end
	end

	return numbers
end

return QBattleMissionTracer