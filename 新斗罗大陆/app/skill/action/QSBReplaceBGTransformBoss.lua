local QSBAction = import(".QSBAction")
local QSBReplaceBGTransformBoss = class("QSBReplaceBGTransformBoss", QSBAction)

function QSBReplaceBGTransformBoss:_execute(dt)
	if not IsServerSide and self._attacker:getType() == ACTOR_TYPES.NPC then
		app.scene:replaceBGFileBOSSDungeon()
	end
	self:finished()
end

return QSBReplaceBGTransformBoss