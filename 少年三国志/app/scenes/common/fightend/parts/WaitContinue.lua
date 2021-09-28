
local EffectMovingNode = require "app.common.effects.EffectMovingNode"
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

local WaitContinue = class ("WaitContinue", function() return display.newNode() end)



function WaitContinue:ctor( )
   
    -- self:setNodeEventEnabled(true)

    self._img = ImageView:create()
    self._img:loadTexture( G_Path.getTextPath("dianjijixu.png"))
    self:setPositionY(-380)
    self:addChild(self._img)

end

function WaitContinue:play(   )

    self._effect = EffectSingleMoving.run(self._img, "smoving_wait" )




end




function WaitContinue:onExit()
    self:setNodeEventEnabled(false)
    if  self._effect then
        self._effect:stop()
    end
    
end

return WaitContinue