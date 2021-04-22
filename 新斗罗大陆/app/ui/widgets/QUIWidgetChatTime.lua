-- @Author: liaoxianbo
-- @Date:   2020-06-11 11:48:46
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-06-11 16:19:23
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetChatTime = class("QUIWidgetChatTime", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

function QUIWidgetChatTime:ctor(options)
	local ccbFile = "ccb/Widget_ChatTime.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetChatTime.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetChatTime:setInfo(showTime)
	if showTime == nil then return end
	local curTime = q.serverTime()
	local invalTime = curTime - showTime
	if invalTime >= WEEK then --超过一周年月日时分
		self._ccbOwner.tf_time:setString(q.timeToMonthDayHourMin(showTime))
	elseif invalTime < WEEK and  invalTime >= DAY*2 then --星期
		if q.isSameWeekTime(showTime,0) then
			local dateTime = q.date("*t", time)
			local weekCommStr = q.timeWeekComm(dateTime.year,dateTime.month,dateTime.day)
			self._ccbOwner.tf_time:setString(weekCommStr.." "..q.date("%H:%M", showTime))
		else
			self._ccbOwner.tf_time:setString(q.timeToMonthDayHourMin(showTime))
		end
	elseif invalTime < DAY*2 and invalTime > DAY then
		self._ccbOwner.tf_time:setString("昨天 "..q.date("%H:%M", showTime))
	else
		self._ccbOwner.tf_time:setString(q.date("%H:%M", showTime))
	end	
	local strSize = self._ccbOwner.tf_time:getContentSize()
	self._ccbOwner.sp_time_bg:setContentSize(CCSize(strSize.width + 20 ,strSize.height))
end

function QUIWidgetChatTime:onEnter()
end

function QUIWidgetChatTime:onExit()
end

function QUIWidgetChatTime:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetChatTime
