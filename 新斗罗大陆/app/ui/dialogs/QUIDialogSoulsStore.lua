--
-- Author: xurui
-- Date: 2015-05-19 17:00:04
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulsStore = class("QUIDialogSoulsStore", QUIDialog)

local QNotificationCenter = import("...controllers.QNotificationCenter")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetStoreBoss = import("..widgets.QUIWidgetStoreBoss")
local QUIWidgetStoreItmeBox = import("..widgets.QUIWidgetStoreItmeBox")
local QUIWidgetShopTap = import("..widgets.QUIWidgetShopTap")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIDialogStoreDetail = import("..dialogs.QUIDialogStoreDetail")
local QShop = import("...utils.QShop")
local QVIPUtil = import("...utils.QVIPUtil")
local QQuickWay = import("...utils.QQuickWay")
local QUIDialogPreview = import("..dialogs.QUIDialogPreview")
local QScrollView = import("...views.QScrollView") 
local QUIWidgetSmallAwardsAlert = import("..widgets.QUIWidgetSmallAwardsAlert")
local QListView = import("...views.QListView")

function QUIDialogSoulsStore:ctor(options)
	local ccbFile = "ccb/Dialog_shop.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerNormal", callback = handler(self, self._onTriggerNormal)},
		-- {ccbCallbackName = "onTriggerPreView", callback = handler(self, self._onTriggerPreView)},
		{ccbCallbackName = "onTriggerGetSoulMoney", callback = handler(self, self._onTriggerGetSoulMoney)},
		{ccbCallbackName = "onTriggerRecharge", callback = handler(self, self._onTriggerRecharge)},
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerRight)},
		{ccbCallbackName = "onTriggerQuickBuy", callback = handler(self, self._onTriggerQuickBuy)},
	}
	QUIDialogSoulsStore.super.ctor(self, ccbFile, callBacks, options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setAllUIVisible(false)
	page._scaling:willPlayHide()
	
    CalculateUIBgSize(self._ccbOwner.sp_bg)

	q.setButtonEnableShadow(self._ccbOwner.btn_preview)
	q.setButtonEnableShadow(self._ccbOwner.btn_refresh)
	q.setButtonEnableShadow(self._ccbOwner.btn_auto_buy)
	
	self._hideWidgetChat = false
	if page.widgetChat:isVisible() then
		page.widgetChat:setVisible(false)
		self._hideWidgetChat = true
	end

	self._rowMaxCount = 3 -- 商店货架一排3个

	self:resetAll()

	self._isMove = false
	self._itemBoxAniamtion = false

	if options.type ~= nil then
		self.shopType = options.type
	end

	print("魂师商店ID self.shopType = ",self.shopType)
	self.shopInfo = remote.stores:getShopResousceByShopId(self.shopType)


	if self.shopInfo.preview == nil then
		self._ccbOwner.node_btn_preview:setVisible(false)
	end

	self:chooseResources()
	local style = string.split(self.shopInfo.moneyType, "^")
	if style then
		page.topBar:showWithStyle(style)
	end

	local refreshShop =  remote.stores:checkCanRefreshShop2(self.shopType)
	if refreshShop == true or refreshShop == nil then
		self:getItem()
	end

	self:setRefreshTime()
	self:checkNextShop()
	self:checkQuickBuyBtn()

	local unlock = app.tip:getUnlockTutorial()
	if unlock["heroShop"] == 1 then
		unlock["heroShop"] = 2
		app.tip:setUnlockTutorial(unlock) 

		self._awardsAlert = QUIWidgetSmallAwardsAlert.new({awards = awards, index = 1, isLabel = true,callBack = function(index)
			if self._awardsAlert ~= nil then
				self._awardsAlert:removeFromParentAndCleanup(true)
				self._awardsAlert = nil
			end
		end})
		app.tutorialNode:addChild(self._awardsAlert)
		self._awardsAlert:setPosition(ccp(display.width/2, display.height/2))
	end

	self:autoView()
	self:_initShopItemData()
end

function QUIDialogSoulsStore:autoView()
	self._ccbOwner.sp_partition:setVisible(false)
	-- 设置底部桌面的宽度（适配）
	-- local _s9sBottomHeight = self._ccbOwner.s9s_bottom:getContentSize().height
	-- self._ccbOwner.s9s_bottom:setPreferredSize(CCSize(self._ccbOwner.node_follow_bottom:getContentSize().width, _s9sBottomHeight))
	
	-- 设置货架高度（适配）	
	-- local _s9sLfetAndRightWidth = self._ccbOwner.s9s_left:getContentSize().width
	-- self._s9sLeftAndRightHeight = (self._ccbOwner.node_follow_top:getPositionY()+self._ccbOwner.node_top_offset:getPositionY()) - (self._ccbOwner.node_follow_bottom:getPositionY()+self._ccbOwner.node_bottom_offset:getPositionY())
	-- self._ccbOwner.s9s_left:setPreferredSize(CCSize(_s9sLfetAndRightWidth, self._s9sLeftAndRightHeight))
	-- self._ccbOwner.s9s_right:setPreferredSize(CCSize(_s9sLfetAndRightWidth, self._s9sLeftAndRightHeight))
	self._s9sLeftAndRightHeight = self._ccbOwner.s9s_left:getContentSize().height
	
	-- 设置货架商品显示区域（即滑动区域，适配）
	-- local _lyWidth = self._ccbOwner.sheet_layout:getContentSize().width
	-- self._ccbOwner.sheet_layout:setContentSize(CCSize(_lyWidth, self._s9sLeftAndRightHeight))
	-- print(self._ccbOwner.node_follow_top:getPositionY(), self._ccbOwner.node_top_offset:getPositionY(), self._ccbOwner.node_follow_bottom:getPositionY(), self._ccbOwner.node_bottom_offset:getPositionY())
end


function QUIDialogSoulsStore:checkQuickBuyBtn()
	self._ccbOwner.node_btn_preview:setVisible(false)
	self._ccbOwner.node_btn_auto_buy:setVisible(true)
	self._ccbOwner.node_btn_refresh:setVisible(true)
	self._ccbOwner.node_btn_refresh:setPositionX(-240)

	local shopData = db:getShopDataByID(self.shopType)
	local unlockData = app.unlock:getConfigByKey(shopData.unlock_shop) or {}
	local configLevel = db:getConfiguration()["show_button"].value or 0

	if app.unlock:checkLock("UNLOCK_HERO_SHOP_EASY_BUY", false) == false then 
		self._ccbOwner.node_btn_auto_buy:setVisible(false)
		self._ccbOwner.node_btn_refresh:setPositionX(-97)
	elseif remote.user.level < (unlockData.team_level or 0) + configLevel then
		makeNodeFromNormalToGray(self._ccbOwner.node_btn_auto_buy)
		self._ccbOwner.node_btn_auto_buy_effect:setVisible(false)
	else
		makeNodeFromGrayToNormal(self._ccbOwner.node_btn_auto_buy)
		self._ccbOwner.node_btn_auto_buy_effect:setVisible(app.tip:checkReduceUnlokState("shopQuickBuy"))
	end
end

function QUIDialogSoulsStore:viewDidAppear()
	QUIDialogSoulsStore.super.viewDidAppear(self)

    self._activityProxy = cc.EventProxy.new(remote.activity)
    self._activityProxy:addEventListener(remote.activity.EVENT_UPDATE, handler(self, self.onEvent))

	self._itemProxy = cc.EventProxy.new(remote.items)
	self._itemProxy:addEventListener(remote.items.EVENT_ITEMS_UPDATE, handler(self, self.itemsUpdateEventHandler))

	QNotificationCenter.sharedNotificationCenter():addEventListener(QUIDialogStoreDetail.ITEM_SELL_FAIL, self.getItem, self)
	QNotificationCenter.sharedNotificationCenter():addEventListener(QUIDialogStoreDetail.ITEM_SELL_SCCESS, self.sellItemSuccess, self)
	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.STORE_QUICK_BUY_IS_END, self._quickBuyIsEnd, self)

	self:addBackEvent()

	local showTips = remote.stores:checkNewShopGoodsView(self.shopType)
	if showTips then
		self.chooseItem = {}
		app:getUserOperateRecord():setShopQuickBuyConfiguration(self.shopType,{})
		app.tip:floatTip("魂师大人，您已可以购买更高级物品，快去重新设置吧~")
	end
end

function QUIDialogSoulsStore:viewWillDisappear()
	QUIDialogSoulsStore.super.viewWillDisappear(self)

    self._activityProxy:removeAllEventListeners()

	QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIDialogStoreDetail.ITEM_SELL_SCCESS, self.sellItemSuccess, self)
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIDialogStoreDetail.ITEM_SELL_FAIL, self.getItem, self)
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.STORE_QUICK_BUY_IS_END, self._quickBuyIsEnd, self)
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
	if self._timeCountDown ~= nil then
		scheduler.unscheduleGlobal(self._timeCountDown)
		self._timeCountDown = nil
	end

	if self._checkItemScheduler ~= nil then
		scheduler.unscheduleGlobal(self._checkItemScheduler)
		self._checkItemScheduler = nil
	end

	if self._itemProxy then
		self._itemProxy:removeAllEventListeners()
	end

	self:clearItembox()

	if self._timeScheduler1 ~= nil then
		scheduler.unscheduleGlobal(self._timeScheduler1)
		self._timeScheduler1 = nil
	end

	if self._timeScheduler2 ~= nil then
		scheduler.unscheduleGlobal(self._timeScheduler2)
		self._timeScheduler2 = nil
	end

	if self._hideWidgetChat then
		local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
		page.widgetChat:setVisible(true)
	end

	self:removeBackEvent()
end

function QUIDialogSoulsStore:resetAll()
	self._ccbOwner.tf_refresh_count:setString("")
	self._ccbOwner.refresh_money:setString("")
	self._ccbOwner.tf_auto_refresh_time:setString("")
	self._ccbOwner.node_btn_recharge:setVisible(ENABLE_CHARGE(true))
	self._ccbOwner.node_btn_item:setVisible(false)
	self._ccbOwner.node_btn_award:setVisible(false)

	self._ccbOwner.node_btn_quick_buy:setVisible(false)
	self._ccbOwner.node_btn_set:setVisible(false)
	self._ccbOwner.node_btn_select:setVisible(false)
	self._ccbOwner.node_total_price_info:setVisible(false)
end

function QUIDialogSoulsStore:clearItembox()
	if self._listView then 
		self._listView:clear(true)
		self._listView = nil
	end
end

function QUIDialogSoulsStore:_quickBuyIsEnd()
	if self:safeCheck() then
		self:_setRefreshInfo()
		self:_initShopItemData()
	end
end

function QUIDialogSoulsStore:updateShopData()
	local storesInfo = remote.stores:getStoresById(self.shopType)
	if storesInfo == nil or next(storesInfo) == nil then 
		return 
	end
	self._data = {}
	for index, value in ipairs(storesInfo) do
		if index % self._rowMaxCount == 1 then
			value.isPartition = true
		end
		value.index = index
		table.insert(self._data, value)
	end
end

--初始化物品格子
function QUIDialogSoulsStore:_initShopItemData()
	self:updateShopData()
	if not self._data then return end
	self:_initListView()

	--检查是否有可出售物品
	self:checkSellItem()
	self:checkItemIsNeed()
	self:_setRefreshInfo()
end

function QUIDialogSoulsStore:_initListView()
	self._curOriginOffset = 10
	if self._data and #self._data <= 6 then
		local item = QUIWidgetStoreItmeBox.new()
		local size = item:getContentSize()
		local row = math.ceil(#self._data/self._rowMaxCount)
		self._curOriginOffset = (self._s9sLeftAndRightHeight - row * size.height) * 0.4
	end

	if not self._listView then
	    local cfg = {
	        renderItemCallBack = handler(self, self.renderItemHandler),
	        multiItems = self._rowMaxCount,
	        enableShadow = false,
	        ignoreCanDrag = false,
	        curOriginOffset = self._curOriginOffset,
	        totalNumber = #self._data,
	    }  
	    self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._listView:resetTouchRect()
		self._listView:reload({totalNumber = #self._data})
	end
end

function QUIDialogSoulsStore:getContentListView()
	return self._listView
end

function QUIDialogSoulsStore:renderItemHandler(list, index, info )
    local isCacheNode = true
    local itemData = self._data[index]
    local item = list:getItemFromCache()
    if not item then
    	item = QUIWidgetStoreItmeBox.new()
    	item:addEventListener(QUIWidgetStoreItmeBox.EVENT_CLICK, handler(self, self.sellClickHandler))
        isCacheNode = false
    end

    item:setItmeBox(itemData, self.shopType)

	self:_checkShowSoulEffect(item, itemData)

    info.item = item
    info.size = item:getContentSize()

    list:registerBtnHandler(index, "btn_item_click", "_onTirggerItemClick")
    list:registerBtnHandler(index, "btn_click", "_onTirggerClick")

    return isCacheNode
end

function QUIDialogSoulsStore:_checkShowSoulEffect(item, data)
	if not item or not data then return end

	local config = QStaticDatabase:sharedDatabase():getConfiguration()
	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(data.id)
	if itemConfig and itemConfig.type == 3 and data.count >= config["HERO_SHOP_EFFECT"].value then
		item:showSoulEffect()
	end
end

function QUIDialogSoulsStore:checkItemIsNeed()
    for i = 1, #self._data, 1 do 
    	if self._data[i].id ~= 0 then
    		local isNeed = remote.stores:checkItemIsNeed(self._data[i].id, self._data[i].count)
    		local item = self._listView:getItemByIndex(i)
    		if isNeed and item then
            	item:needItem()  
            end
		end
    end
end

function QUIDialogSoulsStore:itemsUpdateEventHandler(event)
	if self:safeCheck() then
		self:_initShopItemData()
	end
end

function QUIDialogSoulsStore:onEvent()
	self:_setRefreshInfo()
end

function QUIDialogSoulsStore:_setRefreshInfo()
	local refreshItemNums = remote.items:getItemsNumByID(22)
	local refreshCount = remote.stores:getRefreshCountById(self.shopType) or 0
	local vip = QStaticDatabase:sharedDatabase():getVipContnentByVipLevel(QVIPUtil:VIPLevel())
	if refreshItemNums ~= nil and refreshItemNums > 0 then
		local items = QStaticDatabase:sharedDatabase():getItemByID(22)
		self:createMoneyIcon(items.icon_1, 1)
		local num = 1
		self._ccbOwner.refresh_money:setString(refreshItemNums.."/"..num)
	else
		local refreshMoney, moneyType = self:getRefreshToken(refreshCount)
		local currencyInfo = remote.items:getWalletByType(moneyType)
		self:createMoneyIcon(currencyInfo.alphaIcon, 0.6)
		
		local word = refreshMoney == 0 and "免费" or refreshMoney
		self._ccbOwner.refresh_money:setString(word)
	end

	local vipLimit = vip.ylshop_limit
	if self.shopType ~= SHOP_ID.soulShop then
		vipLimit = vip.gnshop_limit
	end

	local refershNum = vipLimit - refreshCount
	refershNum = refershNum > 0 and refershNum or 0
	self._ccbOwner.tf_refresh_count:setString(refershNum)
end

function QUIDialogSoulsStore:createMoneyIcon(path, scale)
	if self._icon ~= nil then
		self._icon:removeFromParent()
		self._icon = nil
	end
    self._icon = CCSprite:create()
    self._icon:setTexture(CCTextureCache:sharedTextureCache():addImage(path))
    self._ccbOwner.icon_node:addChild(self._icon)
    self._ccbOwner.icon_node:setScale(scale or 1)
end

function QUIDialogSoulsStore:_onScrollViewMoving()
	self._isMove = true
end

function QUIDialogSoulsStore:_onScrollViewBegan()
	self._isMove = false
end

--根据不同的商店显示不同的资源
function QUIDialogSoulsStore:chooseResources()
	-- self._ccbOwner.tf_shop_name:setString(self.shopInfo.titleName)
	local isGetName = false
	local isGetAvatar = false
	if self.shopInfo then
		local namePath = self.shopInfo.namePath
		local avatarId = self.shopInfo.avatarId
		local avatarConfig

		if namePath then
			isGetName = QSetDisplayFrameByPath(self._ccbOwner.sp_shop_name, namePath)
		end
		if avatarId then
			avatarConfig = db:getDialogDisplayById(avatarId)
			if avatarConfig and avatarConfig.shop_card then
				avatarPath = avatarConfig.shop_card
			end
		end
		if avatarConfig then
			if avatarConfig.shop_card then
				isGetAvatar = QSetDisplayFrameByPath(self._ccbOwner.sp_avatar_img, avatarConfig.shop_card)
			end
			if avatarConfig.shop_x then
				self._ccbOwner.sp_avatar_img:setPositionX(avatarConfig.shop_x)
			end
			if avatarConfig.shop_y then
				self._ccbOwner.sp_avatar_img:setPositionY(avatarConfig.shop_y)
			end
			if avatarConfig.shop_scale then
				local turn = avatarConfig.shop_isturn or 1
				self._ccbOwner.sp_avatar_img:setScaleX(avatarConfig.shop_scale * turn)
				self._ccbOwner.sp_avatar_img:setScaleY(avatarConfig.shop_scale)
			end
			if avatarConfig.shop_rotation then
				self._ccbOwner.sp_avatar_img:setRotation(avatarConfig.shop_rotation)
			end
		end
	end
	if not isGetName then
		QSetDisplayFrameByPath(self._ccbOwner.sp_shop_name, QResPath("default_shop_name"))
	end
	if isGetAvatar then
		--切圖
		local size = self._ccbOwner.node_avatar_mask:getContentSize()
		local lyAvatarImageMask = CCLayerColor:create(ccc4(0,0,0,150), size.width, size.height)
		local ccclippingNode = CCClippingNode:create()
		lyAvatarImageMask:setPositionX(self._ccbOwner.node_avatar_mask:getPositionX())
		lyAvatarImageMask:setPositionY(self._ccbOwner.node_avatar_mask:getPositionY())
		lyAvatarImageMask:ignoreAnchorPointForPosition(self._ccbOwner.node_avatar_mask:isIgnoreAnchorPointForPosition())
		lyAvatarImageMask:setAnchorPoint(self._ccbOwner.node_avatar_mask:getAnchorPoint())
		ccclippingNode:setStencil(lyAvatarImageMask)
		ccclippingNode:setInverted(true)
		self._ccbOwner.sp_avatar_img:retain()
		self._ccbOwner.sp_avatar_img:removeFromParent()
		ccclippingNode:addChild(self._ccbOwner.sp_avatar_img)
		self._ccbOwner.node_avatar:addChild(ccclippingNode)
		self._ccbOwner.sp_avatar_img:release()
	end
	self._ccbOwner.sp_avatar_img:setVisible(isGetAvatar)
	
	self._ccbOwner.tf_auto_refresh_time:setVisible(true)
end

function QUIDialogSoulsStore:checkNextShop()
  	local nextShop = remote.stores:moveNextShop(self.shopType, "left", false)
  	if nextShop then
  		self._ccbOwner.btn_right:setVisible(false)
  		self._ccbOwner.btn_left:setVisible(false)
  	end
end

--设置下次刷新时间
function QUIDialogSoulsStore:setRefreshTime()
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end

	if self._timeCountDown ~= nil then
		scheduler.unscheduleGlobal(self._timeCountDown)
		self._timeCountDown = nil
	end

	local lastTime, nextTime, refreshWord = remote.stores:checkedShopBeforeRefreshTime(self.shopType)
	self._ccbOwner.tf_auto_refresh_time:setString(refreshWord)
	self:_generalRefreshTime(nextTime)
end

--普通商店刷新时间
function QUIDialogSoulsStore:_generalRefreshTime(time)
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
	remote.stores:setNextRefershTime(self.shopType, time)
	local offsetTime = q.serverTime()
	if offsetTime < time then
		self._timeHandler = scheduler.performWithDelayGlobal(function()
			if self:safeCheck() then
				self:setRefreshTime()
				self:refreshItems()
			end
		end,(time - offsetTime))
		printInfo(time - offsetTime)
	end
end

function QUIDialogSoulsStore:getRefreshToken(refreshCount)
	local tokeNum = 0
	local refreshInfo = QStaticDatabase:sharedDatabase():getTokenConsumeByType(self.shopInfo.refreshInfo)
	if refreshInfo ~= nil then
		for _, value in pairs(refreshInfo) do
			if value.consume_times == refreshCount + 1 then
				return value.money_num, value.money_type
			end
		end
	end
	return refreshInfo[#refreshInfo].money_num, refreshInfo[#refreshInfo].money_type
end


function QUIDialogSoulsStore:_onTriggerNormal()
	if self._itemBoxAniamtion then return end
	app.sound:playSound("common_small")

	local refreshCount = remote.stores:getRefreshCountById(self.shopType) or 0
    local refreshItemNum = remote.items:getItemsNumByID(22) or 0

	local vip = QStaticDatabase:sharedDatabase():getVipContnentByVipLevel(QVIPUtil:VIPLevel())
	local refershNum = vip.ylshop_limit - refreshCount
    if refershNum <= 0 then
        -- app.tip:floatTip("魂师大人大人，提升VIP等级可以增加商店刷新次数")
        self:_showVipAlert()
        return
    end
	local refreshToken, moneyType = self:getRefreshToken(refreshCount)
	refreshToken = refreshToken or 0
	local currencyInfo = remote.items:getWalletByType(moneyType)
	local money = remote.user[currencyInfo.name]
	if refreshItemNum == 0 and money < refreshToken then
			-- QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, 22, nil, nil, false)
		remote.stores:checkShopCurrencyQuickWay(currencyInfo.name)
		return
	end

	if not self:_checkRefresh() then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogNpcPrompt", 
			options = {content ="魂师大人，您有未购买的7折碎片哟，确定要刷新吗？", comfirmCallback = function ()
				self:shopRefresh()
    		end}})
		return
	end
	self:shopRefresh()
end

function QUIDialogSoulsStore:shopRefresh()
	app:getClient():refreshShop(self.shopType, function(data)
		if self.class ~= nil then
			remote.user:addPropNumForKey("todayRefreshShop501Count")
			if self._itemBoxAniamtion == false then
				self:itemBoxRunOutAction()
			end
		end
		remote.user:addPropNumForKey("c_resetSoulShopCount")
		remote.activity:updateLocalDataByType(526, 1)
	end,
	function(data)
	end)
end 

function QUIDialogSoulsStore:itemBoxRunOutAction()
	self._itemBoxAniamtion = true
	self.time = 0.08
	local index = 1
	self.func1 = function()
		if index <= self._rowMaxCount then
			local itemBox1, itemBox2
			if self._listView then
				itemBox1 = self._listView:getItemByIndex(index)
				itemBox2 = self._listView:getItemByIndex(index + self._rowMaxCount)
			end
			if itemBox1 ~= nil then
				local posx,posy = itemBox1:getPosition()
				local array1 = CCArray:create()
				array1:addObject(CCMoveTo:create(self.time, ccp(posx, posy - 5)))
				array1:addObject(CCMoveTo:create(self.time, ccp(posx, posy + self._s9sLeftAndRightHeight/2)))
				itemBox1:runAction(CCSequence:create(array1))
			end
			if itemBox2 ~= nil then
				local posx,posy = itemBox2:getPosition()
				local array2 = CCArray:create()
				array2:addObject(CCMoveTo:create(self.time, ccp(posx, posy + 5)))
				array2:addObject(CCMoveTo:create(self.time, ccp(posx, posy - self._s9sLeftAndRightHeight/2)))
				itemBox2:runAction(CCSequence:create(array2))
			end
			index = index + 1
			self._timeScheduler1 = scheduler.performWithDelayGlobal(self.func1, self.time)
		else
			self._checkItemScheduler = scheduler.performWithDelayGlobal(function()
				if self:safeCheck() then
					self:updateShopData()

					for i = 1, self._rowMaxCount do
						local itemBox1, itemBox2
						if self._listView then
							itemBox1 = self._listView:getItemByIndex(i)
							itemBox2 = self._listView:getItemByIndex(i + self._rowMaxCount)
						end
						if itemBox1 and self._data[i] then
							itemBox1:setItmeBox(self._data[i])
    						self:_checkShowSoulEffect(itemBox1, self._data[i])
						end
						if itemBox2 and self._data[i+self._rowMaxCount] then
							itemBox2:setItmeBox(self._data[i+self._rowMaxCount])
							self:_checkShowSoulEffect(itemBox2, self._data[i+self._rowMaxCount])
						end
					end
					self:itemBoxRunInAction()
				end
			end, 0.1)
		end
	end
	self.func1()
end 

function QUIDialogSoulsStore:itemBoxRunInAction()
	self._itemBoxAniamtion = true
	local index = 1
	self.func2 = function()
		if index <= self._rowMaxCount then
			local itemBox1 = self._listView:getItemByIndex(index)
			local itemBox2 = self._listView:getItemByIndex(index + self._rowMaxCount)
			if itemBox1 ~= nil then
				local posx,posy = itemBox1:getPosition()
				local array1 = CCArray:create()
				array1:addObject(CCMoveTo:create(self.time, ccp(posx, posy - (self._s9sLeftAndRightHeight/2 + 5))))
				array1:addObject(CCMoveTo:create(self.time, ccp(posx, posy - self._s9sLeftAndRightHeight/2)))
				itemBox1:runAction(CCSequence:create(array1))
			end
			if itemBox2 ~= nil then
				local posx,posy = itemBox2:getPosition()
				local array2 = CCArray:create()
				array2:addObject(CCMoveTo:create(self.time, ccp(posx, posy + (self._s9sLeftAndRightHeight/2 + 5))))
				array2:addObject(CCMoveTo:create(self.time, ccp(posx, posy + self._s9sLeftAndRightHeight/2)))
				itemBox2:runAction(CCSequence:create(array2))
			end
			index = index + 1
			self._timeScheduler2 = scheduler.performWithDelayGlobal(self.func2, self.time)
		else
			self._itemBoxAniamtion = false
			self:_setRefreshInfo()
		end
	end
	self.func2()
end 

function QUIDialogSoulsStore:getItem()
	app:getClient():getStores(self.shopType, function(data)
		if self:safeCheck() then
			self:_initShopItemData()
		end
	end)
end

--自动刷新物品
function QUIDialogSoulsStore:refreshItems()
	app:getClient():getStores(self.shopType, function(data)
		if self:safeCheck() then
			self:_initShopItemData()
		end
	end)
end


function QUIDialogSoulsStore:sellClickHandler(data)
	if self._isMove == false and self._itemBoxAniamtion == false then
		app.sound:playSound("common_small")
		if data.itemInfo.id == -1 then
			app.tip:floatTip("魂师大人，改物品不能购买")
			return
		end
		if data.isSell == false then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogStoreDetail",
				options = {shopId = self.shopType, itemInfo = data.itemInfo, index = data.index, isCombination = data.isCombination}},
			{isPopCurrentDialog = false})
		end
	end
end

function QUIDialogSoulsStore:removeEvent()
	if self._alert ~= nil then
		self._alert:removeAllEventListeners()
		self._alert = nil
	end
end

function QUIDialogSoulsStore:sellItemSuccess(data)
	if data ~= nil then
		local index = 1
		while true do
			local item = self._listView:getItemByIndex(index)
			if item then
				if index == data.index then
					item:_setItemIsSell()
				end
				item:setPieceNum()
				index = index + 1
			else
				break
			end
		end
		self:checkSellItem()
	end
end

function QUIDialogSoulsStore:checkSellItem()
	local sellItems = remote.items:getItemsByType(ITEM_CONFIG_TYPE.CONSUM_MONEY)
	if next(sellItems) ~= nil then
		if app.unlock:checkLock("UNLOCK_SELL_GOLDEN") and app:getUserOperateRecord():getStoreAutoSellItem() then
			local items = remote.items:getSellMoneyItem()
			items = remote.items:itemSort(items)
			app:getClient():sellItem(items, function(data)
		  		
			end)
		else
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSellItems"},{isPopCurrentDialog = false})
		end
	end
end

function QUIDialogSoulsStore:_onTriggerGetSoulMoney()
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroReborn", options = {tab = "recycle"}})
end

function QUIDialogSoulsStore:_onTriggerLeft()
	app.sound:playSound("common_small")
	remote.stores:moveNextShop(self.shopType, "left")
end

function QUIDialogSoulsStore:_onTriggerRight()
	app.sound:playSound("common_small")
	remote.stores:moveNextShop(self.shopType, "right")
end

function QUIDialogSoulsStore:_onTriggerQuickBuy()
	app.sound:playSound("common_small")
	
	local shopData = db:getShopDataByID(self.shopType)
	local unlockData = app.unlock:getConfigByKey(shopData.unlock_shop) or {}
	local configLevel = db:getConfiguration()["show_button"].value or 0
	if remote.user.level < (unlockData.team_level or 0) + configLevel then
		app.tip:floatTip(string.format("战队等级大于等于商店开放等级%d级后开启", configLevel))
		return
	end
	--一键购买解锁提示
	if app.tip:checkReduceUnlokState("shopQuickBuy") then
		app.tip:setReduceUnlockState("shopQuickBuy", 2)
		self._ccbOwner.node_btn_auto_buy_effect:setVisible(false)
	end
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogStoreQuickBuy", 
			options = {parentOptions = self:getOptions()}},{isPopCurrentDialog = true})
end

function QUIDialogSoulsStore:_onTriggerRecharge()
	app.sound:playSound("common_small")
	if ENABLE_CHARGE() then
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVIPRecharge"})
	end
end

function QUIDialogSoulsStore:_showVipAlert()
	app:vipAlert({title = "魂师商店可刷新次数", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.YLSHOP_LIMIT_COUNT}, false)
end

function QUIDialogSoulsStore:_checkRefresh()
	if self._listView then
		local index = 1
		while true do
			local item = self._listView:getItemByIndex(index)
			if item then
				if not item:checkRefresh() then
					return false
				end
				index = index + 1
			else
				break
			end
		end
	end

	return true
end

function QUIDialogSoulsStore:onTriggerBackHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogSoulsStore:onTriggerHomeHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogSoulsStore