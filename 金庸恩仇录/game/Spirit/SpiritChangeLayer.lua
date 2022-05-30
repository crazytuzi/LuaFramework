local data_jingyuantype_jingyuantype = require("data.data_jingyuantype_jingyuantype")
local data_item_nature = require("data.data_item_nature")
local data_item_item = require("data.data_item_item")

local SpiritChangeLayer = class("SpiritChangeLayer", function ()
	return require("utility.ShadeLayer").new()
end)

function SpiritChangeLayer:ctor(data)
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("spirit/spirit_desc.ccbi", proxy, rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	rootnode.nameLabel:setString(data_item_item[data.resId].name)
	rootnode.spiritTypeLabel:setString(data_jingyuantype_jingyuantype[data_item_item[data.resId].pos].name)
	rootnode.spiritLevelLabel:setString(tostring(data.level))
	for k, v in ipairs(data.props) do
		local l = string.format("propNameLabel_%d", k)
		rootnode[l]:setString(data_item_nature[v.idx].nature .. "：")
		rootnode[l]:setVisible(true)
		local valueLabel = ui.newTTFLabel({
		text = tostring(v.val),
		size = 28,
		font = FONTS_NAME.font_haibao
		})
		valueLabel:setAnchorPoint(0, 0.5)
		valueLabel:setPosition(rootnode[l]:getContentSize().width, rootnode[l]:getContentSize().height / 2)
		rootnode[l]:addChild(valueLabel)
	end
	
	local function close(sender, eventName)
		self:removeSelf()
	end
	
	rootnode.closeBtn:addHandleOfControlEvent(close, CCControlEventTouchUpInside)
	rootnode.tag_close:addHandleOfControlEvent(close, CCControlEventTouchUpInside)
end

return SpiritChangeLayer