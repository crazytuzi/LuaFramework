local QTeamNormal = class("QTeamNormal")
local QStaticDatabase = import("....controllers.QStaticDatabase")

function QTeamNormal:ctor(options)
	self.config = options.config
	self._team = {}
end

--获取是否防守阵容
function QTeamNormal:getIsDefense()
	return self.config.isSaveAtServer == true
end

--获取战队Key
function QTeamNormal:getTeamKey()
	return self.config.key
end

--获取是否防守阵容
function QTeamNormal:getIsPVP()
	return self.config.isPVP or false
end

--[[
	获取总的战队table对象
	team = {}
	team[1] = {}
	team[1].actorIds = {10001,10002} 战队的魂师队列
	team[1].assistActorIds = {10001,10002} 战队的援助魂师队列
	team[1].skill = {10001} 战队的技能队列
	team[1].spiritIds = {10001} 战队的精灵队列
]]
function QTeamNormal:getAllTeam()
	local maxIndex = self:getTeamMaxIndex()
	for i = 1, maxIndex do
		if self._team[i] == nil then
			self._team[i] = {}
		end
	end
	return self._team
end

--设置战队的数据
function QTeamNormal:setTeamData(teamData)
	self._team = clone(teamData) or {}
	self:sortTeam()
end

--设置战队的数据
function QTeamNormal:setTeamDataWithBattleFormation(battleFormation)
	self:setTeamActorsByIndex(1, battleFormation.mainHeroIds or {})
	self:setTeamActorsByIndex(2, battleFormation.sub1HeroIds or {})
	self:setTeamActorsByIndex(3, battleFormation.sub2HeroIds or {})
	self:setTeamActorsByIndex(4, battleFormation.sub3HeroIds or {})
	self:setTeamGodarmByIndex(5, battleFormation.godArmIdList or {})

	self:setTeamAlternatesByIndex(1, battleFormation.alternateHeroIds or {})
	self:setTeamAssistActorsByIndex(1, battleFormation.mainHelpHeroIds or {})
	self:setTeamAssistActorsByIndex(2, battleFormation.sub1HelpHeroIds or {})
	self:setTeamAssistActorsByIndex(3, battleFormation.sub2HelpHeroIds or {})
	self:setTeamAssistActorsByIndex(4, battleFormation.sub3HelpHeroIds or {})
	if battleFormation.activeSub1HeroId ~= nil then
		self:setTeamSkillByIndex(2, {battleFormation.activeSub1HeroId})
	else
		self:setTeamSkillByIndex(2, {})
	end
	if battleFormation.activeSub2HeroId ~= nil then
		self:setTeamSkillByIndex(3, {battleFormation.activeSub2HeroId})
	else
		self:setTeamSkillByIndex(3, {})
	end
	if battleFormation.activeSub3HeroId ~= nil then
		self:setTeamSkillByIndex(4, {battleFormation.activeSub3HeroId})
	else
		self:setTeamSkillByIndex(4, {})
	end
	if battleFormation.soulSpiritId ~= nil then
		self:setTeamSpiritsByIndex(1, battleFormation.soulSpiritId)
	else
		self:setTeamSpiritsByIndex(1, {})	
	end
	self:checkTeam()
end

--获取战队的魂师对象通过Index
function QTeamNormal:getTeamActorsByIndex(index)
	if self._team[index] ~= nil then
		return self._team[index].actorIds or {}
	end
	return {}
end

--设置战队的魂师通过Index
function QTeamNormal:setTeamActorsByIndex(index, actorIds)
	if self._team[index] == nil then
		self._team[index] = {}
	end
	self._team[index].actorIds = actorIds or {}
	self:sortTeamByIndex(index)
end

--获取战队的精灵对象通过Index
function QTeamNormal:getTeamSpiritsByIndex(index)
	if self._team[index] ~= nil then
		return self._team[index].spiritIds or {}
	end
	return {}
end

--设置战队的精灵通过index
function QTeamNormal:setTeamSpiritsByIndex(index, spiritIds)
	if self._team[index] == nil then
		self._team[index] = {}
	end
	self._team[index].spiritIds = spiritIds or {}
end

--获取战队的神器对象通过Index
function QTeamNormal:getTeamGodarmByIndex(index)
	if self._team[index] ~= nil then
		return self._team[index].godarmIds or {}
	end
	return {}
end

--设置战队的神器通过index
function QTeamNormal:setTeamGodarmByIndex(index, godarmIds)
	if self._team[index] == nil then
		self._team[index] = {}
	end
	self._team[index].godarmIds = godarmIds or {}
end

--获取战队的替补对象通过Index
function QTeamNormal:getTeamAlternatesByIndex(index)
	if self._team[index] ~= nil then
		return self._team[index].alternateIds or {}
	end
	return {}
end
--获取战队的主力包括替补对象通过Index
function QTeamNormal:getTeamMianAndAlternatesByIndex(index)
	local actorIds = {}
	if self._team[index] ~= nil and next(self._team[index].actorIds) then
		for _,v in pairs(self._team[index].actorIds) do
			table.insert(actorIds,v)
		end
	end
	if self._team[index] ~= nil and next(self._team[index].alternateIds) ~= nil then
		for _,v in pairs(self._team[index].alternateIds) do
			table.insert(actorIds,v)
		end
	end
	return actorIds
end

--设置战队的替补通过index
function QTeamNormal:setTeamAlternatesByIndex(index, alternateIds)
	if self._team[index] == nil then
		self._team[index] = {}
	end
	self._team[index].alternateIds = alternateIds or {}
end

--获取战队的援助魂师对象通过Index
function QTeamNormal:getTeamAssistActorsByIndex(index)
	if self._team[index] ~= nil then
		return self._team[index].assistActorIds or {}
	end
	return {}
end

--获取战队的援助魂师对象通过Index
function QTeamNormal:setTeamAssistActorsByIndex(index, actorIds)
	if self._team[index] == nil then
		self._team[index] = {}
	end
	self._team[index].assistActorIds = actorIds or {}
end

--获取战队的技能对象通过Index
function QTeamNormal:getTeamSkillByIndex(index)
	if self._team[index] ~= nil then
		return self._team[index].skill or {}
	end
	return {}
end

--设置战队的技能
function QTeamNormal:setTeamSkillByIndex(index, skill)
	if self._team[index] == nil then
		self._team[index] = {}
	end
	self._team[index].skill = skill or {}
end

--移除战队的技能
function QTeamNormal:removeTeamSkillByIndex(index)
	if self._team[index] == nil or self._team[index].skill == nil then return end
	self._team[index].skill = nil
end

--解锁阵容的提示
function QTeamNormal:getHeroLockStrByData(trialNum , index  ,pos)
	
	return "未解锁"
end

function QTeamNormal:getHeroLockTipsByData(trialNum , index  ,pos)

end

function QTeamNormal:getHerosMaxCountBytrialNumAndIndex(trialNum,index)
	return self:getHerosMaxCountByIndex(index)
end


--根据战队序号获取解锁的魂师最大位置
function QTeamNormal:getHerosMaxCountByIndex(index)
	local count = 0
	if index == 1 then
		count = 2
		if app.unlock:getUnlockTeam4() then
			count = 4
		elseif app.unlock:getUnlockTeam3() then
			count = 3
		end
	elseif index == 2 then
		if app.unlock:getUnlockTeamHelp4() then
			count = 4
		elseif app.unlock:getUnlockTeamHelp3() then
			count = 3
		elseif app.unlock:getUnlockTeamHelp2() then
			count = 2
		elseif app.unlock:getUnlockTeamHelp1() then
			count = 1
		end
	elseif index == 3 then
		if app.unlock:getUnlockTeamHelp8() then
			count = 4
		elseif app.unlock:getUnlockTeamHelp7() then
			count = 3
		elseif app.unlock:getUnlockTeamHelp6() then
			count = 2
		elseif app.unlock:getUnlockTeamHelp5() then
			count = 1
		end
	elseif index == 4 then
		if app.unlock:getUnlockTeamHelp12() then
			count = 4
		elseif app.unlock:getUnlockTeamHelp11() then
			count = 3
		elseif app.unlock:getUnlockTeamHelp10() then
			count = 2
		elseif app.unlock:getUnlockTeamHelp9() then
			count = 1
		end
	elseif index == 5 then
		if app.unlock:getUnlockTeamGodarmHelp4() then
			count = 4
		elseif app.unlock:getUnlockTeamGodarmHelp3() then
			count = 3
		elseif app.unlock:getUnlockTeamGodarmHelp2() then
			count = 2
		elseif app.unlock:getUnlockTeamGodarmHelp1() then
			count = 1
		end
	end
	return count
end
 
--根据战队序号获取解锁的精灵最大位置
function QTeamNormal:getSpiritsMaxCountByIndex(index,isMockTeam)
	if app.unlock:checkLock("UNLOCK_SOUL_SPIRIT", false) == false then
		return 0
	end
	if isMockTeam then
		return 1
	else
		if index == 1 then
			local isTeamType = self:getTeamType()
			return remote.soulSpirit:getTeamSpiritsMaxCount(isTeamType==2)
		else
			return 0
		end
	end
end

--根据战队序号获取解锁的替补最大位置
function QTeamNormal:getAlternateMaxCountByIndex(index)
	if index == 1 then
		return 3
	else
		return 0
	end
end

--根据战队序号获取解锁的援助魂师的最大位置
function QTeamNormal:getAssistHeroMaxCountByIndex(index)
	return 0
end

--检查一个战队中某个小队是否满员
function QTeamNormal:checkTeamIsFullByIndex(index)
	local actorIds = self:getTeamActorsByIndex(index)
	local maxCount = self:getHerosMaxCountByIndex(index)
	return #actorIds >= maxCount
end

--检查一个战队中某个小队的精灵是否满员
function QTeamNormal:checkSpiritIsFullByIndex(index)
	local spiritIds = self:getTeamSpiritsByIndex(index)
	local maxCount = self:getSpiritsMaxCountByIndex(index)
	return #spiritIds >= maxCount
end

--检查一个战队中某个小队的替补是否满员
function QTeamNormal:checkAlternateIsFullByIndex(index)
	return true
end

--获取战队的最大队伍数量
function QTeamNormal:getTeamMaxIndex()
	return 4
end

--添加某个魂师到指定的魂师队列中
function QTeamNormal:addHeroByIndex(index, actorId)
	if index == nil or actorId == nil then return false end
	local actorIds = self:getTeamActorsByIndex(index)
	if q.isEmpty(actorIds) == false then
		local maxIndex = self:getHerosMaxCountByIndex(index)
		if #actorIds >= maxIndex then
			return false
		end
	else
		actorIds = {}
	end
	table.insert(actorIds, actorId)
	self:setTeamActorsByIndex(index, actorIds)
	return true
end

--删除某个魂师从战队的指定小队中
function QTeamNormal:delHeroByIndex(index, actorId)
	if index == nil or actorId == nil then return end
	local actorIds = self:getTeamActorsByIndex(index)
	if q.isEmpty(actorIds) == false then
		for i,v in ipairs(actorIds) do
			if v == actorId then
				table.remove(actorIds,i)
				return 
			end
		end
		self:setTeamActorsByIndex(index, actorIds)
	end
end

--添加某个魂师到指定的魂师替补中
function QTeamNormal:addAlternateByIndex(index, actorId)
	if index == nil or actorId == nil then return false end
	local alternateIds = self:getTeamAlternatesByIndex(index)
	if q.isEmpty(alternateIds) == false then
		local maxIndex = self:getAlternateMaxCountByIndex(index)
		if #alternateIds >= maxIndex then
			return false
		end
	else
		alternateIds = {}
	end
	table.insert(alternateIds, actorId)
	self:setTeamAlternatesByIndex(index, alternateIds)
	return true
end

--删除某个魂师从战队的指定替补中
function QTeamNormal:delAlternateByIndex(index, actorId)
	if index == nil or actorId == nil then return end
	local alternateIds = self:getTeamAlternatesByIndex(index)
	if q.isEmpty(alternateIds) == false then
		for i,v in ipairs(alternateIds) do
			if v == actorId then
				table.remove(alternateIds,i)
				return 
			end	
		end
		self:setTeamAlternatesByIndex(index, alternateIds)
	end
end

--删除某个精灵从战队的指定小队中
function QTeamNormal:delSpiritByIndex(index, soulSpiritId)
	if index == nil or soulSpiritId == nil then return end
	local spiritIds = self:getTeamSpiritsByIndex(index)
	if q.isEmpty(spiritIds) == false then
		for i,v in ipairs(spiritIds) do
			if v == soulSpiritId then
				table.remove(spiritIds,i)
				break
			end
		end
		self:setTeamSpiritsByIndex(index, spiritIds)
	end
end

--删除某个神器从战队的指定小队中
function QTeamNormal:delGodarmsIndex(index, godarmId)
	if index == nil or godarmId == nil then return end
	local godarmIds = self:getTeamGodarmByIndex(index)
	if q.isEmpty(godarmIds) == false then
		for i,v in ipairs(godarmIds) do
			if v == godarmId then
				table.remove(godarmIds,i)
				break
			end
		end
		self:setTeamGodarmByIndex(index, godarmIds)
	end
end

--添加某个魂师到指定的援助魂师队列中
function QTeamNormal:addAssistHeroByIndex(index, actorId)
	if index == nil or actorId == nil then return false end
	local actorIds = self:getTeamAssistActorsByIndex(index)
	if q.isEmpty(actorIds) == false then
		local maxIndex = self:getAssistHeroMaxCountByIndex(index)
		if #actorIds >= maxIndex then
			return false
		end
	else
		actorIds = {}
	end
	table.insert(actorIds, actorId)
	self:setTeamAssistActorsByIndex(index, actorIds)
	return true
end

--删除某个魂师从战队的援助魂师小队中
function QTeamNormal:delAssistHeroByIndex(index, actorId)
	if index == nil or actorId == nil then return end
	local actorIds = self:getTeamAssistActorsByIndex(index)
	if q.isEmpty(actorIds) == false then
		for i,v in ipairs(actorIds) do
			if v == actorId then
				table.remove(actorIds,i)
				return 
			end
		end
		self:setTeamAssistActorsByIndex(index, actorIds)
	end
end

--检查战队
function QTeamNormal:checkTeam()
	self:checkTeamHero()
	self:checkTeamSpirit()
	self:checkTeamAlternate()
	self:checkTeamGodarm()
end

--检查战队中的精灵是否存在，不存在就删除掉
function QTeamNormal:checkTeamSpirit()
	local maxIndex = self:getTeamMaxIndex()
	for i=1,maxIndex do
		local maxCount = self:getSpiritsMaxCountByIndex(i)
		local spiritIds = self:getTeamSpiritsByIndex(i)
		if q.isEmpty(spiritIds) == false then
			local index = 1
			local totalCount = #spiritIds
			while index <= totalCount do
				local spiritId = spiritIds[index]
				if q.isEmpty(remote.soulSpirit:getMySoulSpiritInfoById(spiritId)) == false and index <= maxCount then
					index = index + 1
				else
					table.remove(spiritIds, index)
					totalCount = totalCount - 1
				end
			end
			self:setTeamSpiritsByIndex(i, spiritIds)
		end
	end
end

--检查战队中的精灵是否存在，不存在就删除掉
function QTeamNormal:checkTeamGodarm()
	local godarmIds = self:getTeamGodarmByIndex(remote.teamManager.TEAM_INDEX_GODARM)
	if q.isEmpty(godarmIds) == false then
        for _, godarmId in ipairs(godarmIds) do
            local godarmInfo = remote.godarm:getGodarmById(godarmId) or {}
            if q.isEmpty(godarmInfo) then
                self:delGodarmsIndex(remote.teamManager.TEAM_INDEX_GODARM, godarmId)
            end
        end		
	end

end

--检查战队中的替补是否存在，不存在就删除掉
function QTeamNormal:checkTeamAlternate()
	local maxIndex = self:getTeamMaxIndex()
	for i = 1, maxIndex do
		local maxCount = self:getAlternateMaxCountByIndex(i)
		local alternateIds = self:getTeamAlternatesByIndex(i)
		if q.isEmpty(alternateIds) == false then
			local index = 1
			local totalCount = #alternateIds
			while index <= totalCount do
				local alternateId = alternateIds[index]
				if q.isEmpty(remote.herosUtil:getHeroByID(alternateId)) == false and index <= maxCount then
					index = index + 1
				else
					table.remove(alternateIds, index)
					totalCount = totalCount - 1
				end
			end
			self:setTeamAlternatesByIndex(i, alternateIds)
		end
	end
end

--检查战队中的魂师是否存在，不存在就删除掉
function QTeamNormal:checkTeamHero()
	local maxIndex = self:getTeamMaxIndex()
	for i=1,maxIndex do
		local maxCount = self:getHerosMaxCountByIndex(i)
		local actorIds = self:getTeamActorsByIndex(i)
		local skillHeroId = self:getTeamSkillByIndex(i)[1]
		local isFindSkillHeroId = false
		local isFindSkillAssistHeroId = false
		if q.isEmpty(actorIds) == false then
			local index = 1
			local totalCount = #actorIds
			while index <= totalCount do
				local actorId = actorIds[index]
				if q.isEmpty(remote.herosUtil:getHeroByID(actorId)) == false and index <= maxCount then
					index = index + 1
				else
					table.remove(actorIds, index)
					totalCount = totalCount - 1
				end
				if skillHeroId == actorId then
					isFindSkillHeroId = true
				end
			end
			self:setTeamActorsByIndex(i, actorIds)
			if not isFindSkillHeroId or not skillHeroId then
				self:setTeamSkillByIndex(i, {actorIds[1]})
			end
		end

		local maxCount = self:getAssistHeroMaxCountByIndex(i)
		local assistActorIds = self:getTeamAssistActorsByIndex(i)
		if q.isEmpty(assistActorIds) == false then
			local index = 1
			local totalCount = #assistActorIds
			while index <= totalCount do
				local actorId = assistActorIds[index]
				if q.isEmpty(remote.herosUtil:getHeroByID(actorId)) == false and index <= maxCount then
					index = index + 1
				else
					table.remove(assistActorIds, index)
					totalCount = totalCount - 1
				end
				if skillHeroId == actorId then
					isFindSkillAssistHeroId = true
				end
			end
			self:setTeamAssistActorsByIndex(i, assistActorIds)
			if not isFindSkillAssistHeroId or not skillHeroId then
				self:setTeamSkillByIndex(i, {assistActorIds[1]})
			end
		end

		if i == 1 then
			self:removeTeamSkillByIndex(i)
		end
	end
end

--排序战队中的魂师
function QTeamNormal:sortTeamByIndex(index)
	local heros = self:getTeamActorsByIndex(index)
	if q.isEmpty(heros) == false then
		remote.teamManager:sortTeam(heros)
	end
end

--排序战队中的魂师
function QTeamNormal:sortTeam()
	local count = self:getTeamMaxIndex()
	for i=1,count do
		local heros = self:getTeamActorsByIndex(i)
		if q.isEmpty(heros) == false then
			remote.teamManager:sortTeam(heros)
		end
	end
end

--计算本战队的所有战力
function QTeamNormal:getTeamBattleForce(islocal)
	local force = 0
	local maxCount = self:getTeamMaxIndex()
	for i=1, maxCount do
		force = force + remote.herosUtil:countForceByHeros(self:getTeamActorsByIndex(i), islocal) 
		force = force + remote.herosUtil:countForceByHeros(self:getTeamAlternatesByIndex(i), islocal) 
		force = force + remote.herosUtil:countForceByHeros(self:getTeamAssistActorsByIndex(i), islocal) 
		force = force + remote.soulSpirit:countForceBySpiritIds(self:getTeamSpiritsByIndex(i), islocal)
	end

	force = force + remote.godarm:countForceByGodarmIds(self:getTeamGodarmByIndex(remote.teamManager.TEAM_INDEX_GODARM),islocal)

	return force
end

--查询是否包含某个魂师
function QTeamNormal:contains(actorId)
	local maxCount = self:getTeamMaxIndex()
	for i=1,maxCount do
		if self:containsByIndex(actorId, i) then
			return true
		end
	end
	return false
end

--查询是否包含某个魂师
function QTeamNormal:containsByIndex(actorId, index)
	if index == nil then index = 1 end
	local actorIds = self:getTeamActorsByIndex(index)
	for _,v in ipairs(actorIds) do
		if v == actorId then
			return true
		end
	end
	local alternateIds = self:getTeamAlternatesByIndex(index)
	for _,v in ipairs(alternateIds) do
		if v == actorId then
			return true
		end
	end
	local assistActorIds = self:getTeamAssistActorsByIndex(index)
	for _,v in ipairs(assistActorIds) do
		if v == actorId then
			return true
		end
	end
	return false
end

--查询是否包含某个精灵
function QTeamNormal:containsSpirit(spiritId)
	local maxCount = self:getTeamMaxIndex()
	for i=1,maxCount do
		if self:containsSpiritByIndex(spiritId, i) then
			return true
		end
	end
	return false
end

--查询是否包含某个魂灵
function QTeamNormal:containsSpiritByIndex(spiritId, index)
	if index == nil then index = 1 end
	local spiritIds = self:getTeamSpiritsByIndex(index)
	if not q.isEmpty(spiritIds) then
		for _,v in ipairs(spiritIds) do
			if v == spiritId then
				return true
			end
		end
	end
	return false
end

--生成默认的阵容
function QTeamNormal:getDefaultTeam()
	local maxIndex = self:getTeamMaxIndex()
    local haveActorIds = self:getHeroWithOutIsHealth(1)
    local haveSpiritIds = self:getAllSortSpiritIds()
    
	local team = {}
   	local actorIdIndex = 1
   	local spiritIdIndex = 1
	for i = 1, maxIndex do
		team[i] = {}
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
		team[i].skill = {tbl[1]}

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

--获取已经有的魂师,传入一个位置，该位置之前的不会是治疗
function QTeamNormal:getHeroWithOutIsHealth(pos)
	local heros = remote.herosUtil:getHaveHero()
	table.sort(heros, handler(self, self._sortTeam))
	if pos > 0 then
		local fun = function (indexA, indexB)
			local configA = QStaticDatabase:sharedDatabase():getCharacterByID(heros[indexA])
			local configB = QStaticDatabase:sharedDatabase():getCharacterByID(heros[indexB])
			if configA.func ~= "health" then
				return true
			elseif configA.func == "health" and configB.func ~= "health" then
				local actorId = heros[indexA]
				heros[indexA] = heros[indexB]
				heros[indexB] = actorId
				return true
			end
			return false
		end
		local totalCount = #heros
		for i=1,pos do
			local offset = 1
			while true do
				if i < totalCount and (i+offset) <= totalCount then
					if fun(i,i+offset) then
						break
					else
						offset = offset + 1
					end
				else
					break
				end
			end
		end
	end
	return heros
end

--获取援助技能最大值
function QTeamNormal:getTeamHelpSkillMaxNumByIndex(_index)
	local count = 0
	if index == remote.teamManager.TEAM_INDEX_SKILL then
		count = 1
	elseif index == remote.teamManager.TEAM_INDEX_SKILL2 then
		count = 1
	elseif index == remote.teamManager.TEAM_INDEX_SKILL3 then
		count = 1
	end
	return count
end


-- 魂灵id集合 战力排序
function QTeamNormal:getAllSortSpiritIds()
	local soulSpirits = remote.soulSpirit:getMySoulSpiritInfoList()
	table.sort(soulSpirits, function(a, b)
		local characherA = db:getCharacterByID(a.id)
		local characherB = db:getCharacterByID(a.id)
		if characherA.aptitude ~= characherB.aptitude then
			return characherA.aptitude > characherB.aptitude
		elseif a.grade ~= a.grade then
			return a.grade > b.grade
		elseif a.level ~= b.level then
			return a.level > b.level
		else
			return a.id > b.id
		end
	end)

	local spiritIds = {}
	for _, soulSpirit in pairs(soulSpirits) do
		table.insert(spiritIds, soulSpirit.id)
	end
	return spiritIds
end

--治疗放到后面
function QTeamNormal:_sortTeam(a,b)
	local heroA = remote.herosUtil:getHeroByID(a)
	local heroB = remote.herosUtil:getHeroByID(b)
	if heroA.force ~= heroB.force then
		return heroA.force > heroB.force
	end
	return heroA.actorId < heroB.actorId
end

--获取战队队伍编号
function QTeamNormal:getTeamNum()
	if self.config and self.config.teamNum then
		return self.config.teamNum
	else
		return 1
	end
end

--获取战队队伍类型
function QTeamNormal:getTeamType()
	if self.config and self.config.teamTypeNum then
		return self.config.teamTypeNum
	else
		return 1
	end
end
return QTeamNormal