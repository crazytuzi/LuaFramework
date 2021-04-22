--[[
    Class name QSBJumpAppear
    Create by julian 
--]]

local QSBAction = import(".QSBAction")
local QSBJumpAppear = class("QSBJumpAppear", QSBAction)

function QSBJumpAppear:_execute(dt)
    local actor = self._attacker
    local jumpanimation = self._options.jump_animation

    if self.__isAnimationPlaying == true then
        return
    end

    local mates = actor:getType() == ACTOR_TYPES.NPC and app.battle:getEnemies() or app.battle:getHeroes()
    for i, mate in ipairs(mates) do
        if mate == actor then
            table.remove(mates, i)
            app.battle._appearActors[actor] = actor
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

    if actor:getPosition().x < BATTLE_AREA.left + BATTLE_AREA.right / 2 then
        actor:setDirection(actor.DIRECTION_RIGHT)
    else
        actor:setDirection(actor.DIRECTION_LEFT)
    end
    self._direction = actor:getDirection()

    self._attacker:playSkillAnimation({jumpanimation}, false)
    self._endAnimationName = jumpanimation
    self._eventListener = cc.EventProxy.new(self._attacker)
    self._eventListener:addEventListener(actor.ANIMATION_ENDED, handler(self, self._onAnimationEnded))
    self.__isAnimationPlaying = true
end

function QSBJumpAppear:_onAnimationEnded(event)
    if event.animationName == self._endAnimationName then
        self._eventListener:removeAllEventListeners()
        
        local actor = self._attacker
        -- local enemies = app.battle:getEnemies()
        if not actor:isGhost() and not actor:isPet() then
            local enemies = actor:getType() == ACTOR_TYPES.NPC and app.battle:getEnemies() or app.battle:getHeroes()
            table.insert(enemies, actor)
        end
        app.battle._appearActors[actor] = nil

        self:finished()
    end
end

function QSBJumpAppear:_onCancel()
    if self.__isAnimationPlaying then
        local actor = self._attacker
        -- local enemies = app.battle:getEnemies()
        if not actor:isGhost() and not actor:isPet() then
            local enemies = actor:getType() == ACTOR_TYPES.NPC and app.battle:getEnemies() or app.battle:getHeroes()
            table.insert(enemies, actor)
        end
        app.battle._appearActors[actor] = nil
    end
end

function QSBJumpAppear:_onRevert()
    if self.__isAnimationPlaying then
        local actor = self._attacker
        -- local enemies = app.battle:getEnemies()
        if not actor:isGhost() and not actor:isPet() then
            local enemies = actor:getType() == ACTOR_TYPES.NPC and app.battle:getEnemies() or app.battle:getHeroes()
            table.insert(enemies, actor)
        end
        app.battle._appearActors[actor] = nil
    end
end

return QSBJumpAppear