
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/add_sub")
-------------------------------------------------------
wnd_destroy_item_count = i3k_class("wnd_destroy_item_cont",ui.wnd_add_sub)

function wnd_destroy_item_count:ctor()
	self._itemid = 0
	self._item_count = 0
end

function wnd_destroy_item_count:configure()
	local widgets = self._layout.vars
	widgets.money_root:hide()

	self.sale_count = widgets.sale_count
	self.sale_count:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
	self.sale_count:addEventListener(function(eventType)
		if eventType == "ended" then
			local str = tonumber(self.sale_count:getText()) or 1
			if  str > self.current_add_num then
				str = self.current_add_num
			end
			str = str == 0 and 1 or str
			self.sale_count:setText(str)
			self.current_num = str
		end
	end)


	widgets.cancel:onClick(self, self.onCloseUI)
	widgets.ok:onClick(self, self.okButton)

	widgets.jia:onTouchEvent(self, self.onAdd)
	widgets.jian:onTouchEvent(self,self.onSub)
	widgets.max:onTouchEvent(self,self.onMax)
	self._fun = function()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_DestroyItem_Count,"updateCount",self.current_num)
	end
	self.sale_count:setText(self.current_num)
	--self.current_add_num = 100
end

function wnd_destroy_item_count:refresh(id, count)
	self._itemid = id
	self.current_add_num = count

	local widgets = self._layout.vars
	local item_rank = g_i3k_db.i3k_db_get_common_item_rank(self._itemid)
	widgets.item_desc:setText(g_i3k_db.i3k_db_get_common_item_desc(self._itemid))
	widgets.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(self._itemid,i3k_game_context:IsFemaleRole()))
	widgets.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(self._itemid))
	widgets.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(self._itemid))
	widgets.item_name:setTextColor(g_i3k_get_color_by_rank(item_rank))
	widgets.item_count:setText(count)

end

function wnd_destroy_item_count:updateCount(count)
	self.sale_count:setText(count)
end

function wnd_destroy_item_count:okButton(sender)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_DestroyItem, "updateDestroyItem", {id = self._itemid, count = self.current_num}, true)
	self:onCloseUI()
end

function wnd_create(layout, ...)
	local wnd = wnd_destroy_item_count.new()
	wnd:create(layout, ...)
	return wnd;
end
