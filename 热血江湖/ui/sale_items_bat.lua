-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_sale_items_bat = i3k_class("wnd_sale_items_bat",ui.wnd_base)

local RowitemCount = 5
local WIDGETS_PLCST	= "ui/widgets/plcst"
local WIDGETS_DJ	= "ui/widgets/dj1"

local ITEM_TYPE_ICON = {g_BASE_ITEM_EQUIP_ENERGY, g_BASE_ITEM_GEM_ENERGY, g_BASE_ITEM_BOOK_ENERGY, g_BASE_ITEM_COIN}
local Empty_Cell = {}
local SHOW_TIME = 3 --tips显示时间
local DEFAULT_COUNT = 25 --默认格子数

local DESC = {g_SaleBat_Equip_Desc, g_SaleBat_Gem_Desc, g_SaleBat_Book_Desc, g_SaleBat_Other_Desc}

function wnd_sale_items_bat:ctor()
	self.showType = 1 --1.装备 2.宝石 3.心法 4.杂物
	self.total_count = 0
	self.isSelectBlue = true --是否可以选择蓝色
	self.isSelectAll = true --是否可以全选
	self.sale_items_changed = false --是否可以刷新
	self.record_time = 0 --记录时间
end

function wnd_sale_items_bat:configure()
	local widget = self._layout.vars
	self.select_all = widget.select_all
	self.select_blue = widget.select_blue
	self.select_blue:onClick(self, self.onSelectBlueButton)
	self.select_all:onClick(self, self.onSelectAllButton)

	widget.sale:onClick(self, self.onSaleButton)
	widget.close:onClick(self, self.onCloseButton)

	self.saleItemTypeButton = {widget.equip_btn, widget.diamond_btn, widget.xinfa_btn}
	self.saleItemTypeButton[1]:stateToPressed(true)
	for i, e in ipairs(self.saleItemTypeButton) do
		e:onClick(self, self.onShowTypeChanged, i)
	end

	self.suo = widget.suo
	self.money_icon = widget.money_icon
	self.blue_icon = widget.blue_icon
	self.diamond_lable = widget.diamond_lable
	self.money_lable = widget.money_lable

	self.scroll = widget.scroll
	self.item_scroll = widget.item_scroll
	self.get_desc = widget.get_desc
	self.type_desc = widget.type_desc
	self.no_item = widget.no_item
end

function wnd_sale_items_bat:setSaleShowType(showType)
	if self.showType ~= showType then
		local str = showType == 3 and "选中非本职业气功" or "选中蓝色及以下物品"
		self._layout.vars.tips:setText(str)
		self.showType = showType
		for i, e in ipairs(self.saleItemTypeButton) do
			e:stateToNormal(true)
		end
		self.isSelectAll = true
		self.isSelectBlue = true
		self:rightDefaultCellUI()
		self.saleItemTypeButton[showType]:stateToPressed(true)
		self:updateScroll(g_i3k_game_context:GetBagInfo())
		self.suo:setVisible(showType == 4)
		self.money_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(ITEM_TYPE_ICON[showType],i3k_game_context:IsFemaleRole()))
		self.blue_icon:hide()
		self.total_count = 0
		self.diamond_lable:setText(self.total_count)
		self.type_desc:show()
		self.get_desc:setText(i3k_get_string(DESC[showType]))
		self.record_time = i3k_game_get_time()
		if self.showType == 3 then
			self:onSelectBlueButton()
		end
	end
end

function wnd_sale_items_bat:rightDefaultCellUI()
	self.item_scroll:removeAllChildren()
	self:updateItemScroll(Empty_Cell)
end

function wnd_sale_items_bat:onShowTypeChanged(sender, tag)
	self:setSaleShowType(tag)
end

function wnd_sale_items_bat:refresh()
	self.record_time = i3k_game_get_time()
	self.get_desc:setText(i3k_get_string(DESC[1]))
	self:updateScroll(g_i3k_game_context:GetBagInfo())
	self.diamond_lable:setText(self.total_count)
	self.suo:hide()
	self.money_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(ITEM_TYPE_ICON[self.showType],i3k_game_context:IsFemaleRole()))
	self:updateItemScroll(Empty_Cell)
end

function wnd_sale_items_bat:checkSaleQualify(id)	
	local itype = g_i3k_db.i3k_db_get_common_item_type(id)
	if itype == g_COMMON_ITEM_TYPE_EQUIP then
		return true
	elseif itype == g_COMMON_ITEM_TYPE_GEM then
		return math.abs(id % 100) < g_GEM_SALE_CONFIRM_LEVEL
	elseif itype == g_COMMON_ITEM_TYPE_BOOK then
		return true
	elseif itype == g_COMMON_ITEM_TYPE_ITEM then
		return true
	end
end
function wnd_sale_items_bat:updateScroll(bagSize, BagItems)
	self.scroll:removeAllChildren()
	self.scroll:setContainerSize(0, 0)
	local items = self:itemSort(BagItems)
	for i,e in ipairs(items) do
		if self.showType == self:getSaleItemShowType(e.id) and self:checkSaleQualify(e.id) then
			if g_i3k_db.i3k_db_get_common_item_sell_count(e.id) ~= 0 then
				local stack_count = g_i3k_db.i3k_db_get_bag_item_stack_max(e.id)
				local cell_count = g_i3k_get_use_bag_cell_size(e.count, stack_count)
				for k=1,cell_count do
					local plcst = require(WIDGETS_PLCST)()
					local widget = plcst.vars
					local itemCount = k == cell_count and e.count-(cell_count-1)*stack_count or stack_count
					self:updateScrollWidget(widget, e.id, itemCount, e.guids[k])
					local equip = g_i3k_game_context:GetBagEquip(e.id, e.guids[k])
					if equip then --是否为装备
						local partID = g_i3k_db.i3k_db_get_equip_item_cfg(e.id).partID
						if equip.naijiu == -1 and partID ~= eEquipArmor and partID ~= eEquipSymbol then --不是传世装备
							self.scroll:addItem(plcst)
						end
					else
						self.scroll:addItem(plcst)
					end
				end
			end
		end
	end
	local all_widget = self.scroll:getAllChildren()
	self.no_item:setVisible(all_widget[1]==nil)
	self.sale_items_changed = false
end

function wnd_sale_items_bat:updateScrollWidget(widget, id, count, guid)
	widget.select_icon2:hide()
	widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
	local item_rank = g_i3k_db.i3k_db_get_common_item_rank(id)
	local name = g_i3k_make_color_string(g_i3k_db.i3k_db_get_common_item_name(id), g_i3k_get_color_by_rank(item_rank))
	local Xcount = string.format("x%s", count)
	local countStr = g_i3k_make_color_string(Xcount, g_i3k_get_white_color())
	local str = string.format("%s %s", name, countStr)
	widget.item_name:setText(str)
	widget.item_level:setVisible(guid~=nil)
	widget.power_value:setVisible(guid~=nil)
	if guid ~= nil then
		local str2 = string.format("战力:")
		local power_desc = g_i3k_make_color_string(str2, g_i3k_get_red_color())
		widget.item_level:setText(power_desc)
		widget.power_value:setText(self:GetEquipPower(id, guid))
	end
	widget.item_suo:setVisible(id>0)
	widget.money:setText(g_i3k_db.i3k_db_get_common_item_sell_count(id))
	widget.item_grade:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widget.suo:setVisible(self.showType == 4)
	widget.little_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(ITEM_TYPE_ICON[self.showType],i3k_game_context:IsFemaleRole()))
	widget.itemTips_btn:onClick(self, guid and self.onSelectLeftEquip or self.onSelectLeftItem, {id = id, guid = guid})
	widget.id = id
	widget.count = count
	widget.guid = guid
	widget.isCanSelect = true
	widget.select:onClick(self, self.isSelectItem, widget)
end

function wnd_sale_items_bat:GetEquipPower(id, guid)
	local equipCfg = g_i3k_game_context:GetBagEquip(id, guid)
	return math.modf(g_i3k_game_context:GetBagEquipPower(id, g_i3k_get_equip_attributes(equipCfg), g_i3k_get_equip_durability(equipCfg), equipCfg.refine, equipCfg.legends, equipCfg.smeltingProps))
end

function wnd_sale_items_bat:onSelectLeftItem(sender, data)
	g_i3k_ui_mgr:ShowCommonItemInfo(data.id)
end

function wnd_sale_items_bat:onSelectLeftEquip(sender, args)
	g_i3k_ui_mgr:ShowCommonEquipInfo(g_i3k_game_context:GetBagEquip(args.id, args.guid))
end

function wnd_sale_items_bat:onItemTips(sender, data)
	self:setCellIsSelectHide()
	data.is_select:show()
	g_i3k_ui_mgr:ShowCommonItemInfo(data.id)
end

function wnd_sale_items_bat:onEquipTips(sender, args)
	self:setCellIsSelectHide()
	args.is_select:show()
	g_i3k_ui_mgr:ShowCommonEquipInfo(g_i3k_game_context:GetBagEquip(args.id, args.guid))
end

function wnd_sale_items_bat:setCellIsSelectHide()
	for i, e in ipairs(self.item_scroll:getAllChildren()) do
		e.vars.is_select:hide()
	end
end

function wnd_sale_items_bat:getSelectItemData()
	local select_item = {}
	for i, e in ipairs(self.scroll:getAllChildren()) do
		local widget = e.vars
		if not widget.isCanSelect then
			local item = self:setItemData(widget)
			if select_item[widget.id] then
				select_item[widget.id].count = select_item[widget.id].count + item.count
				if self:GetEquipCount(item.equips) ~= 0 then
					select_item[widget.id].equips[widget.guid] = true
				end
			else
				select_item[widget.id] = item
			end
		end
	end
	return select_item
end

function wnd_sale_items_bat:setItemData(widget)
	local item_data = {id = widget.id, count = widget.count}
	if widget.guid ~= nil then
		item_data.equips = {[widget.guid] = true}
	else
		item_data.equips = {}
	end
	return item_data
end

function wnd_sale_items_bat:isSelectItem(sender, widget)
	widget.select_icon2:setVisible(widget.isCanSelect)
	if widget.isCanSelect then
		widget.isCanSelect = false
		self.total_count = self.total_count + g_i3k_db.i3k_db_get_common_item_sell_count(widget.id) * widget.count
	else
		self.total_count = self.total_count - g_i3k_db.i3k_db_get_common_item_sell_count(widget.id) * widget.count
		widget.isCanSelect = true
	end
	self.diamond_lable:setText(self.total_count)
	local item = self:getSelectItemData()
	self:updateItemScroll(item)
	self.isSelectAll = true
	self.isSelectBlue = true
end

function wnd_sale_items_bat:updateItemScroll(selectItem)
	self.item_scroll:jumpToListPercent(0)
	if not self.isSelectAll then
		self.item_scroll:removeAllChildren()
	elseif not self.isSelectBlue then
		self.item_scroll:removeAllChildren()
	end
	local items = self:itemSort(selectItem)
	local totalItem = self:getCellCount(items)
	local cellCount = totalItem < DEFAULT_COUNT and DEFAULT_COUNT or math.ceil(totalItem/RowitemCount)*RowitemCount
	local all_layer = self.item_scroll:addChildWithCount(WIDGETS_DJ, RowitemCount, cellCount)
	local cell_index = 1
	for i,e in ipairs(items) do
		local stack_count = g_i3k_db.i3k_db_get_bag_item_stack_max(e.id)
		local cell_count = g_i3k_get_use_bag_cell_size(e.count, stack_count)
		for k=1,cell_count do
			local widget = all_layer[cell_index].vars
			local itemCount = k == cell_count and e.count-(cell_count-1)*stack_count or stack_count
			self:updateCell(widget, e.id, itemCount, e.guids[k])
			self:setUpIsShow(e.id, e.guids[k], widget)
			cell_index = cell_index + 1
		end
	end
	for k = cell_index, cellCount do --显示空格
		if k > totalItem then
			local widget = all_layer[k].vars
			self:updateCell(widget, 0, 0, nil)
		end
	end
end

function wnd_sale_items_bat:getCellCount(items)
	local count = 0
	for i,e in ipairs(items) do
		count = count +  g_i3k_get_use_bag_cell_size(e.count, g_i3k_db.i3k_db_get_bag_item_stack_max(e.id))
	end
	return count
end

function wnd_sale_items_bat:updateCell(widget, id, count, guid)
	widget.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
	widget.item_count:setText(count)
	if guid or count <= 0 then
		widget.item_count:hide()
		self:setMaskIsShow(id, widget)
	else
		widget.item_count:show()
	end
	widget.suo:setVisible(id>0)
	if id == 0 then
		widget.bt:disable()
	end
	widget.bt:onClick(self, guid and self.onEquipTips or self.onItemTips, {is_select = widget.is_select, id = id, guid = guid})
end

function wnd_sale_items_bat:setMaskIsShow(id, widget)
	if g_i3k_db.i3k_db_get_common_item_type(id) == g_COMMON_ITEM_TYPE_EQUIP then
		if g_i3k_db.i3k_db_check_equip_level(id) then
			widget.is_show:hide()
		else
			local equip_cfg = g_i3k_db.i3k_db_get_equip_item_cfg(id)
			local bwType = g_i3k_game_context:GetTransformBWtype()
			local isSameBwType = equip_cfg.M_require == 0 or equip_cfg.M_require == bwType
			if equip_cfg.roleType == 0 and g_i3k_game_context:GetLevel() >= equip_cfg.levelReq then--装备全系,不分职业
				widget.is_show:hide()
			elseif g_i3k_game_context:GetRoleType() ~= equip_cfg.roleType or not isSameBwType then
				widget.is_show:show()
			else
				if equip_cfg.C_require ~= 0 then
					widget.is_show:setVisible(g_i3k_game_context:GetTransformLvl() < equip_cfg.C_require)
				else
					widget.is_show:hide()
				end
			end
		end
	end
end

function wnd_sale_items_bat:setUpIsShow(id, guid, widget)
	if g_i3k_db.i3k_db_get_common_item_type(id) == g_COMMON_ITEM_TYPE_EQUIP and guid then
		local equip_cfg = g_i3k_db.i3k_db_get_equip_item_cfg(id)
		local bwType = g_i3k_game_context:GetTransformBWtype()
		local isSameBwType = equip_cfg.M_require == 0 or equip_cfg.M_require == bwType
		if (g_i3k_game_context:GetRoleType() == equip_cfg.roleType or equip_cfg.roleType == 0) and isSameBwType  then
			local equip = g_i3k_game_context:GetBagEquip(id, guid)
			local wearEquips = g_i3k_game_context:GetWearEquips()
			local _data = wearEquips[equip_cfg.partID].equip
			if _data and equip then
				local wAttribute = _data.attribute
				local wNaijiu = _data.naijiu
				local wEquip_id = _data.equip_id
				local wPower = g_i3k_game_context:GetBagEquipPower(wEquip_id,wAttribute,wNaijiu,_data.refine,_data.legends, _data.smeltingProps)
				local total_power = g_i3k_game_context:GetBagEquipPower(id,equip.attribute,equip.naijiu,equip.refine,equip.legends, equip.smeltingProps)
				widget.isUp:show()
				if wPower > total_power then
					widget.isUp:setImage(g_i3k_db.i3k_db_get_icon_path(175))
				elseif wPower < total_power then
					widget.isUp:setImage(g_i3k_db.i3k_db_get_icon_path(174))
				else
					widget.isUp:hide()
				end
			else
				widget.isUp:show()
				widget.isUp:setImage(g_i3k_db.i3k_db_get_icon_path(174))
			end
		else
			widget.isUp:hide()
		end
	end
end

function wnd_sale_items_bat:getSaleItemShowType(id)
	local itype = g_i3k_db.i3k_db_get_common_item_type(id)
	if itype == g_COMMON_ITEM_TYPE_EQUIP then
		return 1
	elseif itype == g_COMMON_ITEM_TYPE_GEM then
		return 2
	elseif itype == g_COMMON_ITEM_TYPE_BOOK then
		return 3
	elseif itype == g_COMMON_ITEM_TYPE_ITEM then
		return 4
	end
end

function wnd_sale_items_bat:itemSort(items)
	local sort_items = {}
	for k,v in pairs(items) do
		local guids = {}
		local sorit = g_i3k_db.i3k_db_get_bag_item_order(k)
		for kk, vv in pairs(v.equips) do
			table.insert(guids, kk)
		end
		table.insert(sort_items, { sortid = g_i3k_db.i3k_db_get_bag_item_order(k), id = v.id, count = v.count, guids = guids})
	end
	table.sort(sort_items,function (a,b)
		return a.sortid < b.sortid
	end)
	return sort_items
end

function wnd_sale_items_bat:onCloseButton(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_SaleItemBat)
end

function wnd_sale_items_bat:onSelectBlueButton(sender)
	self.isSelectAll = true
	self.blue_icon:setVisible(self.isSelectBlue)
	local temp = {}
	self.total_count = 0
	if self.isSelectBlue then
		self:updateScroll(g_i3k_game_context:GetBagInfo())
		for i, e in ipairs(self.scroll:getAllChildren()) do
			local widget = e.vars
			local db = g_i3k_db.i3k_db_get_common_item_cfg(widget.id);
			local selectType = self.showType == 3 and g_i3k_game_context:getValidXinfabookItemList(widget.id) or g_i3k_db.i3k_db_get_common_item_rank(widget.id) <= g_RANK_VALUE_BLUE
			if selectType and (not db.partID and true or i3k_db_common.equip.equipPropPart[db.partID]) then
				self.total_count = self.total_count + g_i3k_db.i3k_db_get_common_item_sell_count(widget.id) * widget.count
				local item = self:setItemData(widget)
				if temp[widget.id] then
					temp[widget.id].count = temp[widget.id].count + item.count
					if self:GetEquipCount(item.equips) ~= 0 then
						temp[widget.id].equips[widget.guid] = true
					end
				else
					temp[widget.id] = item
				end
				widget.isCanSelect = false
				widget.select_icon2:show()
			end
		end
		self:updateItemScroll(temp)
		self.isSelectBlue = false
	else
		for i, e in ipairs(self.scroll:getAllChildren()) do
			local widget = e.vars
			widget.isCanSelect = true
			widget.select_icon2:hide()
		end
		self:rightDefaultCellUI()
		self.isSelectBlue = true
	end
	self.diamond_lable:setText(self.total_count)
end

function wnd_sale_items_bat:GetEquipCount(equips)
	local count = 0
	for a,b in pairs(equips) do
		if a then
			count = count + 1
		end
	end
	return count
end

function wnd_sale_items_bat:onSelectAllButton(sender)
	self.isSelectBlue = true
	self.blue_icon:hide()
	local temp = {}
	self.total_count = 0
	if self.isSelectAll then
		self:updateScroll(g_i3k_game_context:GetBagInfo())
		for i, e in ipairs(self.scroll:getAllChildren()) do
			local widget = e.vars
			self.total_count = self.total_count + g_i3k_db.i3k_db_get_common_item_sell_count(widget.id) * widget.count
			local item = self:setItemData(widget)
			if temp[widget.id] then
				temp[widget.id].count = temp[widget.id].count + item.count
				if self:GetEquipCount(item.equips) ~= 0 then
					temp[widget.id].equips[widget.guid] = true
				end
			else
				temp[widget.id] = item
			end
			widget.isCanSelect = false
			widget.select_icon2:show()
		end
		self:updateItemScroll(temp)
		self.isSelectAll = false
	else
		for i, e in ipairs(self.scroll:getAllChildren()) do
			local widget = e.vars
			widget.isCanSelect = true
			widget.select_icon2:hide()
		end
		self:rightDefaultCellUI()
		self.isSelectAll = true
		self.total_count = 0
	end
	self.diamond_lable:setText(self.total_count)
end

function wnd_sale_items_bat:onSaleButton(sender)
	local _temp = {}
	local sale_item = self:getSelectItemData()
	if next(sale_item) == nil then
		self.isSelectBlue = true
		self.blue_icon:hide()
		return
	end
	for i, e in pairs(sale_item) do
		local _t = i3k_sbean.DummyGoods.new()
		local _equip = i3k_sbean.KinEquips.new()
		local equip_guid = nil
		for k, v in pairs(e.equips) do
			equip_guid = k
		end
		if equip_guid then
			_equip.id = e.id
			_equip.guids = e.equips
			_temp[e.id] = _equip
		else
			_t.id = e.id
			_t.count = e.count
			table.insert(_temp,_t)
		end
	end
	if self.showType == 1 then
		i3k_sbean.bag_batchsellequips(_temp)
	elseif self.showType == 2 then
		i3k_sbean.bag_batchsellgems(_temp)
	elseif self.showType == 3 then
		i3k_sbean.bag_batchsellbooks(_temp)
	elseif self.showType == 4 then
		i3k_sbean.bag_batchsellitems(_temp)
	end
	self.isSelectBlue = true
	self.blue_icon:hide()
	self.total_count = 0
	self.diamond_lable:setText(self.total_count)
end

function wnd_sale_items_bat:onUpdate(dTime)
	if i3k_game_get_time() - self.record_time >  SHOW_TIME then
		self.type_desc:hide()
	end

	if self.sale_items_changed then
		self:updateScroll(g_i3k_game_context:GetBagInfo())
		self:rightDefaultCellUI()
	end
end

function wnd_sale_items_bat:setSaleItemsChanged()
	self.sale_items_changed = true
end

function wnd_create(layout)
	local wnd = wnd_sale_items_bat.new()
		wnd:create(layout)
	return wnd
end
