-- @Author: xurui
-- @Date:   2018-08-07 17:05:48
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-03-04 23:12:22
local QTeamNormal = import(".QTeamNormal")
local QTeamMetalCity = class("QTeamMetalCity", QTeamNormal)
local QStaticDatabase = import("....controllers.QStaticDatabase")

function QTeamMetalCity:ctor(options)
	QTeamMetalCity.super.ctor(self, options)
end

--设置战队的数据
function QTeamMetalCity:setTeamDataWithBattleFormation(battleFormation)
	self:setTeamActorsByIndex(1, battleFormation.mainHeroIds or {})
	self:setTeamActorsByIndex(2, battleFormation.sub1HeroIds or {})
	self:setTeamGodarmByIndex(5, battleFormation.godArmIdList or {})
	local skill = {}
	skill[1] = battleFormation.activeSub1HeroId
	skill[2] = battleFormation.activeSub2HeroId
	self:setTeamSkillByIndex(2, skill)

	-- local soulSpiritId = battleFormation.soulSpiritId or {}
	self:setTeamSpiritsByIndex(1, battleFormation.soulSpiritId or {})	

	self:checkTeam()
end

--根据战队序号获取解锁的魂师最大位置
function QTeamMetalCity:getHerosMaxCountByIndex(index)
	local trailNum = self:getTeamNum()
	local count = 0
	if index == 1 then
		count = 4
	elseif index == 2 then
		if trailNum == 1 then
			if app.unlock:checkLock("UNLOCK_METALCITY_HELP_7") then
				count = 4
			elseif app.unlock:checkLock("UNLOCK_METALCITY_HELP_5") then
				count = 3
			elseif app.unlock:checkLock("UNLOCK_METALCITY_HELP_3") then
				count = 2
			elseif app.unlock:checkLock("UNLOCK_METALCITY_HELP_1") then
				count = 1
			end
		else
			if app.unlock:checkLock("UNLOCK_METALCITY_HELP_8") then
				count = 4
			elseif app.unlock:checkLock("UNLOCK_METALCITY_HELP_6") then
				count = 3
			elseif app.unlock:checkLock("UNLOCK_METALCITY_HELP_4") then
				count = 2
			elseif app.unlock:checkLock("UNLOCK_METALCITY_HELP_2") then
				count = 1
			end
		end
	elseif index == 5 then
		if trailNum == 1 then
			if app.unlock:checkLock("UNLOCK_GOD_ARM_2_4") then
				count = 4
			elseif app.unlock:checkLock("UNLOCK_GOD_ARM_2_3") then
				count = 3
			elseif app.unlock:checkLock("UNLOCK_GOD_ARM_2_2") then
				count = 2
			elseif app.unlock:checkLock("UNLOCK_GOD_ARM_2_1") then
				count = 1
			end
		else
			if app.unlock:checkLock("UNLOCK_GOD_ARM_2_8") then
				count = 4
			elseif app.unlock:checkLock("UNLOCK_GOD_ARM_2_7") then
				count = 3
			elseif app.unlock:checkLock("UNLOCK_GOD_ARM_2_6") then
				count = 2
			elseif app.unlock:checkLock("UNLOCK_GOD_ARM_2_5") then
				count = 1
			end
		end		
	end

	return count
end

--获取战队的最大队伍数量
function QTeamMetalCity:getTeamMaxIndex()
	return 2
end

--生成默认阵容
function QTeamMetalCity:getDefaultTeam()
	local maxIndex = self:getTeamMaxIndex()
	local teamKey = self:getTeamKey()
	local otherTeamKey = remote.teamManager:getOtherTeamKey(teamKey)

	-- 另一个队伍的成员
	local otherTeamVO = remote.teamManager:getTeamByKey(otherTeamKey)
	local otherActorIds = {}
	local otherSpiritIds = {}
	local maxIndex = otherTeamVO:getTeamMaxIndex()
	for i = 1, maxIndex do
		local actorIds = otherTeamVO:getTeamActorsByIndex(i)
		for _, actorId in pairs(actorIds) do
			otherActorIds[actorId] = true
		end
		local spiritIds = otherTeamVO:getTeamActorsByIndex(i)
		for _, spiritId in pairs(spiritIds) do
			otherSpiritIds[spiritId] = true
		end
	end

	-- 剩余成员
	local haveActorIds = {}
	local haveSpiritIds = {}
	local allActorIds = self:getHeroWithOutIsHealth(1)
	local allSpiritIds = self:getAllSortSpiritIds()
	for _, actorId in ipairs(allActorIds) do
		if otherActorIds[actorId] == nil then
			haveActorIds[#haveActorIds+1] = actorId
		end
	end
	for _, spiritId in ipairs(allSpiritIds) do
		if otherSpiritIds[spiritId] == nil then
			haveSpiritIds[#haveSpiritIds+1] = spiritId
		end
	end

	-- 设置阵容
	local team = {}
   	local actorIdIndex = 1
   	local spiritIdIndex = 1
	for i = 1, maxIndex do
		-- 魂师
		local maxCount = self:getHerosMaxCountByIndex(i)
		local tbl = {}
		for j = 1, maxCount do
			if haveActorIds[actorIdIndex] then
				table.insert(tbl, haveActorIds[actorIdIndex])
				actorIdIndex = actorIdIndex + 1
			end
		end
		team[i] = {}
		team[i].actorIds = tbl
		team[i].skill = {tbl[1], tbl[2]}

		-- 魂灵
		local maxCount = self:getSpiritsMaxCountByIndex(i)
		local tbl = {}
		for j = 1, maxCount do
			if haveSpiritIds[spiritIdIndex] then
				table.insert(tbl, haveSpiritIds[spiritIdIndex])
				spiritIdIndex = spiritIdIndex + 1
			end
		end
		if i == 1 then
			team[i].spiritIds = tbl
		end
	end

	return team
end


--排序战队中的魂师
function QTeamMetalCity:sortTeam()
	local count = self:getTeamMaxIndex()
	for i = 1, count do
		local heros = self:getTeamActorsByIndex(i)
		if q.isEmpty(heros) == false then
			if i == 1 then
				remote.teamManager:sortTeam(heros)
			else
				remote.teamManager:sortTeamByForce(heros)
			end
		end
	end
end

function QTeamMetalCity:getHelpUnlockLevel(index)
	if index == nil then return 0 end
	
	local trailNum = self:getTeamNum()
	-- 第1队传入位置的奇数解锁
	-- 第2队传入位置的偶数解锁
	local unlockNum = index*2-1
	if trailNum == 2 then
		unlockNum = index*2
	end
	local unlockLevel = app.unlock:getConfigByKey("UNLOCK_METALCITY_HELP_"..unlockNum).team_level
	return unlockLevel
end


--检查战队中的魂师是否存在，不存在就删除掉
function QTeamMetalCity:checkTeamHero()
	local maxIndex = self:getTeamMaxIndex()
	for i=1,maxIndex do
		local maxCount = self:getHerosMaxCountByIndex(i)
		local actorIds = self:getTeamActorsByIndex(i)
		local skills = self:getTeamSkillByIndex(i)
		local isFindSkillAssistHeroId = false
		if q.isEmpty(actorIds) == false then
			local index = #actorIds
			while index > 0 do
				local actorId = actorIds[index]
				if q.isEmpty(remote.herosUtil:getHeroByID(actorId)) then
					table.remove(actorIds, index)
				end
				index = index - 1
			end
			self:setTeamActorsByIndex(i, actorIds)
		end
		if i == 1 then
			self:removeTeamSkillByIndex(i)
		else
			local newSkills = remote.teamManager:sortSubActorIds(actorIds, skills[1], skills[2])
			self:setTeamSkillByIndex(i, {newSkills[1], newSkills[2]})
		end
	end
end
return QTeamMetalCity
