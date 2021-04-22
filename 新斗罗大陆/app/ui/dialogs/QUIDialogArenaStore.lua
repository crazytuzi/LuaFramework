--
-- Author: xurui
-- Date: 2015-05-19 09:57:56
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogArenaStore = class("QUIDialogArenaStore", QUIDialog)

local QNotificationCenter = import("...controllers.QNotificationCenter")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetStoreItmeBox = import("..widgets.QUIWidgetStoreItmeBox")
local QUIWidgetStoreAwardsBox = import("..widgets.QUIWidgetStoreAwardsBox")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIDialogStoreDetail = import("..dialogs.QUIDialogStoreDetail")
local QVIPUtil = import("...utils.QVIPUtil")
local QListView = import("...views.QListView")
local QUIWidgetSilverStoreBox = import("..widgets.QUIWidgetSilverStoreBox")
local QUIDialogSilverStoreDetail = import("..dialogs.QUIDialogSilverStoreDetail")
local QUIWidgetSmallAwardsAlert = import("..widgets.QUIWidgetSmallAwardsAlert")

-- 功能商店标签类型
QUIDialogArenaStore.SHOP_ITEM = "SHOP_ITEM"        -- 物品标签
QUIDialogArenaStore.SHOP_AWARDS = "SHOP_AWARDS"    -- 奖励标签

function QUIDialogArenaStore:ctor(options)
	local ccbFile = "ccb/Dialog_shop.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerNormal", callback = handler(self, self._onTriggerNormal)},
		{ccbCallbackName = "onTriggerItems", callback = handler(self, self._onTriggerItems)},
		{ccbCallbackName = "onTriggerAwards", callback = handler(self, self._onTriggerAwards)},
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerRight)},
		{ccbCallbackName = "onTriggerQuickBuy", callback = handler(self, self._onTriggerQuickBuy)}
	}
	QUIDialogArenaStore.super.ctor(self, ccbFile, callBacks, options)
    CalculateUIBgSize(self._ccbOwner.sp_bg)

    self._callback = nil
	if options.callback then
		self._callback = options.callback 
	end
	if options.type ~= nil then
		self.shopId = options.type
	end

	if self.shopId and self.shopId == SHOP_ID.consortiaShop and (remote.user.userConsortia.consortiaId == nil or remote.user.userConsortia.consortiaId == "")  then
		app:alert({content = "您被移出宗门！", title = "系统提示", callback = function (state)
				if state == ALERT_TYPE.CONFIRM then
                	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
                end
            end},false,true)
		return
	end

	ui.tabButton(self._ccbOwner.tab_item, "物品")
    ui.tabButton(self._ccbOwner.tab_award, "奖励")
    local tabs = {}
    table.insert(tabs, self._ccbOwner.tab_item)
    table.insert(tabs, self._ccbOwner.tab_award)
    self._tabManager = ui.tabManager(tabs)

    self._rowMaxCount = 3 -- 商店货架一排3个
	
    q.setButtonEnableShadow(self._ccbOwner.btn_auto_buy)
    q.setButtonEnableShadow(self._ccbOwner.btn_refresh)

	self.titleLabelType = QUIDialogArenaStore.SHOP_ITEM
	self._tabManager:selected(self._ccbOwner.tab_item)
	self._ccbOwner.node_btn_item:setVisible(true)

	if FinalSDK.isHXShenhe() then
		self._ccbOwner.arrowLeft:setVisible(false)
		self._ccbOwner.btn_left:setVisible(false)
		self._ccbOwner.arrowRight:setVisible(false)
		self._ccbOwner.btn_right:setVisible(false)
		self._ccbOwner.node_btn_award:setVisible(false)
	end
	self:resetAll()

	self._itemBoxAniamtion = false
	self._isMove = false
	self.awardsItemBox = {}
	self._awardsInfo = {}

	self:updateShopView()
end

function QUIDialogArenaStore:updateToppageView( )
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.setAllUIVisible then
		page:setAllUIVisible(false)
	end
	if page._scaling and page._scaling.willPlayHide then
		page._scaling:willPlayHide()	
	end

	if FinalSDK.isHXShenhe() then
        page:setScalingVisible(false)
    end
	self._hideWidgetChat = false
	if page.widgetChat:isVisible() then
		page.widgetChat:setVisible(false)
		self._hideWidgetChat = true
	end
	local style = string.split(self.shopInfo.moneyType, "^")
	if style then
		page.topBar:showWithStyle(style)
	end	
end

function QUIDialogArenaStore:updateShopView( )

	self._proxy = remote.stores:getProxyById(self.shopId)

	self:clearItembox()
	self.titleLabelType = QUIDialogArenaStore.SHOP_ITEM
	self._tabManager:selected(self._ccbOwner.tab_item)

	self.shopInfo = remote.stores:getShopResousceByShopId(self.shopId)
	self:chooseResources()

	self:updateToppageView()
	if self.shopInfo.isExchangeShop then
		local refreshShop = remote.exchangeShop:checkCanRefreshShop(self.shopId)
		if refreshShop == true then
			remote.exchangeShop:exchangeShopGetRequest(self.shopId, function(data)
	        		self:_initShopItemData()
				end)
		end		
	else
		local refreshShop =  remote.stores:checkCanRefreshShop2(self.shopId)
		if refreshShop == true or refreshShop == nil then
			self:getItem()
		end
	end

	self:autoView()

	self:_initShopItemData()
	self:setRefreshTime()

	self:checkRedTips()
	self:checkNextShop()
	self:checkQuickBuyBtn()	
	self:checkLabelBtn()
	self._proxy:checkSpeckTips()
	self:checkUnlockTutorial()
	self:showDirectionBtn()
end

function QUIDialogArenaStore:checkUnlockTutorial()
	if self.shopId == SHOP_ID.blackShop then
		local unlock = app.tip:getUnlockTutorial()
		if unlock["black"] ~= 2 then
			unlock["black"] = 2
			app.tip:setUnlockTutorial(unlock) 
		end
	elseif self.shopId == SHOP_ID.soulShop then
		local unlock = app.tip:getUnlockTutorial()
		if unlock["heroShop"] == 1 then
			unlock["heroShop"] = 2
			app.tip:setUnlockTutorial(unlock) 
		end		
	end
end

function QUIDialogArenaStore:autoView()
	self._ccbOwner.node_btn_preview:setVisible(false)
	self._ccbOwner.node_btn_refresh:setVisible(true)
	self._ccbOwner.node_btn_recharge:setVisible(false)
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

--当前界面为宗门商店时   接收到 被踢出宗门推送  处理
function QUIDialogArenaStore:kickedUnion()
	-- body
	if self.shopId and self.shopId == SHOP_ID.consortiaShop and not app.battle then
		app:alert({content = "您被移出宗门！", title = "系统提示", callback = function (state)
                if state == ALERT_TYPE.CONFIRM or state == ALERT_TYPE.CANCEL then
                	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
                end
            end},false,true)
	end
end

function QUIDialogArenaStore:viewDidAppear()
	QUIDialogArenaStore.super.viewDidAppear(self)

	self._itemProxy = cc.EventProxy.new(remote.items)
	self._itemProxy:addEventListener(remote.items.EVENT_ITEMS_UPDATE, handler(self, self.itemsUpdateEventHandler))

	-- QNotificationCenter.sharedNotificationCenter():addEventListener(QUIDialogStoreDetail.ITEM_SELL_FAIL, self.getItem, self)
	QNotificationCenter.sharedNotificationCenter():addEventListener(remote.stores.SHOP_ITEM_BUY_SCCESS, self.sellItemSuccess, self)
	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.UNION_CONSORTIA_KICKED, self.kickedUnion, self)
	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.STORE_QUICK_BUY_IS_END, self._quickBuyIsEnd, self)

	self:addBackEvent()
end

function QUIDialogArenaStore:viewWillDisappear()
	QUIDialogArenaStore.super.viewWillDisappear(self)

	QNotificationCenter.sharedNotificationCenter():removeEventListener(remote.stores.SHOP_ITEM_BUY_SCCESS, self.sellItemSuccess, self)
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.UNION_CONSORTIA_KICKED, self.kickedUnion, self)
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.STORE_QUICK_BUY_IS_END, self._quickBuyIsEnd, self)

	if self._itemProxy then
		self._itemProxy:removeAllEventListeners()
	end

	-- QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIDialogStoreDetail.ITEM_SELL_FAIL, self.getItem, self)
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end

	if self._checkItemScheduler ~= nil then
		scheduler.unscheduleGlobal(self._checkItemScheduler)
		self._checkItemScheduler = nil
	end

	if self._hideWidgetChat then
		local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
		page.widgetChat:setVisible(true)
	end

	if self._timeScheduler ~= nil then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end

	if self._timeScheduler1 ~= nil then
		scheduler.unscheduleGlobal(self._timeScheduler1)
		self._timeScheduler1 = nil
	end

	if self._timeScheduler2 ~= nil then
		scheduler.unscheduleGlobal(self._timeScheduler2)
		self._timeScheduler2 = nil
	end

	if self._animationScheduler ~= nil then
		scheduler.unscheduleGlobal(self._animationScheduler)
		self._animationScheduler = nil
	end

	self:clearItembox()
	self:removeBackEvent()
end

function QUIDialogArenaStore:resetAll()
	self._ccbOwner.tf_refresh_count:setString("")
	self._ccbOwner.refresh_money:setString("")
	self._ccbOwner.tf_auto_refresh_time:setString("")
	self._ccbOwner.sp_tab_item_red_tips:setVisible(false)
	self._ccbOwner.sp_tab_award_red_tips:setVisible(false)

	self._ccbOwner.node_btn_quick_buy:setVisible(false)
	self._ccbOwner.node_btn_set:setVisible(false)
	self._ccbOwner.node_btn_select:setVisible(false)
	self._ccbOwner.node_total_price_info:setVisible(false)

end

function QUIDialogArenaStore:showDirectionBtn()
	if self.shopInfo and self.shopInfo.hideDirection then
		self._ccbOwner.node_btn_left:setVisible(false)
		self._ccbOwner.node_btn_right:setVisible(false)
	else
		self._ccbOwner.node_btn_left:setVisible(true)
		self._ccbOwner.node_btn_right:setVisible(true)		
	end
end

function QUIDialogArenaStore:clearItembox()
	if self._listView then 
		self._listView:clear(true)
		self._listView = nil
	end
end

function QUIDialogArenaStore:_initListView(bufferMode)
	self._curOriginOffset = 10
	if self._data and #self._data <= 6 then
		-- local item = QUIWidgetStoreItmeBox.new()
		local size = CCSize(269, 200) --item:getContentSize()
		local row = math.ceil(#self._data/self._rowMaxCount)
		self._curOriginOffset = (self._s9sLeftAndRightHeight - row * size.height) * 0.4
	end

	local cfg = nil
	if bufferMode == QUIDialogArenaStore.SHOP_AWARDS then
		cfg = {
			renderItemCallBack = function( list, index, info )
	            local isCacheNode = true
	            local itemData = self._awardsInfo[index]
	            local item = list:getItemFromCache(QUIDialogArenaStore.SHOP_AWARDS)
	            if not item then
            		item = QUIWidgetStoreAwardsBox.new()
            		item:addEventListener(QUIWidgetStoreAwardsBox.EVENT_CLICK_AWARDS_BOX, handler(self, self.sellClickHandler))
	            	isCacheNode = false
	            end
				item:setItmeBox(self.shopInfo, itemData)
				info.tag = QUIDialogArenaStore.SHOP_AWARDS
	            info.item = item
	            info.size = item:getContentSize()

	            if self._ccbOwner.sp_partition:isVisible() == false then
					self._ccbOwner.sp_partition:setVisible(true)
					local sp = item:getSpPartition()
					self._ccbOwner.sp_partition:setPositionY(sp:getPositionY())
				end
				list:unRegisterTouchHandler(index)
                list:registerBtnHandler(index, "btn_click", "_onTirggerClick")

	            return isCacheNode
	        end,
	        multiItems = 1,
	        curOriginOffset = 0,
	        curOffset = 0,
	        enableShadow = false,
	      	ignoreCanDrag = false,
	      	isVertical = false,
	      	spaceY = 0,
	      	spaceX = 0,
	        totalNumber = #self._awardsInfo,
		}
	else
		cfg = {
			renderItemCallBack = function( list, index, info )
	            local isCacheNode = true
	            local itemData = self._data[index]
	            local item = list:getItemFromCache(QUIDialogArenaStore.SHOP_ITEM)
	            if not item then
	            	if self.shopInfo.isExchangeShop then
						item = QUIWidgetSilverStoreBox.new()
						item:addEventListener(QUIWidgetSilverStoreBox.SILVER_STORE_BOX_EVENT, handler(self, self.onClickItemBox))	            		
	            	else
	            		item = QUIWidgetStoreItmeBox.new()
	            		item:addEventListener(QUIWidgetStoreItmeBox.EVENT_CLICK, handler(self, self.sellClickHandler))
	            	end        	
	            	
	            	isCacheNode = false
	            end

	            item:setItmeBox(itemData)
	            info.item = item
				info.tag = QUIDialogArenaStore.SHOP_ITEM
	            info.size = item:getContentSize()

	            if self._ccbOwner.sp_partition:isVisible() == true then
					self._ccbOwner.sp_partition:setVisible(false)
				end

                list:registerBtnHandler(index, "btn_item_click", "_onTirggerItemClick")
                list:registerBtnHandler(index, "btn_click", "_onTirggerClick")

	            return isCacheNode
	        end,
	        multiItems = self._rowMaxCount,
	        curOriginOffset = self._curOriginOffset,
	        curOffset = 10,
	        enableShadow = false,
	      	ignoreCanDrag = false,
	      	isVertical = true,
	        totalNumber = #self._data,
		}
	end
	if not self._listView then
		self._listView = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listView:resetTouchRect()
		self._listView:reload(cfg)
	end
end

function QUIDialogArenaStore:updateShopData()
	-- print("[self.shopId] ", self.shopId)
	-- local storesInfo = remote.stores:getStoresById(self.shopId)
	-- if storesInfo == nil or next(storesInfo) == nil then 
	-- 	return 
	-- end
	-- self._data = {}
	-- for index, value in ipairs(storesInfo) do
	-- 	if index % self._rowMaxCount == 1 then
	-- 		value.isPartition = true
	-- 	end
	-- 	value.index = index
	-- 	table.insert(self._data, value)
	-- end

	-- local proxy = remote.stores:getProxyById(self.shopId)
	self._data = {}
	if self._proxy then
		self._data = self._proxy:getShopData()	
	end
end

function QUIDialogArenaStore:updateExchangeShopData()
	local newShopInfos = {}
	local shops = remote.exchangeShop:getShopInfoById(self.shopId)
	local userLevel = remote.user.level or 0
	local vipLevel = QVIPUtil:VIPLevel() or 0
	for i = 1, #shops do
		if userLevel >= shops[i].team_minlevel and userLevel <= shops[i].team_maxlevel and vipLevel >= shops[i].vip_id then
			newShopInfos[i] = shops[i]
		end
	end

	table.sort(newShopInfos, function(a, b)
		if a.show_grid_id and b.show_grid_id then
			return a.show_grid_id < b.show_grid_id
		else
			return a.grid_id < b.grid_id
		end
	end)

	self._data = {}
	for i, v in pairs(newShopInfos) do
		if i % self._rowMaxCount == 1 then
			v.isPartition = true
		end		
		if not db:checkItemShields(v.item_id) then
			table.insert(self._data, v)
		end
	end
end
	

--初始化物品格子
function QUIDialogArenaStore:_initShopItemData(isAutoRefresh)
	self:setAwardsItems()
	self:updateShopData()
	-- if self.shopInfo.isExchangeShop then	
	-- 	self:updateExchangeShopData()
	-- else
	-- 	self:updateShopData()
	-- end

	if not self._data then return end
	self:_initListView()

	self:checkItemIsNeed()
	if self.shopInfo.refreshInfo and self.shopInfo.refreshInfo ~= "" then
		self:_setRefreshInfo()
		self._ccbOwner.node_follow_left_bottom:setVisible(true)
		self._ccbOwner.node_follow_right_botoom:setVisible(true)	
		self._ccbOwner.node_refresh_count:setVisible(true)		
	else
		self._ccbOwner.node_follow_left_bottom:setVisible(false)
		self._ccbOwner.node_follow_right_botoom:setVisible(false)		
	end
	--检查是否有可出售物品
	if isAutoRefresh ~= true then
		self:checkSellItem()
	end
end

function QUIDialogArenaStore:checkItemIsNeed()
    for i = 1, #self._data, 1 do 
    	if self._data[i].id ~= 0 then
    		local isNeed = remote.stores:checkItemIsNeed(self._data[i].id, self._data[i].count)
    		self._data[i].isNeed = isNeed
		end
    end
end

function QUIDialogArenaStore:_setRefreshInfo()
	local refreshItemNums = 0
	local refreshItemId = nil
	local refershAllNum = 20
	if self._proxy then
		refreshItemId = self._proxy:getResourcesItemId()
		refreshItemNums = remote.items:getItemsNumByID(refreshItemId)
		refershAllNum = self._proxy:getRefreshCount()
	end
	local refreshCount = remote.stores:getRefreshCountById(self.shopId) or 0
	-- local vip = QStaticDatabase:sharedDatabase():getVipContnentByVipLevel(QVIPUtil:VIPLevel())

	if refreshItemNums ~= nil and refreshItemNums > 0 then
		local items = db:getItemByID(refreshItemId)
		if items then
			self:createMoneyIcon(items.icon_1, 1)
		end
		local num = 1
		self._ccbOwner.refresh_money:setString(refreshItemNums.."/"..num)		
	else
		local refreshMoney, moneyType = self:getRefreshToken(refreshCount)
		local currencyInfo = remote.items:getWalletByType(moneyType)
		self:createMoneyIcon(currencyInfo.alphaIcon, 0.6)

		local word = refreshMoney == 0 and "免费" or refreshMoney
		self._ccbOwner.refresh_money:setString(word)		
	end

	-- local refershNum = vip.gnshop_limit - refreshCount
	local refershNum = refershAllNum - refreshCount
	refershNum = refershNum > 0 and refershNum or 0
	self._ccbOwner.tf_refresh_count:setString(refershNum)
	self._ccbOwner.tf_refresh_count_title:setString("今日剩余刷新次数：")
end

function QUIDialogArenaStore:createMoneyIcon(path, scale)
	if self._icon ~= nil then
		self._icon:removeFromParent()
		self._icon = nil
	end
    self._icon = CCSprite:create()
    self._icon:setTexture(CCTextureCache:sharedTextureCache():addImage(path))
    self._ccbOwner.icon_node:addChild(self._icon)
    self._ccbOwner.icon_node:setScale(scale or 1)
end

function QUIDialogArenaStore:checkRedTips()
	self._ccbOwner.sp_tab_award_red_tips:setVisible(false)
	if remote.stores:checkAwardsShopCanBuyByShopId(self.shopInfo.arawdsId) then
		self._ccbOwner.sp_tab_award_red_tips:setVisible(true)
	end
	if FinalSDK.isHXShenhe() then
		self._ccbOwner.sp_tab_award_red_tips:setVisible(false)
	end
end

function QUIDialogArenaStore:setAwardsItems()
	-- local proxy = remote.stores:getProxyById(self.shopId)
	self._awardsInfo = {}
	if self._proxy then
		self._awardsInfo = self._proxy:getAwrdsData()
	end
	-- if self.shopInfo.arawdsId == nil then return end

	-- local awardsInfo = QStaticDatabase:sharedDatabase():getItemsByShopAwardsId(self.shopInfo.arawdsId) or {}
	-- for i = 1, #awardsInfo, 1 do
	-- 	awardsInfo[i].position = i 
	-- end
	-- self._awardsInfo = self:sortAwardsItem(awardsInfo)
end

function QUIDialogArenaStore:sortAwardsItem(awardInfos)
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

function QUIDialogArenaStore:checkNextShop()
  	local nextShop = remote.stores:moveNextShop(self.shopId, "left", false)
  	if nextShop then
  		self._ccbOwner.btn_right:setVisible(false)
  		self._ccbOwner.btn_left:setVisible(false)
  	end
end

function QUIDialogArenaStore:checkLabelBtn( )
	if not self.shopInfo.arawdsId then
		self._ccbOwner.node_btn_item:setVisible(false)
		self._ccbOwner.node_btn_award:setVisible(false)
	else
		self._ccbOwner.node_btn_item:setVisible(true)
		self._ccbOwner.node_btn_award:setVisible(true)
	end
end

function QUIDialogArenaStore:checkQuickBuyBtn()
	self._ccbOwner.node_btn_auto_buy:setVisible(true)
	self._ccbOwner.node_btn_refresh:setVisible(true)
	self._ccbOwner.node_btn_refresh:setPositionX(-240)

	if self.shopInfo.quickBuy then
		local shopData = db:getShopDataByID(self.shopId)
		local unlockData = app.unlock:getConfigByKey(shopData.unlock_shop) or {}
		local configLevel = db:getConfiguration()["show_button"].value or 0
		if self.shopId == SHOP_ID.soulShop and app.unlock:checkLock("UNLOCK_HERO_SHOP_EASY_BUY", false) == false then 
			self._ccbOwner.node_btn_auto_buy:setVisible(false)
			self._ccbOwner.node_btn_refresh:setPositionX(-97)
		elseif app.unlock:checkLock("UNLOCK_EASY_BUY", false) == false then 
			self._ccbOwner.node_btn_auto_buy:setVisible(false)
			self._ccbOwner.node_btn_refresh:setPositionX(-97)
		elseif remote.user.level < (unlockData.team_level or 0) + configLevel then
			makeNodeFromNormalToGray(self._ccbOwner.node_btn_auto_buy)
			self._ccbOwner.node_btn_auto_buy_effect:setVisible(false)
		else
			makeNodeFromGrayToNormal(self._ccbOwner.node_btn_auto_buy)
			--xurui:检查扫荡功能解锁提示
			self._ccbOwner.node_btn_auto_buy_effect:setVisible(app.tip:checkReduceUnlokState("shopQuickBuy"))
		end
	else
		self._ccbOwner.node_btn_auto_buy:setVisible(false)
		self._ccbOwner.node_btn_refresh:setPositionX(-97)		
	end
end

--根据不同的商店显示不同的资源
function QUIDialogArenaStore:chooseResources()
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
	
	self._ccbOwner.tf_auto_refresh_time:setVisible(true)
end

--设置下次刷新时间
function QUIDialogArenaStore:setRefreshTime()
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
	if self.shopInfo.isExchangeShop then
		self:_timeCountDown()
	else
		local lastTime, nextTime, refreshWord = remote.stores:checkedShopBeforeRefreshTime(self.shopId)
		self._ccbOwner.tf_auto_refresh_time:setString(refreshWord)
		self:_generalRefreshTime(nextTime)
	end
end

--普通商店刷新时间
function QUIDialogArenaStore:_generalRefreshTime(time)
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
	remote.stores:setNextRefershTime(self.shopId, time)
	local offsetTime = q.serverTime()
	if offsetTime < time then
		self._timeHandler = scheduler.performWithDelayGlobal(function()
			self:setRefreshTime()
			self:refreshItems()
		end,(time - offsetTime))
	end
end

--倒计时
function QUIDialogArenaStore:_timeCountDown()
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
	self._ccbOwner.node_follow_left_bottom:setVisible(true)
	self._ccbOwner.node_follow_right_botoom:setVisible(false)
	self._ccbOwner.node_refresh_count:setVisible(false)
	self._ccbOwner.tf_auto_refresh_title:setString("货物下次刷新时间：")
	local timeCount = 0
	if self.shopId == SHOP_ID.monthSignInShop then
		local nextMonthTime = q.getFirstTimeOfNextMonth()
		timeCount = nextMonthTime - q.serverTime()
	elseif self.shopId == SHOP_ID.crystalShop then
		local weektime = q.getFirstTimeOfWeek()
		local endTime = weektime + WEEK - q.serverTime()
		timeCount = endTime
	else
		self._ccbOwner.node_follow_left_bottom:setVisible(false)
		self._ccbOwner.node_follow_right_botoom:setVisible(false)	
		self._ccbOwner.tf_auto_refresh_title:setString("货物自动更新时间：")	 
	end

	local str = ""
	if timeCount > 0 then
		local day = math.floor(timeCount/DAY)
		timeCount = timeCount%DAY
		str = q.timeToHourMinuteSecond(timeCount)
		if day > 0 then
			str = day.."天 "..str
		end
		self._timeHandler = scheduler.performWithDelayGlobal(function ()
			self:_timeCountDown()
		end,1)
	end
	self._ccbOwner.tf_auto_refresh_time:setString(str)
end

function QUIDialogArenaStore:getRefreshToken(refreshCount)
	local tokeNum = 0
	local refreshInfo = QStaticDatabase:sharedDatabase():getTokenConsumeByType(self.shopInfo.refreshInfo)
	if refreshInfo ~= nil then
		for _, value in pairs(refreshInfo) do
			if value.consume_times == refreshCount + 1 then
				return value.money_num, value.money_type
			end
		end

		return refreshInfo[#refreshInfo].money_num, refreshInfo[#refreshInfo].money_type
	end
	
	return 0, "token"
end

function QUIDialogArenaStore:_onTriggerNormal()
	if self._itemBoxAniamtion then return end
	app.sound:playSound("common_small")

	local refreshCount = remote.stores:getRefreshCountById(self.shopId) or 0
	local refreshToken, moneyType = self:getRefreshToken(refreshCount)
	local refershAllNum = 20

	-- local vip = QStaticDatabase:sharedDatabase():getVipContnentByVipLevel(QVIPUtil:VIPLevel())
	if self._proxy then
		refershAllNum = self._proxy:getRefreshCount()
	end

	local currencyInfo = remote.items:getWalletByType(moneyType)

	-- local refershNum = vip.gnshop_limit - refreshCount
	local refershNum = refershAllNum - refreshCount
    if refershNum <= 0 then
        -- app.tip:floatTip("魂师大人大人，提升VIP等级可以增加商店刷新次数")
        self:_showVipAlert()
        return
    end

	local money = remote.user[currencyInfo.name] or 0
	if money < refreshToken then
		remote.stores:checkShopCurrencyQuickWay(currencyInfo.name)
		return
	end
	if not self:_checkRefresh() then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogNpcPrompt", 
			options = {content ="魂师大人，您有未购买的7折碎片哟，确定要刷新吗？", comfirmCallback = function ()
					app:getClient():refreshShop(self.shopId, function(data)
						if self:safeCheck() then
							if self._itemBoxAniamtion == false then
								self:itemBoxRunOutAction()
							end
							self:checkRedTips()
							if self.shopId == SHOP_ID.generalShop then
								remote.user:addPropNumForKey("todayRefreshShopCount")
							end
							if self.shopId == SHOP_ID.blackShop then
								remote.activity:updateLocalDataByType(553, 1)
							end	
							if self.shopId == SHOP_ID.soulShop then
								remote.user:addPropNumForKey("todayRefreshShop501Count")
								remote.user:addPropNumForKey("c_resetSoulShopCount")
								remote.activity:updateLocalDataByType(526, 1)								
							end						
						end
					end)
    		end}})
		return
	end

	app:getClient():refreshShop(self.shopId, function(data)
		if self:safeCheck() then
			if self._itemBoxAniamtion == false then
				self:itemBoxRunOutAction()
			end
			self:checkRedTips()
			if self.shopId == SHOP_ID.generalShop then
				remote.user:addPropNumForKey("todayRefreshShopCount")
			end
			if self.shopId == SHOP_ID.blackShop then
				remote.activity:updateLocalDataByType(553, 1)
			end		
			if self.shopId == SHOP_ID.soulShop then
				remote.user:addPropNumForKey("todayRefreshShop501Count")
				remote.user:addPropNumForKey("c_resetSoulShopCount")
				remote.activity:updateLocalDataByType(526, 1)								
			end					
		end
	end,
	function(data)
	end)
end

function QUIDialogArenaStore:itemBoxRunOutAction()
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
						end
						if itemBox2 and self._data[i+self._rowMaxCount] then
							itemBox2:setItmeBox(self._data[i+self._rowMaxCount])
						end
					end
					self:itemBoxRunInAction()
				end
			end, 0.1)
		end
	end
	self.func1()
end 

function QUIDialogArenaStore:itemBoxRunInAction()
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

function QUIDialogArenaStore:_onTriggerItems()
	if self.titleLabelType == QUIDialogArenaStore.SHOP_ITEM then return end
    app.sound:playSound("common_menu")

	self.titleLabelType = QUIDialogArenaStore.SHOP_ITEM
	self._ccbOwner.node_follow_left_bottom:setVisible(true)
	self._ccbOwner.node_follow_right_botoom:setVisible(true)
	self._tabManager:selected(self._ccbOwner.tab_item)

	self:_initShopItemData()
end

function QUIDialogArenaStore:_onTriggerAwards()
	if self._itemBoxAniamtion then return end
	if self.titleLabelType == QUIDialogArenaStore.SHOP_AWARDS then return end
    app.sound:playSound("common_menu")

	self.titleLabelType = QUIDialogArenaStore.SHOP_AWARDS
	self._ccbOwner.node_follow_left_bottom:setVisible(false)
	self._ccbOwner.node_follow_right_botoom:setVisible(false)
	self._tabManager:selected(self._ccbOwner.tab_award)

	if remote.stores:getAwardsShopState(self.shopInfo.arawdsId) == false then
		remote.stores:setAwardsShopState(self.shopInfo.arawdsId)
		self:checkRedTips()
	end

	self:_initListView(QUIDialogArenaStore.SHOP_AWARDS)
end

function QUIDialogArenaStore:_onTriggerQuickBuy()
	app.sound:playSound("common_small")
	local shopData = db:getShopDataByID(self.shopId)
	local unlockData = app.unlock:getConfigByKey(shopData.unlock_shop) or {}
	local configLevel = db:getConfiguration()["show_button"].value or 0
	if remote.user.level < (unlockData.team_level or 0) + configLevel then
		app.tip:floatTip(string.format("战队等级大于等于商店开放等级%d级后开启", configLevel))
		return
	end
	local parentOptions = self:getOptions()
	parentOptions.type = self.shopId

	--xurui:设置扫荡功能解锁提示
	if app.tip:checkReduceUnlokState("shopQuickBuy") then
		app.tip:setReduceUnlockState("shopQuickBuy", 2)
		self._ccbOwner.node_btn_auto_buy_effect:setVisible(false)
	end
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogStoreQuickBuy", 
			options = {parentOptions = parentOptions }},{isPopCurrentDialog = true})
end

function QUIDialogArenaStore:openQucikShopByShopId(shopId)
	if not shopId then return end
	self.shopId = shopId
	self:getOptions().type = shopId
	self:updateShopView()
end

function QUIDialogArenaStore:_onTriggerLeft()
	app.sound:playSound("common_small")
	local isNextShop,shopId = remote.stores:moveNextShop(self.shopId, "left")
	if not isNextShop and shopId then
		self.shopId = shopId
		self:getOptions().type = shopId
		self:updateShopView()
	end
end

function QUIDialogArenaStore:_onTriggerRight()
	app.sound:playSound("common_small")
	local isNextShop,shopId = remote.stores:moveNextShop(self.shopId, "right")
	if not isNextShop and shopId then	
		self.shopId = shopId
		self:getOptions().type = shopId
		self:updateShopView()
	end	
end

function QUIDialogArenaStore:getItem()
	app:getClient():getStores(self.shopId, function(data)
		if self:safeCheck() then
			self:_initShopItemData()
		end
	end)
end

--自动刷新物品
function QUIDialogArenaStore:refreshItems()
	app:getClient():getStores(self.shopId, function(data)
		if self.titleLabelType == QUIDialogArenaStore.SHOP_ITEM then
			self:_initShopItemData(true)
		end
	end)
end

function QUIDialogArenaStore:sellClickHandler(data)
	if self._isMove == false and self._itemBoxAniamtion == false then
    	app.sound:playSound("common_small")
		if data.canSell ~= nil and data.canSell == false then
			app.tip:floatTip("不满足购买条件")
			return
		end

		if data.itemInfo.id == -1 then
			app.tip:floatTip("魂师大人，改物品不能购买")
			return
		end
		if data.isSell == false then
			local shopId = data.awards ~= nil and data.awards or self.shopId
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogStoreDetail",
				options = {shopId = shopId, itemInfo = data.itemInfo, index = data.index, isCombination = data.isCombination}},
			{isPopCurrentDialog = false})
		else
		end
	end
end

function QUIDialogArenaStore:onClickItemBox(data)
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

	local itemInfo = data.itemInfo
	local buyInfo = remote.exchangeShop:getShopBuyInfo(self.shopId)
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

	if self.shopId == SHOP_ID.crystalShop and self:_checkCrystalShopSkin(itemInfo.item_id) then
		app.tip:floatTip("已激活宝箱中所有皮肤")
		return
	end

	local index = itemInfo.index
	local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilverStoreDetail", 
		options = {shopId = self.shopId, itemInfo = itemInfo, index = index}})

end

-- 魂晶商店判断玩家是否已经激活某多选一皮肤宝箱内所有皮肤
function QUIDialogArenaStore:_checkCrystalShopSkin(itemId)
	local itemInfo = db:getItemByID(itemId)
	if itemInfo.type ~= ITEM_CONFIG_TYPE.CONSUM_CHOOSE_PACKAGE then
		return false
	end
	local items = remote.items:analysisServerItem(itemInfo.content)
	local skinCount, activatedCount = 0, 0
	for _, item in ipairs(items) do
		local selectItemInfo = db:getItemByID(item.id)
		if selectItemInfo.type == ITEM_CONFIG_TYPE.SKIN_ITEM then
			skinCount = skinCount + 1
			if remote.heroSkin:checkItemSkinByItem(item.id) == remote.heroSkin.ITEM_SKIN_ACTIVATED then
				activatedCount = activatedCount + 1
			else
				return false
			end
		end
	end

	if skinCount ~= 0 and skinCount == activatedCount then
		return true
	end
	return false
end

function QUIDialogArenaStore:removeEvent()
	if self._alert ~= nil then
		self._alert:removeAllEventListeners()
		self._alert = nil
	end
end

function QUIDialogArenaStore:itemsUpdateEventHandler(event)
	if self:safeCheck() and not self.shopInfo.isExchangeShop then
		self:_initListView()
	end
end

function QUIDialogArenaStore:sellItemSuccess(data)
	if data ~= nil then
		if self.titleLabelType == QUIDialogArenaStore.SHOP_AWARDS then
			self:setAwardsItems()
			self:_initListView(QUIDialogArenaStore.SHOP_AWARDS)
		else
			-- self:_initShopItemData()
			if self:safeCheck() then
				self:updateShopData()
				local targetItem = self._data[data.index]
				print("[event.index]", data.index)
				QPrintTable(targetItem)
				if self._listView then
					local item = self._listView:getItemByIndex(data.index)
					if item then
						item:setItmeBox(targetItem)
					end
				end
			end			
		end
		self:checkRedTips()
	end
end

function QUIDialogArenaStore:checkSellItem()
	local sellItems = remote.items:getItemsByType(ITEM_CONFIG_TYPE.CONSUM_MONEY)
	if next(sellItems) ~= nil then
		if app.unlock:checkLock("UNLOCK_SELL_GOLDEN") and app:getUserOperateRecord():getStoreAutoSellItem() then
			local items = remote.items:getSellMoneyItem()
			items = remote.items:itemSort(items)
			app:getClient():sellItem(items, function(data)
		  		
			end)
		else
			self.sellDialog =  app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSellItems"},{isPopCurrentDialog = false})
		end
	end
end

function QUIDialogArenaStore:_showVipAlert()
	app:vipAlert({title = "刷新次数", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.GNSHOP_LIMIT_COUNT}, false)
end

function QUIDialogArenaStore:_checkRefresh()
	if self._data then
		for _,info in ipairs(self._data) do
			if info.count ~= 0 and self:isOffByInfo(info) then
				return false
			end
		end
	end
	return true
end

function QUIDialogArenaStore:isOffByInfo(info)
	if nil == info or info.moneyType ~= "TOKEN" then return false end
	local itemConfig = nil
	if info.itemType == "item" then
		itemConfig = QStaticDatabase:sharedDatabase():getItemByID(info.id)
	else
		itemConfig = remote.items:getWalletByType(info.itemType)
	end
	if itemConfig and itemConfig.type == ITEM_CONFIG_TYPE.SOUL then
		local actorId = QStaticDatabase:sharedDatabase():getActorIdBySoulId(info.id)
		local aptitudeInfo = QStaticDatabase:sharedDatabase():getActorSABC(actorId)
		if aptitudeInfo.soulPrice then
			local count = info.count or 0
			local price = aptitudeInfo.soulPrice or 0
			if info.cost == count * price * 0.7 then
				return true
			end
		end
	end
	return false
end

function QUIDialogArenaStore:_quickBuyIsEnd()
	if self:safeCheck() then
		self:_setRefreshInfo()
		self:_initShopItemData()
	end
end

function QUIDialogArenaStore:onTriggerBackHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	if self._callback then
		self._callback()
	end    
end

function QUIDialogArenaStore:onTriggerHomeHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogArenaStore
