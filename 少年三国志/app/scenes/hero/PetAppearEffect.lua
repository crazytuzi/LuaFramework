require("app.cfg.pet_info")

local EffectMovingNode = require "app.common.effects.EffectMovingNode"
local EffectNode = require "app.common.effects.EffectNode"

local PetAppearEffect = class ("PetAppearEffect", function() return display.newNode() end)

function PetAppearEffect:ctor( resId, endCallback)
    self._resId = resId
    self._endCallback =  endCallback
    self:setNodeEventEnabled(true)

    local info = pet_info.get(resId)
    self._petInfo = info
end

function PetAppearEffect:play(   )

    self._node = EffectMovingNode.new("moving_card_jump", 
        function(key)
            if key == "char" then                                          
                return self:_createPetNode(self._petInfo)
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

function PetAppearEffect:_createPetNode( info,shadow )
    local node = display.newNode()
    local petPath2 = G_Path.getPetReadyGuangEffect(info.ready_id)
    pic2 = EffectNode.new(petPath2)
    pic2:setScale(0.65)
    pic2:play()
    node:addChild(pic2)
    local petPath = G_Path.getPetReadyEffect(info.ready_id)
    local pic = EffectNode.new(petPath)
    pic:play()
    node:addChild(pic)
    return node
    
end

function PetAppearEffect:onExit()
    self:setNodeEventEnabled(false)
    if self._node then
        self._node:stop()
    end
    if self._effect then
        self._effect:stop()
    end
end

return PetAppearEffect


