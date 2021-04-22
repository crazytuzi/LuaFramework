
-- 本地调试配置的按钮

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetLocalConfigSelect = class("QUIWidgetLocalConfigSelect", QUIWidget)

QUIWidgetLocalConfigSelect.EVENT_SELECT_CHANGED = "LOCAL_CONFIG_EVENT_SELECT_CHANGED"

function QUIWidgetLocalConfigSelect:ctor(options)
	local ccbFile = "ccb/Widget_local_config_single.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
	}
	QUIWidgetLocalConfigSelect.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._configs = nil
	self._isSelected = false
	self._isSingleMode = options.isSingle

	self._ccbOwner.node_single:setVisible(self._isSingleMode)
	self._ccbOwner.node_multiple:setVisible(not self._isSingleMode)
end

function QUIWidgetLocalConfigSelect:setInfo(config)
	self._configs = config
	self._ccbOwner.tf_name:setString(self._configs.showName)
end

-- 多选模式设置value，单选模式根据value设置选中状态
function QUIWidgetLocalConfigSelect:setValue(value)
	if not self._isSingleMode then
		self:setSelected(value)
	else
		self:setSelected(self._configs.values == value)
	end
end
 
-- 多选模式返回选中状态，单选模式返回value
function QUIWidgetLocalConfigSelect:getValue()
	if not self._isSingleMode then
		return self._isSelected
	end

	return self._configs.values
end

-- 选中或强制模式返回key，否则返回nil
function QUIWidgetLocalConfigSelect:getKey(isForce)
	if self._isSelected or isForce then
		return self._configs.key
	end
	return nil
end

function QUIWidgetLocalConfigSelect:getGroup()
	return self._configs.group
end

function QUIWidgetLocalConfigSelect:getId()
	return self._configs.id
end

function QUIWidgetLocalConfigSelect:isSelected()
	return self._isSelected
end

function QUIWidgetLocalConfigSelect:setSelected(isSelected)
	self._isSelected = isSelected
	self._ccbOwner.sp_single_select:setVisible(self._isSelected)
	self._ccbOwner.sp_multiple_select:setVisible(self._isSelected)
end

function QUIWidgetLocalConfigSelect:_onTriggerClick()
	self:setSelected(not self._isSelected)
	self:dispatchEvent({ 
		name = QUIWidgetLocalConfigSelect.EVENT_SELECT_CHANGED, 
		source = self, 
		configs = self._configs,
		isSingle = self._isSingleMode
	})
end

function QUIWidgetLocalConfigSelect:getContentSize()
	local boxSize = self._ccbOwner.sp_multiple_select:getContentSize()
	local tfPosX = self._ccbOwner.tf_name:getPositionX()
	local tfWidth = self._ccbOwner.tf_name:getContentSize().width

	return CCSize(tfPosX + tfWidth + 30, boxSize.height)
end

return QUIWidgetLocalConfigSelect