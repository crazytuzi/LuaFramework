local CrossWarBetAwardLayer = class("CrossWarBetAwardLayer", UFCCSModelLayer)

require("app.cfg.contest_arena_bets_info")
local CrossWarCommon = require("app.scenes.crosswar.CrossWarCommon")
local BetResultItem = require("app.scenes.crosswar.CrossWarBetResultItem")

function CrossWarBetAwardLayer.create(...)
	return CrossWarBetAwardLayer.new("ui_layout/crosswar_BetAwardLayer.json", Colors.modelColor, ...)
end

function CrossWarBetAwardLayer:ctor(json, color, ...)
	-- super constructor
	self.super.ctor(self, ...)
end

function CrossWarBetAwardLayer:onLayerLoad(...)
	-- create strokes
	self:enableLabelStroke("Label_Top10", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_BetUsers", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_ResultTitle", Colors.strokeBrown, 2)

	-- initialize the bet result list view
	self:_initListView()

	-- initialize other UI contents
	self:_initContents()

	-- register button events
	self:registerBtnClickEvent("Button_Get", handler(self, self._onClickGet))
	self:registerBtnClickEvent("Button_Close", handler(self, self._onClickClose))
end

function CrossWarBetAwardLayer:onLayerEnter(...)
	self:showAtCenter(true)
	self:closeAtReturn(true)

	-- register event listeners
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_FINISH_BET_AWARD, self._onRcvFinishBetAward, self)
end

function CrossWarBetAwardLayer:onLayerExit(...)
	uf_eventManager:removeListenerWithTarget(self)
end

function CrossWarBetAwardLayer:_initListView()
	if not self._listView then
		local panel = self:getPanelByName("Panel_ListView")
		self._listView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)

		self._listView:setCreateCellHandler(function(list, index)
			return BetResultItem.new()
		end)

		self._listView:setUpdateCellHandler(function(list, index, cell)
			cell:update(index + 1)
		end)
	end

	self._listView:reloadWithLength(CrossWarCommon.CHAMPIONSHIP_TOP_RANKS)

	--这里是为了修正一个列表对齐问题：列表在刚显示时顶部并未完全顶格
    self._listView:scrollToTopLeftCellIndex(0, -5, 0, function() end)
end

function CrossWarBetAwardLayer:_initContents()
	-- 根据玩家是否进行过押注，是否领过奖，显示不同UI
	local betNum = G_Me.crossWarData:getBetNum()
	local hasBet = betNum > 0
	local hasGetAward = G_Me.crossWarData:hasGetBetAward()
	self:showWidgetByName("Panel_Result", hasBet)
	self:showWidgetByName("Label_NotBet", not hasBet)
	self:showWidgetByName("Button_Get", hasBet and not hasGetAward)
	self:showWidgetByName("Image_Status", hasGetAward or not hasBet)

	-- 如果进行过押注，则显示奖励细节，否则显示“未押注”
	if hasBet then
		-- 显示演武勋章icon
		self:getImageViewByName("Image_AwardIcon"):loadTexture(CrossWarCommon.ICON_MEDAL_BIG)

		-- 奖励细节
		local awardID = G_Me.crossWarData:getBetAwardID()
		local awardNum = G_Me.crossWarData:getBetAwardNum()
		local awardInfo = contest_arena_bets_info.get(awardID)

		local strResult = awardInfo.name .. "-" .. G_lang:get("LANG_CROSS_WAR_BET_HIT", {num = awardInfo.number})
		self:showTextWithLabel("Label_ResultDetail", strResult)
		self:showTextWithLabel("Label_ConsumeNum", tostring(betNum))
		self:showTextWithLabel("Label_MedalNum", tostring(awardNum))
	else
		-- 没有押注过，显示“未押注”水印
		self:getImageViewByName("Image_Status"):loadTexture(G_Path.getTxt("kfyw_weiyazhu.png"))
	end
end

function CrossWarBetAwardLayer:_onClickGet()
	G_HandlersManager.crossWarHandler:sendFinishBetAward()
end

function CrossWarBetAwardLayer:_onClickClose()
	self:animationToClose()

	local soundConst = require("app.const.SoundConst")
	G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
end

function CrossWarBetAwardLayer:_onRcvFinishBetAward(awards)
	-- pop up a message panel
	local layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(awards)
	uf_notifyLayer:getModelNode():addChild(layer)

	-- refresh UI
	self:showWidgetByName("Button_Get", false)
	self:showWidgetByName("Image_Status", true)
	self:getImageViewByName("Image_Status"):loadTexture(G_Path.getTxt("shuiyin_yilingqu.png"))
end

return CrossWarBetAwardLayer