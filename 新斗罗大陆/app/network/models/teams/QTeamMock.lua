
-- @Author: qinsiyang
-- @大师阵容

local QTeamNormal = import(".QTeamNormal")
local QTeamMock = class("QTeamMock", QTeamNormal)
local QStaticDatabase = import("....controllers.QStaticDatabase")

function QTeamMock:ctor(options)
	QTeamMock.super.ctor(self, options)
end

--
function QTeamMock:getHerosMaxCountByIndex(index)
	return 4
end
function QTeamMock:getSoulSpriteMaxCountByIndex(index)
	return 1
end
--
function QTeamMock:getHerosGodArmMaxCountByIndex(index)
	return 2
end
--设置战队的数据

function QTeamMock:initBattleFormation(teamIdx)
	teamIdx = teamIdx and teamIdx or 1

	local battleFormation = remote.mockbattle:getMockBattleBattleFormation(teamIdx)
	self:setMockTeamDataWithBattleFormation(battleFormation,teamIdx)
end

function QTeamMock:setMockTeamDataWithBattleFormation(battleFormation,teamIdx)
	teamIdx = teamIdx and teamIdx or 1

	local offside = (teamIdx - 1) * 100

	self:setTeamMountsByIndex(1 + offside, battleFormation.wearInfo or {}, battleFormation.mainHeroIds  or {})
	self:setTeamActorsByIndex(1 + offside, battleFormation.mainHeroIds or {})
	self:setTeamActorsByIndex(2 + offside, battleFormation.sub1HeroIds or {})
	self:setTeamActorsByIndex(3 + offside, battleFormation.sub2HeroIds or {})

	local skill = {}
	skill[1] = battleFormation.activeSub1HeroId
	skill[2] = battleFormation.activeSub2HeroId
	skill[3] = battleFormation.activeSub3HeroId
	self:setTeamSkillByIndex(2 + offside, skill)

	local soulSpiritId = battleFormation.soulSpiritId or 0
	self:setTeamSpiritsByIndex(1 + offside, {soulSpiritId})	

	self:setTeamGodarmByIndex(5 + offside, battleFormation.godArmIdList or {})
	self:sortTeamByTeamIndex(teamIdx)
end

--获取战队的暗器对象通过Index
function QTeamMock:getTeamMountsByIndexAndTeamIdx(index ,teamIdx)
	teamIdx = teamIdx and teamIdx or 1
	local offside = (teamIdx - 1) * 100
	if self._team[index + offside] ~= nil then
		return self._team[index + offside].mountIds or {}
	end
	return {}
end


function QTeamMock:getTeamGodarmByIndexAndTeamIdx(index ,teamIdx)
	teamIdx = teamIdx and teamIdx or 1
	local offside = (teamIdx - 1) * 100
	if self._team[index + offside] ~= nil then
		return self._team[index + offside].godarmIds or {}
	end
	return {}
end


function QTeamMock:getTeamSpiritsByIndexAndTeamIdx(index ,teamIdx)
	teamIdx = teamIdx and teamIdx or 1
	local offside = (teamIdx - 1) * 100

	return self:getTeamSpiritsByIndex(index + offside)

end


--设置战队的暗器通过index
function QTeamMock:setTeamMountsByIndex(index, wearInfo ,heros)
	if self._team[index] == nil then
		self._team[index] = {}
	end
	local mountIds = {}
	for _, info in pairs(wearInfo) do
		for i,v in pairs(heros) do
			if v == info.actorId then
				mountIds[i]=info.zuoqiId
			end
		end
	end
	self._team[index].mountIds = mountIds
end

function QTeamMock:setTeamMountsListByIndex(index,mountIds)
	if self._team[index] == nil then
		self._team[index] = {}
	end
	self._team[index].mountIds = mountIds
end


function QTeamMock:getTeamActorsByIndexAndTeamIdx(index,teamIdx)
	teamIdx = teamIdx and teamIdx or 1
	local offside = (teamIdx - 1) * 100
	if self._team[index + offside] ~= nil then
		local ids = self._team[index + offside].actorIds or {}
		self:sortTeam(ids)
		return ids or {}
	end
	return {}
end


--检查一个战队中某个小队的精灵是否满员
function QTeamMock:checkAlternateIsFullByIndex(index,teamIdx)
	local alternateIds = self:getTeamAlternatesByIndex(index)
	local maxCount = self:getAlternateMaxCountByIndex(index)
	return #alternateIds >= maxCount
end

--获取战队的最大队伍数量
function QTeamMock:getTeamMaxIndex()
	return 2
end

function QTeamMock:getDefaultTeam()
	return team
end

--排序战队中的魂师
function QTeamMock:sortTeamByTeamIndex(teamIdx)
	teamIdx = teamIdx and teamIdx or 1
	local count = self:getTeamMaxIndex()
	for i = 1, count do
		local heros = self:getTeamActorsByIndexAndTeamIdx(i,teamIdx)
		if q.isEmpty(heros) == false then
			self:sortTeam(heros)
		end
	end
end

function QTeamMock:getHelpUnlockLevel(index)
	if index == nil then return 0 end
	local unlockLevel = 0
	return unlockLevel
end

--检查战队中的魂师是否存在，不存在就删除掉
function QTeamMock:checkTeamHero()
	-- local maxIndex = self:getTeamMaxIndex()
	-- for i=1,maxIndex do
	-- 	local actorIds = self:getTeamActorsByIndex(i)
	-- 	if q.isEmpty(actorIds) == false then
	-- 		local index = #actorIds
	-- 		while index > 0 do
	-- 			local actorId = actorIds[index]
	-- 			if q.isEmpty(remote.herosUtil:getHeroByID(actorId)) then
	-- 				table.remove(actorIds, index)
	-- 			end
	-- 			index = index - 1
	-- 		end
	-- 		self:setTeamActorsByIndex(i, actorIds)
	-- 	end
	-- end
end


function QTeamMock:sortTeam(Ids)
	if not Ids or not next(Ids) then
		return 
	end
	local availableHero={}
	for i, id in pairs(Ids) do
		local hero_info = remote.mockbattle:getCardInfoByIndex(id)
		local characher = QStaticDatabase:sharedDatabase():getCharacterByID(hero_info.actorId)

		local heroType = 1
		local hatred = characher.hatred
		if characher.func == 't' then
			heroType = 't'
		elseif characher.func == 'health' then
			heroType = 'h'
		elseif characher.func == 'dps' and characher.attack_type == 1 then
			heroType = 'pd'
		elseif characher.func == 'dps' and characher.attack_type == 2 then
			heroType = 'md'
		end
		local force  = 0
		if hero_info then
			force = hero_info.force
		end
		availableHero[id] = { hatred = hatred,  force = force}
	end


	table.sort(Ids, function (x, y)
		if availableHero[x].hatred == availableHero[y].hatred then
			return availableHero[x].force < availableHero[y].force
		end
		return availableHero[x].hatred < availableHero[y].hatred
	end )
	QPrintTable(Ids)

end


function QTeamMock:sortTeamByHeroId(heros)
	if not heros or not next(heros) then
		return 
	end
	--QPrintTable(heros)

	local availableHero={}
	for i, actorId in pairs(heros) do
		local hero_info = remote.mockbattle:getCardInfoById(actorId)
		local characher = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)

		local heroType = 1
		local hatred = characher.hatred
		if characher.func == 't' then
			heroType = 't'
		elseif characher.func == 'health' then
			heroType = 'h'
		elseif characher.func == 'dps' and characher.attack_type == 1 then
			heroType = 'pd'
		elseif characher.func == 'dps' and characher.attack_type == 2 then
			heroType = 'md'
		end
		local force  = 0
		if hero_info then
			force = hero_info.force
		end
		availableHero[actorId] = { hatred = hatred,  force = force}
	end
	table.sort(heros, function (x, y)
		if availableHero[x].hatred == availableHero[y].hatred then
			return availableHero[x].force > availableHero[y].force
		end
		return availableHero[x].hatred > availableHero[y].hatred
	end )
end



return QTeamMock