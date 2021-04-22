-- @Author: xurui
-- @Date:   2019-01-22 17:43:21
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-01-25 15:28:51
local QUIWidgetActivityExchange = import("..widgets.QUIWidgetActivityExchange")
local QUIWidgetCarnivalActivityExchange = class("QUIWidgetCarnivalActivityExchange", QUIWidgetActivityExchange)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

function QUIWidgetCarnivalActivityExchange:ctor(options)
	if options == nil then
		options = {}
	end
	local ccbFile = "ccb/Widget_Carnival_client2.ccbi"
	options.ccbFile = ccbFile
    QUIWidgetCarnivalActivityExchange.super.ctor(self, options)

end

function QUIWidgetCarnivalActivityExchange:setInfo(id, info, activityPanel, activityInfo, curDay)
	QUIWidgetCarnivalActivityExchange.super.setInfo(self, id, info, activityPanel)

	self._listView:setScale(0.9)
	self._ccbOwner.node_tom:setVisible(false)
	self._ccbOwner.sp_none:setVisible(false)
	local dayNum = string.split(activityInfo.params, ",")
	dayNum = tonumber(dayNum[1])
	if dayNum > curDay then
		self._ccbOwner.sp_none:setVisible(true)
		self._ccbOwner.node_btn:setVisible(false)
		self._ccbOwner.node_tom:setVisible(true)
		self._ccbOwner.timesLabel:setString(string.format("剩余次数：%d/%d", 0, info.repeatCount))
	end
end

return QUIWidgetCarnivalActivityExchange
