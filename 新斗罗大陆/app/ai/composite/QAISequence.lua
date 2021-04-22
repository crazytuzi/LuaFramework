--[[
    Class name QAISequence
    Create by julian 
--]]

local QAIComposite = import("..base.QAIComposite")
local QAISequence = class("QAISequence", QAIComposite)

function QAISequence:_execute(arguments)
    local count = self:getChildrenCount()
    for index = 1, count, 1 do
        local behavior = self:getChildAtIndex(index)
        if behavior:visit(arguments) == false then
            return false
        end
    end

    return true
end

return QAISequence