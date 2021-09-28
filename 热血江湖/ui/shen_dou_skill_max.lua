------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/shen_dou_skill')
local BASE = ui.wnd_shen_dou_skill
------------------------------------------------------
wnd_shen_dou_skill_max = i3k_class("wnd_shen_dou_skill_max", BASE)

function wnd_shen_dou_skill_max:refresh(skillId)
	local widgets = self._layout.vars
	local cfg = i3k_db_matrail_soul_shen_dou_xing_shu[skillId]
	self.skillId = skillId
	cfg = cfg[#cfg]
	self.cfg = cfg
	widgets.name:setText(cfg.name)
	widgets.icon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.iconID))
	widgets.help:setVisible(skillId == g_SHEN_DOU_SKILL_STAR_ID)
	if next(cfg.needXinShu) then
		self:setSmallSkillActiveOrMaxDesc(widgets.desc)
	else
		widgets.desc:setText(cfg.desc)
	end
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_shen_dou_skill_max.new()
	wnd:create(layout,...)
	return wnd
end