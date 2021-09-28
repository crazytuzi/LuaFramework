local CrossPVPBetRankLayer = class("CrossPVPBetRankLayer", UFCCSModelLayer)

require("app.cfg.crosspvp_value_info")
local CrossPVPConst = require("app.const.CrossPVPConst")
local BetRankItem = require("app.scenes.crosspvp.CrossPVPBetRankItem")

function CrossPVPBetRankLayer.show()
	local layer = CrossPVPBetRankLayer.new("ui_layout/crosspvp_BetRankLayer.json", Colors.modelColor)
	layer:adapterWithScreen()
	uf_sceneManager:getCurScene():addChild(layer)
end

function CrossPVPBetRankLayer:ctor(json, color)
	self._rankData = {}
	self.super.ctor(self, json, color)
end

function CrossPVPBetRankLayer:onLayerLoad()
	-- 观战的条件描述
	local rankRequest = crosspvp_value_info.get(2).value
	self:showTextWithLabel("Label_Explain", G_lang:get("LANG_CROSS_PVP_WATCH_CONDITION", {rank = rankRequest}))

	-- set bet number
	local flowerNum = G_Me.crossPVPData:getNumBetFlower()
	local eggNum    = G_Me.crossPVPData:getNumBetEgg()
	self:showTextWithLabel("Label_MyFlowerNum", tostring(flowerNum))
	self:showTextWithLabel("Label_MyEggNum", tostring(eggNum))
	self:showTextWithLabel("Label_MyTotalBetNum", tostring(flowerNum + eggNum))

	-- initialize list view
	self:_initListView()

	-- stroke
	self:enableLabelStroke("Label_Explain", Colors.strokeBrown, 1)

	-- register button click events
	self:registerBtnClickEvent("Button_Close", handler(self, self._onClickClose))
	self:registerBtnClickEvent("Button_Close_TopRight", handler(self, self._onClickClose))
end

function CrossPVPBetRankLayer:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_Bg"), "smoving_bounce")

	-- register event
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_GET_BET_RANK, self._onRcvBetRank, self)
	uf_eventManager:addEventListener(CrossPVPConst.EVENT_STAGE_CHANGED, self.animationToClose, self)

	-- pull rank data from server
	G_HandlersManager.crossPVPHandler:sendGetBetRank(0,20)
end

function CrossPVPBetRankLayer:_initListView()
	if not self._listView then
		local panel = self:getPanelByName("Panel_ListView")
		self._listView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)

		self._listView:setCreateCellHandler(function(list, index)
			return BetRankItem.new()
		end)

		self._listView:setUpdateCellHandler(function(list, index, cell)
			cell:update(index + 1, self._rankData[index + 1])
		end)
	end

	self._listView:reloadWithLength(0)
end

function CrossPVPBetRankLayer:_onRcvBetRank(data)
	self._rankData = clone(data.ranks)

	-- set my rank
	local myRank = rawget(data, "self_rank") or 0
	local strRank = myRank > 0 and tostring(myRank) or G_lang:get("LANG_NOT_IN_RANKING_LIST")
	self:showTextWithLabel("Label_MyRankNum", strRank)

	-- sort list
	local sortFunc = function(a, b)
		return a.sp3 > b.sp3
	end
	table.sort(self._rankData, sortFunc)

	-- reload list view
	self._listView:reloadWithLength(#self._rankData)
end

function CrossPVPBetRankLayer:_onClickClose()
	self:animationToClose()

	local soundConst = require("app.const.SoundConst")
	G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
end

return CrossPVPBetRankLayer