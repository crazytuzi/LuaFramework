-- @Author: xurui
-- @Date:   2019-01-22 17:11:37
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-01-28 10:11:31
local QUIWidgetActivityItem = import("..widgets.QUIWidgetActivityItem")
local QUIWidgetCarnivalActivityItem = class("QUIWidgetCarnivalActivityItem", QUIWidgetActivityItem)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

function QUIWidgetCarnivalActivityItem:ctor(options)
	if options == nil then
		options = {}
	end
	local ccbFile = "ccb/Widget_Carnival_client.ccbi"
	options.ccbFile = ccbFile
    QUIWidgetCarnivalActivityItem.super.ctor(self, options)

end

function QUIWidgetCarnivalActivityItem:setInfo(id, info, activityPanel, activityInfo, curDay)
	QUIWidgetCarnivalActivityItem.super.setInfo(self, id, info, activityPanel)

	self._listView:setScale(0.9)
	self._ccbOwner.node_tom:setVisible(false)
	self._ccbOwner.sp_time_out:setVisible(false)
	self._ccbOwner.sp_none:setVisible(false)
	self._ccbOwner.tf_num:setVisible(true)

	local paramsTbl = string.split(activityInfo.params, ",")
	local dayNum = tonumber(paramsTbl[1])
	local typeNm = tonumber(paramsTbl[2])
	if (remote.activityCarnival:checkActivityIsAwardTime() or dayNum < curDay) and typeNm == 1 and info.completeNum < 2 then
		self._ccbOwner.sp_time_out:setVisible(false)
		self._ccbOwner.node_btn:setVisible(false)
		self._ccbOwner.node_btn2:setVisible(false)
		self._ccbOwner.node_btn_go:setVisible(false)
		self._ccbOwner.notTouch:setVisible(false)
		self._ccbOwner.tf_num:setVisible(false)
		self._ccbOwner.sp_time_out:setVisible(true)
	else

		if dayNum > curDay and info.completeNum < 3 then
			self._ccbOwner.sp_time_out:setVisible(false)
			self._ccbOwner.node_btn:setVisible(false)
			self._ccbOwner.node_btn2:setVisible(false)
			self._ccbOwner.node_btn_go:setVisible(false)
			self._ccbOwner.notTouch:setVisible(false)
			self._ccbOwner.node_tom:setVisible(true)
			self._ccbOwner.sp_none:setVisible(true)
			self._ccbOwner.tf_num:setString("进度: ".."0/"..self.info.value)
		end
	end
end

return QUIWidgetCarnivalActivityItem
