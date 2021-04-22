
local QAIAction = import("..base.QAIAction")
local QAIMoveRoundTrip = class("QAIMoveRoundTrip", QAIAction)

function QAIMoveRoundTrip:ctor( options )
    QAIMoveRoundTrip.super.ctor(self, options)
    self:setDesc("来回移动")
end

function QAIMoveRoundTrip:_evaluate(args)
    local actor = args.actor
    if actor == nil or actor:isDead() == true then
        return false
    end

    if self._options.distance == nil or self._options.distance <= 0 then
        return false
    end

    return true
end

function QAIMoveRoundTrip:_execute(args)
    local actor = args.actor
    local currentTime = app.battle:getTime()
    if self._lastTime == nil or currentTime - self._lastTime > 0.5 then
        self._targetPosition = nil
    end
    self._lastTime = currentTime

    if self._targetPosition == nil then
        self:_calculateTargetPosition(actor)
    else
        local position = actor:getPosition()
        local deltaX = self._targetPosition.x - position.x
        -- local dy = self._targetPosition.y - position.y
        if math.abs(deltaX) < global.pixel_per_unit * 0.5 then
            self:_calculateTargetPosition(actor)
        end
    end

    app.grid:moveActorTo(actor, self._targetPosition)

    return true
end

function QAIMoveRoundTrip:_calculateTargetPosition(actor)
    if actor == nil then
        return 
    end

    local position = actor:getPosition()
    local leftDistance = position.x - BATTLE_AREA.left
    local reightDistance = BATTLE_AREA.right - position.x
    if reightDistance - leftDistance > 3 * global.pixel_per_unit then
        self._targetPosition = {x = position.x + self._options.distance * global.pixel_per_unit, y = position.y}
    else
        self._targetPosition = {x = position.x - self._options.distance * global.pixel_per_unit, y = position.y}
    end

    if self._targetPosition.x > BATTLE_AREA.right - 3 * global.pixel_per_unit then
        self._targetPosition.x = BATTLE_AREA.right - 3 * global.pixel_per_unit
    elseif self._targetPosition.x < BATTLE_AREA.left + 3 * global.pixel_per_unit then
        self._targetPosition.x = BATTLE_AREA.left + 3 * global.pixel_per_unit
    end

end

return QAIMoveRoundTrip