local EffectNode = require("app.common.effects.EffectNode")
local HeroSoulConst = require("app.const.HeroSoulConst")
local HeroSoulChartRankLayer = require("app.scenes.herosoul.HeroSoulChartRankLayer")

local HeroSoulMainLayer = class("HeroSoulMainLayer", UFCCSNormalLayer)

function HeroSoulMainLayer.create(scenePack)
	local layer = HeroSoulMainLayer.new("ui_layout/herosoul_MainLayer.json", nil, scenePack)
	return layer
end

function HeroSoulMainLayer:ctor(jsonFile, fun, scenePack)
	self._hasGetLocalRanks = false
	self._hasGetCrossRanks = false
	self._tScrollView = self:getScrollViewByName("ScrollView_Map")

	self.super.ctor(self, jsonFile, fun)
	G_GlobalFunc.savePack(self, scenePack)
end

function HeroSoulMainLayer:onLayerLoad()
	self:_initSoulInfo()
	self:_initWidgets()
end

function HeroSoulMainLayer:onLayerEnter()
	local oldSize = self._tScrollView:getSize()
	self._tScrollView:setSize(CCSize(oldSize.width, display.height))
	self:_addMapEffect()

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HERO_SOUL_GET_SOUL_INFO, self._updateRedTips, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HERO_SOUL_GET_CHART_RANK, self._onRcvChartRank, self)
	
	if G_Me.heroSoulData:isAnotherDay() then
		G_HandlersManager.heroSoulHandler:sendGetSoulInfo()
	else
		self:_updateRedTips()
	end
end

function HeroSoulMainLayer:onLayerExit()
	uf_eventManager:removeListenerWithTarget(self)
end

function HeroSoulMainLayer:_initWidgets()
	self:_initEntryButtons()

	self:registerBtnClickEvent("Button_Help", function()
		require("app.scenes.common.CommonHelpLayer").show({
			{title=G_lang:get("LANG_HERO_SOUL_HELP_TITLE1"), content=G_lang:get("LANG_HERO_SOUL_HELP_CONTENT1")},
			{title=G_lang:get("LANG_HERO_SOUL_HELP_TITLE2"), content=G_lang:get("LANG_HERO_SOUL_HELP_CONTENT2")},
			{title=G_lang:get("LANG_HERO_SOUL_HELP_TITLE3"), content=G_lang:get("LANG_HERO_SOUL_HELP_CONTENT3")},
			{title=G_lang:get("LANG_HERO_SOUL_HELP_TITLE4"), content=G_lang:get("LANG_HERO_SOUL_HELP_CONTENT4")},
    	})
	end)
	self:registerBtnClickEvent("Button_Back", function()
		uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.mainscene.MainScene").new())
	end)
	self:registerBtnClickEvent("Button_ChartRank", function()
		self:_onClickChartRank()
	end)
end

function HeroSoulMainLayer:_initEntryButtons()
	self._imgTrial = self:getImageViewByName("Image_HeroTrial")
	self._imgShop = self:getImageViewByName("Image_Shop")
	self._imgTerrace = self:getImageViewByName("Image_HeroTerrace")
	self._imgChart = self:getImageViewByName("Image_Chart")

	local tClickPanelList = {
		"Panel_HeroTrial", "Panel_Shop", "Panel_HeroTerrace", "Panel_Chart",
	}
	local tImgList = {
		self._imgTrial, self._imgShop, self._imgTerrace, self._imgChart
	}
	local tFuncList = {
		self._onClickHeroTrial, self._onClicShop, self._onClickHeroTerrace, self._onClickChart
	}

	for i=1, 4 do
		self:registerWidgetTouchEvent(tClickPanelList[i], function(sender, eventType)
			if eventType == TOUCH_EVENT_BEGAN then
				tImgList[i]:setScale(1.1)
			elseif eventType == TOUCH_EVENT_ENDED then
				tImgList[i]:setScale(1)
				tFuncList[i](self)
			elseif eventType == TOUCH_EVENT_CANCELED then
				tImgList[i]:setScale(1)
			end
		end)
	end

	local tEffNameList = {
		"effect_jiangling_a", "effect_jiangling_b", "effect_jiangling_c", "effect_jiangling_d", 
	}
	local tOffsetYList = {
		5, 5, 10, 90
	}

	for i=1, 4 do
		tImgList[i]:setCascadeOpacityEnabled(false)
		tImgList[i]:setOpacity(0)
		self:_addButtonEffect(tImgList[i], tEffNameList[i], tOffsetYList[i])
	end
end

function HeroSoulMainLayer:jumpToPercent()
	self._tScrollView:jumpToPercentVertical(G_Me.heroSoulData:getMovePercent())
end

function HeroSoulMainLayer:_onClickChart()
	uf_sceneManager:getCurScene():goToLayer("HeroSoulChartLayer", true)
	self:_calcMovePercent()
end

function HeroSoulMainLayer:_onClickHeroTerrace()
	uf_sceneManager:getCurScene():goToLayer("HeroSoulTerraceLayer", true)
	self:_calcMovePercent()
end

function HeroSoulMainLayer:_onClickHeroTrial()
	uf_sceneManager:getCurScene():goToLayer("HeroSoulTrialLayer", true)
	self:_calcMovePercent()
end

function HeroSoulMainLayer:_onClicShop()
	local pack = G_GlobalFunc.sceneToPack("app.scenes.herosoul.HeroSoulScene")
	uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.herosoul.HeroSoulShopScene").new(pack))
	self:_calcMovePercent()
end

function HeroSoulMainLayer:_updateRedTips()
	-- 将灵商店
	self:showWidgetByName("Image_ShopTips", G_Me.heroSoulData:showSoulShopRedTips())
	-- 点将台
	self:showWidgetByName("Image_TerraceTips", G_Me.heroSoulData:getFreeExtractCount() > 0)
	-- 名将试炼
	self:showWidgetByName("Image_TrialTips", G_Me.heroSoulData:getLeftDgnChallengeCount() > 0)
	-- 灵阵图
	self:showWidgetByName("Image_ChartTips", G_Me.heroSoulData:hasChartToActivate() or
											 G_Me.heroSoulData:hasAchievementToActivate())
end

function HeroSoulMainLayer:_calcMovePercent()
	local tContainer = self._tScrollView:getInnerContainer()
	local nOffsetH = tContainer:getSize().height - self._tScrollView:getSize().height 
	local nPosY = tContainer:getPositionY()
	local nMoveY = nOffsetH + nPosY
	local nPercent = nMoveY / nOffsetH * 100

	G_Me.heroSoulData:setMovePercent(nPercent)
end

function HeroSoulMainLayer:_addMapEffect()
	local bgImg = self:getImageViewByName("Image_Bg")

	local tParent = bgImg
	if not tParent then
		return
	end
	if not self._tMapEffect and require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
		self._tMapEffect = EffectNode.new("effect_jiangling_bg", function(event, frameIndex)
			if event == "finish" then
	
			end
		end)
		self._tMapEffect:play()
		local tSize = tParent:getContentSize()
		tParent:addNode(self._tMapEffect, 10)
	end
end

function HeroSoulMainLayer:_addButtonEffect(tParent, szEffect, nOffsetY)
	local tEffect = EffectNode.new(szEffect, function(event, frameIndex)
		if event == "finish" then

		end
	end)
	tEffect:setPositionY(nOffsetY)
	tEffect:play()
	local tSize = tParent:getContentSize()
	tParent:addNode(tEffect)
end

-- receive chart rank data
function HeroSoulMainLayer:_onRcvChartRank(rankType)
	if rankType == HeroSoulConst.RANK_LOCAL then
		self._hasGetLocalRanks = true
	else
		self._hasGetCrossRanks = true
	end

	if self._hasGetLocalRanks and self._hasGetCrossRanks then
		HeroSoulChartRankLayer.show()
	end
end

-- click chart rank button
function HeroSoulMainLayer:_onClickChartRank()
	self._hasGetLocalRanks = false
	self._hasGetCrossRanks = false
	G_HandlersManager.heroSoulHandler:sendGetChartRank(HeroSoulConst.RANK_LOCAL)
	G_HandlersManager.heroSoulHandler:sendGetChartRank(HeroSoulConst.RANK_CROSS)
end

function HeroSoulMainLayer:_initSoulInfo()
	self:enableLabelStroke("Label_SoulPoint", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_SoulPoint_Num", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_ChartValue", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_CharValue_Num", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Activated", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Activated_Num", Colors.strokeBrown, 1)


	-- initialize some values
	self:showTextWithLabel("Label_SoulPoint_Num", tostring(G_Me.userData.hero_soul_point))

	local chartPoints = G_Me.heroSoulData:getChartPoints()
	self:showTextWithLabel("Label_CharValue_Num", tostring(chartPoints))

	local activatedChartsNum = G_Me.heroSoulData:getActivatedChartsNum()
	self:showTextWithLabel("Label_Activated_Num", tostring(activatedChartsNum))
end

return HeroSoulMainLayer