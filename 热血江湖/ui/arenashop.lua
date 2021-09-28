-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
local store_base = require("ui/store_base");
-------------------------------------------------------
wnd_arenaShop = i3k_class("wnd_arenaShop", store_base.wnd_store_base)
function wnd_arenaShop:ctor()
	self._refreshTime = 0
	self._curPage = 1
end

function wnd_arenaShop:configure()
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
	
	local moneyCount = g_i3k_game_context:GetArenaMoney()
	self._layout.vars.contri_value:setText(moneyCount)
	
	self._layout.vars.refresh_btn:onClickWithChild(self, self.refreshData)
	self._layout.vars.contri_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_ARENA_MONEY,i3k_game_context:IsFemaleRole()))
	self._layout.vars.shopName:setImage(g_i3k_db.i3k_db_get_icon_path(498))
	self._layout.vars.money_root:onTouchEvent(self,self.onItemTips)
	
	self._layout.vars.subPage:onClick(self, self.onSubPage)
	self._layout.vars.addPage:onClick(self, self.onAddPage)
end

function wnd_arenaShop:onShow()
	
end

function wnd_arenaShop:refresh(info)
	self._curPage = 1
	self:setData(info)
end

function wnd_arenaShop:onItemTips(sender, eventType)
	if eventType == ccui.TouchEventType.began then
		g_i3k_ui_mgr:OpenUI(eUIID_NewTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_NewTips, i3k_get_string(593), self:getBtnPosition())
	elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
		g_i3k_ui_mgr:CloseUI(eUIID_NewTips)
	end
end

function wnd_arenaShop:getBtnPosition()
	local root = self._layout.vars.money_root
	local btnSize = root:getParent():getContentSize()
	local sectPos = root:getPosition()
	local btnPos = root:getParent():convertToWorldSpace(sectPos)
	return {width = btnSize.width, height = btnSize.height, pos = btnPos}
end
	
function wnd_arenaShop:setData(info)
	local timeNow = g_i3k_get_GMTtime(i3k_game_get_time())
	local hour = tonumber(os.date("%H", timeNow))
	local cfgRefresh = i3k_db_arena.arenaCfg.refreshTime
	local refreshHour = tonumber(string.sub(cfgRefresh, 1, 2))
	local nextRefreshTime
	if hour<refreshHour then
		nextRefreshTime = string.format("今日%d点", refreshHour)
		self._layout.vars.refreshTime:setText(nextRefreshTime)
	else
		nextRefreshTime = string.format("明日%d点", refreshHour)
		self._layout.vars.refreshTime:setText(nextRefreshTime)
	end
	
	self._refreshTime = info.refreshTimes
	local goods = info.goods
	local scroll = self._layout.vars.item_scroll
	scroll:setBounceEnabled(false)
	if scroll then
		
		local nodePath = "ui/widgets/bpsdt"
		
		local count = #goods
		
		local children = scroll:addChildWithCount(nodePath, 3, count)
		for i,v in ipairs(goods) do
			local shopItem = i3k_db_arenaShop[v.id]
			children[i].vars.item_btn:setTag(1000+i)
			children[i].vars.money_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_ARENA_MONEY,i3k_game_context:IsFemaleRole()))
			if v.buyTimes==0 then--<shopItem.itemCount then
				children[i].vars.out_icon:hide()
				children[i].vars.item_btn:onClick(self, self.buyItem, info)
			else
				children[i].vars.out_icon:show()
				children[i].vars.item_btn:setTouchEnabled(false)
			end
			children[i].vars.item_name:setText(shopItem.name.."*"..shopItem.itemCount)
			local textColor = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(shopItem.itemId))
			children[i].vars.item_name:setTextColor(textColor)
			children[i].vars.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(shopItem.itemId))
			children[i].vars.money_count:setText(shopItem.totalPrice)
			children[i].vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(shopItem.itemId,i3k_game_context:IsFemaleRole()))
		end
	end
end

function wnd_arenaShop:reloadMoney()
	-- local count = #i3k_db_arenaShopCost.needCoin
	-- local needMoney = 0
	-- if self._refreshTime>count then
	-- 	needMoney = i3k_db_arenaShopCost.needCoin[count]
	-- else
	-- 	needMoney = i3k_db_arenaShopCost.needCoin[self._refreshTime]
	-- end
	-- g_i3k_game_context:AddArenaMoney(0-needMoney)
	self:updateArenaMoney()
end

function wnd_arenaShop:refreshData(sender)
	local count = #i3k_db_arenaShopCost.needCoin
	local needMoney = 0
	local diaCnt = 0
	if self._refreshTime+1>count then
		needMoney = i3k_db_arenaShopCost.needCoin[count]
		diaCnt = i3k_db_arenaShopCost.needCoin2[count]
	else
		needMoney = i3k_db_arenaShopCost.needCoin[self._refreshTime+1]
		diaCnt = i3k_db_arenaShopCost.needCoin2[self._refreshTime+1]
	end

	local isEnough, sub = self:enoughDiamond(diaCnt)
	local moneyCount = g_i3k_game_context:GetArenaMoney()
	local spEnough = moneyCount < needMoney
	if moneyCount < needMoney and not isEnough then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(423))
		-- local desc = i3k_get_string(265, needMoney)
		-- local callback = function (isOk)
		-- 	if isOk then
		-- 		self._refreshTime = self._refreshTime+1
		-- 		local refreshShop = i3k_sbean.arena_shoprefresh_req.new()
		-- 		refreshShop.times = self._refreshTime
		-- 		i3k_game_send_str_cmd(refreshShop, "arena_shoprefresh_res")
		-- 	end
		-- end
		-- g_i3k_ui_mgr:ShowMessageBox2(desc, callback)
		return
	end
	self:openRefreshItemUI(g_BASE_ITEM_ARENA_MONEY, needMoney, not spEnough, diaCnt, sub, self._refreshTime)
end

function wnd_arenaShop:buyItem(sender, info)
	local index = sender:getTag()-1000
	local shopItem = i3k_db_arenaShop[info.goods[index].id]
	g_i3k_ui_mgr:OpenUI(eUIID_ArenaShopBuyTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_ArenaShopBuyTips, index, shopItem, info, g_ARENA_SOLO)
end

function wnd_arenaShop:updateArenaMoney()
	local moneyCount = g_i3k_game_context:GetArenaMoney()
	self._layout.vars.contri_value:setText(moneyCount)
end

function wnd_create(layout, ...)
	local wnd = wnd_arenaShop.new();
		wnd:create(layout, ...);

	return wnd;
end
