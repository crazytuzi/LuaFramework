--
-- Author: nieming
-- Date: 2016-10-09 20:39:10
--
local QBattleDialog = import("...QBattleDialog")
local QBattleDialogWaveEnd = class("QBattleDialogWaveEnd", QBattleDialog)

local QUIWidgetHeroHead = import("....widgets.QUIWidgetHeroHead")
local QBattleDialogFightEndRecord = import(".....ui.battle.QBattleDialogFightEndRecord")
local QUIWidgetItemsBox = import("....widgets.QUIWidgetItemsBox")
local QUIWidgetAnimationPlayer = import("....widgets.QUIWidgetAnimationPlayer")
local QUIWidgetAvatar = import("....widgets.QUIWidgetAvatar")
local QStaticDatabase = import(".....controllers.QStaticDatabase")
local QPVPMultipleFightInfo = import(".....ui.battle.QPVPMultipleFightInfo")
local QUIWidgetTitelEffect = import("....widgets.QUIWidgetTitelEffect")

function QBattleDialogWaveEnd:ctor(options,owner)
	local ccbFile = "ccb/Dialog_StormArena_fightwin.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerNext", callback = handler(self, QBattleDialogWaveEnd._onTriggerNext)},
		{ccbCallbackName = "onTriggerData", callback = handler(self, QBattleDialogWaveEnd._onTriggerData)},
		{ccbCallbackName = "onTriggerDetail", callback = handler(self, QBattleDialogWaveEnd._onTriggerDetail)},
	}
	if owner == nil then 
		owner = {}
	end

	local titleWidget = QUIWidgetTitelEffect.new()
	
	self:setNodeEventEnabled(true)
	QBattleDialogWaveEnd.super.ctor(self,ccbFile,owner,callBacks)
	self._ccbOwner.node_title_effect:addChild(titleWidget)

    CalculateUIBgSize(self._ccbOwner.ly_bg)
	
	if self._ccbOwner.node_star ~= nil then
		self._ccbOwner.node_star:setVisible(false)
	end
	self._ccbOwner.node_title_win:setVisible(options.isWin)
	self._ccbOwner.node_title_lose:setVisible(not options.isWin)
	self._ccbOwner.node_detail:setVisible(false)

	self._isWin = options.isWin
	self.info = options.info
	self._scoreList = self.info.scoreList
	self._replayInfo = self.info.replayInfo

 --   	local spriteFrame = QSpriteFrameByKey("storm_arena_num", self.info.team1Score + 1)
 --    if spriteFrame then
	-- 	self._ccbOwner.firstnumber:setDisplayFrame(spriteFrame)
	-- end

	self._ccbOwner.firstnumber:setString(self.info.team1Score)
	self._ccbOwner.secondnumber:setString(self.info.team2Score)
	-- spriteFrame = QSpriteFrameByKey("storm_arena_num", self.info.team2Score + 1)
 --    if spriteFrame then
	-- 	self._ccbOwner.secondnumber:setDisplayFrame(spriteFrame)
	-- end
	
	self._ccbOwner.team1Name:setString(self.info.team1Name or "")
	self._ccbOwner.team2Name:setString(self.info.team2Name or "")

	local team1avatar = QUIWidgetAvatar.new(self.info.team1avatar)
	local team2avatar = QUIWidgetAvatar.new(self.info.team2avatar)
    self._ccbOwner.team1Head:addChild(team1avatar)
    self._ccbOwner.team2Head:addChild(team2avatar)
    if self.info.isTotemChallenge then
    	
    end
	self._ccbOwner.sp_fight_end:setVisible(false)
	if self.info.isMockBattle then
		self._ccbOwner.tf_mockbattle:setVisible(true)
		if not self._isWin then
			self._ccbOwner.sp_fight_end:setVisible(true)
			self._ccbOwner.sp_fight_prize:setVisible(false)
			self._ccbOwner.tf_mockbattle:setVisible(false)
			self._ccbOwner.node_lose:setVisible(true)
			local lose_num = remote.mockbattle:getMockBattleRoundInfo().loseCount or 0
			for i=1,5 do
				local lose = i <= lose_num
				self._ccbOwner["sp_lose_n"..i]:setVisible(not lose)
				self._ccbOwner["sp_lose_y"..i]:setVisible(lose)
			end
		end
    end
	
    if self.info.addScore then
    	if self.info.isSanctuary then
    		self._ccbOwner.tf_score:setString("积分：+"..self.info.addScore)
    	elseif self.info.isConsortiaWar then
    		self._ccbOwner.tf_score:setString("摧毁旗帜："..self.info.addScore.."面")
    	end
    	self._ccbOwner.tf_score:setVisible(true)
    end

    self.rankInfo = {}
	if options.rankInfo ~= nil then
	   self.rankInfo = options.rankInfo
	end
	
 	self._itemsBox = {}
	local awards = {}
	if options.rankInfo and type(options.rankInfo.extraExpItem) == "table" then
		for _, value in pairs(options.rankInfo.extraExpItem) do
			table.insert(awards, {id = value.id or 0, type = value.type, count = value.count or 0})
		end
	end

	local yield = 1
	local activityYield
	if self.info.isStormArena then
		table.insert(awards,{type = ITEM_TYPE.MARITIME_MONEY, count = self.info.maritimeMoney})
		if self.rankInfo.stormFightEndResponse then
			yield = self.rankInfo.stormFightEndResponse.yield or 1
			activityYield = remote.activity:getActivityMultipleYield()
		end
	elseif self.info.isMaritime and self.rankInfo.gfEndResponse.maritimeFightEndResponse then
		local rewards = self.rankInfo.gfEndResponse.maritimeFightEndResponse.lootRewards or ""
		awards = remote.items:analysisServerItem(rewards, awards)
		yield = self.rankInfo.gfEndResponse.maritimeFightEndResponse.yield or 1
		activityYield = remote.activity:getActivityMultipleYield()
	elseif self.info.isSanctuary or self.info.isConsortiaWar or self.info.isTotemChallenge or self.info.isMockBattle then
		local rewardTbl = {}
		remote.items:analysisServerItem(self.info.reward or "", rewardTbl)
		for i, value in pairs(rewardTbl) do
			table.insert(awards, {id = value.id or 0, type = value.typeName, count = value.count or 0})
		end
	end

	local itemCount = 0
	for index,value in ipairs(awards) do
    	self._itemsBox[index] = QUIWidgetItemsBox.new()
    	self._itemsBox[index]:setPromptIsOpen(true)
		self._ccbOwner.node_item1:addChild(self._itemsBox[index])
		self._itemsBox[index]:setPositionX((index-1) * 100)
		itemCount = math.ceil((value.count or 0) / yield)
		self._itemsBox[index]:setGoodsInfo(value.id, value.type or value.typeName, itemCount)
		if value.type == "token" and self.info.isMockBattle then
			self._itemsBox[index]:setFirstAward(true)
		end
		if self.info.activityYield and self.info.activityYield > 1 and value.type == ITEM_TYPE.MARITIME_MONEY then
			self._itemsBox[index]:setRateActivityState(true, self.info.activityYield)
		end
	end

	local awardsNum = #awards
	if awardsNum < 5 and awardsNum > 0 then
		self._ccbOwner.node_item:setPositionX(-(awardsNum - 1) * 50)
	end


	-- centerAlignBattleDialogVictory2(self._ccbOwner, nil, nil, self._itemsBox, awardsNum)

	if yield ~= nil and yield > 1 and self._ccbOwner["node_item"..#self._itemsBox] ~= nil then
		self._yieldScheduler = scheduler.performWithDelayGlobal(function()
			self:setYieldInfo(yield, itemCount)
		end, 1)
	end

	if options.isWin == true and options.rivalId and options.isFriend ~= true then
		remote.stormArena:setTopRankUpdate(self.rankInfo, options.rivalId)
	else
		remote.stormArena:stormArenaRefresh(self.rankInfo)
	end
  	
  	if options.isWin then
		self._audioHandler = app.sound:playSound("battle_complete")
	else
		self._audioHandler = app.sound:playSound("battle_failed")
	end
    audio.stopBackgroundMusic()
	
	self._openTime = q.time()
end

function QBattleDialogWaveEnd:onEnter()
    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)
end

function QBattleDialogWaveEnd:onExit()
   	if self.prompt ~= nil then
   		self.prompt:removeItemEventListener()
   	end
    if self._yieldScheduler ~= nil then
    	scheduler.unscheduleGlobal(self._yieldScheduler)
    	self._yieldScheduler = nil
    end
end

-- ÏÔÊ¾»õ±Ò±©»÷ÌØÐ§
function QBattleDialogWaveEnd:setYieldInfo(yield, itemCount)
	local yieldLevel = QStaticDatabase:sharedDatabase():getYieldLevelByYieldData(yield, "arena_money_crit")

	self._yieldAnimation = QUIWidgetAnimationPlayer.new()
	self._ccbOwner["node_item"..#self._itemsBox]:addChild(self._yieldAnimation)
	self._yieldAnimation:setPosition(ccp(120, -35))
	self._yieldAnimation:playAnimation("ccb/effects/baoji_shuzi.ccbi", function(ccbOwner)
			for i = 1, 3, 1 do
				ccbOwner["sp_crit"..i]:setVisible(false)
			end
			ccbOwner["sp_crit"..yieldLevel]:setVisible(true)
			ccbOwner["tf_crit"..yieldLevel]:setString(yield)
		end, function()
			self._itemsBox[#self._itemsBox]:_scrollItemNum(itemCount, itemCount*yield)
		end, false)
end

function QBattleDialogWaveEnd:setItemBoxShakeEffect(node)
	local time = 0.032
	local ccArray = CCArray:create()
	ccArray:addObject(CCScaleTo:create(time, 0.96))
	ccArray:addObject(CCScaleTo:create(time, 1))
	node:runAction(CCSequence:create(ccArray))
end

function QBattleDialogWaveEnd:_onTriggerNext(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_next) == false then return end
  	app.sound:playSound("common_item")
	self:onClose()
end

function QBattleDialogWaveEnd:_backClickHandler()
	if q.time() - self._openTime > 3.5 then
		self._ccbOwner:onChoose()
  	end
end

function QBattleDialogWaveEnd:onClose()
	self._ccbOwner:onChoose()
	audio.stopSound(self._audioHandler)
end

function QBattleDialogWaveEnd:_onTriggerData(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_data) == false then return end
    app.sound:playSound("common_small")
    QBattleDialogFightEndRecord.new() 
end

function QBattleDialogWaveEnd:_onTriggerDetail(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_detail) == false then return end
    app.sound:playSound("common_small")

    QPVPMultipleFightInfo.new(
    			{
	    			info = {
	    				name = self.info.team2Name, avatar = self.info.team2avatar, attackScore = self.info.team1Score, 
	    				defenseScore = self.info.team2Score, scoreList = self._scoreList, result = self._isWin, replayInfo = self._replayInfo,
	    			},
	    			replayType = REPORT_TYPE.STORM_ARENA,
    			})
end

return QBattleDialogWaveEnd