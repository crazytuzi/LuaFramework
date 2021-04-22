local QEBattleViewer = class("QEBattleViewer", function()
    return display.newScene("QEBattleViewer")
end)

local QESkeletonViewer = import(".QESkeletonViewer")
local QBattleScene = import("...scenes.QBattleScene")
local QBattleVCRScene = import("...vcr.scenes.QBattleVCRScene")
local QBattleVCR = import("...vcr.controllers.QBattleVCR")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("...ui.QUIViewController")
local QSkeletonViewController = import("...controllers.QSkeletonViewController")
local QFileCache = import("...utils.QFileCache")
local QBattleDialogAgainstRecord = import("...ui.battle.QBattleDialogAgainstRecord")
local QUIDialogFloatTip = import("...ui.dialogs.QUIDialogFloatTip")

function QEBattleViewer:ctor(options)
	-- background
	self:addChild(CCLayerColor:create(ccc4(128, 128, 128, 255), display.width, display.height))

	app.tutorial._runingStage = nil

    local menu = CCMenu:create()
    self:addChild(menu, 1)
    local button = CCMenuItemFont:create("暂停")
    button:setPosition(0 - 500, 300)
    button:setEnabled(true)
    button:registerScriptTapHandler(function()
    	self:disableSlowMotion()
    	app.battle:pause()

    	local curModalDialog = nil
        curModalDialog = QBattleDialogAgainstRecord.new({},{}) 
    end)
    menu:addChild(button)
    local button = CCMenuItemFont:create("步进")
    button:setPosition(0 - 425, 300)
    button:setEnabled(true)
    button:registerScriptTapHandler(function()
    	self:disableSlowMotion()
		app.battle:resume()
		scheduler.performWithDelayGlobal(function()
			app.battle:pause()
		end, 0)
    end)
    menu:addChild(button)
    local button = CCMenuItemFont:create("继续")
    button:setPosition(0 - 350, 300)
    button:setEnabled(true)
    button:registerScriptTapHandler(function()
    	self:disableSlowMotion()
    	app.battle:resume()
    end)
    menu:addChild(button)
    local button = CCMenuItemFont:create("慢速")
    button:setPosition(0 - 275, 300)
    button:setEnabled(true)
    button:registerScriptTapHandler(function()
    	self:toggleSlowMotion()
    end)
    menu:addChild(button)
    local button = CCMenuItemFont:create("回放")
    button:setPosition(0 - 200, 300)
    button:setEnabled(true)
    button:registerScriptTapHandler(function()
	 	-- app:loadBattleRecord()
	 	app:loadBattleRecordFromProtobuf()
		if app:getBattleRecord() then
			self:endBattle()
			self:replayBattle()
		end
    end)
    menu:addChild(button)
    local button = CCMenuItemFont:create("回流")
    button:setPosition(0 - 125, 300)
    button:setEnabled(true)
    button:registerScriptTapHandler(function()
	 	app:loadBattleRecordFromStream()
		if app:getBattleRecord() then
			self:endBattle()
			self:replayBattle()
		end
    end)
    menu:addChild(button)
    local button = CCMenuItemFont:create("副技")
    button:setPosition(0 - 50, 300)
    button:setEnabled(true)
    button:registerScriptTapHandler(function()
    	app.battle:useSupportHeroSkill(app.battle:getSupportHeroes() or app.battle:getSupportHeroes2() or app.battle:getSupportHeroes3(), true)
    end)
    menu:addChild(button)

    app.tip = {}
    local _self = self
    function app.tip:floatTip(content)
    	local tip = QUIDialogFloatTip.new({words = content})
    	function tip:removeSelf()
    		self:getView():removeFromParent()
    	end
        _self:addChild(tip:getView(), 10000)
    end
end

function QEBattleViewer:disableSlowMotion()
	if self._slowIndex ~= nil and self._slowIndex > 0 and self._slowHandler then
		self._slowIndex = 0
		self._slowHandler.destroy()
		self._slowHandler = nil
	end
end

function QEBattleViewer:toggleSlowMotion()
	if self._slowMax == nil then
		self._slowMax = 2
	end
	if self._slowIndex == nil then
		self._slowIndex = 0
	end

	self._slowIndex = (self._slowIndex + 1) % self._slowMax
	if self._slowIndex > 0 and self._slowHandler == nil then
	    local obj = {}
    	local function pause()	
			if obj._ended then
				return
			end	

    		scheduler.performWithDelayGlobal(function()
    			if obj._ended then
    				return
    			end
    			app.battle:pause()
    			obj.resume()
    		end, 0)
    	end
    	local function resume()		
			if obj._ended then
				return
			end
			
			local sharedScheduler = CCDirector:sharedDirector():getScheduler()
			local count = math.pow(2, self._slowIndex - 1)
		    local handle 
		    handle = sharedScheduler:scheduleScriptFunc(function()
		    	count = count - 1
		    	if count == 0 then
		        	sharedScheduler:unscheduleScriptEntry(handle)
	    			if obj._ended then
	    				return
	    			end
	    			app.battle:resume()
	    			obj.pause()
		    	end
		    end, 0, false)
    	end
    	obj = {pause = pause, resume = resume}
    	obj.pause()
	    obj.destroy = function()
	    	obj._ended = true
	    	app.battle:resume()
	   	end
	    self._slowHandler = obj
	elseif self._slowIndex == 0 and self._slowHandler ~= nil then
		self._slowHandler.destroy()
		self._slowHandler = nil
	end
end

function QEBattleViewer:cleanup()
	self:endBattle()
end

function QEBattleViewer:onReceiveData(message)
	if message == nil then
		return
	end

	self._message = message
	self:onResetBattle()
end

function QEBattleViewer:endBattle()
	if app.grid then
    	app.grid:pauseMoving()
    end
    if app.scene then
    	app.scene:setBattleEnded(true)
	    app.scene:removeFromParentAndCleanup(true)
	    app.scene = nil
    end
end

function QEBattleViewer:replayBattle()
	local record = app:getBattleRecord()
	if not record then
		return
	end

	local config = record.dungeonConfig
	config.isEditor = true
	config.isReplay = true
	config.replayTimeSlices = record.recordTimeSlices
	config.replayRandomSeed = record.recordRandomSeed

    local scene = QBattleScene.new(config)
    self:addChild(scene)

    local label = CCLabelTTF:create("REPLAY", global.font_default, 50)
    label:setColor(ccc3(255, 0, 0))
    label:setPositionX(CONFIG_SCREEN_WIDTH - 75)
    label:setPositionY(CONFIG_SCREEN_HEIGHT - 25)
	scene:addChild(label, 10000)
	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(0.5))
	arr:addObject(CCCallFunc:create(function() label:setVisible(not label:isVisible()) end))
	label:runAction(CCRepeatForever:create(CCSequence:create(arr)))
end

function QEBattleViewer:onResetBattle()
	local msg = self._message
	local dungeonId = msg.dungeon
	local database = QStaticDatabase:sharedDatabase()
	local config = q.cloneShrinkedObject(database:getDungeonConfigByID(dungeonId))
	assert(config, "no dungeon for " .. dungeonId .. "!")

	config.heroInfos = {}
	config.supportHeroInfos = {}
	local override_properties = {}
	local support_override_properties = {}

	if msg.enableH1 > 0 then
		local hero = 
		{
			actorId = msg.characterH1,
			heroId = "EditorHero1",
			level = msg.levelH1,
			skills = {},
			ranCode = "R0",
			EXP = 100,
			POSITION = {X = 0, Y = 0},
		}
		local skills = {}
		for i = 1, 11 do
			level = msg["s" .. i .. "H1"]
			if level and level ~= 0 then
				local skill_id = database:getSkillByActorAndSlot(hero.actorId, i)
				if skill_id then
					table.insert(skills, skill_id .. "," .. level)
				end
			end
		end
		local addSkill = string.split(msg.addSkillH1 or "", ";")
		for i = #addSkill, 1, -1 do
			local str = addSkill[i]
			if string.find(str, "godSkillLevel") then
				local level = string.split(str, "=")[2]
				hero.godSkillGrade = tonumber(level)
				table.remove(addSkill, i)
			end
		end
		table.mergeForArray(skills, addSkill)
		hero.skills = skills
		table.insert(config.heroInfos, hero)

		local override_property = {}
		override_property.hp = msg.hpH1
		override_property.atk = msg.atkH1
		table.insert(override_properties, override_property)
	end

	if msg.enableH2 > 0 then
		local hero = 
		{
			actorId = msg.characterH2,
			heroId = "EditorHero1",
			level = msg.levelH2,
			skills = {},
			ranCode = "R0",
			EXP = 100,
			POSITION = {X = 0, Y = 0},
		}
		local skills = {}
		for i = 1, 11 do
			level = msg["s" .. i .. "H2"]
			if level and level ~= 0 then
				local skill_id = database:getSkillByActorAndSlot(hero.actorId, i)
				if skill_id then
					table.insert(skills, skill_id .. "," .. level)
				end
			end
		end
		local addSkill = string.split(msg.addSkillH2 or "", ";")
		for i = #addSkill, 1, -1 do
			local str = addSkill[i]
			if string.find(str, "godSkillLevel") then
				local level = string.split(str, "=")[2]
				hero.godSkillGrade = tonumber(level)
				table.remove(addSkill, i)
			end
		end
		table.mergeForArray(skills, addSkill)
		hero.skills = skills
		table.insert(config.heroInfos, hero)

		local override_property = {}
		override_property.hp = msg.hpH2
		override_property.atk = msg.atkH2
		table.insert(override_properties, override_property)
	end

	if msg.enableH3 > 0 then
		local hero = 
		{
			actorId = msg.characterH3,
			heroId = "EditorHero1",
			level = msg.levelH3,
			skills = {},
			ranCode = "R0",
			EXP = 100,
			POSITION = {X = 0, Y = 0},
		}
		local skills = {}
		for i = 1, 11 do
			level = msg["s" .. i .. "H3"]
			if level and level ~= 0 then
				local skill_id = database:getSkillByActorAndSlot(hero.actorId, i)
				if skill_id then
					table.insert(skills, skill_id .. "," .. level)
				end
			end
		end
		local addSkill = string.split(msg.addSkillH3 or "", ";")
		for i = #addSkill, 1, -1 do
			local str = addSkill[i]
			if string.find(str, "godSkillLevel") then
				local level = string.split(str, "=")[2]
				hero.godSkillGrade = tonumber(level)
				table.remove(addSkill, i)
			end
		end
		table.mergeForArray(skills, addSkill)
		hero.skills = skills
		table.insert(config.heroInfos, hero)

		local override_property = {}
		override_property.hp = msg.hpH3
		override_property.atk = msg.atkH3
		table.insert(override_properties, override_property)
	end

	if msg.enableH4 > 0 then
		local hero = 
		{
			actorId = msg.characterH4,
			heroId = "EditorHero1",
			level = msg.levelH4,
			skills = {},
			ranCode = "R0",
			EXP = 100,
			POSITION = {X = 0, Y = 0},
		}
		local skills = {}
		for i = 1, 11 do
			level = msg["s" .. i .. "H4"]
			if level and level ~= 0 then
				local skill_id = database:getSkillByActorAndSlot(hero.actorId, i)
				if skill_id then
					table.insert(skills, skill_id .. "," .. level)
				end
			end
		end
		local addSkill = string.split(msg.addSkillH4 or "", ";")
		for i = #addSkill, 1, -1 do
			local str = addSkill[i]
			if string.find(str, "godSkillLevel") then
				local level = string.split(str, "=")[2]
				hero.godSkillGrade = tonumber(level)
				table.remove(addSkill, i)
			end
		end
		table.mergeForArray(skills, addSkill)
		hero.skills = skills
		table.insert(config.heroInfos, hero)

		local override_property = {}
		override_property.hp = msg.hpH4
		override_property.atk = msg.atkH4
		table.insert(override_properties, override_property)
	end

	if msg.enableS1 > 0 then
		local hero = 
		{
			actorId = msg.characterS1,
			heroId = "EditorSero1",
			level = msg.levelS1,
			skills = {},
			ranCode = "R0",
			EXP = 100,
			POSITION = {X = 0, Y = 0},
		}
		local skills = {}
		for i = 1, 11 do
			level = msg["s" .. i .. "S1"]
			if level and level ~= 0 then
				local skill_id = database:getSkillByActorAndSlot(hero.actorId, i)
				if skill_id then
					table.insert(skills, skill_id .. "," .. level)
				end
			end
		end
		local addSkill = string.split(msg.addSkillS1 or "", ";")
		for i = #addSkill, 1, -1 do
			local str = addSkill[i]
			if string.find(str, "godSkillLevel") then
				local level = string.split(str, "=")[2]
				hero.godSkillGrade = tonumber(level)
				table.remove(addSkill, i)
			end
		end
		table.mergeForArray(skills, addSkill)
		hero.skills = skills
		table.insert(config.supportHeroInfos, hero)

		local override_property = {}
		override_property.hp = msg.hpS1
		override_property.atk = msg.atkS1
		table.insert(support_override_properties, override_property)
	end

	if msg.enableS2 > 0 then
		local hero = 
		{
			actorId = msg.characterS2,
			heroId = "EditorSero1",
			level = msg.levelS2,
			skills = {},
			ranCode = "R0",
			EXP = 100,
			POSITION = {X = 0, Y = 0},
		}
		local skills = {}
		for i = 1, 11 do
			level = msg["s" .. i .. "S2"]
			if level and level ~= 0 then
				local skill_id = database:getSkillByActorAndSlot(hero.actorId, i)
				if skill_id then
					table.insert(skills, skill_id .. "," .. level)
				end
			end
		end
		local addSkill = string.split(msg.addSkillS2 or "", ";")
		for i = #addSkill, 1, -1 do
			local str = addSkill[i]
			if string.find(str, "godSkillLevel") then
				local level = string.split(str, "=")[2]
				hero.godSkillGrade = tonumber(level)
				table.remove(addSkill, i)
			end
		end
		table.mergeForArray(skills, addSkill)
		hero.skills = skills
		table.insert(config.supportHeroInfos, hero)

		local override_property = {}
		override_property.hp = msg.hpS2
		override_property.atk = msg.atkS2
		table.insert(support_override_properties, override_property)
	end

	if msg.enableS3 > 0 then
		local hero = 
		{
			actorId = msg.characterS3,
			heroId = "EditorSero1",
			level = msg.levelS3,
			skills = {},
			ranCode = "R0",
			EXP = 100,
			POSITION = {X = 0, Y = 0},
		}
		local skills = {}
		for i = 1, 11 do
			level = msg["s" .. i .. "S3"]
			if level and level ~= 0 then
				local skill_id = database:getSkillByActorAndSlot(hero.actorId, i)
				if skill_id then
					table.insert(skills, skill_id .. "," .. level)
				end
			end
		end
		local addSkill = string.split(msg.addSkillS3 or "", ";")
		for i = #addSkill, 1, -1 do
			local str = addSkill[i]
			if string.find(str, "godSkillLevel") then
				local level = string.split(str, "=")[2]
				hero.godSkillGrade = tonumber(level)
				table.remove(addSkill, i)
			end
		end
		table.mergeForArray(skills, addSkill)
		hero.skills = skills
		table.insert(config.supportHeroInfos, hero)

		local override_property = {}
		override_property.hp = msg.hpS3
		override_property.atk = msg.atkS3
		table.insert(support_override_properties, override_property)
	end

	if msg.enableS4 > 0 then
		local hero = 
		{
			actorId = msg.characterS4,
			heroId = "EditorSero1",
			level = msg.levelS4,
			skills = {},
			ranCode = "R0",
			EXP = 100,
			POSITION = {X = 0, Y = 0},
		}
		local skills = {}
		for i = 1, 11 do
			level = msg["s" .. i .. "S4"]
			if level and level ~= 0 then
				local skill_id = database:getSkillByActorAndSlot(hero.actorId, i)
				if skill_id then
					table.insert(skills, skill_id .. "," .. level)
				end
			end
		end
		local addSkill = string.split(msg.addSkillS4 or "", ";")
		for i = #addSkill, 1, -1 do
			local str = addSkill[i]
			if string.find(str, "godSkillLevel") then
				local level = string.split(str, "=")[2]
				hero.godSkillGrade = tonumber(level)
				table.remove(addSkill, i)
			end
		end
		table.mergeForArray(skills, addSkill)
		hero.skills = skills
		table.insert(config.supportHeroInfos, hero)

		local override_property = {}
		override_property.hp = msg.hpS4
		override_property.atk = msg.atkS4
		table.insert(support_override_properties, override_property)
	end

	-- TODO 副将 编辑模式技能副将的index
	config.supportSkillHeroIndex = 1

	config.isEditor = true
	config.isReplay = false

	local heroRecords = {}
	for _, heroInfo in ipairs(config.heroInfos) do
		local id = tonumber(heroInfo.actorId)
		heroRecords[#heroRecords + 1] = id
	end
	for _, heroInfo in ipairs(config.supportHeroInfos) do
		local id = tonumber(heroInfo.actorId)
		heroRecords[#heroRecords + 1] = id
	end
	config.heroRecords = heroRecords

    local scene = QBattleScene.new(config)
    self:addChild(scene)

    local sharedScheduler = CCDirector:sharedDirector():getScheduler()
    local handle
    handle = sharedScheduler:scheduleScriptFunc(
    function()
    	if app.battle and app.battle.getHeroes then
    		sharedScheduler:unscheduleScriptEntry(handle)
    	else
    		return
    	end

	    local heroes = app.battle:getHeroes()
	    for i, hero in ipairs(heroes) do
	    	local property = override_properties[i]

	    	local hp = property.hp
	    	hp = tonumber(hp)
	    	if hp and hp ~= 0 then
			    hero:modifyPropertyValue("hp_value", hero, "+", hp)
			    hero:modifyPropertyValue("hp_percent", hero, "+", 0)
	    		hero:setFullHp()
	    	end
	    	
	    	local atk = property.atk
	    	atk = tonumber(atk)
	    	if atk and atk ~= 0 then
			    hero:modifyPropertyValue("attack_value", hero, "+", atk)
			    hero:modifyPropertyValue("attack_percent", hero, "+", 0)
	    	end
	    end

	    local supportHeroes = app.battle:getSupportHeroes()
	    for i, hero in ipairs(supportHeroes) do
	    	local property = support_override_properties[i]

	    	local hp = property.hp
	    	hp = tonumber(hp)
	    	if hp and hp ~= 0 then
			    hero:modifyPropertyValue("hp_value", hero, "+", hp)
			    hero:modifyPropertyValue("hp_percent", hero, "+", 0)
	    		hero:setFullHp()
	    	end
	    	
	    	local atk = property.atk
	    	atk = tonumber(atk)
	    	if atk and atk ~= 0 then
			    hero:modifyPropertyValue("attack_value", hero, "+", atk)
			    hero:modifyPropertyValue("attack_percent", hero, "+", 0)
	    	end
	    end

	    app.battle:_applySupportHeroAttributes()
	end, 0, false)
end

return QEBattleViewer