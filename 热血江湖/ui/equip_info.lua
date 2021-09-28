-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_equip_info = i3k_class("wnd_equip_info", ui.wnd_base)

local bless_rankImg = {5139, 5140, 5141, 5142, 10856, 10857, 10858, 10859, 10860, 10861}
local LAYER_ZBTIPST = "ui/widgets/zbtipst"
local LAYER_ZBTIPST2 = "ui/widgets/zbtipst2"
local LAYER_ZBTIPST3 = "ui/widgets/zbtipst3"
local LAYER_ZBTIPST6 = "ui/widgets/zbtipst6"

local base_attribute_desc = "基础属性"
local add_attribute_desc = "附加属性"
local diamond_desc = "宝石"
local refine_desc = "精炼属性"
local smelting_desc = "锤炼属性"

--宝石类型对应icon
local dia_icon = {
	169,
	170,
	171,
	172,
}

local compare_icon = {
	174,
	175,
	176,
}


local LegendsTab = {i3k_db_equips_legends_1, i3k_db_equips_legends_2, i3k_db_equips_legends_3}

function wnd_equip_info:ctor()
	self._equip_id = nil
	self._equip_guid = nil
	self._equip_attribute = nil
	self._equip_naijiu = nil
	self._body_equip = nil

	-----装备对比
	self._equip_id1 = nil
	self._equip_guid1 = nil
	self._equip_attribute1 = nil
	self._equip_naijiu1 = nil
	self._equip_refine1 = nil

	self._equip_id2 = nil
	self._equip_guid2 = nil
	self._equip_attribute2 = nil
	self._equip_naijiu2 = nil
	self._equip_refine2 = nil

	self._equip_refine = nil
end

function wnd_equip_info:configure()
	local widgets = self._layout.vars

	self.xiexia_bt = widgets.xiexia_bt
	self.sale = widgets.sale
	self.globel_bt = widgets.globel_bt

	self.xiexia_bt:onClick(self, self.unInstall)
	self.sale:onClick(self, self.saleButton)
	self.globel_bt:onClick(self, self.closeButton)

	self.label1 = widgets.label1
	self.label2 = widgets.label2
	self.get_label1 = widgets.get_label1
	self.get_label2 = widgets.get_label2

	self.scroll1 = widgets.scroll
	self.scroll2 = widgets.scroll2
	self.layer2 = widgets.layer2

	self.naijiu2 = widgets.naijiu2
	self.shuijing2 = widgets.shuijing2
	self.repair_btn = widgets.repair_btn

	self.is_free1 = widgets.is_free1
	self.is_free2 = widgets.is_free2
	self.is_sale1 = widgets.is_sale1
	self.is_sale2 = widgets.is_sale2
	self.label3 = widgets.label3
	self.role1 = widgets.role1
	self.role2 = widgets.role2
	self.mark_icon = widgets.mark_icon
	self.equip_name1 = widgets.equip_name1
	self.equip_name2 = widgets.equip_name2
end

function wnd_equip_info:unInstall(sender)
	if g_i3k_game_context:GetIsSpringWorld() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17285))
		return
	end
	local _equip = g_i3k_db.i3k_db_get_equip_item_cfg(self._equip_id)
	local wearEquips = g_i3k_game_context:GetWearEquips()
	if self._body_equip then
		local _data = wearEquips[_equip.partID].equip
		if _data then
			local old_one = g_i3k_db.i3k_db_get_equip_item_cfg(_data.equip_id)
			local temp = {}
			temp[_data.equip_id] = 1
			if g_i3k_game_context:IsBagEnough(temp) then
				i3k_sbean.equip_downwear(self._equip_guid, _equip.partID)
			else
				g_i3k_ui_mgr:PopupTipMessage("背包已满，无法卸下装备")
				return
			end
		end
		return
	end
	if not g_i3k_db.i3k_db_check_equip_level(self._equip_id) then
		if _equip.roleType ~= 0 and _equip.roleType ~= g_i3k_game_context:GetRoleType() then
			g_i3k_ui_mgr:PopupTipMessage("职业不同，无法装备")
			return
		end

		if _equip.levelReq > g_i3k_game_context:GetLevel() then
			g_i3k_ui_mgr:PopupTipMessage("等级不足，无法装备")
			return
		end
		if _equip.C_require ~= 0 and _equip.C_require >  g_i3k_game_context:GetTransformLvl() then
			g_i3k_ui_mgr:PopupTipMessage("转职等级不足，无法装备")
			return
		end
		if _equip.M_require ~= 0 then
			local roleInfo = g_i3k_game_context:GetRoleInfo()
			local bwtype = roleInfo.curChar._bwtype
			if _equip.M_require ~= bwtype then
				g_i3k_ui_mgr:PopupTipMessage("正邪不同，无法装备")
				return
			end
		end
	end
	local _data = wearEquips[_equip.partID].equip
	if _data and _data.smeltingProps and next(_data.smeltingProps) then
		local callback = function (isOk)
			if isOk then
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_EquipTips, "upWearEquip")
			end
		end
		g_i3k_ui_mgr:ShowCustomMessageBox2(i3k_get_string(1833), i3k_get_string(1834), i3k_get_string(1832), callback)
	else
		self:upWearEquip()
	end
end
function wnd_equip_info:upWearEquip()
	local _equip = g_i3k_db.i3k_db_get_equip_item_cfg(self._equip_id)
	if self._equip_id < 0 then
		local fun = (function(ok)
			if ok then
				i3k_sbean.equip_upwear(self._equip_id, self._equip_guid, _equip.partID)
				g_i3k_ui_mgr:CloseUI(eUIID_EquipTips)
			end
		end)
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(292), fun)
	else
		i3k_sbean.equip_upwear(self._equip_id, self._equip_guid, _equip.partID)
		g_i3k_ui_mgr:CloseUI(eUIID_EquipTips)
	end
end

function wnd_equip_info:saleButton(sender)
	local id = self._equip_id
	local guid = self._equip_guid
	local _equip = g_i3k_db.i3k_db_get_equip_item_cfg(self._equip_id)
	local sell = _equip.sellItem
	if sell == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(895));
	else
		local fun = (function(ok)
			if ok then
				i3k_sbean.bag_sellequip(id, guid)
			end
		end)

		local desc = i3k_get_string(29,sell)
		g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
		g_i3k_ui_mgr:CloseUI(eUIID_EquipTips)
	end
end

function wnd_equip_info:closeButton(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_EquipTips)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bag, "updateWearEquipSelect")
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_RoleLy, "updateWearEquipSelect")
end

function wnd_equip_info:onRepairEquip(sender, legends)
	local tag = sender:getTag()
	local wEquips = g_i3k_game_context:GetWearEquips()
	if not wEquips[tag] then
		return
	end
	local naijiu = wEquips[tag].equip.naijiu
	local MaxVlaue = i3k_db_common.equip.durability.durabilityMax
	--if naijiu == MaxVlaue then
	--	g_i3k_ui_mgr:PopupTipMessage("耐久度已满，无需修理")
	--	return
	--end
	g_i3k_ui_mgr:OpenUI(eUIID_RepairEquipTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_RepairEquipTips, tag, legends)
	g_i3k_ui_mgr:CloseUI(eUIID_EquipTips)
end

function wnd_equip_info:refresh(equip, out, transformId)
	self._equip_id = equip.equip_id
	self._equip_guid = equip.equip_guid
	self._equip_attribute = equip.attribute
	self._equip_naijiu = equip.naijiu
	self._equip_refine = equip.refine
	self._equip_smeltingProps = equip.smeltingProps
	self._equip_hammerSkill = equip.hammerSkill
	self._body_equip = false
	local wearEquips = g_i3k_game_context:GetWearEquips()
	local equip_t = g_i3k_db.i3k_db_get_equip_item_cfg(self._equip_id)
	if not out then
		local _data = wearEquips[equip_t.partID].equip
		if _data then
			self:SetTips(self.scroll2, _data, true)
			self.layer2:show()
		else
			self.layer2:hide()
		end
	else
		self.layer2:hide()
	end
	self:SetBagTips(self.scroll1, equip)

	self.repair_btn:hide()
	self.xiexia_bt:hide()
	self.sale:hide()
	if transformId and transformId > 0 then
		self:tryToTransform(equip, transformId) --祭炼单独处理,transformId为祭炼的种类
	end
end

function wnd_equip_info:updateTwoEquipInfo(equip1, equip2)
	self.layer2:show()
	self.label2:hide()
	self.sale:hide()
	self.xiexia_bt:hide()
	for i=1, 2 do
		local equip = i == 2 and equip1 or equip2
		self["_equip_id" .. i] = equip.equip_id
		self["_equip_guid" .. i] = equip.equip_guid
		self["_equip_attribute" .. i] = equip.attribute
		self["_equip_refine" .. i] = equip.refine
		self["_equip_naijiu" .. i] = equip.naijiu
	end
	for i=1, 2 do
		local equip = i == 2 and equip1 or equip2
		self._equip_id = equip.equip_id
		self._equip_guid = equip.equip_guid
		self._equip_attribute = equip.attribute
		self._equip_naijiu = equip.naijiu
		self._equip_refine = equip.refine
		self:SetBagTips(self["scroll" .. i], i == 2 and equip1 or equip2,  i)
	end
	self._layout.vars.alreadyWearImg:hide()
end

function wnd_equip_info:updateBagEquipInfo(equip, isWarehouse, hideBtn)--右边装备信息
	if equip then
		self._equip_id = equip.equip_id
		self._equip_refine = equip.refine
		self._equip_guid = equip.equip_guid
		self._equip_attribute = equip.attribute
		self._equip_naijiu = equip.naijiu
		self._equip_smeltingProps = equip.smeltingProps
		self._equip_hammerSkill = equip.hammerSkill
		local wearEquips = g_i3k_game_context:GetWearEquips()
		local equip_t = g_i3k_db.i3k_db_get_equip_item_cfg(self._equip_id)
		local _data = wearEquips[equip_t.partID].equip
		if _data then
			self:SetTips(self.scroll2, _data, true)
			self.layer2:show()
			self.label2:setText("更换")
		else
			self.layer2:hide()
			self.label2:setText("穿上")
		end
		self.xiexia_bt:show()
		self:SetBagTips(self.scroll1, equip)
		self.label1:setText("出售")
		if isWarehouse then
			self.layer2:hide()
			self.xiexia_bt:hide()
			self.repair_btn:hide()
			self.sale:hide()
			local str = isWarehouse.around == 1 and "取出仓库" or "存入仓库"
			self.label1:setText(str)
			if isWarehouse.isCanSave then
				self.sale:show()
				self.sale:onClick(self, self.onStrengBtn, isWarehouse)
			end
		else
			self.sale:show()
			self.sale:onClick(self, self.saleButton, isWarehouse)
		end
		if hideBtn then
			self.xiexia_bt:hide()
			self.sale:hide()
			self.repair_btn:hide()
		end
	end
end

function wnd_equip_info:updateWearEquipInfo(equip, isWarehouse)--左边装备信息
	self._equip_id = equip.equip_id
	self._equip_guid = equip.equip_guid
	self._equip_refine = equip.refine
	self._body_equip = true
	self._equip_attribute = nil
	self._equip_naijiu = nil
	self.layer2:hide()
	self:SetTips(self.scroll1, equip, false)
	self.sale:onClick(self, self.onStrengBtn, isWarehouse)--强化
	self.label1:setText("强化")
	self.label2:setText("卸下")
end

function wnd_equip_info:onStrengBtn(sender, isWarehouse)
	if g_i3k_game_context:GetIsGlodCoast() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5582))
		return 
	end
	if isWarehouse then
		local str = isWarehouse.around == 1 and "取出仓库(测试)" or "存入仓库(测试)"
		--g_i3k_ui_mgr:PopupTipMessage(str)
		g_i3k_ui_mgr:CloseUI(eUIID_EquipTips)
		if isWarehouse.around == 1 then
			i3k_sbean.goto_take_out_warehouse(isWarehouse.id, isWarehouse.count, isWarehouse.warehouseType, isWarehouse.guid)
		elseif isWarehouse.around == 2 then
			i3k_sbean.goto_put_in_warehouse(isWarehouse.id, isWarehouse.count, isWarehouse.warehouseType, isWarehouse.guid)
		end
	else
		local strengLvl = i3k_db_common.functionOpen.strengLvl
		if g_i3k_game_context:GetLevel() < strengLvl then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(125, strengLvl))
			return
		end
		local partID = g_i3k_db.i3k_db_get_equip_item_cfg(self._equip_id).partID
		g_i3k_ui_mgr:CloseUI(eUIID_Bag)
		g_i3k_ui_mgr:CloseUI(eUIID_RoleLy)
		g_i3k_logic:OpenStrengEquipUI(partID, self._equip_id)
		g_i3k_ui_mgr:CloseUI(eUIID_EquipTips)
	end

end

function wnd_equip_info:SetTips(list, equip, isCompare)
	local itemid = equip.equip_id
	local equip_t = g_i3k_db.i3k_db_get_equip_item_cfg(itemid)

	local base_attribute = equip_t.properties
	local expect_attribute = equip_t.ext_properties
	local roleName = TYPE_SERIES_NAME[equip_t.roleType]

	local partID = equip_t.partID
	local C_require = equip_t.C_require
	local M_require = equip_t.M_require

	local is_effect = equip_t.rankFactor

	local wEquips = g_i3k_game_context:GetWearEquips()
	local qLv = wEquips[partID].eqGrowLvl
	local sLv = wEquips[partID].eqEvoLvl
	local slot_data = wEquips[partID].slot
	local gemBless = wEquips[partID].gemBless
	--local attribute = wEquips[partID].equip.attribute
	local attribute = equip.attribute
	local refine = equip.refine
	local naijiu = nil
	local smeltingProps = equip.smeltingProps
	local hammerSkill = equip.hammerSkill
	if wEquips[partID] and wEquips[partID].equip and wEquips[partID].equip.naijiu  then
		naijiu = wEquips[partID].equip.naijiu
	end
	if isCompare then
		self.repair_btn:hide()
	elseif naijiu and naijiu ~= -1  then
		self.repair_btn:show()
		self.repair_btn:setTag(partID)
		self.repair_btn:onClick(self, self.onRepairEquip, equip.legends)
		self.label3:setText("传世")
	else
		self.repair_btn:hide()
	end
	local widgets = self._layout.vars
	local needItem = {}
	local icon = g_i3k_db.i3k_db_get_common_item_icon_path(itemid,g_i3k_game_context:IsFemaleRole())
	local name = equip_t.name
	local level = equip_t.levelReq
	local star_iconid = 34
	local icon1 = i3k_db_icons[star_iconid + sLv]
	local star_animationID = 1806
	local icon2 = i3k_db_icons[star_animationID + sLv]
	for i = 1,2 do
		local naijiuS = "naijiu"..i
		local shuijing = "shuijing"..i
		local is_free = "is_free"..i
		local is_sale = "is_sale"..i
		local get_label = "get_label"..i
		local equip_icon = "equip_icon"..i
		local equip_bg = "equip_bg"..i

		local starlvlBg = "starlvlBg"..i
		local starlvl = "starlvl"..i
		local power = "power"..i
		local power_value = "power_value"..i
		local level = "level"..i
		local part = "part"..i
		local equip_name = "equip_name"..i
		local role = "role"..i
		needItem[i] = {
			naijiuS	        = widgets[naijiuS],
			--shuijing		= widgets[shuijing],
			is_free			= widgets[is_free],
			is_sale	    	= widgets[is_sale],
			get_label	    = widgets[get_label],
			equip_icon		= widgets[equip_icon],
			equip_bg	    = widgets[equip_bg],

			starlvlBg	    = widgets[starlvlBg],
			starlvl			= widgets[starlvl],
			power			= widgets[power],
			power_value	    = widgets[power_value],
			level	    	= widgets[level],
			part			= widgets[part],
			equip_name	    = widgets[equip_name],
			role			= widgets[role]
		}
	end
	local compareID = isCompare and 2 or 1
	needItem[compareID].naijiuS:setVisible(naijiu~=-1)
	--needItem[compareID].shuijing:setVisible(naijiu~=-1)
	self._layout.vars["an"..compareID .. 1]:hide()
	self._layout.vars["an"..compareID .. 2]:hide()
	if naijiu and naijiu ~= -1 then
		needItem[compareID].naijiuS:setText("耐久度："..math.modf(naijiu/1000))
		local rankIndex = g_i3k_game_context:GetBagEquipIsSpecial(itemid, naijiu)
		local index = rankIndex == 1 and 2 or 1
		self._layout.vars["an"..compareID .. index]:show()
	end
	needItem[compareID].is_free:show()
	needItem[compareID].is_sale:show()
	needItem[compareID].is_free:setText(itemid>0 and "已绑定" or "未绑定")
	if itemid > 0 then
		needItem[compareID].is_sale:hide()
	end
	needItem[compareID].is_sale:setText(g_i3k_db.i3k_db_get_common_item_can_sale(itemid) and "可交易" or "不可交易")
	needItem[compareID].is_free:setTextColor(g_i3k_get_cond_color(itemid<0))
	needItem[compareID].is_sale:setTextColor(g_i3k_get_cond_color(g_i3k_db.i3k_db_get_common_item_can_sale(itemid)))
	needItem[compareID].get_label:setText(equip_t.get_way)
	local total_power = g_i3k_game_context:GetBodyEquipPower(itemid,attribute,naijiu,qLv,sLv,slot_data,refine,equip.legends, gemBless, smeltingProps, hammerSkill)
	local base_power = g_i3k_game_context:GetBagEquipPower(itemid,attribute,naijiu, refine, equip.legends, smeltingProps)
	total_power = math.modf(total_power)
	base_power = math.modf(base_power)
	if total_power - base_power >= 1 then
		needItem[compareID].power_value:setText(base_power.."+"..(total_power - base_power ))
	else
		needItem[compareID].power_value:setText(base_power)
	end
	if qLv ~= 0 then
		needItem[compareID].equip_name:setText("  "..name.."+"..qLv)
	else
		needItem[compareID].equip_name:setText("  "..name)
	end

	needItem[compareID].equip_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemid)))
	needItem[compareID].equip_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
	needItem[compareID].equip_icon:setImage(icon)
	needItem[compareID].level:setText(level .. "级")
	needItem[compareID].part:setText(i3k_db_equip_part[partID].partName)
	if i3k_db_equip_part[partID].nameColor ~= "0.0" then
		needItem[compareID].part:setTextColor(i3k_db_equip_part[partID].nameColor)
	end
	if sLv ~= 0 then
		needItem[compareID].starlvlBg:setImage(icon1.path)
		needItem[compareID].starlvl:setImage(icon2.path)
		needItem[compareID].starlvl.ccNode_:setBlendAdditive(true)
	else
		needItem[compareID].starlvlBg:hide()
	end
	local roleStr = ""
	if M_require == 1 then
		roleStr = "转".."  正"
	elseif M_require == 2 then
		roleStr = "转".."  邪"
	elseif M_require == 0 then
		roleStr = "转"
	end
	needItem[compareID].role:setText(roleName.."   "..C_require..roleStr)
	if compareID == 1 then
		self.mark_icon:hide()
	end
	self:setScrollLegends(list, equip.legends, partID)
	self:setScrollData(list, base_attribute, expect_attribute, naijiu, attribute, refine, equip.legends, itemid, smeltingProps, hammerSkill)
	--宝石
	local inlayLvl = i3k_db_common.functionOpen.inlayLvl
	local lvl = g_i3k_game_context:GetLevel()
	if lvl >= inlayLvl then
		if i3k_db_equip_part[partID].slot1Icon and i3k_db_equip_part[partID].slot1Icon ~= 0 then
			local des = require(LAYER_ZBTIPST3)()
			des.vars.desc:setText(diamond_desc)
			list:addItem(des)
		end
		local ratio = g_i3k_game_context:GetIncreaseRatioOfGemBlessOnEquip(partID) --提升宝石属性的系数
		for i=1,4 do
			local slotIcon = i3k_db_equip_part[partID]["slot" .. i .."Icon"]
			local slotName = i3k_db_equip_part[partID]["slot" .. i .."Name"]
			if slotIcon and slotIcon ~= 0 then
				local des = require(LAYER_ZBTIPST2)()
				des.vars.desc:setText(slotName)
				des.vars.diamond_bg:setImage(g_i3k_db.i3k_db_get_icon_path(slotIcon))
				local diamondID =  slot_data[i]
				if diamondID and g_i3k_db.i3k_db_get_gem_item_cfg(diamondID) then
					local gemCfg = g_i3k_db.i3k_db_get_gem_item_cfg(diamondID)
					local iconid = g_i3k_db.i3k_db_get_gem_item_cfg(diamondID).icon
					local effect_id = g_i3k_db.i3k_db_get_gem_item_cfg(diamondID).effect_id
					local effect_value = g_i3k_db.i3k_db_get_gem_item_cfg(diamondID).effect_value
					local blessCfg = g_i3k_db.i3k_db_get_diamond_bless_cfg(gemCfg.type)
					local isBless = false
					local addPercent = 0
					if gemBless and gemBless[i] and gemBless[i] >= 1 then
						isBless = true
						addPercent = blessCfg[gemBless[i]]
					end
					effect_value = math.floor(effect_value * (1 + addPercent  + ratio ))
					local effect_desc = i3k_db_prop_id[effect_id].desc
					local textColor = i3k_db_prop_id[effect_id].textColor
					local valuColor = i3k_db_prop_id[effect_id].valuColor
					effect_desc = effect_desc.."<c/>".."<c=ff1f9400>".." +"..effect_value.."<c/>"
					des.vars.diamond_icon:setImage(g_i3k_db.i3k_db_get_icon_path(iconid))
					des.vars.blessIcon:setVisible(isBless)
					des.vars.blessIcon:setImage(g_i3k_db.i3k_db_get_icon_path(bless_rankImg[gemBless[i]]))
					des.vars.desc:setText(effect_desc)
				end
				list:addItem(des)
			end
		end
	end
end

function wnd_equip_info:SetBagTips(list, equip, needIndex)
	local itemid = equip.equip_id
	local guid = equip.equip_guid
	local index = needIndex and needIndex or 1
	self.repair_btn:hide()
	local equip_t =  g_i3k_db.i3k_db_get_equip_item_cfg(itemid)
	local roleName = TYPE_SERIES_NAME[equip_t.roleType]
	--local equips = g_i3k_game_context:GetBagEquip(itemid,guid)
	local base_attribute = equip_t.properties
	local expect_attribute = equip_t.ext_properties

	local C_require = equip_t.C_require
	local M_require = equip_t.M_require
	local partID = equip_t.partID
	local is_effect = equip_t.rankFactor

	local transfromLvl = g_i3k_game_context:GetTransformLvl()
	local bwtype = g_i3k_game_context:GetTransformBWtype()

	self["get_label" .. index]:setText(equip_t.get_way)

	local wEquips = g_i3k_game_context:GetWearEquips()
	local naijiu = self._equip_naijiu
	local attribute = self._equip_attribute
	local refine = self._equip_refine
	local smeltingProps = self._equip_smeltingProps
	local hammerSkill = self._equip_hammerSkill
	self["is_free" .. index]:show()
	self["is_sale" .. index]:show()
	self["is_free" .. index]:setText(itemid>0 and "已绑定" or "未绑定")
	if itemid > 0 then
		self["is_sale" .. index]:hide()
	end
	self["is_sale" .. index]:setText(g_i3k_db.i3k_db_get_common_item_can_sale(itemid) and "可交易" or "不可交易")
	self["is_free" .. index]:setTextColor(g_i3k_get_cond_color(itemid<0))
	self["is_sale" .. index]:setTextColor(g_i3k_get_cond_color(g_i3k_db.i3k_db_get_common_item_can_sale(itemid)))
	self["get_label" .. index]:setText(equip_t.get_way)
	local naijiu1 = self._layout.vars["naijiu" .. index]
	--local shuijing1 = self._layout.vars["shuijing" .. index]
	if naijiu1 and naijiu ~= -1 then
		local value1 = math.modf(naijiu/1000)
		naijiu1:show()
		naijiu1:setText("耐久度："..value1)
		--shuijing1:show()
		local rankIndex = g_i3k_game_context:GetBagEquipIsSpecial(itemid, naijiu)
		rankIndex = rankIndex == 1 and 2 or 1
		self._layout.vars["an"..index..rankIndex]:show()
	elseif naijiu1 then
		naijiu1:hide()
		--shuijing1:hide()
		self._layout.vars["an"..index.."1"]:hide()
		self._layout.vars["an"..index.."2"]:hide()
	end
	---------naijiu1, shuijing1
	local icon = g_i3k_db.i3k_db_get_common_item_icon_path(itemid,g_i3k_game_context:IsFemaleRole())
	local name = equip_t.name
	local level = equip_t.levelReq

	local equip_icon = self._layout.vars["equip_icon" .. index]
	local equip_bg = self._layout.vars["equip_bg" .. index]

	local starlvlBg = self._layout.vars["starlvlBg" .. index]

	local power1 = self._layout.vars["power" .. index]
	local power_value1 = self._layout.vars["power_value" .. index]

	if power_value1 then
		local total_power = g_i3k_game_context:GetBagEquipPower(itemid,attribute,naijiu,refine,equip.legends, smeltingProps)
		total_power = math.modf(total_power)
		power_value1:setText(total_power)
		if wEquips[partID].equip and wEquips[partID].equip.equip_id then
			local wEquip = wEquips[partID].equip
			local wAttribute = wEquip.attribute
			local wNaijiu =wEquip.naijiu
			local wEquip_id = wEquip.equip_id
			local wPower = g_i3k_game_context:GetBagEquipPower(wEquip_id,wAttribute,wNaijiu,refine,wEquip.legends, wEquip.smeltingProps)
			if wPower > total_power then
				self.mark_icon:setImage(i3k_db_icons[compare_icon[2]].path)
			elseif wPower < total_power then
				self.mark_icon:setImage(i3k_db_icons[compare_icon[1]].path)
			elseif wPower == total_power then
				self.mark_icon:setImage(i3k_db_icons[compare_icon[3]].path)
			end
		else
			self.mark_icon:setImage(i3k_db_icons[compare_icon[1]].path)
		end
	end

	if needIndex then
		local power1 = g_i3k_game_context:GetBagEquipPower(self._equip_id1,self._equip_attribute1 ,self._equip_naijiu1, self._equip_refine1, equip.legends)
		local power2 = g_i3k_game_context:GetBagEquipPower(self._equip_id2,self._equip_attribute2 ,self._equip_naijiu2, self._equip_refine2, equip.legends)
		if power2 > power1 then
			self.mark_icon:setImage(i3k_db_icons[compare_icon[2]].path)
		elseif power2 < power1 then
			self.mark_icon:setImage(i3k_db_icons[compare_icon[1]].path)
		elseif power2 == power1 then
			self.mark_icon:setImage(i3k_db_icons[compare_icon[3]].path)
		end
	end

	self:setScrollLegends(list, equip.legends, partID)
	local level1 = self._layout.vars["level" .. index]
	local part = self._layout.vars["part" .. index]
	self["equip_name" .. index]:setText("  "..name)
	self["equip_name" .. index]:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemid)))
	equip_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
	equip_icon:setImage(icon)
	level1:setText(level .. "级")
	starlvlBg:hide()
	part:setText(i3k_db_equip_part[partID].partName)
	if i3k_db_equip_part[partID].nameColor ~= "0.0" then
		part:setTextColor(i3k_db_equip_part[partID].nameColor)
	end
	if not g_i3k_db.i3k_db_check_equip_level(itemid) then
		if g_i3k_game_context:GetLevel() < level then
			level1:setTextColor(g_i3k_game_context:GetRedColour())
		end
	end
	if equip_t.roleType == 0 then
		--roleName = "<c=white>"..roleName.."</c>"
	elseif equip_t.roleType ~= 0 and equip_t.roleType ~= g_i3k_game_context:GetRoleType() then
		roleName = "<c=red>"..roleName.."</c>"
	end
	C_require = ( transfromLvl < C_require and not g_i3k_db.i3k_db_check_equip_level(itemid) )and "<c=red>"..C_require.."转</c>" or C_require.."转"
	local role1Str = ""
	if M_require == 1 then
		role1Str = M_require ~= bwtype and "<c=red>正</c>" or "正"
	elseif M_require == 2 then
		role1Str = M_require ~= bwtype and "<c=red>邪</c>" or "邪"
	elseif M_require == 0 then
		role1Str = ""
	end
	self["role" .. index]:setText(roleName.."   "..C_require.."  "..role1Str)
	self:setScrollData(list, base_attribute, expect_attribute, naijiu, attribute, refine, equip.legends, itemid, smeltingProps, hammerSkill)
end

function wnd_equip_info:setScrollLegends(list, legends, partID)
	for i,e in ipairs(legends) do
		if e ~= 0 then
			local layer = require("ui/widgets/sjzbt")()
			local widget = layer.vars
			local cfg = LegendsTab[i]
			local nCfg
			if i == 3 then
				nCfg = cfg[partID][e]
			else
				nCfg = cfg[e]
			end
			widget.icon:setImage(g_i3k_db.i3k_db_get_icon_path(nCfg.icon))
			widget.desc:setText(nCfg.tips);
			list:addItem(layer)
		end
	end
end

function wnd_equip_info:setScrollData(list, base_attribute, expect_attribute, naijiu, attribute, refine, legends, equipID, smeltingProps, hammerSkill)
	--基础属性
	local des = require(LAYER_ZBTIPST3)()
	des.vars.desc:setText(base_attribute_desc)
	list:addItem(des)

	if base_attribute and type(base_attribute) == "table" then
		for k,v in ipairs(base_attribute) do
			if v.type ~= 0 then
				local des = require(LAYER_ZBTIPST)()
				local _t = i3k_db_prop_id[v.type]
				local _desc = _t.desc
				local colour1 = _t.textColor
				local colour2 = _t.valuColor
				local _value = v.value
				local Threshold = i3k_db_common.equip.durability.Threshold
				if naijiu ~= -1 and naijiu > Threshold then
					if legends[1] and legends[1] ~= 0 then
						_value = math.floor(_value * (1+i3k_db_equips_legends_1[legends[1]].count/10000))
					end
				end
				_value = math.modf(_value)
				_desc = _desc.." :"
				des.vars.desc:setText(_desc)
				--des.vars.desc:setTextColor(colour1)
				des.vars.value:setText(i3k_get_prop_show(v.type, _value))
				--des.vars.value:setTextColor(colour2)
				list:addItem(des)
			end
		end
	end
	--附加属性
	if expect_attribute and type(expect_attribute) == "table" and next(attribute) then
		for k,v in ipairs(expect_attribute) do
			if v.type ~= 0 then
				if k == 1 then
					local des = require(LAYER_ZBTIPST3)()
					des.vars.desc:setText(add_attribute_desc)
					list:addItem(des)
				end
				local des = require(LAYER_ZBTIPST)()
				local max = g_i3k_db.i3k_db_is_equip_ext_prop_sharpen_max(equipID, k, attribute[k])
				if max then
					des.vars.max_img:show()
				end
				if v.type == 1 then
					local _t = i3k_db_prop_id[v.args]
					local _desc = _t.desc
					local colour1 = _t.textColor
					local colour2 = _t.valuColor
					_desc = _desc
					des.vars.desc:setText(_desc)
					local value = attribute[k]
					local Threshold = i3k_db_common.equip.durability.Threshold
					if naijiu ~= -1 and naijiu > Threshold then
						if legends[2] and legends[2] ~= 0 then
							value = math.floor(value * (1+i3k_db_equips_legends_2[legends[2]].count/10000))
						end
					end
					des.vars.value:setText("+"..i3k_get_prop_show(v.args, value))
					list:addItem(des)
				elseif v.type == 2 then
					local _t = i3k_db_skills[v.args]
					local name = _t.name
					name = name.."等级 +"
					des.vars.desc:setText(name)
					--des.vars.desc:setTextColor(colour1)
					--des.vars.value:setTextColor(colour2)
					des.vars.value:setText("10")
					list:addItem(des)
				elseif v.type == 3 then
					local _t = i3k_db_skills[v.args]
					local name = _t.name
					name = name.."CD -"
					des.vars.desc:setText(name)
					--des.vars.desc:setTextColor(colour1)
					--des.vars.value:setTextColor(colour2)
					des.vars.value:setText("10")
					list:addItem(des)
				elseif v.type == 4 then
					local _t = i3k_db_skills[v.args]
					local _desc= _t.desc
					des.vars.desc:setText(name)
					--des.vars.desc:setTextColor(colour1)
					--des.vars.value:setTextColor(colour2)
					des.vars.value:setText("10")
					list:addItem(_desc)
				end
			end
		end
		local sharpen = g_i3k_db.i3k_db_check_equip_can_sharpen(equipID)
		if not sharpen then
			local rank = g_i3k_db.i3k_db_get_common_item_rank(equipID)
			if rank >= g_RANK_VALUE_PURPLE then
				local sharpenWidget = require("ui/widgets/zbtipst4")()
				sharpenWidget.vars.desc:setText("<不可淬锋>")
				list:addItem(sharpenWidget)
			end
		end
	end

	--精炼属性
	if next(refine) then
		for k,v in pairs(refine) do
			if k == 1 then
				local des = require(LAYER_ZBTIPST3)()
				des.vars.desc:setText(refine_desc)
				list:addItem(des)
			end
			local des = require(LAYER_ZBTIPST)()
			local _t = i3k_db_prop_id[v.id]
			local _desc = _t.desc
			des.vars.desc:setText(_desc)
			des.vars.value:setText("+"..i3k_get_prop_show(v.id, v.value))
			list:addItem(des)
		end
	end

	if smeltingProps and next(smeltingProps) then
		local des = require(LAYER_ZBTIPST3)()
		des.vars.desc:setText(smelting_desc)
		list:addItem(des)
		for k,v in ipairs(smeltingProps) do
			local des = require(LAYER_ZBTIPST)()
			local _t = i3k_db_prop_id[v.id]
			local _desc = _t.desc
			des.vars.desc:setText(_desc..":")
			des.vars.value:setText(i3k_get_prop_show(v.id,v.value))
			des.vars.max_img:setVisible(g_i3k_game_context:isMaxOfEquipProp(equipID, k, v.id, v.value))
			list:addItem(des)
		end
		if hammerSkill and next(hammerSkill) then
			for i, v in pairs(hammerSkill) do
				local cfg = i3k_db_equip_temper_skill[i][v]
				local layer = require(LAYER_ZBTIPST6)()
				layer.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.icon))
				layer.vars.desc:setText(cfg.name)
				list:addItem(layer)
			end
		end
	else
		if not g_i3k_db.i3k_db_get_equip_can_temper(equipID) then
			local sharpenWidget = require("ui/widgets/zbtipst4")()
			local equipCfg = g_i3k_db.i3k_db_get_equip_item_cfg(equipID)
			if equipCfg.temperPropsStarLimit and next(equipCfg.temperPropsStarLimit) then
				sharpenWidget.vars.desc:setText("<未开放锤炼>")
			else
				sharpenWidget.vars.desc:setText("<不可锤炼>")
			end
			list:addItem(sharpenWidget)
		end
	end
end

function wnd_equip_info:tryToTransform(hufu, groupId)
	local info = {_hufu = hufu, _groupId = groupId}
	self.repair_btn:hide()
	self.xiexia_bt:hide()
	self.sale:show()
	self.label1:setText(i3k_db_equip_transform_cfg[groupId].btnName)
	self.sale:onClick(self, self.gotoTransform, info)
end

function wnd_equip_info:gotoTransform(sender, info)
	if info._hufu.equip_id < 0 then
		local callback = function(isOk)
			if isOk then
				g_i3k_ui_mgr:OpenUI(eUIID_EquipTransformCompare)
				g_i3k_ui_mgr:RefreshUI(eUIID_EquipTransformCompare, info._hufu, info._groupId)
				g_i3k_ui_mgr:CloseUI(eUIID_EquipTransform)
				g_i3k_ui_mgr:CloseUI(eUIID_EquipTips)
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(1251), callback)
	else
		g_i3k_ui_mgr:OpenUI(eUIID_EquipTransformCompare)
		g_i3k_ui_mgr:RefreshUI(eUIID_EquipTransformCompare, info._hufu, info._groupId)
		g_i3k_ui_mgr:CloseUI(eUIID_EquipTransform)
		g_i3k_ui_mgr:CloseUI(eUIID_EquipTips)
	end
end

function wnd_create(layout)
	local wnd = wnd_equip_info.new()
		wnd:create(layout)
	return wnd
end
