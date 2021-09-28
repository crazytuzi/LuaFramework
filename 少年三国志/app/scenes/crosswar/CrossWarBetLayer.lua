local CrossWarBetLayer = class("CrossWarBetLayer", UFCCSModelLayer)

require("app.cfg.shop_score_info")
require("app.cfg.contest_value_info")
local CrossWarCommon = require("app.scenes.crosswar.CrossWarCommon")
local CrossWarBuyPanel = require("app.scenes.crosswar.CrossWarBuyPanel")
local BetKnightItem = require("app.scenes.crosswar.CrossWarBetKnightItem")
local RankItem = require("app.scenes.crosswar.CrossWarRankItem")

function CrossWarBetLayer.create(...)
	return CrossWarBetLayer.new("ui_layout/crosswar_BetLayer.json", Colors.modelColor, ...)
end

function CrossWarBetLayer:ctor(jsonFile, color, ...)
	self.super.ctor(self, ...)
end

function CrossWarBetLayer:onLayerLoad(...)
	-- initialize tabs
	self:_initTabs()

	-- initialize list views and contents
	self:_initBetListView()
	self:_initFollowListView()
	self:_initContents()
	self:_updateWidgetsVisibility()

	-- create strokes
	self:enableLabelStroke("Label_BonusPool", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_Bonus", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_PoolDesc", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_BetDesc_1", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_BetDesc_2_1", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_BetDesc_2_2", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_GoldArrow", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_FlowerNum", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_CD", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_BetOver", Colors.strokeBrown, 2)

	-- register button events
	self:registerBtnClickEvent("Button_Add", handler(self, self._onClickAdd))
	self:registerBtnClickEvent("Button_Bet", handler(self, self._onClickBet))
	self:registerBtnClickEvent("Button_Close", handler(self, self._onClickClose))
	self:registerBtnClickEvent("Button_Close_TopRight", handler(self, self._onClickClose))
end

function CrossWarBetLayer:onLayerEnter(...)
	self:showAtCenter(true)
	self:closeAtReturn(true)

	-- register event listeners
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_BET_SOMEONE, self._onRcvBetSomeone, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_ADD_BETS, self._onRcvAddBets, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, self._onRcvBagChanged, self)

	uf_eventManager:addEventListener(CrossWarCommon.EVENT_STATE_CHANGED, self._updateMatchState, self)
	uf_eventManager:addEventListener(CrossWarCommon.EVENT_UPDATE_COUNTDOWN, self._updateCD, self)

	-- pull bet list
	G_HandlersManager.crossWarHandler:sendGetBetList()
end

function CrossWarBetLayer:onLayerExit(...)
	uf_eventManager:removeListenerWithTarget(self)
end

function CrossWarBetLayer:onBackKeyEvent(...)
	self:_onClickClose()
	return true
end

-- initialize tabs
function CrossWarBetLayer:_initTabs()
	self._tabs = require("app.common.tools.Tabs").new(3, self, self._onTabChecked, self._onTabUnchecked)
	self._tabs:add("CheckBox_Bet", self:getPanelByName("Panel_Bet"), "Label_Bet")
	self._tabs:add("CheckBox_FollowRank", self:getPanelByName("Panel_FollowRank"), "Label_FollowRank")
	self._tabs:add("CheckBox_AwardExplain", self:getPanelByName("Panel_AwardExplain"), "Label_AwardExplain")

	-- check the "bet" tab in default
	self._tabs:checked("CheckBox_Bet")
end

-- initialize bet list view
function CrossWarBetLayer:_initBetListView()
	if not self._betListView then
		local panel = self:getPanelByName("Panel_BetList")
		self._betListView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_HORIZONTAL)

		self._betListView:setCreateCellHandler(function(list, index)
			return BetKnightItem.new()
		end)

		self._betListView:setUpdateCellHandler(function(list, index, cell)
			cell:update(index + 1)
		end)
	end

	-- reload the list
	self._betListView:reloadWithLength(CrossWarCommon.CHAMPIONSHIP_TOP_RANKS)
end

-- initialize follow list view
function CrossWarBetLayer:_initFollowListView()
	if not self._followListView then
		local panel = self:getPanelByName("Panel_RankList")
		self._followListView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)

		self._followListView:setCreateCellHandler(function(list, index)
			return RankItem.new(CrossWarCommon.RANK_BET)
		end)

		self._followListView:setUpdateCellHandler(function(list, index, cell)
			local data = G_Me.crossWarData:getBetUserInList(index + 1)
			cell:update(index + 1, data)
		end)
	end
end

-- initialize contents
function CrossWarBetLayer:_initContents()
	-- bonus pool
	local bonus = G_Me.crossWarData:getBonusPool()
	local bonusPerBet = contest_value_info.get(27).value
	self:showTextWithLabel("Label_Bonus", bonus * bonusPerBet)

	-- number of flowers I bet
	local betNum = G_Me.crossWarData:getBetNum()
	self:showTextWithLabel("Label_BetNum", betNum)

	-- number of flowers I own
	local flowerNum = G_Me.bagData:getNumByTypeAndValue(G_Goods.TYPE_ITEM, CrossWarCommon.ITEM_FLOWER_ID)
	self:showTextWithLabel("Label_FlowerNum", flowerNum)
end

function CrossWarBetLayer:_onClickAdd()
	if G_Me.crossWarData:getCurState() ~= CrossWarCommon.STATE_AFTER_SCORE_MATCH then
		-- 不是押注阶段，不能购买
		G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_WAR_BET_OVER_2"))
	else
		-- 若购买数量已达上限，弹出提示
		local shopInfo = shop_score_info.get(CrossWarCommon.ITEM_FLOWER_SHOP_ID)
		local limit    = shopInfo["vip" .. G_Me.userData.vip .. "_num"]
		local curNum   = G_Me.shopData:getScorePurchaseNumById(CrossWarCommon.ITEM_FLOWER_SHOP_ID)

		if curNum >= limit then
			G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_WAR_BUY_NUM_LIMIT"))
		else
			local layer = require("app.scenes.common.PurchaseScoreDialog").create(CrossWarCommon.ITEM_FLOWER_SHOP_ID)
			uf_sceneManager:getCurScene():addChild(layer)
		end
	end
end

function CrossWarBetLayer:_onClickBet()
	local curBetNum = G_Me.crossWarData:getBetNum()
	local limit 	= CrossWarCommon.getLimitBetNum()
	local flowerNum = G_Me.bagData:getNumByTypeAndValue(G_Goods.TYPE_ITEM, CrossWarCommon.ITEM_FLOWER_ID)

	if curBetNum == limit then
		G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_WAR_BET_REACH_LIMIT"))
	elseif flowerNum == 0 then
		G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_WAR_BET_LACK_FLOWER"))
	else
		CrossWarBuyPanel.show(CrossWarBuyPanel.BET)
	end
end

function CrossWarBetLayer:_onClickClose()
	self:animationToClose()

	local soundConst = require("app.const.SoundConst")
	G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
end

function CrossWarBetLayer:_onTabChecked(btnName)
	self:showWidgetByName("Button_Close", btnName ~= "CheckBox_Bet")

	-- switch to the follow-rate rank
	if btnName == "CheckBox_FollowRank" then
		self:_switchToFollowRank()
	elseif btnName == "CheckBox_AwardExplain" then
		local labelExplain = self:getLabelByName("Label_ExplainText")
		if labelExplain:getStringLength() == 0 then
			labelExplain:setText(G_lang:get("LANG_CROSS_WAR_HELP_BET_AWARD"))
		end
	end
end

function CrossWarBetLayer:_onTabUnchecked()
	
end

function CrossWarBetLayer:_switchToFollowRank()
	-- sort the bet list by follow-rate
	G_Me.crossWarData:sortBetListByFollow()

	-- reload list
	local listNum = G_Me.crossWarData:getBetListNum()
	self._followListView:reloadWithLength(listNum)
	self._followListView:setVisible(true)
end

function CrossWarBetLayer:_onRcvBetSomeone()
	self._betListView:refreshAllCell()
	self:_updateWidgetsVisibility()
end

function CrossWarBetLayer:_onRcvAddBets(addNum)
	local betNum = G_Me.crossWarData:getBetNum()
	self:showTextWithLabel("Label_BetNum", betNum)

	-- change the bonus pool
	local bonusPerBet = contest_value_info.get(27).value
	local bonusLabel = self:getLabelByName("Label_Bonus")
	local oldBonusNum = G_Me.crossWarData:getBonusPool()
	local newBonusNum = G_Me.crossWarData:addBonusPool(addNum)
	CrossWarCommon.jumpOutNumber(bonusLabel, oldBonusNum * bonusPerBet, newBonusNum * bonusPerBet)
end

function CrossWarBetLayer:_onRcvBagChanged()
	-- update the number of flowers I own
	local flowerNum = G_Me.bagData:getNumByTypeAndValue(G_Goods.TYPE_ITEM, CrossWarCommon.ITEM_FLOWER_ID)
	self:showTextWithLabel("Label_FlowerNum", flowerNum)
end

function CrossWarBetLayer:_updateWidgetsVisibility()
	-- some flags
	local canBet = G_Me.crossWarData:getCurState() == CrossWarCommon.STATE_AFTER_SCORE_MATCH
	local betUserNum = G_Me.crossWarData:getBetUserNum()

	-- show or hide some widgets
	self:showWidgetByName("Panel_CountDown", canBet)
	self:showWidgetByName("Label_BetDesc_1", betUserNum == 0)
	self:showWidgetByName("Label_BetDesc_3", canBet and betUserNum == 0)
	self:showWidgetByName("Button_Bet", canBet and betUserNum > 0)
	self:showWidgetByName("Image_BetOver", not canBet)

	self:showTextWithLabel("Label_BetDesc_1", G_lang:get(canBet and "LANG_CROSS_WAR_BET_TIP" or "LANG_CROSS_WAR_BET_OVER_1"))
end

function CrossWarBetLayer:_updateMatchState()
	local needCD = G_Me.crossWarData:getCurState() == CrossWarCommon.STATE_AFTER_SCORE_MATCH
	if not needCD then
		self:animationToClose()
	end
end

function CrossWarBetLayer:_updateCD(strCD)
	local needCD = G_Me.crossWarData:getCurState() == CrossWarCommon.STATE_AFTER_SCORE_MATCH

	if needCD then
		self:showTextWithLabel("Label_CD", strCD)

		-- adjust the whole line, keep it at the center
		local panel = self:getPanelByName("Panel_CountDown")
		CrossWarCommon.centerContent(panel)
	end
end

return CrossWarBetLayer