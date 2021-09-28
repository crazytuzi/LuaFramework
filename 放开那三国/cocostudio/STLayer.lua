-- Filename: STLayer.lua
-- Author: bzx
-- Date: 2015-04-25
-- Purpose: 

STLayer = class("STLayer", function ( ... )
	local ret = STNode:create()
	local subnode = CCLayer:create()
	ret:setSubnode(subnode)
	return ret
end)

function STLayer:ctor()
	STNode.ctor(self)
	self._isSwallowTouch = false
	self._touchEnabled = false
	self._touchPriority = 0
end

function STLayer:create( ... )
	return STLayer.new()
end

function STLayer:setSwallowTouch( isSwallowTouch )
	self._isSwallowTouch = isSwallowTouch
end

function STLayer:isSwallowTouch( ... )
	return self._isSwallowTouch
end

function STLayer:setTouchEnabled( touchEnabled )
	if self._touchEnabled == touchEnabled then
		return
	end
	self._touchEnabled = touchEnabled
	if not touchEnabled then
		self:unregisterScriptTouchHandler()
	elseif self:isRunning() then
		self:registerWithTouchDispatcher()
	end
end

function STLayer:registerScriptTouchHandler(handler, isMultiTouches, priority, isSwallowsTouches)
	self:unregisterScriptTouchHandler()
	self._subnode:registerScriptTouchHandler(handler, isMultiTouches, priority, isSwallowsTouches)
	print(self:getName())
	print(handler, isMultiTouches, priority, isSwallowsTouches)
end

function STLayer:setTouchPriority( touchPriority )	
	self._touchPriority = touchPriority
	self._subnode:setTouchPriority(touchPriority)
	self:setTouchEnabled(false)
	self:setTouchEnabled(true)
end

function STLayer:getTouchPriority( ... )
	return self._touchPriority
end

function STLayer:isTouchEnabled( ... )
	return self._touchEnabled
end

function STLayer:onNodeEvent( event )
	if event == "enter" then
		if self._touchEnabled then
			self:registerWithTouchDispatcher()
		end
	elseif event == "exit" then
		if self._touchEnabled then
			self:unregisterScriptTouchHandler()
		end
	end
end

function STLayer:onTouchEvent(event, x, y)
	if type(x) == "table" and x[3] == 0 then
		y = x[2]
		x = x[1]
	end
	if not self:isAbsoluteVisible() then
		return false
	end
	if event == "began" then
		local point = ccp(x, y)
		if self:containsWorldPoint(point) and self:isSwallowTouch() then
			return true
		end
		return false
	end
end

function STLayer:unregisterScriptTouchHandler( )
	self._subnode:unregisterScriptTouchHandler()
end

function STLayer:registerWithTouchDispatcher( ... )
	local onTouchEvent = function ( event, x, y )
		if tolua.isnull(self) then
			return
		end
		return self:onTouchEvent(event, x, y)
	end
	self:registerScriptTouchHandler(onTouchEvent, false, self:getTouchPriority(), self:isSwallowTouch())
	self._subnode:setTouchEnabled(true)
end