--[[
    Class name QAIDecorator
    Create by julian 
--]]

local QAIBehavior = import(".QAIBehavior")
local QAIDecorator = class("QAIDecorator", QAIBehavior)

function QAIDecorator:_evaluate(arguments)
    local count = self:getChildrenCount()
    if count >= 1 then 
        return true
    else
        return false
    end
end

return QAIDecorator