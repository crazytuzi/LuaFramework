-- 
-- Kumo.Wang
-- 小助手——宗門玩法設置
-- 

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSecretarySettingII = class("QUIWidgetSecretarySettingII", QUIWidget)

QUIWidgetSecretarySettingII.EVENT_SELECT_CLICK = "EVENT_SELECT_CLICK"

function QUIWidgetSecretarySettingII:ctor(options)
	local ccbFile = "ccb/Widget_Secretary_setting2.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
	}
	QUIWidgetSecretarySettingII.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetSecretarySettingII:setInfo(info)
	if not info then return end
	self._info = info
	self._index = self._info.index
end

function QUIWidgetSecretarySettingII:setSelected(bSelected)
	self._ccbOwner.sp_select:setVisible(bSelected)
end

function QUIWidgetSecretarySettingII:setIndex(index)
	self._index = index
end

function QUIWidgetSecretarySettingII:getIndex()
	return self._index
end

function QUIWidgetSecretarySettingII:getContentSize()
	local size = self._ccbOwner.node_size:getContentSize()
	size.height = size.height + 10
	return size
end

function QUIWidgetSecretarySettingII:_onTriggerClick()
    app.sound:playSound("common_switch")
	self:dispatchEvent({name = QUIWidgetSecretarySettingII.EVENT_SELECT_CLICK, index = self._index})
end

return QUIWidgetSecretarySettingII