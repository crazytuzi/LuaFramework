--ModelLayer

local CCBModelLayerBase = class("CCBModelLayerBase", function(ccbFile, clr)
    return UIModelLayer:create(ccbFile, clr)
end)

function CCBModelLayerBase:ctor( ccbfile, ... )
    self._layerName = ccbfile
    self:_onLayerLoad()
    self._parentScene = nil
    self._animationCB = {}
end

function CCBModelLayerBase:setParentScene( scene )
    self._parentScene = scene
end

function CCBModelLayerBase:getParentScene(  )
    return self._parentScene
end

function CCBModelLayerBase:getLayerName(  )
    return self._layerName
end

function CCBModelLayerBase:isLayer( )
    return true
end

function CCBModelLayerBase:registerNodeEvent()
    local handler = function(event, param1, param2)
        if event == "enter" then
            self:onLayerEnter()
        elseif event == "exit" then
            self:onLayerExit()
        elseif event == "cleanup" then
            self:onLayerUnload()
        elseif event == "animation_finish" then 
            self:onAnimateFinish(param1)
        elseif event == "animation_callback" then
            self:_onAnimationCallback(param1)
        end
    end
    self:registerScriptHandler(handler)
end

function CCBModelLayerBase:unregisterNodeEvent()
    self:unregisterScriptHandler()
end

function CCBModelLayerBase:_onLayerLoad( )
    --__Log("CCBModelLayerBase:_onLayerLoad")
	self:registerNodeEvent()
    if self.onLayerLoad ~= nil then 
	   self:onLayerLoad()
    end
end

function CCBModelLayerBase:_onAnimationCallback( selector )
    local cb = self._animationCB[selector]
    if type(cb) == "table" then
        if cb[1] ~= nil and cb[2] ~= nil then 
            cb[1](cb[2], selector)
        elseif cb[1] ~= nil then
            cb[1](selector)
        end
    end

    self:onAnimationCallback(selector)
end

function CCBModelLayerBase:onLayerLoad( )
end

function CCBModelLayerBase:onLayerUnload( )
end

function CCBModelLayerBase:onLayerEnter( )
end

function CCBModelLayerBase:onLayerExit( )
end

function CCBModelLayerBase:onAnimateFinish( name )
end

function CCBModelLayerBase:onAnimationCallback( selector )
end

-- touch event callback
function CCBModelLayerBase:registerTouchEvent( isMultiTouches, priority, swallowsTouches )
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
                self:onTouchCancel(xpos, ypos)
            elseif event == "cancelled" then 
                self:onTouchEnd(xpos, ypos)
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

    self:registerScriptTouchHandler(handler, isMultiTouches, priority, swallowsTouches)
end

function CCBModelLayerBase:unregisterTouchEvent(  )
    self:unregisterScriptTouchHandler()
end

function CCBModelLayerBase:_onTouchBegin( xpos, ypos )
    self:onTouchBegin(xpos, ypos)
    return true
end

function CCBModelLayerBase:onTouchBegin( xpos, ypos )
end

function CCBModelLayerBase:onTouchMove( xpos, ypos )
end

function CCBModelLayerBase:onTouchCancel( xpos, ypos )
end

function CCBModelLayerBase:onTouchEnd( xpos, ypos )
end

function CCBModelLayerBase:onTouchesBegin( touches )
end

function CCBModelLayerBase:onTouchesMove( touches )
end

function CCBModelLayerBase:onTouchesEnd( touches )
end

function CCBModelLayerBase:onTouchesCancel( touches )
end

function CCBModelLayerBase:registerMenuHandler(menuName, fun, target )
	local node = self:getNode(menuName)
	if node ~= nil then 
        local callHandler = function (  )
            if target ~= nil and fun ~= nil then 
                fun(target)
            elseif fun ~= nil then 
                fun()
            end
        end
		self:setCallback(node, callHandler)
        return true
	else
		__Log(string.format("[CCBModelLayerBase]register menu handler {%s} failed", menuName))
        return false
	end
end

function CCBModelLayerBase:registerAnimationCallback( selector, fun, target )
    if type(selector) ~= "string" or type(fun) ~= "function" then 
        return nil
    end

    self._animationCB[selector] = {fun, target}
end

function CCBModelLayerBase:assignChildPriority( child, zorder, tag )
    return self:assignChildPriorityForParent(self, child, zorder, tag)
end

function CCBModelLayerBase:assignChildPriorityForParent( parent, child, zorder, tag )
    if child == nil or parent == nil then
        return false
    end
    self:assginChildTouchPriority(parent, child)
    return true
end

function CCBModelLayerBase:onLayerEvent( event, sender, ... )
    
end

function CCBModelLayerBase:sendSceneEvent( event, sender, ... )
    if self._parentScene == nil then
        __Log("parent scene is nil")
        return false
    end

    if self._parentScene.onSceneEvent ~= nil then 
        return self._parentScene.onSceneEvent(self._parentScene, event, sender, ...)
    end

    return false
end

function CCBModelLayerBase:sendLayerEvent( layerName, event, sender, ... )
    if layerName == nil or self._parentScene == nil then
        return false
    end
    
    if layerName == self._layerName then 
        return self.onLayerEvent(event, sender, ...)
    end

    return self._parentScene:sendLayerEvent(layerName, event, sender, ...)
end

function CCBModelLayerBase:close( )
    self:removeFromParentAndCleanup(true)
end

function CCBModelLayerBase:delayToClose( time )
    if type(time) ~= "number" or time <= 0 then
        return false
    end

    g_funcCallHelper:callAfterDelayTimeOnObj(self, time, nil, function (  )
        self:close()
    end)
end


return CCBModelLayerBase

