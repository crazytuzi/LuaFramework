-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_escort_store_buy = i3k_class("wnd_escort_store_buy", ui.wnd_base)

function wnd_escort_store_buy:ctor()
	self._id = nil 
	self._buyTimes = 0
	self._index = 0
end

function wnd_escort_store_buy:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	local buy_btn = self._layout.vars.buy_btn 
	buy_btn:onClick(self,self.onBuy)
	self.money_icon = self._layout.vars.money_icon 
	self.money_count = self._layout.vars.money_count 
	self.item_bg = self._layout.vars.item_bg 	
	self.item_icon = self._layout.vars.item_icon 	
	self.item_name = self._layout.vars.item_name
	self.item_desc = self._layout.vars.item_desc	
	
end

function wnd_escort_store_buy:onShow()
	
end

function wnd_escort_store_buy:updateItemData(id,buyTimes)
	
	
	local itemid = i3k_db_escort_store.item_data[id].itemID
	local maxCount = i3k_db_escort_store.item_data[id].itemCount
	self.money_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_escort_store.item_data[id].moneyType,i3k_game_context:IsFemaleRole()))
	self.money_count:setText(i3k_db_escort_store.item_data[id].moneyCount)
	self.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))		
	self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole()))
	local tmp_str = string.format("%s*%s",g_i3k_db.i3k_db_get_common_item_name(itemid),maxCount -buyTimes)				
	self.item_name:setText(tmp_str)
	self.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemid)))
	self.item_desc:setText(g_i3k_db.i3k_db_get_common_item_desc(itemid))
					
	
end

function wnd_escort_store_buy:onBuy(sender,eventType)

	local itemid = i3k_db_escort_store.item_data[self._id].itemID
	local maxCount = i3k_db_escort_store.item_data[self._id].itemCount
	local money_count = i3k_db_escort_store.item_data[self._id].moneyCount
	local moneyType = i3k_db_escort_store.item_data[self._id].moneyType
	local name = i3k_db_escort_store.item_data[self._id].itemName
	
	local contribution = g_i3k_game_context:GetBaseItemCanUseCount(moneyType)
	
	if contribution < money_count then
		local tmp_str = i3k_get_string(555)
			g_i3k_ui_mgr:PopupTipMessage(tmp_str)
		return 
	end

	local t = {[itemid] = maxCount}
	local is_ok = g_i3k_game_context:IsBagEnough(t)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
		return 
	end
	local tmp_str = i3k_get_string(189,name,maxCount)
	i3k_sbean.escort_store_buy(self._index,tmp_str,moneyType,money_count,itemid,maxCount)
	
end

function wnd_escort_store_buy:refresh(id,buyTimes,index)
	self._id = id
	self._buyTimes = buyTimes
	self._index = index
	self:updateItemData(id,buyTimes)
end 

--[[function wnd_escort_store_buy:onClose(sender,eventType)
	
	g_i3k_ui_mgr:CloseUI(eUIID_EscortStoreBuy)
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_escort_store_buy.new()
	wnd:create(layout, ...)

	return wnd
end

