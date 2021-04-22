-- @Author: Kumo
-- 功能商店一键快速购买
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogStoreFastClient = class("QUIDialogStoreFastClient", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollView = import("...views.QScrollView")
local QUIWidgetStoreFastClientCell = import("..widgets.QUIWidgetStoreFastClientCell")
local QVIPUtil = import("...utils.QVIPUtil")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QNotificationCenter = import("...controllers.QNotificationCenter")

function QUIDialogStoreFastClient:ctor(options)
	local ccbFile = "ccb/Dialog_EliteBattleAgain_yijiangoumai.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerStop", callback = handler(self, self._onTriggerStop)},
	}
	QUIDialogStoreFastClient.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	if options then
		self.chooseItem = options.chooseItem
		self.shopId = tonumber(options.shopId)
	end
	q.setButtonEnableShadow(self._ccbOwner.btn_close)
	q.setButtonEnableShadow(self._ccbOwner.btn_stop)
	self.moveTime = 0
	self.stop = false
	self.allItems = {}
	self.allItemsCell = {}
	self._totalHeight = 0
	self.index = 1
	self.animationIsEnd = false
	self.refreshTimes = 0
	self.allToken = 0
	self.allCurrency = 0
	self.allRefresh = 0
	self.allRefreshItemNum = 0
	self.useItemRefresh = false
	self.oldRefreshItemNums = remote.items:getItemsNumByID(22)  --刷新令
	self.shopInfo = remote.stores:getShopResousceByShopId(self.shopId)

	self._ccbOwner.frame_tf_title:setString("一键购买")

	self._ccbOwner.btn_close:setVisible(false)

	self:initScrollView()
end

function QUIDialogStoreFastClient:viewDidAppear()
	QUIDialogStoreFastClient.super.viewDidAppear(self)
	self._ccbOwner.node_btn_stop:setVisible(false)
	self:buyCurrentItems()
end

function QUIDialogStoreFastClient:viewWillDisappear()
	QUIDialogStoreFastClient.super.viewWillDisappear(self)

	if self.itemScheduler then
		scheduler.unscheduleGlobal(self.itemScheduler)
		self.itemScheduler = nil
	end
end

function QUIDialogStoreFastClient:initScrollView()
	local contentSize = self._ccbOwner.sheet_layout:getContentSize()

	self._scrollView = QScrollView.new(self._ccbOwner.sheet, contentSize, {bufferMode = 1, sensitiveDistance = 10, isNoTouch = true})
	self._scrollView:setHorizontalBounce(false)

    self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))
    self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))
end

function QUIDialogStoreFastClient:buyCurrentItems()
	if not self.chooseItem or not next(self.chooseItem) then 
		self:setAllItems()
		return 
	end
	-- 后端无法解析数据结构，需要前端重新包装
	local tbl = {}
	for _, list in pairs(self.chooseItem) do
		for _, value in ipairs(list) do
			if not self.moneyType and value.moneyType ~= "token" then
				self.moneyType = value.moneyType
			end
			if tonumber(value.id) then
				table.insert(tbl, {id = value.id, itemType = "item", moneyType = value.moneyType, moneyNum = tonumber(value.moneyNum)})
			else
				table.insert(tbl, {itemType = value.id, moneyType = value.moneyType, moneyNum = tonumber(value.moneyNum)})
			end
		end
	end
	if self.moneyType then
		self.currencyInfo = remote.items:getWalletByType(self.moneyType)
	end

	local refushCount = 0

	if self.shopId == tonumber(SHOP_ID.soulShop) then
		refushCount = app:getUserOperateRecord():getStoreQuickRefreshCount()
        if refushCount == nil then
            refushCount = QStaticDatabase:sharedDatabase():getConfigurationValue("HERO_SHOP_EASYBUY_AUTO")
        end
	end

	app:getClient():shopQuickBuyRequest(self.shopId, tbl, false, refushCount,function (data)
		if data and data.shopQuickBuyResponse and data.shopQuickBuyResponse.ShopQuickBuyList then
			-- 记录任务完成进度
			for _, value in ipairs(data.shopQuickBuyResponse.ShopQuickBuyList) do
				if value.selectItems then
					app.taskEvent:updateTaskEventProgress(app.taskEvent.THUNDER_STORE_BUY_TASK_EVENT, #value.selectItems)
				end
			end
			if 	self.shopId == tonumber(SHOP_ID.soulShop) then
				remote.user:addPropNumForKey("c_soulShopConsumeCount",data.shopQuickBuyResponse.buyCount)
        		remote.activity:updateLocalDataByType(525, data.shopQuickBuyResponse.buyCount)

        		remote.user:addPropNumForKey("todayRefreshShop501Count",data.shopQuickBuyResponse.refreshCount)
				remote.user:addPropNumForKey("c_resetSoulShopCount",data.shopQuickBuyResponse.refreshCount)
				remote.activity:updateLocalDataByType(526, data.shopQuickBuyResponse.refreshCount)
        	end
		end
		if data.items then remote.items:setItems(data.items) end
		self._data = data.shopQuickBuyResponse.ShopQuickBuyList
		self._stopType = data.shopQuickBuyResponse.stop_type
		if self:safeCheck() then
			self:buySuccess()
		end
	end, function()
		if self:safeCheck() then
			self:setAllItems()
		end
	end)
end

function QUIDialogStoreFastClient:buySuccess()
	if self.itemScheduler then
		scheduler.unscheduleGlobal(self.itemScheduler)
		self.itemScheduler = nil
	end
	local info = self._data[self.index]
	if info then
		self.refreshCount = info.rushIndex - 1
		local refreshMoney, moneyType = remote.stores:getShopRefreshToken(self.refreshCount, self.shopInfo.refreshInfo)
		if info.rushIndex == 0 then
			-- 不刷新直接购买，不算刷新次数
			refreshMoney = 0
		end
		if not self.moneyType then
			self.moneyType = moneyType
			self.currencyInfo = remote.items:getWalletByType(self.moneyType)
		end

		local buyToken = 0
		local buyCurrency = 0
		if info.selectItems then
			for _, value in ipairs(info.selectItems) do
				if value.moneyType == "token" then
					buyToken = buyToken + value.moneyNum
				else
					buyCurrency = buyCurrency + value.moneyNum
				end
			end
		else
			info.selectItems = {}
		end

		self.allToken = self.allToken + buyToken
		self.allCurrency = self.allCurrency + buyCurrency

		self.allRefresh = self.allRefresh + refreshMoney


		-- self.allItemsCell[self.index] = QUIWidgetStoreFastClientCell.new()
		-- self._scrollView:addItemBox(self.allItemsCell[self.index])
		-- local positionX = 0
		-- local positionY = - self._totalHeight
		-- self.allItemsCell[self.index]:setPosition(positionX, positionY)
		-- self.allItemsCell[self.index]:setInfo(info.selectItems, self.index, self.currencyInfo, refreshMoney, buyToken, buyCurrency, false, handler(self, self.checkCanRefreshShop))

		-- self._totalHeight = self._totalHeight + self.allItemsCell[self.index]:getContentSize().height
		-- self._scrollView:setRect(0, -self._totalHeight, 0, 0)

		-- self._scrollView:runToBottom(true, self.moveTime)
		-- self._scrollView:runToBottom(true)
		-- self.itemScheduler = scheduler.performWithDelayGlobal(function()
		-- 		self.allItemsCell[self.index]:setItemBox()
		-- 	end, self.moveTime)

		for _, value in pairs(info.selectItems) do
			self.allItems[#self.allItems+1] = value
		end
		self:checkCanRefreshShop()
	else
		self:setAllItems()
	end
end

function QUIDialogStoreFastClient:checkCanRefreshShop()
	self.index = self.index + 1
	self:buySuccess()
end

function QUIDialogStoreFastClient:stopBuy()
	self.stop = true
end

function QUIDialogStoreFastClient:setAllItems()
	-- self.index = self.index + 1
	if self.itemScheduler then
		scheduler.unscheduleGlobal(self.itemScheduler)
		self.itemScheduler = nil
	end

	if not self.moneyType then
		local _, moneyType = remote.stores:getShopRefreshToken(15, self.shopInfo.refreshInfo)
		self.moneyType = moneyType
		self.currencyInfo = remote.items:getWalletByType(self.moneyType)
	end

	self.allItemsCell[self.index] = QUIWidgetStoreFastClientCell.new()
	self._scrollView:addItemBox(self.allItemsCell[self.index])
	local positionX = 0
	local positionY = self._totalHeight
	self.allItemsCell[self.index]:setPosition(positionX, -positionY)
	self.allItemsCell[self.index]:setStopState(self._stopState)

	local refreshMoney, moneyTypeNew = remote.stores:getShopRefreshToken(self.refreshCount, self.shopInfo.refreshInfo)
	if self.shopId == tonumber(SHOP_ID.soulShop) then
		local refreshItemNums = remote.items:getItemsNumByID(22)  --刷新令
		local costRefreshItemNums = self.oldRefreshItemNums - refreshItemNums
		if costRefreshItemNums > 0 and costRefreshItemNums >= (self.index - 2) then
			self.allRefreshItemNum = self.index -2
			self.allRefresh = 0
		elseif costRefreshItemNums > 0 and costRefreshItemNums < (self.index - 2) then
			self.allRefreshItemNum = costRefreshItemNums
			self.allRefresh = self.allRefresh - refreshMoney * costRefreshItemNums
		else
			self.allRefreshItemNum = 0
		end 
		-- remote.activity:updateLocalDataByType(526, self.index -2)
	end


	self.allCurrency = self.allCurrency + self.allRefresh 

	self.allItems = self.allItemsCell[self.index]:setInfo(tostring(self.shopId),self.allItems, self.index, self.currencyInfo, self.allRefresh, self.allRefreshItemNum,self.allToken, self.allCurrency, true, handler(self, self.buyAllItemsDone))

	self._totalHeight = self._totalHeight + self.allItemsCell[self.index]:getContentSize().height
	self._scrollView:setRect(0, -self._totalHeight, 0, 0)

	self._scrollView:runToBottom(true)
	self.itemScheduler = scheduler.performWithDelayGlobal(function()
			self.allItemsCell[self.index]:setItemBox()
			if self._stopType then
				if self._stopType == 1 then
					app.tip:floatTip("货币不足无法刷新")
				elseif self._stopType == 2 then
					app.tip:floatTip("货币不足无法购买")
				end
			end
		end, self.moveTime)
end

function QUIDialogStoreFastClient:buyAllItemsDone()
	if self._scrollView then
		self._scrollView:stopAllActions()
	end
	scheduler.performWithDelayGlobal(function()
		self._scrollView:setTouchState(true)
		self._ccbOwner.node_btn_stop:setVisible(true)
		self._ccbOwner.tf_one:setString("确 认")
		self._ccbOwner.btn_close:setVisible(true)

		for _, value in pairs(self.allItemsCell) do
			value:setItemPrompt()
		end
		self.animationIsEnd = true
	end, 0)
end

function QUIDialogStoreFastClient:_onTriggerStop(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_stop) == false then return end
	app.sound:playSound("common_small")
	if self.animationIsEnd then
		self:_onTriggerClose()
	else
		self:stopBuy()
	end
end

function QUIDialogStoreFastClient:_onScrollViewMoving()
	self._isMove = true
end

function QUIDialogStoreFastClient:_onScrollViewBegan()
	self._isMove = false
end

function QUIDialogStoreFastClient:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogStoreFastClient:_onTriggerClose(event)
	-- if q.buttonEventShadow(event,self._ccbOwner.btn_close) == false then return end
	if self.animationIsEnd == false then return end

    app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogStoreFastClient:viewAnimationOutHandler()
	local callback = self._callback
	self:popSelf()
	if callback then
		callback()
	end
	QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.STORE_QUICK_BUY_IS_END})
end

return QUIDialogStoreFastClient