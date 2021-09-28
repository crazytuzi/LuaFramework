-- CardSpEntry

local CardSpEntry = class("CardSpEntry", require "app.scenes.battle.entry.SpEntry")

-- 人物角色特效位置需要
function CardSpEntry:setPositionXY(positionX, positionY)
    if self._node:isRunning() then
        self._node:setPositionXY(self._node:getParent():convertToNodeSpaceXY(self._objects:getCardBody():convertToWorldSpaceXY(positionX, positionY)))
    else
       self._node:setPositionXY(self._objects:getCardBody():convertToWorldSpaceXY(positionX, positionY))
    end
end
function CardSpEntry:getPosition()
    if self._node:isRunning() then
        return self._objects:getCardBody():convertToNodeSpaceXY(self._node:getParent():convertToWorldSpaceXY(self._node:getPosition()))
    else
        return self._objects:getCardBody():convertToNodeSpaceXY(self._node:getPosition())
    end
end

-- 敌方需要翻转
function CardSpEntry:setScaleX(scaleX)
    self._node:setScaleX(scaleX * self._objects:getScaleX())
end

function CardSpEntry:setScaleY(scaleY)

    local object = self._objects
    local sp = self._node
--    local direction = 1
--    if self._direction then
--        if self._direction == "up" and object:getCardBody():getScaleX() == 1 then direction = 1
--        elseif self._direction == "up" and object:getCardBody():getScaleX() == -1 then direction = -1
--        elseif self._direction == "down" and object:getCardBody():getScaleX() == -1 then direction = 1
--        elseif self._direction == "down" and object:getCardBody():getScaleX() == 1 then direction = -1 end
--    end
    sp:setScaleY(scaleY * object:getScaleY())
end


return CardSpEntry


