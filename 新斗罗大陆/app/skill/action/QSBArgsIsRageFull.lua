--[[
    Class name QSBArgsIsRageFull
    Create by nan.zhang
--]]


local QSBNode = import("..QSBNode")
local QSBArgsIsRageFull = class("QSBArgsIsRageFull", QSBNode)

function QSBArgsIsRageFull:_execute(dt)    
    local actor = self._attacker
    self:finished({select = actor:isRageEnough()})
end

return QSBArgsIsRageFull