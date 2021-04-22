--[[
    Class name QSBArgsIsHero
    Create by wanghai 
--]]


local QSBNode = import("..QSBNode")
local QSBArgsIsHero = class("QSBArgsIsHero", QSBNode)

function QSBArgsIsHero:_execute(dt)    
    local actor
    if self:getOptions().is_attacker then
        actor = self._attacker
    elseif self:getOptions().is_attackee then
        actor = self._target
    end
    if actor == nil then
        self:finished({select = true})
    else
        local actorType = actor:getType()
        if actorType == ACTOR_TYPES.HERO or actorType == ACTOR_TYPES.HERO_NPC then
            self:finished({select = true})
        else
            self:finished({select = false})
        end
    end
end

return QSBArgsIsHero