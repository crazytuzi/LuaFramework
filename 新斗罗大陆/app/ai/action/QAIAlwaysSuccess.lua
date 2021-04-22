
local QAIAction = import("..base.QAIAction")
local QAIAlwaysSuccess = class("QAIAlwaysSuccess", QAIAction)

function QAIAlwaysSuccess:ctor( options )
    QAIAlwaysSuccess.super.ctor(self, options)
    self:setDesc("总是成功的辅助节点")
end

return QAIAlwaysSuccess