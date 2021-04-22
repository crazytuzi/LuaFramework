-- 
-- zxs
-- 周基金时间点
--

local QUIWidget = import(".QUIWidget")
local QUIWidgetActivityWeekFundDot = class("QUIWidgetActivityWeekFundDot", QUIWidget)

QUIWidgetActivityWeekFundDot.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetActivityWeekFundDot:ctor(options)
    local ccbFile = "ccb/Widget_zhoujijin_dot.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
    }
    QUIWidgetActivityWeekFundDot.super.ctor(self, ccbFile, callBacks, options)

    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetActivityWeekFundDot:setDotIndex(index)
    self._index = index or 0
    self._ccbOwner.tf_day:setString(self._index)
end

function QUIWidgetActivityWeekFundDot:setIsReady(state)
    self._ccbOwner.sp_normal:setVisible(state)
    self._ccbOwner.sp_gray:setVisible(not state)
end

function QUIWidgetActivityWeekFundDot:setIsSelect(state)
    self._ccbOwner.sp_light:setVisible(state)
end

function QUIWidgetActivityWeekFundDot:_onTriggerClick()
    app.sound:playSound("common_small")

    self:dispatchEvent({name = QUIWidgetActivityWeekFundDot.EVENT_CLICK, index = self._index})
end

return QUIWidgetActivityWeekFundDot