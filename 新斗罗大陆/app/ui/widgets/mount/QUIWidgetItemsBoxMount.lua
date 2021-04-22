local QUIWidgetItemsBox = import("...widgets.QUIWidgetItemsBox")
local QUIWidgetItemsBoxMount = class("QUIWidgetItemsBoxMount", QUIWidgetItemsBox)
local QNotificationCenter = import("....controllers.QNotificationCenter")


QUIWidgetItemsBoxMount.EVENT_CLICK = "EVENT_CLICK"
QUIWidgetItemsBoxMount.EVENT_CLICK_END = "EVENT_CLICK_END"
QUIWidgetItemsBoxMount.EVENT_BEGAIN = "ITEM_EVENT_BEGAIN"
QUIWidgetItemsBoxMount.EVENT_END = "ITEM_EVENT_END"
QUIWidgetItemsBoxMount.EVENT_MINUS_CLICK = "EVENT_MINUS_CLICK"
QUIWidgetItemsBoxMount.EVENT_MINUS_CLICK_END = "EVENT_MINUS_CLICK_END"

function QUIWidgetItemsBoxMount:ctor(options)
	QUIWidgetItemsBoxMount.super.ctor(self, options)
	self._ccbOwner.tf_goods_name:setFontSize(18)
end

function QUIWidgetItemsBoxMount:onEnter()
	QUIWidgetItemsBoxMount.super.onEnter(self)
end

function QUIWidgetItemsBoxMount:onExit()
	QUIWidgetItemsBoxMount.super.onExit(self)
	
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
	if self._timeMinusHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeMinusHandler)
		self._timeMinusHandler = nil
	end
end

function QUIWidgetItemsBoxMount:setInfo(config)
	self._config = config
	self:setGoodsInfo(config.id, ITEM_TYPE.ITEM, config.selectedCount .. "/" .. config.count, true)
	self:showMinusButton(config.selectedCount > 0)
end

function QUIWidgetItemsBoxMount:setGoodsInfo(itemID, itemType, goodsNum, froceShow)
	QUIWidgetItemsBoxMount.super.setGoodsInfo(self, itemID, itemType, goodsNum, froceShow)
	self:showItemName()
end

function QUIWidgetItemsBoxMount:showMinusButton(visible)
	self._ccbOwner.minus:setVisible(visible)
end

function QUIWidgetItemsBoxMount:getContentSize()
	return self._ccbOwner.node_scrap_bj:getContentSize()
end

function QUIWidgetItemsBoxMount:_onTouch(event)
	if event.name == "began" then 
		self:onDownHandler()
	elseif event.name == "ended" or event.name == "cancelled" then 
	    self:_onTriggerClick()
		self:onUpHandler()
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetItemsBoxMount.EVENT_CLICK_END , itemID = self._itemID, source = self})
  	end
end

function QUIWidgetItemsBoxMount:onDownHandler()
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
	self.interval = 0.2
 
	self._timeHandler = scheduler.performWithDelayGlobal(handler(self, self.consecutivePush), 1)
end

function QUIWidgetItemsBoxMount:onUpHandler( ... )
	self.interval = 0.2
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
end

function QUIWidgetItemsBoxMount:consecutivePush( ... )
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end

    self:_onTriggerClick()
	self._timeHandler = scheduler.performWithDelayGlobal(handler(self, self.consecutivePush), self.interval)
	self.interval = self.interval - 0.02
	if self.interval < 0.05 then self.interval = 0.05 end
end

function QUIWidgetItemsBoxMount:_onTriggerClick()
	QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetItemsBoxMount.EVENT_CLICK , itemID = self._itemID, source = self})
end

function QUIWidgetItemsBoxMount:_onTriggerMinus(event)
	if event.name == "began" then 
		self:onMinusDownHandler()
	elseif event.name == "ended" or event.name == "cancelled" then 
		self:onMinusUpHandler()
    	self:_onTriggerMinusClick()
		self:onUpHandler()
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetItemsBoxMount.EVENT_MINUS_CLICK_END , itemID = self._itemID, source = self})
  	end
end

function QUIWidgetItemsBoxMount:onMinusDownHandler()
	if self._timeMinusHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeMinusHandler)
		self._timeMinusHandler = nil
	end

	self._timeMinusHandler = scheduler.performWithDelayGlobal(handler(self, self.consecutiveMinusPush), 1)
end

function QUIWidgetItemsBoxMount:onMinusUpHandler( ... )
	if self._timeMinusHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeMinusHandler)
		self._timeMinusHandler = nil
	end
	self.interval = 0.2
end

function QUIWidgetItemsBoxMount:consecutiveMinusPush( ... )
	if self._timeMinusHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeMinusHandler)
		self._timeMinusHandler = nil
	end

    self:_onTriggerMinusClick()
	self._timeMinusHandler = scheduler.performWithDelayGlobal(handler(self, self.consecutiveMinusPush), self.interval)
	self.interval = self.interval - 0.02
	if self.interval < 0.05 then self.interval = 0.05 end
end

function QUIWidgetItemsBoxMount:_onTriggerMinusClick()
	QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetItemsBoxMount.EVENT_MINUS_CLICK , itemID = self._itemID, source = self})
end

return QUIWidgetItemsBoxMount