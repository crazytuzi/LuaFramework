--
-- Kumo.Wang
-- 回收站，listView item 容器
--

local QUIWidget = import(".QUIWidget")
local QUIWidgetRecycleItemContainer = class("QUIWidgetRecycleItemContainer", QUIWidget)

QUIWidgetRecycleItemContainer.EVENT_ADD = "QUIWIDGETRECYCLEITEMCONTAINER.EVENT_ADD"
QUIWidgetRecycleItemContainer.EVENT_MINUS = "QUIWIDGETRECYCLEITEMCONTAINER.EVENT_MINUS"

function QUIWidgetRecycleItemContainer:ctor(options)
	local ccbFile = "Widget_Recycle_Item_Container.ccbi"
	local callBacks = {
	}
	QUIWidgetRecycleItemContainer.super.ctor(self,ccbFile,callBacks,options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._ccbOwner.node_minus:setVisible(false)
	self:setTFNameVisible(false)
end

function QUIWidgetRecycleItemContainer:onTriggerAdd()
	print("[QUIWidgetRecycleItemContainer:onTriggerAdd()]")
	self:dispatchEvent({name = QUIWidgetRecycleItemContainer.EVENT_ADD, index = self._index})
end

function QUIWidgetRecycleItemContainer:onTriggerMinus()
	print("[QUIWidgetRecycleItemContainer:onTriggerMinus()]")
	self:dispatchEvent({name = QUIWidgetRecycleItemContainer.EVENT_MINUS, index = self._index})
end

function QUIWidgetRecycleItemContainer:onTouchListView( event )
    -- QKumo(event)
    if not event then
        return
    end
    if event.name == "began" then
    	self._beganTime = q.serverTime()
    elseif event.name == "moved" then
    	
    elseif event.name == "ended" then
    	self._beganTime = nil
    end
end

function QUIWidgetRecycleItemContainer:getContentSize()
	local size = CCSize(self._ccbOwner.node_size:getContentSize().width * self._ccbOwner.node_item:getScaleX(), self._ccbOwner.node_size:getContentSize().height * self._ccbOwner.node_item:getScaleY())
	return size
end

function QUIWidgetRecycleItemContainer:setScale(scale)
	self._ccbOwner.node_item:setScale(scale)
	self._ccbOwner.node_minus:setScale(scale)
end

function QUIWidgetRecycleItemContainer:setIndex(index)
	self._index = index
end

function QUIWidgetRecycleItemContainer:setNodeMinusVisible(boo)
	self._ccbOwner.node_minus:setVisible(boo)
end

function QUIWidgetRecycleItemContainer:setTFNameVisible(boo)
	self._ccbOwner.tf_item_name:setVisible(boo)
end

function QUIWidgetRecycleItemContainer:setTFNameValue(strName)
	if strName and strName ~= "" then
		self._ccbOwner.tf_item_name:setString(strName)
		self:setTFNameVisible(true)
	else
		self:setTFNameVisible(false)
	end
end

function QUIWidgetRecycleItemContainer:setTFNameColor(fontColor, isShadow)
	self._ccbOwner.tf_item_name:setColor(fontColor)
	if isShadow then
		self._ccbOwner.tf_item_name = setShadowByFontColor(self._ccbOwner.tf_item_name, fontColor)
	else
		TFSetDisableOutline(self._ccbOwner.tf_item_name, true)
	end
end

return QUIWidgetRecycleItemContainer
