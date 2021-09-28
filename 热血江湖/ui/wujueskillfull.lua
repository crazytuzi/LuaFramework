-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
wnd_wujueSkillFull = i3k_class("wnd_wujueSkillFull", ui.wnd_base)

-- 武诀技能圆满
-- [eUIID_WujueSkillFull]	= {name = "wujueSkillFull", layout = "wujuejnm", order = eUIO_TOP_MOST,},
-------------------------------------------------------

function wnd_wujueSkillFull:ctor()

end

function wnd_wujueSkillFull:configure()
	local widgets = self._layout.vars
	widgets.Close:onClick(self, self.onCloseUI)
end

function wnd_wujueSkillFull:refresh(skillID)
	local widgets = self._layout.vars
	local skillLvl = g_i3k_game_context:getWujueSkillLevel(skillID)
	local skillCfg = i3k_db_wujue_skill[skillID][skillLvl]
	widgets.cover:setImage(g_i3k_db.i3k_db_get_icon_path(skillCfg.coverImg))
	widgets.name:setText(skillCfg.name)
	widgets.icon:setImage(g_i3k_db.i3k_db_get_icon_path(skillCfg.icon))
	widgets.level:setText(string.format("%s/%s", skillLvl, #i3k_db_wujue_skill[skillID]))
	widgets.nextEffect:setText(skillCfg.effectDesc)
end

function wnd_create(layout, ...)
	local wnd = wnd_wujueSkillFull.new()
	wnd:create(layout, ...)
	return wnd;
end
