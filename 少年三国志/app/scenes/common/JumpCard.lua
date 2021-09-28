require("app.cfg.knight_info")
require("app.cfg.treasure_info")

local EffectMovingNode = require "app.common.effects.EffectMovingNode"
local EffectNode = require "app.common.effects.EffectNode"
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

local KnightPic = require "app.scenes.common.KnightPic"


local JumpCard = class ("JumpCard", UFCCSModelLayer)

local JUMP_KNIGHT   = 1
local JUMP_TREASURE = 2

local JUMP_IN       = 1 --跳出来
local JUMP_BACK     = 2 --跳回去

function JumpCard:ctor( ... )
    self.super.ctor(self, ...)
end


--startWorldPosition 冒光点的位置
--jumpToWorldPosition 结束动画后, 侠客跳到哪里
--jumpToScale 结束动画后, 侠客的缩放度
--waitCallback 暂停动画,等待外部调用resume()

function JumpCard.create(objId, startWorldPosition, jumpToWorldPosition, jumpToScale, waitCallback, endCallback, newResId )
    local node = JumpCard.new()
    node:init(JUMP_KNIGHT, objId, startWorldPosition, jumpToWorldPosition, jumpToScale, waitCallback, endCallback, newResId)
    return node
end

function JumpCard.createWithTreasure(objId, startWorldPosition, jumpToWorldPosition, jumpToScale, waitCallback, endCallback, newResId )
    local node = JumpCard.new()
    node:init(JUMP_TREASURE, objId, startWorldPosition, jumpToWorldPosition, jumpToScale, waitCallback, endCallback, newResId)
    return node
end

function JumpCard:init(jumpType, objId, startWorldPosition, jumpToWorldPosition, jumpToScale, waitCallback, endCallback, newResId)
    self._jumpType = jumpType
    self._objId = objId
    self._startWorldPosition = startWorldPosition

    self._jumpToWorldPosition = jumpToWorldPosition
    self._jumpToScale = jumpToScale
    self._waitCallback = waitCallback
    self._endCallback = endCallback

    self._fullScreenMoving = nil
    self._jumpMoving = nil

    self._newResId = newResId or 0

    self:setPosition(display.cx, display.cy)



    local startPosition = self:convertToNodeSpace(  startWorldPosition  )
    local effect 


    effect = EffectNode.new("effect_circle_light", 
        function(event)

            if event == "finish" then
                effect:removeFromParentAndCleanup(true)
                self:_startFullScreen()
            end
        end
    )
    self:addChild(effect)
    effect:setPosition(startPosition)
    effect:play()



end


function JumpCard:_startFullScreen()
    self._fullScreenMoving = EffectMovingNode.new("moving_card_fullscreen", 
        function(key)
            if key == "char" then                                          
                self._fullCharNode =  self:_createPicNode(true, JUMP_IN)
                if self._effect_card_back == nil then
                    self._effect_card_back= EffectNode.new("effect_zjbj", function(event) 
                        
                    end) 
                    self._effect_card_back:setPositionX(0)
                    self._effect_card_back:setPositionY(150)
                    self._effect_card_back:setScale(0.7)
                    self._effect_card_back:play()
                    self._fullCharNode:addChild(self._effect_card_back, - 4)
                end
                return self._fullCharNode
            elseif key == "light_all" then
                local pic = CCSprite:create(G_Path.getShopCardDir() .."square.png")

                return pic  
            elseif key == "light" then
                local pic = CCSprite:create("ui/yangcheng/light_jinjiechenggong.png")

                return pic  
            elseif key == "effect_jingjie_light_fg" then
                local effect = EffectNode.new("effect_jingjie_light_fg")
             
                effect:play()
                return effect
            elseif key == "bg2" then
                local pic = CCSprite:create(G_Path.getBackground("bg_common.png"))

                return pic
            end
        end,
        function (event)
            if event == "finish" then
                --播放结束,开始播放跳跃啦
                self._fullScreenMoving:removeFromParentAndCleanup(true)
                self._fullScreenMoving = nil
            elseif event == "wait" then

                if self._waitCallback then
                    G_SoundManager:playSound(require("app.const.SoundConst").GameSound.KNIGHT_SPECIAL)

                    self._fullScreenMoving:pause()
                    self._waitCallback()
                    self._waitCallback = nil
                else 
                    self:_startJump()
               end
            end
        end
    )
    self._fullScreenMoving:play()
    self:addChild(self._fullScreenMoving )
end

function JumpCard:_startJump()
    if self._fullCharNode then
        self._fullCharNode:setVisible(false)
    end

    if self._fullScreenMoving then
        self._fullScreenMoving:resume()
    end

    self._jumpMoving = EffectMovingNode.new("moving_card_jump", 
        function(key)
            if key == "char" then                                          
                local node = self:_createPicNode(false, JUMP_BACK)
                return node
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

    local jumpToPosition =  self:convertToNodeSpace(  self._jumpToWorldPosition  )

    --这个地方有个很恶心的地方, 外面通过createKnightNode创建的侠客, 锚点在脚中心(读配置),
    --但是动画里画的跳跃动画里的卡牌, 锚点距离脚中心有一点偏移量, 也就是意味着这个地方我们需要重新校准一下位置,我日
    --
    self._jumpMoving:setScale(0.8)
    transition.scaleTo(self._jumpMoving, {time=0.1, scaleX= self._jumpToScale, scaleY=self._jumpToScale})
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

function JumpCard:resume(  )
    if self._fullScreenMoving then
        self:_startJump()
    end
end



function JumpCard:_createPicNode(shadow, jumpMode)
    local node = nil
    if self._jumpType == JUMP_KNIGHT then
        local info = knight_info.get(self._objId)
        node = KnightPic.createKnightNode(self._newResId > 0 and self._newResId or info.res_id, "knight", shadow)
    elseif self._jumpType == JUMP_TREASURE then
        local info = treasure_info.get(self._objId)
        picPath = G_Path.getTreasurePic(info.res_id)
        
        local sprite = ImageView:create()
        sprite:loadTexture(picPath)

        if jumpMode == JUMP_IN then
            -- 这个特效本来是为武将量身定做的，而武将是以脚底为基准点的，所以特效中的图片位置较低
            -- 因此这里强行把宝物的图片拉高
            sprite:setAnchorPoint(ccp(0.5, -0.25))
        end

        node = display.newNode()
        node:addChild(sprite)
    end


    -- if info.quality >= 4 then
    --     local effect  
    --     effect= EffectNode.new("effect_card_back", function(event) 
            
    --     end) 
    --     effect:setScale(3.2)
    --     effect:play()
    --     pic:addChild(effect, - 4)
    -- end

    node:setCascadeOpacityEnabled(true)
    return node
end


return JumpCard


