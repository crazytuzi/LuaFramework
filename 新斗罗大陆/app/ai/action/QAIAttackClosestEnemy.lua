
local QAIAction = import("..base.QAIAction")
local QAIAttackClosestEnemy = class("QAIAttackClosestEnemy", QAIAction)

function QAIAttackClosestEnemy:ctor( options )
    QAIAttackClosestEnemy.super.ctor(self, options)
    self:setDesc("攻击最近的敌人")
end

function QAIAttackClosestEnemy:_execute(args)
    local actor = args.actor
    local target = actor:getTarget()

    if target and not target:isDead() and target:isMarked() then
        return false
    end

    if actor == nil then
        assert(false, "invalid args, actor is nil.")
        return false
    end

    if not self:getOptions().always and actor:getTarget() ~= nil and not actor:getTarget():isDead() then
        -- 如果当前已经选择了敌人，则继续保持
        if app.grid:hasActor(actor:getTarget()) == true then
            return true
        end
    end

    local candidate = {}
    local enemies = app.battle:getMyEnemies(actor)
    if self._options.not_support then
        candidate = enemies
        enemies = {}
        for _, enemy in ipairs(candidate) do
            if not enemy:isSupportHero() then
                table.insert(enemies, enemy)
            end
        end
    end
    if self._options.not_copy_hero then
        candidate = enemies
        enemies = {}
        for _, enemy in ipairs(candidate) do
            if not enemy:isCopyHero() then
                table.insert(enemies, enemy)
            end
        end
    end

    local target = actor:getClosestActor(enemies, self._options.in_battle_area)

    if target == nil then
        return false
    end

    actor:setTarget(target)
    return true
end

return QAIAttackClosestEnemy