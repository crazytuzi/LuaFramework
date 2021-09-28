-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_store_buy = i3k_class("wnd_faction_store_buy", ui.wnd_base)

function wnd_faction_store_buy:ctor()
	self._id = nil
end

function wnd_faction_store_buy:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	local buy_btn = self._layout.vars.buy_btn
	buy_btn:onClick(self,self.onBuy)
	self.money_root = self._layout.vars.money_root
	self.money_icon = self._layout.vars.money_icon
	self.money_count = self._layout.vars.money_count
	self.money_root2 = self._layout.vars.money_root2
	self.money_icon1 = self._layout.vars.money_icon1
	self.money_count1 = self._layout.vars.money_count1
	self.money_icon2 = self._layout.vars.money_icon2
	self.money_count2 = self._layout.vars.money_count2
	self.item_bg = self._layout.vars.item_bg
	self.item_icon = self._layout.vars.item_icon
	self.item_name = self._layout.vars.item_name
	self.item_desc = self._layout.vars.item_desc
	
end

function wnd_faction_store_buy:onShow()

end

function wnd_faction_store_buy:updateItemData()
	if self._id then
		local data = g_i3k_game_context:GetFactionStoreData()
		local _id = data.items[self._id].id
		local itemid = i3k_db_faction_store.item_data[_id].itemID
		local maxCount = i3k_db_faction_store.item_data[_id].itemCount
		self.money_root:hide()
		self.money_root2:hide()
		if i3k_db_faction_store.item_data[_id].moneyType > 0 and i3k_db_faction_store.item_data[_id].moneyCount > 0 then
			if i3k_db_faction_store.item_data[_id].moneyType2 > 0 and i3k_db_faction_store.item_data[_id].moneyCount2 > 0 then
				self.money_root2:show()
				self.money_icon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_faction_store.item_data[_id].moneyType,g_i3k_game_context:IsFemaleRole()))
				self.money_count1:setText(i3k_db_faction_store.item_data[_id].moneyCount)
				self.money_icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_faction_store.item_data[_id].moneyType2,g_i3k_game_context:IsFemaleRole()))
				self.money_count2:setText(i3k_db_faction_store.item_data[_id].moneyCount2)
				if g_i3k_game_context:GetBaseItemCanUseCount(i3k_db_faction_store.item_data[_id].moneyType) < i3k_db_faction_store.item_data[_id].moneyCount then
					self.money_count1:setTextColor(g_COLOR_VALUE_RED)
				end
				if g_i3k_game_context:GetBaseItemCanUseCount(i3k_db_faction_store.item_data[_id].moneyType2) < i3k_db_faction_store.item_data[_id].moneyCount2 then
					self.money_count2:setTextColor(g_COLOR_VALUE_RED)
				end
			else
				self.money_root:show()
				self.money_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_faction_store.item_data[_id].moneyType, g_i3k_game_context:IsFemaleRole()))
				self.money_count:setText(i3k_db_faction_store.item_data[_id].moneyCount)
				if g_i3k_game_context:GetBaseItemCanUseCount(i3k_db_faction_store.item_data[_id].moneyType) < i3k_db_faction_store.item_data[_id].moneyCount then
					self.money_count:setTextColor(g_COLOR_VALUE_RED)
				end
			end
		else
			if i3k_db_faction_store.item_data[_id].moneyType2 > 0 and i3k_db_faction_store.item_data[_id].moneyCount2 > 0 then
				self.money_root:show()
				self.money_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_faction_store.item_data[_id].moneyType2,g_i3k_game_context:IsFemaleRole()))
				self.money_count:setText(i3k_db_faction_store.item_data[_id].moneyCount2)
				if g_i3k_game_context:GetBaseItemCanUseCount(i3k_db_faction_store.item_data[_id].moneyType2) < i3k_db_faction_store.item_data[_id].moneyCount2 then
					self.money_count:setTextColor(g_COLOR_VALUE_RED)
				end
			end
		end
		self.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
		self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,g_i3k_game_context:IsFemaleRole()))
		local _count = data.items[self._id].buyTimes
		local tmp_str = string.format("%s*%s",g_i3k_db.i3k_db_get_common_item_name(itemid),maxCount -_count)
		self.item_name:setText(tmp_str)
		self.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemid)))
		self.item_desc:setText(g_i3k_db.i3k_db_get_common_item_desc(itemid))
		local data = g_i3k_game_context:GetFactionStoreData()
	end
end

function wnd_faction_store_buy:onBuy(sender)

	local data = g_i3k_game_context:GetFactionStoreData()
	local _id = data.items[self._id].id
	local itemid = i3k_db_faction_store.item_data[_id].itemID
	local maxCount = i3k_db_faction_store.item_data[_id].itemCount
	local money_count = i3k_db_faction_store.item_data[_id].moneyCount
	local money_count2 = i3k_db_faction_store.item_data[_id].moneyCount2
	local moneyType = i3k_db_faction_store.item_data[_id].moneyType
	local moneyType2 = i3k_db_faction_store.item_data[_id].moneyType2
	local name = i3k_db_faction_store.item_data[_id].itemName

	local contribution = g_i3k_game_context:GetBaseItemCanUseCount(moneyType)
	local honor = g_i3k_game_context:GetBaseItemCanUseCount(moneyType2)

	if moneyType ~= 0 and money_count > 0 and contribution < money_count then
		g_i3k_ui_mgr:PopupTipMessage("帮贡不足，购买失败")
		return
	end
	if moneyType2 ~= 0 and money_count2 > 0 and honor < money_count2 then
		g_i3k_ui_mgr:PopupTipMessage("帮派荣誉不足，购买失败")
		return
	end

	-- local _count = data.items[self._id].buyTimes -- 这个字段是服务器同步过来的，不是0就是1。表示一个购买的标记位
	local t = {[itemid] = maxCount}
	local is_ok = g_i3k_game_context:IsBagEnough(t)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
		return
	end
	local tmp_str = string.format("成功购买了%s*%s",name, maxCount)
	local data = i3k_sbean.sect_shopbuy_req.new()
	data.seq = self._id
	data.str = tmp_str
	i3k_game_send_str_cmd(data,i3k_sbean.sect_shopbuy_res.getName())

end

function wnd_faction_store_buy:refresh(index)
	self._id = index
	self:updateItemData()
end

--[[function wnd_faction_store_buy:onClose(sender,eventType)

	g_i3k_ui_mgr:CloseUI(eUIID_FactionStoreBuy)
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_faction_store_buy.new()
	wnd:create(layout, ...)

	return wnd
end
