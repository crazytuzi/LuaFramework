--
-- Kumo.Wang
-- 西尔维斯大斗魂场战斗总结算伤害信息
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilvesFightDataClient = class("QUIWidgetSilvesFightDataClient", QUIWidget)
local QUIWidgetFightEndData = import("..widgets.QUIWidgetFightEndData")

local NUMBERS = {"一","二","三"}

QUIWidgetSilvesFightDataClient.HERO_FIGHT_INFO = "HERO_FIGHT_INFO"

local function compareFunc(hero1, hero2)
	if hero1.isTreat ~= hero2.isTreat then
		return hero2.isTreat == true
	end
	local value1 = hero1.isTreat and hero1.treat or hero1.damage
	local value2 = hero2.isTreat and hero2.treat or hero2.damage
	if value1 ~= value2 then
		return value1 > value2
	end
	if hero1.order ~= hero2.order then
		return hero1.order < hero2.order
	end

	return hero1.actorId < hero2.actorId
end

function QUIWidgetSilvesFightDataClient:ctor(options)
	local ccbFile = "ccb/Widget_FightEnd_data_client.ccbi"
	local callBack = {
	}
	QUIWidgetSilvesFightDataClient.super.ctor(self, ccbFile, callBack, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._originalHeight = self._ccbOwner.node_size:getContentSize().height
end

function QUIWidgetSilvesFightDataClient:setInfo(info, index)
	if q.isEmpty(remote.silvesArena.fightInfo) then
		return
	end

    self._headBox = {}
	self._height = self._originalHeight
	self._teamInfo = {}
	for _, fighter in ipairs(remote.silvesArena.fightInfo.attackFightInfo) do
		if fighter.silvesArenaFightPos == index then
			self._teamInfo.hero = fighter
		end
	end
	for _, fighter in ipairs(remote.silvesArena.fightInfo.defenseFightInfo) do
		if fighter.silvesArenaFightPos == index then
			self._teamInfo.enemy = fighter
		end
	end
	self:readdLog(info.log)


	local fightNumStr = string.format("第%s场", NUMBERS[index])
	self._ccbOwner.tf_fight_num:setString(fightNumStr)

    local nodeHero = self._ccbOwner.node_item_left
    local nodeEnemy = self._ccbOwner.node_item_right
    nodeHero:removeAllChildren()
    nodeEnemy:removeAllChildren()
	local height = 90
    local index1 = 0
	for i, hero in ipairs(self._heroes) do
		local widget = QUIWidgetFightEndData.new()
        widget:setInfo(hero, true, self._maxValue)
        widget:setPosition(ccp(0, -index1*height))
        widget:initGLLayer()
        nodeHero:addChild(widget)
        index1 = index1 + 1
        self._headBox[index1] = widget
	end

	local index2 = 0
	for i, hero in ipairs(self._enemies) do
		local widget = QUIWidgetFightEndData.new()
        widget:setInfo(hero, false, self._maxValue)
        widget:setPosition(ccp(0, -index2*height))
        widget:initGLLayer()
        nodeEnemy:addChild(widget)
        index2 = index2 + 1
        self._headBox[index1+index2] = widget
	end

	if index2 > index1 then
		self._height = self._height + height*index2
	else
		self._height = self._height + height*index1
	end
end

function QUIWidgetSilvesFightDataClient:updateHeroInfo(heroStats, isHero)
	heroStats.treat = heroStats.treat or 0
	heroStats.damage = heroStats.damage or 0

	local curHero = isHero and self._teamInfo.hero or self._teamInfo.enemy
	local data = db:getCharacterByID(heroStats.actorId)
	local tempHero = {}
	local inTeam = false
	local isSoulSpirit = false
	local isSupport = false
	local order = 1
	for i, hero in ipairs(curHero.heros) do
		if hero.actorId == heroStats.actorId then
			tempHero = hero
			inTeam = true
			break
		end
	end

	if inTeam ~= true then
		for i, hero in ipairs(curHero.subheros or {}) do
			if hero.actorId == heroStats.actorId then
				tempHero = hero
				order = 2
				inTeam = true
				isSub = true
				break
			end
		end
	end

	if inTeam ~= true then
		for i, hero in ipairs(curHero.sub2heros or {}) do
			if hero.actorId == heroStats.actorId then
				tempHero = hero
				order = 3
				isSub2 = true
				inTeam = true
				break
			end
		end
	end

	if inTeam ~= true then
		for i, hero in ipairs(curHero.sub3heros or {}) do
			if hero.actorId == heroStats.actorId then
				tempHero = hero
				order = 4
				isSub3 = true
				inTeam = true
				break
			end
		end
	end

	if inTeam ~= true then
		for i, hero in ipairs(curHero.soulSpirit or {}) do
			if hero.id == heroStats.actorId then
				tempHero = hero
				order = 5
				inTeam = true
				isSoulSpirit = true
				break
			end
		end
	end

	heroStats.heroInfo = tempHero
	heroStats.inTeam = inTeam
	heroStats.order = order
	heroStats.isSoulSpirit = isSoulSpirit
	heroStats.isSub = isSub
	heroStats.isSub2 = isSub2
	heroStats.isSub3 = isSub3
	heroStats.isTreat = data.func == "health"

	return heroStats
end

function QUIWidgetSilvesFightDataClient:readdLog(log)
	if not log then return end

	local heroes = {}
	local enemies = {}
	for actorId, hero in pairs(log.heroStats) do
		if not hero.actorId then
			hero.actorId = actorId
		end
		self:updateHeroInfo(hero, true)
		if hero.show and hero.inTeam then
			table.insert(heroes, hero)
			-- local data = db:getCharacterByID(hero.actorId)
			-- if data.heal_count or (data.func ~= "health" and hero.treat > 0) or (data.func == "health" and hero.damage > 0) then
			-- 	local copyHero = clone(hero)
			-- 	local copyHero = {}
			-- 	copyHero.actorId = hero.actorId
			-- 	copyHero.treat = hero.treat
			-- 	copyHero.isTreat = not hero.isTreat
			-- 	copyHero.heroInfo = {}
			-- 	copyHero.heroInfo.level = hero.heroInfo.level 
			-- 	copyHero.heroInfo.skinId = hero.heroInfo.skinId 
			-- 	copyHero.heroInfo.grade = hero.heroInfo.grade 
			-- 	copyHero.heroInfo.breakthrough = hero.heroInfo.breakthrough
			-- 	copyHero.heroInfo.godSkillGrade = hero.heroInfo.godSkillGrade
			-- 	table.insert(heroes, copyHero)
			-- end
		end
	end
	for actorId, hero in pairs(log.enemyHeroStats) do
		if not hero.actorId then
			hero.actorId = actorId
		end
		self:updateHeroInfo(hero, false)
		if hero.show and hero.inTeam then
			table.insert(enemies, hero)
			-- local data = db:getCharacterByID(hero.actorId)
			-- if data.heal_count or (data.func ~= "health" and hero.treat > 0) or (data.func == "health" and hero.damage > 0) then
			-- 	local copyHero = {}
			-- 	copyHero.actorId = hero.actorId
			-- 	copyHero.treat = hero.treat
			-- 	copyHero.isTreat = not hero.isTreat
			-- 	copyHero.heroInfo = {}
			-- 	copyHero.heroInfo.level = hero.heroInfo.level 
			-- 	copyHero.heroInfo.skinId = hero.heroInfo.skinId 
			-- 	copyHero.heroInfo.grade = hero.heroInfo.grade 
			-- 	copyHero.heroInfo.breakthrough = hero.heroInfo.breakthrough
			-- 	copyHero.heroInfo.godSkillGrade = hero.heroInfo.godSkillGrade
			-- 	table.insert(enemies, copyHero)
			-- end
		end
	end
	-- 按照职业排序
	table.sort(heroes, compareFunc)
	table.sort(enemies, compareFunc)
		
	self._heroes = heroes or {}
	self._enemies = enemies or {}

	-- 初始化统计数字和统计条
	local maxValue = 1
	for _, hero in ipairs(heroes) do
		local value1 = hero.treat or 0
		local value2 = hero.damage or 0
		maxValue = math.max(maxValue, value1, value2)
	end
	for _, hero in ipairs(enemies) do
		local value1 = hero.treat or 0
		local value2 = hero.damage or 0
		maxValue = math.max(maxValue, value1, value2)
	end
	self._maxValue = maxValue
end

function QUIWidgetSilvesFightDataClient:registerItemBoxPrompt( index, list )
    for k, headBox in pairs(self._headBox) do
        list:registerItemBoxPrompt(index, k, headBox, 0, function()
        		local info = headBox:getInfo()
        		local isHero = headBox:getIsHero()
				self:dispatchEvent({name = QUIWidgetSilvesFightDataClient.HERO_FIGHT_INFO, info = info, isHero = isHero})
            end)
    end
end

function QUIWidgetSilvesFightDataClient:getContentSize()
	local size = self._ccbOwner.node_size:getContentSize()
	size.height = self._height + 10
	return size
end

return QUIWidgetSilvesFightDataClient

