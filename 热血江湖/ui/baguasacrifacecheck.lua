module(...,package.seeall)

local require = require;
local ui = require("ui/base");

wnd_baguaSacrifaceCheck = i3k_class("wnd_baguaSacrifaceCheck", ui.wnd_base)

local SORTBASE = 1000000
local RowitemCount = 5
local DEFAULT_COUNT = 10 --默认格子数

function wnd_baguaSacrifaceCheck:ctor()

end 

function wnd_baguaSacrifaceCheck:configure()
	local weight = self._layout.vars
	weight.close:onClick(self, self.onCloseUI)
	weight.compound:onClick(self, self.onCompoundBt)
	weight.tips:setText(i3k_get_string(17904))
end

function wnd_baguaSacrifaceCheck:refresh()
	local _, bagItems = g_i3k_game_context:GetBagInfo()
	
	local weights = self._layout.vars
	local scoll = weights.scoll
	scoll:removeAllChildren()
	local items = self:itemsSort(bagItems)
	local totalItem = self:getCellCount(items)
	local cellCount = totalItem < DEFAULT_COUNT and DEFAULT_COUNT or math.ceil(totalItem / RowitemCount) * RowitemCount
	local all_layer = scoll:addChildWithCount("ui/widgets/baguajipin2t", RowitemCount, cellCount)
	local cell_index = 1
	
	for i, e in ipairs(items) do
		local stack_count = g_i3k_db.i3k_db_get_bag_item_stack_max(e.id)
		local cell_count = g_i3k_get_use_bag_cell_size(e.count, stack_count)
		
		for k = 1, cell_count do
			local widget = all_layer[cell_index].vars
			local itemCount = k == cell_count and e.count - (cell_count - 1) * stack_count or stack_count
			self:updateScrollWidget(widget, e.id, itemCount)
			cell_index = cell_index + 1
		end
	end
	
	for k = cell_index, cellCount do --显示空格
		if k > totalItem then
			local widget = all_layer[k].vars
			self:updateScrollWidget(widget, 0, 0, nil)
		end
	end
	
	local count = scoll:getChildrenCount()
	weights.desc:setVisible(count == 0)
end

function wnd_baguaSacrifaceCheck:updateScrollWidget(widget, id, count)
	widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
	widget.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widget.suo:setVisible(id > 0)
	widget.item_count:setText("x" .. count)
	widget.item_count:setVisible(count > 0)

	if id == 0 then
		widget.bt:disable()
	end
	
	widget.bt:onClick(self, self.onItemClick, id)
end

function wnd_baguaSacrifaceCheck:onItemClick(sender, id)
	g_i3k_ui_mgr:OpenUI(eUIID_BagItemInfo)
	g_i3k_ui_mgr:RefreshUI(eUIID_BagItemInfo, id)
end

function wnd_baguaSacrifaceCheck:getCellCount(items)
	local count = 0
	
	for i,e in ipairs(items) do
		count = count +  g_i3k_get_use_bag_cell_size(e.count, g_i3k_db.i3k_db_get_bag_item_stack_max(e.id))
	end
	
	return count
end

function wnd_baguaSacrifaceCheck:itemsSort(bagItems)
	local items = self:getBaGuaSacrifaceItems(bagItems)
	
	local fun = function (a, b)
		return a.sortId < b.sortId
	end
	
	table.sort(items, fun)
	
	return items
end

function wnd_baguaSacrifaceCheck:getBaGuaSacrifaceItems(bagItems)
	local items = {}
	local index = 1
	
	for _, v in pairs(bagItems) do
		local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(v.id)
		
		if item_cfg and item_cfg.type == UseItemBaguaSacrifice then		
			items[index] = v
			index = index + 1
		end
	end
	
	return items
end

function wnd_baguaSacrifaceCheck:onCompoundBt()
	g_i3k_logic:OpenBaGuaCompound()
end

function wnd_create(layout)
	local wnd = wnd_baguaSacrifaceCheck.new();
	wnd:create(layout);
	return wnd;
end
