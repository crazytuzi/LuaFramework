--HeroGuanghuanResult.lua


local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

local HeroGuanghuanResult = class("HeroGuanghuanResult", UFCCSModelLayer)

function HeroGuanghuanResult:ctor( ... )
	self._callback = nil
	self._clickToClose = false
	self._parentLayer = nil
	self._finishGuideClick = false

	self.super.ctor(self, ...)

	self:showWidgetByName("Image_click_continue", false)

	 self:enableLabelStroke("Label_unlock_text_0", Colors.strokeBrown, 1 )
	 self:enableLabelStroke("Label_unlock_text_1", Colors.strokeBrown, 1 )
	 self:enableLabelStroke("Label_unlock_text_2", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_new_knight", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_old_attack", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_old_hp", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_old_def_p", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_old_def_m", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_old_ji", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_old_he", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_new_attack", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_new_hp", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_new_def_p", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_new_def_m", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_new_ji", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_new_he", Colors.strokeBrown, 1 )

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
 --    createStoke("Label_attri_ji")
 --    createStoke("Label_attri_he")

    self:adapterWithScreen()
    self:registerTouchEvent(false,true,0)
end

function HeroGuanghuanResult:onLayerEnter( ... )
	self:closeAtReturn(true)
	local soundConst = require("app.const.SoundConst")
    G_SoundManager:playSound(soundConst.GameSound.KNIGHT_SPECIAL)

	self:showWidgetByName("Label_new_attack", false)
	self:showWidgetByName("Label_new_hp", false)
	self:showWidgetByName("Label_new_def_p", false)
	self:showWidgetByName("Label_new_def_m", false)
	self:showWidgetByName("Label_new_ji", false)
	self:showWidgetByName("Label_new_he", false)
	self:showWidgetByName("Image_arrow_attack", false)
	self:showWidgetByName("Image_arrow_hp", false)
	self:showWidgetByName("Image_arrow_def_p", false)
	self:showWidgetByName("Image_arrow_def_m", false)
	self:showWidgetByName("Image_arrow_ji", false)
	self:showWidgetByName("Image_arrow_he", false)

	self:showWidgetByName("Panel_border", false)

	GlobalFunc.flyDown({self:getWidgetByName("Image_title_back")}, 0.3, 0, 3, function ( ... )
		self:showWidgetByName("Panel_border", true)
		GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_attri1"), 
                    self:getWidgetByName("Panel_attri2"),
                    self:getWidgetByName("Panel_attri3"), 
                    self:getWidgetByName("Panel_attri4"),
                    self:getWidgetByName("Panel_attri5"),
                    self:getWidgetByName("Panel_attri6")}, true, 0.3, 2, 50, function ( ... )

                    	self:showWidgetByName("Label_new_attack", true)

						GlobalFunc.flyDown({self:getWidgetByName("Label_new_attack"),
							self:getWidgetByName("Label_new_hp"),
							self:getWidgetByName("Label_new_def_p"),
							self:getWidgetByName("Label_new_def_m"),
							self:getWidgetByName("Label_new_ji"),
							self:getWidgetByName("Label_new_he")}, 0.2, 0.1, 3, function ( ... )
								self:showWidgetByName("Image_arrow_attack", true)
								self:showWidgetByName("Image_arrow_hp", true)
								self:showWidgetByName("Image_arrow_def_p", true)
								self:showWidgetByName("Image_arrow_def_m", true)
								self:showWidgetByName("Image_arrow_ji", true)
								self:showWidgetByName("Image_arrow_he", true)

								self:showWidgetByName("Image_click_continue", true)
                    			EffectSingleMoving.run(self:getWidgetByName("Image_click_continue"), "smoving_wait", nil , {position = true} )

                    			self._clickToClose = true
                    			self:setClickClose(true)
                    			

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

function HeroGuanghuanResult:initWithBaseId( parentLayer, baseId, haloLevel1, haloLevel2, func )
	baseId = baseId or 0
	haloLevel1 = haloLevel1 or 1
	haloLevel2 = haloLevel2 or (haloLevel1 + 1)
	self._parentLayer = parentLayer
	self._callback = func
	require("app.cfg.knight_halo_info")

	local haloInfo = knight_halo_info.get(haloLevel1)
	local nextHaloInfo = knight_halo_info.get(haloLevel2)

	if not haloInfo or not nextHaloInfo then
		__Log("haloInfo is nil , curHaloLevel=%d, ", haloLevel1)
		dump(haloInfo) 
		return 
	end

	local knightInfo = nil
	if baseId > 0 then 
		knightInfo = knight_info.get(baseId)
	end

	if knightInfo and type(knightInfo.common_sound) == "string" and #knightInfo.common_sound > 3 then
		G_SoundManager:playSound(knightInfo.common_sound)
	end

	self:showTextWithLabel("Label_unlock_text_1", haloLevel2)

	local dressInfo = nil
	if knightInfo and knightInfo.type == 1 then
		local dress = G_Me.dressData:getDressed() 
		if dress and knightInfo.group == 0 then
			dressInfo = G_Me.dressData:getDressInfo(dress.base_id) 
		end
	end

	require("app.cfg.skill_info")
	local skillInfo = nil 
	if dressInfo then
		skillInfo = skill_info.get(dressInfo.active_skill_id_1)
	elseif knightInfo and knightInfo.active_skill_id > 0 then 
		skillInfo = skill_info.get(knightInfo.active_skill_id)
	end
	self:showWidgetByName("Panel_attri5", skillInfo ~= nil )
	if skillInfo then
		self:showTextWithLabel("Label_attri_ji", skillInfo.name)
		self:showTextWithLabel("Label_old_ji", G_lang:get("LANG_KNIGHT_GUANGHUAN_RESULT_SKILL_FORMAT", {levelCount=haloLevel1}))
		self:showTextWithLabel("Label_new_ji", G_lang:get("LANG_KNIGHT_GUANGHUAN_RESULT_SKILL_FORMAT", {levelCount=haloLevel2}))
	end

	local heSkillInfo = nil 
	if dressInfo then
		skillInfo = skill_info.get(dressInfo.unite_skill_id)
	elseif knightInfo and knightInfo.unite_skill_id > 0 then 
		heSkillInfo = skill_info.get(knightInfo.unite_skill_id)
	end
	self:showWidgetByName("Panel_attri6", heSkillInfo ~= nil )
	if heSkillInfo then
		self:showTextWithLabel("Label_attri_he", heSkillInfo.name)
		self:showTextWithLabel("Label_old_he", G_lang:get("LANG_KNIGHT_GUANGHUAN_RESULT_SKILL_FORMAT", {levelCount=haloLevel1}))
		self:showTextWithLabel("Label_new_he", G_lang:get("LANG_KNIGHT_GUANGHUAN_RESULT_SKILL_FORMAT", {levelCount=haloLevel2}))
	end

		if haloInfo then 
			self:showTextWithLabel("Label_old_hp", "+"..(haloInfo.health_add/10).."%")
			self:showTextWithLabel("Label_old_attack", "+"..(haloInfo.attack_add/10).."%")
			self:showTextWithLabel("Label_old_def_p", "+"..(haloInfo.phy_defence_add/10).."%")
			self:showTextWithLabel("Label_old_def_m", "+"..(haloInfo.magic_defence_add/10).."%")
		else
			self:showTextWithLabel("Label_old_hp", "+0%")
			self:showTextWithLabel("Label_old_attack", "+0%")
			self:showTextWithLabel("Label_old_def_p", "+0%")
			self:showTextWithLabel("Label_old_def_m", "+0%")
		end

		if nextHaloInfo then 
			if knightInfo and type(knightInfo.common_sound) == "string" and #knightInfo.common_sound > 3 then 
				G_SoundManager:playSound(knightInfo.common_sound)
			end

			self:showTextWithLabel("Label_new_hp", "+"..(nextHaloInfo.health_add/10).."%")
			self:showTextWithLabel("Label_new_attack", "+"..(nextHaloInfo.health_add/10).."%")
			self:showTextWithLabel("Label_new_def_p", "+"..(nextHaloInfo.health_add/10).."%")
			self:showTextWithLabel("Label_new_def_m", "+"..(nextHaloInfo.health_add/10).."%")
		else
			self:showTextWithLabel("Label_new_hp", "")
			self:showTextWithLabel("Label_new_attack", "")
			self:showTextWithLabel("Label_new_def_p", "")
			self:showTextWithLabel("Label_new_def_m", "")
		end

	require("app.cfg.passive_skill_info")

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
	trainingArrowAnimation("Image_arrow_ji", "Label_new_ji", skillInfo ~= nil)
	trainingArrowAnimation("Image_arrow_he", "Label_new_he", heSkillInfo ~= nil)
end

function HeroGuanghuanResult.showHeroGuanghuanResult( parentLayer, baseId, haloLevel1, haloLevel2, func )
	local HeroGuanghuanResult = require("app.scenes.herofoster.HeroGuanghuanResult")
	local heroResult = HeroGuanghuanResult.new("ui_layout/HeroGuanhuan_Result.json")
	heroResult:initWithBaseId(parentLayer, baseId, haloLevel1, haloLevel2, func)
	uf_notifyLayer:getModelNode():addChild(heroResult)

end

function HeroGuanghuanResult:_onCloseLayer( ... )
	if not self._clickToClose then 
		return true
	end

    if self._callback then 
    	self._callback()
    end
    self:close()
    
	return true
end

function HeroGuanghuanResult:onBackKeyEvent( ... )
	return self:_onCloseLayer()
end

function HeroGuanghuanResult:onClickClose( ... )
    return self:_onCloseLayer()
end

-- function HeroGuanghuanResult:onTouchEnd( xpos, ypos )
-- 	return self:_onCloseLayer()
-- end


return HeroGuanghuanResult

