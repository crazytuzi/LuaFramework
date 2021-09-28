
local UIDefault = require "ui/common/DefaultValue"

local UICommon = require "ui/common/UICommon"

local NodeRichText = {}

function NodeRichText.createNode(prop)
	local nodeCreate = ccui.RichText:create()
	if prop.verticalMode then
		nodeCreate:setVerticalMode(true)
		if prop.colFromLeft then
			nodeCreate:setColFromLeft(true)
		end
	end
	if prop.autoWrap == false then
		nodeCreate:setAutoWrap(false)
	end
	local wordSpace = nil
	if prop.fontOutlineEnable then
		nodeCreate:enableOutline(UICommon.getColorC4BByStr(prop.fontOutlineColor or UIDefault.DefLabelRichText.fontOutlineColor), prop.fontOutlineSize or UIDefault.DefLabelRichText.fontOutlineSize)
		wordSpace = prop.wordSpace or UIDefault.DefLabelRichText.wordSpace
		wordSpace = wordSpace - 2
	else
		wordSpace = prop.wordSpace or UIDefault.DefLabelRichText.wordSpace
	end
	nodeCreate:setVerticalSpace(prop.lineSpace or UIDefault.DefLabelRichText.lineSpace)
	if wordSpace and wordSpace ~= 0 then
		nodeCreate:setVerticalWordSpace(wordSpace)
	end
	nodeCreate:setTextHorizontalAlignment(prop.hTextAlign or UIDefault.DefLabelRichText.hTextAlign)
	nodeCreate:setTextVerticalAlignment(prop.vTextAlign or UIDefault.DefLabelRichText.vTextAlign)
	return nodeCreate
end

return NodeRichText