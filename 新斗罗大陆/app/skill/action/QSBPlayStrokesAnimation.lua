
local QSBAction = import(".QSBAction")
local QSBPlayStrokesAnimation = class("QSBPlayStrokesAnimation", QSBAction)

function QSBPlayStrokesAnimation:_execute(dt)
	local actor = self._skill:getDamager() or self._attacker
	if not IsServerSide and self._skill:getStrokesIcon() then 
		app.scene:_onPlayStrokesAnimation(actor, self._skill:getStrokesIcon())
	end
	self:finished()
end

return QSBPlayStrokesAnimation