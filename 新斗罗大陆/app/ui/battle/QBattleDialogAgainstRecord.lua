--
-- Author: Your Name
-- Date: 2014-05-19 10:58:04
--
local QBattleDialog = import(".QBattleDialog")
local QBattleDialogAgainstRecord = class(".QBattleDialogAgainstRecord", QBattleDialog)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroProfessionalIcon = import("..widgets.QUIWidgetHeroProfessionalIcon")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIWidgetAgainstRecordProgressBar = import("..widgets.QUIWidgetAgainstRecordProgressBar")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QBattleLog = import("...controllers.QBattleLog")
local QBattleDialogSkillData = import(".QBattleDialogSkillData")

local LEFT_TALENT_POS = {[1] = {x = -285.0,y = 50.0}, [2] = {x = -285.0, y = -48.0}, [3] = {x = -285.0, y = -143.0}, [4] = {x = -285.0, y = -239.0}}
local RIGHT_TALENT_POS = {[1] = {x = 295.0,y = 50.0}, [2] = {x = 295.0, y = -48.0}, [3] = {x = 295.0, y = -143.0}, [4] = {x = 295.0, y = -239.0}}
local LEFT_HEAD_POS = {[1] = {x = -227.0,y = 52.0}, [2] = {x = -227.0, y = -44.0}, [3] = {x = -227.0, y = -140.0}, [4] = {x = -227.0, y = -237.0}}
local RIGHT_HEAD_POS = {[1] = {x = 241.0,y = 52.0}, [2] = {x = 241.0, y = -44.0}, [3] = {x = 241.0, y = -140.0}, [4] = {x = 241.0, y = -237.0}}
local LEFT_BAR_POS = {[1] = {x = -98.0, y = 23.0}, [2] = {x = -98.0, y = -75.0}, [3] = {x = -98.0, y = -170.0}, [4] = {x = -98.0, y = -266.0}}
local RIGHT_BAR_POS = {[1] = {x = 132.0, y = 23.0}, [2] = {x = 132.0, y = -75.0}, [3] = {x = 132.0, y = -170.0}, [4] = {x = 132.0, y = -266.0}}

local orders = {dps = 1, t = 2, health = 3}
local function compareHeroFunc(hero1, hero2)
	-- if hero1.actor:isSupport() and not hero2.actor:isSupport() then
	-- 	return false
	-- elseif not hero1.actor:isSupport() and hero2.actor:isSupport() then
	-- 	return true
	-- elseif orders[hero1.actor:getTalentFunc()] < orders[hero2.actor:getTalentFunc()] then
	-- 	return true
	-- elseif orders[hero1.actor:getTalentFunc()] > orders[hero2.actor:getTalentFunc()] then
	-- 	return false
	-- else
		local talent1 = hero1.actor:getTalentFunc() == "health"
		local talent2 = hero2.actor:getTalentFunc() == "health"
		if not talent1 and talent2 then
			return true
		elseif talent1 and not talent2 then
			return false
		end
		if hero1.order ~= hero2.order then
			return hero1.order < hero2.order
		end
		local value1 = talent1 and hero1.treat or hero1.damage
		local value2 = talent2 and hero2.treat or hero2.damage
		if value1 > value2 then
			return true
		elseif value1 < value2 then
			return false
		else
			if hero1.actor:getActorID(true) >= hero2.actor:getActorID(true) then
				return false
			else
				return true
			end
		end
	-- end
end
local function compareNpcFunc(npc1, npc2)
	-- if npc1.actor:isSupport() and not npc2.actor:isSupport() then
	-- 	return true
	-- elseif not npc1.actor:isSupport() and npc2.actor:isSupport() then
	-- 	return false
	-- else
		local talent1 = npc1.actor:getTalentFunc() == "health"
		local talent2 = npc2.actor:getTalentFunc() == "health"
		if not talent1 and talent2 then
			return true
		elseif talent1 and not talent2 then
			return false
		end
		local value1 = talent1 and npc1.treat or npc1.damage
		local value2 = talent2 and npc2.treat or npc2.damage
		if value1 > value2 then
			return true
		elseif value1 < value2 then
			return false
		else
			if npc1.actor:getActorID(true) >= npc2.actor:getActorID(true) then
				return false
			else
				return true
			end
		end
	-- end
end

function QBattleDialogAgainstRecord:_onTriggerTeam1()
	if self._cur_log_idx == 1 then return end
	local log = nil
	if app.battle:isPVEMultipleWave() then
		log = app.battle:getBattleLog1()
	elseif app.battle:isPVPMultipleWaveNew() then
		log = app.battle:getPVPMultipleWaveNewScoreInfo().battleLogList[1]:getBattleLog()
	end

	if not log then return end
	self._cur_log_idx = 1
	self:setButtonState()
	self:_removeAllWidgets()
	self:_readdLog(log)
end

function QBattleDialogAgainstRecord:_onTriggerTeam2()
	if self._cur_log_idx == 2 then return end
	local log = nil
	if app.battle:isPVEMultipleWave() then
		log = app.battle:getBattleLog()
	elseif app.battle:isPVPMultipleWaveNew() then
		log = app.battle:getPVPMultipleWaveNewScoreInfo().battleLogList[2]:getBattleLog()
	end

	if not log then return end
	self._cur_log_idx = 2
	self:setButtonState()
	self:_removeAllWidgets()
	self:_readdLog(log)
end

function QBattleDialogAgainstRecord:_onTriggerTeam3()
	if self._cur_log_idx == 3 then return end
	local log = nil
	if app.battle:isPVEMultipleWave() then
		log = app.battle:getBattleLog()
	elseif app.battle:isPVPMultipleWaveNew() then
		log = app.battle:getPVPMultipleWaveNewScoreInfo().battleLogList[3]:getBattleLog()
	end

	if not log then return end
	self._cur_log_idx = 3
	self:setButtonState()
	self:_removeAllWidgets()
	self:_readdLog(log)
end

function QBattleDialogAgainstRecord:setButtonState()
	local btn1 = self._cur_log_idx == 1
	self._ccbOwner.team_but_1:setHighlighted(btn1)
	self._ccbOwner.team_but_1:setEnabled(not btn1)

	local btn2 = self._cur_log_idx == 2
	self._ccbOwner.team_but_2:setHighlighted(btn2)
	self._ccbOwner.team_but_2:setEnabled(not btn2)

	local btn3 = self._cur_log_idx == 3
	self._ccbOwner.team_but_3:setHighlighted(btn3)
	self._ccbOwner.team_but_3:setEnabled(not btn3)
end

local NUMBERS = {"一","二","三"}

function QBattleDialogAgainstRecord:ctor(options,owner,closeCallback)
	local ccbFile = "ccb/Dialog_AgainstRecord_Bata.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QBattleDialogAgainstRecord._onTriggerClose)},
		{ccbCallbackName = "onTriggerTeam1", callback = handler(self, QBattleDialogAgainstRecord._onTriggerTeam1)},
		{ccbCallbackName = "onTriggerTeam2", callback = handler(self, QBattleDialogAgainstRecord._onTriggerTeam2)},
		{ccbCallbackName = "onTriggerTeam3", callback = handler(self, QBattleDialogAgainstRecord._onTriggerTeam3)},
	}

	if owner == nil then 
		owner = {}
	end

	--设置该节点启用enter事件
	self:setNodeEventEnabled(true)
	QBattleDialogAgainstRecord.super.ctor(self,ccbFile,owner,callBacks)

	self._closeCallback = closeCallback

	owner.tf_title:setString("数据查看")


	local log = nil

	if app.battle:isPVEMultipleWave() then
		owner.team_but_1:setVisible(true)
		owner.team_but_2:setVisible(app.battle:getPVEMultipleCurWave() == 2)
		owner.team_but_3:setVisible(false)
		owner.team_but_1:setEnabled(app.battle:getBattleLog() ~= nil)
		self._ccbOwner.team_but_1:setHighlighted(true)
		log = app.battle:getBattleLog1()
		self._cur_log_idx = 1
	elseif app.battle:isPVPMultipleWaveNew() then
		local totalWave = app.battle:getPVPMultipleNewCurWave()
		for i = 1, 3 do
			local but = owner["team_but_"..i]
			but:setVisible(totalWave >= i)
			local title = CCString:create(string.format("第%s场",NUMBERS[i]))
			but:setTitleForState(title, CCControlStateNormal)
			but:setTitleForState(title, CCControlStateHighlighted)
			but:setTitleForState(title, CCControlStateDisabled)
		end
		self._ccbOwner.team_but_1:setHighlighted(true)
		log = app.battle:getPVPMultipleWaveNewScoreInfo().battleLogList[1]:getBattleLog()
		self._cur_log_idx = 1
	else
		owner.team_but_1:setVisible(false)
		owner.team_but_2:setVisible(false)
		owner.team_but_3:setVisible(false)
		-- dirty fix: http://jira.joybest.com.cn/browse/WOW-18616
		if (app.battle:isInRebelFight() or app.battle:isInWorldBoss()) and (#app.battle:getEnemies() + #app.battle:getDeadEnemies() == 0) then
			local character_id, level
	        if app.battle:isInRebelFight() then
	            character_id = app.battle:getDungeonConfig().rebelID
	            level = app.battle:getDungeonConfig().rebelLevel
	        elseif app.battle:isInWorldBoss() then
	            character_id = app.battle:getDungeonConfig().worldBossID
	            level = app.battle:getDungeonConfig().worldBossLevel
	        end
	        if character_id and level then
	        	local boss = app:createNpc(character_id, "", level, {}, nil, true)
	        	table.insert(app.battle._deadEnemies, boss)
	        end
		end
		-- 取统计数据
		local rawBattleLogFromServer = app.battle:getRawBattleLogFromServer()
		if rawBattleLogFromServer then
			log = QBattleLog.new()
			log:setBattleLogFromServer(rawBattleLogFromServer)
			log = log:getBattleLog()
		else
			log = app.battle:getBattleLog()
		end
	end	
	self:_readdLog(log)

end

function QBattleDialogAgainstRecord:_readdLog(log)
	if not log then return end
	local owner = self._ccbOwner
	local heroes = {}
	local enemies = {}
	local healcountHeroIDs = {}
	local healcountEnemyIDs = {}
	
	for actorId, hero in pairs(log.heroStats) do
		if not app.battle:isGhost(hero.actor) and hero.show and hero.actor then
			local isAdd = false
			if not hero.actor:isSupport() then
				if hero.actor:isAlternate() then
					hero.order = 2
					hero.isAlternate = true
				else
					hero.order = 1
				end
				table.insert(heroes, hero)
				isAdd = true
			elseif log.supportSkillHero == hero.actor or 
				log.supportSkillHero2 == hero.actor or 
				app.battle:getSupportSkillHero() == hero.actor or 
				app.battle:getSupportSkillHero2() == hero.actor or 
				app.battle:getSupportSkillHero3() == hero.actor then
				hero.isSupport = true
				hero.order = 4
				table.insert(heroes, hero)
				isAdd = true
			end
			if isAdd then
				local actor = hero.actor
				local id = actor:getActorID(true)
				local data = db:getCharacterByID(id)
				if data.heal_count or (data.func ~= "health" and hero.treat > 0) or (data.func == "health" and hero.damage > 0) then
					healcountHeroIDs[id] = 0
				end
			end
		elseif app.battle:isGhost(hero.actor) and hero.show and hero.actor and hero.actor:isSoulSpirit() then
			hero.order = 3
			local actor = hero.actor
			local id = actor:getActorID(true)
			local data = db:getCharacterByID(id)
			if data.heal_count or (data.func ~= "health" and hero.treat > 0) or (data.func == "health" and hero.damage > 0) then
				healcountHeroIDs[id] = 0
			end
			table.insert(heroes, hero)
		end
	end
	for actorId, enemy in pairs(log.enemyHeroStats) do
		if not app.battle:isGhost(enemy.actor) and enemy.show and enemy.actor then
			local isAdd = false
			if not enemy.actor:isSupport() then
				if enemy.actor:isAlternate() then
					enemy.order = 2
					enemy.isAlternate = true
				else
					enemy.order = 1
				end
				table.insert(enemies, enemy)
				isAdd = true
			elseif log.supportSkillEnemy == enemy.actor or 
				log.supportSkillEnemy2 == enemy.actor or 
				app.battle:getSupportSkillEnemy() == enemy.actor or 
				app.battle:getSupportSkillEnemy2() == enemy.actor or 
				app.battle:getSupportSkillEnemy3() == enemy.actor then
				enemy.isSupport = true
				enemy.order = 4
				table.insert(enemies, enemy)
				isAdd = true
			end
			if isAdd then
				local actor = enemy.actor
				local id = actor:getActorID(true)
				local data = db:getCharacterByID(id)
				if data.heal_count or (data.func ~= "health" and enemy.treat > 0) or (data.func == "health" and enemy.damage > 0) then
					healcountEnemyIDs[id] = 0
				end
			end
		elseif app.battle:isGhost(enemy.actor) and enemy.show and enemy.actor and enemy.actor:isSoulSpirit() then
			enemy.order = 3
			local actor = enemy.actor
			local id = actor:getActorID(true)
			local data = db:getCharacterByID(id)
			if data.heal_count or (data.func ~= "health" and enemy.treat > 0) or (data.func == "health" and enemy.damage > 0) then
				healcountEnemyIDs[id] = 0
			end
			table.insert(enemies, enemy)
		end
	end

	-- 按照职业排序
	table.sort(heroes, compareHeroFunc)
	local insertNum = 0
	local insert_cache = {}
	for index, hero in ipairs(heroes) do
		if insertNum >= table.nums(healcountHeroIDs) then
			break
		end
		if not insert_cache[hero] then
			local actor = hero.actor
			local id = actor:getActorID(true)
			if healcountHeroIDs[id] == 0 then
				local isInsert = false
				insertNum = insertNum + 1
				for i = 1, #heroes do
					local treat = heroes[i].actor:getTalentFunc() == "health"
					if not isInsert and treat and hero.treat >= heroes[i].treat then
						isInsert = true
						table.insert(heroes, i, hero)
						insert_cache[hero] = true
						break
					end
				end
				if not isInsert then
					isInsert = true
					table.insert(heroes, hero)
					insert_cache[hero] = true
				end
			end
		end
	end

	insert_cache = {}

	if app.battle:isPVPMode() then
		table.sort(enemies, compareHeroFunc)
		insertNum = 0
		for index, enemy in ipairs(enemies) do
			if insertNum >= table.nums(healcountEnemyIDs) then
				break
			end
			if not insert_cache[enemy] then
				local actor = enemy.actor
				local id = actor:getActorID(true)
				if healcountEnemyIDs[id] == 0 then
					local isInsert = false
					insertNum = insertNum + 1
					for i = 1, #enemies do
						local actor = enemies[i].actor
						local treat = actor:getTalentFunc() == "health"
						if not isInsert and treat and enemy.treat >= enemies[i].treat then
							isInsert = true
							table.insert(enemies, i, enemy)
							insert_cache[enemy] = true
						end
					end
					if not isInsert then
						isInsert = true
						table.insert(enemies, enemy)
						insert_cache[enemy] = true
					end
				end
			end
		end
	else
		table.sort(enemies, compareNpcFunc)
	end

	-- for index, hero in ipairs(heroes) do
	-- 	local actor = hero.actor
	-- 	local id = actor:getActorID()
	-- 	local data = QStaticDatabase.sharedDatabase():getCharacterByID(id)
	-- 	print("name = ", data.name, "  id = ", id, "  damage = ", hero.damage, "  treat = ", hero.treat)
	-- end

	-- 根据魂师/敌人数量初始化widgets
	local node_head = self._ccbOwner.node_head
	local node_xuetiao = self._ccbOwner.node_xuetiao
	local heroTalentWidgets = {}
	local heroHeadWidgets = {}
	local heroBarWidgets = {}
	local enemyTalentWidgets = {}
	local enemyHeadWidgets = {}
	local enemyBarWidgets = {}
	
	for index = 1, #heroes do
		if index > 4 then
			local node_left_talent = CCNode:create()
			local node_left_head = CCNode:create()
			local node_left_bar = CCNode:create()
			node_left_talent:setScale(0.65)
			node_left_head:setScale(0.65)
			node_head:addChild(node_left_talent)
			node_head:addChild(node_left_head)
			node_xuetiao:addChild(node_left_bar)
			node_left_talent:setPositionX(owner.node_left_talent_4:getPositionX())
			node_left_head:setPositionX(owner.node_left_head_4:getPositionX())
			node_left_bar:setPositionX(owner.node_left_bar_4:getPositionX())
			node_left_talent:setPositionY(owner.node_left_talent_4:getPositionY() - 98 * (index - 4))
			node_left_head:setPositionY(owner.node_left_head_4:getPositionY() - 98 * (index - 4))
			node_left_bar:setPositionY(owner.node_left_bar_4:getPositionY() - 98 * (index - 4))
			owner["node_left_talent_" .. (index)] = node_left_talent
			owner["node_left_head_" .. (index)] = node_left_head
			owner["node_left_bar_" .. (index)] = node_left_bar
		end

		local widget = QUIWidgetHeroProfessionalIcon.new()
		table.insert(heroTalentWidgets, widget)
		owner["node_left_talent_" .. (index)]:addChild(widget)

		local widget = QUIWidgetHeroHead.new()
		table.insert(heroHeadWidgets, widget)
		owner["node_left_head_" .. (index)]:addChild(widget)
		widget:moveDownTeam()
		
		local widget = QUIWidgetAgainstRecordProgressBar.new()
		table.insert(heroBarWidgets, widget)
		owner["node_left_bar_" .. (index)]:addChild(widget)
	end
	for index = 1, #enemies do
		if index > 4 then
			local node_left_talent = CCNode:create()
			local node_left_head = CCNode:create()
			local node_left_bar = CCNode:create()
			node_left_talent:setScale(0.65)
			node_left_head:setScale(0.65)
			node_head:addChild(node_left_talent)
			node_head:addChild(node_left_head)
			node_xuetiao:addChild(node_left_bar)
			node_left_talent:setPositionX(owner.node_right_talent_4:getPositionX())
			node_left_head:setPositionX(owner.node_right_head_4:getPositionX())
			node_left_bar:setPositionX(owner.node_right_bar_4:getPositionX())
			node_left_talent:setPositionY(owner.node_left_talent_4:getPositionY() - 98 * (index - 4))
			node_left_head:setPositionY(owner.node_right_head_4:getPositionY() - 98 * (index - 4))
			node_left_bar:setPositionY(owner.node_right_bar_4:getPositionY() - 98 * (index - 4))
			owner["node_right_talent_" .. (index)] = node_left_talent
			owner["node_right_head_" .. (index)] = node_left_head
			owner["node_right_bar_" .. (index)] = node_left_bar
		end

		local widget = QUIWidgetHeroProfessionalIcon.new()
		table.insert(enemyTalentWidgets, widget)
		owner["node_right_talent_" .. (index)]:addChild(widget)

		local widget = QUIWidgetHeroHead.new()
		table.insert(enemyHeadWidgets, widget)
		owner["node_right_head_" .. (index)]:addChild(widget)
		widget:moveDownTeam()
		
		local widget = QUIWidgetAgainstRecordProgressBar.new()
		table.insert(enemyBarWidgets, widget)
		owner["node_right_bar_" .. (index)]:addChild(widget)
	end
	-- 初始化滚动
	self:_initScroll(math.max(#heroes, #enemies))
	
	local dunguenConfig = app.battle:getDungeonConfig()
	local userAlternateInfos = dunguenConfig.userAlternateInfos or {}
	local enemyAlternateInfos = dunguenConfig.enemyAlternateInfos or {}
	local getAlternateNum = function(alternateInfos, actorId)
		for i, v in pairs(alternateInfos) do
			if v.actorId == actorId then
				return i
			end
		end
		return 0
	end

	for index, hero in ipairs(heroes) do
		local actor = hero.actor
		local widget = heroTalentWidgets[index]
		widget:setHero(actor:getActorID(true))

		local widget = heroHeadWidgets[index]
		local actorInfo = actor:getActorInfo()
		widget:setHeroInfo(actorInfo)
		widget:setProfession()
		
		if actor:isSupport() then
			widget:setTeam(2)
		else
			local alternateNum = getAlternateNum(userAlternateInfos, actor:getActorID(true))
			if alternateNum == 0 then
				widget:setTeam(1)
			else
				widget:setTeam(alternateNum, false, true)
			end
		end
		self:_addHeadTouchEvent(widget, hero, true)
	end

	for index, enemy in ipairs(enemies) do
		local actor = enemy.actor
		local widget = enemyTalentWidgets[index]
		if app.battle:isPVPMode() then
			widget:setHero(actor:getActorID(true))
		else
			widget:setVisible(false)
		end

		local widget = enemyHeadWidgets[index]
		local actorInfo = actor:getActorInfo()
		widget:setHeroInfo(actorInfo)
		widget:setProfession()
		
		if actor:isSupport() then
			widget:setTeam(2)
		else
			local alternateNum = getAlternateNum(enemyAlternateInfos, actor:getActorID(true))
			if alternateNum == 0 then
				widget:setTeam(1)
			else
				widget:setTeam(alternateNum, false, true)
			end
		end
		self:_addHeadTouchEvent(widget, enemy, false)
	end
	-- 初始化统计数字和统计条
	local max_value = 1
	for _, hero in ipairs(heroes) do
		local actor = hero.actor
		local id = actor:getActorID(true)
		local value = actor:getTalentFunc() == "health" and hero.treat or hero.damage
		value = value or 0
		local value1 = 0
		local value2 = 0
		if healcountHeroIDs[id] == 0 then
			value1 = hero.treat or 0
			value2 = hero.damage or 0
		end
		max_value = math.max(max_value, value, value1, value2)
	end
	for _, enemy in ipairs(enemies) do
		local actor = enemy.actor
		local id = actor:getActorID(true)
		local value = actor:getTalentFunc() == "health" and enemy.treat or enemy.damage
		value = value or 0
		local value1 = 0
		local value2 = 0
		if healcountEnemyIDs[id] == 0 then
			value1 = enemy.treat or 0
			value2 = enemy.damage or 0
		end
		max_value = math.max(max_value, value, value1, value2)
	end
	for index, hero in ipairs(heroes) do
		local actor = hero.actor
		local treat = actor:getTalentFunc() == "health"
		local value = treat and hero.treat or hero.damage
		local id = actor:getActorID(true)
		if healcountHeroIDs[id] == 0 then
			-- 未处理过，显示伤害
			value = hero.damage
			value = value or 0
			local widget = heroBarWidgets[index]
			widget:setColor("green")
			widget:setValue(0, value, 0, (value == 0) and 0 or math.max(value / max_value, 0.005), "伤害 ")
			healcountHeroIDs[id] = 1
		elseif healcountHeroIDs[id] == 1 then
			--显示过伤害，显示治疗
			value = hero.treat
			value = value or 0
			local widget = heroBarWidgets[index]
			widget:setColor("green")
			widget:setValue(0, value, 0, (value == 0) and 0 or math.max(value / max_value, 0.005), "治疗 ")
			healcountHeroIDs[id] = 2
		elseif not healcountHeroIDs[id] then
			--不需要显示两种的
			local value = treat and hero.treat or hero.damage
			value = value or 0
			local widget = heroBarWidgets[index]
			widget:setColor("green")
			widget:setValue(0, value, 0, (value == 0) and 0 or math.max(value / max_value, 0.005), treat and "治疗 " or "伤害 ")
		end
	end
	for index, enemy in ipairs(enemies) do
		local actor = enemy.actor
		local treat = actor:getTalentFunc() == "health"
		local value = treat and enemy.treat or enemy.damage
		local id = actor:getActorID(true)
		if healcountEnemyIDs[id] == 0 then
			-- 未处理过，显示伤害
			value = enemy.damage
			value = value or 0
			local widget = enemyBarWidgets[index]
			widget:setColor("red")
			widget:setValue(0, value, 0, (value == 0) and 0 or math.max(value / max_value, 0.005), "伤害 ")
			healcountEnemyIDs[id] = 1
		elseif healcountEnemyIDs[id] == 1 then
			--显示过伤害，显示治疗
			value = enemy.treat
			value = value or 0
			local widget = enemyBarWidgets[index]
			widget:setColor("red")
			widget:setValue(0, value, 0, (value == 0) and 0 or math.max(value / max_value, 0.005), "治疗 ")
			healcountEnemyIDs[id] = 2
		elseif not healcountEnemyIDs[id] then
			--不需要显示两种的
			local value = treat and enemy.treat or enemy.damage
			value = value or 0
			local widget = enemyBarWidgets[index]
			widget:setColor("red")
			widget:setValue(0, value, 0, (value == 0) and 0 or math.max(value / max_value, 0.005), treat and "治疗 " or "伤害 ")
		end
	end

	-- 胜负手，编辑器模式
	if app.battle:isInEditor() then
		local win, lose, timeout = 0, 0, 0
		if app.battle:getBattleLog().win == true then
			win = win + 1
		elseif app.battle:getBattleLog().win == false then
			lose = lose + 1
			timeout = timeout + (app.battle:getBattleLog().overtime and 1 or 0)
		end
		for _, log in ipairs(app:getBattleLogs()) do
			if log:getBattleLog().win == true then
				win = win + 1
			elseif log:getBattleLog().win == false then
				lose = lose + 1
				timeout = timeout + (log:getBattleLog().overtime and 1 or 0)
			end
		end
	    local label = ui.newTTFLabel( {
	        text = "胜利: " .. tostring(win) .. "次，失败: " .. tostring(lose) .. "次（含平： " .. tostring(timeout) .. "次）",
	        font = global.font_default,
	        size = 20,
	        color = display.COLOR_GREEN,
	        } )
	    self._ccbNode:addChild(label)
	    label:setPosition(ccp(0, 124))
	end
end

local function reAddWidget1_4(owner)
	local node_head = owner.node_head
	local node_xuetiao = owner.node_xuetiao
	for i = 1,4 do
		local node_left_talent = CCNode:create()
		local node_left_head = CCNode:create()
		local node_left_bar = CCNode:create()
		node_left_talent:setScale(0.65)
		node_left_head:setScale(0.65)
		node_head:addChild(node_left_talent)
		node_head:addChild(node_left_head)
		node_xuetiao:addChild(node_left_bar)
		node_left_talent:setPositionX(LEFT_TALENT_POS[i].x)
		node_left_head:setPositionX(LEFT_HEAD_POS[i].x)
		node_left_bar:setPositionX(LEFT_BAR_POS[i].x)
		node_left_talent:setPositionY(LEFT_TALENT_POS[i].y)
		node_left_head:setPositionY(LEFT_HEAD_POS[i].y)
		node_left_bar:setPositionY(LEFT_BAR_POS[i].y)
		owner["node_left_talent_" .. (i)] = node_left_talent
		owner["node_left_head_" .. (i)] = node_left_head
		owner["node_left_bar_" .. (i)] = node_left_bar
	end

	for i = 1,4 do
		local node_right_talent = CCNode:create()
		local node_right_head = CCNode:create()
		local node_right_bar = CCNode:create()
		node_right_talent:setScale(0.65)
		node_right_head:setScale(0.65)
		node_head:addChild(node_right_talent)
		node_head:addChild(node_right_head)
		node_xuetiao:addChild(node_right_bar)
		node_right_talent:setPositionX(RIGHT_TALENT_POS[i].x)
		node_right_head:setPositionX(RIGHT_HEAD_POS[i].x)
		node_right_bar:setPositionX(RIGHT_BAR_POS[i].x)
		node_right_talent:setPositionY(RIGHT_TALENT_POS[i].y)
		node_right_head:setPositionY(RIGHT_HEAD_POS[i].y)
		node_right_bar:setPositionY(RIGHT_BAR_POS[i].y)
		owner["node_right_talent_" .. (i)] = node_right_talent
		owner["node_right_head_" .. (i)] = node_right_head
		owner["node_right_bar_" .. (i)] = node_right_bar
	end
end

function QBattleDialogAgainstRecord:_removeAllWidgets()
	self._ccbOwner.node_head:removeAllChildrenWithCleanup()
	self._ccbOwner.node_xuetiao:removeAllChildrenWithCleanup()
	for i = 1,10000,1 do
		local is_break = true
		if self._ccbOwner["node_left_talent_"..i] then
			self._ccbOwner["node_left_talent_"..i] = nil
			is_break = false
		end

		if self._ccbOwner["node_right_talent_"..i] then
			self._ccbOwner["node_right_talent_"..i] = nil
			is_break = false
		end

		if self._ccbOwner["node_left_head_"..i] then
			self._ccbOwner["node_left_head_"..i] = nil
			is_break = false
		end

		if self._ccbOwner["node_right_head_"..i] then
			self._ccbOwner["node_right_head_"..i] = nil
			is_break = false
		end

		if self._ccbOwner["node_left_bar_"..i] then
			self._ccbOwner["node_left_bar_"..i] = nil
			is_break = false
		end

		if self._ccbOwner["node_right_bar_"..i] then
			self._ccbOwner["node_right_bar_"..i] = nil
			is_break = false
		end

		if is_break then
			break
		end
	end

	self._ccbOwner["node_head"]:removeFromParentAndCleanup()
	self._ccbOwner["node_xuetiao"]:removeFromParentAndCleanup()
	self._touchLayer:detach()
	self._layerColor:removeFromParentAndCleanup()
	self._boxContent:removeFromParentAndCleanup()
	self._sheet:removeFromParentAndCleanup()
	local node_head = CCNode:create()
	local node_xuetiao = CCNode:create()
	self._ccbOwner["parent_node"]:addChild(node_head)
	self._ccbOwner["parent_node"]:addChild(node_xuetiao)
	node_head:setPosition(ccp(2.0, 54.0))
	node_xuetiao:setPosition(ccp(2.0, 63.0))
	self._ccbOwner["node_head"] = node_head
	self._ccbOwner["node_xuetiao"] = node_xuetiao
	reAddWidget1_4(self._ccbOwner)
end

function QBattleDialogAgainstRecord:_addHeadTouchEvent(widget, stat, isHero)
	if not app.battle:isInEditor() and not DISPLAY_MORE_BATTLE_DETAIL then
		return
	end

	if self._widgetToStat == nil then
		self._widgetToStat = {}
	end
	self._widgetToStat[widget] = {stat = stat, isHero = isHero}
	widget:addEventListener(widget.EVENT_HERO_HEAD_CLICK, handler(self, self._onTriggerTouchHead))
end

function QBattleDialogAgainstRecord:_onTriggerTouchHead(event)
	local statObj = self._widgetToStat[event.target]
	if statObj then
		self:_popDetailDialog(statObj.stat, statObj.isHero)
	end
end

function QBattleDialogAgainstRecord:_popDetailDialog(stat, isHero)
    QBattleDialogSkillData.new({skillData = stat.skill, isHero = isHero}) 
end

-- 初始化滚动
function QBattleDialogAgainstRecord:_initScroll(max_number)
	local node_head = self._ccbOwner.node_head
	local node_xuetiao = self._ccbOwner.node_xuetiao
	local parent = node_head:getParent()

	local node_sheet = CCLayer:create()
	node_sheet:setPositionX(-350)
	node_sheet:setPositionY(-175)
	parent:addChild(node_sheet)

	local node_sheet_layout = CCLayer:create()
	node_sheet_layout:setAnchorPoint(CCPoint(0.5, 0.5))
	node_sheet_layout:setContentSize(CCSize(750, 350))
	-- node_sheet_layout:setTouchEnabled(true)
	node_sheet:addChild(node_sheet_layout)

    self._boxWidth = node_sheet_layout:getContentSize().width
    self._boxHeight = node_sheet_layout:getContentSize().height
    self._boxOriginX = node_sheet_layout:getPositionX()
    self._boxOriginY = node_sheet_layout:getPositionY()

	node_head:retain()
	node_xuetiao:retain()
	node_head:removeFromParent()
	node_xuetiao:removeFromParent()
	node_head:setPositionX(node_head:getPositionX() + 350)
	node_head:setPositionY(node_head:getPositionY() + 200)
	node_xuetiao:setPositionX(node_xuetiao:getPositionX() + 350)
	node_xuetiao:setPositionY(node_xuetiao:getPositionY() + 200)

    self._boxContent = CCNode:create()
    self._boxContent:addChild(node_head)
    self._boxContent:addChild(node_xuetiao)

	node_head:release()
	node_xuetiao:release()

    self._layerColor = CCLayerColor:create(ccc4(0,0,0,150),self._boxWidth,self._boxHeight + 20)
    local ccclippingNode = CCClippingNode:create()
    self._layerColor:setPositionX(node_sheet_layout:getPositionX() - 20)
    self._layerColor:setPositionY(node_sheet_layout:getPositionY() - 20)
    ccclippingNode:setStencil(self._layerColor)
    ccclippingNode:addChild(self._boxContent)

    node_sheet:addChild(ccclippingNode)
    self._isAnimRunning = false

    self._sheet = node_sheet

    self._touchLayer = QUIGestureRecognizer.new()
    self._touchLayer:attachToNode(node_sheet, self._boxWidth, self._boxHeight, self._boxOriginX - 580, self._boxOriginY - 370 - (UI_DESIGN_WIDTH * display.height / display.width - UI_DESIGN_HEIGHT) / 2, handler(self, self.onTouchEvent))

	self._node_head_y = node_head:getPositionY()
	self._node_xuetiao_y = node_xuetiao:getPositionY()
	self._max_y_offset = math.max(0, max_number - 4) * 98 + 10

    self._touchLayer:enable()
    self._touchLayer:setAttachSlide(true)
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self.onTouchEvent))
end

function QBattleDialogAgainstRecord:onTouchEvent(event)
    if event == nil or event.name == nil then
        return
    end

    if event.name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE then

    elseif event.name == "began" then
        self._startY = event.y
        self._isMoving = true
    elseif event.name == "moved" then
        local offsetY = event.y - self._startY
        self._startY = event.y
        -- offsetY = offsetY / 3
        if self._detailContainer then
			self._detailContainer:setPositionY(self._detailContainer:getPositionY() + offsetY)
        else
			self:moveBy(offsetY)
		end
		self._isMoving = true
    elseif event.name == "ended" or event.name == "cancelled" then
    	self._isMoving = false
    end
end

function QBattleDialogAgainstRecord:moveBy(offset_y)
	local node_head = self._ccbOwner.node_head
	local node_xuetiao = self._ccbOwner.node_xuetiao

	local pos_y = math.max(node_head:getPositionY() + offset_y, self._node_head_y - 150)
	pos_y = math.min(pos_y, self._node_head_y + self._max_y_offset + 150)
	node_head:setPositionY(pos_y)
	local pos_y = math.max(node_xuetiao:getPositionY() + offset_y, self._node_xuetiao_y - 150)
	pos_y = math.min(pos_y, self._node_xuetiao_y + self._max_y_offset + 150)
	node_xuetiao:setPositionY(pos_y)

	-- node_head:setPositionY(node_head:getPositionY() + offset_y)
	-- node_xuetiao:setPositionY(node_xuetiao:getPositionY() + offset_y)
end

function QBattleDialogAgainstRecord:_onFrame(dt)
	if not self._isMoving then
		local node_head = self._ccbOwner.node_head
		local node_xuetiao = self._ccbOwner.node_xuetiao
		local pos_y = node_head:getPositionY()
		local pos_y_target = math.clamp(pos_y, self._node_head_y, self._node_head_y + self._max_y_offset)
		if pos_y_target ~= pos_y then
			local delta_y = pos_y_target - pos_y
			local sign = delta_y / math.abs(delta_y)
			local speed = math.sampler2(500, 200, 100, 0, math.clamp(math.abs(delta_y), 0, 150))
			local step = sign * speed * dt
			local pos_y_new = pos_y + step
			local delta_y_new = pos_y_target - pos_y_new
			local sign_new = delta_y_new / math.abs(delta_y_new)
			if sign ~= sign_new then
				pos_y_new = pos_y_target
			end
			node_head:setPositionY(pos_y_new)
			node_xuetiao:setPositionY(node_xuetiao:getPositionY() + pos_y_new - pos_y)
		end
	end
end

function QBattleDialogAgainstRecord:onEnter()
	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self._onFrame))
	self:scheduleUpdate_()
end

function QBattleDialogAgainstRecord:onExit()
    self:removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)
end

function QBattleDialogAgainstRecord:_backClickHandler()
	self:_onTriggerClose()
end

function QBattleDialogAgainstRecord:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
	if app.battle:isInEditor() then
		app.battle:resume()
	end
	if event ~= nil then 
		app.sound:playSound("common_cancel")
	end

	self:close()
end

function QBattleDialogAgainstRecord:close()
    if self._closeCallback then
    	local closeCallback = self._closeCallback
    	self._closeCallback = nil
    	closeCallback()
    else
	    self._touchLayer:enable()
	    self._touchLayer:setAttachSlide(true)
	    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self.onTouchEvent))
	    QBattleDialogAgainstRecord.super.close(self)
    end
end

return QBattleDialogAgainstRecord