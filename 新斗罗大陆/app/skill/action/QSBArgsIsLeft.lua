--[[
    Class name QSBArgsIsLeft
    Create by julian 
--]]


local QSBNode = import("..QSBNode")
local QSBArgsIsLeft = class("QSBArgsIsLeft", QSBNode)

function QSBArgsIsLeft:_execute(dt)    
    local actor
    if self:getOptions().is_attacker then
        actor = self._attacker
    elseif self:getOptions().is_attackee then
        actor = self._target
    end
    if actor == nil then
        self:finished({select = true})
    else
        if actor:getPosition().x <= BATTLE_SCREEN_WIDTH / 2 then
            self:finished({select = true})
        else
            self:finished({select = false})
        end
    end
end

return QSBArgsIsLeft