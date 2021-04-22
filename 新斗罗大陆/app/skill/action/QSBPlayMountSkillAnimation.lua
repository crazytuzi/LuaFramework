
local QSBAction = import(".QSBAction")
local QSBPlayMountSkillAnimation = class("QSBPlayMountSkillAnimation", QSBAction)

function QSBPlayMountSkillAnimation:_execute(dt)
	local actor = self._skill:getDamager() or self._attacker
	if not IsServerSide and actor:getMountId() then 
		self._skill:setMountId(actor:getMountId())
		app.scene:playMountSkillAnimation(actor, self._skill)
	end
	self:finished()
end

return QSBPlayMountSkillAnimation