-- @Author: xurui
-- @Date:   2017-02-23 15:46:27
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-03-26 16:14:41
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogStoreQuickClient = class("QUIDialogStoreQuickClient", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollView = import("...views.QScrollView")
local QUIWidgetStoreQuickClientCell = import("..widgets.QUIWidgetStoreQuickClientCell")
local QVIPUtil = import("...utils.QVIPUtil")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QNotificationCenter = import("...controllers.QNotificationCenter")

function QUIDialogStoreQuickClient:ctor(options)
	local ccbFile = "ccb/Dialog_EliteBattleAgain_yijiangoumai.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerStop", callback = handler(self, self._onTriggerStop)},
	}
	QUIDialogStoreQuickClient.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	q.setButtonEnableShadow(self._ccbOwner.btn_close)
	q.setButtonEnableShadow(self._ccbOwner.btn_stop)
	self._ccbOwner.tf_one:setString("立刻停止")
	if options then
		self.chooseItem = options.chooseItem
		self.shopId = options.shopId
		self.buyItems = options.buyItems
		self.buyToken = options.buyToken
		self.buyCurrency = options.buyCurrency
		self._callback = options.callback
	end

	self.moveTime = 0.5
	self.stop = false
	self.allItems = {}
	self.allItemsCell = {}
	self._totalHeight = 0
	self.index = 1
	self.animationIsEnd = false
	self.refreshTimes = 0
	self.allToken = self.buyToken or 0
	self.allCurrency = self.buyCurrency
	self.allRefresh = 0
	self.allRefreshItemNum = 0

	self.shopInfo = remote.stores:getShopResousceByShopId(self.shopId)

	self._currentResfreshTime = 0   --商店刷新次数记录

	self._ccbOwner.frame_tf_title:setString("一键购买")

	self._ccbOwner.btn_close:setVisible(false)

	self:initScrollView()
end

function QUIDialogStoreQuickClient:viewDidAppear()
	QUIDialogStoreQuickClient.super.viewDidAppear(self)

	self:buyCurrentItems()
end

function QUIDialogStoreQuickClient:viewWillDisappear()
	QUIDialogStoreQuickClient.super.viewWillDisappear(self)

	if self.itemScheduler then
		scheduler.unscheduleGlobal(self.itemScheduler)
		self.itemScheduler = nil
	end
end

function QUIDialogStoreQuickClient:initScrollView()
	local contentSize = self._ccbOwner.sheet_layout:getContentSize()

	self._scrollView = QScrollView.new(self._ccbOwner.sheet, contentSize, {bufferMode = 1, sensitiveDistance = 10, isNoTouch = true})
	self._scrollView:setHorizontalBounce(false)

    self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))
    self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))
end

function QUIDialogStoreQuickClient:buyCurrentItems(isUseItem)
	local itemList = {}
	for _, value in pairs(self.buyItems) do
		itemList[#itemList+1] = {shopId = self.shopId, pos = value.position, itemId = value.id, count = value.count, buyCount = 1}
	end
	-- QPrintTable(itemList)
	app:getClient():requestBuyShopItems(itemList, false, function()
		if #itemList > 0 then
			-- 记录任务完成进度
			app.taskEvent:updateTaskEventProgress(app.taskEvent.THUNDER_STORE_BUY_TASK_EVENT, #itemList)

			if self.shopId == SHOP_ID.soulShop then
				remote.user:addPropNumForKey("c_soulShopConsumeCount",#itemList)
	    		remote.activity:updateLocalDataByType(525, #itemList) 
			end

		end

		if self:safeCheck() then
			self:buySuccess(isUseItem)
		end
	end, function()
		if self:safeCheck() then
			self:setAllItems()
		end
	end)
end

function QUIDialogStoreQuickClient:buySuccess(isUseItem)
	if self.itemScheduler then
		scheduler.unscheduleGlobal(self.itemScheduler)
		self.itemScheduler = nil
	end

	local useItemNum = 0
	if isUseItem then
		useItemNum = 1
	end
	self.refreshCount = remote.stores:getRefreshCountById(self.shopId) or 0
	self.refreshMoney, self.moneyType = remote.stores:getShopRefreshToken(self.refreshCount-1, self.shopInfo.refreshInfo)
	self.currencyInfo = remote.items:getWalletByType(self.moneyType)

	self.allItemsCell[self.index] = QUIWidgetStoreQuickClientCell.new()
	self._scrollView:addItemBox(self.allItemsCell[self.index])
	local positionX = 0
	local positionY = - self._totalHeight
	self.allItemsCell[self.index]:setPosition(positionX, positionY)
	self.allItemsCell[self.index]:setInfo(self.shopId,self.buyItems, self.index, self.currencyInfo, self.refreshMoney, useItemNum,self.buyToken, self.buyCurrency, false, handler(self, self.checkCanRefreshShop))

	self._totalHeight = self._totalHeight + self.allItemsCell[self.index]:getContentSize().height
	self._scrollView:setRect(0, -self._totalHeight, 0, 0)

	self._scrollView:runToBottom(true, self.moveTime)
	self.itemScheduler = scheduler.performWithDelayGlobal(function()
			self.allItemsCell[self.index]:setItemBox()
		end, self.moveTime)

	for _, value in pairs(self.buyItems) do
		self.allItems[#self.allItems+1] = value
	end
end

function QUIDialogStoreQuickClient:checkCanRefreshShop()
	print("自动刷新商店self.stop=",self.stop)
	if self.stop then
		self:setAllItems()
		return
	end
	self._stopState = nil

	local isUseRefreshItem = false
	local vip = QStaticDatabase:sharedDatabase():getVipContnentByVipLevel(QVIPUtil:VIPLevel())
	local refershNum = vip.gnshop_limit - self.refreshCount
	if self.shopId == SHOP_ID.soulShop then
		local refreshItemNums = remote.items:getItemsNumByID(22)  --刷新令
		if refreshItemNums > 0 then
			isUseRefreshItem = true
		end

		refershNum = vip.ylshop_limit - self.refreshCount
		local curNum = app:getUserOperateRecord():getStoreQuickRefreshCount()
        if curNum == nil then
            curNum = QStaticDatabase:sharedDatabase():getConfigurationValue("HERO_SHOP_EASYBUY_AUTO")
        end		
		if self._currentResfreshTime >= curNum then
			self:setAllItems()
			return 			
		end
	end
	if refershNum <= 0 then
		self:setAllItems()
		return 
	end
	
	self.refreshMoney, self.moneyType = remote.stores:getShopRefreshToken(self.refreshCount, self.shopInfo.refreshInfo)
	if self.refreshMoney > remote.user[self.currencyInfo.name] then
		self._stopState = 3
		self:setAllItems()
	else
		app:getClient():refreshShop(self.shopId, function(data)
			if self:safeCheck() then
				if self.shopId == SHOP_ID.soulShop then
	        		remote.user:addPropNumForKey("todayRefreshShop501Count")
					remote.user:addPropNumForKey("c_resetSoulShopCount")
					remote.activity:updateLocalDataByType(526, 1)
				end
				local buyItems, canBuy, buyToken, buyCurrency, currencyItems, tokenItems = remote.stores:checkQuickBuyItemById(self.shopId, self.chooseItem, false)
				if canBuy then
					self.index = self.index + 1
					self.buyItems = buyItems
					self.buyToken = buyToken or 0
					self.buyCurrency = buyCurrency or 0

					self.allToken = self.allToken + self.buyToken
					self.allCurrency = self.allCurrency + self.buyCurrency 
					if isUseRefreshItem then
						self.allRefreshItemNum = self.allRefreshItemNum + 1
					else
						self.allRefresh = self.allRefresh + self.refreshMoney
					end

					-- self.allRefresh = self.allRefresh + self.refreshMoney

					self._currentResfreshTime = self._currentResfreshTime + 1

					self:buyCurrentItems(isUseRefreshItem)
				else
					local state = 2
					if currencyItems and next(currencyItems) then
						state = 1
					end
					self._stopState = state
					self.stop = true
					self.index = self.index + 1

					if isUseRefreshItem  then
						self.allRefreshItemNum = self.allRefreshItemNum + 1
					else
						self.allRefresh = self.allRefresh + self.refreshMoney
					end

					-- self.allRefresh = self.allRefresh + self.refreshMoney
					self.buyItems = {}
					self.buyToken = 0
					self.buyCurrency = 0
					self:buySuccess(isUseRefreshItem)
				end
			end
		end, function ()
			if self:safeCheck() then
				self:setAllItems()
			end
		end)
	end
end

function QUIDialogStoreQuickClient:stopBuy()
	self.stop = true
end

function QUIDialogStoreQuickClient:setAllItems()
	self.index = self.index + 1

	if self.itemScheduler then
		scheduler.unscheduleGlobal(self.itemScheduler)
		self.itemScheduler = nil
	end

	self.allCurrency = self.allCurrency + self.allRefresh 

	self.allItemsCell[self.index] = QUIWidgetStoreQuickClientCell.new()
	self._scrollView:addItemBox(self.allItemsCell[self.index])
	local positionX = 0
	local positionY = self._totalHeight
	self.allItemsCell[self.index]:setPosition(positionX, -positionY)
	self.allItemsCell[self.index]:setStopState(self._stopState)
	self.allItems = self.allItemsCell[self.index]:setInfo(self.shopId,self.allItems, self.index, self.currencyInfo, self.allRefresh, self.allRefreshItemNum,self.allToken, self.allCurrency, true, handler(self, self.buyAllItemsDone))

	self._totalHeight = self._totalHeight + self.allItemsCell[self.index]:getContentSize().height
	self._scrollView:setRect(0, -self._totalHeight, 0, 0)

	self._scrollView:runToBottom(true)
	self.itemScheduler = scheduler.performWithDelayGlobal(function()
			self.allItemsCell[self.index]:setItemBox()
		end, self.moveTime)

end

function QUIDialogStoreQuickClient:buyAllItemsDone()
	if self._scrollView then
		self._scrollView:stopAllActions()
	end
	scheduler.performWithDelayGlobal(function()
		self._scrollView:setTouchState(true)
		self._ccbOwner.tf_one:setString("确 认")
		self._ccbOwner.btn_close:setVisible(true)

		for _, value in pairs(self.allItemsCell) do
			value:setItemPrompt()
		end
		self.animationIsEnd = true
	end, 0)
end

function QUIDialogStoreQuickClient:_onTriggerStop(tag)
	app.sound:playSound("common_small")
	if self.animationIsEnd then
		self:_onTriggerClose()
	else
		self:stopBuy()
	end
end

function QUIDialogStoreQuickClient:_onScrollViewMoving()
	self._isMove = true
end

function QUIDialogStoreQuickClient:_onScrollViewBegan()
	self._isMove = false
end

function QUIDialogStoreQuickClient:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogStoreQuickClient:_onTriggerClose()
	if self.animationIsEnd == false then return end

    app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogStoreQuickClient:viewAnimationOutHandler()
	local callback = self._callback
	self:popSelf()
	if callback then
		callback()
	end
	QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.STORE_QUICK_BUY_IS_END})
end

return QUIDialogStoreQuickClient