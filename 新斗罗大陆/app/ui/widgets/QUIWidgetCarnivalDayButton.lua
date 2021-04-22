-- @Author: xurui
-- @Date:   2019-01-21 16:07:09
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-08-01 15:26:27
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetCarnivalDayButton = class("QUIWidgetCarnivalDayButton", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

QUIWidgetCarnivalDayButton.EVENT_CLICK_DAY_BUTTON = "EVENT_CLICK_DAY_BUTTON"

function QUIWidgetCarnivalDayButton:ctor(options)
	local ccbFile = "ccb/Widget_Carnival_activity_btn.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClickDay", callback = handler(self, self._onTriggerClickDay)},
    }
    QUIWidgetCarnivalDayButton.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetCarnivalDayButton:onEnter()
end

function QUIWidgetCarnivalDayButton:onExit()
end

function QUIWidgetCarnivalDayButton:setInfo(i)
	self._index = i

	self._ccbOwner.tf_day:setString(i)

	self._ccbOwner.sp_activity_tips:setVisible(remote.activityCarnival:checkDayCarnivalActivityTipByDay(self._index))

	local curDay = remote.activityCarnival:getCurrentDayNum()
	self._ccbOwner.node_lock:setVisible(false)
	if curDay + 1 < self._index then
		self._ccbOwner.node_lock:setVisible(true)
	end
end

function QUIWidgetCarnivalDayButton:setSelectStatus(status)
	if status == nil then status = false end

	self._ccbOwner.btn_day:setHighlighted(status)
	self._ccbOwner.btn_day:setEnabled(not status)
	if status then
		self._ccbOwner.tf_day_di:setColor(ccc3(193, 59, 0))
		self._ccbOwner.tf_day_tian:setColor(ccc3(193, 59, 0))
		self._ccbOwner.tf_day:setColor(ccc3(193, 59, 0))
	else
		self._ccbOwner.tf_day_di:setColor(ccc3(242, 147, 97))
		self._ccbOwner.tf_day_tian:setColor(ccc3(242, 147, 97))
		self._ccbOwner.tf_day:setColor(ccc3(242, 147, 97))
	end
end

function QUIWidgetCarnivalDayButton:_onTriggerClickDay()
	self:dispatchEvent({name = QUIWidgetCarnivalDayButton.EVENT_CLICK_DAY_BUTTON, index = self._index})
end

function QUIWidgetCarnivalDayButton:getContentSize()
	return CCSize(0, 0)
end

return QUIWidgetCarnivalDayButton
