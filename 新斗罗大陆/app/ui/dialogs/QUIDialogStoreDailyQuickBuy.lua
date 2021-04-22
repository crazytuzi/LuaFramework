-- @Author: zhouxiaoshu
-- @Date:   2019-05-28 11:04:32
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-12-23 18:30:34

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogStoreDailyQuickBuy = class("QUIDialogStoreDailyQuickBuy", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QListView = import("...views.QListView")
local QUIWidgetStoreQuickBuyClient = import("..widgets.QUIWidgetStoreQuickBuyClient")
local QVIPUtil = import("...utils.QVIPUtil")
local QQuickWay = import("...utils.QQuickWay")

function QUIDialogStoreDailyQuickBuy:ctor(options)
	local ccbFile = "ccb/Dialog_shop.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerQuickBuy", callback = handler(self, self._onTriggerQuickBuy)},
	}
	QUIDialogStoreDailyQuickBuy.super.ctor(self, ccbFile, callBack, options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setAllUIVisible(false)
	page.topBar:showWithMainPage()
	page._scaling:willPlayHide()
	
    CalculateUIBgSize(self._ccbOwner.sp_bg)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._shopId = options.shopId
	self._isSecretary = options.isSecretary
	self._rowMaxCount = 3

	q.setButtonEnableShadow(self._ccbOwner.btn_set)
	q.setButtonEnableShadow(self._ccbOwner.btn_quick_buy)
	q.setButtonEnableShadow(self._ccbOwner.btn_tips)
	
	if self._isSecretary then
		self.isAnimation = true
		self._ccbOwner.node_btn_left:setVisible(false)
		self._ccbOwner.node_btn_right:setVisible(false)
		self._ccbOwner.tf_btn_quick_buy:setString("确认选择")
	end

	self:resetAll()
	self:autoView()
	self:initShopInfo()
	self:initListView()
	local refreshShop = remote.exchangeShop:checkCanRefreshShop(self._shopId)
	if refreshShop then
		remote.exchangeShop:exchangeShopGetRequest(self._shopId, function()
				self:initListView()
			end)
	end
end

function QUIDialogStoreDailyQuickBuy:autoView()
	self._ccbOwner.node_btn_preview:setVisible(false)
	self._ccbOwner.sp_partition:setVisible(false)
	-- -- 设置底部桌面的宽度（适配）
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

function QUIDialogStoreDailyQuickBuy:resetAll()
	self._ccbOwner.node_btn_preview:setVisible(false)
	self._ccbOwner.node_btn_auto_buy:setVisible(false)
	self._ccbOwner.node_btn_refresh:setVisible(false)
	self._ccbOwner.node_btn_item:setVisible(false)
	self._ccbOwner.node_btn_award:setVisible(false)
	self._ccbOwner.node_btn_recharge:setVisible(false)
	
	self._ccbOwner.node_btn_quick_buy:setVisible(true)
	self._ccbOwner.node_btn_set:setVisible(false)
	self._ccbOwner.node_btn_select:setVisible(false)
	self._ccbOwner.node_total_price_info:setVisible(true)
end

function QUIDialogStoreDailyQuickBuy:viewDidAppear()
	QUIDialogStoreDailyQuickBuy.super.viewDidAppear(self)

	self:addBackEvent()
end

function QUIDialogStoreDailyQuickBuy:viewWillDisappear()
	QUIDialogStoreDailyQuickBuy.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogStoreDailyQuickBuy:initShopInfo()
	self._shopInfo = remote.stores:getShopResousceByShopId(self._shopId)
	self._itemBox = {}
	local chooseItem = app:getUserOperateRecord():getShopLimitQuickBuyConfiguration(self._shopId)
	self._chooseItem = self:recheckChooseItem(chooseItem)
	-- self._ccbOwner.tf_shop_title:setString(self._shopInfo.titleName)
	local isGetName = false
	local isGetAvatar = false
	if self._shopInfo then
		local namePath = self._shopInfo.namePath
		local avatarId = self._shopInfo.avatarId
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

	self._ccbOwner.tf_auto_refresh_title:setString("系统将根据您的选择按最大兑换次数购买商品\n货币不足时，将根据您的选择顺序依次购买")
	self._ccbOwner.tf_auto_refresh_time:setVisible(false)
	self._ccbOwner.tf_refresh_count:setVisible(false)
	self._ccbOwner.node_auto_refresh:setVisible(true)
	self._ccbOwner.node_refresh_count:setVisible(false)

	local iconPath = remote.items:getWalletByType(self._shopInfo.currencyType).alphaIcon
	self._ccbOwner.sp_money:setTexture(CCTextureCache:sharedTextureCache():addImage(iconPath))
end

function QUIDialogStoreDailyQuickBuy:recheckChooseItem( chooseItems )
	if not next(chooseItems) then 
		return chooseItems
	end
	
	local newChooseItems
	local shops = remote.exchangeShop:getShopInfoById(self._shopId)
	self._data = self:filterShopInfo(shops)

	for i = #chooseItems, 1, -1 do
		local choose = chooseItems[1]
		for j, itemInfo in pairs(self._data) do
			if itemInfo.grid_id == choose.grid_id and itemInfo.item_id ~= choose.itemId then
    			table.remove(chooseItems, i)
			end
		end
	end
	return chooseItems
end

function QUIDialogStoreDailyQuickBuy:initListView()
	local shops = remote.exchangeShop:getShopInfoById(self._shopId)
	self._data = self:filterShopInfo(shops)

	for index, value in ipairs(self._data) do
		if index % self._rowMaxCount == 1 then
			value.isPartition = true
		end
		value.index = index
	end

	self._curOriginOffset = 10
	if self._data and #self._data <= 6 then
		local item = QUIWidgetStoreQuickBuyClient.new()
		local size = item:getContentSize()
		local row = math.ceil(#self._data/self._rowMaxCount)
		self._curOriginOffset = (self._s9sLeftAndRightHeight - row * size.height) * 0.4
	end

	if not self._listView then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemFunc),
	        curOriginOffset = self._curOriginOffset,
	        isVertical = true,
	        enableShadow = false,
	      	ignoreCanDrag = false,
	      	multiItems = self._rowMaxCount,
	      	curOffset = 10,
	        totalNumber = #self._data,
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listView:refreshData()
	end

	local buyInfo = remote.exchangeShop:getShopBuyInfo(self._shopId)
	local tokenNum = 0
	local moneyNum = 0
	for i, v in pairs(self._data) do
		local selectNum = self:getSelectNum(v.grid_id)
		if selectNum > 0 then
			local buyNum = buyInfo[tostring(v.grid_id)] or 0
			local lostNum = (v.exchange_number or 0) - buyNum
			if v.resource_1 == "token" then
				tokenNum = tokenNum + v.resource_number_1*lostNum
			else
				moneyNum = moneyNum + v.resource_number_1*lostNum
			end
		end
	end

	local num,unit = q.convertLargerNumber(tokenNum)
	self._ccbOwner.tf_token:setString(num..unit)
	local num,unit = q.convertLargerNumber(moneyNum)
	self._ccbOwner.tf_money:setString(num..unit)
end

function QUIDialogStoreDailyQuickBuy:_renderItemFunc( list, index, info )
    local isCacheNode = true
    local itemData = self._data[index]
    local item = list:getItemFromCache(self._selectTab)
    if not item then
		item = QUIWidgetStoreQuickBuyClient.new()
		item:addEventListener(QUIWidgetStoreQuickBuyClient.EVENT_CLICK, handler(self, self.sellClickHandler))
    	isCacheNode = false
    end
    item:setInfo({info = itemData, chooseItem = self._chooseItem, typeNum = 2, shopId = self._shopId, isPartition = itemData.isPartition})
    info.item = item
    info.size = item:getContentSize()

	list:registerBtnHandler(index, "btn_item_click", "_onTirggerItemClick")
	list:registerBtnHandler(index, "btn_click", "_onTriggerClick")

    return isCacheNode
end

function QUIDialogStoreDailyQuickBuy:filterShopInfo(shopInfo)
	local newShopInfos = {}
	local userLevel = remote.user.level or 0
	local vipLevel = QVIPUtil:VIPLevel() or 0
	for i = 1, #shopInfo do
		if userLevel >= shopInfo[i].team_minlevel and userLevel <= shopInfo[i].team_maxlevel and vipLevel >= shopInfo[i].vip_id then
			newShopInfos[i] = shopInfo[i]
		end
	end
	table.sort( newShopInfos, function(a, b)
		if a.show_grid_id and b.show_grid_id then
			return a.show_grid_id < b.show_grid_id
		elseif a.grid_id and b.grid_id then
			return a.grid_id < b.grid_id
		else
			return a.good_id < b.good_id
		end
	end)
	return newShopInfos
end 

function QUIDialogStoreDailyQuickBuy:getSelectNum(gridId)
	for i, v in pairs(self._chooseItem) do
    	if v.gridId == gridId then
    		return i
    	end
    end
    return 0
end

function QUIDialogStoreDailyQuickBuy:sellClickHandler(event)
	if event.name == nil or not event.itemInfo then return end
    app.sound:playSound("common_small")

    local itemInfo = event.itemInfo
    local isDelete = false
    for i, v in pairs(self._chooseItem) do
    	if v.gridId == itemInfo.grid_id then
    		table.remove(self._chooseItem, i)
    		isDelete = true
    		break
    	end
    end

    if not isDelete then
    	table.insert(self._chooseItem, {gridId = itemInfo.grid_id, itemId = itemInfo.item_id})
    end
	self:initListView()
end

function QUIDialogStoreDailyQuickBuy:_onTriggerQuickBuy()
	app.sound:playSound("common_small")

	if next(self._chooseItem) == nil then
		app.tip:floatTip("魂师大人，请勾选您想要购买的货物哦~")
		return
	end
	
	app:getUserOperateRecord():setShopLimitQuickBuyConfiguration(self._shopId, self._chooseItem)
	app.tip:floatTip("设置已保存~")

    self:playEffectOut()
end

function QUIDialogStoreDailyQuickBuy:onTriggerBackHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogStoreDailyQuickBuy:onTriggerHomeHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogStoreDailyQuickBuy