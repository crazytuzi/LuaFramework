-- @Author: liaoxianbo
-- @Date:   2019-05-05 14:33:28
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-07-29 17:23:02
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetQuickOpenBoxSetting = class("QUIWidgetQuickOpenBoxSetting", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

function QUIWidgetQuickOpenBoxSetting:ctor(options)
	local ccbFile = "ccb/Widget_monopoly_setting.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerBoxPlus", callback = handler(self, self._onTriggerBoxPlus)},
		{ccbCallbackName = "onTriggerBoxSub", callback = handler(self, self._onTriggerBoxSub)},
		{ccbCallbackName = "onTriggerPlus", callback = handler(self, self._onTriggerPlus)},
		{ccbCallbackName = "onTriggerSub", callback = handler(self, self._onTriggerSub)},		
    }
    QUIWidgetQuickOpenBoxSetting.super.ctor(self, ccbFile, callBacks, options)
  
	q.setButtonEnableShadow(self._ccbOwner.btn_boxplus)
	q.setButtonEnableShadow(self._ccbOwner.btn_boxsub)
	q.setButtonEnableShadow(self._ccbOwner.btn_sub)
	q.setButtonEnableShadow(self._ccbOwner.btn_plus)

  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._maxNum = 10
	self._tabId = remote.monopoly.ZIDONG_OPEN
end

function QUIWidgetQuickOpenBoxSetting:setBoxInfo(id)
	self._tabId = id
	if id == remote.monopoly.MONOPOLY_BUYNUM_CHEAST then
		self._ccbOwner.tf_title:setString("购买次数")
		local setconfig = remote.monopoly:getOneSetMonopolyId(2)
		self._curNum = setconfig.buyNum or 1
		self._maxNum = 5
	else
		self._ccbOwner.tf_title:setString("开箱次数")
		self._maxNum = 10
		local setconfig = remote.monopoly:getSelectByMonopolyId(id)
		self._curNum = setconfig.openNum or 1
	end

	self._ccbOwner.node_box:setVisible(true)
	self._ccbOwner.node_game:setVisible(false)
	self._ccbOwner.node_flower:setVisible(false)
	self:updateBuyNum(self._tabId)
end

function QUIWidgetQuickOpenBoxSetting:updateBuyNum(id)
	if id == remote.monopoly.MONOPOLY_BUYNUM_CHEAST then
		self._ccbOwner.tf_open_num:setString(self._curNum)
		self._currentMoney = 0
		
		for i=1,self._curNum do
			local consumeConfig, isFinal = QStaticDatabase:sharedDatabase():getTokenConsume("monopoly_buy_times", i)
			self._currentMoney = self._currentMoney+consumeConfig.money_num
		end 
		self._ccbOwner.tf_cost:setString(self._currentMoney)
	else
		self._ccbOwner.tf_open_num:setString(self._curNum)
		self._currentMoney = 0
		for i=1,self._curNum-1 do
			local consumeConfig, isFinal = QStaticDatabase:sharedDatabase():getTokenConsume("monopoly_buy_good_times", i)
			self._currentMoney = self._currentMoney+consumeConfig.money_num
		end 
		if self._curNum == 1 then
			self._ccbOwner.tf_cost:setString("免费")
		else
			self._ccbOwner.tf_cost:setString(self._currentMoney)
		end
	end
end

function QUIWidgetQuickOpenBoxSetting:_onUpHandler(num)
	self._isDown = false	
	self._isUp = true
	self:_subBuyNums(num)
end

function QUIWidgetQuickOpenBoxSetting:_onDownHandler(num)
	self._isDown = true
	self._isUp = false
	self._calculatorScheduler = scheduler.performWithDelayGlobal(function()
			self:_subBuyNums(num)
		end, 0.5)
end

function QUIWidgetQuickOpenBoxSetting:_subBuyNums(num)
	if self._calculatorScheduler then
		scheduler.unscheduleGlobal(self._calculatorScheduler)
		self._calculatorScheduler = nil
	end

	if self._isDown or self._isUp then
		if self._curNum + num <= 0 then 
			self._curNum = 1
		elseif self._curNum + num > self._maxNum then 
			self._curNum = self._maxNum
		elseif self._curNum == 1 and num == self._maxNum then
			self._curNum = self._maxNum
		else
			self._curNum = self._curNum + num
		end
		self:updateBuyNum(self._tabId)

		if self._isUp then return end
		self._calculatorScheduler = scheduler.performWithDelayGlobal(function()
			self:_subBuyNums(num)
		end, 0.05)
	end
end

function QUIWidgetQuickOpenBoxSetting:_onTriggerBoxSub(event)
	if tonumber(event) == CCControlEventTouchDown then
		app.sound:playSound("common_increase")
		self:_onDownHandler(-1)
	else
		app.sound:playSound("common_increase")
		self:_onUpHandler(-1)
	end
end

function QUIWidgetQuickOpenBoxSetting:_onTriggerBoxPlus(event)
	if tonumber(event) == CCControlEventTouchDown then
		app.sound:playSound("common_increase")
		self:_onDownHandler(1)
	else
		app.sound:playSound("common_increase")
		self:_onUpHandler(1)
	end
end

function QUIWidgetQuickOpenBoxSetting:_onTriggerPlus(event)
end

function QUIWidgetQuickOpenBoxSetting:_onTriggerSub(event)
end

function QUIWidgetQuickOpenBoxSetting:getCurNum()
	return self._curNum
end

function QUIWidgetQuickOpenBoxSetting:getContentSize()
	local size = self._ccbOwner.node_size:getContentSize()
	size.height = size.height + 10
	return size	
end

return QUIWidgetQuickOpenBoxSetting
