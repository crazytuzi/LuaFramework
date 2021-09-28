local HeroSoulChartRankLayer = class("HeroSoulChartRankLayer", UFCCSModelLayer)

local EffectSingleMoving = require("app.common.effects.EffectSingleMoving")
local HeroSoulChartRankItem = require("app.scenes.herosoul.HeroSoulChartRankItem")
local HeroSoulConst = require("app.const.HeroSoulConst")

function HeroSoulChartRankLayer.show()
	local layer = HeroSoulChartRankLayer.new("ui_layout/herosoul_ChartRankLayer.json", Colors.modelColor)
	uf_sceneManager:getCurScene():addChild(layer)
	return layer
end

function HeroSoulChartRankLayer:ctor(jsonFile, color)
	self._tabs = nil
	self._listView = nil
	self._rankType = HeroSoulConst.RANK_LOCAL
	self.super.ctor(self, jsonFile, color)
end

function HeroSoulChartRankLayer:onLayerLoad()
	self:_initListView()
	self:_initTabs()

	self:registerBtnClickEvent("Button_Close", handler(self, self._onClickClose))
	self:registerBtnClickEvent("Button_Close_TopRight", handler(self, self._onClickClose))
end

function HeroSoulChartRankLayer:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)

	-- bounce in the layer
	EffectSingleMoving.run(self:getWidgetByName("Image_Bg"), "smoving_bounce")

	-- set some values
	local chartPoint = G_Me.heroSoulData:getChartPoints()
	self:showTextWithLabel("Label_MyChartPoint_Num", tostring(chartPoint))

	local activatedNum = G_Me.heroSoulData:getActivatedChartsNum()
	self:showTextWithLabel("Label_MyActivated_Num", tostring(activatedNum))

	local localRank = G_Me.heroSoulData:getChartRank(HeroSoulConst.RANK_LOCAL)
	local strLocalRank = localRank > 0 and tostring(localRank) or G_lang:get("LANG_NOT_IN_RANKING_LIST")
	self:showTextWithLabel("Label_MyLocalRank_Num", strLocalRank)

	local crossRank = G_Me.heroSoulData:getChartRank(HeroSoulConst.RANK_CROSS)
	local strCrossRank = crossRank > 0 and tostring(crossRank) or G_lang:get("LANG_NOT_IN_RANKING_LIST")
	self:showTextWithLabel("Label_MyCrossRank_Num", strCrossRank)

	-- add event listners
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ARENA_USER_INFO, self._onRcvUserData, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_PLAYER_TEAM, self._onRcvUserData, self)
end

function HeroSoulChartRankLayer:_initTabs()
	self._tabs = require("app.common.tools.Tabs").new(1, self, self._onTabChecked, self._onTabUnchecked)
	self._tabs:add("CheckBox_LocalRank", nil, "Label_LocalRank")
	self._tabs:add("CheckBox_CrossRank", nil, "Label_CrossRank")

	-- check the "local rank" tab in default
	self._tabs:checked("CheckBox_LocalRank")
end

function HeroSoulChartRankLayer:_initListView()
	if not self._listView then
		local panel = self:getPanelByName("Panel_ListView")

		self._listView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
		self._listView:setClippingType(1)

		self._listView:setCreateCellHandler(function(list, index)
			return HeroSoulChartRankItem.new()
		end)

		self._listView:setUpdateCellHandler(function(list, index, cell)
			cell:update(self._rankType, index + 1)
		end)
	end
end

function HeroSoulChartRankLayer:_onTabChecked(btnName)
	if btnName == "CheckBox_LocalRank" then
		self._rankType = HeroSoulConst.RANK_LOCAL
	else
		self._rankType = HeroSoulConst.RANK_CROSS
	end

	local listLen = G_Me.heroSoulData:getChartRankNum(self._rankType)
	self._listView:reloadWithLength(listLen)
end

function HeroSoulChartRankLayer:_onTabUnchecked()
	
end

function HeroSoulChartRankLayer:_onClickClose()
	self:animationToClose()
end

function HeroSoulChartRankLayer:_onRcvUserData(data)
	local user = rawget(data, "user")
	if user ~= nil then
		local layer = require("app.scenes.arena.ArenaZhenrong").create(user)
		uf_sceneManager:getCurScene():addChild(layer)
	end
end

return HeroSoulChartRankLayer