-------------------------------------------------------
module(..., package.seeall)

local require = require

require("ui/ui_funcs")
local ui = require("ui/base")

-------------------------------------------------------
wnd_equip_temper_skill_des = i3k_class("wnd_equip_temper_skill_des",ui.wnd_base)

function wnd_equip_temper_skill_des:refresh(info)
	local cfg =  i3k_db_equip_temper_skill[info.skillID][info.skillLvl]
	local widgets = self._layout.vars
	widgets.name:setText(cfg.name)
	widgets.des:setText(cfg.des)
	widgets.icon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.icon))
	widgets.okBtn:onClick(self, self.onCloseUI)
	widgets.close_btn:onClick(self, self.onCloseUI)
end
---------------------------------------------------------
function wnd_create(layout)
	local wnd = wnd_equip_temper_skill_des.new()
	wnd:create(layout)
	return wnd
end