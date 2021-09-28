--HeroJingJieLayer.lua

local EffectNode = require "app.common.effects.EffectNode"

local HeroJingJieBubbleEffect = class("HeroJingJieBubbleEffect", EffectNode)

function HeroJingJieBubbleEffect:ctor(color)
    local effectName = ""
    if color == "red" then
        effectName = "effect_bubble_red"
    elseif color == "blue" then
        effectName = "effect_bubble_blue"
    elseif color == "purple" then
        effectName = "effect_bubble_purple"
    elseif color == "green" then
        effectName = "effect_bubble_green"
    end


    self.super.ctor(self, effectName)

    self._percentY0 =   -62
    self._percentY100 =   50
    self:play()
end

--percent is 0-100
function HeroJingJieBubbleEffect:_getY(percent)
    return self._percentY0 + (self._percentY100 - self._percentY0)/100*percent
end


function HeroJingJieBubbleEffect:setPercent(startPercent, transitionTime)
    local water = self:getEffectNode("content_1"):getEffectNode("water_1")
    water:stopAllActions()

    if transitionTime == nil then 
        water:setPosition(  ccp(0,  self:_getY(startPercent))  )

    else
        transition.moveTo(water, {x=0, y=  self:_getY(startPercent), time=transitionTime})
    end
    
   
end



-- function HeroJingJieBubbleEffect:set(start, end)
--     -- self:getEffectNode("content"):getEffectNode("water_1"):setPosition(  ccp(0,  self:_getY(start))  )
-- end


return HeroJingJieBubbleEffect