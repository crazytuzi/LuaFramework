-- @Author: xurui
-- @Date:   2016-12-14 10:19:32
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-09-21 14:22:06
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogBuyInvasionChest = class("QUIDialogBuyInvasionChest", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIDialogBuyInvasionChest:ctor(options)
	local ccbFile = "ccb/Dialog_Panjun_piliangkaiqi.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onSub", callback = handler(self, self._onSub)},
		{ccbCallbackName = "onPlus", callback = handler(self, self._onPlus)},
		{ccbCallbackName = "onSubTen", callback = handler(self, self._onSubTen)},
		{ccbCallbackName = "onPlusTen", callback = handler(self, self._onPlusTen)},
		{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)}
	}
	QUIDialogBuyInvasionChest.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._index = options.index
	self._callback = options.callback
	self._cancelBack = options.cancelBack
	self.nums = 1
	self._isBuy = false

	q.setButtonEnableShadow(self._ccbOwner.btn_plusOne)
	q.setButtonEnableShadow(self._ccbOwner.btn_plusTen)
	q.setButtonEnableShadow(self._ccbOwner.btn_subOne)
	q.setButtonEnableShadow(self._ccbOwner.btn_subTen)
	
	self:setInfo()
end

function QUIDialogBuyInvasionChest:viewDidAppear()
	QUIDialogBuyInvasionChest.super.viewDidAppear(self)
end

function QUIDialogBuyInvasionChest:viewWillDisappear()
	QUIDialogBuyInvasionChest.super.viewWillDisappear(self)
end

function QUIDialogBuyInvasionChest:setInfo()
	self._chestId = remote.invasion.CHEST[self._index]
	self._keyId = remote.invasion.KEY[self._index]
	for i=1,3 do
	    self._ccbOwner["sp_chest"..i]:setVisible(false)
	    self._ccbOwner["sp_key1_"..i]:setVisible(false)                                                                       
	    self._ccbOwner["sp_key2_"..i]:setVisible(false)
	end
	self._ccbOwner["sp_chest"..self._index]:setVisible(true)
	self._ccbOwner["sp_key1_"..self._index]:setVisible(true)
	self._ccbOwner["sp_key2_"..self._index]:setVisible(true)

	local chestInfo = QStaticDatabase:sharedDatabase():getItemByID(self._chestId)
	self._chestCount = remote.items:getItemsNumByID(self._chestId)
	self._keyCount = remote.items:getItemsNumByID(self._keyId)

	self._ccbOwner.tf_name:setString(chestInfo.name or "")
	self._ccbOwner.tf_chest_count:setString(self._chestCount)
	self._ccbOwner.tf_key_count:setString(self._keyCount)

	self.maxNum = math.min(self._chestCount, self._keyCount)

	self:setNums()
end

function QUIDialogBuyInvasionChest:setNums()
	self._ccbOwner.tf_item_num:setString(self.nums .. "/" .. self.maxNum)
	self._ccbOwner.tf_get_money:setString(self.nums)
end

function  QUIDialogBuyInvasionChest:_onSub(event)
	-- if q.buttonEventShadow(event,self._ccbOwner.btn_subOne) == false then return end
	
	app.sound:playSound("common_increase")

	-- self._isMaxNum = false
	if self.nums - 1 <= 0 then 
		self.nums = 1
	else
		self.nums = self.nums - 1
	end
	self:setNums()
end

function  QUIDialogBuyInvasionChest:_onSubTen(event)
	-- if q.buttonEventShadow(event,self._ccbOwner.btn_subTen) == false then return end
	-- self._isMaxNum = false
	if tonumber(event) == CCControlEventTouchDown then
		self:_onDownHandler(-10)
	else
		app.sound:playSound("common_increase")
		self:_onUpHandler(-10)
	end
end

function  QUIDialogBuyInvasionChest:_onPlus(event)
	-- if q.buttonEventShadow(event,self._ccbOwner.btn_plusOne) == false then return end
	app.sound:playSound("common_increase")

	-- if self._isMaxNum then return end

	if self.nums + 1 > self.maxNum then 
		self.nums = self.maxNum < 1 and 1 or self.maxNum
	else
		self.nums = self.nums + 1
	end
	self:setNums()
end

function  QUIDialogBuyInvasionChest:_onPlusTen(event)
	-- if q.buttonEventShadow(event,self._ccbOwner.btn_plusTen) == false then return end
	-- if self._isMaxNum then return end
	if tonumber(event) == CCControlEventTouchDown then
		self:_onDownHandler(10)
	else
		app.sound:playSound("common_increase")
		self:_onUpHandler(10)
	end
end

function QUIDialogBuyInvasionChest:_onUpHandler(num)
	self._isDown = false	
	self._isUp = true
	self:_subBuyNums(num)
end

function QUIDialogBuyInvasionChest:_onDownHandler(num)
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

function QUIDialogBuyInvasionChest:_subBuyNums(num)
	if self._calculatorScheduler then
		scheduler.unscheduleGlobal(self._calculatorScheduler)
		self._calculatorScheduler = nil
	end

	if self._isDown or self._isUp then
		if self.nums + num <= 0 then 
			self.nums = 1
		elseif self.nums + num > self.maxNum then 
			self.nums =  self.maxNum < 1 and 1 or self.maxNum
		elseif self.nums == 1 and  num == 10 then 
			self.nums =  10
		else
			self.nums = self.nums + num
		end
		self:setNums()

		if self._isUp then return end
		self._calculatorScheduler = scheduler.performWithDelayGlobal(function()
			self:_subBuyNums(num)
		end, 0.05)
	end
end

function QUIDialogBuyInvasionChest:viewAnimationOutHandler()
	local callback = self._callback
	local cancelBack = self._cancelBack
	local isBuy = self._isBuy
	self:popSelf()
	if isBuy then
		remote.invasion:intrusionOpenBossBoxRequest(self._index, self.nums,nil, function (data)
			if callback then
				callback(data, self.nums)
			end
		end)
	else
		if cancelBack then
			cancelBack(data)
		end
	end
end

function QUIDialogBuyInvasionChest:_onTriggerOK(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end
	self._isBuy = true
	self:_onTriggerClose()
end

function QUIDialogBuyInvasionChest:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogBuyInvasionChest:_onTriggerClose()
	if self._calculatorScheduler then
		scheduler.unscheduleGlobal(self._calculatorScheduler)
		self._calculatorScheduler = nil
	end
	self:playEffectOut()
end

return QUIDialogBuyInvasionChest