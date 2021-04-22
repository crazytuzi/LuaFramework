local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhaseMutanus = class("QTutorialPhaseMutanus", QTutorialPhase)

local QUIWidgetBattleTutorialDialogue = import("...ui.widgets.QUIWidgetBattleTutorialDialogue")
local QTimer = import("...utils.QTimer")
local QActor = import("...models.QActor")
local QBaseActorView = import("...views.QBaseActorView")
local QBaseEffectView = import("...views.QBaseEffectView")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QBattleManager = import("...controllers.QBattleManager")

function QTutorialPhaseMutanus:start()
    local dungeon = app.battle._dungeonConfig
    if dungeon.monster_id == "wailing_caverns_1" then

    else
        self:finished()
    end
end

function QTutorialPhaseMutanus:visit()
    if self._found == true then
        if self._updateWaitSkillOver then
            self._updateWaitSkillOver()
        end
        return
    end

    -- 等待毒雾(trap的释放)
    if not self._trapTutorial then
        for _, trapDirector in ipairs(app.battle:getTrapDirectors()) do
            if trapDirector:getTrap():getId() == "xinmantuoluoshewang_dutan" then
                local trap = trapDirector:getTrap()
                self._kresh = trap:getTrapOwner()
                local actor = app.battle:getHeroes()[1]
                self:_showTutorial(actor, false)
                self._found = true
                self._trapTutorial = true
                return
            end
        end
    end

    local enemies = app.battle:getEnemies()
    for _, enmey in ipairs(enemies) do
        local skill = enmey:getCurrentSkill()
        if nil ~= skill and skill:getId() == 51313 then
            self._kresh = enmey
            local actor = app.battle:getHeroes()[1]
            self:_showTutorial(actor, true)
            self._found = true
            return
        end
    end
end

function QTutorialPhaseMutanus:_showTutorial(actor, isFinished)
    if actor == nil then
        return
    end

    local _changeRage = actor._changeRage
    function actor:_changeRage(dRage, ...)
        if self:getRage() + dRage < self:getRageTotal() 
            or app.battle:getCurrentWave() > 1 then
            _changeRage(self, dRage, ...)
        end
    end

    self._updateWaitSkillOver = function()
        if self._oneSecondStart == nil then
            self._oneSecondStart = app.battle:getTimeLeft()
        end
        if self._oneSecondStart - app.battle:getTimeLeft() < 4.0 then
            return
        end

        local start_pos = clone(actor:getPosition_Stage())
        start_pos.y = start_pos.y + 20
        local up = start_pos.y > (BATTLE_AREA.bottom + BATTLE_AREA.height / 2) 
        local end_pos = {x = 450, y = up and (start_pos.y - 100) or (start_pos.y + 100)}

        self._handTouch1 = QUIWidgetTutorialHandTouch.new({id = 1001, parentNode = app.scene})
        self._handTouch1:setPosition(start_pos.x - (false and (2 * global.pixel_per_unit) or 0), start_pos.y)
        app.scene:addUI(self._handTouch1)
    
        self._handTouch2 = QUIWidgetTutorialHandTouch.new({})
        self._handTouch2:setPosition(end_pos.x, end_pos.y)
        app.scene:addUI(self._handTouch2)

        local hands = {}
        local hand_count = 20
        local spriteFrameName = QSpriteFrameByPath("ui/Newplayer/Hands.png")
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

        app.scene:visibleBackgroundLayer(true, actor, 0.1)
        app.battle:pause()

        local dragged = false
        scheduler.performWithDelayGlobal(function()
            if app.battle == nil or app.battle:isBattleEnded() then
                return
            end
            self._found = false
            if dragged == false then
                actor:onDragMove(end_pos, true)
                dragged = true
            end
        end, 7.5)

        local phase = self
        function actor:onDragMove(position, isAuto)
            if not isAuto then
                app:triggerBuriedPoint(20441)
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

            app.scene:visibleBackgroundLayer(false, actor, 0.1)
            app.battle:resume()

            if isFinished then
                phase:finished()
            end

            dragged = true
        end
        function app.battle:pause()
        end
        function app.battle:resume()
        end

        self._updateWaitSkillOver = nil
    end
end

function QTutorialPhaseMutanus:_onBattleEnd()
    self._proxy:removeAllEventListeners()
    if self._actor then
        self._actor.onDragMove = QActor.onDragMove
    end
    app.battle.pause = QBattleManager.pause
    app.battle.resume = QBattleManager.resume
end

return QTutorialPhaseMutanus