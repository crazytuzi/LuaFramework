
local UIBase = require "ui/common/UIBase"

local UIScrollView=class("UIScrollView", UIBase)

function UIScrollView:ctor(ccNode, propConfig)
    UIScrollView.super.ctor(self, ccNode, propConfig)
	self.child = {}
	--self:AddScriptCallback("exit", function ()
		--self:removeAllChildren(false)
	--end)
	self.ccNode_:setClippingType(1)
end

--TODO lannan

function UIScrollView:getInnerContainer()
	return self.ccNode_:getInnerContainer()
end

function UIScrollView:setDirection(direct)
	self.ccNode_:setDirection(direct)
end

function UIScrollView:getDirection()
	return self.ccNode_:getDirection()
end

function UIScrollView:setContainerSize(width, height)
	local contentSize = self:getContentSize()
	if height then
		if width<contentSize.width then
			width = contentSize.width
		end
		if height<contentSize.height then
			height = contentSize.height
		end
		self.ccNode_:setInnerContainerSize(cc.size(width, height))
	elseif width.width then
		self.ccNode_:setInnerContainerSize(width)
	end
end

function UIScrollView:getContainerSize()
	return self.ccNode_:getInnerContainerSize()
end

function UIScrollView:addItem(node, cantDrag)
	--self:setDirection(3)
	local contentSize = self:getContentSize()
	local var = node.rootVar
	local nodeSize = var:getContentSize()
	if nodeSize.width>contentSize.width and nodeSize.height>contentSize.height then
		self:setDirection(3)
	elseif nodeSize.width>contentSize.width then
		self:setDirection(2)
	elseif nodeSize.height>contentSize.height then
		self:setDirection(1)
	end
	if cantDrag then
		self:setDirection(0)
	end
	
	local containerSize = self:getContainerSize()
	if containerSize.width<nodeSize.width then
		containerSize.width = nodeSize.width
	end
	if containerSize.height<nodeSize.height then
		containerSize.height = nodeSize.height
	end
	self:setContainerSize(containerSize.width, containerSize.height)
	var:setSizeType(ccui.SizeType.percent)
	var:setSizeInScroll(self, nodeSize.width, nodeSize.height)
	var:setPositionInScroll(self, containerSize.width/2, containerSize.height/2)
	self:addChildAndAnis(node)
	table.insert(self.child, node)
end

function UIScrollView:addChild(node, order)
	local node2 = node.root or node
	if order then
		self.ccNode_:addChild(node2, order)
	else
		self.ccNode_:addChild(node2)
	end
	if node.root and node.anis and node.anis.c_dakai then
		node.anis.c_dakai.play()
	end
end

function UIScrollView:removeChild(child)
	self.ccNode_:removeChild(child, true)
end

function UIScrollView:getAllChildren()
	return self.child
end

function UIScrollView:removeAllChildren()
	self.ccNode_:removeAllChildren()
	self.child = {}
	local scrollContentSize = self:getContentSize()
	self:setContainerSize(scrollContentSize.width, scrollContentSize.height)
end

function UIScrollView:stopChildAnis(node)
	if node.anis then
		for _,t in pairs(node.anis) do
			if t.stop then
				t.stop()
			elseif t.quit then
				t.quit()
			end
		end
	end
end

function UIScrollView:addChildAndAnis(node)
	self.ccNode_:addChild(node.root)
	if node.anis and node.anis.c_dakai then
		node.anis.c_dakai.play()
	end
end


return UIScrollView