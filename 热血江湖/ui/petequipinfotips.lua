-------------------------------------------------------
module(..., package.seeall)
local require = require
local ui = require("ui/base")
-------------------------------------------------------
wnd_petEquipInfoTips = i3k_class("wnd_petEquipInfoTips", ui.wnd_base)

local LAYER_ZBTIPST = "ui/widgets/zbtipst"    --属性
local LAYER_ZBTIPST3 = "ui/widgets/zbtipst3"  --标题
local LAYER_ZBTIPST5 = "ui/widgets/zbtipst5"  --试炼技能

local compare_icon = {
	174,
	175,
	176,
}

function wnd_petEquipInfoTips:ctor()
	self.isEquip = false
	self.isOut = false
	self.isBag = false

	self.id = nil
	self.group = nil

	self.isFight = false

	self.leftPower = 0
end

function wnd_petEquipInfoTips:configure()
	local widgets = self._layout.vars
	widgets.globel_bt:onClick(self, self.onCloseUI)

	--装备或更换
	widgets.btn2:onClick(self, self.onWear)
end

function wnd_petEquipInfoTips:refresh(data)
	local widgets = self._layout.vars
	self.isEquip = data.isEquip  --是否装备部位上点击
	self.isOut = data.isOut 	 --是否外部点击
	self.isBag = data.isBag

	self.id = data.id
	self.group = data.group

	self.isFight = data.isFight  --是否试炼副本点击

	self.selectGroup = data.selectGroup

	self.isRankList = data.isRankList --是否排行榜点击
	self.upLvl = data.upLvl

	local wEquip = g_i3k_game_context:GetPetEquipsData(data.group)
	local upLvls = g_i3k_game_context:GetPetEquipsLvlData(data.group)

	local equipCfg = g_i3k_db.i3k_db_get_pet_equip_item_cfg(data.id)

	if data.isRankList then
		--所查看的宠物所在分组内，自己的分组中，同部位上也有装备
		local equipID = wEquip[equipCfg.part]
		if equipID then
			widgets.layer2:show()
			self:setRankListMyTips({id = data.id, upLvl = data.upLvl, group = data.group, isShowUpLvl = true})
			self:setRankListOtherTips({id = equipID, upLvl = upLvls[equipCfg.part] or 0, group = equipCfg.petGroupLimit})
		else
			self:setRankListOtherTips({id = data.id, upLvl = data.upLvl, group = data.group})
			widgets.layer2:hide()
		end
	else
		if data.group == data.selectGroup and wEquip[equipCfg.part] and data.isBag then
			widgets.layer2:show()
			self:setEquipTips({id = wEquip[equipCfg.part], group = data.group})
		else
			widgets.layer2:hide()
		end

		self:setBagTips(data)
	end

	self:updateBtnState(data)
	self:updateBtnEvent(data)
end

function wnd_petEquipInfoTips:updateBtnState(data)
	local widgets = self._layout.vars
	if data.isOut then
		widgets.btn1:hide()
		widgets.btn2:hide()
	else
		widgets.btn1:show()
		widgets.btn2:setVisible(not data.isEquip)
	end
	if (not data.isOut) and (not data.isEquip) and data.isFight then
		widgets.btn1:hide()
	end
end

function wnd_petEquipInfoTips:updateBtnEvent(data)
	local widgets = self._layout.vars
	if not data.isOut then
		if data.isEquip then
			widgets.label1:setText(i3k_get_string(1524))
			widgets.btn1:onClick(self, self.onUnwear)
		else
			widgets.label1:setText(i3k_get_string(1525))
			widgets.btn1:onClick(self, self.onSplit)
		end
		local wEquip = g_i3k_game_context:GetPetEquipsData(data.group)
		local equipCfg = g_i3k_db.i3k_db_get_pet_equip_item_cfg(data.id)
		if wEquip[equipCfg.part] then
			widgets.label2:setText(i3k_get_string(1526))
		else
			widgets.label2:setText(i3k_get_string(1527))
		end
	end
end

function wnd_petEquipInfoTips:setRankListMyTips(data)
	local widgets = self._layout.vars

	local id = data.id
	local curLvl = data.upLvl
	local group = data.group

	local equipCfg = g_i3k_db.i3k_db_get_pet_equip_item_cfg(id)
	local partID = equipCfg.part

	local name = g_i3k_db.i3k_db_get_common_item_name(id)
	if curLvl <= 0 then
		widgets.equip_name2:setText(name)
	else
		widgets.equip_name2:setText(name .. "+" .. curLvl)
	end
	widgets.equip_name2:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(id)))
	widgets.equip_bg2:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widgets.equip_icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
	widgets.role2:setText(i3k_db_pet_equips_group[group])
	widgets.part2:setText(i3k_db_pet_equips_part[partID].name)

	local basePower = math.modf(g_i3k_game_context:GetOnePetEquipFightPower(id))
	local addPower = math.modf(g_i3k_game_context:GetOnePetEquipUpLvlFightPower(group, partID, curLvl))
	if addPower == 0 then
		widgets.power_value2:setText(string.format("%s", basePower))
	else
		widgets.power_value2:setText(string.format("%s+%s", basePower, addPower))
	end
	

	widgets.get_label2:setText(equipCfg.get_way)
	widgets.level2:setText(i3k_get_string(1528, equipCfg.needPetLvl))
	widgets.scroll2:removeAllChildren()

	self:setPropScroll(widgets.scroll2, {equipCfg = equipCfg})
end

function wnd_petEquipInfoTips:setRankListOtherTips(data)
	local widgets = self._layout.vars
	local id = data.id
	local group = data.group

	local equipCfg = g_i3k_db.i3k_db_get_pet_equip_item_cfg(id)

	local partID = equipCfg.part
	local curLvl = data.upLvl

	local name = g_i3k_db.i3k_db_get_common_item_name(id)
	widgets.equip_name1:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(id)))
	widgets.equip_bg1:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widgets.equip_icon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
	widgets.role1:setText(i3k_db_pet_equips_group[group])
	widgets.part1:setText(i3k_db_pet_equips_part[partID].name)

	local basePower = math.modf(g_i3k_game_context:GetOnePetEquipFightPower(id))
	if not data.isShowUpLvl then
		local addPower = math.modf(g_i3k_game_context:GetOnePetEquipUpLvlFightPower(group, partID, curLvl, id))
		if curLvl <= 0 then
			widgets.equip_name1:setText(name)
		else
			widgets.equip_name1:setText(name .. "+" .. curLvl)
		end	
		if addPower == 0 then
			widgets.power_value1:setText(basePower)
		else
			widgets.power_value1:setText(string.format("%s+%s", basePower, addPower))
		end
	else
		widgets.equip_name1:setText(name)
		widgets.power_value1:setText(basePower)
	end
	widgets.mark_icon:hide()

	widgets.get_label1:setText(equipCfg.get_way)
	widgets.level1:setText(i3k_get_string(1528, equipCfg.needPetLvl))
	widgets.scroll:removeAllChildren()

	self:setPropScroll(widgets.scroll, {equipCfg = equipCfg})
end

--已装备
function wnd_petEquipInfoTips:setEquipTips(data)
	local widgets = self._layout.vars
	local id = data.id
	local group = data.group

	local upLvls = g_i3k_game_context:GetPetEquipsLvlData(group)
	local equipCfg = g_i3k_db.i3k_db_get_pet_equip_item_cfg(id)

	local partID = equipCfg.part
	local curLvl = upLvls[partID] or 0

	local name = g_i3k_db.i3k_db_get_common_item_name(id)
	if curLvl <= 0 then
		widgets.equip_name2:setText(name)
	else
		widgets.equip_name2:setText(name .. "+" .. curLvl)
	end
	widgets.equip_name2:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(id)))
	widgets.equip_bg2:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widgets.equip_icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
	widgets.role2:setText(i3k_db_pet_equips_group[group])
	if not data.isOut then
		widgets.role2:setTextColor(g_i3k_get_cond_color(true))
	end
	widgets.part2:setText(i3k_db_pet_equips_part[partID].name)

	local basePower = math.modf(g_i3k_game_context:GetOnePetEquipFightPower(id))
	local addPower = math.modf(g_i3k_game_context:GetOnePetEquipUpLvlFightPower(group, partID, curLvl))
	if addPower == 0 then
		widgets.power_value2:setText(basePower)
	else
		widgets.power_value2:setText(string.format("%s+%s", basePower, addPower))
	end

	self.leftPower = basePower

	widgets.get_label2:setText(equipCfg.get_way)
	widgets.level2:setText(i3k_get_string(1528, equipCfg.needPetLvl))
	if not data.isOut then
		local curGroup = g_i3k_game_context:GetPetEquipGroup()
		local maxLvl = g_i3k_db.i3k_db_get_pet_max_level_in_group(curGroup)
		widgets.level2:setTextColor(g_i3k_get_cond_color(maxLvl >= equipCfg.needPetLvl))
	end
	widgets.scroll2:removeAllChildren()

	self:setPropScroll(widgets.scroll2, {equipCfg = equipCfg})
end

function wnd_petEquipInfoTips:setBagTips(data)
	local widgets = self._layout.vars
	local id = data.id
	local group = data.group

	local upLvls = g_i3k_game_context:GetPetEquipsLvlData(group)
	local equipCfg = g_i3k_db.i3k_db_get_pet_equip_item_cfg(id)
	
	local partID = equipCfg.part
	local curLvl = upLvls[partID] or 0

	local name = g_i3k_db.i3k_db_get_common_item_name(id)
	widgets.equip_name1:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(id)))
	widgets.equip_bg1:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widgets.equip_icon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
	widgets.role1:setText(i3k_db_pet_equips_group[group])
	if self.selectGroup then
		widgets.role1:setTextColor(g_i3k_get_cond_color(self.selectGroup == group or group == 0))
	end
	widgets.part1:setText(i3k_db_pet_equips_part[partID].name)

	local basePower = math.modf(g_i3k_game_context:GetOnePetEquipFightPower(id))
	if self.isEquip then
		local addPower = math.modf(g_i3k_game_context:GetOnePetEquipUpLvlFightPower(group, partID, curLvl))
		if curLvl <= 0 then
			widgets.equip_name1:setText(name)
		else
			widgets.equip_name1:setText(name .. "+" .. curLvl)
		end	
		if addPower == 0 then
			widgets.power_value1:setText(basePower)
		else
			widgets.power_value1:setText(string.format("%s+%s", basePower, addPower))
		end
	else
		widgets.equip_name1:setText(name)
		widgets.power_value1:setText(basePower)
	end

	if self.leftPower > 0 then
		if self.leftPower > basePower then
			widgets.mark_icon:setImage(i3k_db_icons[compare_icon[2]].path)
		elseif self.leftPower < basePower then
			widgets.mark_icon:setImage(i3k_db_icons[compare_icon[1]].path)
		else
			widgets.mark_icon:setImage(i3k_db_icons[compare_icon[3]].path)
		end
	else
		widgets.mark_icon:hide()
	end

	widgets.get_label1:setText(equipCfg.get_way)
	widgets.level1:setText(i3k_get_string(1528, equipCfg.needPetLvl))
	if not data.isOut then
		local curGroup = g_i3k_game_context:GetPetEquipGroup()
		local maxLvl = g_i3k_db.i3k_db_get_pet_max_level_in_group(curGroup)
		widgets.level1:setTextColor(g_i3k_get_cond_color(maxLvl >= equipCfg.needPetLvl))
	end
	widgets.scroll:removeAllChildren()

	self:setPropScroll(widgets.scroll, {equipCfg = equipCfg})
end

function wnd_petEquipInfoTips:setPropScroll(scroll, data)
	self:setBasePropScroll(scroll, data)
	self:setAdditionalPropScroll(scroll, data)
	self:setSkillLvlScroll(scroll, data)
end

function wnd_petEquipInfoTips:setBasePropScroll(scroll, data)
	local equipCfg = data.equipCfg
	if next(equipCfg.baseProp) then
		local header = require(LAYER_ZBTIPST3)()
		header.vars.desc:setText(i3k_get_string(1529))
		scroll:addItem(header)

		for _, v in ipairs(equipCfg.baseProp) do
			if v.propID ~= 0 then
				local ui = require(LAYER_ZBTIPST)()
				local _t = i3k_db_prop_id[v.propID]
				ui.vars.desc:setText(_t.desc)
				ui.vars.value:setText(i3k_get_prop_show(v.propID, v.propValue))
				scroll:addItem(ui)
			end
		end
	end
end

function wnd_petEquipInfoTips:setAdditionalPropScroll(scroll, data)
	local equipCfg = data.equipCfg
	if next(equipCfg.additionalProp) then
		local header = require(LAYER_ZBTIPST3)()
		header.vars.desc:setText(i3k_get_string(1530))
		scroll:addItem(header)

		for _, v in ipairs(equipCfg.additionalProp) do
			if v.propID ~= 0 then
				local ui = require(LAYER_ZBTIPST)()
				local _t = i3k_db_prop_id[v.propID]
				ui.vars.desc:setText(_t.desc)
				ui.vars.value:setText(i3k_get_prop_show(v.propID, v.propValue))
				scroll:addItem(ui)
			end
		end
	end
end

function wnd_petEquipInfoTips:setSkillLvlScroll(scroll, data)
	local equipCfg = data.equipCfg
	local isHaveSkill = g_i3k_db.i3k_db_get_pet_equip_is_have_skill(equipCfg)
	if not isHaveSkill then
		return
	end
	if next(equipCfg.skills) then
		local header = require(LAYER_ZBTIPST3)()
		header.vars.desc:setText(i3k_get_string(1531))
		scroll:addItem(header)

		for _, v in ipairs(equipCfg.skills) do
			if v.skillID ~= 0 and v.skillLvl ~= 0 then
				local ui = require(LAYER_ZBTIPST5)()
				ui.vars.daw:setText(i3k_db_pet_skill[v.skillID].name)
				ui.vars.count:setText("+" .. v.skillLvl)
				scroll:addItem(ui)
			end
		end
	end
end

--装备/更换
function wnd_petEquipInfoTips:onWear(sender)
	local equips = {}
	local equipCfg = g_i3k_db.i3k_db_get_pet_equip_item_cfg(self.id)
	local partID = equipCfg.part
	equips[partID] = self.id

	local curGroup = g_i3k_game_context:GetPetEquipGroup()
	if curGroup ~= self.group then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1532, i3k_db_pet_equips_group[self.group]))
	end

	local groupMaxLvl = g_i3k_db.i3k_db_get_pet_max_level_in_group(curGroup)
	if groupMaxLvl < equipCfg.needPetLvl then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1533))
	end

	if self.id < 0 then
		local desc = i3k_get_string(1534)
		local fun = (function(ok)
			if ok then
				i3k_sbean.pet_domestication_equip_wear(self.group, equips)
			end
		end)
		g_i3k_ui_mgr:ShowMessageBox2(desc, fun)
	else
		i3k_sbean.pet_domestication_equip_wear(self.group, equips)
	end
end

--分解
function wnd_petEquipInfoTips:onSplit(sender)
	local equipCfg = g_i3k_db.i3k_db_get_pet_equip_item_cfg(self.id)

	local equips = {}
	equips[self.id] = 1

	local getItem = {}
	table.insert(getItem, {id = g_BASE_ITEM_PET_EQUIP_SPIRIT, count = equipCfg.petPower})

	local splitFun = function()
		local itemName = g_i3k_db.i3k_db_get_common_item_name(g_BASE_ITEM_PET_EQUIP_SPIRIT)
		local desc = i3k_get_string(1535, equipCfg.petPower, itemName)
		local fun = (function(ok)
			if ok then
				i3k_sbean.pet_domestication_equip_split(equips, getItem)
			end
		end)
		g_i3k_ui_mgr:ShowMessageBox2(desc, fun)
	end

	local isHaveHighQuality = equipCfg.rank >= g_RANK_VALUE_ORANGE
	if isHaveHighQuality then
		local desc2 = i3k_get_string(1536)
		local fun2 = (function(ok)
			if ok then
				splitFun()
			end
		end)
		g_i3k_ui_mgr:ShowMessageBox2(desc2, fun2)
	else
		splitFun()
	end
end

--卸下
function wnd_petEquipInfoTips:onUnwear(sender)
	local equipCfg = g_i3k_db.i3k_db_get_pet_equip_item_cfg(self.id)
	local partID = equipCfg.part
	i3k_sbean.pet_domestication_equip_unwear(self.group, partID)
end

function wnd_create(layout, ...)
	local wnd = wnd_petEquipInfoTips.new()
	wnd:create(layout, ...)
	return wnd
end
