-- Filename: STNode.lua
-- Author: bzx
-- Date: 2015-04-24
-- Purpose: 

STNode = class("STNode", function ( ... )
	return CCSprite:create()
end)

function STNode:ctor()
	self._UIType = "st"
	self._classTree = {}
	self._name = ""
	self._nodes = {}
	self._isSwallowTouch = false
	self._touchEnabled = false
	self._nodeSize = CCSizeMake(0, 0)
	self._bg = nil
	self._parent = nil
	self._percentPositionXEnabled = false
	self._percentPositionYEnabled = false
	self._percentPositionX = 0
	self._percentPositionY = 0
	self._scaleX = 1
	self._scaleY = 1
end

function STNode:create()
	local ret = STNode.new()
	ret:setSubnode(CCNode:create())
	local onNodeEvent = function ( event )
		if ret.onNodeEvent ~= nil then
			ret:onNodeEvent(event)
		end
	end
	ret:registerScriptHandler(onNodeEvent)
	return ret
end

function STNode:clone( ... )
	local ret = STNode:createCloneNode()
	ret:copyProperties(self)
	ret:copyNodes(self)
	return ret
end

function STNode:createCloneNode( ... )
	return STNode:create()
end

function STNode:copyProperties(node)
	self:setAnchorPoint(node:getAnchorPoint())
	self:setPosition(node:getPosition())
	self:setPercentPositionXEnabled(node:isPercentPositionXEnabled())
	self:setPercentPositionYEnabled(node:isPercentPositionYEnabled())
	-- self:setSwallowTouch(node:isSwallowTouch())
	-- self:setTouchEnabled(node:isTouchEnabled())
	self:setContentSize(node:getContentSize())
	self:setScaleX(node:getScaleX())
	self:setScaleY(node:getScaleY())
	self:copySpecialProperties(node)
end

function STNode:copySpecialProperties( ... )
end

function STNode:copyNodes( node )
	local nodes = node:getNodes()
	for i = 1, #nodes do
		local node = nodes[i]
		local cloneNode = node:clone()
		self:addChild(cloneNode)
	end
end

function STNode:addChild( node, zOrder, tag )
	zOrder = zOrder or node:getZOrder()
	tag = tag or node:getTag()
	self._subnode:addChild(node, zOrder, tag)
	if node._UIType == "st" then
		table.insert(self._nodes, node)
		node:setParent(self)
		self:updateChildrenPosition()
	end
end

function STNode:getSubNode( ... )
	return self._subnode
end

function STNode:setAnchorPoint(anchorPoint)
	self._subnode:setAnchorPoint(anchorPoint)
end

function STNode:getAnchorPoint( ... )
	return self._subnode:getAnchorPoint()
end

function STNode:setPosition( position )
	self._subnode:setPosition(position)
end

function STNode:getPosition( ... )
	return ccp(self._subnode:getPositionX(), self._subnode:getPositionY())
end

function STNode:setPositionX( positionX )
	self._subnode:setPositionX(positionX)
end

function STNode:getPositionX( ... )
	return self._subnode:getPositionX()
end

function STNode:setPositionY( positionY )
	self._subnode:setPositionY(positionY)
end

function STNode:getPositionY( ... )
	return self._subnode:getPositionY()
end

function STNode:setScale( scale )
	self._scaleX = scale
	self._scaleY = scale
	self._subnode:setScale(scale)
end

function STNode:getScale( ... )
	return self._scaleX
end

function STNode:setScaleX( scaleX )
	self._scaleX = scaleX
	self._subnode:setScaleX(scaleX)
end

function STNode:getScaleX( ... )
	return self._scaleX
end

function STNode:setScaleY( scaleY )
	self._scaleY = scaleY
	self._subnode:setScaleY(scaleY)
end

function STNode:getScaleY( ... )
	return self._scaleY
end

function STNode:getChildren( )
	return self._nodes
end

function STNode:getChildrenByName( name )
	local nodes = {}
	for i = 1, #self._nodes do
		local node = self._nodes[i]
		if node:getName() == name then
			table.insert(nodes, node)
		end
	end
	return nodes
end

function STNode:getChildByName( name )
	for i = 1, #self._nodes do
		local node = self._nodes[i]
		if node.getName ~= nil then
			if node:getName() == name then
				return node
			end
		end
	end
end

function STNode:removeAllChildren()
	self._subnode:removeAllChildrenWithCleanup(true)
	self._nodes = {}
end

function STNode:removeChildByName( name )
	for i = 1, #self._nodes do
		local node = self._nodes[i]
		if node.getName ~= nil then
			if node:getName() == name then
				node:removeFromParent()
				table.remove(self._nodes, i)
				return
			end
		end
	end
end

function STNode:removeChildByTag(tag, cleanup)
	cleanup = cleanup or true
	self._subnode:removeChildByTag(tag, cleanup)
end

function STNode:isAbsoluteVisible()
	if self:isVisible() then
		local parent = self:getParent()
		if parent then
			return STNode.isAbsoluteVisible(parent)
		else
			return true
		end
	else
		return false
	end
end

function STNode:removeChildrenByName( name )
	local indexes = {}
	for i = 1, #self._nodes do
		local node = self._nodes[i]
		if node.getName ~= nil then
			if node:getName() == name then
				node:removeFromParent()
				table.insert(indexes, i)
			end
		end
	end
	for i = 1, #indexes do
		local  index = indexes[i]
		table.remove(self._nodes, index)
	end
end

function STNode:getParent( ... )
	return self._parent
end

function STNode:setParent( parent )
	self._parent = parent
end

function STNode:setContentSize( size )
	self._nodeSize = size
	if self._bg ~= nil then
		self._bg:setContentSize(size)
	end
	self._subnode:setContentSize(size)
	self:updateChildrenPosition()
end

function STNode:getContentSize( ... )
	return self._subnode:getContentSize()
end

function STNode:setWidth( width )
	self._nodeSize.width = width
	self:setContentSize(self._nodeSize)
end

function STNode:setHeight( height )
	self._nodeSize.height = height
	self:setContentSize(self._nodeSize)
	--self:updateChildrenPosition()
end

function STNode:replace(node, isExceptNodes)
	local parent = self:getParent()
	node:copyBaseInfo(self)
	if isExceptNodes then
		for i = 1, #self._nodes do
			local nodeTemp = self._nodes[i]
			self._nodes[i]:retain()
			nodeTemp:removeFromParent()
			node:addChild(nodeTemp)
			nodeTemp:release()
		end
	end
	if parent then
		self:removeFromParent()
		local zOrder = self:getZOrder()
		local tag = self:getTag()
		parent:addChild(node, zOrder, tag)
	end
end

function STNode:copyBaseInfo(node)
	self:setPosition(node:getPosition())
	self:setAnchorPoint(node:getAnchorPoint())
	self:setScaleX(node:getScaleX())
	self:setScaleY(node:getScaleY())
	self:setPercentPositionX(node:getPercentPositionX())
	self:setPercentPositionXEnabled(node:isPercentPositionXEnabled())
	self:setPercentPositionY(node:getPercentPositionY())
	self:setPercentPositionYEnabled(node:isPercentPositionYEnabled())
	self:setTag(node:getTag())
	self:setName(node:getName())
end

function STNode:setName( name )
	self._name = name
end

function STNode:getName()
	return self._name
end

function STNode:removeFromParent( ... )
	if self._parent then
		self._parent:removeChild(self)
	else
		self:removeFromParentAndCleanup(true)
	end
end

function STNode:removeChild(node, cleanup)
	cleanup = cleanup or true
	node:removeFromParentAndCleanup(true)
	for i = 1, #self._nodes do
		local nodeTemp = self._nodes[i]
		if tostring(nodeTemp) == tostring(node) then
			table.remove(self._nodes, i)
			break
		end
	end
end

-- function STNode:setSwallowTouch( isSwallowTouch)
-- 	self._isSwallowTouch = isSwallowTouch
-- 	if isSwallowTouch then
-- 		self:setTouchEnabled(true)
-- 	end
-- end

-- function STNode:isSwallowTouch(  )
-- 	return self._isSwallowTouch
-- end

-- function STNode:setTouchEnabled( touchEnabled )
-- 	self._touchEnabled = touchEnabled
-- 	-- if touchEnabled then
-- 	-- 	print("setTouchEnabled====", self:getTag())
-- 	-- 	STTouchDispatcher:getInstance():addListener(self)
-- 	-- else
-- 	-- 	STTouchDispatcher:getInstance():removeListener(self)
-- 	-- end
-- end

-- function STNode:onNodeEvent( event )
-- 	if event == "enter" then
-- 		self:registerScriptTouchHandler(STTouchDispatcher.onTouchEvent, false, -999999999, true)
-- 		self:setTouchEnabled(true)
-- 	elseif event == "exit" then
-- 		self:unregisterScriptTouchHandler()
-- 	end
-- end

-- function STNode:isNodeTouchEnabled( )
-- 	return self._touchEnabled
-- end

function STNode:getWorldPosition( ... )
	local parent = self:getParent()
	local position = nil
	if parent then
		position = parent:convertToWorldSpace(ccp(self:getPositionX(), self:getPositionY()))
	else
		position = self:getPosition()
	end
	return position
end

function STNode:convertToWorldSpace( point )
	return self._subnode:convertToWorldSpace(point)
end

function STNode:containsWorldPoint(point)
	local nodeSpace = self:convertToNodeSpace(point)
	local rect = CCRectMake(0, 0, self:getContentSize().width, self:getContentSize().height)
	return rect:containsPoint(nodeSpace)
end

function STNode:convertToNodeSpace( point )
	return self._subnode:convertToNodeSpace(point)
end

function STNode:setBgColor(bgColor)
	if self._bg == nil then
		self._bg = STLayerColor:create(ccc4(0, 0, 0, 100))
		self:addChild(self._bg, -1)
		self._bg:setName("bg")
		self._bg:setContentSize(self:getContentSize())
	end
	self._bg:setColor(bgColor)
end

function STNode:setBgOpacity( bgOpacity )
	if self._bg then
		self._bg:setOpacity(bgOpacity)
	end
end

function STNode:setOpacity( opacity )
	if self._subnode.setOpacity ~= nil then
		self._subnode:setOpacity(opacity)
	end
end

function STNode:setColor( color )
	if self._subnode.setColor ~= nil then
		self._subnode:setColor(color)
	end
end

function STNode:setPercentPositionXEnabled( enabled )
	self._percentPositionXEnabled = enabled
	self:updatePosition()
end

function STNode:percentPositionXEnabled(  )
	return self._percentPositionXEnabled
end

function STNode:setPercentPositionX( percentPositionX )
	self._percentPositionX = percentPositionX
	self._percentPositionXEnabled = true
	self:updatePosition()
end

function STNode:getPercentPositionX( )
	return self._percentPositionX
end

function STNode:setPercentPositionYEnabled( enabled )
	self._percentPositionYEnabled = enabled
	self:updatePosition()
end

function STNode:percentPositionYEnabled( )
	return self._percentPositionYEnabled
end

function STNode:setPercentPositionY( percentPositionY )
	self._percentPositionY = percentPositionY
	self._percentPositionYEnabled = true
	self:updatePosition()
end

function STNode:getPercentPositionY( )
	return self._percentPositionY
end

function STNode:setPercentPosition( percentPositionX, percentPositionY )
	self._percentPositionXEnabled = true
	self._percentPositionYEnabled = true
	self._percentPositionX = percentPositionX
	self._percentPositionY = percentPositionY
	self:updatePosition()
end

function STNode:updatePosition( ... )
	if not self._parent then
		return
	end
	local parentSize = self._parent:getContentSize()
	if self:percentPositionXEnabled() then
		self:setPositionX(parentSize.width * self:getPercentPositionX())
	end
	if self:percentPositionYEnabled() then
		self:setPositionY(parentSize.height * self:getPercentPositionY())
	end
end

function STNode:updateChildrenPosition( ... )
	for k, node in pairs(self._nodes) do
		if node.updatePosition ~= nil then
			node:updatePosition()
		end
	end
end

function STNode:setSubnode( subnode )
	local anchorPoint = nil
	local position = nil
	if self._subnode then
		anchorPoint = self:getAnchorPoint()
		position = ccp(self:getPositionX(), self:getPositionY())
 		self._subnode:removeFromParentAndCleanup(true)
	else
		anchorPoint = ccp(0, 0)
		position = ccp(0, 0)
	end
	self._subnode = subnode
	local node = CCSprite:create()
	node.addChild(self, subnode)
	node:release()
	subnode:setAnchorPoint(anchorPoint)
	subnode:setPosition(position)
	subnode:ignoreAnchorPointForPosition(false)
	self:setContentSize(subnode:getContentSize())
end

function STNode:runAction( action )
	self._subnode:runAction(action)
end

function STNode:isClass( className )
	for i = 1, #self._classTree do
		if className == self._classTree[i] then
			return true
		end
	end
	return false
end