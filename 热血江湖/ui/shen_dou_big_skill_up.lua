------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/shen_dou_skill')
local BASE = ui.wnd_shen_dou_skill

------------------------------------------------------
wnd_shen_dou_big_skill_up = i3k_class("wnd_shen_dou_big_skill_up", BASE)

function wnd_shen_dou_big_skill_up:refresh(skillId)
	BASE.refresh(self, skillId)
	self._layout.vars.level:setText(i3k_get_string(1726, self.lvl))
end

function wnd_shen_dou_big_skill_up:setDesc1()
	local widgets = self._layout.vars
	widgets.lable1:setText(i3k_get_string(1742, self.lvl))
	widgets.desc1:setText(self.cfg.desc)
end

function wnd_shen_dou_big_skill_up:setDesc2()
	self:setPreviewDesc(self.lvl + 1)
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_shen_dou_big_skill_up.new()
	wnd:create(layout,...)
	return wnd
end