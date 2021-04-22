-- 
-- zxs
-- 小助手小标题
-- 

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSecretarySettingTitle = class("QUIWidgetSecretarySettingTitle", QUIWidget)

QUIWidgetSecretarySettingTitle.EVENT_SELECT_CLICK = "EVENT_SELECT_CLICK"

function QUIWidgetSecretarySettingTitle:ctor(options)
	local ccbFile = "ccb/Widget_Secretary_settingtitle.ccbi"
	local callBack = {
	}
	QUIWidgetSecretarySettingTitle.super.ctor(self, ccbFile, callBack, options)
end

function QUIWidgetSecretarySettingTitle:setInfo(title)
	self._ccbOwner.tf_title:setString(title or "")
end

function QUIWidgetSecretarySettingTitle:setTitleColor(color, outlineColor)
	if color then
		self._ccbOwner.tf_title:setColor(color)
	end
	if outlineColor then
		self._ccbOwner.tf_title:setOutlineColor(outlineColor)
		self._ccbOwner.tf_title:enableOutline(true)
	end
end

function QUIWidgetSecretarySettingTitle:getContentSize()
	local size = self._ccbOwner.node_size:getContentSize()
	return size
end

return QUIWidgetSecretarySettingTitle