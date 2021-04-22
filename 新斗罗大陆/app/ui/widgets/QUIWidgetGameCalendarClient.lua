-- 
-- zxs
-- 玩法日历每天
-- 

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGameCalendarClient = class("QUIWidgetGameCalendarClient", QUIWidget)

local QUIWidgetGameCalendarCell = import("..widgets.QUIWidgetGameCalendarCell") 
local QScrollView = import("...views.QScrollView") 
local QQuickWay = import("...utils.QQuickWay")

function QUIWidgetGameCalendarClient:ctor(options)
	local ccbFile = "ccb/Widget_wanfarili_client.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerGo", callback = handler(self, self._onTriggerGo)},
	}
	QUIWidgetGameCalendarClient.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._dateInfo = options.dateInfo
	self._cellClient = {}
end

function QUIWidgetGameCalendarClient:onEnter()
	self._calendarProxy = cc.EventProxy.new(remote.calendar)
    self._calendarProxy:addEventListener(remote.calendar.SELECT_UPDATE_EVENT, handler(self, self.updateSelect))

	self:initScrollView()
	self:setInfo(self._dateInfo)
end

function QUIWidgetGameCalendarClient:onExit()
	if self._calendarProxy ~= nil then
        self._calendarProxy:removeAllEventListeners()
		self._calendarProxy = nil
    end
end

function QUIWidgetGameCalendarClient:initScrollView()
	local itemWidth = self._ccbOwner.sheet_layout:getContentSize()

	self._scrollView = QScrollView.new(self._ccbOwner.sheet, itemWidth, {bufferMode = 1, sensitiveDistance = 10})
	self._scrollView:replaceGradient(self._ccbOwner.node_up, self._ccbOwner.node_down)
	self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._scrollViewMoveState))
	self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._scrollViewMoveState))
end

function QUIWidgetGameCalendarClient:_scrollViewMoveState(event)
	if event.name == QScrollView.GESTURE_MOVING then
		self._isMoving = true
	elseif event.name == QScrollView.GESTURE_BEGAN then
		self._isMoving = false
	end
end

function QUIWidgetGameCalendarClient:setInfo(dateInfo)
	self._dateInfo = dateInfo
	local time = q.date("%m-%d", self._dateInfo.date)
	self._ccbOwner.tf_date:setString(time)
	self._ccbOwner.node_gray:setVisible(q.serverTime() > self._dateInfo.date+DAY)
	self._ccbOwner.cur_banner:setVisible(false)
	if self._dateInfo.date <= q.serverTime() and q.serverTime() < self._dateInfo.date+DAY then
		self._ccbOwner.cur_banner:setVisible(true)
	end
	
	local info = self._dateInfo.info
	if not next(info) then
		self._ccbOwner.tf_none:setVisible(true)
		self._scrollView:clear()
		return
	end

	table.sort( info, function(a, b) 
		if a.type ~= b.type then
			return a.type < b.type
		else
			return a.id < b.id
		end
	end)
	
	local height = 0
	for i = 1, #info do
		if info[i].isShow then
			if self._cellClient[i] == nil then
				self._cellClient[i] = QUIWidgetGameCalendarCell.new()
				self._cellClient[i]:setPositionY(-height)
				self._cellClient[i]:addEventListener(QUIWidgetGameCalendarCell.EVENT_CLICK_SELECT, handler(self, self._clickSelect))
				self._scrollView:addItemBox(self._cellClient[i])
			end
			self._cellClient[i]:setInfo(info[i])
			height = height + self._cellClient[i]:getContentSize().height
		end
	end
	self._scrollView:setRect(0, -height, 0, 0)
	self._ccbOwner.tf_none:setVisible(false)

	if #info > 2 then
		self._scrollView:setVerticalBounce(true)
		self._scrollView:setGradient(true)
	end
end

function QUIWidgetGameCalendarClient:_clickSelect(event)
	if self._isMoving then return end

	local setting = {}
	setting.id = event.id
	setting.isSelect = not event.select
	remote.calendar:updateCalendarSetting(setting)
end

function QUIWidgetGameCalendarClient:updateSelect(event)
	local setting = event.setting
	if setting and self._dateInfo.info then
		for _, value in ipairs(self._dateInfo.info) do
			if value.id == setting.id then
				value.isSelect = setting.isSelect
			end
		end
	end

	self:setInfo(self._dateInfo)
end

return QUIWidgetGameCalendarClient