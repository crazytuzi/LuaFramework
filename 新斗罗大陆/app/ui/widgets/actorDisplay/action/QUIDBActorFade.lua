

local QUIDBAction = import(".QUIDBAction")
local QUIDBActorFade= class("QUIDBActorFade", QUIDBAction)

function QUIDBActorFade:_execute(dt)
	local actor = self._widgetActor
	if self._options.fadein then
		actor:getSkeletonView():runAction(CCFadeIn:create(self._options.duration))
	elseif self._options.fadeout then
		local opacity = self._options.opacity or 0
		if self._options.duration == 0 then
			actor:getSkeletonView():setOpacity(opacity)
		else
			actor:getSkeletonView():runAction(CCFadeTo:create(self._options.duration, opacity))
		end
	end

	self:finished()
end

return QUIDBActorFade