--[[
    Class name QSBReloadAnimation
    Create by julian 
--]]
local QSBAction = import(".QSBAction")
local QSBReloadAnimation = class("QSBReloadAnimation", QSBAction)

local QActor = import("...models.QActor")

function QSBReloadAnimation:_execute(dt)
	if not IsServerSide then
		local actorView = app.scene:getActorViewFromModel(self._attacker)
		if not actorView:getSkeletonActor().isFca then
			actorView:reloadSkeleton()
			actorView:getSkeletonActor():resetActorWithAnimation(ANIMATION.STAND, true)
			local scale, _ = actorView:getModel():getActorScale()
			actorView:getSkeletonActor():setSkeletonScaleX(scale)
			actorView:getSkeletonActor():setSkeletonScaleY(scale)
		end
	end

	self:finished()
end

return QSBReloadAnimation