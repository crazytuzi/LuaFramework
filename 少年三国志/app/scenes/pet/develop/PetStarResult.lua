local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")
local EffectNode = require "app.common.effects.EffectNode"
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local PetAppearEffect = require("app.scenes.hero.PetAppearEffect")
local PetStarResult = class("PetStarResult", UFCCSModelLayer)
require("app.cfg.pet_info")

function PetStarResult.create(pet, container, pet_star, ...)
    local tLayer = PetStarResult.new("ui_layout/petbag_Star_Result.json", Colors.modelColor, pet,container,pet_star, ...)
    uf_sceneManager:getCurScene():addChild(tLayer,10)
    return tLayer
end

function PetStarResult:ctor(json, param, pet,container,pet_star,...)
    self.super.ctor(self, json, param, ...)
    self._pet = pet
    self._container = container
    self._pet_star = pet_star
    self:adapterWithScreen()
    self._clickToClose = false
end

function PetStarResult:onLayerEnter( ... )
    self:initView()
    self:enterMove()
end

function PetStarResult:enterMove()
    self:showWidgetByName("Label_new_attack", false)
    self:showWidgetByName("Label_new_hp", false)
    self:showWidgetByName("Label_new_def_p", false)
    self:showWidgetByName("Label_new_def_m", false)
    self:showWidgetByName("Label_new_harm_add", false)
    self:showWidgetByName("Image_arrow_harm_add", false)
    self:showWidgetByName("Image_arrow_attack", false)
    self:showWidgetByName("Image_arrow_hp", false)
    self:showWidgetByName("Image_arrow_def_p", false)
    self:showWidgetByName("Image_arrow_def_m", false)

    self:showWidgetByName("Panel_border", false)

    GlobalFunc.flyDown({self:getWidgetByName("Image_title_back")}, 0.3, 0, 3, function ( ... )
        self:showWidgetByName("Panel_border", true)
        GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_attri1"), 
                    self:getWidgetByName("Panel_attri2"),
                    self:getWidgetByName("Panel_attri3"), 
                    self:getWidgetByName("Panel_attri4"),
                    self:getWidgetByName("Panel_attri5")}, true, 0.3, 2, 50, function ( ... )

                        self:showWidgetByName("Label_new_attack", true)

                        GlobalFunc.flyDown({self:getWidgetByName("Label_new_attack"),
                            self:getWidgetByName("Label_new_hp"),
                            self:getWidgetByName("Label_new_def_p"),
                            self:getWidgetByName("Label_new_def_m"),
                            self:getWidgetByName("Label_new_harm_add")}, 0.2, 0.1, 3, function ( ... )
                                self:showWidgetByName("Image_arrow_attack", true)
                                self:showWidgetByName("Image_arrow_hp", true)
                                self:showWidgetByName("Image_arrow_def_p", true)
                                self:showWidgetByName("Image_arrow_def_m", true)
                                self:showWidgetByName("Image_arrow_harm_add", true)

                                self:showWidgetByName("Image_click_continue", true)
                                EffectSingleMoving.run(self:getWidgetByName("Image_click_continue"), "smoving_wait", nil , {position = true} )

                                self._clickToClose = true
                                self:setClickClose(true)
                                self:closeAtReturn(true)

                            end)                        
                    end)

        GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_name")}, false, 0.3, 2, 50)
    end)   
end

function PetStarResult:initView()
    local effect = EffectNode.new("effect_jingjie_light_fg")
    effect:play()
    self:getPanelByName("Panel_effect"):addNode(effect)


    -- 背景光
    if not self._bgEffect then
        self._bgEffect = EffectNode.new("effect_zjbj")  -- effect_zjbj
        local tParent = self:getPanelByName("Panel_effect")
        if tParent then
            tParent:addNode(self._bgEffect)
            self._bgEffect:play()
            self._bgEffect:setPositionY(self._bgEffect:getPositionY() + 180)
            self._bgEffect:setScale(0.5)
        end
    end


                
    local info = pet_info.get(self._pet.base_id - 1)
    local info_new = pet_info.get(self._pet.base_id)
    --战宠形象
    if not self._petImg then
        self._petNode = display.newNode()
        local petPath = G_Path.getPetReadyEffect(info.ready_id)
        self._petImg = EffectNode.new(petPath)
        self._petNode:addChild(self._petImg)
        self._petImg:setPositionXY(display.width/2,display.height * 0.4)
        self._petImg:play()
        self:getImageViewByName("Image_title"):setZOrder(1)
        self._petNode:setZOrder(0)
        self:addChild(self._petNode)
    end


    self:getLabelByName("Label_old_attack"):setText("+" .. tostring(info.develop_attack) )
    self:getLabelByName("Label_new_attack"):setText("+" .. tostring(info_new.develop_attack) )

    self:getLabelByName("Label_old_hp"):setText( "+" .. tostring(info.develop_hp) )
    self:getLabelByName("Label_new_hp"):setText( "+" .. tostring(info_new.develop_hp) )

    self:getLabelByName("Label_old_def_p"):setText( "+" .. tostring(info.develop_physical_defence) )
    self:getLabelByName("Label_new_def_p"):setText( "+" .. tostring(info_new.develop_physical_defence) )

    self:getLabelByName("Label_old_def_m"):setText( "+" .. tostring(info.develop_magical_defence) )
    self:getLabelByName("Label_new_def_m"):setText( "+" .. tostring(info_new.develop_magical_defence) )

    self:getLabelByName("Label_old_harm_add"):setText( "+" .. tostring(info.harm_add/10 .. "%") )
    self:getLabelByName("Label_new_harm_add"):setText( "+" .. tostring(info_new.harm_add/10 .. "%") )

    EffectSingleMoving.run(self:getWidgetByName("Image_click_continue"), "smoving_wait", nil , {position = true} )


    -- 显示名字
    local nameLabel = self:getLabelByName("Label_old_pet")
    nameLabel:setColor(Colors.getColor(info.quality))
    nameLabel:setText(tostring(info.star) .. "星 " ..info.name)
    nameLabel:createStroke(Colors.strokeBrown,2)

    local nameLabelNew = self:getLabelByName("Label_new_pet")
    nameLabelNew:setColor(Colors.getColor(info_new.quality))
    nameLabelNew:setText( tostring(info_new.star) .. "星 " ..info_new.name)
    nameLabelNew:createStroke(Colors.strokeBrown,2)

    self:arrowAnime()
end

function PetStarResult:arrowAnime(  )
    local trainingArrowAnimation = function ( arrowName, followLabel, showArrow)
        if not arrowName  then
            return 
        end
        local arrow = self:getImageViewByName(arrowName)
        if not arrow then 
            return 
        end

        local arrowX, arrowY = arrow:getPosition()
        local arrowSize = arrow:getSize()
        if followLabel then 
            local followLabelCtrl = self:getWidgetByName(followLabel)
            if followLabelCtrl then 
                local posx, posy = followLabelCtrl:getPosition()
                --local anchorPt = followLabelCtrl:getAnchorPoint()
                --local followLabelSize = followLabelCtrl:getSize()
                --arrowX = posx + (1 - anchorPt.x)*followLabelSize.width + arrowSize.width/2
                arrowY = posy
            end         
        end

        showArrow = showArrow or false
        arrow:stopAllActions()
        arrow:setVisible(showArrow)
        if showArrow then 
            
            arrow:setVisible(true)
            arrow:setOpacity(255)
        --arrow:loadTexture(G_Path.getGrowupIcon(isGrowup))
            local moveDistUp = 10
            local startPosy = (arrowY - moveDistUp/2)

            local arr = CCArray:create()
            arr:addObject(CCResetPosition:create(arrow, ccp(arrowX, startPosy)))
            arr:addObject(CCResetOpacity:create(arrow, 255))
            local moveby = CCMoveBy:create(0.8, ccp(0, moveDistUp))
            arr:addObject(CCEaseIn:create(moveby, 0.3))
            arr:addObject(CCFadeOut:create(0.2))
            
            arrow:runAction(CCRepeatForever:create(CCSequence:create(arr)))
        end
    end

    trainingArrowAnimation("Image_arrow_hp", "Label_new_hp", true)
    trainingArrowAnimation("Image_arrow_attack", "Label_new_attack", true)
    trainingArrowAnimation("Image_arrow_def_m", "Label_new_def_p", true)
    trainingArrowAnimation("Image_arrow_def_p", "Label_new_def_m", true)
    trainingArrowAnimation("Image_arrow_harm_add", "Label_new_harm_add", true)
end


function PetStarResult:onLayerExit( ... )
    -- body
end

function PetStarResult:onClickClose( ... )
    if not self._clickToClose then 
        return 
    end
    -- self:getPanelByName("Root"):runAction(
    --     CCSequence:createWithTwoActions(CCFadeOut:create(0.2), CCCallFunc:create(function( ... )  

    --         -- 播放增加一颗星的特效
    --         self._container:updateStar()
    --         -- 调用文字飞出特效
    --         self._pet_star:_starUpAnime()
    --         -- 宠物跳出
    --         -- local temp_container = self._container
    --         -- local ani = PetAppearEffect.new(self._pet.base_id, function() 
    --         --     temp_container:getEffectNode():removeAllNodes()
    --         -- end)
    --         -- ani:play()
    --         -- self._container:getEffectNode():addNode(ani)
    --         -- ani:setPositionXY(0,25)
    --         self:close() 
    --         end)
    --     )
    -- )
    -- 播放增加一颗星的特效
    self._container:updateStar()
    -- 调用文字飞出特效
    self._pet_star:_starUpAnime()
    self:close() 
    return true
end

return PetStarResult
