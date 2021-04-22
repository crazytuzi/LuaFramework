
local QAIAction = import("..base.QAIAction")
local QAIHPLost = class("QAIHPLost", QAIAction)

function QAIHPLost:ctor( options )
    QAIHPLost.super.ctor(self, options)
    self:setDesc("检查血量")
end

function QAIHPLost:_execute(args)
    if self._options.hp_less_then == nil then
        return false
    end

    local actor = args.actor
    if actor == nil or actor:isDead() == true then
        return false
    end

    if self._lastHp == nil then
        self._lastHp = actor:getHp()
    end

    for i, hp in ipairs(self._options.hp_less_then) do
        local hpFrom = self._lastHp / actor:getMaxHp()
        local hpTo = actor:getHp() / actor:getMaxHp()
        if (hpFrom > hp and hpTo <= hp) or (hpFrom >= hp and hpTo < hp) then
            if self._options.only_trigger_once == true then
                table.remove(self._options.hp_less_then, i)
            end
            self._lastHp = actor:getHp()
            return true
        end
    end

    return false
end

return QAIHPLost