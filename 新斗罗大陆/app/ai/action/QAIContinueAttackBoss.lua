
local QAIAction = import("..base.QAIAction")
local QAIContinueAttackBoss = class("QAIContinueAttackBoss", QAIAction)

function QAIContinueAttackBoss:ctor( options )
    QAIContinueAttackBoss.super.ctor(self, options)
    self:setDesc("继续攻击BOSS")
end

function QAIContinueAttackBoss:_execute(args)
    return false
end

return QAIContinueAttackBoss