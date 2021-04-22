local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhaseLakezuo = class("QTutorialPhaseLakezuo", QTutorialPhase)

local QUIWidgetBattleTutorialDialogue = import("...ui.widgets.QUIWidgetBattleTutorialDialogue")
local QTimer = import("...utils.QTimer")
local QActor = import("...models.QActor")
local QBaseActorView = import("...views.QBaseActorView")
local QBaseEffectView = import("...views.QBaseEffectView")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QBattleManager = import("...controllers.QBattleManager")

function QTutorialPhaseLakezuo:start()
	local dungeon = app.battle._dungeonConfig
	if dungeon.monster_id == "deadmine_8" then

	else
		self:finished()
	end
end

function QTutorialPhaseLakezuo:visit()
	if self._bloodlust then
        if self._updateWaitSkillOver then
            self._updateWaitSkillOver()
        end
        return
	end

	local enemies = app.battle:getEnemies()
	local lakezuo = nil
	for _, enemy in ipairs(enemies) do
		if enemy:getActorID() == 40148 then
			lakezuo = enemy
			break
		end
	end

	if not lakezuo then
		return
	end

	local bloodlust = nil
    for _, buff in ipairs(lakezuo._buffs) do
    	if buff:get("effect_type_1") == "physical_damage_percent_attack" and buff:get("effect_value_1") >= 1 then
    		bloodlust = true
    		break
    	end
    end

    if bloodlust then
        self._proxy = cc.EventProxy.new(self._stage._battle)
        self._proxy:addEventListener(self._stage._battle.END, handler(self, self._onBattleEnd))

    	self._bloodlust = true
    	self._lakezuo = lakezuo
    	app.battle:performWithDelay(function()
            if not app.battle:isBattleEnded() then
        	   self:_showTutorial()
            end
    	end, 1.5, nil, true)
    end
end

function QTutorialPhaseLakezuo:_showTutorial()
	local actor = self._lakezuo:getTarget()
	self._actor = actor

    if actor == nil then
        return
    end

    if q.distOf2Points(actor:getPosition(), self._lakezuo:getPosition()) > 400 then
        return
    end

    -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ui/NewPlayer.plist")
    -- local spriteFrameName = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("Hands.png")
    local spriteFrameName = QSpriteFrameByPath("ui/Newplayer/Hands.png")
    if spriteFrameName == nil then
        return
    end

    self._updateWaitSkillOver = function()
        local skill = actor:getCurrentSkill()
        if skill and skill:isAllowMoving() == false then
            return
        else
            self._updateWaitSkillOver = nil
        end

    	local start_pos = clone(actor:getPosition_Stage())
    	start_pos.y = start_pos.y + 20
        local right = nil
        if start_pos.x >= (BATTLE_AREA.left + BATTLE_AREA.width / 4) and start_pos.x <= (BATTLE_AREA.left + BATTLE_AREA.width / 1.33333) then
            right = actor:getPosition().x < self._lakezuo:getPosition().x
        else
            right = start_pos.x > (BATTLE_AREA.left + BATTLE_AREA.width / 2)
        end
    	local up = start_pos.y < (BATTLE_AREA.bottom + BATTLE_AREA.height / 2) 
    	local end_pos = {x = right and 150 or BATTLE_AREA.width - 200, y = start_pos.y}

        self._handTouch1 = QUIWidgetTutorialHandTouch.new({word = "", direction = (up and "up" or "down"), no_spotlight = true})
        self._handTouch1:setPosition(start_pos.x - (false and (2 * global.pixel_per_unit) or 0), start_pos.y)
        app.scene:addUI(self._handTouch1)
    	
        self._handTouch2 = QUIWidgetTutorialHandTouch.new({word = "滑动人物远离boss", direction = (up and "up" or "down"), no_spotlight = true})
        self._handTouch2:setPosition(end_pos.x, end_pos.y)
        app.scene:addUI(self._handTouch2)
        
        -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ui/NewPlayer.plist")
        -- local spriteFrameName = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("Hands.png")
        local spriteFrameName = QSpriteFrameByPath("ui/Newplayer/Hands.png")
        local hands = {}
        local hand_count = 20
        for i = 1, hand_count do
        	local sprite = CCSprite:createWithSpriteFrame(spriteFrameName)
        	app.scene:addUI(sprite)
        	sprite:setPosition(math.sampler(start_pos.x - (false and (2 * global.pixel_per_unit) or 0) + 40, end_pos.x + 40, (i - 1) / (hand_count - 1)), start_pos.y - 40)
        	sprite:setOpacity(0)
        	hands[i] = sprite

    		local arr = CCArray:create()
    		arr:addObject(CCDelayTime:create((i - 1) * 0.05 + 0.5))
    		arr:addObject(CCFadeOut:create(0.2))
    		arr:addObject(CCDelayTime:create((hand_count - i) * 0.05))
        	sprite:runAction(CCRepeatForever:create(CCSequence:create(arr)))
        end
        self._hands = hands
        self._hands[1]:setOpacity(255)
        self._hands[hand_count]:setOpacity(255)
        self._hands[1]:stopAllActions()
        self._hands[hand_count]:stopAllActions()

    	-- QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.EVENT_BULLET_TIME_TURN_ON, actor = actor})
    	app.scene:visibleBackgroundLayer(true, actor, 0.1)
    	app.battle:pause()

        local dragged = false
        scheduler.performWithDelayGlobal(function()
            if dragged == false then
                actor:onDragMove(end_pos)
                dragged = true
            end
        end, 5.0)

        local phase = self
        function actor:onDragMove(position)
            local actorView = app.scene:getActorViewFromModel(self)
            local adjust = actorView:convertToWorldSpace(ccp(0, 0))
            adjust.x = adjust.x - self._position.x
            adjust.y = adjust.y - self._position.y
    		if math.abs(position.x + adjust.x - end_pos.x) >= 192 or math.abs(position.y - end_pos.y) >= 192 then
    			return
    		end

        	QActor.onDragMove(actor, position)
        	actor.onDragMove = QActor.onDragMove
    	    app.battle.pause = QBattleManager.pause
    	    app.battle.resume = QBattleManager.resume

    		phase._handTouch1:removeFromParent()
    		phase._handTouch1 = nil
    		phase._handTouch2:removeFromParent()
    		phase._handTouch2 = nil

    		for _, hand in ipairs(phase._hands) do
    			hand:removeFromParent()
    		end
    		phase._hands = nil

    		-- QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.EVENT_BULLET_TIME_TURN_OFF, actor = actor})
    		app.scene:visibleBackgroundLayer(false, actor, 0.1)
    		app.battle:resume()

    		phase:finished()

            dragged = true
        end
        function app.battle:pause()
        end
        function app.battle:resume()
        end
    end
end

function QTutorialPhaseLakezuo:_onBattleEnd()
    self._proxy:removeAllEventListeners()
    if self._actor then
    	self._actor.onDragMove = QActor.onDragMove
    end
    app.battle.pause = QBattleManager.pause
    app.battle.resume = QBattleManager.resume
end

return QTutorialPhaseLakezuo