local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSellItems = class("QUIDialogSellItems", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogSellItems:ctor(options)
	local ccbFile = "ccb/Dialog_ItemSell.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIDialogSellItems._onTriggerConfirm)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogSellItems._onTriggerClose)},
        {ccbCallbackName = "onTriggerSelected", callback = handler(self, self._onTriggerSelected)},
	}
	QUIDialogSellItems.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true
	self.isSell = false
    self._isSelected = false

	self:resetAll()

	self.sellItems = remote.items:getSellMoneyItem()

	self:setItemInfo()
	
	q.setButtonEnableShadow(self._ccbOwner.button_ok)

	if app.unlock:checkLock("UNLOCK_SELL_GOLDEN") == false then
		self._ccbOwner.node_select:setVisible(false)
	end
end

function QUIDialogSellItems:viewDidAppear()
	QUIDialogSellItems.super.viewDidAppear(self)
	self.prompt = app:promptTips()
	self.prompt:addItemEventListener(self)

    self:showSelectState()
end

function QUIDialogSellItems:viewWillDisappear()
	QUIDialogSellItems.super.viewWillDisappear(self)
  	self.prompt:removeItemEventListener()
end

function QUIDialogSellItems:viewAnimationOutHandler()
  	self:removeSelfFromParent()
  	if self.isSell == true then
		local items = remote.items:itemSort(self.sellItems)
		app:getClient():sellItem(items, function(data)
	  
		end)
  	end
end

function QUIDialogSellItems:resetAll()
  	for i = 1, 4, 1 do
		self._ccbOwner["tf_value"..i]:setString("")
  	end
  	self._ccbOwner.money_num:setString("")
end

function QUIDialogSellItems:setItemInfo()
  	local money = 0
  	for i = 1, #self.sellItems, 1 do
		local itemInfo = QStaticDatabase.sharedDatabase():getItemByID(self.sellItems[i].type)
		if self.sellItems[i].type == "8" then

		end
		self._ccbOwner["tf_value"..i]:setString(itemInfo.name.."x"..self.sellItems[i].count)
		local itemBox = QUIWidgetItemsBox.new()
		self._ccbOwner["item"..i]:addChild(itemBox)
		itemBox:setGoodsInfo(self.sellItems[i].type, ITEM_TYPE.ITEM, 0)
		itemBox:setPromptIsOpen(true)
	
		money = money + self.sellItems[i].count * (itemInfo.selling_price or 0)
  	end
  	self._ccbOwner.money_num:setString(money)
end

function QUIDialogSellItems:showSelectState()
    self._ccbOwner.btn_select:setHighlighted(not (self._isSelected == true))
    
    app:getUserOperateRecord():setStoreAutoSellItem(self._isSelected)
end

function QUIDialogSellItems:_onTriggerConfirm()
  	self.isSell = true
  	self:_onTriggerClose()
end

function QUIDialogSellItems:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogSellItems:_onTriggerClose()
	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogSellItems:_onTriggerSelected()
    self._isSelected = not self._isSelected
    self:showSelectState()
end

function QUIDialogSellItems:removeSelfFromParent()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogSellItems
