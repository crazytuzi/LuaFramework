--
-- Author: xurui
-- Date: 2015-04-24 10:24:15
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogDivinationBuyMultiple = class("QUIDialogDivinationBuyMultiple", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("...ui.QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QQuickWay = import("...utils.QQuickWay")

QUIDialogDivinationBuyMultiple.ARENA_BUY_SUCCESS = "ARENA_BUY_SUCCESS"

function QUIDialogDivinationBuyMultiple:ctor(options)
	local ccbFile = "ccb/Dialog_Divination_Buy_Multiple.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onSub", callback = handler(self, self._onSub)},
		{ccbCallbackName = "onPlus", callback = handler(self, self._onPlus)},
		{ccbCallbackName = "onSubTen", callback = handler(self, self._onSubTen)},
		{ccbCallbackName = "onPlusTen", callback = handler(self, self._onPlusTen)},
		{ccbCallbackName = "onMax", callback = handler(self, self._onMax)},
		{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)}
	}
	QUIDialogDivinationBuyMultiple.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true
	
	if options == nil then
		options = {}
	end
	self.itemID = options.itemID
	self.maxNum = options.maxNum or 0
	self.price = options.price or 0
	self._oldData = options.data 


	self._ccbOwner.buy_content:setString("购 买")
	self._ccbOwner.item_name:setString("占卜令")
	
	self.maxNum = self.maxNum 
	self.nums = 1
	self.itemCount = remote.items:getItemsNumByID(self.itemID) or 0 

	self:init()

end

function QUIDialogDivinationBuyMultiple:viewDidAppear()
	QUIDialogDivinationBuyMultiple.super.viewDidAppear(self)
end

function QUIDialogDivinationBuyMultiple:viewWillDisappear()
	QUIDialogDivinationBuyMultiple.super.viewWillDisappear(self)

	if self._calculatorScheduler then
		scheduler.unscheduleGlobal(self._calculatorScheduler)
		self._calculatorScheduler = nil
	end
end

function QUIDialogDivinationBuyMultiple:init()
	local itemBox = QUIWidgetItemsBox.new()
	itemBox:setGoodsInfoByID(self.itemID)
	itemBox:setPromptIsOpen(true)
	self._ccbOwner.node_icon:addChild(itemBox)
	self._ccbOwner.one_sell_money:setString(self.price)
	self._ccbOwner.have_num:setString( self.itemCount )
	self:setNums()
end	



function QUIDialogDivinationBuyMultiple:setNums()
	
	if self.nums > self.itemCount then
		self._ccbOwner.totalToken:setString((self.nums - self.itemCount) * self.price)
	else
		self._ccbOwner.totalToken:setString(0)
	end
	self._ccbOwner.item_num:setString(self.nums .. "/" .. self.maxNum)
end


function  QUIDialogDivinationBuyMultiple:_onSub()
	app.sound:playSound("common_increase")

	-- self._isMaxNum = false
	if self.nums <= 1 then 
		self.nums = 1
	else
		self.nums = self.nums - 1
	end
	self:setNums()
end

function  QUIDialogDivinationBuyMultiple:_onSubTen(event)
	-- self._isMaxNum = false
	if tonumber(event) == CCControlEventTouchDown then
		self:_onDownHandler(-10)
	else
		app.sound:playSound("common_increase")
		self:_onUpHandler(-10)
	end
end

function  QUIDialogDivinationBuyMultiple:_onPlus()
	app.sound:playSound("common_increase")

	-- if self._isMaxNum then return end

	if self.nums + 1 > self.maxNum then 
		self.nums = self.maxNum
	else
		self.nums = self.nums + 1
	end
	self:setNums()
end

function  QUIDialogDivinationBuyMultiple:_onPlusTen(event)
	-- if self._isMaxNum then return end
	if tonumber(event) == CCControlEventTouchDown then
		self:_onDownHandler(10)
	else
		app.sound:playSound("common_increase")
		self:_onUpHandler(10)
	end
end

function QUIDialogDivinationBuyMultiple:_onUpHandler(num)
	self._isDown = false	
	self._isUp = true
	self:_subBuyNums(num)
end

function QUIDialogDivinationBuyMultiple:_onDownHandler(num)
	self._isDown = true
	self._isUp = false
	self._calculatorScheduler = scheduler.performWithDelayGlobal(function()
			self:_subBuyNums(num)
		end, 0.5)
end

function QUIDialogDivinationBuyMultiple:_subBuyNums(num)
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

function  QUIDialogDivinationBuyMultiple:_onMax()
	app.sound:playSound("common_increase")
	self.nums = self.maxNum
	self:setNums()
end

function QUIDialogDivinationBuyMultiple:viewAnimationOutHandler()
	self:removeSelfFromParent()
end


function  QUIDialogDivinationBuyMultiple:_onTriggerOK()
	app.sound:playSound("common_confirm")
	if self.nums == 0 then 
		app.tip:floatTip("购买数量不能为0")
		return
	end
	local imp = remote.activityRounds:getDivination()
	local oldData = self._oldData
	if imp then
		if not imp.isOpen or not imp.isActivityNotEnd then
			self:playEffectOut()
			app.tip:floatTip("当前活动已结束，下次请早！")
			return 
		end
		imp:requestDivinationBegin(self.nums, function ( data )
			-- body
			if data.divinationDivineResponse.divinationScore then
				remote.activity:updateLocalDataByType(560, data.divinationDivineResponse.divinationScore, "=")
			end

			remote.activityRounds:dispatchEvent({name = remote.activityRounds.DIVINATION_UPDATE})
			remote.redTips:setTipsStateByName("QUIActivityDialogDivination_DivinationTips", imp:checkDivinationItemRedTips())
			app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogDivinationAchievecard", 
       			options = {data = data.divinationDivineResponse or {}, oldData = oldData}})
		end)
	end
end

function QUIDialogDivinationBuyMultiple:removeSelfFromParent()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogDivinationBuyMultiple:_backClickHandler()
	 self:_onTriggerClose()
end

function  QUIDialogDivinationBuyMultiple:_onTriggerClose(e)
	if e ~= nil then
	 	app.sound:playSound("common_close")
 	end
	self:playEffectOut()
end

return QUIDialogDivinationBuyMultiple 