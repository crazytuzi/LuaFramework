-- CrossWarScoreMatchLayer
-- This layer shows the main UI of the score-match mode. When the player select the
-- "score-match" at the entry layer, and with group choosed, it will jump to this layer

local CrossWarScoreMatchLayer = class("CrossWarScoreMatchLayer", UFCCSNormalLayer)

require("app.cfg.knight_info")
require("app.cfg.contest_value_info")
local GlobalConst = require("app.const.GlobalConst")
local FightEnd = require("app.scenes.common.fightend.FightEnd")
local KnightPic = require("app.scenes.common.KnightPic")
local EffectNode = require("app.common.effects.EffectNode")
local EffectSingleMoving = require("app.common.effects.EffectSingleMoving")
local CrossWarCommon = require("app.scenes.crosswar.CrossWarCommon")
local CrossWarBattleScene = require("app.scenes.crosswar.CrossWarBattleScene")
local CrossWarBuyPanel = require("app.scenes.crosswar.CrossWarBuyPanel")
local OpponentItem = require("app.scenes.crosswar.CrossWarOpponentItem")
local OPPONENT_NUM = 3

function CrossWarScoreMatchLayer.create(...)
	return CrossWarScoreMatchLayer.new("ui_layout/crosswar_ScoreMatchLayer.json", nil, ...)
end

function CrossWarScoreMatchLayer:ctor(jsonFile, fun, ...)
	self._bgEffect 				= nil
	self._opponents 			= nil
	self._challengedIndex 		= nil	-- the index of the opponent challenged just now
	self._isMatchEnd			= G_Me.crossWarData:isScoreMatchEnd()
	self._curMatchState			= G_Me.crossWarData:getCurState()
	self._isFirstEnter			= true
	self._needRefreshOpponents	= false -- 当三个对手都被击败后，将此flag设为true，以便在回到此界面的时候刷新对手
	self._oldScore				= 0
	self._oldMedalNum			= 0
	self._isFighting			= false -- 是否在战斗期间

	self._labelScoreNum 		= self:getLabelByName("Label_Score_Num")
	self._labelRankNum			= self:getLabelByName("Label_Rank_Num")
	self._labelGroupName		= self:getLabelByName("Label_GroupName")
	self._labelMedalNum			= self:getLabelByName("Label_Medal_Num")
	self._labelRefreshCost		= self:getLabelByName("Label_Refresh_Cost")
	self._labelRefreshNum		= self:getLabelByName("Label_Refresh_Num")
	self._labelChallengeNum		= self:getLabelByName("Label_ChallengeCount")
	self._panelOpponents		= self:getPanelByName("Panel_Opponents")
	self._panelMatchEnd			= self:getPanelByName("Panel_MatchEnd")

	self.super.ctor(self, ...)
end

function CrossWarScoreMatchLayer:onLayerLoad(...)
	-- create strokes for labels
	self:_createStrokes()

	-- set fixed texts
	self:_setFixedTexts()

	-- initialize opponents or the match-end UI
	self:_initEndUI()
	self:_initOpponentItems()

	self:getPanelByName("Panel_BottomUI"):setVisible(self._isMatchEnd == false)

	-- initialize background effect
	self:_initBgEffect()

	-- register button events
	self:registerBtnClickEvent("Button_Back", handler(self, self.onBackKeyEvent))
	self:registerBtnClickEvent("Button_WinStreakAward", handler(self, self._onClickAward))
	self:registerBtnClickEvent("Button_Rank", handler(self, self._onClickRank))
	self:registerBtnClickEvent("Button_Refresh", handler(self, self._onClickRefresh))
	self:registerBtnClickEvent("Button_BuyChallenge", handler(self, self._onClickBuyChallenge))
	self:registerBtnClickEvent("Button_Help", handler(self, self._onClickHelp))
	self:registerBtnClickEvent("Button_Shop", handler(self, self._onClickShop))
end

function CrossWarScoreMatchLayer:onLayerEnter(...)
	self:registerKeypadEvent(true, false)

	-- initialize base info
	self:_updateScore()
	self:_updateRank()
	self:_updateMedalNum()
	self:_updateRefreshCount()
	self:_updateChallengeCount()
	self:_updateGroupName()
	self:_updateMatchState()

	-- register event listeners
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_BATTLE_ENEMY, self._onRcvOpponents, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_CHALLENGE_SCORE_ENEMY, self._onRcvChallengeResult, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_COUNT_RESET, self._onRcvCountReset, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_BUY_CHALLENGE, self._updateChallengeCount, self)
	--uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_FLUSH_SCORE, self._updateScore, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_FLUSH_SCORE_MATCH_RANK, self._updateRank, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECV_ROLE_INFO, self._updateMedalNum, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_FINISH_WINS_AWARD, self._checkWinStreakAward, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_WINS_AWARD_INFO, self._checkWinStreakAward, self)

	uf_eventManager:addEventListener(CrossWarCommon.EVENT_STATE_CHANGED, self._updateMatchState, self)
	uf_eventManager:addEventListener(CrossWarCommon.EVENT_UPDATE_COUNTDOWN, self._updateCD, self)

	-- pull opponents' info
	if self._isFirstEnter and not self._isMatchEnd then
		G_HandlersManager.crossWarHandler:sendGetEnemy(false)
		self._isFirstEnter = false
	elseif self._needRefreshOpponents then
		if not self._isMatchEnd then
			G_HandlersManager.crossWarHandler:sendGetEnemy(false)
		end
		self._needRefreshOpponents = false
	end

	-- pull the ID list of got award IDs
	G_HandlersManager.crossWarHandler:sendGetWinsAwardInfo()
end

function CrossWarScoreMatchLayer:onLayerExit(...)
	uf_eventManager:removeListenerWithTarget(self)
end

function CrossWarScoreMatchLayer:onBackKeyEvent(...)
	uf_sceneManager:getCurScene():goToEntry()
	return true
end

-- create strokes for labels
function CrossWarScoreMatchLayer:_createStrokes()
	self:enableLabelStroke("Label_Score", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_Rank", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_Medal", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_Refresh", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_EndTime_Text", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_EndTime", Colors.strokeBrown, 2)

	self._labelScoreNum:createStroke(Colors.strokeBrown, 2)
	self._labelRankNum:createStroke(Colors.strokeBrown, 2)
	self._labelGroupName:createStroke(Colors.strokeBrown, 2)
	self._labelMedalNum:createStroke(Colors.strokeBrown, 2)
	self._labelRefreshCost:createStroke(Colors.strokeBrown, 2)
	self._labelRefreshNum:createStroke(Colors.strokeBrown, 2)
	self._labelChallengeNum:createStroke(Colors.strokeBrown, 1)
end

-- set fixed texts
function CrossWarScoreMatchLayer:_setFixedTexts()
	local score = self:getLabelByName("Label_Score")
	score:setText(G_lang:get("LANG_DAILYTASK_SCORE"))

	local rank = self:getLabelByName("Label_Rank")
	rank:setText(G_lang:get("LANG_CROSS_WAR_GROUP_RANK"))

	local medal = self:getLabelByName("Label_Medal")
	medal:setText(G_lang:get("LANG_GOODS_CROSSWAR_MEDAL") .. "：")

	local refresh = self:getLabelByName("Label_Refresh")
	refresh:setText(G_lang:get("LANG_REFRESH"))
end

-- initialize background effect
function CrossWarScoreMatchLayer:_initBgEffect()
	if not self._bgEffect then
		self._bgEffect = EffectNode.new("effect_yuanwu", function(event) end)
		self:getWidgetByName("ImageView_BG"):addNode(self._bgEffect)
		self._bgEffect:setScale(0.5)
		self._bgEffect:play()
	end
end

-- initialize opponent items
function CrossWarScoreMatchLayer:_initOpponentItems()
	self._opponents = {}
	for i = 1, OPPONENT_NUM do
		self._opponents[i] = OpponentItem.new(i, self)
		local parent = self:getPanelByName("Panel_Opponent" .. i)
		parent:addChild(self._opponents[i])
	end

	self._panelOpponents:setVisible(not self._isMatchEnd)
end

-- initialize the match-end panel if match is end
function CrossWarScoreMatchLayer:_initEndUI()
	self._panelMatchEnd:setVisible(self._isMatchEnd)
	if self._isMatchEnd then
		self:showWidgetByName("Label_EndTime_Text", false)
		self:showWidgetByName("Label_EndTime", false)
		self:_requestGroupChampions()
	end
end

function CrossWarScoreMatchLayer:_updateScore()
	self._labelScoreNum:setText("" .. G_Me.crossWarData:getScore())
	self._oldScore = G_Me.crossWarData:getScore()
end

function CrossWarScoreMatchLayer:_updateRank()
	local rank = G_Me.crossWarData:getRank()
	local strRank = rank > 0 and tostring(rank) or G_lang:get("LANG_NOT_IN_RANKING_LIST")
	self._labelRankNum:setText(strRank)
end

function CrossWarScoreMatchLayer:_updateMedalNum()
	-- 因为战斗后要播跳数字效果，这里暂时不设置新的数值
	if not self._isFighting then
		self._labelMedalNum:setText("" .. G_Me.userData.contest_point)
		self._oldMedalNum = G_Me.userData.contest_point
	end
end

function CrossWarScoreMatchLayer:_updateRefreshCount()
	local canFreeRefresh = G_Me.crossWarData:canFreeRefresh()
	local canBuyRefresh = G_Me.crossWarData:canBuyRefresh()

	self._labelRefreshNum:setVisible(canFreeRefresh or not canBuyRefresh)
	self._labelRefreshCost:setVisible(not canFreeRefresh and canBuyRefresh)
	self:showWidgetByName("ImageView_Yuanbao", not canFreeRefresh and canBuyRefresh)
	self:showWidgetByName("Label_Refresh", not canFreeRefresh and canBuyRefresh)

	if canFreeRefresh then
		local freeNum = G_Me.crossWarData:getRefreshCount()
		self._labelRefreshNum:setText(G_lang:get("LANG_CROSS_WAR_FREE_REFRESH_NUM", {num = freeNum}))
	elseif canBuyRefresh then
		local cost = G_Me.crossWarData:getRefreshCost()
		self._labelRefreshCost:setText(tostring(cost))
	else
		self._labelRefreshNum:setText(G_lang:get("LANG_CROSS_WAR_CANNOT_REFRESH"))
	end
end

function CrossWarScoreMatchLayer:_updateChallengeCount()
	self._labelChallengeNum:setText(G_lang:get("LANG_DUNGEON_TODAYCHALLENGE", {num = G_Me.crossWarData:getChallengeCount()}))
end

function CrossWarScoreMatchLayer:_updateGroupName()
	local group = G_Me.crossWarData:getGroup()

	if group == 0 then
		self._labelGroupName:setVisible(false)
	else
		local groupName = contest_points_buff_info.get(group).name
		self._labelGroupName:setVisible(true)
		self._labelGroupName:setText("(" .. groupName .. ")")

		-- adjust position to align with the rank label
		local newX = self._labelRankNum:getPositionX() + self._labelRankNum:getContentSize().width
		self._labelGroupName:setPositionX(newX)
	end
end

function CrossWarScoreMatchLayer:_requestGroupChampions()
	-- 获取4个组的状元，如果没有则向服务器发请求
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_BATTLE_RANK, self._requestGroupChampions, self)
	for i = 1, 4 do
		if not G_Me.crossWarData:hasFinalScoreRank(i) then
			G_HandlersManager.crossWarHandler:sendGetBattleRank(i)
			return
		end
	end

	-- 四个组的排行榜都已拉过, 显示结束UI
	uf_eventManager:removeListenerWithEvent(self, G_EVENTMSGID.EVENT_CROSS_WAR_GET_BATTLE_RANK)
	self._panelMatchEnd:setVisible(true)
	self:_showEndInfo()
	self:_showChampions()
end

-- 显示结束后提示语句
function CrossWarScoreMatchLayer:_showEndInfo()
	-- 显示蔡文姬说的提示话
	local tip = ""
	local groupID = G_Me.crossWarData:getGroup()
	local tipLabel = self:getLabelByName("Label_EndTip")
	if groupID == 0 then
		tip = G_lang:get("LANG_CROSS_WAR_SCORE_MATCH_END_TIP_3")
		tipLabel:setText(tip)
	else
		local groupName = contest_points_buff_info.get(groupID).name
		local myRank = G_Me.crossWarData:getRank()
		if myRank > 0 and myRank <= 100 then
			tip = G_lang:get("LANG_CROSS_WAR_SCORE_MATCH_END_TIP_1", {group = groupName, rank = myRank})
		else
			tip = G_lang:get("LANG_CROSS_WAR_SCORE_MATCH_END_TIP_2", {group = groupName})
		end

		-- create a rich text label to show the tip
		if not self._richLabel then
			self._richLabel = CrossWarCommon.createRichTextFromTemplate(tipLabel, tipLabel:getParent(), tip)
		end
	end
end

-- 更新达人榜（即每个组的第一名）
function CrossWarScoreMatchLayer:_showChampions()
	for i = 1, 4 do
		local playerInfo = G_Me.crossWarData:getScoreRankItem(i, 1)
		local nameLabel = self:getLabelByName("Label_ChampionName_" .. i)
		nameLabel:setText(playerInfo and playerInfo.name or G_lang:get("LANG_CROSS_WAR_WAIT_FOR_NO1"))
		nameLabel:setColor(playerInfo and Colors.lightColors.TITLE_01 or Colors.lightColors.DESCRIPTION)

		if playerInfo then
			nameLabel:createStroke(Colors.strokeBrown, 1)
		end

		local serverLabel = self:getLabelByName("Label_ChampionServer_" .. i)
		serverLabel:setVisible(playerInfo ~= nil)
		serverLabel:setText(playerInfo and "(" .. string.gsub(playerInfo.sname, "^.-%((.-)%)", "%1") .. ")" or "")
	end
end

function CrossWarScoreMatchLayer:_updateMatchState()
	local newState = G_Me.crossWarData:getCurState()

	-- 状态没变，什么也不做
	if newState == self._curMatchState then
		return
	end

	if self._curMatchState == CrossWarCommon.STATE_IN_SCORE_MATCH and newState > self._curMatchState then
		-- 从比赛中转为比赛结束
		self._panelOpponents:setVisible(false)
		self:showWidgetByName("Label_EndTime_Text", false)
		self:showWidgetByName("Label_EndTime", false)
		self:_requestGroupChampions()

	elseif newState < self._curMatchState then
		-- 从比赛结束转为新一轮比赛开始，强制踢回入口界面
		uf_sceneManager:replaceScene(require("app.scenes.crosswar.CrossWarScene").new())
		return
	end

	-- 底部刷新和挑战UI
	self._isMatchEnd = G_Me.crossWarData:isScoreMatchEnd()
	self:showWidgetByName("Panel_BottomUI", not self._isMatchEnd)

	-- 记住新的state
	self._curMatchState = newState
end

function CrossWarScoreMatchLayer:_updateCD(strCD)
	self:showTextWithLabel("Label_EndTime", strCD)
end

function CrossWarScoreMatchLayer:_onClickAward()
	self:showWinAwardLayer()
end

function CrossWarScoreMatchLayer:_onClickRank()
	layer = require("app.scenes.crosswar.CrossWarScoreRankLayer").create()
	uf_sceneManager:getCurScene():addChild(layer)
end

function CrossWarScoreMatchLayer:_onClickRefresh()
	local canFreeRefresh = G_Me.crossWarData:canFreeRefresh()
	local canBuyRefresh = G_Me.crossWarData:canBuyRefresh()
	local cost = G_Me.crossWarData:getRefreshCost()

	if canFreeRefresh then
		-- free refresh
		G_HandlersManager.crossWarHandler:sendGetEnemy(true)
	elseif canBuyRefresh then
		if G_Me.userData.gold < cost then
			-- gold not enough
			G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_REBORN_GOLD_EMPTY"))
		else
			-- buy refresh num
			G_HandlersManager.crossWarHandler:sendCountReset(1)
		end
	else
		-- refresh count has reached limitation
		G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_WAR_CANNOT_REFRESH"))
	end
end

function CrossWarScoreMatchLayer:_onClickBuyChallenge()
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

function CrossWarScoreMatchLayer:_onClickHelp()
	require("app.scenes.common.CommonHelpLayer").show(
		{
			{title = G_lang:get("LANG_CROSS_WAR_MODE_1"), content = G_lang:get("LANG_CROSS_WAR_HELP_SCORE_MATCH")},
		})
end

function CrossWarScoreMatchLayer:_onClickShop()
	uf_sceneManager:pushScene(require("app.scenes.shop.score.ShopScoreScene").new(SCORE_TYPE.CROSS_WAR))
end

-- handler of "EVENT_CROSS_WAR_GET_BATTLE_ENEMY" event
function CrossWarScoreMatchLayer:_onRcvOpponents()
	-- update refresh count
	self:_updateRefreshCount()

	-- update opponent info
	for _, v in ipairs(self._opponents) do
		v:update()
	end
end

-- handler of "EVENT_CROSS_WAR_CHALLENGE_SCORE_ENEMY" event
function CrossWarScoreMatchLayer:_onRcvChallengeResult(battleReport)
	-- refresh remaining challenge count
	self._labelChallengeNum:setText(G_lang:get("LANG_DUNGEON_TODAYCHALLENGE", {num = G_Me.crossWarData:getChallengeCount()}))

	-- callback when the battle finished
	local callback = function(result)
		local curSceneName = G_SceneObserver:getSceneName()
		if not self or curSceneName ~= "CrossWarScene" and curSceneName ~= "CrossWarBattleScene" then
        	return
        end

        -- update rank
        self:_updateRank()

        -- update the opponent's UI if win
        local isWin = battleReport.is_win
        if isWin == true then
        	self._opponents[self._challengedIndex]:setBeaten(true)
        end

        -- show fight result
        FightEnd.show(FightEnd.TYPE_CROSSWAR, isWin, 
        			  {
        			  	crosswar_score = G_Me.crossWarData:getScore() - self._oldScore,
        			  	crosswar_medal = G_Me.userData.contest_point - self._oldMedalNum,
        			  	crosswar_curWinStreak = G_Me.crossWarData:getCurWinStreak()
        			  },
        			  handler(self, self._fightEndCallback), result)
	end

	-- show battle scene
	G_Loading:showLoading(
		function(...)
			local opponentInfo = G_Me.crossWarData:getOpponentInfo(self._challengedIndex)
			local opponent = 
			{
				id = opponentInfo.id,
				name = opponentInfo.name,
				power = opponentInfo.fight_value
			}

			self._battleScene = CrossWarBattleScene:new(battleReport, opponent, callback)
			uf_sceneManager:pushScene(self._battleScene)
		end,

		function(...)
			if self._battleScene then
				self._battleScene:play()
			end
		end
	)
end

-- handler of "EVENT_CROSS_WAR_COUNT_RESET" event
function CrossWarScoreMatchLayer:_onRcvCountReset(resetType)
	-- update refresh cost or challenge count
	if resetType == 1 then
		G_HandlersManager.crossWarHandler:sendGetEnemy(true)
	elseif resetType == 2 then
		self:_updateChallengeCount()
	end
end

-- callback when the fightend layer disappears
function CrossWarScoreMatchLayer:_fightEndCallback()
	local curSceneName = G_SceneObserver:getSceneName()
    if not self or curSceneName ~= "CrossWarScene" and curSceneName ~= "CrossWarBattleScene" then
		return
    end

    -- pop the battle scene
	uf_sceneManager:popScene()

	-- reset the challenged index
	self:setChallengedIndex(0)

	-- if all opponents are beaten, refresh
	if G_Me.crossWarData:isAllOpponentsBeaten() then
		self._needRefreshOpponents = true
	end

	-- jump out the new score and medal number
	self:_playAddNum(self._labelScoreNum, self._oldScore, G_Me.crossWarData:getScore())
	self:_playAddNum(self._labelMedalNum, self._oldMedalNum, G_Me.userData.contest_point)

	-- 因为播完跳数字效果后不会再调相应的_update，在这里记录加好后的数值
	self._oldScore = G_Me.crossWarData:getScore()
	self._oldMedalNum = G_Me.userData.contest_point
end

-- save the index of the opponent challenged just now
function CrossWarScoreMatchLayer:setChallengedIndex(index_)
	self._challengedIndex = index_
	self._isFighting = index_ ~= 0
end

-- check if there's winning-streak award to get
function CrossWarScoreMatchLayer:_checkWinStreakAward()
	local canGet = G_Me.crossWarData:checkCanGetAward()
	self:getImageViewByName("Image_RedTip"):setVisible(canGet)
end

-- increase the score or medal number by jumping the number out
function CrossWarScoreMatchLayer:_playAddNum(labelNum, oldNum, newNum)
	-- create the action array
	local scale = CCSequence:createWithTwoActions(CCScaleTo:create(0.25, 2), CCScaleTo:create(0.25, 1))
	local growUp = CCNumberGrowupAction:create(oldNum, newNum, 0.5, function(number) 
		labelNum:setText(tostring(number))
	end)
	local act = CCSpawn:createWithTwoActions(scale, growUp)
	labelNum:runAction(act)
end

function CrossWarScoreMatchLayer:showWinAwardLayer()
	local layer = require("app.scenes.crosswar.CrossWarWinAwardLayer").create()
	uf_sceneManager:getCurScene():addChild(layer)
end

return CrossWarScoreMatchLayer