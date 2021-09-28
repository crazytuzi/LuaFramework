--HeroQualityResult.lua


local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local EffectNode = require "app.common.effects.EffectNode"

local HeroQualityResult = class("HeroQualityResult", UFCCSModelLayer)

local KnightPic = require "app.scenes.common.KnightPic"


function HeroQualityResult:ctor( ... )
    self._callback = nil
    self._clickToClose = false

    self.super.ctor(self, ...)

    self:showWidgetByName("Image_click_continue", false)

    self:enableLabelStroke("Label_unlock_text", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_unlock_desc", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_old_knight", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_new_knight", Colors.strokeBrown, 1 )
    -- self:enableLabelStroke("Label_old_attack", Colors.strokeBrown, 1 )
    -- self:enableLabelStroke("Label_old_hp", Colors.strokeBrown, 1 )
    -- self:enableLabelStroke("Label_old_def_p", Colors.strokeBrown, 1 )
    -- self:enableLabelStroke("Label_old_def_m", Colors.strokeBrown, 1 )
    -- self:enableLabelStroke("Label_new_attack", Colors.strokeBrown, 1 )
    -- self:enableLabelStroke("Label_new_hp", Colors.strokeBrown, 1 )
    -- self:enableLabelStroke("Label_new_def_p", Colors.strokeBrown, 1 )
    -- self:enableLabelStroke("Label_new_def_m", Colors.strokeBrown, 1 )

    local createStoke = function ( name )
        local label = self:getLabelByName(name)
        if label then 
            label:createStroke(Colors.strokeBrown, 1)
        end
    end
    -- createStoke("Label_attri_attack")
    -- createStoke("Label_attri_hp")
    -- createStoke("Label_attri_def_p")
    -- createStoke("Label_attri_def_m")






    self:adapterWithScreen()
    self:registerTouchEvent(false,true,0)
end

function HeroQualityResult:onLayerEnter( ... )

    local soundConst = require("app.const.SoundConst")
    G_SoundManager:playSound(soundConst.GameSound.KNIGHT_SPECIAL)

    self:showWidgetByName("Label_new_attack", false)
    self:showWidgetByName("Label_new_hp", false)
    self:showWidgetByName("Label_new_def_p", false)
    self:showWidgetByName("Label_new_def_m", false)
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
                    self:getWidgetByName("Panel_attri4")}, true, 0.3, 2, 50, function ( ... )

                        self:showWidgetByName("Label_new_attack", true)

                        GlobalFunc.flyDown({self:getWidgetByName("Label_new_attack"),
                            self:getWidgetByName("Label_new_hp"),
                            self:getWidgetByName("Label_new_def_p"),
                            self:getWidgetByName("Label_new_def_m")}, 0.2, 0.1, 3, function ( ... )
                                self:showWidgetByName("Image_arrow_attack", true)
                                self:showWidgetByName("Image_arrow_hp", true)
                                self:showWidgetByName("Image_arrow_def_p", true)
                                self:showWidgetByName("Image_arrow_def_m", true)

                                self:showWidgetByName("Image_click_continue", true)
                                EffectSingleMoving.run(self:getWidgetByName("Image_click_continue"), "smoving_wait", nil , {position = true} )

                                self._clickToClose = true
                                self:setClickClose(true)
                            end)                        
                    end)

        GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_name")}, false, 0.3, 2, 50)
    end)    
end

function HeroQualityResult:initWithBaseId(baseId1, baseId2, func )
    baseId1 = baseId1 or 0
    baseId2 = baseId2 or 0
    local level = 1
    self._callback = func




    local newPassiveSkill = {}

    local knightName = ""

    local knightInfo = nil

    knightInfo = knight_info.get(baseId2)
    knightName = knightInfo.name



    if baseId1 > 0 then 
        knightInfo = knight_info.get(baseId1)
        if knightInfo then 
            self:showTextWithLabel("Label_old_hp", ""..(knightInfo.base_hp + (level - 1)*knightInfo.develop_hp))
            self:showTextWithLabel("Label_old_attack", ""..(G_Me.bagData.knightsData:calcAttackByBaseId(knightInfo.id, level)))
            self:showTextWithLabel("Label_old_def_p", ""..(knightInfo.base_physical_defence + (level - 1)*knightInfo.develop_physical_defence))
            self:showTextWithLabel("Label_old_def_m", ""..(knightInfo.base_magical_defence + (level - 1)*knightInfo.develop_magical_defence))
            
            local label = self:getLabelByName("Label_old_knight")
            if label then 
                label:setColor(Colors.qualityColors[knightInfo.quality])
                if knightInfo.advanced_level > 0 then 
                    label:setText(""..knightName.." +"..knightInfo.advanced_level) 
                else
                    label:setText(knightName)
                end
                -- label:setColor(Colors.getColor(knightInfo.quality))
            end
            
        else
            self:showTextWithLabel("Label_old_hp", "")
            self:showTextWithLabel("Label_old_attack", "")
            self:showTextWithLabel("Label_old_def_p", "")
            self:showTextWithLabel("Label_old_def_m", "")
            self:showTextWithLabel("Label_old_knight", "")
        end
    end

    if baseId2 > 0 then 
        knightInfo = knight_info.get(baseId2)
        if knightInfo then 
            self:showTextWithLabel("Label_new_hp", ""..(knightInfo.base_hp + (level - 1)*knightInfo.develop_hp))
            self:showTextWithLabel("Label_new_attack", ""..(G_Me.bagData.knightsData:calcAttackByBaseId(knightInfo.id, level)))
            self:showTextWithLabel("Label_new_def_p", ""..(knightInfo.base_physical_defence + (level - 1)*knightInfo.develop_physical_defence))
            self:showTextWithLabel("Label_new_def_m", ""..(knightInfo.base_magical_defence + (level - 1)*knightInfo.develop_magical_defence))
            local label = self:getLabelByName("Label_new_knight")
            if label then 
                label:setColor(Colors.qualityColors[knightInfo.quality])
                if knightInfo.advanced_level > 0 then 
                    label:setText(""..knightName.." +"..knightInfo.advanced_level) 
                else
                    label:setText(knightName)
                end
                -- label:setColor(Colors.getColor(knightInfo.quality))
            end




            local knight = KnightPic.createKnightNode(knightInfo.res_id, "knight", true)    
            knight:setScale(0.8)
            self:getPanelByName("Panel_knight"):addNode(knight)


        else
            self:showTextWithLabel("Label_new_hp", "")
            self:showTextWithLabel("Label_new_attack", "")
            self:showTextWithLabel("Label_new_def_p", "")
            self:showTextWithLabel("Label_new_def_m", "")
            self:showTextWithLabel("Label_new_knight", "")
        end
    end

    local effect = EffectNode.new("effect_jingjie_light_fg")
    
    effect:play()
    self:getPanelByName("Panel_effect"):addNode(effect)

    
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
                local anchorPt = followLabelCtrl:getAnchorPoint()
                local followLabelSize = followLabelCtrl:getSize()
                arrowX = posx + (1 - anchorPt.x)*followLabelSize.width + arrowSize.width/2
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

    trainingArrowAnimation("Image_arrow_hp", "Label_new_hp", knightInfo ~= nil)
    trainingArrowAnimation("Image_arrow_attack", "Label_new_attack", knightInfo ~= nil)
    trainingArrowAnimation("Image_arrow_def_m", "Label_new_def_p", knightInfo ~= nil)
    trainingArrowAnimation("Image_arrow_def_p", "Label_new_def_m", knightInfo ~= nil)
end

function HeroQualityResult.showHeroQualityResult( func )
    local heroResult = HeroQualityResult.new("ui_layout/Hero_QualityResult.json")


    -- 找到主角提升品质的记录
    require("app.cfg.role_quality_info")

    local oldId = 0
    local nowId = G_Me.bagData.knightsData:getMainKnightBaseId()

    local len = role_quality_info.getLength()
    for i=1,len do 
        local record =  role_quality_info.indexOf(i)
        if record.result_id == nowId then
            oldId = record.pre_knight_id
            break
        end
    end
    -- print("nowId =" .. nowId)

    if oldId == 0 then
        oldId = newId
        --in case of error
    end
    -- print("oldid =" .. oldId)
    heroResult:initWithBaseId(oldId, nowId,  func)
    uf_sceneManager:getCurScene():addChild(heroResult)

end


function HeroQualityResult:onTouchEnd( xpos, ypos )
    if not self._clickToClose then 
        return 
    end

    self:close()

    if self._callback then 
        self._callback()
    end
end


return HeroQualityResult

