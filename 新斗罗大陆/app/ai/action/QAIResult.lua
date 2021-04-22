
local QAIAction = import("..base.QAIAction")
local QAIResult = class("QAIResult", QAIAction)

function QAIResult:ctor( options )
    QAIResult.super.ctor(self, options)
    self:setDesc("仅仅用于返回设定result的QAIActioin")
end

function QAIResult:_execute(args)
	return self._options.result ~= nil and self._options.result
end

return QAIResult