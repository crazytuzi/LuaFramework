-- **************************************************
-- Author               : wanghai
-- FileName             : QUIDBSummonGhosts.lua
-- Description          : 
-- Create time          : 2019-03-25 15:10
-- Last modified        : 2019-03-25 15:10
-- **************************************************

local QUIWidgetActorDisplay = import("..QUIWidgetActorDisplay")
local QUIDBAction = import(".QUIDBAction")
local QUIDBSummonGhosts = class("QUIDBSummonGhosts", QUIDBAction)

function QUIDBSummonGhosts:_execute(dt)
    if self._isCreate then
        return
    end

    local avatar = QUIWidgetActorDisplay.new(self._options.ghostId) 

    local summerAvatar = self._widgetActor:getParent() 
    local uiNode = summerAvatar:getParent() 
    uiNode:addChild(avatar)
    self._director:addGhostAvatar(avatar)
    self._isCreate = true

    avatar:setScale(self._options.scale)
    avatar:setPosition(self._options.pos.x, self._options.pos.y)

    local actor = avatar:getActor()
    if self._options.direction == "RIGHT" then
        actor:getSkeletonView():flipActor()
    end

    actor:playAnimation(self._options.action, false)

    actor:getSkeletonView():disconnectAnimationEventSignal()
    actor:getSkeletonView():connectAnimationEventSignal(function(eventType, trackIndex, animationName, loopCount)
        if eventType == SP_ANIMATION_END or eventType == SP_ANIMATION_COMPLETE then
            actor:getSkeletonView():disconnectAnimationEventSignal()
            self:finished()
        end
    end)
end

return QUIDBSummonGhosts

