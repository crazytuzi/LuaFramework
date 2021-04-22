-- 
-- zxs
-- 玩法日历每天的每个任务
-- 

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSecretarySetting = class("QUIWidgetSecretarySetting", QUIWidget)

QUIWidgetSecretarySetting.EVENT_SELECT_CLICK = "EVENT_SELECT_CLICK"

function QUIWidgetSecretarySetting:ctor(options)
	local ccbFile = "ccb/Widget_Secretary_setting.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
	}
	QUIWidgetSecretarySetting.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._oldTitlePos = ccp(self._ccbOwner.tf_name:getPosition())
	self._isNotSelect = false
end

function QUIWidgetSecretarySetting:setInfo(info)
	self._info = info
	self._index = self._info.index
	self._ccbOwner.tf_name:setString(info.desc or "")
end

function QUIWidgetSecretarySetting:setSelectTitle(title)
	if title == nil then return end
	self._ccbOwner.tf_name:setString(title)
end

function QUIWidgetSecretarySetting:setTitleAnchorPoint(point)
	if point == nil then return end
	self._ccbOwner.tf_name:setAnchorPoint(point)
end
 

function QUIWidgetSecretarySetting:setTitleDimensions(size)
	if size == nil then return end
	self._ccbOwner.tf_name:setDimensions(size)
end

function QUIWidgetSecretarySetting:setTitlePosition(posX, posY)
	if posX then
		self._ccbOwner.tf_name:setPositionX(self._oldTitlePos.x + posX)
	end
	if posY then
		self._ccbOwner.tf_name:setPositionY(self._oldTitlePos.y + posY)
	end
end

function QUIWidgetSecretarySetting:setNotChooseState(b)
	self._isNotSelect = b
end

function QUIWidgetSecretarySetting:setSelected(bSelected)
	self._isSelect = bSelected
	self._ccbOwner.sp_select:setVisible(bSelected)
end

function QUIWidgetSecretarySetting:setIndex(index)
	self._index = index
end

function QUIWidgetSecretarySetting:getIndex()
	return self._index
end

function QUIWidgetSecretarySetting:getContentSize()
	local size = self._ccbOwner.node_size:getContentSize()
	size.height = size.height + 10
	return size
end

function QUIWidgetSecretarySetting:_onTriggerClick()
	if self._isNotSelect then return end
    app.sound:playSound("common_switch")

    self._isSelect = not self._isSelect
    self:setSelected(self._isSelect)
	self:dispatchEvent({name = QUIWidgetSecretarySetting.EVENT_SELECT_CLICK, index = self._index, isSelect = self._isSelect})
end

return QUIWidgetSecretarySetting