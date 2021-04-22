local QTeamNormal = import(".QTeamNormal")
local QTeamMetalAbyss = class("QTeamMetalAbyss", QTeamNormal)
local QTeamManager = import("..network.models.QTeamManager")

function QTeamMetalAbyss:ctor(options)
	QTeamMetalAbyss.super.ctor(self, options)
end

--设置战队的数据
function QTeamMetalAbyss:setTeamDataWithBattleFormation(battleFormation)
	self:setTeamActorsByIndex(1, battleFormation.mainHeroIds or {})
	self:setTeamSpiritsByIndex(1, battleFormation.soulSpiritId or {})	
	self:setTeamActorsByIndex(2, battleFormation.sub1HeroIds or {})
	self:setTeamGodarmByIndex(5, battleFormation.godArmIdList or {})
	local skill = {}
	skill[1] = battleFormation.activeSub1HeroId
	skill[2] = battleFormation.activeSub2HeroId
	self:setTeamSkillByIndex(2, skill)
	self:checkTeam()
end

--根据战队序号获取解锁的魂师最大位置
function QTeamMetalAbyss:getHerosMaxCountByIndex(index)
	local trailNum = self:getTeamNum()
	local count = 0
	if index == remote.teamManager.TEAM_INDEX_MAIN then
		count = 4
	elseif index == remote.teamManager.TEAM_INDEX_HELP then
		count = 2
	elseif index == remote.teamManager.TEAM_INDEX_GODARM then
		count = 3
	end
	return count
end

function QTeamMetalAbyss:getHerosMaxCountBytrialNumAndIndex(trialNum,index)

	local result = 0
	if index == remote.teamManager.TEAM_INDEX_HELP then
		for i=1,2 do
			local num = trialNum + (i - 1) * 3
			local lock = "UNLOCK_ABYSS_HELP_"..num
    		if app.unlock:checkLock(lock, false)  then
        		result = result + 1
    		end
		end
		return result
	end
	return self:getHerosMaxCountByIndex(index)
end


function QTeamMetalAbyss:getHeroLockStrByData(trialNum , index ,pos)
	
	if pos <= 2 then
		local num = trialNum + (pos - 1) * 3
		local config = app.unlock:getConfigByKey("UNLOCK_ABYSS_HELP_"..num)
		if config then
			return config.description or "敬请期待"
		end
	end

	return "敬请期待"
end

function QTeamMetalAbyss:getHeroLockTipsByData(trialNum , index  ,pos)

	if pos <= 2 then
		local num = trialNum + (pos - 1) * 3
		local config = app.unlock:getConfigByKey("UNLOCK_ABYSS_HELP_"..num)
		if config then
			app.unlock:checkLock("UNLOCK_ABYSS_HELP_"..num, true)
			return
		end
	end
	return
end

--获取战队的最大队伍数量
function QTeamMetalAbyss:getTeamMaxIndex()
	return 2
end

function QTeamMetalAbyss:getTeamHelpSkillMaxNumByIndex(_index)
	local count = 0
	if _index == remote.teamManager.TEAM_INDEX_SKILL then
		if self.config.key == remote.teamManager.METAL_ABYSS_TEAM1 then
			count = 2
		elseif self.config.key == remote.teamManager.METAL_ABYSS_TEAM2 then
			count = 2
		elseif self.config.key == remote.teamManager.METAL_ABYSS_TEAM3 then
			count = 2
		end
	elseif _index == remote.teamManager.TEAM_INDEX_SKILL2 then
	elseif _index == remote.teamManager.TEAM_INDEX_SKILL3 then
	end

	return count
end


--生成默认阵容
function QTeamMetalAbyss:getDefaultTeam()
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
function QTeamMetalAbyss:sortTeam()
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

function QTeamMetalAbyss:getHelpUnlockLevel(index)
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
function QTeamMetalAbyss:checkTeamHero()
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


return QTeamMetalAbyss