local QTutorialStoryLine

local QTutorialPhase = import("..QTutorialPhase")
local QTutorialStoryLine = class("QTutorialStoryLine", QTutorialPhase)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QSkeletonViewController = import("...controllers.QSkeletonViewController")
local QBattleManager = import("...controllers.QBattleManager")
local QSkill = import("..models.QSkill")
local QActor = import("..models.QActor")

local QUIWidgetBattleTutorialDialogue = import("...ui.widgets.QUIWidgetBattleTutorialDialogue")

local luaType = type
local luaIpairs = ipairs
local luaPairs = pairs
local luaInsert = table.insert
local luaTonumber = tonumber
local luaRemove = table.remove
local waveIndex = {wave1 = 1, wave2 = 2, wave3 = 3}
local indexWave = {"wave1", "wave2", "wave3"}

function QTutorialStoryLine:ctor(stage)
	QTutorialStoryLine.super.ctor(self, stage)

	self:_initSkipButton()
	self._tutorialObjs = {}
	self._passTime = 0
	self._wave = 1
	self._willPassTime = nil
	self._createActors = {}
	self._playerHeroes = {}
	self._maxWave = 1 
	-- self._battleGear = nil
	-- self._directorGear = nil

	self:_createTouchNode()
	self.reverseMoveList = {} --倒退魂师的列表
	self:_initTutorialFunctions()
	set_story_uuid(0)
end

function QTutorialStoryLine:_initTutorialFunctions()
	local action_list = {}
	action_list["speak"] = handler(self,QTutorialStoryLine.tutorialSpeak)
	action_list["turn"] = handler(self,QTutorialStoryLine.tutorialTurn)
	action_list["skill"] = handler(self,QTutorialStoryLine.tutorialSkill)
	action_list["move"] = handler(self,QTutorialStoryLine.tutorialMove)
	action_list["action"] = handler(self,QTutorialStoryLine.tutorialAction)
	action_list["dialog"] = handler(self,QTutorialStoryLine.tutorialDialog)
	action_list["create"] = handler(self,QTutorialStoryLine.tutorialCreate)
	action_list["remove"] = handler(self,QTutorialStoryLine.tutorialRemove)
	action_list["reverse_move"] = handler(self,QTutorialStoryLine.tutorialReverseMove)
	action_list["play_sound"] = handler(self,QTutorialStoryLine.tutorialPlaySound)
	action_list["play_music"] = handler(self,QTutorialStoryLine.tutorialPlayMusic)
	action_list["surprise"] = handler(self,QTutorialStoryLine.tutorialSurprise)
	action_list["hide_view"] = handler(self,QTutorialStoryLine.tutorialHideView)
	action_list["show_view"] = handler(self,QTutorialStoryLine.tutorialShowView)
	action_list["hero_enter"] = handler(self,QTutorialStoryLine.tutorialHeroEnter)
	action_list["play_dragon_soul"] = handler(self, QTutorialStoryLine.tutorialDragonBackSoul)
	action_list["play_weather_effect"] = handler(self, QTutorialStoryLine.tutorialWeatherEffect)
	self._action_list = action_list
end

function QTutorialStoryLine:_initSkipButton()
    -- 增加跳过按钮
    local ccbi = "Widget_tiaoguo.ccbi"
    local node = CCBuilderReaderLoad(ccbi, CCBProxy:create(), {onTriggerSkip = function ( ... )
		self:pause()
    end})
	node:setVisible(false)
    node:setPosition(73, display.height - 31)
    CalculateBattleUIPosition(node)
    app.scene:addChild(node, 100001)
    self._skipButton = node
    self._skipButtonPos = node:getParent():convertToWorldSpace(ccp(node:getPosition()))
end

function QTutorialStoryLine:start()
	local success = self:_initTutorial()

	local curBattleWave = app.battle:getCurrentWave()
	if curBattleWave == 0 then curBattleWave = 1 end
	if not success or curBattleWave ~= self._wave then
		self:pause()
		return
	end
	
	self._pause = false
	self:battlePause()
	self._skipButton:setVisible(true)
	app.scene._uiLayer:setVisible(false)
	if nil ~= app.scene._touchController then
		app.scene._touchController:disableTouchEvent()
	end
end

function QTutorialStoryLine:_initTutorial()
	local db = QStaticDatabase:sharedDatabase()
	local config = clone(db:getStorylineById(app.battle:getDungeonConfig().id))
	if nil == config then
		self:finished()
		return false
	end
	self._tutorialObjs = {}
	self._maxWave = config.maxWave
	local curTutorialInfo = config[indexWave[self._wave]]	
	if nil == curTutorialInfo then
		return false
	end

	local createPlayerHero = false

	for key, tutorialInfo in ipairs(curTutorialInfo) do
		if tutorialInfo.action == "create" and not tutorialInfo.initlize then
			local actor = self:createNpc(tutorialInfo)
			self._createActors[tutorialInfo.id] = actor
			local tab = {actor = {npc = actor}, time = tutorialInfo.time,
				action = tutorialInfo.action, tutorial = tutorialInfo.tutorial, ended = false}
			luaInsert(self._tutorialObjs, tab)
			tutorialInfo.initlize = true
		end
		if tutorialInfo.action == "hero_enter" then
			createPlayerHero = true
		end
	end
	-- create hero
	for k, v in luaIpairs(curTutorialInfo) do
		if not v.initlize then
			local actor = self._createActors[v.id] 
			local tab = {actor = {npc = actor}, time = v.time,
				action = v.action, tutorial = v.tutorial, ended = false}
			luaInsert(self._tutorialObjs, tab)
			v.initlize = true
		end
	end
	--create player hero
	if createPlayerHero then
		for i,heroInfo in ipairs(app.battle:getDungeonConfig().heroInfos) do
			local actor = app.battle:_createHero(heroInfo, nil, nil, true, true) 
			self._createActors[actor:getId()] = actor
			table.insert(self._playerHeroes, actor)
			app.battle:dispatchEvent({name = app.battle.NPC_CREATED, npc = actor, pos = {x = 0, y = 0}, isBoss = false})
		end
	end
	return true
end

function QTutorialStoryLine:createNpc(info)
	local db = QStaticDatabase:sharedDatabase()
	local str = string.split(info.tutorial, ";")
	local characterInfo = db:getCharacterByID(info.actorID)
	local actor = app:createNpc(luaTonumber(str[1]), nil, nil, nil, true, nil, true)
	local skill = QSkill.new(9, {}, actor)
	function actor:getTalentSkill() return skill end

	local event = {name = app.battle.NPC_CREATED, npc = actor, pos = {x = luaTonumber(str[2]), y = luaTonumber(str[3])}, isBoss = false, noreposition = true}
	app.battle:dispatchEvent(event)
	local view = app.scene:getActorViewFromModel(actor)
	if view then
		view:setVisible(false)
		-- view:showName()
	end
	luaInsert(app.battle._enemies, actor)

    return actor
end

function QTutorialStoryLine:visit(dt)
	if self._pause == true or self._wave == 0 then
		return
	end

	for k, v in luaPairs(self._createActors) do
		if v:isDead() then
            app.battle:dispatchEvent({name = QBattleManager.NPC_CLEANUP, npc = v})
            app.battle:dispatchEvent({name = QBattleManager.NPC_DEATH_LOGGED, npc = v})
        else
        	for _, sb in ipairs(v._sbDirectors) do
        		sb:visit(dt)
        	end
        	local canStop = app.grid:_handleActorMove(v, dt)
        	if canStop then
        		v:stopMoving()
        	end
		end
	end

	for k,v in pairs(self.reverseMoveList) do
		if self:onReverseMove(v,dt) then
			v.actor:stopDoing()
			v.actor.canMove = QActor.canMove
			self.reverseMoveList[k] = nil
		end
	end

	self._passTime = self._passTime + dt	
	local objs = self._tutorialObjs
	if #objs > 0 then
		local all_ended = true
		for index, obj in luaIpairs(objs) do
			if not (obj.ended or self._passTime < obj.time) then 
				obj.ended = self._action_list[obj.action](obj)
			end
			all_ended = all_ended and obj.ended
		end
		if all_ended then
			if nil == self._willPassTime then
				self._willPassTime = self._passTime
			end
			if self._passTime - self._willPassTime >= 2 then
				self._willPassTime = nil
				self:pause()
			end
		end
	end
end

function QTutorialStoryLine:tutorialHideView(obj)
	local view = app.scene:getActorViewFromModel(obj.actor.npc)
	if view then
		view:setVisible(false)
	end
	return true
end

function QTutorialStoryLine:tutorialShowView(obj)
	local view = app.scene:getActorViewFromModel(obj.actor.npc)
	if view then
		view:setVisible(true)
	end
	return true
end

function QTutorialStoryLine:tutorialSurprise(obj)
	obj.actor.npc:showCCB("ccb/effects/gantanhao.ccbi","start",7/30 + 1.5)
	return true
end

function QTutorialStoryLine:tutorialPlayMusic(obj)
	app.sound:playMusic(obj.tutorial)
	return true
end

function QTutorialStoryLine:tutorialWeatherEffect(obj)
	app.scene:playWeatherEffect(tonumber(obj.tutorial))
	return true
end

function QTutorialStoryLine:tutorialPlaySound(obj)
	app.sound:playSound(obj.tutorial)
	return true
end

function QTutorialStoryLine:onReverseMove(msg,dt)
	local actor = msg.actor
	msg.totalTime = msg.totalTime + dt
    msg.totalTime = math.min(msg.time, msg.totalTime)
    local percent = msg.totalTime / msg.time
    local newx = math.round(msg.startPos.x * (1 - percent) + msg.endPos.x * percent)
    local newy = math.round(msg.startPos.y * (1 - percent) + msg.endPos.y * percent)

    if actor:isFlipX() then
        newx = math.min(BATTLE_AREA.right, newx)
    else
        newx = math.max(BATTLE_AREA.left, newx)
    end

	local _, gridPos = app.grid:_toGridPos(newx, newy)
	app.grid:_resetActorFollowStatus(actor)
	app.grid:_setActorGridPos(actor, gridPos, nil, true)
	actor:setActorPosition({x = newx,y = newy})

	if msg.totalTime >= msg.time then
        return true
    end
	return false
end

--因为只是做表现，所以魂师倒退尽量不修改QPositionDirector的代码
function QTutorialStoryLine:tutorialReverseMove(obj) 
	local strs = string.split(obj.tutorial,";")
	local time = tonumber(strs[3]) or 0
	local endPos = {x = tonumber(strs[1]) or 0 , y = tonumber(strs[2]) or 0}
	local actor = obj.actor.npc
	local view = app.scene:getActorViewFromModel(actor)
	actor.canMove = function() return false end
	view._animationQueue = {ANIMATION.REVERSEWALK}
	view:_changeAnimation(true) --强行播放后退动画
	table.insert(self.reverseMoveList,{actor = actor,startPos = actor:getPosition(),endPos = endPos,time = time,totalTime = 0})
	return true
end

function QTutorialStoryLine:tutorialRemove(obj)
	local monster = obj.actor
	if monster.npc then
		monster.npc:cancelAllSkills()
    	local view = app.scene:getActorViewFromModel(monster.npc)
	   	table.removebyvalue(app.scene:getEnemyViews(), view) 
	   	view:removeFromParentAndCleanup(true)
	   	app.grid:removeActor(monster.npc)
	   	table.removebyvalue(app.battle._enemies, monster.npc)	
	   	table.removebyvalue(self._tutorialObjs, monster.npc)
	   	return true
	end
end

function QTutorialStoryLine:tutorialCreate(obj)
	local monster = obj.actor
	if monster.npc then
		local view = app.scene:getActorViewFromModel(monster.npc)
		if view then
			view:setVisible(true)
		end
		return true
	end
end

function QTutorialStoryLine:tutorialTurn(obj)
	local monster = obj.actor 
	local option = string.split(obj.tutorial, ";")
	if monster.npc then
		monster.npc:setDirection(option[1])
		return true
	end
end

function QTutorialStoryLine:tutorialSpeak(obj)
	local monster = obj.actor
	local option = string.split(obj.tutorial, ";")
	if monster.npc then
		local str = option[1]
		local duration = luaTonumber(option[2])
		local speakType = luaTonumber(option[3])
		monster.npc:speak(str, duration, speakType)
		return true
	end
end

function QTutorialStoryLine:tutorialSkill(obj)
	local monster = obj.actor
	local option = string.split(obj.tutorial, ";")
	if monster.npc then
		local skillId = luaTonumber(option[1])
		local level = luaTonumber(option[2])
		local skill = monster.npc:getSkills()[skillId]
		if nil == skill then
			skill = QSkill.new(skillId, {}, monster.npc, level)
		end
		monster.npc:attack(skill)
		return true
	end
end

function QTutorialStoryLine:tutorialMove(obj)
	local monster = obj.actor
	local option = string.split(obj.tutorial, ";")
	if monster.npc then
		local pos = monster.npc:getPosition()
		local newPos = clone(pos)
		newPos.x, newPos.y = newPos.x + luaTonumber(option[1]), newPos.y + luaTonumber(option[2])
		local _, gridPos = app.grid:_toGridPos(newPos.x, newPos.y)
		app.grid:_setActorGridPos(monster.npc, gridPos)
		-- app.grid:moveActorTo(monster.npc, newPos)
		return true
	end
end

function QTutorialStoryLine:tutorialAction(obj)
	local monster = obj.actor
	local option = string.split(obj.tutorial, ";")
	if monster.npc then
		local view = app.scene:getActorViewFromModel(monster.npc)
		view._animationQueue = {option[1]}
		view:_changeAnimation()
		return true
	end
end

function QTutorialStoryLine:tutorialDialog(obj)
	local monster = obj.actor
	local option = string.split(obj.tutorial, ";")
	if monster.npc then
		local word = option[1]
		local isLeftSide = option[2] == "y" and true or false
		local isSay = option[3] == "y" and true or false
		local name = option[4]
		local image = option[5]
		local nameTitle = option[6]
		local dialog = QUIWidgetBattleTutorialDialogue.new({isLeftSide = isLeftSide, text = word, isSay = isSay, name = name,nameTitle = nameTitle})
		dialog:setActorImage(image)
		self._dialog = dialog
		self._touchNode:setTouchEnabled(true)
		self:enableTouch(handler(self, self._onTouch))
		app.scene:addChild(dialog, 1000)
		self._pause = true
		return true
	end
end

function QTutorialStoryLine:clean()
    for k, v in luaPairs(self._createActors) do
    	local view = app.scene:getActorViewFromModel(v)
    	if not v:isDead() then
    		v:cancelAllSkills()
    		v:removeAllBuff()
    	end
    	if view then
		   	table.removebyvalue(app.scene:getEnemyViews(), view)
		   	view:removeFromParentAndCleanup(true)
		   	app.grid:removeActor(v)
	   	end
	   	table.removebyvalue(app.battle._enemies, v, true)
	   	table.removebyvalue(self._tutorialObjs, v)
	   	v._battleEventListener:removeAllEventListeners()
    end
	if nil ~= self._battleGear and nil ~= self._directorGear then
		-- app:setSpeedGear(self._directorGear, self._battleGear)
	end
    app.scene._uiLayer:setVisible(true)
	if nil ~= app.scene._touchController then
		app.scene._touchController:setSelectActorView(nil)
		app.scene._touchController:enableTouchEvent()
	end
end

function QTutorialStoryLine:finished()
    set_story_uuid(0)
    self.super.finished(self)
end

function QTutorialStoryLine:pause()
	self._pause = true
	if self._wave > 1 then
		for k, v in ipairs(app.battle:getHeroes()) do
			local view = app.scene:getActorViewFromModel(v)
			if view then view:setVisible(true) end
		end
	end
	self._skipButton:setVisible(false)
	self:clean()
	if self._pauseCallback then
		self:_pauseCallback()
		self._pauseCallback = nil
	end
	self:battleResume()
end

function QTutorialStoryLine:setPauseCallback(func)
	self._pauseCallback = func
end

function QTutorialStoryLine:resume()
	local curBattleWave = app.battle:getCurrentWave()
	curBattleWave = curBattleWave + 1
	self._wave = self._wave + 1
	local success = self:_initTutorial()
	if not success or curBattleWave ~= self._wave then
		self:pause()
		return
	end

	-- self._battleGear = app:getBattleSpeedGear()
	-- self._directorGear = app:getDirectorSpeedGear()
	self._passTime = 0
	self._pause = false
	self:battlePause()

	for k, v in ipairs(app.battle:getHeroes()) do
		local view = app.scene:getActorViewFromModel(v)
		if view then view:setVisible(false) end
	end
	-- app:setSpeedGear(1, 1)
	app.scene._uiLayer:setVisible(false)
	self._skipButton:setVisible(true)
	if nil ~= app.scene._touchController then
		app.scene._touchController:disableTouchEvent()
	end
end

function QTutorialStoryLine:enableTouch(func)
    self._enableTouch = true
    self._touchCallBack = func
end

function QTutorialStoryLine:disableTouch()
    self._enableTouch = false
    self._touchCallBack = nil
end

function QTutorialStoryLine:_onTouch(event)
    if event.name == "began" then
        return true
    elseif event.name == "ended" then
        if self._dialog ~= nil and self._dialog._isSaying == true and self._dialog:isVisible() then 
            self._dialog:printAllWord()
        elseif self._dialog then
            self._dialog:removeFromParent()
            self._dialog = nil
            self._pause = false
            self:disableTouch()
            self._touchNode:setTouchEnabled(false)
        end
    end
end

function QTutorialStoryLine:tutorialDragonBackSoul(obj)
	local actor = obj.actor.npc
	if actor then
		local bossId = app.battle:getUnionDragonWarBossId()
		local view = app.scene:getActorViewFromModel(actor)
		local fca_file = QStaticDatabase:sharedDatabase():getUnionDragonConfigById(bossId).fca
		if view and fca_file then
			local skeletonViewController = QSkeletonViewController.sharedSkeletonViewController()
			view._backSoulAnim = skeletonViewController:createSkeletonActorWithFile(fca_file, false)
	        view._backSoulAnim:setVisible(false)
	        view._backSoulAnim:setScale(1.3 * 4)
	        view._skeletonActor:attachNodeToBone(nil, view._backSoulAnim, false, true)
	        view._backSoulAnim:setPositionX(150)
	        view._backSoulAnim:connectAnimationEventSignal(function(eventType, trackIndex, animationName, loopCount)
	            if eventType == SP_ANIMATION_END or eventType == SP_ANIMATION_COMPLETE then
	                view._backSoulAnim:disconnectAnimationEventSignal()
	                view._skeletonActor:detachNodeToBone(view._backSoulAnim)
                	skeletonViewController:removeSkeletonActor(view._backSoulAnim)
	                view._backSoulAnim = nil
	            end
	        end)
	        if view._backSoulAnim:canPlayAnimation("variant") then
	            view._backSoulAnim:setVisible(true)
	            view._backSoulAnim:playAnimation("variant", false)
	        else
	            view._backSoulAnim:disconnectAnimationEventSignal()
	            view._skeletonActor:detachNodeToBone(view._backSoulAnim)
            	skeletonViewController:removeSkeletonActor(view._backSoulAnim)
	            view._backSoulAnim = nil
	        end
		end
	end
	return true
end

function QTutorialStoryLine:tutorialHeroEnter(obj)
	if obj.enter_start_time then
		return (self._passTime - obj.enter_start_time) > global.hero_enter_time
	end
	local heros = self._playerHeroes
    local heroCount = table.nums(heros)

    for i, hero in ipairs(heros) do
        hero:setAnimationScale(app.battle:getTimeGear(), "time_gear")
    end

    local left = BATTLE_AREA.left
    local bottom = BATTLE_AREA.bottom
    local w = BATTLE_AREA.width
    local h = BATTLE_AREA.height
    -- 魂师入场起始点
    local stopPosition = clone(HERO_POS)
    for _, position in ipairs(stopPosition) do
        position[1] = BATTLE_AREA.left + position[1] + BATTLE_AREA.width / 2
        position[2] = BATTLE_AREA.bottom + position[2] + BATTLE_AREA.height / 2
    end
    
    for i, hero in ipairs(heros) do
        local index = heroCount - i + 1
        local enterStartPosition = {x = stopPosition[index][1] - BATTLE_AREA.width / 2, y = stopPosition[index][2]}
        local enterStopPosition = {x = stopPosition[index][1], y = stopPosition[index][2]}
        app.grid:addActor(hero) -- 注意要在view创建后加入app.grid，否则只有model，没有view的情况下，有些状态消息会miss掉
        app.grid:setActorTo(hero, enterStartPosition)
        local _, gridPos = app.grid:_toGridPos(enterStopPosition.x, enterStopPosition.y)
		app.grid:_setActorGridPos(hero, gridPos)

        -- 宠物出场
        local pet = hero:getHunterPet()
        if pet then
            local startpos = clone(enterStartPosition)
            local stoppos = clone(enterStopPosition)
            startpos.x = startpos.x - 125
            stoppos.x = stoppos.x - 125
            app.grid:addActor(pet)
            app.grid:setActorTo(pet, startpos)
            local _, gridPos = app.grid:_toGridPos(stoppos.x, stoppos.y)
			app.grid:_setActorGridPos(pet, gridPos)
        end
    end

    obj.enter_start_time = self._passTime
    return false
end

function QTutorialStoryLine:_createTouchNode()
	if nil ~= self._touchNode then return end
    local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.scene:addChild(touchNode)
    touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self._onTouch))
    self._touchNode = touchNode
end

function QTutorialStoryLine:getWave()
	return self._wave
end

function QTutorialStoryLine:battlePause()
	-- app.battle:pause()
	app.battle.__pauseRecord = true
end

function QTutorialStoryLine:battleResume()
	-- app.battle:resume()
	app.battle.__pauseRecord = false
	for k, v in ipairs(app.battle:getHeroes()) do
		v:setActorPosition(v:getPosition())
	end
end

return QTutorialStoryLine
