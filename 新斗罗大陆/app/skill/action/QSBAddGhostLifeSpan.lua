    --[[
    Class name QSBAddGhostLifeSpan
    Create by wanghai
--]]

local QSBAction = import(".QSBAction")
local QSBAddGhostLifeSpan = class("QSBAddGhostLifeSpan", QSBAction)

local QActor = import("...models.QActor")

function QSBAddGhostLifeSpan:_execute(dt)
    local actor = self._attacker
    local addTime = self:getOptions().add_time
    if nil == addTime then
        addTime = 5
    end

    local totoalGhosts = actor:getType() == ACTOR_TYPES.NPC and app.battle:getEnemyGhosts() or app.battle:getHeroGhosts()
    for _, ghostInfo in ipairs(totoalGhosts) do
        if not ghostInfo.actor:isDead() and ghostInfo.summoner == actor and ghostInfo.actor:isUnderStatus(self:getOptions().status) then
            ghostInfo.life_countdown = ghostInfo.life_countdown + addTime
        end
    end

    self:finished()
end

return QSBAddGhostLifeSpan