module(..., package.seeall)

local require = require;
local ui = require("ui/base")

-------------------------------------------------------
wnd_qilingTips = i3k_class("wnd_qilingTips", ui.wnd_base)

function wnd_qilingTips:ctor()
end

function wnd_qilingTips:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self,self.onCloseUI)
end

function wnd_qilingTips:refresh(qilingID)
	local foreverProp = g_i3k_game_context:getActivePropImpl(qilingID, "foreverAttr")
	local transProp = g_i3k_game_context:getActivePropImpl(qilingID, "transAttr")
	self:setScrollData(foreverProp, transProp)
end

function wnd_qilingTips:onShow()

end

function wnd_qilingTips:setScrollData(foreverProp, transProp)
	local widgets = self._layout.vars
	local scroll = widgets.scroll
	scroll:removeAllChildren()
	local header1 = require("ui/widgets/qilingtipst2")()
	header1.vars.name:setText(i3k_get_string(1099))
	scroll:addItem(header1)

	local prop1 = self:sortProp(foreverProp)
	for i, e in ipairs(prop1) do
		local des = require("ui/widgets/qilingtipst")()
		local _t = i3k_db_prop_id[e]
		local _desc = _t.desc
		local icon = g_i3k_db.i3k_db_get_property_icon(e)
		des.vars.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
		des.vars.propertyName:setText(_desc)
		des.vars.propertyValue:setText(i3k_get_prop_show(e, foreverProp[e]))
		scroll:addItem(des)
	end

	local header2 = require("ui/widgets/qilingtipst2")()
	header2.vars.name:setText(i3k_get_string(1100))
	scroll:addItem(header2)
	local prop2 = self:sortProp(transProp)
	for i, e in ipairs(prop2) do
		local des = require("ui/widgets/qilingtipst")()
		local _t = i3k_db_prop_id[e]
		local _desc = _t.desc
		local icon = g_i3k_db.i3k_db_get_property_icon(e)
		des.vars.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
		des.vars.propertyName:setText(_desc)
		des.vars.propertyValue:setText(i3k_get_prop_show(e, transProp[e]))
		scroll:addItem(des)
	end
end

-- 参数为Key value形式，返回一个排序好的key数组
function wnd_qilingTips:sortProp(prop)
	local temp = {}
	for k, v in pairs(prop) do
		table.insert(temp, k)
	end
	table.sort(temp)
	return temp
end

function wnd_create(layout, ...)
	local wnd = wnd_qilingTips.new();
		wnd:create(layout, ...);
	return wnd;
end
