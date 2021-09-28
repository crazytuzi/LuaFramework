local CrossWarChampionshipLayer = class("CrossWarChampionshipLayer", UFCCSNormalLayer)

local CrossWarCommon	   	= require("app.scenes.crosswar.CrossWarCommon")
local CrossWarChampionItem 	= require("app.scenes.crosswar.CrossWarChampionItem")
local CrossWarBuyPanel 		= require("app.scenes.crosswar.CrossWarBuyPanel")
local CrossWarBattleScene	= require("app.scenes.crosswar.CrossWarBattleScene")
local FightEnd 				= require("app.scenes.common.fightend.FightEnd")
local BreakAwardLayer		= require("app.scenes.arena.BreakAwardLayer")

local MIN_LIST_OFFSET		= -75
local BUTTON_TAG_BET		= 1 -- 设置给押注按钮的TAG，1为押注状态，2为领奖状态
local BUTTON_TAG_BET_AWARD	= 2

function CrossWarChampionshipLayer.create(...)
	return CrossWarChampionshipLayer.new("ui_layout/crosswar_ChampionshipLayer.json", nil, ...)
end

function CrossWarChampionshipLayer:ctor(jsonFile, fun, ...)
	self._curMatchState = G_Me.crossWarData:getCurState()
	self._hasTopRanks	= false	-- 是否已拉取前N名
	self._hasCloseRanks = false	-- 是否已拉取自己排名附近的玩家
	self._listView 		= nil
	self._listLen		= 0		-- 列表元素个数
	self._listOffset	= 0		-- 当前listview的偏移值
	self._myPosInList	= 0		-- 我在列表中的位置
	self._myBgID		= 0 	-- 我的cell背景图的ID
	self._atLeft		= false	-- 我是否在左侧（默认在右侧）
	self._isFirstEnter	= true 	-- 是否第一次进入layer
	self._challengeInfo	= {} 	-- 挑战时记录下的信息（被挑战者的name, baseID, resID, 所在的listcell, newRank, oldRank）
	self._toShowBetAward= false -- 这个flag用于标示是否将要显示押注奖励（点击押注奖励按钮时标记）
	self.super.ctor(self, ...)
end

function CrossWarChampionshipLayer:onLayerLoad(...)
	self._betBtn = self:getButtonByName("Button_Bet")

	-- create strokes
	self:enableLabelStroke("Label_EndTime_Desc", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_EndTime", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_MyRank_Desc", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_ChallengeCount", Colors.strokeBrown, 1)

	-- initialize list view
	self:_initListView()

	-- initialize UI
	self:_initUI()

	-- register button events
	self:registerBtnClickEvent("Button_Back", handler(self, self.onBackKeyEvent))
	self:registerBtnClickEvent("Button_Help", handler(self, self._onClickHelp))
	self:registerBtnClickEvent("Button_Shop", handler(self, self._onClickShop))
	self:registerBtnClickEvent("Button_BuZhen", handler(self, self._onClickBuZhen))
	self:registerBtnClickEvent("Button_Award", handler(self, self._onClickAward))
	self:registerBtnClickEvent("Button_Bet", handler(self, self._onClickBet))
	self:registerBtnClickEvent("Button_Rank", handler(self, self._onClickRank))
	self:registerBtnClickEvent("Button_BuyChallenge", handler(self, self._onClickBuyChallenge))
end

function CrossWarChampionshipLayer:onLayerEnter(...)
	self:registerKeypadEvent(true, false)

	-- update UI by current state
	self:_updateMatchState()
	self:_updateChallengeNum()

	-- register event listeners
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_TOP_RANKS, self._onRcvTopRanks, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_CLOSE_RANKS, self._onRcvCloseRanks, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_CHALLENGE_CHAMPION, self._onRcvChallenge, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_BUY_CHALLENGE, self._updateChallengeNum, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_BET_INFO, self._onRcvBetInfo, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_BET_AWARD, self._updateBetAwardTip, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_FINISH_BET_AWARD, self._updateBetAwardTip, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_FINISH_SERVER_AWARD, self._updateServerAwardTip, self)

	uf_eventManager:addEventListener(CrossWarCommon.EVENT_STATE_CHANGED, self._updateMatchState, self)
	uf_eventManager:addEventListener(CrossWarCommon.EVENT_UPDATE_COUNTDOWN, self._updateCD, self)

	-- 拉取参赛选手和押注信息
	self:_pullPlayers()

	-- 如果比赛已结束，检查是否有全服奖励或者押注奖励（奖励数据原则上在外面已经拉过）
	if G_Me.crossWarData:isChampionshipEnd() then
		-- NOTE:现在暂时关闭押注功能
		--self:_updateBetAwardTip(true)
		self:_updateServerAwardTip()
	end
end

function CrossWarChampionshipLayer:onLayerExit(...)
	uf_eventManager:removeListenerWithTarget(self)
end

function CrossWarChampionshipLayer:onBackKeyEvent(...)
	uf_sceneManager:getCurScene():goToEntry()
	return true
end

function CrossWarChampionshipLayer:_onClickHelp()
	require("app.scenes.common.CommonHelpLayer").show(
		{
			{title = G_lang:get("LANG_CROSS_WAR_MODE_2"), content = G_lang:get("LANG_CROSS_WAR_HELP_CHAMPIONSHIP")},
		})
end

function CrossWarChampionshipLayer:_onClickShop()
	uf_sceneManager:pushScene(require("app.scenes.shop.score.ShopScoreScene").new(SCORE_TYPE.CROSS_WAR))
end

function CrossWarChampionshipLayer:_onClickBuZhen()
	require("app.scenes.hero.HerobuZhengLayer").showBuZhengLayer()
end

function CrossWarChampionshipLayer:_onClickAward()
	self:showServerAward()
end

function CrossWarChampionshipLayer:_onClickBet()
	-- 如果按钮状态仍然是“押注”，弹出押注界面，如果是“押注奖励”，则弹出押注奖励界面
	if self._betBtn:getTag() == BUTTON_TAG_BET then
		G_HandlersManager.crossWarHandler:sendGetBetInfo()
	else
		self:prepareToShowBetAward()
	end
end

function CrossWarChampionshipLayer:_onClickRank()
	local layer = require("app.scenes.crosswar.CrossWarChampionRankLayer").create()
	uf_sceneManager:getCurScene():addChild(layer)
end

function CrossWarChampionshipLayer:_onClickBuyChallenge()
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

function CrossWarChampionshipLayer:_initListView()
	if not self._listView then
		local panel = self:getPanelByName("Panel_ChampionList")
		panel:setSize(CCSize(display.width, display.height))

		self._listView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
		self._listView:setBouncedEnable(false)
		self._listView:setScrollSpace(75, -90)

		self._listView:setCreateCellHandler(function(list, index)
			return CrossWarChampionItem.new(self)
		end)

		self._listView:setUpdateCellHandler(function(list, index, cell)
			-- 计算这个cell是否不显示内容
			local isEmpty = function(index)
				return index == 0 or index == self._listLen - 1
			end

			-- 计算这个cell的人是否站左边
			local atLeft = function(index)
				if self._myPosInList == 0 then
					return index % 2 == 1 -- 如果我不参赛，那么奇数名次的人站左侧
				else
					if index % 2 == self._myPosInList % 2 then	-- 如果我参赛，那么跟我同奇同偶名次的人，站同侧
						return self._atLeft
					else
						return not self._atLeft
					end
				end
			end

			-- 计算这个cell所用的背景图ID
			local bgID = function(index)
				local id = (index - self._myPosInList + self._myBgID) % 6
				while id < 0 do
					id = id + 6
				end

				if id == 0 then id = 6 end
				return id
			end

			-- 参数：1 - index，2 - 此cell是否为空，3 - 角色是否站左侧, 4 - 背景图ID
			cell:update(index, isEmpty(index), atLeft(index), bgID(index))
		end)

		self._listView:setScrollEventHandler(function(list, scrollType, nBegin, nEnd)
			self._listOffset = self._listView:getCellTopLeftOffset(0)
		end)

		-- 创建后先默认刷新一遍
		self._listView:reloadWithLength(CrossWarCommon.CHAMPIONSHIP_TOP_RANKS)
	end
end

-- 初始化UI状态
function CrossWarChampionshipLayer:_initUI()
	local isQualify = G_Me.crossWarData:isQualify()
	local isInChampionship = G_Me.crossWarData:isInChampionship()
	local isChampionshipEnd = G_Me.crossWarData:isChampionshipEnd()

	-- set widgets' visibility
	self:showWidgetByName("Label_EndTime_Desc", isInChampionship)
	self:showWidgetByName("Label_EndTime", isInChampionship)
	self:showWidgetByName("Panel_Bottom", isQualify and  isInChampionship)

	-- if championship is over, change the "Bet" button to "Bet Award"
	local hasPulledBetAward = G_Me.crossWarData:hasPulledBetAward()
	self._betBtn:setTag(hasPulledBetAward and BUTTON_TAG_BET_AWARD or BUTTON_TAG_BET)
	if isChampionshipEnd and hasPulledBetAward then
		self:getImageViewByName("Image_BetText"):loadTexture(G_Path.getTextPath("kfyw_yazhujiangli.png"))
	end

	-- initialize my rank info
	local myRank    = G_Me.crossWarData:getRankInChampionship()
	local rankLabel = self:getLabelByName("Label_MyRank")

	rankLabel:setText(isQualify and tostring(myRank) or G_lang:get("LANG_CROSS_WAR_NOT_ATTEND"))
	rankLabel:setColor(isQualify and Colors.darkColors.DESCRIPTION or Colors.darkColors.TIPS_02)
	rankLabel:setFontSize(isQualify and 28 or 24)
	rankLabel:createStroke(Colors.strokeBrown, isQualify and 2 or 0)
end

-- 拉取参赛选手
function CrossWarChampionshipLayer:_pullPlayers()
	-- 如果自己也参赛了，拉取附近排名的玩家
	local isQualify = G_Me.crossWarData:isQualify()

	if isQualify and not self._hasCloseRanks then
		G_HandlersManager.crossWarHandler:sendGetCloseRanks()
	else
		self._hasCloseRanks = true
	end

	-- 拉取前几名
	if not self._hasTopRanks then
		G_HandlersManager.crossWarHandler:sendGetTopRanks()
	end
end

function CrossWarChampionshipLayer:_onRcvBetInfo()
	-- 如果请求该信息的目的是为了显示押注奖励，那么就显示押注奖励界面。。。
	-- 否则就显示押注信息的界面
	if self._toShowBetAward == true then
		self:showBetAward()
	else
		self:showBetLayer()
	end
end

function CrossWarChampionshipLayer:_onRcvTopRanks()
	self._hasTopRanks = true
	
	-- 整个参赛列表准备就绪，刷新列表
	if self._hasTopRanks and self._hasCloseRanks then
		self:_updateListView()
	end

	-- 如果此时比赛已经结束，根据最终排行榜检查是否有全服奖励
	if G_Me.crossWarData:isChampionshipEnd() then
		self:_updateServerAwardTip()
	end
end

function CrossWarChampionshipLayer:_onRcvCloseRanks()
	self._hasCloseRanks = true

	-- 整个参赛列表准备就绪，刷新列表
	if self._hasTopRanks and self._hasCloseRanks then
		self:_updateListView()
	end

	-- 刷新一下我的排名
	self:_updateRank()
end

function CrossWarChampionshipLayer:_onRcvChallenge(battleReport, awards)
	-- 记录下排名变化情况
	local oldRank = G_Me.crossWarData:getRankInChampionship()
	local newRank = battleReport.is_win and self._challengeInfo.rank or oldRank
	self._challengeInfo.isBreak = battleReport.is_win and newRank < oldRank

	-- 刷新一下剩余挑战次数
	self:_updateChallengeNum()

	-- 战斗结束后的回调
	local callback = function(result)
		local curSceneName = G_SceneObserver:getSceneName()
		if not self or curSceneName ~= "CrossWarScene" and curSceneName ~= "CrossWarBattleScene" then
        	return
        end

        -- 刷新名次
        self:_updateRank()

        -- 显示战斗结算界面
        FightEnd.show(FightEnd.TYPE_CROSSWAR, battleReport.is_win,
        			  {
        			  	crosswar_medal	= awards[1].size,
        			  	new_rank		= newRank,
        			  	old_rank		= oldRank,
        			  	opponent		= { base_id = self._challengeInfo.baseID, name = self._challengeInfo.name }
        			  },
        			  handler(self, self._fightEndCallBack), result)
	end

	-- 显示战斗场景
	G_Loading:showLoading(
		function(...)
			local opponent = 
			{
				id = 0,
				name = "",
				power = 1
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

-- 战斗结算界面消失后的回调
function CrossWarChampionshipLayer:_fightEndCallBack()
	local curSceneName = G_SceneObserver:getSceneName()
    if not self or curSceneName ~= "CrossWarScene" and curSceneName ~= "CrossWarBattleScene" then
		return
    end

    -- 移除战斗界面
	uf_sceneManager:popScene()

	-- 如果排名有突破，则弹出排名突破框
	if self._challengeInfo.isBreak then
		--local layer = BreakAwardLayer.create(self._challengeInfo.newRank, self._challengeInfo.oldRank, 0, handler(self, self._kickOutLoser))
		--uf_notifyLayer:getModelNode():addChild(layer)
		self:_kickOutLoser()
	end
end

-- 播放排名突破的踢人效果
function CrossWarChampionshipLayer:_kickOutLoser()
	self._listView:setScrollEnabled(false)

	-- 先交换我和败者的信息
	local myCell  = self._listView:getCellByIndex(self._myPosInList )
	local hisCell = self._listView:getCellByIndex(self._challengeInfo.index)
	local myInfo  = G_Me.crossWarData:getUserInChampionList(self._myPosInList)
	local hisInfo = G_Me.crossWarData:getUserInChampionList(self._challengeInfo.index)

	if myCell and hisInfo then
		myCell:updateContent(hisInfo)
	end

	if hisCell and myInfo then
		hisCell:updateContent(myInfo)
	end

	-- 保存我的新方向,和新的背景图ID
	self._atLeft = self._challengeInfo.isLeft
	self._myBgID = self._challengeInfo.bgID

	-- 踢人动画播完之后的回调（将列表滑到新位置）
	local callback = function()
		self._listOffset = self:_calcListOffset(self._challengeInfo.index)
		local moveTime = self._listOffset <= MIN_LIST_OFFSET and 0.01 or 0.15
		self._listView:scrollToTopLeftCellIndex(0, self._listOffset, moveTime, function() end)

		--滑动结束后，重新拉取参赛列表
		uf_funcCallHelper:callAfterDelayTime(moveTime, nil, function()
				self._hasTopRanks = false
				self._hasCloseRanks = false
				self:_pullPlayers()
			end, nil)
	end

	-- 播放踢人的动画
	if self._challengeInfo and self._challengeInfo.cell then
		local hisResID = G_Me.dressData:getDressedResidWithClidAndCltm(hisInfo.main_role, hisInfo.dress_id,
			rawget(hisInfo,"clid"),rawget(hisInfo,"cltm"),rawget(hisInfo,"clop"))
		local myResID  = G_Me.dressData:getDressedResidWithClidAndCltm(myInfo.main_role, myInfo.dress_id,
			rawget(myInfo,"clid"),rawget(myInfo,"cltm"),rawget(myInfo,"clop"))
		self._challengeInfo.cell:playKickEffect(hisResID, myResID, callback)
	end
end

-- 计算列表偏移
function CrossWarChampionshipLayer:_calcListOffset(targetIndex)
	return -560 + 190 * targetIndex
end

-- 刷新一下参赛者列表
function CrossWarChampionshipLayer:_updateListView()
	-- 玩家是否有参赛资格
	local crossData = G_Me.crossWarData
	local isQualify = crossData:isQualify()
	local isInChampionship = crossData:isInChampionship()
	local isChampionshipEnd = crossData:isChampionshipEnd()
	local myRank = crossData:getRankInChampionship()

	-- 计算我在列表中的位置
	if isQualify then
		self._myPosInList = crossData:getMyPosInRanks()
	
		-- 比赛结束，如果我不在前十，就不要显示我
		if isChampionshipEnd and myRank > CrossWarCommon.CHAMPIONSHIP_TOP_RANKS then
			self._myPosInList = 0
		end
	else
		self._myPosInList = 0
	end

	-- reload列表, + 2是为了最前和最后预留两个空位
	self._listLen = math.min(CrossWarCommon.CHAMPIONSHIP_TOP_RANKS, crossData:getTopRankNum()) + 2
	if isQualify and isInChampionship then
		self._listLen = self._listLen + crossData:getCloseRankNum()
	end

	self._listView:reloadWithLength(self._listLen)

	-- 让listview滑到正好显示我的位置(未参赛则滑到顶部）
	self._listOffset = isQualify and self:_calcListOffset(self._myPosInList) or MIN_LIST_OFFSET
	self._listView:scrollToTopLeftCellIndex(0, self._listOffset, 0, function() end)

	-- 允许滑动
	self._listView:setScrollEnabled(true)

	-- isFirstEnter置为false
	self._isFirstEnter = false
end

-- 刷新名次
function CrossWarChampionshipLayer:_updateRank()
	self:showTextWithLabel("Label_MyRank", G_Me.crossWarData:getRankInChampionship())
end

-- 刷新押注按钮的提示状态
-- @参数 info_ok 为true时表示押注奖励已经成功拉取到， false时什么也不做
function CrossWarChampionshipLayer:_updateBetAwardTip(info_ok)
	if info_ok ~= false then
		-- 把“押注”换成“押注奖励”
		local betTag = self._betBtn:getTag()
		if betTag == BUTTON_TAG_BET then
			self:getImageViewByName("Image_BetText"):loadTexture(G_Path.getTextPath("kfyw_yazhujiangli.png"))
			self._betBtn:setTag(BUTTON_TAG_BET_AWARD)
		end

		-- 检查是否需要显示小红点
		local canGetBetAward = G_Me.crossWarData:checkCanGetBetAward()
		self:showWidgetByName("Image_RedTip_BetAward", canGetBetAward)
	end
end

-- 刷新全服奖励按钮的提示状态
function CrossWarChampionshipLayer:_updateServerAwardTip()
	local canGetServerAward = G_Me.crossWarData:checkCanGetServerAward()
	self:showWidgetByName("Image_RedTip_ServerAward", canGetServerAward)
end

-- 刷新一下挑战次数
function CrossWarChampionshipLayer:_updateChallengeNum()
	local num_ = G_Me.crossWarData:getChallengeCount()
	local text = G_lang:get("LANG_DUNGEON_TODAYCHALLENGE", {num = num_})
	self:showTextWithLabel("Label_ChallengeCount", text)
end

function CrossWarChampionshipLayer:_updateMatchState()
	local newState = G_Me.crossWarData:getCurState()

	-- 状态没变，什么也不做
	if newState == self._curMatchState then
		return
	end

	if self._curMatchState == CrossWarCommon.STATE_IN_CHAMPIONSHIP and newState == CrossWarCommon.STATE_AFTER_CHAMPIONSHIP then
		-- 从比赛中转为比赛结束
		self:showWidgetByName("Label_EndTime_Desc", false)
		self:showWidgetByName("Label_EndTime", false)
		self:showWidgetByName("Panel_Bottom", false)

	elseif newState < self._curMatchState then
		-- 从比赛结束转为新一轮比赛开始，强制踢回入口界面
		uf_sceneManager:replaceScene(require("app.scenes.crosswar.CrossWarScene").new())
		return
	end

	-- 记住新的state
	self._curMatchState = newState
end

function CrossWarChampionshipLayer:_updateCD(strCD)
	self:showTextWithLabel("Label_EndTime", strCD)
end

function CrossWarChampionshipLayer:setChallengeInfo(index_, rank_, name_, baseID_, resID_, isLeft_, bgID_, cell_)
	self._challengeInfo = {index = index_, rank = rank_, name = name_, baseID = baseID_, resID = resID_, isLeft = isLeft_, bgID = bgID_, cell = cell_ }
end

function CrossWarChampionshipLayer:canClickListItem()
	return self._listView:isScrollEnabled()
end

function CrossWarChampionshipLayer:prepareToShowBetAward()
	-- 标示一下，说明接着要显示押注奖励的界面
	self._toShowBetAward = true

	-- 在显示押注奖励时，需要BetInfo协议中的信息
	-- 如果此时还没有拉取，则先去请求(在这接口中会判断需不需要拉取)
	G_HandlersManager.crossWarHandler:sendGetBetInfo()
end

function CrossWarChampionshipLayer:showBetAward()
	local layer = require("app.scenes.crosswar.CrossWarBetAwardLayer").create()
	uf_sceneManager:getCurScene():addChild(layer)

	-- 押注奖励界面已显示，取消标示
	self._toShowBetAward = false
end

function CrossWarChampionshipLayer:showServerAward()
	local layer = require("app.scenes.crosswar.CrossWarServerAwardLayer").create()
	uf_sceneManager:getCurScene():addChild(layer)
end

function CrossWarChampionshipLayer:showBetLayer()
	layer = require("app.scenes.crosswar.CrossWarBetLayer").create()
	uf_sceneManager:getCurScene():addChild(layer)
end

return CrossWarChampionshipLayer