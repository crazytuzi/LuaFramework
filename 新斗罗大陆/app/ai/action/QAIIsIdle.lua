
local QAIAction = import("..base.QAIAction")
local QAIIsIdle = class("QAIIsIdle", QAIAction)

function QAIIsIdle:ctor( options )
    QAIIsIdle.super.ctor(self, options)
    self:setDesc("是否空闲")
end

--[[
是否处于空闲状态，判定条件:
1. actor的状态是空闲状态
2. 没有正在攻击人活着上次攻击过的对象已经被打死了
--]]
function QAIIsIdle:_evaluate(args)
    local actor = args.actor

    if not self:getOptions().ignore_attackee 
        and actor:getManualMode() == actor.AUTO and (not actor:getTarget() or actor:getTarget():isDead()) and actor._lastAttackee then
        return true
    end

    if not actor:isIdle() then return false end

    if not self:getOptions().ignore_attackee then
        local attackee = actor:getLastAttackee()
        if attackee ~= nil and not attackee:isDead() then
            assert(app.grid:hasActor(attackee) == true)
            return false
        end
    else
        if actor and actor:getTarget() and not actor:getTarget():isDead() then
            if actor:getManualMode() == actor.ATTACK then
                return false
            else
                -- 如果当前目标在攻击范围之内，则返回false
                local target = actor:getTarget()
                local actorWidth = actor:getRect().size.width / 2
                local targetWidth = target:getRect().size.width / 2
                local _, skillRange = actor:getTalentSkill():getSkillRange(true)

                local dx = math.abs(actor:getPosition().x - target:getPosition().x)
                local dy = math.abs(actor:getPosition().y - target:getPosition().y)

                if dx - actorWidth - targetWidth < skillRange and dy < skillRange * 0.6 then
                    return false
                end
            end
        end
    end

    return true
end

return QAIIsIdle