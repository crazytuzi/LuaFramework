
local QAIAction = import("..base.QAIAction")
local QAIRewindTimers = class("QAIRewindTimers", QAIAction)

local QAITimer = import("..base.QAITimer")

function QAIRewindTimers:ctor( options )
    QAIRewindTimers.super.ctor(self, options)
    self:setDesc("重调计时器")
end

function QAIRewindTimers:_execute(args)
    local actor = args.actor
    local root = self
    while true do
        local parent = root:getParent()
        if parent == nil or parent:isDirector() then
            break
        else
            root = parent
        end
    end
    local function traverse(node)
        for _, subnode in ipairs(node:getChildren()) do
            traverse(subnode)
        end

        if node._execute == QAITimer._execute then
            node._lastTime = app.battle:getTime()
        end
    end
    traverse(root)
    return true
end

return QAIRewindTimers