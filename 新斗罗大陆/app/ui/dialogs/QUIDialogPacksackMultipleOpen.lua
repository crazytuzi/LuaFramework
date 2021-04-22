--[[	
	文件名称：QUIDialogPacksackMultipleOpen.lua
	创建时间：2016-03-02 11:20:44
	作者：nieming
	描述：QUIDialogPacksackMultipleOpen
]]

local QUIDialog = import(".QUIDialog")
local QNavigationController = import("...controllers.QNavigationController")
local QRichText = import("...utils.QRichText")
local QUIDialogPacksackMultipleOpen = class("QUIDialogPacksackMultipleOpen", QUIDialog)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIViewController = import("..QUIViewController")
--初始化
function QUIDialogPacksackMultipleOpen:ctor(options)
	local ccbFile = "Dialog_Packsack_Multiple_Open.ccbi"
	local callBacks = {
		{ccbCallbackName = "onSubTen", callback = handler(self, self._onSubTen)},
		{ccbCallbackName = "onPlusTen", callback = handler(self, self._onPlusTen)},
		{ccbCallbackName = "onTriggerOpen", callback = handler(self, QUIDialogPacksackMultipleOpen._onTriggerOpen)},
		{ccbCallbackName = "onTriggerCancel", callback = handler(self, QUIDialogPacksackMultipleOpen._onTriggerCancel)},
		{ccbCallbackName = "onPlus", callback = handler(self, QUIDialogPacksackMultipleOpen._onPlus)},
		{ccbCallbackName = "onMinus", callback = handler(self, QUIDialogPacksackMultipleOpen._onMinus)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogPacksackMultipleOpen._onTriggerCancel)},

	}
	QUIDialogPacksackMultipleOpen.super.ctor(self,ccbFile,callBacks,options)
	self._itemID = options.itemId
	self._itemNum = remote.items:getItemsNumByID(self._itemID)
	self._maxOpenNum = self._itemNum
	if self._itemNum > 999 then
		self._maxOpenNum = 999
	end
	
	q.setButtonEnableShadow(self._ccbOwner.btn_plus_ten)
	q.setButtonEnableShadow(self._ccbOwner.btn_sub_ten)
	q.setButtonEnableShadow(self._ccbOwner.button_ok)
	q.setButtonEnableShadow(self._ccbOwner.button_cancel)
	q.setButtonEnableShadow(self._ccbOwner.btn_subOne)
	q.setButtonEnableShadow(self._ccbOwner.btn_plusOne)
	q.setButtonEnableShadow(self._ccbOwner.btn_close)

	self._itemInfo = QStaticDatabase:sharedDatabase():getItemByID(self._itemID)
	if not self._itemNum or not self._itemInfo then
		printError(string.format("can not find itemId = %d",options.itemId))
		return
	end
	self._callback = options.callback
	self.isAnimation = true
	self._curSelectNum = 1
	self:render()
	--代码
end

function QUIDialogPacksackMultipleOpen:render( )
	-- body

	if not self._itemIcon then
		self._ccbOwner.itemIcon:removeAllChildren()
		self._itemIcon = QUIWidgetItemsBox.new()
		self._ccbOwner.itemIcon:addChild(self._itemIcon)
	end
	self._itemIcon:setGoodsInfo(self._itemID, ITEM_TYPE.ITEM, 0)
	
	self._ccbOwner.itemName:setString(self._itemInfo.name)
	local fontColor = EQUIPMENT_COLOR[self._itemInfo.colour]
	self._ccbOwner.itemName:setColor(fontColor)
	self._ccbOwner.itemName = setShadowByFontColor(self._ccbOwner.itemName, fontColor)

	if not self._itemNumRichtext  then
		self._itemNumRichtext = QRichText.new()
		self._ccbOwner.itemNum:addChild(self._itemNumRichtext)
	end

	if self._itemInfo.type ~= 7 then
		-- self._ccbOwner.openTTF:setString("打开")
		-- self._ccbOwner.dialogTitle:setString("批量打开")
		local options = self:getOptions()
		self._ccbOwner.dialogComment:setString(options.tips or "批量使用上限为999")
	end 
	
	self._itemNumRichtext:setString({
			{oType = "font", content = "拥有: ",size = 24,color = GAME_COLOR_LIGHT.normal},
            {oType = "font", content = self._itemNum,size = 26,color = GAME_COLOR_LIGHT.stress},
            -- {oType = "font", content = "件",size = 24,color = ccc3(56,17,0)},
		})
	self:updateSelectNum()
end
function QUIDialogPacksackMultipleOpen:updateSelectNum(  )
	-- body
	self._ccbOwner.selectItemNum:setString(string.format("%d/%d",self._curSelectNum, self._maxOpenNum))


end
--describe：
function QUIDialogPacksackMultipleOpen:_onMax()
	--代码
	self._curSelectNum = self._maxOpenNum
	self:updateSelectNum()
end

--describe：
function QUIDialogPacksackMultipleOpen:_onMin()
	--代码
	self._curSelectNum = 1
	self:updateSelectNum()
end

--describe：
function QUIDialogPacksackMultipleOpen:_onTriggerOpen(event)
	-- if q.buttonEventShadow(event,self._ccbOwner.button_ok) == false then return end
    app.sound:playSound("common_small")
	app:getClient():openItemPackage(self._itemID, self._curSelectNum, function(data)
		local luckyDrawAwards = data.luckyDrawItemReward 

		if data.heroSkins then
			remote.heroSkin:openRecivedSkinDialog(data.heroSkins)
		elseif luckyDrawAwards ~= nil then
			local awards = {}
			for _,value in ipairs(luckyDrawAwards) do
				table.insert(awards, {id = value.id, typeName = value.type, count = value.count})
			end
			local callback = self._callback
			app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
			if callback ~= nil then
				callback(self._curSelectNum)
			else
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
					options = {awards = awards}})
			end
		else
			local callback = self._callback
			app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
			if callback ~= nil then
				callback(self._curSelectNum)
			else
				app.tip:floatTip(self._itemInfo.name.." 使用成功")
			end			
		end
	end)	
end

--describe：
function QUIDialogPacksackMultipleOpen:_onTriggerCancel(event)
	-- if q.buttonEventShadow(event,self._ccbOwner.button_cancel) == false then return end
	self:close()
end

--describe：
function QUIDialogPacksackMultipleOpen:_onPlus(event)
	-- if q.buttonEventShadow(event,self._ccbOwner.btn_plusOne) == false then return end
    app.sound:playSound("common_increase")
	if self._curSelectNum < self._maxOpenNum then
		self._curSelectNum = self._curSelectNum + 1
		self:updateSelectNum()
	end
end

function  QUIDialogPacksackMultipleOpen:_onPlusTen(event)
	-- if q.buttonEventShadow(event,self._ccbOwner.btn_plus_ten) == false then return end
	if tonumber(event) == CCControlEventTouchDown then
		self:_onDownHandler(10)
	else
    	app.sound:playSound("common_increase")
		self:_onUpHandler(10)
	end
end

--describe：
function QUIDialogPacksackMultipleOpen:_onMinus(event)
	-- if q.buttonEventShadow(event,self._ccbOwner.btn_subOne) == false then return end
    app.sound:playSound("common_increase")
	if self._curSelectNum > 1 then
		self._curSelectNum = self._curSelectNum - 1
		self:updateSelectNum()
	end
end

function  QUIDialogPacksackMultipleOpen:_onSubTen(event)
	-- if q.buttonEventShadow(event,self._ccbOwner.btn_sub_ten) == false then return end
	if tonumber(event) == CCControlEventTouchDown then
		self:_onDownHandler(-10)
	else
    	app.sound:playSound("common_increase")
		self:_onUpHandler(-10)
	end
end

function QUIDialogPacksackMultipleOpen:_onUpHandler(num)
	self._isDown = false	
	self._isUp = true
	self:_subBuyNums(num)
end

function QUIDialogPacksackMultipleOpen:_onDownHandler(num)
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

function QUIDialogPacksackMultipleOpen:_subBuyNums(num)
	if self._calculatorScheduler then
		scheduler.unscheduleGlobal(self._calculatorScheduler)
		self._calculatorScheduler = nil
	end

	if self._isDown or self._isUp then
		if self._curSelectNum + num <= 0 then 
			self._curSelectNum = 1
		elseif self._curSelectNum + num > self._maxOpenNum then 
			self._curSelectNum = self._maxOpenNum
		elseif self._curSelectNum == 1 and num == 10 then
			self._curSelectNum = 10
		else
			self._curSelectNum = self._curSelectNum + num
		end
		self:updateSelectNum()

		if self._isUp then return end
		self._calculatorScheduler = scheduler.performWithDelayGlobal(function()
			self:_subBuyNums(num)
		end, 0.05)
	end
end

--describe：关闭对话框
function QUIDialogPacksackMultipleOpen:close( )
	app.sound:playSound("common_cancel")
	if self._calculatorScheduler then
		scheduler.unscheduleGlobal(self._calculatorScheduler)
		self._calculatorScheduler = nil
	end
	self:playEffectOut()
end

--describe：viewAnimationOutHandler 
function QUIDialogPacksackMultipleOpen:viewAnimationOutHandler()
	--代码
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

--describe：viewDidAppear 
--function QUIDialogPacksackMultipleOpen:viewDidAppear()
	----代码
--end

function QUIDialogPacksackMultipleOpen:viewWillDisappear()
    QUIDialogPacksackMultipleOpen.super.viewWillDisappear(self)
	if self._calculatorScheduler then
		scheduler.unscheduleGlobal(self._calculatorScheduler)
		self._calculatorScheduler = nil
	end
end

--describe：viewAnimationInHandler 
--function QUIDialogPacksackMultipleOpen:viewAnimationInHandler()
	----代码
--end

--describe：_backClickHandler 
function QUIDialogPacksackMultipleOpen:_backClickHandler()
	--代码
	self:close()
end

return QUIDialogPacksackMultipleOpen
