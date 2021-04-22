
local QAIAction = import("..base.QAIAction")
local QAIAttackAnyEnemy = class("QAIAttackAnyEnemy", QAIAction)

local QAIUseSkill = import(".QAIUseSkill")

function QAIAttackAnyEnemy:ctor( options )
    QAIAttackAnyEnemy.super.ctor(self, options)
    self:setDesc("选择任何一个敌人攻击")
end

function QAIAttackAnyEnemy:_execute(args)
    local actor = args.actor
    if actor == nil then
        assert(false, "invalid args, actor is nil.")
        return false
    end

    local target = actor:getTarget()
    if self:getOptions().always == true or target == nil or target:isDead() then
        -- 如果当前已经选择了敌人，则继续保持。除非配置文件中always指定为true
        local enemies = app.battle:getMyEnemies(actor)
        local count = table.nums(enemies)

        if count == 0 then
            return false
        end

        local index = app.random(1, count)

        target = enemies[index]
        if target == nil then
            return false
        end
    end

    if self:getOptions().skill_id == nil then
        actor:setTarget(target)
    else
        -- 如果指定某个技能进行攻击，则只攻击一次
        local oldTarget = actor:getTarget()
        actor:setTarget(target)

        QAIUseSkill:useSkillForActor(actor, self:getOptions().skill_id)

        -- 切换回老的target
        actor:setTarget(oldTarget)
    end

    return true
end

return QAIAttackAnyEnemy