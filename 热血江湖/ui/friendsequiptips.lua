-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_friendsEquiptips = i3k_class("wnd_friendsEquiptips",ui.wnd_base)
local bless_rankImg = {5139, 5140, 5141, 5142, 10856, 10857, 10858, 10859, 10860, 10861}
local LAYER_ZBTIPST = "ui/widgets/zbtipst"
local LAYER_ZBTIPST2 = "ui/widgets/zbtipst2"
local LAYER_ZBTIPST3 = "ui/widgets/zbtipst3"
local LAYER_ZBTIPST6 = "ui/widgets/zbtipst6"

local base_attribute_desc = "基础属性"
local add_attribute_desc = "附加属性"
local refine_desc = "精炼属性"
local diamond_desc = "宝石"
local temper_desc = "锤炼属性"

--宝石类型对应icon
local dia_icon = {
	[1] = 169,
	[2] = 170,
	[3] = 171,
	[4] = 172,
}

local compare_icon = {
	[1] = 174,
	[2] = 175,
	[3] = 176,
}

local LegendsTab = {i3k_db_equips_legends_1, i3k_db_equips_legends_2, i3k_db_equips_legends_3}
function wnd_friendsEquiptips:ctor()

end

function wnd_friendsEquiptips:configure()
	local widgets = self._layout.vars
	widgets.globel_bt:onClick(self, self.onClose)
end

function wnd_friendsEquiptips:onShow()

end

function wnd_friendsEquiptips:refresh(data)
	self:setTips(data)
end

function wnd_friendsEquiptips:equipSelfDate(data)
	local widgets = self._layout.vars
	local wEquips = g_i3k_game_context:GetWearEquips()--获取个人装备
	if wEquips and wEquips[data.id] and wEquips[data.id].equip then
		widgets.layer1:show()
		local oneSelfItemId = wEquips[data.id].equip.equip_id
		local oneSelfEquip = g_i3k_db.i3k_db_get_equip_item_cfg(oneSelfItemId)
		self:Getdata(wEquips,oneSelfItemId,oneSelfEquip)
		if self.eqGrowLvl ~= 0 then
			widgets.equip_name1:setText("  "..self.name.."+"..self.eqGrowLvl)
		else
			widgets.equip_name1:setText("  "..self.name)
		end
		widgets.equip_name1:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(oneSelfItemId)))
		widgets.equip_bg1:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(oneSelfItemId))
		widgets.equip_icon1:setImage(self.icon.path)
		widgets.level1:setText(self.level .. "级")
		if self.sLv ~= 0 then
			widgets.starlvl1:setImage(self.icon1.path)
		else
			widgets.starlvl1:hide()
		end
		if self.M_require == 1 then
			widgets.role1:setText(self.roleName.."   "..self.C_require.."转".."  正")
		elseif self.M_require == 2 then
			widgets.role1:setText(self.roleName.."   "..self.C_require.."转".."  邪")
		elseif self.M_require == 0 then
			widgets.role1:setText(self.roleName.."   "..self.C_require.."转")
		end
		widgets.power_value1:setText(self.total_power)
		widgets.part1:setText(i3k_db_equip_part[self.partID].partName)
		widgets.is_free1:show()
		widgets.is_sale1:show()
		widgets.is_free1:setText(oneSelfItemId>0 and "已绑定" or "未绑定")
		widgets.is_sale1:setText(g_i3k_db.i3k_db_get_common_item_can_sale(oneSelfItemId) and "可交易" or "不可交易")
		widgets.is_free1:setTextColor(g_i3k_get_cond_color(oneSelfItemId<0))
		widgets.is_sale1:setTextColor(g_i3k_get_cond_color(g_i3k_db.i3k_db_get_common_item_can_sale(oneSelfItemId)))
		widgets.get_label1:setText(oneSelfEquip.get_way)
		self:setScrollLegends(widgets.scroll, wEquips[self.partID].equip.legends,self.partID);
		self:showBaseProperty(widgets.scroll, wEquips[self.partID].equip.legends)
		self:plusProperty(widgets.scroll, wEquips[self.partID].equip.legends, oneSelfItemId)
		self:refineProerty(widgets.scroll, wEquips[self.partID].equip.refine)
		self:showTemperProperty(widgets.scroll, wEquips[self.partID].equip.smeltingProps, wEquips[self.partID].equip.hammerSkill, oneSelfItemId)
		local ratio = g_i3k_db.i3k_db_get_equip_bless_increase_ratio_by_skill_set(wEquips[self.partID].equip.hammerSkill)
		self:showJewel(widgets.scroll, ratio)
	else
		widgets.layer1:hide();
	end
end

function wnd_friendsEquiptips:equipOtherDate(data)
	local widgets = self._layout.vars
	local weakEquips = data.wEquips
	local itemid = weakEquips[data.id].equip.equip_id
	local equip_t = g_i3k_db.i3k_db_get_equip_item_cfg(itemid)
	self:Getdata(weakEquips,itemid,equip_t)
	if self.eqGrowLvl ~= 0 then
		widgets.equip_name2:setText("  "..self.name.."+"..self.eqGrowLvl)
	else
		widgets.equip_name2:setText("  "..self.name)
	end
	widgets.equip_name2:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemid)))
	widgets.equip_bg2:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
	widgets.equip_icon2:setImage(self.icon.path)
	widgets.level2:setText(self.level .. "级")
	if self.sLv ~= 0 then
		widgets.starlvl2:setImage(self.icon1.path)
	else
		widgets.starlvl2:hide()
	end
	if self.M_require == 1 then
		widgets.role2:setText(self.roleName.."   "..self.C_require.."转".."  正")
	elseif self.M_require == 2 then
		widgets.role2:setText(self.roleName.."   "..self.C_require.."转".."  邪")
	elseif self.M_require == 0 then
		widgets.role2:setText(self.roleName.."   "..self.C_require.."转")
	end
	widgets.power_value2:setText(self.total_power)
	widgets.part2:setText(i3k_db_equip_part[self.partID].partName)
	widgets.is_free2:show()
	widgets.is_sale2:show()
	widgets.is_free2:setText(itemid>0 and "已绑定" or "未绑定")
	widgets.is_sale2:setText(g_i3k_db.i3k_db_get_common_item_can_sale(itemid) and "可交易" or "不可交易")
	widgets.is_free2:setTextColor(g_i3k_get_cond_color(itemid<0))
	widgets.is_sale2:setTextColor(g_i3k_get_cond_color(g_i3k_db.i3k_db_get_common_item_can_sale(itemid)))
	widgets.get_label2:setText(equip_t.get_way)
	local refine = weakEquips[equip_t.partID].equip.refine
	self:setScrollLegends(widgets.scroll2, weakEquips[self.partID].equip.legends,self.partID);
	self:showBaseProperty(widgets.scroll2,weakEquips[self.partID].equip.legends)
	self:plusProperty(widgets.scroll2,weakEquips[self.partID].equip.legends, itemid)
	self:refineProerty(widgets.scroll2, refine)
	self:showTemperProperty(widgets.scroll2, weakEquips[self.partID].equip.smeltingProps, weakEquips[self.partID].equip.hammerSkill, itemid)
	local ratio = g_i3k_db.i3k_db_get_equip_bless_increase_ratio_by_skill_set(weakEquips[self.partID].equip.hammerSkill)
	self:showJewel(widgets.scroll2, ratio)
end

function wnd_friendsEquiptips:setTips(data)
	self:equipSelfDate(data);
	self:equipOtherDate(data);
end

function wnd_friendsEquiptips:showBaseProperty(list, legends)
	--基础属性
	local des = require(LAYER_ZBTIPST3)()
	des.vars.desc:setText(base_attribute_desc)
	list:addItem(des)
	if self.base_attribute then
		for k,v in ipairs(self.base_attribute) do
			if v.type ~= 0 then
				local des = require(LAYER_ZBTIPST)()
				local _t = i3k_db_prop_id[v.type]
				local _desc = _t.desc
				local colour1 = _t.textColor
				local colour2 = _t.valuColor
				local Threshold = i3k_db_common.equip.durability.Threshold
				local temp_value = v.value
				if legends[1] and legends[1] ~= 0 then
					temp_value = math.floor(temp_value * (1+i3k_db_equips_legends_1[legends[1]].count/10000))
				end
				temp_value = math.modf(temp_value)
				_desc = _desc.." :"
				des.vars.desc:setText(_desc)
				des.vars.value:setText(temp_value)
				list:addItem(des)
			end
		end
	end
end

function wnd_friendsEquiptips:plusProperty(list, legends, equipID)
	--附加属性
	local index = 0
	if self.expect_attribute and type(self.expect_attribute) == "table" then
		for k,v in ipairs(self.expect_attribute) do
			if v.type ~= 0 then
				index = index + 1
				if index == 1 then
					local des = require(LAYER_ZBTIPST3)()
					des.vars.desc:setText(add_attribute_desc)
					list:addItem(des)
				end
				local des = require(LAYER_ZBTIPST)()
				local max = g_i3k_db.i3k_db_is_equip_ext_prop_sharpen_max(equipID, k, self.attribute[k])
				if max then
					des.vars.max_img:show()
				end
				if v.type == 1 then
					local _t = i3k_db_prop_id[v.args]
					des.vars.desc:setText(_t.desc)
					local multi = 1
					if legends[2] and legends[2] ~= 0 then
						multi = 1+i3k_db_equips_legends_2[legends[2]].count/10000
					end
					if index == 1 and self.attribute[1] then
						des.vars.value:setText("+"..i3k_get_prop_show(v.args, self.attribute[1] * multi))
					elseif index == 2 and self.attribute[2] then
						des.vars.value:setText("+"..i3k_get_prop_show(v.args, self.attribute[2] * multi))
					elseif index == 3 and self.attribute[3] then
						des.vars.value:setText("+"..i3k_get_prop_show(v.args, self.attribute[3] * multi))
					elseif index == 4 and self.attribute[4] then
						des.vars.value:setText("+"..i3k_get_prop_show(v.args, self.attribute[4] * multi))
					elseif index == 5 and self.attribute[5] then
						des.vars.value:setText("+"..i3k_get_prop_show(v.args, self.attribute[5] * multi))
					end
					list:addItem(des)
				elseif v.type == 2 then
					local _t = i3k_db_skills[v.args]
					local name = _t.name
					name = name.."等级 +"
					des.vars.desc:setText(name)
					des.vars.value:setText(i3k_get_prop_show(v.args, self.attribute[2]))
					list:addItem(des)
				elseif v.type == 3 then
					local _t = i3k_db_skills[v.args]
					local name = _t.name
					name = name.."CD -"
					des.vars.desc:setText(name)
					des.vars.value:setText(i3k_get_prop_show(v.args, self.attribute[3]))
					list:addItem(des)
				elseif v.type == 4 then
					local _t = i3k_db_skills[v.args]
					des.vars.desc:setText(name)
					des.vars.value:setText(i3k_get_prop_show(v.args, self.attribute[4]))
					list:addItem(des)
				end
			end
		end
	end
end

function wnd_friendsEquiptips:refineProerty(list, refine)
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
end

function wnd_friendsEquiptips:showTemperProperty(list, smeltingProps, hammerSkill, equipID)
	--锤炼属性
	if smeltingProps and next(smeltingProps) then
		local des = require(LAYER_ZBTIPST3)()
		des.vars.desc:setText(temper_desc)
		list:addItem(des)
		for i, v in ipairs(smeltingProps) do
			local des = require(LAYER_ZBTIPST)()
			local _t = i3k_db_prop_id[v.id]
			local _desc = _t.desc
			des.vars.desc:setText(_desc)
			des.vars.value:setText("+"..i3k_get_prop_show(v.id, v.value))
			des.vars.max_img:setVisible(g_i3k_game_context:isMaxOfEquipProp(equipID, i, v.id, v.value))
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
	end
end

function wnd_friendsEquiptips:showJewel(list, ratio)
	--宝石
	local inlayLvl = i3k_db_common.functionOpen.inlayLvl
	local lvl = g_i3k_game_context:GetLevel()
	if lvl >= inlayLvl then
		if i3k_db_equip_part[self.partID].slot1Icon and i3k_db_equip_part[self.partID].slot1Icon ~= 0 then
			local des = require(LAYER_ZBTIPST3)()
			des.vars.desc:setText(diamond_desc)
			list:addItem(des)
		end
		for i=1,4 do
			local _temp = self["slot" .. i .."Type"]
			local _tempIcon = i3k_db_equip_part[self.partID]["slot" .. i .."Icon"]
			local _tempName = i3k_db_equip_part[self.partID]["slot" .. i .."Name"]
			if _tempIcon and _tempIcon ~= 0 then
				local des = require(LAYER_ZBTIPST2)()
				des.vars.desc:setText(_tempName)
				des.vars.diamond_bg:setImage(g_i3k_db.i3k_db_get_icon_path(_tempIcon))
				local diamondID =  self.slot_data[i]
				if diamondID and g_i3k_db.i3k_db_get_gem_item_cfg(diamondID) then
					local gemCfg = g_i3k_db.i3k_db_get_gem_item_cfg(diamondID)
					local iconid = g_i3k_db.i3k_db_get_gem_item_cfg(diamondID).icon
					local effect_id = g_i3k_db.i3k_db_get_gem_item_cfg(diamondID).effect_id
					local effect_value = g_i3k_db.i3k_db_get_gem_item_cfg(diamondID).effect_value
					local effect_desc = i3k_db_prop_id[effect_id].desc
					local blessCfg = g_i3k_db.i3k_db_get_diamond_bless_cfg(gemCfg.type)
					local isBless = false
					local addPercent = 0
					if self.bless_data and self.bless_data[i] and self.bless_data[i] ~= 0 then
						isBless = true
						addPercent = blessCfg[self.bless_data[i]]
					end
					effect_value = math.floor(effect_value * (1 + addPercent + ratio))
					effect_desc = effect_desc.."<c/>".."<c=ff1f9400>".." +"..effect_value.."<c/>"
					des.vars.diamond_icon:setImage(g_i3k_db.i3k_db_get_icon_path(iconid))
					des.vars.blessIcon:setVisible(isBless)
					des.vars.blessIcon:setImage(g_i3k_db.i3k_db_get_icon_path(bless_rankImg[self.bless_data[i]]))
					des.vars.desc:setText(effect_desc)
				end
				list:addItem(des)
			end
		end
	end
end

function wnd_friendsEquiptips:setScrollLegends(list, legends, partID)
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
			widget.desc:setText(nCfg.tips)
			list:addItem(layer)
		end
	end
end

function wnd_friendsEquiptips:Getdata(wEquips,itemid,equip_t)
	--装备基础信息
	self.base_attribute = equip_t.properties
	self.expect_attribute = equip_t.ext_properties
	self.roleName = TYPE_SERIES_NAME[equip_t.roleType]
	self.partID = equip_t.partID
	self.C_require = equip_t.C_require
	self.M_require = equip_t.M_require
	self.icon = i3k_db_icons[equip_t.icon]
	self.name = equip_t.name
	self.level = equip_t.levelReq
	local is_effect = equip_t.rankFactor
	--个人信息
	self.eqGrowLvl = wEquips[self.partID].eqGrowLvl
	self.sLv = wEquips[self.partID].eqEvoLvl
	self.slot_data = wEquips[self.partID].slot
	self.bless_data = wEquips[self.partID].gemBless
	self.attribute = wEquips[self.partID].equip.attribute
	self.naijiu = wEquips[self.partID].equip.naijiu
	self.smeltingProps = wEquips[self.partID].equip.smeltingProps
	self.hammerSkill = wEquips[self.partID].equip.hammerSkill
	local total_power = g_i3k_game_context:GetBodyEquipPower(itemid,self.attribute,self.naijiu,self.eqGrowLvl,self.sLv,self.slot_data,wEquips[self.partID].equip.refine, wEquips[self.partID].equip.legends, self.bless_data, self.smeltingProps, self.hammerSkill)
	self.total_power = math.modf(total_power)
	local star_iconid = 34
	self.icon1 = i3k_db_icons[star_iconid + self.sLv]
end

function wnd_friendsEquiptips:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_ShowFriendsEquipTips)
end

function wnd_create(layout, ...)
	local wnd = wnd_friendsEquiptips.new();
		wnd:create(layout, ...);
	return wnd;
end 
