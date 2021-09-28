--HeroJingJieLayer.lua

local EffectNode = require "app.common.effects.EffectNode"

local HeroGuangHuangBarEffect = class("HeroGuangHuangBarEffect", EffectNode)

function HeroGuangHuangBarEffect:ctor()
    local effectName = "effect_dragon_bar"
  

    self.super.ctor(self, effectName)

    self._percentX0 =   -338.3
    self._percentX100 =   -1
  
end

--percent is 0-100
function HeroGuangHuangBarEffect:_getX(percent)
    return self._percentX0 + (self._percentX100 - self._percentX0)/100*percent
end


function HeroGuangHuangBarEffect:setPercent(startPercent, transitionTime)
    local maskNode = self:getEffectNode("mask_rect_0")
    maskNode:stopAllActions()

    if transitionTime == nil then 
        maskNode:setPosition(  ccp( self:_getX(startPercent), 0)  )

    else
        transition.moveTo(maskNode, {y=0, x=  self:_getX(startPercent), time=transitionTime})
    end
    
   
end



return HeroGuangHuangBarEffect