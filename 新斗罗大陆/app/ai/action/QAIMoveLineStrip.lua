
local QAIAction = import("..base.QAIAction")
local QAIMoveLineStrip = class("QAIMoveLineStrip", QAIAction)

function QAIMoveLineStrip:ctor( options )
    QAIMoveLineStrip.super.ctor(self, options)
    self:setDesc("沿着预定的屏幕坐标上的target list移动")

    self._current_index = 0
    self._target_list = clone(self:getOptions().target_list)
    self._relative = self:getOptions().relative or false
    self._target_lists = clone(self:getOptions().target_lists)

    self._list_random_array = {}
    self._current_list_index = 0

    if self._target_list then
        for _, target in ipairs(self._target_list) do
            target.x = target.x * global.pixel_per_unit
            target.y = target.y * global.pixel_per_unit
            if not self._relative then
                QAIMoveLineStrip._adjustTargetPositionByBattleArea(target)
            end
        end
    elseif self._target_lists then
        for _, target_list in ipairs(self._target_lists) do
            for _, target in ipairs(target_list) do
                target.x = target.x * global.pixel_per_unit
                target.y = target.y * global.pixel_per_unit
                if not self._relative then
                    QAIMoveLineStrip._adjustTargetPositionByBattleArea(target)
                end
            end
        end
    end
end

function QAIMoveLineStrip:_evaluate(args)
    local actor = args.actor
    if actor == nil or actor:isDead() == true then
        return false
    end

    if (self._target_list == nil or #self._target_list == 0) and (self._target_lists == nil or #self._target_lists == 0) then
        return false
    end

    return true
end

function QAIMoveLineStrip:_execute(args)
    local actor = args.actor
    local currentTime = app.battle:getTime()
    if self._lastTime == nil or currentTime - self._lastTime > 0.5 then
        if self._target_lists and #self._target_lists > 0 then
            if self._current_list_index == 0 or self._current_list_index == #self._list_random_array then
                self._list_random_array = clone(self._target_lists)
                for i = 1, #self._list_random_array do
                    local random_index = app.random(i, #self._list_random_array)
                    local tmp = self._list_random_array[i]
                    self._list_random_array[i] = self._list_random_array[random_index]
                    self._list_random_array[random_index] = tmp
                end
                self._current_list_index = 0
            end
            self._current_list_index = self._current_list_index + 1
            self._target_list = self._list_random_array[self._current_list_index]
        end

        self._current_index = 1
        self._original_pos = actor:getPosition()
        self._target_position = self:getRelativePosition(clone(self._target_list[self._current_index]))
        self._target_position.x = math.clamp(self._target_position.x + actor:getRect().size.width / 2 + 10, BATTLE_AREA.left, BATTLE_AREA.right - actor:getRect().size.width / 2 - 10)

        if self:getOptions().speed then
            actor:insertPropertyValue("movespeed_replace", self, "&", self:getOptions().speed)
        end
    end
    self._lastTime = currentTime

    if q.is2PointsCloseWithTolerance(self._target_position, actor:getPosition(), 5) then
        return false
    end

    local position = actor:getPosition()
    local deltaX = self._target_position.x - position.x
    local deltaY = self._target_position.y - position.y
    if deltaX * deltaX + 4 * deltaY * deltaY < global.pixel_per_unit * global.pixel_per_unit * 0.25 then
        self._current_index = self._current_index + 1
        if self._current_index <= #self._target_list then
            self._target_position = self:getRelativePosition(clone(self._target_list[self._current_index]))
        elseif self._current_index == #self._target_list + 1 and self:getOptions().goback then
            self._target_position = self:getRelativePosition(clone(self._original_pos))
        elseif self:getOptions().speed then
            actor:removePropertyValue("movespeed_replace", self)
        end
    end

    app.grid:moveActorTo(actor, self._target_position)

    return true
end

function QAIMoveLineStrip:getRelativePosition(position)
    if not self._relative then
        return position
    else
        position.x = position.x + self._original_pos.x
        position.y = position.y + self._original_pos.y
        self._adjustTargetPositionByBattleArea(position)
        return position
    end
end

function QAIMoveLineStrip._adjustTargetPositionByBattleArea(position)
    if position.x > BATTLE_AREA.right then
        position.x = BATTLE_AREA.right
    elseif position.x < BATTLE_AREA.left then
        position.x = BATTLE_AREA.left
    end
    if position.y > BATTLE_AREA.top then
        position.y = BATTLE_AREA.top
    elseif position.y < BATTLE_AREA.bottom then
        position.y = BATTLE_AREA.bottom
    end
end

return QAIMoveLineStrip