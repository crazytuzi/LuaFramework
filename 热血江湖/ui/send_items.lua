-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
local ui = require("ui/add_sub")

-------------------------------------------------------

wnd_send_items = i3k_class("wnd_send_items",ui.wnd_add_sub)

function wnd_send_items:ctor()
	self._itemid = 0
	self._item_count = 0
	self._isMoodDiarySend = false
end

function wnd_send_items:configure()
	local widgets = self._layout.vars
	self.item_desc = widgets.item_desc
	self.item_icon = widgets.item_icon
	self.item_bg = widgets.item_bg
	self.item_name = widgets.item_name
	self.item_count = widgets.item_count
	self.send_count = widgets.send_count
	self.suo_icon = widgets.suo_icon
	self.ok = widgets.ok
	self.cancel = widgets.cancel

	self.add_btn = widgets.jia
	self.sub_btn = widgets.jian
	self.max_btn = widgets.max
	self.add_btn:onTouchEvent(self, self.onAdd)
	self.sub_btn:onTouchEvent(self,self.onSub)
	self.max_btn:onTouchEvent(self,self.addten)
end

function wnd_send_items:refresh(items,isMoodDiarySend)
	if isMoodDiarySend then
		self._isMoodDiarySend = true
	end
	self._itemid = items.id
	self._item_count = items.count
	self.current_add_num = items.count
	local item_rank = g_i3k_db.i3k_db_get_common_item_rank(self._itemid)
	self.item_desc:setText(g_i3k_db.i3k_db_get_common_item_desc(self._itemid))
	self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(self._itemid,i3k_game_context:IsFemaleRole()))
	self.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(self._itemid))
	self.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(self._itemid))
	self.item_name:setTextColor(g_i3k_get_color_by_rank(item_rank))
	self.item_count:setText(self._item_count)
	self.send_count:setText(self.current_num)
	self.suo_icon:hide()
	self:updatefun()
	self.ok:onClick(self, self.send, items)
	self.cancel:onClick(self,self.cancelbtn)
end

function wnd_send_items:cancelbtn()
	g_i3k_ui_mgr:CloseUI(eUIID_SendItems)
end

function wnd_send_items:send(sender, data)
	data.count = self.current_num
	local fun = (function(ok)
		if ok then
			i3k_sbean.send_gift(data.id, data.count, data.roleId, data.name)
		end
	end)
	if self._isMoodDiarySend then
		fun = (function(ok)
			if ok then
				i3k_sbean.mood_diary_send_popularity_item(data.count, data.id, data.roleId)
			end
		end)
	end
	local test = self._isMoodDiarySend
	local cfg = g_i3k_db.i3k_db_get_other_item_cfg(data.id)
	local desc = string.format("确认赠送%d个%s给%s吗？", self.current_num, cfg.name or "", data.name)
	g_i3k_ui_mgr:ShowMessageBox2(desc, fun)
	g_i3k_ui_mgr:CloseUI(eUIID_SendItems)
end

function wnd_send_items:setSendItemsCount(count)
	self.send_count:setText(count)
end

function wnd_send_items:updatefun()
	self._fun = function()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SendItems,"setSendItemsCount",self.current_num)
	end
end 

function wnd_send_items:addten(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		--[[if self.current_num <= self.current_add_num - 10 then 
			self.current_num = self.current_num + 10
		else
			self.current_num = self.current_add_num
			g_i3k_ui_mgr:PopupTipMessage("已到可使用上限")
		end--]]
		if self.current_num < 10 then
			self.current_num = 10
		else
			self.current_num = self.current_num + 10
		end
		if self.current_num > self.current_add_num then
			self.current_num = self.current_add_num
		end
		if self.current_num == self.current_add_num then
			g_i3k_ui_mgr:PopupTipMessage("已到可使用上限")
		end
		self.send_count:setText(self.current_num)
	end
end

function wnd_create(layout)
	local wnd = wnd_send_items.new()
	wnd:create(layout)
	return wnd
end
