--[[
    Class name QSBFlashAppear
    Create by julian 
--]]

local QSBAction = import(".QSBAction")
local QSBFlashAppear = class("QSBFlashAppear", QSBAction)

function QSBFlashAppear:_execute(dt)
    local actor = self._attacker
    local color = self._options.color
    local wait_time = self._options.wait_time
    local fade_in_time = self._options.fade_in_time

    if self.__isAnimationPlaying == true then
        self.__time = self.__time + dt
        if self.__time > wait_time then
            local percent = (self.__time - wait_time) / fade_in_time
            if not IsServerSide then
                local view = app.scene:getActorViewFromModel(actor)
                if view and view.isFca then
                    local one_minus_percent = math.max(0, 1 - percent)
                    one_minus_percent = math.pow(1 - math.abs(one_minus_percent - 0.8), 2)
                    view:setOpacityActor(math.min(255, 255 * percent))
                    view:setScissorEnabled(true)
                    view:setScissorColor(ccc3(color.r * one_minus_percent, color.g * one_minus_percent, color.b * one_minus_percent))
                end
            end

            if percent >= 1 then
                self:finished()
            end
        end
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

    -- if not IsServerSide then
    --     local view = app.scene:getActorViewFromModel(actor)
    --     if view and view.isFca then
    --         local maskRect = CCRect(-200, -200, 400, 400)
    --         view:setScissorEnabled(true)
    --         view:setScissorRects(
    --             maskRect,
    --             CCRect(0, 0, 0, 0),
    --             CCRect(0, 0, 0, 0),
    --             CCRect(0, 0, 0, 0)
    --         )
    --         local func = ccBlendFunc()
    --         func.src = GL_DST_ALPHA
    --         func.dst = GL_DST_ALPHA
    --         view:setScissorBlendFunc(func)
    --         view:setScissorColor(color)
    --         view:setScissorOpacity(0)
    --         func.src = GL_SRC_ALPHA
    --         func.dst = GL_ONE_MINUS_SRC_ALPHA
    --         view:setRenderTextureBlendFunc(func)
    --         view:setOpacityActor(0)
    --     end
    -- end

    local options = {}
    options.isAttackEffect = true
    options.skillId = self._skill:getId()
    self._appearActor = actor

    self.__isAnimationPlaying = true
    self.__time = 0
end

function QSBFlashAppear:finished()
    if not IsServerSide then
        local view = app.scene:getActorViewFromModel(self._appearActor)
        if view and view.isFca then
            view:setOpacityActor(255)
            view:setScissorEnabled(false)
        end
    end
    if self._appearActor and not self._appearActor:isGhost() and not self._appearActor:isPet() then
        local arr = self:_getMyTeammates()
        table.insert(arr, self._appearActor)
    end
    app.battle._appearActors[self._appearActor] = nil
    self.__isAnimationPlaying = false

    self.super.finished(self)
end

function QSBFlashAppear:_onCancel()
    if self.__isAnimationPlaying then
        local actor = self._attacker
        if not actor:isGhost() and not actor:isPet() then
            local arr = self:_getMyTeammates()
            table.insert(arr, actor)
        end
        app.battle._appearActors[actor] = nil
        if not IsServerSide then
            local view = app.scene:getActorViewFromModel(actor)
            if view and view.isFca then
                view:setOpacityActor(255)
            end
        end
        self.__isAnimationPlaying = false
    end
end

function QSBFlashAppear:_onRevert()
    self:_onCancel()
end

function QSBFlashAppear:_getMyTeammates()
    local actor = self._attacker
    if actor:getType() == ACTOR_TYPES.HERO or actor:getType() == ACTOR_TYPES.HERO_NPC then
        return app.battle:getHeroes()
    else
        return app.battle:getEnemies()
    end
end

return QSBFlashAppear
