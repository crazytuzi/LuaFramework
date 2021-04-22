-- @Author: liaoxianbo
-- @Date:   2019-05-05 16:03:38
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-05-05 19:07:06
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetQuickCaiQuanSetting = class("QUIWidgetQuickCaiQuanSetting", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

function QUIWidgetQuickCaiQuanSetting:ctor(options)
	local ccbFile = "ccb/Widget_monopoly_setting.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerBoxPlus", callback = handler(self, self._onTriggerBoxPlus)},
		{ccbCallbackName = "onTriggerBoxSub", callback = handler(self, self._onTriggerBoxSub)},
		{ccbCallbackName = "onTriggerPlus", callback = handler(self, self._onTriggerPlus)},
		{ccbCallbackName = "onTriggerSub", callback = handler(self, self._onTriggerSub)},		
    }
    QUIWidgetQuickCaiQuanSetting.super.ctor(self, ccbFile, callBacks, options)
	q.setButtonEnableShadow(self._ccbOwner.btn_boxplus)
	q.setButtonEnableShadow(self._ccbOwner.btn_boxsub)
	q.setButtonEnableShadow(self._ccbOwner.btn_sub)
	q.setButtonEnableShadow(self._ccbOwner.btn_plus)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetQuickCaiQuanSetting:setBoxInfo(id)
	self._ccbOwner.tf_title:setString("猜拳次数")
	local setconfig = remote.monopoly:getSelectByMonopolyId(id)
	self._curNum = setconfig.caiQuanNum or 1
	self._ccbOwner.node_box:setVisible(false)
	self._ccbOwner.node_game:setVisible(true)
	self._ccbOwner.node_flower:setVisible(false)
	self:updateBuyNum()
end

function QUIWidgetQuickCaiQuanSetting:updateBuyNum()
	self._ccbOwner.tf_item_num:setString(self._curNum)

end

function QUIWidgetQuickCaiQuanSetting:_onUpHandler(num)
	self._isDown = false	
	self._isUp = true
	self:_subBuyNums(num)
end

function QUIWidgetQuickCaiQuanSetting:_onDownHandler(num)
	self._isDown = true
	self._isUp = false
	self._calculatorScheduler = scheduler.performWithDelayGlobal(function()
			self:_subBuyNums(num)
		end, 0.5)
end

function QUIWidgetQuickCaiQuanSetting:_subBuyNums(num)
	if self._calculatorScheduler then
		scheduler.unscheduleGlobal(self._calculatorScheduler)
		self._calculatorScheduler = nil
	end
	if self._isDown or self._isUp then
		if self._curNum + num <= 0 then 
			self._curNum = 1
		elseif self._curNum + num > 3 then 
			self._curNum = 3
		elseif self._curNum == 1 and num == 3 then
			self._curNum = 3
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

function QUIWidgetQuickCaiQuanSetting:_onTriggerBoxSub(event)

end

function QUIWidgetQuickCaiQuanSetting:_onTriggerBoxPlus(event)

end

function QUIWidgetQuickCaiQuanSetting:_onTriggerPlus(event)
	if tonumber(event) == CCControlEventTouchDown then
		app.sound:playSound("common_increase")
		self:_onDownHandler(1)
	else
		app.sound:playSound("common_increase")
		self:_onUpHandler(1)
	end	
end

function QUIWidgetQuickCaiQuanSetting:_onTriggerSub(event)
	if tonumber(event) == CCControlEventTouchDown then
		app.sound:playSound("common_increase")
		self:_onDownHandler(-1)
	else
		app.sound:playSound("common_increase")
		self:_onUpHandler(-1)
	end	
end

function QUIWidgetQuickCaiQuanSetting:getCurNum()
	return self._curNum
end

function QUIWidgetQuickCaiQuanSetting:onEnter()
end

function QUIWidgetQuickCaiQuanSetting:onExit()
end

function QUIWidgetQuickCaiQuanSetting:getContentSize()
	local size = self._ccbOwner.node_size:getContentSize()
	size.height = size.height + 10
	return size		
end

return QUIWidgetQuickCaiQuanSetting
