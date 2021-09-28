local HeroSoulChartList = class("HeroSoulChartList", UFCCSNormalLayer)
local HeroSoulConst = require("app.const.HeroSoulConst")

require("app.cfg.ksoul_group_chapter_info")
local HeroSoulChartItem = require("app.scenes.herosoul.HeroSoulChartItem")

function HeroSoulChartList.create(chapterIndex)
	return HeroSoulChartList.new("ui_layout/herosoul_ChartList.json", nil, chapterIndex)
end

function HeroSoulChartList:ctor(jsonFile, fun, chapterIndex)
	self._chapterIndex = chapterIndex
	self._chartList = nil	-- chart id list of this chapter
	self._listView = nil 	-- list view of the charts

	-- prepare some data(chart id list)
	self:_prepareData()

	self.super.ctor(self, jsonFile, fun)
end

function HeroSoulChartList:onLayerLoad()
	-- set chapter title
	local chapterInfo = ksoul_group_chapter_info.indexOf(self._chapterIndex)
	local chapterName = chapterInfo.name
	local chapterNo   = G_lang:get("LANG_DUNGEON_CHAPTER_INDEX", {num = self._chapterIndex})
	local chapterLabel = self:getLabelByName("Label_ChapterName")
	chapterLabel:setText(chapterNo .. " " .. chapterName)
	chapterLabel:createStroke(Colors.strokeBrown, 1)

	self:registerBtnClickEvent("Button_Bag", handler(self, self._onClickBag))
	self:registerBtnClickEvent("Button_Back", handler(self, self._onClickBack))
end

function HeroSoulChartList:onLayerEnter()
--	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HERO_SOUL_ACTIVATE_CHART, self._onRcvActivateChart, self)
end

function HeroSoulChartList:onLayerExit()
	G_Me.heroSoulData:setOnActivating(false)
	G_flyAttribute._clearFlyAttributes()
	uf_eventManager:removeListenerWithTarget(self)
end

function HeroSoulChartList:adapterLayer()
	local layerSize = self:getRootWidget():getContentSize()

	local topPanel  = self:getPanelByName("Panel_Top")
	local listPanel = self:getPanelByName("Panel_ListView")

	-- adjust top panel position
	topPanel:setPositionY(layerSize.height - topPanel:getContentSize().height)

	-- adjust list panel height
	local panelSize = listPanel:getContentSize()
	listPanel:setSize(CCSize(panelSize.width, topPanel:getPositionY() - listPanel:getPositionY()))
	
	self:_initListView()
end

function HeroSoulChartList:_prepareData()
	self._chartList = {}
	local temp = clone(G_Me.heroSoulData:getAllChartsByChap(self._chapterIndex))

	-- 移除前置未完成的阵图
	for i, v in ipairs(temp) do
		local chartInfo = ksoul_group_info.get(v)
		local preId = chartInfo.pre_id
		if preId == 0 or G_Me.heroSoulData:isChartActivated(preId) then
			self._chartList[#self._chartList + 1] = v
		end
	end

	-- sort, put activated charts firstly
	local sortFunc = function(a, b)
		local isActivatedA = G_Me.heroSoulData:isChartActivated(a)
		local isActivatedB = G_Me.heroSoulData:isChartActivated(b)

		-- 未激活的排在前面，已激活的排在后面
		if isActivatedA ~= isActivatedB then
			return isActivatedA == false
		end

		local canActivateA = G_Me.heroSoulData:canActivateChart(a)
		local canActivateB = G_Me.heroSoulData:canActivateChart(b)

		-- 可激活的排在前面，不可激活的排在后面
		if canActivateA ~= canActivateB then
			return canActivateA == true
		end

		-- 都不可激活的话，把缺少材料少的排在前面
		if not canActivateA and not canActivateB then
			local lackHeroNumA = G_Me.heroSoulData:getChartLackHeroNum(a)
			local lackHeroNumB = G_Me.heroSoulData:getChartLackHeroNum(b)

			if lackHeroNumA ~= lackHeroNumB then
				return lackHeroNumA < lackHeroNumB
			end
		end

		return a < b
	end

	table.sort(self._chartList, sortFunc)
end

function HeroSoulChartList:_initListView()
	if not self._listView then
		local panel = self:getPanelByName("Panel_ListView")

		self._listView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
		self._listView:setClippingType(1)

		self._listView:setCreateCellHandler(function(list, index)
			return HeroSoulChartItem.new(handler(self, self._flyAttr), handler(self, self._onRcvActivateChart))
		end)

		self._listView:setUpdateCellHandler(function(list, index, cell)
			cell:update(self._chartList[index + 1])
		end)
	end

	self._listView:reloadWithLength(#self._chartList)
	self._listView:setSpaceBorder(0, 20)
end

function HeroSoulChartList:_onClickBack()
	uf_sceneManager:getCurScene():goBack()
end

function HeroSoulChartList:_onClickBag()
	uf_sceneManager:getCurScene():goToLayer("HeroSoulBagLayer", true, self._chapterIndex)
end

function HeroSoulChartList:_onRcvActivateChart(chartId)
	-- refresh list
	self:_prepareData()
	self._listView:reloadWithLength(#self._chartList)

	G_Me.heroSoulData:setOnActivating(false)
end

function HeroSoulChartList:_flyAttr(chartId)
	G_Me.heroSoulData:setOnActivating(true)

	G_flyAttribute.addNormalText(G_lang:get("LANG_HERO_SOUL_ACTIVATE_SUCC"), Colors.darkColors.DESCRIPTION)
	local chartInfo = ksoul_group_info.get(chartId)
	for i = 1, HeroSoulConst.MAX_ATTR_PER_CHART do
		local attrType = chartInfo["attribute_type" .. i]

		-- set attributes
		if attrType > 0 then
			local attrValue = chartInfo["attribute_value" .. i]
			local attrNameStr = G_lang.getGrowthTypeName(attrType)
			local attrValueStr = G_lang.getGrowthValue(attrType, attrValue)

			G_flyAttribute.addNormalText(attrNameStr .. "  +" .. attrValueStr, Colors.darkColors.ATTRIBUTE)
		end
	end

	-- 增加的阵图值
	G_flyAttribute.addNormalText(G_lang:get("LANG_HERO_SOUL_CHART_POINT").."+"..chartInfo.target_value, Colors.darkColors.TIPS_01)

	G_flyAttribute.play()
end

return HeroSoulChartList