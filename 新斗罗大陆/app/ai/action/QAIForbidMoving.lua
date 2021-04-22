
local QAIAction = import("..base.QAIAction")
local QAIForbidMoving = class("QAIForbidMoving", QAIAction)

function QAIForbidMoving:ctor( options )
    QAIForbidMoving.super.ctor(self, options)
    self:setDesc("禁止ai移动")
end

function QAIForbidMoving:_execute( args )
    local actor = args.actor
    actor:forbidMove()

    return true
end

return QAIForbidMoving