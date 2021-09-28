--CCSNormalLayerBase.lua


local CCSNormalLayerBase = class ("CCSNormalLayerBase", function(jsonFile, param, ...)
    if jsonFile ~= nil then
        if type(param) == "function" then
            return CCSNormalLayer:createAsync(jsonFile, param)
        else
            return CCSNormalLayer:create(jsonFile)
        end
    else 
        return CCSNormalLayer:create()
    end
end)

function CCSNormalLayerBase:ctor( jsonFile, param, ... )
    self._layerName = jsonFile
    self._backKeypadFlag = false
    self._menuKeypadFlag = false
    self._funCallHelper = nil

    self:_onLayerLoad(jsonFile, param, ...)
    self._parentScene = nil
end


function CCSNormalLayerBase:getLayerName(  )
    return self._layerName
end

function CCSNormalLayerBase:registerKeypadEvent( backKey, menuKey )
    if backKey then 
        self._backKeypadFlag = true
        self:_doRegisterBackKeyHandler()
    end

    if menuKey then 
        self._menuKeypadFlag = true
        self:_doRegisterMenuKeyHandler()
    end
end

function CCSNormalLayerBase:_doRegisterBackKeyHandler( ... )
    uf_keypadHandler:registerBackKeyHandler(function ( ... )
        return self:_onBackKeyHandler()
    end, self)
end

function CCSNormalLayerBase:_doRegisterMenuKeyHandler( ... )
    uf_keypadHandler:registerMenuKeyHandler(function ( ... )
        return self:_onMenuKeyHandler()
    end, self)
end

function CCSNormalLayerBase:unregisterKeypadEvent( ... )
    uf_keypadHandler:unregisterKeyHandler(self)
    self._backKeypadFlag = false
    self._menuKeypadFlag = false
end

function CCSNormalLayerBase:_onBackKeyHandler( ... )
    return self:onBackKeyEvent()
end

function CCSNormalLayerBase:onBackKeyEvent( ... )
    -- body
end

function CCSNormalLayerBase:_onMenuKeyHandler( ... )
    return self:onMenuKeyEvent()
end

function CCSNormalLayerBase:onMenuKeyEvent( ... )
    -- body
end
function CCSNormalLayerBase:registerNodeEvent()
    local handler = function(event, param1, param2)
        if event == "enter" then
            self:_onLayerEnter()
        elseif event == "exit" then
            self:_onLayerExit()
        elseif event == "cleanup" then
            self:_onLayerUnload()
        end
    end
    self:registerScriptHandler(handler)
end

function CCSNormalLayerBase:unregisterNodeEvent()
    self:unregisterScriptHandler()
end

function CCSNormalLayerBase:_onLayerLoad( ... )
	self:registerNodeEvent()
	if self.onLayerLoad ~= nil then 
       self:onLayerLoad( ... )
    end
end

function CCSNormalLayerBase:onLayerLoad( ... )
end

function CCSNormalLayerBase:_onLayerEnter( )
    UFCCSUIHooker.hitLayerHooker(self.class.__cname, "enter", self)
    -- if self._backKeypadFlag == 1 then 
    --     self:_doRegisterBackKeyHandler()
    -- end

    -- if self._menuKeypadFlag == 1 then 
    --     self:_doRegisterMenuKeyHandler()
    -- end

    self:onLayerEnter()
end

function CCSNormalLayerBase:onLayerEnter( )
end

function CCSNormalLayerBase:_onLayerExit( )
    UFCCSUIHooker.hitLayerHooker(self.class.__cname, "exit", self)
    -- if self._backKeypadFlag or self._menuKeypadFlag then 
    --     self:unregisterKeypadEvent()
    -- end
    self:onLayerExit()
end

function CCSNormalLayerBase:onLayerExit( )
end

function CCSNormalLayerBase:_onLayerUnload( )
    if uf_eventManager then 
        uf_eventManager:removeListenerWithTarget(self)
    end
    if self._funCallHelper then 
        self._funCallHelper:clearCallHelper()
        self._funCallHelper:removeFromParentAndCleanup(true)
        self._funCallHelper = nil
    end
    if self._backKeypadFlag or self._menuKeypadFlag then 
        self:unregisterKeypadEvent()
    end
    self:onLayerUnload()
end

function CCSNormalLayerBase:onLayerUnload( )
end

-- touch event callback
function CCSNormalLayerBase:registerTouchEvent( isMultiTouches, swallowsTouches, priority )
    if type(isMultiTouches) ~= "boolean" then 
        isMultiTouches = false
    end
    if type(priority) ~= "number" then
        priority = self:getTouchPriority()
    end
    if type(swallowsTouches) ~= "boolean" then
        swallowsTouches = false
    end

    local handler = nil
    if not isMultiTouches then
        handler = function ( event, xpos, ypos )
            if event == "began" then
                return self:_onTouchBegin(xpos, ypos)
            elseif event == "moved" then
                self:onTouchMove(xpos, ypos)
            elseif event == "ended" then
                self:onTouchEnd(xpos, ypos)
            elseif event == "cancelled" then 
                self:onTouchCancel(xpos, ypos)
            end
        end
    else
        handler = function ( event, touches  )
            if event == "began" then
                self:onTouchesBegin(touches)
            elseif event == "moved" then
                self:onTouchesMove(touches)
            elseif event == "ended" then
                self:onTouchesEnd(touches)
            elseif event == "cancelled" then 
                self:onTouchesCancel(touches)
            end
        end
    end

    --self:unregisterTouchEvent()
    self:registerScriptTouchHandler(handler, isMultiTouches, priority, swallowsTouches)
end

function CCSNormalLayerBase:unregisterTouchEvent(  )
    self:unregisterScriptTouchHandler()
end

function CCSNormalLayerBase:_onTouchBegin( xpos, ypos )
    local ret = self:onTouchBegin(xpos, ypos)
    if type(ret) ~= "boolean" then 
        ret = false
    end

    return ret
end

function CCSNormalLayerBase:onTouchBegin( xpos, ypos )
    return false
end

function CCSNormalLayerBase:onTouchMove( xpos, ypos )
end

function CCSNormalLayerBase:onTouchCancel( xpos, ypos )
end

function CCSNormalLayerBase:onTouchEnd( xpos, ypos )
end

function CCSNormalLayerBase:onTouchesBegin( touches )
end

function CCSNormalLayerBase:onTouchesMove( touches )
end

function CCSNormalLayerBase:onTouchesEnd( touches )
end

function CCSNormalLayerBase:onTouchesCancel( touches )
end

function CCSNormalLayerBase:_doCreateFunCallHelper( ... )
    if not self._funCallHelper then 
        self._funCallHelper = require(__UUZU_FRAME__..".tools.FuncCallHelper").new(self)
    end
end

function CCSNormalLayerBase:callAfterFrameCount( frame, fun, target )
    if type(frame) ~= "number" or not fun then
        return 
    end

    self:_doCreateFunCallHelper()

    if self._funCallHelper then 
        self._funCallHelper:callAfterFrameCount(frame, fun, target)
    end
end

function CCSNormalLayerBase:callAfterDelayTime( delay, args, fun, target )
    if type(delay) ~= "number" or delay <= 0 or not fun then 
        return false
    end

    self:_doCreateFunCallHelper()

    if self._funCallHelper then 
        self._funCallHelper:callAfterDelayTime( delay, args, fun, target )
    end
end

function CCSNormalLayerBase:startAnimation( name, fun, target )
	local callHandler = function (  )
        if target ~= nil and fun ~= nil then 
            fun(target)
        elseif fun ~= nil then 
            fun()
        end
    end

    self:playAnimation(name, callHandler)
end

--[[
 frameIndex: it is the frame should call |fun| when playing, it has two condition:
 1 >>  it is a number, for example: 5, then |fun| only called at frame 5
 2 >>  it is a table, for example:{7, 29, 31}, then |fun| will be called at frame 7, 29, and 31
]]
function CCSNormalLayerBase:startAndCallAtFrame( name, frameIndex, fun, target )
	local callHandler = function (  )
        if target ~= nil and fun ~= nil then 
            fun(target)
        elseif fun ~= nil then 
            fun()
        end
    end

    self:clearFrameCallback(name)
    if type(frameIndex) == "number" then
    	self:addFrameCallback(name, frameIndex, callHandler)
    elseif type(frameIndex) == "table" then
    	for key, value in ipairs(frameIndex) do 
    		self:addFrameCallback(name, value, callHandler)
    	end
    end

    self:playAnimation(name)
end

function CCSNormalLayerBase:close( )
    self:removeFromParentAndCleanup(true)
end

function CCSNormalLayerBase:delayToClose( time )
    if type(time) ~= "number" or time <= 0 then
        return false
    end

    g_funcCallHelper:callAfterDelayTime(time, nil, function (  )
        self:close()
    end)
end

function CCSNormalLayerBase:animationToClose( target )
    self:unregisterTouchEvent()
    self:removeBackColor()

    local action = CCEaseOut:create(CCScaleTo:create(0.15, 0), 0.15)
    action = CCSequence:createWithTwoActions(action, CCCallFunc:create(function (  )
        self:close()
        end))

    local obj = target 
    if type(obj) == "string" then 
        obj = self:getWidgetByName(obj)
    elseif type(obj) == "userdata" then 
    else 
        obj = nil 
    end

    if obj then 
        obj:runAction(action)
    else
        self:runAction(action)
    end
    self:setTouchEnabled(false)
end


return CCSNormalLayerBase