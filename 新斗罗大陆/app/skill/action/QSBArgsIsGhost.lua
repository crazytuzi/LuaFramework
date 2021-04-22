--[[
    Class name QSBArgsIsGhost
    Create by wanghai 
--]]


local QSBNode = import("..QSBNode")
local QSBArgsIsGhost = class("QSBArgsIsGhost", QSBNode)

function QSBArgsIsGhost:_execute(dt)    
    local actor
    if self:getOptions().is_attacker then
        actor = self._attacker
    elseif self:getOptions().is_attackee then
        actor = self._target
    end
    if actor == nil then
        self:finished({select = true})
    else
        if actor:isGhost() then
            self:finished({select = true})
        else
            self:finished({select = false})
        end
    end
end

return QSBArgsIsGhost
