-- @Author: liaoxianbo
-- @Date:   2020-01-19 10:55:15
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-01-19 11:56:52
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogChestGoldNewBuy = class("QUIDialogChestGoldNewBuy", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogChestGoldNewBuy:ctor(options)
	local ccbFile = "ccb/Dialog_vritualBuy_count_new.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerBuy", callback = handler(self, self._onTriggerBuy)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerSelect1", callback = handler(self, self._onTriggerSelect1)},
		{ccbCallbackName = "onTriggerSelect2", callback = handler(self, self._onTriggerSelect2)},
	}
	QUIDialogChestGoldNewBuy.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._buyNum = 1
	self._price = 0
	self._actualPrice = 0
	if options then
		self._itemId = options.itemId
		self._buyNum = options.buyNum or 1
		self._price = options.price or 0
		self._isHalf = options.isHalf or false
		self._callback = options.callback
		self._buyType = options.buyType
		self._isHalf = options.isHalf
	end

	self._isBuy = false
    self._ccbOwner.frame_tf_title:setString("购 买")
end

function QUIDialogChestGoldNewBuy:viewDidAppear()
	QUIDialogChestGoldNewBuy.super.viewDidAppear(self)

	self:setClientInfo()

	self:setSelectState(2)

	self:addBackEvent(false)
end

function QUIDialogChestGoldNewBuy:viewWillDisappear()
	QUIDialogChestGoldNewBuy.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogChestGoldNewBuy:setClientInfo()
	self._ccbOwner.itemParent:removeAllChildren()
	local itembox = QUIWidgetItemsBox.new()
	itembox:setGoodsInfoByID(self._itemId)
	self._ccbOwner.itemParent:addChild(itembox)
 	
 	self._ccbOwner.tf_tips1:setVisible(self._isHalf)

	local itemConfig = db:getItemByID(self._itemId)
	-- set item info
	self._ccbOwner.tf_name:setString(itemConfig.name)
	local haveNum = remote.items:getItemsNumByID(self._itemId)
	self._ccbOwner.have_num:setString(haveNum or 0)
	if self._ccbOwner["node_"..EQUIPMENT_QUALITY[itemConfig.colour]] then
		self._ccbOwner["node_"..EQUIPMENT_QUALITY[itemConfig.colour]]:setVisible(true)
	end
	local goldCost = db:getConfigurationValue("ADVANCE_LUCKY_DRAW_TOKEN_COST")
	local buqiNum = self._buyNum - haveNum
	self._ccbOwner.tf_item_num_1:setString("x "..buqiNum)
	if self._isHalf then
		self._actualPrice = (buqiNum*goldCost - goldCost/2)
	else
		self._actualPrice = (buqiNum*goldCost)
	end
	self._ccbOwner.tf_token_num_1:setString(self._actualPrice)
	-- set small icon 
	-- if self._icon == nil and itemConfig.icon_1 then
	-- 	self._icon = CCSprite:create(itemConfig.icon_1)
	-- 	self._icon:setScale(0.7)
	-- 	self._ccbOwner.sp_Item_icon:addChild(self._icon)
	-- end

	self._ccbOwner.tf_item_num_2:setString("x "..self._buyNum or 1)
	self._ccbOwner.tf_token_num_2:setString(self._price)
	
end

function QUIDialogChestGoldNewBuy:setSelectState(index)
	self._selectType = index
	self._ccbOwner.sp_select1:setVisible(self._selectType == 1)
	self._ccbOwner.sp_select2:setVisible(self._selectType == 2)
end

function QUIDialogChestGoldNewBuy:_onTriggerBuy(event)
	if q.buttonEventShadow(event, self._ccbOwner.buy) == false then return end
  	app.sound:playSound("common_confirm")
	self._isBuy = true
	self:_onTriggerClose()
end

function QUIDialogChestGoldNewBuy:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogChestGoldNewBuy:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogChestGoldNewBuy:_onTriggerSelect1()
	app.sound:playSound("common_small")

	self:setSelectState(1)
end

function QUIDialogChestGoldNewBuy:_onTriggerSelect2()
	app.sound:playSound("common_small")

	self:setSelectState(2)
end

function QUIDialogChestGoldNewBuy:viewAnimationOutHandler()
	local callback = self._callback
	local _select = self._select
	local buyType = self._buyType

	self:popSelf()

	if _select == true then
		app:getUserOperateRecord():recordeCurrentTime(buyType)
	end

	if self._isBuy and callback then
		if self._selectType == 2 then
			callback(self._price)
		else
			callback(self._actualPrice)
		end
	end
end

return QUIDialogChestGoldNewBuy
