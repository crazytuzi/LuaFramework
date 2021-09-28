-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
local ui = require("ui/add_sub")

-------------------------------------------------------

wnd_sale_items = i3k_class("wnd_sale_items",ui.wnd_add_sub)

local SALE_COUNT_TEXT 		= 1

function wnd_sale_items:ctor()
	self._itemid = 0
	self._item_count = 0
end

function wnd_sale_items:configure()
	local widgets = self._layout.vars

	self.item_icon = widgets.item_icon
	self.item_bg = widgets.item_bg
	self.item_name = widgets.item_name
	self.item_count = widgets.item_count
	self.money_count = widgets.money_count
	self.money_icon = widgets.money_icon
	self.suo_icon = widgets.suo_icon
	self.item_desc = widgets.item_desc
	self.sale_count = widgets.sale_count


	self.sale_count:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
	self.sale_count:addEventListener(function(eventType)
		if eventType == "ended" then
			local str = tonumber(self.sale_count:getText()) or 1
			if str > self.current_add_num then
				str = self.current_add_num
			end
			if str > g_edit_box_max then
				str = g_edit_box_max
			end
			if str < 1 then
				str = 1
			end
			self.sale_count:setText(str)
			self.money_count:setText(str*g_i3k_db.i3k_db_get_common_item_sell_count(self._itemid))
			self.current_num = str
		end
	end)


	widgets.cancel:onClick(self, self.cancelButton)
	widgets.ok:onClick(self, self.okButton)

	self.add_btn = widgets.jia
	self.sub_btn = widgets.jian
	self.max_btn = widgets.max
	--self._count_label = self.sale_count

	--self.current_add_num = 100 	--当前能够增加到的最大值

	self.add_btn:onTouchEvent(self, self.onAdd)
	self.sub_btn:onTouchEvent(self,self.onSub)
	self.max_btn:onTouchEvent(self,self.onMax)
end

function wnd_sale_items:setSaleMoneyCount(count)
	local moneyCount = g_i3k_db.i3k_db_get_common_item_sell_count(self._itemid) * count
	self.sale_count:setText(count)
	self.money_count:setText(moneyCount)
end



function wnd_sale_items:updatefun()
	self._fun = function()
		--[[
		local moneyCount = g_i3k_db.i3k_db_get_common_item_sell_count(self._itemid) * self.current_num
		self.sale_count:setText(self.current_num)
		self.money_count:setText(moneyCount)
		--]]
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SaleItems,"setSaleMoneyCount",self.current_num)
	end
end

function wnd_sale_items:cancelButton(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_SaleItems)
end

function wnd_sale_items:okButton(sender)
	if tonumber(self.current_num) > 0 then
		if g_i3k_db.i3k_db_get_gem_item_cfg(self._itemid) then
			if math.abs(self._itemid % 100) >= g_GEM_SALE_CONFIRM_LEVEL then
				g_i3k_logic:OpenGemSaleConfirmUI(self._itemid, self.current_num)
			else
			i3k_sbean.bag_sellgem(self._itemid, self.current_num)
			end			
		elseif g_i3k_db.i3k_db_get_book_item_cfg(self._itemid) then
			i3k_sbean.bag_sellbook(self._itemid, self.current_num)
		else
			i3k_sbean.bag_sellitem(self._itemid, self.current_num)
		end
		g_i3k_ui_mgr:CloseUI(eUIID_SaleItems)
	end
end

function wnd_sale_items:refresh(id, count)
	SALE_COUNT_TEXT = 1
	self._itemid = id
	self._item_count = count

	local item_rank = g_i3k_db.i3k_db_get_common_item_rank(self._itemid)
	self.item_desc:setText(g_i3k_db.i3k_db_get_common_item_desc(self._itemid))
	self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(self._itemid,i3k_game_context:IsFemaleRole()))
	self.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(self._itemid))
	self.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(self._itemid))
	self.item_name:setTextColor(g_i3k_get_color_by_rank(item_rank))
	self.item_count:setText(self._item_count)
	self.current_add_num = self._item_count
	self:setSaleMoneyCount(self.current_num)
	self:setMoneyIcon()
	self:updatefun()
end

function wnd_sale_items:setMoneyIcon()
	if g_i3k_db.i3k_db_get_gem_item_cfg(self._itemid) then
		self.money_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_GEM_ENERGY,i3k_game_context:IsFemaleRole()))
		self.suo_icon:hide()
	elseif g_i3k_db.i3k_db_get_book_item_cfg(self._itemid) then
		self.money_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_BOOK_ENERGY,i3k_game_context:IsFemaleRole()))
		self.suo_icon:hide()
	end
end

function wnd_create(layout)
	local wnd = wnd_sale_items.new()
	wnd:create(layout)
	return wnd
end
