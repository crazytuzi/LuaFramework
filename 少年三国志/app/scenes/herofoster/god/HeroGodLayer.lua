-- HeroGodLayer.lua
-- 武将化神界面
require("app.cfg.knight_info")
require("app.cfg.knight_god_info")

local HeroGodTurnplateLayer = require "app.scenes.herofoster.god.HeroGodTurnplateLayer"
-- local HeroGodScrollViewLayer = require "app.scenes.herofoster.god.HeroGodScrollViewLayer"
local HeroGodResultLayer = require "app.scenes.herofoster.god.HeroGodResult"
local JumpCard = require "app.scenes.common.JumpCard"
local KnightConst = require("app.const.KnightConst")
local HeroGodAttrPreviewSmallLayer = require "app.scenes.herofoster.god.HeroGodAttrPreviewSmallLayer"
local HeroGodAttrPreviewLargeLayer = require "app.scenes.herofoster.god.HeroGodAttrPreviewLargeLayer"
local EffectNode = require("app.common.effects.EffectNode")
local HeroGodCommon = require "app.scenes.herofoster.god.HeroGodCommon"

local HeroGodLayer = class("HeroGodLayer", UFCCSNormalLayer)

function HeroGodLayer.create( mainKnightId, ... )
	local layer = HeroGodLayer.new("ui_layout/HeroGod_Main.json", nil, mainKnightId, ...)
	return layer
end

function HeroGodLayer:ctor(json, param, mainKnightId, ...)

	self._mainKnightId = mainKnightId
	self._scrollViewPanel = self:getPanelByName("Panel_ScrollView")
	self._turnplateLayer = nil
	self._jumpCardNode = nil
	self._attrsValues = {} -- 左右两侧的属性信息
	self._lightEffect = nil -- 光团特效
	self._knightLightEffect = nil -- 武将发光特效
	self._isPlayAnim = false

	self:_reloadKnightData()

	self:attachImageTextForBtn("Button_Huashen", "ImageView_4673")

	self._godButton = self:getButtonByName("Button_Huashen")

	self.super.ctor(self, json,  ...)

end

function HeroGodLayer:adapterLayer( ... )
	
	self:adapterWidgetHeight("Panel_heros", "Panel_header", "Panel_BaseInfo", 0, 0)
end

function HeroGodLayer:onLayerEnter( ... )
	
	self:_initWidget()

	self:_createStrokes()

	self:registerBtnClickEvent("Button_Huashen", handler(self, self._onGodClick))
	self:registerBtnClickEvent("Button_Preview", handler(self, self._onPreviewClick))

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECEIVE_GOD_KNIGHT, self._onReciveGodKnightSuccessCallback, self)

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

    if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then 
		local effect  = EffectNode.new("effect_jinjiechangjing")
    	effect:play()
    	local left = self:getWidgetByName("ImageView_4674")
    	if left then 
    		left:addNode(effect)
    	end
    end  
end

function HeroGodLayer:_createStrokes( ... )
	
	self:enableLabelStroke("Label_name", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_shengjie", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_guanzhi_name", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_jieshu_0", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_hp_value_0", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_attack_value_0", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_defense_p_value_0", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_defense_m_value_0", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_skill_name_0", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_level_0", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_jieshu_1", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_attack_value_1", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_hp_value_1", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_defense_p_value_1", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_defense_m_value_1", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_level_1", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_cur_growup", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_clear_time_2", Colors.strokeBrown, 1 )

    self:enableLabelStroke("Label_attack_0", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_hp_0", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_defense_p_0", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_defense_m_0", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_attack_1", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_hp_1", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_defense_p_1", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_defense_m_1", Colors.strokeBrown, 1 )

    self:enableLabelStroke("Label_Desc_Title", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_Desc_Content", Colors.strokeBrown, 1 )
end

function HeroGodLayer:_getMainKnightInfo()
	return G_Me.bagData.knightsData:getKnightByKnightId(self._mainKnightId)
end

function HeroGodLayer:_getMainKnightBaseInfo(baseId)
	if not baseId then
		local knightInfo = self:_getMainKnightInfo()
		baseId = knightInfo and knightInfo.base_id
	end

	if baseId then
		return knight_info.get(baseId)
	end
end

-- 设置武将
function HeroGodLayer:_setKnight()
	
	-- 突破等级
	local label = self:getLabelByName("Label_shengjie")
	if label then
		label:setColor(Colors.getColor(self._knightBaseInfo.quality))
		if self._knightBaseInfo.advanced_level > 0 then
			label:setText( "+".. self._knightBaseInfo.advanced_level )
			-- label:setText( "+".. G_Me.bagData.knightsData:getGodLevel(self._mainKnightId) )
		else
			label:setText("")
		end
	end

	-- 名字
	label = self:getLabelByName("Label_name")
	if label then
		label:setColor(Colors.getColor(self._knightBaseInfo.quality))
		label:setText(self._knightBaseInfo.name)
	end

	-- 贴图
	local knightPicPanel = self:getWidgetByName("Panel_knight_pic")
	knightPicPanel:removeAllChildren()
	if knightPicPanel then
		local resId = self._knightBaseInfo.res_id
		if self._mainKnightId == G_Me.formationData:getMainKnightId() then 
        	resId = G_Me.dressData:getDressedPic()
    	end

		local knightPic = require("app.scenes.common.KnightPic")
		local pic = knightPic.createKnightButton(resId, knightPicPanel, "mainKnight_button", self, function ( ... )

			if CCDirector:sharedDirector():getSceneCount() > 1 then 
				uf_sceneManager:popScene()
			else
				uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroFosterScene").new(1, self._mainKnightId))
			end
		end, true)
		local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
        EffectSingleMoving.run(pic, "smoving_idle", nil, {}, 1+ math.floor(math.random()*30))
	end

	-- 武将脚下信息
	local titleText, contentText
	local potentialColor = G_lang:get("LANG_GOD_HONG")
	if self._knightBaseInfo.potential < KnightConst.KNIGHT_GOD_RED_POTENTIAL then
		potentialColor = G_lang:get("LANG_GOD_CHENG")
	end
	titleText = G_lang:get("LANG_GOD_HUASHEN_ZHI", {god = KnightConst.KNIGHT_GOD_MAX_LEVEL, color = potentialColor})
	if self._knightBaseInfo.potential < KnightConst.KNIGHT_GOD_RED_POTENTIAL then
		contentText = G_lang:get("LANG_GOD_UP_RED")
	else
		contentText = G_lang:get("LANG_GOD_UP_SKILL")
	end

	self:showTextWithLabel("Label_Desc_Title", titleText)
	self:showTextWithLabel("Label_Desc_Content", contentText)
end

-- 属性
function HeroGodLayer:_getAttrsTablesInfo(knightBaseInfo, level, pulseLevel, knightBaseInfo2, pulseLevel2)
	return G_Me.bagData.knightsData:getGodAttrsTablesInfo(knightBaseInfo, level, pulseLevel, knightBaseInfo2, pulseLevel2)
end

function HeroGodLayer:_setAttrInfo()

	local nowGodLevel = G_Me.bagData.knightsData:getGodLevel(self._mainKnightId)
	local nextGodLevel = G_Me.bagData.knightsData:getNextGodLevel(self._mainKnightId)
	
	local godLevels = {nowGodLevel, nextGodLevel}
	if nextGodLevel == 0 and nowGodLevel > 0 then
		godLevels[2] = KnightConst.KNIGHT_GOD_RED_MAX_LEVEL
	end

	local level = self._knightInfo.level

	local nextKnightBaseInfo = knight_info.get(self._knightBaseInfo.god_id)

	local attrNames = {"Label_attack_value_", "Label_hp_value_", "Label_defense_p_value_", "Label_defense_m_value_"}

	self._attrsValues = {}
	if self._knightInfo.pulse_level == KnightConst.KNIGHT_GOD_ZHENGJIE - 1 then
		self._attrsValues = {
			self:_getAttrsTablesInfo(self._knightBaseInfo, level, self._knightInfo.pulse_level) or {},
			self:_getAttrsTablesInfo(nextKnightBaseInfo, level, 0, self._knightBaseInfo, KnightConst.KNIGHT_GOD_ZHENGJIE - 1) or {},
		}
	else
		local leftAttr = self:_getAttrsTablesInfo(self._knightBaseInfo, level, self._knightInfo.pulse_level)
		local rightAttr
		if nowGodLevel == nextGodLevel then
			rightAttr = self:_getAttrsTablesInfo(self._knightBaseInfo, level, self._knightInfo.pulse_level) or leftAttr
		else
			rightAttr = self:_getAttrsTablesInfo(self._knightBaseInfo, level, self._knightInfo.pulse_level + 1) or leftAttr
		end
		
		self._attrsValues = {
			leftAttr or {},
			rightAttr or {},
		}

	end

	for i = 1, #self._attrsValues do
		self:showTextWithLabel("Label_jieshu_" .. (i - 1), G_lang:get("LANG_GOD_HUASHEN") ..  HeroGodCommon.getDisplyLevel(godLevels[i]))

		if self._attrsValues[i] then
			for j = 1, #self._attrsValues[i] do
				self:showTextWithLabel(attrNames[j] .. (i - 1), self._attrsValues[i][j])
			end
		end
	end

	self:showWidgetByName("Panel_right", nowGodLevel ~= nextGodLevel)

	HeroGodCommon.trainingArrowAnimation(self, "Image_Arrow1", "Label_attack_value_1", self._attrsValues[1][1] < self._attrsValues[2][1], true)
	HeroGodCommon.trainingArrowAnimation(self, "Image_Arrow2", "Label_hp_value_1", self._attrsValues[1][2] < self._attrsValues[2][2], true)
	HeroGodCommon.trainingArrowAnimation(self, "Image_Arrow3", "Label_defense_p_value_1", self._attrsValues[1][3] < self._attrsValues[2][3], true)
	HeroGodCommon.trainingArrowAnimation(self, "Image_Arrow4", "Label_defense_m_value_1", self._attrsValues[1][4] < self._attrsValues[2][4], true)

end

-- 箭头的Action
function HeroGodLayer:_trainingArrowAnimation( arrowName, followLabel, showArrow)
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

function HeroGodLayer:_setCostItem(i, goods)
	
	if goods then
		local nameLabel = self:getLabelByName("Label_Name" .. i)
		nameLabel:setText(goods.name .. G_lang:get("LANG_MAOHAO"))
		local iconImage = self:getImageViewByName("Image_Icon" .. i)
		iconImage:loadTexture(goods.icon_mini, goods.texture_type)
		local ownNum = G_Me.bagData:getNumByTypeAndValue(goods.type,goods.value)
		local numLabel = self:getLabelByName("Label_Num" .. i)
		numLabel:setText(ownNum .. "/" .. goods.size)
		numLabel:setPositionX(nameLabel:getPositionX() + nameLabel:getContentSize().width + 2)
		numLabel:setColor(goods.size > ownNum and Colors.lightColors.TIPS_01 or Colors.lightColors.DESCRIPTION)
	end
end

function HeroGodLayer:_updateCostInfo()

	local knightGodInfo = knight_god_info.get(self._knightBaseInfo.god_add_id, self._knightInfo.pulse_level + 1)

	for i = 1, 3 do
		self:showWidgetByName("Panel_Res" .. i, false)
	end

	if not knightGodInfo then

		local isMaxGodLevel = G_Me.bagData.knightsData:isMaxGodLevel(self._mainKnightId)

		self:showWidgetByName("Label_Max_Level", isMaxGodLevel)
		self:showWidgetByName("Button_Huashen", not isMaxGodLevel)
		self:showWidgetByName("Image_Cost_Money", not isMaxGodLevel)
		self:showWidgetByName("Label_Cost_Money", not isMaxGodLevel)
		self:showWidgetByName("Panel_cost_item", not isMaxGodLevel)

		return
	end

	local showIndex = 1
	for i = 1, 3 do
		local typeId = knightGodInfo["pulse_type_" .. i]
		local value = knightGodInfo["pulse_value_" .. i]
		local num = knightGodInfo["pulse_num_" .. i]

		self:showWidgetByName("Panel_Res" .. showIndex, true)
		
		if typeId > 0 and num > 0 then
			local goods = G_Goods.convert(typeId, value, num)
			self:_setCostItem(showIndex, goods)
			self:showWidgetByName("Panel_Res" .. showIndex, true)
			showIndex = showIndex + 1
		end
	end

	if knightGodInfo.sp_cost > 0 then
		local num = knightGodInfo.sp_cost
		self:showTextWithLabel("Label_Name" .. showIndex, G_lang:get("LANG_GOD_SUIPIAN"))
		local iconImage = self:getImageViewByName("Image_Icon" .. showIndex)
		iconImage:loadTexture("ui/equipment/icon_mini_suipian.png")
		local fragment = G_Me.bagData.fragmentList:getItemByKey(self._knightBaseInfo.fragment_id)
		local fragmentnum = fragment and fragment.num or 0

		local numLabel = self:getLabelByName("Label_Num" .. showIndex)
		numLabel:setText(fragmentnum .. "/" .. num)
		numLabel:setColor(num > fragmentnum and Colors.lightColors.TIPS_01 or Colors.lightColors.DESCRIPTION)
		self:showWidgetByName("Panel_Res" .. showIndex, true)
		showIndex = showIndex + 1
	end

	for i = showIndex, 3 do
		self:showWidgetByName("Panel_Res" .. i, false)
	end

	local costMoneyLabel = self:getLabelByName("Label_Cost_Money")
	costMoneyLabel:setText(GlobalFunc.ConvertNumToCharacter3(knightGodInfo.money))
	local goods = G_Goods.convert(G_Goods.TYPE_MONEY, 0, 0)
	local ownNum = G_Me.bagData:getNumByTypeAndValue(goods.type,goods.value)
	costMoneyLabel:setColor(knightGodInfo.money > ownNum and Colors.lightColors.TIPS_01 or Colors.lightColors.DESCRIPTION)


end

function HeroGodLayer:_initWidget()
	
	-- 增加滑动列表
	if not self._turnplateLayer then
		self._turnplateLayer = HeroGodTurnplateLayer.new()
		-- self._turnplateLayer = HeroGodScrollViewLayer.new()
	    self._turnplateLayer:init(self, G_Me.bagData.knightsData:getGodLevel(self._mainKnightId), self._knightBaseInfo.quality)
	    self._turnplateLayer:setPositionXY(-100, 0)
	    self._scrollViewPanel:addNode(self._turnplateLayer)
	end

	self:_setKnight()

	self:_setAttrInfo()

	self:_updateCostInfo()
end

-- 点击灯的响应
function HeroGodLayer:lightOnClick(index, isPreview)

	local godLevel
	if self._knightBaseInfo.god_level >= KnightConst.KNIGHT_GOD_MAX_LEVEL then
		godLevel = index + KnightConst.KNIGHT_GOD_RED_MAX_LEVEL
	else
		godLevel = index
	end
	
	local godBigLevel = math.floor(godLevel / KnightConst.KNIGHT_GOD_ZHENGJIE)
	local pulseLevel = godLevel % KnightConst.KNIGHT_GOD_ZHENGJIE

	local nowGodBigLevel = self._knightBaseInfo.god_level

	local baseInfo

	if godBigLevel == nowGodBigLevel then
		baseInfo = self._knightBaseInfo
	elseif godBigLevel < nowGodBigLevel then
		local knightBaseInfo = self._knightBaseInfo
		for i = 1, 3 do
			if knightBaseInfo.god_pre_id > 0 then
				knightBaseInfo = knight_info.get(knightBaseInfo.god_pre_id)
				if godBigLevel == knightBaseInfo.god_level then
					baseInfo = knightBaseInfo
					break
				end
			else
				break
			end
		end
	elseif godBigLevel > nowGodBigLevel then
		local knightBaseInfo = self._knightBaseInfo
		for i = 1, 3 do
			if knightBaseInfo.god_id > 0 then

				knightBaseInfo = knight_info.get(knightBaseInfo.god_id)
				if godBigLevel == knightBaseInfo.god_level then
					baseInfo = knightBaseInfo
					break
				end
			else
				break
			end
		end
	end

	if not baseInfo then
		return
	end

	if pulseLevel == 0 then
		HeroGodAttrPreviewLargeLayer.show(self._mainKnightId, baseInfo, isPreview)
	else

		local godInfo = knight_god_info.get(baseInfo.god_add_id, pulseLevel)

		local preGodInfo
		if pulseLevel == 1 and baseInfo.god_pre_id > 0 then
			
			local preKnightBaseInfo = knight_info.get(baseInfo.god_pre_id)
			preGodInfo = knight_god_info.get(preKnightBaseInfo.god_add_id, KnightConst.KNIGHT_GOD_ZHENGJIE - 1)
		elseif pulseLevel > 1 then
			preGodInfo = knight_god_info.get(baseInfo.god_add_id, pulseLevel - 1)
		end
		if godInfo then
			HeroGodAttrPreviewSmallLayer.show(godInfo, preGodInfo)
		end
	end

end

function HeroGodLayer:_onPreviewClick()
	self:lightOnClick(KnightConst.KNIGHT_GOD_RED_MAX_LEVEL, true)
end

-- 点击化神按钮
function HeroGodLayer:_onGodClick()

	if self._isPlayAnim then
		return
	end

	local nowGodLevel = G_Me.bagData.knightsData:getGodLevel(self._mainKnightId)
	local nextGodLevel = G_Me.bagData.knightsData:getNextGodLevel(self._mainKnightId)

	self:_stopAllActions()

	if nowGodLevel == nextGodLevel then
		G_MovingTip:showMovingTip(G_lang:get("LANG_GOD_MAX_JIESHU_TIP"))
		return
	end

	local knightGodInfo = knight_god_info.get(self._knightBaseInfo.god_add_id, self._knightInfo.pulse_level + 1)

	for i = 1, 3 do
		local typeId = knightGodInfo["pulse_type_" .. i]
		local value = knightGodInfo["pulse_value_" .. i]
		local num = knightGodInfo["pulse_num_" .. i]
		
		if typeId > 0 and num > 0 then
			local goods = G_Goods.convert(typeId, value, num)
			local ownNum = G_Me.bagData:getNumByTypeAndValue(goods.type,goods.value)
			if num > ownNum then
				require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(goods.type, goods.value,
					GlobalFunc.sceneToPack("app.scenes.herofoster.HeroDevelopScene", {KnightConst.KNIGHT_TYPE.KNIGHT_GOD, self._mainKnightId}))
				return
			end
		end
	end

	if knightGodInfo.sp_cost > 0 then
		local num = knightGodInfo.sp_cost
		local fragment = G_Me.bagData.fragmentList:getItemByKey(self._knightBaseInfo.fragment_id)
		local fragmentnum = fragment and fragment.num or 0
		if num > fragmentnum then
			require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_FRAGMENT, self._knightBaseInfo.fragment_id,
				GlobalFunc.sceneToPack("app.scenes.herofoster.HeroDevelopScene", {KnightConst.KNIGHT_TYPE.KNIGHT_GOD, self._mainKnightId}))
			return
		end
	end

	local goods = G_Goods.convert(G_Goods.TYPE_MONEY, 0, num)
	local ownNum = G_Me.bagData:getNumByTypeAndValue(goods.type,goods.value)
	if knightGodInfo.money > ownNum then
		require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(goods.type, goods.value,
			GlobalFunc.sceneToPack("app.scenes.herofoster.HeroDevelopScene", {KnightConst.KNIGHT_TYPE.KNIGHT_GOD, self._mainKnightId}))
		return
	end

	G_HandlersManager.heroUpgradeHandler:sendGodKnight(self._mainKnightId)
end

-- 重新加载武将数据
function HeroGodLayer:_reloadKnightData()
	
	self._knightInfo = self:_getMainKnightInfo()
	if not self._knightInfo then
		__LogError("HeroGodLayer knightInfo is nil, knghitId is " .. tostring(self._mainKnightId))
	end
	
	self._knightBaseInfo = self:_getMainKnightBaseInfo(self._knightInfo.base_id)
	if not self._knightBaseInfo then
		__LogError("HeroGodLayer knightBaseInfo is nil, knghitId is " .. tostring(self._mainKnightId))
	end
end

-- 服务器化神成功的返回
function HeroGodLayer:_onReciveGodKnightSuccessCallback()

	self._isPlayAnim = true
	self._godButton:setEnabled(false)

	local oldKnightBaseId = self._knightBaseInfo.id
	
	self:_reloadKnightData()

	local nowGodLevel = G_Me.bagData.knightsData:getGodLevel(self._mainKnightId)

	if self._knightBaseInfo.god_level == KnightConst.KNIGHT_GOD_MAX_LEVEL and nowGodLevel == 0 then
		nowGodLevel = KnightConst.KNIGHT_GOD_RED_MAX_LEVEL
	end

	self._turnplateLayer:updateLightStatus(nowGodLevel)

	local function lightAnimEnd()
		if self._knightInfo.pulse_level == 0 then

			self:_playFullScreenAnim(oldKnightBaseId)
		end
	end

	local function knightLightAnim()
		self:_playKnightLightAnim(lightAnimEnd)

		if self._knightInfo.pulse_level ~= 0 then
			self:_playAttrAnim(nowGodLevel, function() 
				self:_onResultLayerCallback()
			end)
		end
	end

	self:_playLightMoveAnim(knightLightAnim)

	
end

-- 播放全屏动画
function HeroGodLayer:_playFullScreenAnim(oldKnightBaseId)

	local baseId = G_Me.bagData.knightsData:getBaseIdByKnightId(self._mainKnightId or 0)
	local panel = self:getWidgetByName("Panel_knight_pic")
	local scaleValue = 0.5

	local waitfunc = function()
		HeroGodResultLayer.showHeroGodResult(self, 
			oldKnightBaseId, 
			self._knightBaseInfo.id, 
			G_Me.bagData.knightsData:getGodLevel(self._mainKnightId),
			self._attrsValues, 
			handler(self, self._onResultLayerCallback))
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

function HeroGodLayer:_playAttrAnim(godLevel, cb)

	local attrNames = {"Label_attack_value_0", "Label_hp_value_0", "Label_defense_p_value_0", "Label_defense_m_value_0"}
	local attrTitles = {"LANG_GROWUP_ATTRIBUTE_GONGJI", "LANG_GROWUP_ATTRIBUTE_SHENGMING", "LANG_GROWUP_ATTRIBUTE_WUFANG", "LANG_GROWUP_ATTRIBUTE_MOFANG"}

	local delattrs = {}
	for i = 1, #self._attrsValues[1] do
		delattrs[i] = {typeString = G_lang:get(attrTitles[i]), 
		delta = self._attrsValues[2][i] - self._attrsValues[1][i], 
		labelName = attrNames[i]}
	end
    self:_flyAttr(delattrs, HeroGodCommon.getDisplyLevel(godLevel or 0), color, 
			"Label_jieshu_0", cb)
end

-- 属性飞行动画
function HeroGodLayer:_flyAttr(attrsNext, title_text, color, value_label, finish_callback)

    G_flyAttribute._clearFlyAttributes()

    G_flyAttribute.addNormalText(title_text,color or Colors.uiColors.ORANGE, self:getLabelByName(value_label))
    
    --属性加成
    for i, attrInfo in ipairs(attrsNext) do
    	if attrInfo.delta > 0 then
        	G_flyAttribute.addAttriChange(attrInfo.typeString, attrInfo.delta, self:getLabelByName(attrInfo.labelName))
        end
    end
    attrsNext = {}

    G_flyAttribute.play(function ( ... )
    	if finish_callback then
        	finish_callback()
        end
    end)
end

-- 播放完全屏动画后的回调
function HeroGodLayer:_onResultLayerCallback()
	if self._jumpCardNode then 
		self._jumpCardNode:resume()
	end

	local nowGodLevel = G_Me.bagData.knightsData:getGodLevel(self._mainKnightId)

	if self._knightBaseInfo.god_level == 3 and nowGodLevel == 0 then
		uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroDevelopScene").new( KnightConst.KNIGHT_TYPE.KNIGHT_GOD, self._mainKnightId, nil, nil, nil))
	end

	self._isPlayAnim = false
	self._godButton:setEnabled(true)

	self._turnplateLayer:updateLightStatus(nowGodLevel)

	self:_updateCostInfo()
	self:_setAttrInfo()
	self:_setKnight()
end

-- 武将发光特效
function HeroGodLayer:_playKnightLightAnim(cb)
	
	if not self._knightLightEffect then

		self._knightLightEffect = EffectNode.new("effect_huashen_hurt",function(event, frameIndex)
	            if event == "finish" then

	                if self._knightLightEffect then
	                	self._knightLightEffect:removeFromParentAndCleanup(true)
	                	self._knightLightEffect = nil
	                end
			        if cb then cb() end
	            end
	        end)
		uf_sceneManager:getCurScene():addChild(self._knightLightEffect,7)
	end
	self._knightLightEffect:play()

	local panel = self:getWidgetByName("Panel_knight_pic")
	local x, y = panel:convertToWorldSpaceXY(0, 0)
	self._knightLightEffect:setPositionXY(x, y + 70)

end

-- 光团移动特效
function HeroGodLayer:_playLightMoveAnim(cb)

	local nowGodLevel = G_Me.bagData.knightsData:getGodLevel(self._mainKnightId)

	if nowGodLevel == 0 then
		nowGodLevel = KnightConst.KNIGHT_GOD_RED_MAX_LEVEL
	end
	
	if not self._lightEffect then

		self._lightEffect = EffectNode.new("effect_huashen_star_" .. HeroGodTurnplateLayer.effects[nowGodLevel])
		uf_sceneManager:getCurScene():addChild(self._lightEffect,7)
	end
	self._lightEffect:play()

	

	local startX, startY = self._turnplateLayer:getWorldWorldSpaceXYByIndex(nowGodLevel)
	self._lightEffect:setPositionXY(startX + 10, startY + 10)

	local panel = self:getWidgetByName("Panel_knight_pic")
	local endX, endY = panel:convertToWorldSpaceXY(0, 0)

	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(0.5))
	arr:addObject(CCMoveTo:create(0.6, ccp(endX + 5, endY + 15)))
	arr:addObject(CCCallFunc:create(function()
			
			if self._lightEffect then
		    	self._lightEffect:removeFromParentAndCleanup(true)
		    	self._lightEffect = nil
		    end
			if cb then cb() end
			
		end))
	self._lightEffect:runAction(CCSequence:create(arr))
end

function HeroGodLayer:_stopAllActions()
	if self._knightLightEffect then
		self._knightLightEffect:stop()
    	self._knightLightEffect:removeFromParentAndCleanup(true)
    	self._knightLightEffect = nil
    end

    if self._lightEffect then
    	self._lightEffect:stop()
    	self._lightEffect:removeFromParentAndCleanup(true)
    	self._lightEffect = nil
    end

    G_flyAttribute._clearFlyAttributes()

end

function HeroGodLayer:onLayerExit( ... )
	uf_eventManager:removeListenerWithTarget(self)

	if self._jumpCardNode  ~= nil then 
		self._jumpCardNode:removeFromParentAndCleanup(true)
		self._jumpCardNode = nil
	end
	-- self:_stopAllActions()
	G_flyAttribute._clearFlyAttributes()
end

return HeroGodLayer