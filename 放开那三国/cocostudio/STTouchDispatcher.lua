-- Filename: STTouchDispatcher.lua
-- Author: bzx
-- Date: 2015-04-24
-- Purpose: 触摸事件调度器

STTouchDispatcher = {}--class("STTouchDispatcher", {})

function STTouchDispatcher:ctor()
	self.new = nil
	self._listeners = {}
	self._layer = nil
	self._isStop = false
end

STTouchDispatcher:ctor()
local instance = nil

function STTouchDispatcher:getInstance()
	if instance == nil then
		instance = self
	end
	return instance
end

function STTouchDispatcher:addListener( listener )
	self._listeners[tostring(listener)] = {node = listener}
end

function STTouchDispatcher:startListen( ... )
	self._isStop = false
	if not self._layer then
		self._layer = CCLayer:create()
		local onNodeEvent = function ( event )
			return self:onNodeEvent(event)
		end
		self._layer:registerScriptHandler(onNodeEvent)
		CCDirector:sharedDirector():getRunningScene():addChild(self._layer, 1, 394215)
	end
end

function STTouchDispatcher:stopListen( ... )
	self._isStop = true
end

function STTouchDispatcher:removeListener( listener )
	self._listeners[tostring(listener)] = nil
end

function STTouchDispatcher:onTouchEvent(event, x, y)
	if self._isStop then
		return
	end
	if event == "began" then
		print("图片地址为：", CCDirector:sharedDirector():getPath(ccp(x, y)))
	end
	-- if event == "began" then
	-- 	for k, listener in pairs(self._listeners) do
	-- 		if tolua.isnull(listener.node) then
	-- 			listener.isHandleTouch = false
	-- 		else
	-- 			listener.isHandleTouch = listener.node:containsWorldPoint(ccp(x, y)) and listener.node:isNodeTouchEnabled()
	-- 		end
	-- 	end
	-- end
	-- local sortListeners = self:sortListeners()
	-- for i = 1, #sortListeners do
	-- 	local node = sortListeners[i]
	-- 	local listenerKey = tostring(node)
	-- 	local listener = self._listeners[listenerKey]
	-- 	if listener and listener.isHandleTouch then
	-- 		if listener.node.onTouchEvent ~= nil then
	-- 			local ret = listener.node:onTouchEvent(event, x, y)
	-- 			if ret == false then
	-- 				listener.isHandleTouch = false
	-- 			end
	-- 		end
	-- 	 	if listener.node:isSwallowTouch() then
	-- 			return true
	-- 		end
	-- 		if tolua.type(node) == "LuaTableView" then
	-- 			break
	-- 		end
	-- 	end

	-- 	local nodeSpace = node:convertToNodeSpace(ccp(x, y))
	-- 	local nodeSize = nil
	-- 	classType = tolua.type(node)
	-- 	nodeTemp = tolua.cast(node, classType)
	-- 	if classType == "CCScrollView" or classType == "LuaTableView" then 
	-- 		nodeSize = nodeTemp:getViewSize()
	-- 	else
	-- 		nodeSize = nodeTemp:getContentSize()
	-- 	end
	-- 	local rect = CCRectMake(0, 0, nodeSize.width, nodeSize.height)
	-- 	if rect:containsPoint(nodeSpace) then
	-- 		local classTypes = {"CCMenuItemImage", "CCMenuItemSprite"}
	-- 		for i = 1, #classTypes do
	-- 			if classType == classTypes[i] then
	-- 				return false
	-- 			end
	-- 		end
	-- 		if nodeTemp.isTouchEnabled ~= nil then
	-- 			if nodeTemp:isTouchEnabled() then
	-- 				return false
	-- 			end
	-- 		end
	-- 	end
	-- end
	return false
end

function STTouchDispatcher:onNodeEvent(event )
	if event == "enter" then
		local onTouchEvent = function ( event, x, y )
			return self:onTouchEvent(event, x, y)
		end
		self._layer:registerScriptTouchHandler(onTouchEvent, false, -999999999, true)
		self._layer:setTouchEnabled(true)
	elseif event == "exit" then
		self._layer:unregisterScriptTouchHandler()
		self._layer = nil
	end
end

function STTouchDispatcher:sortListeners( node, newListeners)
	if not node then
		node = CCDirector:sharedDirector():getRunningScene()
		newListeners = {}
	end 
	local childrenArray = node:getChildren()
	if not childrenArray then
		return
	end
	local children = {}
	local childrenCount = childrenArray:count()
	for i = childrenCount - 1, 0, -1 do
		local child = tolua.cast(childrenArray:objectAtIndex(i), "CCNode")
		-- TODO visible, touchPoint 区域内的
		table.insert(children, child)
		child.sortValue = i + child:getZOrder() * childrenCount
	end
	table.sort(children, STTouchDispatcher.sortListenerComparator)
	for i = 1, #children do
		local child = children[i]
		self:sortListeners(child, newListeners)
		table.insert(newListeners, child)
	end
	return newListeners
end

function STTouchDispatcher.sortListenerComparator(listen1, listen2)
	return listen1.sortValue > listen2.sortValue
end
