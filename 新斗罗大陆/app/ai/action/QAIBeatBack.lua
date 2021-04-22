
local QAIAction = import("..base.QAIAction")
local QAIBeatBack = class("QAIBeatBack", QAIAction)

function QAIBeatBack:ctor( options )
    QAIBeatBack.super.ctor(self, options)
    self._last_trigger_time = self:_getTime()
    self:setDesc("反击敌人")
end

--[[
进行反击，不需要反击的情况下返回false：
这个反击策略主要用于魂师空闲的时候。还有一个反击策略用于魂师不是空闲的时候。
1. 如果没有被人攻击过则不需要反击
2. 如果攻击者已经被打死则不需要反击
--]]
function QAIBeatBack:_execute(args)
    local actor = args.actor

    local current_time = self:_getTime()

    local target = actor:getTarget()
    if target and not target:isDead() and target:isMarked() then
        return false
    elseif target and target:isDead() == false and (current_time - self._last_trigger_time) < (self:getOptions().interval or 0) then
        return false
    end

    local attacker = actor:getLastAttacker()
    if attacker == nil or attacker:isDead() then return false end

    if self:getOptions().without_move then
        local actorWidth = actor:getRect().size.width / 2
        local targetWidth = attacker:getRect().size.width / 2
        local _, skillRange = actor:getTalentSkill():getSkillRange(false)

        local dx = math.abs(actor:getPosition().x - attacker:getPosition().x)
        local dy = math.abs(actor:getPosition().y - attacker:getPosition().y)

        if dx - actorWidth - targetWidth >= skillRange or dy >= skillRange * 0.6 then
        	return false
        end
    end

    actor:setTarget(attacker)
    self._last_trigger_time = current_time
    return QAIBeatBack.super._execute(self, args)
end

function QAIBeatBack:_getTime()
    return app.battle:getDungeonDuration() - app.battle:getTimeLeft()
end

return QAIBeatBack