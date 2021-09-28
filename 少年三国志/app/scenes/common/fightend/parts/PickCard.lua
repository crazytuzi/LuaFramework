
local EffectMovingNode = require "app.common.effects.EffectMovingNode"
local PickCardLayer = require "app.scenes.common.fightend.controls.PickCardLayer"

local PickCard = class ("PickCard", function() return display.newNode() end)



function PickCard:ctor( picks, endCallback)
  
   self._endCallback =  endCallback
   self:setNodeEventEnabled(true)
   self._layer = PickCardLayer.create()
   self._layer:setPicks(picks)
   self._layer:setEndCallback(endCallback)
   local size = self._layer:getContentSize()
   self._layer:setPosition(ccp(-size.width/2, -size.height/2))
   self:addChild(self._layer)


end


function PickCard:play(   )
    --显示卡牌 的背面状态
    self._layer:playAtBack()
end

function PickCard:onExit()
    self:setNodeEventEnabled(false)


    
end

return PickCard