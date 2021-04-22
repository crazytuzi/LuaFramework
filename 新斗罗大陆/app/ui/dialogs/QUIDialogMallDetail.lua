--
-- Author: xurui
-- Date: 2015-04-24 10:24:15
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMallDetail = class("QUIDialogMallDetail", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("...ui.QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QQuickWay = import("...utils.QQuickWay")

QUIDialogMallDetail.ARENA_BUY_SUCCESS = "ARENA_BUY_SUCCESS"

function QUIDialogMallDetail:ctor(options)
	local ccbFile = "ccb/Dialog_Shop_Buymore.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onSub", callback = handler(self, self._onSub)},
		{ccbCallbackName = "onPlus", callback = handler(self, self._onPlus)},
		{ccbCallbackName = "onSubTen", callback = handler(self, self._onSubTen)},
		{ccbCallbackName = "onPlusTen", callback = handler(self, self._onPlusTen)},
		{ccbCallbackName = "onMax", callback = handler(self, self._onMax)},
		{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)}
	}
	QUIDialogMallDetail.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true
	
	q.setButtonEnableShadow(self._ccbOwner.btn_close)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._nameMaxSize = 120
	self._ccbOwner.frame_tf_title:setString("购 买")
	q.setButtonEnableShadow(self._ccbOwner.btn_close)
	q.setButtonEnableShadow(self._ccbOwner.btn_plusOne)
	q.setButtonEnableShadow(self._ccbOwner.btn_plusTen)
	q.setButtonEnableShadow(self._ccbOwner.btn_subOne)
	q.setButtonEnableShadow(self._ccbOwner.btn_subTen)
	q.setButtonEnableShadow(self._ccbOwner.btn_ok)
	printTable(options)
	if options ~= nil then
		self.shopId = options.shopId
		self.itemInfo = options.itemInfo
		self.maxNum = options.maxNum
		self.position = options.pos
		self._callback = options.callBack or options.callback
		self._isGemstone = options.isGemstone
		self._isMountBox = options.isMountBox
		self._sale = options.sale
	end
	self._isBuy = false
	self._currencyInfos = {}
	self:setBuyMoneyByBuyCount()

	self._ccbOwner.node_2:setVisible(false)
	self._ccbOwner.buy_content:setString("确认购买")
	if options.btnName then
		self._ccbOwner.buy_content:setString(options.btnName)
	end

	self.maxNum = self.maxNum - self.itemInfo.buy_count
	self.nums = 1
	self.percent = self.itemInfo.sale or 1

	local count = self.itemInfo.buy_count == 0 and 1 or (self.itemInfo.buy_count+1)
	self.needMoney = self:getBuyMoneyByBuyCount(count)

	if self.shopId == SHOP_ID.vipShop or self.shopId == SHOP_ID.weekShop then
		self.needMoney = self.itemInfo.cost
	end
	self:setItemBoxInfo()

	-- 外传打折
	if not self._sale then
		self._sale = self:calculaterDiscount(self.needMoney)
	end
	self:setSaleState(self._sale)

	if self.shopId == SHOP_ID.vipShop then
		self._ccbOwner.node_next_price:setVisible(false)
		self._ccbOwner.tf_content1:setString("可购买")
		self._ccbOwner.tf_content2:setString("次")
		self._ccbOwner.node_buy_num:setPositionX(50)
	end
end

function QUIDialogMallDetail:viewDidAppear()
	QUIDialogMallDetail.super.viewDidAppear(self)
end

function QUIDialogMallDetail:viewWillDisappear()
	QUIDialogMallDetail.super.viewWillDisappear(self)

	if self._calculatorScheduler then
		scheduler.unscheduleGlobal(self._calculatorScheduler)
		self._calculatorScheduler = nil
	end
end

function QUIDialogMallDetail:hidAllDiscountLabel()
	self._ccbOwner.sale:setVisible(false)
	self._ccbOwner.chengDisCountBg:setVisible(false)
	self._ccbOwner.lanDisCountBg:setVisible(false)
	self._ccbOwner.ziDisCountBg:setVisible(false)
	self._ccbOwner.hongDisCountBg:setVisible(false)
end

function QUIDialogMallDetail:setSaleState(sale)
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

function QUIDialogMallDetail:setItemBoxInfo()
	local itemConfig = nil
	local name = ""
	if self.itemInfo.itemType == "item" then
		itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self.itemInfo.id)
		if itemConfig == nil then return end
		name = itemConfig.name
		self._itemNum = remote.items:getItemsNumByID(self.itemInfo.id)
	else
		itemConfig = remote.items:getWalletByType(self.itemInfo.itemType)
		name = itemConfig.nativeName
		self._itemNum = remote.user[itemConfig.name]
	end
	local itemBox = QUIWidgetItemsBox.new()
	itemBox:setGoodsInfo(tonumber(self.itemInfo.id), self.itemInfo.itemType, tonumber(self.itemInfo.count))
	self._ccbOwner.node_icon:addChild(itemBox)

	if itemConfig ~= nil then
		self._ccbOwner.item_name:setString(name)
	end

	-- local itemNum = remote.items:getItemsNumByID(tonumber(self.itemInfo.id))
	self._ccbOwner.have_num:setString(self._itemNum or 0)

	local oneMoney = self:getBuyMoneyByBuyCount(self.itemInfo.buy_count+1)
	if self.shopId == SHOP_ID.vipShop or self.shopId == SHOP_ID.weekShop then
		oneMoney = self.needMoney
	end
	self._ccbOwner.one_sell_money:setString(math.floor((oneMoney * self.percent) or 0))
	self._ccbOwner.tf_currency_1:setString(math.floor(self.needMoney * self.percent))
	self:setCurrencyInfo()

	self._ccbOwner.buy_count:setString(self.maxNum)

	self._ccbOwner.item_num:setString(self.nums .. "/" .. self.maxNum)

	local nameWidth = self._ccbOwner.item_num:getContentSize().width
	self._ccbOwner.item_num:setScale(1)
	if nameWidth > self._nameMaxSize then
		self._ccbOwner.item_num:setScale(1-(nameWidth - self._nameMaxSize)/self._nameMaxSize)
	end

	-- if self.shopId == SHOP_ID.vipShop or self.shopId == SHOP_ID.weekShop then
	-- 	self._ccbOwner.buy_count_node:setVisible(false)
	-- end
end	

function QUIDialogMallDetail:setCurrencyInfo()
  	local path = remote.items:getWalletByType("token").alphaIcon
  	
  	if path ~= nil then
	    local icon = CCSprite:create()
	    icon:setTexture(CCTextureCache:sharedTextureCache():addImage(path))
	    self._ccbOwner["node_currency_"..1]:addChild(icon)
	    self._ccbOwner["node_currency_"..1]:setScale(0.6)
  	end
end

function QUIDialogMallDetail:setNums()
	self.needMoney = 0
	local buyCount = self.itemInfo.buy_count 
	for i = self.itemInfo.buy_count, buyCount+self.nums-1, 1 do
		local currentMoney = self:getBuyMoneyByBuyCount(i+1) * self.percent
		if self.shopId == SHOP_ID.vipShop or self.shopId == SHOP_ID.weekShop then
			currentMoney = self.itemInfo.cost * self.percent
		end

		-- if self.needMoney + currentMoney <= remote.user.token then
		self.needMoney = self.needMoney + currentMoney
		buyCount = buyCount + 1
		-- else
		-- 	self.nums = buyCount
		-- 	self._isMaxNum = true
		-- 	break
		-- end
	end


	local nextMoney = self:getBuyMoneyByBuyCount(buyCount+1)
	if self.shopId == SHOP_ID.vipShop or self.shopId == SHOP_ID.weekShop then
		nextMoney = self.itemInfo.cost
	end
	self._ccbOwner.one_sell_money:setString(math.floor((nextMoney * self.percent) or 0))
	self._ccbOwner.tf_currency_1:setString(math.floor(self.needMoney or 0))
	self._ccbOwner.item_num:setString(self.nums .. "/" .. self.maxNum)
	local nameWidth = self._ccbOwner.item_num:getContentSize().width
	self._ccbOwner.item_num:setScale(1)
	if nameWidth > self._nameMaxSize then
		self._ccbOwner.item_num:setScale(1-(nameWidth - self._nameMaxSize)/self._nameMaxSize)
	end	
end

function QUIDialogMallDetail:setBuyMoneyByBuyCount()
	local moneyInfo = QStaticDatabase:sharedDatabase():getTokenConsumeByType(tostring(self.itemInfo.good_group_id))
	if moneyInfo ~= nil then
		for _, value in pairs(moneyInfo) do
			self._currencyInfos[value.consume_times] = {}
			self._currencyInfos[value.consume_times].money_num = value.money_num
			self._currencyInfos[value.consume_times].money_type = value.money_type
		end
	end
end

function QUIDialogMallDetail:getBuyMoneyByBuyCount(buyCount)
	if buyCount == 0 then return 0 end

	if buyCount > 0 and self._currencyInfos[buyCount] == nil and #self._currencyInfos > 0 then
		return self._currencyInfos[#self._currencyInfos].money_num or 0
	end
	if self._currencyInfos[buyCount] ~= nil then
		return self._currencyInfos[buyCount].money_num or 0
	end
	return 0
end

function QUIDialogMallDetail:calculaterDiscount(realMoney)
	local discount = {0, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5}
	local goodInfo = db:getGoodsGroupByGroupId(self.itemInfo.good_group_id)

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

function QUIDialogMallDetail:_onSub(event)
	app.sound:playSound("common_increase")

	-- self._isMaxNum = false
	if self.nums - 1 <= 0 then 
		self.nums = 1
	else
		self.nums = self.nums - 1
	end
	self:setNums()
end

function  QUIDialogMallDetail:_onSubTen(event)
	-- self._isMaxNum = false
	if tonumber(event) == CCControlEventTouchDown then
		self._ccbOwner.btn_subTen:setColor(ccc3(210, 210, 210))
		self:_onDownHandler(-10)
	else
		self._ccbOwner.btn_subTen:setColor(ccc3(255, 255, 255))
		app.sound:playSound("common_increase")
		self:_onUpHandler(-10)
	end
end

function  QUIDialogMallDetail:_onPlus(event)
	app.sound:playSound("common_increase")

	-- if self._isMaxNum then return end

	if self.nums + 1 > self.maxNum then 
		self.nums = self.maxNum
	else
		self.nums = self.nums + 1
	end
	self:setNums()
end

function  QUIDialogMallDetail:_onPlusTen(event)
	-- if self._isMaxNum then return end
	if tonumber(event) == CCControlEventTouchDown then
		self._ccbOwner.btn_plusTen:setColor(ccc3(210, 210, 210))
		self:_onDownHandler(10)
	else
		self._ccbOwner.btn_plusTen:setColor(ccc3(255, 255, 255))
		app.sound:playSound("common_increase")
		self:_onUpHandler(10)
	end
end

function QUIDialogMallDetail:_onUpHandler(num)
	self._isDown = false	
	self._isUp = true
	self:_subBuyNums(num)
end

function QUIDialogMallDetail:_onDownHandler(num)
	self._isDown = true
	self._isUp = false
	self._calculatorScheduler = scheduler.performWithDelayGlobal(function()
			self:_subBuyNums(num)
		end, 0.5)
end

function QUIDialogMallDetail:_subBuyNums(num)
	if self._calculatorScheduler then
		scheduler.unscheduleGlobal(self._calculatorScheduler)
		self._calculatorScheduler = nil
	end

	if self._isDown or self._isUp then
		if self.nums + num <= 0 then 
			self.nums = 1
		elseif self.nums + num > self.maxNum then 
			self.nums = self.maxNum
		elseif self.nums == 1 and num == 10 then
			self.nums = 10
		else
			self.nums = self.nums + num
		end
		self:setNums()

		if self._isUp then return end
		self._calculatorScheduler = scheduler.performWithDelayGlobal(function()
			self:_subBuyNums(num)
		end, 0.05)
	end
end

function  QUIDialogMallDetail:_onMax()
	app.sound:playSound("common_increase")
	self.nums = self.maxNum
	self:setNums()
end

function QUIDialogMallDetail:viewAnimationOutHandler()
	local callback = nil
	if self._callback then 
		callback = self._callback
	end

	self:removeSelfFromParent()

	if self._isBuy then
		if math.floor(self.needMoney*self.percent) > remote.user.token then
			QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
			return
		end

		-- 魂骨购买
		if self._isGemstone or self._isMountBox then
			local data = {num = self.nums}
			if callback then
				callback(data)
			end
			return
		end

		local nums = self.nums
		app:getClient():buyShopItem(self.shopId, self.itemInfo.position, self.itemInfo.id, self.itemInfo.count, self.nums, function(data)
				app.taskEvent:updateTaskEventProgress(app.taskEvent.MALL_BUY_TASK_EVENT, nums, false, false)
		 		if self.class ~= nil then
		 			if self.shopId == SHOP_ID.itemShop then
		 				local itemId = tostring(self.itemInfo.id)
			 			if itemId == "160" then
			 				remote.activity:updateLocalDataByType(556, self.nums)
			 			end
			 			if itemId == "10000006" then
			 				remote.activity:updateLocalDataByType(558, self.nums)
			 			end
			 			if itemId == "10000013" then
			 				remote.activity:updateLocalDataByType(559, self.nums)
			 			end
		 			end
		 			local data = {}
					data.num = self.nums
					if callback then
						callback(data)
					else
						self:dispatchEvent({name = QUIDialogMallDetail.ARENA_BUY_SUCCESS, money = self.needMoney})
						app.tip:floatTip("购买成功")
					end
		 		end
		 	end)
	end
end


function  QUIDialogMallDetail:_onTriggerOK(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end
	app.sound:playSound("common_confirm")
	if self.nums == 0 then 
		app.tip:floatTip("购买数量不能为0")
		return
	end
	self._isBuy = true
	self:_onTriggerClose()
end

function QUIDialogMallDetail:removeSelfFromParent()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogMallDetail:_backClickHandler()
	 self:_onTriggerClose()
end

function  QUIDialogMallDetail:_onTriggerClose(e)
	if e ~= nil then
	 	app.sound:playSound("common_close")
 	end
	self:playEffectOut()
end

return QUIDialogMallDetail 