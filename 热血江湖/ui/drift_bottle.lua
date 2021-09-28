-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_drift_bottle = i3k_class("wnd_drift_bottle", ui.wnd_base)
local ITEMWIDGET = "ui/widgets/piaoliupingt"

function wnd_drift_bottle:ctor()
	self.id = nil
end

function wnd_drift_bottle:configure()
	local widgets = self._layout.vars
	self.editBox = widgets.editBox
	self.editBox:setMaxLength(i3k_db_common.bottle.maxLength)
	self.itemIcon = widgets.itemIcon
	self.itembg = widgets.itembg
	self.suo = widgets.suo
	self.itemCount = widgets.itemCount
	self.itemBtn = widgets.itemBtn
	self.scroll = widgets.scroll
	self.desc = widgets.desc
	self.exchangeBtn = widgets.exchangeBtn
	self.exchangeBtn:onClick(self, self.onExchange)
	self.itemBtn:onClick(self, self.cancelItem)
	widgets.bottleBtn:onClick(self, self.onBottle)
	widgets.help_btn:onClick(self, self.onHelp)
	widgets.close:onClick(self, self.onCloseBtn)
end

function wnd_drift_bottle:refresh()
	self.desc:hide()
	self:changeExchange()
	self:updateBag()
end

function wnd_drift_bottle:changeExchange()
	if self.id then
		self.exchangeBtn:enableWithChildren()
		self.itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(self.id))
		self.itembg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(self.id))
		self.itemCount:setText("x1")
		self.suo:setVisible(self.id > 0)
		self.itemIcon:show()
	else
		self.exchangeBtn:disableWithChildren()
		self.itemIcon:hide()
		self.itembg:setImage(g_i3k_db.i3k_db_get_icon_path(106))
		self.suo:hide()
		self.itemCount:setText("")
	end
end

function wnd_drift_bottle:updateBag()
	self.scroll:removeAllChildren()
	local bagSize, items = g_i3k_game_context:GetBagInfo()
	local sort_items = self:itemSort(items)
	local all_layer = self.scroll:addItemAndChild(ITEMWIDGET, 5, bagSize)
	local i = 1
	for k, v in pairs(sort_items) do
		if self.id and self.id == v.id and v.count == 1 then
			
		else
			all_layer[i].vars.item_count:setVisible(true)
			if self.id and self.id == v.id then
				all_layer[i].vars.item_count:setText("x"..(v.count - 1))
			else
				all_layer[i].vars.item_count:setText("x"..v.count)
			end
			all_layer[i].vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id))
			all_layer[i].vars.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
			all_layer[i].vars.suo:setVisible(v.id > 0)
			all_layer[i].vars.bt:onClick(self, self.addOneItem, v.id)
			i = i + 1
		end
	end
end

function wnd_drift_bottle:itemSort(items)
	local sort_items = {}
	local canExchange = 1
	if #i3k_db_common.bottle.exchange.binding == 1 then
		if i3k_db_common.bottle.exchange.binding[1] == -1 then
			canExchange = 1
		else
			canExchange = 2
		end
	else
		canExchange = 3
	end
	for k,v in pairs(items) do
		local itemId = k < 0 and -k or k
		local isCan = false
		if canExchange == 1 then
			isCan = k < 0 and i3k_db_bottle[itemId]
		elseif canExchange == 2 then
			isCan = k > 0 and i3k_db_bottle[itemId]
		else
			isCan = i3k_db_bottle[itemId]
		end
		if isCan then
			table.insert(sort_items, { sortid = g_i3k_db.i3k_db_get_bag_item_order(k), id = v.id, count = v.count})
		end
	end
	table.sort(sort_items,function (a,b)
		return a.sortid < b.sortid
	end)
	return sort_items
end

function wnd_drift_bottle:addOneItem(sender, id)
	if self.id then
		return
	end
	self.id = id
	g_i3k_ui_mgr:RefreshUI(eUIID_DriftBottle)
end

function wnd_drift_bottle:cancelItem(sender)
	self.id = nil
	g_i3k_ui_mgr:RefreshUI(eUIID_DriftBottle)
end

function wnd_drift_bottle:onExchange(sender)
	local bagSize = g_i3k_game_context:GetBagSize()
	local text = self.editBox:getText()
	local namecount = i3k_get_utf8_len(text)
	--if not g_i3k_game_context:checkBagCanAddCell(i3k_db_common.bottle.bagSize, true) then
	if bagSize - g_i3k_game_context:GetBagUseCell() < i3k_db_common.bottle.bagSize then
		g_i3k_ui_mgr:PopupTipMessage("背包剩余空间不足，请先清理背包")
	elseif text == "" then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16101))
	elseif namecount < i3k_db_common.bottle.minLength then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16100, "少"))
	elseif namecount > i3k_db_common.bottle.maxLength then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16100, "多"))
	else
		i3k_sbean.bottle_exchange(self.id, text)
	end
end

function wnd_drift_bottle:onBottle(sender)
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16102))
end

function wnd_drift_bottle:onHelp(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_Help)
	g_i3k_ui_mgr:RefreshUI(eUIID_Help, i3k_get_string(16103))
end

function wnd_drift_bottle:onCloseBtn(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_DriftBottle)
end

function wnd_create(layout, ...)
	local wnd = wnd_drift_bottle.new();
		wnd:create(layout, ...);
	return wnd;
end
