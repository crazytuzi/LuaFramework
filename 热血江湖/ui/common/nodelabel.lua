
local UIDefault = require "ui/common/DefaultValue"

local UICommon = require "ui/common/UICommon"

local NodeLabel = {}

function ccui.Text:setEnableControl(enable)
	if enable then
		if self._color then
			self:setTextColor(self._color)
		end
		if self._outlineColor then
			self:enableOutline(self._outlineColor)
		end
	else
		--其实这里有个问题，就是disable再enable之后，如果改过颜色，_outlineColor和_color里面的还是旧的
		--但是这俩if是在svn版本25752为了改一个bug加上的，所以，这是个诡异的特性，而不是bug
		if not self._outlineColor then
			self._outlineColor = self:getEffectColor()
		end
		if not self._color then
			self._color = self:getTextColor()
		end
		self:setTextColor(UICommon.getColorC4BByStr(UIDefault.DefLabelRichText.disableColor))
		self:enableOutline(UICommon.getColorC4BByStr(UIDefault.DefLabelRichText.disableOutlineColor))
	end
end

function NodeLabel.createNode(prop)
	local outlineSize = 0
	if prop.fontOutlineEnable then
		outlineSize = prop.fontOutlineSize or UIDefault.DefLabelRichText.fontOutlineSize
	end
	local nodeCreate = ccui.Text:create(prop.text or "", prop.fontName or UIDefault.DefLabelRichText.fontName, prop.fontSize or UIDefault.DefLabelRichText.fontSize, outlineSize)
	nodeCreate:setTextHorizontalAlignment(prop.hTextAlign or UIDefault.DefLabelRichText.hTextAlign)
	nodeCreate:setTextVerticalAlignment(prop.vTextAlign or UIDefault.DefLabelRichText.vTextAlign)
	local color = prop.color or UIDefault.DefLabelRichText.color
	nodeCreate:setTextColor(UICommon.getColorC4BByStr(color))
	local wordSpace = nil
	if prop.fontOutlineEnable then
		nodeCreate:enableOutline(UICommon.getColorC4BByStr(prop.fontOutlineColor or UIDefault.DefLabelRichText.fontOutlineColor), prop.fontOutlineSize or UIDefault.DefLabelRichText.fontOutlineSize)
		wordSpace = prop.wordSpaceAdd or UIDefault.DefLabelRichText.wordSpace
		wordSpace = wordSpace - 2
	else
		wordSpace = prop.wordSpaceAdd or UIDefault.DefLabelRichText.wordSpace
	end
	if prop.fontDellineEnable then
		nodeCreate:enableDelline(true)
	end
	if prop.fontUnderlineEnable then
		nodeCreate:enableUnderline(true)
	end
	if prop.useQuadColor then
		nodeCreate:setQuadColor( prop.quadColorGroup and true or false
			, UICommon.getColorC4BByStr(prop.colorTL or UIDefault.DefLabelRichText.color)
			, UICommon.getColorC4BByStr(prop.colorTR or UIDefault.DefLabelRichText.color)
			, UICommon.getColorC4BByStr(prop.colorBR or UIDefault.DefLabelRichText.color)
			, UICommon.getColorC4BByStr(prop.colorBL or UIDefault.DefLabelRichText.color))
	end
	if prop.lineSpaceAdd and prop.lineSpaceAdd ~= 0 then
		nodeCreate:getVirtualRenderer():setLineHeight(nodeCreate:getVirtualRenderer():getLineHeight() + prop.lineSpaceAdd)
	end
	if wordSpace and wordSpace ~= 0 then
		nodeCreate:getVirtualRenderer():setAdditionalKerning(wordSpace)
	end
	if prop.autoWrap == false then
		nodeCreate:setAutoWrap(false)
	end
	return nodeCreate
end

return NodeLabel
