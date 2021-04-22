
local QAIAction = import("..base.QAIAction")
local QAITreatTeammate = class("QAITreatTeammate", QAIAction)

function QAITreatTeammate:ctor( options )
    QAITreatTeammate.super.ctor(self, options)
    self:setDesc("治疗队友")
end

function QAITreatTeammate:_execute(args)
    local actor = args.actor

    local teammates = app.battle:getMyTeammates(actor)

    if self:getOptions().include_self == true then
        table.insert(teammates, actor)
    end

    local hp_below = self:getOptions().hp_below
    assert(hp_below ~= nil, "QAITreatTeammate must config the option with the name 'hp_below'")

    local isTreatHpLowest = (self:getOptions().treat_hp_lowest == true)

    if isTreatHpLowest == true and actor:getTarget() == nil then
        -- 如果当前没有治疗目标，则治疗血最少的，不受hp_below限制
        hp_below = 1.0
    end

    local hpPertent = 1.0
    local selectTeammate = nil
    for k, teammate in pairs(teammates) do
        if teammate ~= nil and not teammate:isDead() and teammate:getHp() < teammate:getMaxHp() * hp_below and not teammate:isLockHp() then
            if isTreatHpLowest == false then
                actor:setTarget(teammate)
                return true
            end
            local newPercent = teammate:getHp() / teammate:getMaxHp()
            if hpPertent >= newPercent then
                selectTeammate = teammate
                hpPertent = newPercent
            end
        end
    end

    if isTreatHpLowest == true and selectTeammate ~= nil then
        actor:setTarget(selectTeammate)
        return true
    end

    return false
end

return QAITreatTeammate