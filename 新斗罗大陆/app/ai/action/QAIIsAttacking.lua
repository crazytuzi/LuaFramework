
local QAIAction = import("..base.QAIAction")
local QAIIsAttacking = class("QAIIsAttacking", QAIAction)

function QAIIsAttacking:ctor( options )
    QAIIsAttacking.super.ctor(self, options)
    self:setDesc("是否在进行攻击")
end

--[[
是否处于攻击状态，判定条件:
1. 有上次攻击的敌人
2. 上次攻击过的对象依然活着
--]]
function QAIIsAttacking:_evaluate(args)
	if args.actor:getTarget() == nil then
		return false
	end
    local attackee = args.actor:getLastAttackee()
    if attackee == nil or attackee:isDead() then return false end

    return true
end

return QAIIsAttacking