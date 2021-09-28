
local UIBase = require "ui/common/UIBase"

local UIDefault = require "ui/common/DefaultValue"

local UICommon = require "ui/common/UICommon"

local UILabel = class("UILabel", UIBase)

function UILabel:ctor(ccNode, propConfig)
    UILabel.super.ctor(self, ccNode, propConfig)
	self._textColor = propConfig.color or UIDefault.DefLabelRichText.color
	self._outlineColor = UICommon.getColorC4BByStr(propConfig.fontOutlineColor or UIDefault.DefLabelRichText.fontOutlineColor)
	self._outlineSize = propConfig.fontOutlineSize or UIDefault.DefLabelRichText.fontOutlineSize
end

function UILabel:setText(txt)
	self.ccNode_:setString(txt)
	return self
end

function UILabel:getText()
	return self.ccNode_:getString()
end

function UILabel:autoChangeLine()
	local width = self:getContentSize().width
	local height = self:getContentSize().height
	self.ccNode_:ignoreContentAdaptWithSize(true)
	self.ccNode_:setTextAreaSize(cc.size(50, 150))
	--[[local size = self.ccNode_:getVirtualRendererSize()
	i3k_log("size")]]
end

function UILabel:setTextColor(color)
	if type(color)~="table" then
		self.ccNode_:setTextColor(UICommon.getColorC4BByStr(color))
	else
		self.ccNode_:setTextColor(color)
	end
	return self
end

function UILabel:getTextColor()
	return self.ccNode_:getTextColor()
end

function UILabel:setFontSize(size)
	self.ccNode_:setFontSize(size)
end

function UILabel:getFontSize()
	return self.ccNode_:getFontSize()
end

function UILabel:stateToNormal(textColor, outLineColor, outLineSize)--toNormal方法一般不用传参数，除非有特殊需求
	if not textColor then
		if self._textColor then
			self:setTextColor(self._textColor)
		end
	else
		self._textColor = textColor
		self:setTextColor(textColor)
		
		if not outLineColor then
			if self._outlineColor then
				self.ccNode_:enableOutline(self._outlineColor)
			end
		else
			self._outlineColor = UICommon.getColorC4BByStr(outLineColor)
			
			local size = outLineSize or self._outlineSize
			self:enableOutline(outLineColor, size)
		end
	end
end

function UILabel:stateToPressed(textColor, outLineColor, outLineSize)
	if textColor then
		self:setTextColor(textColor)
		if outLineColor then
			if outLineSize then
				self:enableOutline(outLineColor, outLineSize)
			else
				self:enableOutline(outLineColor)
			end
		end
	else
		
	end
end

function UILabel:enableOutline(color, size)
	if color and size then
		self.ccNode_:enableOutline(UICommon.getColorC4BByStr(color), size)
	elseif color and not size then
		self.ccNode_:enableOutline(UICommon.getColorC4BByStr(color), self._outlineSize)
	else
		
	end
end

return UILabel
