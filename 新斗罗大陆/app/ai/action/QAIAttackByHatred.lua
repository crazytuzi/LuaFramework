
local QAIAction = import("..base.QAIAction")
local QAIAttackByHatred = class("QAIAttackByHatred", QAIAction)

function QAIAttackByHatred:ctor( options )
    QAIAttackByHatred.super.ctor(self, options)
    self:setDesc("根据危险度选择一个敌人攻击")
    if self._options.is_get_max == nil  then
        self._options["is_get_max"] = true
    end
end

function QAIAttackByHatred:_execute(args)
    local actor = args.actor
    if actor == nil then
        assert(false, "invalid args, actor is nil.")
        return false
    end

    local enemies = app.battle:getMyEnemies(actor)

    if enemies == nil then 
        return nil 
    end

    local target = nil
    local hatred = 0
    if self._options.is_get_max == false then
        hatred = 10e20
    end
    for i, other in ipairs(enemies) do
        local otherHatred = other:getTalentHatred()
        if self._options.is_get_max == true then
            if otherHatred > hatred then
                target = other
                hatred = otherHatred
            end
        else
            if otherHatred < hatred then
                target = other
                hatred = otherHatred
            end
        end
    end

    if target == nil then
        return false
    end

    actor:setTarget(target)

    return true
end

return QAIAttackByHatred