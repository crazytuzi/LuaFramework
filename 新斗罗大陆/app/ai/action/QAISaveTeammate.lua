
local QAIAction = import("..base.QAIAction")
local QAISaveTeammate = class("QAISaveTeammate", QAIAction)

function QAISaveTeammate:ctor( options )
    QAISaveTeammate.super.ctor(self, options)
    self:setDesc("救援队友")
end

function QAISaveTeammate:_execute(args)
    local actor = args.actor

    -- 如果当前目标是被激活的目标，则不转火
    if actor:getTarget() and not actor:getTarget():isDead() and actor:getTarget():isMarked() then
        return false
    end

    local enemies = app.battle:getMyEnemies(actor)

    local who = self:getOptions().who
    assert(who ~= nil, "QAISaveTeammate must config the option with the name 'who'")

    local targets = {}
    for k, enemy in pairs(enemies) do
        local teammate = enemy:getLastAttackee()
        if teammate ~= nil and not teammate:isDead() and teammate:getTalentFunc() == who then
            table.insert(targets, enemy)
        end
    end

    local target = nil
    if self:getOptions().priority == "closest" then
        -- 攻击目标优先级方式为寻找最近的敌人
        target = actor:getClosestActor(targets)
    else
        -- 攻击目标优先级方式为寻找危险等级最高的敌人
        target = table.max_fun(targets, actor.getAttack)
    end

    if target ~= nil then
        actor:setTarget(target)
        return true
    end

    return false
end

return QAISaveTeammate