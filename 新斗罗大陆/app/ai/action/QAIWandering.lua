
local QAIAction = import("..base.QAIAction")
local QAIWandering = class("QAIWandering", QAIAction)

function QAIWandering:ctor( options )
    QAIWandering.super.ctor(self, options)
    self:setDesc("远离目标的方向移动")
end

function QAIWandering:_evaluate(args)
    local actor = args.actor
    if actor == nil or actor:isDead() == true then
        return false
    end

    if actor:isBlowingup() or actor:isBeatbacking() then
        return false
    end

    return true
end

function QAIWandering:_execute(args)
    local actor = args.actor

    -- 随机选取一个目标地点走过去
    if not self._target_position then
        if self._stay_time then
            self._stay_time = self._stay_time - (app.battle:getTime() - self._stay_time_stamp)
            if self._stay_time <= 0 then
                self._stay_time = nil 
                self._stay_time_stamp = nil
            end
        elseif self._eventListener then
            -- wait for animation end
        else
            local area = app.grid:getRangeArea()
            local current_position = actor:getPosition()
            local target_position = clone(current_position)
            if target_position.y > area.top - 15 then
                target_position.y = area.top - 15 - app.random(50, 100)
            elseif target_position.y < area.bottom + 15 then
                target_position.y = area.bottom + 15 + app.random(50, 100)
            else
                target_position.y = app.random(area.bottom, area.top)
            end
            if target_position.x < area.left + 80 then
                target_position.x = area.left + 80 + app.random(50, 100)
            elseif target_position.x > area.right - 45 then
                target_position.x = area.right - 45 - app.random(50, 100)
            else
                target_position.x = app.random(area.left, area.right)
            end
            app.grid:moveActorTo(actor, target_position, false, true)
            self._target_position = target_position
        end
    else
        if q.is2PointsClose(self._target_position, actor:getPosition()) or not actor:isWalking() then
            self._target_position = nil

            -- self._stay_time = app.random(0.5, 1.0)
            -- self._stay_time_stamp = app.battle:getTime()

            local animations = self._options.animations
            if animations and #animations > 0 then
                local name = animations[app.random(1, #animations)]
                local view = app.scene:getActorViewFromModel(actor)
                if view:getSkeletonActor():canPlayAnimation(name) then
                    actor:playSkillAnimation({name}, false)
                    self._eventListener = cc.EventProxy.new(actor)
                    self._eventListener:addEventListener(actor.ANIMATION_ENDED, function()
                        self._eventListener:removeAllEventListeners()
                        self._eventListener = nil
                    end)
                end
            else
                local skill_id = self._options.skill_id
                local behaviors = self._options.behaviors
                if skill_id and behaviors and #behaviors > 0 then
                    local behavior = behaviors[app.random(1, #behaviors)]
                    local skill = actor:getSkillWithId(skill_id)
                    skill:set("skill_behavior", behavior)
                    actor:attack(skill)
                    self._eventListener = cc.EventProxy.new(actor)
                    self._eventListener:addEventListener(actor.SKILL_END, function()
                        self._eventListener:removeAllEventListeners()
                        self._eventListener = nil
                    end)
                end
            end
        end
    end

    return true
end

return QAIWandering