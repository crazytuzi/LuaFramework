
local QAIAction = import("..base.QAIAction")
local QAIPriorityBeatBack = class("QAIPriorityBeatBack", QAIAction)

function QAIPriorityBeatBack:ctor( options )
    QAIPriorityBeatBack.super.ctor(self, options)
    self:setDesc("优先反击")
end

--[[
进行反击，不需要反击的情况下返回false：
这个反击策略主要用于魂师不是空闲的时候，查找攻击列表内最近5秒打击过自己的
敌人，如果自己攻击的对象最近5秒内没有攻击过自己，同时有另一个对象在攻击自己，
则需要更改攻击目标，优先反击对自己威胁最大的敌人。
--]]
function QAIPriorityBeatBack:_execute(args)
    local actor = args.actor
    local target = actor:getTarget()

    if target and not target:isDead() and target:isMarked() then
        return false
    end

    if target and actor:getLastAttacker() ~= target then
        return false
    end

    local enemies = actor:getHitLog():getEnemiesInPeriod(self:getOptions().period)

    -- 如果正在攻击的敌人在规定时间内攻击过自己，则不切换攻击目标
    if table.find(enemies, actor:getTarget()) then return false end

    -- 找到离自己最近的敌人，并切换目标
    local target = actor:getClosestActor(enemies)

    if target == nil then
        return false
    end

    actor:setTarget(target)

    return QAIPriorityBeatBack.super._execute(self, args)
end

return QAIPriorityBeatBack