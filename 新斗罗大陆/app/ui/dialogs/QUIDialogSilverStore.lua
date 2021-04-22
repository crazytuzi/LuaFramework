--
-- Author: xurui
-- Date: 2016-07-27 19:09:38
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSilverStore = class("QUIDialogSilverStore", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("...ui.QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIDialogStoreDetail = import("..dialogs.QUIDialogStoreDetail")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetSilverStoreBox = import("..widgets.QUIWidgetSilverStoreBox")
local QUIDialogSilverStoreDetail = import("..dialogs.QUIDialogSilverStoreDetail")
local QUIWidgetStoreAwardsBox = import("..widgets.QUIWidgetStoreAwardsBox")
local QVIPUtil = import("...utils.QVIPUtil")
local QScrollView = import("...views.QScrollView") 
local QListView = import("...views.QListView")

QUIDialogSilverStore.SHOP_ITEM = "SHOP_ITEM"        -- 物品标签
QUIDialogSilverStore.SHOP_AWARDS = "SHOP_AWARDS"    -- 奖励标签

function QUIDialogSilverStore:ctor(options)
	local ccbFile = "ccb/Dialog_shop.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerItems", callback = handler(self, self._onTriggerItems)},
		{ccbCallbackName = "onTriggerAwards", callback = handler(self, self._onTriggerAwards)},
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerRight)},
	}
	QUIDialogSilverStore.super.ctor(self, ccbFile, callBacks, options)
	self._callback = nil
    CalculateUIBgSize(self._ccbOwner.sp_bg)
	if options ~= nil then
		self.shopType = options.shopId or options.type
		if options.callback then
		self._callback = options.callback 
		end
	end

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setAllUIVisible(false)
	page._scaling:willPlayHide()
	self._hideWidgetChat = false
	if page.widgetChat:isVisible() then
		page.widgetChat:setVisible(false)
		self._hideWidgetChat = true
	end

	ui.tabButton(self._ccbOwner.tab_item, "物品")
    ui.tabButton(self._ccbOwner.tab_award, "奖励")
    local tabs = {}
    table.insert(tabs, self._ccbOwner.tab_item)
    table.insert(tabs, self._ccbOwner.tab_award)
    self._tabManager = ui.tabManager(tabs)
    self._ccbOwner.sp_tab_item_red_tips:setVisible(false)
    
    self._rowMaxCount = 3 -- 商店货架一排3个

    q.setButtonEnableShadow(self._ccbOwner.btn_auto_buy)
    q.setButtonEnableShadow(self._ccbOwner.btn_refresh)
    
	self.titleLabelType = QUIDialogSilverStore.SHOP_ITEM 
	self._tabManager:selected(self._ccbOwner.tab_item)
	self._ccbOwner.node_btn_item:setVisible(true)

	self._itemBoxAniamtion = false
	self._isMove = false
	self.lineDistance = 20
	self.awardsItemBox = {}
	
	self.shopInfo = remote.stores:getShopResousceByShopId(self.shopType)
	if not self.shopInfo.arawdsId then
		self._ccbOwner.node_btn_item:setVisible(false)
		self._ccbOwner.node_btn_award:setVisible(false)
	end
	
	-- set shop top bar
	local style = string.split(self.shopInfo.moneyType, "^")
	if style then
		page.topBar:showWithStyle(style)
	end

	local refreshShop = remote.exchangeShop:checkCanRefreshShop(self.shopType)
	if refreshShop == true then
		remote.exchangeShop:exchangeShopGetRequest(self.shopType, function(data)
        		self:_initShopItemData()
			end)
	end

	self:autoView()
	self:_initShopItemData()
end

function QUIDialogSilverStore:autoView()
	self._ccbOwner.node_btn_preview:setVisible(false)
	self._ccbOwner.node_btn_recharge:setVisible(false)
	self._ccbOwner.sp_partition:setVisible(false)
	self._ccbOwner.node_btn_quick_buy:setVisible(false)
	self._ccbOwner.node_btn_set:setVisible(false)
	self._ccbOwner.node_btn_select:setVisible(false)
	self._ccbOwner.node_total_price_info:setVisible(false)
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

	-- if self.shopType and self.shopType == SHOP_ID.mockbattleShop then
	-- 	self._ccbOwner.node_btn_right:setVisible(false)
	-- 	self._ccbOwner.node_btn_left:setVisible(false)
	-- end

end

function QUIDialogSilverStore:activityOffline()
	if self.shopType and self.shopType == SHOP_ID.rushBuyShop then
		local imp = remote.activityRounds:getRushBuy()
    	if imp and not imp.isOpen then
			app:alert({content = "该活动下线了", title = "系统提示", callback = function (  )
	                app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
	            end},false,true)
		end
	end

	if self.shopType then
		local imp = nil
		if self.shopType == SHOP_ID.rushBuyShop then
			imp = remote.activityRounds:getRushBuy()
		end
		if imp and not imp.isOpen then
			app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
			app:alert({content = "该活动下线了", title = "系统提示", btns = {ALERT_BTN.BTN_OK}, callback = function (  )
	                app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
	            end},false,true)
		end
	end
end

function QUIDialogSilverStore:viewDidAppear()
	QUIDialogSilverStore.super.viewDidAppear(self)
	QNotificationCenter.sharedNotificationCenter():addEventListener(QUIDialogStoreDetail.ITEM_SELL_SCCESS, self._buySuccess, self)

	self._activityRoundsEventProxy = cc.EventProxy.new(remote.activityRounds)
	self._activityRoundsEventProxy:addEventListener(remote.activityRounds.RUSHBUY_UPDATE, handler(self, self.activityOffline))

	self:checkRedTips()
	self:chooseResources()

	self:addBackEvent()
end

function QUIDialogSilverStore:viewWillDisappear()
	QUIDialogSilverStore.super.viewWillDisappear(self)
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIDialogStoreDetail.ITEM_SELL_SCCESS, self._buySuccess, self)
	if self._activityRoundsEventProxy then
		self._activityRoundsEventProxy:removeAllEventListeners()
		self._activityRoundsEventProxy = nil
	end

	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end

	self:clearItembox()
	self:removeBackEvent()
end

function QUIDialogSilverStore:clearItembox()
	if self._listView then 
		self._listView:clear(true)
		self._listView = nil
	end
end

--倒计时
function QUIDialogSilverStore:_timeCountDown()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end

	local timeCount = 0
	if self.shopType == SHOP_ID.monthSignInShop then
		local nextMonthTime = q.getFirstTimeOfNextMonth()
		timeCount = nextMonthTime - q.serverTime()
	elseif self.shopType == SHOP_ID.crystalShop then
		local weektime = q.getFirstTimeOfWeek()
		local endTime = weektime + WEEK - q.serverTime()
		timeCount = endTime 
	end

	local str = ""
	if timeCount > 0 then
		local day = math.floor(timeCount/DAY)
		timeCount = timeCount%DAY
		str = q.timeToHourMinuteSecond(timeCount)
		if day > 0 then
			str = day.."天 "..str
		end
		self._schedulerHandler = scheduler.performWithDelayGlobal(function ()
			self:_timeCountDown()
		end,1)
	end
	self._ccbOwner.tf_auto_refresh_time:setString(str)
end

function QUIDialogSilverStore:_initShopItemData()
	self:getShopData()
	if not self._data then return end

	if self.titleLabelType == QUIDialogSilverStore.SHOP_ITEM then
		for index, value in ipairs(self._data) do
			if index % self._rowMaxCount == 1 then
				value.isPartition = true
			end
			value.index = index
		end

		self._curOriginOffset = 10
		if self._data and #self._data <= 6 then
			local item = QUIWidgetSilverStoreBox.new()
			local size = item:getContentSize()
			local row = math.ceil(#self._data/self._rowMaxCount)
			self._curOriginOffset = (self._s9sLeftAndRightHeight - row * size.height) * 0.4
		end
	else
		self._curOriginOffset = 0
	end
	-- QPrintTable(self._data)
	self:clearItembox()
	if self.titleLabelType == QUIDialogSilverStore.SHOP_ITEM then
		self._rowMaxCount = 3
		self._isVertical = true
		self:_initListView()
	elseif self.titleLabelType == QUIDialogSilverStore.SHOP_AWARDS then
		self._rowMaxCount = 1
		self._isVertical = false
		self:_initListView()
	end
end

function QUIDialogSilverStore:_initListView()
	if not self._listView then
	    local cfg = {
	        renderItemCallBack = handler(self, self.renderItemHandler),
	        multiItems = self._rowMaxCount,
	        isVertical = self._isVertical,
	        enableShadow = false,
	        ignoreCanDrag = false,
	        curOriginOffset = self._curOriginOffset,
	        curOffset = 10,
	        totalNumber = #self._data,
	    }  
	    self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._listView:resetTouchRect()
		self._listView:reload({totalNumber = #self._data})
	end
end

function QUIDialogSilverStore:getContentListView()
	return self._listView
end

function QUIDialogSilverStore:renderItemHandler(list, index, info )
    local isCacheNode = true
    local itemData = self._data[index]
    local item = list:getItemFromCache(self.titleLabelType)
    if not item then
    	if self.titleLabelType == QUIDialogSilverStore.SHOP_ITEM then
			item = QUIWidgetSilverStoreBox.new()
			item:addEventListener(QUIWidgetSilverStoreBox.SILVER_STORE_BOX_EVENT, handler(self, self.onClickItemBox))
		elseif self.titleLabelType == QUIDialogSilverStore.SHOP_AWARDS then
			item = QUIWidgetStoreAwardsBox.new()
			item:addEventListener(QUIWidgetStoreAwardsBox.EVENT_CLICK_AWARDS_BOX, handler(self, self.onClickItemBox))
		end

        isCacheNode = false
    end
    
    if self.titleLabelType == QUIDialogSilverStore.SHOP_ITEM then
		if self._ccbOwner.sp_partition:isVisible() == true then
			self._ccbOwner.sp_partition:setVisible(false)
		end
		item:setItmeBox(itemData)
	elseif self.titleLabelType == QUIDialogSilverStore.SHOP_AWARDS then
		if self._ccbOwner.sp_partition:isVisible() == false then
			self._ccbOwner.sp_partition:setVisible(true)
			local sp = item:getSpPartition()
			self._ccbOwner.sp_partition:setPositionY(sp:getPositionY())
		end
		item:setItmeBox(self.shopInfo, itemData)
	end
    info.tag = self.titleLabelType
    info.item = item
    info.size = item:getContentSize()

    if self.titleLabelType == QUIDialogSilverStore.SHOP_ITEM then
    	list:registerBtnHandler(index, "btn_item_click", "_onTirggerItemClick")
    end
    list:registerBtnHandler(index, "btn_click", "_onTirggerClick")
    return isCacheNode
end

function QUIDialogSilverStore:getShopData()
	local data = {}
	if self.titleLabelType == QUIDialogSilverStore.SHOP_ITEM then
		local shops = remote.exchangeShop:getShopInfoById(self.shopType)
		data = self:filterShopInfo(shops)
		table.sort(data, function(a, b)
			if a.show_grid_id and b.show_grid_id then
				return a.show_grid_id < b.show_grid_id
			else
				return a.grid_id < b.grid_id
			end
		end)
	elseif self.titleLabelType == QUIDialogSilverStore.SHOP_AWARDS then
		local awardsInfo = QStaticDatabase:sharedDatabase():getItemsByShopAwardsId(self.shopInfo.arawdsId)
		for i = 1, #awardsInfo, 1 do
			awardsInfo[i].position = i 
		end
		data = self:sortAwardsItem(awardsInfo)
	end

	self._data = {}
	for i, v in pairs(data) do
		if not db:checkItemShields(v.item_id) then
			table.insert(self._data, v)
		end
	end
	-- QKumo(data)
end

function QUIDialogSilverStore:filterShopInfo(shopInfo)
	local newShopInfos = {}
	local userLevel = remote.user.level or 0
	local vipLevel = QVIPUtil:VIPLevel() or 0
	for i = 1, #shopInfo do
		if userLevel >= shopInfo[i].team_minlevel and userLevel <= shopInfo[i].team_maxlevel and vipLevel >= shopInfo[i].vip_id then
			-- newShopInfos[i] = shopInfo[i]
			table.insert(newShopInfos , shopInfo[i])
		end
	end
	return newShopInfos
end 	

function QUIDialogSilverStore:sortAwardsItem(awardInfos)
	local awards = awardInfos
	local newAwards = {}
	local sellInfo = remote.stores:getAwardsShopById(tostring(self.shopInfo.arawdsId))
	if sellInfo == nil or sellInfo == "" then return awardInfos end
	sellInfo = string.split(sellInfo, ";")

	local index = 1
	for i = 1, #awards, 1 do
		local isSell = false
		for j = 1, #sellInfo, 1 do
			if tonumber(sellInfo[j]) == awards[i].position-1 then
				isSell = true
				table.insert(newAwards, awards[i])
				table.remove(sellInfo, j)
				break
			end
		end
		if not isSell then
			table.insert(newAwards, index, awards[i])
			index = index + 1
		end 
	end
	return newAwards
end

--根据不同的商店显示不同的资源
function QUIDialogSilverStore:chooseResources()
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

	if self.shopType == SHOP_ID.crystalShop or self.shopType == SHOP_ID.monthSignInShop then
		self._ccbOwner.node_follow_left_bottom:setVisible(true)
		self._ccbOwner.node_follow_right_botoom:setVisible(false)
		self._ccbOwner.node_refresh_count:setVisible(false)
		self._ccbOwner.tf_auto_refresh_title:setString("货物下次刷新时间：")
		self:_timeCountDown()

		local isOpen = remote.crystal:getIsOpenCrystalShop()
		self._ccbOwner.btn_left:setVisible(isOpen)
		self._ccbOwner.arrowLeft:setVisible(isOpen)
		self._ccbOwner.btn_right:setVisible(isOpen)
		self._ccbOwner.arrowRight:setVisible(isOpen)
	else
		self._ccbOwner.node_follow_left_bottom:setVisible(false)
		self._ccbOwner.node_follow_right_botoom:setVisible(false)
	end
end

function QUIDialogSilverStore:checkRedTips()
	self._ccbOwner.sp_tab_award_red_tips:setVisible(false)
	if remote.stores:checkAwardsShopCanBuyByShopId(self.shopInfo.arawdsId) then
		self._ccbOwner.sp_tab_award_red_tips:setVisible(true)
	end
end

function QUIDialogSilverStore:onClickItemBox(data)
	if self._isMove then return end

	app.sound:playSound("common_small")
	if data.canSell ~= nil and data.canSell == false then
		if tonumber(data.shopId) == tonumber(SHOP_ID.blackRockShop) then
			app.tip:floatTip("尚未满足兑换条件")
		else
			app.tip:floatTip("尚未满足购买条件")
		end
		return
	end 
	if data.itemInfo.id == -1 then
		app.tip:floatTip("魂师大人，该物品不能购买")
		return
	end
		
	if self.titleLabelType == QUIDialogSilverStore.SHOP_ITEM then
		local itemInfo = data.itemInfo
		local buyInfo = remote.exchangeShop:getShopBuyInfo(self.shopType)
		local buyNum = buyInfo[tostring(itemInfo.grid_id)] or 0
		local lostNum = (itemInfo.exchange_number or 99999999)-buyNum
		if lostNum <= 0 then
			if itemInfo.can_not_refresh == 1 then
				app.tip:floatTip("永久兑换次数已达上限")
			else
				if tonumber(data.shopId) == tonumber(SHOP_ID.crystalShop) or tonumber(data.shopId) == tonumber(SHOP_ID.silvesShop) then
					app.tip:floatTip("本周兑换次数已达上限")
				elseif	tonumber(data.shopId) == SHOP_ID.mockbattleShop then
					app.tip:floatTip("赛季兑换次数已达上限")
				elseif	tonumber(data.shopId) == SHOP_ID.monthSignInShop then
					app.tip:floatTip("本月兑换次数已达上限")
				else
					app.tip:floatTip("今日兑换次数已达上限")
				end
			end
			return 
		end

		local index = itemInfo.index
		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilverStoreDetail", 
		options = {shopId = self.shopType, itemInfo = itemInfo, index = index, callback = handler(self, self._exchangeSuccess)}})
	else
		local itemInfo = data.itemInfo
		local isSell = data.isSell
		if isSell == false then
			local shopId = self.shopInfo.arawdsId
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogStoreDetail",
				options = {shopId = shopId, itemInfo = itemInfo}},
			{isPopCurrentDialog = false})
		end
	end
end

function QUIDialogSilverStore:_exchangeSuccess(event)
	if self:safeCheck() then
		self:getShopData()
		local targetItem = self._data[event.index]
		print("[event.index]", event.index)
		-- QPrintTable(self._data)
		QPrintTable(targetItem)
		if self._listView then
			local item = self._listView:getItemByIndex(event.index)
			if item then
				if item.getItemInfo then
					local itemInfo = item:getItemInfo()
					-- QPrintTable(itemInfo)
					if itemInfo and itemInfo.grid_id == targetItem.grid_id then
						item:setItmeBox(targetItem)
						print("=111==== [END] =====")
						return
					end
				end
			end
			local index = 1
			while true do
				local item = self._listView:getItemByIndex(index)
				if item then
					if item.getItemInfo then
						local itemInfo = item:getItemInfo()
						print("[index] = ", index)
						-- QPrintTable(itemInfo)
						if itemInfo and itemInfo.grid_id == targetItem.grid_id then
							item:setItmeBox(targetItem)
							print("==222=== [END] =====")
							break
						end
					end
					index = index + 1
				else
					break
				end
			end
		end
	end
end

function QUIDialogSilverStore:_buySuccess()
	if self:safeCheck() then
		self:_initShopItemData()
		self:checkRedTips()
	end
end

function QUIDialogSilverStore:_onTriggerItems()
	if self.titleLabelType == QUIDialogSilverStore.SHOP_ITEM then return end
    app.sound:playSound("common_menu")

	self.titleLabelType = QUIDialogSilverStore.SHOP_ITEM
	self._tabManager:selected(self._ccbOwner.tab_item)

    self:_initShopItemData()
end

function QUIDialogSilverStore:_onTriggerAwards()
	if self._itemBoxAniamtion then return end
	if self.titleLabelType == QUIDialogSilverStore.SHOP_AWARDS then return end
    app.sound:playSound("common_menu")

	self.titleLabelType = QUIDialogSilverStore.SHOP_AWARDS
	self._tabManager:selected(self._ccbOwner.tab_award)

    self:_initShopItemData()

	if remote.stores:getAwardsShopState(self.shopInfo.arawdsId) == false then
		remote.stores:setAwardsShopState(self.shopInfo.arawdsId)
		self:checkRedTips()
	end
end

function QUIDialogSilverStore:_onTriggerLeft()
	app.sound:playSound("common_small")
	remote.stores:moveNextShop(self.shopType, "left")
end

function QUIDialogSilverStore:_onTriggerRight()
	app.sound:playSound("common_small")
	remote.stores:moveNextShop(self.shopType, "right")
end

function QUIDialogSilverStore:onTriggerBackHandler(tag)

    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	if self._callback then
		self._callback()
	end
end

function QUIDialogSilverStore:onTriggerHomeHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogSilverStore