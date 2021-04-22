local QSBAction = import(".QSBAction")
local QSBRemoveStatusByCast = class("QSBRemoveStatusByCast", QSBAction)

function QSBRemoveStatusByCast:_execute(dt)
	local actors = {self._attacker}
	local skill = self._skill

    if self._options.teammate_and_self then
        actors = app.battle:getMyTeammates(self._attacker, true)
    end
    for i, actor in ipairs(actors) do
        local remove_buffs = {}
        for _, buff in ipairs(actor:getBuffs()) do
            if skill:isRemoveStatus(buff:getStatus()) then
                table.insert(remove_buffs, buff)
            end
        end
        for _, buff in ipairs(remove_buffs) do
            actor:removeBuffByInstance(buff)
        end
    end
	self:finished()
end

return QSBRemoveStatusByCast