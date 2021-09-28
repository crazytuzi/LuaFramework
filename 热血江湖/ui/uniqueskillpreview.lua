-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_uniqueskill_preview = i3k_class("wnd_uniqueskill_preview", ui.wnd_base)

function wnd_uniqueskill_preview:ctor()
	self._itemID = 0
	self._skillID = 0
	self._sortID = 0
end

function wnd_uniqueskill_preview:configure()
	local widgets = self._layout.vars

	self.skillName = widgets.skillName
	self.skillDesc = widgets.skillDesc
	self.heroModule = widgets.hero_module
	widgets.useBtn:onClick(self, self.onUseBtn)
	widgets.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_uniqueskill_preview:refresh(itemID)
	self._itemID = itemID
	local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(itemID)
	local uniqueSkillID = item_cfg.args1
	local skills = i3k_db_exskills[uniqueSkillID].skills
	self._sortID = i3k_db_exskills[uniqueSkillID].sortid
	self._skillID = skills[g_i3k_game_context:GetRoleType()]
	local skillCfg = i3k_db_skills[self._skillID]
	self.skillName:setText(skillCfg.name)
	self.skillDesc:setText(skillCfg.desc)
	ui_set_hero_model(self.heroModule, i3k_game_get_player_hero(), g_i3k_game_context:GetWearEquips(), g_i3k_game_context:GetIsShwoFashion())
	self.heroModule:pushActionList(skillCfg.action, 1)
	self.heroModule:pushActionList("stand",-1)
	self.heroModule:playActionList()
end

function wnd_uniqueskill_preview:onUseBtn(sender)
	i3k_sbean.bag_useitemuskill(self._itemID, self._skillID, self._sortID)
end

function wnd_create(layout)
	local wnd = wnd_uniqueskill_preview.new()
	wnd:create(layout)
	return wnd
end
