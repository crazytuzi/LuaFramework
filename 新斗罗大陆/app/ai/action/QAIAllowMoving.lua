
local QAIAction = import("..base.QAIAction")
local QAIAllowMoving = class("QAIAllowMoving", QAIAction)

function QAIAllowMoving:ctor( options )
    QAIAllowMoving.super.ctor(self, options)
    self:setDesc("允许ai移动")
end

function QAIAllowMoving:_execute( args )
    local actor = args.actor
    actor:allowMove()

    return true
end

return QAIAllowMoving