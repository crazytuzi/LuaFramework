-------------------------------------------------------
module(..., package.seeall)

local require = require

require("ui/ui_funcs")
local ui = require("ui/base")

-------------------------------------------------------
wnd_equip_temper_star_preview = i3k_class("wnd_equip_temper_star_preview",ui.wnd_base)
local T1 = "ui/widgets/zbclt2"

function wnd_equip_temper_star_preview:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
end

function wnd_equip_temper_star_preview:refresh(partID)
	local wEquip = g_i3k_game_context:GetWearEquips()[partID]
	local equip_id = wEquip.equip.equip_id
	local limit = g_i3k_db.i3k_db_get_equip_item_cfg(equip_id).temperPropsStarLimit
	for i, v in ipairs(limit) do
		local layer = require(T1)()
		layer.vars.des:setText(string.format("第%d条属性： %d★ ~ %d★", i, v.min, v.max))
		self._layout.vars.content:addItem(layer)
	end
end
------------------------------------------------------
function wnd_create(layout)
	local wnd = wnd_equip_temper_star_preview.new()
	wnd:create(layout)
	return wnd
end
