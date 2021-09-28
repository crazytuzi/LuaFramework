-- ActionEntry

local ActionEntry = class("ActionEntry", require "app.scenes.battle.entry.Entry")

function ActionEntry:ctor(actionJson, objects, battleField, eventHandler, ignoreCard)
    
    self._actionName = actionJson
    
    -- 是否屏蔽卡牌效果
    self._ignoreCard = ignoreCard
    
--    print("ActionEntry:ctor: "..self._actionName.." is created")
    
    -- 解析json
    local action = self:getJson(actionJson) or decodeJsonFile(actionJson)
    self:setJson(actionJson, action)
    
    -- 用来保存每一层action的target
    self._actionArr = {}
    
    -- 用来存放action递进的函数
    self._actionStepArr = {}
    
    -- 外部的entry
    self._externalEntryArr = {}
    
    ActionEntry.super.ctor(self, action, objects, battleField, eventHandler)
    
end

function ActionEntry:addEntryToNewQueue(target, ...)
    
    if target and target ~= self then
        if target.isEntry then
            target:retainEntry()
        end
        self._externalEntryArr[#self._externalEntryArr+1] = {target, ...}
    elseif not target then
        self._externalEntryArr[#self._externalEntryArr+1] = {target, ...}
    end
    
    ActionEntry.super.addEntryToNewQueue(self, target, ...)
    
end

function ActionEntry:initEntry()
    
    ActionEntry.super.initEntry(self)

    for k, action in pairs(self._actionArr) do
        if action.manualrelease then
            if action:getParent() then
                action:removeFromParent()
            end
        elseif action.isEntry then
            action:initEntry()
            -- 这里主要是sp，所以可以移除
            if action:getObject():getParent() then
                action:getObject():removeFromParent()
            end
            action:setPreEvent("reset")
        end
    end
    
    self._actionStepArr = {}

    self:addEntryToQueue(self, self.update)
     
    for i=1, #self._externalEntryArr do
        local target = self._externalEntryArr[i][1]
        -- 这里主要是ActionEntry，不能移除显示
        if target and target.isEntry and target ~= self then
            target:initEntry()
        end
        self.super.addEntryToNewQueue(self, unpack(self._externalEntryArr[i]))
    end
    
end

function ActionEntry:update(frameIndex)
    
    local fx = string.gsub("f0", "%d", frameIndex)
    local actionJson = self._data
    
    for k, v in pairs(actionJson) do
        if k ~= "events" then
            if k == "card_layer" or k == "card_layer1" or k == "card_layer2" or
                k == "base_layer" or k == "base_layer1" or k == "base_layer2" then
                if not self._ignoreCard then
                    self._actionStepArr[k] = self._actionStepArr[k] or self:_actionStep(k, v)
                    self._actionStepArr[k](frameIndex)
                end
            else
                self._actionStepArr[k] = self._actionStepArr[k] or self:_actionStep(k, v)
                self._actionStepArr[k](frameIndex)
            end
        end
    end
    
    local event = actionJson.events[fx]
    
    if event == "finish" then
        for k, action in pairs(self._actionArr) do
            if action.isEntry then
                action:stop()
            end
        end
    end
    
    return event == "finish", event
    
end

function ActionEntry:_actionStep(key, actionNode)
    
    local action = nil
    local target = nil
    
    return function(frameIndex)
        
        local fx = string.gsub("f0", "%d", frameIndex)
        
        if actionNode[fx] then
            
            if actionNode[fx].remove then
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
--                        target:release()
                        if target.manualrelease then
                            target:removeFromParent()
                        end
                    end
                    target = nil
--                    self._actionArr[key] = nil
                end
                return
            end
            
            if not target then
                target = self:createDisplayNodeWithActionNode(key, actionNode, frameIndex, self._actionArr[key])
                assert(target, "Unknown actionNode key: "..key)
                
                if not self._actionArr[key] then
                    if target.isEntry then
                        target:retainEntry()
                    else
                        target:retain()
                    end
                end
                
                self._actionArr[key] = target
            end

            -- 清理上一个的痕迹
            if action then
                action:release()
                action = nil
            end
            
            local start = actionNode[fx].start
            
            target:setPositionXY(start.x, start.y)
            target:setRotation(start.rotation)
            target:setScaleX(start.scaleX)
            target:setScaleY(start.scaleY)
            if start.opacity then target:setOpacity(start.opacity) end
            if start.color then
                target:setColorRGB(start.color.red_original * 255, start.color.green_original * 255, start.color.blue_original * 255)
                target:setOpacity(start.color.alpha_original * 255)
                target:setColorOffsetRGBA(start.color.red/255, start.color.green/255, start.color.blue/255, start.color.alpha/255)
            end
            
            local nextFx = actionNode[fx].nextFrame
            if nextFx then
                local duration = actionNode[fx].frames - 1
                local nextStart = actionNode[nextFx].start
                
                if nextStart then
                    local ActionFactory = require "app.common.action.Action"
                    action = ActionFactory.newSpawn{
                        (nextStart.x ~= start.x or nextStart.y ~= start.y) and ActionFactory.newMoveTo(duration, {x=nextStart.x, y=nextStart.y}) or false,
                        (nextStart.rotation ~= start.rotation) and ActionFactory.newRotateTo(duration, nextStart.rotation) or false,
                        (nextStart.scaleX ~= start.scaleX or nextStart.scaleY ~= start.scaleY) and ActionFactory.newScaleTo(duration, nextStart.scaleX, nextStart.scaleY) or false,
                        (nextStart.opacity and nextStart.opacity ~= start.opacity) and ActionFactory.newFadeTo(duration, nextStart.opacity) or false,
                        (nextStart.color and start.color) and ActionFactory.newColor(duration, {r=nextStart.color.red_original*255, g=nextStart.color.green_original*255, b=nextStart.color.blue_original*255}) or false,
                        (nextStart.color and start.color) and ActionFactory.newFadeTo(duration, nextStart.color.alpha_original * 255) or false,
                        (nextStart.color and start.color) and ActionFactory.newColorOffset(duration, {r=nextStart.color.red/255, g=nextStart.color.green/255, b=nextStart.color.blue/255, a=nextStart.color.alpha/255}) or false
                    }

                    action:startWithTarget(target)
                    action:retain()
                end
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

function ActionEntry:createDisplayNodeWithActionNode(key, actionNode, frameIndex, node)
    
    local object = self._objects
    
    local displayNode = node 
    
    if not displayNode then
        -- 主卡牌
        if key == "card_layer" then

            displayNode = object:getCardSprite()

        -- 卡牌残影
        elseif key == "card_layer2" or key == "card_layer3" then

            local node = display.newNode()
            local cardSprite = object:getCardSprite()
            node:setCascadeOpacityEnabled(true)
            node:setCascadeColorEnabled(true)
--            object:getCardBody():addChild(node, 2)
            local order = -2
            if key == "card_layer3" then order = -3 end
            node:setZOrder(order)
            local card = nil
            if g_target == kTargetWP8 or g_target == kTargetWinRT then
                local spriteChild = cardSprite:getChildren() or {}
                card = spriteChild[#spriteChild]
            else
                card = cardSprite:getChildren():lastObject()
            end
            local sprite = CCSpriteLighten:createWithSpriteFrame(card:getDisplayFrame())
--            local sprite = display.newSprite(card:getDisplayFrame())
            node:addChild(sprite)
            sprite:setPosition(ccp(card:getPosition()))
            sprite:setScaleX(card:getScaleX())
            node.setColorOffsetRGBA = function(_, r, g, b, a)
                sprite:setColorOffsetRGBA(r, g, b, a)
--                sprite:setShaderProgram(CCShaderCache:sharedShaderCache():programForKey(G_ColorShaderManager:getShaderKey(colorOffset.r, colorOffset.g, colorOffset.b)))
            end
            node.getColorRGBA = function()
                return sprite:getColorRGBA()
            end

            -- 此标记是表示在释放的时候需要删除
            node.manualrelease = true

            displayNode = node

        -- 主底座
        elseif key == "base_layer" then

            displayNode = object:getCardBase()

        -- 底座残影
        elseif key == "base_layer2" or key == "base_layer3" then

            local node = display.newNode()
            local cardSprite = object:getCardBase()
            node:setCascadeOpacityEnabled(true)
            node:setCascadeColorEnabled(true)
--            object:getCardBody():addChild(node, 2)
            local order = -2
            if key == "base_layer3" then order = -3 end
            node:setZOrder(order)
            local card = nil
            if g_target == kTargetWP8 or g_target == kTargetWinRT then
                local spriteChild = cardSprite:getChildren() or {}
                card = spriteChild[#spriteChild]
                card = tolua.cast(card, "cc.Sprite")
            else
                card = cardSprite:getChildren():lastObject()
                card = tolua.cast(card, "CCSprite")
            end
            
            local sprite = CCSpriteLighten:createWithSpriteFrame(card:getDisplayFrame())
--            local sprite = display.newSprite(card:getDisplayFrame())
            node:addChild(sprite)
            sprite:setPosition(ccp(card:getPosition()))
            sprite:setScaleX(card:getScaleX())
            node.setColorOffsetRGBA = function(_, r, g, b, a)
                sprite:setColorOffsetRGBA(r, g, b, a)
--                sprite:setShaderProgram(CCShaderCache:sharedShaderCache():programForKey(G_ColorShaderManager:getShaderKey(colorOffset.r, colorOffset.g, colorOffset.b)))
            end
            node.getColorRGBA = function()
                return sprite:getColorRGBA()
            end

            -- 此标记是表示在释放的时候需要删除
            node.manualrelease = true

            displayNode = node

        -- 特效
        elseif key == "sp_down_layer" or key == "sp_up_layer" or key == "sp_stage_center_layer" then

            local fx = string.gsub("f0", "%d", frameIndex)
            local start = actionNode[fx].start or actionNode[fx][1]

            local CardSpEntry = require "app.scenes.battle.entry.CardSpEntry"
            local spJson = {spId=actionNode.spId or start.spId, x=start.x, y=start.y, scaleX=start.scaleX, scaleY=start.scaleY, opacity=start.opacity, rotation=start.rotation}

            local spEntry = CardSpEntry.new(spJson, object, self._battleField)
            displayNode = spEntry

        end
    end
    
    assert(displayNode, "the displayNode could not be nil with key: "..key.." and name: "..self._actionName)
    
    if displayNode.isEntry then
        self._battleField:addEntryToSynchQueue(displayNode, displayNode.updateEntry)
        self._battleField:addToNormalSpNode(displayNode:getObject(), object:getZOrder())
    else
        if key == "card_layer2" or key == "card_layer3" or key == "base_layer2" or key == "base_layer3" then
            object:getCardBody():addChild(displayNode)
        end
    end
    
    return displayNode
    
end

function ActionEntry:destroyEntry()
    ActionEntry.super.destroyEntry(self)

--    print("ActionEntry:destroyEntry: "..self._actionName.." is destroyed")

    self._actionStepArr = {}
    
    for k, action in pairs(self._actionArr) do
        if action.isEntry then
            action:releaseEntry()
        else
            if action.manualrelease then
                if action:getParent() then
                    action:removeFromParent()
                end
            end
            action:release()
        end
    end
    
    self._actionArr = {}
    
    for i=1, #self._externalEntryArr do
        local target = self._externalEntryArr[i][1]
        if target and target.isEntry and target ~= self then
            target:releaseEntry()
        end
    end
    
    self._externalEntryArr = {}
    
end

return ActionEntry
