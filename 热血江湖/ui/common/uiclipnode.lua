
local UIBase = require "ui/common/UIBase"

local UIClipnode=class("UIClipnode", UIBase)

function UIClipnode:ctor(ccNode, propConfig)
    UIClipnode.super.ctor(self, ccNode, propConfig)
end

function UIClipnode:hasContent()
	return self.ccNode_:hasContent()
end

function UIClipnode:setInverted(inverted)
	self.ccNode_:setInverted(inverted)
end

function UIClipnode:setStencil(stencil)
	--stencil得是一个ccNode（话说要不要是个UIBase呢？然后再取它的ccNode出来）
	self.ccNode_:setStencil(stencil)
end

function UIClipnode:getStencil()
	--拿出来的是个ccNode
	return self.ccNode_:getStencil()
end

function UIClipnode:isInverted()
	return self.ccNode_:isInverted()
end

return UIClipnode
