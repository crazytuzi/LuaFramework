
local UIBase = require "ui/common/UIBase"

local UIImage = class("UIImage", UIBase)

local UIDefault = require "ui/common/DefaultValue"

function UIImage:ctor(ccNode, propConfig)
    UIImage.super.ctor(self, ccNode, propConfig)
	self._image = propConfig.image or UIDefault.DefImage.image
end

function UIImage:setScale9Enabled(able)
	self.ccNode_:setScale9Enabled(able)
end

function UIImage:setImage(img)
	if img then
		self.ccNode_:loadTexture(i3k_checkPList(img))
		self._image = img
	else
		self.ccNode_:loadTexture("")
		self._image = ""
	end
	return self
end

function UIImage:setFlippedX(flippedX)
	self.ccNode_:getVirtualRenderer():setFlippedX(flippedX)
end

function UIImage:getImage()
	return self._image
end

return UIImage