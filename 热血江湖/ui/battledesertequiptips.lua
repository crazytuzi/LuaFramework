
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_battleDesertEquipTips = i3k_class("wnd_battleDesertEquipTips",ui.wnd_base)

local LAYER_ZBTIPST = "ui/widgets/juezhanhuangmozbtipst1"   --属性
local LAYER_ZBTIPST2 = "ui/widgets/juezhanhuangmozbtipst2"  --标题
local LAYER_ZBTIPST3 = "ui/widgets/juezhanhuangmozbtipst3"  --心法说明

local compare_icon = {
	174,
	175,
	176,
}

function wnd_battleDesertEquipTips:ctor()
	self.id = nil
	self.leftPower = 0
	self.wEquipID = nil
end

function wnd_battleDesertEquipTips:configure()
	local widgets = self._layout.vars
	widgets.globel_bt:onClick(self, self.onCloseUI)

	--销毁
	widgets.btn1:onClick(self, self.onDestroyItem)
end

function wnd_battleDesertEquipTips:refresh(data)
	local widgets = self._layout.vars
	self.id = data.id

	local wEquip = g_i3k_game_context:GetDesertBattleEquipData()
	local equipCfg = g_i3k_db.i3k_db_get_desert_equip_item_cfg(data.id)

	local wEquipID = wEquip[equipCfg.part]
	self.wEquipID = wEquipID

	if wEquipID and data.isBag then
		widgets.layer2:show()
		self:setEquipTips({id = wEquipID})
	else
		widgets.layer2:hide()
	end

	self:setBagTips({id = data.id})

	self:updateBtnState(data)
	self:updateBtnEvent(data)
end

function wnd_battleDesertEquipTips:updateBtnState(data)
	local widgets = self._layout.vars
	widgets.btn1:setVisible(data.isBag)
	widgets.btn2:show()
end

function wnd_battleDesertEquipTips:updateBtnEvent(data)
	local widgets = self._layout.vars
	if not data.isBag then
		widgets.label2:setText(i3k_get_string(1524))
		widgets.btn2:onClick(self, self.onUnWear)
	else
		if self.wEquipID then
			widgets.label2:setText(i3k_get_string(1526))
		else
			widgets.label2:setText(i3k_get_string(1527))
		end
		widgets.btn2:onClick(self, self.onWear)
	end
end

--装备内容
function wnd_battleDesertEquipTips:setEquipTips(data)
	local widgets = self._layout.vars
	local id = data.id

	local equipCfg = g_i3k_db.i3k_db_get_desert_equip_item_cfg(id)
	local roleType = equipCfg.roleType
	local partID = equipCfg.part

	local name = g_i3k_db.i3k_db_get_common_item_name(id)
	widgets.equip_name2:setText(name)
	widgets.equip_name2:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(id)))
	widgets.equip_bg2:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widgets.equip_icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
	widgets.role2:setText(i3k_db_desert_battle_equip_roleType[roleType])
	widgets.role2:setTextColor(g_i3k_get_cond_color(true))
	widgets.part2:setText(i3k_db_desert_battle_equip_part[partID])

	local basePower = math.modf(g_i3k_game_context:GetOneDesertEquipFightPower(id))
	widgets.power_value2:setText(basePower)

	self.leftPower = basePower

	widgets.get_label2:hide()
	widgets.level2:hide()

	widgets.scroll2:removeAllChildren()
	self:setPropScroll(widgets.scroll2, {equipCfg = equipCfg})
end

--背包内容
function wnd_battleDesertEquipTips:setBagTips(data)
	local widgets = self._layout.vars
	local id = data.id

	local equipCfg = g_i3k_db.i3k_db_get_desert_equip_item_cfg(id)
	local roleType = equipCfg.roleType
	local partID = equipCfg.part

	local name = g_i3k_db.i3k_db_get_common_item_name(id)
	widgets.equip_name1:setText(name)
	widgets.equip_name1:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(id)))
	widgets.equip_bg1:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widgets.equip_icon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
	widgets.role1:setText(i3k_db_desert_battle_equip_roleType[roleType])
	local myRoleType = g_i3k_game_context:getBattleDesertCurHero()
	widgets.role1:setTextColor(g_i3k_get_cond_color(roleType == 0 or roleType == myRoleType))
	widgets.part1:setText(i3k_db_desert_battle_equip_part[partID])

	local basePower = math.modf(g_i3k_game_context:GetOneDesertEquipFightPower(id))
	widgets.power_value1:setText(basePower)

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

	widgets.scroll:removeAllChildren()
	self:setPropScroll(widgets.scroll, {equipCfg = equipCfg})
end

function wnd_battleDesertEquipTips:setPropScroll(scroll, data)
	self:setBasePropScroll(scroll, data)
	self:setAdditionalPropScroll(scroll, data)
	self:setXinfaScroll(scroll, data)
end

function wnd_battleDesertEquipTips:setBasePropScroll(scroll, data)
	local equipCfg = data.equipCfg
	if next(equipCfg.baseProp) then
		local header = require(LAYER_ZBTIPST2)()
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

function wnd_battleDesertEquipTips:setAdditionalPropScroll(scroll, data)
	local equipCfg = data.equipCfg
	if next(equipCfg.additionalProp) then
		local header = require(LAYER_ZBTIPST2)()
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

function wnd_battleDesertEquipTips:setXinfaScroll(scroll, data)
	local equipCfg = data.equipCfg
	if equipCfg.xinfaType == 0 then
		return
	end

	local equipXinfaID = g_i3k_db.i3k_db_get_desert_xinfaID_by_xinfaType(equipCfg.xinfaType)
	if equipXinfaID then
		local header = require(LAYER_ZBTIPST2)()
		header.vars.desc:setText(i3k_get_string(17645))
		scroll:addItem(header)

		local ui = require(LAYER_ZBTIPST3)()
		local xinfaCfg = i3k_db_desert_battle_xinfa_cfg[equipXinfaID]
		
		local needCnt = #xinfaCfg.xinfaType
		local nowCnt = g_i3k_db.i3k_db_get_desert_enough_xinfa_count(equipXinfaID)
		local str = string.format("(%s/%s)", nowCnt, needCnt)
		
		ui.vars.desc:setText(xinfaCfg.desc .. str)
		scroll:addItem(ui)
	end
end

--装备/更换
function wnd_battleDesertEquipTips:onWear(sender)
	local equips = {}
	local equipCfg = g_i3k_db.i3k_db_get_desert_equip_item_cfg(self.id)
	local partID = equipCfg.part
	equips[partID] = self.id

	local isEnough = g_i3k_game_context:isEquipEnoughRoleType(equipCfg)
	if not isEnough then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17646))
	end

	local needWearEquipCnt = g_i3k_game_context:GetDesertBattleItemCount(self.id)
	local oldEquips = g_i3k_game_context:GetDesertBattleEquipData()
	local oldEquipID = oldEquips[partID]
	--更换装备时，如果需要更换的装备数量大于1，则需要判断背包是否满
	if oldEquipID and needWearEquipCnt > 1 then
		local getItems = {}
		getItems[oldEquipID] = 1
		if not g_i3k_game_context:IsDesertBagEnough(getItems) then
			return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1481))
		end
	end

	i3k_sbean.survive_equip_upwear(equips)
end

--卸下
function wnd_battleDesertEquipTips:onUnWear(sender)
	local equipCfg = g_i3k_db.i3k_db_get_desert_equip_item_cfg(self.id)
	local partID = equipCfg.part

	local getItems = {}
	getItems[self.id] = 1
	if not g_i3k_game_context:IsDesertBagEnough(getItems) then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1481))
	end

	i3k_sbean.survive_equip_downwear(partID)
end

--销毁
function wnd_battleDesertEquipTips:onDestroyItem(sender)
	local itemName = g_i3k_db.i3k_db_get_common_item_name(self.id)
	local desc = i3k_get_string(17625, itemName)
	local fun = (function(ok)
		if ok then
			local items = {}
			local _t = i3k_sbean.DummyGoods.new()
			_t.id = self.id
			_t.count = g_i3k_game_context:GetDesertBattleItemCount(self.id)
			table.insert(items, _t)

			i3k_sbean.survive_destoryitems(items)
		end
	end)
	g_i3k_ui_mgr:ShowMessageBox2(desc, fun)
end

function wnd_create(layout, ...)
	local wnd = wnd_battleDesertEquipTips.new()
	wnd:create(layout, ...)
	return wnd;
end

