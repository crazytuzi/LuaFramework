--[[
    Class name QAINode
    Create by julian 
--]]

local QNode = import("..base.QNode")
local QAINode = class("QAINode", QNode)

--[[
    options is a table. Valid key below:
--]]
function QAINode:ctor( options )
    QAINode.super.ctor(self, options)
    self._name = nil
    self._desc = nil
    self._isDirector = false
end

function QAINode:getDesc()
    return self._desc
end

function QAINode:setDesc(desc)
    self._desc = desc
end

function QAINode:getName()
    return self._name
end

function QAINode:setName(name)
    self._name = name
end

function QAINode:isDirector()
    return self._isDirector
end

local function createRegulator(count)
    local i = 1
    local function check()
        i = i + 1
        if i > count then
            i = 1
        end
        return i == 1
    end
    return check
end

function QAINode:createRegulator(count)
    self._regulator = createRegulator(count)
end

return QAINode