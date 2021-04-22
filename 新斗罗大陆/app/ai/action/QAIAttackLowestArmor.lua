
local QAIAction = import("..base.QAIAction")
local QAIAttackLowestArmor = class("QAIAttackLowestArmor", QAIAction)

function QAIAttackLowestArmor:ctor( options )
    QAIAttackLowestArmor.super.ctor(self, options)
    self:setDesc("攻击防御最低的敌人")
end

function QAIAttackLowestArmor:_execute(args)
    local actor = args.actor
    local target = actor:getTarget()
    if actor == nil then
        assert(false, "invalid args, actor is nil.")
        return false
    end

    if target and not target:isDead() and target:isMarked() then
        return false
    end

    local enemies = app.battle:getMyEnemies(actor)

    if enemies == nil then 
        return nil 
    end

    local get_armor = nil

    local armor_type = self._options.armor_type or "all"
    if armor_type == "physical" then
        get_armor = function(actor) return actor:getPhysicalArmor() end
    elseif armor_type == "magic" then
        get_armor = function(actor) return actor:getMagicArmor() end
    elseif armor_type == "all" then
        get_armor = function(actor) return actor:getPhysicalArmor() + actor:getMagicArmor() end
    end

    if get_armor == nil then
        return false
    end

    local target = enemies[1]
    for i, other in ipairs(enemies) do
        if not other:isDead() then
            if get_armor(other) < get_armor(target) then
                target = other
            end
        end
    end

    if target == nil then
        return false
    end

    actor:setTarget(target)

    return true
end

return QAIAttackLowestArmor