
local QAIAction = import("..base.QAIAction")
local QAISetSpeed = class("QAISetSpeed", QAIAction)

function QAISetSpeed:ctor( options )
    QAISetSpeed.super.ctor(self, options)
    self:setDesc("设置QActor的速度")
end

function QAISetSpeed:_evaluate(args)
    local actor = args.actor
    if actor == nil or actor:isDead() == true then
        return false
    end

    if type(self:getOptions().speed) ~= "number" and self:getOptions().speed ~= "character_speed" then
        return false
    end

    return true
end

function QAISetSpeed:_execute(args)
    local actor = args.actor

    if type(self:getOptions().speed) == "number" then
        actor:insertPropertyValue("movespeed_replace", self, "&", self:getOptions().speed)
    elseif self:getOptions().speed == "character_speed" then
        actor:removePropertyValue("movespeed_replace", self)
    end

    return true
end

return QAISetSpeed