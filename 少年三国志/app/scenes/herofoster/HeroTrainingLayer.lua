--HeroTrainingLayer.lua

local HeroJingJieBubbleEffect = require("app.scenes.herofoster.HeroJingJieBubbleEffect")
local KnightConst = require("app.const.KnightConst")
local EffectNode = require "app.common.effects.EffectNode"
local HeroTrainingLayer = class ("HeroJingJieLayer", UFCCSNormalLayer)

function HeroTrainingLayer.create( ... )
	return require("app.scenes.herofoster.HeroTrainingLayer").new("ui_layout/HeroLiLian_Main.json", ... )
end

function HeroTrainingLayer:ctor( ... )
	self._mainKnightId = 0
	self._isOnTraining = false
	self._trainingTimes = 1
	self._trainingType = 1
	self._isFullAttribute = true
	self._hasGrowupAttribute = false
	self._curTrainingOffset = {}

	self._hpBubble = nil 
	self._attackBubble = nil 
	self._pDefBubble = nil 
	self._mDefBubble = nil

	self.super.ctor(self, ...)
end

function HeroTrainingLayer:onLayerLoad( jsonFile, knightId, ... )
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECEIVE_TRAINING_KNIGHT, self._onTrainingKnighRet, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECEIVE_SAVE_TRAINING, self._onSaveTrainingKnighRet, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECEIVE_GIVEUP_TRAINING, self._onGiveUpTrainingKnighRet, self)

	self:registerBtnClickEvent("Button_Cancel", function ( widget )
		self:_onCancelBtnClick()
	end)
	self:registerBtnClickEvent("Button_Replace", function ( widget )
		self:_onReplaceClick()
	end)
	self:registerBtnClickEvent("Button_LiLian", function ( widget )
		self:_onLilianClick()
	end)
	self:registerBtnClickEvent("Button_Replace_M", function ( widget )
		self:_onReplaceClick()
	end)
	self:registerBtnClickEvent("Button_choose", function ( widget )
		self:_onSelectTrainingClick()
	end)
	self:registerWidgetClickEvent("ImageView_xilian_times", function ( widget )
		self:_onSelectTrainingClick()
	end)
	
	self:showWidgetByName("Button_Replace_M", false)

	self:addCheckBoxGroupItem(1, "CheckBox_shujian")
	self:addCheckBoxGroupItem(1, "CheckBox_yinbi")
	self:addCheckBoxGroupItem(1, "CheckBox_jinbi")

	self:attachImageTextForBtn("Button_LiLian", "ImageView_6362")

	self:registerCheckboxEvent("CheckBox_shujian", function ( widget, type, isCheck )
		self:_onTrainingTypeChange(1)
	end)
	self:registerCheckboxEvent("CheckBox_yinbi", function ( widget, type, isCheck )
		self:_onTrainingTypeChange(2)
	end)
	self:registerCheckboxEvent("CheckBox_jinbi", function ( widget, type, isCheck )
		self:_onTrainingTypeChange(3)
	end)
	
	self:setCheckStatus(1, "CheckBox_shujian")
	self:_updateTrainingTimes(1)

	self._mainKnightId = knightId
	

	-- self:enableLabelStroke("Label_shujian_count", Colors.strokeBrown, 1)
	-- self:enableLabelStroke("Label_xilian_times", Colors.strokeBrown, 1)

	self:enableLabelStroke("Label_hp_value", Colors.strokeBlack, 1)
	--self:enableLabelStroke("Label_hp_offset", Colors.strokeBlack, 1)
	self:enableLabelStroke("Label_attack_value", Colors.strokeBlack, 1)
	--self:enableLabelStroke("Label_attack_offset", Colors.strokeBlack, 1)
	self:enableLabelStroke("Label_physic_defense_value", Colors.strokeBlack, 1)
	--self:enableLabelStroke("Label_physic_defense_offset", Colors.strokeBlack, 1)
	self:enableLabelStroke("Label_magic_defense_value", Colors.strokeBlack, 1)
	--self:enableLabelStroke("Label_magic_defense_offset", Colors.strokeBlack, 1)
	 self:enableLabelStroke("Label_shi_count", Colors.strokeBlack, 1)
	 self:enableLabelStroke("Label_jingjie", Colors.strokeBlack, 1)
	 self:enableLabelStroke("Label_name", Colors.strokeBlack, 1)
	-- local label = self:getLabelByName("Label_have")
 --    if label then
 --        label:createStroke(Colors.strokeBrown, 1)
 --    end
 --    label = self:getLabelByName("Label_danyao")
 --    if label then
 --        label:createStroke(Colors.strokeBrown, 1)
 --    end
 --    label = self:getLabelByName("Label_yinbi")
 --    if label then
 --        label:createStroke(Colors.strokeBrown, 1)
 --    end
 --    label = self:getLabelByName("Label_jinbi")
 --    if label then
 --        label:createStroke(Colors.strokeBrown, 1)
 --    end
 --    label = self:getLabelByName("Label_cost1_1")
 --    if label then
 --        label:createStroke(Colors.strokeBrown, 1)
 --    end
 --    label = self:getLabelByName("Label_cost2_1")
 --    if label then
 --        label:createStroke(Colors.strokeBrown, 1)
 --    end
 --    label = self:getLabelByName("Label_cost3_1")
 --    if label then
 --        label:createStroke(Colors.strokeBrown, 1)
 --    end
 --    label = self:getLabelByName("Label_cost2_2")
 --    if label then
 --        label:createStroke(Colors.strokeBrown, 1)
 --    end
 --    label = self:getLabelByName("Label_cost3_2")
 --    if label then
 --        label:createStroke(Colors.strokeBrown, 1)
 --    end

 -- 	local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(knightId)
	-- self:_initBaseInfo( knightInfo )
	-- self:_checkFullAttribute(knightInfo)
	-- self:_updateTrainingOffset(knightInfo)
	-- self:_updateCostCount()
	-- self:_updateLoadingBar(knightInfo, false, true)

	-- self:_updateTrainingBtns(knightInfo)

	if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then 
		local EffectNode = require("app.common.effects.EffectNode")
		local effect  = EffectNode.new("effect_jinjiechangjing")
    	effect:play()
    	local left = self:getWidgetByName("ImageView_6065")
    	if left then 
    		left:addNode(effect)
    	end
    end

end

function HeroTrainingLayer:onLayerUnload(  )
	uf_eventManager:removeListenerWithTarget(self)
end

function HeroTrainingLayer:onLayerEnter( ... )
	-- 和谐版本中，需要隐藏元宝历炼选择项
	if IS_HEXIE_VERSION then
		self:callAfterFrameCount(1, function ( ... )
			
    		self:showWidgetByName("Panel_jinbi", false)
    		local panel = self:getWidgetByName("Panel_yinbi")
    		if panel then 
    			local posx, posy = panel:getPosition()
    			panel:setPosition(ccp(posx, posy - 20))
    		end

    		panel = self:getWidgetByName("Panel_danyao")
    		if panel then 
    			local posx, posy = panel:getPosition()
    			panel:setPosition(ccp(posx, posy - 10))
    		end
		end)
    end

	local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(self._mainKnightId)
	self:_initBaseInfo( knightInfo )
	self:_checkFullAttribute(knightInfo)
	self:_updateTrainingOffset(knightInfo)
	self:_updateCostCount()
	self:_updateLoadingBar(knightInfo, false, true)

	self:_updateTrainingBtns(knightInfo)

	local knightPanel =self:getWidgetByName("Panel_knight_pic")
	local knightDizuo = self:getWidgetByName("ImageView_dizou")
	local baseId = G_Me.bagData.knightsData:getBaseIdByKnightId(self._mainKnightId)
	if not knightPanel or not knightDizuo or baseId < 1 then 
		return 
	end

	local callback = nil
	self:showWidgetByName("Panel_attack", false)
	self:showWidgetByName("Panel_hp", false)
	self:showWidgetByName("Panel_physic_defense", false)
	self:showWidgetByName("Panel_magic_defense", false)
	
	local dressKnightId = 0
    if self._mainKnightId == G_Me.formationData:getMainKnightId() then 
        dressKnightId = G_Me.dressData:getDressedPic()
    end

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
    	self:showWidgetByName("Panel_knight_pic", true)
    	--end)
    end, dressKnightId)
    ani:setPositionXY(centerPtx, centerPty)
    ani:play()
    ani:setScale(knightPanel:getScale())
    knightDizuo:addNode(ani)

    callback = function ( ... )
    	self:showWidgetByName("Panel_attack", true)
		self:showWidgetByName("Panel_hp", true)
		self:showWidgetByName("Panel_physic_defense", true)
		self:showWidgetByName("Panel_magic_defense", true)

    	GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_attack"), 
    		self:getWidgetByName("Panel_hp") }, true, 0.2, 3, 50)
    	GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_physic_defense"), 
    		self:getWidgetByName("Panel_magic_defense") }, false, 0.2, 3, 50, function ( ... )
    			self:_initBubbleEffect()
    		end)
    end
end

function HeroTrainingLayer:adapterLayer(  )
	self:adapterWidgetHeight("Panel_content", "", "Panel_cost", 0, 0)
end

function HeroTrainingLayer:_initBubbleEffect( ... )
	local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId( self._mainKnightId )
	self:_updateLoadingBar(knightInfo, true)
end

function HeroTrainingLayer:_initBaseInfo( knightInfo )
		local baseId = knightInfo and knightInfo["base_id"] or 0
		local knightBaseInfo = knight_info.get(baseId)

		local level = knightInfo and knightInfo["level"] or 0

		if knightBaseInfo then
			local spritePanel = self:getWidgetByName("Panel_knight_pic")
			if spritePanel and knightBaseInfo then
				local picSize = spritePanel:getSize()

				local resId = knightBaseInfo.res_id
				if self._mainKnightId == G_Me.formationData:getMainKnightId() then 
        			resId = G_Me.dressData:getDressedPic()
    			end

    			local knightPic = require("app.scenes.common.KnightPic")
				local pic = knightPic.createKnightButton(resId, spritePanel, "mainKnight_button", self, function ( ... )
					if CCDirector:sharedDirector():getSceneCount() > 1 then 
						uf_sceneManager:popScene()
					else
						uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroFosterScene").new(1, self._mainKnightId))
					end
				end, true)
				local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
        		EffectSingleMoving.run(pic, "smoving_idle", nil, {}, 1+ math.floor(math.random()*30))
				--local pic = knightPic.createKnightPic(knightBaseInfo.res_id, spritePanel)
				pic:setTag(1000)
			end

			local jieShu = self:getLabelByName("Label_jingjie")
			if jieShu ~= nil then
				if knightBaseInfo then
					jieShu:setColor(Colors.getColor(knightBaseInfo and knightBaseInfo.quality or 1))
					jieShu:setText(knightBaseInfo.advanced_level > 0 and ("+"..knightBaseInfo.advanced_level) or "")
				else
					jieShu:setText("")
				end
			end

			local name = self:getLabelByName("Label_name")
			if name ~= nil then
				name:setColor(Colors.getColor(knightBaseInfo and knightBaseInfo.quality or 1))
				name:setText(knightBaseInfo ~= nil and knightBaseInfo.name or "")
			end

			--GlobalFunc.loadStars(self, 
			--	{"ImageView_star_1", "ImageView_star_2","ImageView_star_3","ImageView_star_4","ImageView_star_5", "ImageView_star_6",},
			--	knightBaseInfo and knightBaseInfo.star or 0, 1, G_Path.getNormalStarIcon())
		end
end

-- 检查是否满属性了
function HeroTrainingLayer:_checkFullAttribute( knightInfo )
	local baseId = knightInfo and knightInfo["base_id"] or 0

	local trainingData = knightInfo and knightInfo["training"] or nil
	local calcTrainingRange = G_Me.bagData.knightsData:getKnightTrainingRange(knightInfo and knightInfo["id"] or 0)

	if trainingData then
		self._isOnTraining = trainingData["hp_tmp"] < 10000 and trainingData["at_tmp"] < 10000 
		and trainingData["pd_tmp"] < 10000 and trainingData["md_tmp"] < 10000

		--self._hasGrowupAttribute = not self._isOnTraining
		--__Log("self._hasGrowupAttribute:%d", self._hasGrowupAttribute and 1 or 0)

		local maxRange = calcTrainingRange and calcTrainingRange["hp_max"] or 0
		self._isFullAttribute = self._isFullAttribute and (trainingData["hp"] == maxRange and maxRange > 0)
		maxRange = calcTrainingRange and calcTrainingRange["at_max"] or 0
		self._isFullAttribute = self._isFullAttribute and (trainingData["at"] == maxRange and maxRange > 0)
		maxRange = calcTrainingRange and calcTrainingRange["pd_max"] or 0
		self._isFullAttribute = self._isFullAttribute and (trainingData["pd"] == maxRange and maxRange > 0)
		maxRange = calcTrainingRange and calcTrainingRange["md_max"] or 0
		self._isFullAttribute = self._isFullAttribute and (trainingData["md"] == maxRange and maxRange > 0)
	end
end

function HeroTrainingLayer:_updateTrainingInfo( knightInfo, runProgress )
	self:_checkFullAttribute(knightInfo)
	self:_updateTrainingOffset(knightInfo)
	self:_updateCostCount()

	self:_updateLoadingBar(knightInfo, runProgress)
end

function HeroTrainingLayer:_updateLoadingBar( knightInfo, runProgress, firstTime )
	runProgress = runProgress or false
	firstTime = firstTime or false
	local baseId = knightInfo and knightInfo["base_id"] or 0

	local trainingData = knightInfo and knightInfo["training"] or nil
	local calcTrainingRange = G_Me.bagData.knightsData:getKnightTrainingRange(knightInfo and knightInfo["id"] or 0)

	if not self._hpBubble then 
		self._hpBubble = HeroJingJieBubbleEffect.new("red")
		self._hpBubble:setPercent(0)
		self._hpBubble:setPosition(ccp(0, 52))
		local widget = self:getWidgetByName("ImageView_shadow_hp")
		if widget then 
			widget:addNode(self._hpBubble, 0, 1111)
		end
	end
	if not self._attackBubble then 
		self._attackBubble = HeroJingJieBubbleEffect.new("green")
		self._attackBubble:setPercent(0)
		self._attackBubble:setPosition(ccp(0, 52))
		local widget = self:getWidgetByName("ImageView_shadow_attack")
		if widget then 
			widget:addNode(self._attackBubble, 0, 1111)
		end
	end
	if not self._pDefBubble then 
		self._pDefBubble = HeroJingJieBubbleEffect.new("blue")
		self._pDefBubble:setPercent(0)
		self._pDefBubble:setPosition(ccp(0, 52))
		local widget = self:getWidgetByName("ImageView_shadow_pdef")
		if widget then 
			widget:addNode(self._pDefBubble, 0, 1111)
		end
	end
	if not self._mDefBubble then 
		self._mDefBubble = HeroJingJieBubbleEffect.new("purple")
		self._mDefBubble:setPercent(0)
		self._mDefBubble:setPosition(ccp(0, 52))
		local widget = self:getWidgetByName("ImageView_shadow_mdef")
		if widget then 
			widget:addNode(self._mDefBubble, 0, 1111)
		end
	end

	local maxRange = calcTrainingRange and calcTrainingRange["hp_max"] or 0
	local label = self:getLabelByName("Label_hp_value")	
	if label then
		local text = ""
		if not firstTime then 
			text = trainingData and (""..trainingData["hp"].."/"..maxRange) or "0/"..maxRange
		else
			text = "0/"..maxRange
		end
		
		if not firstTime and trainingData and trainingData["hp"] == maxRange and maxRange > 0 then
			text = text..G_lang:get("LANG_KNIGHT_TRAINING_TIP_FULL")
		end
		label:setText(text)

		if runProgress and self._hpBubble then 	
			local completeRait = 0
			if maxRange > 0 then
				completeRait = trainingData and (((trainingData["hp"] or 0)*100) / maxRange) or 0
			else 
				completeRait = 0
			end		
			self._hpBubble:setPercent(completeRait, 0.5)
		end
	end	

	maxRange = calcTrainingRange and calcTrainingRange["at_max"] or 0
	label = self:getLabelByName("Label_attack_value")
	if label then
		local text = ""
		if not firstTime then 
			text = trainingData and (""..trainingData["at"].."/"..maxRange) or "0".."/"..maxRange
		else
			text = "0/"..maxRange
		end

		if not firstTime and trainingData and trainingData["at"] == maxRange and maxRange > 0 then
			text = text..G_lang:get("LANG_KNIGHT_TRAINING_TIP_FULL")
		end
		label:setText(text)

		if runProgress and self._attackBubble then 	
			local completeRait = 0
			if maxRange > 0 then
				completeRait = trainingData and (((trainingData["at"] or 0)*100) / maxRange) or 0
			else 
				completeRait = 0
			end		
			self._attackBubble:setPercent(completeRait, 0.5)
		end
	end
	
	maxRange = calcTrainingRange and calcTrainingRange["pd_max"] or 0
	label = self:getLabelByName("Label_physic_defense_value")
	if label then
		local text = ""
		if not firstTime then 
			text = trainingData and (""..trainingData["pd"].."/"..maxRange) or "0".."/"..maxRange
		else
			text = "0/"..maxRange
		end
		if not firstTime and trainingData and trainingData["pd"] == maxRange and maxRange > 0 then
			text = text..G_lang:get("LANG_KNIGHT_TRAINING_TIP_FULL")
		end
		label:setText(text)

		if runProgress and self._pDefBubble then 	
			local completeRait = 0
			if maxRange > 0 then
				completeRait = trainingData and (((trainingData["pd"] or 0)*100) / maxRange) or 0
			else 
				completeRait = 0
			end		
			self._pDefBubble:setPercent(completeRait, 0.5)
		end
	end

	maxRange = calcTrainingRange and calcTrainingRange["md_max"] or 0
	label = self:getLabelByName("Label_magic_defense_value")
	if label then
		local text = ""
		if not firstTime then 
			text = trainingData and (""..trainingData["md"].."/"..maxRange) or "0".."/"..maxRange
		else
			text = "0/"..maxRange
		end
		if not firstTime and trainingData and trainingData["md"] == maxRange and maxRange > 0 then
			text = text..G_lang:get("LANG_KNIGHT_TRAINING_TIP_FULL")
		end
		label:setText(text)

		if runProgress and self._mDefBubble then 	
			local completeRait = 0
			if maxRange > 0 then
				completeRait = trainingData and (((trainingData["md"] or 0)*100) / maxRange) or 0
			else 
				completeRait = 0
			end		
			self._mDefBubble:setPercent(completeRait, 0.5)
		end
	end

	-- local loadingBar = self:getLoadingBarByName("LoadingBar_hp")
	-- if loadingBar then
	-- 	local maxRange = calcTrainingRange and calcTrainingRange["hp_max"] or 0
	-- 	local completeRait = 0
	-- 	if maxRange > 0 then
	-- 		completeRait = trainingData and (((trainingData["hp"] or 0)*100) / maxRange) or 0
	-- 	else 
	-- 		completeRait = 0
	-- 	end

	-- 	if runProgress then
	-- 		loadingBar:runToPercent(completeRait, 0.5)
	-- 	else
	-- 		loadingBar:setPercent(completeRait)
	-- 	end

		
	-- end

	-- loadingBar = self:getLoadingBarByName("LoadingBar_attack")
	-- if loadingBar then
	-- 	local maxRange = calcTrainingRange and calcTrainingRange["at_max"] or 0
	-- 	local completeRait = 0
	-- 	if maxRange > 0 then
	-- 		completeRait = trainingData and (((trainingData["at"] or 0)*100) / maxRange) or 0
	-- 	else 
	-- 		completeRait = 0
	-- 	end
		
	-- 	if runProgress then
	-- 		loadingBar:runToPercent(completeRait, 0.5)
	-- 	else
	-- 		loadingBar:setPercent(completeRait)
	-- 	end

	-- 	if not self._attackBubble then 
	-- 		self._attackBubble = HeroJingJieBubbleEffect.new("green")
	-- 		self._attackBubble:setPercent(0)
	-- 		loadingBar:addNode(self._attackBubble, 0, 1111)
	-- 		self._attackBubble:setRotation(90)
	-- 	end

	-- 	if runProgress and self._attackBubble then 			
	-- 		self._attackBubble:setPercent(completeRait, 0.5)
	-- 	end
	-- end

	-- loadingBar = self:getLoadingBarByName("LoadingBar_physic_defense")
	-- if loadingBar then
	-- 	local maxRange = calcTrainingRange and calcTrainingRange["pd_max"] or 0
	-- 	local completeRait = 0
	-- 	if maxRange > 0 then
	-- 		completeRait = trainingData and (((trainingData["pd"] or 0)*100) / maxRange) or 0
	-- 	else 
	-- 		completeRait = 0
	-- 	end
		
	-- 	if runProgress then
	-- 		loadingBar:runToPercent(completeRait, 0.5)
	-- 	else
	-- 		loadingBar:setPercent(completeRait)
	-- 	end

	-- 	if not self._pDefBubble then 
	-- 		self._pDefBubble = HeroJingJieBubbleEffect.new("blue")
	-- 		self._pDefBubble:setPercent(0)
	-- 		loadingBar:addNode(self._pDefBubble, 0, 1111)
	-- 		self._pDefBubble:setRotation(90)
	-- 	end

	-- 	if runProgress and self._pDefBubble then 			
	-- 		self._pDefBubble:setPercent(completeRait, 0.5)
	-- 	end
	-- end

	-- loadingBar = self:getLoadingBarByName("LoadingBar_magic_defense")
	-- if loadingBar then
	-- 	local maxRange = calcTrainingRange and calcTrainingRange["md_max"] or 0
	-- 	local completeRait = 0
	-- 	if maxRange > 0 then
	-- 		completeRait = trainingData and (((trainingData["md"] or 0)*100) / maxRange) or 0
	-- 	else 
	-- 		completeRait = 0
	-- 	end
		
	-- 	if runProgress then
	-- 		loadingBar:runToPercent(completeRait, 0.5)
	-- 	else
	-- 		loadingBar:setPercent(completeRait)
	-- 	end

	-- 	if not self._mDefBubble then 
	-- 		self._mDefBubble = HeroJingJieBubbleEffect.new("purple")
	-- 		self._mDefBubble:setPercent(0)
	-- 		loadingBar:addNode(self._mDefBubble, 0, 1111)
	-- 		self._mDefBubble:setRotation(90)
	-- 	end

	-- 	if runProgress and self._mDefBubble then 			
	-- 		self._mDefBubble:setPercent(completeRait, 0.5)
	-- 	end
	-- end
end

function HeroTrainingLayer:_updateCostCount(  )
	local label = self:getLabelByName("Label_shujian_count")
	if label then
		local hasShujianCost = G_Me.bagData:getPropCount(9)
		local shujianCost, yinbiCost, jinbiCost = self:_getCostCount()
		label:setColor(hasShujianCost >= shujianCost and ccc3(0x50, 0x3e, 0x32) or Colors.titleRed)
		label:setText(hasShujianCost, true)
	end
end

-- 更新当前培养的属性值改变, 红色/绿色显示，并显示红色/绿色箭头
function HeroTrainingLayer:_updateTrainingOffset( knightInfo, playAnimation )
	playAnimation = playAnimation or false
	local baseId = knightInfo and knightInfo["base_id"] or 0
	local trainingData = knightInfo and knightInfo["training"] or nil

	self:_checkFullAttribute(knightInfo)

	local trainingOffstAnimation = function ( labelName, value, playAnimation )
		value = value or 0
		local label = self:getLabelByName(labelName or "")
		if not label then
			return 
		end

		if not self._isOnTraining then
			value = 0
		end
		if value > 0 then
			label:setColor(Colors.titleGreen)
		elseif value < 0 then
			label:setColor(Colors.titleRed)
		else
			label:setColor(ccc3(0xfe, 0xf6, 0xd8))
		end
		label:setText( value >= 0 and ("+"..value) or (""..value) )

		if playAnimation then
			label:setScale(1.5)
			local scaleTo = CCScaleTo:create(0.7, 1)
			local ease = CCEaseSineOut:create(scaleTo)
			label:runAction(ease)
		end
	end

	self._curTrainingOffset = {}
	if self._isOnTraining then
		table.insert(self._curTrainingOffset, #self._curTrainingOffset + 1, trainingData and trainingData["hp_tmp"] or 0)
		table.insert(self._curTrainingOffset, #self._curTrainingOffset + 1, trainingData and trainingData["at_tmp"] or 0)
		table.insert(self._curTrainingOffset, #self._curTrainingOffset + 1, trainingData and trainingData["pd_tmp"] or 0)
		table.insert(self._curTrainingOffset, #self._curTrainingOffset + 1, trainingData and trainingData["md_tmp"] or 0)
	end

	trainingOffstAnimation("Label_hp_offset", self._curTrainingOffset[1] or 0, playAnimation )
	trainingOffstAnimation("Label_attack_offset", self._curTrainingOffset[2] or 0, playAnimation )
	trainingOffstAnimation("Label_physic_defense_offset", self._curTrainingOffset[3] or 0, playAnimation )
	trainingOffstAnimation("Label_magic_defense_offset", self._curTrainingOffset[4] or 0, playAnimation )

	local trainingArrowAnimation = function ( arrowName, labelName, offset )
		if not arrowName or not labelName then
			return 
		end
		local arrow = self:getImageViewByName(arrowName)
		if not arrow then 
			return 
		end
		local label = self:getWidgetByName(labelName)
		if not label then 
			return 
		end

		arrow:stopAllActions()
		local posx, posy = label:getPosition()
		posx = posx + 40
		if offset == 0 then 
			return arrow:setVisible(false)
		end

		arrow:setVisible(true)
		arrow:setOpacity(255)
		isGrowup = offset > 0
		arrow:setScale(isGrowup and 1.2 or 1.2)
		arrow:loadTexture(G_Path.getGrowupIcon(isGrowup))
		local moveDistUp = 20
		local moveDistDown = 20
		local startPosy = isGrowup and (posy - moveDistUp/2) or (posy + moveDistDown/2)

		local arr = CCArray:create()
		arr:addObject(CCResetPosition:create(arrow, ccp(posx, startPosy)))
		arr:addObject(CCResetOpacity:create(arrow, 255))
		local moveby = CCMoveBy:create(0.8, ccp(0, isGrowup and moveDistUp or -moveDistDown))
		arr:addObject(CCEaseIn:create(moveby, 0.3))
		arr:addObject(CCFadeOut:create(0.2))
		arrow:runAction(CCRepeatForever:create(CCSequence:create(arr)))
	end

	trainingArrowAnimation("Image_flag_hp", "Label_hp_offset", self._curTrainingOffset[1] and self._curTrainingOffset[1] or 0 )
	trainingArrowAnimation("Image_flag_attack", "Label_attack_offset", self._curTrainingOffset[2] and self._curTrainingOffset[2] or 0 )
	trainingArrowAnimation("Image_flag_physic", "Label_physic_defense_offset", self._curTrainingOffset[3] and self._curTrainingOffset[3] or 0 )
	trainingArrowAnimation("Image_magic_flag", "Label_magic_defense_offset", self._curTrainingOffset[4] and self._curTrainingOffset[4] or 0 )
end

-- 点击替换时，改变的属性飞到显示的当前属性上
function HeroTrainingLayer:_startFlyingTrainingOffset( knightInfo )
	local baseId = knightInfo and knightInfo["base_id"] or 0
	local trainingData = knightInfo and knightInfo["training"] or nil

	local doFlyLabel = function ( startLabel, endLabel, offsetValue )
		if type(startLabel) ~= "string" or type(endLabel) ~= "string" then
			return 
		end

		offsetValue = offsetValue or 0
		if offsetValue == 0 then
			return 
		end

		local startCtrl = self:getLabelByName(startLabel)
		local endCtrl = self:getWidgetByName(endLabel)
		if not startCtrl or not endCtrl then
			return 
		end

		local startPtx, startPty = startCtrl:convertToWorldSpaceXY(0, 0)
		local endPtx, endPty = endCtrl:convertToWorldSpaceXY(0, 0)
		local moveAction = CCMoveBy:create(0.5, ccp(endPtx - startPtx, endPty - startPty))
		local scaleUpAction = CCScaleTo:create(0.5, 2)
		local ease1 = CCEaseSineOut:create(CCSpawn:createWithTwoActions(moveAction, scaleUpAction))
		local scaleDownAction = CCScaleTo:create(0.3, 0.1)
		local ease2 = CCEaseSineOut:create(scaleDownAction)
		local callback = CCCallFuncN:create(function ( node )
			node:removeFromParentAndCleanup(true)
			self:_startGrowupAttribute()
			if startCtrl then 
				startCtrl:setColor(ccc3(0xfe, 0xf6, 0xd8))
				startCtrl:setText("+0")
			else
				__LogError("[Error] startCtrl is nil")
			end
		end)
		local actionArr = CCArray:create()
		actionArr:addObject(ease1)
		actionArr:addObject(ease2)
		actionArr:addObject(callback)

		local cloneLabel = startCtrl:clone()
		local cloneLabelPtx, cloneLabelPty = self:convertToNodeSpaceXY(startPtx, startPty)
		cloneLabel:setPositionXY(cloneLabelPtx, cloneLabelPty)
		self:addChild(cloneLabel)

		local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.KNIGHT_TRAINING)

		cloneLabel:runAction(CCSequence:create(actionArr))

		if offsetValue ~= 0 then 
			local effect = nil 
			effect = EffectNode.new("effect_blue_add", 
        		function(event)
        			if event == "finish" then 
        				effect:removeFromParentAndCleanup(true)
        			end
        		end)
			endCtrl:addNode(effect, 1000)
			effect:play()
		end
	end

	doFlyLabel("Label_hp_offset", "Label_hp_value", self._curTrainingOffset[1] or 0)

	doFlyLabel("Label_attack_offset", "Label_attack_value", self._curTrainingOffset[2] or 0)

	doFlyLabel("Label_physic_defense_offset", "Label_physic_defense_value", self._curTrainingOffset[3] or 0)

	doFlyLabel("Label_magic_defense_offset", "Label_magic_defense_value", self._curTrainingOffset[4] or 0)

	self:enableWidgetByName("Button_LiLian", false)

	local stopFlagAction = function ( imageName )
		if not imageName then 
			return 
		end

		local widget = self:getWidgetByName(imageName)
		if not widget then 
			return 
		end

		widget:stopAllActions()
		widget:setVisible(false)
	end
	stopFlagAction("Image_flag_hp")
	stopFlagAction("Image_flag_attack")
	stopFlagAction("Image_flag_physic")
	stopFlagAction("Image_magic_flag")
end

-- 播放武将属性值进度球滚动动画
function HeroTrainingLayer:_startGrowupAttribute(  )
	if self._hasGrowupAttribute then
		return 
	end

	self._hasGrowupAttribute = true
	local CommonImageTip = require("app.scenes.common.CommonImageTip")
	local imgTip = CommonImageTip.showImageTip("ui/text/txt/zbyc_xilianchenggong.png")
	self:addChild(imgTip)
	local size = self:getSize()
	imgTip:setPosition(ccp(size.width/2, size.height*2/3))

	local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(self._mainKnightId)
	local trainingData = knightInfo and knightInfo["training"] or nil
	local calcTrainingRange = G_Me.bagData.knightsData:getKnightTrainingRange(knightInfo and knightInfo["id"] or 0)
	if not knightInfo or not trainingData or not calcTrainingRange then
		return 
	end

	local doGrowupAttribute = function ( labelName, loadingBarName, bubble, startValue, destValue, maxValue )
		if (startValue == destValue) or (startValue == maxValue) then
			return
		end

		 local label = self:getLabelByName(labelName)
		-- if label then
		-- 	local growupNumber = CCNumberGrowupAction:create(startValue, destValue, 0.5, function ( number )
		-- 		local text = ""..number.."/"..maxValue
		-- 		if number >= maxValue then
		-- 			text = text..G_lang:get("LANG_KNIGHT_TRAINING_TIP_FULL")
		-- 		end
		-- 		label:setText(text)
		-- 	end)
		-- 	label:runAction(growupNumber)
		-- end

		-- local loadingBar = self:getLoadingBarByName(loadingBarName)
		-- if loadingBar then
		-- 	loadingBar:runToPercent(destValue*100/maxValue, 0.8)
		-- end	
		if destValue >= maxValue then 
			label:setText(""..destValue.."/"..maxValue..G_lang:get("LANG_KNIGHT_TRAINING_TIP_FULL"))
		else
			label:setText(""..destValue.."/"..maxValue)
		end
		if bubble and bubble.setPercent then 
			bubble:setPercent(destValue*100/maxValue, 0.8)
		end
	end

	local maxRange = calcTrainingRange["hp_max"]
	local curValue = trainingData["hp"]
	local lastValue = curValue - (self._curTrainingOffset[1] or 0)
	doGrowupAttribute("Label_hp_value", "LoadingBar_hp", self._hpBubble, lastValue, curValue, maxRange )

	maxRange = calcTrainingRange["at_max"]
	curValue = trainingData["at"]
	lastValue = curValue - (self._curTrainingOffset[2] or 0)
	doGrowupAttribute("Label_attack_value", "LoadingBar_attack", self._attackBubble, lastValue, curValue, maxRange )

	maxRange = calcTrainingRange["pd_max"]
	curValue = trainingData["pd"]
	lastValue = curValue - (self._curTrainingOffset[3] or 0)
	doGrowupAttribute("Label_physic_defense_value", "LoadingBar_physic_defense", self._pDefBubble, lastValue, curValue, maxRange )

	maxRange = calcTrainingRange["md_max"]
	curValue = trainingData["md"]
	lastValue = curValue - (self._curTrainingOffset[4] or 0)
	doGrowupAttribute("Label_magic_defense_value", "LoadingBar_magic_defense", self._mDefBubble, lastValue, curValue, maxRange )

	self:enableWidgetByName("Button_LiLian", true)
end

function HeroTrainingLayer:_updateTrainingBtns( knightInfo )
	local trainingData = knightInfo and knightInfo["training"] or nil
	local valueHp = trainingData and trainingData["hp_tmp"] or -1
	valueHp = (valueHp == 10000) and 0 or valueHp
	local valueAt = trainingData and trainingData["at_tmp"] or -1
	valueAt = (valueAt == 10000) and 0 or valueAt
	local valuePd = trainingData and trainingData["pd_tmp"] or -1
	valuePd = (valuePd == 10000) and 0 or valuePd
	local valueMd = trainingData and trainingData["md_tmp"] or -1
	valueMd = (valueMd == 10000) and 0 or valueMd
	local allValuePositive = valueHp >= 0 and valueAt >= 0 and valuePd >= 0 and valueMd >= 0 
	local allIsZero = valueHp == 0 and valueAt == 0 and valuePd == 0 and valueMd == 0
	allValuePositive = allValuePositive and not allIsZero
	self:showWidgetByName("Button_LiLian", not allValuePositive)
	self:showWidgetByName("Button_Replace_M", allValuePositive)
	self:showWidgetByName("Button_Replace", not allValuePositive and not allIsZero and self._isOnTraining)
end

function HeroTrainingLayer:_onCancelBtnClick( ... )
	G_HandlersManager.heroUpgradeHandler:sendGiveUpTrainingKnight(self._mainKnightId)
end

function HeroTrainingLayer:_onLilianClick( ... )

	if self._isFullAttribute then
		return G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_TRAINING_TIP_FULL_TRAINING"))
	end

	local xilianUnlock, canXiLian = G_Me.bagData.knightsData:isKnightCanTraining(self._mainKnightId)
	if not xilianUnlock then 
		local funLevelConst = require("app.const.FunctionLevelConst")
	    return G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.KNIGHT_TRAINING)
	end

	if not canXiLian then
		if xilianUnlock then 
			return G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_TRAINING_TIP_FULL_TRAINING"))
		else
			return G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_TRAINING_TIP_CANOT_TRAINING"))
		end
	end

	self:_doTraining()
end

function HeroTrainingLayer:_onSelectTrainingClick(  )
	local heroTraining = require("app.scenes.herofoster.HeroTrainingSelect")
	heroTraining.showTrainingSelectLayer(uf_sceneManager:getCurScene(), function ( count )
		self:_updateTrainingTimes(count)
	end)
end

function HeroTrainingLayer:_updateTrainingTimes( count )
	self._trainingTimes = count or 1
	local trainingTimes = self:getLabelByName("Label_xilian_times")
	if trainingTimes then
		trainingTimes:setText(G_lang:get("LANG_XILIAN_TIMES", {times = self._trainingTimes}))
	end

	self:showTextWithLabel("Label_cost1_1", 5*self._trainingTimes)

	self:showTextWithLabel("Label_cost2_1", 4*self._trainingTimes)
	self:showTextWithLabel("Label_cost2_2", 3000*self._trainingTimes)

	self:showTextWithLabel("Label_cost3_1", 3*self._trainingTimes)
	self:showTextWithLabel("Label_cost3_2", 5*self._trainingTimes)
end

function HeroTrainingLayer:_doTraining(  )
	if self:_checkResourcesEnough() then
		G_HandlersManager.heroUpgradeHandler:sendTrainingKnight(self._mainKnightId, self._trainingType, self._trainingTimes)
	end
end

function HeroTrainingLayer:_getCostCount( ... )
	local shujianCost = 0
	local yinbiCost = 0
	local jinbiCost = 0
	if self._trainingType == 1 then
		shujianCost = 5
	elseif self._trainingType == 2 then
		shujianCost = 4
		yinbiCost = 3000
	elseif self._trainingType == 3 then
		shujianCost = 3
		jinbiCost = 5
	end

	shujianCost = shujianCost * self._trainingTimes
	yinbiCost = yinbiCost * self._trainingTimes
	jinbiCost = jinbiCost * self._trainingTimes

	return shujianCost, yinbiCost, jinbiCost
end

function HeroTrainingLayer:_checkResourcesEnough(  )
	local shujianCost, yinbiCost, jinbiCost = self:_getCostCount()

	-- shujianCost = shujianCost * self._trainingTimes
	-- yinbiCost = yinbiCost * self._trainingTimes
	-- jinbiCost = jinbiCost * self._trainingTimes

	if shujianCost > 0 and not G_Me.bagData:hasEnoughProp( 9, shujianCost ) then
		local itemInfo = item_info.get(9)
		local itemName = itemInfo ~= nil and itemInfo.name or G_lang:get("LANG_RES_NAME")
		require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_ITEM, 9,
			GlobalFunc.sceneToPack("app.scenes.herofoster.HeroDevelopScene", {KnightConst.KNIGHT_TYPE.KNIGHT_TRAINING, self._mainKnightId}))
		--G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_TRAINING_TIP_LACKOF_RES", {resName=itemName}) )
		return false
	end

	if yinbiCost > 0 and not (G_Me.userData.money >= yinbiCost) then
		require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_MONEY, 0,
			GlobalFunc.sceneToPack("app.scenes.herofoster.HeroDevelopScene", {KnightConst.KNIGHT_TYPE.KNIGHT_TRAINING, self._mainKnightId}))
		--G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_TRAINING_TIP_LACKOF_RES", {resName=G_lang:get("LANG_SILVER")}) )
		return false
	end

	if jinbiCost > 0 and not (G_Me.userData.money >= jinbiCost) then
		G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_TRAINING_TIP_LACKOF_RES", {resName=G_lang:get("LANG_GOLDEN")}) )
		return false
	end

	return true
end

function HeroTrainingLayer:_onReplaceClick( ... )
	if self._isOnTraining then
		G_HandlersManager.heroUpgradeHandler:sendSaveTrainingKnight(self._mainKnightId)
	end
end

function HeroTrainingLayer:_onTrainingTypeChange( trainingType )
	self._trainingType = trainingType

	self:_updateCostCount()
end

function HeroTrainingLayer:_onTrainingKnighRet( ret )
	if ret == NetMsg_ERROR.RET_OK then
		self:_updateCostCount()
		local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(self._mainKnightId)
		--self:_updateTrainingInfo( knightInfo )
		self._hasGrowupAttribute = false
		self:_updateTrainingOffset(knightInfo, true)
		self:_updateTrainingBtns(knightInfo)

		--G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_TRAINING_TIP_TRAINING_SUCCESS"))
	end
end

function HeroTrainingLayer:_onSaveTrainingKnighRet( ret )
	if ret == NetMsg_ERROR.RET_OK then
		local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(self._mainKnightId)
		self:_checkFullAttribute(knightInfo)
		--self:_updateTrainingInfo( knightInfo, true )
		self:_startFlyingTrainingOffset(knightInfo)
		self:_updateTrainingBtns(nil)

		--G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_TRAINING_TIP_REPLACE_SUCCESS"))
	end
end

function HeroTrainingLayer:_onGiveUpTrainingKnighRet( ret )
	--if ret == NetMsg_ERROR.RET_OK then
	--	local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(self._mainKnightId)
	--	self:_updateTrainingInfo( knightInfo )
	--	self:_updateTrainingBtns(knightInfo)

	--	G_MovingTip:showMovingTip("成功放弃厉练值!")
	--end
end

return HeroTrainingLayer
