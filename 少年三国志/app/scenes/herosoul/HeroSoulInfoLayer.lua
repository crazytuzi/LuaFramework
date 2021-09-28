-- HeroSoulInfoLayer 将灵信息面板
-- This layer shows the basic info and associated charts of a hero-soul,
-- with its ID passed in as the parameter.
local HeroSoulInfoLayer = class("HeroSoulInfoLayer", UFCCSModelLayer)

require("app.cfg.ksoul_info")
require("app.cfg.ksoul_group_info")
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

-- 阵图表的一些宏
HeroSoulInfoLayer.CHART_GAP_HOR		= 161			-- 两个label的水平距离
HeroSoulInfoLayer.CHART_GAP_VER		= 35			-- 两个label的垂直距离
HeroSoulInfoLayer.CHARTS_PER_LINE	= 3 			-- 每行显示label数

function HeroSoulInfoLayer.show(soulId)
	local layer = HeroSoulInfoLayer.new("ui_layout/herosoul_SoulInfoLayer.json", Colors.modelColor, soulId)
	uf_sceneManager:getCurScene():addChild(layer)
	return layer
end

function HeroSoulInfoLayer:ctor(jsonFile, color, soulId)
	self._soulId = soulId
	self.super.ctor(self, jsonFile, color)
end

function HeroSoulInfoLayer:onLayerLoad()
	-- initialize
	self:_initBaseInfo()
	self:_initAssociatedCharts()

	-- label stroke
	self:enableLabelStroke("Label_SoulName", Colors.strokeBrown, 1)

	-- register button click events
	self:registerBtnClickEvent("Button_ToGet", handler(self, self._onClickToGet))
	self:registerBtnClickEvent("Button_Close", handler(self, self._onClickClose))
end

function HeroSoulInfoLayer:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)

	-- bounce in the layer
	EffectSingleMoving.run(self:getWidgetByName("Image_Bg"), "smoving_bounce")
end

function HeroSoulInfoLayer:_initBaseInfo()
	local soulInfo = ksoul_info.get(self._soulId)

	-- head icon
	local iconPath = G_Path.getKnightIcon(soulInfo.res_id)
	self:getImageViewByName("Image_Head"):loadTexture(iconPath)

	-- quality bg and quality frame
	local bgPath = G_Path.getEquipIconBack(soulInfo.quality)
	self:getImageViewByName("Image_QualityBg"):loadTexture(bgPath, UI_TEX_TYPE_PLIST)

	local framePath = G_Path.getEquipColorImage(soulInfo.quality, G_Goods.TYPE_HERO_SOUL)
	self:getImageViewByName("Image_QualityFrame"):loadTexture(framePath)

	-- name
	local nameLabel = self:getLabelByName("Label_SoulName")
	nameLabel:setText(soulInfo.name)
	nameLabel:setColor(Colors.qualityColors[soulInfo.quality])

	-- description
	self:showTextWithLabel("Label_SoulDesc", soulInfo.directions)

	-- count
	local count = G_Me.heroSoulData:getSoulNum(self._soulId)
	local strCount = G_lang:get("LANG_GOODS_NUM", {num = count})
	self:showTextWithLabel("Label_Num", strCount)
end

function HeroSoulInfoLayer:_initAssociatedCharts()
	local charts = G_Me.heroSoulData:getAllChartsBySoul(self._soulId)
	local numActivated = 0
	local parent = self:getScrollViewByName("ScrollView_Charts")
	local parentSize = parent:getSize()

	-- create the chart name table
	local tempArr = {}
	for i, v in ipairs(charts) do
		-- create label
		local label = Label:create()
		label:setFontName(G_Path.getBattleLabelFont())
		label:setFontSize(22)
		label:setAnchorPoint(ccp(0, 1))
		tempArr[#tempArr + 1] = label

		-- set chart name
		local chartInfo = ksoul_group_info.get(v)
		label:setText(chartInfo.group_name)

		-- set chart color
		local isActivated = G_Me.heroSoulData:isChartActivated(v)
		local color = isActivated and Colors.lightColors.TIPS_01 or Colors.lightColors.DESCRIPTION
		label:setColor(color)

		-- increase activated number
		if isActivated then numActivated = numActivated + 1 end
	end

	-- adjust the inner size of the scroll view adn add labels
	local totalLine = math.ceil(#charts / HeroSoulInfoLayer.CHARTS_PER_LINE)
	local innerHeight = HeroSoulInfoLayer.CHART_GAP_VER * totalLine
	innerHeight = math.max(innerHeight, parentSize.height)

	local oldPosY = parent:getPositionY()
	local oldHeight = parentSize.height
	parent:setInnerContainerSize(CCSize(parentSize.width, innerHeight))

	for i, v in ipairs(tempArr) do
		-- calculate position
		local line = math.ceil(i / HeroSoulInfoLayer.CHARTS_PER_LINE)
		local col  = i % HeroSoulInfoLayer.CHARTS_PER_LINE
		if col == 0 then col = HeroSoulInfoLayer.CHARTS_PER_LINE end

		local x = HeroSoulInfoLayer.CHART_GAP_HOR * (col - 1)
		local y = innerHeight - HeroSoulInfoLayer.CHART_GAP_VER * (line - 1)
		v:setPositionXY(x, y)

		parent:addChild(v)
	end

	-- set activated progress
	self:showTextWithLabel("Label_ChartNum", numActivated .. "/" .. #charts)
end

function HeroSoulInfoLayer:_onClickToGet()
	require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_HERO_SOUL, self._soulId,
    GlobalFunc.sceneToPack("app.scenes.herosoul.HeroSoulScene") )
end

function HeroSoulInfoLayer:_onClickClose()
	self:animationToClose()
end

return HeroSoulInfoLayer