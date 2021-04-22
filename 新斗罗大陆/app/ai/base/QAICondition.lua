--[[
    Class name QAICondition
    Create by julian 
    Terminal node
--]]

local QAIBehavior = import(".QAIBehavior")
local QAICondition = class("QAICondition", QAIBehavior)

--[[
    condition: {identity = string, operator = string, params = {...} }
    options is a table. Valid key below:
--]]
function QAICondition:ctor( condition, options )
    QAICondition.super.ctor(self, options)
    self._condition = condition
    self:setNodeEventEnabled(true)

end

function QAICondition:getCondition()
    return self._condition
end

--[[
    arguments: { {identity = string, params = {...} }, }
--]]
function QAICondition:_execute( arguments )
    
    if self._condition == nil then
        return true
    end

    local identity = self._condition["identity"]
    local operator = self._condition["operator"]
    local params = self._condition["params"]
    local resoult = false

    for key, condition in ipairs(arguments) do
        if identity == condition["identity"] then
            resoult = self:_executeEachCondition(operator, params, condition["params"])
        end
    end

    return resoult

end

function QAICondition:_executeEachCondition( operator, params, current)
    return true
end

return QAICondition
