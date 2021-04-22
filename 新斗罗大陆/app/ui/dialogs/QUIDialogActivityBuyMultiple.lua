local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogActivityBuyMultiple = class("QUIDialogActivityBuyMultiple", QUIDialog)
local QStaticDatabase = import("...controllers.QStaticDatabase")

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogActivityBuyMultiple:ctor(options)
	local ccbFile = "ccb/Dialog_Pilianglingqu.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onMax", callback = handler(self, self._onMax)},
        {ccbCallbackName = "onMin", callback = handler(self, self._onMin)},
        {ccbCallbackName = "onPlus", callback = handler(self, self._onPlus)},
        {ccbCallbackName = "onSub", callback = handler(self, self._onSub)},
        {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
    }
    QUIDialogActivityBuyMultiple.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true

	self._items = options.items
	self._isItemExchange = options.isItemExchange
	self._maxCount = options.maxCount
	self._price = options.price 
	self._moneyType = options.moneyType
	self._callback = options.callback
	self._ccbOwner.frame_tf_title:setString("兑 换")

	if self._isItemExchange then
		self._ccbOwner.dialogComment:setString("剩余次数：")
		self._ccbOwner.sp_money:setVisible(false)

		self._ccbOwner.dialogComment:setPositionX(self._ccbOwner.dialogComment:getPositionX() + 40)
		self._ccbOwner.openTTF:setString("兑 换")
	else
		local respath = remote.items:getURLForItem(self._moneyType, "alphaIcon")
		self._ccbOwner.sp_money:setTexture(CCTextureCache:sharedTextureCache():addImage(respath))
	end
	
	if self._items.typeName == ITEM_TYPE.ITEM then
		local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self._items.id)
		self._ccbOwner.itemName:setString(itemConfig.name)
		self._ccbOwner.have_num:setString(remote.items:getItemsNumByID(self._items.id))
	else
		local itemType, itemName = remote.items:getItemType(self._items.typeName)
		self._ccbOwner.itemName:setString(itemName)
		self._ccbOwner.have_num:setString(remote.user[itemType] or 0)
	end
	local itemBox = QUIWidgetItemsBox.new()
	itemBox:setGoodsInfo(self._items.id, self._items.typeName, self._items.count)
	self._ccbOwner.itemIcon:addChild(itemBox)
	
	self._ccbOwner.tf_end:setPositionX(self._ccbOwner.have_num:getPositionX() + self._ccbOwner.have_num:getContentSize().width)
	self._count = 1
	self:updateCount()
end

function QUIDialogActivityBuyMultiple:updateCount()
	if not self._isItemExchange then
		self._ccbOwner.item_num:setString(self._count.."/"..self._maxCount)
		self._ccbOwner.dialogPrice:setString(self._count * self._price)
	else
		self._ccbOwner.item_num:setString(self._count.."/"..self._maxCount)
		self._ccbOwner.dialogPrice:setString(self._maxCount - self._count )	
	end
end

function QUIDialogActivityBuyMultiple:_onMax(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_plusTen) == false then return end
	if event ~= nil then
    	app.sound:playSound("common_increase")
	end
	self._count = self._maxCount
	self:updateCount()
end

function QUIDialogActivityBuyMultiple:_onMin(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_subTen) == false then return end
	if event ~= nil then
    	app.sound:playSound("common_increase")
	end
	self._count = 1
	self:updateCount()
end

function QUIDialogActivityBuyMultiple:_onPlus(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_plusOne) == false then return end
	if event ~= nil then
    	app.sound:playSound("common_increase")
	end
	self._count = self._count + 1
	self._count = math.min(self._count, self._maxCount)
	self:updateCount()
end

function QUIDialogActivityBuyMultiple:_onSub(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_subOne) == false then return end
	if event ~= nil then
    	app.sound:playSound("common_increase")
	end
	self._count = self._count - 1
	self._count = math.max(self._count, 1)
	self:updateCount()
end

function QUIDialogActivityBuyMultiple:_onTriggerOK(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end
	if self._isBuy == true then return end
	self._isBuy = true
	self:_onTriggerClose()
end

function QUIDialogActivityBuyMultiple:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogActivityBuyMultiple:_backClickHandler()
	 self:_onTriggerClose()
end

function QUIDialogActivityBuyMultiple:viewAnimationOutHandler()
	local isBuy = self._isBuy
	local callback = self._callback
	local count = self._count
	self:popSelf()
	if isBuy == true then
		callback(count)
	end
end

return QUIDialogActivityBuyMultiple