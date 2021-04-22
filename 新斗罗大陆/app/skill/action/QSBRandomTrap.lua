--[[
    间隔interval_time生成一个trap，一共生成count个
--]]
local QSBAction = import(".QSBAction")
local QSBRandomTrap = class("QSBRandomTrap", QSBAction)
local QTrapDirector = import("..trap.QTrapDirector")

local insertTab = table.insert

function QSBRandomTrap:ctor(director, attacker, target, skill, options)
    QSBRandomTrap.super.ctor(self, director, attacker, target, skill, options)
    self._trapId = self._options.trapId
    self._interval_time = self._options.interval_time or 0
    self._count = self._options.count
    self._triggered_count = 0
    self._triggered_positions = {}
end

function QSBRandomTrap:_execute(dt)
    if self._trapId == nil or self._count < 1 then
        self:finished()
    end

    if self._startTime == nil then
        self._startTime = app.battle:getTime()
        self._currentTime = self._startTime
        self._lastTriggerTime = self._startTime
    else
        self._currentTime = self._currentTime + dt
    end

    if self._currentTime - self._lastTriggerTime >= self._interval_time then
        self._lastTriggerTime = self._lastTriggerTime + self._interval_time
        if self._triggered_count < self._count then
            local trapId, level = q.parseIDAndLevel(self._trapId)
            local position = app.battle:_calculateRandomPosition(self._triggered_positions, 0.1, true)
            insertTab(self._triggered_positions, position)
            local trapDirector = QTrapDirector.new(trapId, position, self._attacker:getType(), self._attacker, level, self._skill)
            app.battle:addTrapDirector(trapDirector)
            self._triggered_count = self._triggered_count + 1
        else
            self:finished()
        end
    end
end

return QSBRandomTrap