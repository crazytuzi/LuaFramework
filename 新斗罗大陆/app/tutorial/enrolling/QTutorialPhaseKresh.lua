local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhaseKresh = class("QTutorialPhaseKresh", QTutorialPhase)

local QUIWidgetBattleTutorialDialogue = import("...ui.widgets.QUIWidgetBattleTutorialDialogue")
local QTimer = import("...utils.QTimer")
local QActor = import("...models.QActor")
local QBaseActorView = import("...views.QBaseActorView")
local QBaseEffectView = import("...views.QBaseEffectView")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QBattleManager = import("...controllers.QBattleManager")

function QTutorialPhaseKresh:start()
	local dungeon = app.battle._dungeonConfig
	if dungeon.monster_id == "wailing_caverns_4" then

	else
		self:finished()
	end
end

function QTutorialPhaseKresh:visit()
	if self._revolving then
        if self._updateWaitSkillOver then
            self._updateWaitSkillOver()
        end
        return
	end

	local enemies = app.battle:getEnemies()
	local kresh = nil
	for _, enemy in ipairs(enemies) do
		if enemy:getActorID() == 3086 then
			kresh = enemy
			break
		end
	end

	if not kresh then
		return
	end

	local revolving = nil
    if kresh:getCurrentSkill() and kresh:getCurrentSkill():getId() == 50602 then
        revolving = true
    end

    if revolving then
        self._proxy = cc.EventProxy.new(self._stage._battle)
        self._proxy:addEventListener(self._stage._battle.END, handler(self, self._onBattleEnd))

    	self._revolving = true
    	self._kresh = kresh
    	app.battle:performWithDelay(function()
        	self:_showTutorial()
    	end, 0.8, nil, true)
    end
end

function QTutorialPhaseKresh:_showTutorial()
	-- local actor = self._kresh:getTarget()
    local actor = app.battle:getHeroes()[1]
	self._actor = actor

    if actor == nil then
        return
    end

    -- if q.distOf2Points(actor:getPosition(), self._kresh:getPosition()) > 400 then
    --     return
    -- end

    self._updateWaitSkillOver = function()
        local skill = actor:getCurrentSkill()
        if skill and skill:isAllowMoving() == false then
            return
        else
            self._updateWaitSkillOver = nil
        end

    	local start_pos = clone(actor:getPosition_Stage())
    	start_pos.y = start_pos.y + 20
        -- local right = nil
        -- if start_pos.x >= (BATTLE_AREA.left + BATTLE_AREA.width / 4) and start_pos.x <= (BATTLE_AREA.left + BATTLE_AREA.width / 1.33333) then
        --     right = actor:getPosition().x < self._kresh:getPosition().x
        -- else
        --     right = start_pos.x > (BATTLE_AREA.left + BATTLE_AREA.width / 2)
        -- end
        -- right = actor:getPosition().x < BATTLE_AREA.width / 2
    	local up = start_pos.y > (BATTLE_AREA.bottom + BATTLE_AREA.height / 2) 
        -- local end_pos = {x = right and (BATTLE_AREA.right - 450) or (BATTLE_AREA.left + 300), y = start_pos.y}
        local up = nil
        up = actor:getPosition().y < BATTLE_AREA.height/2
        local end_pos = {x = start_pos.x - 150, y = up and BATTLE_AREA.top - 100 or BATTLE_AREA.bottom + 200}

        self._handTouch1 = QUIWidgetTutorialHandTouch.new({id = 1002, parentNode = app.scene})
        self._handTouch1:setPosition(start_pos.x - (false and (2 * global.pixel_per_unit) or 0), start_pos.y)
        app.scene:addUI(self._handTouch1)
    	
        self._handTouch2 = QUIWidgetTutorialHandTouch.new({})
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
        	sprite:setPositionX(math.sampler(start_pos.x - (false and (2 * global.pixel_per_unit) or 0) + 40, end_pos.x + 40, (i - 1) / (hand_count - 1)))
            sprite:setPositionY(math.sampler(start_pos.y - 40, end_pos.y - 40, (i - 1) / (hand_count - 1)))
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
                actor:onDragMove(end_pos, true)
                dragged = true
            end
        end, 5.0)

        local phase = self
        function actor:onDragMove(position, isAuto)
            if not isAuto then
                app:triggerBuriedPoint(20850)
            end

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

function QTutorialPhaseKresh:_onBattleEnd()
    self._proxy:removeAllEventListeners()
    if self._actor then
    	self._actor.onDragMove = QActor.onDragMove
    end
    app.battle.pause = QBattleManager.pause
    app.battle.resume = QBattleManager.resume
end

return QTutorialPhaseKresh