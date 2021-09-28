--HeroAwakenLevelUpLayer.lua

require "app.cfg.knight_info"
require "app.cfg.passive_skill_info"
require "app.cfg.knight_awaken_info"

local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

local HeroAwakenLevelUpLayer = class("HeroAwakenLevelUpLayer", UFCCSModelLayer)

function HeroAwakenLevelUpLayer:ctor( ... )
	self._callback = nil
	self._clickToClose = false
	self._parentLayer = nil
	self._finishGuideClick = false

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

	-- local createStoke = function ( name )
 --        local label = self:getLabelByName(name)
 --        if label then 
 --            label:createStroke(Colors.strokeBrown, 1)
 --        end
 --    end
 --    createStoke("Label_attri_attack")
 --    createStoke("Label_attri_hp")
 --    createStoke("Label_attri_def_p")
 --    createStoke("Label_attri_def_m")

    self:adapterWithScreen()
    self:registerTouchEvent(false,true,0)
end

function HeroAwakenLevelUpLayer:onLayerEnter( ... )
    self:registerKeypadEvent(1, 0)

	if self.__EFFECT_FINISH_CALLBACK__ and self._parentLayer then 
		__Log("set __EFFECT_FINISH_CALLBACK__")
		self._parentLayer.__EFFECT_FINISH_CALLBACK__ = self.__EFFECT_FINISH_CALLBACK__
	else
		__Log("__EFFECT_FINISH_CALLBACK__ is nil")
	end

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
                    			self:closeAtReturn(1)

                    			if self._finishGuideClick and self.__EFFECT_FINISH_CALLBACK__ then 
                    				if self._callback then 
    									self._callback()
    								end
    								self:close()
                    			end
							end)                    	
                    end)

		GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_name")}, false, 0.3, 2, 50)
	end)	
end

function HeroAwakenLevelUpLayer:initWithBaseId( parentLayer, knightId, beforeAttr, afterAttr, func )

	self._parentLayer = parentLayer
	self._callback = func

	local newPassiveSkill = {}
        
        local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(knightId)
        assert(knightInfo, "Could not find the knightInfo with id: "..tostring(knightId))
        
        local knightConfig = knight_info.get(knightInfo.base_id)
        assert(knightConfig, "Could not find the knight info with id: "..tostring((knightInfo.base_id)))
        
        local knightName = knightConfig.name
        local awakenStar = math.floor(knightInfo.awaken_level / 10)
        
        -- beforeAttr
        self:showTextWithLabel("Label_old_hp", beforeAttr.hp)
        self:showTextWithLabel("Label_old_attack", beforeAttr.attack)
        self:showTextWithLabel("Label_old_def_p", beforeAttr.phyDefense)
        self:showTextWithLabel("Label_old_def_m", beforeAttr.magicDefense)

        local label = self:getLabelByName("Label_old_knight")
        if label then
            label:setColor(Colors.getColor(knightConfig.quality))
            label:setText(knightName..G_lang:get("LANG_AWAKEN_LEVELUP_KNIGHT_DESC", {star=awakenStar-1}))
        end
        
        -- afterAttr
        self:showTextWithLabel("Label_new_hp", afterAttr.hp)
        self:showTextWithLabel("Label_new_attack", afterAttr.attack)
        self:showTextWithLabel("Label_new_def_p", afterAttr.phyDefense)
        self:showTextWithLabel("Label_new_def_m", afterAttr.magicDefense)

        local label = self:getLabelByName("Label_new_knight")
        if label then 
            label:setColor(Colors.getColor(knightConfig.quality))
            label:setText(knightName..G_lang:get("LANG_AWAKEN_LEVELUP_KNIGHT_DESC", {star=awakenStar}))	
        end

        local awakenKnightInfo = knight_awaken_info.get(knightConfig.awaken_code, knightInfo.awaken_level)
        assert(awakenKnightInfo, "Could not find the knight awaken info with awaken_code and awaken_level: "..tostring(knightConfig.awaken_code)..", "..tostring(knightInfo.awaken_level))
        
	local passiveInfo = passive_skill_info.get(awakenKnightInfo.ability_id)
        assert(passiveInfo, "Could not find the passive skill info with id: "..awakenKnightInfo.ability_id)

        self:showTextWithLabel("Label_unlock_text", G_lang:get("LANG_KNIGHT_JINGJIE_UNLOCK_TIANFU", {tianfu=passiveInfo.name}))
        self:showTextWithLabel("Label_unlock_desc", passiveInfo.directions)

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

	trainingArrowAnimation("Image_arrow_hp", "Label_new_hp", knightInfo ~= nil)
	trainingArrowAnimation("Image_arrow_attack", "Label_new_attack", knightInfo ~= nil)
	trainingArrowAnimation("Image_arrow_def_m", "Label_new_def_p", knightInfo ~= nil)
	trainingArrowAnimation("Image_arrow_def_p", "Label_new_def_m", knightInfo ~= nil)
        
        -- 星数
        for i=1, 6 do
            self:showWidgetByName("Image_star"..i, i <= awakenStar)
        end
end

function HeroAwakenLevelUpLayer.showHeroAwakenLevelUpLayer( parentLayer, knightInfo, beforeAttr, afterAttr, func )
	local HeroAwakenLevelUpLayer = require("app.scenes.herofoster.HeroAwakenLevelUpLayer")
	local heroResult = HeroAwakenLevelUpLayer.new("ui_layout/HeroAwakenLevelUpLayer.json")
	heroResult:initWithBaseId(parentLayer, knightInfo, beforeAttr, afterAttr, func)
	uf_notifyLayer:getModelNode():addChild(heroResult)

end

function HeroAwakenLevelUpLayer:onBackKeyEvent( ... )
	if not self._finishGuideClick then 
		self:_onDoPauseCurGuide()
	end
	self._finishGuideClick = true
	
	if not self._clickToClose then 
		return true
	end

    if self._callback then 
    	self._callback()
    end
    self:close()
	return true
end


function HeroAwakenLevelUpLayer:onClickClose( ... )
	if not self._finishGuideClick then 
		self:_onDoPauseCurGuide()
	end
    self._finishGuideClick = true

	if not self._clickToClose then 
		return true
	end

    if self._callback then 
    	self._callback()
    end
    self:close()
	return true
end

function HeroAwakenLevelUpLayer:onTouchEnd( xpos, ypos )
	if not self._finishGuideClick then 
		self:_onDoPauseCurGuide()
	end
	self._finishGuideClick = true
	if not self._clickToClose then 
		return 
	end

    ---if self.__EFFECT_FINISH_CALLBACK__ then 
    --    self.__EFFECT_FINISH_CALLBACK__()
    --end

    -- if self._callback then 
    -- 	self._callback()
    -- end
    -- self:close()
end

function HeroAwakenLevelUpLayer:_onDoPauseCurGuide( ... )
	if self.__EFFECT_FINISH_CALLBACK__ then 
        self.__EFFECT_FINISH_CALLBACK__( true )
    end
end


return HeroAwakenLevelUpLayer

