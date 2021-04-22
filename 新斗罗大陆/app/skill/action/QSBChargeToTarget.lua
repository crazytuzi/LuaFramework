--[[
    冲锋,可以在黑屏时冲锋
    @common
--]]
local QSBAction = import(".QSBAction")
local QSBChargeToTarget = class("QSBChargeToTarget", QSBAction)
local QActor = import("...models.QActor")

local math_min = math.min
local math_max = math.max

function QSBChargeToTarget:_execute(dt)
    if nil == self._target then
        self:finished()
        return
    end

    if not self._initialize then
        self._startPos = self._attacker:getPosition()

        local gridPos, midPos = app.grid:_findBestPositionByTarget(self._attacker, self._target, true)
        self._targetPos = app.grid:_toScreenPos(gridPos)
        self._wp = {x = self._attacker:getPosition().x, y = self._attacker:getPosition().y}

        local dist = q.distOf2Points(self._startPos, self._targetPos)
        if dist <= 0 then
            self:finished()
            return
        end
        
        if self:getOptions().speed then 
            self._move_time = dist / (self:getOptions().speed or 1500)
        else
            self._move_time = self:getOptions().move_time
        end
        self._pass_time = 0

        self._initialize = true
        self._attacker:lockDrag()
        function self._attacker:canMove() return false end
    end
    
    self._pass_time = self._pass_time + dt
    self._pass_time = math_min(self._move_time, self._pass_time)
    local percent = self._pass_time / self._move_time
    local newx = math.round(self._startPos.x * (1 - percent) + self._targetPos.x * percent)
    local newy = math.round(self._startPos.y * (1 - percent) + self._targetPos.y * percent)

    if self._attacker:isFlipX() then
        newx = math_min(BATTLE_AREA.right, newx)
    else
        newx = math_max(BATTLE_AREA.left, newx)
    end

    local _, gridPos = app.grid:_toGridPos(newx, newy)
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
    else
        local curPos = self._attacker:getPosition()
        if self:getOptions().effect_id and self:getOptions().effect_interval then
            local effect_id = self:getOptions().effect_id
            local effect_interval = self:getOptions().effect_interval
            if q.distOf2PointsSquareWithYCoefficient(self._wp, curPos, 2) >= (effect_interval * effect_interval) then
                local options = {}
                options.attacker = self._attacker
                options.attackee = self._attackee
                options.targetPosition = clone(curPos)
                options.scale_actor_face = self._options.scale_actor_face
                options.ground_layer = true
                self._attacker:playSkillEffect(effect_id, nil, options)
                self._wp = {x = curPos.x, y = curPos.y}
            end
        end
    end
end

function QSBChargeToTarget:_onCancel()
    self._attacker:unlockDrag()
    self._attacker.canMove = QActor.canMove
end

function QSBChargeToTarget:finished()
    QSBChargeToTarget.super.finished(self)
    self._attacker:unlockDrag()
    self._attacker.canMove = QActor.canMove
end

return QSBChargeToTarget
