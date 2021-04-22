--[[
    Class name QSBArgsIsDirectionLeft
    Create by julian 
    @common
--]]


local QSBNode = import("..QSBNode")
local QActor = import("..models.QActor")
local QSBArgsIsDirectionLeft = class("QSBArgsIsDirectionLeft", QSBNode)

function QSBArgsIsDirectionLeft:_execute(dt)    
    local actor
    if self:getOptions().is_attacker then
        actor = self._attacker
    elseif self:getOptions().is_attackee then
        actor = self._target
    end
    if actor == nil then
        self:finished({select = true})
    else
        if actor:getDirection() <= QActor.DIRECTION_LEFT then
            self:finished({select = true})
        else
            self:finished({select = false})
        end
    end
end

return QSBArgsIsDirectionLeft