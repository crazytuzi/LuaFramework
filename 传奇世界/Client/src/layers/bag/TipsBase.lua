local M = Myoung.beginModule(...)
----------------------------------------------------------------
local MpropOp = require "src/config/propOp"
----------------------------------------------------------------
background = function(self, protoId, equipQuality)
	local bg = cc.Sprite:create("res/group/itemTips/6.png")
	
	local ColorMask = MpropOp.tips(protoId, equipQuality)
	local ColorNode = cc.Sprite:create(ColorMask)
	
	
	Mnode.overlayNode(
	{
		parent = bg,
		{
			node = ColorNode,
		}
	})
	
	bg.ColorNode = ColorNode
	bg.ColorMask = ColorMask
	
	bg.setColorBg = function(self, res)
		if res ~= self.ColorMask then
			self.ColorMask = res
			bg.ColorNode:setTexture(res)
		end
	end
	
	return bg
end

swallowTouchEvent = function(self, tips)
	local Mnode = require "src/young/node"
	return Mnode.swallowTouchEvent(tips)
end

