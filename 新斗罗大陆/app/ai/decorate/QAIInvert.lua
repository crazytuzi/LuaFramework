--[[
    Class name QAIInvert
    Create by julian 
--]]

local QAIComposite = import("..base.QAIComposite")
local QAIInvert = class("QAIInvert", QAIComposite)

function QAIInvert:_execute(arguments)
    local count = self:getChildrenCount()
    if count <= 0 then
        return false
    end

    local behavior = self:getChildAtIndex(1)
    if behavior:visit(arguments) == true then
        return false
    else
        return true
    end
end

return QAIInvert