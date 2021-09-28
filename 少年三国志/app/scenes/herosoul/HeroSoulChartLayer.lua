local HeroSoulChartLayer = class("HeroSoulChartLayer", UFCCSNormalLayer)

require("app.cfg.ksoul_group_chapter_info")
local AttributesConst = require("app.const.AttributesConst")
local HeroSoulConst = require("app.const.HeroSoulConst")
local HeroSoulChapterItem = require("app.scenes.herosoul.HeroSoulChapterItem")
local HeroSoulChartRankLayer = require("app.scenes.herosoul.HeroSoulChartRankLayer")
local HeroSoulAchievementLayer = require("app.scenes.herosoul.HeroSoulAchievementLayer")
local HeroSoulBattleBaseLayer = require("app.scenes.herosoul.HeroSoulBattleBaseLayer")

-- 底部属性面板相关的一些常量
local MIN_BOTTOM_HEIGHT	= 93
local MAX_BOTTOM_HEIGHT = 400
local EXTEND_SPEED		= 1500
local LEFT_ATTR_X		= -100
local RIGHT_ATTR_X		= 145
local FIRST_ATTR_Y		= -43
local ATTR_HEIGHT_GAP	= 33

function HeroSoulChartLayer.create()
	return HeroSoulChartLayer.new("ui_layout/herosoul_ChartLayer.json", nil)
end

function HeroSoulChartLayer:ctor(jsonFile, fun)
	self._listView			= nil	-- list view of chapters
	self._hasGetLocalRanks 	= false	-- 是否已经拉到本服排行
	self._hasGetCrossRanks	= false	-- 是否已经拉到全服排行
	self._timer				= nil	-- 用于底部属性框的伸展
	self._isBottomExtended	= false

	self._bottomPanel = self:getPanelByName("Panel_Bottom")
	self._attrScroll  = self:getScrollViewByName("ScrollView_Clip")
	self._attrPanel   = self:getPanelByName("Panel_Attrs")
	self._attrArrow	  = self:getImageViewByName("Image_Arrow")

	self._attrScroll:setTouchEnabled(false)

	self.super.ctor(self)
	G_GlobalFunc.savePack(self, scenePack)
end

function HeroSoulChartLayer:onLayerLoad()
	-- initialize chapter list view
	self:_initListView()

	-- initialize attributes
	self:_initAttrs()

	-- label strokes
	self:enableLabelStroke("Label_SoulPoint", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_SoulPoint_Num", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_ChartValue", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_CharValue_Num", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Activated", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Activated_Num", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_AttrTitle", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_AttrHint", Colors.strokeBrown, 1)

	-- register button events
	self:registerWidgetClickEvent("Panel_Bottom", handler(self, self._onClickBottom))
	self:registerBtnClickEvent("Button_ChartRank", handler(self, self._onClickChartRank))
	self:registerBtnClickEvent("Button_Achievement", handler(self, self._onClickAchievement))
	self:registerBtnClickEvent("Button_BattleBase", handler(self, self._OnClickBattleBase))
	self:registerBtnClickEvent("Button_Bag", handler(self, self._onClickBag))
	self:registerBtnClickEvent("Button_Back", handler(self, self._onClickBack))
end

function HeroSoulChartLayer:onLayerEnter()
	-- initialize some values
	self:showTextWithLabel("Label_SoulPoint_Num", tostring(G_Me.userData.hero_soul_point))

	local chartPoints = G_Me.heroSoulData:getChartPoints()
	self:showTextWithLabel("Label_CharValue_Num", tostring(chartPoints))

	local activatedChartsNum = G_Me.heroSoulData:getActivatedChartsNum()
	self:showTextWithLabel("Label_Activated_Num", tostring(activatedChartsNum))

	-- update red tip
	self:_updateRedTips()

	-- add event listener
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HERO_SOUL_GET_CHART_RANK, self._onRcvChartRank, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HERO_SOUL_ACTIVATE_ACHIEVEMENT, self._onRcvActivateAchieve, self)
end

function HeroSoulChartLayer:onLayerExit()
	self:_removeTimer()
	uf_eventManager:removeListenerWithTarget(self)
end

function HeroSoulChartLayer:adapterLayer()
	local layerSize   = self:getRootWidget():getContentSize()

	local titleBar    = self:getImageViewByName("Image_TitleBar")
	local topPanel	  = self:getPanelByName("Panel_Top")
	local middlePanel = self:getPanelByName("Panel_Middle")
	local bottomPanel = self:getPanelByName("Panel_Bottom")

	titleBar:setPositionY(layerSize.height)
	topPanel:setPositionY(layerSize.height - titleBar:getContentSize().height - topPanel:getContentSize().height)

	local bottomLimit = bottomPanel:getPositionY() + bottomPanel:getContentSize().height
	local topLimit	  = topPanel:getPositionY()

	-- adjust position of the middle panel, put it center between top and bottom panels
	local offset = (topLimit - bottomLimit - middlePanel:getContentSize().height) / 2
	local y = bottomLimit + offset
	middlePanel:setPositionY(math.max(y, 0))
end

function HeroSoulChartLayer:_createTimer()
	if not self._timer then
		self._timer = G_GlobalFunc.addTimer(0, handler(self, self._update))
	end
end

function HeroSoulChartLayer:_removeTimer()
	if self._timer then
		G_GlobalFunc.removeTimer(self._timer)
		self._timer = nil
	end
end

-- initialize the list view of chapters
function HeroSoulChartLayer:_initListView()
	if not self._listView then
		local panel = self:getPanelByName("Panel_ListView")
		self._listView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_HORIZONTAL)

		self._listView:setCreateCellHandler(function(list, index)
			return HeroSoulChapterItem.new()
		end)

		self._listView:setUpdateCellHandler(function(list, index, cell)
			cell:update(index + 1)
		end)
	end

	local len = ksoul_group_chapter_info.getLength()
	self._listView:reloadWithLength(len)
end

-- initialize attributes
function HeroSoulChartLayer:_initAttrs()
	local attrs = G_Me.heroSoulData:getChartAttrs()
	local panel = self:getPanelByName("Panel_Attrs")
	local i = 1
	for k, v in pairs(attrs) do
		local x = i % 2 == 1 and LEFT_ATTR_X or RIGHT_ATTR_X
		local y = FIRST_ATTR_Y - math.floor((i - 1) / 2) * ATTR_HEIGHT_GAP

		local attrLabel = Label:create()
		attrLabel:setFontName(G_Path.getBattleLabelFont())
		attrLabel:setFontSize(20)
		attrLabel:setAnchorPoint(ccp(1,0.5))
		attrLabel:setPositionXY(x, y)
		attrLabel:setColor(Colors.darkColors.TITLE_02)
		attrLabel:createStroke(Colors.strokeBrown, 1)
		panel:addChild(attrLabel)

		local preFix = (k >= AttributesConst.ATTRIBUTE_TYPE.ATTRIBUTE_ATK_UP_TO_WEI and
		                k <= AttributesConst.ATTRIBUTE_TYPE.ATTRIBUTE_DEF_UP_TO_QUN)
					   and G_lang:get("LANG_KNIGHT") or G_lang:get("LANG_HERO_SOUL_ALL_MEMBERS")
		attrLabel:setText(preFix .. G_lang.getGrowthTypeName(k) .. "：")

		local valueLabel = Label:create()
		valueLabel:setFontName(G_Path.getBattleLabelFont())
		valueLabel:setFontSize(20)
		valueLabel:setAnchorPoint(ccp(0,0.5))
		valueLabel:setPositionXY(x, y)
		valueLabel:setColor(Colors.darkColors.DESCRIPTION)
		valueLabel:createStroke(Colors.strokeBrown, 1)
		valueLabel:setText("+" .. G_lang.getGrowthValue(k, v))
		panel:addChild(valueLabel)

		i = i + 1
	end
end

-- update bottom panel
function HeroSoulChartLayer:_update(t)
	-- 计算新的属性panel高度
	local deltaH = EXTEND_SPEED * t
	local curBottomSize = self._bottomPanel:getSize()
	local newH = curBottomSize.height + deltaH

	-- 如果到达最高，结束
	if curBottomSize.height + deltaH >= MAX_BOTTOM_HEIGHT then
		deltaH = MAX_BOTTOM_HEIGHT - curBottomSize.height
		self._isBottomExtended = true
		self._bottomPanel:setTouchEnabled(true)
		self:_removeTimer()
	end

	self._bottomPanel:setSize(CCSize(curBottomSize.width, curBottomSize.height + deltaH))

	-- 设置新的clip scrollview高度
	local curScrollSize = self._attrScroll:getSize()
	local newScrollH = curScrollSize.height + deltaH
	self._attrScroll:setSize(CCSize(curScrollSize.width, newScrollH))
	self._attrScroll:setInnerContainerSize(CCSize(curScrollSize.width, newScrollH))

	local curAttrPosY = self._attrPanel:getPositionY()
	self._attrPanel:setPositionY(curAttrPosY + deltaH)
end

-- update red tips
function HeroSoulChartLayer:_updateRedTips()
	local showAchieveTip = G_Me.heroSoulData:hasAchievementToActivate()
	self:showWidgetByName("Image_AchieveTip", showAchieveTip)
end

-- receive chart rank data
function HeroSoulChartLayer:_onRcvChartRank(rankType)
	if rankType == HeroSoulConst.RANK_LOCAL then
		self._hasGetLocalRanks = true
	else
		self._hasGetCrossRanks = true
	end

	if self._hasGetLocalRanks and self._hasGetCrossRanks then
		HeroSoulChartRankLayer.show()
	end
end

-- receive achievement activating event
function HeroSoulChartLayer:_onRcvActivateAchieve()
	self:_updateRedTips()
end

-- click the bottom panel
function HeroSoulChartLayer:_onClickBottom()
	if self._isBottomExtended then
		-- 缩回底部框
		local curBottomSize = self._bottomPanel:getSize()
		local deltaH = curBottomSize.height - MIN_BOTTOM_HEIGHT
		self._bottomPanel:setSize(CCSize(curBottomSize.width, MIN_BOTTOM_HEIGHT))
		
		local curScrollSize = self._attrScroll:getSize()
		local newH = curScrollSize.height - deltaH
		self._attrScroll:setSize(CCSize(curScrollSize.width, newH))
		self._attrScroll:setInnerContainerSize(CCSize(curScrollSize.width, newH))

		local curAttrPosY = self._attrPanel:getPositionY()
		self._attrPanel:setPositionY(curAttrPosY - deltaH)

		-- 小箭头翻回来
		self._attrArrow:setRotation(-90)

		-- 重新可以触摸
		self._listView:setTouchEnabled(true)
		self._isBottomExtended = false
	else
		-- 禁止再触摸下列面板
		self._bottomPanel:setTouchEnabled(false)
		self._listView:setTouchEnabled(false)

		-- 小箭头翻转
		self._attrArrow:setRotation(90)

		-- 开始伸展
		self:_createTimer()
	end
end

-- click chart rank button
function HeroSoulChartLayer:_onClickChartRank()
	self._hasGetLocalRanks = false
	self._hasGetCrossRanks = false
	G_HandlersManager.heroSoulHandler:sendGetChartRank(HeroSoulConst.RANK_LOCAL)
	G_HandlersManager.heroSoulHandler:sendGetChartRank(HeroSoulConst.RANK_CROSS)
end

-- click achievement button
function HeroSoulChartLayer:_onClickAchievement()
	HeroSoulAchievementLayer.show()
end

-- click battle-base button
function HeroSoulChartLayer:_OnClickBattleBase()
	HeroSoulBattleBaseLayer.show()
end

-- click bag button
function HeroSoulChartLayer:_onClickBag()
	uf_sceneManager:getCurScene():goToLayer("HeroSoulBagLayer", true)
end

-- click back button
function HeroSoulChartLayer:_onClickBack()
	uf_sceneManager:getCurScene():goBack()
end

return HeroSoulChartLayer