--CCSModelLayerBase.lua

local CCSModelLayerBase = class ("CCSModelLayerBase", function(jsonFile, param, ...)
    if jsonFile ~= nil then
        if param ~= nil then
            if type(param) == "function" then
                return CCSModelLayer:createAsync(jsonFile, param)
            else
                return CCSModelLayer:create(jsonFile, param)
            end
        else
            return CCSModelLayer:create(jsonFile)
        end
    else
        return CCSModelLayer:create()
    end
end)


function CCSModelLayerBase:ctor( jsonFile, param, ... )
    self._layerName = jsonFile
    self._returnKeyClose = 0
    self._backKeypadFlag = false
    self._menuKeypadFlag = false
    self._funCallHelper = nil

    self:_onLayerLoad(jsonFile, param, ...)
    self._parentScene = nil
end


function CCSModelLayerBase:getLayerName(  )
    return self._layerName
end

function CCSModelLayerBase:registerKeypadEvent( backKey, menuKey )
    if backKey then 
        self._backKeypadFlag = true
        self:_doRegisterBackKeyHandler()
    end

    if menuKey then 
        self._menuKeypadFlag = true
        self:_doRegisterMenuKeyHandler()
    end
end

function CCSModelLayerBase:_doRegisterBackKeyHandler( ... )
    uf_keypadHandler:registerBackKeyHandler(function ( ... )
        return self:_onBackKeyHandler()
    end, self)
end

function CCSModelLayerBase:_doRegisterMenuKeyHandler( ... )
    uf_keypadHandler:registerMenuKeyHandler(function ( ... )
        return self:_onMenuKeyHandler()
    end, self)
end

function CCSModelLayerBase:unregisterKeypadEvent( ... )
    uf_keypadHandler:unregisterKeyHandler(self)
    self._backKeypadFlag = false
    self._menuKeypadFlag = false
end

function CCSModelLayerBase:_onBackKeyHandler( ... )
    local ret = self:onBackKeyEvent()
    if not ret and self._returnKeyClose ~= 0 then 
        self:animationToClose()        
        ret = true
    end

    return ret
end

function CCSModelLayerBase:onBackKeyEvent( ... )
    -- body
end

function CCSModelLayerBase:_onMenuKeyHandler( ... )
    return self:onMenuKeyEvent()
end

function CCSModelLayerBase:onMenuKeyEvent( ... )
    -- body
end

function CCSModelLayerBase:registerNodeEvent()
    local handler = function(event, param1, param2)
        if event == "enter" then
            self:_onLayerEnter()
        elseif event == "exit" then
            self:_onLayerExit()
        elseif event == "cleanup" then
            self:_onLayerUnload()
        elseif event == "clickclose" then
            self:_onClickClose()
        end
    end
    self:registerScriptHandler(handler)
end

function CCSModelLayerBase:unregisterNodeEvent()
    self:unregisterScriptHandler()
end

function CCSModelLayerBase:closeAtReturn( close )
    local flag = close and 1 or 0
    if flag == self._returnKeyClose then 
        return 
    end

    self._returnKeyClose = flag
    if self._returnKeyClose ~= 0 then 
        self:registerKeypadEvent(true, self._menuKeypadFlag)
    end
end

function CCSModelLayerBase:_onLayerLoad( ... )
	self:registerNodeEvent()
	if self.onLayerLoad ~= nil then 
       self:onLayerLoad(...)
    end
end

function CCSModelLayerBase:onLayerLoad( ... )
end

function CCSModelLayerBase:_onLayerEnter( )
    --__Log("CCSModelLayerBase::_onLayerEnter: name:%s, enter", self.class.__cname)
    UFCCSUIHooker.hitLayerHooker(self.class.__cname, "enter", self)
    -- if self._backKeypadFlag == 1 then 
    --     self:_doRegisterBackKeyHandler()
    -- end

    -- if self._menuKeypadFlag == 1 then 
    --     self:_doRegisterMenuKeyHandler()
    -- end
    self:onLayerEnter()
end

function CCSModelLayerBase:onLayerEnter( )
end

function CCSModelLayerBase:_onLayerExit( )
    --__Log("CCSModelLayerBase::_onLayerExit: name:%s, enter", self.class.__cname)
    UFCCSUIHooker.hitLayerHooker(self.class.__cname, "exit", self)
    -- if self._backKeypadFlag == 1 or self._menuKeypadFlag == 1 then 
    --     self:unregisterKeypadEvent()
    -- end
    self:onLayerExit()
end

function CCSModelLayerBase:onLayerExit( )
end

function CCSModelLayerBase:_onLayerUnload( )
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

function CCSModelLayerBase:onLayerUnload( )
end

function CCSModelLayerBase:_onClickClose( ... )
    local ret = self:onClickClose()
    if not ret then 
        self:animationToClose()
    end
end

function CCSModelLayerBase:onClickClose( ... )
    
end

-- touch event callback
function CCSModelLayerBase:registerTouchEvent( isMultiTouches, swallowsTouches, priority )
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

   -- __Log("registerTouchEvent: layer:[%s], isMultiTouches:%d, priority:%d, swallowsTouches:%d", 
     --   self.class.__cname, isMultiTouches and 1 or 0, priority, swallowsTouches and 1 or 0)
    --self:unregisterTouchEvent()
    self:registerScriptTouchHandler(handler, isMultiTouches, priority, swallowsTouches)
end

function CCSModelLayerBase:unregisterTouchEvent(  )
    self:unregisterScriptTouchHandler()
end

function CCSModelLayerBase:_onTouchBegin( xpos, ypos )
    return self:onTouchBegin(xpos, ypos)
end

function CCSModelLayerBase:onTouchBegin( xpos, ypos )
end

function CCSModelLayerBase:onTouchMove( xpos, ypos )
end

function CCSModelLayerBase:onTouchCancel( xpos, ypos )
end

function CCSModelLayerBase:onTouchEnd( xpos, ypos )
end

function CCSModelLayerBase:onTouchesBegin( touches )
end

function CCSModelLayerBase:onTouchesMove( touches )
end

function CCSModelLayerBase:onTouchesEnd( touches )
end

function CCSModelLayerBase:onTouchesCancel( touches )
end


function CCSModelLayerBase:_doCreateFunCallHelper( ... )
    if not self._funCallHelper then 
        self._funCallHelper = require(__UUZU_FRAME__..".tools.FuncCallHelper").new(self)
    end
end

function CCSModelLayerBase:callAfterFrameCount( frame, fun, target )
    if type(frame) ~= "number" or not fun then
        return 
    end

    self:_doCreateFunCallHelper()

    if self._funCallHelper then 
        self._funCallHelper:callAfterFrameCount(frame, fun, target)
    end
end

function CCSModelLayerBase:callAfterDelayTime( delay, args, fun, target )
    if type(delay) ~= "number" or delay <= 0 or not fun then 
        return false
    end

    self:_doCreateFunCallHelper()

    if self._funCallHelper then 
        self._funCallHelper:callAfterDelayTime( delay, args, fun, target )
    end
end

function CCSModelLayerBase:startAnimation( name, fun, target )
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
function CCSModelLayerBase:startAndCallAtFrame( name, frameIndex, fun, target )
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

function CCSModelLayerBase:close( )
    self:removeFromParentAndCleanup(true)
end

function CCSModelLayerBase:delayToClose( time )
    if type(time) ~= "number" or time <= 0 then
        return false
    end

    g_funcCallHelper:callAfterDelayTime(time, nil, function (  )
        self:animationToClose()
    end)
end

--[[
	level: it's a number which indicates that the priority of the model layer.
	when many model layers show together, then we should have a level to judge
	which one can receive touch msg first. it has four choice:
	1 >> ModelViewLevel_Default
	2 >> ModelViewLevel_Normal
	3 >> ModelViewLevel_MessageBox
	4 >> ModelViewLevel_Lock
	ModelViewLevel_Default is default level, ModelViewLevel_Lock is highest.
]]
function CCSModelLayerBase:setModelLevel( level )
	if level < ModelViewLevel_Default then 
		level = ModelViewLevel_Default
	end
	if level > ModelViewLevel_Lock then
		level = ModelViewLevel_Lock
	end

	self:setModelViewLevel(level)
end

function CCSModelLayerBase:setBackgroundColor( r, g, b, a )
	self:setBackColor(ccc4(r, g, b, a))
end

function CCSModelLayerBase:animationToClose( target )
    self:setTouchEnabled(false)
    self:removeBackColor()
    local action = CCEaseOut:create(CCScaleTo:create(0.15, 0), 0.15)
    local sharedApplication = CCApplication:sharedApplication()
    local target = sharedApplication:getTargetPlatform()
    if target == kTargetIphone or target == kTargetIpad or target == kTargetAndroid or target == kTargetWindows then
        action = CCSequence:createWithTwoActions(action, CCCallFunc:create(function (  )
            self:close()
            end))
    else
        action = CCSequence:create(action, CCCallFunc:create(function (  )
            self:close()
            end))
    end

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

return CCSModelLayerBase