
local QAIAction = import("..base.QAIAction")
local QAIAttackByActorID = class("QAIAttackByActorID", QAIAction)

function QAIAttackByActorID:ctor( options )
    QAIAttackByActorID.super.ctor(self, options)
    self:setDesc("按照actor id设定目标")
end

function QAIAttackByActorID:_execute(args)
    local actor = args.actor
    local actor_id = self._options.actor_id

    if actor == nil then
        assert(false, "invalid args, actor is nil.")
        return false
    end

    if actor_id == nil then
        assert(false, "invalid args, actor_id is nil")
        return false
    end

    local enemies = app.battle:getMyEnemies(actor)
    local mates = app.battle:getMyTeammates(actor, false)
    local candidates = {}
    for _, actor in ipairs(enemies) do
        if actor:getActorID() == actor_id then
            table.insert(candidates, actor)
        end
    end
    for _, actor in ipairs(mates) do
        if actor:getActorID() == actor_id then
            table.insert(candidates, actor)
        end
    end

    if #candidates == 0 then
        return false
    end

    local target = actor:getClosestActor(candidates)

    if target == nil then
        return false
    end

    actor:setTarget(target)
    return true
end

return QAIAttackByActorID