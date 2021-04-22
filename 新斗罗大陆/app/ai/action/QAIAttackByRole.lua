
local QAIAction = import("..base.QAIAction")
local QAIAttackByRole = class("QAIAttackByRole", QAIAction)

local QAIUseSkill = import(".QAIUseSkill")

function QAIAttackByRole:ctor( options )
    QAIAttackByRole.super.ctor(self, options)
    self:setDesc("攻击指定职责内的敌人")
end

function QAIAttackByRole:_evaluate(args)
    local actor = args.actor
    if actor == nil then
        assert(false, "invalid args, actor is nil.")
        return false
    end

    local options = self:getOptions()
    if options.role == nil and options.ranged == nil then -- role 参数必填
        assert(false, "invalid args, no role and no ranged in options")
        return false
    end

    return true
end

function QAIAttackByRole:_execute(args)
    local actor = args.actor
    if actor == nil then
        assert(false, "invalid args, actor is nil.")
        return false
    end

    local options = self:getOptions()
    local target = self._getTargetEnemy(actor, options.role, options.ranged, options.exclusive, options.ignore_support)

    if target == nil then
        return false
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

function QAIAttackByRole._getTargetEnemy(actor, role, ranged, exclusive, ignore_support)
    if exclusive == nil then exclusive = false end
    local enemies = app.battle:getMyEnemies(actor)

    local candidates = {}
    for i, enemy in ipairs(enemies) do
        -- exclusive 表示在给定的role之外取
        local matched = ((role == nil or  enemy:getTalentFunc() == role) and (ranged == nil or ranged == enemy:isRanged()))

        if not enemy:isDead() and math.xor(matched, exclusive) and ((not ignore_support) or (not enemy:isSupport())) then
            table.insert(candidates, enemy)
        end
    end

    if #candidates == 0 then
        -- 没有可获取的敌人
        return nil
    else
        return candidates[app.random(1, #candidates)]
    end
end

return QAIAttackByRole