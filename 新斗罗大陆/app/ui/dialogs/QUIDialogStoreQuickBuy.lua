-- @Author: xurui
-- @Date:   2017-02-22 14:54:19
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-07-14 19:23:55
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogStoreQuickBuy = class("QUIDialogStoreQuickBuy", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollView = import("...views.QScrollView")
local QUIWidgetStoreQuickBuyClient = import("..widgets.QUIWidgetStoreQuickBuyClient")
local QVIPUtil = import("...utils.QVIPUtil")
local QQuickWay = import("...utils.QQuickWay")
local QNotificationCenter = import("...controllers.QNotificationCenter")

function QUIDialogStoreQuickBuy:ctor(options)
	local ccbFile = "ccb/Dialog_shop.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerRight)},
		{ccbCallbackName = "onTriggerQuickBuy", callback = handler(self, self._onTriggerQuickBuy)},
		{ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},
		{ccbCallbackName = "onTriggerTips", callback = handler(self, self._onTriggerTips)},
		{ccbCallbackName = "onTriggerSetConfig", callback = handler(self, self._onTriggerSetConfig)},
	}
	QUIDialogStoreQuickBuy.super.ctor(self, ccbFile, callBack, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	
    CalculateUIBgSize(self._ccbOwner.sp_bg)

	q.setButtonEnableShadow(self._ccbOwner.btn_set)
	q.setButtonEnableShadow(self._ccbOwner.btn_quick_buy)
	q.setButtonEnableShadow(self._ccbOwner.btn_tips)
	
	self._shopId = options.shopId

	self._isSecretary = options.isSecretary
	self._rowMaxCount = 3
	
	if self._isSecretary then
		self.isAnimation = true
		self._ccbOwner.node_btn_left:setVisible(false)
		self._ccbOwner.node_btn_right:setVisible(false)
		self._ccbOwner.tf_btn_quick_buy:setString("确认选择")
	end

	self:resetAll()
	self:autoView()
	self:initShopInfo(options)
	self:initScrollView()
end

function QUIDialogStoreQuickBuy:autoView()
	self._ccbOwner.node_btn_preview:setVisible(false)
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

function QUIDialogStoreQuickBuy:resetAll()
	self._ccbOwner.node_btn_preview:setVisible(false)
	self._ccbOwner.node_btn_auto_buy:setVisible(false)
	self._ccbOwner.node_btn_refresh:setVisible(false)
	self._ccbOwner.node_btn_item:setVisible(false)
	self._ccbOwner.node_btn_award:setVisible(false)
	self._ccbOwner.node_btn_recharge:setVisible(false)
	
	self._ccbOwner.node_btn_quick_buy:setVisible(true)
	self._ccbOwner.node_btn_set:setVisible(true)
	self._ccbOwner.node_btn_select:setVisible(true)
	self._ccbOwner.node_total_price_info:setVisible(false)
end

function QUIDialogStoreQuickBuy:viewDidAppear()
	QUIDialogStoreQuickBuy.super.viewDidAppear(self)

	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.UNION_CONSORTIA_KICKED, self.kickedUnion, self)

	self:setRefreshInfo()

	self:setItemInfo()

	self:addBackEvent()
end

function QUIDialogStoreQuickBuy:viewWillDisappear()
	QUIDialogStoreQuickBuy.super.viewWillDisappear(self)

	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.UNION_CONSORTIA_KICKED, self.kickedUnion, self)

	app:getUserOperateRecord():setShopQuickBuyConfiguration(self._shopId, self.chooseItem)

	self:removeBackEvent()
end

--当前界面为宗门商店时   接收到 被踢出宗门推送  处理
function QUIDialogStoreQuickBuy:kickedUnion()
	-- body
	if self._shopId and self._shopId == SHOP_ID.consortiaShop and not app.battle then
		app:alert({content = "您被移出宗门！", title = "系统提示", callback = function (state)
                if state == ALERT_TYPE.CONFIRM or state == ALERT_TYPE.CANCEL then
                	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
                end
            end},false,true)
	end
end

function QUIDialogStoreQuickBuy:initShopInfo(options)
	if options.parentOptions then
		self._parentOptions = options.parentOptions
		self._shopId = self._parentOptions.type
	end

	if self._shopId == SHOP_ID.soulShop then
		self._ccbOwner.btn_set:setVisible(true)
		self._ccbOwner.btn_set:setTouchEnabled(true)
		local showTips = remote.stores:checkNewShopGoodsView(self._shopId)
		if showTips then
			self.chooseItem = {}
			app:getUserOperateRecord():setShopQuickBuyConfiguration(self._shopId,{})
			app.tip:floatTip("魂师大人，您已可以购买更高级物品，快去重新设置吧~")
		end
	else
		self._ccbOwner.btn_set:setVisible(false)
		self._ccbOwner.btn_set:setTouchEnabled(false)
	end

	self.shopInfo = remote.stores:getShopResousceByShopId(self._shopId)
	self.itemBox = {}
	self.chooseItem = app:getUserOperateRecord():getShopQuickBuyConfiguration(self._shopId)
	-- QPrintTable(self.chooseItem)
	self.chooseItem = self:recheckChooseItem(self.chooseItem)
	-- QPrintTable(self.chooseItem)
	-- self._ccbOwner.tf_shop_title:setString(self.shopInfo.titleName)
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

	self._isSelected = app:getUserOperateRecord():getStoreSelectQuickBuyStated(self._shopId) or false -- 是否勾选快速购买
	if self._isSecretary then
		self._isSelected = true
	else
		local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
		if page then
			page:setAllUIVisible(false)
			page._scaling:willPlayHide()
			local style = string.split(self.shopInfo.moneyType, "^")
			if style then
				page.topBar:showWithStyle(style)
			end
		end
	end
	self._ccbOwner.sp_on:setVisible(self._isSelected)
	self._ccbOwner.sp_off:setVisible(not self._isSelected)
end


function QUIDialogStoreQuickBuy:recheckChooseItem( chooseItem )
	local isMaxSale = function(shopItems, choose)
		local maxNum = 0
		for j, itemInfo in pairs(shopItems) do
			local id = itemInfo.id 
			if id == nil then
				id = itemInfo.itemType
			end
			if id == choose.id and itemInfo.moneyType == choose.moneyType and (itemInfo.sale or 1) == 1 then
				maxNum = itemInfo.moneyNum
				break
			end
		end
		return maxNum
	end
	local chooseItems = {}
	if chooseItem == nil then return chooseItems end
	local configuration = {}
	self._shopItems = remote.stores:getShopAllItemsByShopId2(self._shopId)
	for j, itemInfo in pairs(self._shopItems) do
		local id = itemInfo.id 
		if id == nil then
			id = itemInfo.itemType
		end

		for _,value in pairs(chooseItem) do
			local index = 1
			for i, chooseItemInfo in pairs(value) do
				if id == chooseItemInfo.id and itemInfo.moneyType == chooseItemInfo.moneyType and tonumber(chooseItemInfo.moneyNum) == tonumber(itemInfo.moneyNum) then
					if configuration[id] == nil then
						configuration[id] = {}
					end
					configuration[id][index] = {id = id, moneyType = chooseItemInfo.moneyType, moneyNum = tonumber(chooseItemInfo.moneyNum)}
				end
				index = index + 1
			end
		end
	end
	return configuration

end

function QUIDialogStoreQuickBuy:initScrollView()
	local contentSize = self._ccbOwner.sheet_layout:getContentSize()
	self._scrollView = QScrollView.new(self._ccbOwner.sheet, contentSize, {bufferMode = 2, sensitiveDistance = 10})
	self._scrollView:setVerticalBounce(true)
	self._scrollView:setHorizontalBounce(false)
	self._scrollView:setGradient(true)
    self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))
    self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))
end

function QUIDialogStoreQuickBuy:_refreshItems()
	if self:safeCheck() then
		self.chooseItem = {}
		self:setRefreshInfo()
		self:setItemInfo()
	end
end

function QUIDialogStoreQuickBuy:setRefreshInfo()
	local refreshCount = remote.stores:getRefreshCountById(self._shopId) or 0
	local vip = QStaticDatabase:sharedDatabase():getVipContnentByVipLevel(QVIPUtil:VIPLevel())
	local proxy = remote.stores:getProxyById(self._shopId)
	local refreshLimit = proxy:getRefreshCount()

	self._refershNum = refreshLimit - refreshCount
	if self._shopId == SHOP_ID.soulShop then
		self._refershNum = vip.ylshop_limit - refreshCount
	end
	self._refershNum = self._refershNum > 0 and self._refershNum or 0
	self._ccbOwner.tf_refresh_count:setString(self._refershNum)
	self._ccbOwner.tf_refresh_count:setColor(QIDEA_QUALITY_COLOR.WHITE)
	if self._refershNum == 0 then
		self._ccbOwner.tf_refresh_count:setColor(QIDEA_QUALITY_COLOR.RED)
	end
	self._ccbOwner.tf_refresh_count_title:setString("今日剩余刷新次数：")
	self._ccbOwner.tf_auto_refresh_title:setString("系统将根据您的选择刷新商店并购买道具")
	self._ccbOwner.tf_auto_refresh_time:setVisible(false)
	self._ccbOwner.node_auto_refresh:setVisible(true)
	self._ccbOwner.node_refresh_count:setVisible(true)
	q.autoLayerNode({self._ccbOwner.tf_auto_refresh_title, self._ccbOwner.node_refresh_count}, "x", 20)

	makeNodeFromGrayToNormal(self._ccbOwner.btn_quick_buy)
	self._ccbOwner.tf_btn_quick_buy:enableOutline()
	local buyItems , buyInfo, needInfo = proxy:getBuyInfo(self.chooseItem)
	if next(self.chooseItem) == nil then
		makeNodeFromNormalToGray(self._ccbOwner.btn_quick_buy)
		self._ccbOwner.tf_btn_quick_buy:disableOutline()
	end
end

function QUIDialogStoreQuickBuy:setItemInfo()	
	self._scrollView:clear()
	self._shopItems = remote.stores:getShopAllItemsByShopId2(self._shopId)
	local proxy = remote.stores:getProxyById(self._shopId)
	if proxy.refreshChooseItem then
		proxy:refreshChooseItem()
	end
	if proxy.sortFun and self._shopItems ~= nil then
		table.sort(self._shopItems, handler(proxy, proxy.sortFun))
	end

	local itemContentSize, buffer = self._scrollView:setCacheNumber(15, "widgets.QUIWidgetStoreQuickBuyClient")
	for _, value in pairs(buffer) do
	    value:addEventListener(QUIWidgetStoreQuickBuyClient.EVENT_CLICK, handler(self, self.sellClickHandler))
	    table.insert(self.itemBox, value)
	end

	self._curOriginOffset = 10
	if self._shopItems and #self._shopItems <= 6 then
		local item = QUIWidgetStoreQuickBuyClient.new()
		local size = item:getContentSize()
		local row = math.ceil(#self._shopItems/self._rowMaxCount)
		self._curOriginOffset = (self._s9sLeftAndRightHeight - row * size.height) * 0.4
	end

	local row = 0
	local rowDistance = 0
	local line = 0
	local lineDistance = 0
	local offsetX = 0
	local offsetY = -self._curOriginOffset
	local lineMaxNum = 3

	for i = 1, #self._shopItems do
		local positionX = (itemContentSize.width + lineDistance) * row + offsetX
		local positionY = -(itemContentSize.height + rowDistance) * line + offsetY
		local isPartition = false
		if row == 0 then
			isPartition = true
		end
		self._scrollView:addItemBox(positionX, positionY, {info = self._shopItems[i], chooseItem = self.chooseItem, typeNum = 1, isPartition = isPartition})

		row = row + 1
		if row % lineMaxNum == 0 then
			row = 0
			line = line + 1
		end
	end
	if row % lineMaxNum ~= 0 then
		line = line + 1
	end
	local totalWidth = (itemContentSize.width + lineDistance) * lineMaxNum
	local totalHeight = (itemContentSize.height + rowDistance) * line + 10

	self._scrollView:setRect(0, -totalHeight, 0, totalWidth)
end

function QUIDialogStoreQuickBuy:sellClickHandler(data)
	if self._isMove or data.itemBox == nil then return end
    app.sound:playSound("common_small")

	local state = data.itemBox:getChooseState()
	print("勾选前状态=",state)
	data.itemBox:setChooseState(not state)
	local itemInfo = data.itemBox:getItemInfo()
	QPrintTable(itemInfo)
	local id = itemInfo.id
	if id == nil or id == "" then
		id = itemInfo.itemType
	end
	if state then
		if self.chooseItem[id] then
			if self.chooseItem[id][1] and self.chooseItem[id][1].moneyType == itemInfo.moneyType and tonumber(self.chooseItem[id][1].moneyNum) == tonumber(itemInfo.moneyNum) then
				table.remove(self.chooseItem[id], 1)
			elseif self.chooseItem[id][2] and self.chooseItem[id][2].moneyType == itemInfo.moneyType and tonumber(self.chooseItem[id][2].moneyNum) == tonumber(itemInfo.moneyNum) then
				table.remove(self.chooseItem[id], 2)
			elseif self.chooseItem[id][3] and self.chooseItem[id][3].moneyType == itemInfo.moneyType and tonumber(self.chooseItem[id][3].moneyNum) == tonumber(itemInfo.moneyNum) then
				table.remove(self.chooseItem[id], 3)
			elseif self.chooseItem[id][4] and self.chooseItem[id][4].moneyType == itemInfo.moneyType and tonumber(self.chooseItem[id][4].moneyNum) == tonumber(itemInfo.moneyNum) then
				table.remove(self.chooseItem[id], 4)
			end
		end
		if self.chooseItem[id] and next(self.chooseItem[id]) == nil then
			self.chooseItem[id] = nil
		end
	else
		if self.chooseItem[id] == nil then
			self.chooseItem[id] = {}
			self.chooseItem[id][1] = {id = id, moneyType = itemInfo.moneyType, moneyNum = itemInfo.moneyNum}
		else
			local newChooseItem = true
			for _ , value in pairs(self.chooseItem[id]) do
				if value.moneyType == itemInfo.moneyType and tonumber(value.moneyNum) == tonumber(itemInfo.moneyNum) then
					newChooseItem = false
				end
			end
			if newChooseItem == true then
				self.chooseItem[id][#self.chooseItem[id] + 1] = {id = id, moneyType = itemInfo.moneyType, moneyNum = itemInfo.moneyNum}
			end
		end
	end
	self:setRefreshInfo()
end

function QUIDialogStoreQuickBuy:_onTriggerQuickBuy()
	app.sound:playSound("common_small")

	app:getUserOperateRecord():setShopQuickBuyConfiguration(self._shopId, self.chooseItem)

	if next(self.chooseItem) == nil then
		app.tip:floatTip("魂师大人，请勾选您想要购买的货物哦~")
		return
	end
	
	if self._isSecretary then
        self:playEffectOut()
		app.tip:floatTip("设置已保存~")
		return
	end
	
	if self._shopId == SHOP_ID.soulShop then
		local refushCount = app:getUserOperateRecord():getStoreQuickRefreshCount()
        if refushCount == nil then
            refushCount = QStaticDatabase:sharedDatabase():getConfigurationValue("HERO_SHOP_EASYBUY_AUTO")
        end

        if refushCount == 0 then
			app.tip:floatTip("您的魂师商店还未设置刷新次数~")
			return        	
        end
	end

	if self._isSelected then
		-- 快速一键购买
		self:popSelf()
    	remote.stores:openShopDialog(shopId)
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogStoreFastClient", 
			options = {chooseItem = self.chooseItem, shopId = self._shopId}})
	else
		-- 普通一键购买
		local buyItems, canBuy, buyToken, buyCurrency = remote.stores:checkQuickBuyItemById(self._shopId, self.chooseItem, true)
		buyToken = buyToken or 0
		buyCurrency = buyCurrency or 0
		local proxy = remote.stores:getProxyById(self._shopId)
		local buyItems, buyInfo, needInfo = proxy:getBuyInfo(self.chooseItem)
		if q.isEmpty(needInfo) == true then
			local chooseItem = self.chooseItem
			local shopId = self._shopId
			self:popSelf()
	    	remote.stores:openShopDialog(shopId)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogStoreQuickClient", 
				options = {chooseItem = chooseItem, shopId = shopId, buyItems = buyItems, buyToken = buyToken, buyCurrency = buyCurrency}})
		else
			if needInfo[1].typeName == ITEM_TYPE.TOKEN_MONEY then
				QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY)
			else
				QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, needInfo[1].typeName)
			end
		end
	end
end

function QUIDialogStoreQuickBuy:_onTriggerSelect()
	app.sound:playSound("common_small")
	if self._isSecretary then
		app.tip:floatTip("小舞助手的商店购买只能快速购买~")
		return
	end

	self._isSelected = not self._isSelected
	self._ccbOwner.sp_on:setVisible(self._isSelected)
	self._ccbOwner.sp_off:setVisible(not self._isSelected)

	app:getUserOperateRecord():setStoreSelectQuickBuyStated(self._shopId, self._isSelected)
end

function QUIDialogStoreQuickBuy:_onTriggerTips()
	app.sound:playSound("common_small")
	app.tip:floatTip("勾选“快速购买”后，一键购买时将一次性刷新剩余全部次数，并显示购买结果。")
end

function QUIDialogStoreQuickBuy:_onTriggerSetConfig(event)
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogStoreQuickBuySet", 
		options = {refershNum = self._refershNum}})

end
function QUIDialogStoreQuickBuy:_onTriggerLeft()
	app.sound:playSound("common_small")

	local isMove, shopId = remote.stores:moveNextShop(self._shopId, "left", nil, true)
	if isMove == false and shopId then
		self:moveNextShop(shopId)
	else
		app.tip:floatTip("暂未开启其他商店的一键购买功能")
	end
end

function QUIDialogStoreQuickBuy:_onTriggerRight()
	app.sound:playSound("common_small")

	local isMove, shopId = remote.stores:moveNextShop(self._shopId, "right", nil, true)
	if isMove == false and shopId then
		self:moveNextShop(shopId)
	else
		app.tip:floatTip("暂未开启其他商店的一键购买功能")
	end
end

function QUIDialogStoreQuickBuy:moveNextShop(shopId)
	local options = self:getOptions()
	options.parentOptions.type = shopId

	self:initShopInfo(options)

	self:setRefreshInfo()

	self:setItemInfo()
end

function QUIDialogStoreQuickBuy:_onScrollViewMoving()
	self._isMove = true
end

function QUIDialogStoreQuickBuy:_onScrollViewBegan()
	self._isMove = false
end

function QUIDialogStoreQuickBuy:onTriggerBackHandler(tag)
	local shopId
	if not self._isSecretary then
		shopId = self._shopId
	end
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
    remote.stores:openShopDialog(shopId)
end

function QUIDialogStoreQuickBuy:onTriggerHomeHandler(tag)
	-- local shopId = self._shopId
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    -- remote.stores:openShopDialog(shopId)
end

return QUIDialogStoreQuickBuy