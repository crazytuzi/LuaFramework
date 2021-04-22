-- **************************************************
-- Author               : wanghai
-- FileName             : QSBActorFadeTo.lua
-- Description          : 
-- Create time          : 2019-11-12 19:17
-- Last modified        : 2019-11-12 19:17
-- **************************************************

local QSBAction = import(".QSBAction")
local QSBActorFadeTo = class("QSBActorFadeTo", QSBAction)

local QActor = import("...models.QActor")

function QSBActorFadeTo:_execute(dt)
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
			self._original_opacity = actorView:getSkeletonActor():getOpacity()
			self._actorView = actorView
            self._opcity = self._options.opcity
            self._isDoFinal = self._options.is_do_final
			local arr = CCArray:create()
		    arr:addObject(CCFadeTo:create(duration,self._opcity))
		    actorView:getSkeletonActor():runAction(CCSequence:create(arr))

            if actor:isCopyHero() then
                actor:setCopyHeroFinalOpcity(self._opcity)
            end
		end
	end

    app.battle:performWithDelay(function ()
    	self:finished()
    end, duration, self._attacker)

    self._isExecuting = true

end

function QSBActorFadeTo:_onCancel()
	self:_onRevert()
end

function QSBActorFadeTo:_onRevert()
	if not IsServerSide then
		if self._original_opacity ~= nil and self._actorView ~= nil and self._actorView.getSkeletonActor ~= nil and self._actorView:getSkeletonActor().stopAllActions ~= nil then
			pcall(function( ... )
					self._actorView:getSkeletonActor():stopAllActions()
                    if self._isDoFinal then
                        self._actorView:getSkeletonActor():setOpacity(self._opcity)
                    else
                        self._actorView:getSkeletonActor():setOpacity(self._original_opacity)
                    end
					self._original_opacity = nil
					self._actorView = nil
                    self._opcity = nil
				end)
		end
	end
end

return QSBActorFadeTo
