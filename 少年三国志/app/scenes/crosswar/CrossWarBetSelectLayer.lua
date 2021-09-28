local CrossWarBetSelectLayer = class("CrossWarBetSelectLayer", UFCCSModelLayer)

local BetSelectItem 	= require("app.scenes.crosswar.CrossWarBetSelectItem")
local CrossWarCommon 	= require("app.scenes.crosswar.CrossWarCommon")

function CrossWarBetSelectLayer.create(betIndex, ...)
	return CrossWarBetSelectLayer.new("ui_layout/crosswar_BetSelectLayer.json", Colors.modelColor, betIndex, ...)
end

function CrossWarBetSelectLayer:ctor(json, color, betIndex, ...)
	self._betIndex = betIndex
	self.super.ctor(self, ...)
end

function CrossWarBetSelectLayer:onLayerLoad(...)
	-- initialize list view
	self:_initListView()

	-- create strokes
	self:enableLabelStroke("Label_CD", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_BetOver", Colors.strokeBrown, 2)

	-- register button events
	self:registerBtnClickEvent("Button_Close", handler(self, self._onClickClose))
	self:registerBtnClickEvent("Button_Close_TopRight", handler(self, self._onClickClose))
end

function CrossWarBetSelectLayer:onLayerEnter(...)
	self:showAtCenter(true)
	self:closeAtReturn(true)

	-- register event listner
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_BET_SOMEONE, self._onRcvBetSomeone, self)
	uf_eventManager:addEventListener(CrossWarCommon.EVENT_STATE_CHANGED, self._updateMatchState, self)
	uf_eventManager:addEventListener(CrossWarCommon.EVENT_UPDATE_COUNTDOWN, self._updateCD, self)
end

function CrossWarBetSelectLayer:onLayerExit(...)
	uf_eventManager:removeListenerWithTarget(self)
end

function CrossWarBetSelectLayer:_initListView()
	if not self._listView then
		local panel = self:getPanelByName("Panel_ListView")
		self._listView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)

		self._listView:setCreateCellHandler(function(list, index)
			return BetSelectItem.new(self._betIndex)
		end)

		self._listView:setUpdateCellHandler(function(list, index, cell)
			cell:update(index + 1)
		end)
	end

	-- 滑到第一个未选择的人上方
	local listNum = G_Me.crossWarData:getBetListNum()
	local scrollTo = 0
	for i = 1, listNum do
		local user = G_Me.crossWarData:getBetUserInList(i)
		if user.betIndex and user.betIndex == 0 then
			scrollTo = i - 1 - 1
			break
		end
	end

	scrollTo = math.max(scrollTo, 0)
	self._listView:reloadWithLength(listNum, scrollTo)
end

function CrossWarBetSelectLayer:_onClickClose()
	self:animationToClose()

	local soundConst = require("app.const.SoundConst")
	G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
end

function CrossWarBetSelectLayer:_onRcvBetSomeone()
	self:animationToClose()
end

function CrossWarBetSelectLayer:_updateMatchState()
	local needCD = G_Me.crossWarData:getCurState() == CrossWarCommon.STATE_AFTER_SCORE_MATCH
	if not needCD then
		self:animationToClose()
	end
end

function CrossWarBetSelectLayer:_updateCD(strCD)
	local needCD = G_Me.crossWarData:getCurState() == CrossWarCommon.STATE_AFTER_SCORE_MATCH

	if needCD then
		self:showTextWithLabel("Label_CD", strCD)

		-- adjust the whole line, keep it at the center
		local panel = self:getPanelByName("Panel_CountDown")
		CrossWarCommon.centerContent(panel)
	end
end

return CrossWarBetSelectLayer