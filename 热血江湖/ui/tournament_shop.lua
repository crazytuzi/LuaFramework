-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
local store_base = require("ui/store_base");
-------------------------------------------------------
wnd_tournament_shop = i3k_class("wnd_tournament_shop", store_base.wnd_store_base)

function wnd_tournament_shop:ctor()
	self._refreshTimes = 0
	
	self._curPage = 3
end

function wnd_tournament_shop:configure()
	local moneyCount = g_i3k_game_context:getTournamentPoints()
	self._layout.vars.contri_value:setText(moneyCount)
	self._layout.vars.contri_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_TOURNAMENT_MONEY,i3k_game_context:IsFemaleRole()))
	self._layout.vars.refresh_btn:onClickWithChild(self, self.refreshData)
	self._layout.vars.shopName:setImage(g_i3k_db.i3k_db_get_icon_path(1845))
	self._layout.vars.money_root:onTouchEvent(self,self.onItemTips)
	
	self._layout.vars.subPage:onClick(self, self.onSubPage)
	self._layout.vars.addPage:onClick(self, self.onAddPage)
end

function wnd_tournament_shop:onShow()
	
end

function wnd_tournament_shop:refresh(info)
	self._curPage = 3
	local timeNow = g_i3k_get_GMTtime(i3k_game_get_time())
	local hour = tonumber(os.date("%H", timeNow))
	local cfgRefresh = i3k_db_tournament_shop_base.refreshTime
	local refreshHour = tonumber(string.sub(cfgRefresh, 1, 2))
	local nextRefreshTime
	if hour<refreshHour then
		nextRefreshTime = string.format("今日%d点", refreshHour)
		self._layout.vars.refreshTime:setText(nextRefreshTime)
	else
		nextRefreshTime = string.format("明日%d点", refreshHour)
		self._layout.vars.refreshTime:setText(nextRefreshTime)
	end
	
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	
	local goods = info.goods
	self._refreshTimes = info.refreshTimes
	local scroll = self._layout.vars.item_scroll
	scroll:setBounceEnabled(false)
	local count = 0
	for i,v in ipairs(goods) do
		count = count + 1
	end
	local nodePath = "ui/widgets/bpsdt"
	local count = #goods
	local children = scroll:addChildWithCount(nodePath, 3, count)
	for i,v in ipairs(children) do
		local shopItem = i3k_db_tournament_shop[goods[i].id]
		v.vars.item_name:setText(shopItem.name.."*"..shopItem.itemCount)
		v.vars.money_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_TOURNAMENT_MONEY,i3k_game_context:IsFemaleRole()))
		local textColor = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(shopItem.itemId))
		v.vars.item_name:setTextColor(textColor)
		v.vars.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(shopItem.itemId))
		v.vars.money_count:setText(shopItem.totalPrice)
		v.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(shopItem.itemId,i3k_game_context:IsFemaleRole()))
		
		v.vars.item_btn:setTag(i)
		if goods[i].buyTimes==0 then
			v.vars.out_icon:hide()
			v.vars.item_btn:onClick(self, self.buyItem, info)
		else
			v.vars.out_icon:show()
			v.vars.item_btn:setTouchEnabled(false)
		end
	end
end

function wnd_tournament_shop:onItemTips(sender, eventType)
	if eventType == ccui.TouchEventType.began then
		g_i3k_ui_mgr:OpenUI(eUIID_NewTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_NewTips, i3k_get_string(594), self:getBtnPosition())
	elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
		g_i3k_ui_mgr:CloseUI(eUIID_NewTips)
	end
end

function wnd_tournament_shop:getBtnPosition()
	local root = self._layout.vars.money_root
	local btnSize = root:getParent():getContentSize()
	local sectPos = root:getPosition()
	local btnPos = root:getParent():convertToWorldSpace(sectPos)
	return {width = btnSize.width, height = btnSize.height, pos = btnPos}
end

function wnd_tournament_shop:refreshData(sender)
	local count = #i3k_db_tournament_shop_base.needCoin
	local needCount = 0
	local diaCnt = 0
	if self._refreshTimes+1>count then
		needCount = i3k_db_tournament_shop_base.needCoin[count]
		diaCnt = i3k_db_tournament_shop_base.needCoin2[count]
	else
		needCount = i3k_db_tournament_shop_base.needCoin[self._refreshTimes+1]
		diaCnt = i3k_db_tournament_shop_base.needCoin2[self._refreshTimes+1]
	end
	
	local isEnough, sub = self:enoughDiamond(diaCnt)
	local moneyCount = g_i3k_game_context:getTournamentPoints()
	local spEnough = moneyCount < needCount
	if spEnough and not isEnough then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(493))
		return
	end
	self:openRefreshItemUI(g_BASE_ITEM_TOURNAMENT_MONEY, needCount, not spEnough, diaCnt, sub, self._refreshTimes)
	-- local desc = i3k_get_string(494, needCount)
	-- local callback = function (isOk)
	-- 	if isOk then
	-- 		local callfunc = function ()
	-- 			g_i3k_game_context:addTournamentPoint(0-needCount)
	-- 		end
	-- 		i3k_sbean.team_arena_refresh_store(self._refreshTimes+1, callfunc)
	-- 	end
	-- end
	-- g_i3k_ui_mgr:ShowMessageBox2(desc, callback)
	
end

function wnd_tournament_shop:buyItem(sender, info)
	local index = sender:getTag()
	local shopItem = i3k_db_tournament_shop[info.goods[index].id]
	g_i3k_ui_mgr:OpenUI(eUIID_ArenaShopBuyTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_ArenaShopBuyTips, index, shopItem, info, g_TOURNAMENT)
end

function wnd_tournament_shop:updateMoney(count)
	self._layout.vars.contri_value:setText(count)
end

function wnd_create(layout, ...)
	local wnd = wnd_tournament_shop.new()
	wnd:create(layout, ...)
	return wnd;
end
