--[[
    设置人物为中立方(无法被选中)
    必须先用isNeutral = true后再使用isNeutral = false，isNeutral = false 不能单独使用
    @common
--]]
local QSBAction = import(".QSBAction")
local QSBSetActorNeutral = class("QSBSetActorNeutral", QSBAction)

function QSBSetActorNeutral:ctor(director, attacker, target, skill, options)
    QSBSetActorNeutral.super.ctor(self, director, attacker, target, skill, options)
    self._isNeutral = options.isNeutral
    self._executed = false
end

function QSBSetActorNeutral:_execute(dt)
    local target = self._target or self._attacker:getTarget()
    if nil ~= target and not target:isDead() then
        self:setActorNeutral(self._isNeutral, target)
        self._executed = true

        self:finished()
    else
        self:finished()
    end
end

function QSBSetActorNeutral:_onCancel()
    if self._executed then
        local target = self._target or self._attacker:getTarget()
        if nil ~= target and not target:isDead() then
            local isNeutral = (not self._isNeutral)
            self:setActorNeutral(isNeutral, target)
        end
    end
end

function QSBSetActorNeutral:_onRevert()
    if self._executed then
        local target = self._target or self._attacker:getTarget()
        if nil ~= target and not target:isDead() then
            local isNeutral = (not self._isNeutral)
            self:setActorNeutral(isNeutral, target)
        end
    end
end

function QSBSetActorNeutral:setActorNeutral(isNeutral, target)
    if not IsServerSide then
        local view = app.scene:getActorViewFromModel(target)
        if view.setEnableTouchEvent then
            view:setEnableTouchEvent(false == self._isNeutral)
        end
    end

    local actorType = target:getType()
    local actorList = nil
    if actorType == ACTOR_TYPES.HERO or actorType == ACTOR_TYPES.HERO_NPC then
        if target:isGhost() then
            actorList = app.battle:getHeroGhosts()
        else
            actorList = app.battle:getHeroes()
        end
    else
        if target:isGhost() then
            actorList = app.battle:getEnemyGhosts()
        else
            actorList = app.battleL:getEnemies()
        end
    end
    if nil ~= actorList then
        if true == self._isNeutral then
            local allActorsList = {}
            table.mergeForArray(allActorsList, app.battle:getHeroes())
            table.mergeForArray(allActorsList, app.battle:getEnemies())
            for _, actor in ipairs(allActorsList) do
                if not actor:isDead() and actor:getTarget() == target then
                    while actor:isLockTarget() do
                        actor:unlockTarget()
                    end
                    actor:setTarget(nil)
                end
            end

            table.removebyvalue(actorList, target)
            target:lockDrag()
        else
            table.insert(actorList, target)
            target:unlockDrag()
        end
    end
    
    target:setIsNeutral(self._isNeutral)
end

return QSBSetActorNeutral
