--[[
    Class name QAIComposite
    Create by julian 
--]]

local QAIBehavior = import(".QAIBehavior")
local QAIComposite = class("QAIComposite", QAIBehavior)

function QAIComposite:_evaluate(arguments)
    local count = self:getChildrenCount()
    if count >= 1 then 
        return true
    else
        return false
    end
end

return QAIComposite