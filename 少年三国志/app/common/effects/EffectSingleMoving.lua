-- EffectSingleMoving

-- @desc 第节点设计目的在于使用自定义的配置文件（通常位于res/moving/目录下）播放自定义动画

local EffectSingleMoving = class("EffectSingleMoving")

--ignoreAttr默认为空, 可以传哪些属性不做moving, 比如 position, opacity, scale, rotation
function EffectSingleMoving.run(node, effectJsonName, eventHandler, ignoreAttr, startFrame)
    local singleMoving = EffectSingleMoving.new(node, effectJsonName, eventHandler, ignoreAttr, startFrame)
    return singleMoving
end


local defaultDouble = 1
local effectDesignInterval = 1/30 -- 动画设计时的FPS速度



function EffectSingleMoving:ctor(node, effectJsonName, eventHandler, ignoreAttr, startFrame)
    --self:setCascadeOpacityEnabled(true)
    
    -- effectJson名称
    self._effectJsonName = effectJsonName
    
    -- json路径
    self._effectJsonPath = "moving/"..effectJsonName

    -- 解析json并保存起来
    self._effectJson = decodeJsonFile(self._effectJsonPath..".json")
    

    
    -- 事件处理函数
    self._eventHandler = eventHandler

    --ignoreAttr默认为空, 可以传哪些属性不做moving, 比如 position, opacity, scale, rotation

    self._ignoreAttr = ignoreAttr or {}
    

    -- 倍数
    self._double = defaultDouble

    self._node = node
   

    -- 帧数计数
    self._frameIndex = 1


    self._lastFrameStart = 0

    self._startX = self._node:getPositionX()
    self._startY = self._node:getPositionY()
    --print("set starty " .. self._startY )
    self._startScaleX = self._node:getScaleX()
    self._startScaleY= self._node:getScaleY()
 


    self._totalDt = 0

    --默认显示第一帧
    self:_step()


    if startFrame == nil then
        startFrame = 1
    end
    self:gotoAndPlay(startFrame)

end

function EffectSingleMoving:play()

    -- 开启update循环
    self._node:scheduleUpdate(handler(self, self._update), 0)
    
end

--frame > 0
function EffectSingleMoving:gotoAndPlay(frame)
    self:play()

    for i=1, frame-1 do 
        self:_step()
    end
    
end

function EffectSingleMoving:stop()
    if self._node ~= nil then
        self._node:unscheduleUpdate()
        self._node = nil

    end
end




function EffectSingleMoving:_update(dt)
    self._totalDt = self._totalDt + dt -- 毫秒
    

     -- 计算实际上应该播放多少帧
     local extraInterval = effectDesignInterval/self._double
     local frames = math.floor(self._totalDt/extraInterval)
     if frames > self._double  then frames = math.floor(self._double) end

     for i=1, frames do
     
        self._totalDt = self._totalDt - extraInterval
        
        if not self:_step() then
             break
        end
         
     end

end


function EffectSingleMoving:_step()
    local fx = "f"..self._frameIndex
    local effectJson = self._effectJson

    self:_nodeStep()

    local ret = true
    local frameIndex = self._frameIndex
    self._frameIndex = self._frameIndex + 1

    if effectJson.events[fx] == "forever" then
        self._frameIndex = 1
    elseif effectJson.events[fx] == "finish" then
        self:stop()
        ret = false
    end

    if self._eventHandler and effectJson.events[fx] ~= nil then
        self._eventHandler(effectJson.events[fx], frameIndex, self)
    end
    
    return ret
end


local function calValueByK(start, endt, percent)
    return start + (endt-start)*percent;

end



function EffectSingleMoving:_nodeStep()
    
    local effectNode = self._node
    local targetKey = "target"
    local effectJson = self._effectJson
    local effectLayer = self._effectJson[targetKey]
    local frameIndex = self._frameIndex
        
    local fx = "f"..frameIndex

    if effectLayer[fx] then  self._lastFrameStart = frameIndex end

    local lastFrameStart =  self._lastFrameStart





    if lastFrameStart == frameIndex then
        
        local start = effectLayer[fx].start
        --ignoreAttr默认为空, 可以传哪些属性不做moving, 比如 position, opacity, scale, rotation
        if not self._ignoreAttr['position'] then


            effectNode:setPositionX(start.dx + self._startX)
            effectNode:setPositionY(start.dy + self._startY)

           -- print("set starty........... " .. (start.dy + self._startY) )

        end
        if not self._ignoreAttr['rotation'] then
           effectNode:setRotation(start.rotation)
        end 
        if not self._ignoreAttr['scale'] then
            effectNode:setScaleX(start.scaleX*self._startScaleX)
            effectNode:setScaleY(start.scaleY*self._startScaleY)
        end 
        if not self._ignoreAttr['opacity'] then
            effectNode:setOpacity(start.opacity)
        end 
        

    else
        local lastFx = "f"..lastFrameStart
        local start = effectLayer[lastFx].start
        local nextFrame = effectLayer[lastFx].nextFrame
        local frames = effectLayer[lastFx].frames
        if nextFrame then
            
            
            local percent = (frameIndex - lastFrameStart) / frames

            local nextStart = effectLayer[nextFrame].start
          
            -- 位置
            if not self._ignoreAttr['position'] then
               
                -- local startPosition = ccp(start.dx + self._startX, start.dy + self._startY)
                -- local nextStartPosition = ccp(nextStart.dx+ self._startX, nextStart.dy+ self._startY)


                -- effectNode:setPosition(ccpAdd(startPosition, ccpMult(ccpSub(nextStartPosition, startPosition), percent)))




                effectNode:setPositionX(calValueByK(start.dx + self._startX, nextStart.dx+ self._startX, percent))
                effectNode:setPositionY(calValueByK(start.dy + self._startY, nextStart.dy+ self._startY, percent))


                --print("set starty2==" .. (effectNode:getPositionY()) )

            end
            -- 旋转
            if not self._ignoreAttr['rotation'] then
               effectNode:setRotation(start.rotation + (nextStart.rotation - start.rotation) * percent)
            end 


            -- 拉伸
            if not self._ignoreAttr['scale'] then
                --print("scaley " .. ((start.scaleY + (nextStart.scaleY - start.scaleY) * percent)*self._startScaleY))

                effectNode:setScaleX((start.scaleX + (nextStart.scaleX - start.scaleX) * percent)*self._startScaleX)
                effectNode:setScaleY((start.scaleY + (nextStart.scaleY - start.scaleY) * percent)*self._startScaleY)
            end 
            -- 透明度
            if not self._ignoreAttr['opacity'] then
                effectNode:setOpacity(start.opacity + (nextStart.opacity - start.opacity) * percent)
            end 

            
            
        end
    end



end



function EffectSingleMoving:resetPosition()
    if not self._ignoreAttr['position'] and self._node ~= nil then 

        --如果之前没有播放完, 恢复位置
        self._node:setPositionX(self._startX)
        self._node:setPositionY(self._startY)

        
    end
end


return EffectSingleMoving
