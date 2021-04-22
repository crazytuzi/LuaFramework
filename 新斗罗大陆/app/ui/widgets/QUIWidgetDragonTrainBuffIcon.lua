--
-- Kumo.Wang
-- 宗门武魂祝福Buff图标
--

local QUIWidget = import(".QUIWidget")
local QUIWidgetDragonTrainBuffIcon = class("QUIWidgetDragonTrainBuffIcon", QUIWidget)

local QRichText = import("...utils.QRichText")

function QUIWidgetDragonTrainBuffIcon:ctor(options)
	local ccbFile = "Widget_DragonTrain_BuffIcon.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerBuffInfo", callback = handler(self, self._onTriggerBuffInfo)},
	}
	QUIWidgetDragonTrainBuffIcon.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetDragonTrainBuffIcon:onEnter()
	if self._countdownSchedule then
		scheduler.unscheduleGlobal(self._countdownSchedule)
		self._countdownSchedule = nil
	end
	self._ccbOwner.node_buff_info:setVisible(false)
	self._ccbOwner.node_rtf:removeAllChildren()
end

function QUIWidgetDragonTrainBuffIcon:onExit()
	if self._countdownSchedule then
		scheduler.unscheduleGlobal(self._countdownSchedule)
		self._countdownSchedule = nil
	end
end

function QUIWidgetDragonTrainBuffIcon:getIcon()
	return self._ccbOwner.sp_icon
end

function QUIWidgetDragonTrainBuffIcon:_updateDragonTrainBuffCountdown()
	if self._countdownSchedule then
		scheduler.unscheduleGlobal(self._countdownSchedule)
		self._countdownSchedule = nil
	end

	-- local rtf = QRichText.new(nil, 200)
	local rtf = QRichText.new()
    rtf:setAnchorPoint(ccp(0, 1))
    local timeStr = remote.union:getDragonTrainBuffCountdown()
    local content = {}
    table.insert(content, {oType = "font", content = "剩余 ", size = 20, color = COLORS.a})
    table.insert(content, {oType = "font", content = timeStr, size = 20, color = COLORS.a})
    table.insert(content, {oType = "wrap"})
    table.insert(content, {oType = "font", content = "宗门武魂任务获取武魂", size = 20, color = COLORS.a})
    table.insert(content, {oType = "wrap"})
    table.insert(content, {oType = "font", content = "经验+100%", size = 20, color = COLORS.a})
    table.insert(content, {oType = "wrap"})
    table.insert(content, {oType = "font", content = "宗门武魂任务宝箱获取", size = 20, color = COLORS.a})
    table.insert(content, {oType = "wrap"})
    table.insert(content, {oType = "font", content = "武魂经验+100%", size = 20, color = COLORS.a})
    table.insert(content, {oType = "wrap"})
    rtf:setString(content)
	self._ccbOwner.node_rtf:removeAllChildren()
	self._ccbOwner.node_rtf:addChild(rtf)
	self._ccbOwner.node_buff_info:setVisible(true)

	self._countdownSchedule = scheduler.scheduleGlobal(function()
		if self._ccbView then
			self:_updateDragonTrainBuffCountdown()
		end
	end, 1)
end

--[[
enum
{
    CCControlEventTouchDown           = 1 << 0,    // A touch-down event in the control.
    CCControlEventTouchDragInside     = 1 << 1,    // An event where a finger is dragged inside the bounds of the control.
    CCControlEventTouchDragOutside    = 1 << 2,    // An event where a finger is dragged just outside the bounds of the control.
    CCControlEventTouchDragEnter      = 1 << 3,    // An event where a finger is dragged into the bounds of the control.
    CCControlEventTouchDragExit       = 1 << 4,    // An event where a finger is dragged from within a control to outside its bounds.
    CCControlEventTouchUpInside       = 1 << 5,    // A touch-up event in the control where the finger is inside the bounds of the control.
    CCControlEventTouchUpOutside      = 1 << 6,    // A touch-up event in the control where the finger is outside the bounds of the control.
    CCControlEventTouchCancel         = 1 << 7,    // A system event canceling the current touches for the control.
    CCControlEventValueChanged        = 1 << 8      // A touch dragging or otherwise manipulating a control, causing it to emit a series of different values.
};
]]
function QUIWidgetDragonTrainBuffIcon:_onTriggerBuffInfo(event)
	if tonumber(event) == CCControlEventTouchDown then
		self:_updateDragonTrainBuffCountdown()
	else
		if self._countdownSchedule then
			scheduler.unscheduleGlobal(self._countdownSchedule)
			self._countdownSchedule = nil
		end
		self._ccbOwner.node_buff_info:setVisible(false)
	end
end

return QUIWidgetDragonTrainBuffIcon
