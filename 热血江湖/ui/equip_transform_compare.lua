-------------------------------------------------------
module(..., package.seeall)

local require = require;
require("ui/ui_funcs")
local ui = require("ui/base");

-------------------------------------------------------
wnd_equip_transform_compare = i3k_class("wnd_equip_transform_compare", ui.wnd_base)

local HUFUPROP = "ui/widgets/hufuzh2t1"
local ITEMWIDGET = "ui/widgets/hufuzh2t2"
local LAYER_ZBTIPST3 = "ui/widgets/zbtipst3"
local LAYER_ZBTIPST2 = "ui/widgets/zbtipst2"
local LAYER_ZBTIPST6 = "ui/widgets/zbtipst6"

local base_attribute_desc = "基础属性"
local add_attribute_desc = "附加属性"
local refine_desc = "精炼属性"
local temper_desc = "锤炼属性"

local LegendsTab = {i3k_db_equips_legends_1, i3k_db_equips_legends_2, i3k_db_equips_legends_3}
local TopRate = i3k_db_common.equipSharpen.topRate

function wnd_equip_transform_compare:ctor()
	self.items = {}
	self.equip = {}
end

function wnd_equip_transform_compare:configure()
	self._layout.vars.close:onClick(self, self.onCloseUI)
	self.scroll1 = self._layout.vars.scroll1
	self.scroll2 = self._layout.vars.scroll2
end

function wnd_equip_transform_compare:refresh(equip,groupId)
	self.equip = equip
	self._groupId = groupId
	self._layout.vars.titleImage:setImage(i3k_db_icons[i3k_db_equip_transform_cfg[groupId].pictureId].path)
	self._layout.vars.desc:setText(i3k_get_string(i3k_db_equip_transform_cfg[groupId].tipId))
	self._layout.vars.btnName:setText(i3k_db_equip_transform_cfg[groupId].btnName)
	self:setCurrentProp(equip)
	self:setTransformProp(equip)
	self:setConsumeItems()
end

--左侧装备信息
function wnd_equip_transform_compare:setCurrentProp(equip)
	local equipId = equip.equip_id
	local equip_t = g_i3k_db.i3k_db_get_equip_item_cfg(equipId)
	local base_attribute = equip_t.properties
	local expect_attribute = equip_t.ext_properties
	local naijiu = equip.naijiu
	local refine = equip.refine
	local legends = equip.legends
	local smeltingProps = equip.smeltingProps
	local hammerSkill = equip.hammerSkill
	local power = g_i3k_game_context:GetBagEquipPower(equipId, equip.attribute, naijiu, refine, legends, smeltingProps, hammerSkill)
	self._layout.vars.equipBg1:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equipId))
	self._layout.vars.equipIcon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equipId,g_i3k_game_context:IsFemaleRole()))
	self._layout.vars.equipName1:setText(equip_t.name)
	self._layout.vars.suo1:setVisible(equipId > 0)
	self._layout.vars.power1:setText(power)
	self:setLegendsProp(legends, self.scroll1, equip_t.partID)
	self:setBaseProp(legends, base_attribute, self.scroll1, naijiu)
	--附加属性
	if expect_attribute and type(expect_attribute) == "table" then
		for k,v in ipairs(expect_attribute) do
			if v.type ~= 0 then
				if k == 1 then
					local des = require(LAYER_ZBTIPST3)()
					des.vars.desc:setText(add_attribute_desc)
					self.scroll1:addItem(des)
				end
				local des = require(HUFUPROP)()
				local max = g_i3k_db.i3k_db_is_equip_ext_prop_sharpen_max(equipId, k, equip.attribute[k])
				if max then
					des.vars.max_img:show()
				end
				if v.type == 1 then
					local _t = i3k_db_prop_id[v.args]
					local _desc = _t.desc
					des.vars.desc:setText(_desc)
					local value = equip.attribute[k]
					local Threshold = i3k_db_common.equip.durability.Threshold
					if naijiu ~= -1 and naijiu > Threshold then
						if legends[2] and legends[2] ~= 0 then
							value = math.floor(value * (1 + i3k_db_equips_legends_2[legends[2]].count/10000))
						end
					end
					des.vars.value:setText("+"..i3k_get_prop_show(v.args, value))
					self.scroll1:addItem(des)
				elseif v.type == 2 then
					local _t = i3k_db_skills[v.args]
					local name = _t.name
					name = name.."等级 +"
					des.vars.desc:setText(name)
					des.vars.value:setText("10")
					self.scroll1:addItem(des)
				elseif v.type == 3 then
					local _t = i3k_db_skills[v.args]
					local name = _t.name
					name = name.."CD -"
					des.vars.desc:setText(name)
					des.vars.value:setText("10")
					self.scroll1:addItem(des)
				elseif v.type == 4 then
					local _t = i3k_db_skills[v.args]
					local _desc= _t.desc
					des.vars.desc:setText(name)
					des.vars.value:setText("10")
					self.scroll1:addItem(_desc)
				end
			end
		end
		local sharpen = g_i3k_db.i3k_db_check_equip_can_sharpen(equipId)
		if not sharpen then
			local rank = g_i3k_db.i3k_db_get_common_item_rank(equipId)
			if rank >= g_RANK_VALUE_PURPLE then
				local sharpenWidget = require("ui/widgets/zbtipst4")()
				sharpenWidget.vars.desc:setText("<不可淬锋>")
				self.scroll1:addItem(sharpenWidget)
			end
		end
	end
	self:setRefineProp(refine, self.scroll1)
	self:setTemperProp(smeltingProps, hammerSkill, self.scroll1, equipId)
end

--右侧装备信息
function wnd_equip_transform_compare:setTransformProp(equip)
	local equipId = i3k_db_equip_transform[self._groupId][math.abs(equip.equip_id)].newEquipId
	local equip_t = g_i3k_db.i3k_db_get_equip_item_cfg(equipId)
	local base_attribute = equip_t.properties
	local naijiu = equip.naijiu
	local refine = equip.refine
	local legends = equip.legends
	local smeltingProps = equip.smeltingProps
	local hammerSkill = equip.hammerSkill
	local attribute_min = {}
	local attribute_max = {}
	local attribute_max_per = {}
	for i, j in ipairs(equip_t.ext_properties) do
		table.insert(attribute_min, j.minVal)
		table.insert(attribute_max, j.maxVal * TopRate[equip_t.partID])
		table.insert(attribute_max_per, j.maxVal)
	end
	local power_min = g_i3k_game_context:GetBagEquipPower(equipId, attribute_min, naijiu, refine, legends, smeltingProps)
	local power_max = g_i3k_game_context:GetBagEquipPower(equipId, attribute_max_per, naijiu, refine, legends, smeltingProps)
	self._layout.vars.equipBg2:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equipId))
	self._layout.vars.equipIcon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equipId,g_i3k_game_context:IsFemaleRole()))
	self._layout.vars.equipName2:setText(equip_t.name)
	self._layout.vars.suo2:setVisible(true)
	self:setLegendsProp(legends, self.scroll2, equip_t.partID)
	self:setBaseProp(legends, base_attribute, self.scroll2, naijiu)
	if power_min == power_max then
		self._layout.vars.power2:setText(power_min)
	else
	self._layout.vars.power2:setText(power_min.."~"..power_max)
	end
	--附加属性
	if equip_t.ext_properties and type(equip_t.ext_properties) == "table" then
		for k,v in ipairs(equip_t.ext_properties) do
			if v.type ~= 0 then
				if k == 1 then
					local des = require(LAYER_ZBTIPST3)()
					des.vars.desc:setText(add_attribute_desc)
					self.scroll2:addItem(des)
				end
				local des = require(HUFUPROP)()
				--[[local max = g_i3k_db.i3k_db_is_equip_ext_prop_sharpen_max(equipId, k, attribute[k])
				if max then
					des.vars.max_img:show()
				end--]]
				if v.type == 1 then
					local _t = i3k_db_prop_id[v.args]
					local _desc = _t.desc
					des.vars.desc:setText(_desc)
					local value_min = attribute_min[k]
					local value_max = attribute_max[k]
					local Threshold = i3k_db_common.equip.durability.Threshold
					if naijiu ~= -1 and naijiu > Threshold then
						if legends[2] and legends[2] ~= 0 then
							value_min = math.floor(value_min * (1 + i3k_db_equips_legends_2[legends[2]].count/10000))
							value_max = math.floor(value_max * (1 + i3k_db_equips_legends_2[legends[2]].count/10000))
						end
					end
					if value_min == attribute_max_per[k] then
						des.vars.value:setText("+"..i3k_get_prop_show(v.args, value_min))
					else
					des.vars.value:setText("+"..i3k_get_prop_show(v.args, value_min).."~"..i3k_get_prop_show(v.args, value_max))
					end
					self.scroll2:addItem(des)
				elseif v.type == 2 then
					local _t = i3k_db_skills[v.args]
					local name = _t.name
					name = name.."等级 +"
					des.vars.desc:setText(name)
					des.vars.value:setText("10")
					self.scroll2:addItem(des)
				elseif v.type == 3 then
					local _t = i3k_db_skills[v.args]
					local name = _t.name
					name = name.."CD -"
					des.vars.desc:setText(name)
					des.vars.value:setText("10")
					self.scroll2:addItem(des)
				elseif v.type == 4 then
					local _t = i3k_db_skills[v.args]
					local _desc= _t.desc
					des.vars.desc:setText(name)
					des.vars.value:setText("10")
					self.scroll2:addItem(_desc)
				end
			end
		end
		local sharpen = g_i3k_db.i3k_db_check_equip_can_sharpen(equipId)
		if not sharpen then
			local rank = g_i3k_db.i3k_db_get_common_item_rank(equipId)
			if rank >= g_RANK_VALUE_PURPLE then
				local sharpenWidget = require("ui/widgets/zbtipst4")()
				sharpenWidget.vars.desc:setText("<不可淬锋>")
				self.scroll2:addItem(sharpenWidget)
			end
		end
	end
	self:setRefineProp(refine, self.scroll2)
	self:setTemperProp(smeltingProps, hammerSkill, self.scroll2, equipId)
end

--传世属性
function wnd_equip_transform_compare:setLegendsProp(legends, scroll, partID)
	for i, e in ipairs(legends) do
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
			scroll:addItem(layer)
		end
	end
end

--基础属性
function wnd_equip_transform_compare:setBaseProp(legends, base_attribute, scroll, naijiu)
	local node = require(LAYER_ZBTIPST3)()
	node.vars.desc:setText(base_attribute_desc)
	scroll:addItem(node)

	if base_attribute and type(base_attribute) == "table" then
		for k,v in ipairs(base_attribute) do
			if v.type ~= 0 then
				local node = require(HUFUPROP)()
				local _t = i3k_db_prop_id[v.type]
				local _desc = _t.desc
				local colour1 = _t.textColor
				local colour2 = _t.valuColor
				local _value = v.value
				local Threshold = i3k_db_common.equip.durability.Threshold
				if naijiu and naijiu ~= -1 and naijiu > Threshold then
					if legends[1] and legends[1] ~= 0 then
						_value = math.floor(_value * (1+i3k_db_equips_legends_1[legends[1]].count/10000))
					end
				end
				_value = math.modf(_value)
				_desc = _desc.." :"
				node.vars.desc:setText(_desc)
				node.vars.value:setText(i3k_get_prop_show(v.type, _value))
				scroll:addItem(node)
			end
		end
	end
end

--精炼属性
function wnd_equip_transform_compare:setRefineProp(refine, scroll)
	if next(refine) then
		for k,v in pairs(refine) do
			if k == 1 then
				local des = require(LAYER_ZBTIPST3)()
				des.vars.desc:setText(refine_desc)
				scroll:addItem(des)
			end
			local des = require(HUFUPROP)()
			local _t = i3k_db_prop_id[v.id]
			local _desc = _t.desc
			des.vars.desc:setText(_desc)
			des.vars.value:setText("+"..i3k_get_prop_show(v.id, v.value))
			scroll:addItem(des)
		end
	end
end

--锤炼属性
function wnd_equip_transform_compare:setTemperProp(smeltingProps, hammerSkill, scroll, equipID)
	if smeltingProps and next(smeltingProps) then
		local des = require(LAYER_ZBTIPST3)()
		des.vars.desc:setText(temper_desc)
		scroll:addItem(des)
		for i, v in ipairs(smeltingProps) do
			local des = require(HUFUPROP)()
			local _t = i3k_db_prop_id[v.id]
			local _desc = _t.desc
			des.vars.desc:setText(_desc)
			des.vars.value:setText("+"..i3k_get_prop_show(v.id, v.value))
			des.vars.max_img:setVisible(g_i3k_game_context:isMaxOfEquipProp(equipID, i, v.id, v.value))
			scroll:addItem(des)
		end
		if hammerSkill and next(hammerSkill) then
			for i, v in pairs(hammerSkill) do
				local cfg = i3k_db_equip_temper_skill[i][v]
				local layer = require(LAYER_ZBTIPST6)()
				layer.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.icon))
				layer.vars.desc:setText(cfg.name)
				scroll:addItem(layer)
			end
		end
	end
end
--转化消耗
function wnd_equip_transform_compare:setConsumeItems()
	local equipId = self.equip.equip_id
	self.items = {}
	self._layout.vars.scroll3:removeAllChildren()
	local isEnough = true
	for i = 1, 3 do
		local itemId = i3k_db_equip_transform[self._groupId][math.abs(equipId)]["itemId"..i]
		if itemId ~= 0 then
			local itemCount = i3k_db_equip_transform[self._groupId][math.abs(equipId)]["itemCount"..i]
			local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(itemId)
			table.insert(self.items, {id = itemId, count = itemCount})
			local node = require(ITEMWIDGET)()
			node.vars.itemBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemId))
			node.vars.itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemId, g_i3k_game_context:IsFemaleRole()))
			if math.abs(itemId) == g_BASE_ITEM_COIN then
				node.vars.itemCount:setText(itemCount)
			else
				node.vars.itemCount:setText(haveCount.."/"..itemCount)
			end
			if itemCount > haveCount then
				node.vars.itemCount:setTextColor(g_i3k_get_cond_color(false))
				isEnough = false
			else
				node.vars.itemCount:setTextColor(g_i3k_get_cond_color(true))
			end
			node.vars.suo:setVisible(itemId > 0)
			node.vars.name:setText(g_i3k_db.i3k_db_get_common_item_name(itemId))
			node.vars.select_btn:onClick(self, self.onItem, itemId)
			self._layout.vars.scroll3:addItem(node)
		end
	end
	self._layout.vars.transform:onClick(self, self.onTransform, isEnough)
end

function wnd_equip_transform_compare:onTransform(sender, isEnough)
	if isEnough then
		local equip = self.equip
		i3k_sbean.equip_trans(equip.equip_id, equip.equip_guid, self.items, self._groupId)
	else
		g_i3k_ui_mgr:PopupTipMessage("道具不足")
	end
end

function wnd_equip_transform_compare:onItem(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_create(layout, ...)
	local wnd = wnd_equip_transform_compare.new()
	wnd:create(layout, ...)
	return wnd
end
