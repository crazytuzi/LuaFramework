module(..., package.seeall)

local require = require;
local ui = require("ui/base")

-------------------------------------------------------
wnd_qilingSkillDesc = i3k_class("wnd_qilingSkillDesc", ui.wnd_base)

function wnd_qilingSkillDesc:ctor()
	self.skillLevel = 1
end

function wnd_qilingSkillDesc:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self,self.onCloseUI)
end

function wnd_qilingSkillDesc:refresh(id)
	local data = g_i3k_game_context:getQilingData()
	local skillLevel = data[id].skillLevel
	if 0 == skillLevel then
		self.skillLevel = 1
	else
		self.skillLevel = skillLevel
	end
	self:setUI(id)
end

function wnd_qilingSkillDesc:setUI(id)
	local cfg = i3k_db_qiling_type[id]
	local widgets = self._layout.vars
	local maxRank = cfg.transUpLevel
	widgets.skill_lvl:setText(i3k_get_string(467, self.skillLevel))
	widgets.skill_desc:setText(i3k_db_qiling_skill[id][self.skillLevel].desc)
	if cfg then
		widgets.skill_name:setText(cfg.skillName)
		if self.skillLevel >= i3k_db_qiling_trans[id][maxRank].skillUpLevel then
			widgets.tips:setText(i3k_get_string(1082))
		else
			widgets.tips:setText(i3k_get_string(1083, cfg.name, cfg.needLevel))
		end
	end
end

function wnd_qilingSkillDesc:onCloseUI(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_QilingSkillDesc)
end

function wnd_create(layout, ...)
	local wnd = wnd_qilingSkillDesc.new();
		wnd:create(layout, ...);
	return wnd;
end
