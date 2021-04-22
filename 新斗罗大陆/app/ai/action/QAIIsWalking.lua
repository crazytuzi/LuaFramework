
local QAIAction = import("..base.QAIAction")
local QAIIsWalking = class("QAIIsWalking", QAIAction)

function QAIIsWalking:ctor( options )
    QAIIsWalking.super.ctor(self, options)
    self:setDesc("是否走动且非追击")
end

--[[
是否处于单纯走动状态，判定条件:
1. actor的状态是走动状态
2. 没有正在攻击人活着上次攻击过的对象已经被打死了
--]]
function QAIIsWalking:_evaluate(args)
    local actor = args.actor

    if not actor:isWalking() then return false end

    local attackee = actor:getLastAttackee()
    if attackee ~= nil and not attackee:isDead() then return false end

    return true
end

return QAIIsWalking