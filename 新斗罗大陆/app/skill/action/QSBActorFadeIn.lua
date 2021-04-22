--[[
    Class name QSBActorFadeIn
    Create by julian 
--]]
local QSBAction = import(".QSBAction")
local QSBActorFadeIn = class("QSBActorFadeIn", QSBAction)

local QActor = import("...models.QActor")

function QSBActorFadeIn:_execute(dt)
	if self._isExecuting == true then
		return
	end

	local actor = self._attacker
	if self._options.is_target == true then
		actor = self._target
    elseif self._options.selectTarget then
        actor = self._options.selectTarget
	end

	if actor == nil then
		return self:finished()
	end

	local duration = self._options.duration or 0.25

	if not IsServerSide then
		local actorView = app.scene:getActorViewFromModel(actor)
		if actorView then
			-- 初始状态记录
			self._original_opacity = actorView:getSkeletonActor():getOpacity()
			self._actorView = actorView
            if actor:isCopyHero() then
                self._original_opacity = actor:getCopyHeroFinalOpcity() or 200
                local arr = CCArray:create()
                arr:addObject(CCFadeTo:create(duration, self._original_opacity))
                actorView:getSkeletonActor():runAction(CCSequence:create(arr))
            else
                local arr = CCArray:create()
                arr:addObject(CCFadeIn:create(duration))
                actorView:getSkeletonActor():runAction(CCSequence:create(arr))
            end
		end
	end

    app.battle:performWithDelay(function ()
    	self:finished()
    end, duration, self._attacker)

    self._isExecuting = true

end

function QSBActorFadeIn:_onCancel()
	self:_onRevert()
end

function QSBActorFadeIn:_onRevert()
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

return QSBActorFadeIn
