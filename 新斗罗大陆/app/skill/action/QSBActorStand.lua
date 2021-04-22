--[[
    Class name QSBActorStand
    Create by julian 
--]]
local QSBAction = import(".QSBAction")
local QSBActorStand = class("QSBActorStand", QSBAction)

local QActor = import("...models.QActor")

function QSBActorStand:_execute(dt)
	if not IsServerSide then
		if self._options.reload == true then
			local view = app.scene:getActorViewFromModel(self._attacker)
			view:reloadSkeleton()
			view:getSkeletonActor():resetActorWithAnimation(ANIMATION.STAND, true)
			-- local scale, _ = view:getModel():getActorScale()
			-- view:getSkeletonActor():setSkeletonScaleX(scale)
			-- view:getSkeletonActor():setSkeletonScaleY(scale)
		end
		if self._attacker ~= nil then
			local attackerView = app.scene:getActorViewFromModel(self._attacker)
			if attackerView ~= nil then
				attackerView:getSkeletonActor():resetActorWithAnimation(ANIMATION.STAND, true)
			end
		end
	end
	self:finished()
end

return QSBActorStand