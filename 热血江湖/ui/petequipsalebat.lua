
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_petEquipSaleBat = i3k_class("wnd_petEquipSaleBat",ui.wnd_base)

local WIDGETS_LEFT	= "ui/widgets/plcst"
local WIDGETS_RIGHT= "ui/widgets/plcst2"

local RowitemCount = 5
local DEFAULT_COUNT = 25 --默认格子数
local SHOW_TIME = 3 --tips显示时间

local SHANYUANZHIID = 7824
local SORTBASE = 1000000


function wnd_petEquipSaleBat:ctor()
	self.total_count = 0
	self.isCanSelectBlue = true --是否可以选择蓝色
	self.isCanSelectAll = true --是否可以全选
	self.record_time = 0
	self.showflag = true
end

function wnd_petEquipSaleBat:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)
	widgets.select_blue:onClick(self, self.onSelectBlueButton)
	widgets.sale:onClick(self, self.onSaleButton)
	self.type_desc = widgets.type_desc
end

function wnd_petEquipSaleBat:refresh()
	self:updateLeftScroll(g_i3k_game_context:GetAllBagPetEquips())
	self:updateRightScroll()
	self:RefreshMainText()
end

function wnd_petEquipSaleBat:onUpdate(dTime)
	if i3k_game_get_time() - self.record_time > SHOW_TIME and self.showflag then
		self.type_desc:hide()
		self.showflag = false
	end
end

function wnd_petEquipSaleBat:rightDefaultCellUI()
	self._layout.vars.item_scroll:removeAllChildren()
	self:updateRightScroll()
end

function wnd_petEquipSaleBat:RefreshMainText()
	local weight = self._layout.vars
	weight.diamond_lable:setText(self.total_count)
	weight.money_icon:setImage(g_i3k_db.i3k_db_get_icon_path(SHANYUANZHIID))
	self.type_desc:show()
	self.record_time = i3k_game_get_time()
end


function wnd_petEquipSaleBat:updateLeftScroll(BagItems)
	local weights = self._layout.vars
	local scoll = weights.scroll
	scoll:removeAllChildren()
	local items = self:itemsSort(BagItems)
	
	for i, e in ipairs(items) do
		local cfg = i3k_db_pet_equips[e.id]
		
		if cfg then
			local plcst = require(WIDGETS_LEFT)()
			local widget = plcst.vars
			local itemCount = e.count
			local sellNum =  e.count * cfg.petPower
			self:updateScrollWidget(widget, e.id, itemCount, sellNum)	
			scoll:addItem(plcst)
		end
	end
	
	local count = scoll:getChildrenCount()
	weights.no_item:setVisible(count == 0)
	--self.sale_items_changed = false
end

function wnd_petEquipSaleBat:updateScrollWidget(widget, id, count, sellNum)
	local cfg = i3k_db_pet_equips[id]
	widget.select_icon2:hide()
	widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
	local item_rank = g_i3k_db.i3k_db_get_common_item_rank(id)
	local name = g_i3k_make_color_string(g_i3k_db.i3k_db_get_common_item_name(id), g_i3k_get_color_by_rank(item_rank))
	local Xcount = string.format("x%s", count)
	local countStr = g_i3k_make_color_string(Xcount, g_i3k_get_white_color())
	local str = string.format("%s %s", name, countStr)
	widget.item_name:setText(str)
	widget.power_value:setText(math.modf(g_i3k_game_context:GetOnePetEquipFightPower(id)))
	widget.item_suo:setVisible(id > 0)
	widget.money:setText(sellNum)
	widget.item_grade:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widget.suo:setVisible(false)
	widget.little_icon:setImage(g_i3k_db.i3k_db_get_icon_path(SHANYUANZHIID))
	widget.itemTips_btn:onClick(self, self.onSelectLeftItem, {id = id})
	widget.id = id
	widget.count = count
	widget.isCanSelect = true
	widget.select:onClick(self, self.isSelectItem, widget)
end

function wnd_petEquipSaleBat:onSelectLeftItem(sender, data)
	g_i3k_ui_mgr:ShowCommonItemInfo(data.id)
end

function wnd_petEquipSaleBat:onItemTips(sender, data)
	g_i3k_ui_mgr:ShowCommonItemInfo(data.id)
end

function wnd_petEquipSaleBat:getSelectItemData()
	local select_item = {}
	local weights = self._layout.vars
	local items = weights.scroll:getAllChildren()
	
	for i, e in ipairs(items) do
		local wight = e.vars
		local id = wight.id
		
		if not wight.isCanSelect then
			local item = self:setItemData(wight)
			
			if select_item[id] then
				select_item[id].count = select_item[id].count + item.count
			else
				select_item[id] = item
			end
		end
	end
	
	return select_item
end

function wnd_petEquipSaleBat:setItemData(widget)
	return {id = widget.id, count = widget.count}
end

function wnd_petEquipSaleBat:isSelectItem(sender, widget)
	local weights = self._layout.vars
	widget.select_icon2:setVisible(widget.isCanSelect)
	local cfg = i3k_db_pet_equips[widget.id]
	local sell = cfg.petPower
	
	if widget.isCanSelect then
		widget.isCanSelect = false
		self.total_count = self.total_count + sell * widget.count
	else
		self.total_count = self.total_count - sell * widget.count
		widget.isCanSelect = true
	end
	
	weights.diamond_lable:setText(self.total_count)
	local item = self:getSelectItemData()
	self:updateRightScroll(item)
	self.isCanSelectAll = true
	self.isCanSelectBlue = true
end

function wnd_petEquipSaleBat:updateRightScroll(selectItem)
	local items = selectItem == nil and {} or selectItem
	local weights = self._layout.vars
	local item_scroll = weights.item_scroll
	
	item_scroll:jumpToListPercent(0)
	
	if not self.isCanSelectAll then
		item_scroll:removeAllChildren()
	elseif not self.isCanSelectBlue then
		item_scroll:removeAllChildren()
	end
	
	items = self:itemsSort(items)
	local totalItem = table.nums(items)
	local cellCount = totalItem < DEFAULT_COUNT and DEFAULT_COUNT or math.ceil(totalItem / RowitemCount) * RowitemCount
	local all_layer = item_scroll:addChildWithCount(WIDGETS_RIGHT, RowitemCount, cellCount)
	local cell_index = 1
	
	for i, e in ipairs(items) do		
		local widget = all_layer[cell_index].vars	
		self:updateCell(widget, e.id, e.count)
		cell_index = cell_index + 1
	end
	
	for k = cell_index, cellCount do --显示空格
		if k > totalItem then
			local widget = all_layer[k].vars
			self:updateCell(widget, 0, 0, nil)
		end
	end
end

function wnd_petEquipSaleBat:updateCell(widget, id, count)
	widget.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,g_i3k_game_context:IsFemaleRole()))
	widget.item_count:setText(count)
	widget.item_count:setVisible(count > 0)
	widget.suo:setVisible(id > 0)
	
	if id == 0 then
		widget.bt:disable()
	end
	
	widget.bt:onClick(self, self.onItemTips, {id = id})
end

function wnd_petEquipSaleBat:itemsSort(bagItems)
	local items = self:getReleaseItems(bagItems)
	
	local fun = function (a, b) 
		local rankA = g_i3k_db.i3k_db_get_common_item_rank(a.id) * SORTBASE + a.id
		local rankB = g_i3k_db.i3k_db_get_common_item_rank(b.id) * SORTBASE + b.id
 
		return -rankA < -rankB
	end
	
	table.sort(items, fun)
	
	return items
end

function wnd_petEquipSaleBat:getReleaseItems(bagItems)
	local items = {}
	local index = 1
	
	for _, v in pairs(bagItems) do
		items[index] = v
		index = index + 1
	end
	
	return items
end

function wnd_petEquipSaleBat:onSelectBlueButton(sender)
	local weights = self._layout.vars
	local temp = {}	
	self.total_count = 0
	self.isCanSelectAll = true
	weights.blue_icon:setVisible(self.isCanSelectBlue)
	
	if self.isCanSelectBlue then
		self:updateLeftScroll(g_i3k_game_context:GetAllBagPetEquips())
		local items = weights.scroll:getAllChildren()
			
		for i, e in ipairs(items) do
			local wight = e.vars
			local id = wight.id
			local count = wight.count
			local selectType = g_i3k_db.i3k_db_get_common_item_rank(id) <= g_RANK_VALUE_PURPLE
			
			if selectType then
				local cfg = i3k_db_pet_equips[id]
				local sell = cfg.petPower
				self.total_count = self.total_count + sell * count
				local item = self:setItemData(wight)
				
				if temp[id] then
					temp[id].count = temp[id].count + count
				else
					temp[id] = item
				end
				
				wight.isCanSelect = false
				wight.select_icon2:show()
			end
		end
		
		self:updateRightScroll(temp)
		self.isCanSelectBlue = false
	else
		local items = weights.scroll:getAllChildren()
		
		for i, e in ipairs(items) do
			local wight = e.vars
			wight.isCanSelect = true
			wight.select_icon2:hide()
		end
		
		self:rightDefaultCellUI()
		self.isCanSelectBlue = true
	end
	
	weights.diamond_lable:setText(self.total_count)
end

function wnd_petEquipSaleBat:onSaleButton(sender)
	local weights = self._layout.vars
	local sale_item = self:getSelectItemData()
	local items = {}
	
	if next(sale_item) == nil then
		self.isCanSelectBlue = true
		weights.blue_icon:hide()
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1539))
		return
	end
	
	
	for k, v in pairs(sale_item) do
		items[k] = v.count
	end
	
	local tmp_items = {}
	local t = {id = g_BASE_ITEM_PET_EQUIP_SPIRIT, count = self.total_count}
	table.insert(tmp_items, t)
	i3k_sbean.pet_domestication_equip_split(items, tmp_items)
	weights.isCanSelectBlue = true
	weights.blue_icon:hide()
	self.total_count = 0
	weights.diamond_lable:setText(self.total_count)
end

function wnd_petEquipSaleBat:refreshSaleScoll()
	self:updateLeftScroll(g_i3k_game_context:GetAllBagPetEquips())
	self:rightDefaultCellUI()
end

function wnd_create(layout, ...)
	local wnd = wnd_petEquipSaleBat.new()
	wnd:create(layout, ...)
	return wnd;
end

-------------------------------------------------------
