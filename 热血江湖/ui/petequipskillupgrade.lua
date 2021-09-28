
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_petEquipSkillUpGrade = i3k_class("wnd_petEquipSkillUpGrade",ui.wnd_base)

function wnd_petEquipSkillUpGrade:ctor()
	self._petID = nil
	self._skillID = nil
	self._skillNextLvl = nil
	self._cost = {}
end

function wnd_petEquipSkillUpGrade:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)

	widgets.up_btn:onClick(self, self.onUpBtn)
end

function wnd_petEquipSkillUpGrade:refresh(petID, skillID)
	local widgets = self._layout.vars
	local skillData = g_i3k_game_context:GetPetTrainSkillsData(petID)
	local skillLvl = skillData[skillID] or 0

	self._petID = petID
	self._skillID = skillID
	self._skillNextLvl = skillLvl + 1

	self:updateSkillUI(skillID, skillLvl)
	self:updateCostScroll()
end

function wnd_petEquipSkillUpGrade:updateSkillUI(skillID, skillLvl)
	local widgets = self._layout.vars
	local skillCfg = i3k_db_pet_skill[skillID]
	widgets.bg1:setImage(g_i3k_db.i3k_db_get_icon_path(skillCfg.icon))
	widgets.bg2:setImage(g_i3k_db.i3k_db_get_icon_path(skillCfg.icon))

	widgets.des1:setText(i3k_get_string(1540, skillCfg.name, skillLvl))
	widgets.des2:setText(i3k_get_string(1540, skillCfg.name, (skillLvl + 1)))
end

function wnd_petEquipSkillUpGrade:updateCostScroll()
	local widgets = self._layout.vars
	local skillID = self._skillID
	local skillNextLvl = self._skillNextLvl

	local petLvl = g_i3k_game_context:getPetLevel(self._petID)
	local upCfg = g_i3k_db.i3k_db_get_pet_equip_skill_up_cfg(skillID, skillNextLvl)
	widgets.needLvlLabel:setText(i3k_get_string(1541, upCfg.needPetLvl))
	widgets.needLvlLabel:setTextColor(g_i3k_get_cond_color(petLvl >= upCfg.needPetLvl))

	self._cost = upCfg.costItem
	widgets.costScroll:removeAllChildren()
	for _, v in ipairs(upCfg.costItem) do
		local ui = require("ui/widgets/xunyangjnsjt")()
		ui.vars.grade:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
		ui.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, g_i3k_game_context:IsFemaleRole()))

		if math.abs(v.id) == g_BASE_ITEM_DIAMOND or math.abs(v.id) == g_BASE_ITEM_COIN then
			ui.vars.count:setText(v.count)
		else
			ui.vars.count:setText(g_i3k_game_context:GetCommonItemCanUseCount(v.id) .."/".. v.count)
		end
		ui.vars.count:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(v.id) >= v.count))

		ui.vars.suo:setVisible(math.abs(v.id) == g_BASE_ITEM_COIN and v.id > 0)
		ui.vars.bt:onClick(self, self.onItemTips, v.id)
		widgets.costScroll:addItem(ui)
	end
end

function wnd_petEquipSkillUpGrade:onItemTips(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

function wnd_petEquipSkillUpGrade:onUpBtn(sender)
	local upCfg = g_i3k_db.i3k_db_get_pet_equip_skill_up_cfg(self._skillID, self._skillNextLvl)
	local petLvl = g_i3k_game_context:getPetLevel(self._petID)
	if petLvl < upCfg.needPetLvl then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1542))
	end

	for _, v in ipairs(self._cost) do
		if g_i3k_game_context:GetCommonItemCanUseCount(v.id) < v.count then
			return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1543))
		end
	end

	i3k_sbean.pet_domestication_skill_lvlup(self._petID, self._skillID, self._skillNextLvl, self._cost)
end

function wnd_create(layout, ...)
	local wnd = wnd_petEquipSkillUpGrade.new()
	wnd:create(layout, ...)
	return wnd;
end

