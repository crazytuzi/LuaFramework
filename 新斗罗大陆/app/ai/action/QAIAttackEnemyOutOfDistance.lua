
local QAIAction = import("..base.QAIAction")
local QAIAttackEnemyOutOfDistance = class("QAIAttackEnemyOutOfDistance", QAIAction)

local QAIUseSkill = import(".QAIUseSkill")

function QAIAttackEnemyOutOfDistance:ctor( options )
    QAIAttackEnemyOutOfDistance.super.ctor(self, options)
    self:setDesc("攻击远处的敌人")
end

function QAIAttackEnemyOutOfDistance:_execute(args)
    local actor = args.actor

    if actor == nil then
        assert(false, "invalid args, actor is nil.")
        return false
    end

    local target = self:_getTargetEnemy(actor)

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

function QAIAttackEnemyOutOfDistance:_getTargetEnemy(actor)
    local enemies = app.battle:getMyEnemies(actor)
    local current_target_excluded = self._options.current_target_excluded and #enemies > 1
    local isNotSupport = self._options.not_support
    local isNotCopyHero = self._options.not_copy_hero
    local current_target
    if current_target_excluded then
        current_target = actor:getTarget()
    end

    if self._options.distance ~= nil then
        local distance = self._options.distance * global.pixel_per_unit
        distance = distance * distance
        for i, enemy in ipairs(enemies) do
            if not enemy:isDead() and enemy ~= current_target then
                if (not isNotSupport or not enemy:isSupportHero()) and
                    (not isNotCopyHero or not enemy:isCopyHero()) then

                    local x = enemy:getPosition().x - actor:getPosition().x
                    local y = enemy:getPosition().y - actor:getPosition().y
                    if x * x + 4 * y * y > distance then
                        return enemy
                    end
                end
            end
        end
    end

    local target = nil
    local distance = 0
    for i, enemy in ipairs(enemies) do
        if not enemy:isDead() and enemy ~= current_target then
            if (not isNotSupport or not enemy:isSupportHero()) and
                (not isNotCopyHero or not enemy:isCopyHero()) then

                local x = enemy:getPosition().x - actor:getPosition().x
                local y = enemy:getPosition().y - actor:getPosition().y
                local newDistance = x * x + 4 * y * y
                if newDistance > distance then
                    distance = newDistance
                    target = enemy
                end
            end
        end
    end

    return target
end

return QAIAttackEnemyOutOfDistance