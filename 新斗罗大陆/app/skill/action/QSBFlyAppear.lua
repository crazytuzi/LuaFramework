--[[
    Class name QSBFlyAppear
    Create by julian 
--]]

local QSBAction = import(".QSBAction")
local QSBFlyAppear = class("QSBFlyAppear", QSBAction)

function QSBFlyAppear:_execute(dt)
    local actor = self._attacker
    local flyanimation = self._options.fly_animation

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

    self._attacker:playSkillAnimation({flyanimation}, false)
    self._endAnimationName = flyanimation
    self._eventListener = cc.EventProxy.new(self._attacker)
    self._eventListener:addEventListener(actor.ANIMATION_ENDED, handler(self, self._onAnimationEnded))
    self.__isAnimationPlaying = true
end

function QSBFlyAppear:_onAnimationEnded(event)
    if event.animationName == self._endAnimationName then
        self._eventListener:removeAllEventListeners()
        
        local actor = self._attacker
        -- local enemies = app.battle:getEnemies()
        if not actor:isGhost() and not actor:isPet() then
            local enemies = actor:getType() == ACTOR_TYPES.NPC and app.battle:getEnemies() or app.battle:getHeroes()
            table.insert(enemies, actor)
        end
        app.battle._appearActors[actor] = nil
        self.__isAnimationPlaying = false

        self:finished()
    end
end

function QSBFlyAppear:_onCancel()
    if self.__isAnimationPlaying then
        local actor = self._attacker
        -- local enemies = app.battle:getEnemies()
        if not actor:isGhost() and not actor:isPet() then
            local enemies = actor:getType() == ACTOR_TYPES.NPC and app.battle:getEnemies() or app.battle:getHeroes()
            table.insert(enemies, actor)
        end
        app.battle._appearActors[actor] = nil
        self.__isAnimationPlaying = false
    end
end

function QSBFlyAppear:_onRevert()
    if self.__isAnimationPlaying then
        local actor = self._attacker
        -- local enemies = app.battle:getEnemies()
        if not actor:isGhost() and not actor:isPet() then
            local enemies = actor:getType() == ACTOR_TYPES.NPC and app.battle:getEnemies() or app.battle:getHeroes()
            table.insert(enemies, actor)
        end
        app.battle._appearActors[actor] = nil
        self.__isAnimationPlaying = false
    end
end

return QSBFlyAppear