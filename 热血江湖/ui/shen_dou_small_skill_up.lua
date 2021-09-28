------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/shen_dou_skill')
local BASE = ui.wnd_shen_dou_skill
------------------------------------------------------
wnd_shen_dou_small_skill_up = i3k_class("wnd_shen_dou_small_skill_up", BASE)

local DESC_WIDGET = "ui/widgets/shendoujnsjt"

function wnd_shen_dou_small_skill_up:setDesc1()
	self:setUpLevelDesc()
	self._layout.vars.level:setText(i3k_get_string(1726, self.lvl))
end

local strMap = {
	[g_SHEN_DOU_SKILL_MARTIAL_ID] = 1704,--武魂
	[g_SHEN_DOU_SKILL_STAR_ID] = 1705,--星耀
	[g_SHEN_DOU_SKILL_GOD_STAR_ID] = 1706,--神斗
}

function wnd_shen_dou_small_skill_up:setDesc2()
	local widgets = self._layout.vars
	widgets.scroll:removeAllChildren()
	widgets.help:setVisible(self.skillId == g_SHEN_DOU_SKILL_STAR_ID)
	local ui = require(DESC_WIDGET)()
	ui.vars.part1:setText(i3k_get_string(strMap[self.skillId], self.cfg.args1 / 100))
	ui.vars.part2:setText(self.nextCfg.args1 / 100 .. "%")
	widgets.scroll:addItem(ui)
	if self.skillId == g_SHEN_DOU_SKILL_STAR_ID then
		local activeStarCount = g_i3k_game_context:GetActiveStarsCount()
		local addition = i3k_db_martial_soul_cfg.addition[activeStarCount] or 0
		local curRatio = self.cfg.args1 / 10000
		local ratio = self.nextCfg.args1 / 10000
		local ui = require(DESC_WIDGET)()
		ui.vars.part1:setText(i3k_get_string(1707, (1 + addition) * (1 + curRatio) * 100))
		ui.vars.part2:setText((1 + addition) * (1 + ratio) * 100 .. "%")
		widgets.scroll:addItem(ui)
	end
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_shen_dou_small_skill_up.new()
	wnd:create(layout,...)
	return wnd
end
