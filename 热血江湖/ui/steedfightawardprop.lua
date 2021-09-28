-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_steedFightAwardProp = i3k_class("wnd_steedFightAwardProp", ui.wnd_base)

local WIDGET_QZPFJLT = "ui/widgets/qzpfjlt"

function wnd_steedFightAwardProp:ctor()

end

function wnd_steedFightAwardProp:configure( )
	local widgets = self._layout.vars
	self.scroll = widgets.scroll
	widgets.close:onClick(self, self.onCloseUI)
end

function wnd_steedFightAwardProp:refresh()
	self:loadScroll()
end

function wnd_steedFightAwardProp:loadScroll()
	self.scroll:removeAllChildren()
	local index = 1
	local activateCount = g_i3k_game_context:getSteedFightShowCount()
	for i, e in ipairs(i3k_db_steed_fight_award_prop) do
		local node = require(WIDGET_QZPFJLT)()
		local widget = node.vars
		local isActivate = activateCount >= e.needUnlockCount
		if isActivate then
			index = i
		end
		widget.title:setText(i3k_get_string(1253, e.needUnlockCount, activateCount, e.needUnlockCount))
		widget.title:setTextColor(g_i3k_get_cond_color(isActivate))
		widget.isReach:setVisible(isActivate)
		self:updatePropWidget(widget, e.propTb)
		self.scroll:addItem(node)
	end
	if index ~= 1 then
		self.scroll:jumpToChildWithIndex(index)
	end
end

-- 属性
function wnd_steedFightAwardProp:updatePropWidget(widget, propTb)
	for i = 1, 2 do 
		local propIcon = widget["property_icon"..i]
		local propNameTxt = widget["attribute"..i]
		local propValueTxt = widget["value"..i]
		local id = propTb[i].propID
		local value = propTb[i].propValue
		if id ~= 0 then
			propIcon:setImage(g_i3k_db.i3k_db_get_attribute_icon(id))
			propNameTxt:setText(g_i3k_db.i3k_db_get_attribute_name(id))
			propValueTxt:setText(i3k_get_prop_show(id, value))
		end
		propIcon:setVisible(id ~= 0)
		propNameTxt:setVisible(id ~= 0)
		propValueTxt:setVisible(id ~= 0)
	end
end

function wnd_create(layout)
	local wnd = wnd_steedFightAwardProp.new()
	wnd:create(layout)
	return wnd
end
