-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/person_shop");

-------------------------------------------------------
wnd_person_shop_buy = i3k_class("wnd_person_shop_buy", ui.wnd_person_shop)

function wnd_person_shop_buy:ctor()
	self._id = nil
	self.info = {}
	self.shopType = 1
	self._discount = 0 --商店折扣，整型，不要转成浮点型
	self._discountCfg = {}
end

function wnd_person_shop_buy:configure()
	self.buyInfo =
	{
		[g_SHOP_TYPE_ESCORT] = {itemCfg = i3k_db_escort_store.item_data, currencyType = {g_BASE_ITEM_ESCORTT_MONEY}, buySync = i3k_sbean.escort_store_buy,},--押镖
		[g_SHOP_TYPE_ARENA] = {itemCfg = i3k_db_arenaShop, currencyType = {g_BASE_ITEM_ARENA_MONEY}, buySync = i3k_sbean.arena_shopbuy,},--竞技
		[g_SHOP_TYPE_FACTION] = {itemCfg = i3k_db_faction_store.item_data, currencyType = {g_BASE_ITEM_SECT_MONEY, g_BASE_ITEM_SECT_HONOR}, buySync = i3k_sbean.sect_shopbuy,},--帮派
		[g_SHOP_TYPE_TOURNAMENT] = {itemCfg = i3k_db_tournament_shop, currencyType = {g_BASE_ITEM_TOURNAMENT_MONEY, g_BASE_ITEM_BUDO}, buySync = i3k_sbean.team_arena_buy_item,},--会武
		[g_SHOP_TYPE_MASTER] = {itemCfg = i3k_db_master_store.item_data, currencyType = {g_BASE_ITEM_MASTER_POINT}, buySync = i3k_sbean.master_shop_buy_item,},--师徒
		[g_SHOP_TYPE_PET] = {itemCfg = i3k_db_pet_race_store.item_data, currencyType = {g_BASE_ITEM_PETCOIN}, buySync = i3k_sbean.petRaceShopBuy,},--龟龟
		[g_SHOP_TYPE_FAME] = {itemCfg = i3k_db_fameShop, currencyType = {g_BASE_ITEM_FAME, g_BASE_ITEM_SPIRIT_BOSS}, buySync = i3k_sbean.fame_shopbuy,},--武林声望
	}
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
	self.skillPanel = self._layout.vars.skillPanel
	self.mainPanel = self._layout.vars.mainPanel
	self.scroll = self._layout.vars.scroll
end

function wnd_person_shop_buy:refresh(id, info, shopType, discount, discountCfg)
	self._id = id
	self.info = info
	self.shopType = shopType or 1
	self._discount = discount or 0
	self._discountCfg = discountCfg
	self:updateItemData()
end

function wnd_person_shop_buy:updateItemData()
	local widgets = self._layout.vars
	if self._id then
		local id = self.info.goods[self._id].id
		local item = self.buyInfo[self.shopType].itemCfg[id]
		local itemId = item.itemId
		local itemName = g_i3k_db.i3k_db_get_common_item_name(itemId)
		local itemCount = item.itemCount
		local moneyType = item.moneyType
		local moneyCount = item.moneyCount
		local moneyType2 = item.moneyType2
		local moneyCount2 = item.moneyCount2

		local isShowSkillPanel = i3k_show_skill_item_description(self.scroll, itemId)
		self.skillPanel:setVisible(isShowSkillPanel)
		if not isShowSkillPanel then
			local skillPanelPosition = self.skillPanel:getPosition()
			local mainPanelPosition = self.mainPanel:getPosition()
			self.mainPanel:setPosition((skillPanelPosition.x + mainPanelPosition.x) / 2, mainPanelPosition.y)
		end
		widgets.buy_btn:onClick(self, self.onBuy)
		widgets.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemId))
		widgets.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemId, g_i3k_game_context:IsFemaleRole()))
		widgets.item_name:setText(itemName.."*"..itemCount)
		widgets.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemId)))
		widgets.item_desc:setText(g_i3k_db.i3k_db_get_common_item_desc(itemId))

		widgets.money_root:hide()
		widgets.money_root2:hide()
		if self._discount > 0 then
			widgets.discount:show()
			local imgID = self:getDiscountImageID(self._discount)
			widgets.discount:setImage(g_i3k_db.i3k_db_get_icon_path(imgID))
			moneyCount = math.ceil(item.moneyCount * self._discount / 10)
			moneyCount2 = math.ceil(item.moneyCount2 * self._discount / 10)
			widgets.discountRoot1:hide()
			widgets.discountRoot2:hide()
			widgets.money_root:hide()
			widgets.money_root2:hide()
			if moneyType ~= 0 and moneyCount > 0 and moneyType2 ~= 0 and moneyCount2 > 0 then
				widgets.discountRoot2:show()
				widgets.all_money_icon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(moneyType, g_i3k_game_context:IsFemaleRole()))
				widgets.all_money_count1:setText(item.moneyCount)
				widgets.cur_money_icon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(moneyType, g_i3k_game_context:IsFemaleRole()))
				widgets.cur_money_count1:setText(moneyCount)
				widgets.all_money_icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(moneyType2, g_i3k_game_context:IsFemaleRole()))
				widgets.all_money_count2:setText(item.moneyCount2)
				widgets.cur_money_icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(moneyType2, g_i3k_game_context:IsFemaleRole()))
				widgets.cur_money_count2:setText(moneyCount2)
				if g_i3k_game_context:GetBaseItemCanUseCount(moneyType) < moneyCount then
					widgets.cur_money_count1:setTextColor(g_COLOR_VALUE_RED)
				end
				if g_i3k_game_context:GetBaseItemCanUseCount(moneyType2) < moneyCount2 then
					widgets.cur_money_count2:setTextColor(g_COLOR_VALUE_RED)
				end
		else
				widgets.discountRoot1:show()
				if moneyType ~= 0 and moneyCount > 0 then
					widgets.all_money_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(moneyType, g_i3k_game_context:IsFemaleRole()))
					widgets.all_money_count:setText(item.moneyCount)
					widgets.cur_money_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(moneyType, g_i3k_game_context:IsFemaleRole()))
					widgets.cur_money_count:setText(moneyCount)
					if g_i3k_game_context:GetBaseItemCanUseCount(moneyType) < moneyCount then
						widgets.cur_money_count:setTextColor(g_COLOR_VALUE_RED)
					end
				else
					widgets.all_money_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(moneyType2, g_i3k_game_context:IsFemaleRole()))
					widgets.all_money_count:setText(item.moneyCount2)
					widgets.cur_money_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(moneyType2, g_i3k_game_context:IsFemaleRole()))
					widgets.cur_money_count:setText(moneyCount2)
					if g_i3k_game_context:GetBaseItemCanUseCount(moneyType2) < moneyCount2 then
						widgets.cur_money_count:setTextColor(g_COLOR_VALUE_RED)
					end
		end
			end
		else
			widgets.discountRoot1:hide()
			widgets.discountRoot2:hide()
			widgets.discount:hide()
		if moneyType ~= 0 and moneyCount > 0 then
			if moneyType2 ~= 0 and moneyCount2 > 0 then
				widgets.money_root2:show()
				widgets.money_icon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(moneyType, g_i3k_game_context:IsFemaleRole()))
				widgets.money_count1:setText(moneyCount)
				widgets.money_icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(moneyType2, g_i3k_game_context:IsFemaleRole()))
				widgets.money_count2:setText(moneyCount2)
				if g_i3k_game_context:GetBaseItemCanUseCount(moneyType) < moneyCount then
					widgets.money_count1:setTextColor(g_COLOR_VALUE_RED)
				end
				if g_i3k_game_context:GetBaseItemCanUseCount(moneyType2) < moneyCount2 then
					widgets.money_count2:setTextColor(g_COLOR_VALUE_RED)
				end
			else
				widgets.money_root:show()
				widgets.money_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(moneyType, g_i3k_game_context:IsFemaleRole()))
				widgets.money_count:setText(moneyCount)
				if g_i3k_game_context:GetBaseItemCanUseCount(moneyType) < moneyCount then
					widgets.money_count:setTextColor(g_COLOR_VALUE_RED)
				end
			end
		else
			if moneyType2 ~= 0 and moneyCount2 > 0 then
				widgets.money_root:show()
				widgets.money_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(moneyType2, g_i3k_game_context:IsFemaleRole()))
				widgets.money_count:setText(moneyCount2)
				if g_i3k_game_context:GetBaseItemCanUseCount(moneyType2) < moneyCount2 then
					widgets.money_count:setTextColor(g_COLOR_VALUE_RED)
				end
			end
		end
	end
end
end

function wnd_person_shop_buy:onBuy(sender)
	local id = self.info.goods[self._id].id
	local item = self.buyInfo[self.shopType].itemCfg[id]
	local itemId = item.itemId
	local itemCount = item.itemCount
	local moneyType = item.moneyType
	local moneyNeed = item.moneyCount
	local moneyType2 = item.moneyType2
	local moneyNeed2 = item.moneyCount2
	if self._discount > 0 then
		moneyNeed = math.ceil(item.moneyCount * self._discount / 10)
		moneyNeed2 = math.ceil(item.moneyCount2 * self._discount / 10)
	end
	if moneyType ~= 0 and moneyNeed > 0 and g_i3k_game_context:GetBaseItemCanUseCount(moneyType) < moneyNeed then
		g_i3k_ui_mgr:PopupTipMessage(string.format("%s不足，购买失败", i3k_db_base_item[moneyType].name))
	elseif moneyType2 ~= 0 and moneyNeed2 > 0 and g_i3k_game_context:GetBaseItemCanUseCount(moneyType2) < moneyNeed2 then
		g_i3k_ui_mgr:PopupTipMessage(string.format("%s不足，购买失败", i3k_db_base_item[moneyType2].name))
	elseif not g_i3k_game_context:IsBagEnough({[itemId] = itemCount}) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
	else
		self.buyInfo[self.shopType].buySync(self._id, self.info, self._discount, self._discountCfg)
	end
	g_i3k_ui_mgr:CloseUI(eUIID_PersonShopBuy)
end

function wnd_create(layout, ...)
	local wnd = wnd_person_shop_buy.new()
	wnd:create(layout, ...)
	return wnd
end
