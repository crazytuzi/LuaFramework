--[[
    Class name QSBActorFadeOut
    Create by julian 
--]]


local QSBAction = import(".QSBAction")
local QSBActorFadeOut = class("QSBActorFadeOut", QSBAction)

local QActor = import("...models.QActor")

function QSBActorFadeOut:_execute(dt)
	if self._isExecuting == true then
		return
	end

	local actor = self._attacker
	if self._options.is_target == true then
		actor = self._target
	end

	if actor == nil then
		return self:finished()
	end

	local duration = self._options.duration or 0.25

	if not IsServerSide then
		local actorView = app.scene:getActorViewFromModel(actor)
		if actorView then
			-- 初始状态记录
			actorView:setCascadeOpacityEnabled(true)
			actorView:getSkeletonActor():setCascadeOpacityEnabled(true)
			self._original_opacity = actorView:getSkeletonActor():getOpacity()
			self._actorView = actorView
			local arr = CCArray:create()
		    arr:addObject(CCFadeOut:create(duration))
		    actorView:getSkeletonActor():runAction(CCSequence:create(arr))
		end
	end

    app.battle:performWithDelay(function ()
    	self:finished()
    end, duration, self._attacker)

    self._isExecuting = true

end

function QSBActorFadeOut:_onCancel()
	self:_onRevert()
end

function QSBActorFadeOut:_onRevert()
	if not IsServerSide then
		if self._original_opacity ~= nil and self._actorView ~= nil and self._actorView.getSkeletonActor ~= nil and self._actorView:getSkeletonActor().stopAllActions ~= nil then
			pcall(function( ... )
					self._actorView:getSkeletonActor():stopAllActions()
					self._actorView:getSkeletonActor():setOpacity(self._original_opacity)
					self._original_opacity = nil
					self._actorView = nil
				end)
		end
	end
end

return QSBActorFadeOut