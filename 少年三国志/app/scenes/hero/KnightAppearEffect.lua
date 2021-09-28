require("app.cfg.knight_info")

local EffectMovingNode = require "app.common.effects.EffectMovingNode"
local EffectNode = require "app.common.effects.EffectNode"

local KnightPic = require "app.scenes.common.KnightPic"

local KnightAppearEffect = class ("KnightAppearEffect", function() return display.newNode() end)



function KnightAppearEffect:ctor( knightInfoId, endCallback, dressResId)
    self._knightInfoId = knightInfoId
    self._endCallback =  endCallback
    self:setNodeEventEnabled(true)

    self._dressResId = dressResId or 0
    local info = knight_info.get(knightInfoId)
    self._knightInfo = info
end





function KnightAppearEffect:play(   )

    -- self._node = EffectMovingNode.new("moving_onecard", function(key)
    --         if key == "btn" then
    --             local pic = KnightPic.createKnightNode(self._knightInfo.res_id)    
    --             pic:setCascadeOpacityEnabled(true)

    --             return pic
    --         elseif key == "shadow" then
    --             local pic = KnightPic.createKnightNode(self._knightInfo.res_id)    
    --             pic:setCascadeOpacityEnabled(true)

    --             return pic   
    --         elseif key == "effect" then
    --             if self._knightInfo.quality >= 4 then
    --                 self._effect = EffectNode.new("effect_bomb", function(event) 
    --                     if event == "finish" then
    --                         self._effect:stop()
    --                     end
    --                 end) 
    --                 self._effect:play()
    --                 return self._effect
    --             end

    --             return display.newNode()
    --         end
    --     end,
    --     function (event) 
    --         if event=="finish_appear" and self._endCallback ~= nil then
    --             self._endCallback()
    --             self._endCallback  = nil
                
    --         end
    --     end
    -- )

    
    -- self:addChild(self._node)
    -- self._node:play()
    --self._endCallback()

    self._node = EffectMovingNode.new("moving_card_jump", 
        function(key)
            if key == "char" then                                          
                return self:_createKnightNode(self._knightInfo, false)
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

function KnightAppearEffect:_createKnightNode( info,shadow )

    local pic = KnightPic.createKnightNode(self._dressResId > 0 and self._dressResId or info.res_id, "knight", shadow)    
    pic:setCascadeOpacityEnabled(true)




    -- if info.quality >= 4 then
    --     local effect  
    --     effect= EffectNode.new("effect_card_back", function(event) 
            
    --     end) 
    --     effect:setScale(3.2)
    --     effect:play()
    --     pic:addChild(effect, - 4)
    -- end

    return pic
    
end


function KnightAppearEffect:onExit()
    self:setNodeEventEnabled(false)
    if self._node then
        self._node:stop()
    end
    if self._effect then
        self._effect:stop()
    end
end

return KnightAppearEffect


