--
-- zxs
-- 玩法日历主界面
-- 

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGameCalendar = class("QUIDialogGameCalendar", QUIDialog)

local QUIWidgetGameCalendarClient = import("..widgets.QUIWidgetGameCalendarClient")

function QUIDialogGameCalendar:ctor(options)
	local ccbFile = "ccb/Dialog_wanfarili.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerSetting", callback = handler(self, self._onTriggerSetting)},
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, self._onTriggerConfirm)},
	}
	QUIDialogGameCalendar.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    q.setButtonEnableShadow(self._ccbOwner.frame_btn_close)
    q.setButtonEnableShadow(self._ccbOwner.btn_confirm)
    q.setButtonEnableShadow(self._ccbOwner.btn_setting)


	remote.calendar:setIsSetting(false)
	self:setCurrentTime()
	self:initGameClient()
	self:updateSelect()
end

function QUIDialogGameCalendar:viewDidAppear()
	QUIDialogGameCalendar.super.viewDidAppear(self)

	self._calendarProxy = cc.EventProxy.new(remote.calendar)
    self._calendarProxy:addEventListener(remote.calendar.SELECT_UPDATE_EVENT, handler(self, self.updateSelect))
end

function QUIDialogGameCalendar:viewWillDisappear()
	QUIDialogGameCalendar.super.viewWillDisappear(self)
	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end
	if self._calendarProxy ~= nil then
        self._calendarProxy:removeAllEventListeners()
		self._calendarProxy = nil
    end
end

function QUIDialogGameCalendar:setCurrentTime()
	local nowTime = q.serverTime()
	local time = q.date("%Y-%m-%d %H:%M", nowTime)
	local week = q.date("*t", nowTime).wday
	week = week == 1 and 7 or (week-1)
	week = q.numToWord(week) == "七" and "日" or q.numToWord(week)
	self._ccbOwner.tf_currtent_time:setString(time.." (周"..week..")")

	self._scheduler = scheduler.performWithDelayGlobal(function ()
		self:setCurrentTime()
	end, 1, self._scheduler)
end

function QUIDialogGameCalendar:initGameClient()
	-- 显示两周14天的日程
	local calendar = remote.calendar:getCalendarData()
	local startTime = remote.calendar:getCurWeekStartTime()
	local size = self._ccbOwner.sheet_layout:getContentSize()
	local width = size.width/7
	local height = size.height/2
	local index = 1
	for i = 0, 13 do
		local date = startTime + i*DAY
		local dateInfo = {}
		dateInfo.date = date
		dateInfo.info = {}
		while calendar[index] do
			local info = calendar[index]
			if info and date <= info.date and info.date < date + DAY then
				table.insert(dateInfo.info, info)
				index = index + 1
			else
				break
			end
		end

		local row = i / 7
		local col = i % 7 
		local client = QUIWidgetGameCalendarClient.new({dateInfo = dateInfo})
		client:setPosition(ccp(width*col, -height*math.floor(row)))
		self._ccbOwner.node_client:addChild(client)
	end
end

function QUIDialogGameCalendar:updateSelect()
	local isSetting = remote.calendar:getIsSetting()
	self._ccbOwner.node_confirm:setVisible(isSetting)
	self._ccbOwner.node_set_tips:setVisible(isSetting)
	self._ccbOwner.node_setting:setVisible(not isSetting)
	self._ccbOwner.node_time:setVisible(not isSetting)
end

function QUIDialogGameCalendar:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
    app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogGameCalendar:_onTriggerSetting()
    app.sound:playSound("common_close")
    remote.calendar:setIsSetting(true)
end

function QUIDialogGameCalendar:_onTriggerConfirm()
    app.sound:playSound("common_close")
    remote.calendar:setCalendarSetting()
    remote.calendar:setIsSetting(false)
end

return QUIDialogGameCalendar
