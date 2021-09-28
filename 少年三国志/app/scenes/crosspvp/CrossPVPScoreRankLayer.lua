local CrossPVPScoreRankLayer = class("CrossPVPScoreRankLayer", UFCCSModelLayer)

local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")
local CrossPVPConst = require("app.const.CrossPVPConst")
local CrossPVPCommon = require("app.scenes.crosspvp.CrossPVPCommon")
local CrossPVPScoreRankItem = require("app.scenes.crosspvp.CrossPVPScoreRankItem")
local tNameList = {
   "Primary", "Middle", "Advanced", "Extreme"
}

local RANK_STEP = 20

function CrossPVPScoreRankLayer.show()
	local layer = CrossPVPScoreRankLayer.new("ui_layout/crosspvp_ScoreRankLayer.json", Colors.modelColor)
	layer:adapterWithScreen()
	uf_sceneManager:getCurScene():addChild(layer)
end

function CrossPVPScoreRankLayer:ctor(json, color)
	self._myField = G_Me.crossPVPData:getBattlefield()
	self.super.ctor(self, json, color)
end

function CrossPVPScoreRankLayer:onLayerLoad()
	-- initialize list view
	self:_initListView()

	-- initialize tabs
	self:_initTabs()

	-- initialize my info
	self:_initMyInfo()

	-- register button click events
	self:registerBtnClickEvent("Button_Close", handler(self, self._onCloseWindow))
    self:registerBtnClickEvent("Button_Close_TopRight", handler(self, self._onCloseWindow))
end

function CrossPVPScoreRankLayer:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)
	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_Bg"), "smoving_bounce")

	if self._myField > 0 then
		self._tabs:checked("CheckBox_" .. self._myField)
	else
		if G_Me.crossPVPData:getCourse() == CrossPVPConst.COURSE_PROMOTE_1024 then
			self._tabs:checked("CheckBox_" .. G_Me.crossPVPData:getActiveField() - 1)
		else
			self._tabs:checked("CheckBox_" .. CrossPVPConst.BATTLE_FIELD_NUM)
		end
	end

	-- register event listener
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_GET_LAST_RANK, self._onRcvRankList, self)
	uf_eventManager:addEventListener(CrossPVPConst.EVENT_STAGE_CHANGED, self._onCloseWindow, self)
end


function CrossPVPScoreRankLayer:_initListView()
	if not self._listView then
		local panel = self:getPanelByName("Panel_ListView")
		self._listView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)

		self._listView:setCreateCellHandler(function(list, index)
			return CrossPVPScoreRankItem.new(true)
		end)

		self._listView:setUpdateCellHandler(function(list, index, cell)
			local data = G_Me.crossPVPData:getScoreRanks(self._selField)[index + 1]
			cell:updateItem(data, index + 1)
		end)
	end

	self._listView:reloadWithLength(0)
end

function CrossPVPScoreRankLayer:_initTabs()
	self._tabs = require("app.common.tools.Tabs").new(1, self, self._onTabChecked, self._onTabUnchecked)
	for i = CrossPVPConst.BATTLE_FIELD_NUM, 1, -1 do
		self._tabs:add("CheckBox_" .. i, nil, "Label_" .. i)
	end
end

function CrossPVPScoreRankLayer:_initMyInfo()
	self:showWidgetByName("Panel_AppliedInfo", self._myField > 0)
	self:showWidgetByName("Label_NotApplied", self._myField <= 0)

	if self._myField > 0 then
		self:showTextWithLabel("Label_FieldName", CrossPVPCommon.getBattleFieldName(self._myField))
		self:showTextWithLabel("Label_ScoreNum", tostring(G_Me.crossPVPData:getScore()))
		self:showTextWithLabel("Label_FieldRankNum", tostring(G_Me.crossPVPData:getFieldRank()))
		self:showTextWithLabel("Label_RoomRankNum", tostring(G_Me.crossPVPData:getRoomRank()))
	end
end

function CrossPVPScoreRankLayer:_reloadListView()
	local rankList = G_Me.crossPVPData:getScoreRanks(self._selField)
	self:showWidgetByName("Panel_ListView", true)
	self._listView:reloadWithLength(#rankList)
end

function CrossPVPScoreRankLayer:_onRcvRankList(data)
	G_Me.crossPVPData:updateScoreRanks(data)
	self:_reloadListView()
end

function CrossPVPScoreRankLayer:_onTabChecked(szCheckBoxName)
	self._selField = self:getWidgetByName(szCheckBoxName):getTag()
	
	local course = G_Me.crossPVPData:getCourse()

	-- 海选阶段四个战场比赛不同步，可能有战场比赛还没结束
	if course == CrossPVPConst.COURSE_PROMOTE_1024 then
		local stage = G_Me.crossPVPData:getFieldStage(self._selField)
		if stage ~= CrossPVPConst.STAGE_END then
			self:showWidgetByName("Label_MatchNotEnd", true)
			self:showWidgetByName("Panel_ListView", false)
			return
		end
	end

	self:showWidgetByName("Label_MatchNotEnd", false)
	if G_Me.crossPVPData:hasScoreRankCache(self._selField) then
		self:_reloadListView()
	else
		G_HandlersManager.crossPVPHandler:sendGetLastRank(self._selField, 0, 20)
	end
end

function CrossPVPScoreRankLayer:_onTabUnchecked()
	
end

function CrossPVPScoreRankLayer:_onCloseWindow()
	self:animationToClose()
end

return CrossPVPScoreRankLayer