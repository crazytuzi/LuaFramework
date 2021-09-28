-- EffectMovingNode

-- @desc 第节点设计目的在于使用自定义的配置文件（通常位于res/moving/目录下）播放自定义动画

local EffectMovingNode = class("EffectMovingNode", function() return display.newNode() end)


local defaultDouble = 1
local effectDesignInterval = 1/30 -- 动画设计时的FPS速度






function EffectMovingNode:ctor(effectJsonName, effectFunction, eventHandler)
    
    self:setCascadeOpacityEnabled(true)
    
    -- effectJson名称
    self._effectJsonName = effectJsonName
    
    -- json路径
    self._effectJsonPath = "moving/"..effectJsonName
    -- 解析json并保存起来
    self._effectJson = decodeJsonFile(self._effectJsonPath..".json")
    


--    for k, node in pairs(effectNodes) do
--        self:addChild(node, self._effectJson[k].order)
--        node:setVisible(false)
--    end

    -- 节点回调
    self._effectFunction = effectFunction
    
    -- 事件处理函数
    self._eventHandler = eventHandler
    

    -- 倍数
    self._double = defaultDouble
   

    self:reset()

    self._totalDt = 0
 
    --默认显示第一帧
    self:_step()


end

function EffectMovingNode:play()


    -- 开启update循环
    self:scheduleUpdate(handler(self, self._update), 0)
    
end


function EffectMovingNode:reset()
    
    -- 清空step数组
    self._effectStepArr = {}
     -- 特效显示节点    
    self._effectNodes = {}
    -- 帧数计数
    self._frameIndex = 1

    --是否暂停中
    self._paused = false

    
end


function EffectMovingNode:stop()
    self:unscheduleUpdate()
end

function EffectMovingNode:pause()
    self._paused = true
end

function EffectMovingNode:resume()
    self._paused = false
end

function EffectMovingNode:setDouble(double)
    assert(double and double > 0, "double could not be nil and negative !")
    self._double = double
end

function EffectMovingNode:_update(dt)
    if self._paused then
        return
    end

   
   self._totalDt = self._totalDt + dt -- 毫秒
      

   -- 计算实际上应该播放多少帧
   local extraInterval = effectDesignInterval/self._double
   local frames = math.floor(self._totalDt/extraInterval)
   if frames > self._double  then frames = math.floor(self._double) end

   for i=1, frames do
       if self._paused then
            break
       end
       if not self:isRunning() then
           break
       end
       self._totalDt = self._totalDt - extraInterval
       if not self:_step() then

           break
       end
       
   end

    
end

local function calValueByK(start, endt, percent)
    return start + (endt-start)*percent;

end

function EffectMovingNode:_step()
    local fx = "f"..self._frameIndex
    local effectJson = self._effectJson

    -- 用来保存effectStep数据用数组
    self._effectStepArr = self._effectStepArr or {}
    for k, v in pairs(effectJson) do
        if k ~= "events" then
            self._effectStepArr[k] = self._effectStepArr[k] or self:_effectStep(k, v)
            self._effectStepArr[k](self._frameIndex)
        end
    end

    local ret = true
    local frameIndex = self._frameIndex
    self._frameIndex = self._frameIndex + 1

    if effectJson.events[fx] == "forever" then
        self._frameIndex = 0
    elseif effectJson.events[fx] == "finish" then
        self:unscheduleUpdate()
        ret = false
    end

    if self._eventHandler and effectJson.events[fx] ~= nil then
        self._eventHandler(effectJson.events[fx], frameIndex, self)
    end

    return ret
end

function EffectMovingNode:_effectStep(key, effectLayer)
    
    local lastFrameStart = nil
            
    -- 这里的effectNode表示实际显示的节点
    local effectNode = self._effectNodes[key]
--    assert(effectNode, "the "..key.." node could not be nil !")
    
    return function(frameIndex)
        
        local fx = "f"..frameIndex
 
        if lastFrameStart or effectLayer[fx] then

            if not self._effectNodes[key] then
                effectNode = self._effectFunction(key)
                assert(effectNode, "the "..key.." node could not be nil !")
                self:addChild(effectNode, effectLayer.order)

                self._effectNodes[key] = effectNode
            end
            
            -- 初次使用，则显示effectNode
            if not lastFrameStart then effectNode:setVisible(true) end
            
            if effectLayer[fx] and effectLayer[fx].remove then
                effectNode:setVisible(false)
                lastFrameStart = nil
                return
            end
            
            if effectLayer[fx] then lastFrameStart = frameIndex end
            
            if lastFrameStart == frameIndex then
                local start = effectLayer[fx].start


                effectNode:setPositionX(start.x)
                effectNode:setPositionY(start.y)

                effectNode:setRotation(start.rotation)
                effectNode:setScaleX(start.scaleX)
                effectNode:setScaleY(start.scaleY)
                effectNode:setOpacity(start.opacity)
                if start.png then effectNode:setDisplayFrame(display.newSpriteFrame(start.png)) end

            else
                local lastFx = "f"..lastFrameStart
                
                local start = effectLayer[lastFx].start
                local nextFrame = effectLayer[lastFx].nextFrame
                local frames = effectLayer[lastFx].frames
                if nextFrame then
                    
                    if effectLayer[nextFrame].remove then return end
                    
                    local percent = (frameIndex - lastFrameStart) / frames
                    local nextStart = effectLayer[nextFrame].start
                    -- 位置
                


                    effectNode:setPositionX(calValueByK(start.x, nextStart.x, percent))
                    effectNode:setPositionY(calValueByK(start.y, nextStart.y, percent))
                    
                    -- 旋转
                    effectNode:setRotation(start.rotation + (nextStart.rotation - start.rotation) * percent)
                    -- 拉伸

                    effectNode:setScaleX(start.scaleX + (nextStart.scaleX - start.scaleX) * percent)
                    effectNode:setScaleY(start.scaleY + (nextStart.scaleY - start.scaleY) * percent)
                    -- 透明度
                    effectNode:setOpacity(start.opacity + (nextStart.opacity - start.opacity) * percent)
                end
            end
        end
    end
end

return EffectMovingNode
