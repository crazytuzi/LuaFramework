require("app.cfg.knight_info")

local EffectMovingNode = require "app.common.effects.EffectMovingNode"
local EffectNode = require "app.common.effects.EffectNode"
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

local KnightPic = require "app.scenes.common.KnightPic"


local JumpBackCard = class ("JumpBackCard", UFCCSModelLayer)


function JumpBackCard:ctor( ... )
    self.super.ctor(self, ...)
    
end



function JumpBackCard.create( )
    local node = JumpBackCard.new()
    return node
end

function JumpBackCard:play(knightResId,  startJumpWorldPosition, startJumpScale, jumpToWorldPosition, jumpToScale, endCallback)



    self._jumpMoving = EffectMovingNode.new("moving_card_jump", 
        function(key)
            if key == "char" then                                          
                return self:_createKnightNode(knightResId, false)
            elseif key == "effect_card_dust" then
                local effect   = EffectNode.new("effect_card_dust") 

                effect:play()
                return effect  
            end
        end,
        function(event)
            if event == "finish" then
                if endCallback ~= nil then
                    endCallback()
                end
            end
        end
    )


    local startPosition =  self:convertToNodeSpace( startJumpWorldPosition )
    local jumpToPosition =  self:convertToNodeSpace( jumpToWorldPosition )
    self._jumpMoving:setPosition(startPosition)
    self._jumpMoving:setScale(startJumpScale)
    transition.fadeIn(self._jumpMoving, {time=0.1})
    transition.scaleTo(self._jumpMoving, {time=0.1, scaleX= jumpToScale, scaleY=jumpToScale})
    local sequence = transition.sequence({
        CCMoveTo:create(0.2, jumpToPosition),
        CCCallFunc:create(
            function() 
                self._jumpMoving:play()
                G_SoundManager:playSound(require("app.const.SoundConst").GameSound.KNIGHT_DOWN)

            end
        )
    })
    
    self._jumpMoving:runAction(sequence)
    self:addChild(self._jumpMoving)



end

function JumpBackCard:playWithKnight(knight,  startJumpWorldPosition, startJumpScale, jumpToWorldPosition, jumpToScale, endCallback)



    self._jumpMoving = EffectMovingNode.new("moving_card_jump", 
        function(key)
            if key == "char" then                                          
                return knight
            elseif key == "effect_card_dust" then
                local effect   = EffectNode.new("effect_card_dust") 

                effect:play()
                return effect  
            end
        end,
        function(event)
            if event == "finish" then
                if endCallback ~= nil then
                    endCallback()
                end
            end
        end
    )


    local startPosition =  self:convertToNodeSpace( startJumpWorldPosition )
    local jumpToPosition =  self:convertToNodeSpace( jumpToWorldPosition )
    self._jumpMoving:setPosition(startPosition)
    self._jumpMoving:setScale(startJumpScale)
    transition.fadeIn(self._jumpMoving, {time=0.1})
    transition.scaleTo(self._jumpMoving, {time=0.1, scaleX= jumpToScale, scaleY=jumpToScale})
    local sequence = transition.sequence({
        CCMoveTo:create(0.2, jumpToPosition),
        CCCallFunc:create(
            function() 
                self._jumpMoving:play()
                G_SoundManager:playSound(require("app.const.SoundConst").GameSound.KNIGHT_DOWN)

            end
        )
    })
    
    self._jumpMoving:runAction(sequence)
    self:addChild(self._jumpMoving)



end


function JumpBackCard:_createKnightNode( res_id,shadow )

    local pic = KnightPic.createKnightNode(res_id, "knight", shadow)    
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



return JumpBackCard


