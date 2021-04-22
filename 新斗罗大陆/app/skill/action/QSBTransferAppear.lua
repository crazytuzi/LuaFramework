--[[
    Class name QSBTransferAppear
    Create by julian 
--]]

local QSBAction = import(".QSBAction")
local QSBTransferAppear = class("QSBTransferAppear", QSBAction)

function QSBTransferAppear:_execute(dt)
    local actor = self._attacker
    local color = self._options.color

    if self.__isAnimationPlaying == true then
        self.__time = self.__time + dt
        if self.__time > 1.3 then
            if not IsServerSide then
                local view = app.scene:getActorViewFromModel(actor)
                local percent = (self.__time - 1.3) / (26 / SPINE_RUNTIME_FRAME)
                local on_minus_percent = 1 - percent
                view:setOpacityActor(math.min(255, 255 * percent))
                view:setScissorEnabled(true)
                view:setScissorColor(ccc3(color.r * on_minus_percent, color.g * on_minus_percent, color.b * on_minus_percent))
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

    if not IsServerSide then
        local view = app.scene:getActorViewFromModel(actor)
        local maskRect = CCRect(-200, -200, 400, 400)
        view:setScissorEnabled(true)
        view:setScissorRects(
            maskRect,
            CCRect(0, 0, 0, 0),
            CCRect(0, 0, 0, 0),
            CCRect(0, 0, 0, 0)
        )
        local func = ccBlendFunc()
        func.src = GL_DST_ALPHA
        func.dst = GL_DST_ALPHA
        view:setScissorBlendFunc(func)
        view:setScissorColor(color)
        view:setScissorOpacity(0)
        func.src = GL_SRC_ALPHA
        func.dst = GL_ONE_MINUS_SRC_ALPHA
        view:setRenderTextureBlendFunc(func)
        view:setOpacityActor(0)

        local effectID = self._options.effect_id
        local options = {}
        options.isAttackEffect = true
        options.skillId = self._skill:getId()
        actor:playSkillEffect("transfer_matrix_1", function()
            view:setOpacityActor(255)
            view:setScissorEnabled(false)
        end, options)
        actor:playSkillEffect("transfer_matrix_2", nil, options)
    end

    app.battle:performWithDelay(function()
        if not actor:isGhost() and not actor:isPet() then
            local arr = self:_getMyTeammates()
            table.insert(arr, actor)
        end
        app.battle._appearActors[actor] = nil
        self:finished()
    end, 60 / SPINE_RUNTIME_FRAME)

    self.__isAnimationPlaying = true
    self.__time = 0
end

function QSBTransferAppear:_onCancel()
    if self.__isAnimationPlaying then
        local actor = self._attacker
        if not actor:isGhost() and not actor:isPet() then
            local arr = self:_getMyTeammates()
            table.insert(arr, actor)
        end
        app.battle._appearActors[actor] = nil
        if not IsServerSide then
            app.scene:getActorViewFromModel(actor):setOpacityActor(255)
        end
    end
end

function QSBTransferAppear:_onRevert()
    if self.__isAnimationPlaying then
        local actor = self._attacker
        if not actor:isGhost() and not actor:isPet() then
            local arr = self:_getMyTeammates()
            table.insert(arr, actor)
        end
        app.battle._appearActors[actor] = nil
        if not IsServerSide then
            app.scene:getActorViewFromModel(actor):setOpacityActor(255)
        end
    end
end

function QSBTransferAppear:_getMyTeammates()
    local actor = self._attacker
    if actor:getType() == ACTOR_TYPES.HERO or actor:getType() == ACTOR_TYPES.HERO_NPC then
        return app.battle:getHeroes()
    else
        return app.battle:getEnemies()
    end
end

return QSBTransferAppear
