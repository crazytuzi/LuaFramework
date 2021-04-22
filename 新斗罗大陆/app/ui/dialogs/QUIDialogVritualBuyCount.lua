-- @Author: xurui
-- @Date:   2017-04-12 16:11:44
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-10-29 18:46:54
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogVritualBuyCount = class("QUIDialogVritualBuyCount", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogVritualBuyCount:ctor(options)
	local ccbFile = "ccb/Dialog_vritualBuy_count.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerBuy", callback = handler(self, self._onTriggerBuy)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},
	}
	QUIDialogVritualBuyCount.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._buyNum = 1
	self._price = 0
	if options then
		self._itemId = options.itemId
		self._buyNum = options.buyNum or 1
		self._price = options.price or 0
		self._callback = options.callback
		self._buyType = options.buyType
		self._isHalf = options.isHalf
	end

	self._isBuy = false
	self._select = false
    self._ccbOwner.frame_tf_title:setString("购 买")
end

function QUIDialogVritualBuyCount:viewDidAppear()
	QUIDialogVritualBuyCount.super.viewDidAppear(self)

	self:setClientInfo()

	self:setSelectState()

	self:addBackEvent(false)
end

function QUIDialogVritualBuyCount:viewWillDisappear()
	QUIDialogVritualBuyCount.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogVritualBuyCount:setClientInfo()
	self._ccbOwner.itemParent:removeAllChildren()
	local itembox = QUIWidgetItemsBox.new()
	itembox:setGoodsInfoByID(self._itemId)
	self._ccbOwner.itemParent:addChild(itembox)
 
	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self._itemId)
	-- set item info
	self._ccbOwner.tf_name:setString(itemConfig.name)
	local haveNum = remote.items:getItemsNumByID(self._itemId)
	self._ccbOwner.have_num:setString(haveNum or 0)
	if self._ccbOwner["node_"..EQUIPMENT_QUALITY[itemConfig.colour]] then
		self._ccbOwner["node_"..EQUIPMENT_QUALITY[itemConfig.colour]]:setVisible(true)
	end
	-- set small icon 
	if self._icon == nil and itemConfig.icon_1 then
		self._icon = CCSprite:create(itemConfig.icon_1)
		self._icon:setScale(0.7)
		self._ccbOwner.sp_Item_icon:addChild(self._icon)
	end
	self._ccbOwner.tf_item_num:setString("x "..self._buyNum or 1)
	self._ccbOwner.tf_token_num:setString(self._price)
	self._ccbOwner.sp_line:setVisible(false)
	self._ccbOwner.tf_token:setString("")
	
	-- 半价
	if self._isHalf then
		self._ccbOwner.tf_token:setString(math.floor(self._price/2))
		self._ccbOwner.sp_line:setVisible(true)
	end
end

function QUIDialogVritualBuyCount:setSelectState()
	self._ccbOwner.sp_select:setVisible(self._select)
end

function QUIDialogVritualBuyCount:_onTriggerBuy(event)
	if q.buttonEventShadow(event, self._ccbOwner.buy) == false then return end
  	app.sound:playSound("common_confirm")
	self._isBuy = true
	self:_onTriggerClose()
end

function QUIDialogVritualBuyCount:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogVritualBuyCount:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogVritualBuyCount:_onTriggerSelect()
	app.sound:playSound("common_small")

	self._select = not self._select

	self:setSelectState()
end

function QUIDialogVritualBuyCount:viewAnimationOutHandler()
	local callback = self._callback
	local _select = self._select
	local buyType = self._buyType

	self:popSelf()

	if _select == true then
		app:getUserOperateRecord():recordeCurrentTime(buyType)
	end

	if self._isBuy and callback then
		callback()
	end
end

return QUIDialogVritualBuyCount