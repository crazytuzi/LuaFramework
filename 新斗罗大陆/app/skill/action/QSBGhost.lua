--[[
    Class name QSBGhost
    Create by julian 
--]]

local QSBAction = import(".QSBAction")
local QSBGhost = class("QSBGhost", QSBAction)

function QSBGhost:_execute(dt)
    local actor = self._attacker

    if self._options.ghost then
        local enemies
        if actor:getType() == ACTOR_TYPES.NPC then
            enemies = app.battle:getEnemies()
        else
            enemies = app.battle:getHeroes()
        end
        for i, enemy in ipairs(enemies) do
            if enemy == actor then
                table.remove(enemies, i)
                local myenemies = app.battle:getMyEnemies(actor)
                for _, myenemy in ipairs(myenemies) do
                    if myenemy:getTarget() == actor then
                        myenemy:setTarget(nil)
                        myenemy:_cancelCurrentSkill()
                        local pos = myenemy:getPosition()
                        _, pos = app.grid:_toGridPos(pos.x, pos.y)
                        app.grid:_setActorGridPos(myenemy, pos)
                    end
                end
                break
            end
        end
    else
        local enemies = app.battle:getEnemies()
        table.insert(enemies, actor)
    end

    self:finished()
end

function QSBGhost:_onCancel()
    if self._options.ghost then
        local actor = self._attacker
        local enemies
        if actor:getType() == ACTOR_TYPES.NPC then
            enemies = app.battle:getEnemies()
        else
            enemies = app.battle:getHeroes()
        end
        for _, enemy in ipairs(enemies) do
            if enemy == actor then
                return
            end
        end
        table.insert(enemies, actor)
    end
end

function QSBGhost:_onRevert()
    if self._options.ghost then
        local actor = self._attacker
        local enemies
        if actor:getType() == ACTOR_TYPES.NPC then
            enemies = app.battle:getEnemies()
        else
            enemies = app.battle:getHeroes()
        end
        for _, enemy in ipairs(enemies) do
            if enemy == actor then
                return
            end
        end
        table.insert(enemies, actor)
    end
end

return QSBGhost