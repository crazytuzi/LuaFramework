------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/base')
------------------------------------------------------
wnd_pet_guard_skill_info = i3k_class("wnd_pet_guard_skill_info",ui.wnd_base)

function wnd_pet_guard_skill_info:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
end

function wnd_pet_guard_skill_info:refresh(id)
	local widgets = self._layout.vars
	local skilllvl = g_i3k_db.i3k_db_get_pet_guard_skill_lvl(id)
	local cfg = i3k_db_pet_guard_skills[id][skilllvl]
	widgets.icon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.iconId))
	widgets.name:setText(cfg.name)
	widgets.desc1:setText(cfg.desc1)
	widgets.desc2:setText(cfg.desc2)
end
-------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_pet_guard_skill_info.new()
	wnd:create(layout,...)
	return wnd
end