local QSBAction = import(".QSBAction")
local QSkill = import("...models.QSkill")
local QSBChangeRecoverHpLimit = class("QSBChangeRecoverHpLimit", QSBAction)

function QSBChangeRecoverHpLimit:_execute(dt)
	local percent = self._options.percent
	local actor
    if self._options.is_attacker == true then
        actor = self._attacker
    else
        if self._skill:getRangeType() == QSkill.MULTIPLE then
            self._targets = self._attacker:getMultipleTargetWithSkill(self._skill, self._target)
            if #self._targets == 0 then
                self:finished()
                return
            end
        else
            self._targets = {self._target}
        end
    end

	if percent and #self._targets > 0 then
        for _, actor in ipairs(self._targets) do
    		local limit = actor:getRecoverHpLimit()
            if self._options.is_hp_percent then
                limit = actor:getMaxHp()
            elseif self._options.is_inherit_damage_percent then
                limit = self._skill:getInHeritedDamage() or 0
            end
    		actor:setRecoverHpLimit(limit * percent, actor:getMaxHp())
        end
	end
	self:finished()
end

return QSBChangeRecoverHpLimit