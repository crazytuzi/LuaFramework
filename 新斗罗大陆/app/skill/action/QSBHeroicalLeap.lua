--[[
    X轴直线冲锋
    @common
--]]
local QSBAction = import(".QSBAction")
local QSBHeroicalLeap = class("QSBHeroicalLeap", QSBAction)
local QActor = import("...models.QActor")

local math_min = math.min
local math_max = math.max

function QSBHeroicalLeap:ctor(director, attacker, target, skill, options)
    QSBHeroicalLeap.super.ctor(self, director, attacker, target, skill, options)
    self._speed = self._options.speed
    self._move_time = self._options.move_time
    self._damage_once = self._options.damage_once
    self._pass_time = 0
    -- self._interval_time = self._options.interval_time or 0
    self._bound_height = self._options.bound_height or 100
end

function QSBHeroicalLeap:_execute(dt)
    if not self._initialize then
        self:initializeMoveArg()
        self._distance = self._attacker:isFlipX() and self._options.distance or -self._options.distance
        self._startPos = self._attacker:getPosition()
        local targetPosX = self._startPos.x + self._distance
        local targetPosY = self._startPos.y
        self._targetPos = {x = targetPosX, y = targetPosY}

        local rect = self._attacker:getRect()
        self._width = rect.size.width

        self._hited = {}
        self._initialize = true
        self._attacker:lockDrag()
        function self._attacker:canMove() return false end
    end
    if self._startTime == nil then
        self._startTime = app.battle:getTime()
        self._currentTime = self._startTime
        self._lastTriggerTime = self._startTime
    else
        self._currentTime = self._currentTime + dt
    end
    
    self._pass_time = self._pass_time + dt
    self._pass_time = math_min(self._move_time, self._pass_time)
    local percent = self._pass_time / self._move_time
    local newx = math.round(self._startPos.x * (1 - percent) + self._targetPos.x * percent)
    local newy = self._targetPos.y
    local _, gridPos = app.grid:_toGridPos(newx, newy)
    if not self._options.outside then
        -- if self._attacker:isFlipX() then
        --     newx = math_min(BATTLE_AREA.right, newx)
        -- else
        --     newx = math_max(BATTLE_AREA.left, newx)
        -- end
        gridPos.x = math.clamp(gridPos.x, 1, app.grid._nx)
    end
    app.grid:_resetActorFollowStatus(self._attacker)
    local screenPos = app.grid:_toScreenPos(gridPos)
    app.grid:setActorTo(self._attacker, screenPos, not self._options.outside, true)
    -- app.grid:_setActorGridPos(self._attacker, gridPos, nil, true)

    -- self._attacker:setActorPosition({x = newx, y = newy})
    -- app.grid:moveActorTo(self._attacker, {x = newx, y = newy})

    for _, enemy in ipairs(app.battle:getMyEnemies(self._attacker)) do
        local pos = enemy:getPosition()
        local attackerPos = self._attacker:getPosition()
        local rect = self:rectMake(  self._attacker:getRect().origin.x + attackerPos.x, 
                        self._attacker:getRect().origin.y + attackerPos.y - self._bound_height, 
                        self._attacker:getRect().size.width, self._bound_height * 2)
        local enemyRect = self:rectMake(  enemy:getRect().origin.x + pos.x, enemy:getRect().origin.y + pos.y, 
                        enemy:getRect().size.width, enemy:getRect().size.height)

        local do_hit = false
        if self._options.is_hit_target then
            if not self._hited[enemy] then
                do_hit = true
            else
                if self._options.hit_once then
                    do_hit = false
                else
                    do_hit = true
                end
            end
        end

        local time_trigger = false
        if self._interval_time then
            if self._currentTime - self._lastTriggerTime >= self._interval_time then
                time_trigger = true
                self._lastTriggerTime = self._lastTriggerTime + self._interval_time
            end
        else
            time_trigger = true
        end

        if do_hit then
            if time_trigger then
                if rect:intersectsRect(enemyRect) then
                    self._attacker:onHit(self._skill, enemy)
                    self._hited[enemy] = true
                    if not self._interval_time then
                        self._interval_time = self._options.interval_time or 0
                    end
                end
            end
        end
    end

    if self._pass_time == self._move_time then
        -- local curPos = app.grid:_toScreenPos(gridPos)
        -- self._attacker:setActorPosition(curPos)
        app.grid:setActorTo(self._attacker, screenPos, not self._options.outside, true)
        self:finished()
        return
    end
end

function QSBHeroicalLeap:initializeMoveArg()
    if not self._move_time then
        if nil == self._options.distance or nil == self._speed then
            self:finished()
            return false
        end
        self._move_time = math.abs(self._options.distance) / self._speed
    end

    if not self._speed then
        if nil == self._move_time or nil == self._options.distance then
            self:finished()
            return false
        end
        self._speed = math.abs(self._options.distance) / self._move_time
    end

    if not self._options.distance then
        if not self._speed or not self._move_time then
            self:finished()
            return false
        end
        self._options.distance = self._move_time * self._speed
    end

    return true
end

function QSBHeroicalLeap:_onCancel()
    self._attacker:unlockDrag()
    self._attacker.canMove = QActor.canMove
end

function QSBHeroicalLeap:finished()
    QSBHeroicalLeap.super.finished(self)
    self._attacker:unlockDrag()
    self._attacker.canMove = QActor.canMove
end

function QSBHeroicalLeap:rectMake(x, y, width, height)
    local t = {}
    t.origin = {}
    t.size = {}
    t.origin.x, t.origin.y = x, y
    t.size.width, t.size.height = width, height
    function t:intersectsRect(rect)
        return not(     self:getMaxX() < rect:getMinX() or
             rect:getMaxX() <      self:getMinX() or
                  self:getMaxY() < rect:getMinY() or
             rect:getMaxY() <      self:getMinY());
    end
    function t:getMinX()
        return self.origin.x
    end
    function t:getMaxX()
        return (self.origin.x + self.size.width)
    end
    function t:getMinY()
        return self.origin.y
    end
    function t:getMaxY()
        return (self.origin.y + self.size.height)
    end
    return t
end

return QSBHeroicalLeap
