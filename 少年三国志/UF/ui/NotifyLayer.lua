--NotifyLayer.lua


local NotifyLayer = class ("NotifyLayer")

function NotifyLayer:ctor(  )
	self._nodeRoot = nil

	self.NodeTag = {
		ModelNode_Tag	= 10,
		PopupNode_Tag 	= 30,
		MoveTip_Tag		= 50,
		Guide_Tag 		= 70,
		LockView_Tag 	= 90,
		SysView_Tag		= 110,
		DebugView_Tag	= 130,
	}
end

function NotifyLayer:init() 
	if self._nodeRoot == nil then
		self._nodeRoot = TopLevelLayer:getInstance():getTopLevelNode()
	end


	return self._nodeRoot ~= nil 
end

function NotifyLayer:getRoot( ... )
	return self._nodeRoot
end

function NotifyLayer:unInit( )
	self._nodeRoot = nil
end

function NotifyLayer:clearAll( func )
	local node = self:getModelNode()
	if node then 
		node:removeAllChildren()
	end

	node = self:getPopupNode()
	if node then 
		node:removeAllChildren()
	end

	node = self:getTipNode()
	if node then 
		node:removeAllChildren()
	end
	
	node = self:getGuideNode()
	if node then 
		node:removeAllChildren()
	end

	node = self:getSysNode()
	if node then 
		node:removeAllChildren()
	end

	if func then 
		func()
	end
end

function NotifyLayer:getModelNode( )
	if self:init() ~= true then
		return nil
	end

	local node = self._nodeRoot:getChildByTag(self.NodeTag.ModelNode_Tag)
	if node ~= nil then
		return node 
	end

	node = CCNode:create()
	self._nodeRoot:addChild(node, self.NodeTag.ModelNode_Tag, self.NodeTag.ModelNode_Tag)
	return node
end

function NotifyLayer:getPopupNode( )
	if self:init() ~= true then
		return nil
	end

	local node = self._nodeRoot:getChildByTag(self.NodeTag.PopupNode_Tag)
	if node ~= nil then
		return node 
	end

	node = CCNode:create()
	self._nodeRoot:addChild(node, self.NodeTag.PopupNode_Tag, self.NodeTag.PopupNode_Tag)
	return node
end

function NotifyLayer:getTipNode( )
	if self:init() ~= true then
		return nil
	end

	local node = self._nodeRoot:getChildByTag(self.NodeTag.MoveTip_Tag)
	if node ~= nil then
		return node 
	end

	node = CCNode:create()
	self._nodeRoot:addChild(node, self.NodeTag.MoveTip_Tag, self.NodeTag.MoveTip_Tag)
	return node
end

function NotifyLayer:getGuideNode( )
	if self:init() ~= true then
		return nil
	end

	local node = self._nodeRoot:getChildByTag(self.NodeTag.Guide_Tag)
	if node ~= nil then
		return node 
	end

	node = CCNode:create()
	self._nodeRoot:addChild(node, self.NodeTag.Guide_Tag, self.NodeTag.Guide_Tag)
	return node
end

function NotifyLayer:getLockNode(  )
	if self:init() ~= true then
		return nil
	end

	local node = self._nodeRoot:getChildByTag(self.NodeTag.LockView_Tag)
	if node ~= nil then
		return node 
	end

	node = CCNode:create()
	self._nodeRoot:addChild(node, self.NodeTag.LockView_Tag, self.NodeTag.LockView_Tag)
	return node
end

function NotifyLayer:getDebugNode(  )
	if self:init() ~= true then
		return nil
	end

	local node = self._nodeRoot:getChildByTag(self.NodeTag.DebugView_Tag)
	if node ~= nil then
		return node 
	end

	node = CCNode:create()
	self._nodeRoot:addChild(node, self.NodeTag.DebugView_Tag, self.NodeTag.DebugView_Tag)
	return node
end

function NotifyLayer:getSysNode() 
	if self:init() ~= true then
		return nil
	end

	local node = self._nodeRoot:getChildByTag(self.NodeTag.SysView_Tag)
	if node ~= nil then
		return node 
	end

	node = CCNode:create()
	self._nodeRoot:addChild(node, self.NodeTag.SysView_Tag, self.NodeTag.SysView_Tag)
	return node
end

function NotifyLayer:addNode( node )
	if self:init() ~= true then
		return nil
	end

	self._nodeRoot:addChild(node, 0, 0)
end


return NotifyLayer
