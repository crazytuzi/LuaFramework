--[[
    QVCRAactorView 
--]]

local QNpcActorView = import("...views.QNpcActorView")
local QVCRAactorView = class("QVCRAactorView", QNpcActorView)

local QBaseActorView = import("...views.QBaseActorView")

function QVCRAactorView:ctor(actor, skeletonView)
    QVCRAactorView.super.ctor(self, actor, skeletonView)
end

function QVCRAactorView:onEnter()
    QVCRAactorView.super.onEnter(self)
    self:setEnableTouchEvent(true)
end

function QVCRAactorView:onExit()
    QVCRAactorView.super.onExit(self)
    self:setEnableTouchEvent(false)
end

function QVCRAactorView:_onPlayEffectForSkill(event)
	QBaseActorView._onPlayEffectForSkill(self, event)
end


function QVCRAactorView:_onHit(event)
    if event.tip == "0" then return end
    
    local font = global.ui_hp_change_font_damage_hero
    if self:getModel():getType() == ACTOR_TYPES.NPC then
        font = global.ui_hp_change_font_damage_npc
    end
    if event.isTreat == false then
        local arr = CCArray:create()
        arr:addObject(CCTintTo:create(0.1, 255, 100, 100))
        arr:addObject(CCTintTo:create(0.1, self._colorOverlay.r, self._colorOverlay.g, self._colorOverlay.b))
        self._skeletonActor:runAction(CCSequence:create(arr))
    else
        font = global.ui_hp_change_font_treat
    end

    local tip = nil
    local ccbOwner = {}
    local appearDistance = 20 -- 伤害数字向上移动出现的距离
    if event.isCritical then
        if event.isTreat then
            -- tip = CCBuilderReaderLoad("effects/Attack_shanbi.ccbi", CCBProxy:create(), ccbOwner):addTo(self)
            tip = app.scene:getTip("effects/Attack_shanbi.ccbi"):addTo(self)
            ccbOwner = tip.ccbOwner
            tip:setPosition(0, self:getSize().height - appearDistance)
       else
            if self:getModel():getType() == ACTOR_TYPES.NPC then
                -- tip = CCBuilderReaderLoad("effects/Attack_Ybaoji.ccbi", CCBProxy:create(), ccbOwner):addTo(self)
                tip = app.scene:getTip("effects/Attack_Ybaoji.ccbi"):addTo(self)
                ccbOwner = tip.ccbOwner
            else
                -- tip = CCBuilderReaderLoad("effects/Attack_baoji.ccbi", CCBProxy:create(), ccbOwner):addTo(self)
                tip = app.scene:getTip("effects/Attack_baoji.ccbi"):addTo(self)
                ccbOwner = tip.ccbOwner
            end
        end
        tip:setPosition(-10, self:getSize().height)
    else
        if event.isTreat then
            -- tip = CCBuilderReaderLoad("effects/Heal_number.ccbi", CCBProxy:create(), ccbOwner):addTo(self)
            tip = app.scene:getTip("effects/Heal_number.ccbi"):addTo(self)
            ccbOwner = tip.ccbOwner
            tip:setScale(0.8)
        else
            if string.find(event.tip, "闪避") then
                if self:getModel():getType() == ACTOR_TYPES.NPC then
                    -- tip = CCBuilderReaderLoad("effects/Attack_Ynumber.ccbi", CCBProxy:create(), ccbOwner):addTo(self)
                tip = app.scene:getTip("effects/Attack_Ynumber.ccbi"):addTo(self)
                ccbOwner = tip.ccbOwner
                    tip:setScale(0.8)
                else
                    -- tip = CCBuilderReaderLoad("effects/Attack_shanbi.ccbi", CCBProxy:create(), ccbOwner):addTo(self)
                tip = app.scene:getTip("effects/Attack_shanbi.ccbi"):addTo(self)
                ccbOwner = tip.ccbOwner
                end
            else
                if self:getModel():getType() == ACTOR_TYPES.NPC then
                    -- tip = CCBuilderReaderLoad("effects/Attack_Ynumber.ccbi", CCBProxy:create(), ccbOwner):addTo(self)
                tip = app.scene:getTip("effects/Attack_Ynumber.ccbi"):addTo(self)
                ccbOwner = tip.ccbOwner
                else
                    -- tip = CCBuilderReaderLoad("effects/Attack_number.ccbi", CCBProxy:create(), ccbOwner):addTo(self)
                tip = app.scene:getTip("effects/Attack_number.ccbi"):addTo(self)
                ccbOwner = tip.ccbOwner
                end
                tip:setScale(0.8)
            end
        end
        tip:setPosition(0, self:getSize().height - appearDistance)
    end
    ccbOwner.var_text:setString(event.tip)

    local appearTime = 0.2 -- 冒伤害数字的时间
    local stayTimeScale = 0.2 -- 数字的停留时间
    local stayTimeDelay = 0.1 -- 数字的停留时间
    local elapseTime = 0.5 -- 伤害数字的消失时间

    -- 计算上一次伤害到这一次伤害数字冒出需要等待的时间，避免重复
    local wait = stayTimeScale + stayTimeDelay - (app.battle:getTime() - self._lastTipTime)

    local sequence = CCArray:create()

    if wait < 0 then
        wait = 0
    elseif wait > 0 then
        self._waitingHitTips[tip] = tip
        sequence:addObject(CCDelayTime:create(wait))
        sequence:addObject(CCCallFunc:create(
            function()
                self._waitingHitTips[tip] = nil
            end))
    end
    self._lastTipTime = app.battle:getTime() + wait

    tip:setVisible(false)

    sequence:addObject(CCCallFunc:create(
        function ()
        tip:setVisible(true)
        local animationManager = tolua.cast(tip:getUserObject(), "CCBAnimationManager")
        animationManager:runAnimationsForSequenceNamed("Default Timeline")
        animationManager:connectScriptHandler(function(animationName)
            animationManager:disconnectScriptHandler()
            tip:removeFromParent()
            if tip.need_return then
                if app.scene then
                    app.scene:returnTip(tip)
                else
                    tip:release()
                end
            end
            -- CCRemoveSelf:create(true)
        end)
    end))
   
    tip:runAction(CCSequence:create(sequence))
end

return QVCRAactorView