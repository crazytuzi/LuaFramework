-- @Author: xurui
-- @Date:   2019-12-09 11:49:18
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-12-09 12:32:10

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSecretarySettingSelect = class("QUIWidgetSecretarySettingSelect", QUIWidget)

QUIWidgetSecretarySettingSelect.EVENT_SELECT_CLICK = "EVENT_SELECT_CLICK"

function QUIWidgetSecretarySettingSelect:ctor(options)
	local ccbFile = "ccb/Widget_Secretary_setting3.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerSub", callback = handler(self, self._onTriggerSub)},
		{ccbCallbackName = "onSubTen", callback = handler(self, self._onTriggerSubTen)},
		{ccbCallbackName = "onTriggerPlus", callback = handler(self, self._onTriggerPlus)},
		{ccbCallbackName = "onPlusTen", callback = handler(self, self._onTriggerPlusTen)},
	}
	QUIWidgetSecretarySettingSelect.super.ctor(self, ccbFile, callBack, options)
    q.setButtonEnableShadow(self._ccbOwner.btn_plus)
    q.setButtonEnableShadow(self._ccbOwner.btn_sub)
    q.setButtonEnableShadow(self._ccbOwner.btn_plusTen)
    q.setButtonEnableShadow(self._ccbOwner.btn_subTen)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._minNum = 1
end

function QUIWidgetSecretarySettingSelect:onExit()
	if self._calculatorScheduler then
		scheduler.unscheduleGlobal(self._calculatorScheduler)
		self._calculatorScheduler = nil
	end
end

function QUIWidgetSecretarySettingSelect:setInfo(id, curNum)
	self._setId = id

	self._curNum = curNum or 1
	self:updateBuyNum()
end

function QUIWidgetSecretarySettingSelect:setTitleDesc(str, desc)
	if str == nil then str = "" end
	if desc == nil then desc = "" end
	
	self._ccbOwner.tf_title:setString(str)
	self._ccbOwner.tf_desc:setString(desc)
end

function QUIWidgetSecretarySettingSelect:updateBuyNum()
	self._ccbOwner.tf_item_num:setString(self._curNum)
end

function QUIWidgetSecretarySettingSelect:_onUpHandler(num)
	self._isDown = false	
	self._isUp = true
	self:_subBuyNums(num)
end

function QUIWidgetSecretarySettingSelect:_onDownHandler(num)
	self._isDown = true
	self._isUp = false
	self._calculatorScheduler = scheduler.performWithDelayGlobal(function()
			self:_subBuyNums(num)
		end, 0.5)
end

function QUIWidgetSecretarySettingSelect:_subBuyNums(num)
	if self._calculatorScheduler then
		scheduler.unscheduleGlobal(self._calculatorScheduler)
		self._calculatorScheduler = nil
	end

	if self._isDown or self._isUp then
		if self._curNum + num <= 0 then 
			self._curNum = 0
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

function QUIWidgetSecretarySettingSelect:_onTriggerSub(event)
	if tonumber(event) == CCControlEventTouchDown then
		app.sound:playSound("common_increase")
		self:_onDownHandler(-1)
	else
		app.sound:playSound("common_increase")
		self:_onUpHandler(-1)
	end
end

function QUIWidgetSecretarySettingSelect:_onTriggerSubTen(event)
	if tonumber(event) == CCControlEventTouchDown then
		app.sound:playSound("common_increase")
		self:_onDownHandler(-10)
	else
		app.sound:playSound("common_increase")
		self:_onUpHandler(-10)
	end
end

function QUIWidgetSecretarySettingSelect:_onTriggerPlus(event)
	if tonumber(event) == CCControlEventTouchDown then
		app.sound:playSound("common_increase")
		self:_onDownHandler(1)
	else
		app.sound:playSound("common_increase")
		self:_onUpHandler(1)
	end
end

function QUIWidgetSecretarySettingSelect:_onTriggerPlusTen(event)
	if tonumber(event) == CCControlEventTouchDown then
		app.sound:playSound("common_increase")
		self:_onDownHandler(10)
	else
		app.sound:playSound("common_increase")
		self:_onUpHandler(10)
	end
end 

function QUIWidgetSecretarySettingSelect:getCurNum()
	return self._curNum
end

function QUIWidgetSecretarySettingSelect:getContentSize()
	local size = self._ccbOwner.node_size:getContentSize()
	return size
end

return QUIWidgetSecretarySettingSelect
