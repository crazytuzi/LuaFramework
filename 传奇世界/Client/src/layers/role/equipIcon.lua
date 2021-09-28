return { new = function(params)
-----------------------------------------------------------------------
local Mnode = require "src/young/node"
local MpropOp = require "src/config/propOp"
local MequipOp = require "src/config/equipOp"
local MColor = require "src/config/FontColor"
-----------------------------------------------------------------------
local res = "res/rolebag/role/"
-----------------------------------------------------------------------
local root = cc.Sprite:create(params.bg or res .. "32.png")
local M = Mnode.beginNode(root)
-----------------------------------------------------------------------
local starLevel = params.starLevel
local qualityLevel = params.qualityLevel
-----------------------------------------------------------------------
-- 设置物品原型id
protoId = function(self, protoId)
	if not protoId then return self.mProtoId end
	
	local icon = self:getChildByTag(1)
	if not icon then
		self.mProtoId = protoId
		local size = self:getContentSize()
		Mnode.createSprite({
			src = MpropOp.icon(protoId),
			parent = self,
			pos = cc.p(size.width/2, size.height/2),
		})
	elseif protoId ~= self.mProtoId then
		self.mProtoId = protoId
		icon:setTexture( MpropOp.icon(protoId) )
	end
end; root:protoId(params.protoId)

-- 设置星级
setStarLevel = function(self, starLevel)
	local star = self:getChildByTag(2)
	if star then
		if starLevel == self.mStarLevel then return end
		removeFromParent(star)
	end
	
	local nodes = {}
	for i = 1, starLevel do
		nodes[i] = cc.Sprite:create(res .. "13.png")
	end
	
	local size = self:getContentSize()
	Mnode.addChild({
		parent = self,
		child = Mnode.combineNode({
			nodes = nodes,
			margins = -15,
		}),
		pos = cc.p(size.width/2, 0),
	})
	
end; if starLevel then root:setStarLevel(starLevel) end

-- 设置名字
setQuality = function(self, level)
	local name = self:getChildByTag(3)
	if not name then
		name = Mnode.createLabel(
		{
			src = "xxxx",
			size = 20,
		})
		
		Mnode.overlayNode(
		{
			parent = self,
			{
				node = name,
				origin = "bo",
				offset = { y = -10, },
			}
		})
	end
	
	if level == self.mQualityLevel then return end
	self.mQualityLevel = level
	
	local info = MequipOp.qualityInfo(level)
	name:setColor(info.color)
	name:setString( MpropOp.name( self:protoId() ) .. info.level)
end; if qualityLevel then root:setQuality(qualityLevel) end
-----------------------------------------------------------------------
return root
end }