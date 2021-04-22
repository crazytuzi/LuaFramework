-- 
-- zxs
-- 小助手购买次数选择
-- 

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSecretarySettingBuy = class("QUIWidgetSecretarySettingBuy", QUIWidget)

QUIWidgetSecretarySettingBuy.EVENT_SELECT_CLICK = "EVENT_SELECT_CLICK"

function QUIWidgetSecretarySettingBuy:ctor(options)
	local ccbFile = "ccb/Widget_Secretary_setting1.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerSub", callback = handler(self, self._onTriggerSub)},
		{ccbCallbackName = "onTriggerPlus", callback = handler(self, self._onTriggerPlus)},
	}
	QUIWidgetSecretarySettingBuy.super.ctor(self, ccbFile, callBack, options)
    q.setButtonEnableShadow(self._ccbOwner.btn_plus)
    q.setButtonEnableShadow(self._ccbOwner.btn_sub)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._minNum = 1
end

function QUIWidgetSecretarySettingBuy:onExit()
	if self._calculatorScheduler then
		scheduler.unscheduleGlobal(self._calculatorScheduler)
		self._calculatorScheduler = nil
	end
end

function QUIWidgetSecretarySettingBuy:setResourceIcon(typeName)
	local info = remote.items:getWalletByType(typeName)
	if info ~= nil and info.alphaIcon ~= nil then
		local texture = CCTextureCache:sharedTextureCache():addImage(info.alphaIcon)
		self._ccbOwner.sp_icon:setTexture(texture)
	end
end

function QUIWidgetSecretarySettingBuy:setInfo(id, curNum, costFunc)
	self._setId = id
	self._costFunc = costFunc

	self._curNum = curNum or 1
	self:updateBuyNum()
end

function QUIWidgetSecretarySettingBuy:setMinNum(num)
	if num == nil then num = 1 end
	self._minNum = num
end

function QUIWidgetSecretarySettingBuy:setBuyTitle(str)
	if str == nil then return end
	
	self._ccbOwner.tf_buy_title:setString(str)
end

function QUIWidgetSecretarySettingBuy:updateBuyNum()
	self._ccbOwner.tf_item_num:setString(self._curNum)
	local needMoney, maxNum = 0, 9999
	if self._costFunc == nil then
		local dataProxy = remote.secretary:getSecretaryDataProxyById(self._setId)
		needMoney, maxNum = dataProxy:getBuyCost(self._curNum)
	else
		needMoney, maxNum = self._costFunc(self._curNum)
	end
	self._maxNum = maxNum or 9999
	self._ccbOwner.tf_cost:setString(needMoney)
end

function QUIWidgetSecretarySettingBuy:_onUpHandler(num)
	self._isDown = false	
	self._isUp = true
	self:_subBuyNums(num)
end

function QUIWidgetSecretarySettingBuy:_onDownHandler(num)
	self._isDown = true
	self._isUp = false
	self._calculatorScheduler = scheduler.performWithDelayGlobal(function()
			self:_subBuyNums(num)
		end, 0.5)
end

function QUIWidgetSecretarySettingBuy:_subBuyNums(num)
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

function QUIWidgetSecretarySettingBuy:_onTriggerSub(event)
	if tonumber(event) == CCControlEventTouchDown then
		app.sound:playSound("common_increase")
		self:_onDownHandler(-1)
	else
		app.sound:playSound("common_increase")
		self:_onUpHandler(-1)
	end
end

function QUIWidgetSecretarySettingBuy:_onTriggerPlus(event)
	if tonumber(event) == CCControlEventTouchDown then
		app.sound:playSound("common_increase")
		self:_onDownHandler(1)
	else
		app.sound:playSound("common_increase")
		self:_onUpHandler(1)
	end
end

function QUIWidgetSecretarySettingBuy:getCurNum()
	return self._curNum
end

function QUIWidgetSecretarySettingBuy:getContentSize()
	local size = self._ccbOwner.node_size:getContentSize()
	return size
end

return QUIWidgetSecretarySettingBuy