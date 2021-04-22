--[[
    冲锋,不会打断当前动作
    @common
--]]
local QSBAction = import(".QSBAction")
local QSBCharge = class("QSBCharge", QSBAction)
local QActor = import("...models.QActor")

local math_min = math.min
local math_max = math.max

function QSBCharge:ctor(director, attacker, target, skill, options)
    QSBCharge.super.ctor(self, director, attacker, target, skill, options)
    self._move_time = self._options.move_time
    self._offset = options.offset or {x = 0, y = 0}
    self._pass_time = 0
end

function QSBCharge:_execute(dt)
    if nil == self._target and self._options.pos == nil then
        self:finished()
        return
    end

    if not self._initialize then
        self._startPos = self._attacker:getPosition()
        if self._options.pos then
            self._targetPos = clone(self._options.pos)
        else
            self._targetPos = clone(self._target:getPosition())
        end
        self._targetPos.x = self._targetPos.x + self._offset.x
        self._targetPos.y = self._targetPos.y + self._offset.y

        self._initialize = true
        self._attacker:lockDrag()
        function self._attacker:canMove() return false end
    end
    
    self._pass_time = self._pass_time + dt
    self._pass_time = math_min(self._move_time, self._pass_time)
    local percent = self._pass_time / self._move_time
    local newx = math.round(self._startPos.x * (1 - percent) + self._targetPos.x * percent)
    local newy = math.round(self._startPos.y * (1 - percent) + self._targetPos.y * percent)

    -- if self._attacker:isFlipX() then
    --     newx = math_min(BATTLE_AREA.right, newx)
    -- else
    --     newx = math_max(BATTLE_AREA.left, newx)
    -- end

    local _, gridPos = app.grid:_toGridPos(newx, newy)

    gridPos.x = math.clamp(gridPos.x, 1, app.grid._nx)
    gridPos.y = math.clamp(gridPos.y, 1, app.grid._ny)

    local pos = app.grid:_toScreenPos(gridPos)
    newx = pos.x
    newy = pos.y

    app.grid:_resetActorFollowStatus(self._attacker)
    app.grid:_setActorGridPos(self._attacker, gridPos, nil, true)

    self._attacker:setActorPosition({x = newx, y = newy})

    if self._pass_time >= self._move_time then
        if self._options.fcae_target then
            local attackerPos = self._attacker:getPosition()
            local targetPos = self._target:getPosition()
            local currentDirector = self._attacker:getDirection()
            if (attackerPos.x - targetPos.x) > 0 and
                currentDirector == QActor.DIRECTION_RIGHT then
                self._attacker:setDirection(QActor.DIRECTION_LEFT)
            elseif (attackerPos.x - targetPos.x) <=0 and
                currentDirector == QActor.DIRECTION_LEFT then
                self._attacker:setDirection(QActor.DIRECTION_RIGHT)
            end
        end
        self:finished()
        return
    end
end

function QSBCharge:_onCancel()
    self._attacker:unlockDrag()
    self._attacker.canMove = QActor.canMove
end

function QSBCharge:finished()
    QSBCharge.super.finished(self)
    self._attacker:unlockDrag()
    self._attacker.canMove = QActor.canMove
end

return QSBCharge
