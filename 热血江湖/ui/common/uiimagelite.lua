local UIImageLite = {}

local UIDefault = require "ui/common/DefaultValue"

function UIImageLite.new(ccNode, propConfig)
	local imageLite = {}
	setmetatable(imageLite, {__index = UIImageLite})
	imageLite._image = propConfig.image
	imageLite._ccParent = propConfig._ccParent
	imageLite._ccName = propConfig.name
	imageLite._visible = propConfig.visible
	return imageLite
end

function UIImageLite:setScale9Enabled(able)
	
end

function UIImageLite:checkCCNode()
	if self.ccNode_ == nil then
		self.ccNode_ = self._ccParent:getScale9SpriteChild(self._ccName)
		return self.ccNode_ ~= nil
	else
		return true
	end
	return false
end

function UIImageLite:setImage(img)
	if self._image == img then
		return self
	end
--[[	if self:checkCCNode() then
		if img ~= nil then
			local filename, tType = i3k_checkPList(img)
			if tType == 0 then
				self.ccNode_:initWithFile(filename)
			elseif tType == 1 then
				self.ccNode_:initWithSpriteFrameName(filename)
			end
		else
			self.ccNode_:initWithFile("")
		end
	end]]
	self._ccParent:setScale9SpriteChildImage(self._ccName, i3k_checkPList(img))
	self._image = img
	return self
end

function UIImageLite:getImage()
	return self._image
end

function UIImageLite:setVisible(isShow)
	if (self._visible == nil and isShow) or self._visible == isShow then
		return self
	end
	--[[if self:checkCCNode() then
		self.ccNode_:setVisible(isShow)
		self._visible = isShow
	end]]
	self._ccParent:setScale9SpriteChildVisible(self._ccName, isShow)
	self._visible = isShow
	return self
end

function UIImageLite:show()
	self:setVisible(true)
	return self
end

function UIImageLite:hide()
	self:setVisible(false)
	return self
end

function UIImageLite:setOpacity(opacity)
	--self.ccNode_:setOpacity(opacity)
end

function UIImageLite:getOpacity()
	--return self.ccNode_:getOpacity()
	return 100
end

return UIImageLite