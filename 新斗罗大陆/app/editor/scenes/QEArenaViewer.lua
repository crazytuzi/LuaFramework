
local QEArenaViewer = class("QEArenaViewer", function()
    return display.newScene("QEArenaViewer")
end)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QBattleScene = import("...scenes.QBattleScene")
local QBattleVCRScene = import("...vcr.scenes.QBattleVCRScene")
local QBattleVCR = import("...vcr.controllers.QBattleVCR")
local QBattleDialogAgainstRecord = import("...ui.battle.QBattleDialogAgainstRecord")
local QUIDialogFloatTip = import("...ui.dialogs.QUIDialogFloatTip")
local QHerosUtils = import("...utils.QHerosUtils")
local QProtocol = import("...network.QProtocol")
local QBattleLog = import("...controllers.QBattleLog")

function QEArenaViewer:ctor(options)
	self._type = options.type

	-- background
	self:addChild(CCLayerColor:create(ccc4(128, 128, 128, 255), display.width, display.height))

	remote.herosUtil:initHero()

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
    
    if BATTLE_EDITOR_HIDE_MENU then
    	menu:setVisible(false)
    end


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

function QEArenaViewer:disableSlowMotion()
	if self._slowIndex ~= nil and self._slowIndex > 0 and self._slowHandler then
		self._slowIndex = 0
		self._slowHandler.destroy()
		self._slowHandler = nil
	end
end

function QEArenaViewer:toggleSlowMotion()
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

function QEArenaViewer:cleanup()
	self:endBattle()
end

function QEArenaViewer:onReceiveData(message)
	if message == nil then
		return
	end

	self._message = message
	self:onResetBattle(true)
end

function QEArenaViewer:endBattle(isWin)
	if app.grid then
    	app.grid:pauseMoving()
    end
    if app.scene then
    	app.scene:setBattleEnded(true)
	    app.scene:removeFromParentAndCleanup(true)
	    app.scene = nil
    end
    if app.editor.databaser ~= nil then
    	app.editor.databaser:onBattleEnd(isWin)
    end
end

function QEArenaViewer:replayBattle()
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

function QEArenaViewer:onResetBattle(newData)
	if self._type == 1 then
	elseif self._type == 2 then
		self:onResetBattle2(newData)
		return
	else
		assert(false, "")
	end

	if self._message == nil or self._message.team1 == nil or self._message.team2 == nil or self._message.supportTeam1 == nil or self._message.supportTeam2 == nil then
		return
	end

	printTable(self._message)

    local database = QStaticDatabase:sharedDatabase()
    local config = q.cloneShrinkedObject(database:getDungeonConfigByID("arena"))
	config.isPVPMode = true
	config.isArena = true

	local compareFunc = function(member1, member2)
			local character1 = QStaticDatabase:sharedDatabase():getCharacterByID(member1.id)
			local character2 = QStaticDatabase:sharedDatabase():getCharacterByID(member2.id)
			if character1.hatred < character2.hatred then
				return true
			elseif character1.hatred > character2.hatred then
				return false
			else
				if member1.id >= member2.id then
					return false
				else
					return true
				end
			end
		end
		
	if #self._message.team1 > 1 then
		table.sort(self._message.team1, compareFunc)
	end
	if #self._message.supportTeam1 > 1 then
		table.sort(self._message.supportTeam1, compareFunc)
	end
	if #self._message.team2 > 1 then
		table.sort(self._message.team2, compareFunc)
	end
	if #self._message.supportTeam2 > 1 then
		table.sort(self._message.supportTeam2, compareFunc)
	end

	local heroInfo = {}
	for _, member in ipairs(self._message.team1) do
		local info = {}
		info.actorId = member.id
		info.level = member.level
		info.breakthrough = member["break"]
		info.grade = member.grade
		info.rankCode = "R0"
		if member.equipment == "all" then
			info.equipments = app.editor.helper:getHeroItems(info.actorId, info.breakthrough, member.enchant)
		else
			info.equipments = {}
		end
		local isMaxLevel = true
		if member.skill ~= "max" then
			isMaxLevel = false
		end
		info.skills = app.editor.helper:getHeroSkills(info.actorId, info.level, info.breakthrough, isMaxLevel)
		table.insert(heroInfo, info)
	end
	config.heroInfos = heroInfo

	local supportHeroInfo = {}
	for _, member in ipairs(self._message.supportTeam1) do
		local info = {}
		info.actorId = member.id
		info.level = member.level
		info.breakthrough = member["break"]
		info.grade = member.grade
		info.rankCode = "R0"
		if member.equipment == "all" then
			info.equipments = app.editor.helper:getHeroItems(info.actorId, info.breakthrough, member.enchant)
		else
			info.equipments = {}
		end
		local isMaxLevel = true
		if member.skill ~= "max" then
			isMaxLevel = false
		end
		info.skills = app.editor.helper:getHeroSkills(info.actorId, info.level, info.breakthrough, isMaxLevel)
		table.insert(supportHeroInfo, info)
	end
	config.supportHeroInfos = supportHeroInfo

	local rivalInfo = {}
	for _, member in ipairs(self._message.team2) do
		local info = {}
		info.actorId = member.id
		info.level = member.level
		info.breakthrough = member["break"]
		info.grade = member.grade
		info.rankCode = "R0"
		if member.equipment == "all" then
			info.equipments = app.editor.helper:getHeroItems(info.actorId, info.breakthrough, member.enchant)
		else
			info.equipments = {}
		end
		local isMaxLevel = true
		if member.skill ~= "max" then
			isMaxLevel = false
		end
		info.skills = app.editor.helper:getHeroSkills(info.actorId, info.level, info.breakthrough, isMaxLevel)
		table.insert(rivalInfo, info)
	end
	config.pvp_rivals = rivalInfo

	local supportRivalInfo = {}
	for _, member in ipairs(self._message.supportTeam2) do
		local info = {}
		info.actorId = member.id
		info.level = member.level
		info.breakthrough = member["break"]
		info.grade = member.grade
		info.rankCode = "R0"
		if member.equipment == "all" then
			info.equipments = app.editor.helper:getHeroItems(info.actorId, info.breakthrough, member.enchant)
		else
			info.equipments = {}
		end
		local isMaxLevel = true
		if member.skill ~= "max" then
			isMaxLevel = false
		end
		info.skills = app.editor.helper:getHeroSkills(info.actorId, info.level, info.breakthrough, isMaxLevel)
		table.insert(supportRivalInfo, info)
	end
	config.pvp_rivals2 = supportRivalInfo

	-- 副将 编辑模式技能副将
	config.pvp_rivals3 = supportRivalInfo[1]

	if newData or (app:getBattleRound() or 0) == 0 then
		-- 额外参数
		local battleSpeed, battleRound = 1, 0
		local args = string.split(string.gsub(self._message.additionalArguments or "", " ", ""), "&")
		local opt,val
		for _, arg in ipairs(args) do
			arg = string.split(arg, "=")
			opt = arg[1]
			val = arg[2]
			if opt == "speed" then
				local speed = val and tonumber(val)
				speed = math.clamp(speed or 1, 1, 16)
				battleSpeed = speed
			elseif opt == "round" then
				local round = val and tonumber(val)
				round = math.max(round or 1, 1)
				battleRound = round
			end
		end
		-- time gear setting
		local directorSpeedGear = math.clamp(battleSpeed, 1, 4)
		local battleSpeedGear = math.clamp(battleSpeed / 4, 1, 4)
		app:setSpeedGear(directorSpeedGear, battleSpeedGear)
		-- battle rounds
		app:setBattleRound(battleRound)
		-- clear battle logs
		app:clearBattleLogs()
	end

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

	local pvpRivalHeroRecords = {}
	for _, heroInfo in ipairs(config.pvp_rivals) do
		local id = tonumber(heroInfo.actorId)
		pvpRivalHeroRecords[#pvpRivalHeroRecords + 1] = id
	end
	for _, heroInfo in ipairs(config.pvp_rivals2) do
		local id = tonumber(heroInfo.actorId)
		pvpRivalHeroRecords[#pvpRivalHeroRecords + 1] = id
	end
	config.pvpRivalHeroRecords = pvpRivalHeroRecords

	print("battle config:")
	printTable(config)

	local scene = QBattleScene.new(config)
    self:addChild(scene)

end

local function sortHero(heroInfos)
	local qactorcache = {}
	local forcecache = {}
	table.sort(heroInfos, function(heroInfo1, heroInfo2)
		local characterInfo1 = db:getCharacterByID(heroInfo1.actorId)
		local characterInfo2 = db:getCharacterByID(heroInfo2.actorId)
		app:removeHero(heroInfo1.actorId)
		app:removeHero(heroInfo2.actorId)
		local actor1 = qactorcache[heroInfo1.actorId] or app:createHero(heroInfo1)
		local actor2 = qactorcache[heroInfo2.actorId] or app:createHero(heroInfo2)
		qactorcache[heroInfo1.actorId] = actor1
		qactorcache[heroInfo2.actorId] = actor2
		if characterInfo1.hatred ~= characterInfo2.hatred then
			return characterInfo1.hatred < characterInfo2.hatred
		else
			local force1 = forcecache[heroInfo1.actorId] or actor1:getBattleForce(true)
			local force2 = forcecache[heroInfo2.actorId] or actor2:getBattleForce(true)
			forcecache[heroInfo1.actorId] = force1
			forcecache[heroInfo2.actorId] = force2
			if force1 ~= force2 then
				return force1 < force2
			else
				return heroInfo1.actorId < heroInfo2.actorId
			end
		end
	end)
end

local function setHeroArtifact(member)
	local ret = {}
	if member.artBrk and member.artBrk ~= "" then
		ret.artifactBreakthrough = tonumber(member.artBrk)
	end
	if member.skillPage and member.skillPage ~= "" then
		local pages = EDITOR_ARTIFACT_SKILL_PAGES or {}
		local pageNumber = tonumber(member.skillPage)
		ret.artifactSkillList = {}
		for i = 1, pageNumber do
			table.mergeForArray(ret.artifactSkillList, (pages[tonumber(member.id)]or{})[i]or{})
		end
	end
	return ret
end

local function getSoulSpiritsInfo(id, str)
	local infos  = string.split(str, ",")
	local skills = {}
	if infos[4] and infos[4] ~= "" then
		local skillInfo = string.split(infos[4], ";")
		table.insert(skills, {key = tonumber(skillInfo[1]), value = tonumber(skillInfo[2])})
	end
	return {
		id = id,
		grade = tonumber(infos[2]),
		level = tonumber(infos[1]),
		addCoefficient = tonumber(infos[3]),
		additionSkills = skills,
		exp = 0,
	}
end

function QEArenaViewer:onResetBattle2(newData)
	if self._message == nil or self._message.team1 == nil or self._message.team2 == nil or self._message.supportTeam1 == nil or self._message.supportTeam2 == nil then
		return
	end

	printTable(self._message)

    local database = QStaticDatabase:sharedDatabase()
    local config = q.cloneShrinkedObject(database:getDungeonConfigByID("arena"))
	config.isPVPMode = true
	config.isArena = true

	for i, obj in ipairs(self._message.supportTeam1) do
		obj.original_index = i
	end
	for i, obj in ipairs(self._message.supportTeam2) do
		obj.original_index = i
	end

	local compareFunc = function(member1, member2)
			local function inArea(a,b,c)
				return (a >= b and a <= c) or (a >= c and a <= b)
			end

			if member1.original_index and member2.original_index then
				if inArea(member1.original_index, 1, 4) and inArea(member2.original_index, 5, 12) then
					return true
				elseif inArea(member1.original_index, 5, 12) and inArea(member2.original_index, 1, 4) then
					return false
				elseif inArea(member1.original_index, 5, 8) and inArea(member2.original_index, 9, 12) then
					return true
				elseif inArea(member1.original_index, 9, 12) and inArea(member2.original_index, 5, 8) then
					return false
				elseif member1.id == nil and member2.id ~= nil then
					return false
				elseif member1.id ~= nil and member2.id == nil then
					return true
				elseif member1.id == nil and member2.id == nil then
					return member1.original_index < member2.original_index
				end
			end
			local character1 = QStaticDatabase:sharedDatabase():getCharacterByID(member1.id)
			local character2 = QStaticDatabase:sharedDatabase():getCharacterByID(member2.id)
			if character1.hatred < character2.hatred then
				return true
			elseif character1.hatred > character2.hatred then
				return false
			else
				if member1.id >= member2.id then
					return false
				else
					return true
				end
			end
		end
		
	if #self._message.team1 > 1 then
		table.sort(self._message.team1, compareFunc)
	end
	if #self._message.supportTeam1 > 1 then
		table.sort(self._message.supportTeam1, compareFunc)
	end
	if #self._message.team2 > 1 then
		table.sort(self._message.team2, compareFunc)
	end
	if #self._message.supportTeam2 > 1 then
		table.sort(self._message.supportTeam2, compareFunc)
	end

	local heroInfo = {}
	local userSoulSpirits = {}
	for _, member in ipairs(self._message.team1) do
		local info = {}
		info.actorId = tonumber(member.id)
		info.level = member.level
		info.breakthrough = member["break"]
		info.grade = member.grade
		info.rankCode = "R0"
		if member.equipment == "all" then
			info.equipments = app.editor.helper:getHeroItems(info.actorId, info.breakthrough, member.enchant)
		else
			info.equipments = {}
		end
		local isMaxLevel = true
		if member.skill ~= "max" then
			isMaxLevel = false
		end
		info.skills = app.editor.helper:getHeroSkills(info.actorId, info.level, info.breakthrough, isMaxLevel)
		info.gemstones = app.editor.helper:getHeroGemstones(member.gem_set, member.gem_brk, member.gem_str)
		table.insert(heroInfo, info)
		if member.mid and member.mid ~= "" then
			local zuoqiInfo = 
			{
				zuoqiId = tonumber(member.mid),
    			actorId = info.actorId,
    			grade = tonumber(member.mgrd),
    			enhanceLevel = tonumber(member.mstr),
			}
			info.zuoqi = zuoqiInfo
		end
		info.super_skill = member.super_skill == "true"
		info.artifact = setHeroArtifact(member)
		local skills = string.split(member.add_skill or "", ";")
		for i = #skills, 1, -1 do
			local str = skills[i]
			if string.find(str, "godSkillLevel") then
				local level = string.split(str, "=")[2]
				info.godSkillGrade = tonumber(level)
				table.remove(skills, i)
			end
		end
		table.mergeForArray(info.skills, skills)
		info.soulSpirits = getSoulSpiritsInfo(member.elfId, member.elfInfo)
		if member.elfOn == "true" then
			table.insert(userSoulSpirits, getSoulSpiritsInfo(member.elfId, member.elfInfo))
		end
		if member.elfOn2 == "true" then
			table.insert(userSoulSpirits, getSoulSpiritsInfo(member.elfId2, member.elfInfo2))
		end
	end
	config.heroInfos = heroInfo
	QHerosUtils.addPeripheralSkills(nil, config.heroInfos)

	sortHero(config.heroInfos)

	local supportHeroInfo = {}
	local supportHeroInfo2 = {}
	local supportHeroInfo3 = {}
	for i, member in ipairs(self._message.supportTeam1) do
		if member.id then
			local info = {}
			info.actorId = tonumber(member.id)
			info.level = member.level
			info.breakthrough = member["break"]
			info.grade = member.grade
			info.rankCode = "R0"
			if member.equipment == "all" then
				info.equipments = app.editor.helper:getHeroItems(info.actorId, info.breakthrough, member.enchant)
			else
				info.equipments = {}
			end
			local isMaxLevel = true
			if member.skill ~= "max" then
				isMaxLevel = false
			end
			info.skills = app.editor.helper:getHeroSkills(info.actorId, info.level, info.breakthrough, isMaxLevel)
			info.gemstones = app.editor.helper:getHeroGemstones(member.gem_set, member.gem_brk, member.gem_str)
			if i <= 4 then
				if member.support_skill == "true" then
					config.supportSkillHeroIndex = i
				end
				table.insert(supportHeroInfo, info)
			elseif i > 4 and i <= 8 then
				if member.support_skill == "true" then
					config.supportSkillHeroIndex2 = i - 4
				end
				table.insert(supportHeroInfo2, info)
			else
				if member.support_skill == "true" then
					config.supportSkillHeroIndex3 = i - 8
				end
				table.insert(supportHeroInfo3, info)
			end
			if member.mid and member.mid ~= "" then
				local zuoqiInfo = 
				{
					zuoqiId = tonumber(member.mid),
	    			actorId = info.actorId,
	    			grade = tonumber(member.mgrd),
	    			enhanceLevel = tonumber(member.mstr),
				}
				info.zuoqi = zuoqiInfo
			end
			info.super_skill = member.super_skill == "true"
			info.artifact = setHeroArtifact(member)
			local skills = string.split(member.add_skill or "", ";")
			for i = #skills, 1, -1 do
				local str = skills[i]
				if string.find(str, "godSkillLevel") then
					local level = string.split(str, "=")[2]
					info.godSkillGrade = tonumber(level)
					table.remove(skills, i)
				end
			end
			table.mergeForArray(info.skills, skills)
			info.soulSpirits = getSoulSpiritsInfo(member.elfId, member.elfInfo)
			if member.elfOn == "true" then
				table.insert(userSoulSpirits, getSoulSpiritsInfo(member.elfId, member.elfInfo))
			end
			if member.elfOn2 == "true" then
				table.insert(userSoulSpirits, getSoulSpiritsInfo(member.elfId2, member.elfInfo2))
			end
		end
	end

	assert(#userSoulSpirits <= 2, "hero soulSpirits more then two!!!")
	config.supportHeroInfos = supportHeroInfo
	config.supportHeroInfos2 = supportHeroInfo2
	config.supportHeroInfos3 = supportHeroInfo3
	config.userSoulSpirits = userSoulSpirits
	QHerosUtils.addPeripheralSkills(nil, config.supportHeroInfos)
	QHerosUtils.addPeripheralSkills(nil, config.supportHeroInfos2)
	QHerosUtils.addPeripheralSkills(nil, config.supportHeroInfos3)

	local rivalInfo = {}
	local enemySoulSpirits = {}
	for _, member in ipairs(self._message.team2) do
		local info = {}
		info.actorId = tonumber(member.id)
		info.level = member.level
		info.breakthrough = member["break"]
		info.grade = member.grade
		info.rankCode = "R0"
		if member.equipment == "all" then
			info.equipments = app.editor.helper:getHeroItems(info.actorId, info.breakthrough, member.enchant)
		else
			info.equipments = {}
		end
		local isMaxLevel = true
		if member.skill ~= "max" then
			isMaxLevel = false
		end
		info.skills = app.editor.helper:getHeroSkills(info.actorId, info.level, info.breakthrough, isMaxLevel)
		info.gemstones = app.editor.helper:getHeroGemstones(member.gem_set, member.gem_brk, member.gem_str)
		table.insert(rivalInfo, info)
		if member.mid and member.mid ~= "" then
			local zuoqiInfo = 
			{
				zuoqiId = tonumber(member.mid),
    			actorId = info.actorId,
    			grade = tonumber(member.mgrd),
    			enhanceLevel = tonumber(member.mstr),
			}
			info.zuoqi = zuoqiInfo
		end
		info.super_skill = member.super_skill == "true"
		info.artifact = setHeroArtifact(member)
		local skills = string.split(member.add_skill or "", ";")
		for i = #skills, 1, -1 do
			local str = skills[i]
			if string.find(str, "godSkillLevel") then
				local level = string.split(str, "=")[2]
				info.godSkillGrade = tonumber(level)
				table.remove(skills, i)
			end
		end
		table.mergeForArray(info.skills, skills)
		info.soulSpirits = getSoulSpiritsInfo(member.elfId, member.elfInfo)
		if member.elfOn == "true" then
			table.insert(enemySoulSpirits, getSoulSpiritsInfo(member.elfId, member.elfInfo))
		end
		if member.elfOn2 == "true" then
			table.insert(enemySoulSpirits, getSoulSpiritsInfo(member.elfId2, member.elfInfo2))
		end
	end
	config.pvp_rivals = rivalInfo
	QHerosUtils.addPeripheralSkills(nil, config.pvp_rivals)

	sortHero(config.pvp_rivals)

	local supportRivalInfo = {}
	local supportRivalInfo2 = {}
	local supportRivalInfo3 = {}
	for i, member in ipairs(self._message.supportTeam2) do
		if member.id then
			local info = {}
			info.actorId = tonumber(member.id)
			info.level = member.level
			info.breakthrough = member["break"]
			info.grade = member.grade
			info.rankCode = "R0"
			if member.equipment == "all" then
				info.equipments = app.editor.helper:getHeroItems(info.actorId, info.breakthrough, member.enchant)
			else
				info.equipments = {}
			end
			local isMaxLevel = true
			if member.skill ~= "max" then
				isMaxLevel = false
			end
			info.skills = app.editor.helper:getHeroSkills(info.actorId, info.level, info.breakthrough, isMaxLevel)
			info.gemstones = app.editor.helper:getHeroGemstones(member.gem_set, member.gem_brk, member.gem_str)
			if i <= 4 then
				if member.support_skill == "true" then
					config.pvp_rivals3 = info
				end
				table.insert(supportRivalInfo, info)
			elseif i <= 8 then
				if member.support_skill == "true" then
					config.pvp_rivals5 = info
				end
				table.insert(supportRivalInfo2, info)
			else
				if member.support_skill == "true" then
					config.pvp_rivals7 = info
				end
				table.insert(supportRivalInfo3, info)
			end
			if member.mid and member.mid ~= "" then
				local zuoqiInfo = 
				{
					zuoqiId = tonumber(member.mid),
	    			actorId = info.actorId,
	    			grade = tonumber(member.mgrd),
	    			enhanceLevel = tonumber(member.mstr),
				}
				info.zuoqi = zuoqiInfo
			end
			info.super_skill = member.super_skill == "true"
			info.artifact = setHeroArtifact(member)
			local skills = string.split(member.add_skill or "", ";")
			for i = #skills, 1, -1 do
				local str = skills[i]
				if string.find(str, "godSkillLevel") then
					local level = string.split(str, "=")[2]
					info.godSkillGrade = tonumber(level)
					table.remove(skills, i)
				end
			end
			table.mergeForArray(info.skills, skills)
			info.soulSpirits = getSoulSpiritsInfo(member.elfId, member.elfInfo)
			if member.elfOn == "true" then
				table.insert(enemySoulSpirits, getSoulSpiritsInfo(member.elfId, member.elfInfo))
			end
			if member.elfOn2 == "true" then
				table.insert(enemySoulSpirits, getSoulSpiritsInfo(member.elfId2, member.elfInfo2))
			end
		end
	end

	assert(#enemySoulSpirits <= 2, "enemy soulSpirits more then two!!!")
	config.pvp_rivals2 = supportRivalInfo
	config.pvp_rivals4 = supportRivalInfo2
	config.pvp_rivals6 = supportRivalInfo3
	config.enemySoulSpirits = enemySoulSpirits
	QHerosUtils.addPeripheralSkills(nil, config.pvp_rivals2)
	QHerosUtils.addPeripheralSkills(nil, config.pvp_rivals4)
	QHerosUtils.addPeripheralSkills(nil, config.pvp_rivals6)

	local isConsole = false
	if newData or (app:getBattleRound() or 0) == 0 then
		-- 额外参数
		local battleSpeed, battleRound = 1, 0
		local args = string.split(string.gsub(self._message.additionalArguments or "", " ", ""), "&")
		local opt,val
		for _, arg in ipairs(args) do
			arg = string.split(arg, "=")
			opt = arg[1]
			val = arg[2]
			if opt == "speed" then
				local speed = val and tonumber(val)
				speed = math.clamp(speed or 1, 1, 16)
				battleSpeed = speed
			elseif opt == "round" then
				local round = val and tonumber(val)
				round = math.max(round or 1, 1)
				battleRound = round
			elseif opt == "console" then
				isConsole = val == "true"
			end
		end
		-- time gear setting
		local directorSpeedGear = math.clamp(battleSpeed, 1, 4)
		local battleSpeedGear = math.clamp(battleSpeed / 4, 1, 4)
		app:setSpeedGear(directorSpeedGear, battleSpeedGear)
		-- battle rounds
		app:setBattleRound(battleRound)
		-- clear battle logs
		app:clearBattleLogs()
	end

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

	local pvpRivalHeroRecords = {}
	for _, heroInfo in ipairs(config.pvp_rivals) do
		local id = tonumber(heroInfo.actorId)
		pvpRivalHeroRecords[#pvpRivalHeroRecords + 1] = id
	end
	for _, heroInfo in ipairs(config.pvp_rivals2) do
		local id = tonumber(heroInfo.actorId)
		pvpRivalHeroRecords[#pvpRivalHeroRecords + 1] = id
	end
	config.pvpRivalHeroRecords = pvpRivalHeroRecords

	config.supportSkillEnemyIndex = 1
    if config.pvp_rivals3 then
    	local supportSkillRival = config.pvp_rivals3
        for index, info in ipairs(config.pvp_rivals2) do
            if info.actorId == supportSkillRival.actorId then
                config.supportSkillEnemyIndex = index
            end
        end
    end

	config.supportSkillEnemyIndex2 = 1
    if config.pvp_rivals5 then
    	local supportSkillRival = config.pvp_rivals5
        for index, info in ipairs(config.pvp_rivals4) do
            if info.actorId == supportSkillRival.actorId then
                config.supportSkillEnemyIndex2 = index
            end
        end
    end

	config.supportSkillEnemyIndex3 = 1
    if config.pvp_rivals7 then
    	local supportSkillRival = config.pvp_rivals7
        for index, info in ipairs(config.pvp_rivals6) do
            if info.actorId == supportSkillRival.actorId then
                config.supportSkillEnemyIndex3 = index
            end
        end
    end

    -- 神器代码
    local allHeroGodArmIdList = {}
    local heroGodArmIdList = {}
    if self._message.allHeroGodArmIdList then
    	for k, godInfo in ipairs(self._message.allHeroGodArmIdList) do
    		table.insert(heroGodArmIdList, godInfo.id)
    		table.insert(allHeroGodArmIdList, godInfo.id .. ";"..godInfo.level)
    	end
    end

    local allEnemyGodArmIdList = {}
    local enemyGodArmIdList = {}
    if self._message.allEnemyGodArmIdList then
    	for k, godInfo in ipairs(self._message.allEnemyGodArmIdList) do
    		table.insert(enemyGodArmIdList, godInfo.id)
    		table.insert(allEnemyGodArmIdList, godInfo.id .. ";"..godInfo.level)
    	end
    end

    config.allHeroGodArmIdList = allHeroGodArmIdList
    config.heroGodArmIdList = heroGodArmIdList
    config.allEnemyGodArmIdList = allEnemyGodArmIdList
    config.enemyGodArmIdList = enemyGodArmIdList

	print("battle config:")
	printTable(config)

	if isConsole then
 		self:runConsole(config)
 	else
		local scene = QBattleScene.new(config)
	    self:addChild(scene)
	end
end

function QEArenaViewer:runConsole(config)
	config.isEditor = nil
	config.isReplay = nil
	config.battleDT = 1 / 30
	local battleRecord = {
		dungeonConfig = config,
    	recordRandomSeed = os.time(),
    	recordFrameCount = 0,
    	recordTimeSlices = {},
	}
	local battleRound = app:getBattleRound()
	local subOutputs = {}
	local _EDITOR_WOW_VERIFY_PATH = EDITOR_WOW_VERIFY_PATH or os.getenv("WOW_VERIFY_PATH")
	for i = 1, battleRound do
		battleRecord.recordRandomSeed = os.time()
		app:saveBattleRecordIntoProtobuf(battleRecord)
	    local file
	    local fileutil = CCFileUtils:sharedFileUtils()
		if device.platform == "mac" then
			local wow_battle_path = _EDITOR_WOW_VERIFY_PATH and (_EDITOR_WOW_VERIFY_PATH.."/wow-battle/")
			os.execute("cp -f " .. fileutil:getWritablePath() .. "last.reppb " .. wow_battle_path .. "last.reppb")
			os.execute(wow_battle_path .. "luajit-mac " .. wow_battle_path .. "main.lua mac")
			file = io.open(wow_battle_path .. "replayOutput", "rb")
		elseif device.platform == "windows" then
			local wow_battle_path = _EDITOR_WOW_VERIFY_PATH and (_EDITOR_WOW_VERIFY_PATH.."\\wow-battle\\")
			os.execute("copy /Y " .. fileutil:getWritablePath() .. "last.reppb " .. wow_battle_path .. "last.reppb")
			os.execute(wow_battle_path .. "luajit.exe " .. wow_battle_path .. "main.lua win")
			file = io.open(wow_battle_path .. "replayOutput", "rb")
		else
			assert(false, "unknown platform " .. device.platform)
		end
		if file then
			local buffer = file:read("*all")
			file:close()
			file = nil
			local output = app:getProtocol():decodeBufferToMessage("cc.qidea.wow.client.battle.ReplayOutput", buffer)
			table.insert(subOutputs, output)
		end
	end
	config.isEditor = true
	config.isReplay = false
	local scene = QBattleScene.new(config)
    self:addChild(scene)
	scheduler.performWithDelayGlobal(function()
		local battleLog = app.battle._battleLog
		for _, output in ipairs(subOutputs) do
			local subBattleLog = QBattleLog.new()
			subBattleLog:setBattleLogFromServer(output.battleLog)
			subBattleLog:setIsWin(output.isWin or false)
			subBattleLog:setIsOvertime(output.isOvertime or false)
			battleLog:mergeStats(subBattleLog)
			app:pushBattleLog(subBattleLog)
		end
		app.battle._battleLog = battleLog
    	app.battle:pause()
    	local curModalDialog = nil
        curModalDialog = QBattleDialogAgainstRecord.new({},{})
	end, 0.5)
end

return QEArenaViewer