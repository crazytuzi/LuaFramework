--
-- Author: Bai Yun
-- Date: 2014-07-22 10:40:33
--

--[[
 Eg:
	-- origin Component
	local img = TFImage:create("test.png")
	img:addComponent(TFLuaTransform)
	- when run:
		local comp = img:getComponent(TFLuaTransform)
		comp.position = ccp(100, 100)  -- set position
		local pos = comp:get("position")      -- get position
		other properties: 
			zOrder, scale, rotation, size, opacity
			scaleX, scaleY, rotationX, rotationY, rotationZ
			width, height, parent
	other usage:
		img:addComponent("TFFramework.client.system.components.luacomps.TFLuaTransform")
		local comp = img:getComponent("TFFramework.client.system.components.luacomps.TFLuaTransform")
	and 
		img:addComponent("TFFramework.client.system.components.luacomps.TFLuaTransform")
		local TFLuaTransform = require("TFFramework.client.system.components.luacomps.TFLuaTransform")
		local comp = img:getComponent(TFLuaTransform)

		...

	Implement:
		Transform = class("Transform", TFLuaTransform)
		function Transform:Awake()
			-- do init there
		end
]] 

TFLuaTransform = CLASS("TFLuaTransform", TFLuaComponent)

function TFLuaTransform:set__worldPosition(pos)
	local pat = self.gameObject:getParent()
	if pat then 
		pos = pat:convertToNodeSpace(pos)
		self.gameObject:setPosition(pos)
	end
end

function TFLuaTransform:get__worldPosition()
	return self.gameObject:convertToWorldSpaceAR(ccp(0, 0))
end

function TFLuaTransform:set__position(pos)
	self.gameObject:setPosition(pos)
end

function TFLuaTransform:get__position()
	return self.gameObject:getPosition()
end

function TFLuaTransform:set__positionX(posX)
	self.gameObject:setPositionX(posX)
end

function TFLuaTransform:get__positionX()
	return self.gameObject:getPositionX()
end

function TFLuaTransform:set__positionY(posY)
	self.gameObject:setPositionY(posY)
end

function TFLuaTransform:get__positionY()
	return self.gameObject:getPositionY()
end

function TFLuaTransform:set__positionZ(posZ)
	self.gameObject:setPositionZ(posZ)
end

function TFLuaTransform:get__positionZ()
	return self.gameObject:getPositionZ()
end

function TFLuaTransform:set__scale(scale)
	self.gameObject:setScale(scale)
end

function TFLuaTransform:get__scale()
	return self.gameObject:getScale()
end

function TFLuaTransform:set__scaleX(scaleX)
	self.gameObject:setScaleX(scaleX)
end

function TFLuaTransform:get__scaleX()
	return self.gameObject:getScaleX()
end

function TFLuaTransform:set__scaleY(scaleY)
	self.gameObject:setScaleY(scaleY)
end

function TFLuaTransform:get__scaleY()
	return self.gameObject:getScaleY()
end

function TFLuaTransform:set__skewX(skewX)
	self.gameObject:setSkewX(skewX)
end

function TFLuaTransform:get__skewX()
	return self.gameObject:getSkewX()
end

function TFLuaTransform:set__skewY(skewY)
	self.gameObject:setSkewY(skewY)
end

function TFLuaTransform:get__skewY()
	return self.gameObject:getSkewY()
end

function TFLuaTransform:set__tag(tag)
	self.gameObject:setTag(tag)
end

function TFLuaTransform:get__tag()
	return self.gameObject:getTag()
end

function TFLuaTransform:set__anchorPointX(anchorPointX)
	local y = self.gameObject:getAnchorPoint().y
	self.gameObject:setAnchorPoint(ccp(anchorPointX, y))
end

function TFLuaTransform:get__anchorPointX()
	return self.gameObject:getAnchorPoint().x
end

function TFLuaTransform:set__anchorPointY(anchorPointY)
	local x = self.gameObject:getAnchorPoint().x
	self.gameObject:setAnchorPoint(ccp(x, anchorPointY))
end

function TFLuaTransform:get__anchorPointY()
	return self.gameObject:getAnchorPoint().y
end

function TFLuaTransform:set__anchorPoint(anchorPoint)
	self.gameObject:setAnchorPoint(anchorPoint)
end

function TFLuaTransform:get__anchorPoint()
	return self.gameObject:getAnchorPoint()
end

function TFLuaTransform:set__rotation(rotation)
	self.gameObject:setRotation(rotation)
end

function TFLuaTransform:get__rotation()
	return self.gameObject:getRotation()
end

function TFLuaTransform:set__rotationX(rotationX)
	self.gameObject:setRotationX(rotationX)
end

function TFLuaTransform:get__rotationX()
	return self.gameObject:getRotationX()
end

function TFLuaTransform:set__rotationY(rotationY)
	self.gameObject:setRotationY(rotationY)
end

function TFLuaTransform:get__rotationY()
	return self.gameObject:getRotationY()
end

function TFLuaTransform:set__rotationZ(rotationZ)
	self.gameObject:setRotationZ(rotationZ)
end

function TFLuaTransform:get__rotationZ()
	return self.gameObject:getRotationZ()
end

function TFLuaTransform:set__width(width)
	local height = self.gameObject:getSize().height
	self.gameObject:setSize(ccs(width, height))
end

function TFLuaTransform:get__width()
	return self.gameObject:getSize().width
end

function TFLuaTransform:set__height(height)
	local width = self.gameObject:getSize().width
	self.gameObject:setSize(ccs(width, height))
end

function TFLuaTransform:get__height()
	return self.gameObject:getSize().height
end

function TFLuaTransform:set__size(size)
	self.gameObject:setSize(size)
end

function TFLuaTransform:get__size()
	return self.gameObject:getSize()
end

function TFLuaTransform:set__opacity(opacity)
	self.gameObject:setOpacity(opacity)
end

function TFLuaTransform:get__opacity()
	return self.gameObject:getOpacity()
end

function TFLuaTransform:set__alpha(alpha)
	self.gameObject:setOpacity(alpha * 255)
end

function TFLuaTransform:get__alpha()
	return self.gameObject:getOpacity() / 255
end

function TFLuaTransform:set__zOrder(zOrder)
	self.gameObject:setZOrder(zOrder)
end

function TFLuaTransform:get__zOrder()
	return self.gameObject:getZOrder()
end

function TFLuaTransform:set__parent(parent)
	if parent == nil then return end
	self.gameObject:retain()
	self.gameObject:removeFromParent(false)
	parent:addChild(self.gameObject)
	self.gameObject:release()
end

function TFLuaTransform:get__parent()
	return self.gameObject:getParent()
end

return TFLuaTransform