require("app.cfg.knight_info")

local EffectMovingNode = require "app.common.effects.EffectMovingNode"
local EffectNode = require "app.common.effects.EffectNode"

local KnightPic = require "app.scenes.common.KnightPic"

local KnightAppearEffect2 = class ("KnightAppearEffect2", function() return display.newNode() end)



function KnightAppearEffect2:ctor(resId, endCallback)
    self._resId = resId
    self._endCallback =  endCallback
    self:setNodeEventEnabled(true)
end


function KnightAppearEffect2:play(   )
    self._node = EffectMovingNode.new("moving_card_jump", 
        function(key)
            if key == "char" then                                          
                return self:_createKnightNode(self._resId, false)
            elseif key == "effect_card_dust" then
                local effect   = EffectNode.new("effect_card_dust") 

                effect:play()
                return effect  
            end
        end,
        function(event)
            if event == "finish" then
                if self._endCallback ~= nil then
                    self._endCallback()
                end
            end
        end
    )
    self._node:play()
    self:addChild(self._node)

end

function KnightAppearEffect2:_createKnightNode(resId, shadow )
    local pic = KnightPic.createKnightNode(resId, "knight", shadow)    
    pic:setCascadeOpacityEnabled(true)
    return pic
end


function KnightAppearEffect2:onExit()
    self:setNodeEventEnabled(false)
    if self._node then
        self._node:stop()
    end
    if self._effect then
        self._effect:stop()
    end
end

return KnightAppearEffect2


