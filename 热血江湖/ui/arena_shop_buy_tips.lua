module(..., package.seeall)

local require = require;

local ui = require("ui/base");


wnd_arena_shop_buy_tips = i3k_class("wnd_arena_shop_buy_tips", ui.wnd_base)

function wnd_arena_shop_buy_tips:ctor()
	
end

function wnd_arena_shop_buy_tips:configure()
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
end

function wnd_arena_shop_buy_tips:onShow()
	
end

function wnd_arena_shop_buy_tips:refresh(index, shopItem, info, arenaType)
	self._arenaType = arenaType
	if arenaType==g_ARENA_SOLO then
		self._layout.vars.money_icon:setImage(i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_ARENA_MONEY,i3k_game_context:IsFemaleRole()))
	else
		self._layout.vars.money_icon:setImage(i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_TOURNAMENT_MONEY,i3k_game_context:IsFemaleRole()))
	end
	local needValue = {index = index, shopItem = shopItem, info = info}
	self._layout.vars.buy_btn:onClick(self, self.onBuy, needValue)
	
	local id = shopItem.itemId
	local rank = g_i3k_db.i3k_db_get_common_item_rank(id)
	self._layout.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
	self._layout.vars.item_bg:setImage(g_i3k_get_icon_frame_path_by_rank(rank))
	self._layout.vars.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(id).."*"..shopItem.itemCount)
	local textColor = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(id))
	self._layout.vars.item_name:setTextColor(textColor)
	self._layout.vars.item_desc:setText(g_i3k_db.i3k_db_get_common_item_desc(id))
	self._layout.vars.money_count:setText(shopItem.totalPrice)
end

function wnd_arena_shop_buy_tips:onBuy(sender, needValue)
	local shopItem = needValue.shopItem
	
	local moneyCount
	if self._arenaType==g_ARENA_SOLO then
		moneyCount = g_i3k_game_context:GetArenaMoney()
	else
		moneyCount = g_i3k_game_context:getTournamentPoints()
	end
	local isEnoughTable = {}
	isEnoughTable[shopItem.itemId] = shopItem.itemCount
	local isEnough = g_i3k_game_context:IsBagEnough(isEnoughTable)
	if moneyCount<shopItem.totalPrice then
		local stringId = self._arenaType==g_ARENA_SOLO and 170 or 492
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(stringId))
	elseif not isEnough then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
	else 
		if self._arenaType==g_ARENA_SOLO then
			local buy = i3k_sbean.arena_shopbuy_req.new()
			buy.info = needValue.info
			buy.index = needValue.index
			buy.seq = needValue.index
			buy.count = shopItem.itemCount
			i3k_game_send_str_cmd(buy, "arena_shopbuy_res")
		elseif self._arenaType then
			i3k_sbean.team_arena_buy_item(needValue.index, shopItem.itemCount, needValue.info)
		end
	end
	g_i3k_ui_mgr:CloseUI(eUIID_ArenaShopBuyTips)
end

--[[function wnd_arena_shop_buy_tips:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_ArenaShopBuyTips)
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_arena_shop_buy_tips.new();
	wnd:create(layout, ...);
	
	return wnd;
end
