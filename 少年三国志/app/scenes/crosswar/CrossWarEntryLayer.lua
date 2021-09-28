-- CrossWarEntryLayer
-- This layer is the entry point of the Score-Match mode and ChampionShip mode in the cross-server war.
-- It's as well the first layer to appear when user enters the cross-server war.

local CrossWarEntryLayer = class("CrossWarEntryLayer", UFCCSNormalLayer)

function CrossWarEntryLayer.create(scenePack, ...)
	return CrossWarEntryLayer.new("ui_layout/crosswar_EntryLayer.json", nil, scenePack, ...)
end

local EffectNode = require("app.common.effects.EffectNode")
local CrossWarCommon = require("app.scenes.crosswar.CrossWarCommon")
local CrossWarBuyPanel = require("app.scenes.crosswar.CrossWarBuyPanel")

local MODE_SCORE_MATCH 	= 1	-- 积分赛
local MODE_CHAMPIONSHIP	= 2 -- 争霸赛
local STATUS_INVALID 	= 1	-- 功能尚未开放（敬请期待）
local STATUS_NOT_OPEN  	= 2 -- 功能开放但时间未到（尚未开启）
local STATUS_END		= 3 -- 功能已结束（回顾战况）
local STATUS_CD_TO_BEGIN= 4 -- 比赛开始倒计时
local STATUS_CD_TO_END 	= 5 -- 比赛结束倒计时
local status_textures	= { {"ui/text/txt/kfyw_jinqingqidai.png", "ui/text/txt/kfyw_shangweikaiqi.png", "ui/text/txt/kfyw_huiguzhankuang.png"},
							{"ui/text/txt/kfyw_jinqingqidai.png", "ui/text/txt/kfyw_zhengzaichoubei.png", "ui/text/txt/kfyw_huiguzhankuang.png"} }
local str_modes			= {G_lang:get("LANG_CROSS_WAR_MODE_1"), G_lang:get("LANG_CROSS_WAR_MODE_2")}

function CrossWarEntryLayer:ctor(jsonFile, fun, scenePack, ...)
	self._isFirstEnter	= true
	self._uiStatus		= { nil, nil }	-- 积分赛和争霸赛入口UI的状态
	self._curCdLabel 	= { nil, nil }	-- 积分赛和争霸赛倒计时label的引用
	self._knifeEffect 	= nil

	self.super.ctor(self, ...)
	G_GlobalFunc.savePack(self, scenePack)
end

function CrossWarEntryLayer:onLayerLoad(...)
	self:registerKeypadEvent(true)

	-- set some text
	self:showTextWithLabel("Label_Medal", G_lang:get("LANG_GOODS_CROSSWAR_MEDAL") .. "：")
	self:showTextWithLabel("Label_Hot", G_lang:get("LANG_FU_STATE2"))

	-- create strokes
	self:enableLabelStroke("Label_Medal", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Medal_Num", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_ChallengeCount", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_CD_Tip_1", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_CD_Tip_2", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_CD_1", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_CD_2", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Hot", Colors.strokeBrown, 2)

	-- register button events
	self:registerBtnClickEvent("Button_Match_1", handler(self, self._onClickScoreMatch))
	self:registerBtnClickEvent("Button_Match_2", handler(self, self._onClickChampionShip))
	self:registerBtnClickEvent("Button_BuyChallenge", handler(self, self._onClickBuyChallenge))
	self:registerBtnClickEvent("Button_Help", handler(self, self._onClickHelp))
	self:registerBtnClickEvent("Button_Shop", handler(self, self._onClickShop))
	self:registerBtnClickEvent("Button_Invitation", handler(self, self._onClickInvitation))
	self:registerBtnClickEvent("Button_Bet", handler(self, self._onClickBet))
	self:registerBtnClickEvent("Button_Back", handler(self, self.onBackKeyEvent))

	-- light effect on the bet button
	if not self._btnEffect then
		self._btnEffect = EffectNode.new("effect_circle_light2", function(event) end)
		self:getWidgetByName("Panel_BtnEffect"):addNode(self._btnEffect)
		--self._bgEffect:setScale(0.5)
		self._btnEffect:play()
	end
end

function CrossWarEntryLayer:onLayerEnter(...)
	-- set medal count and challenge count
	self:_updateMedalCount()
	self:_updateChallengeCount()

	-- update UI about states when entering the layer
	self:_updateMatchState()
	self:_updateChampionshipUI()

	-- register event listners
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_BATTLE_INFO, self._onRcvBattleInfo, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_ARENA_INFO, self._updateChampionshipUI, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_INVITATION, self._showInvitation, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_ENTER_SCORE_MATCH, self._updateChallengeCount, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_COUNT_RESET, self._updateChallengeCount, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_BUY_CHALLENGE, self._updateChallengeCount, self)

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_BET_INFO, self._showBetLayer, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_TOP_RANKS, self._updateRedTip_championship, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_BET_AWARD, self._updateRedTip_championship, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_SERVER_AWARD_INFO, self._updateRedTip_championship, self)	

	uf_eventManager:addEventListener(CrossWarCommon.EVENT_STATE_CHANGED, self._updateMatchState, self)
	uf_eventManager:addEventListener(CrossWarCommon.EVENT_UPDATE_COUNTDOWN, self._updateCD, self)
end

function CrossWarEntryLayer:onLayerExit(...)
	uf_eventManager:removeListenerWithTarget(self)
end

-- back
function CrossWarEntryLayer:onBackKeyEvent()
	local packScene = G_GlobalFunc.createPackScene(self)
    if not packScene then 
       	packScene = require("app.scenes.mainscene.PlayingScene").new()
    end
    uf_sceneManager:replaceScene(packScene)
    return true
end

-- "积分赛"按钮响应函数
function CrossWarEntryLayer:_onClickScoreMatch()
	local state = G_Me.crossWarData:getCurState()

	if state <= CrossWarCommon.STATE_BEFORE_SCORE_MATCH then
		G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_WAR_MODE_NOT_OPEN", {mode = str_modes[MODE_SCORE_MATCH]}))
	
	elseif state == CrossWarCommon.STATE_IN_SCORE_MATCH and not G_Me.crossWarData:isGroupChoosed() then
			self:showChooseGroupLayer()

	else
		local layer = require("app.scenes.crosswar.CrossWarScoreMatchLayer").create()
		uf_sceneManager:getCurScene():replaceLayer(layer)
	end
end

-- "争霸赛"按钮响应函数
function CrossWarEntryLayer:_onClickChampionShip()
	local uiStatus = self._uiStatus[MODE_CHAMPIONSHIP]

	if uiStatus == STATUS_INVALID then
		G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_WAR_CHAMPIONSHIP_DISABLE"))
	elseif uiStatus == STATUS_NOT_OPEN then
		G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_WAR_CHAMPIONSHIP_WILL_OPEN"))
	elseif uiStatus == STATUS_CD_TO_BEGIN then
		G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_WAR_BET_PLEASE"))
	elseif uiStatus == STATUS_CD_TO_END or uiStatus == STATUS_END then
		local layer = require("app.scenes.crosswar.CrossWarChampionshipLayer").create()
		uf_sceneManager:getCurScene():replaceLayer(layer)
	end
end

-- buy challenge count
function CrossWarEntryLayer:_onClickBuyChallenge()
	local canBuy = G_Me.crossWarData:canBuyChallenge()
	local cost = G_Me.crossWarData:getChallengeCost()

	-- check purchase conditions
	if not canBuy then
		-- purshase count has reached limitation
		G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_WAR_CANNOT_BUY"))
	
	elseif G_Me.userData.gold < cost then
		-- gold not enough
		G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_REBORN_GOLD_EMPTY"))

	else
		-- pop up the purchase panel
		CrossWarBuyPanel.show(CrossWarBuyPanel.BUY_CHALLENGE)
	end
end

-- show help panel
function CrossWarEntryLayer:_onClickHelp()
	require("app.scenes.common.CommonHelpLayer").show(
		{
			{title = G_lang:get("LANG_CROSS_WAR_MODE_1"), content = G_lang:get("LANG_CROSS_WAR_HELP_SCORE_MATCH")},
			{title = G_lang:get("LANG_CROSS_WAR_MODE_2"), content = G_lang:get("LANG_CROSS_WAR_HELP_CHAMPIONSHIP")}
		})
end

-- click the invitation button
function CrossWarEntryLayer:_onClickInvitation()
	if G_Me.crossWarData:getQualifyType() == 0 then
		G_HandlersManager.crossWarHandler:sendGetInvitation()
	else
		self:_showInvitation()
	end
end

-- show shop
function CrossWarEntryLayer:_onClickShop()
	uf_sceneManager:pushScene(require("app.scenes.shop.score.ShopScoreScene").new(SCORE_TYPE.CROSS_WAR))
end

-- show the championship-match bet layer
function CrossWarEntryLayer:_onClickBet()
	G_HandlersManager.crossWarHandler:sendGetBetInfo()
end

-- handler of the "EVENT_CROSS_WAR_GET_BATTLE_INFO" event
function CrossWarEntryLayer:_onRcvBattleInfo()
	-- 只执行一次
	if self._isFirstEnter == false then
		return
	end

	local isPullingMsg = false

	-- if the user has choosed a group, then pull the match info
	if G_Me.crossWarData:isGroupChoosed() then
		G_HandlersManager.crossWarHandler:sendEnterScoreBattle()
		isPullingMsg = true		
	end

	-- pull the championship info
	if G_Me.crossWarData:isChampionshipEnabled() then
		if G_Me.crossWarData:getCurState() >= CrossWarCommon.STATE_AFTER_SCORE_MATCH then
			G_HandlersManager.crossWarHandler:sendGetChampionshipInfo()
			isPullingMsg = true
		end

		if G_Me.crossWarData:getCurState() == CrossWarCommon.STATE_AFTER_CHAMPIONSHIP then
			-- NOTE:现在暂时关闭押注功能
			--G_HandlersManager.crossWarHandler:sendGetBetAward()
			G_HandlersManager.crossWarHandler:sendGetServerAwardInfo()
			G_HandlersManager.crossWarHandler:sendGetTopRanks()
		end
	end

	-- no info needs pulling, use native config table to set the challenge count
	if not isPullingMsg then
		self:_updateChallengeCount()
	end

	-- update UI about states
	self:_updateMatchState()

	self._isFirstEnter = false
end

-- update UI status
function CrossWarEntryLayer:_updateMatchState()
	-- 积分赛和争霸赛UI在各个阶段的默认状态
	local UIStatus = { {[0] = STATUS_NOT_OPEN, [1] = STATUS_CD_TO_BEGIN, [2] = STATUS_CD_TO_END, [3] = STATUS_END, [4] = STATUS_END, [5] = STATUS_END},
					   {[0] = STATUS_INVALID, [1] = STATUS_NOT_OPEN, [2] = STATUS_NOT_OPEN, [3] = STATUS_CD_TO_BEGIN, [4] = STATUS_CD_TO_END, [5] = STATUS_END} }

	-- 获取当前比赛状态
	local warState		 		= G_Me.crossWarData:getCurState()
	local isChampionshipEnabled = G_Me.crossWarData:isChampionshipEnabled()
	local hasLastChampionship	= G_Me.crossWarData:hasLastChampionship()
	local isQualify				= G_Me.crossWarData:isQualify()
	local isInScoreMatch		= warState == CrossWarCommon.STATE_IN_SCORE_MATCH
	local isInChampionship		= warState == CrossWarCommon.STATE_IN_CHAMPIONSHIP
	local isInMatch 			= isInScoreMatch or isInChampionship and isChampionshipEnabled
	
	-- 设定UI状态，本轮争霸赛未开启，或上轮争霸赛开启，UI状态都有变化
	self._uiStatus = { UIStatus[1][warState], UIStatus[2][warState] }
	if not isChampionshipEnabled then
		self._uiStatus[2] = STATUS_INVALID
	elseif hasLastChampionship and (warState == CrossWarCommon.STATE_BEFORE_SCORE_MATCH or warState == CrossWarCommon.STATE_IN_SCORE_MATCH) then
		self._uiStatus[2] = STATUS_END
	end

	-- 更新入口UI
	self:_updateEntryUI(MODE_SCORE_MATCH, self._uiStatus[MODE_SCORE_MATCH])
	self:_updateEntryUI(MODE_CHAMPIONSHIP, self._uiStatus[MODE_CHAMPIONSHIP])

	-- 是否显示“火热进行中”特效
	local effectPanel = self:getPanelByName("Panel_InMatch_Effects")
	effectPanel:setVisible(isInMatch)

	if isInMatch then
		if not self._knifeEffect then
			self._knifeEffect = EffectNode.new("effect_knife", nil)
			self._knifeEffect:play()
			self:getPanelByName("Panel_Knife_Effect"):addNode(self._knifeEffect)
		end

		local attachToBtn = self:getWidgetByName(isInScoreMatch and "Button_Match_1" or "Button_Match_2")
		if effectPanel:getParent():getName() ~= attachToBtn:getName() then
			effectPanel:retain()
			effectPanel:removeFromParentAndCleanup(false)
			attachToBtn:addChild(effectPanel)
			effectPanel:release()
		end
	end

	-- 是否显示争霸赛押注按钮
	-- NOTE:现在暂时关闭押注功能
	--self:showWidgetByName("Image_Bet_Bg", isChampionshipEnabled and warState == CrossWarCommon.STATE_AFTER_SCORE_MATCH)
	self:showWidgetByName("Image_Bet_Bg", false)

	-- 是否显示邀请函
	local showInvite = (warState == CrossWarCommon.STATE_AFTER_SCORE_MATCH or isInChampionship) and isChampionshipEnabled and isQualify
	self:showWidgetByName("Button_Invitation", showInvite)

	-- 是否显示“今日挑战次数”
	local canEnterMatch = ( (isInScoreMatch and G_Me.crossWarData:isGroupChoosed()) or (isInChampionship and isChampionshipEnabled and isQualify) )
	self:showWidgetByName("Panel_BottomUI", canEnterMatch)
	if canEnterMatch then
		self:showTextWithLabel("Label_ChallengeCount", G_lang:get("LANG_TOWER_CISHUSHENGYU1") .. G_Me.crossWarData:getChallengeCount())
	end

	-- 是否显示小红点提示
	self:_updateRedTip()
	self:_updateRedTip_championship()
end

-- update entry UI
-- #param type: 1 - score match; 2 - championship
-- #param status: 1 - invalid; 2 - not open; 3 - end; 4 - countdown to begin; 5 - countdown to end
function CrossWarEntryLayer:_updateEntryUI(type, status)
	local isShowCD		= (status == STATUS_CD_TO_BEGIN or status == STATUS_CD_TO_END)

	-- should we show the countdown label or the status image?
	local tipLabel = self:getLabelByName("Label_CD_Tip_" .. type)
	local cdLabel  = self:getLabelByName("Label_CD_" .. type)
	local statusImg = self:getImageViewByName("Image_Status_" .. type)
	tipLabel:setVisible(isShowCD)
	cdLabel:setVisible(isShowCD)
	statusImg:setVisible(not isShowCD)

	-- if the countdown will show, save the CD label
	self._curCdLabel[type] = isShowCD and cdLabel or nil

	-- if the countdown will show, set the description text
	-- else, show different status image according to status
	if isShowCD then
		local lang = (status == STATUS_CD_TO_END and "LANG_CROSS_WAR_TIME_TO_END" or "LANG_CROSS_WAR_TIME_TO_BEGIN")
		local strTip = G_lang:get(lang, {mode = str_modes[type]})
		tipLabel:setText(strTip)
	else
		statusImg:loadTexture(status_textures[type][status])
	end
end

-- update UI of championship(invitation, bet button ...)
function CrossWarEntryLayer:_updateChampionshipUI()
	-- if qualified for the championship
	if G_Me.crossWarData:isQualify() then
		local state = G_Me.crossWarData:getCurState()

		-- show the invitation button
		self:showWidgetByName("Button_Invitation", state == CrossWarCommon.STATE_AFTER_SCORE_MATCH or
												   state == CrossWarCommon.STATE_IN_CHAMPIONSHIP)

		-- show the challenge count and update it
		self:showWidgetByName("Panel_BottomUI", state == CrossWarCommon.STATE_IN_CHAMPIONSHIP)

		if state == CrossWarCommon.STATE_IN_CHAMPIONSHIP then
			self:_updateChallengeCount()
		end
	end
end

-- update countdown
function CrossWarEntryLayer:_updateCD(strCD)
	for i = 1, #self._curCdLabel do
		if self._curCdLabel[i] then
			self._curCdLabel[i]:setText(strCD)
		end
	end
end

-- update challenge count
function CrossWarEntryLayer:_updateChallengeCount()
	-- set challenge count
	local count = G_Me.crossWarData:getChallengeCount()
	self:showTextWithLabel("Label_ChallengeCount", G_lang:get("LANG_TOWER_CISHUSHENGYU1") .. count)

	-- update red-dot tip
	self:_updateRedTip()
	self:_updateRedTip_championship()
end

-- update cross-war medal count
function CrossWarEntryLayer:_updateMedalCount()
	self:showTextWithLabel("Label_Medal_Num", tostring(G_Me.userData.contest_point))
end

function CrossWarEntryLayer:_updateRedTip()
	self:showWidgetByName("Image_RedTip_1", G_Me.crossWarData:checkCanGetAward() or G_Me.crossWarData:canChallenge())
end

function CrossWarEntryLayer:_updateRedTip_championship()
	-- 争霸赛的小红点
	local state = G_Me.crossWarData:getCurState()
	local tipImage = self:getImageViewByName("Image_RedTip_2")
	if state == CrossWarCommon.STATE_IN_CHAMPIONSHIP then
		-- 比赛进行中，如果有挑战次数没用完，显示小红点
		local canChallenge = G_Me.crossWarData:checkCanChallengeChampion()
		tipImage:setVisible(canChallenge)
	elseif state == CrossWarCommon.STATE_AFTER_CHAMPIONSHIP then
		-- 比赛已结束，如果有奖励可拿，显示小红点
		local canGetBetAward = G_Me.crossWarData:checkCanGetBetAward()
		local canGetServerAward = G_Me.crossWarData:checkCanGetServerAward()
		tipImage:setVisible(canGetBetAward or canGetServerAward)
	else
		tipImage:setVisible(false)
	end
end

function CrossWarEntryLayer:showChooseGroupLayer()
	local layer = require("app.scenes.crosswar.CrossWarChooseGroupLayer").create()
	uf_sceneManager:getCurScene():addChild(layer)
end

function CrossWarEntryLayer:_showInvitation()
	layer = require("app.scenes.crosswar.CrossWarInviteLayer").create(false)
	uf_sceneManager:getCurScene():addChild(layer)
end

function CrossWarEntryLayer:_showBetLayer()
	layer = require("app.scenes.crosswar.CrossWarBetLayer").create()
	uf_sceneManager:getCurScene():addChild(layer)
end

return CrossWarEntryLayer