-- TweenEntry

local TweenEntry = class("TweenEntry", require "app.scenes.battle.entry.Entry")

function TweenEntry:ctor(tweenJsonName, data, objects, battleField)
    
    local tweenJson = self:getJson(tweenJsonName) or decodeJsonFile(tweenJsonName)
    self:setJson(tweenJsonName, tweenJson)
    
    self._tweenJson = tweenJson
    
    self._tweenJsonName = tweenJsonName
    
--    print("TweenEntry:ctor: "..tweenJsonName.." is created")
    
    -- 根节点
    self._node = display.newNode()
    self._node:retain()
    self._node:setCascadeOpacityEnabled(true)
    self._node:setCascadeColorEnabled(true)
    
    -- 用来保存tweenstep数据用数组
    self._tweenStepArr = {}
    
    -- 保存所有显示节点的数组
    self._tweenArr = {}
    
    TweenEntry.super.ctor(self, data, objects, battleField)
    
end

function TweenEntry:initEntry()
    
    TweenEntry.super.initEntry(self)
    
--    print("TweenEntry:initEntry: "..self._tweenJsonName.." is inited")
    
    if self._tweenArr then
        for k, tween in pairs(self._tweenArr) do
            if tween.isEntry then
                tween:initEntry()
                if tween:getObject():getParent() then
                    tween:getObject():removeFromParent()
                end
            elseif tween.clipNode and tween.clipNode:getParent() then
                tween.clipNode:removeFromParent()
            elseif tween:getParent() then
                tween:removeFromParent()
            end
        end
    end
    
    self._tweenStepArr = {}
    
    self:addEntryToQueue(self, self.update)
    
end

function TweenEntry:getObject() return self._node end

function TweenEntry:getTotalFrame()
    for k, v in pairs(self._tweenJson.events) do
        if v == "finish" then
            return tonumber(string.sub(k, 2))
        end
    end
    assert(false, "could not find the finish frame")
end

function TweenEntry:update(frameIndex)

    local fx = string.gsub("f0", "%d", frameIndex)
    local tweenJson = self._tweenJson
    
    -- 优先找遮罩层
    local maskKey = nil
    for k, v in pairs(tweenJson) do
        if v.mask_info then
            maskKey = k
            self._tweenStepArr[k] = self._tweenStepArr[k] or self:_tweenStep(k, v)
            self._tweenStepArr[k](frameIndex)
        end
    end
    
    for k, v in pairs(tweenJson) do
        if k ~= "events" and k ~= maskKey then
            self._tweenStepArr[k] = self._tweenStepArr[k] or self:_tweenStep(k, v)
            self._tweenStepArr[k](frameIndex)
        end
    end
    
    local event = tweenJson.events[fx]
    
    if event == "finish" then
        for k, tween in pairs(self._tweenArr) do
            if tween.isEntry then
                tween:stop()
            end
        end
    end
    
    return event == "finish", event
end

function TweenEntry:_tweenStep(k, tween)
    
    local action = nil
    local target = nil
    
    return function(frameIndex)
        
        local fx = string.gsub("f0", "%d", frameIndex)
        
        if tween[fx] then
            
            if tween[fx].remove then

                if action then
                    action:release()
                    action = nil
                end

                if target then
                    if target.isEntry then
                        target:stop()
                        target:getObject():removeFromParent()
--                        target:releaseEntry()
                    else
                        target:removeFromParent()
--                        target:release()
                    end
                    target = nil
--                    self._tweenArr[k] = nil
                end
                return
            end
            
            if not target then
                target = self:createDisplayWithTweenNode(k, frameIndex, tween, self._tweenArr[k])
                assert(target, "Target could not be nil with key: "..k)
                
                if not self._tweenArr[k] then
                    if target.isEntry then
                        target:retainEntry()
                    elseif target.clipNode then
                        target.clipNode:retain()
                    else
                        target:retain()
                    end
                end
                
                -- 将mask数据保存至target
                self._tweenArr[k] = target
            end
            
            -- 清理上一个的痕迹
            if action then
                action:release()
                action = nil
            end
            
            local start = tween[fx].start
            
            target:setPositionXY(start.x, start.y)
            target:setRotation(start.rotation)
            target:setScaleX(start.scaleX)
            target:setScaleY(start.scaleY)
            target:setOpacity(start.opacity)
            
            local nextFx = tween[fx].nextFrame
            if nextFx then
                local duration = tween[fx].frames - 1
                local nextStart = tween[nextFx].start
                
                local ActionFactory = require "app.common.action.Action"
                action = ActionFactory.newSpawn{
                    (nextStart.x ~= start.x or nextStart.y ~= start.y) and ActionFactory.newMoveTo(duration, {x=nextStart.x, y=nextStart.y}) or false,
                    (nextStart.rotation ~= start.rotation) and ActionFactory.newRotateTo(duration, nextStart.rotation) or false,
                    (nextStart.scaleX ~= start.scaleX or nextStart.scaleY ~= start.scaleY) and ActionFactory.newScaleTo(duration, nextStart.scaleX, nextStart.scaleY) or false,
                    (nextStart.opacity ~= start.opacity) and ActionFactory.newFadeTo(duration, nextStart.opacity) or false
                }

                action:startWithTarget(target)
                action:retain()
            end
            
        elseif action then
            if action:isDone() then
                action:release()
                action = nil
            else
                action:step(1)
            end
        end
    end
    
end

function TweenEntry:createDisplayWithTweenNode(tweenNode, frameIndex, tween)
    assert(false, "Please override this method to return display node and order with tweenNode: "..tweenNode)
end

function TweenEntry:getTweenNode(key)
    return self._tweenArr[key]
end

function TweenEntry:destroyEntry()
    TweenEntry.super.destroyEntry(self)
    
--    print("TweenEntry:destroyEntry: "..self._tweenJsonName.." is destroyed")
    
    for k, tween in pairs(self._tweenArr) do
        if tween.isEntry then
            tween:releaseEntry()
        elseif tween.clipNode then
            tween.clipNode:release()
        else
            tween:release()
        end
    end
    
    if self._node then
        if self._node:getParent() then
            self._node:removeFromParent()
        end
        self._node:release()
        self._node = nil
    end
    
    self._tweenStepArr = nil
    self._tweenNode = nil
    
end

return TweenEntry
