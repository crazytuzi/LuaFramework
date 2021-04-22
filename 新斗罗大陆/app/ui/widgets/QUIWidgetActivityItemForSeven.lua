-- @Author: xurui
-- @Date:   2018-06-06 16:06:39
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-07 19:52:18
local QUIWidgetActivityItem = import("..widgets.QUIWidgetActivityItem")
local QUIWidgetActivityItemForSeven = class("QUIWidgetActivityItemForSeven", QUIWidgetActivityItem)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

function QUIWidgetActivityItemForSeven:ctor(options)
	local ccbFile = "ccb/Widget_SevenDayAcitivity.ccbi"
	if options == nil then
		options = {}
	end
	options.ccbFile = ccbFile

    QUIWidgetActivityItemForSeven.super.ctor(self, options)

    self._isSelectPreviewDay = false
end

function QUIWidgetActivityItemForSeven:setInfo(id, info, activityPanel)
    QUIWidgetActivityItemForSeven.super.setInfo(self, id, info, activityPanel)
end

function QUIWidgetActivityItemForSeven:setPreviewStated(stated)
	if stated == nil then stated = false end

    self._isSelectPreviewDay = stated
    -- print("------self._isSelectPreviewDay------", self._isSelectPreviewDay)
	if stated then
		self._ccbOwner.tf_btn:setString("明日开启")
	end
	self._ccbOwner.tf_num:setVisible(not stated)
	if stated then
		self._ccbOwner.node_btn:setVisible(true)
		self._ccbOwner.node_btn_go:setVisible(false)
		self._ccbOwner.sp_ishave:setVisible(false)
	end

   	local openTime = (remote.user.openServerTime or 0)/1000
	local activityType = self._activityPanel:getCurActivityType()
	local currTime = q.serverTime()
	local endTime = openTime + remote.activity.TIME1 * DAY - currTime
	local activityEndTime = openTime + remote.activity.TIME2 * DAY
	local awardTime = (remote.activity.TIME1 - remote.activity.TIME2) * DAY
	if activityType == 2 then
		endTime = openTime + remote.activity.TIME5 * DAY - currTime
		activityEndTime = openTime + remote.activity.TIME6 * DAY
		awardTime = (remote.activity.TIME5 - remote.activity.TIME6) * DAY
	end
	if currTime > activityEndTime and self.info.completeNum == 1 then
		self._ccbOwner.tf_num:setVisible(false)
		self._ccbOwner.node_btn_go:setVisible(false)
		self._ccbOwner.sp_time_out:setVisible(true)
		self._ccbOwner.node_btn2:setVisible(false)
	end
end

return QUIWidgetActivityItemForSeven
