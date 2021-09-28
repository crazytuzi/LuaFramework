module(..., package.seeall)
local require = require
local ui = require("ui/base")

local wnd_flyingEquipTrans = i3k_class("wnd_flyingEquipTrans", ui.wnd_base)

local equip_offset = 8
local equip_num = 6
local HUFUPROP = "ui/widgets/feishenghyjd2t2"
local ITEMWIDGET = "ui/widgets/feishenghyjd2t1"
local LAYER_ZBTIPST3 = "ui/widgets/feishenghyjd2t3"
local LAYER_ZBTIPST6 = "ui/widgets/zbtipst6"
local TopRate = i3k_db_common.equipSharpen.topRate

local base_attribute_desc = "基础属性"
local add_attribute_desc = "附加属性"
local refine_desc = "精炼属性"
local temper_desc = "锤炼属性"

function wnd_flyingEquipTrans:ctor()
	self._selectNum = 0
	self._selectEquip = nil
	self._isItemsEnough = {}
end

function wnd_flyingEquipTrans:configure()
	local vars = self._layout.vars
	self.equipSharpenBtn = vars.equip_sharpen_btn
	self.equipSharpenBtn:onClick(self, self.onEquipSharpenBtnClick)
	self.equipTransBtn = vars.equip_trans_btn
	self.equipTransBtn:stateToPressed()
	self.sharpen_all = vars.sharpen_all
	self.trans_all = vars.trans_all
	self.return_btn = vars.return_btn
	self.return_btn:onClick(self, self.onReturnBtnClick)
	self.return_btn:setVisible(false)
	self.closeBtn = vars.close_btn
	self.closeBtn:onClick(self, self.onCloseUI)
	self.refine_root = vars.refine_root
	self.propScroll = vars.propScroll
	self.sharpenScroll = vars.sharpenScroll
	self.itemlistview = vars.itemlistview
	self.transBtn = vars.transBtn
	self.transBtn:onClick(self, self.onTransBtnClick)
	self.equip_panel = vars.equip_panel
	for i = 1, equip_num do
		self['rank_icon' .. i] = vars['rank_icon' .. i]
		self['equip_icon' .. i] = vars['equip_icon' .. i]
		self['qh_level' .. i] = vars['qh_level' .. i]
		self['tips' .. i] = vars['tips' .. i]
		self['equip' .. i] = vars['equip' .. i]
		self['equip' .. i]:onClick(self, self.onEquipBtnClick, i)
	end
end

function wnd_flyingEquipTrans:refresh(index)
	self._selectNum = index and index or self._selectNum
	if self._selectNum == 0 then
		self._selectEquip = nil
		self.refine_root:setVisible(false)
		self.equip_panel:setVisible(true)
		self.return_btn:setVisible(false)
	else
		local equipData = g_i3k_game_context:GetWearEquips()
		self._selectEquip = equipData[self._selectNum + equip_offset].equip
		self.refine_root:setVisible(true)
		self.equip_panel:setVisible(false)
		self.return_btn:setVisible(true)
	end
	self:refreshAllRedPoint()
	self:refreshRefineRoot()
	self:refreshEquipPanel()
end

function wnd_flyingEquipTrans:refreshAllRedPoint()
	local equipData = g_i3k_game_context:GetWearEquips()
	local isSharpenAllVisible = g_i3k_game_context:isFlyingSharpenHaveRedPoint()
	self.sharpen_all:setVisible(isSharpenAllVisible)
	local isTransAllVisible = g_i3k_game_context:isFlyingTransHaveRedPoint()
	self.trans_all:setVisible(isTransAllVisible)
	for i = 1, equip_num do
		self['tips' .. i]:setVisible(false)
		self['qh_level' .. i]:setVisible(false)
		local equipInfo = equipData[i + equip_offset].equip
		if equipInfo then
			local consume = g_i3k_db.i3k_db_get_equip_trans_need_items(i3k_db_feisheng_misc.jingduanTransGroup, equipInfo.equip_id)
			self._isItemsEnough[i] = true
			for k, v in pairs(consume) do
				if v > g_i3k_game_context:GetCommonItemCanUseCount(k) then
					self._isItemsEnough[i] = false
					break
				end
			end
			local isSharpenMax = g_i3k_game_context:isFlyingEquipSharpenMax(equipInfo)
			local flyingLevel = g_i3k_game_context:getFlyingLevel()
			local transLevel = i3k_db_role_flying[flyingLevel].jingduanLevel
			if self._isItemsEnough[i] and isSharpenMax and transLevel > i3k_db_equips[equipInfo.equip_id].flyingLevel then
				self['tips' .. i]:setVisible(true)
			end
			self['qh_level' .. i]:setVisible(true)
			self['qh_level' .. i]:setText(i3k_db_feisheng_level[i3k_db_equips[equipInfo.equip_id].flyingLevel])
		end
	end
end

function wnd_flyingEquipTrans:refreshRefineRoot()
	if self._selectEquip == nil then
		return
	end
	self:setConsumeItems()
	self:setCurrentProp()
	self:setTransformProp()
end

function wnd_flyingEquipTrans:refreshEquipPanel()
	local equipData = g_i3k_game_context:GetWearEquips()
	for i = 1, equip_num do
		local equipInfo = equipData[i + equip_offset].equip
		if equipInfo then
			self['rank_icon' .. i]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equipInfo.equip_id))
			self['equip_icon' .. i]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equipInfo.equip_id, g_i3k_game_context:IsFemaleRole()))
		end
	end
end

function wnd_flyingEquipTrans:onEquipBtnClick(sender, index)
	local equipData = g_i3k_game_context:GetWearEquips()
	local equipInfo = equipData[index + equip_offset].equip
	self._selectEquip = nil
	local flyingLevel = g_i3k_game_context:getFlyingLevel()
	local transLevel = i3k_db_role_flying[flyingLevel].jingduanLevel
	if equipInfo and g_i3k_game_context:isFlyingEquipSharpenMax(equipInfo) and transLevel > i3k_db_equips[equipInfo.equip_id].flyingLevel then
		self._selectNum = index
		self._selectEquip = equipData[index + equip_offset].equip
		self:refresh()
	elseif equipInfo and transLevel <= i3k_db_equips[equipInfo.equip_id].flyingLevel then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1799, i3k_db_feisheng_level[i3k_db_equips[equipInfo.equip_id].flyingLevel]))
	elseif equipInfo then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1800))
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1798))
	end
end

function wnd_flyingEquipTrans:onEquipSharpenBtnClick(sender)
	g_i3k_ui_mgr:OpenAndRefresh(eUIID_FlyingEquipSharpen)
	g_i3k_ui_mgr:CloseUI(eUIID_FlyingEquipTrans)
end

function wnd_flyingEquipTrans:onReturnBtnClick(sender)
	self._selectEquip = nil
	self._selectNum = 0
	self:refresh()
end

function wnd_flyingEquipTrans:onTransBtnClick(sender)
	local equipID = self._selectEquip.equip_id
	if self._isItemsEnough[self._selectNum] and g_i3k_game_context:isFlyingEquipSharpenMax(self._selectEquip) then
		local equip = self._selectEquip
		i3k_sbean.equip_trans(equip.equip_id, equip.equip_guid, self.items, i3k_db_feisheng_misc.jingduanTransGroup)
	elseif self._isItemsEnough[self._selectNum] then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1800))
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1812))
	end
end

function wnd_flyingEquipTrans:setConsumeItems()
	if self._selectEquip == nil then
		return
	end
	local equipID = self._selectEquip.equip_id
	local groupID = i3k_db_feisheng_misc.jingduanTransGroup
	self.items = {}
	self.itemlistview:removeAllChildren()
	for i = 1, 3 do
		local itemId = i3k_db_equip_transform[groupID][math.abs(equipID)]["itemId"..i]
		if itemId ~= 0 then
			local itemCount = i3k_db_equip_transform[groupID][math.abs(equipID)]["itemCount"..i]
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
			else
				node.vars.itemCount:setTextColor(g_i3k_get_cond_color(true))
			end
			node.vars.suo:setVisible(itemId > 0)
			node.vars.name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemId)))
			node.vars.name:setText(g_i3k_db.i3k_db_get_common_item_name(itemId))
			node.vars.select_btn:onClick(self, self.onItem, itemId)
			self.itemlistview:addItem(node)
		end
	end
end

function wnd_flyingEquipTrans:setCurrentProp()
	if self._selectEquip == nil then
		return
	end
	local groupID = i3k_db_feisheng_misc.jingduanTransGroup
	local equipId = self._selectEquip.equip_id
	local equip_t = g_i3k_db.i3k_db_get_equip_item_cfg(equipId)
	local base_attribute = equip_t.properties
	local expect_attribute = equip_t.ext_properties
	local naijiu = self._selectEquip.naijiu
	local refine = self._selectEquip.refine
	local smeltingProps = self._selectEquip.smeltingProps
	local hammerSkill = self._selectEquip.hammerSkill
	self.propScroll:removeAllChildren()
	self:setBaseProp(nil, base_attribute, self.propScroll, naijiu)
	--附加属性
	if expect_attribute and type(expect_attribute) == "table" then
		for k,v in ipairs(expect_attribute) do
			if v.type ~= 0 then
				if k == 1 then
					local des = require(LAYER_ZBTIPST3)()
					des.vars.desc:setText(add_attribute_desc)
					self.propScroll:addItem(des)
				end
				local des = require(HUFUPROP)()
				local max = g_i3k_db.i3k_db_is_equip_ext_prop_sharpen_max(equipId, k, self._selectEquip.attribute[k])
				if max then
					des.vars.max_img:show()
				end
				if v.type == 1 then
					local _t = i3k_db_prop_id[v.args]
					local _desc = _t.desc
					des.vars.desc:setText(_desc)
					local value = self._selectEquip.attribute[k]
					des.vars.value:setText("+"..i3k_get_prop_show(v.args, value))
					self.propScroll:addItem(des)
				elseif v.type == 2 then
					local _t = i3k_db_skills[v.args]
					local name = _t.name
					name = name.."等级 +"
					des.vars.desc:setText(name)
					des.vars.value:setText("10")
					self.propScroll:addItem(des)
				elseif v.type == 3 then
					local _t = i3k_db_skills[v.args]
					local name = _t.name
					name = name.."CD -"
					des.vars.desc:setText(name)
					des.vars.value:setText("10")
					self.propScroll:addItem(des)
				elseif v.type == 4 then
					local _t = i3k_db_skills[v.args]
					local _desc= _t.desc
					des.vars.desc:setText(name)
					des.vars.value:setText("10")
					self.propScroll:addItem(_desc)
				end
			end
		end
	end
	self:setRefineProp(refine, self.propScroll)
	self:setTemperProp(smeltingProps, hammerSkill, self.propScroll, equipId)
end

function wnd_flyingEquipTrans:setTransformProp()
	if self._selectEquip == nil then
		return
	end
	local groupID = i3k_db_feisheng_misc.jingduanTransGroup
	local equipId = i3k_db_equip_transform[groupID][math.abs(self._selectEquip.equip_id)].newEquipId
	local equip_t = g_i3k_db.i3k_db_get_equip_item_cfg(equipId)
	local base_attribute = equip_t.properties
	local naijiu = self._selectEquip.naijiu
	local refine = self._selectEquip.refine
	local smeltingProps = self._selectEquip.smeltingProps
	local hammerSkill = self._selectEquip.hammerSkill
	local attribute_min = {}
	local attribute_max = {}
	local attribute_max_per = {}
	self.sharpenScroll:removeAllChildren()
	for i, j in ipairs(equip_t.ext_properties) do
		table.insert(attribute_min, j.minVal)
		table.insert(attribute_max, j.maxVal * TopRate[equip_t.partID])
		table.insert(attribute_max_per, j.maxVal)
	end
	self._layout.vars.equipBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equipId))
	self._layout.vars.equipIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equipId, g_i3k_game_context:IsFemaleRole()))
	self._layout.vars.equipName:setText(equip_t.name)
	self._layout.vars.lockImg:setVisible(true)
	self:setBaseProp(nil, base_attribute, self.sharpenScroll, naijiu)
	--附加属性
	if equip_t.ext_properties and type(equip_t.ext_properties) == "table" then
		for k,v in ipairs(equip_t.ext_properties) do
			if v.type ~= 0 then
				if k == 1 then
					local des = require(LAYER_ZBTIPST3)()
					des.vars.desc:setText(add_attribute_desc)
					self.sharpenScroll:addItem(des)
				end
				local des = require(HUFUPROP)()
				if v.type == 1 then
					local _t = i3k_db_prop_id[v.args]
					local _desc = _t.desc
					des.vars.desc:setText(_desc)
					local value_min = attribute_min[k] > self._selectEquip.attribute[k] and attribute_min[k] or self._selectEquip.attribute[k]
					local value_max = attribute_max[k] > self._selectEquip.attribute[k] and attribute_max[k] or self._selectEquip.attribute[k]
					local Threshold = i3k_db_common.equip.durability.Threshold
					if value_min == attribute_max_per[k] then
						des.vars.value:setText("+"..i3k_get_prop_show(v.args, value_min))
					else
						des.vars.value:setText("+"..i3k_get_prop_show(v.args, value_min).."~"..i3k_get_prop_show(v.args, value_max))
					end
					self.sharpenScroll:addItem(des)
				elseif v.type == 2 then
					local _t = i3k_db_skills[v.args]
					local name = _t.name
					name = name.."等级 +"
					des.vars.desc:setText(name)
					des.vars.value:setText("10")
					self.sharpenScroll:addItem(des)
				elseif v.type == 3 then
					local _t = i3k_db_skills[v.args]
					local name = _t.name
					name = name.."CD -"
					des.vars.desc:setText(name)
					des.vars.value:setText("10")
					self.sharpenScroll:addItem(des)
				elseif v.type == 4 then
					local _t = i3k_db_skills[v.args]
					local _desc= _t.desc
					des.vars.desc:setText(name)
					des.vars.value:setText("10")
					self.sharpenScroll:addItem(_desc)
				end
			end
		end
	end
	self:setRefineProp(refine, self.sharpenScroll)
	self:setTemperProp(smeltingProps, hammerSkill, self.sharpenScroll, equipId)
end

function wnd_flyingEquipTrans:setBaseProp(legends, base_attribute, scroll, naijiu)
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

function wnd_flyingEquipTrans:setRefineProp(refine, scroll)
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

function wnd_flyingEquipTrans:setTemperProp(smeltingProps, hammerSkill, scroll, equipID)
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

function wnd_flyingEquipTrans:onItem(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_flyingEquipTrans:transCallBack()
	local flyingLevel = g_i3k_game_context:getFlyingLevel()
	local transLevel = i3k_db_role_flying[flyingLevel].jingduanLevel
	if transLevel > i3k_db_equips[self._selectEquip.equip_id].flyingLevel + 1 then
		self:refresh()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1801))
		self:refresh(0)
	end
end

function wnd_create(layout)
	local wnd = wnd_flyingEquipTrans.new()
	wnd:create(layout)
	return wnd
end
