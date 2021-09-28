--CCBNormalLayerBase

local CCBNormalLayerBase = class("CCBNormalLayerBase", function(ccbFile)
    return UINormalLayer:create(ccbFile)
end)

function CCBNormalLayerBase:ctor( ccbfile,... )
    self._layerName = ccbfile
    self:_onLayerLoad()
    self._parentScene = nil
    self._animationCB = {}
end

function CCBNormalLayerBase:setParentScene( scene )
    self._parentScene = scene
end

function CCBNormalLayerBase:getParentScene(  )
    return self._parentScene
end

function CCBNormalLayerBase:getLayerName(  )
    return self._layerName
end

function CCBNormalLayerBase:isLayer( )
    return true
end

function CCBNormalLayerBase:registerNodeEvent()
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

function CCBNormalLayerBase:unregisterNodeEvent()
    self:unregisterScriptHandler()
end

function CCBNormalLayerBase:_onLayerLoad( )
	self:registerNodeEvent()
	if self.onLayerLoad ~= nil then 
       self:onLayerLoad()
    end
end

function CCBNormalLayerBase:_onAnimationCallback( selector )
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

function CCBNormalLayerBase:onLayerLoad( )
end

function CCBNormalLayerBase:onLayerEnter( )
end

function CCBNormalLayerBase:onLayerExit( )
end

function CCBNormalLayerBase:onLayerUnload( )
end

function CCBNormalLayerBase:onAnimateFinish( name )
end

function CCBNormalLayerBase:onAnimationCallback( selector )
end

-- touch event callback
function CCBNormalLayerBase:registerTouchEvent( isMultiTouches, priority, swallowsTouches )
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

    self:unregisterTouchEvent()
    self:registerScriptTouchHandler(handler, isMultiTouches, priority, swallowsTouches)
end

function CCBNormalLayerBase:unregisterTouchEvent(  )
    self:unregisterScriptTouchHandler()
end

function CCBNormalLayerBase:_onTouchBegin( xpos, ypos )
    local ret = self:onTouchBegin(xpos, ypos)
    if type(ret) ~= "boolean" then 
        ret = false
    end

    return ret
end

function CCBNormalLayerBase:onTouchBegin( xpos, ypos )
    return false
end

function CCBNormalLayerBase:onTouchMove( xpos, ypos )
end

function CCBNormalLayerBase:onTouchCancel( xpos, ypos )
end

function CCBNormalLayerBase:onTouchEnd( xpos, ypos )
end

function CCBNormalLayerBase:onTouchesBegin( touches )
end

function CCBNormalLayerBase:onTouchesMove( touches )
end

function CCBNormalLayerBase:onTouchesEnd( touches )
end

function CCBNormalLayerBase:onTouchesCancel( touches )
end

function CCBNormalLayerBase:registerMenuHandler( menuName, fun, target )
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
		__Log(string.format("[CCBNormalLayerBase]register menu handler {%s} failed", menuName))
        return false
	end
end

function CCBNormalLayerBase:registerAnimationCallback( selector, fun, target )
    if type(selector) ~= "string" or type(fun) ~= "function" then 
        return nil
    end

    self._animationCB[selector] = {fun, target}
end

function CCBNormalLayerBase:assignChildPriority( child, zorder, tag )
    return self:assignChildPriorityForParent(self, child, zorder, tag)
end

function CCBNormalLayerBase:assignChildPriorityForParent( parent, child, zorder, tag )
    if child == nil or parent == nil then
        return false
    end
    self:assginChildTouchPriority(parent, child)
    return true
end

function CCBNormalLayerBase:onLayerEvent( event, sender, ... )
    
end

function CCBNormalLayerBase:sendSceneEvent( event, sender, ... )
    if self._parentScene == nil then
        return false
    end

    if self._parentScene.onSceneEvent ~= nil then 
        return self._parentScene.onSceneEvent(self._parentScene, event, sender, ...)
    end

    return false
end

function CCBNormalLayerBase:sendLayerEvent( layerName, event, sender, ... )
    if layerName == nil or self._parentScene == nil then
        return false
    end
    
    if layerName == self._layerName then 
        return self.onLayerEvent(event, sender, ...)
    end

    return self._parentScene:sendLayerEvent(layerName, event, sender, ...)
end

function CCBNormalLayerBase:close( )
    self:removeFromParentAndCleanup(true)
end

function CCBNormalLayerBase:delayToClose( time )
    if type(time) ~= "number" or time <= 0 then
        return false
    end

    g_funcCallHelper:callAfterDelayTime(time, nil, function (  )
        self:close()
    end)
end

return CCBNormalLayerBase

