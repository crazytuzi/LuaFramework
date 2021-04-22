--[[
    Class name QSBActorKeepAnimation
    Create by julian 
--]]
local QSBAction = import(".QSBAction")
local QSBActorKeepAnimation = class("QSBActorKeepAnimation", QSBAction)

local QActor = import("...models.QActor")

function QSBActorKeepAnimation:_execute(dt)
	if not IsServerSide then
		if self._attacker ~= nil then
			local actorView = app.scene:getActorViewFromModel(self._attacker)
			if actorView ~= nil then
				actorView:setIsKeepAnimation(self._options.is_keep_animation)
				self._director:setActorKeepAnimation(self._options.is_keep_animation)
			end
		end
	end
	self:finished()
end

return QSBActorKeepAnimation