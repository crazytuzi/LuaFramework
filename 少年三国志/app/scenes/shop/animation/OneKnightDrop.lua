require("app.cfg.knight_info")

local EffectMovingNode = require "app.common.effects.EffectMovingNode"
local EffectNode = require "app.common.effects.EffectNode"
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

local KnightPic = require "app.scenes.common.KnightPic"


local OneKnightDrop = class ("OneKnightDrop", UFCCSModelLayer)

OneKnightDrop.GOOD_KNIGHT_ONE_TIME_MONEY = 2000
OneKnightDrop.GODLY_KNIGHT_ONE_TIME_MONEY = 10000

function OneKnightDrop:ctor( ... )
    self._hasTouched = false
    self._knightPic = nil
    self.super.ctor(self, ...)

end


--type == 1 免费招将
--type ==2, 元宝招将
--type ==3 武将合成
--type ==4 阵营招将
-- @param num 武将合成时可能是一次合成多个武将，故需要num
function OneKnightDrop.show(type, knightInfoId, endCallback, num)
    local node = OneKnightDrop.new()
    node:init(type, knightInfoId, endCallback, num)

    node:setPosition(display.cx, display.cy)
    uf_sceneManager:getCurScene():addChild(node)
   
    node:play()
end

function OneKnightDrop:init(type, knightInfoId, endCallback, num)
    self._type = type
    self._knightInfoId = knightInfoId
    self._endCallback =  endCallback
    self._num = num
    __Log("type = %d", type)

    local info = knight_info.get(knightInfoId)
    self._knightInfo = info
    self:registerTouchEvent(false,true,0)

end

function OneKnightDrop:play(   )
    local effectName = ""

    if self._knightInfo.quality >= 4 then
        effectName = "moving_pickcard1"
    else
        effectName = "moving_pickcard1_bad"
    end
    
    self._node = EffectMovingNode.new(effectName, function(key)
            if key == "bg1" then
                local pic = CCSprite:create(G_Path.getBackground("bg_pick1.png"))

                return pic
            elseif key == "bg2" then
                local pic = CCSprite:create(G_Path.getBackground("xingkong.png"))
                return pic 
            elseif key == "char" then
              

                self._knightPic = KnightPic.createKnightNode(self._knightInfo.res_id, "knight", true)    
                local pic = self._knightPic
                pic:setCascadeOpacityEnabled(true)

                if pic.imageNode then
                    pic.imageNode:setPosition(ccp(pic.imageNode:getPositionX(),pic.imageNode:getPositionY()))
                end
                if self._knightInfo.quality >= 4 then
                    if self._effect_card_back == nil then
                        self._effect_card_back= EffectNode.new("effect_zjbj", function(event) 
                            
                        end) 
                        -- self._effect_card_back:setScale(3.2)
                        self._effect_card_back:setPositionX(0)
                        self._effect_card_back:setPositionY(150)
                        self._effect_card_back:setScale(0.5)
                        self._effect_card_back:play()
                        self._effect_card_back:setVisible(false)
                        pic:addChild(self._effect_card_back, - 4)
                    end
                end
                
                
                return pic
            elseif key == "effect_card_show" then
              
                local effect  
                effect= EffectNode.new("effect_card_show", function(event) 
                    if event == "finish" then
                        if type(self._knightInfo.common_sound) == "string" and #self._knightInfo.common_sound > 3 then
                            G_SoundManager:playSound(self._knightInfo.common_sound)
                        end

                        effect:stop()
                    end
                end) 
                effect:play()
                G_SoundManager:playSound(require("app.const.SoundConst").GameSound.KNIGHT_SHOW)


                return effect
            elseif key == "effect_card_dust" then
                
                local effect  
                effect= EffectNode.new("effect_card_dust", function(event) 
                    if event == "finish" then
                        effect:stop()
                    end
                end) 

                effect:play()
                return effect    
            elseif key == "light_all" then
                local pic = CCSprite:create(G_Path.getShopCardDir() .."square.png")

                 return pic 
            elseif key == "light_circle" then
                local pic = CCSprite:create(G_Path.getShopCardDir() .."circle.png")

                 return pic 
            elseif key == "gongxi_text" then
                G_SoundManager:playSound(require("app.const.SoundConst").GameSound.KNIGHT_SPECIAL)

                --因为缩放锚点问题, 得再包一层node
                local node = display.newNode()
                local layer = require("app.scenes.shop.animation.DropGongXiLayer").create(self._knightInfo, self._num)
                if self._effect_card_back then
                    self._effect_card_back:setVisible(true)
                end
                node:addChild(layer)
                return node      
            elseif key == "info_text" then
                local layer = require("app.scenes.shop.animation.ShopDropInfoTextLayer").create(self._knightInfo, self._type, self._num)
                return layer      
            elseif key == "next_input" then
                if self._type == 3 then
                    self:_createWaiting2()
                    return display.newNode()
                elseif self._type == 4 and G_Me.shopData.dropKnightInfo.zy_recruited_times == 15 then
                    --如果阵营抽将结束了
                    self:_createWaiting2()
                    return display.newNode()
                end

                local layer = UFCCSNormalLayer.new("ui_layout/shop_ShopDropInfoNextInputLayer.json")
                layer.class.__cname = "ShopDropInfoNextInputLayer"
                layer:setCascadeOpacityEnabled(true)
                layer:registerBtnClickEvent("Button_close", function()  self:_end(false) end )
                layer:registerBtnClickEvent("Button_again", function()  self:_end(true) end )
                layer:setClickSwallow(true)
                layer:getLabelByName("Label_priceGold"):createStroke(Colors.strokeBrown,1)
                layer:getLabelByName("Label_priceToken"):createStroke(Colors.strokeBrown,1)
                layer:getLabelByName("Label_ownGold"):createStroke(Colors.strokeBrown,1)
                layer:getLabelByName("Label_ownToken"):createStroke(Colors.strokeBrown,1)
                layer:getLabelByName("Label_curPrice"):createStroke(Colors.strokeBrown,1)

                layer:getLabelByName("Label_ownGold"):setText(G_lang:get("LANG_ONE_KNIGHT_DROP_OWN",{num=G_GlobalFunc.ConvertNumToCharacter(G_Me.userData.gold)}))

                if self._type == 1 then
                    layer:getPanelByName("Panel_useGold"):setVisible(false)
                    layer:getPanelByName("Panel_useToken"):setVisible(true)
                    local tokenImg = layer:getImageViewByName("ImageView_priceTokenTag")
                    tokenImg:loadTexture("icon_liangjiangling.png",UI_TEX_TYPE_PLIST)
                    local tokenCount = G_Me.bagData:getGoodKnightTokenCount()
                    layer:getLabelByName("Label_ownToken"):setText(G_lang:get("LANG_ONE_KNIGHT_DROP_OWN",{num=tokenCount}))
                    if tokenCount == 0 then 
                        layer:getLabelByName("Label_priceToken"):setColor(Colors.darkColors.TIPS_01)
                        layer:getLabelByName("Label_priceToken"):setText(  layer:getLabelByName("Label_priceToken"):getStringValue() )
                    end
                    ---todo!!, 设置需要消耗的数量
                elseif self._type == 4 then
                    layer:getPanelByName("Panel_useGold"):setVisible(true)
                    layer:getPanelByName("Panel_useToken"):setVisible(false)
                    local price = G_Me.shopData:getZhenYingDropPrice()
                    if price == -1 then
                        --表示已经结束
                    else
                        layer:getLabelByName("Label_priceGold"):setText(tostring(price))
                    end
                else
                    ---todo!!!, 设置需要消耗的数量
                    local tokenCount = G_Me.bagData:getGodlyKnightTokenCount()
                    layer:getLabelByName("Label_ownToken"):setText(G_lang:get("LANG_ONE_KNIGHT_DROP_OWN",{num=tokenCount}))
                    layer:getPanelByName("Panel_useToken"):setVisible(tokenCount > 0)
                    layer:getPanelByName("Panel_useGold"):setVisible(tokenCount <= 0)
                    local BagConst = require("app.const.BagConst")
                    local isDiscount,discount = G_Me.activityData.custom:isGodlyDropDiscount()
                    --是否活动中
                    local price = BagConst.DROP_KNIGHT_GOLD_CONSUMPTION_PER_TIME
                    if isDiscount then
                        price = math.ceil(price * discount / 1000)
                        layer:showWidgetByName("Label_huaxian",true)
                        layer:showWidgetByName("Label_curPrice",true)
                        layer:getLabelByName("Label_priceGold"):setText(price)
                        layer:getLabelByName("Label_curPrice"):setText(BagConst.DROP_KNIGHT_GOLD_CONSUMPTION_PER_TIME)
                    else
                        layer:showWidgetByName("Label_huaxian",false)
                        layer:showWidgetByName("Label_curPrice",false)
                    end 
                    if G_Me.userData.gold < price then
                        local label = layer:getLabelByName("Label_priceGold")
                        label:setColor(Colors.darkColors.TIPS_01)
                        label:setText(label:getStringValue())
                    end

                end
                self._inputLayer = layer
                return layer      
            
            else 
                
                return display.newNode()
            end
        end,
        function (event) 
            if event=="wait"  then
                self._node:pause()               

                if self._hasTouched then 
                    if self.__EFFECT_FINISH_CALLBACK__ then 
                        self.__EFFECT_FINISH_CALLBACK__()
                        self._node:resume()
                    else
                        self:_createWaiting()
                    end
                else
                    self:_createWaiting()
                end

             elseif event == "down" then
                if self._effect_card_back then
                    self._effect_card_back:setVisible(false)
                end
                G_SoundManager:playSound(require("app.const.SoundConst").GameSound.KNIGHT_DOWN)

            elseif event == "finish" then
                if self._type ~= 3 and self._inputLayer then
                    local worldY = 60

                    local endPosition = self._node:convertToNodeSpace(  ccp(0,worldY)  )
                    transition.moveTo(self._inputLayer, {time=0.2, y=endPosition.y})
                end
                self._smovingEffect = EffectSingleMoving.run(self._knightPic, "smoving_idle", nil, {})
            elseif event == "plate" then
                --盘子出现
                -- local config = decodeJsonFile(G_Path.getKnightPicConfig(self._knightInfo.res_id))
                -- local sp = ImageView:create()
                -- sp:setName(name or "default_image_name")
                -- local plate = CCSprite:create(G_Path.getDropKnightShadow(self._knightInfo.quality))
                -- plate:setPosition(ccp(tonumber(config.shadow_x - config.x),  tonumber(config.shadow_y - config.y)))
                -- sp:addNode(plate, -3)   
                -- sp:setPosition(ccp(tonumber(config.x), tonumber(config.y)-140)) 
                -- self._node:addChild(sp)
            end

        end
    )

    
    self:addChild(self._node)
    self._node:play()
end

function OneKnightDrop:onTouchEnd( xpos, ypos )
    if self._type == 3 or (self._type == 4 and G_Me.shopData.dropKnightInfo.zy_recruited_times==15)then
        if self._continueImage2 ~= nil  then
            self._continueImage2:removeFromParentAndCleanup(true)
            self._continueImage2 = nil
            self:_end()
            return
        end
    end



    if self.__EFFECT_FINISH_CALLBACK__ and self._hasTouched then 
        return 
    end
    
    self._hasTouched = true

    if self._continueImage ~= nil  then
        self._continueImage:removeFromParentAndCleanup(true)
        self._continueImage = nil
        self._node:resume()

        if self.__EFFECT_FINISH_CALLBACK__ then 
            self.__EFFECT_FINISH_CALLBACK__()
        end
    end





    return true
end

function OneKnightDrop:_createWaiting(  )
    self._continueImage = ImageView:create()
    self._continueImage:loadTexture( G_Path.getTextPath("dianjijixu.png")) 
    self._continueImage:setPosition(ccp(0, -350))
    self:addChild( self._continueImage)
    EffectSingleMoving.run(self._continueImage, "smoving_wait", nil , {position = true} )    
end


function OneKnightDrop:_createWaiting2(  )
    self._continueImage2 = ImageView:create()
    self._continueImage2:loadTexture( G_Path.getTextPath("dianjijixu.png")) 
    self._continueImage2:setPosition(ccp(0, -350))
    self:addChild( self._continueImage2)
    EffectSingleMoving.run(self._continueImage2, "smoving_wait", nil , {position = true} )    
end


function OneKnightDrop:_end(again)
    if self._endCallback ~= nil then
       self._endCallback(again, self._type)
    end
    self:removeFromParentAndCleanup(true)

end

return OneKnightDrop


