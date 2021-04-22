--
-- Author: Your Name
-- Date: 2016-03-23 19:09:03
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogEnchantExchange = class("QUIDialogEnchantExchange", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QScrollView = import("...views.QScrollView")
local QUIWidgetEnchantAwardsBox = import("..widgets.QUIWidgetEnchantAwardsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

function QUIDialogEnchantExchange:ctor(options)
	local ccbFile = "ccb/Dialog_shop.ccbi"
	local callBacks = {
        {ccbCallbackName = "onOK", callback = handler(self, QUIDialogEnchantExchange._onTriggerBack)},
	}
	QUIDialogEnchantExchange.super.ctor(self, ccbFile, callBacks, options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page.topBar:showWithEnchantOrient()
	
    CalculateUIBgSize(self._ccbOwner.sp_bg)

	self._isMove = false
	self._index = 1
	self.lineDistance = 0
	self.itemBox = {}
	self._totalHeight = 0
	self.line = 0
	self.row = 1
	self.rowDistance = 0

	self:autoView()
	self:chooseResources()
	self:setScrollView()
	self:setAwardsInfo()
end

function QUIDialogEnchantExchange:autoView()
	self._ccbOwner.node_btn_recharge:setVisible(false)
	self._ccbOwner.node_btn_item:setVisible(false)
	self._ccbOwner.node_btn_award:setVisible(false)
	self._ccbOwner.node_btn_auto_buy:setVisible(false)
	self._ccbOwner.node_btn_refresh:setVisible(false)
	self._ccbOwner.sp_partition:setVisible(false)
	self._ccbOwner.node_btn_quick_buy:setVisible(false)
	self._ccbOwner.node_btn_set:setVisible(false)
	self._ccbOwner.node_btn_select:setVisible(false)
	self._ccbOwner.node_total_price_info:setVisible(false)
	self._ccbOwner.node_auto_refresh:setVisible(false)
	self._ccbOwner.node_refresh_count:setVisible(false)
	self._ccbOwner.node_btn_preview:setVisible(false)
	self._ccbOwner.node_btn_right:setVisible(false)
	self._ccbOwner.node_btn_left:setVisible(false)
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

function QUIDialogEnchantExchange:chooseResources()
	local isGetName = false
	local isGetAvatar = false
	local namePath = "ui/update_shop/shop/sp_words_jifenduihuan.png"
	local avatarId = 1032
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
end

function QUIDialogEnchantExchange:viewDidAppear()
	QUIDialogEnchantExchange.super.viewDidAppear(self)
	self:addBackEvent()
end

function QUIDialogEnchantExchange:viewWillDisappear()
	QUIDialogEnchantExchange.super.viewWillDisappear(self)
	self:removeBackEvent()
end

function QUIDialogEnchantExchange:setScrollView()
	self._itemWidth = self._ccbOwner.sheet_layout:getContentSize().width
	self._itemHeight = self._ccbOwner.sheet_layout:getContentSize().height

	self._scrollView = QScrollView.new(self._ccbOwner.sheet, CCSize(self._itemWidth, self._itemHeight), {bufferMode = 1, sensitiveDistance = 10})
	-- self._scrollView:replaceGradient(self._ccbOwner.top_shadow, self._ccbOwner.bottom_shadow, nil, nil)
	self._scrollView:setVerticalBounce(true)
	self._scrollView:setHorizontalBounce(false)
	self._scrollView:setGradient(true)

    self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))
    self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))
end

function QUIDialogEnchantExchange:setAwardsInfo()
	self._scrollView:clear()
	local awardsInfo = QStaticDatabase:sharedDatabase():getEnchantOrientAwards()
	local tbl = {}
	for i, v in pairs(awardsInfo) do
		table.insert(tbl, v)
	end
	table.sort(tbl, function(a, b)
			return a.index < b.index
		end)

	local offsetX = 0
	local index = 1
	for i, v in pairs(tbl) do
		if not db:checkHeroShields(v.id, SHIELDS_TYPE.HERO_ENCHANT) then
			local isPartition = false
			if self.line == 0 then
				isPartition = true
			end
			self.line = self.line + 1
			if self.itemBox[index] == nil then
				self.itemBox[index] = QUIWidgetEnchantAwardsBox.new({position = i, shopType = "0"})
				self.itemBox[index]:addEventListener(QUIWidgetEnchantAwardsBox.EVENT_CLICK, handler(self, self.sellClickHandler))
				self._scrollView:addItemBox(self.itemBox[index])

				self._itemContent = self.itemBox[index]:getContentSize()

				local positionX = (((self._itemContent.width + self.lineDistance) * (self.line - 1)) ) + offsetX
				local positionY = -(((self._itemContent.height + self.rowDistance) * (self.row - 1)) )
				self.itemBox[index]:setPosition(ccp(positionX, positionY))
			end
			v.isPartition = isPartition
			self.itemBox[index]:setItmeBox(v)

			if index % 3 == 0 then
				self.line = 0
				self.row = self.row + 1
				self._totalHeight = self._totalHeight + self._itemContent.height + self.rowDistance
			end
			index = index + 1
		end
	end

	if (index-1) % 3 ~= 0 then
		self._totalHeight = self._totalHeight + self._itemContent.height + self.rowDistance
	end

	self._scrollView:setRect(0, -self._totalHeight, 0, (self._itemContent.width * 3))
end

function QUIDialogEnchantExchange:sellClickHandler(event)
	if self._isMove == false then
    	app.sound:playSound("common_small")
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogEnchantAwardsDetail",
			options = {shopId = self.shopType, itemInfo = event.itemInfo, position = event.position}},
		{isPopCurrentDialog = false})
	end
end

function QUIDialogEnchantExchange:_onScrollViewMoving()
	self._isMove = true
end

function QUIDialogEnchantExchange:_onScrollViewBegan()
	self._isMove = false
end

-- 对话框退出
function QUIDialogEnchantExchange:_onTriggerBack(tag, menuItem)
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

-- 返回主界面
function QUIDialogEnchantExchange:_onTriggerHome(tag, menuItem)
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogEnchantExchange