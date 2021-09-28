-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_jiayuanfangsheng = i3k_class("wnd_jiayuanfangsheng", ui.wnd_base)

local RowitemCount = 5
local WIDGETS_LEFT	= "ui/widgets/fangshengt"
local WIDGETS_RIGHT	= "ui/widgets/dj1"
local SHANYUANZHIID = 50
local SORTBASE = 1000000

-------------------------------------------------------
local DEFAULT_COUNT = 25 --默认格子数

function wnd_jiayuanfangsheng:ctor()
	self.total_count = 0
	self.isCanSelectBlue = true --是否可以选择蓝色
	self.isCanSelectAll = true --是否可以全选
	--self.sale_items_changed = false --是否可以刷新
end

function wnd_jiayuanfangsheng:configure()
	local wight = self._layout.vars
	wight.close:onClick(self, self.onCloseUI) 
	wight.select_blue:onClick(self, self.onSelectBlueButton)
	wight.select_all:onClick(self, self.onSelectAllButton)
	wight.sale:onClick(self, self.onSaleButton)
end

function wnd_jiayuanfangsheng:rightDefaultCellUI()
	self._layout.vars.item_scroll:removeAllChildren()
	self:updateRightScroll()
end

function wnd_jiayuanfangsheng:refresh()
	self:updateLeftScroll(g_i3k_game_context:GetBagInfo())
	self:updateRightScroll()
	self:RefreshMainText()
end

function wnd_jiayuanfangsheng:RefreshMainText()
	local weight = self._layout.vars
	weight.des:setText(i3k_get_string(17388))
	weight.diamond_lable:setText(self.total_count)
	weight.money_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(SHANYUANZHIID))
end

function wnd_jiayuanfangsheng:updateLeftScroll(bagSize, BagItems)
	local weights = self._layout.vars
	local scoll = weights.scroll
	scoll:removeAllChildren()
	local items = self:itemsSort(BagItems)
	
	for i, e in ipairs(items) do
		local sellNum = g_i3k_db.i3k_db_get_homeland_release_count(e.id)
		
		if sellNum ~= 0 then  
			local stack_count = g_i3k_db.i3k_db_get_bag_item_stack_max(e.id)
			local cell_count = g_i3k_get_use_bag_cell_size(e.count, stack_count)
				
			for k = 1, cell_count do
				local plcst = require(WIDGETS_LEFT)()
				local widget = plcst.vars
				local itemCount = k == cell_count and e.count - (cell_count - 1) * stack_count or stack_count
				self:updateScrollWidget(widget, e.id, itemCount, sellNum)	
				scoll:addItem(plcst)
			end
		end
	end
	
	local count = scoll:getChildrenCount()
	weights.no_item:setVisible(count == 0)
	weights.no_item:setText(i3k_get_string(17390))
	--self.sale_items_changed = false
end

function wnd_jiayuanfangsheng:updateScrollWidget(widget, id, count, sellNum)
	widget.select_icon2:hide()
	widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
	local item_rank = g_i3k_db.i3k_db_get_common_item_rank(id)
	local name = g_i3k_make_color_string(g_i3k_db.i3k_db_get_common_item_name(id), g_i3k_get_color_by_rank(item_rank))
	local Xcount = string.format("x%s", count)
	local countStr = g_i3k_make_color_string(Xcount, g_i3k_get_white_color())
	local str = string.format("%s %s", name, countStr)
	widget.item_name:setText(str)
	
	widget.item_suo:setVisible(id > 0)
	widget.money:setText(sellNum)
	widget.item_grade:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widget.suo:setVisible(false)
	widget.little_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(SHANYUANZHIID))
	widget.itemTips_btn:onClick(self, self.onSelectLeftItem, {id = id})
	widget.id = id
	widget.count = count
	widget.isCanSelect = true
	widget.select:onClick(self, self.isSelectItem, widget)
end

function wnd_jiayuanfangsheng:onSelectLeftItem(sender, data)
	g_i3k_ui_mgr:ShowCommonItemInfo(data.id)
end

function wnd_jiayuanfangsheng:onItemTips(sender, data)
	self:setCellIsSelectHide()
	data.is_select:show()
	g_i3k_ui_mgr:ShowCommonItemInfo(data.id)
end

function wnd_jiayuanfangsheng:setCellIsSelectHide()
	local items = self._layout.vars.item_scroll:getAllChildren()
	
	for i, e in ipairs(items) do
		e.vars.is_select:hide()
	end
end

function wnd_jiayuanfangsheng:getSelectItemData()
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

function wnd_jiayuanfangsheng:setItemData(widget)
	return {id = widget.id, count = widget.count}
end

function wnd_jiayuanfangsheng:isSelectItem(sender, widget)
	local weights = self._layout.vars
	widget.select_icon2:setVisible(widget.isCanSelect)
	local sell = g_i3k_db.i3k_db_get_homeland_release_count(widget.id)
	
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

function wnd_jiayuanfangsheng:updateRightScroll(selectItem)
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
	local totalItem = self:getCellCount(items)
	local cellCount = totalItem < DEFAULT_COUNT and DEFAULT_COUNT or math.ceil(totalItem / RowitemCount) * RowitemCount
	local all_layer = item_scroll:addChildWithCount(WIDGETS_RIGHT, RowitemCount, cellCount)
	local cell_index = 1
	
	for i, e in ipairs(items) do
		local stack_count = g_i3k_db.i3k_db_get_bag_item_stack_max(e.id)
		local cell_count = g_i3k_get_use_bag_cell_size(e.count, stack_count)
		
		for k = 1, cell_count do
			local widget = all_layer[cell_index].vars
			local itemCount = k == cell_count and e.count - (cell_count - 1) * stack_count or stack_count
			self:updateCell(widget, e.id, itemCount)
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

function wnd_jiayuanfangsheng:getCellCount(items)
	local count = 0
	
	for i,e in ipairs(items) do
		count = count +  g_i3k_get_use_bag_cell_size(e.count, g_i3k_db.i3k_db_get_bag_item_stack_max(e.id))
	end
	
	return count
end

function wnd_jiayuanfangsheng:updateCell(widget, id, count)
	widget.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,g_i3k_game_context:IsFemaleRole()))
	widget.item_count:setText(count)
	widget.item_count:setVisible(count > 0)
	widget.suo:setVisible(id > 0)
	
	if id == 0 then
		widget.bt:disable()
	end
	
	widget.bt:onClick(self, self.onItemTips, {is_select = widget.is_select, id = id})
end

function wnd_jiayuanfangsheng:itemsSort(bagItems)
	local items = self:getReleaseItems(bagItems)
	
	local fun = function (a, b) 
		local rankA = g_i3k_db.i3k_db_get_common_item_rank(a.id) * SORTBASE + a.id
		local rankB = g_i3k_db.i3k_db_get_common_item_rank(b.id) * SORTBASE + b.id
 
		return -rankA < -rankB
	end
	
	table.sort(items, fun)
	
	return items
end

function wnd_jiayuanfangsheng:onSelectBlueButton(sender)
	local weights = self._layout.vars
	local temp = {}	
	self.total_count = 0
	self.isCanSelectAll = true
	weights.blue_icon:setVisible(self.isCanSelectBlue)
	
	if self.isCanSelectBlue then
		self:updateLeftScroll(g_i3k_game_context:GetBagInfo())
		local items = weights.scroll:getAllChildren()
			
		for i, e in ipairs(items) do
			local wight = e.vars
			local id = wight.id
			local count = wight.count
			local selectType = g_i3k_db.i3k_db_get_common_item_rank(id) <= g_RANK_VALUE_BLUE
			
			if selectType then
				self.total_count = self.total_count + g_i3k_db.i3k_db_get_homeland_release_count(id) * count
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

function wnd_jiayuanfangsheng:onSelectAllButton(sender)
	local weights = self._layout.vars
	local temp = {}
	self.total_count = 0
	self.isCanSelectBlue = true
	weights.blue_icon:hide()
	
	if self.isCanSelectAll then
		self:updateLeftScroll(g_i3k_game_context:GetBagInfo())
		local items = weights.scroll:getAllChildren()
		
		for i, e in ipairs(items) do
			local wight = e.vars
			local id = wight.id
			local count = wight.count
			self.total_count = self.total_count + g_i3k_db.i3k_db_get_homeland_release_count(id) * count
			local item = self:setItemData(wight)
			
			if temp[id] then
				temp[id].count = temp[id].count + count
			else
				temp[id] = item
			end
			
			wight.isCanSelect = false
			wight.select_icon2:show()
		end
		
		self:updateRightScroll(temp)
		self.isCanSelectAll = false
	else
		local items = weights.scroll:getAllChildren()
		
		for i, e in ipairs(items) do
			local wight = e.vars
			wight.isCanSelect = true
			wight.select_icon2:hide()
		end
		
		self:rightDefaultCellUI()
		self.isCanSelectAll = true
		self.total_count = 0
	end
	
	weights.diamond_lable:setText(self.total_count)
end

function wnd_jiayuanfangsheng:onSaleButton(sender)
	local weights = self._layout.vars
	local sale_item = self:getSelectItemData()
	local items = {}
	
	if next(sale_item) == nil then
		self.isCanSelectBlue = true
		weights.blue_icon:hide()
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17389))
		return
	end
	
	
	for k, v in pairs(sale_item) do
		items[k] = v.count
	end
	
	i3k_sbean.release_homeland_items(items, self.total_count)
	weights.isCanSelectBlue = true
	weights.blue_icon:hide()
	self.total_count = 0
	weights.diamond_lable:setText(self.total_count)
end

function wnd_jiayuanfangsheng:getReleaseItems(bagItems)
	local items = {}
	local index = 1
	
	for _, v in pairs(bagItems) do
		local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(v.id)
		
		if item_cfg and item_cfg.isGoto ~= 0 and item_cfg.type == UseItemRelease then
			items[index] = v
			index = index + 1
		end
	end
	
	return items
end

function wnd_jiayuanfangsheng:onUpdate(dTime)
	--[[if self.sale_items_changed then
		self:updateLeftScroll(g_i3k_game_context:GetBagInfo())
		self:rightDefaultCellUI()
	end--]]
end

function wnd_jiayuanfangsheng:refreshSaleScoll()
	self:updateLeftScroll(g_i3k_game_context:GetBagInfo())
	self:rightDefaultCellUI()
end

function wnd_create(layout)
	local wnd = wnd_jiayuanfangsheng.new()
		wnd:create(layout)
	return wnd
end

