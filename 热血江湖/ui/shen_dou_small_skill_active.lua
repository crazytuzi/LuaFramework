------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/shen_dou_skill')
local BASE = ui.wnd_shen_dou_skill

------------------------------------------------------
wnd_shen_dou_small_skill_active = i3k_class("wnd_shen_dou_small_skill_active", BASE)

function wnd_shen_dou_small_skill_active:setDesc1()
	self:setUpLevelDesc()
end

local strMap = {
	[g_SHEN_DOU_SKILL_MARTIAL_ID] = 1704,--武魂
	[g_SHEN_DOU_SKILL_STAR_ID] = 1705,--星耀
	[g_SHEN_DOU_SKILL_GOD_STAR_ID] = 1706,--神斗
}

function wnd_shen_dou_small_skill_active:setDesc2()
	local widgets = self._layout.vars
	widgets.help:setVisible(self.skillId == g_SHEN_DOU_SKILL_STAR_ID)
	self:setSmallSkillActiveOrMaxDesc(widgets.desc2)
	-- local str = i3k_get_string(strMap[self.skillId], self.cfg.args1 / 100)
	-- if self.skillId == g_SHEN_DOU_SKILL_STAR_ID then
	-- 	local activeStarCount = g_i3k_game_context:GetActiveStarsCount()
	-- 	local addition = i3k_db_martial_soul_cfg.addition[activeStarCount] or 0
	-- 	local ratio = g_i3k_db.i3k_db_get_shen_dou_skill_prop_ratio(g_SHEN_DOU_SKILL_STAR_ID)
	-- 	str = str .. '\n' .. i3k_get_string(1707, (1 + addition) * 100 * (1 + ratio))
	-- end
	-- widgets.desc2:setText(str)
end


function wnd_shen_dou_small_skill_active:onHelpBtn(sender)
	local activeStarCount = g_i3k_game_context:GetActiveStarsCount()
	local addition = i3k_db_martial_soul_cfg.addition[activeStarCount] or 0
	local cfg = i3k_db_matrail_soul_shen_dou_xing_shu[self.skillId][self.lvl] or i3k_db_matrail_soul_shen_dou_xing_shu[self.skillId][1]
	local ratio = cfg.args1 / 10000
	local xingShuName = i3k_db_matrail_soul_shen_dou_xing_shu[g_SHEN_DOU_SKILL_STAR_ID][1].name
	local finalRatio = (1 + ratio) * (1 + addition) * 100
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(1749, addition * 100, xingShuName, ratio * 100, addition * 100, ratio * 100, finalRatio, finalRatio))
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_shen_dou_small_skill_active.new()
	wnd:create(layout,...)
	return wnd
end
