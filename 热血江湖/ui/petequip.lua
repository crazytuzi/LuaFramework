
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/petEquipProfile")
-------------------------------------------------------
wnd_petEquip = i3k_class("wnd_petEquip", ui.wnd_petEquipProfile)

local RowitemCount = 5
local PET_EQUIP_PART_OPEN_CONT = #i3k_db_pet_equips_part

function wnd_petEquip:ctor()

end

function wnd_petEquip:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)

	widgets.sale_bat:onClick(self, self.onSaleBat)
	widgets.yjzb_btn:onClick(self, self.onAutoWear)

	widgets.choseGroupBtn:onClick(self, function()
		widgets.choseGroupUI:setVisible(not widgets.choseGroupUI:isVisible())
	end)

	widgets.bag_btn:onClick(self, function()
		--g_i3k_logic:OpenPetEquipUI(eUIID_PetEquip)
	end)

	widgets.upLvl_btn:onClick(self, function()
		g_i3k_logic:OpenPetEquipUpLevelUI(eUIID_PetEquip)
	end)

	widgets.skill_btn:onClick(self, function()
		g_i3k_logic:OpenPetEquipUpSkillLevelUI(eUIID_PetEquip)
	end)

	widgets.guard_btn:onClick(self, function()
		g_i3k_logic:OpenPetGuardUI(eUIID_PetEquip)
	end)
	widgets.markBtn:onClick(self, function()
		widgets.mark:setVisible(not widgets.mark:isVisible())
		self:updateBagScroll()
	end)

	widgets.bag_btn:stateToPressed(true)

	widgets.help_btn:onClick(self, function()
		 g_i3k_ui_mgr:ShowHelp(i3k_get_string(1518))
	end)
	widgets.guard_btn:setVisible(g_i3k_game_context:GetLevel() >= i3k_db_pet_guard_base_cfg.showLvl)

	self:initPetEquipWidget(widgets)

	self.equipPoint = widgets.equipPoint
	self.upLvlPoint = widgets.upLvlPoint
	self.skillPoint = widgets.skillPoint
	self.guardPoint = widgets.guardPoint
	self.petScroll = widgets.petScroll
	self.pet_power = widgets.pet_power
	self.addIcon = widgets.addIcon
	self.powerValue = widgets.powerValue
	self.hero_module = widgets.hero_module
	self.revolve = widgets.revolve
	self.revolve:onTouchEvent(self, self.onRotateBtn) --旋转模型
end

--初始化宠物装备控件
function wnd_petEquip:initPetEquipWidget(widgets)
	for i = 1, g_PET_EQUIP_PART_COUNT do
		local equip_btn = "equip" .. i
		local equip_icon = "equip_icon" .. i
		local grade_icon = "grade_icon" .. i
		local is_select = "is_select" .. i
		local level_label = "qh_level" .. i
		local red_tips = "tips" .. i

		self.pet_equip[i] = {
			equip_btn = widgets[equip_btn],
			equip_icon = widgets[equip_icon],
			grade_icon = widgets[grade_icon],
			is_select = widgets[is_select],
			level_label = widgets[level_label],
			red_tips = widgets[red_tips],
		}
	end
end

function wnd_petEquip:refresh(isFirst, isFight)
	self._isFight = isFight
	if isFight then
		local widgets = self._layout.vars
		widgets.choseGroupBtn:disableWithChildren()
		widgets.upLvl_btn:hide()
		widgets.skill_btn:hide()
		widgets.sale_bat:hide()
		widgets.guard_btn:hide()
	end

	self:setChoseGroupScroll()
	self:updateEquipUI()
	self:updateBagScroll()
	self:updatePetScroll(isFirst, isFight)
	self:updateTabRedPoint()
end

--设置分组下拉框
function wnd_petEquip:setChoseGroupScroll()
	local widgets = self._layout.vars
	widgets.choseGroupScroll:removeAllChildren()

	for i = 1, #i3k_db_pet_equips_group do
		local item = require("ui/widgets/xunyangbgt1")()
		item.vars.groupName:setText(i3k_db_pet_equips_group[i])
		item.vars.groupBtn:onClick(self, function()
			self:chosePetGroup(i)
		end)
		widgets.choseGroupScroll:addItem(item)
	end
end

function wnd_petEquip:chosePetGroup(group)
	local widgets = self._layout.vars
	if self._choosePetGroup == group then
		return
	end

	if not g_i3k_db.i3k_db_get_is_have_one_pet_in_group(group) then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1521))
	end

	self._choosePetGroup = group
	g_i3k_game_context:SetPetEquipGroup(group)

	widgets.choseGroupUI:setVisible(false)
	widgets.groupLabel:setText(i3k_db_pet_equips_group[group])

	self:updateEquipUI()
	self:updateBagScroll()
	self:updatePetScroll(false)
	self:updateTabRedPoint()
end

--刷新左侧装备UI
function wnd_petEquip:updateEquipUI()
	local widgets = self._layout.vars
	local group = self:getChooseGroup()
	widgets.groupLabel:setText(i3k_db_pet_equips_group[group])

	self:updateProfile(group)
	self:updateWearEquipsData(group)
end

function wnd_petEquip:updateWearEquipsData(group)
	local wEquip = g_i3k_game_context:GetPetEquipsData(group)

	for i, v in ipairs(self.pet_equip) do
		if i <= PET_EQUIP_PART_OPEN_CONT then
			local equipID = wEquip[i]
			if equipID then
				v.equip_btn:onClick(self, self.onSelectEquip, {id = equipID, group = group, isEquip = true, selectGroup = group, isFight = self._isFight})
			end
		end
	end
end

--刷新右侧背包UI
function wnd_petEquip:updateBagScroll()
	local widgets = self._layout.vars
	local isMark = widgets.mark:isVisible()
	local group = self:getChooseGroup()

	local equipData = {}
	local equips = g_i3k_game_context:GetAllBagPetEquips()
	if isMark then
		for _, v in ipairs(equips) do
			local equipCfg = g_i3k_db.i3k_db_get_pet_equip_item_cfg(v.id)
			if self:isEquipEnoughGroup(equipCfg) then
				table.insert(equipData, v)
			end
		end
	else
		equipData = equips
	end

	local allBars = widgets.scroll:addChildWithCount("ui/widgets/xunyangbgt2", RowitemCount, #equipData)
	for i, v in ipairs(allBars) do
		local id = equipData[i].id
		local count = equipData[i].count
		local equipCfg = g_i3k_db.i3k_db_get_pet_equip_item_cfg(id)

		v.vars.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
		v.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
		v.vars.item_count:setText(count)
		v.vars.suo:setVisible(id > 0)
		v.vars.bt:onClick(self, self.onSelectEquip, {id = id, group = equipCfg.petGroupLimit, isBag = true, isFight = self._isFight, selectGroup = group})

		local isEnough = self:isEquipEnoughGroup(equipCfg) and self:isEquipEnoughLvl(equipCfg)
		v.vars.is_show:setVisible(not isEnough)

		local wEquip = g_i3k_game_context:GetPetEquipsData(group)
		local equipID = wEquip[equipCfg.part]
		if equipID then
			local power = math.modf(g_i3k_game_context:GetOnePetEquipFightPower(id))
			local wPower = math.modf(g_i3k_game_context:GetOnePetEquipFightPower(equipID))
			v.vars.isUp:show()
			if wPower > power then
				v.vars.isUp:setImage(g_i3k_db.i3k_db_get_icon_path(175))
			elseif wPower < power then
				v.vars.isUp:setImage(g_i3k_db.i3k_db_get_icon_path(174))
			else
				v.vars.isUp:hide()
			end
		else
			v.vars.isUp:show()
			v.vars.isUp:setImage(g_i3k_db.i3k_db_get_icon_path(174))
		end
		if not isEnough then
			v.vars.isUp:hide()
		end
	end
	widgets.noItemTips:setText(i3k_get_string(1522))
	widgets.noItemTips:setVisible(table.nums(equipData) == 0)

	--刷新一键装备红点
	self:updateAutoWearRedPoint()
end

--选择装备
function wnd_petEquip:onSelectEquip(sender, data)
	g_i3k_ui_mgr:OpenUI(eUIID_PetEquipInfoTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_PetEquipInfoTips, data)
end

--满足组别
function wnd_petEquip:isEquipEnoughGroup(equipCfg)
	local group = self:getChooseGroup()
	return (group == equipCfg.petGroupLimit or equipCfg.petGroupLimit == 0)
end

--满足等级
function wnd_petEquip:isEquipEnoughLvl(equipCfg)
	local group = self:getChooseGroup()
	local maxLvl = g_i3k_db.i3k_db_get_pet_max_level_in_group(group)
	return maxLvl >= equipCfg.needPetLvl
end

--批量出售
function wnd_petEquip:onSaleBat(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_PetEquipSaleBat)
	g_i3k_ui_mgr:RefreshUI(eUIID_PetEquipSaleBat)
end

--一键装备
function wnd_petEquip:onAutoWear(sender)
	local group = self:getChooseGroup()
	local bestEquip, equips, replace_count = self:getBestEquipsInfo()

	if replace_count ~= 0 then
		if self:getIsHaveFreeEquip(bestEquip) then
			local fun = (function(ok)
				if ok then
					i3k_sbean.pet_domestication_equip_wear(group, equips)
				end
			end)
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(308, g_i3k_db.i3k_db_get_free_equip_desc(bestEquip)), fun)
		else
			i3k_sbean.pet_domestication_equip_wear(group, equips)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1523))
	end
end

function wnd_petEquip:getBestEquipsInfo()
	local group = self:getChooseGroup()
	local bagEquips = g_i3k_game_context:GetAllBagPetEquips()
	local wEquip = g_i3k_game_context:GetPetEquipsData(group)

	local bestEquip = {}
	local replace_count = 0

	for i, e in ipairs(self.pet_equip) do
		if i <= PET_EQUIP_PART_OPEN_CONT then
			local wPower = 0
			local equipID = wEquip[i]
			if equipID then
				wPower = math.modf(g_i3k_game_context:GetOnePetEquipFightPower(equipID))
			end

			local canWearEquips = {}
			for _, v in ipairs(bagEquips) do
				local equipCfg = g_i3k_db.i3k_db_get_pet_equip_item_cfg(v.id)
				local isEnough = self:isEquipEnoughGroup(equipCfg) and self:isEquipEnoughLvl(equipCfg)
				if isEnough then
					table.insert(canWearEquips, {id = v.id, partID = equipCfg.part})
				end
			end

			table.sort(canWearEquips, function(a, b)
				local powerA = math.modf(g_i3k_game_context:GetOnePetEquipFightPower(a.id))
				local powerB = math.modf(g_i3k_game_context:GetOnePetEquipFightPower(b.id))
				return powerA > powerB
			end)

			local ePower = 0
			local bagEquipID = 0
			for _, v in ipairs(canWearEquips) do
				if v.partID == i then
					bagEquipID = v.id
					ePower = math.modf(g_i3k_game_context:GetOnePetEquipFightPower(v.id))
					break
				end
			end

			if ePower > wPower then
				bestEquip[bagEquipID] = i
				replace_count = replace_count + 1
			end
		end
	end

	local equips = {}
	for k, v in pairs(bestEquip) do
		equips[v] = k
	end

	return bestEquip, equips, replace_count
end

--一键装备时是否有非绑定的装备
function wnd_petEquip:getIsHaveFreeEquip(bestEquip)
	for k, v in pairs(bestEquip) do
		if k < 0 then
			return true
		end
	end
	return false
end

function wnd_petEquip:updateAutoWearRedPoint()
	local widgets = self._layout.vars
	local _, _, replace_count = self:getBestEquipsInfo()
	widgets.autoWearPoint:setVisible(replace_count > 0)
end

function wnd_create(layout, ...)
	local wnd = wnd_petEquip.new()
	wnd:create(layout, ...)
	return wnd;
end

