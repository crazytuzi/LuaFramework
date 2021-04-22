
local QSBAction = import(".QSBAction")
local QSBActorScale = class("QSBActorScale", QSBAction)

function QSBActorScale:_execute(dt)
	local actor = nil
	if self._options.is_attacker == true then
		actor = self._attacker
	else
		actor = self._target
	end

	local duration = self._options.duration or 0.1
	self._duration = duration
	if actor ~= nil then
		if not IsServerSide then
			local actorView = app.scene:getActorViewFromModel(actor)
			if actorView ~= nil then
				local scale = self._options.scale_to or 1.0
				actorView:runAction(CCEaseIn:create(CCScaleTo:create(duration, scale), 3))
				self._actorView = actorView
				self._scaleTo = scale
			end
		end
	end
	
	self._delayHandle = app.battle:performWithDelay(function()
		if not IsServerSide then
			self._director:setActorScale(self._scaleTo)
		end
        self:finished()
    end, self._duration, self._attacker)
	
end

function QSBActorScale:_onCancel()
	if self._delayHandle ~= nil then
		app.battle:removePerformWithHandler(self._delayHandle)
    end
    if not IsServerSide then
		if self._actorView ~= nil then
	    	self._actorView:stopAllActions()
	    	self._actorView:setScale(1.0)
	    end
	end
end

return QSBActorScale