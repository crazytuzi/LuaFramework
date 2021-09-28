-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_giveItem = i3k_class("wnd_giveItem", ui.wnd_base)

local RowitemCount = 5
local QJ_WIDGETS = "ui/widgets/szzst"

function wnd_giveItem:ctor()
end

function wnd_giveItem:configure()
	local widgets = self._layout.vars
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
end

function wnd_giveItem:refresh(roleId, name)
	local items = g_i3k_db.i3k_db_get_can_giveItem()
	if #items == 0 then
		g_i3k_ui_mgr:CloseUI(eUIID_GiveItem)
		return
	end
	local cellTotal = 0
	for i, e in ipairs(items) do
		local stackCount = g_i3k_db.i3k_db_get_bag_item_stack_max(e.id)
		local count = g_i3k_get_use_bag_cell_size(e.count, stackCount)
		cellTotal = cellTotal + g_i3k_get_use_bag_cell_size(e.count, stackCount)
	end
	local all_layer = self._layout.vars.scroll:addChildWithCount(QJ_WIDGETS,RowitemCount, cellTotal)
	local cell_index = 1
	for i,e in ipairs(items) do
		local stack_count = g_i3k_db.i3k_db_get_bag_item_stack_max(e.id)
		local cell_count = g_i3k_get_use_bag_cell_size(e.count, stack_count)
		for k=1,cell_count do
			local widget = all_layer[cell_index].vars
			local itemCount = k == cell_count and e.count-(cell_count-1)*stack_count or stack_count
			self:updateCell(widget, e.id, itemCount, roleId, name)
			--self:setUpIsShow(e.id, e.guids[k], widget)
			cell_index = cell_index + 1
		end
	end
end

function wnd_giveItem:updateCell(widget, id, count, roleId, name)
	widget.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
	widget.item_count:setText(count)
	--widget.suo:setVisible(id>0)
	widget.bt:onClick(self, self.sendGift, {id = id, count = count, roleId = roleId, name = name})
end

function wnd_giveItem:sendGift(sender, data)
	local fun = (function(ok)
		if ok then
			i3k_sbean.send_gift(data.id, data.count, data.roleId, data.name)
		end
	end)
	if data.count > 1 then
		g_i3k_ui_mgr:OpenUI(eUIID_SendItems)
		g_i3k_ui_mgr:RefreshUI(eUIID_SendItems, data)
	else
		local cfg = g_i3k_db.i3k_db_get_other_item_cfg(data.id)
		local desc = string.format("确认赠送%s给%s吗？", cfg.name or "", data.name)
		g_i3k_ui_mgr:ShowMessageBox2(desc, fun)
	end
end

function wnd_create(layout)
	local wnd = wnd_giveItem.new()
	wnd:create(layout)
	return wnd
end

