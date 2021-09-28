-- EquipmentStarResultLayer.lua

local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local EffectNode = require "app.common.effects.EffectNode"

local EquipmentStarResultLayer = class("EquipmentStarResultLayer", UFCCSModelLayer)
local EquipmentConst = require("app.const.EquipmentConst")


function EquipmentStarResultLayer:ctor( ... )
    self._callback = nil
    self._clickToClose = false

    self.super.ctor(self, ...)

    self:showWidgetByName("Image_click_continue", false)

    self:enableLabelStroke("Label_unlock_text", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_unlock_desc", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_old_knight", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_new_knight", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_name1", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_name2", Colors.strokeBrown, 2 )

    self:adapterWithScreen()
    self:registerTouchEvent(false,true,0)
end

function EquipmentStarResultLayer:onLayerEnter( ... )

    local soundConst = require("app.const.SoundConst")
    G_SoundManager:playSound(soundConst.GameSound.KNIGHT_SPECIAL)

    self:showWidgetByName("Label_new_attr", false)
    self:showWidgetByName("Panel_stars_equip_2", false)
    self:showWidgetByName("Image_arrow_attr", false)


    self:showWidgetByName("Panel_border", false)

    GlobalFunc.flyDown({self:getWidgetByName("Image_title_back")}, 0.3, 0, 3, function ( ... )
        self:showWidgetByName("Panel_border", true)
        GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_attr")}, true, 0.3, 2, 50, function ( ... )

                        self:showWidgetByName("Label_new_attr", true)
                        self:showWidgetByName("Panel_stars_equip_2", true)

                        GlobalFunc.flyDown({self:getWidgetByName("Label_new_attr"), 
                        	self:getWidgetByName("Image_arrow_attr"), 
                        	self:getWidgetByName("Panel_stars_equip_2"),}, 0.2, 0.1, 3, function ( ... )
                                self:showWidgetByName("Image_arrow_attr", true)

                                self:showWidgetByName("Image_click_continue", true)
                                EffectSingleMoving.run(self:getWidgetByName("Image_click_continue"), "smoving_wait", nil , {position = true} )

                                self._clickToClose = true
                                self:setClickClose(true)
                            end)                        
                    end)

        GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_name")}, false, 0.3, 2, 50)
    end)    
end

function EquipmentStarResultLayer:initView(equipment, oldAttrs, func )
    self._callback = func

    self:getImageViewByName("Image_equip"):loadTexture(equipment:getPic())

    -- 星星的显示
	local starLevel = equipment.star or 0
	local oldStarLevel = starLevel - 1

	for i = 1, EquipmentConst.Star_MAX_LEVEL do

		self:getImageViewByName(string.format("Image_start1_%d_full", i)):setVisible(i <= oldStarLevel)
		self:getImageViewByName(string.format("Image_start2_%d_full", i)):setVisible(i <= starLevel)
	end

	self:getLabelByName("Label_attri_name"):setText(oldAttrs[1].typeString)
	self:getLabelByName("Label_old_attr"):setText("+" ..oldAttrs[1].value)
	local attrs = equipment:getStarAttrs()
	self:getLabelByName("Label_new_attr"):setText("+" ..attrs[1].valueString)
	self:getLabelByName("Label_attri_name_right"):setText(oldAttrs[1].typeString)

	local info = equipment:getInfo()
    --名字
    local name1Label = self:getLabelByName("Label_name1")
    name1Label:setColor(Colors.getColor(info.quality))
    name1Label:setText(info.name)
    name1Label:createStroke(Colors.strokeBrown,2)

    local name2Label = self:getLabelByName("Label_name2")
    name2Label:setColor(Colors.getColor(info.quality))
    name2Label:setText(info.name)
    name2Label:createStroke(Colors.strokeBrown,2)

    local maxLevel = equipment:getMaxStarLevel()

   	self:getPanelByName("Panel_stars_equip_1"):setPositionX(maxLevel == EquipmentConst.Star_CHENG_MAX_LEVEL and -243 + 53 or -243)
    self:getPanelByName("Panel_stars_equip_2"):setPositionX(maxLevel == EquipmentConst.Star_CHENG_MAX_LEVEL and 105 + 53 or 105)


    for i = 1, 2 do
    	for j = 1, 5 do
    		self:getImageViewByName(string.format("Image_start%d_%d", i, j)):setVisible(j <= maxLevel)
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

    trainingArrowAnimation("Image_arrow_attr", "Label_new_attr", knightInfo ~= nil)
end

function EquipmentStarResultLayer.showEquipmentStarResultLayer(equipment, oldAttrs, func )
    local heroResult = EquipmentStarResultLayer.new("ui_layout/equipment_EquipmentStarResult.json")


    if oldId == 0 then
        oldId = newId
        --in case of error
    end
    -- print("oldid =" .. oldId)
    heroResult:initView(equipment, oldAttrs, func)
    uf_sceneManager:getCurScene():addChild(heroResult)

end


function EquipmentStarResultLayer:onTouchEnd( xpos, ypos )
    if not self._clickToClose then 
        return 
    end

    self:close()

    if self._callback then 
        self._callback()
    end
end


return EquipmentStarResultLayer

