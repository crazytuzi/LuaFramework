-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_petRaceShopBuy = i3k_class("wnd_petRaceShopBuy", ui.wnd_base)

function wnd_petRaceShopBuy:ctor()
	self._id = nil
end

function wnd_petRaceShopBuy:configure(...)
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

function wnd_petRaceShopBuy:onShow()

end

function wnd_petRaceShopBuy:updateItemData()

	if self._id then
		local data = g_i3k_game_context:getPetRaceShopData()
		local _id = data.items[self._id].id
		local itemid = i3k_db_pet_race_store.item_data[_id].itemID
		local maxCount = i3k_db_pet_race_store.item_data[_id].itemCount
		self.money_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_pet_race_store.item_data[_id].moneyType,i3k_game_context:IsFemaleRole()))
		self.money_count:setText(i3k_db_pet_race_store.item_data[_id].moneyCount)
		self.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
		self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid, i3k_game_context:IsFemaleRole()))
		local _count = data.items[self._id].buyTimes
		local tmp_str = string.format("%s*%s",g_i3k_db.i3k_db_get_common_item_name(itemid),maxCount -_count)
		self.item_name:setText(tmp_str)
		self.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemid)))
		self.item_desc:setText(g_i3k_db.i3k_db_get_common_item_desc(itemid))
		local data = g_i3k_game_context:getPetRaceShopData()

	end
end

function wnd_petRaceShopBuy:onBuy(sender,eventType)
	local data = g_i3k_game_context:getPetRaceShopData()
	local _id = data.items[self._id].id
	local itemid = i3k_db_pet_race_store.item_data[_id].itemID
	local maxCount = i3k_db_pet_race_store.item_data[_id].itemCount
	local money_count = i3k_db_pet_race_store.item_data[_id].moneyCount
	local moneyType = i3k_db_pet_race_store.item_data[_id].moneyType
	local name = i3k_db_pet_race_store.item_data[_id].itemName

	local contribution = g_i3k_game_context:GetBaseItemCanUseCount(moneyType)

	if contribution < money_count then
		g_i3k_ui_mgr:PopupTipMessage("货币不足，购买失败")
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
	i3k_sbean.petRaceShopBuy(self._id, tmp_str, money_count)
end

function wnd_petRaceShopBuy:refresh(index)
	self._id = index
	self:updateItemData()
end


function wnd_create(layout, ...)
	local wnd = wnd_petRaceShopBuy.new()
	wnd:create(layout, ...)

	return wnd
end
