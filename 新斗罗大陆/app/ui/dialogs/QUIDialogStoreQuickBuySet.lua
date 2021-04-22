-- @Author: vicentboo
-- @Date:   2019-08-29 17:41:31
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-11-11 18:00:41
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogStoreQuickBuySet = class("QUIDialogStoreQuickBuySet", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

function QUIDialogStoreQuickBuySet:ctor(options)
	local ccbFile = "ccb/Dialog_StoreQuickBuySetting.ccbi"
    local callBacks = {
		{ccbCallbackName = "onPlus", callback = handler(self, self._onPlus)},
		{ccbCallbackName = "onSub", callback = handler(self, self._onSub)},
		{ccbCallbackName = "onPlusTen", callback = handler(self, self._onPlusTen)},
		{ccbCallbackName = "onSubTen", callback = handler(self, self._onSubTen)},
		{ccbCallbackName = "onMax", callback = handler(self, self._onMax)},
		{ccbCallbackName = "onTriggerOk", callback = handler(self, self._onTriggerOk)},
		{ccbCallbackName = "onTriggerCancel", callback = handler(self, self._onTriggerCancel)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogStoreQuickBuySet.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	q.setButtonEnableShadow(self._ccbOwner.btn_plus)
	q.setButtonEnableShadow(self._ccbOwner.btn_sub)
	q.setButtonEnableShadow(self._ccbOwner.btn_plusTen)

	q.setButtonEnableShadow(self._ccbOwner.btn_subTen)
	q.setButtonEnableShadow(self._ccbOwner.btn_max)
	q.setButtonEnableShadow(self._ccbOwner.btn_ok)
	q.setButtonEnableShadow(self._ccbOwner.btn_cancel)
	
    if options then
    	self._callBack = options.callBack
    	self._refershMaxNum = options.refershNum or 0
    end

    self._curNum = app:getUserOperateRecord():getStoreQuickRefreshCount()
    if self._curNum == nil then
    	self._curNum = QStaticDatabase:sharedDatabase():getConfigurationValue("HERO_SHOP_EASYBUY_AUTO")
    end

    self:initSettingLayer()
end

function QUIDialogStoreQuickBuySet:viewDidAppear()
	QUIDialogStoreQuickBuySet.super.viewDidAppear(self)
	-- self:addBackEvent(true)
end


function QUIDialogStoreQuickBuySet:viewWillDisappear()
  	QUIDialogStoreQuickBuySet.super.viewWillDisappear(self)

	-- self:removeBackEvent()
	if self._calculatorScheduler then
		scheduler.unscheduleGlobal(self._calculatorScheduler)
		self._calculatorScheduler = nil
	end	
end

function QUIDialogStoreQuickBuySet:initSettingLayer()
	self._ccbOwner.tf_title_name:setString("自动刷新")
	self:updateNum()
end

function QUIDialogStoreQuickBuySet:updateNum()
	self._ccbOwner.tf_item_num:setString(self._curNum)
end
function QUIDialogStoreQuickBuySet:_onDownHandler(num)
	self._isDown = true
	self._isUp = false
	self._calculatorScheduler = scheduler.performWithDelayGlobal(function()
			self:_subBuyNums(num)
		end, 0.5)
end

function QUIDialogStoreQuickBuySet:_subBuyNums(num)
	print("num=",num)
	-- if self._calculatorScheduler then
	-- 	scheduler.unscheduleGlobal(self._calculatorScheduler)
	-- 	self._calculatorScheduler = nil
	-- end

	-- if self._isDown or self._isUp then
		if self._curNum + num <= 0 then 
			self._curNum = 1
		elseif self._curNum + num > self._refershMaxNum then 
			self._curNum = self._refershMaxNum
		elseif self._curNum == 1 and num == self._refershMaxNum then
			self._curNum = self._refershMaxNum
		else
			self._curNum = self._curNum + num
		end
		self._ccbOwner.tf_item_num:setString(self._curNum)

		-- if self._isUp then return end
		-- self._calculatorScheduler = scheduler.performWithDelayGlobal(function()
		-- 	self:_subBuyNums(num)
		-- end, 0.05)
	-- end
end


function QUIDialogStoreQuickBuySet:_onSub(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_sub) == false then return end	
	app.sound:playSound("common_increase")
	self:_subBuyNums(-1)
end

function QUIDialogStoreQuickBuySet:_onPlus(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_plus) == false then return end	
	app.sound:playSound("common_increase")
	self:_subBuyNums(1)

end

function QUIDialogStoreQuickBuySet:_onPlusTen(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_plusTen) == false then return end
	app.sound:playSound("common_increase")
	self:_subBuyNums(10)	
end

function QUIDialogStoreQuickBuySet:_onSubTen(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_subTen) == false then return end
	app.sound:playSound("common_increase")
	self:_subBuyNums(-10)	
end

function QUIDialogStoreQuickBuySet:_onMax(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_max) == false then return end
	app.sound:playSound("common_increase")
	self:_subBuyNums(self._refershMaxNum)	
end

function QUIDialogStoreQuickBuySet:_onTriggerOk(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end

	app.sound:playSound("common_small")

	app:getUserOperateRecord():setStoreQuickRefreshCount(self._curNum)
	self:_onTriggerClose()
end

function QUIDialogStoreQuickBuySet:_onTriggerCancel(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_cancel) == false then return end
	app.sound:playSound("common_small")
	self:_onTriggerClose()
end

-- function QUIDialogStoreQuickBuySet:_backClickHandler()
--     self:_onTriggerClose()
-- end

function QUIDialogStoreQuickBuySet:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end


function QUIDialogStoreQuickBuySet:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogStoreQuickBuySet
