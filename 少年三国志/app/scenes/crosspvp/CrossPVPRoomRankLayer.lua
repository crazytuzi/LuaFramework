local CrossPVPConst = require("app.const.CrossPVPConst")
local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")
local CrossPVPCommon = require("app.scenes.crosspvp.CrossPVPCommon")

local CrossPVPRoomRankLayer = class("CrossPVPRoomRankLayer", UFCCSModelLayer)

local tNameList = {
   "Primary", "Middle", "Advanced", "Extreme"
}

function CrossPVPRoomRankLayer.create(nBattleFieldType, nRoom, isAudience, nSelfScore, nSelfRank, ...)
	return CrossPVPRoomRankLayer.new("ui_layout/crosspvp_RoomRankLayer.json", Colors.modelColor, nBattleFieldType, nRoom, isAudience, nSelfScore, nSelfRank, ...)
end

function CrossPVPRoomRankLayer:ctor(json, param, nBattleFieldType, nRoom, isAudience, nSelfScore, nSelfRank, ...)
	self._nCurBattleField = nBattleFieldType or CrossPVPConst.BATTLE_FIELD_TYPE.EXTREME
	self._nRoom = nRoom 
	self._tListViewList = {}
	self._tRoomRankList = {}

	self._isAudience = isAudience or false

	-- 玩家自己的信息
	self._nSelfRank = nSelfRank or 0
	self._nSelfScore = nSelfScore or 0

	self.super.ctor(self, json, param, ...)
end

function CrossPVPRoomRankLayer:onLayerLoad()
	self:_initView()
    self:_initWidgets()
end

function CrossPVPRoomRankLayer:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)
	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_Bg"), "smoving_bounce")

	-- 事件监听
	-- 状态切换后，关掉自己
    uf_eventManager:addEventListener(CrossPVPConst.EVENT_STAGE_CHANGED, self._onCloseSelf, self)
	-- 获取当前战场，战前房间的排行榜
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_GET_SCORE_RANK_SUCC, self._onReloadListView, self)
	-- 更新自己的分数
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_UPDATE_SELF_ROOM_SCORE, self._onUpdateSelfScore, self)

	self:_onUpdateSelfInfo()

	-- 初始化listView
	self:_initListView()
	-- 发送协议拉取数据
	G_HandlersManager.crossPVPHandler:sendGetCrossPvpRank(self._nCurBattleField, self._nRoom)
end

function CrossPVPRoomRankLayer:onLayerExit()
	uf_eventManager:removeListenerWithTarget(self)
end

function CrossPVPRoomRankLayer:_initView()
	if self._isAudience then
		self:showWidgetByName("Panel_NotAudience", false)
		self:showWidgetByName("Panel_Audience", true)
	else
		self:showWidgetByName("Panel_NotAudience", true)
		self:showWidgetByName("Panel_Audience", false)
	end
end

function CrossPVPRoomRankLayer:_initWidgets()
	self:registerBtnClickEvent("Button_Close", handler(self, self._onCloseWindow))
    self:registerBtnClickEvent("Button_Close_TopRight", handler(self, self._onCloseWindow))
end

function CrossPVPRoomRankLayer:_onCloseWindow()
	self:animationToClose()
end

function CrossPVPRoomRankLayer:_initListView()
	if not self._tListView then
		local panel = self:getPanelByName("Panel_ListView_Room")
		if panel then
			self._tListView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)

			self._tListView:setCreateCellHandler(function(list, index)
				return require("app.scenes.crosspvp.CrossPVPScoreRankItem").new(false)
			end)

			self._tListView:setUpdateCellHandler(function(list, index, cell)
				local tRank = self._tRoomRankList[index + 1]
				if tRank then
					cell:updateItem(tRank, index + 1)
				end
			end)

			self._tListView:initChildWithDataLength(0)
		end
	end
end

-- 玩家自己的信息面板
function CrossPVPRoomRankLayer:_onUpdateSelfInfo()
	local szSelfFieldName = CrossPVPCommon.getBattleFieldName(self._nCurBattleField)

	if self._nSelfRank == 0 then
		CommonFunc._updateLabel(self, "Label_SelfField_Value", {text=szSelfFieldName})
		CommonFunc._updateLabel(self, "Label_SelfScore_Value", {text=self._nSelfScore})
		CommonFunc._updateLabel(self, "Label_SelfRoomRank_Value", {text=G_lang:get("LANG_REBEL_BOSS_NOT_ON_RANK_1")})
		return
	end

	CommonFunc._updateLabel(self, "Label_SelfField_Value", {text=szSelfFieldName})
	CommonFunc._updateLabel(self, "Label_SelfScore_Value", {text=self._nSelfScore})
	CommonFunc._updateLabel(self, "Label_SelfRoomRank_Value", {text=self._nSelfRank})
end

-- sp1为积分
function CrossPVPRoomRankLayer:_onReloadListView(tData)
	assert(tData.ranks)
	self._tRoomRankList = {}
	-- v为CrossUser结构数据
	for i, v in ipairs(tData.ranks) do
		local tRank = v
		table.insert(self._tRoomRankList, #self._tRoomRankList + 1, tRank)
	end
	local function sortFunc(tRank1, tRank2)
		return tRank1.sp1 > tRank2.sp1
	end
	table.sort(self._tRoomRankList, sortFunc)

	local hasMyRank = false
	for i=1, #self._tRoomRankList do
		local tRank = self._tRoomRankList[i]
		if tostring(G_PlatformProxy:getLoginServer().id) == tostring(tRank.sid) and tostring(G_Me.userData.id) == tostring(tRank.id) then
			if self._nSelfScore == 0 then
				self._nSelfScore = tRank1.sp1
			end
			self._nSelfRank = i
			hasMyRank = true
		end
	end
	if not hasMyRank then
		self._nSelfRank = 0
	end

	if self._tListView then
	--	self._tListView:reloadWithLength(table.nums(tData.ranks))
		self._tListView:refreshAllCell()
	end

	self:_onUpdateSelfInfo()
end

function CrossPVPRoomRankLayer:_onCloseSelf()
	self:close()
end

function CrossPVPRoomRankLayer:_onUpdateSelfScore(nScore)
	self._nSelfScore = nScore or 0
	CommonFunc._updateLabel(self, "Label_SelfScore_Value", {text=self._nSelfScore})
end



return CrossPVPRoomRankLayer