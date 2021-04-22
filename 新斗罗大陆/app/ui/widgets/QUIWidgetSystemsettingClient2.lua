--[[	
	文件名称：QUIWidgetSystemsettingClient2.lua
	创建时间：2017-03-10 12:18:06
	作者：nieming
	描述：QUIWidgetSystemsettingClient2
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetSystemsettingClient2 = class("QUIWidgetSystemsettingClient2", QUIWidget)
local QUIWidgetSwitchBtn = import("..widgets.QUIWidgetSwitchBtn")

--初始化
function QUIWidgetSystemsettingClient2:ctor(options)
	local ccbFile = "Widget_SystemSetting_client2.ccbi"
	local callBacks = {
	}
	QUIWidgetSystemsettingClient2.super.ctor(self,ccbFile,callBacks,options)

end

--describe：
function QUIWidgetSystemsettingClient2:_onTriggerClick()
	local value = self._info.isOpen == 0 and 1 or 0
	app:getClient():setRemoteNotificationSetting(tostring(self._info.id), value, function (data)
		remote:updateNotifiCationSystemSetting(self._info.id, value)
		self._info.isOpen = value
		self._btnWidget:setInfo(self._info)
	end)
end

--describe：setInfo 
function QUIWidgetSystemsettingClient2:setInfo(info)
	--代码
	self._info = info 
	self._ccbOwner.label:setString(info.label)

	if not self._btnWidget then
		self._btnWidget = QUIWidgetSwitchBtn.new()
    	self._btnWidget:addEventListener(QUIWidgetSwitchBtn.EVENT_CLICK, handler(self, self._onTriggerClick))
		self._ccbOwner.node_btn:removeAllChildren()
		self._ccbOwner.node_btn:addChild(self._btnWidget)
	end
	self._btnWidget:setInfo(info)
end

return QUIWidgetSystemsettingClient2
