-- HeroGodAttrPreviewLargeLayer.lua

local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local HeroGodAttrPreviewLargeLayer = class("HeroGodAttrPreviewLargeLayer", UFCCSModelLayer)
require "app.cfg.knight_info"
local KnightConst = require("app.const.KnightConst")
local HeroGodCommon = require "app.scenes.herofoster.god.HeroGodCommon"
local knightPic = require("app.scenes.common.KnightPic")

local findIdInTable = function( t, value ) 
	if type(t) ~= "table" or not value then
		return false
	end

	for key, obj in pairs(t) do 
		if obj == value then
			return true
		end
	end

	return false
end


function HeroGodAttrPreviewLargeLayer.show( knightId, nextKnightBaseInfo, isPreview, isHandBook, ... )
	local layer = HeroGodAttrPreviewLargeLayer.new("ui_layout/HeroGod_AttrPreview2.json", Colors.modelColor, knightId, nextKnightBaseInfo, isPreview, isHandBook, ...)
	uf_sceneManager:getCurScene():addChild(layer)
	return layer
end

function HeroGodAttrPreviewLargeLayer:ctor( json, color, knightId, nextKnightBaseInfo, isPreview, isHandBook, ... )

	self._knightId = knightId or 0

	self._isPreview = isPreview or false -- 是否是预览界面进来的
	self._isHandBook = isHandBook or false -- 是否是图鉴进来的

	self._nextKnightBaseInfo = nextKnightBaseInfo

	self._knightBaseInfo = knight_info.get(self._nextKnightBaseInfo.god_pre_id)

	self._knightInfo = nil
	if self._knightId > 0 then
		self._knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(self._knightId)
	end
	

	

	self.super.ctor(self, json, ...)
end

function HeroGodAttrPreviewLargeLayer:onLayerLoad( ... )
	self:_initWiget()
	
end

function HeroGodAttrPreviewLargeLayer:onLayerEnter( ... )
	self:showAtCenter(true)
	self:closeAtReturn(true)
	self:setClickClose(true)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_back"), "smoving_bounce")
	EffectSingleMoving.run(self:getWidgetByName("Image_click_continue"), "smoving_wait", nil , {position = true} )
end

function HeroGodAttrPreviewLargeLayer:_resetCellPos(baseY)

	local panel = self:getPanelByName("Panel_Tianfu")
	if panel:isVisible() then
		panel:setPositionY(panel:getPositionY() + baseY)
	end

	local panel = self:getPanelByName("Panel_Skill")
	if panel:isVisible() then
		panel:setPositionY(panel:getPositionY() + baseY)
	end

	local panel = self:getPanelByName("Panel_Attr")
	if panel:isVisible() then
		panel:setPositionY(panel:getPositionY() + baseY)
	end

	local panel = self:getPanelByName("Panel_Pinzhi")
	if panel:isVisible() then
		panel:setPositionY(panel:getPositionY() + baseY)
	end

	local panel = self:getPanelByName("Panel_Hero")
	if panel:isVisible() then
		panel:setPositionY(panel:getPositionY() + baseY)
	end
end

function HeroGodAttrPreviewLargeLayer:_initWiget()


	local scrollView = self:getScrollViewByName("ScrollView_Panel")
	if scrollView then
		local bottomY = 3
		local scrollSize = scrollView:getInnerContainerSize()

		if self._knightInfo then
			bottomY = self:_loadTianfuPanel(self._nextKnightBaseInfo, bottomY, self._knightInfo.passive_skill or {})
		else
			bottomY = self:_loadTianfuPanel(self._nextKnightBaseInfo, bottomY, nil)
		end
		if self._knightInfo then
			bottomY = self:_loadSkillPanel(self._nextKnightBaseInfo, self._knightInfo.halo_level, bottomY, scrollSize.height)
		else
			bottomY = self:_loadSkillPanel(self._nextKnightBaseInfo, 1, bottomY, scrollSize.height)
		end
		bottomY = self:_loadAttrPanel(bottomY)
		bottomY = self:_loadPinzhiPanel(bottomY)
		bottomY = self:_loadHeroPanel(bottomY)

		scrollView:setInnerContainerSize(CCSizeMake(scrollSize.width, bottomY))
		local scrollViewHeight = scrollView:getContentSize().height

		local attrPanel = self:getPanelByName("Panel_Attr")
		if bottomY < attrPanel:getContentSize().height + 10  then
			self:getPanelByName("Panel_Attr"):setPositionY(scrollViewHeight - bottomY)

			local backImage = self:getImageViewByName("Image_back")
			local titleImage = self:getImageViewByName("Image_Title")
			local backPanel = self:getPanelByName("panel_back")
			local size = backImage:getSize()
			local DIFFER_HEIGHT = 200
			backImage:setSize(CCSize(size.width, size.height - DIFFER_HEIGHT))
			titleImage:setPositionY(titleImage:getPositionY() - DIFFER_HEIGHT / 2)
			local size = backPanel:getSize()
			backPanel:setSize(CCSize(size.width, size.height - DIFFER_HEIGHT))
			backPanel:setPositionY(backPanel:getPositionY() + DIFFER_HEIGHT / 2)
			scrollView:setSize(CCSizeMake(scrollSize.width, bottomY - DIFFER_HEIGHT))
			scrollView:setInnerContainerSize(CCSizeMake(scrollSize.width, bottomY - DIFFER_HEIGHT))
			
			attrPanel:setPositionY(attrPanel:getPositionY() - DIFFER_HEIGHT)
			local continueImage = self:getImageViewByName("Image_click_continue")
			continueImage:setPositionY(continueImage:getPositionY() + DIFFER_HEIGHT / 2)
		elseif bottomY < scrollViewHeight - 10 then
			self:_resetCellPos(scrollViewHeight - bottomY)
		end
		
	end

	HeroGodCommon.trainingArrowAnimation(self, "Image_22", "Label_value22", true)
	HeroGodCommon.trainingArrowAnimation(self, "Image_5", "Label_value5", true)
	HeroGodCommon.trainingArrowAnimation(self, "Image_6", "Label_value6", true)
	HeroGodCommon.trainingArrowAnimation(self, "Image_7", "Label_value7", true)
	HeroGodCommon.trainingArrowAnimation(self, "Image_8", "Label_value8", true)
	HeroGodCommon.trainingArrowAnimation(self, "Image_13", "Label_value13", true)
	HeroGodCommon.trainingArrowAnimation(self, "Image_14", "Label_value14", true)
	HeroGodCommon.trainingArrowAnimation(self, "Image_15", "Label_value15", true)
	HeroGodCommon.trainingArrowAnimation(self, "Image_16", "Label_value16", true)

	self:_createStrokes()
end

function HeroGodAttrPreviewLargeLayer:_createStrokes()
	self:enableLabelStroke("Label_Pinzhi_Header", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_Attr_Header", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_Skill_Header", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_Tianfu_Header", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_Hero_Name1", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Hero_Name2", Colors.strokeBrown, 1)

end

function HeroGodAttrPreviewLargeLayer:_loadHeroPanel(bottomY)
	local panel = self:getPanelByName("Panel_Hero")
	if not panel then
		return bottomY
	end

	if not self._isPreview then
		panel:setVisible(false)
		return bottomY
	end

	local heroPicPanel = self:getPanelByName("Panel_Hero_Pic")
	local heroLabel = self:getLabelByName("Label_Name")

	local resId = self._nextKnightBaseInfo.res_id

	knightPic.createKnightPic(resId, heroPicPanel)

	heroLabel:setText(self._nextKnightBaseInfo.name)
	heroLabel:setColor(Colors.getColor(self._nextKnightBaseInfo.quality))
	heroLabel:createStroke(Colors.strokeBrown, 1)
	heroPicPanel:setScale(0.5)

	panel:setPositionY(bottomY)
	bottomY = bottomY + panel:getContentSize().height + 5
	return bottomY

end

function HeroGodAttrPreviewLargeLayer:_loadPinzhiPanel(bottomY)

	local panel = self:getPanelByName("Panel_Pinzhi")
	if not panel or not self._nextKnightBaseInfo or self._nextKnightBaseInfo.god_level % 3 ~= 0 then
		panel:setVisible(false)
		return bottomY
	end

	if self._knightBaseInfo.quality >= 6 then
		panel:setVisible(false)
		return bottomY
	end

	if self._isPreview then
		panel:setVisible(false)
		return bottomY
	end

	local baseInfos = {self._knightBaseInfo, self._nextKnightBaseInfo}

	for i = 1, #baseInfos do

		local icon = self:getImageViewByName("ImageView_Hero_Head" .. i)
		if icon then
			local heroPath = G_Path.getKnightIcon(baseInfos[i].res_id)
	    	icon:loadTexture(heroPath, UI_TEX_TYPE_LOCAL) 
		end

		local pingji = self:getImageViewByName("ImageView_Hero_Pinji" .. i)
		if pingji then
	    	pingji:loadTexture(G_Path.getAddtionKnightColorImage(baseInfos[i].quality)) 
	    end

	    local name = self:getLabelByName("Label_Hero_Name" .. i)
		if name then
			name:setColor(Colors.qualityColors[baseInfos[i].quality])
			name:setText(baseInfos[i].name)
		end
	end

	local panel = self:getPanelByName("Panel_Pinzhi")
	panel:setPositionY(bottomY)
	bottomY = bottomY + panel:getContentSize().height + 5
	
	return bottomY
end

-- 化神的加成属性
function HeroGodAttrPreviewLargeLayer:_getAttrsTablesGodInfo(knightBaseInfo, pulseLevel)

	if pulseLevel ~= 0 then

		local knightGodInfo = knight_god_info.get(knightBaseInfo.god_add_id, pulseLevel)
		if knightGodInfo then
			return {
				knightGodInfo.pulse_att,
				knightGodInfo.pulse_hp,
				knightGodInfo.pulse_phy_def,
				knightGodInfo.pulse_mag_def,
			}
		end
	else
		return {0,0,0,0}
	end
end

-- 属性
function HeroGodAttrPreviewLargeLayer:_getAttrsTablesInfo(knightBaseInfo, level, isPre)

	local preId = knightBaseInfo.god_pre_id

	local attrsTablesGodInfo
	local preKnightBaseInfo
	if preId > 0 then
		preKnightBaseInfo = knight_info.get(preId)
	end

	if isPre then
		attrsTablesGodInfo = self:_getAttrsTablesGodInfo(knightBaseInfo, KnightConst.KNIGHT_GOD_ZHENGJIE - 1)
	elseif preKnightBaseInfo then
		attrsTablesGodInfo = self:_getAttrsTablesGodInfo(preKnightBaseInfo, KnightConst.KNIGHT_GOD_ZHENGJIE - 1)
	end
	

	if not attrsTablesGodInfo then
		attrsTablesGodInfo = {0, 0, 0, 0}
	end

	-- 减去0阶的属性
	local zeroBaseInfo = knightBaseInfo
	for i = 1, KnightConst.KNIGHT_GOD_MAX_LEVEL * 2 do
		if zeroBaseInfo.god_level ~= 0 then
			zeroBaseInfo = knight_info.get(zeroBaseInfo.god_pre_id)
		end
	end

	return {
		G_Me.bagData.knightsData:calcAttackByBaseId(knightBaseInfo.id, level) + attrsTablesGodInfo[1] 
		- G_Me.bagData.knightsData:calcAttackByBaseId(zeroBaseInfo.id, level),

		knightBaseInfo.base_hp + (level - 1)*knightBaseInfo.develop_hp + attrsTablesGodInfo[2]
		- (zeroBaseInfo.base_hp + (level - 1)*zeroBaseInfo.develop_hp),

		knightBaseInfo.base_physical_defence + (level - 1)*knightBaseInfo.develop_physical_defence + attrsTablesGodInfo[3]
		- (zeroBaseInfo.base_physical_defence + (level - 1)*zeroBaseInfo.develop_physical_defence),

		knightBaseInfo.base_magical_defence + (level - 1)*knightBaseInfo.develop_magical_defence + attrsTablesGodInfo[4]
		- (zeroBaseInfo.base_magical_defence + (level - 1)*zeroBaseInfo.develop_magical_defence),
	}
end

function HeroGodAttrPreviewLargeLayer:_getUpAttrInfo(knightBaseInfo)
	local develop_attack
	if knightBaseInfo.damage_type == 1 then
	    develop_attack = knightBaseInfo.develop_physical_attack
    else
        develop_attack = knightBaseInfo.develop_magical_attack
    end

	return {
		develop_attack,
		knightBaseInfo.develop_hp,
		knightBaseInfo.develop_physical_defence,
		knightBaseInfo.develop_magical_defence,
	}
end

function HeroGodAttrPreviewLargeLayer:_loadAttrPanel(bottomY)

	local panel = self:getPanelByName("Panel_Attr")

	if self._isPreview then
		panel:setVisible(false)
		return bottomY
	end

	if not self._knightInfo then
		panel:setVisible(false)
		return bottomY
	end
	
	local nowAttrs = self:_getAttrsTablesInfo(self._knightBaseInfo, self._knightInfo.level, true)
	local nextAttrs = self:_getAttrsTablesInfo(self._nextKnightBaseInfo, self._knightInfo.level)

	local nowUpAttrs = self:_getUpAttrInfo(self._knightBaseInfo)
	local nextUpAttrs = self:_getUpAttrInfo(self._nextKnightBaseInfo)

	local godLevels = {G_Me.bagData.knightsData:getGodLevelByBaseInfo(self._knightBaseInfo, KnightConst.KNIGHT_GOD_ZHENGJIE - 1),
		G_Me.bagData.knightsData:getGodLevelByBaseInfo(self._nextKnightBaseInfo, 0)}

	local qualitys = {self._knightBaseInfo.quality, self._nextKnightBaseInfo.quality}

	for i = 1, #nowAttrs do
		self:showTextWithLabel("Label_value" .. i, nowAttrs[i])
	end

	for i = 1, #nextAttrs do
		self:showTextWithLabel("Label_value" .. (i + 4), nextAttrs[i])
	end

	for i = 1, #nowUpAttrs do
		self:showTextWithLabel("Label_value" .. (i + 8), nowUpAttrs[i])
	end

	for i = 1, #nextUpAttrs do
		self:showTextWithLabel("Label_value" .. (i + 12), nextUpAttrs[i])
	end

	for i = 1, 2 do
		local label = self:getLabelByName("Label_value" .. (i + 20))
		label:setText(HeroGodCommon.getDisplyLevel4(godLevels[i], qualitys[i]))
		label:setColor(Colors.getColor(qualitys[i]))
		label:createStroke(Colors.strokeBrown, 1)
	end

	local panel = self:getPanelByName("Panel_Attr")
	panel:setPositionY(bottomY)
	bottomY = bottomY + panel:getContentSize().height + 5

	return bottomY
end

function HeroGodAttrPreviewLargeLayer:isUnionSkillActive( knightInfo )
	if not knightInfo then 
		return false
	end

	local skillArr = {}
	local count = 0
	if knightInfo.release_knight_1 > 0 then 
		skillArr[knightInfo.release_knight_1] = 1
		count = count + 1
	end
	if knightInfo.release_knight_2 > 0 then 
		skillArr[knightInfo.release_knight_2] = 1
		count = count + 1
	end

	if count < 1 then  
		return false
	end
	
	local formationKnight = G_Me.formationData:getFirstTeamKnightIds()
	for key, value in pairs(formationKnight) do 
		local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(value)
		if knightInfo then
			local knightBaseInfo = knight_info.get(knightInfo["base_id"])
			if knightBaseInfo and skillArr[knightBaseInfo.advance_code] then 
				count = count - 1
				skillArr[knightBaseInfo.advance_code] = nil
			end
		end
	end

	local needKnightIds = {}
	for key, value in pairs(skillArr) do 
		table.insert(needKnightIds, #needKnightIds + 1, key)
	end

	return count == 0, needKnightIds
end

function HeroGodAttrPreviewLargeLayer:isUnionSkillActiveForDress( dressInfo )
	if not dressInfo then 
		return false
	end

	local skillArr = {}
	local count = 0
	if dressInfo.release_knight_id > 0 then 
		skillArr[dressInfo.release_knight_id] = 1
		count = count + 1
	end
	if count < 1 then  
		return false
	end
	
	local formationKnight = G_Me.formationData:getFirstTeamKnightIds()
	for key, value in pairs(formationKnight) do 
		local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(value)
		if knightInfo then
			local knightBaseInfo = knight_info.get(knightInfo["base_id"])
			if knightBaseInfo and skillArr[knightBaseInfo.advance_code] then 
				count = count - 1
				skillArr[knightBaseInfo.advance_code] = nil
			end
		end
	end

	local needKnightIds = {}
	for key, value in pairs(skillArr) do 
		table.insert(needKnightIds, #needKnightIds + 1, key)
	end

	return count == 0, needKnightIds
end

function HeroGodAttrPreviewLargeLayer:_loadSkillPanel(knightInfo, guanhuan, bottomY)

	local panel = self:getPanelByName("Panel_Skill")
	if not panel or not knightInfo or knightInfo.god_level % 3 ~= 0 then 
		panel:setVisible(false)
		return bottomY
	end

	local title = self:getWidgetByName("ImageView_Skill_Header")
	if title then 
		title:retain()
	end

	local dress = G_Me.dressData:getDressed() 
	local dressInfo = nil
	if dress and knightInfo.group == 0 then
		dressInfo = G_Me.dressData:getDressInfo(dress.base_id) 
	end
	local guanhuanLevel = guanhuan or 1
	panel:removeAllChildren()
	local size = panel:getSize()
	local initYPos = bottomY
	local startYpos = 5

	-- local validSkill, skillIds = self:isUnionSkillActive(knightInfo)
	if dress and knightInfo.group == 0 then 
		if G_Me.dressData:getDressed() and G_Me.dressData:getDressed().level >= 160 then
			validSkill, skillIds = self:isUnionSkillActiveForDress(dressInfo)
		end
	end

	-- 超级技能
	local super_unite_skill_id = knightInfo.super_unite_skill_id
	if super_unite_skill_id > 0 then 
		local skillInfo = skill_info.get(super_unite_skill_id)
		if skillInfo then
			local heSkill = "["..skillInfo.name.." Lv."..guanhuanLevel.."]  "..G_GlobalFunc.formatText(skillInfo.directions, 
	 			{num1 = skillInfo.formula_value1_1 + math.floor(skillInfo.formula_value1_add_1 / 10 *(guanhuanLevel - 1)),
	 			 num2 = skillInfo.formula_value1_2 + skillInfo.formula_value1_add_2*(guanhuanLevel - 1), 
	 			 test = (guanhuanLevel <= 1) and "" or G_lang:get("LANG_KNIGHT_GUANHUAN_ADDITION", {num3=math.floor(skillInfo.formula_value1_add_1 / 10 *(guanhuanLevel - 1))}) })

			local label = GlobalFunc.createGameLabel(heSkill, 22, Colors.inActiveSkill,
		 		nil, CCSizeMake(size.width - 50, 0), true)
			local labelSize = label:getSize()
			local labelPosX = size.width - labelSize.width/2 - 5
			label:setPosition(ccp(labelPosX, startYpos + labelSize.height/2))
			panel:addChild(label, 1, 100)
			startYpos = startYpos + labelSize.height

			labelPosX = labelPosX - labelSize.width/2
			local img = ImageView:create()
			img:loadTexture("ui/text/txt/icon_skill_chao.png", UI_TEX_TYPE_LOCAL)
			local imgSize = img:getSize()
			img:setPosition(ccp(labelPosX - imgSize.width/2 - 5, startYpos - imgSize.height/2))
			panel:addChild(img)

			startYpos = startYpos + 5
		end
	end

	-- 合击技能
	local unite_skill_id = dressInfo and dressInfo.unite_skill_id or knightInfo.unite_skill_id
	if unite_skill_id > 0 then 
		local skillInfo = skill_info.get(unite_skill_id)
		if skillInfo then
			
			if type(skillIds) == "table" and #skillIds > 0 then
				local label = GlobalFunc.createGameLabel(G_lang:get("LANG_KNIGHT_AQUIRE_KNIGHT_DESC"), 22, Colors.inActiveSkill, nil, nil, true)
				local labelSize = label:getSize()
			
				local underLine = GlobalFunc.createGameLabel("_", 22, Colors.inActiveSkill, nil, nil, true)
				local lineSize = underLine:getSize()
				underLine:setPositionXY(size.width - 15 -labelSize.width/2, startYpos + labelSize.height/2)
				panel:addChild(underLine)
				underLine:setScaleX(labelSize.width/lineSize.width + 1)

				panel:addChild(label, 1, 100)
				label:setPositionXY(size.width - 15 -labelSize.width/2, startYpos + labelSize.height/2)
				label:setName("__ACQUIRE_KNIGHT__")
				label:setTouchEnabled(true)
				self:registerWidgetClickEvent("__ACQUIRE_KNIGHT__", function ( ... )
					require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_KNIGHT, skillIds[1])
				end)
				startYpos = startYpos + labelSize.height
			end

			local heSkill = "["..skillInfo.name.." Lv."..guanhuanLevel.."]  "..G_GlobalFunc.formatText(skillInfo.directions, 
	 			{num1 = skillInfo.formula_value1_1 + math.floor(skillInfo.formula_value1_add_1 / 10 *(guanhuanLevel - 1)),
	 			 num2 = skillInfo.formula_value1_2 + skillInfo.formula_value1_add_2*(guanhuanLevel - 1), 
	 			 test = (guanhuanLevel <= 1) and "" or G_lang:get("LANG_KNIGHT_GUANHUAN_ADDITION", {num3=math.floor(skillInfo.formula_value1_add_1 / 10*(guanhuanLevel - 1))})})

			local label = GlobalFunc.createGameLabel(heSkill, 22, Colors.inActiveSkill,
		 		nil, CCSizeMake(size.width - 50, 0), true)
			labelSize = label:getSize()
			local labelPosX = size.width - labelSize.width/2 - 5
			label:setPositionXY(labelPosX, startYpos + labelSize.height/2)
			panel:addChild(label, 1, 100)
			startYpos = startYpos + labelSize.height

			labelPosX = labelPosX - labelSize.width/2
			local img = ImageView:create()
			img:loadTexture("ui/text/txt/icon_skill_he.png", UI_TEX_TYPE_LOCAL)
			local imgSize = img:getSize()
			img:setPosition(ccp(labelPosX - imgSize.width/2 - 5, startYpos - imgSize.height/2))
			panel:addChild(img)

			startYpos = startYpos + 5
		end
	end

	local active_skill_id = dressInfo and dressInfo.active_skill_id_1 or knightInfo.active_skill_id
	if active_skill_id > 0 then 
		local skillInfo = skill_info.get(active_skill_id)
		if skillInfo then
			local jiSkill = "["..skillInfo.name.." Lv."..guanhuanLevel.."]  "..G_GlobalFunc.formatText(skillInfo.directions, 
	 			{num1 = skillInfo.formula_value1_1 + math.floor(skillInfo.formula_value1_add_1 / 10 *(guanhuanLevel - 1)),
	 			 num2 = skillInfo.formula_value1_2 + skillInfo.formula_value1_add_2*(guanhuanLevel - 1), 
	 			 test = (guanhuanLevel <= 1) and "" or G_lang:get("LANG_KNIGHT_GUANHUAN_ADDITION", {num3=math.floor(skillInfo.formula_value1_add_1 / 10 *(guanhuanLevel - 1))})})

			local label = GlobalFunc.createGameLabel(jiSkill, 22, Colors.inActiveSkill,
		 		nil, CCSizeMake(size.width - 50, 0), true)
			local labelSize = label:getSize()
			local labelPosX = size.width - labelSize.width/2 - 5
			label:setPosition(ccp(labelPosX, startYpos + labelSize.height/2))
			panel:addChild(label, 1, 100)
			startYpos = startYpos + labelSize.height

			labelPosX = labelPosX - labelSize.width/2
			local img = ImageView:create()
			img:loadTexture("ui/text/txt/icon_skill_ji.png", UI_TEX_TYPE_LOCAL)
			local imgSize = img:getSize()
			img:setPosition(ccp(labelPosX - imgSize.width/2 - 5, startYpos - imgSize.height/2))
			panel:addChild(img)

			startYpos = startYpos + 5
		end
	end

	if self._isHandBook then
		local common_id = dressInfo and dressInfo.common_skill_id or knightInfo.common_id
		if common_id > 0 then 
			local skillInfo = skill_info.get(common_id)
			if skillInfo then 
				local skillText = "["..skillInfo.name.."]  "..G_GlobalFunc.formatText(skillInfo.directions, 
					{num1 = skillInfo.formula_value1_1,
					num2 = skillInfo.formula_value1_2,
					damage_type = G_lang:get("LANG_DRESS_ATTACK_TYPE"..knightInfo.damage_type)})

				local label = GlobalFunc.createGameLabel(skillText, 22, Colors.inActiveSkill,
			 		nil, CCSizeMake(size.width - 50, 0), true)
				local labelSize = label:getSize()
				local labelPosX = size.width - labelSize.width/2 - 5
				label:setPosition(ccp(labelPosX, startYpos + labelSize.height/2))
				panel:addChild(label, 1, 100)
				startYpos = startYpos + labelSize.height

				labelPosX = labelPosX - labelSize.width/2
				local img = ImageView:create()
				img:loadTexture("ui/text/txt/icon_skill_pu.png", UI_TEX_TYPE_LOCAL)
				local imgSize = img:getSize()
				img:setPosition(ccp(labelPosX - imgSize.width/2 - 5, startYpos - imgSize.height/2))
				panel:addChild(img)

				startYpos = startYpos + 5
			end
		end
	end

	startYpos = startYpos + 5
	if title then 
		local titleSize = title:getSize()
		panel:addChild(title)
		title:release()
		title:setPosition(ccp(size.width/2, startYpos + titleSize.height/2))
		startYpos = startYpos + titleSize.height
	end


	bottomY = startYpos + bottomY
	panel:setSize(CCSizeMake(size.width, bottomY - initYPos + 10))
	panel:setPosition(ccp(0, initYPos))
	
	bottomY = bottomY + 15

	return bottomY
	
end

function HeroGodAttrPreviewLargeLayer:_loadTianfuPanel(knightInfo, bottomY, passive_skill)
	
	local panel = self:getPanelByName("Panel_Tianfu")
	if not panel or not knightInfo or knightInfo.god_level % 3 ~= 0 then 
		panel:setVisible(false)
		return bottomY
	end

	if knightInfo.quality >= 6 and knightInfo.god_id == 0 and not self._isHandBook then
		panel:setVisible(false)
		return bottomY
	end

	local title = self:getWidgetByName("ImageView_Tianfu_Header")
	if title then 
		title:retain()
	end
	panel:removeAllChildren()
	local size = panel:getSize()
	local initYPos = bottomY
	local startYpos = 5
	require("app.cfg.passive_skill_info")
	local addTianfuContent = function ( passiveId, isActive )

		local passiveInfo = passive_skill_info.get(passiveId)
		if not passiveInfo then
			return 
		end

		local desc = string.format("[%s] %s", passiveInfo.name, passiveInfo.directions)
		local label = GlobalFunc.createGameLabel(desc, 22, Colors.inActiveSkill,
		 nil, CCSizeMake(size.width - 15, 0), true)

		local labelSize = label:getSize()

		label:setPosition(ccp(size.width/2, startYpos + labelSize.height/2))
		panel:addChild(label)
		startYpos = startYpos + labelSize.height
	end

	local oldYPos = startYpos
	addTianfuContent(knightInfo.passive_skill_15, false)
	addTianfuContent(knightInfo.passive_skill_14, false)
	addTianfuContent(knightInfo.passive_skill_13, false)
	addTianfuContent(knightInfo.passive_skill_12, false)
	addTianfuContent(knightInfo.passive_skill_11, false)
	addTianfuContent(knightInfo.passive_skill_10, false)
	addTianfuContent(knightInfo.passive_skill_9, false)
	addTianfuContent(knightInfo.passive_skill_8, false)
	addTianfuContent(knightInfo.passive_skill_7, false)
	addTianfuContent(knightInfo.passive_skill_6, false)
	addTianfuContent(knightInfo.passive_skill_5, false)
	addTianfuContent(knightInfo.passive_skill_4, false)
	addTianfuContent(knightInfo.passive_skill_3, false)
	addTianfuContent(knightInfo.passive_skill_2, false)
	addTianfuContent(knightInfo.passive_skill_1, false)

	if startYpos == 0 then 
		panel:setVisible(false)
		return bottomY
	end
	if oldYPos == startYpos then
		startYpos = startYpos + 45
	end
	startYpos = startYpos + 5
	
	if title then 
		local titleSize = title:getSize()
		panel:addChild(title)
		title:release()
		title:setPosition(ccp(size.width/2, startYpos + titleSize.height/2))
		startYpos = startYpos + titleSize.height
	end

	bottomY = startYpos + bottomY
	panel:setSize(CCSizeMake(size.width, bottomY - initYPos + 5))
	panel:setPosition(ccp(0, initYPos))
	bottomY = bottomY + 10

	return bottomY
end

return HeroGodAttrPreviewLargeLayer