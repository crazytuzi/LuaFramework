
-------------------------------------------------------
module(..., package.seeall)
local require = require;
--local ui = require("ui/base");
local ui = require("ui/profile")

-------------------------------------------------------
wnd_battleDesertBag = i3k_class("wnd_battleDesertBag",ui.wnd_profile)

local BagColumn = g_DESEET_BAG_ROW_NUM

function wnd_battleDesertBag:ctor()
end

function wnd_battleDesertBag:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)

	self.battle_power = widgets.battle_power

	self:initDesertEquipWidget(widgets)

	self.hero_module = widgets.hero_module
	self.revolve = widgets.revolve
	self.revolve:onTouchEvent(self, self.onRotateBtn) --旋转模型
end

--初始化荒漠装备控件
function wnd_battleDesertBag:initDesertEquipWidget(widgets)
	self.desert_equip = {}
	for i = 1, #i3k_db_desert_battle_equip_part do
		local equip_btn = "equip" .. i
		local equip_icon = "equip_icon" .. i
		local grade_icon = "grade_icon" .. i
		local is_select = "is_select" .. i

		self.desert_equip[i] = {
			equip_btn = widgets[equip_btn],
			equip_icon = widgets[equip_icon],
			grade_icon = widgets[grade_icon],
			is_select = widgets[is_select],
		}
	end
end

function wnd_battleDesertBag:refresh()
	self:updateEquipUI()
	self:updateHeroModel()
	self:updateBagScroll()
end

function wnd_battleDesertBag:updateEquipUI()
	local equipData = g_i3k_game_context:GetDesertBattleEquipData()
	for i, v in ipairs(self.desert_equip) do
		local equipID = equipData[i]
		if equipID then
			v.equip_btn:enable()
			v.equip_icon:show()
			v.equip_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equipID, g_i3k_game_context:IsFemaleRole()))
			v.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equipID))
			v.equip_btn:onClick(self, self.onSelectEquip, {partID = i, id = equipID, isBag = false})
		else
			v.equip_btn:disable()
			v.equip_icon:hide()
			v.grade_icon:setImage(g_i3k_get_icon_frame_path_by_pos(i))
		end
		v.is_select:hide()
	end
	self:setBattlePower()
end

--选择装备
function wnd_battleDesertBag:onSelectEquip(sender, data)
	if not data.isBag then
		for i, v in ipairs(self.desert_equip) do
			v.is_select:setVisible(i == data.partID)
		end
	end
	g_i3k_ui_mgr:OpenUI(eUIID_BattleDesertEquipTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_BattleDesertEquipTips, data)
end

--选择道具
function wnd_battleDesertBag:onSelectItem(sender, id)
	g_i3k_ui_mgr:OpenUI(eUIID_BattleDesertItemTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_BattleDesertItemTips, id)
end

function wnd_battleDesertBag:updateHeroModel()
	local curHero = g_i3k_game_context:getBattleDesertCurHero()
	local modelID = i3k_db_desert_generals[curHero].modelID
	self:setModel(modelID)
end

function wnd_battleDesertBag:setModel(id)
	local path = i3k_db_models[id].path
	local uiscale = i3k_db_models[id].uiscale
	self.hero_module:setSprite(path)
	self.hero_module:setSprSize(uiscale)
	self.hero_module:setRotation(math.pi/2)
	self.hero_module:playAction("stand")
end

function wnd_battleDesertBag:updateBagScroll()
	local widgets = self._layout.vars

	local bagItems = g_i3k_game_context:GetDesertBattleBagItems()
	local sortItems = self:sortBagItems(bagItems)

	local allBars = widgets.scroll:addChildWithCount("ui/widgets/juezhanhuangmobgt", BagColumn, #sortItems)
	for i, v in ipairs(allBars) do
		local id = sortItems[i].id
		local count = sortItems[i].count

		local itemType = g_i3k_db.i3k_db_get_common_item_type(id)
		if itemType == g_COMMON_ITEM_TYPE_DESERT_EQUIP then
			self:updateEquipCell(v.vars, sortItems[i])
		elseif itemType == g_COMMON_ITEM_TYPE_DESERT_ITEM then
			self:updateItemCell(v.vars, sortItems[i])
		end
	end
end

function wnd_battleDesertBag:updateEquipCell(widgets, data)
	local id = data.id
	local count = data.count

	local equipCfg = g_i3k_db.i3k_db_get_desert_equip_item_cfg(id)

	widgets.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widgets.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
	widgets.item_count:setText(count)
	widgets.suo:setVisible(id > 0)
	widgets.bt:onClick(self, self.onSelectEquip, {partID = equipCfg.part, id = id, isBag = true})

	local isEnough = g_i3k_game_context:isEquipEnoughRoleType(equipCfg)
	widgets.is_show:setVisible(not isEnough)

	local wEquip = g_i3k_game_context:GetDesertBattleEquipData()
	local equipID = wEquip[equipCfg.part]
	if equipID then
		local power = math.modf(g_i3k_game_context:GetOneDesertEquipFightPower(id))
		local wPower = math.modf(g_i3k_game_context:GetOneDesertEquipFightPower(equipID))
		widgets.isUp:show()
		if wPower > power then
			widgets.isUp:setImage(g_i3k_db.i3k_db_get_icon_path(175))
		elseif wPower < power then
			widgets.isUp:setImage(g_i3k_db.i3k_db_get_icon_path(174))
		else
			widgets.isUp:hide()
		end
	else
		widgets.isUp:show()
		widgets.isUp:setImage(g_i3k_db.i3k_db_get_icon_path(174))
	end
	if not isEnough then
		widgets.isUp:hide()
	end
end

function wnd_battleDesertBag:updateItemCell(widgets, data)
	local id = data.id
	local count = data.count

	widgets.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widgets.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
	widgets.item_count:setText(count)
	widgets.suo:setVisible(id > 0)
	widgets.bt:onClick(self, self.onSelectItem, id)

	widgets.is_show:hide()
	widgets.isUp:hide()
end

--背包物品排序
function wnd_battleDesertBag:sortBagItems(items)
	local result = {}
	for id, count in pairs(items) do
		table.insert(result, {id = id, count = count, sortid = g_i3k_db.i3k_db_get_bag_item_order(id)})
	end
	table.sort(result, function(a, b)
		return a.sortid < b.sortid
	end)
	return result
end

--设置角色战力
function wnd_battleDesertBag:setBattlePower()
	local widgets = self._layout.vars
	local power = g_i3k_game_context:GetDesertRoleFightPower()
	self.battle_power:setText(power)
end

function wnd_create(layout, ...)
	local wnd = wnd_battleDesertBag.new()
	wnd:create(layout, ...)
	return wnd;
end

