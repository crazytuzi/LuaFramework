--[[
    以目标脚下为起点在X轴上间隔interval_time间距distance 生成一个trap，一共生成count个
    @common
--]]
local QSBAction = import(".QSBAction")
local QSBMultipleTrap = class("QSBMultipleTrap", QSBAction)
local QTrapDirector = import("..trap.QTrapDirector")

function QSBMultipleTrap:ctor(director, attacker, target, skill, options)
    QSBMultipleTrap.super.ctor(self, director, attacker, target, skill, options)
    self._trapId = self._options.trapId
    self._interval_time = self._options.interval_time or 0
    self._count = self._options.count
    self._distance = self._options.distance or 50
    self._triggered_count = 1
    self._trapIndex = 1
    self._inited = false
end

function QSBMultipleTrap:_execute(dt)
    if self._inited == false then
        local target = self._options.attacker_underfoot and self._attacker or self._target
        local attacker_face = self._options.attacker_face and true or false
        if attacker_face then
            self._distance = self._attacker:isFlipX() and -self._distance or self._distance
        else
            self._distance = self._attacker:isFlipX() and self._distance or -self._distance
        end
        if self._options.pos then
            self._triggered_position = clone(self._options.pos)
        else
            if nil == target then
                self:finished()
                return
            end
            self._triggered_position = clone(target:getPosition())
        end
        self._inited = true
    end

    if self._trapId == nil or (type(self._trapId) == "table" and #self._trapId == 0) or self._count < 1 then
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
        if self._triggered_count <= self._count then
            self._triggered_count = self._triggered_count + 1
            local trapIndex = type(self._trapId) == "table" and self._trapId[self._trapIndex] or self._trapId
            local trapId, level = q.parseIDAndLevel(trapIndex)
            local trapDirector = QTrapDirector.new(trapId, self._triggered_position, self._attacker:getType(), self._attacker, level, self._skill)
            self._triggered_position.x = self._triggered_position.x + self._distance
            app.battle:addTrapDirector(trapDirector)
            self._trapIndex = self._trapIndex + 1
            if type(self._trapId) == "table" then
                if self._trapIndex > #self._trapId then
                    self._trapIndex = 1
                end
            end 
        else
            self:finished()
        end
    end
end

return QSBMultipleTrap
