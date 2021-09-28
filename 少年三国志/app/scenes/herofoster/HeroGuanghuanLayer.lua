--HeroGuanghuanLayer.lua

local KnightConst = require("app.const.KnightConst")
local JumpCard = require "app.scenes.common.JumpCard"
local HeroGuanghuanLayer = class ("HeroGuanghuanLayer", UFCCSNormalLayer)
local EffectNode = require "app.common.effects.EffectNode"

function HeroGuanghuanLayer.create( ... )
	return require("app.scenes.herofoster.HeroGuanghuanLayer").new("ui_layout/HeroGuanghuan_Main.json", ... )
end

function HeroGuanghuanLayer:ctor( ... )
	self._mainKnightId = 0
	self._curGuanhuanLevel = 1
	self._bigFire = nil
	self._dragonBar = nil
	self._curTimeCost = 0
	self._smallFireEffect = nil
	self._jumpCardNode = nil
	self._isUpgrading = false
	self._dragonEffect = nil
	self._dragonLight = nil

	self._lastHalovalue = 0
	self._curHaloValue = 0
	self._nextLevelHalo = 0

	self._isRequesting = false

	self._isLongClick = false
	self.super.ctor(self, ...)
end

function HeroGuanghuanLayer:onLayerLoad( jsonFile, knightId, ... )
	self._mainKnightId = knightId

	self:enableLabelStroke("Label_name", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_shengjie", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_guanzhi_name", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_guanhuan", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_hp_value_0", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_attack_value_0", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_defense_p_value_0", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_defense_m_value_0", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_skill_name_0", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_level_0", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_guanghuan_1", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_attack_value_1", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_hp_value_1", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_defense_p_value_1", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_defense_m_value_1", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_skill_name_1", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_level_1", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_cur_growup", Colors.strokeBrown, 1 )
    --self:enableLabelStroke("Label_cost_value", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_clear_time_2", Colors.strokeBrown, 1 )

    self:enableLabelStroke("Label_skill_name_he_0", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_level_he_0", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_skill_name_he_1", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_level_he_1", Colors.strokeBrown, 1 )

    local createStroke = function ( name )
        local label = self:getLabelByName(name)
        if label then 
            label:createStroke(Colors.strokeBrown, 1)
        end
    end
    createStroke("Label_exp")
    --createStroke("Label_cost_name")
    --createStroke("Label_clear_time")
    createStroke("Label_hp_0")
    createStroke("Label_attack_0")
    createStroke("Label_defense_p_0")
    createStroke("Label_defense_m_0")
    createStroke("Label_attack_1")
    createStroke("Label_hp_1")
    createStroke("Label_defense_p_1")
    createStroke("Label_defense_m_1")

	self:registerBtnClickEvent("Button_growup", function ( widget )
		self:_onGuanghuanClick()
	end)
	self:registerBtnClickEvent("Button_tianming", function ( widget )
		self:_onGuanghuanClick()
	end)
	self:registerWidgetTouchEvent("Button_growup", function ( widget, typeValue )
         self:_onGuanghuanTouch(widget, typeValue)
     end)

	if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then 
		local EffectNode = require("app.common.effects.EffectNode")
		local effect  = EffectNode.new("effect_jinjiechangjing")
    	effect:play()
    	local left = self:getWidgetByName("Image_19")
    	if left then 
    		effect:setScale(0.5)
    		left:addNode(effect)
    	end
	end

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECEIVE_HALO_KNIGHT, self._onReceiveHaloResult, self)
end

function HeroGuanghuanLayer:onLayerUnload(  )
	uf_eventManager:removeListenerWithTarget(self)

	
end

function HeroGuanghuanLayer:onLayerEnter( ... )
	self:_initFire()

	local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(self._mainKnightId)

	if knightInfo and GlobalFunc.isTimeToday(knightInfo.halo_ts) < 0 then 
		knightInfo.halo_exp = 0
	end
	self:_initMainHero(self._mainKnightId, knightInfo)
	self:_initGuanghuanInfo(self._mainKnightId, knightInfo)	

	local dressKnightId = 0
    if self._mainKnightId == G_Me.formationData:getMainKnightId() then 
        dressKnightId = G_Me.dressData:getDressedPic()
    end

	local knightPanel =self:getWidgetByName("Panel_knight_pic")
	local knightDizuo = self:getWidgetByName("Image_dizuo")
	local baseId = G_Me.bagData.knightsData:getBaseIdByKnightId(self._mainKnightId)
	if knightPanel and knightDizuo and baseId > 0 then 
		local callback = function ( ... )
    		self:showWidgetByName("Panel_left", true)
			self:showWidgetByName("Panel_right", true)
			self:showWidgetByName("Panel_name", true)
			self:showWidgetByName("Panel_knight_pic", true)

    		GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_left")}, true, 0.2, 3, 50)
    		GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_right")}, false, 0.2, 3, 50)
    	end

    	self:showWidgetByName("Panel_left", false)
		self:showWidgetByName("Panel_right", false)
		self:showWidgetByName("Panel_name", false)
		self:showWidgetByName("Panel_knight_pic", false)
		
		local centerPtx, centerPty = knightPanel:convertToWorldSpaceXY(0, 0)
		centerPtx, centerPty = knightDizuo:convertToNodeSpaceXY(centerPtx, centerPty)
		local KnightAppearEffect = require("app.scenes.hero.KnightAppearEffect")
		local ani = nil 
    	ani = KnightAppearEffect.new(baseId, function()
        	local soundConst = require("app.const.SoundConst")
        	G_SoundManager:playSound(soundConst.GameSound.KNIGHT_DOWN)
    		if callback then 
    			callback() 
    		end
    		if ani then
    			ani:removeFromParentAndCleanup(true)
    		end
    	end, dressKnightId)
    	ani:setPositionXY(centerPtx, centerPty)
    	ani:play()
    	ani:setScale(knightPanel:getScale())
    	knightDizuo:addNode(ani)
    end

    if LANG == "tw" then
    	self:getLabelByName("Label_clear_time_1"):setText(G_lang:get("LANG_KNIGHT_CURRENT_TIP_TW"))
    end
end

function HeroGuanghuanLayer:onLayerExit( ... )
	if self._jumpCardNode  ~= nil then 
		self._jumpCardNode:removeFromParentAndCleanup(true)
		self._jumpCardNode = nil
	end

	if self._dragonEffect then 
		self._dragonEffect:stop()
		self._dragonEffect:removeFromParentAndCleanup(true)
		self._dragonEffect = nil 
	end
end

function HeroGuanghuanLayer:onSwitchLayer( param, fun )
	local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(self._mainKnightId)
	if knightInfo and GlobalFunc.isTimeToday(knightInfo.halo_ts) < 0 then 
		knightInfo.halo_exp = 0
	end

	if not knightInfo or knightInfo.halo_exp <= 0 then 
		return false
	end

	require("app.scenes.herofoster.HeroGuanghuanTipLayer").showGuanghuanTip(nil, function ( ... )
		if fun then 
			fun()
		end
	end)

	return true
end

function HeroGuanghuanLayer:adapterLayer( ... )
	self:adapterWidgetHeight("Panel_knight", "Panel_header", "Panel_baseinfo", 0, 0)
end

function HeroGuanghuanLayer:_initFire( ... )
	local growupBtn = self:getWidgetByName("Button_growup")
	if growupBtn then 
		self._smallFireEffect = EffectNode.new("effect_smallfire")
		if self._smallFireEffect then
			growupBtn:addNode(self._smallFireEffect)
			self._smallFireEffect:pause()
			self._smallFireEffect:setVisible(false)
		end
		self:showWidgetByName("Button_guanhuanshi", false)
	end

	self._dragonBar = self:getLoadingBarByName("ProgressBar_dragon")
	-- local panel = self:getWidgetByName("Panel_progress")
	-- if panel then 
	-- 	self._dragonBar = require("app.scenes.herofoster.HeroGuangHuangBarEffect").new()
	-- 	panel:addNode(self._dragonBar)
	-- 	local panelSize = panel:getSize()
	-- 	self._dragonBar:setPosition(ccp(panelSize.width/2, 10))
	-- end

    if self._dragonBar then 
    	self._dragonLight = EffectNode.new("effect_dragon_light", function ( event )
    		if event == "finish" then 
    			if self._dragonLight then 
    				self._dragonLight:setVisible(false)
    			end
    		end
    	end)
    	self._dragonBar:addNode(self._dragonLight)
		self._dragonLight:setPosition(ccp(0, 150))
		--self._dragonLight:play()
    end
end

function HeroGuanghuanLayer:_initMainHero( knightId, knightInfo )
	local baseId = knightInfo and knightInfo["base_id"] or 0
	local knightBaseInfo = knight_info.get(baseId)
	local level = knightInfo and knightInfo["level"] or 1

	local label = self:getLabelByName("Label_level")
	if label then
		label:setText(G_lang:get("LANG_KNIGHT_GUANZHI_LEVEL", {levelValue = level}))
	end

	label = self:getLabelByName("Label_shengjie")
	if label then
		label:setColor(Colors.getColor(knightBaseInfo and knightBaseInfo.quality or 1))
		if knightBaseInfo and knightBaseInfo.advanced_level > 0 then
			label:setText( "+"..knightBaseInfo.advanced_level )
		else
			label:setText("")
		end
	end

	label = self:getLabelByName("Label_name")
	if label ~= nil then
		label:setColor(Colors.getColor(knightBaseInfo and knightBaseInfo.quality or 1))
		label:setText(knightBaseInfo ~= nil and knightBaseInfo.name or "")
	end

	local knightPicPanel = self:getWidgetByName("Panel_knight_pic")
	if knightPicPanel and knightBaseInfo then
		local resId = knightBaseInfo.res_id
		if self._mainKnightId == G_Me.formationData:getMainKnightId() then 
        	resId = G_Me.dressData:getDressedPic()
    	end

		local knightPic = require("app.scenes.common.KnightPic")
		local pic = knightPic.createKnightButton(resId, knightPicPanel, "mainKnight_button", self, function ( ... )
			local callback = function ( ... )
				if CCDirector:sharedDirector():getSceneCount() > 1 then 
					uf_sceneManager:popScene()
				else
					uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroFosterScene").new(1, self._mainKnightId))
				end
			end
			if not self:onSwitchLayer(nil, callback) then 
				callback()
			end
		end, true)
		local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
        EffectSingleMoving.run(pic, "smoving_idle", nil, {}, 1+ math.floor(math.random()*30))
	end

	-- label = self:getLabelByName("Label_hp_value")
	-- if label and knightBaseInfo then
	-- 	label:setText(""..(knightBaseInfo.base_hp + (level - 1)*knightBaseInfo.develop_hp))
	-- else
	-- 	label:setText("")
	-- end

	-- label = self:getLabelByName("Label_attack_value")
	-- if label  and knightBaseInfo then
	-- 	label:setText(""..(G_Me.bagData.knightsData:calcAttack(knightId)))
	-- else
	-- 	label:setText("")
	-- end

	-- label = self:getLabelByName("Label_defense_p_value")
	-- if label  and knightBaseInfo then
	-- 	label:setText(""..(knightBaseInfo.base_physical_defence + (level - 1)*knightBaseInfo.develop_physical_defence))
	-- else
	-- 	label:setText("")
	-- end

	-- label = self:getLabelByName("Label_defense_m_value")
	-- if label  and knightBaseInfo then
	-- 	label:setText(""..(knightBaseInfo.base_magical_defence + (level - 1)*knightBaseInfo.develop_magical_defence))
	-- else
	-- 	label:setText("")
	-- end

	-- GlobalFunc.showStars(self, 
	-- 	{"ImageView_star_1", "ImageView_star_2","ImageView_star_3","ImageView_star_4","ImageView_star_5","ImageView_star_6"},
	-- 	knightBaseInfo and knightBaseInfo.star or 1, 2)
end

function HeroGuanghuanLayer:_initGuanghuanInfo( knightId, knightInfo )
	require("app.cfg.knight_halo_info")
	local curHaloLevel = knightInfo and knightInfo.halo_level or 1

	local haloInfo = knight_halo_info.get(curHaloLevel)
	local nextHaloInfo = knight_halo_info.get(curHaloLevel + 1)

	if not haloInfo then
		__Log("haloInfo is nil , knightId=%d, ", knightId)
		dump(knightInfo) 
		return 
	end

	self._curGuanhuanLevel = haloInfo.level

	-- 当前光环等级数据
	self:showTextWithLabel("Label_guanhuan", haloInfo.name)
	self:showTextWithLabel("Label_guanzhi_name", haloInfo.name)
	self:showTextWithLabel("Label_guanghuan_1", nextHaloInfo and nextHaloInfo.name or "")

	local skillName = nil
	local dressInfo = nil
	local heSkillName = nil
	if knightInfo then
		if knightId == G_Me.formationData:getMainKnightId() then
			local dress = G_Me.dressData:getDressed() 
			
			local knightBaseInfo = knight_info.get(knightInfo["base_id"] or 0)
			if dress and knightBaseInfo and knightBaseInfo.type == 1 then
				dressInfo = G_Me.dressData:getDressInfo(dress.base_id) 
			end
			
		end

		if dressInfo then
			local skillInfo = skill_info.get(dressInfo.active_skill_id_1)
			skillName = skillInfo and skillInfo.name or nil

			local uniteSkillInfo =  skill_info.get(dressInfo.unite_skill_id)
			heSkillName = uniteSkillInfo and uniteSkillInfo.name or nil
		else
			local knightBaseInfo = knight_info.get(knightInfo["base_id"])
			if knightBaseInfo then 
				local skillInfo = skill_info.get(knightBaseInfo.active_skill_id)
				skillName = skillInfo and skillInfo.name or nil

				local uniteSkillInfo =  skill_info.get(knightBaseInfo.unite_skill_id)
				heSkillName = uniteSkillInfo and uniteSkillInfo.name or nil
			end
		end
	end

	self:showTextWithLabel("Label_skill_name_0", skillName or "")
	self:showTextWithLabel("Label_skill_name_1", skillName or "")
	self:showWidgetByName("Label_level_0", skillName ~= nil)
	self:showWidgetByName("Label_level_1", skillName ~= nil)

	self:showTextWithLabel("Label_skill_name_he_0", heSkillName or "")
	self:showTextWithLabel("Label_skill_name_he_1", heSkillName or "")
	self:showWidgetByName("Label_level_he_0", heSkillName ~= nil)
	self:showWidgetByName("Label_level_he_1", heSkillName ~= nil)

	-- if skillName then 
	-- 	local label = self:getLabelByName("Label_skill_name_0")
	-- 	if label then 
	-- 		local posx, posy = label:getPosition()
	-- 		local labelSize = label:getSize()
	-- 		label = self:getWidgetByName("Label_level_0")
	-- 		if label then 
	-- 			--label:setPosition(ccp(posx + 5 + labelSize.width, posy))
	-- 		end
	-- 	end

	-- 	label = self:getLabelByName("Label_level_1")
	-- 	if label then 
	-- 		local posx, posy = label:getPosition()
	-- 		label = self:getWidgetByName("Label_skill_name_1")
	-- 		if label then 
	-- 			--label:setPosition(ccp(posx - 5, posy))
	-- 		end
	-- 	end
	-- end

	local label = self:getLabelByName("Label_level_0")
	if label then
		label:setText(G_lang:get("LANG_KNIGHT_GUANZHI_LEVEL", {levelValue = haloInfo and haloInfo.level or 1}))
	end

	label = self:getLabelByName("Label_level_he_0")
	if label then
		label:setText(G_lang:get("LANG_KNIGHT_GUANZHI_LEVEL", {levelValue = haloInfo and haloInfo.level or 1}))
	end

	label = self:getLabelByName("Label_hp_value_0")
	if label then
		if haloInfo then
			label:setText("+"..(haloInfo.health_add/10).."%")
		else
			label:setText("+0%")
		end
	end
	label = self:getLabelByName("Label_attack_value_0")
	if label then
		if haloInfo then
			label:setText("+"..(haloInfo.attack_add/10).."%")
		else
			label:setText("+0%")
		end
	end
	label = self:getLabelByName("Label_defense_p_value_0")
	if label then
		if haloInfo then
			label:setText("+"..(haloInfo.phy_defence_add/10).."%")
		else
			label:setText("+0%")
		end
	end
	label = self:getLabelByName("Label_defense_m_value_0")
	if label then
		if haloInfo then
			label:setText("+"..(haloInfo.magic_defence_add/10).."%")
		else
			label:setText("+0%")
		end
	end

	--当前光环升级所需要资源数据
	self:_updateGuanghuanValue(knightInfo)
	-- label = self:getLabelByName("Label_cur_growup")
	-- if label then
	-- 	local curExp = 0
	-- 	if knightInfo then
	-- 		curExp = knightInfo["halo_exp"]
	-- 	end
	-- 	label:setText(curExp.."/"..haloInfo.levelup_value)
	-- end
	-- label = self:getLabelByName("Label_cost_value")
	-- if label then
	-- 	if G_Me.bagData:hasEnoughProp( 14, haloInfo.single_cost ) then 
	-- 		if self._smallFireEffect then 
	-- 			self._smallFireEffect:play()
	-- 			self._smallFireEffect:setVisible(true)
	-- 		end
	-- 		self:showWidgetByName("Button_tianming", false)
	-- 	else
	-- 		if self._smallFireEffect then 
	-- 			self._smallFireEffect:pause()
	-- 			self._smallFireEffect:setVisible(false)
	-- 		end
	-- 		self:showWidgetByName("Button_tianming", true)
	-- 		label:setColor(ccc3(255, 0, 0))
	-- 	end
	-- 	if haloInfo then
	-- 		label:setText(""..haloInfo.single_cost)
	-- 	else
	-- 		label:setText("0")
	-- 	end
	-- end

	-- if self._dragonBar then 
	-- 	local curExp = knightInfo and knightInfo["halo_exp"] or 0
	-- 	local maxExp = haloInfo and haloInfo.levelup_value or 1
	-- 	local percent = curExp * 100 / maxExp
	-- 	__Log("curExp:%d, maxExp:%d, percent:%d", curExp, maxExp, percent)
	-- 	self._dragonBar:setPercent(percent, 0.5)
	-- end

	-- 下一光环等级数据
	local widget = self:getWidgetByName("Panel_right")
	if widget then
		widget:setVisible(curHaloLevel < knight_halo_info.getLength())
	end
	widget = self:getWidgetByName("ImageView_arrow")
	if widget then
		widget:setVisible(curHaloLevel < knight_halo_info.getLength())
	end

	label = self:getLabelByName("Label_level_1")
	if label then
		label:setText(G_lang:get("LANG_KNIGHT_GUANZHI_LEVEL", {levelValue = nextHaloInfo and nextHaloInfo.level or 1}))
	end
	label = self:getLabelByName("Label_level_he_1")
	if label then
		label:setText(G_lang:get("LANG_KNIGHT_GUANZHI_LEVEL", {levelValue = nextHaloInfo and nextHaloInfo.level or 1}))
	end

	label = self:getLabelByName("Label_hp_value_1")
	if label then
		if nextHaloInfo then
			label:setText("+"..(nextHaloInfo.health_add/10).."%")
		else
			label:setText("+0%")
		end
	end
	label = self:getLabelByName("Label_attack_value_1")
	if label then
		if nextHaloInfo then
			label:setText("+"..(nextHaloInfo.health_add/10).."%")
		else
			label:setText("+0%")
		end
	end
	label = self:getLabelByName("Label_defense_p_value_1")
	if label then
		if nextHaloInfo then
			label:setText("+"..(nextHaloInfo.health_add/10).."%")
		else
			label:setText("+0%")
		end
	end
	label = self:getLabelByName("Label_defense_m_value_1")
	if label then
		if nextHaloInfo then
			label:setText("+"..(nextHaloInfo.health_add/10).."%")
		else
			label:setText("+0%")
		end
	end
end

function HeroGuanghuanLayer:_updateGuanghuanValue( knightInfo )
	local haloInfo = knight_halo_info.get(knightInfo and knightInfo.halo_level or 1)
	if not haloInfo or not knightInfo then 
		return 
	end

	self._curHaloValue = knightInfo["halo_exp"] or 0
	self._nextLevelHalo = haloInfo.levelup_value or 0

	if self._lastHalovalue <= 0 then 
		self._lastHalovalue = self._curHaloValue
	end
	self._curGuanhuanLevel = haloInfo.level
	local label = self:getLabelByName("Label_cur_growup")
	if label then
		local curExp = 0
		if knightInfo then
			curExp = knightInfo["halo_exp"]
		end
		label:setText(curExp.."/"..haloInfo.levelup_value)
	end
	label = self:getLabelByName("Label_cost_value")
	if label then
		if G_Me.bagData:hasEnoughProp( 14, haloInfo.single_cost ) then 
			if self._smallFireEffect then 
				self._smallFireEffect:play()
				self._smallFireEffect:setVisible(true)
			end
			self:showWidgetByName("Button_tianming", false)
		else
			if self._smallFireEffect then 
				self._smallFireEffect:pause()
				self._smallFireEffect:setVisible(false)
			end
			self:showWidgetByName("Button_tianming", true)
			label:setColor(ccc3(0xc5, 0x2d, 0))
		end
		if haloInfo then
			label:setText(""..haloInfo.single_cost)
		else
			label:setText("0")
		end
	end

	self:_updateUpgradeRait(haloInfo)

	if self._dragonBar then 
		local curExp = knightInfo and knightInfo["halo_exp"] or 0
		local maxExp = haloInfo and haloInfo.levelup_value or 1
		local percent = curExp * 100 / maxExp
		self._dragonBar:runToPercent(percent, 0.5)
	end

	local propInfo = G_Me.bagData.propList:getItemByKey(14)
	self:showTextWithLabel("Label_shi_count", propInfo and propInfo["num"] or 0)
end

function HeroGuanghuanLayer:_updateUpgradeRait( haloInfo  )
	if not haloInfo then 
		return 
	end

	local clrType = 1
	local raitStr = "LANG_KNIGHT_GUANGHUAN_RAIT_LOW"
	if self._curHaloValue <= haloInfo.low_exp then 
		raitStr = "LANG_KNIGHT_GUANGHUAN_RAIT_LOW"
		clrType = 1
	elseif self._curHaloValue <= haloInfo.lower_exp then
		raitStr = "LANG_KNIGHT_GUANGHUAN_RAIT_LOWER"
		clrType = 2
	elseif self._curHaloValue <= haloInfo.common_exp then
		raitStr = "LANG_KNIGHT_GUANGHUAN_RAIT_COMMON"
		clrType = 3
	elseif self._curHaloValue <= haloInfo.higher_exp then
		raitStr = "LANG_KNIGHT_GUANGHUAN_RAIT_HIGHER"
		clrType = 4
	elseif self._curHaloValue <= haloInfo.high_exp then
		raitStr = "LANG_KNIGHT_GUANGHUAN_RAIT_HIGH"
		clrType = 7
	end

	local label = self:getLabelByName("Label_clear_time_2")
	if label then 
		label:setColor(Colors.getColor(clrType))
		label:setText(G_lang:get(raitStr))
	end
end

function HeroGuanghuanLayer:_onGuanghuanClick(  )
	if self._isUpgrading  then 
		return 
	end

	if self._isRequesting then 
		return true
	end
	
	local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(self._mainKnightId)
	if not knightInfo then 
		return 
	end

	if GlobalFunc.isTimeToday(knightInfo.halo_ts) < 0 then 
		knightInfo.halo_exp = 0
	end
	require("app.cfg.knight_halo_info")
	local curHaloLevel = knightInfo and knightInfo.halo_level or 1
	if curHaloLevel >= 15 then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_GUANZHI_FULL_ATTRIBUTE"))
	end

	local haloInfo = knight_halo_info.get(curHaloLevel)
	if not haloInfo then 
		__LogError("wrong halolevel:%d", curHaloLevel or 0)
		return 
	end

	local yuCount = haloInfo and haloInfo.single_cost or 0
	if yuCount > 0 and not G_Me.bagData:hasEnoughProp( 14, yuCount ) then
		require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_ITEM, 14,
			GlobalFunc.sceneToPack("app.scenes.herofoster.HeroDevelopScene", {KnightConst.KNIGHT_TYPE.KNIGHT_GUANGHUAN, self._mainKnightId}))

		--local itemInfo = item_info.get(14)
		--local itemName = itemInfo ~= nil and itemInfo.name or "道具"
		--MessageBoxEx.showOkMessage(G_lang:get("警    告"), G_lang:get("没有足够数量的")..itemName)
		return false
	end

	if not self._bigFire then 
		local growupBtn = self:getWidgetByName("Button_growup")
		if growupBtn then 
			self._bigFire = EffectNode.new("effect_largefire", function ( event )
				if event == "finish" then
					self._bigFire:setVisible(false)
				end
			end)
			growupBtn:addNode(self._bigFire)
			self._bigFire:setPositionXY(-85, 25)
		end
	else
		self._bigFire:pause()
	end

	if self._bigFire then
		self._bigFire:setVisible(true)
		self._bigFire:play()
	end

	self._isRequesting = true
	G_HandlersManager.heroUpgradeHandler:sendGuanghuanKnight(self._mainKnightId)

	if self._dragonBar and not self._isLongClick then 
		local x, y = self._dragonBar:convertToWorldSpaceXY(0, 0)
		require("app.scenes.common.CommonInfoTipLayer").show(G_lang:get("LANG_KNIGHT_GUANZHI_REPEAT_TIP"), y + 60, 2)
	end

	return true
end

function HeroGuanghuanLayer:_onGuanghuanTouch( widget, typeValue )
	if TOUCH_EVENT_BEGAN == typeValue then 
		self._isLongClick = false
		local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(self._mainKnightId)
		if knightInfo then 
			if GlobalFunc.isTimeToday(knightInfo.halo_ts) < 0 then 
				knightInfo.halo_exp = 0
			end
			local haloInfo = knight_halo_info.get(knightInfo.halo_level)
			if haloInfo and G_Me.bagData:hasEnoughProp( 14, haloInfo.single_cost ) then 
        		self:scheduleUpdate(handler(self, self._onUpdate), 0)
    		end
    	end
    elseif TOUCH_EVENT_MOVED == typeValue then 
        if not widget then 
            self:_stopSchedule()
        end
        local curPt = widget:getTouchMovePos()
        if not widget:hitTest(curPt) then 
            self:_stopSchedule()
        end
    elseif TOUCH_EVENT_ENDED == typeValue then 
        self:_stopSchedule()
    elseif TOUCH_EVENT_CANCELED == typeValue then 
        self:_stopSchedule()
    end
end

function HeroGuanghuanLayer:_stopSchedule( ... )
    self:unscheduleUpdate()
    self._curTimeCost = 0
end

function HeroGuanghuanLayer:_onUpdate( dt )
    self._curTimeCost = self._curTimeCost + dt
        
    if self._curTimeCost > 0.2 and not self._isUpgrading then 
    	self._isLongClick = true
        self._curTimeCost = self._curTimeCost - 0.01
        local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(self._mainKnightId)
        if knightInfo then 
			if GlobalFunc.isTimeToday(knightInfo.halo_ts) < 0 then 
				knightInfo.halo_exp = 0
			end
			local haloInfo = knight_halo_info.get(knightInfo.halo_level)
			if haloInfo and G_Me.bagData:hasEnoughProp( 14, haloInfo.single_cost ) then 
        		if not self:_onGuanghuanClick() then
        			self:_stopSchedule()
        		end
        	end
        end
    end    
end

function HeroGuanghuanLayer:_onReceiveHaloResult( ret )
	
	if ret == NetMsg_ERROR.RET_OK then
		local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(self._mainKnightId)
		local curHoloLevel = knightInfo and knightInfo.halo_level or 1

		if knightInfo then 
			if GlobalFunc.isTimeToday(knightInfo.halo_ts) < 0 then 
				knightInfo.halo_exp = 0
			end
		end
		local offsetValue = 0

		local hasUpgrade = false
		local prefHoloLevel = self._curGuanhuanLevel
		if self._curGuanhuanLevel < curHoloLevel then 
			hasUpgrade = true
			offsetValue = self._nextLevelHalo - self._lastHalovalue
			--self:_initGuanghuanInfo(self._mainKnightId, knightInfo)
			self:_stopSchedule()
			self._isUpgrading = true
			local dizuo = self:getWidgetByName("Image_dizuo")
			if dizuo then 
				--local prefHoloLevel = curHoloLevel
				--if self._dragonEffect then 
				--	self._dragonEffect:removeFromParentAndCleanup(true)
				--	self._dragonEffect = nil
				--end
				if not self._dragonEffect then
					self._dragonEffect = EffectNode.new("effect_dragon", function ( event )
					if event == "finish" then
						if self._dragonEffect then
							self._dragonEffect:stop()
							self._dragonEffect:setVisible(false)
							--self._dragonEffect:removeFromParentAndCleanup(true)
							--self._dragonEffect = nil

							self:showWidgetByName("Panel_knight_pic", false)
							--重新获取,之前的方法有问题
							local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(self._mainKnightId)
							local curHoloLevel = knightInfo and knightInfo.halo_level or 1

							self:_playHaloLevelUpgradeAni(curHoloLevel-1, curHoloLevel, function ( ... )
								self:showWidgetByName("Panel_knight_pic", true)
								self._isUpgrading = false
							end)
						end						
					end
					end)
					local localPosx, localPosy = dizuo:convertToWorldSpaceXY(0, 0)
    				localPosx, localPosy = uf_notifyLayer:getModelNode():convertToNodeSpaceXY(localPosx, localPosy)
    				self._dragonEffect:setPositionXY( localPosx, localPosy )
					uf_notifyLayer:getModelNode():addChild(self._dragonEffect)
				end
				if self._dragonEffect then
					self._dragonEffect:setVisible(true)
					self._dragonEffect:play()
				end

				if self._dragonLight then 
					self._dragonLight:setVisible(true)
					self._dragonLight:play()
				end
			end
		else
			local oldHaloValue = self._lastHalovalue
			--self:_updateGuanghuanValue(knightInfo)
			--offsetValue = self._curHaloValue - oldHaloValue
			offsetValue = knightInfo.halo_exp - oldHaloValue

			__Log("lastHoloExp:%d, curHoloExp:%d, offset:%d", self._lastHalovalue, knightInfo.halo_exp, offsetValue)
		--	G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_ZHURU_SUCCESS"))
		end

		self._lastHalovalue = knightInfo.halo_exp
		if offsetValue > 0 then 
			local curTargetDesc = G_lang:get("LANG_KNIGHT_GUANZHI_VALUE").."+"..offsetValue
        	-- G_flyAttribute.addNormalText(curTargetDesc, Colors.titleGreen)
        	-- G_flyAttribute.play( function ( ... )
        	-- 	if hasUpgrade then 
        	-- 		self:_initGuanghuanInfo(self._mainKnightId, knightInfo)
        	-- 	end
        	-- end, 2, 1  )
			local label = GlobalFunc.createGameLabel(curTargetDesc, 30, Colors.titleGreen, Colors.strokeBrown)
			local arr = CCArray:create()
			arr:addObject(CCEaseIn:create(CCScaleTo:create(0.3, 1.3), 0.3))
			arr:addObject(CCEaseIn:create(CCScaleTo:create(0.15, 1), 0.15))
			arr:addObject(CCDelayTime:create(1.5))
			local moveAction = CCSpawn:createWithTwoActions(CCMoveBy:create(0.6, ccp(0, 150)), CCFadeOut:create(0.6))
			local moveAction = CCEaseIn:create(moveAction, 0.6)
			arr:addObject(moveAction)
			arr:addObject(CCCallFunc:create(function (  )
				if hasUpgrade then 
        	 		self:_initGuanghuanInfo(self._mainKnightId, knightInfo)
        	 	end
			end))
			arr:addObject(CCRemove:create())
			local winSize = CCDirector:sharedDirector():getWinSize()
			self:addChild(label, 10)
			label:setPosition(ccp(winSize.width/2, winSize.height/2))
			label:runAction(CCSequence:create(arr))

        	self:_updateGuanghuanValue(knightInfo)
        end
	end
	self._isRequesting = false
end

function HeroGuanghuanLayer:_playHaloLevelUpgradeAni( level1, level2, func )
	local baseId = G_Me.bagData.knightsData:getBaseIdByKnightId(self._mainKnightId or 0)
		
		local panel = self:getWidgetByName("Panel_knight_pic")
		local scaleValue = 0.5
		if panelBefore then 
			panel = panelBefore:getScale()
		end
		local waitfunc = function() 
            local HeroGuanghuanResult = require("app.scenes.herofoster.HeroGuanghuanResult")
           	HeroGuanghuanResult.showHeroGuanghuanResult(self, baseId, 
                			level1, 
                			level2, 
                		function ( ... )
                			if self._jumpCardNode then 
                				self._jumpCardNode:resume()
                			end
                		end)
        end

        local endfunc = function() 
        	if self._jumpCardNode then 
            	self._jumpCardNode:removeFromParentAndCleanup(true)                   
            	self._jumpCardNode = nil
            end
            if func then 
               	func()
            end
        end

        if self._jumpCardNode then 
        	self._jumpCardNode:removeFromParentAndCleanup(true)
			self._jumpCardNode = nil
        end
        local dressKnightId = 0
    	if self._mainKnightId == G_Me.formationData:getMainKnightId() then 
        	dressKnightId = G_Me.dressData:getDressedPic()
    	end

        self._jumpCardNode = JumpCard.create(baseId, ccp(panel:convertToWorldSpaceXY(0, 0)), 
        	ccp(panel:convertToWorldSpaceXY(0, 0)), scaleValue, waitfunc, endfunc, dressKnightId)
        uf_notifyLayer:getModelNode():addChild(self._jumpCardNode)
end

return HeroGuanghuanLayer
