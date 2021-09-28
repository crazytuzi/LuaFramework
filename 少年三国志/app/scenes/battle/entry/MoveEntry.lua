-- MoveEntry

local MoveEntry = class("MoveEntry", require "app.scenes.battle.entry.Entry")

function MoveEntry:ctor(position, object, duration)
    self._duration = duration
    MoveEntry.super.ctor(self, position, object)
end

function MoveEntry:initEntry()

    MoveEntry.super.initEntry(self)
 
--    self:addEntryToQueue(self, self.update)
    self:addEntryToQueue(nil, self:updateMove())
    
end

function MoveEntry:updateMove()
    
    local action = nil
    local target = self._objects
    local duration = self._duration or 3
    
    return function(_, frameIndex)
        
        -- 创建action
        if not action then
            
            local dstPosition = ccpAdd(ccp(target:getPosition()), self._data)
            local ActionFactory = require "app.common.action.Action"
            action = ActionFactory.newSpawn{
                ActionFactory.newMoveTo(duration, dstPosition),
                ActionFactory.newScaleTo(duration, require("app.scenes.battle.Location").getScaleByPosition{dstPosition.x, dstPosition.y})
            }
            
            -- 开启action
            action:startWithTarget(target)
            action:retain()
            
        end
        
        -- step这个方法主要是计算从开始action累加的时间占总时间的百分比，然后调用update方法，将百分比传入
        -- 所以只需把需要计算的时间分量（帧数）传入即可
        action:step(1)
        -- 重新计算order
        target:getParent():reorderChild(target, target:getPositionY() * -1)
        
        if action:isDone() then
            action:release()
            return true
        end
        
        return false
    end
    
end

return MoveEntry
