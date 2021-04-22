
local QAIAction = import("..base.QAIAction")
local QAINPCStayMode = class("QAINPCStayMode", QAIAction)

function QAINPCStayMode:ctor( options )
    QAINPCStayMode.super.ctor(self, options)
    self:setDesc("是否让npc ai进入STAY模式")
end

function QAINPCStayMode:_execute( args )
    local actor = args.actor
    if self:getOptions().stay then
        actor:setManualMode(actor.STAY)
    else
        actor:setManualMode(actor.AUTO)
    end

    return true
end

return QAINPCStayMode