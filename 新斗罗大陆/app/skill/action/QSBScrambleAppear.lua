--[[
    Class name QSBScrambleAppear
    Create by julian 
--]]

local QSBAction = import(".QSBAction")
local QSBScrambleAppear = class("QSBScrambleAppear", QSBAction)

function QSBScrambleAppear:_execute(dt)
    local actor = self._attacker
    local scrambleanimation = self._options.scramble_animation

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

    if not IsServerSide then
        local maskRect
        if self._options.mask then
            local mask = self._options.mask
            maskRect = CCRect(mask.x, mask.y, mask.width, mask.height)
        else
            maskRect = CCRect(-100, -200, 200, 190)
        end
        local view = app.scene:getActorViewFromModel(actor)
        view:setScissorEnabled(true)
        view:setScissorRects(
            maskRect,
            CCRect(0, 0, 0, 0),
            CCRect(0, 0, 0, 0),
            CCRect(0, 0, 0, 0)
        )
    end

    self._attacker:playSkillAnimation({scrambleanimation}, false)
    self._endAnimationName = scrambleanimation
    self._eventListener = cc.EventProxy.new(self._attacker)
    self._eventListener:addEventListener(actor.ANIMATION_ENDED, handler(self, self._onAnimationEnded))
    self.__isAnimationPlaying = true
end

function QSBScrambleAppear:_onAnimationEnded(event)
    if event.animationName == self._endAnimationName then
        self._eventListener:removeAllEventListeners()
        
        local actor = self._attacker
        if not actor:isGhost() and not actor:isPet() then
            local enemies = app.battle:getEnemies()
            table.insert(enemies, actor)
        end
        app.battle._appearActors[actor] = nil
        self.__isAnimationPlaying = false

        if not IsServerSide then
            local view = app.scene:getActorViewFromModel(actor)
            view:setScissorEnabled(false)
        end

        self:finished()
    end
end

function QSBScrambleAppear:_onCancel()
    if self.__isAnimationPlaying then
        local actor = self._attacker
        if not actor:isGhost() and not actor:isPet() then
            local enemies = app.battle:getEnemies()
            table.insert(enemies, actor)
        end
        app.battle._appearActors[actor] = nil
        self.__isAnimationPlaying = false
    end
end

function QSBScrambleAppear:_onRevert()
    if self.__isAnimationPlaying then
        local actor = self._attacker
        if not actor:isGhost() and not actor:isPet() then
            local enemies = app.battle:getEnemies()
            table.insert(enemies, actor)
        end
        app.battle._appearActors[actor] = nil
        self.__isAnimationPlaying = false
    end
end

return QSBScrambleAppear