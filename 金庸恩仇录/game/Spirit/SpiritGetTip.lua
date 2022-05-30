local data_item_item = require("data.data_item_item")

local SpiritGetTip = class("SpiritGetTip", function ()
	return display.newNode()
end)

function SpiritGetTip:ctor(info)
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("spirit/spirit_get_tip.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node, 3)
	
	table.sort(info, function(a, b)
		return a.resId > b.resId
	end)
	
	for i = 1, 10 do
		if info[i] then
			local item = data_item_item[info[i].resId]
			self._rootnode[string.format("nameLabel%d", i)]:setString(tostring(item.name))
			self._rootnode[string.format("nameLabel%d", i)]:setColor(NAME_COLOR[item.quality])
		end
	end
	
	local action = transition.sequence({
	CCDelayTime:create(2),
	CCFadeOut:create(0.5),
	CCRemoveSelf:create(true)
	})
	self:runAction(action)
end

return SpiritGetTip