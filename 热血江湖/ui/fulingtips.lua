-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_fulingTips = i3k_class("wnd_fulingTips", ui.wnd_base)

function wnd_fulingTips:ctor()

end

function wnd_fulingTips:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)

end

function wnd_fulingTips:refresh()

end

function wnd_fulingTips:onShow()
	local props = g_i3k_game_context:getAllFulingProps()
	self:setUI(props)
end

function wnd_fulingTips:setUI(props)
	local widgets = self._layout.vars
	local power = g_i3k_db.i3k_db_get_battle_power(props)
	widgets.battle_power:setText(power)

	local sortProps = g_i3k_db.i3k_db_sort_props(props)
	local scroll = widgets.scroll
	scroll:removeAllChildren()
	for k, v in ipairs(sortProps) do
		if v.value ~= 0 then
			local ui = require("ui/widgets/lyfltipst")()
			ui.vars.propertyIcon:setImage(g_i3k_db.i3k_db_get_property_icon_path(v.id)) -- 属性图标
			ui.vars.name:setText(i3k_db_prop_id[v.id].desc..":")
			ui.vars.attr:setText(i3k_get_prop_show(v.id, v.value))
			scroll:addItem(ui)
		end
	end
end


function wnd_create(layout, ...)
	local wnd = wnd_fulingTips.new()
	wnd:create(layout, ...)
	return wnd;
end
