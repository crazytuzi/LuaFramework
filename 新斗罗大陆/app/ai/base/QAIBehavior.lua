--[[
    Class name QAIBehavior
    Create by julian 
--]]

local QAINode = import("..QAINode")
local QAIBehavior = class("QAIBehavior", QAINode)

--[[
    options is a table. Valid key below:
--]]
function QAIBehavior:ctor( options )
    QAIBehavior.super.ctor(self, options)
    self._actor = nil
end

function QAIBehavior:getActor()
    return self._actor
end

function QAIBehavior:setActor(actor)
    self._actor = actor
end

function QAIBehavior:_evaluate(arguments)
    return true
end

function QAIBehavior:_execute(arguments)
    return true
end

function QAIBehavior:visit(arguments)
    local log = nil
    local logPos = table.nums(arguments.logs) + 1
    -- if arguments.debug == true then
    --     arguments.depth = arguments.depth + 1
    --     log = self.class.__cname
    --     if self:getDesc() then 
    --         log = log .. " : " .. self:getDesc()
    --     end
    -- end

    local exeResult = false

    if self:_evaluate(arguments) == true then
        -- if arguments.debug == true then
        --     log = log .. " : " .. "eval(过)"
        -- end

        exeResult = self:_execute(arguments)

        -- if arguments.debug == true then
        --     if exeResult then
        --         log = log .. " : " .. "exe(过)"
        --     else
        --         log = log .. " : " .. "exe(错)"
        --     end
        -- end
    else
        -- if arguments.debug == true then
        --     log = log .. " : " .. "eval(错)"
        -- end
    end

    -- if arguments.debug == true then
    --     arguments.depth = arguments.depth - 1
    --     table.insert(arguments.logs, logPos, string.format("%-" .. arguments.depth * 3 .. "s%s", "", log))
    -- end

    return exeResult
end

function QAIBehavior:transition(arguments)

end

return QAIBehavior