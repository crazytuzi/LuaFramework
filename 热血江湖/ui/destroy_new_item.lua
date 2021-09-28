
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_destory_new_item = i3k_class("wnd_destory_new_item",ui.wnd_base)
local RowitemCount = 5
local DEFAULT_COUNT = 25

function wnd_destory_new_item:ctor()
	self._selectItems = {}
	self._allItem = {}
	self._isSelectAll = true
	self._select_icon = nil
end

function wnd_destory_new_item:configure()
	local widget = self._layout.vars
	self.item_scroll = widget.item_scroll
	self.scroll = widget.scroll

	self.not_item_tips = widget.not_item_tips
	self.blue_icon = widget.blue_icon

	widget.not_item_tips:hide()
	widget.select_blue:onClick(self, self.selectAll)
	widget.sale:onClick(self, self.onOk)
	widget.close:onClick(self, self.onCloseUI)
	widget.scroll:setBounceEnabled(false)
	widget.item_scroll:setBounceEnabled(false)
end

function wnd_destory_new_item:refresh()
	self._allItem = self:itemSort(g_i3k_game_context:GetBagInfo())
	self:updateSelectScroll()
	self:InitDestoryItemScroll()
end

function wnd_destory_new_item:updateSelectScroll()
	self.scroll:removeAllChildren()
	self.scroll:setContainerSize(0, 0)
	
	for i,e in ipairs(self._allItem) do
		local node = require("ui/widgets/plcst")()
		local widget = node.vars
		local id = e.id
		
		widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
		widget.item_name:setText(self:getItemNameAndCount(id, e.count))
		widget.item_suo:setVisible(id>0)
		widget.item_grade:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
		widget.itemTips_btn:onClick(self, self.onClickItem, id)
		widget.select:onClick(self, self.onSelectItem, node)
		widget.item_level:hide()
		widget.power_value:hide()
		widget.money:hide()
		widget.little_icon:hide()
		widget.select_icon2:hide()
		node.itemData = e
		self.scroll:addItem(node)
	end
end

function wnd_destory_new_item:getItemNameAndCount(id, count)
	local item_rank = g_i3k_db.i3k_db_get_common_item_rank(id)
	local name = g_i3k_make_color_string(g_i3k_db.i3k_db_get_common_item_name(id), g_i3k_get_color_by_rank(item_rank))
	local countStr = g_i3k_make_color_string(string.format("x%s", count), g_i3k_get_white_color())
	return string.format("%s %s", name, countStr)
end

function wnd_destory_new_item:onClickItem(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_destory_new_item:ChangeSelectScroll(destroyItems)
	local allItems = self.scroll:getAllChildren()
	local data
	local count = 0
	local deleteIdx = {}
	for i,v in ipairs(allItems) do
		data = v.itemData
		for _, dstr in ipairs(destroyItems) do
			if dstr.id == data.id then
				data.count = data.count - dstr.count
			end
		end
		if data.count == 0 then
			deleteIdx[#deleteIdx + 1] = i
		else
			v.vars.select_icon2:hide()
			v.vars.item_name:setText(self:getItemNameAndCount(data.id, data.count))
		end
	end
	for i = #deleteIdx , 1, -1 do
		self.scroll:removeChildAtIndex(deleteIdx[i])
	end

	allItems = self.item_scroll:getAllChildren()
	for i = 1 , #self._selectItems do
		self:clearCell(allItems[i].vars)
	end

	self._selectItems = {}
	self._select_icon = nil
end

function wnd_destory_new_item:onSelectItem(sender, node)
	local widget = node.vars
	self._select_icon = widget.select_icon2
	if widget.select_icon2:isVisible() then
		self:updateDestroyItem(node.itemData, false)
	else
		if not self._isSelectAll then
			g_i3k_ui_mgr:OpenUI(eUIID_DestroyItem_Count)
			g_i3k_ui_mgr:RefreshUI(eUIID_DestroyItem_Count, node.itemData.id, node.itemData.count)
		else
			self:updateDestroyItem(node.itemData, true)
		end
	end
end

function wnd_destory_new_item:InitDestoryItemScroll()
	local totalItem = self:getCellCount(self._allItem)
	if totalItem == 0 then
		self._layout.vars.not_item_tips:show()
		return
	end
	
	local cellCount = totalItem < DEFAULT_COUNT and DEFAULT_COUNT or math.ceil(totalItem/RowitemCount)*RowitemCount
	local all_layer = self.item_scroll:addChildWithCount("ui/widgets/plcht", RowitemCount, cellCount)
	local widget = nil
	for i,e in ipairs(all_layer) do
		widget = all_layer[i].vars
		widget.item_count:hide()
		widget.suo:hide()
		widget.bt:hide()
	end
end

function wnd_destory_new_item:updateDestroyItem(item, destroy)
	if self._select_icon then
		self._select_icon:setVisible(destroy)
	end
	self._select_icon = nil
	local id, count = item.id, item.count

	local index = 0
	local originSize = #self._selectItems
	if not destroy then
		for i = #self._selectItems , 1, -1 do
			if id == self._selectItems[i].id then
				table.remove(self._selectItems, i)
				index = i
			end
		end
		index = index - 1
	else
		local stack_count = g_i3k_db.i3k_db_get_bag_item_stack_max(id)
		local cell_count = g_i3k_get_destroy_bag_cell_size(count, stack_count)
		index = #self._selectItems
		for i = 1, cell_count do
			local itemCount = i == cell_count and count-(cell_count-1)*stack_count or stack_count
			self._selectItems[#self._selectItems + 1] = {id = id, count = itemCount}
		end
	end

	local allItem = self.item_scroll:getAllChildren()

	for i = #self._selectItems+1 , originSize do
		self:clearCell(allItem[i].vars)
	end

	for k = index + 1, #self._selectItems do
		self:updateCell(allItem[k].vars, self._selectItems[k].id, self._selectItems[k].count)	
	end
end

function wnd_destory_new_item:getCellCount(items)
	local count = 0
	for i,e in ipairs(items) do
		count = count +  g_i3k_get_destroy_bag_cell_size(e.count, g_i3k_db.i3k_db_get_bag_item_stack_max(e.id))
	end
	return count
end

function wnd_destory_new_item:itemSort(bagSize, items)
	local sort_items = {}
	for k,v in pairs(items) do
		if g_i3k_db.i3k_db_get_common_item_type(v.id) == g_COMMON_ITEM_TYPE_ITEM then
			table.insert(sort_items, {id = v.id, count = v.count})
		end
	end
	table.sort(sort_items,function (a,b)
		return a.count > b.count
	end)

	return sort_items
end

function wnd_destory_new_item:updateCell(widget, id, count, guid)
	widget.item_count:show()
	widget.suo:show()
	widget.bt:show()
	widget.item_icon:show()
	widget.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
	widget.item_count:setText(count)
	widget.suo:setVisible(id>0)
	widget.bt:onClick(self, self.onClickItem, id)
end

function wnd_destory_new_item:clearCell(widget)
	widget.grade_icon:setImage(g_i3k_get_icon_frame_path_by_rank(0))
	widget.item_icon:hide()
	widget.item_count:hide()
	widget.suo:hide()
	widget.bt:hide()
end

function wnd_destory_new_item:selectAll(sender)
	self._isSelectAll = self._isSelectAll == false and true or false
	self.blue_icon:setVisible(self._isSelectAll)
end

function wnd_destory_new_item:onOk(sender)
	if #self._selectItems == 0 then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15519))
	end
	local callback = function(isOk)
		if isOk then
			i3k_sbean.bag_destroyItems(self._selectItems)
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(15520), callback)
end

function wnd_create(layout, ...)
	local wnd = wnd_destory_new_item.new()
	wnd:create(layout, ...)
	return wnd;
end

