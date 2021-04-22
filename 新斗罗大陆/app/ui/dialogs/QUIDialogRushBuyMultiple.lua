--[[	
	文件名称：QUIDialogRushBuyMultiple.lua
	创建时间：2017-02-14 11:25:34
	作者：nieming
	描述：QUIDialogRushBuyMultiple
]]


local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogRushBuyMultiple = class("QUIDialogRushBuyMultiple", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("...ui.QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QQuickWay = import("...utils.QQuickWay")

QUIDialogRushBuyMultiple.ARENA_BUY_SUCCESS = "ARENA_BUY_SUCCESS"

function QUIDialogRushBuyMultiple:ctor(options)
	local ccbFile = "Dialog_SixYuan_Buy.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onSub", callback = handler(self, self._onSub)},
		{ccbCallbackName = "onPlus", callback = handler(self, self._onPlus)},
		{ccbCallbackName = "onSubTen", callback = handler(self, self._onSubTen)},
		{ccbCallbackName = "onPlusTen", callback = handler(self, self._onPlusTen)},
		
		{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)}
	}
	QUIDialogRushBuyMultiple.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true
	
	if options == nil then
		options = {}
	end

	self.maxNum = options.maxNum or 0
	self.maxBuyNum =  options.maxBuyNum or 0
	self.issue = options.issue or 0
	self.nums = 1
	self:setNums()
end

function QUIDialogRushBuyMultiple:viewDidAppear()
	QUIDialogRushBuyMultiple.super.viewDidAppear(self)
end

function QUIDialogRushBuyMultiple:viewWillDisappear()
	QUIDialogRushBuyMultiple.super.viewWillDisappear(self)

	if self._calculatorScheduler then
		scheduler.unscheduleGlobal(self._calculatorScheduler)
		self._calculatorScheduler = nil
	end
end


function QUIDialogRushBuyMultiple:setNums()
	self._ccbOwner.money:setString(self.nums )
	self._ccbOwner.leftTimes:setString(self.maxNum)
	self._ccbOwner.label:setString(self.nums .. "/" .. self.maxNum)
	if self.nums >= 100 then
		self._ccbOwner.node1:setPositionX(-17)
	else
		self._ccbOwner.node1:setPositionX(-5)
	end
end


function  QUIDialogRushBuyMultiple:_onSub()
	app.sound:playSound("common_increase")

	-- self._isMaxNum = false
	if self.nums <= 1 then 
		self.nums = 1
	else
		self.nums = self.nums - 1
	end
	self:setNums()
end

function  QUIDialogRushBuyMultiple:_onSubTen(event)
	-- self._isMaxNum = false
	if tonumber(event) == CCControlEventTouchDown then
		self:_onDownHandler(-10)
	else
		app.sound:playSound("common_increase")
		self:_onUpHandler(-10)
	end
end

function  QUIDialogRushBuyMultiple:_onPlus()
	app.sound:playSound("common_increase")

	-- if self._isMaxNum then return end

	if self.nums + 1 > self.maxNum then 
		self.nums = self.maxNum
	else
		self.nums = self.nums + 1
	end
	self:setNums()
end

function  QUIDialogRushBuyMultiple:_onPlusTen(event)
	-- if self._isMaxNum then return end
	if tonumber(event) == CCControlEventTouchDown then
		self:_onDownHandler(10)
	else
		app.sound:playSound("common_increase")
		self:_onUpHandler(10)
	end
end

function QUIDialogRushBuyMultiple:_onUpHandler(num)
	self._isDown = false	
	self._isUp = true
	self:_subBuyNums(num)
end

function QUIDialogRushBuyMultiple:_onDownHandler(num)
	self._isDown = true
	self._isUp = false
	self._calculatorScheduler = scheduler.performWithDelayGlobal(function()
			self:_subBuyNums(num)
		end, 0.5)
end

function QUIDialogRushBuyMultiple:_subBuyNums(num)
	if self._calculatorScheduler then
		scheduler.unscheduleGlobal(self._calculatorScheduler)
		self._calculatorScheduler = nil
	end

	if self._isDown or self._isUp then
		if self.nums + num <= 1 then 
			self.nums = 1
		elseif self.nums + num > self.maxNum then 
			self.nums = self.maxNum
		elseif num == 10 and self.nums == 1 then
			self.nums = 10
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

-- function  QUIDialogRushBuyMultiple:_onMax()
-- 	app.sound:playSound("common_increase")
-- 	self.nums = self.maxNum
-- 	self:setNums()
-- end

function QUIDialogRushBuyMultiple:viewAnimationOutHandler()
	self:removeSelfFromParent()
end


function  QUIDialogRushBuyMultiple:_onTriggerOK()
	app.sound:playSound("common_confirm")
	if self.nums == 0 then 
		app.tip:floatTip("购买数量不能为0")
		return
	end
	local imp = remote.activityRounds:getRushBuy()
	if imp then
		if not imp.isOpen or not imp.isActivityNotEnd then
			self:playEffectOut()
			app.tip:floatTip("当前活动已结束，下次请早！")
			return 
		end

		app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
		imp:requestBuyNums(self.issue, self.nums, function ( data )
			
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRushBuyAchieveProp", 
       			options = {data = data or {} }})
		end)

	end
end

function QUIDialogRushBuyMultiple:removeSelfFromParent()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogRushBuyMultiple:_backClickHandler()
	 self:_onTriggerClose()
end

function  QUIDialogRushBuyMultiple:_onTriggerClose(e)
	if e ~= nil then
	 	app.sound:playSound("common_close")
 	end
	self:playEffectOut()
end

return QUIDialogRushBuyMultiple 


