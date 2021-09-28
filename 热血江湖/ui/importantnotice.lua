module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_importantNotice = i3k_class("wnd_importantNotice", ui.wnd_base)

local QJ_WIDGETS = "ui/widgets/dj1"
local RowitemCount = 7

function wnd_importantNotice:ctor()
	self.warehouseType = 1	--为了区分立即取出和滚动内容
end

function wnd_importantNotice:configure()
	local widgets = self._layout.vars
	self.scroll = widgets.scroll

	widgets.cancel_btn:onClick(self,self.addNoTakeOutBtn)
	widgets.ok_btn:onClick(self,self.addTakeOutBtn)
end

function wnd_importantNotice:onUpdateScroll(daibis)
	local count_items = #daibis
	self.scroll:removeAllChildren()
	local all_layer = self["scroll"]:addChildWithCount(QJ_WIDGETS, RowitemCount, count_items)
	local cell_index = 1
	for k,v in pairs(daibis) do
			if all_layer[cell_index] then
				local widget = all_layer[cell_index].vars
				self:updateCell(widget, v.id, v.count, v.guids[1])
				cell_index = cell_index + 1
		end
	end
end

function wnd_importantNotice:updateCell(widget, id, count, guid)
	widget.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
	widget.item_count:setText(count)
	--if guid or count <= 0 then
		--widget.item_count:hide()
		--self:setMaskIsShow(id, widget)
	--else
		widget.item_count:show()
	--end
	--理论上没有id大于0的进来
	if g_i3k_db.i3k_db_get_bag_item_stack_max(id) == 0 then
		widget.suo:setVisible(false)
	else
		widget.suo:setVisible(id > 0)
	end

	widget.bt:onClick(self, self.onTips, id)
end

function wnd_importantNotice:onTips(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_importantNotice:refresh(warehouseType, daibis)
	self.warehouseType = warehouseType
	--local _, ware = g_i3k_game_context:GetWarehouseInfoForType(warehouseType)
	self:onUpdateScroll(daibis)
end

function wnd_importantNotice:onUpdate(dTime)

end

function wnd_importantNotice:onShow()
end

function wnd_importantNotice:onHide()
end

function wnd_create(layout)
	local wnd = wnd_importantNotice.new()
	wnd:create(layout)
	return wnd
end

function wnd_importantNotice:itemSort(items)
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

function wnd_importantNotice:addNoTakeOutBtn(sender)

	local fun_close = (function()
		g_i3k_ui_mgr:CloseUI(eUIID_ImportantNotice)
	end)
	local msg = string.format("下次您进入仓库介面时，会再次得到提示")
	g_i3k_ui_mgr:ShowMessageBox1(msg, fun_close)

end

function wnd_importantNotice:addTakeOutBtn(sender,args)
	local fun_close = (function()
		g_i3k_ui_mgr:CloseUI(eUIID_ImportantNotice)
	end)
	local msg = string.format("下次您进入仓库介面时，会再次得到提示")
	local fun = (function(ok)
			if ok then
				self:takeOutDaiBi()
			else
				g_i3k_ui_mgr:ShowMessageBox1(msg, fun_close)
			end
		end)
	local desc = string.format("您的公共仓库中存在部分代币道具，我们建议您和您的伴侣商讨一下归属问题")
	if self.warehouseType == g_PUBLIC_WAREHOUSE then 
	    g_i3k_ui_mgr:ShowCustomMessageBox2("继续取出", "暂不取出", desc, fun)
	else
	    self:takeOutDaiBi()
	end
end

function wnd_importantNotice:takeOutDaiBi()
	local _, ware = g_i3k_game_context:GetWarehouseInfoForType(self.warehouseType)
	local reqItems = {}
	for _,v in pairs(ware) do
		local stack_count = g_i3k_db.i3k_db_get_bag_item_stack_max(v.id) 
		if stack_count == 0 then
		    reqItems[v.id] = v.count
		end
	end
	i3k_sbean.goto_take_out_warehouse_piece(reqItems, self.warehouseType)
end

function wnd_importantNotice:takeOutSucceed()
	local str = string.format("所有兑换类道具已成功取出")
	g_i3k_ui_mgr:PopupTipMessage(str)
	g_i3k_ui_mgr:CloseUI(eUIID_ImportantNotice)
end

function wnd_importantNotice:takeOutFailed()
	local str = string.format("仓库内代币已经被取走")
	g_i3k_ui_mgr:PopupTipMessage(str)
	g_i3k_ui_mgr:CloseUI(eUIID_ImportantNotice)
end
