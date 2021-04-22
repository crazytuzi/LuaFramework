
local QSBAction = import(".QSBAction")
local QSBClearSkillCD = class("QSBClearSkillCD", QSBAction)

function QSBClearSkillCD:_execute(dt)
	local skill_id = self._options.skill_id
	local actor = self._attacker
	if skill_id and actor and actor._skills[skill_id] then
		actor._skills[skill_id]:resetCoolDown()
	end
	self:finished()
end

return QSBClearSkillCD