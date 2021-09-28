-- SpEntry

local SpEntry = class("SpEntry", require "app.scenes.battle.entry.Entry")

function SpEntry:ctor(spJson, objects, battleField, ...)
    
    local spId = spJson.spId
    local spFilePath = "battle/sp/"..spId.."/"..spId
    
    -- 解析json
    local spJsonName = spFilePath..".json"
    self._spJsonContent = self:getJson(spJsonName) or decodeJsonFile(spJsonName)
    self:setJson(spJsonName, self._spJsonContent)

    self._spJsonName = spJsonName

    -- 这里的node是基础节点, 默认基础节点的位置是在屏幕中心
    self._node = display.newNode()
    self._node:setCascadeOpacityEnabled(true)
    self._node:setCascadeColorEnabled(true)
    self._node:retain()
    
    -- 加载资源
    if (self._spJsonContent.png and self._spJsonContent.png ~= "") or CCFileUtils:sharedFileUtils():isFileExist(CCFileUtils:sharedFileUtils():fullPathForFilename(spFilePath..".png")) then
        display.addSpriteFramesWithFile(spFilePath..".plist", spFilePath..".png")
--        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(spFilePath..".plist", CCTextureCache:sharedTextureCache():textureForKey(spFilePath..".png"))
    end
    
--    print("SpEntry:ctor: "..spJsonName.." is created")
    
    SpEntry.super.ctor(self, spJson, objects, battleField, ...)
    
    self:initWithSpJson(spJson)
    
    -- 用来保存sp的数组
    self._spArr = {}
    
    -- 用来保存spStep数据用数组
    self._spStepArr = {}
    
    -- 是否是永久播放
    local events = self._spJsonContent.events
    if events then
        for k, v in pairs(events) do
            self.isForever = v == "forever"
            if self.isForever then break end
        end
    end
    
    -- 默认的colorOffset
    self._colorOffset = {0, 0, 0, 0}
    setmetatable(self._colorOffset, {__index = function(t, k)
        if k == "r" then return t[1]
        elseif k == "g" then return t[2]
        elseif k == "b" then return t[3]
        elseif k == "a" then return t[4]
        end
    end})
    
    self._colorOffset.set = function(r, g, b, a)
        self._colorOffset[1] = r
        self._colorOffset[2] = g
        self._colorOffset[3] = b
        self._colorOffset[4] = a
    end
    
end

function SpEntry:initEntry()
    
    SpEntry.super.initEntry(self)
    
--    print("SpEntry:initEntry: "..self._spJsonName.." is inited")
    
    if self._spArr then
        for k, sp in pairs(self._spArr) do
            if sp.isEntry then
--                sp:initEntry()
                if sp:getObject():getParent() then
                    sp:getObject():removeFromParent()
                end
            elseif sp.clipNode and sp.clipNode:getParent() then
                sp.clipNode:removeFromParent()
            elseif sp:getParent() then
                sp:removeFromParent()
            end
        end
    end
    
    -- 清理sp的step函数
    self._spStepArr = {}
    
    -- 这里添加需要增加的序列
    self:addEntryToQueue(self, self.update)
    
end

function SpEntry:getObject() return self._node end
function SpEntry:getData() return self._spJsonContent end

function SpEntry:update(frameIndex)

    local fx = string.gsub("f0", "%d", frameIndex)
    local spJson = self._spJsonContent
    
    -- 优先找遮罩层
    local maskKey = nil
    for k, v in pairs(spJson) do
        if v.mask_info then
            maskKey = k
            self._spStepArr[k] = self._spStepArr[k] or self:_spStep(k, v)
            self._spStepArr[k](frameIndex)
        end
    end
    
    for k, v in pairs(spJson) do
        if k ~= "events" and k ~= maskKey then
            self._spStepArr[k] = self._spStepArr[k] or self:_spStep(k, v)
            self._spStepArr[k](frameIndex)
        end
    end
    
    local event = spJson.events[fx]
    
    if event == "finish" then
        for k, sp in pairs(self._spArr) do
            if sp.isEntry then
                sp:stop()
            end
        end
    end
    
    return event == "finish", event
end

function SpEntry:_spStep(key, spNode)
    
    local action = nil        
    -- 这里的sp表示实际显示的节点
    local sp = nil
    
    return function(frameIndex)

        local fx = string.gsub("f0", "%d", frameIndex)
        
        if spNode[fx] then
            -- 移除sp            
            if spNode[fx].remove then
                                
                if action then
                    action:release()
                    action = nil
                end

                if sp then
                    if sp.isEntry then
                        sp:stop()
                        sp:getObject():removeFromParent()
--                        sp:releaseEntry()
                    else
                        if sp.clipNode then
                            sp.clipNode:removeFromParent()
                        else
                            sp:removeFromParent()
                        end
--                        sp:release()
                    end
                    sp = nil
--                    self._spArr[key] = nil
                end
                return
            end
            
            -- 创建sp
            if not sp then
                sp = self:createDisplayNodeWithSpNode(key, spNode, frameIndex, self._spArr[key])
                assert(sp, "Sp could not be nil with key: "..key)
                
                if not self._spArr[key] then
                    if sp.isEntry then
                        sp:retainEntry()
                    elseif sp.clipNode then
                        sp.clipNode:retain()
                    else
                        sp:retain()
                    end
                else
                    if sp.isEntry then
                        sp:initEntry()
                    end
                end
                
                self._spArr[key] = sp
            end
            
            -- 清理上一个的痕迹
            if action then
                action:release()
                action = nil
            end
            
            -- 创建action
            local start = spNode[fx].start
            
            sp:setPositionXY(start.x, start.y)
            sp:setRotation(start.rotation)
            sp:setScaleX(start.scaleX * sp.autoScale)
            sp:setScaleY(start.scaleY * sp.autoScale)
            if start.opacity then sp:setOpacity(start.opacity) end
            if start.color then
                sp:setColorRGB(start.color.red_original * 255, start.color.green_original * 255, start.color.blue_original * 255)
                sp:setOpacity(start.color.alpha_original * 255)
                sp:setColorOffsetRGBA(start.color.red/255 + self._colorOffset.r, start.color.green/255 + self._colorOffset.g, start.color.blue/255 + self._colorOffset.b, start.color.alpha/255 + self._colorOffset.a)
            end       
            if start.png and start.png ~= "" then sp:setDisplayFrame(display.newSpriteFrame(start.png)) end
            
            local nextFx = spNode[fx].nextFrame
            if nextFx then
                local duration = spNode[fx].frames - 1
                local nextStart = spNode[nextFx].start
                
                if nextStart then
                    local ActionFactory = require "app.common.action.Action"
                    action = ActionFactory.newSpawn{
                        (nextStart.x ~= start.x or nextStart.y ~= start.y) and ActionFactory.newMoveTo(duration, {x=nextStart.x, y=nextStart.y}) or false,
                        (nextStart.rotation ~= start.rotation) and ActionFactory.newRotateTo(duration, nextStart.rotation) or false,
                        (nextStart.scaleX ~= start.scaleX or nextStart.scaleY ~= start.scaleY) and ActionFactory.newScaleTo(duration, nextStart.scaleX * sp.autoScale, nextStart.scaleY * sp.autoScale) or false,
                        (nextStart.opacity and nextStart.opacity ~= start.opacity) and ActionFactory.newFadeTo(duration, nextStart.opacity) or false,
                        (nextStart.color and start.color) and ActionFactory.newColor(duration, {r=nextStart.color.red_original*255, g=nextStart.color.green_original*255, b=nextStart.color.blue_original*255}) or false,
                        (nextStart.color and start.color) and ActionFactory.newFadeTo(duration, nextStart.color.alpha_original * 255) or false,
                        (nextStart.color and start.color) and ActionFactory.newColorOffset(duration, {r=nextStart.color.red/255, g=nextStart.color.green/255, b=nextStart.color.blue/255, a=nextStart.color.alpha/255}) or false,
                    }

                    action:startWithTarget(sp)
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

-- @key 图层名，指的是spJson中每一层的名字
-- @spNode 每一层对应的数据
-- @frameIndex 当前是第几帧
-- @node 缓存中当前key的节点，初次时为空

function SpEntry:createDisplayNodeWithSpNode(key, spNode, frameIndex, node)
    
    local fx = string.gsub("f0", "%d", frameIndex)
    
    local displayNode = node
    
    if not displayNode then
        -- 如果当前节点层是指定sp，表示是嵌套层
        if spNode.sp then
            -- 创建json数据
            local spJsonContent = spNode[fx].start
            spJsonContent.spId = spNode.sp

            displayNode = SpEntry.new(spJsonContent, self._objects, self._battleField)
            displayNode.autoScale = 1
            
            displayNode:setColorRGB(self:getColorRGB())
            displayNode:setColorOffsetRGBA(unpack(self._colorOffset))
            
        elseif spNode.mask_info then    -- 遮罩层
            
            local stencil = CCLayerColor:create(ccc4(0, 0, 0, 255), spNode.mask_info.width, spNode.mask_info.height)
            stencil:ignoreAnchorPointForPosition(false)
            stencil:setAnchorPoint(ccp(0.5, 0.5))
            
            displayNode = CCClippingNode:create()
            displayNode:setStencil(stencil)
            
            displayNode.isMask = true
            stencil.clipNode = displayNode
--            displayNode:retain()
            stencil.autoScale = 1
            
        else

--            local sprite = display.newSprite("#"..spNode[fx].start.png)
            local sprite = CCSpriteLighten:createWithSpriteFrameName(spNode[fx].start.png)
--            sprite:setScale(self._spJsonContent.scale or 1)
            
            sprite:setColorRGB(self:getColorRGB())
            sprite:setColorOffsetRGBA(unpack(self._colorOffset))
--            sprite:setShaderProgram(CCShaderCache:sharedShaderCache():programForKey(G_ColorShaderManager:getShaderKey(self._colorOffset.r, self._colorOffset.g, self._colorOffset.b)))
            
            sprite:setCascadeOpacityEnabled(true)
            sprite:setCascadeColorEnabled(true)
            
            displayNode = sprite
            displayNode.autoScale = self._spJsonContent.scale or 1
            
        end
    end
    
    if displayNode then
        
        local parent = self._node
        -- 如果存在遮罩层且名字相同，则父类切换成clipnode    
        if self._spArr[spNode.mask] then
            parent = self._spArr[spNode.mask].clipNode
        end

        if displayNode.isEntry then
            parent:addChild(displayNode:getObject(), spNode.order)
            self:addEntryToNewQueue(displayNode, displayNode.updateEntry)
        elseif displayNode.clipNode then
            parent:addChild(displayNode.clipNode, spNode.order)
        else
            parent:addChild(displayNode, spNode.order)
        end 
    end
    
    return displayNode.isMask and displayNode:getStencil() or displayNode
    
end

-- 此接口主要是用于在action中引用的sp所带的一些参数设置
function SpEntry:initWithSpJson(spJson)
    if spJson.x and spJson.y then self:setPositionXY(spJson.x, spJson.y) end
    if spJson.rotation then self:setRotation(spJson.rotation) end
    if spJson.scaleX then self:setScaleX(spJson.scaleX) end
    if spJson.scaleY then self:setScaleY(spJson.scaleY) end
    if spJson.opacity then self:setOpacity(spJson.opacity) end
end

-- 这里的模仿CCNode的接口都是为了可嵌套sp服务的, 因为本身的sp中的根节点在计算的时候不仅仅只是赋值而已，还需要考虑到方向等逻辑问题，所以需要独立运算
-- 注意，这里的setPosition方法仅适用于嵌套时的调用，如果想要设置整个sp的位置变化，请获取object(self._node)后再自行设置即可
function SpEntry:setPositionXY(positionX, positionY) self._node:setPositionXY(positionX, positionY) end
function SpEntry:getPosition() return self._node:getPosition() end

function SpEntry:setRotation(rotation) self._node:setRotation(rotation) end
function SpEntry:getRotation() return self._node:getRotation() end

function SpEntry:setScale(scale) self:setScale(scale)end
function SpEntry:getScale() return self._node:getScale() end

function SpEntry:setScaleX(scaleX) self._node:setScaleX(scaleX) end    -- 敌方需要翻转
function SpEntry:getScaleX() return self._node:getScaleX() end

function SpEntry:setScaleY(scaleY) self._node:setScaleY(scaleY) end
function SpEntry:getScaleY() return self._node:getScaleY() end

function SpEntry:setOpacity(opacity) self._node:setOpacity(opacity) end
function SpEntry:getOpacity() return self._node:getOpacity() end

function SpEntry:setColorOffsetRGBA(_r, _g, _b, _a)
    for k, sp in pairs(self._spArr) do
        local colorOffset = {sp:getColorRGBA()}
        colorOffset = {r=colorOffset[1], g=colorOffset[2], b=colorOffset[3], a=colorOffset[4]}
        sp:setColorOffsetRGBA(_r + colorOffset.r - self._colorOffset.r, _g + colorOffset.g - self._colorOffset.g, _b + colorOffset.b - self._colorOffset.b, _a + colorOffset.a - self._colorOffset.a)
--        if sp.isEntry then
--            sp:setColorOffset(offset)
--        else
--            sp:setShaderProgram(CCShaderCache:sharedShaderCache():programForKey(G_ColorShaderManager:getShaderKey(offset.r, offset.g, offset.b)))
--        end
    end
    self._colorOffset.set(_r, _g, _b, _a)
end
function SpEntry:getColorRGBA() return unpack(self._colorOffset) end

function SpEntry:setColorRGB(r, g, b) self._node:setColorRGB(r, g, b) end
function SpEntry:getColorRGB() return self._node:getColorRGB() end

function SpEntry:boundingBox()
    -- 这里主要是子弹的碰撞会使用。因为特效里可能含有很多图层，并且每一层的所使用的图片大小不一，所以先不考虑其他多图层下此方法的问题，默认返回找到的第一层
    for k, node in pairs(self._spArr) do
        return node:boundingBox()
    end
    
    return CCRectMake(0, 0, 0, 0)
end

function SpEntry:destroyEntry()
    SpEntry.super.destroyEntry(self)
    
--    print("SpEntry:destroyEntry: "..self._spJsonName.." is destroyed")
    
    for k, sp in pairs(self._spArr) do
        if sp.isEntry then
            sp:releaseEntry()
        elseif sp.clipNode then
            sp.clipNode:release()
        else
            sp:release()
        end
    end
    
    if self._node then
        if self._node:getParent() then
            self._node:removeFromParent()
        end
        self._node:release()
        self._node = nil
    end
    
    self._spStepArr = nil
    self._spArr = nil

end

return SpEntry
