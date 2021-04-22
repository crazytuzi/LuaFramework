-- @Author: xurui
-- @Date:   2018-08-09 15:10:37
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-01-13 15:28:10
local QUIWidgetHeroBattleArray = import("..widgets.QUIWidgetHeroBattleArray")
local QUIWidgetMetalCityHeroBattleArray = class("QUIWidgetMetalCityHeroBattleArray", QUIWidgetHeroBattleArray)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

function QUIWidgetMetalCityHeroBattleArray:ctor(options)
    QUIWidgetMetalCityHeroBattleArray.super.ctor(self, options)

    self._trialNum = options.trialNum
end

function QUIWidgetMetalCityHeroBattleArray:onEnter()
    QUIWidgetMetalCityHeroBattleArray.super.onEnter(self)

	self._ccbOwner.node_helper:setVisible(true)
	self._ccbOwner.node_helper2:setVisible(false)
	self._ccbOwner.node_helper3:setVisible(false)

	self._ccbOwner.btn_helper:setVisible(true)
	self._ccbOwner.btn_helper1:setVisible(false)
	if app.unlock:getUnlockGodarm(false) then
		self._ccbOwner.node_godarm:setVisible(true)
		self._ccbOwner.node_godarm:setPositionX(self._ccbOwner.node_helper2:getPositionX())
	else
		self._ccbOwner.node_godarm:setVisible(false)
	end	
end

function QUIWidgetMetalCityHeroBattleArray:updateArrangement(param)
	print("两小队----:updateArrangement-----------")
    self._heroList = param.heroList
    self._soulSpiritList = param.soulSpiritList
    self._godarmList = param.godarmList or {}
    self._arrangement = param.arrangement
	self._unlockNumber = param and (param.unlockNumber or 4) or 4
	self._selectedNumber = 0
	self._selectTeamIndex = 0
    self._trialNum = param.trialNum
		
	self:onTriggerMain()
	if self._currentButtonName == "soul" then
    	self:selectButton("all")
		self._selectConfig.updateFun()
	end
end

function QUIWidgetMetalCityHeroBattleArray:_onIconClick(event)
	if self._isMoving then return end

	local victoryId = nil 
	local hero = nil
	for k, v in pairs(self._heroList) do
		if v.actorId == event.actorId then
			if v.index == 0 then
				if self._selectedNumber >= self._unlockNumber then
					app.tip:floatTip(QUIWidgetHeroBattleArray.HERO_FULL) 
					return
				end
				victoryId = v.actorId
				v.index = self._selectTeamIndex
				v.trialNum = self._trialNum
				if self._selectTeamIndex == remote.teamManager.TEAM_INDEX_HELP then
					remote.teamManager:updateHeroOrder(v.trialNum, v.actorId, true)
				end
			else
				remote.teamManager:updateHeroOrder(v.trialNum, v.actorId, false)
				v.index = 0
				v.trialNum = nil
				v.helpIndex = 0
			end
			hero = v
			break
		end
	end
	self:_updateHero(victoryId, hero)
	self:_checkTips()
end

function QUIWidgetMetalCityHeroBattleArray:_onSoulIconClick(event)
	local victoryId = nil
	local hero = nil
	local selectIndex = self:getSelectIndex()
	local currentSelect = 0
	for k, v in pairs(self._soulSpiritList) do
		if v.index == selectIndex and v.trialNum == self._trialNum then
			currentSelect = currentSelect + 1
		end
	end

	for k, v in pairs(self._soulSpiritList) do
		if v.soulSpiritId == event.soulSpiritId then
			if v.index == 0 then
				local teamKey = self._arrangement:getTeamKey()
				local teamVO = remote.teamManager:getTeamByKey(teamKey)
				if currentSelect >= teamVO:getSpiritsMaxCountByIndex(selectIndex) then
					app.tip:floatTip(QUIWidgetHeroBattleArray.SOUL_FULL) 
					return
				end
				victoryId = v.soulSpiritId
				v.index = self._selectTeamIndex
				v.trialNum = self._trialNum
				v.pos = currentSelect + 1
			else
				v.trialNum = nil
				v.index = 0
				v.pos = 5
			end
			hero = v
			break
		end
	end

	self:_updateSoulSpirit(victoryId, hero)
	self:_checkTips()
end

function QUIWidgetMetalCityHeroBattleArray:_onGodarmIconClick( event )
	local victoryId = nil
	local hero = nil
	local selectIndex = self:getSelectIndex()
	local characherCOnfig  = db:getCharacterByID(event.godarmId)
	local currentSelect = 0
	local samelabelNum = 0	
	for k, v in pairs(self._godarmList) do
		if v.index == selectIndex  and v.trialNum == self._trialNum then
			local curtentConfig  = db:getCharacterByID(v.godarmId)			
			currentSelect = currentSelect + 1
			if characherCOnfig.label ~= nil and characherCOnfig.label == curtentConfig.label then
				samelabelNum = samelabelNum + 1
			end				
		end
	end

	for k, v in pairs(self._godarmList) do
		if v.godarmId == event.godarmId then
			if v.index == 0 then
				local teamKey = self._arrangement:getTeamKey()
				local teamVO = remote.teamManager:getTeamByKey(teamKey)
				print("currentSelect= selectIndex=",currentSelect,selectIndex)
				if currentSelect >= teamVO:getHerosMaxCountByIndex(selectIndex) then
					app.tip:floatTip(QUIWidgetHeroBattleArray.GODARM_FULL) 
					return
				end
				if samelabelNum >= 2 then
					app.tip:floatTip(QUIWidgetHeroBattleArray.GODARM_SAME_FULL) 
					return
				end				
				victoryId = v.godarmId
				v.index = self._selectTeamIndex
				v.trialNum = self._trialNum
				v.pos = currentSelect + 1
			else
				v.index = 0
				v.trialNum = nil
				v.pos = 5
			end
			hero = v
			break
		end
	end
	self:_updateGodarmInfo(victoryId, hero)
	self:_checkTips()
end
function QUIWidgetMetalCityHeroBattleArray:_updateHero(victoryId, hero)
    local heroList = {}
	self._selectedNumber = 0
	local helperHpSum = 0
	
	for k, v in pairs(self._heroList) do
		if v.index == remote.teamManager.TEAM_INDEX_HELP or v.index == remote.teamManager.TEAM_INDEX_HELP2 then
			local _, _, hp = self:getHeroHpMp(v.actorId)
			helperHpSum = helperHpSum + (hp or 0)
		end
	end
	for k, v in pairs(self._heroList) do
		if v.index == remote.teamManager.TEAM_INDEX_MAIN then
			v.hpScale, v.mpScale = self:getHeroHpMp(v.actorId, helperHpSum / 4)
			v.additionalHpMax = helperHpSum / 4
			self._additionalMaxHp[v.actorId] = helperHpSum / 4 
		else
			v.hpScale, v.mpScale = self:getHeroHpMp(v.actorId)
			v.additionalHpMax = 0
			self._additionalMaxHp[v.actorId] = 0
		end
		if v.trialNum == self._trialNum and v.index == self._selectTeamIndex then
			self._selectedNumber = self._selectedNumber + 1
			table.insert(heroList, v)
		end
	end
	if hero then
		self:_updateWidget(hero)
	else
		self:_updatePage()  
	end
	self:notificationMainPage(victoryId)
end

--更新精灵
function QUIWidgetMetalCityHeroBattleArray:_updateSoulSpirit(victoryId, soulSpirit)
	if soulSpirit then
		self:_updateSoulWidget(soulSpirit)
	else
		self:_updatePage()  
	end
	self:notificationMainPage(victoryId)
end

--更新神器
function QUIWidgetMetalCityHeroBattleArray:_updateGodarmInfo(victoryId, godarmId)
	print("更新神器--QUIWidgetMetalCityHeroBattleArray--")
	if godarmId then
		self:_updateGodarmWidget(godarmId)
	else
		self:_updatePage()  
	end
	self:notificationMainPage(victoryId)
end

function QUIWidgetMetalCityHeroBattleArray:notificationMainPage(victoryId)
	local heroList = {}
	local soulSpiritList = {}
	local assistHeroList = {}
	local godarmList = {}
	local selectIndex = self:getSelectIndex()
	for k, v in pairs(self._heroList) do
		if v.index == selectIndex and v.trialNum == self._trialNum then
			table.insert(heroList, v)
		elseif v.index == (selectIndex+1000) and v.trialNum == self._trialNum then
			table.insert(assistHeroList, v)
		end
	end
	for k, v in pairs(self._soulSpiritList) do
		if v.index == selectIndex and v.trialNum == self._trialNum then
			table.insert(soulSpiritList, v)
		end
	end

	for k,v in pairs(self._godarmList) do
		if v.index ~= 0 and v.trialNum == self._trialNum then
			table.insert(godarmList, v)
		end
	end
    self:dispatchEvent({name = QUIWidgetHeroBattleArray.HERO_CHANGED, hero = heroList, godarmList = godarmList,soulSpirits = soulSpiritList, assistHeroList = assistHeroList, victoryId = victoryId})
end

function QUIWidgetMetalCityHeroBattleArray:removeSelectedHero(id)
	local hero = nil
	for k, v in pairs(self._heroList) do
		if v.actorId == id then
			v.index = 0
			hero = v
			self._selectedNumber = self._selectedNumber - 1
			break
		end
	end
	remote.teamManager:updateHeroOrder(self._trialNum, id, false)

	local helperHpSum = 0
	for k, v in pairs(self._heroList) do
		if v.index == remote.teamManager.TEAM_INDEX_HELP or v.index == remote.teamManager.TEAM_INDEX_HELP2 then
			local _, _, hp = self:getHeroHpMp(v.actorId)
			helperHpSum = helperHpSum + (hp or 0)
		end
	end
	for k, v in pairs(self._heroList) do
		if v.index == remote.teamManager.TEAM_INDEX_MAIN then
			v.hpScale, v.mpScale = self:getHeroHpMp(v.actorId, helperHpSum / 4)
			v.additionalHpMax = helperHpSum / 4
			self._additionalMaxHp[v.actorId] = helperHpSum / 4
		else
			v.hpScale, v.mpScale = self:getHeroHpMp(v.actorId)
			v.additionalHpMax = 0
			self._additionalMaxHp[v.actorId] = 0
		end
	end

	if hero then
		self:_updateWidget(hero)
	else
		self:_updatePage()
	end

	self:_checkTips()
end

function QUIWidgetMetalCityHeroBattleArray:_showArray(condition)
	if self._currentButtonName == "soul" then --走精灵模块
		self._items = {}
		local soulSpiritList = clone(self._soulSpiritList)
		for k, v in pairs(soulSpiritList) do
			v.isStormArena = self._isStromArena
			table.insert(self._items, {oType = "soul", data = v})
		end
		table.sort(self._items, function (a,b)
			local characherA = db:getCharacterByID(a.data.soulSpiritId)
			local characherB = db:getCharacterByID(b.data.soulSpiritId)
			local soulSpiritInfoA = remote.soulSpirit:getMySoulSpiritInfoById(a.data.soulSpiritId)
			local soulSpiritInfoB = remote.soulSpirit:getMySoulSpiritInfoById(b.data.soulSpiritId)
			if characherA.aptitude ~= characherB.aptitude then
				return characherA.aptitude > characherB.aptitude
			elseif soulSpiritInfoA.grade ~= soulSpiritInfoB.grade then
				return soulSpiritInfoA.grade > soulSpiritInfoB.grade
			elseif soulSpiritInfoA.level ~= soulSpiritInfoB.level then
				return soulSpiritInfoA.level > soulSpiritInfoB.level
			else
				return a.data.soulSpiritId > b.data.soulSpiritId
			end
		end)
	elseif self._currentButtonName == "godarm" then --神器上阵
		self._items = {}
		for k, v in pairs(self._godarmList) do
			v.isStormArena = self._isStromArena
			table.insert(self._items, {oType = "godarm", data = v})
		end	
		table.sort(self._items, function (a,b)
			local characherA = db:getCharacterByID(a.data.godarmId)
			local characherB = db:getCharacterByID(b.data.godarmId)
			local godarmA = remote.godarm:getGodarmById(a.data.godarmId)
			local godarmB = remote.godarm:getGodarmById(b.data.godarmId)			
			if characherA.aptitude ~= characherB.aptitude then
				return characherA.aptitude > characherB.aptitude
			elseif godarmA.grade ~= godarmB.grade then
				return godarmA.grade > godarmB.grade
			elseif godarmA.level ~= godarmB.level then
				return godarmA.level > godarmB.level
			else
				return a.data.godarmId > b.data.godarmId
			end
		end)			
	else
		local allHero = {}
		self._items = {}
		self._displayHero = {}
		for k, v in pairs(self._heroList) do
			if condition(v.type) then 
				table.insert(allHero, v.actorId)
			end
		end
		table.sort(allHero, handler(self, self._sortHero))

		local helpIndex = {0, 0}
		for i = #allHero, 1, -1 do 
			local v = self._heroList[allHero[i]]
			v.metalCity = true
			if v.index == 2 and v.trialNum then
				helpIndex[v.trialNum] = helpIndex[v.trialNum] + 1
				v.helpIndex = helpIndex[v.trialNum]
			elseif v.index == 0 then
				v.helpIndex = 0
			end
			v.additionalHpMax = self._additionalMaxHp[v.actorId] or 0
			v.isStormArena = self._isStromArena
			table.insert(self._items, {oType = "hero", data = v})
		end
	end

	self:initListView()
end

function QUIWidgetMetalCityHeroBattleArray:_updateWidget(hero)
	if self._items == nil then self._items = {} end

	if q.isEmpty(self._heroList) == false then
		for k, v in pairs(self._heroList) do
			if v.actorId == hero.actorId then
				local helpIndex = {0, 0}
				hero.metalCity = true
				if hero.index == 2 and v.trialNum then
					helpIndex[v.trialNum] = helpIndex[v.trialNum] + 1
					hero.helpIndex = helpIndex[v.trialNum]
				elseif hero.index == 0 then
					hero.helpIndex = 0
				end
				hero.isStormArena = self._isStromArena
				hero.additionalHpMax = self._additionalMaxHp[v.actorId] or 0
				break
			end
		end
	end

	for _,info in ipairs(self._items) do
		if info.actorId == hero.actorId then
			info.index = hero.index
			info.additionalHpMax = hero.additionalHpMax
			info.trialNum = hero.trialNum
			info.helpIndex = hero.helpIndex
			break
		end
	end
	if self._listViewLayout then
		self._listViewLayout:refreshData()
	end
end

function QUIWidgetMetalCityHeroBattleArray:_updateSoulWidget(soulSpirit)
	if self._items == nil then self._items = {} end

	for _,info in ipairs(self._items) do
		if info.data.soulSpiritId == soulSpirit.soulSpiritId then
			info.data.index = soulSpirit.index
			info.data.trialNum = soulSpirit.trialNum
			info.data.isStormArena = self._isStromArena
			info.data.metalCity = true
			break
		end
	end
	if self._listViewLayout then
		self._listViewLayout:refreshData()
	end
end

function QUIWidgetMetalCityHeroBattleArray:_updateGodarmWidget(godarmInfo)
	for _,v in ipairs(self._items) do
		if v.data.godarmId == godarmInfo.godarmId then
			v.data.index = godarmInfo.index
			v.data.pos = godarmInfo.pos
			break
		end
	end

	if self._listViewLayout then
		self._listViewLayout:refreshData()
	end
end

function QUIWidgetMetalCityHeroBattleArray:getSelectTeam(trialNum)
	local tbl = {}

	local heroTbl = {}
	for _, value in pairs(self._heroList) do
		heroTbl[#heroTbl+1] = value
	end

	table.sort( heroTbl, function (a, b)
		if a.force ~= b.force then
			return a.force > b.force
		else
			return false
		end
	end )

	for _, value in ipairs(heroTbl) do
		if value.index ~= 0 and value.trialNum == trialNum then
			if tbl[value.index] == nil then tbl[value.index] = {} end
			table.insert(tbl[value.index], value.actorId)
		end
	end

	return tbl
end

--获取精灵的战队
function QUIWidgetMetalCityHeroBattleArray:getSelectSoulSpirit(trialNum)
	local tbl = {}
	for _, value in pairs(self._soulSpiritList) do
		if value.index ~= 0 and value.trialNum == trialNum  then
			table.insert(tbl, value.soulSpiritId)
		end
	end
	return tbl
end

--获取神器的战队
function QUIWidgetMetalCityHeroBattleArray:getSelectGodarmList(trialNum)
	local tbl = {}
	local godarmList = clone(self._godarmList)
	table.sort( godarmList, function( a,b )
		if a.pos ~= b.pos then
			return a.pos > b.pos
		end
	end )

	for _,v in pairs(godarmList ) do
		if v.index == 5 and v.trialNum == trialNum then
			table.insert(tbl, v.godarmId)
		end
	end
	return tbl
end

--获取神器info
function QUIWidgetMetalCityHeroBattleArray:getSelectGodarmListInfo(trialNum)
	local tbl = {}

	local godarmList = clone(self._godarmList)

	table.sort( godarmList, function( a,b )
		if a.pos ~= b.pos then
			return a.pos > b.pos
		end
	end)	
	for _,v in pairs(godarmList) do
		if v.index == 5 and v.trialNum == trialNum then
			table.insert(tbl, v)
		end
	end
	return tbl
end

--检查是否有为上阵的
function QUIWidgetMetalCityHeroBattleArray:_checkTips()
	local unlockMainCount = self._arrangement:getUnlockSlots(remote.teamManager.TEAM_INDEX_MAIN)
	local unlockHelp1Count = self._arrangement:getUnlockSlots(remote.teamManager.TEAM_INDEX_HELP)
	local unlockSoulCount = self._arrangement:getSoulSpiritUnlock(remote.teamManager.TEAM_INDEX_MAIN)
	local unlockGodarmCount = self._arrangement:getUnlockSlots(remote.teamManager.TEAM_INDEX_GODARM)

	local emptyCount = 0
	local emptySoulCount = 0
	local emptyGoarmCount = 0
	local mainCount = 0
	local help1Count = 0
	local soulCount = 0
	local godarm1Count = 0

	for _,v in pairs(self._heroList) do
		if v.index == 0 then
			emptyCount = emptyCount + 1
		elseif v.index == remote.teamManager.TEAM_INDEX_MAIN and v.trialNum == self._trialNum then
			mainCount = mainCount + 1
		elseif v.index == remote.teamManager.TEAM_INDEX_HELP and v.trialNum == self._trialNum then
			help1Count = help1Count + 1
		end
	end
	for _, value in pairs(self._soulSpiritList) do
		if value.index == 0 then
			emptySoulCount = emptySoulCount + 1
		elseif value.index == remote.teamManager.TEAM_INDEX_MAIN and value.trialNum == self._trialNum then
			soulCount = soulCount + 1
		end
	end

	for _,value in pairs(self._godarmList) do
		if value.index ~= remote.teamManager.TEAM_INDEX_GODARM then
			emptyGoarmCount = emptyGoarmCount + 1
		elseif value.index == remote.teamManager.TEAM_INDEX_GODARM and value.trialNum == self._trialNum then
			godarm1Count = godarm1Count + 1
		end		
	end

	self._ccbOwner.tip_main:setVisible((emptyCount > 0 and unlockMainCount > mainCount) or (emptySoulCount > 0 and unlockSoulCount > soulCount))
	self._ccbOwner.tip_helper1:setVisible(emptyCount > 0 and unlockHelp1Count > help1Count)
	self._ccbOwner.tip_helper2:setVisible(false)
	self._ccbOwner.tip_helper3:setVisible(false)
	self._ccbOwner.tip_godarm:setVisible(emptyGoarmCount > 0 and unlockGodarmCount > godarm1Count)

	if self._selectTeamIndex == remote.teamManager.TEAM_INDEX_MAIN then
		self._ccbOwner.tip_main:setVisible(false)
	end
end


function QUIWidgetMetalCityHeroBattleArray:updateHeroByTeams(teams1, teams2)
	for k, v in pairs(self._heroList) do
		v.index = 0
	end
	for k, v in pairs(self._soulSpiritList) do
		v.index = 0
	end
	for k,v in pairs(self._godarmList) do
		v.index = 0
	end
	if teams1[1] then
		for _, actorId in ipairs(teams1[1]) do
			self._heroList[actorId].index = 1
			self._heroList[actorId].trialNum = 1
			self._heroList[actorId].helpIndex = 0
		end
	end
	if teams1[2] then
		for helpIndex, actorId in ipairs(teams1[2]) do
			self._heroList[actorId].index = 2
			self._heroList[actorId].trialNum = 1
			self._heroList[actorId].helpIndex = helpIndex
		end
	end
	if teams1[3] then
		for _, soulSpiritId in ipairs(teams1[3]) do
			self._soulSpiritList[soulSpiritId].index = 1
			self._soulSpiritList[soulSpiritId].trialNum = 1
		end
	end

	if next(self._godarmList) ~= nil then
		if teams1[4] then
			for pos,godarmId in pairs(teams1[4]) do
				self._godarmList[godarmId].index = 5
				self._godarmList[godarmId].trialNum = 1
				self._godarmList[godarmId].pos = pos
			end
		end
	end

	if teams2[1] then
		for _, actorId in ipairs(teams2[1]) do
			self._heroList[actorId].index = 1
			self._heroList[actorId].trialNum = 2
			self._heroList[actorId].helpIndex = 0
		end
	end
	if teams2[2] then
		for helpIndex, actorId in ipairs(teams2[2]) do
			self._heroList[actorId].index = 2
			self._heroList[actorId].trialNum = 2
			self._heroList[actorId].helpIndex = helpIndex
		end
	end
	if teams2[3] then
		for _, soulSpiritId in ipairs(teams2[3]) do
			self._soulSpiritList[soulSpiritId].index = 1
			self._soulSpiritList[soulSpiritId].trialNum = 2
		end
	end

	if next(self._godarmList) ~= nil then
		if teams2[4] then
			for pos,godarmId in pairs(teams2[4]) do
				self._godarmList[godarmId].index = 5
				self._godarmList[godarmId].trialNum = 2
				self._godarmList[godarmId].pos = pos
			end
		end
	end
	self._selectedNumber = 0
	local heroList = {}
	for k, v in pairs(self._heroList) do
		if v.trialNum == self._trialNum and v.index == self._selectTeamIndex then
			self._selectedNumber = self._selectedNumber + 1
			table.insert(heroList, v)
		end
	end
	local soulSpiritList = {}
	for k, v in pairs(self._soulSpiritList) do
		if v.trialNum == self._trialNum and v.index == self._selectTeamIndex then
			table.insert(soulSpiritList, v)
		end
	end
	local godarmList = {}	
	for k,v in pairs(self._godarmList) do
		if v.index ~= 0 and v.trialNum == self._trialNum then
			table.insert(godarmList, v)
		end
	end

	self:_updatePage()
	self:_checkTips()
    self:dispatchEvent({name = QUIWidgetHeroBattleArray.HERO_CHANGED, godarmList = godarmList, hero = heroList, soulSpirits = soulSpiritList})
end

return QUIWidgetMetalCityHeroBattleArray
