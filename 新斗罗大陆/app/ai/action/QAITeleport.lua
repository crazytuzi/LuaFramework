
local QAIAction = import("..base.QAIAction")
local QAITeleport = class("QAITeleport", QAIAction)

function QAITeleport:ctor( options )
    QAITeleport.super.ctor(self, options)
    if self._options.interval == nil then
        self._options["interval"] = 1.0
    end
    self._lastRun = -10e20
    self:setDesc("瞬间移动")
end

function QAITeleport:_evaluate(args)
    local actor = args.actor
    if actor == nil or actor:isDead() == true then
        return false
    end

    local time = app.battle:getTime()
    if time - self._lastRun < self._options.interval then
        return false
    end

    if self._options.hp_less_than ~= nil then
        local percent = self._options.hp_less_than
        if percent <= (actor:getHp() / actor:getMaxHp()) then
            return false
        end
    end

    return true
end

function QAITeleport:_execute(args)
    local actor = args.actor
    
    local battle_area = app.grid:getRangeArea()
    local x = app.random(math.floor(battle_area.left), math.floor(battle_area.right))
    local y = app.random(math.floor(battle_area.bottom), math.floor(battle_area.top * 0.8))
    local position = qccp(x, y)

    if not IsServerSide then
        local actorView = app.scene:getActorViewFromModel(actor)
        if actorView ~= nil then
            local arr = CCArray:create()
            arr:addObject(CCFadeOut:create(0.15))
            arr:addObject(CCFadeIn:create(0.15))
            actorView:getSkeletonActor():runAction(CCSequence:create(arr))
        end
    end

    app.battle:performWithDelay(function()
        app.grid:setActorTo(actor, position)
    end, 0.15)

    self._lastRun = app.battle:getTime()

    return true
end

return QAITeleport