
local QAIAction = import("..base.QAIAction")
local QAIInBattleRange = class("QAIInBattleRange", QAIAction)

function QAIInBattleRange:ctor( options )
    QAIInBattleRange.super.ctor(self, options)
    self:setDesc("是否在战斗场地范围内")
end

function QAIInBattleRange:_evaluate(args)
    local actor = args.actor

    local area = app.grid:getRangeArea()
    local pos = actor:getPosition()
    if pos.x >= area.left and pos.x <= area.right and pos.y >= area.bottom and pos.y <= area.top then
        return true
    else
        return false
    end
end

return QAIInBattleRange