local QAIAction = import("..base.QAIAction")
local QAIAllowNormalAttack = class("QAIAllowNormalAttack", QAIAction)

function QAIAllowNormalAttack:ctor( options )
    QAIAllowNormalAttack.super.ctor(self, options)
    self:setDesc("允许AI使用普通攻击")
end

function QAIAllowNormalAttack:_execute(args)
	args.actor:allowNormalAttack()

	return true
end

return QAIAllowNormalAttack