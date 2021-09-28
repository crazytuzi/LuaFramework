------------------------------------------------------
module(...,package.seeall)

local require = require

require("ui/ui_funcs")

local ui = require('ui/base')
------------------------------------------------------
wnd_xinjue_tips = i3k_class("wnd_xinjue_tips",ui.wnd_base)

function wnd_xinjue_tips:configure()
	self._layout.vars.close:onClick(self,self.onCloseUI)
end

function wnd_xinjue_tips:refresh(skillId)
	local widgets = self._layout.vars
	local cfg = i3k_db_xinjue_skills[skillId]
	local xinjueGrade = g_i3k_game_context:getXinjueGrade()
	widgets.img:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.icon))
	widgets.name:setText(cfg.name)
	local unlockdes
	if cfg.needLevel <= xinjueGrade then
		unlockdes = i3k_get_string(1437)
	else
		unlockdes = i3k_get_string(1438, i3k_db_xinjue_level[cfg.needLevel].des)
	end
	widgets.unlock_des:setTextColor(g_i3k_get_cond_color(cfg.needLevel <= xinjueGrade))
	widgets.unlock_des:setText(unlockdes)
	widgets.des:setText(cfg.desc)
end
------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_xinjue_tips.new()
	wnd:create(layout,...)
	return wnd
end