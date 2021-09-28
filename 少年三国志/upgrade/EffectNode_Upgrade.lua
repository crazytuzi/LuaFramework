-- EffectNode

-- @desc 第节点设计目的在于使用自定义的配置文件（通常位于res/effect/目录下）播放自定义动画

--CCFileUtils:sharedFileUtils():addSearchPath("res/effect")


function _decodeJsonFile(jsonFileName)
    
    local json = require "framework.json"
    local jsonString = CCFileUtils:sharedFileUtils():getEncryptFileData(jsonFileName)
    assert(jsonString, "Could not read the json file with path: "..jsonFileName)
    
    local jsonConfig = json.decode(jsonString)
    
    return jsonConfig
end




local EffectNode = class("EffectNode", function() return CCNode:create() end)


function EffectNode:_setNodeEventEnabled(enabled, handler)
    if enabled then
        if not handler then
            handler = function(event)
                if event == "enter" then
                   -- self:onEnter()
                elseif event == "exit" then
                   -- self:onExit()
                elseif event == "enterTransitionFinish" then
                    --self:onEnterTransitionFinish()
                elseif event == "exitTransitionStart" then
                    --self:onExitTransitionStart()
                elseif event == "cleanup" then
                    self:onCleanup()
                end
            end
        end
        self:registerScriptHandler(handler)
    else
        self:unregisterScriptHandler()
    end
    return self
end

local defaultDouble = 1
local effectDesignInterval = 1/30 -- 动画设计时的FPS速度


local reservedKeys = {events=true, scale=true, png=true}



--内部结构如下:

-- *effectNode(key1)    (存放于self._playingSublayers)
-- *effectNode(key2)    (存放于self._playingSublayers)
-- *clippingNode(key3)  (存放于self._maskNodes)
-- **stencilNode(key3)(clippingNode的stencil)   (存放于self._maskStencilNodes) 
-- ***stencil(key3)(遮罩的实际样子,是stencilNode的子节点)   (存放于self._playingSublayers) 

local function isTypeOfEffectNode(o)
    if o._class_name_ ~= nil and tostring(o._class_name_) == "EffectNode" then
        return true
    end
    return false
end

local function debugPrint(str)
   --print(str)
end

function EffectNode:ctor(effectJsonName, eventHandler, colorOffset, resourceIniter, effectNodeCreator)
    self:setCascadeOpacityEnabled(true)
   debugPrint("create effectNode:" .. tostring(effectJsonName))
    -- effectJson名称
    self._effectJsonName = effectJsonName

    --getmetatable(self).__gc = function() print("collected!") end
    -- 解析json并保存起来
    -- self._effectJson = decodeJsonFile("effect/"..effectJsonName.."/"..effectJsonName..".json")




    self._playingSublayers = {}   --当前播放过程用的所有sub元件
    self._subLastStartFrame = {}  --每一个sub元件上一个关键帧的ID

    --跟遮罩有关的
    self._maskNodes = {}  --clipingnode
    self._maskStencilNodes = {} --stencil的父节点


    -- 事件处理函数
    self._eventHandler = eventHandler
    
    -- 帧数计数
    self._frameIndex = 1
    -- 倍数
    self._double = defaultDouble
               
    -- 根节点
    self._rootNode = CCNode:create()
    self:addChild(self._rootNode)
    self._rootNode:setCascadeOpacityEnabled(true)

    self._colorOffset = colorOffset
    -- print("coloroofse=" .. tostring(colorOffset) .. "   for " .. effectJsonName)

    self._totalDt = 0

    self._played = false

    ----下面3个缓存只存在根节点的effectNode才有用
    self._frames = {}  -- frame缓存
    self._resourceList = {}   --持有的所有PNG, PLIST
    self._jsonList = {}       -- 持有的所有JSON文件


    --下面这个不仅存在于根节点
    self._poolSublayers = {}  --sub元件回收池
    

    --加载素材
    if resourceIniter ~= nil then
        self._resourceIniter = resourceIniter
    else
        local _defaultResourceIniter 

        _defaultResourceIniter = {
            jsonGetter = function(effectJsonName) 
                if  self._jsonList[effectJsonName] == nil then
                    -- print("load json " .. effectJsonName)

                    self._jsonList[effectJsonName] = _decodeJsonFile("effect/"..effectJsonName.."/"..effectJsonName..".json")
                else
                    -- print("cache json")
                end
                return self._jsonList[effectJsonName]
            end,
            pngIniter = function(effectJsonName) 
                local effectJson = _defaultResourceIniter.jsonGetter(effectJsonName)

                if self._resourceList[effectJsonName] then
                    --loaded
                else
                    local effectJsonPath = "effect/" .. effectJsonName .. "/" .. effectJsonName
                    if effectJson['png'] ~= nil then
                        if effectJson['png'] ~= "" then
                            self:_loadResource(effectJsonPath .. ".plist",  "effect/" ..effectJsonName.."/".. effectJson['png'])      
                        end
                    else 
                        self:_loadResource(effectJsonPath .. ".plist", effectJsonPath .. ".png") 
                    end
                    self._resourceList[effectJsonName] = 1

                end
            end,
            framesGetter = function(png) 
            
                if self._frames[png] == nil then
                    self._frames[png] = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(png)
                    debugPrint("set sprite frame" .. png .. "," .. self._effectJsonName)
                end
                return self._frames[png]
            end,


        }
      

        self._resourceIniter = _defaultResourceIniter
    end


    self._effectJson = self._resourceIniter.jsonGetter(self._effectJsonName)
    self._resourceIniter.pngIniter(self._effectJsonName)

    self._effectNodeCreator = effectNodeCreator
    self:_setNodeEventEnabled(true)

    --默认第一帧
    self:_step()
end

function EffectNode:_loadResource(plist, png)
    --print("load resource: " .. png .. ",from " .. self._effectJsonName)

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(plist,  png )
    local resource = CCTextureCache:sharedTextureCache():textureForKey(png)
    if resource ~= nil then
        resource:retain()
        table.insert(self._resourceList, resource)
    end
end

function EffectNode:_defaultResourceIniter(effectJsonName, effectJson)

    -- json路径
    if self._resourceList[effectJsonName] then
        --loaded
    else
        local effectJsonPath = "effect/" .. effectJsonName .. "/" .. effectJsonName
        if effectJson['png'] ~= nil then
            if effectJson['png'] ~= "" then
                self:_loadResource(effectJsonPath .. ".plist",  "effect/" ..effectJsonName.."/".. effectJson['png'])      
            end
        else 
            self:_loadResource(effectJsonPath .. ".plist", effectJsonPath .. ".png") 

        end
    end
end

function EffectNode:play()
 
    --第一次play不需要重置, 以后需要
    if self._played then
        -- 重置帧数
        self._frameIndex = 1
        
        -- 清空step数组
        --self._effectStepArr = {}
        
        
        -- 清空节点
        for key, sub in pairs(self._playingSublayers) do
            self:_deleteSub(key,  sub )
        end
        self._subLastStartFrame = {}
        self._playingSublayers = {}
        self._maskNodes = {}  
        self._maskStencilNodes = {} 
   
        -- self._rootNode:removeAllChildrenWithCleanup(true)

    else
        self._played = true

    end


    self._paused = false

    -- 开启update循环
    self:scheduleUpdate(handler(self, self._update), 0)
 
    for k, sub in pairs(self._playingSublayers) do
         if isTypeOfEffectNode(sub) then
            sub:play()
         end
    end
end

function EffectNode:stop()
    self:unscheduleUpdate()

    for i, sub in pairs(self._playingSublayers) do
        if isTypeOfEffectNode(sub) then
            sub:stop()
         end
    end
end

function EffectNode:pause()
    self._paused = true
    for i, sub in pairs(self._playingSublayers) do
        if isTypeOfEffectNode(sub) then
            sub:pause()
         end
    end
end

function EffectNode:resume()
    self._paused = false
    for i, sub in pairs(self._playingSublayers) do
        if isTypeOfEffectNode(sub) then
            sub:resume()
         end
    end
end

function EffectNode:setDouble(double)
    assert(double and double > 0, "double could not be nil and negative !")
    self._double = double
end



function EffectNode:getEffectNode(key)
    --dump(self._playingSublayers)
    return self._playingSublayers[key]    
end

function EffectNode:isPlaying()
    --dump(self._playingSublayers)
    return self._played and not self._paused
end



function EffectNode:_update(dt)
    if self._paused then
        return
    end
    self._totalDt = self._totalDt or 0
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




function EffectNode:_step()
    local fx = "f"..self._frameIndex
    local effectJson = self._effectJson
   -- print("step.." .. tostring(_effectJsonName))

    -- 用来保存effectStep数据用数组
    --self._effectStepArr = self._effectStepArr or {}
    for k, v in pairs(effectJson) do
        if not reservedKeys[k] then
            self:_stepSub(k,  self._frameIndex)
            --self._effectStepArr[k] = self._effectStepArr[k] or self:_effectStep(k, v)
            --self._effectStepArr[k](self._frameIndex)
        end
    end

    if self._eventHandler and effectJson.events[fx] then
        self._eventHandler(effectJson.events[fx], self._frameIndex, self)
    end
    
    self._frameIndex = self._frameIndex + 1

    if effectJson.events[fx] == "forever" then
        self._frameIndex = 1

    elseif effectJson.events[fx] == "finish" then
        self:unscheduleUpdate()
        return false
    end

    return true
end

local function calValueByK(start, endt, percent)
    return start + (endt-start)*percent;

end

function EffectNode:_stepSub(key, frameIndex)
    local lastFrameStart = self._subLastStartFrame[key]
    local playingSub = self._playingSublayers[key]
    local subInfo = self._effectJson[key]
    local fx = "f" .. frameIndex

    if lastFrameStart or subInfo[fx] then

        if subInfo[fx] and subInfo[fx].remove then
            if playingSub == nil then
                debugPrint("??" .. tostring(lastFrameStart) .."," .. fx .. "," .. key)
            else
                --playingSub:removeFromParentAndCleanup(true)
                lastFrameStart = nil
                self:_deleteSub(key,  playingSub )
                self._playingSublayers[key] = nil

                --self._effectStepArr[key] = nil
                self._subLastStartFrame[key] = nil
                
                --print("remove")
            end
           
            return
        end

        if subInfo[fx] then 
            self._subLastStartFrame[key] = frameIndex 
            lastFrameStart = frameIndex
        end
        
        if lastFrameStart == frameIndex then
            
            if not playingSub then
               
                playingSub = self:_createSub(key, subInfo, fx)

                if self:isPlaying() and isTypeOfEffectNode(playingSub) then
                    --debugPrint("play playingSub " .. tostring(key))
                    playingSub:play()
                end
            end
          
            if not playingSub then
                debugPrint("??!!!!!!!!!!" .. ",impossible ..playingsub is nil " .. fx .. "," .. key)
                return
            end
            
            local start = subInfo[fx].start
            playingSub:setPositionXY(start.x, start.y)
            
            playingSub:setRotation(start.rotation)
            playingSub:setScaleX(start.scaleX)
            playingSub:setScaleY(start.scaleY)
            if start.opacity ~= nil then
                playingSub:setOpacity(start.opacity)              
            end
            
            if start.png and start.png ~= "" then  self:_createSprite(start.png, playingSub, key) end



        else
            local lastFx = "f"..lastFrameStart

            local start = subInfo[lastFx].start
            local nextFrame = subInfo[lastFx].nextFrame
            local frames = subInfo[lastFx].frames
            if nextFrame then
                if subInfo[nextFrame].remove then return end
                if frames == nil or frames ==0 then
                    frames = 1
                end
                local percent = (frameIndex - lastFrameStart) / frames
                if percent == nil then
                    percent = 1
                end 
                local nextStart = subInfo[nextFrame].start
                -- 位置
                --local startPosition = ccp(start.x, start.y)
                --local nextStartPosition = ccp(nextStart.x, nextStart.y)



               -- playingSub:setPosition(ccpAdd(startPosition, ccpMult(ccpSub(nextStartPosition, startPosition), percent)))
                
                --playingSub:setPosition( ccp( calValueByK(start.x, nextStart.x, percent),  calValueByK(start.y, nextStart.y, percent)    ) )
                
                playingSub:setPositionXY(calValueByK(start.x, nextStart.x, percent),  calValueByK(start.y, nextStart.y, percent))


                -- 旋转
                playingSub:setRotation(start.rotation + (nextStart.rotation - start.rotation) * percent)
                -- 拉伸

                playingSub:setScaleX(start.scaleX + (nextStart.scaleX - start.scaleX) * percent)
                playingSub:setScaleY(start.scaleY + (nextStart.scaleY - start.scaleY) * percent)
                -- 透明度
                if start.opacity ~= nil and nextStart.opacity ~= nil then
                   playingSub:setOpacity(start.opacity + (nextStart.opacity - start.opacity) * percent)
                end
                
            end
        end
    end

end

function EffectNode:_getMaskParent(key)
    local effectJson = self._effectJson
    local node = self._maskNodes[key]
    if node ==nil then
        local maskInfo = effectJson[key]
        node  = CCClippingNode:create()   
        
        self._rootNode:addChild(node, maskInfo.order)
        self._maskNodes[key] = node

    end
    return node

end


function EffectNode:_getMaskStencil(key)
    local effectJson = self._effectJson

    local node = self._maskStencilNodes[key]
    if node ==nil then

        local maskInfo = effectJson[key]
        node = CCNode:create()
        local parent = self:_getMaskParent(key)
        if parent:getStencil() == nil then
            parent:setStencil(node)

            if maskInfo.mask_info.mask_type ~= "image" then
                --矩形遮罩 或者circle遮罩

            else
                --图形遮罩
                parent:setAlphaThreshold( 0.05 );
            end

        end
        self._maskStencilNodes[key] = node

    end
    return node

end

--创建drawNode 里面是矩形或者圆形
function EffectNode:_createDrawNode(mask_info)
    local effectNode = CCDrawNode:create()
    local sharedApplication = CCApplication:sharedApplication()
    local target = sharedApplication:getTargetPlatform()
    if mask_info.mask_type == "circle" then

        local r = mask_info.width/2
        local pointsCount = 200
        local pointarr1 = CCPointArray:create(pointsCount)

        local angle = 2*math.pi/pointsCount

        for i=1,pointsCount do
           pointarr1:add(ccp(r*math.cos((i-1)*angle), r*math.sin((i-1)*angle)))

        end
        
        if target == kTargetIphone or target == kTargetIpad or target == kTargetAndroid then
            effectNode:drawPolygon(pointarr1:fetchPoints(), pointsCount, ccc4f(1.0, 1.0, 1, 1), 1, ccc4f(0.1, 1, 0.1, 1) )            
        else
            G_WP8.drawPolygon(effectNode, pointarr1, 4, ccc4f(1.0, 1.0, 1, 1), 1, ccc4f(0.1, 1, 0.1, 1))
        end


    else
        local pointarr1 = CCPointArray:create(4)
        local halfw = mask_info.width/2
        local halfh = mask_info.height/2
    
        pointarr1:add(ccp(-halfw, -halfh))
        pointarr1:add(ccp(-halfw, halfh))
        pointarr1:add(ccp(halfw, halfh))
        pointarr1:add(ccp(halfw, -halfh))
        
        if target == kTargetIphone or target == kTargetIpad or target == kTargetAndroid then
            effectNode:drawPolygon(pointarr1:fetchPoints(), 4, ccc4f(1.0, 1.0, 1, 1), 1, ccc4f(0.1, 1, 0.1, 1) )
        else
            G_WP8.drawPolygon(effectNode, pointarr1, 4, ccc4f(1.0, 1.0, 1, 1), 1, ccc4f(0.1, 1, 0.1, 1))
        end
    end
    return effectNode
end

local function getColorOffset(color)
    return  {color.red/255, color.green/255, color.blue/255, color.alpha/255} 
end


--根据png名字创建一个ccsprite
function EffectNode:_createSprite(png, sprite, key, colorOffset)   

    local ret = false
    local outsideObject = nil    
    if sprite == nil then
        debugPrint("---_createSprite" .. tostring(key)  .. " from " ..self._effectJsonName)

        --这是第一次创建这个sprite
        -- display.addSpriteFramesWithFile(spritePlist, spritePng)
        local sprite
        if colorOffset ~= nil then
            
            sprite = CCSpriteLighten:createWithSpriteFrameName(png)   
            
            if sprite.setColorOffsetRGBA ~= nil then
                sprite:setColorOffsetRGBA(colorOffset[1], colorOffset[2], colorOffset[3], colorOffset[4]  )
            else
                sprite:setColorOffset(ccc4f(colorOffset[1], colorOffset[2], colorOffset[3], colorOffset[4]) )
            end
        else
            if self._effectNodeCreator ~= nil then
               ret, outsideObject =  self._effectNodeCreator(sprite, png, key)  -- effectNode之外可以自定义某个动画原件                  
            end
            if not ret then
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(png)
                if frame then
                    sprite = CCSprite:createWithSpriteFrame(frame)
                else
                    sprite = CCSprite:create()
                end
                --print("new sprite " .. png)
                --sprite = display.newSprite("#"..png) 
            else
                sprite =  outsideObject   
            end
            
        end
        return sprite
    else
        if self._effectNodeCreator ~= nil then
           ret, outsideObject =  self._effectNodeCreator(sprite, png, key)     -- effectNode之外可以自定义某个动画原件             
        end 
        if not ret then
           
            sprite:setDisplayFrame(self._resourceIniter.framesGetter(png))   
        else
            sprite =  outsideObject   
        end   

        return sprite
    end
end

--创建某层上的子节点
function EffectNode:_createSub(key, subInfo, frame)
    -- print("create sub" .. tostring(key))

    local parentNode = self._rootNode

    local sub 

    if self._poolSublayers[key] then
        sub = self._poolSublayers[key]
        sub:setVisible(true)
        --debugPrint("get pool sub" .. tostring(key) .. " from " .. self._effectJsonName)

    else 
        --create
        debugPrint("---real create sub" .. tostring(key)  .. " from " ..self._effectJsonName)

        if subInfo.mask then
            --这是被遮罩                
            parentNode = self:_getMaskParent(subInfo.mask)
        elseif subInfo.mask_info then
            -- 这是遮罩的stencil层
            parentNode = self:_getMaskStencil(key)

        end


        -- 如果当前节点层是指定effect，表示是嵌套层
        if subInfo.effect then
            local colorOffset = self._colorOffset
            if subInfo[frame].start.color then
                colorOffset = getColorOffset(subInfo[frame].start.color)
            end
            local embedEffect = EffectNode.new(subInfo.effect, nil , colorOffset, self._resourceIniter, self._effectNodeCreator)
            parentNode:addChild(embedEffect, subInfo.order)

            -- 
            sub = embedEffect
        else
            --如果这个是遮罩层, 而且是rect/circle类型的遮罩,那么创建一个矩形/圆形即可,不需要加载图片
            if  subInfo.mask_info and  subInfo.mask_info.mask_type ~= "image" then
                sub = self:_createDrawNode( subInfo.mask_info)
                parentNode:addChild(sub, subInfo.order)


            else
                -- 创建ccsprite
                local colorOffset = self._colorOffset
                if subInfo[frame].start.color then
                    colorOffset = getColorOffset(subInfo[frame].start.color)
                end
                sub =  self:_createSprite(subInfo[frame].start.png, sub, key, colorOffset) 


                -- print("eff= " .. tostring(effectNode))
                parentNode:addChild(sub, subInfo.order)
            end

            
        end
                                
        sub:setCascadeOpacityEnabled(true)

    end


   
    self._playingSublayers[key] = sub

    return sub
end

function EffectNode:_deleteSub(key,  playingSub)
    --debugPrint("set pool sub" .. tostring(key) .. " from " .. self._effectJsonName)
    -- print("play embedEffect " .. tostring(key))

    playingSub:setVisible(false)


        playingSub:setPositionXY(0, 0)

    --playingSub:setPosition(ccp(0,0))
    playingSub:setScale(1)
    playingSub:setRotation(0)
    playingSub:setOpacity(255)
    if isTypeOfEffectNode(playingSub) then
        playingSub:pause()
    end
    self._poolSublayers[key] = playingSub

end



function EffectNode:onCleanup()
    --print("clen effectNode:" .. tostring(self._effectJsonName))
    for i, resource in ipairs (self._resourceList) do 
        resource:release()
        debugPrint("------>release resource: ")

    end

    self._resourceList = {}
    self._jsonList = {}
    self._poolSublayers = {}
end

return EffectNode
