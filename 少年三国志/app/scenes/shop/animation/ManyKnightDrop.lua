require("app.cfg.knight_info")

local EffectMovingNode = require "app.common.effects.EffectMovingNode"
local EffectNode = require "app.common.effects.EffectNode"
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

local KnightPic = require "app.scenes.common.KnightPic"

local ShopDropKnightCell = require("app.scenes.shop.animation.cell.ShopDropKnightCell")


local ManyKnightDrop = class ("ManyKnightDrop", UFCCSModelLayer)



function ManyKnightDrop.show(buyMoneyNum, knights, endCallback)
    local node = ManyKnightDrop.new()
    uf_sceneManager:getCurScene():addChild(node)
    node:init(buyMoneyNum, knights, endCallback)
    node:play()
end

function ManyKnightDrop:ctor()
    self._knights = nil
    self._waiting = false
    self._endCallback = nil
    self._playLines = 0
    self._waitCallback = nil



end

function ManyKnightDrop:init(buyMoneyNum, knights, endCallback)
    self._knights = knights
    self._endCallback = endCallback


    local bgBlack = CCSprite:create(  G_Path.getBackground("bg_pick3.png") )
    bgBlack:setScale(2)
    bgBlack:setPosition(ccp(display.cx, display.cy))
    self:addChild(bgBlack)


    --三层
    --1. 放侠客 knightsContainer
    --2. 放全屏动画 fullContainer
    --3. 放waiting waitingContainer

    self._knightsContainer = display.newNode()
    self._fullContainer = display.newNode()
    self._waitingContainer = display.newNode()

    self:addChild(self._knightsContainer)
    self:addChild(self._fullContainer)
    self:addChild(self._waitingContainer)

    -- 购买银两总数说明
    local tipsBg = CCScale9Sprite:create("ui/tipsinfo/bg_erjibiaoti.png")
    tipsBg:setPreferredSize(CCSize(350, 50))
    tipsBg:setPositionXY(display.cx, display.cy + 320)

    local buyMoneyLabel = G_GlobalFunc.createGameLabel( 
                                        G_lang:get("LANG_DROP_BUY_MONEY_TIPS", {num = buyMoneyNum}),
                                        28,
                                        Colors.darkColors.DESCRIPTION,
                                        Colors.strokeBrown
                                        )
    buyMoneyLabel:setPositionXY(175, 25)

    tipsBg:addChild(buyMoneyLabel)

    self._fullContainer:addChild(tipsBg)

    self:registerTouchEvent(false,true,0)

end



function ManyKnightDrop:_end(   )
    self:removeFromParentAndCleanup(true)

    if self._effect  then
        self._effect:stop()
        self._effect  = nil
    end

    if self._endCallback ~= nil then
        self._endCallback()
    end
end

function ManyKnightDrop:play(  )


    self._listIndex = 1

    self:_playNext()
end


function ManyKnightDrop:_playNext()
    if self._listIndex >  #self._knights then
        --wait
        self:_createWaiting(handler(self, self._end))   
        return
    end

    G_SoundManager:playSound(require("app.const.SoundConst").GameSound.KNIGHT_SHOW)

    local cell =ShopDropKnightCell.new()
    cell:updateData(self._knights[self._listIndex])
    -- cell:setScale(math.pow(0.85,self._playLines))

    local lineHeight = 200
    local cellGap = 150


    local mx = cellGap*((self._listIndex-1) % 4) + 50
    local my = -self._playLines * lineHeight + display.cy + 100 


    -- if self._playLines == 2 then
    --     mx =  (cellGap+100)*((self._listIndex-1) % 4) + 150
    -- end


    cell:setPosition(ccp(mx, my))

    self._knightsContainer:addChild(cell)


    local info = knight_info.get(self._knights[self._listIndex])

    cell:playAppear(function(showFullScreen)  
        if showFullScreen then
            --特殊武将会展示全屏动画


            self._node2 = EffectMovingNode.new("moving_pickcard_many_s2", 
                 function(key) 

                     if key == "char" then
                       
                        self._charNode =  self:_createKnightNode(info)
                        return self._charNode
                     elseif key == "light_all" then
                         local pic = CCSprite:create(G_Path.getShopCardDir() .."square.png")

                         return pic 
                     elseif key == "gongxi_text" then
                        G_SoundManager:playSound(require("app.const.SoundConst").GameSound.KNIGHT_SPECIAL)

                         --因为缩放锚点问题, 得再包一层node
                        local node = display.newNode()
                        local layer = require("app.scenes.shop.animation.DropGongXiLayer").create(info)
                        node:addChild(layer)
                        return node          
                     elseif key == "bg2" then
                         local pic = CCSprite:create(G_Path.getBackground("xingkong.png"))

                         return pic                 
                     end

                 end, 
                 function(event)
                     if event == "finish" then
                        self._node2:stop()
                        self._node2:removeFromParentAndCleanup(true)
                        self._node2 = nil   


                     elseif event=="wait"  then
                            cell:setVisible(false)
                            self._node2:pause()
                            local callback = function() 
                                self._node2:resume()

                                -- self:_wantPlayNext()
                                --这个时候需要把全屏的侠客 做一个缩小移动, 然后做一个跳跃的动作, 跳到KnightsContainer上
                                --比较方便的做法是 再重新创建一个临时侠客做这个跳跃, 


                                self._node3 = EffectMovingNode.new("moving_pickcard_many_s3", 
                                    function(key)
                                        print("180---key = " .. key)
                                        if key == "char" then                                          
                                            return self:_createKnightNode(info)
                                        elseif key == "effect_card_dust" then
                                            local effect   = EffectNode.new("effect_card_dust") 
                                            effect:play()
                                            return effect    
                                        end
                                    end,
                                    function (event)
                                        if event == "finish" then
                                            cell:setVisible(true)
                                            self._node3:stop()
                                            self._node3:removeFromParentAndCleanup(true)
                                            self._node3 = nil
                                            self:_wantPlayNext()
                                        end
                                    end
                                )


                                self._fullContainer:addChild(self._node3)

                                local charWorldPosition = self._charNode:convertToWorldSpace(ccp(0, 0))
                                local charInFullPosition = self._fullContainer:convertToNodeSpace(  charWorldPosition  )
                                self._node3:setPosition(charInFullPosition)

                                local cellKnightWorldPosition = cell:getKnightWorldPosition()
                                local cellKnightInFullPosition  = self._fullContainer:convertToNodeSpace(  cellKnightWorldPosition  )

                                local scale = cell:getKnightScale()
                                transition.scaleTo(self._node3, {time=0.1, scaleX= scale, scaleY=scale})
                                local sequence = transition.sequence({
                                    CCMoveTo:create(0.2, cellKnightWorldPosition),
                                    CCCallFunc:create(
                                        function() 
                                            self._node3:play()
                                            G_SoundManager:playSound(require("app.const.SoundConst").GameSound.KNIGHT_DOWN)

                                        end
                                    )
                                })
                                
                                self._node3:runAction(sequence)
                            end
                            self:_createWaiting(callback)       
                     end
                 end

             )
             self._node2:setPosition(ccp(display.cx, display.cy))
             self._fullContainer:addChild(self._node2)
             self._node2:play()   



        else 
            self:_wantPlayNext()
        end
        
    end)
end

function ManyKnightDrop:_wantPlayNext(  )
    if self._listIndex > 1 and self._listIndex % 4 ==0 then
        self._playLines = self._playLines + 1
    end

    self._listIndex = self._listIndex + 1

    self:_playNext()
end

function ManyKnightDrop:_createWaiting( callback )
    self._img = ImageView:create()
    self._img:loadTexture(  G_Path.getTextPath("dianjijixu.png"))
    self._img:setPositionY(display.cy -380)
    self._img:setPositionX(display.cx)

    self._waitingContainer:addChild(self._img)
    self._imgEffect = EffectSingleMoving.run(self._img, "smoving_wait" )
    self._waiting = true
    self._waitCallback = callback
end

function ManyKnightDrop:_clearWaiting(  )
    if self._img  ~= nil then
        self._imgEffect:stop()
        self._img:removeFromParentAndCleanup(true)
        self._img = nil 
        self._imgEffect = nil

    end
    self._waiting = false
end

function ManyKnightDrop:_createKnightNode( info )

    local pic = KnightPic.createKnightNode(info.res_id, "knight", true)    
    pic:setCascadeOpacityEnabled(true)


    if info.quality >= 4 then
        local effect  
        effect= EffectNode.new("effect_zjbj", function(event) 
            
        end) 
        effect:setScale(0.5)
        effect:setPositionX(0)
        effect:setPositionY(150)
        effect:play()
        pic:addChild(effect, - 4)
    end

    return pic
    
end

function ManyKnightDrop:onTouchEnd( xpos, ypos )
    if self._waiting  then
        self:_clearWaiting()
        if self._waitCallback ~= nil then
            self._waitCallback()
            self._waitCallback = nil
        end
        

    end

    --return true
end

return ManyKnightDrop