--
-- Author: wkwang
-- Date: 2014-10-29 15:20:04
--
local QUIDialog = import(".QUIDialog")
local QUIDialogBackpackSell = class("QUIDialogBackpackSell", QUIDialog)

local QUIWidgetItemsBox =  import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNavigationController = import("...controllers.QNavigationController")

function QUIDialogBackpackSell:ctor(options)
	local ccbFile = "ccb/Dialog_PacksackSell.ccbi"
	local callBacks = {
		{ccbCallbackName = "onPlus", 				callback = handler(self, QUIDialogBackpackSell._onPlus)},
		{ccbCallbackName = "onSub", 				callback = handler(self, QUIDialogBackpackSell._onSub)},
		{ccbCallbackName = "onSubTen", 				callback = handler(self, self._onSubTen)},
		{ccbCallbackName = "onPlusTen", 			callback = handler(self, self._onPlusTen)},
		{ccbCallbackName = "onTriggerOK", 			callback = handler(self, QUIDialogBackpackSell._onTriggerOK)},
		{ccbCallbackName = "onTriggerClose", 		callback = handler(self, QUIDialogBackpackSell._onTriggerClose)},
	}
	QUIDialogBackpackSell.super.ctor(self,ccbFile,callBacks,options)
    self.isAnimation = true

	self._itemId = options.itemId
	self._itemNum = remote.items:getItemsNumByID(self._itemId)
	self._itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self._itemId)

	self._sellNum = 1
	self._maxNum = self._itemNum
	self._minNum = 1

	self._nameMaxSize = 120
	
	q.setButtonEnableShadow(self._ccbOwner.btn_plusOne)
	q.setButtonEnableShadow(self._ccbOwner.btn_plusTen)
	q.setButtonEnableShadow(self._ccbOwner.btn_subOne)
	q.setButtonEnableShadow(self._ccbOwner.btn_subTen)
	q.setButtonEnableShadow(self._ccbOwner.btn_ok)

	if self._itemIcon == nil then
		self._itemIcon = QUIWidgetItemsBox.new()
		self._ccbOwner.node_icon:removeAllChildren()
		self._ccbOwner.node_icon:addChild(self._itemIcon)
	end
	self._itemIcon:resetAll()
	self._itemIcon:setGoodsInfo(self._itemId, ITEM_TYPE.ITEM, 0)

	self._ccbOwner.tf_name:setString(self._itemConfig.name)
	local fontColor = EQUIPMENT_COLOR[self._itemConfig.colour]
	self._ccbOwner.tf_name:setColor(fontColor)
	self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)

	self._ccbOwner.tf_num:setString(self._itemNum)
	self._ccbOwner.tf_sell_money:setString(self._itemConfig.selling_price or 0)
	self:countMoney()
	self._isSell = false
end

function QUIDialogBackpackSell:countMoney()
	self._ccbOwner.tf_item_num:setString(self._sellNum.."/"..self._maxNum)

	local nameWidth = self._ccbOwner.tf_item_num:getContentSize().width
	self._ccbOwner.tf_item_num:setScale(1)
	if nameWidth > self._nameMaxSize then
		self._ccbOwner.tf_item_num:setScale(1-(nameWidth - self._nameMaxSize)/self._nameMaxSize)
	end

	self._ccbOwner.tf_get_money:setString(self._sellNum * (self._itemConfig.selling_price or 0))
end

function QUIDialogBackpackSell:_onPlus(event)
	-- if q.buttonEventShadow(event,self._ccbOwner.btn_plusOne) == false then return end
	app.sound:playSound("common_increase")
	if self._sellNum < self._maxNum then
		self._sellNum = self._sellNum + 1
		self:countMoney()
	end
end

function  QUIDialogBackpackSell:_onPlusTen(event)
	-- if q.buttonEventShadow(event,self._ccbOwner.btn_plusTen) == false then return end
	app.sound:playSound("common_increase")

	if tonumber(event) == CCControlEventTouchDown then
		self:_onDownHandler(10)
	else
		self:_onUpHandler(10)
	end
end

function QUIDialogBackpackSell:_onSub(event)
	-- if q.buttonEventShadow(event,self._ccbOwner.btn_subOne) == false then return end
	app.sound:playSound("common_increase")
	if self._sellNum > self._minNum then
		self._sellNum = self._sellNum - 1
		self:countMoney()
	end
end

function  QUIDialogBackpackSell:_onSubTen(event)
	-- if q.buttonEventShadow(event,self._ccbOwner.btn_subTen) == false then return end
	app.sound:playSound("common_increase")

	if tonumber(event) == CCControlEventTouchDown then
		self:_onDownHandler(-10)
	else
		self:_onUpHandler(-10)
	end
end

function QUIDialogBackpackSell:_onUpHandler(num)
	self._isDown = false	
	self._isUp = true
	self:_subBuyNums(num)
end

function QUIDialogBackpackSell:_onDownHandler(num)
	self._isDown = true
	self._isUp = false
	if self._calculatorScheduler then
		scheduler.unscheduleGlobal(self._calculatorScheduler)
		self._calculatorScheduler = nil
	end
	self._calculatorScheduler = scheduler.performWithDelayGlobal(function()
			self:_subBuyNums(num)
		end, 0.5)
end

function QUIDialogBackpackSell:_subBuyNums(num)
	if self._calculatorScheduler then
		scheduler.unscheduleGlobal(self._calculatorScheduler)
		self._calculatorScheduler = nil
	end

	if self._isDown or self._isUp then

		if self._sellNum + num <= 0 then 
			self._sellNum = 1
		elseif self._sellNum + num > self._maxNum then 
			self._sellNum = self._maxNum
		elseif self._sellNum == 1 and num == 10 then 
			self._sellNum = 10
		else
			self._sellNum = self._sellNum + num
		end
		self:countMoney()

		if self._isUp then return end
		self._calculatorScheduler = scheduler.performWithDelayGlobal(function()
			self:_subBuyNums(num)
		end, 0.05)
	end
end

function QUIDialogBackpackSell:_onTriggerOK(event)
	-- if q.buttonEventShadow(event,self._ccbOwner.btn_ok) == false then return end
	if self._isSell == true then return end
	app.sound:playSound("common_confirm")
	self._isSell = true
  	local sellItem = {{type = self._itemId, count = self._sellNum}}
	app:getClient():sellItem(sellItem,function (data)
			self:_onTriggerClose()
		end, function ()
			self._isSell = false
		end)
end

function QUIDialogBackpackSell:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogBackpackSell:_onTriggerClose()
	app.sound:playSound("common_close")
	if self._calculatorScheduler then
		scheduler.unscheduleGlobal(self._calculatorScheduler)
		self._calculatorScheduler = nil
	end
    self:playEffectOut()
end

function QUIDialogBackpackSell:viewAnimationOutHandler()
    self:removeSelfFromParent()
end

function QUIDialogBackpackSell:removeSelfFromParent()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogBackpackSell