--
-- Author: xurui
-- Date: 2015-04-21 10:24:15
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMallItemBox = class("QUIWidgetMallItemBox", QUIWidget)

local QShop = import("...utils.QShop")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIDialogMall = import("..dialogs.QUIDialogMall")
local QVIPUtil = import("...utils.QVIPUtil")
local QUIViewController = import("..QUIViewController")

QUIWidgetMallItemBox.MALL_ITEM_BOX_ICON_CLICK = "MALL_ITEM_BOX_ICON_CLICK"

function QUIWidgetMallItemBox:ctor(options)
	local ccbFile = "ccb/Widget_ShopVIP2.ccbi"
	local callBacks = {
	-- {ccbCallbackName = "onTriggerClickClient", callback = handler(self, self._onTriggerClick)},
	-- {ccbCallbackName = "onTriggerClickIcon", callback = handler(self, self._onTriggerClickIcon)},

	}
	QUIWidgetMallItemBox.super.ctor(self, ccbFile, callBacks, options)
	
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self:resetAll()

	self._nameMaxSize = 220
end

function QUIWidgetMallItemBox:onEnter()
	self.prompt = app:promptTips()
	self.prompt:addItemEventListener(self)
end

function QUIWidgetMallItemBox:onExit()
  	self.prompt:removeItemEventListener()
end

function QUIWidgetMallItemBox:resetAll()
	self._ccbOwner.item_name:setString("")
	self._ccbOwner.item_dec:setString("")
	self._ccbOwner.new_price:setString("")
	self._ccbOwner.buy_nums:setString("")
	self._ccbOwner.is_null:setVisible(false)
	self._ccbOwner.sale:setVisible(false)
	self._ccbOwner.recommend:setVisible(false)
	self._ccbOwner.hot_sell:setVisible(false)
	self._ccbOwner.sp_complete:setVisible(false)
	self._ccbOwner.btn_item:setVisible(false)
	-- for i = 1, 9 do
	-- 	self._ccbOwner["discount_"..i]:setVisible(false)
	-- end

	-- self._ccbOwner.chengDisCountBg:setVisible(false) 
	-- self._ccbOwner.lanDisCountBg:setVisible(false)
	-- self._ccbOwner.ziDisCountBg:setVisible(false)
	-- self._ccbOwner.hongDisCountBg:setVisible(false)
	-- self._ccbOwner.discountStr:setVisible(false)
end

function QUIWidgetMallItemBox:setItemBox(index,itemInfo, shopId,parentNode)
	self:resetAll()
	self._index = index
	self._position = itemInfo.position
	self._itemInfo = itemInfo 
	self._shopId = shopId
	self._awardsPanel = parentNode

	local itemConfig = nil
	local name = ""
	if self._itemInfo.itemType == "item" then
		itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self._itemInfo.id)
		if itemConfig == nil then return end
		name = itemConfig.name
	else
		itemConfig = remote.items:getWalletByType(self._itemInfo.itemType)
		name = itemConfig.nativeName
	end
	
	if self._itemBox == nil then
		self._itemBox = QUIWidgetItemsBox.new()
		self._itemBox:setPromptIsOpen(true)
		self._ccbOwner.item_node:addChild(self._itemBox)
	end
	local count = self._itemInfo.count == 1 and 0 or self._itemInfo.count
	self._itemBox:setGoodsInfo(self._itemInfo.id, self._itemInfo.itemType, count)

	if itemConfig ~= nil then
		self._ccbOwner.item_name:setString(name)
		self._ccbOwner.item_dec:setString(itemConfig.description or "")

		if itemConfig.colour ~= nil and remote.stores.itemQualityIndex[tonumber(itemConfig.colour)] ~= nil then
			local fontColor = BREAKTHROUGH_COLOR_LIGHT[remote.stores.itemQualityIndex[tonumber(itemConfig.colour)]]
			self._ccbOwner.item_name:setColor(fontColor)
			self._ccbOwner.item_name = setShadowByFontColor(self._ccbOwner.item_name, fontColor)

			local nameWidth = self._ccbOwner.item_name:getContentSize().width
			self._ccbOwner.item_name:setScale(1)
			if nameWidth > self._nameMaxSize then
				self._ccbOwner.item_name:setScale(1-(nameWidth - self._nameMaxSize)/self._nameMaxSize)
			end
		end

	end
	self._ccbOwner.hot_sell:setVisible(false)

	if self._shopId == SHOP_ID.vipShop then
		self._ccbOwner.btn_item:setVisible(true)
	end

	if self._shopId == SHOP_ID.itemShop then
		local money, moneyType = self:getBuyMoneyByBuyCount(self._itemInfo.buy_count)
		local itemMoney = (itemInfo.sale or 1) * money
		self._ccbOwner.token:setVisible(true)
		self._ccbOwner.new_price:setString(math.ceil(itemMoney))
	
		self.max_count = QVIPUtil:getMallItemMaxCountByVipLevel(self._itemInfo.good_group_id, QVIPUtil:VIPLevel())
		assert(self.max_count, "shop_limit_".. self._itemInfo.good_group_id .. " is null! when vip is ".. QVIPUtil:VIPLevel())
		if self.max_count - self._itemInfo.buy_count == 0 then
			self._ccbOwner.is_null:setVisible(true)
			self._ccbOwner.is_can_buy:setVisible(false)
		else
			self._ccbOwner.is_null:setVisible(false)
			self._ccbOwner.is_can_buy:setVisible(true)
			self._ccbOwner.buy_nums:setString("今日可购买:"..(self.max_count - self._itemInfo.buy_count).. "/" .. self.max_count)
		end

		local sale = self:calculaterDiscount(money)
		self:setSaleState(sale)
	else
		local itemMoney = (itemInfo.sale or 1) * self._itemInfo.cost
		self._ccbOwner.token:setVisible(true)
		self._ccbOwner.new_price:setString(math.floor(itemMoney))
		self.max_count = 1

		self._ccbOwner.is_null:setVisible(false)
		if self._itemInfo.count == 0 then
			self._ccbOwner.buy_nums:setString("已购买")
			self._ccbOwner.sp_complete:setVisible(true)
		else
			self._ccbOwner.buy_nums:setString("VIP"..itemInfo.vipLevel.."可购买")
		end
		self._ccbOwner.is_can_buy:setVisible(true)
	end

	self:setRedTip()
end

function QUIWidgetMallItemBox:getBuyMoneyByBuyCount(buyCount)
	local tokeNum = 0

	local moneyInfo = QStaticDatabase:sharedDatabase():getTokenConsumeByType(tostring(self._itemInfo.good_group_id))
	if moneyInfo ~= nil then
		for _, value in pairs(moneyInfo) do
			if value.consume_times == buyCount + 1 then
				return value.money_num, value.money_type
			end
		end
		return moneyInfo[#moneyInfo].money_num, moneyInfo[#moneyInfo].money_type
	end
	return 0, nil
end

function QUIWidgetMallItemBox:calculaterDiscount(realMoney)
	local discount = {0, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5}
	local goodInfo = QStaticDatabase:sharedDatabase():getGoodsGroupByGroupId(self._itemInfo.good_group_id)
	local money = goodInfo.money_num_1 or 0
	local sale = realMoney/money * 10
	for i = 2, #discount do
		if sale < discount[i] then
			sale = discount[i-1]
			break
		end
	end

	return sale
end

function QUIWidgetMallItemBox:setSaleState(sale)
	self:hidAllDiscountLabel()
	if sale == 0 then return end

	if sale < 10 then
		self._ccbOwner.sale:setVisible(true)
		if sale < 4 then
			self._ccbOwner.hongDisCountBg:setVisible(true)
		elseif sale < 7 then
			self._ccbOwner.ziDisCountBg:setVisible(true)
		else
			self._ccbOwner.lanDisCountBg:setVisible(true)
		end
		self._ccbOwner.discountStr:setString(string.format("%s折", sale))
	end
end

function QUIWidgetMallItemBox:hidAllDiscountLabel()
	self._ccbOwner.sale:setVisible(false)
	self._ccbOwner.chengDisCountBg:setVisible(false)
	self._ccbOwner.lanDisCountBg:setVisible(false)
	self._ccbOwner.ziDisCountBg:setVisible(false)
	self._ccbOwner.hongDisCountBg:setVisible(false)
end

function QUIWidgetMallItemBox:setRedTip(isVip)
	self._ccbOwner.red_tips:setVisible(false)
	
	if self._shopId == SHOP_ID.vipShop or self._shopId == SHOP_ID.weekShop then 
		if self._itemInfo.vipLevel <= QVIPUtil:VIPLevel() and self._itemInfo.count > 0 then
			self._ccbOwner.red_tips:setVisible(true)
		end
	end
end

function QUIWidgetMallItemBox:getContentSize()
	return self._ccbOwner.bg:getContentSize()
end

function QUIWidgetMallItemBox:setHotSell(state)
	self._ccbOwner.hot_sell:setVisible(state)
end

function QUIWidgetMallItemBox:_onTriggerClick()
	self:dispatchEvent({name = QUIDialogMall.MALL_BOX_CLICK, index = self._index,shopId = self._shopId, itemInfo = self._itemInfo, maxNum = self.max_count, pos = self._position})
end

function QUIWidgetMallItemBox:_onTriggerClickIcon()
	print("查看物品信息-=---------")
	-- if self._shopId == SHOP_ID.vipShop then
	-- 	self:dispatchEvent({name = QUIDialogMall.MALL_VIP_BOX_ICON_CLICK, shopId = self._shopId, itemInfo = self._itemInfo})
	-- else
	-- 	self:_onTriggerClick()
	-- end
end

return QUIWidgetMallItemBox