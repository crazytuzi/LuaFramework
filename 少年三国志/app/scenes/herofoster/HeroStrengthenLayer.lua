--HeroStrengthenLayer.lua


local HeroStrengthenLayer = class ("HeroStrengthenLayer", UFCCSNormalLayer)
local EffectNode = require "app.common.effects.EffectNode"
local knightPic = require("app.scenes.common.KnightPic")
local KnightConst = require("app.const.KnightConst")
local MergeEquipment = require("app.data.MergeEquipment")
require("app.cfg.team_target_info")

function HeroStrengthenLayer:ctor( ... )
	self._selectedKnights = {}
	self._knightBtns = {}
	self._mainKnightId = 0
	self._acquireMoney = 0
	self._getExp = 0
	self._maxStarKnight = 1
	self._upgradeNeedExp = 0
	self._maxUpgradeNeedExp = 0
	self._nextUpgradeNeedExp = 100000
	self._upgradeLevel = 0
	self._upgradePercent = 0
	self._materialKnights = nil
	self._knightAttributes = {}
	self._mainKnightBtn = nil
	self._isPlayingAnimation = false
	self._isUpgradingKnight = false
	self._addKnightMaterials = false

	self._mainKnightEffect = nil
	self._knightAttriCtrls = {}

	self.super.ctor(self, ...)
end

function HeroStrengthenLayer:onLayerLoad( jsonFile, knightId, ... )
	self._mainKnightId = knightId

	local _, lastTargetLevel, _ = G_Me.formationData:getKnightFriendTarget(1)
	self._lastTargetLevel = lastTargetLevel

	self:registerBtnClickEvent("Button_add_1", function ( widget )
		self:_onChangeHero( 1, widget, knightId )
	end)
	self:registerBtnClickEvent("Button_add_2", function ( widget )
		self:_onChangeHero( 2, widget, knightId )
	end)
	self:registerBtnClickEvent("Button_add_3", function ( widget )
		self:_onChangeHero( 3, widget, knightId )
	end)
	self:registerBtnClickEvent("Button_add_4", function ( widget )
		self:_onChangeHero( 4, widget, knightId )
	end)
	self:registerBtnClickEvent("Button_add_5", function ( widget )
		self:_onChangeHero( 5, widget, knightId )
	end)

	self:registerBtnClickEvent("Button_remove_1", function ( widget )
		self:_onRemoveKnight( 1)
	end)
	self:registerBtnClickEvent("Button_remove_2", function ( widget )
		self:_onRemoveKnight( 2 )
	end)
	self:registerBtnClickEvent("Button_remove_3", function ( widget )
		self:_onRemoveKnight( 3 )
	end)
	self:registerBtnClickEvent("Button_remove_4", function ( widget )
		self:_onRemoveKnight( 4 )
	end)
	self:registerBtnClickEvent("Button_remove_5", function ( widget )
		self:_onRemoveKnight( 5 )
	end)

	self:registerBtnClickEvent("Button_knight_icon_1", function ( widget )
		self:_onChangeHero( 1, widget, knightId )
	end)
	self:registerBtnClickEvent("Button_knight_icon_2", function ( widget )
		self:_onChangeHero( 2, widget, knightId )
	end)
	self:registerBtnClickEvent("Button_knight_icon_3", function ( widget )
		self:_onChangeHero( 3, widget, knightId )
	end)
	self:registerBtnClickEvent("Button_knight_icon_4", function ( widget )
		self:_onChangeHero( 4, widget, knightId )
	end)
	self:registerBtnClickEvent("Button_knight_icon_5", function ( widget )
		self:_onChangeHero( 5, widget, knightId )
	end)

	self:registerBtnClickEvent("Button_auto", function ( widget )
		self:_onAutoAddHero()
	end)
	self:registerBtnClickEvent("Button_strength", function ( widget )
		self:_onStrengthHero()
	end)

	local progress = self:getLoadingBarByName("LoadingBar_exp")
	if progress then
		progress:loadModificationTexture("ui/yangcheng/progress_yellow.png", false, UI_TEX_TYPE_LOCAL)
		progress:setPercent(10)
	end

	 self:enableLabelStroke("Label_name", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_level", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_jingjie", Colors.strokeBrown, 1 )
	 self:enableLabelStroke("Label_exp_value", Colors.strokeBrown, 1 )
	 self:enableLabelStroke("Label_exp", Colors.strokeBrown, 1 )
	 self:enableLabelStroke("Label_jieshu", Colors.strokeBrown, 1 )

	 self:enableLabelStroke("Label_name_1", Colors.strokeBrown, 1 )
	 self:enableLabelStroke("Label_name_2", Colors.strokeBrown, 1 )
	 self:enableLabelStroke("Label_name_3", Colors.strokeBrown, 1 )
	 self:enableLabelStroke("Label_name_4", Colors.strokeBrown, 1 )
	 self:enableLabelStroke("Label_name_5", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_attack_value", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_hp_value", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_deffenw_value", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_deffenf_value", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_attack_value_offset", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_hp_value_offset", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_deffenw_value_offset", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_deffenf_value_offset", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_yinbi_value", Colors.strokeBrown, 1 )

	-- local label = self:getLabelByName("Label_attack_value_offset")
	-- if label then 
	-- 	label:setCascadeOpacityEnabled(true)
	-- end

	-- local createStroke = function ( name )
 --        local label = self:getLabelByName(name)
 --        if label then 
 --            label:createStroke(Colors.strokeBrown, 1)
 --        end
 --    end
 --    createStroke("Label_attack")
 --    createStroke("Label_hp")
 --    createStroke("Label_deffenw")
 --    createStroke("Label_deffenf")
 --    createStroke("Label_level_title")

	

	table.insert(self._knightBtns, #self._knightBtns + 1, self:getWidgetByName("Panel_main_icon_1"))
	table.insert(self._knightBtns, #self._knightBtns + 1, self:getWidgetByName("Panel_main_icon_2"))
	table.insert(self._knightBtns, #self._knightBtns + 1, self:getWidgetByName("Panel_main_icon_3"))
	table.insert(self._knightBtns, #self._knightBtns + 1, self:getWidgetByName("Panel_main_icon_4"))
	table.insert(self._knightBtns, #self._knightBtns + 1, self:getWidgetByName("Panel_main_icon_5"))
   
    table.insert(self._knightAttriCtrls, #self._knightAttriCtrls + 1, self:getWidgetByName("Label_attack_value"))
    table.insert(self._knightAttriCtrls, #self._knightAttriCtrls + 1, self:getWidgetByName("Label_hp_value"))
    table.insert(self._knightAttriCtrls, #self._knightAttriCtrls + 1, self:getWidgetByName("Label_deffenw_value"))
    table.insert(self._knightAttriCtrls, #self._knightAttriCtrls + 1, self:getWidgetByName("Label_deffenf_value"))
	--self:callAfterFrameCount(2, function (  )
	--	self:_initKnightLine()
	--end)
	
	if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then 
		local EffectNode = require("app.common.effects.EffectNode")
		local effect  = EffectNode.new("effect_jinjiechangjing")
    	effect:play()
    	local left = self:getWidgetByName("ImageView_4536")
    	if left then 
    		left:addNode(effect)
    	end
    end
	
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECEIVE_UPGRADE_KNIGHT, self._onReceiveStrengthRet, self)
end

function HeroStrengthenLayer:onLayerUnload(  )
	uf_eventManager:removeListenerWithTarget(self)
end

function HeroStrengthenLayer:onLayerEnter( ... )
	self:_blurWidget("Button_add_1", true, 2.5)
	self:_blurWidget("Button_add_2", true, 2.5)
	self:_blurWidget("Button_add_3", true, 2.5)
	self:_blurWidget("Button_add_4", true, 2.5)
	self:_blurWidget("Button_add_5", true, 2.5)

	GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_attribute_base")}, true, 0.2, 3, 30)
	GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_4482")}, false, 0.2, 3, 30)

	self:_initMainHero(self._mainKnightId)
	
	self:showWidgetByName("ImageView_line_1", false)
	self:showWidgetByName("ImageView_line_2", false)
	self:showWidgetByName("ImageView_line_3", false)
	self:showWidgetByName("ImageView_line_4", false)
	self:showWidgetByName("ImageView_line_5", false)
	GlobalFunc.flyFromWidget({self:getWidgetByName("ImageView_knight_1"), 
		self:getWidgetByName("ImageView_knight_2"),
		self:getWidgetByName("ImageView_knight_3"),
		self:getWidgetByName("ImageView_knight_4"),
		self:getWidgetByName("ImageView_knight_5"),}, 
		self:getWidgetByName("ImageView_main"), 0.4, 20, function ( ... )
			self:showWidgetByName("ImageView_line_1", true)
			self:showWidgetByName("ImageView_line_2", true)
			self:showWidgetByName("ImageView_line_3", true)
			self:showWidgetByName("ImageView_line_4", true)
			self:showWidgetByName("ImageView_line_5", true)
		end)
end

function HeroStrengthenLayer:adapterLayer( ... )
	--self:adapterWidgetHeight("Panel_mainBody", "", "Panel_baseInfo", 0, 0)
	
end

function HeroStrengthenLayer:_initMainHero( knightId )
	local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(knightId)
	if knightInfo == nil then
		return  
	end
	
	local baseId = knightInfo["base_id"]
	local resId = 1
	local knightBaseInfo = nil
	if baseId > 0 then
		knightBaseInfo = knight_info.get(baseId)
	end

	if knightBaseInfo ~= nil then
		resId = knightBaseInfo["res_id"]
	else
		__LogError("knightinfo is nil for baseId:%d", baseId)
	end

	local heroPath = G_Path.getKnightPic(resId)
	local icon = self:getWidgetByName("Panel_main_icon")
	if icon ~= nil then
		icon:removeAllChildren()
		local knightPic = require("app.scenes.common.KnightPic")
		self._mainKnightBtn = knightPic.createKnightButton(resId, icon, "mainKnight_button", self, function ( ... )
			if CCDirector:sharedDirector():getSceneCount() > 1 then 
				uf_sceneManager:popScene()
			else
				uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroFosterScene").new(1, self._mainKnightId))
			end
		end, true)

        local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
        EffectSingleMoving.run(self._mainKnightBtn, "smoving_idle", nil, {}, 1+ math.floor(math.random()*30))
		--local pic = knightPic.createKnightPic(resId, icon)
		self._mainKnightBtn:setTag(1000)
	end

	local widget = self:getWidgetByName("ImageView_main") 
	if widget then
		self._mainKnightEffect = EffectNode.new("effect_dipan", 
    			function(event)
    			end)
		widget:addNode(self._mainKnightEffect)
		self._mainKnightEffect:stop()
		self._mainKnightEffect:setPosition(ccp(0, 8))
	end

	local name = self:getLabelByName("Label_name")
	if name ~= nil then
		name:setColor(Colors.getColor(knightBaseInfo and knightBaseInfo.quality or 1))
		name:setText(knightBaseInfo ~= nil and knightBaseInfo.name or "Default Name")
	end

	local jieShu = self:getLabelByName("Label_jieshu")
	if jieShu ~= nil then
		if knightBaseInfo then
			local jingjie = knightBaseInfo.advanced_level
			jieShu:setColor(Colors.getColor(knightBaseInfo and knightBaseInfo.quality or 1))
			jieShu:setText(jingjie > 0 and ("+"..jingjie) or "")
		else
			jieShu:setText("")
		end
	end

	local potential = self:getLabelByName("Label_zizhi_value")
	if potential ~= nil then
		potential:setText(knightBaseInfo ~= nil and (""..knightBaseInfo.potential) or "1")
	end

	local mainKnightId = G_Me.formationData:getMainKnightId()
	local mainKnightInfo = G_Me.bagData.knightsData:getKnightByKnightId(mainKnightId)
	local mainKnightLevel = mainKnightInfo and mainKnightInfo["level"] or 1
	local destLevel, offsetLevel, needExp, maxExp, expRait = self:_calcUpgradeDestLevel(0, mainKnightLevel)
	self._upgradeNeedExp = needExp
	self._maxUpgradeNeedExp = maxExp

	local level = knightInfo["level"] or 1
	--GlobalFunc.loadStars(self, 
	--	{"ImageView_star_1", "ImageView_star_2","ImageView_star_3","ImageView_star_4","ImageView_star_5","ImageView_star_6",},
	--	knightBaseInfo and knightBaseInfo.star or 0, 1, G_Path.getListStarIcon())

	local label = self:getLabelByName("Label_yinbi_value")
	if label then
		label:setText(self._getExp > 0 and self._getExp or 0)
	end

	label = self:getLabelByName("Label_exp_value")
	if label then
		label:setText(self._getExp > 0 and self._getExp or 0)
	end

	self._knightAttributes = G_Me.bagData.knightsData:getKnightAttributes(knightBaseInfo and knightBaseInfo.id, level) or {}

	label = self:getLabelByName("Label_hp_value")
	if label  and knightBaseInfo then
		label:setText(self._knightAttributes["hp"] or 0)
	else
		label:setText("")
	end

	label = self:getLabelByName("Label_attack_value")
	if label  and knightBaseInfo then
		label:setText(self._knightAttributes["at"] or 0)
	else
		label:setText("")
	end

	label = self:getLabelByName("Label_deffenw_value")
	if label  and knightBaseInfo then
		label:setText(self._knightAttributes["pd"] or 0)
	else
		label:setText("")
	end

	label = self:getLabelByName("Label_deffenf_value")
	if label  and knightBaseInfo then
		label:setText(self._knightAttributes["md"] or 0)
	else
		label:setText("")
	end

	if not self._addKnightMaterials then 
		self:showTextWithLabel("Label_jingjie", "")

		if self._upgradeLevel < 1 then
			self:showTextWithLabel("Label_level", ""..level)
		end

		local progress = self:getLoadingBarByName("LoadingBar_exp")
		if progress then
			progress:setModificationPercent(0)
			progress:blurModification(false)
			progress:setPercent(expRait)
		end

		label = self:getLabelByName("Label_hp_value_offset")
		if label then
			label:setText("")
		end
		label = self:getLabelByName("Label_attack_value_offset")
		if label then
			label:setText("")
		end
		label = self:getLabelByName("Label_deffenw_value_offset")
		if label then
			label:setText("")
		end
		label = self:getLabelByName("Label_deffenf_value_offset")
		if label then
			label:setText("")
		end
	end
end

function HeroStrengthenLayer:_initKnightLine( ... )
	local mainKnight = self:getWidgetByName("ImageView_main")
	if not mainKnight then
		return 
	end

	local mainPosx, mainPosy = mainKnight:convertToWorldSpaceXY(0, 0)
	for loopi = 1, 5 do 
		local materialKnight = self:getWidgetByName("ImageView_knight_"..loopi)
		local materialKnightLine = self:getWidgetByName("ImageView_line_"..loopi)
		local materialKnightPosx, materialKnightPosy = materialKnight:convertToWorldSpaceXY(0, 0)

		materialKnightLine:setPosition(ccp(materialKnight:getPosition()))

		local tanValue= 0
		if materialKnightPosx ~= mainPosx then
			tanValue = (materialKnightPosy - mainPosy)/(mainPosx - materialKnightPosx)
		else
			tanValue = 1000000
		end
		local degree = math.deg(math.atan(tanValue))
		if degree < 0 then
			degree = degree + 180
		end
		materialKnightLine:setRotation(degree)

		local length = math.sqrt((materialKnightPosy - mainPosy)*(materialKnightPosy - mainPosy) + 
			(mainPosx - materialKnightPosx)*(mainPosx - materialKnightPosx))
		local materialSize = materialKnightLine:getSize()
		materialKnightLine:setSize(CCSizeMake(length, materialSize.height))
		materialKnightLine:setVisible(true)

		-- local materialKnightLineGreen = self:getWidgetByName("ImageView_line_"..loopi.."_"..loopi)
		-- if materialKnightLineGreen then
		-- 	local materialSize = materialKnightLineGreen:getSize()
		-- 	materialKnightLineGreen:setSize(CCSizeMake(length, materialSize.height))

		-- 	materialKnightLineGreen:setVisible(false)
		-- end
	end
end

-- 根据exp的变更和当前level计算出能升到的|级别|，|升级数|，|当前升级所需经验|，
-- |升到最大级别所需要经验|，|目前经验进度|
function HeroStrengthenLayer:_calcUpgradeDestLevel( expOffset, maxLevel )
	local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(self._mainKnightId)
	if knightInfo == nil then
		return 
	end

	local level = knightInfo["level"]
	local curExp = knightInfo["exp"]
	require("app.cfg.knight_info")

	local knightBaseInfo = knight_info.get(knightInfo["base_id"])
	if not knightBaseInfo then
		return 
	end

	-- 计算下一级别所需要的经验
	-- calc |maxLevel + 1| requires exp
	local curMaxLevelFullExp = 0
	local maxNextLevel = 1
	local maxNextLevelExp = 0
	while (maxLevel + 1) > maxNextLevel do
		maxNextLevelExp = (knightBaseInfo.upgrade_exp + (math.floor(math.pow(maxNextLevel, 1.8)))*knightBaseInfo.upgrade_exp_growth)
		curMaxLevelFullExp = curMaxLevelFullExp + maxNextLevelExp
		maxNextLevel = maxNextLevel + 1
	end

--__Log("maxNextLevel:%d, curMaxLevelFullExp:%d, curTotal:%d", maxNextLevel, curMaxLevelFullExp, curExp + expOffset)
	-- adjust the max level and exp which knight can acquire
	-- 当前经验值可以超过升到满级所需时，计算升到满级的经验差值
	if curMaxLevelFullExp <= (curExp + expOffset) then
		expOffset = curMaxLevelFullExp - curExp - 100
		if expOffset < 0 then
			expOffset = 0 
		end
	end

	-- 计算到上一级总共需要的经验值，差值得到增加经验后能达到的经验值进度
	local lastLevelExp = 0
	local destLevel = 1
	local nextLevelExp = (knightBaseInfo.upgrade_exp + (math.floor(math.pow(destLevel, 1.8)))*knightBaseInfo.upgrade_exp_growth)
	local curLevelFullExp = 0
	while maxLevel >= destLevel and curExp + expOffset >= nextLevelExp + lastLevelExp do 
		lastLevelExp = lastLevelExp + nextLevelExp
		--__Log("lastLevelExp:%d, nextLevelExp:%d, level:%d", lastLevelExp, nextLevelExp, level)
		if destLevel <= level + 1 then
			curLevelFullExp = curLevelFullExp + nextLevelExp
		end
		destLevel = destLevel + 1
		nextLevelExp = (knightBaseInfo.upgrade_exp + (math.floor(math.pow(destLevel, 1.8)))*knightBaseInfo.upgrade_exp_growth)
	end

	if maxLevel > destLevel then
		curLevelFullExp  = curLevelFullExp + nextLevelExp
	end
	--__Log("curLevelFullExp:%d, nextLevelExp:%d", curLevelFullExp, nextLevelExp)

	--if maxNextLevelExp <= (curExp + expOffset) then
	--	curRait = 99
	--else
	local lackExp = nextLevelExp - (curExp + expOffset) + lastLevelExp
	lackExp = lackExp > 0 and lackExp or 0
	local curRait = 100 - (lackExp*100 / nextLevelExp + 0.5)
	--end

__Log("[expOffset:%d, curExp:%d, maxLevel:%d, curLevel:%d destLevel:%d, curLevelFullExp:%d, moreExp:%d, maxExp:%d, retRait:%d ]",
	expOffset, curExp, maxLevel, level, destLevel, curLevelFullExp, curLevelFullExp - curExp, curMaxLevelFullExp - curExp, curRait)

	return destLevel, destLevel - level, curLevelFullExp - curExp, curMaxLevelFullExp - curExp, curRait
end

function HeroStrengthenLayer:_checkKnightLevel(  )
	local mainKnightId = G_Me.formationData:getMainKnightId()
	local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(self._mainKnightId)		
	local mainKnightInfo = G_Me.bagData.knightsData:getKnightByKnightId(mainKnightId)
	if knightInfo and mainKnightInfo and knightInfo["level"] >= mainKnightInfo["level"] then
		G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_STRENGTH_TIP_LEVEL_EXCEED"))
		return false
	end

	return true
end

function HeroStrengthenLayer:_onChangeHero( index, widget, except )
	if not self:_checkKnightLevel() then
		return 
	end

	if self._isUpgradingKnight then 
		return 
	end

	self:_generateMaterialKnights()
	if not self._materialKnights or #self._materialKnights < 1 then
		return G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_STRENGTH_TIP_KNIGHT_RES"))
	end
	
	local HeroStrengthChoose = require("app.scenes.herofoster.HeroStrengthChoose")
	HeroStrengthChoose.showHeroChooseLayer( uf_sceneManager:getCurScene(), self._materialKnights, self._selectedKnights, self._upgradeNeedExp, self._maxUpgradeNeedExp, function ( knightIds, acquireExp )
		self:_onSelectedHeros( knightIds, acquireExp )
	end)
end

-- 点击材料武将上面的关闭按钮，移除当前材料武将
function HeroStrengthenLayer:_onRemoveKnight( index )
	index = index or 0
	if not self._selectedKnights or #self._selectedKnights < 1 then 
		return 
	end

	if index < 1 or index > #self._selectedKnights then 
		return 
	end

	local acquireExp =  G_Me.bagData.knightsData:getKnightAcquireExp(self._selectedKnights[index])
	self._selectedKnights[index] = 0
	self:_addKnightToBorder(self._knightBtns[index], 0, index, 0, 0.1, nil)

	local shouldStopMainKnightEffect = true
	for key, value in pairs(self._selectedKnights) do 
		if shouldStopMainKnightEffect and value > 0 then 
			shouldStopMainKnightEffect = false
		end
	end

	self:showTextWithLabel("Label_name_"..index, "")

	if shouldStopMainKnightEffect and self._mainKnightEffect then 
		self._mainKnightEffect:stop()
	end

	self._acquireMoney = self._acquireMoney - acquireExp
	self._getExp = self._getExp - acquireExp
	self:_updateExpChange()
end

function HeroStrengthenLayer:_addKnightToBorder( panel, knightId, index, delay, time, func )
	-- 在底盘上加载武将并转动底盘效果
		local callback = function ( ... )
			if func then 
				func()
			end
		end
		
		if not panel then 
			return callback()
		end

		local line = nil
		local dizuo = nil
		index = index or -1
		if index >= 0 then 
			line = self:getWidgetByName("ImageView_line_"..index)
			dizuo = self:getWidgetByName("ImageView_knight_"..index)
		end

		local baseId = G_Me.bagData.knightsData:getBaseIdByKnightId(knightId or 0)
		panel:removeAllChildren()
		panel:removeAllNodes()

		if dizuo then 
			dizuo:removeAllNodes()
		end

		self:showWidgetByName("Button_add_"..index, not knightId or knightId < 1)
		self:showWidgetByName("Button_remove_"..index, knightId and knightId > 0)
		if baseId <= 0 then 
			self:showTextWithLabel("Label_name_"..index, "")
			return callback()
		end

		local showBorderAndLineEffect = function ( border, line, di )
			if border then 
				border:setVisible(true)
				border:runAction(CCFadeIn:create(0.2))
			end

			if di and line then 
				local localPosx, localPosy = line:convertToWorldSpaceXY(0, 0)
				localPosx, localPosy = di:convertToNodeSpaceXY(localPosx, localPosy)
				local cao = EffectNode.new("effect_lancao")
				if cao then
					di:addNode(cao, -1, 1001)
					cao:setRotation(line:getRotation())
					cao:play()
					cao:setScaleX(0.1)
					cao:setPositionXY(localPosx, localPosy)
					cao:runAction(CCScaleTo:create(0.2, 2, 1))
				end
			end
		end

		local knightInfo = knight_info.get(baseId)
		local resId = knightInfo and knightInfo["res_id"] or 0

		local nameLabel = self:getLabelByName("Label_name_"..index)
		if nameLabel and knightInfo then 
			nameLabel:setColor(Colors.getColor(knightInfo.quality or 1))
			if knightInfo.advanced_level < 1 then
				nameLabel:setText(knightInfo.name)
			else
				nameLabel:setText(knightInfo.name.." + "..knightInfo.advanced_level)
			end
		end
		
		local effect = EffectNode.new("effect_dipan", 
    			function(event)
    			end)
			panel:addNode(effect, 0, 1001)
			effect:play()
			effect:setPosition(ccp(0, -45))
			effect:setScale(panel:getScale()*5.5)
		local knightBtn = knightPic.createKnightButton(resId, panel, "knight_button_"..index, self, function ( widget )
				self:_onChangeHero( index, widget, self._mainKnightId )
			end, true)
		if knightBtn then 
			knightBtn:setTag(1000)
			--knightBtn:setScale(0.8)
			local posx, posy = knightBtn:getPosition()
			local arr = CCArray:create()
			knightBtn:setPosition(ccp(posx, posy + 100))
			if delay > 0 then 
				knightBtn:setVisible(false)				
				arr:addObject(CCDelayTime:create(delay))
				arr:addObject(CCCallFunc:create(function ( ... )
					knightBtn:setVisible(true)
				end))
			end
			--local spawn = CCSpawn:createWithTwoActions(, CCScaleTo:create(time, 1))
			arr:addObject(CCEaseIn:create(CCMoveBy:create(time, ccp(0, -100)), time))
			arr:addObject(CCCallFunc:create(function (  )
        		showBorderAndLineEffect(backBoard, line, dizuo)
        		callback()
    		end))

			knightBtn:runAction(CCSequence:create(arr))
		end
	end

function HeroStrengthenLayer:_onSelectedHeros( selecteKnights, acquireExp )
	acquireExp = acquireExp or 0
	self._acquireMoney = acquireExp
	self._getExp = acquireExp
	self._selectedKnights = selecteKnights or {}

	-- 当选择材料武将的数量大于0时，则转动主角底盘下的特效，否则停止
	self._addKnightMaterials = #self._selectedKnights > 0
	if self._addKnightMaterials then 
		self._mainKnightEffect:play()
	else
		self._mainKnightEffect:stop()
	end

	self._isPlayingAnimation = true
	table.foreach(self._knightBtns, function ( index, panel )
		local knightId = self._selectedKnights[index]
			self:_addKnightToBorder(panel, knightId, index, 0, 0.15, index == #self._knightBtns and function ( ... )
				self._isPlayingAnimation = false
			end or nil )
	end)

	self:_updateExpChange()
	
	-- table.foreach(self._knightBtns, function ( i, btn )
	-- 	local knightId = self._selectedKnights[i]
	-- 	if btn then
	-- 		btn:removeAllChildren()
	-- 		--btn:removeNodeByTag(1000)
	-- 		if knightId then
	-- 			local baseId = G_Me.bagData.knightsData:getBaseIdByKnightId(knightId)
	-- 			local resId = 1
	-- 			local knightInfo = nil
	-- 			if baseId > 0 then
	-- 				knightInfo = knight_info.get(baseId)
	-- 			end

	-- 			if knightInfo ~= nil then
	-- 				resId = knightInfo["res_id"]

	-- 				local knightBtn = knightPic.createKnightButton(resId, btn, "knight_button_"..i, self, function ( widget )
	-- 					self:_onChangeHero( i, widget, self._mainKnightId )
	-- 				end, true)
	-- 				if knightBtn then 
	-- 					--knightBtn:setScale(0.3)
	-- 				end
	-- 				--local heroPath = G_Path.getKnightPic(resId)
 --    				--btn:loadTextureNormal(heroPath, UI_TEX_TYPE_LOCAL)
    				
 --    				if knightInfo.star > self._maxStarKnight then
 --    					self._maxStarKnight = knightInfo.star 
 --    				end
	-- 			else
	-- 				__LogError("knightinfo is nil for baseId:%d", baseId)
	-- 			end
	-- 		end

	-- 		--self:showWidgetByName("Button_knight_icon_"..i, knightId and knightId > 0)
	-- 		self:showWidgetByName("Button_add_"..i, not knightId or knightId < 1)
	-- 		self:showWidgetByName("ImageView_line_"..i.."_"..i, knightId and knightId > 0)
	-- 		self:_brighterKnightLine(i)
	-- 	end
	-- end)
end

function HeroStrengthenLayer:_updateExpChange( ... )
	local label = self:getLabelByName("Label_yinbi_value")
	if label then
		label:setColor(G_Me.userData.money >= self._getExp and ccc3(0x50, 0x3e, 0x32) or ccc3(255, 0, 0))
		label:setText(""..self._getExp)
	end

	local mainKnightId = G_Me.formationData:getMainKnightId()
	local mainKnightInfo = G_Me.bagData.knightsData:getKnightByKnightId(mainKnightId)
	local mainKnightLevel = mainKnightInfo and mainKnightInfo["level"] or 1
	local destLevel, offsetLevel, needExp, maxExp, expRait = self:_calcUpgradeDestLevel(self._getExp, mainKnightLevel)

	self._upgradeLevel = offsetLevel
	self._upgradePercent = expRait

	self:showTextWithLabel("Label_jingjie", offsetLevel > 0 and "+"..offsetLevel or "")
	self:_blurWidget("Label_jingjie", offsetLevel > 0, 0.5)

	local progress = self:getLoadingBarByName("LoadingBar_exp")
	if progress then
		progress:setModificationVisible(true)
		if offsetLevel > 0 then
			progress:setModificationPercent(100)
		else
			progress:setModificationPercent(expRait)
		end

		if self._getExp > 0 then
			progress:blurModification(true)
		end
	end

	label = self:getLabelByName("Label_exp_value")
	if label then
		label:setText(""..self._getExp)
	end
	
	local curKnightInfo = G_Me.bagData.knightsData:getKnightByKnightId(self._mainKnightId)
	local curKnightBaseInfo = knight_info.get(curKnightInfo and curKnightInfo["base_id"] or 0)

	self:_blurWidget("Label_hp_value_offset", curKnightBaseInfo and offsetLevel > 0, 0.5)
	self:_blurWidget("Label_attack_value_offset", curKnightBaseInfo and offsetLevel > 0, 0.5)
	self:_blurWidget("Label_deffenw_value_offset", curKnightBaseInfo and offsetLevel > 0, 0.5)
	self:_blurWidget("Label_deffenf_value_offset", curKnightBaseInfo and offsetLevel > 0, 0.5)

	self:showTextWithLabel("Label_hp_value_offset", (curKnightBaseInfo and offsetLevel > 0) and "+"..(offsetLevel*curKnightBaseInfo.develop_hp) or "")
	if curKnightBaseInfo and offsetLevel > 0 then 
		if curKnightBaseInfo.damage_type == 1 then
			--self._upgradeAttributes[G_lang:get("LANG_GROWUP_ATTRIBUTE_GONGJI")]	= offsetLevel*curKnightBaseInfo.develop_physical_attack
			self:showTextWithLabel("Label_attack_value_offset", "+"..(offsetLevel*curKnightBaseInfo.develop_physical_attack))
		else
			--self._upgradeAttributes[G_lang:get("LANG_GROWUP_ATTRIBUTE_GONGJI")]	= offsetLevel*curKnightBaseInfo.develop_magical_attack
			self:showTextWithLabel("Label_attack_value_offset", "+"..(offsetLevel*curKnightBaseInfo.develop_magical_attack))
		end
	else
		self:showTextWithLabel("Label_attack_value_offset", "")
	end
	
	self:showTextWithLabel("Label_deffenw_value_offset", (curKnightBaseInfo and offsetLevel > 0) and "+"..(offsetLevel*curKnightBaseInfo.develop_physical_defence) or "")
	self:showTextWithLabel("Label_deffenf_value_offset", (curKnightBaseInfo and offsetLevel > 0) and "+"..(offsetLevel*curKnightBaseInfo.develop_magical_defence) or "")
end

function HeroStrengthenLayer:_blurWidget( labelName, blur, offset )
	if not labelName then
		return 
	end
	local labelCtrl = self:getWidgetByName(labelName)
	if not labelCtrl then
		return 
	end

	blur = blur or false
	offset = offset or 0.1

	if blur then
		labelCtrl:stopAllActions()
		local fadeInAction = CCFadeIn:create(offset)
		local fadeOutAction = CCFadeOut:create(offset)
		local seqAction = CCSequence:createWithTwoActions(fadeInAction, fadeOutAction)
		seqAction = CCRepeatForever:create(seqAction)
		labelCtrl:runAction(seqAction)
	else
		labelCtrl:stopAllActions()
		labelCtrl:setOpacity(255)
	end
end

function HeroStrengthenLayer:_brighterKnightLine( index )
	if index < 1 or index > 5 then 
		return 
	end

	local line = self:getWidgetByName("ImageView_line_"..index.."_"..index)
	if not line then
		return 
	end

	line:setScaleX(0.1)

	local scale = CCScaleTo:create(0.5, 1, 1)
	scale = CCEaseIn:create(scale, 0.5)
	line:runAction(scale)
end

function HeroStrengthenLayer:_generateMaterialKnights( force )
	if self._materialKnights and not force then
		return 
	end

	-- 生成材料武将列表：
	-- 先排除上阵武将，再按潜力值，品质和级别从小到大的顺序排列
	local firstTeam = G_Me.formationData:getFirstTeamKnightIds()
	local secondTeam = G_Me.formationData:getSecondTeamKnightIds()

	local exceptArr = {}
	if firstTeam then
		table.foreach(firstTeam, function ( i , value )
			if value > 0 then
				exceptArr[value] = 1
			end
		end)
	end
	if secondTeam then
		table.foreach(secondTeam, function ( i , value )
			if value > 0 then
				exceptArr[value] = 1
			end
		end)
	end
	if self._mainKnightId ~= nil and exceptArr[self._mainKnightId] == nil then
		exceptArr[self._mainKnightId] = 1
	end

	self._materialKnights = G_Me.bagData.knightsData:getMaterialKnight( exceptArr )
	local sortFunc = function( knightId1, knightId2 )
        local knight1 = G_Me.bagData.knightsData:getKnightByKnightId(knightId1)
        local knight2 = G_Me.bagData.knightsData:getKnightByKnightId(knightId2)

        if not knight1 then
        	return false
       	elseif not knight2 then
       		return true
		end        	

		local knightBase1 = knight_info.get(knight1["base_id"])
		local knightBase2 = knight_info.get(knight2["base_id"])
		if not knightBase1 then 
			return false
		elseif not knightBase2 then
			return true
		end

		if knightBase1.potential ~= knightBase2.potential then
			return knightBase1.potential < knightBase2.potential
		end

		if knightBase1.quality ~= knightBase2.quality then 
        	return knightBase1.quality < knightBase2.quality
        end

		if knightBase1.star ~= knightBase2.star then
	        return knightBase1.star < knightBase2.star 
        end     

        if knight1["level"] ~= knight2["level"] then
        	return knight1["level"] < knight2["level"]
        end
        
        return false
    end

    table.sort(self._materialKnights, sortFunc)
end

function HeroStrengthenLayer:_onAutoAddHero(  )
	if self._isPlayingAnimation then 
		return 
	end

	if not self:_checkKnightLevel() then
		return 
	end

	self:_generateMaterialKnights()
    local autoSelectKnight = {}
    for key, value in pairs(self._materialKnights) do
    	local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId( value )
    	if knightInfo then
    		local knightBaseInfo = knight_info.get(knightInfo["base_id"])
    		if knightBaseInfo and knightBaseInfo.potential <= 12 then
    			table.insert(autoSelectKnight, #autoSelectKnight + 1, value)
    		end
    	end
    end
    
    -- 最多选择5个材料武将
    while #autoSelectKnight > 5 do
    	table.remove(autoSelectKnight, #autoSelectKnight)
    end

    local acquireExp = 0
    local retKnight = {}
    for key, value in pairs(autoSelectKnight) do 
    	if self._maxUpgradeNeedExp > acquireExp then
    		acquireExp = acquireExp + G_Me.bagData.knightsData:getKnightAcquireExp(value)
    		table.insert(retKnight, #retKnight + 1, value)
    	end
    end

    if #retKnight < 1 then
    	G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_STRENGTH_TIP_NO_MATERIAL_KNIGHT"))
    else
    	self:_onSelectedHeros( retKnight, acquireExp )	
    end    
end

function HeroStrengthenLayer:_onStrengthHero(  )
	if self._isPlayingAnimation or self._isUpgradingKnight then 
		return 
	end

	if not self:_checkKnightLevel() then
		return 
	end

	local validKnights = {}
	for key, value in pairs(self._selectedKnights) do 
		if value > 0 then 
			table.insert(validKnights, #validKnights + 1, value)
		end
	end

	if #validKnights < 1 then 
		G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_STRENGTH_TIP_ADDKNIGHT"))
		return 
	end

	if self._mainKnightId == 0 then
		__LogError("mainKnightId is not valid!")
		return 
	end

	if self._acquireMoney > 0 and self._acquireMoney > G_Me.userData.money  then
		require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_MONEY, 0,
			GlobalFunc.sceneToPack("app.scenes.herofoster.HeroDevelopScene", {KnightConst.KNIGHT_TYPE.KNIGHT_STRENGTHEN, self._mainKnightId}))
			--G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_JINGJIE_TIP_MONEY"))
		return
	end

	local hideRemoveBtns = function ( ... )
		for loopi = 1, 5, 1 do 
			self:showWidgetByName("Button_remove_"..loopi, false)
		end
	end

	local doCheckExp = function (  )
		local doUpgradeKnightRequest = function (  )
			self._isUpgradingKnight = true
			hideRemoveBtns()
			G_HandlersManager.heroUpgradeHandler:sendUpgradeKnightRequest(self._mainKnightId, validKnights)
		end

		-- 当前经验足以让武将超过最大级别时，弹提示框提示是否需要继续
		if self._getExp > self._upgradeNeedExp and self._nextLevelIsMax then
			return MessageBoxEx.showYesNoMessage(nil, 
				G_lang:get("LANG_EXPERIENCE_EXCEED"), false, 
				function (  )
					doUpgradeKnightRequest()
				end)
		end

		doUpgradeKnightRequest()
	end	

	-- if self._maxStarKnight > 4 then
	-- 	return MessageBoxEx.showYesNoMessage(nil, G_lang:get("LANG_KNIGHT_STRENGTH_TIP_KNIGHT_4STAR"), false, function (  )
	-- 		doCheckExp()
	-- 	end)
	-- end
	
	doCheckExp()
end

function HeroStrengthenLayer:_hideAllAddBtns( ... )
	self:showWidgetByName("Button_add_1", false)
	self:showWidgetByName("Button_add_2", false)
	self:showWidgetByName("Button_add_3", false)
	self:showWidgetByName("Button_add_4", false)
	self:showWidgetByName("Button_add_5", false)
end

function HeroStrengthenLayer:_onReceiveStrengthRet( ret )
	if ret == NetMsg_ERROR.RET_OK then
		self:_hideAllAddBtns()
		self:_generateMaterialKnights(true)
		self:_playStrengthenAnimation(self._upgradeLevel > 0, function ( ... )
			--self:_playAttributeChange()
			self:_flyAttributeChange()
			self._selectedKnights = {}
			self:_onSelectedHeros({}, 0)

		end)						
	end
	self._isUpgradingKnight = false
end

function HeroStrengthenLayer:_playStrengthenAnimation( hasLevelup, func )
	hasLevelup = hasLevelup or false

	-- 强化特效播放顺序：
	-- 吃掉武将的同时，武将底盘效果消失，连接线消失，强化成功特效, 升级特效
	local eatKnight = function ( panel, index, time, func )
		if not panel then 
			return 
		end

		local knightSprite = self:getWidgetByName("knight_button_"..index)
		if not knightSprite then 
			return 
		end

		self:showTextWithLabel("Label_name_"..index, "")

		local backBoard = nil 
		local dizuo = nil
		index = index or -1
		if index >= 0 then 
			backBoard = panel:getNodeByTag(1001)
			dizuo = self:getWidgetByName("ImageView_knight_"..index)
		end

		local mainWidget = self:getWidgetByName("ImageView_main")
		local mainPosx = 0
		local mainPosy = 0
		if mainWidget then 
			mainPosx, mainPosy = mainWidget:convertToWorldSpaceXY(mainPosx, mainPosy)
		end
		local eatBorderAndLineEffect = function ( dizuo, func, time )
			if dizuo then 
					local effect = dizuo and dizuo:getNodeByTag(1001)
					local localPosx, localPosy = dizuo:convertToNodeSpaceXY(mainPosx, mainPosy)
					if effect then 
						local spawn = CCSpawn:createWithTwoActions(CCMoveTo:create(time, ccp(localPosx, localPosy)),
							CCScaleTo:create(time, 0.1, 1))

						local soundConst = require("app.const.SoundConst")
    					G_SoundManager:playSound(soundConst.GameSound.KNIGHT_EAT_MATERIAL)

						effect:runAction(CCSequence:createWithTwoActions(CCEaseOut:create(spawn, time), 
							CCCallFunc:create(function ( ... )
									dizuo:removeNode(effect)
									--effect:removeFromParentAndCleanup(true)
									if func then 
										func()
									end
								end)))
					else
						if func then 
							func()
						end
					end
			else
				if func then 
					func()
				end
			end			
		end

		if knightSprite then 
			local arr1 = CCArray:create()
			arr1:addObject(CCFadeOut:create(time))
			arr1:addObject(CCMoveBy:create(time, ccp(0, -100)))
			arr1:addObject(CCScaleTo:create(time, 0.5))

			local spawn = CCSpawn:create(arr1)
			local arr = CCArray:create()
			arr:addObject(CCDelayTime:create(0.2))
			arr:addObject(CCEaseOut:create(spawn, time))
			arr:addObject(CCCallFunc:create(function (  )
        		eatBorderAndLineEffect(dizuo, func, 0.2)
        		knightSprite:setVisible(false)
    		end))

			local effect = nil
			effect = EffectNode.new("effect_xiaoshi", 
    			function(event)
       				if event == "finish" and effect then
            			effect:removeFromParentAndCleanup(true)
       				end
    			end)
			panel:addNode(effect)
			effect:play()
			effect:setPosition(ccp(0, 30))
			knightSprite:runAction(CCSequence:create(arr))
			backBoard:runAction(CCFadeOut:create(time))
		end
	end

	if #self._selectedKnights < 1 then 
		return 
	end

	local wolunEffect = nil 
	local stopWolunEffect = function ( ... )
		if wolunEffect then
			wolunEffect:removeFromParentAndCleanup(true)
		end
	end

	local fangguangEffect = function ( knightNode, func )
		if not knightNode then 
			if func then
				func()
			end
			return 
		end

		local fangguang = nil 
		fangguang = EffectNode.new("effect_faguang2", 
    		function(event)
       			if event == "finish" and fangguang then 
            		fangguang:removeFromParentAndCleanup(true)
            		if func then 
    					func()
    				end
       			end
    		end)
		fangguang:play()
		--fangguang:setScale(1.5)
		fangguang:setPosition(ccp(0, 75))
    	knightNode:addNode(fangguang, 10)
	end	

	local mainBorder = self:getWidgetByName("ImageView_main")
	if mainBorder then 
		wolunEffect = EffectNode.new("effect_wolun", function ( event )
			if event == "finish" and wolunEffect then 
				wolunEffect:removeFromParentAndCleanup(true)
			end
		end)
		wolunEffect:play()
		local border = self:getWidgetByName("Panel_main_icon")
		if border then 
			__Log("pos(%d, %d)", border:getPosition())
			wolunEffect:setPosition(ccp(border:getPosition()))
		end
		mainBorder:addNode(wolunEffect)
	end

	local levelupEffect = function ( knightNode, func )
		if not knightNode then 
			if func then
				func()
			end
			return 
		end
		local levelup = nil 
		levelup = EffectNode.new("effect_qianghua_levelup", 
    		function(event)
       			if event == "finish" and levelup then
           			levelup:removeFromParentAndCleanup(true)
           			if func then 
    					func()
    				end
       			end
    		end)
    	knightNode:addNode(levelup, 10)
    	levelup:setPosition(ccp(-18, 30))
    	levelup:setVisible(false)
    	knightNode:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.4),
    	 	CCCallFunc:create(function ( ... )
    	 		levelup:setVisible(true)
    			levelup:play()
				--levelup:setScale(1.5)
    		end)))
	end

	self._isPlayingAnimation = true
	local firstKnight = true
	table.foreach(self._knightBtns, function ( index, panel )
		local knightId = self._selectedKnights[index] or 0
		if knightId > 0 then 
			eatKnight(panel, index,  0.3, firstKnight and function ( ... )
				stopWolunEffect()
				local soundConst = require("app.const.SoundConst")
            	G_SoundManager:playSound(soundConst.GameSound.KNIGHT_STRENGTH_UPGRADE)
				levelupEffect(mainBorder, function ( ... )
					if func then 
						func()
					end
					self._isPlayingAnimation = false
				end)
				--fangguangEffect(mainBorder, function ( ... )
				--	if hasLevelup then 
						

						
			--		else
			--			if func then 
			--				func()
			--			end
			--			self._isPlayingAnimation = false
			--		end
				end or nil)
			firstKnight = false
			--end or nil)
		end
	end)
end

function HeroStrengthenLayer:_flyAttributeChange( ... )
	local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(self._mainKnightId)
	if not knightInfo then
		return 
	end

	-- 没有升级时，只需要弹一个经验增加值的属性值滚动
	-- 有升级时，需要弹升到的目标级别，同时提示各属性增加值
	self._materialKnights = nil
	local count = 0
	if self._upgradeLevel < 1 then
		G_flyAttribute.doAddRichtext(G_lang:get("LANG_KNIGHT_STRENGTH_TIP_STRENGTH_SUCCESS", {addExp=self._getExp}), 30, nil, nil)
	else
		G_flyAttribute.addNormalText(G_lang:get("LANG_KNIGHT_STRENGTH_TIP_STRENGTH_TO_LEVEL", {levelValue = knightInfo["level"]}), nil, self:getLabelByName("Label_level"), self._upgradeLevel)
	end	

	self:_blurWidget("Label_hp_value_offset", false)
	self:_blurWidget("Label_deffenf_value_offset", false)
	self:_blurWidget("Label_deffenw_value_offset", false)
	self:_blurWidget("Label_attack_value_offset", false)

	local progress = self:getLoadingBarByName("LoadingBar_exp")
	if progress then
		progress:runToPercent(self._upgradeLevel*100 + self._upgradePercent, 0.5)
    end

	if self._upgradeLevel > 0 then 
		--local beforeLevel = knightInfo["level"] - self._upgradeLevel
    	--local label = self:getLabelByName("Label_level")
    	--local growupNumber = CCNumberGrowupAction:create(beforeLevel, beforeLevel + self._upgradeLevel, 0.5*self._upgradeLevel, function ( number )
    	--	if label then
		--		label:setText(number)
		--	end
		--end)
    	--label:runAction(growupNumber)

		G_flyAttribute.addKnightAttributeWithLevelOffset(knightInfo["base_id"], self._upgradeLevel, self._knightAttriCtrls)

		local _, lastTargetLevel, _ = G_Me.formationData:getKnightFriendTarget(1)
		if lastTargetLevel > self._lastTargetLevel then
			local info = team_target_info.get(5, lastTargetLevel)

			local desc = G_lang:get("LANG_KNIGHT_FRIEND_STRENGTH_TITLE", {level = lastTargetLevel})
			G_flyAttribute.doAddRichtext(desc, nil, nil, nil, self:getWidgetByName("Label_title1"))
			for i = 1 , 4 do 
			    if info["att_type_"..i] > 0 then
			        local attrtype,attrvalue,strtype,strvalue = MergeEquipment.convertAttrTypeAndValue(info["att_type_"..i], info["att_value_"..i])
			        G_flyAttribute.doAddRichtext(strtype.."  +"..strvalue, nil, nil, nil, nil)
			    end
			end
		end

		G_flyAttribute.play(function ( ... )
			if self.__EFFECT_FINISH_CALLBACK__ then 
            	self.__EFFECT_FINISH_CALLBACK__(...)
        	end

        	if self._initMainHero then
        		self:_initMainHero(self._mainKnightId)
        	end
		end)
	else
        if self._initMainHero then
			self:_initMainHero(self._mainKnightId)
		end
		G_flyAttribute.play()
	end
end

-- 这是旧的属性变化提示，现在不用了
function HeroStrengthenLayer:_playAttributeChange( ... )
	local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(self._mainKnightId)
	if not knightInfo then
		return 
	end

	self._materialKnights = nil
	local count = 0
	if self._upgradeLevel < 1 then
		count = G_playAttribute.playTextArray({G_lang:get("LANG_KNIGHT_STRENGTH_TIP_STRENGTH_SUCCESS")}, 0)
		--G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_STRENGTH_TIP_STRENGTH_SUCCESS"))
	else
		count = G_playAttribute.playTextArray({G_lang:get("LANG_KNIGHT_STRENGTH_TIP_STRENGTH_TO_LEVEL", {levelValue = knightInfo["level"]})}, 0)
	end	

	G_playAttribute.playKnightAttributeWithLevelOffset(knightInfo["base_id"], self._upgradeLevel, count, function ( ... )
		if self.__EFFECT_FINISH_CALLBACK__ then 
            self.__EFFECT_FINISH_CALLBACK__(...)
        end
	end)

    if self._upgradeLevel < 1 or not knightInfo then
    	self:_initMainHero(self._mainKnightId)
    	return
    end

    local beforeLevel = knightInfo["level"] - self._upgradeLevel
    local label = self:getLabelByName("Label_level")
    local growupNumber = CCNumberGrowupAction:create(beforeLevel, beforeLevel + self._upgradeLevel, 0.5*self._upgradeLevel, function ( number )
    	if label then
			label:setText(number)
		end
	end)
    label:runAction(growupNumber)

	local curKnightInfo = G_Me.bagData.knightsData:getKnightByKnightId(self._mainKnightId)
	local curKnightBaseInfo = knight_info.get(curKnightInfo and curKnightInfo["base_id"] or 0)
	if not curKnightBaseInfo then
		return 
	end

	self:_blurWidget("Label_hp_value_offset", false)
	self:_blurWidget("Label_deffenf_value_offset", false)
	self:_blurWidget("Label_deffenw_value_offset", false)
	self:_blurWidget("Label_attack_value_offset", false)

	local numberGrowMax = 0
	local growupHp = self._upgradeLevel * curKnightBaseInfo.develop_hp
	local growupPhysicDef = self._upgradeLevel * curKnightBaseInfo.develop_physical_defence
	local growupMagicDef = self._upgradeLevel * curKnightBaseInfo.develop_magical_defence
	local growupAttack = 0
	if curKnightBaseInfo.damage_type == 1 then
		growupAttack = self._upgradeLevel * curKnightBaseInfo.develop_physical_attack
	else
		growupAttack = self._upgradeLevel * curKnightBaseInfo.develop_magical_attack
	end

	numberGrowMax = numberGrowMax > growupHp and numberGrowMax or growupHp
	numberGrowMax = numberGrowMax > growupPhysicDef and numberGrowMax or growupPhysicDef
	numberGrowMax = numberGrowMax > growupMagicDef and numberGrowMax or growupMagicDef
	numberGrowMax = numberGrowMax > growupAttack and numberGrowMax or growupAttack

	local growupAttribute = CCNumberGrowupAction:create(0, numberGrowMax, 0.5*self._upgradeLevel, function ( number )
		if number <= growupHp then
    		self:showTextWithLabel("Label_hp_value", self._knightAttributes["hp"] + number)
    		self:showTextWithLabel("Label_hp_value_offset", growupHp - number)
    		if growupHp <= number then
    			self:showTextWithLabel("Label_hp_value_offset", "")
    		end
    	end
    	if number <= growupPhysicDef then
    		self:showTextWithLabel("Label_deffenf_value", self._knightAttributes["md"] + number)
    		self:showTextWithLabel("Label_deffenf_value_offset", growupPhysicDef - number)
    		if growupPhysicDef<= number then
    			self:showTextWithLabel("Label_deffenf_value_offset", "")
    		end
    	end
    	if number <= growupMagicDef then
    		self:showTextWithLabel("Label_deffenw_value", self._knightAttributes["pd"] + number)
    		self:showTextWithLabel("Label_deffenw_value_offset", growupMagicDef - number)
    		if growupMagicDef <= number then
    			self:showTextWithLabel("Label_deffenw_value_offset", "")
    		end
    	end
    	if number <= growupAttack then
    		self:showTextWithLabel("Label_attack_value", self._knightAttributes["at"] + number)
    		self:showTextWithLabel("Label_attack_value_offset", growupAttack - number)
    		if growupAttack <= number then
    			self:showTextWithLabel("Label_attack_value_offset", "")
    		end
    	end
	end)
	local arr = CCArray:create()
	arr:addObject(growupAttribute)
	arr:addObject(CCCallFunc:create(function (  )
		self:_initMainHero(self._mainKnightId)
	end))
    self:runAction(CCSequence:create(arr))
end


return HeroStrengthenLayer
