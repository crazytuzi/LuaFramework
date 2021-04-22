
local QAIAction = import("..base.QAIAction")
local QAIForbidNormalAttack = class("QAIForbidNormalAttack", QAIAction)

function QAIForbidNormalAttack:ctor( options )
    QAIForbidNormalAttack.super.ctor(self, options)
    self:setDesc("禁止AI使用普通攻击")
end

function QAIForbidNormalAttack:_execute(args)
	args.actor:forbidNormalAttack()

	return true
end

return QAIForbidNormalAttack