local QAIAction = import("..base.QAIAction")
local QAIUnionDragonApplyBuff = class("QAIUnionDragonApplyBuff", QAIAction)

function QAIUnionDragonApplyBuff:ctor( options )
    QAIUnionDragonApplyBuff.super.ctor(self, options)
    self:setDesc("宗门武魂上buff")
end

function QAIUnionDragonApplyBuff:_execute( args )
    local actor = args.actor
    local weatherId = app.battle:getUnionDragonWarWeatherId()
    local buffId = db:getDragonWarWeatherById(weatherId).buff_id
    actor:applyBuff(buffId, actor)
    return true
end

return QAIUnionDragonApplyBuff