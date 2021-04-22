-- @Author: xurui
-- @Date:   2020-03-16 20:52:30
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-03-18 16:09:50
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSecretarySettingItemBuy = class("QUIWidgetSecretarySettingItemBuy", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIWidgetSecretarySettingItemBuy:ctor(options)
	local ccbFile = "ccb/Widget_Secretary_setting4.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerSub", callback = handler(self, self._onTriggerSub)},
		{ccbCallbackName = "onTriggerPlus", callback = handler(self, self._onTriggerPlus)},
		{ccbCallbackName = "onSubTen", callback = handler(self, self._onTriggerSubTen)},
		{ccbCallbackName = "onPlusTen", callback = handler(self, self._onTriggerPlusTen)},
	}
	QUIWidgetSecretarySettingItemBuy.super.ctor(self, ccbFile, callBack, options)
    q.setButtonEnableShadow(self._ccbOwner.btn_plus)
    q.setButtonEnableShadow(self._ccbOwner.btn_sub)
    q.setButtonEnableShadow(self._ccbOwner.btn_plusTen)
    q.setButtonEnableShadow(self._ccbOwner.btn_subTen)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._minNum = 1
end

function QUIWidgetSecretarySettingItemBuy:onEnter()
end

function QUIWidgetSecretarySettingItemBuy:onExit()
	if self._calculatorScheduler then
		scheduler.unscheduleGlobal(self._calculatorScheduler)
		self._calculatorScheduler = nil
	end
end

function QUIWidgetSecretarySettingItemBuy:setInfo(itemInfo, curNum, costFunc)
	self._itemInfo = itemInfo
	self._costFunc = costFunc

	self._curNum = curNum or 1
	self:updateBuyNum()

	self:setItemInfo()
end

function QUIWidgetSecretarySettingItemBuy:setItemInfo()
	if self._itemBox == nil then
		self._itemBox = QUIWidgetItemsBox.new()
		self._ccbOwner.node_item:addChild(self._itemBox)
	end
	self._itemBox:setGoodsInfo(self._itemInfo.id, self._itemInfo.itemType, self._itemInfo.count)

	local itemCount = remote.items:getItemsNumByID(self._itemInfo.id)
	self._ccbOwner.tf_current_count:setString(itemCount)
end

function QUIWidgetSecretarySettingItemBuy:setMinNum(num)
	if num == nil then num = 1 end
	self._minNum = num
end


function QUIWidgetSecretarySettingItemBuy:updateBuyNum()
	local needMoney, maxNum = 0, 9999
	if self._costFunc ~= nil then
		needMoney, maxNum = self._costFunc(self._curNum)
	end
	self._maxNum = maxNum or 9999
	self._ccbOwner.tf_item_num:setString(string.format("%s/%s",self._curNum, self._maxNum))
	self._ccbOwner.tf_sell_money:setString(needMoney)
end

function QUIWidgetSecretarySettingItemBuy:_onUpHandler(num)
	self._isDown = false	
	self._isUp = true
	self:_subBuyNums(num)
end

function QUIWidgetSecretarySettingItemBuy:_onDownHandler(num)
	self._isDown = true
	self._isUp = false
	self._calculatorScheduler = scheduler.performWithDelayGlobal(function()
			self:_subBuyNums(num)
		end, 0.5)
end

function QUIWidgetSecretarySettingItemBuy:_subBuyNums(num)
	if self._calculatorScheduler then
		scheduler.unscheduleGlobal(self._calculatorScheduler)
		self._calculatorScheduler = nil
	end

	if self._isDown or self._isUp then
		if self._curNum + num <= 0 then 
			self._curNum = self._minNum
		elseif self._curNum + num > self._maxNum then 
			self._curNum = self._maxNum
		elseif self._curNum == 1 and num == 10 then
			self._curNum = 10
		else
			self._curNum = self._curNum + num
		end
		self:updateBuyNum()

		if self._isUp then return end
		self._calculatorScheduler = scheduler.performWithDelayGlobal(function()
			self:_subBuyNums(num)
		end, 0.05)
	end
end


function QUIWidgetSecretarySettingItemBuy:_onTriggerSub(event)
	if tonumber(event) == CCControlEventTouchDown then
		app.sound:playSound("common_increase")
		self:_onDownHandler(-1)
	else
		app.sound:playSound("common_increase")
		self:_onUpHandler(-1)
	end
end


function QUIWidgetSecretarySettingItemBuy:_onTriggerSubTen(event)
	if tonumber(event) == CCControlEventTouchDown then
		app.sound:playSound("common_increase")
		self:_onDownHandler(-10)
	else
		app.sound:playSound("common_increase")
		self:_onUpHandler(-10)
	end
end

function QUIWidgetSecretarySettingItemBuy:_onTriggerPlus(event)
	if tonumber(event) == CCControlEventTouchDown then
		app.sound:playSound("common_increase")
		self:_onDownHandler(1)
	else
		app.sound:playSound("common_increase")
		self:_onUpHandler(1)
	end
end

function QUIWidgetSecretarySettingItemBuy:_onTriggerPlusTen(event)
	if tonumber(event) == CCControlEventTouchDown then
		app.sound:playSound("common_increase")
		self:_onDownHandler(10)
	else
		app.sound:playSound("common_increase")
		self:_onUpHandler(10)
	end
end 

function QUIWidgetSecretarySettingItemBuy:getCurNum()
	return self._curNum
end

function QUIWidgetSecretarySettingItemBuy:getContentSize()
	local size = self._ccbOwner.node_size:getContentSize()
	return size
end

return QUIWidgetSecretarySettingItemBuy
