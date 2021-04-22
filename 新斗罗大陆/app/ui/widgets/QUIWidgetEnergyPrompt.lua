--
-- Author: Qinyuanji
-- Date: 2015-01-14 
-- Stick on the energy bar will show the energy information

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetEnergyPrompt = class("QUIWidgetEnergyPrompt", QUIWidget)

QUIWidgetEnergyPrompt.EVERY_SECOND = 1
QUIWidgetEnergyPrompt.EVENT_BEGAIN = "EVENT_ENERGY_BEGAN"
QUIWidgetEnergyPrompt.EVENT_END = "EVENT_ENERGY_END"

-- This is not very accurate, so adjust seconds
QUIWidgetEnergyPrompt.SecondAdjust = 2
QUIWidgetEnergyPrompt.MarginSize = 20
QUIWidgetEnergyPrompt.Message1Format = "当前时间: %s"
QUIWidgetEnergyPrompt.Message2Format = "已买体力次数: %d/%d"
QUIWidgetEnergyPrompt.Message3Format = "体力已回满"
QUIWidgetEnergyPrompt.Message4Format = "下点体力恢复: %s"
QUIWidgetEnergyPrompt.Message5Format = "恢复全部体力: %s"
QUIWidgetEnergyPrompt.Message6Format = "恢复时间间隔: %d分钟"

function QUIWidgetEnergyPrompt:ctor(options, isHave)
    local ccbFile = "ccb/Widget_EnergyPrompt.ccbi"
    local callBacks = {}
    QUIWidgetEnergyPrompt.super.ctor(self, ccbFile, callBacks, options)

    self._curEnergy = options.curEnergy
    self._curEnergyBuyCount = options.curEnergyBuyCount
    self._maxEnergyBuyCount = options.maxEnergyBuyCount
    self._timeToNextEnergyPoint = options.timeToNextEnergyPoint + QUIWidgetEnergyPrompt.SecondAdjust
    self._timeToEnergyFull = options.timeToEnergyFull + QUIWidgetEnergyPrompt.SecondAdjust

    self:updateText()
end

function QUIWidgetEnergyPrompt:onEnter()
    self._everySecond = scheduler.scheduleGlobal(handler(self, QUIWidgetEnergyPrompt._onSecond), QUIWidgetEnergyPrompt.EVERY_SECOND)
end

function QUIWidgetEnergyPrompt:onExit()
    scheduler.unscheduleGlobal(self._everySecond)
end

function QUIWidgetEnergyPrompt:_onSecond(dt)
    self:updateText()
end

-- Update the time every second
function QUIWidgetEnergyPrompt:updateText( ... )
    self._text = string.format(QUIWidgetEnergyPrompt.Message1Format, q.date("%H:%M:%S"))
    self._text = self._text .. "\n" .. string.format(QUIWidgetEnergyPrompt.Message2Format, self._curEnergyBuyCount, self._maxEnergyBuyCount)
    if self._curEnergy >=  global.config.max_energy then
        self._text = self._text .. "\n" .. QUIWidgetEnergyPrompt.Message3Format
        self:setPosition(display.width/2, display.height * 0.8)
    else
        local t1 = q.timeToHourMinuteSecond(self._timeToNextEnergyPoint)
        local t2 = q.timeToHourMinuteSecond(self._timeToEnergyFull)
        self._text = self._text .. "\n" .. string.format(QUIWidgetEnergyPrompt.Message4Format, t1)
        self._text = self._text .. "\n" .. string.format(QUIWidgetEnergyPrompt.Message5Format, t2)
        self._text = self._text .. "\n" .. string.format(QUIWidgetEnergyPrompt.Message6Format, global.config.energy_refresh_interval/60)

        self._timeToEnergyFull = self._timeToEnergyFull - 1
        self._timeToNextEnergyPoint = self._timeToNextEnergyPoint - 1
        if self._timeToNextEnergyPoint <= 0 then -- restart from intervale
            self._timeToNextEnergyPoint = self._timeToNextEnergyPoint + 360
        end
        if self._timeToEnergyFull <= 0 then
            self._curEnergy = global.config.max_energy
        end
        self:setPosition(display.width/2, display.height * 0.75)
    end

    self._ccbOwner.text:setString(self._text)

    self._size = self._ccbOwner.text:getContentSize()
    self._ccbOwner.prompt:setContentSize(CCSize(self._size.width + QUIWidgetEnergyPrompt.MarginSize, self._size.height + QUIWidgetEnergyPrompt.MarginSize))
end

return QUIWidgetEnergyPrompt