
local QUIWidgetActorDisplay = import(".QUIWidgetActorDisplay")
local QUIWidgetMonopolyActorDisplay = class("QUIWidgetMonopolyActorDisplay", QUIWidgetActorDisplay)

function QUIWidgetMonopolyActorDisplay:ctor(actorId, options)
	QUIWidgetMonopolyActorDisplay.super.ctor(self, actorId, options)
end

function QUIWidgetMonopolyActorDisplay:updateWalk(dt)
	if not self._isWalking then
		return
	end

	local duration = self._walkDuration
	local time = math.min(self._walkTime + dt, duration)
	self._walkTime = time

	local x = math.sampler(self._walkSrc.x, self._walkDst.x, time / duration)
	local y = math.sampler(self._walkSrc.y, self._walkDst.y, time / duration)
	self:setPosition(ccp(x, y))

	if duration == time then
		self._isWalking = false
	end
end

function QUIWidgetMonopolyActorDisplay:walkto(point)
	self:displayWithBehavior(ANIMATION_EFFECT.WALK)
	self._isWalking = true
	self._walkDst = {x = point.x, y = point.y}
	self._walkSrc = {x = self:getPositionX(), y = self:getPositionY()}
	self._walkDuration = q.distOf2Points(self._walkDst, self._walkSrc) / 220
	if self._walkDuration == 0 then
		self._isWalking = false
		return
	end
	self._walkTime = 0
end

function QUIWidgetMonopolyActorDisplay:resetActor()
	self._actor:resetActor()
end

return QUIWidgetMonopolyActorDisplay