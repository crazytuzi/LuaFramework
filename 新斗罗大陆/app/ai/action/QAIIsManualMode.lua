
local QAIAction = import("..base.QAIAction")
local QAIIsManualMode = class("QAIIsManualMode", QAIAction)

function QAIIsManualMode:ctor( options )
    QAIIsManualMode.super.ctor(self, options)
    self:setDesc("是否在手动操作模式")
end

--[[
是否处于手动操作模式，一旦用户指挥了魂师，则该魂师进入手动操作模式，除非攻击对象死亡
--]]
function QAIIsManualMode:_evaluate(args)
    return args.actor:isManualMode()
end

return QAIIsManualMode