local CrossWarServerAwardLayer = class("CrossWarServerAwardLayer", UFCCSModelLayer)

require("app.cfg.contest_server_award_info")
local CrossWarCommon = require("app.scenes.crosswar.CrossWarCommon")
local ServerAwardItem = require("app.scenes.crosswar.CrossWarServerAwardItem")

function CrossWarServerAwardLayer.create(...)
	return CrossWarServerAwardLayer.new("ui_layout/crosswar_ServerAwardLayer.json", Colors.modelColor, ...)
end

function CrossWarServerAwardLayer:ctor(...)
	self.super.ctor(self, ...)
end

function CrossWarServerAwardLayer:onLayerLoad(...)
	-- initialize list view
	self:_initListView()

	-- create strokes
	self:enableLabelStroke("Label_AwardDesc", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_Time", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_End", Colors.strokeBrown, 2)

	-- register button events
	self:registerBtnClickEvent("Button_Close", handler(self, self._onClickClose))
	self:registerBtnClickEvent("Button_Close_TopRight", handler(self, self._onClickClose))
end

function CrossWarServerAwardLayer:onLayerEnter(...)
	self:showAtCenter(true)
	self:closeAtReturn(true)

	-- register event listners
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_FINISH_SERVER_AWARD, self._onRcvFinishAward, self)

	uf_eventManager:addEventListener(CrossWarCommon.EVENT_STATE_CHANGED, self._updateMatchState, self)
	uf_eventManager:addEventListener(CrossWarCommon.EVENT_UPDATE_COUNTDOWN, self._updateCD, self)

	-- 
	self:_updateMatchState()
end

function CrossWarServerAwardLayer:_initListView()
	if not self._listView then
		local panel = self:getPanelByName("Panel_ListView")
		self._listView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)

		self._listView:setCreateCellHandler(function(list, index)
			return ServerAwardItem.new()
		end)

		self._listView:setUpdateCellHandler(function(list, index, cell)
			cell:update(index + 1)
		end)
	end

	local listLen = math.min(contest_server_award_info.getLength(), G_Me.crossWarData:getTopRankNum())
	self._listView:reloadWithLength(listLen)
end

function CrossWarServerAwardLayer:_onClickClose()
	self:animationToClose()

	local soundConst = require("app.const.SoundConst")
	G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
end

function CrossWarServerAwardLayer:_onRcvFinishAward(awards)
	-- pop up a message panel
	local layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(awards)
	uf_notifyLayer:getModelNode():addChild(layer)

	-- refresh list
	self._listView:refreshAllCell()
end

function CrossWarServerAwardLayer:_updateMatchState()
	local isInChampionship = G_Me.crossWarData:isInChampionship()

	-- 如果争霸赛已经输，则不再监听倒计时，并隐藏底部的文字
	if not isInChampionship then
		self:showWidgetByName("Label_AwardDesc", false)
		self:showWidgetByName("Panel_CountDown", false)
		uf_eventManager:removeListenerWithEvent(self, CrossWarCommon.EVENT_UPDATE_COUNTDOWN)
	end
end

function CrossWarServerAwardLayer:_updateCD(strCD)
	self:showTextWithLabel("Label_Time", strCD)
	CrossWarCommon.centerContent(self:getPanelByName("Panel_CountDown"))
end

return CrossWarServerAwardLayer