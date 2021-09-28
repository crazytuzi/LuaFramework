
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/petEquipProfile")
-------------------------------------------------------
wnd_petEquipUpSkillLvl = i3k_class("wnd_petEquipUpSkillLvl",ui.wnd_petEquipProfile)

local RowitemCount1 = 2
local RowitemCount2 = 3

local DefaultIndex = 1

function wnd_petEquipUpSkillLvl:ctor()

end

function wnd_petEquipUpSkillLvl:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)

	widgets.bag_btn:onClick(self, function()
		g_i3k_logic:OpenPetEquipUI(eUIID_PetEquipSkillUpLvl)
	end)

	widgets.upLvl_btn:onClick(self, function()
		g_i3k_logic:OpenPetEquipUpLevelUI(eUIID_PetEquipSkillUpLvl)
	end)

	widgets.skill_btn:onClick(self, function()
		--g_i3k_logic:OpenPetEquipUpSkillLevelUI(eUIID_PetEquipSkillUpLvl)
	end)
	widgets.guard_btn:onClick(self, function()
		g_i3k_logic:OpenPetGuardUI(eUIID_PetEquipSkillUpLvl)
	end)

	widgets.skill_btn:stateToPressed(true)

	widgets.help_btn:onClick(self, function()
		 g_i3k_ui_mgr:ShowHelp(i3k_get_string(1520))
	end)

	widgets.guard_btn:setVisible(g_i3k_game_context:GetLevel() >= i3k_db_pet_guard_base_cfg.showLvl)
	self.equipPoint = widgets.equipPoint
	self.upLvlPoint = widgets.upLvlPoint
	self.skillPoint = widgets.skillPoint
	self.guardPoint = widgets.guardPoint
end

function wnd_petEquipUpSkillLvl:refresh()
	self:updatePetScroll()
	self:updateTabRedPoint()
end

function wnd_petEquipUpSkillLvl:updatePetScroll()
	local widgets = self._layout.vars
	widgets.petScroll:removeAllChildren()

	local petCfg = {}

	for _, v in ipairs(i3k_db_mercenaries) do
		if v.isOpen ~= 0 then
			table.insert(petCfg, v)
		end
	end

	table.sort(petCfg, function(a, b)
		local orderA = g_i3k_game_context:getPetLevel(a.id) * 100 + b.id
		local orderB = g_i3k_game_context:getPetLevel(b.id) * 100 + a.id
		return orderA > orderB
	end)

	local allBars = widgets.petScroll:addChildWithCount("ui/widgets/xunyangsljnt1", RowitemCount1, #petCfg)
	for i, v in ipairs(allBars) do
		local cfg = petCfg[i]
		if cfg then
			local id = cfg.id
			local rank = cfg.rank
			local iconID = cfg.icon
			if g_i3k_game_context:getPetWakenUse(id) then
				iconID = i3k_db_mercenariea_waken_property[id].headIcon
			end
			local isHave = g_i3k_game_context:IsHavePet(id)

			v.vars.id = id
			v.vars.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconID, true))
			v.vars.iconBg:setImage(g_i3k_get_icon_frame_path_by_rank(rank))
			v.vars.level:setVisible(isHave)
			v.vars.levelIcon:setVisible(isHave)
			v.vars.level:setText(g_i3k_game_context:getPetLevel(id))
			v.vars.iconBg:SetIsableWithChildren(isHave)
			v.vars.selectBtn:onClick(self, function()
				self:selectPet(i, cfg.id)
			end)
			v.vars.red_point:setVisible(g_i3k_game_context:UpdatePetSkillPetScrollPoint(id))
		end
	end

	self:selectPet(DefaultIndex, petCfg[DefaultIndex].id)
end

function wnd_petEquipUpSkillLvl:setPetSkillPetScrollPoint()
	local widgets = self._layout.vars
	local allBars = widgets.petScroll:getAllChildren()
	for _, v in ipairs(allBars) do
		local petID = v.vars.id
		v.vars.red_point:setVisible(g_i3k_game_context:UpdatePetSkillPetScrollPoint(petID))
	end
end

function wnd_petEquipUpSkillLvl:selectPet(index, petID)
	local widgets = self._layout.vars
	local allChildren = widgets.petScroll:getAllChildren()
	for i, v in ipairs(allChildren) do
		v.vars.selectImg:setVisible(index == i)
	end
	self:updateSkillScroll(petID)
end

function wnd_petEquipUpSkillLvl:updateSkillScroll(petID)
	local widgets = self._layout.vars
	local skillList = i3k_db_mercenaries[petID].skillList
	local skillsData = g_i3k_game_context:GetPetTrainSkillsData(petID)

	local allBars = widgets.skillScroll:addChildWithCount("ui/widgets/xunyangsljnt2", RowitemCount2, #skillList)
	for i, v in ipairs(allBars) do
		local skillID = skillList[i]
		if skillID then
			local skillCfg = i3k_db_pet_skill[skillID]
			v.vars.bg:setImage(g_i3k_db.i3k_db_get_icon_path(skillCfg.icon))
			local totalSkillLvl = g_i3k_game_context:getPetDungeonSkillLevel(skillID, false, false)
			local skillLvl = skillsData[skillID] or 0
			v.vars.des:setText(i3k_get_string(1544, skillCfg.name, skillLvl, totalSkillLvl))
			local maxLvl = g_i3k_db.i3k_db_get_pet_equip_skill_max_lvl(skillID)
			v.vars.max:setVisible(skillLvl >= maxLvl)
			v.vars.selectBtn:onClick(self, function()
				if not g_i3k_game_context:IsHavePet(petID) then
					return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1545))
				end
				
				if skillLvl >= maxLvl then
					return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1546))
				end
				g_i3k_ui_mgr:OpenUI(eUIID_PetEquipSkillUpGrade)
				g_i3k_ui_mgr:RefreshUI(eUIID_PetEquipSkillUpGrade, petID, skillID)
			end)
			v.vars.red_point:setVisible(g_i3k_game_context:UpdatePetSkillUpPoint(skillID, skillLvl, petID))
		end
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_petEquipUpSkillLvl.new()
	wnd:create(layout, ...)
	return wnd;
end

