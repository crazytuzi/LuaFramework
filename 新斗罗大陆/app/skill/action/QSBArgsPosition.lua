--[[
    Class name QSBArgsPosition
    Create by julian 
--]]


local QSBNode = import("..QSBNode")
local QSBArgsPosition = class("QSBArgsPosition", QSBNode)

function QSBArgsPosition:_execute(dt)
    local options = self:getOptions()
    local actor
    if options.is_attacker then
        actor = self._attacker
    elseif options.is_attackee then
        actor = self._target
    elseif options.teammate_lowest_hp then
        local actors = app.battle:getMyTeammates(self._attacker, true, true)
        table.sort(actors, function(e1, e2)
            local d1 = e1:getHp() / e1:getMaxHp()
            local d2 = e2:getHp() / e2:getMaxHp()
            if d1 ~= d2 then
                return d1 < d2
            else
                return e1:getUUID() < e2:getUUID()
            end
        end)
        actor = actors[1]
    end

    local offset = options.offset or {x = 0, y = 0}

    if actor then
        if options.enter_stop_position == true then
            local pos = clone(actor._enterStopPosition)
            pos.x = pos.x + offset.x
            pos.y = pos.y + offset.y
            self:finished({pos = pos})
        else
            local pos = clone(actor:getPosition())
            pos.x = (options.x or pos.x) + offset.x
            pos.y = (options.y or pos.y) + offset.y

            self:finished({pos = pos})
        end
    else
        self:finished()
    end
end

return QSBArgsPosition