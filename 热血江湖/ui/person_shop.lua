-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_person_shop = i3k_class("wnd_person_shop", ui.wnd_base)

local LAYER_BPSDT = "ui/widgets/bpsdt"
local RowitemCount = 3
local LEFT = 1
local RIGHT = 2

function wnd_person_shop:ctor()
	self.shopType = 1
	self.refreshTimes = 0
	self.info = {}
	self.discount = {}
end

function wnd_person_shop:configure()
	self._layout.vars.close_btn:onClick(self, self.onClose)
	self._layout.vars.refresh_btn:onClick(self, self.onRefreshBtn)
	self.shopCfg =
	{
		[g_SHOP_TYPE_ESCORT] = {shopIcon = 4637, itemCfg = i3k_db_escort_store.item_data, refreshCfg = i3k_db_escort_store_refresh, currencyType = {g_BASE_ITEM_ESCORTT_MONEY}, currencyDesc = {595}, isOpen = self.escortIsOpen},--押镖
		[g_SHOP_TYPE_ARENA] = {shopIcon = 498, itemCfg = i3k_db_arenaShop, refreshCfg = i3k_db_arenaShopCost, currencyType = {g_BASE_ITEM_ARENA_MONEY}, currencyDesc = {593}, isOpen = self.arenaIsOpen},--竞技
		[g_SHOP_TYPE_FACTION] = {shopIcon = 2383, itemCfg = i3k_db_faction_store.item_data, refreshCfg = i3k_db_faction_store_refresh, currencyType = {g_BASE_ITEM_SECT_MONEY, g_BASE_ITEM_SECT_HONOR}, currencyDesc = {309, 16873}, isOpen = self.factionIsOpen},--帮派
		[g_SHOP_TYPE_TOURNAMENT] = {shopIcon = 1845, itemCfg = i3k_db_tournament_shop, refreshCfg = i3k_db_tournament_shop_base, currencyType = {g_BASE_ITEM_TOURNAMENT_MONEY, g_BASE_ITEM_BUDO}, currencyDesc = {594, 16947}, isOpen = self.tournamentIsOpen},--会武
		[g_SHOP_TYPE_MASTER] = {shopIcon = 3727, itemCfg = i3k_db_master_store.item_data, refreshCfg = i3k_db_master_store_refresh, currencyType = {g_BASE_ITEM_MASTER_POINT}, currencyDesc = {5009}, isOpen = self.masterIsOpen},--师徒
		[g_SHOP_TYPE_PET] = {shopIcon = 4292, itemCfg = i3k_db_pet_race_store.item_data, refreshCfg = i3k_db_pet_race_store_refresh, currencyType = {g_BASE_ITEM_PETCOIN}, currencyDesc = {16011}, isOpen = self.petRaceIsOpen},--龟龟
		[g_SHOP_TYPE_FAME] = {shopIcon = 5023, itemCfg = i3k_db_fameShop, refreshCfg = i3k_db_fameShopCfg, currencyType = {g_BASE_ITEM_FAME, g_BASE_ITEM_SPIRIT_BOSS}, currencyDesc = {16876, 17325}, isOpen = self.fameShopIsOpen},--武林声望
	}
end

function wnd_person_shop:refresh(info, shopType, discount)
	self.shopType = shopType
	self.refreshTimes = info.refreshTimes
	self.info = info
	self.discount = discount
	self:updateItems(info.goods)
end

function wnd_person_shop:updateItems(items)
	local storeCfg = self.shopCfg[self.shopType]
	local widgets = self._layout.vars
	widgets.shopName:setImage(g_i3k_db.i3k_db_get_icon_path(storeCfg.shopIcon))
	widgets.refreshTime:setText(self:getRefreshTime())
	widgets.contri_value:setText(g_i3k_game_context:GetBaseItemCanUseCount(storeCfg.currencyType[1]))
	widgets.contri_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_base_item[storeCfg.currencyType[1]].icon))
	widgets.subPage:onClick(self, self.onSubPage)
	widgets.addPage:onClick(self, self.onAddPage)
	widgets.money_root:onTouchEvent(self, self.onCurrency, 1)
	
	if #storeCfg.currencyType > 1 then
		widgets.currencyIcon2:show()
		widgets.contri_value2:setText(g_i3k_game_context:GetBaseItemCanUseCount(storeCfg.currencyType[2]))
		widgets.contri_icon2:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_base_item[storeCfg.currencyType[2]].icon))
		widgets.money_root2:onTouchEvent(self, self.onCurrency, 2)
	else
		widgets.currencyIcon2:hide()
	end
	local shopDiscount = self:getDiscount()
	if self.discount and self.discount.endTime then
		widgets.discount_desc:setText(i3k_get_string(1711, shopDiscount, g_i3k_get_YearAndDayTime(self.discount.endTime)))
		widgets.discount_desc:show()
	else
		widgets.discount_desc:hide()
	end
	local superMonthEndtime = g_i3k_game_context:getRoleSpecialCards(SUPER_MONTH_CARD).cardEndTime
	local nowtime  = i3k_game_get_time()
	if nowtime < superMonthEndtime and storeCfg.refreshCfg.specialCardDiscount > 0 then
		self._layout.vars.specialText:setText(i3k_get_string(1710, storeCfg.refreshCfg.specialCardDiscount * 10))
	else
		self._layout.vars.specialText:hide()
	end
	--减去逍遥卡折扣
	local discount = self:getFinalDiscount()
	self._layout.vars.item_scroll:removeAllChildren()
	local children = self._layout.vars.item_scroll:addChildWithCount(LAYER_BPSDT, 3, #items)
	for k, v in ipairs(children) do
		local shopItem = storeCfg.itemCfg[items[k].id]
		v.vars.item_name:setText(shopItem.itemName.."*"..shopItem.itemCount)
		v.vars.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(shopItem.itemId)))
		v.vars.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(shopItem.itemId))
		v.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(shopItem.itemId, g_i3k_game_context:IsFemaleRole()))
		if items[k].buyTimes == 0 then
			v.vars.out_icon:hide()
			v.vars.item_btn:onClick(self, self.buyItem, k)
		else
			v.vars.out_icon:show()
			v.vars.item_btn:setTouchEnabled(false)
		end
		v.vars.money_icon:hide()
		v.vars.money_icon1:hide()
		v.vars.money_icon2:hide()
		
		local moneyCount1 = shopItem.moneyCount
		local moneyCount2 = shopItem.moneyCount2
		if discount > 0 then
			moneyCount1 = math.ceil(shopItem.moneyCount * discount / 10)
			moneyCount2 = math.ceil(shopItem.moneyCount2 * discount / 10)
				v.vars.discount:show()
				local imgID = self:getDiscountImageID(discount)
				v.vars.discount:setImage(g_i3k_db.i3k_db_get_icon_path(imgID))
		else
			v.vars.discount:hide()
		end

		if shopItem.moneyType ~= 0 and moneyCount1 > 0 then
			if shopItem.moneyType2 ~= 0 and moneyCount2 > 0 then
				v.vars.money_icon1:show()
				v.vars.money_icon2:show()
				v.vars.money_icon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(shopItem.moneyType, g_i3k_game_context:IsFemaleRole()))
				v.vars.money_count1:setText(moneyCount1)
				v.vars.money_icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(shopItem.moneyType2, g_i3k_game_context:IsFemaleRole()))
				v.vars.money_count2:setText(moneyCount2)
				if moneyCount1 > g_i3k_game_context:GetBaseItemCanUseCount(storeCfg.currencyType[1]) then
					v.vars.money_count1:setTextColor(g_COLOR_VALUE_RED)
				end
				if moneyCount2 > g_i3k_game_context:GetBaseItemCanUseCount(storeCfg.currencyType[2]) then
					v.vars.money_count2:setTextColor(g_COLOR_VALUE_RED)
				end
			else
				v.vars.money_icon:show()
				v.vars.money_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(shopItem.moneyType, g_i3k_game_context:IsFemaleRole()))
				v.vars.money_count:setText(moneyCount1)
				if moneyCount1 > g_i3k_game_context:GetBaseItemCanUseCount(storeCfg.currencyType[1]) then
					v.vars.money_count:setTextColor(g_COLOR_VALUE_RED)
				end
			end
		else
			if shopItem.moneyType2 ~= 0 and moneyCount2 > 0 then
				v.vars.money_icon:show()
				v.vars.money_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(shopItem.moneyType2, g_i3k_game_context:IsFemaleRole()))
				v.vars.money_count:setText(moneyCount2)
				if moneyCount2 > g_i3k_game_context:GetBaseItemCanUseCount(storeCfg.currencyType[2]) then
					v.vars.money_count:setTextColor(g_COLOR_VALUE_RED)
				end
			end
		end
	end
end

function wnd_person_shop:getRefreshTime()
	local time = self.shopCfg[self.shopType].refreshCfg.refreshTime
	return string.format("%s", time[1])
end

function wnd_person_shop:getDiscount()
	local discount = 0
	if self.discount and self.discount.discount then
		discount = self.discount.discount
	end
	if self.shopType == g_SHOP_TYPE_FACTION then -- 帮派商店的城战计算折扣
		local curCity = g_i3k_game_context:getDefenceWarCurrentCityState()
		if curCity and curCity ~= 0 then
			if discount == 0 or (i3k_db_defenceWar_city[curCity].storeDiscount / 1000) < discount then
				discount = i3k_db_defenceWar_city[curCity].storeDiscount / 1000
			end
		end
	end
	return discount
end
function wnd_person_shop:getFinalDiscount()
	local discount = self:getDiscount()
	local superMonthEndtime = g_i3k_game_context:getRoleSpecialCards(SUPER_MONTH_CARD).cardEndTime
	local nowtime = i3k_game_get_time()
	if nowtime < superMonthEndtime then
		local storeCfg = self.shopCfg[self.shopType]
		if discount ~= 0 then
			discount = discount - storeCfg.refreshCfg.specialCardDiscount
		else
			if storeCfg.refreshCfg.specialCardDiscount > 0 then
				discount = 10 - storeCfg.refreshCfg.specialCardDiscount
			end
		end
	end
	return discount
end


-- 获取几折的图片id（1~9）
function wnd_person_shop:getDiscountImageID(discount)
	local oneDiscount = 498
	return math.floor(discount + oneDiscount)
end


function wnd_person_shop:buyItem(sender, id)
	local discount = self:getFinalDiscount()
	g_i3k_ui_mgr:OpenUI(eUIID_PersonShopBuy)
	g_i3k_ui_mgr:RefreshUI(eUIID_PersonShopBuy, id, self.info, self.shopType, discount, self.discount)
end

function wnd_person_shop:onRefreshBtn(sender)
	local costCfg = self.shopCfg[self.shopType].refreshCfg
	local currency = self.shopCfg[self.shopType].currencyType[1]
	local totalTimes = #costCfg.refreshMoneyCount
	local currencyNeed = 0
	local diamondNeed = 0
	if self.refreshTimes + 1 > totalTimes then
		currencyNeed = costCfg.refreshMoneyCount[totalTimes]
		diamondNeed = costCfg.refreshMoneyCount2[totalTimes]
	else
		currencyNeed = costCfg.refreshMoneyCount[self.refreshTimes + 1]
		diamondNeed = costCfg.refreshMoneyCount2[self.refreshTimes + 1]
	end
	local currencyCanUse = g_i3k_game_context:GetBaseItemCanUseCount(currency)
	local enough, dif = self:isDiamondEnough(diamondNeed)
	if currencyCanUse < currencyNeed and not enough then
		g_i3k_ui_mgr:PopupTipMessage(string.format("%s不足，刷新失败", i3k_db_base_item[currency].name))
		return
	end
	g_i3k_ui_mgr:OpenUI(eUIID_StoreRefresh)
	g_i3k_ui_mgr:RefreshUI(eUIID_StoreRefresh, currency, currencyNeed, currencyCanUse >= currencyNeed, diamondNeed, dif, self.refreshTimes, self.discount)
end

function wnd_person_shop:isDiamondEnough(diamondNeed)
	local bindingDiamond = g_i3k_game_context:GetDiamond(false)
	local freeDiamond = g_i3k_game_context:GetDiamond(true)
	local enough = (freeDiamond + bindingDiamond) >= diamondNeed
	local sub = bindingDiamond - diamondNeed
	return enough, sub
end

function wnd_person_shop:onSubPage(sender)
	self.shopType = self.shopType - 1
	self:gotoPage(LEFT)
end

function wnd_person_shop:onAddPage(sender)
	self.shopType = self.shopType + 1
	self:gotoPage(RIGHT)
end

function wnd_person_shop:goNextPage(direction)
	if direction == 1 then
		self.shopType = self.shopType - 1
	else
		self.shopType = self.shopType + 1
	end
	self:gotoPage(direction)
end

function wnd_person_shop:gotoPage(direction)
	if direction == 1 then
		if self.shopType <= 0 then
			self.shopType = self.shopType + #self.shopCfg
		end
	else
		if self.shopType > #self.shopCfg then
			self.shopType = self.shopType - #self.shopCfg
		end
	end
	self.shopCfg[self.shopType].isOpen(self, direction)
end

function wnd_person_shop:onCurrency(sender, eventType, btn)
	if eventType == ccui.TouchEventType.began then
		if btn == 1 then
			g_i3k_ui_mgr:OpenUI(eUIID_NewTips)
			g_i3k_ui_mgr:RefreshUI(eUIID_NewTips,i3k_get_string(self.shopCfg[self.shopType].currencyDesc[btn]), self:getBtnPosition(self._layout.vars.money_root))
		else
			g_i3k_ui_mgr:OpenUI(eUIID_NewTips)
			g_i3k_ui_mgr:RefreshUI(eUIID_NewTips,i3k_get_string(self.shopCfg[self.shopType].currencyDesc[btn]), self:getBtnPosition(self._layout.vars.money_root2))
		end
	else
		if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
			g_i3k_ui_mgr:CloseUI(eUIID_NewTips)
		end
	end
end

function wnd_person_shop:getBtnPosition(root)
	local btnSize = root:getParent():getContentSize()
	local sectPos = root:getPosition()
	local btnPos = root:getParent():convertToWorldSpace(sectPos)
	return {width = btnSize.width, height = btnSize.height, pos = btnPos}
end

function wnd_person_shop:escortIsOpen(direction)
	local factionID = g_i3k_game_context:GetFactionSectId()
	if factionID and factionID ~= 0 then
		local need_faction_lvl = i3k_db_escort.escort_args.open_lvl
		local now_level = g_i3k_game_context:getSectFactionLevel()
		if g_i3k_game_context:GetLevel() >= i3k_db_escort.escort_args.join_lvl and now_level >= need_faction_lvl then
			i3k_sbean.sect_escort_store_sync()
			g_i3k_ui_mgr:CloseUI(eUIID_PersonShop)
		else
			self:goNextPage(direction)
		end
	else
		self:goNextPage(direction)
	end
end

function wnd_person_shop:arenaIsOpen(direction)
	local syncShop = i3k_sbean.arena_shopsync_req.new()
	i3k_game_send_str_cmd(syncShop, i3k_sbean.arena_shopsync_res.getName())
	g_i3k_ui_mgr:CloseUI(eUIID_PersonShop)
end

function wnd_person_shop:factionIsOpen(direction)
	local factionID = g_i3k_game_context:GetFactionSectId()
	if factionID and factionID ~= 0 then
		local data = i3k_sbean.sect_shopsync_req.new()
		i3k_game_send_str_cmd(data,i3k_sbean.sect_shopsync_res.getName())
		g_i3k_ui_mgr:CloseUI(eUIID_PersonShop)
	else
		self:goNextPage(direction)
	end
end

function wnd_person_shop:tournamentIsOpen(direction)
	local hero = i3k_game_get_player_hero()
	if hero._lvl >= i3k_db_tournament_base.needLvl then
		i3k_sbean.sync_team_arena_store()
		g_i3k_ui_mgr:CloseUI(eUIID_PersonShop)
	else
		self:goNextPage(direction)
	end
end

function wnd_person_shop:masterIsOpen(direction)
	if g_i3k_game_context:GetLevel() >= i3k_db_master_cfg.cfg.apptc_min_lvl then
		i3k_sbean.master_send_store_sync()
		g_i3k_ui_mgr:CloseUI(eUIID_PersonShop)
	else
		self:goNextPage(direction)
	end
end

function wnd_person_shop:petRaceIsOpen(direction)
	local openLevel = i3k_db_common.petRace.startLevel
	local roleLevel = g_i3k_game_context:GetLevel()
	if roleLevel >= openLevel then
		i3k_sbean.syncPetRaceShop()
		g_i3k_ui_mgr:CloseUI(eUIID_PersonShop)
	else
		self:goNextPage(direction)
	end
end

function wnd_person_shop:fameShopIsOpen(direction)
	local openLevel = i3k_db_server_limit.breakSealCfg.limitLevel
	local roleLevel = g_i3k_game_context:GetLevel()
	if roleLevel >= openLevel then
		local data = i3k_sbean.fame_shopsync_req.new()
		i3k_game_send_str_cmd(data, i3k_sbean.fame_shopsync_res.getName())
		g_i3k_ui_mgr:CloseUI(eUIID_PersonShop)
	else
		self:goNextPage(direction)
	end
end

function wnd_person_shop:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_PersonShop)
end


function wnd_create(layout, ...)
	local wnd = wnd_person_shop.new()
	wnd:create(layout, ...);
	return wnd
end
