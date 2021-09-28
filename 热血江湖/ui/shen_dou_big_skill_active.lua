------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/shen_dou_skill')
local BASE = ui.wnd_shen_dou_skill
------------------------------------------------------
wnd_shen_dou_big_skill_active = i3k_class("wnd_shen_dou_big_skill_active",ui.wnd_shen_dou_skill)

function wnd_shen_dou_big_skill_active:refresh(skillId)
	BASE.refresh(self, skillId)
end

function wnd_shen_dou_big_skill_active:setDesc1()
	self:setUpLevelDesc()
end

function wnd_shen_dou_big_skill_active:setDesc2()
	self._layout.vars.desc2:setText(self.nextCfg.desc)
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_shen_dou_big_skill_active.new()
	wnd:create(layout,...)
	return wnd
end