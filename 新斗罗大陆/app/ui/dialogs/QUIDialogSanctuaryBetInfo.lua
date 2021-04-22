--
-- zxs
-- 精英赛下注
--

local QUIDialog = import(".QUIDialog")
local QUIDialogSanctuaryBetInfo = class("QUIDialogSanctuaryBetInfo", QUIDialog)
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIViewController = import("...ui.QUIViewController")
local QReplayUtil = import("...utils.QReplayUtil")

--初始化
function QUIDialogSanctuaryBetInfo:ctor(options)
    local ccbFile = "ccb/Dialog_Sanctuary_bet.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerClick1", callback = handler(self, self._onTriggerClick1)},
        {ccbCallbackName = "onTriggerClick2", callback = handler(self, self._onTriggerClick2)},
        {ccbCallbackName = "onTriggerClick3", callback = handler(self, self._onTriggerClick3)},
        {ccbCallbackName = "onTriggerClick4", callback = handler(self, self._onTriggerClick4)},
        {ccbCallbackName = "onSub", callback = handler(self, self._onSub)},
		{ccbCallbackName = "onPlus", callback = handler(self, self._onPlus)},
		{ccbCallbackName = "onSubTen", callback = handler(self, self._onSubTen)},
		{ccbCallbackName = "onPlusTen", callback = handler(self, self._onPlusTen)},
		{ccbCallbackName = "onSubHundred", callback = handler(self, self._onSubHundred)},
		{ccbCallbackName = "onPlusHundred", callback = handler(self, self._onPlusHundred)},
		{ccbCallbackName = "onTriggerBet", callback = handler(self, self._onTriggerBet)},
		{ccbCallbackName = "onTriggerVisit", callback = handler(self, self._onTriggerVisit)},
		{ccbCallbackName = "onTriggerVisit1", callback = handler(self, self._onTriggerVisit1)},
        {ccbCallbackName = "onTriggerVisit2", callback = handler(self, self._onTriggerVisit2)}, 
	}
	QUIDialogSanctuaryBetInfo.super.ctor(self,ccbFile,callBacks,options)
    self.isAnimation = true --是否动画显示

    self._nums = 0				-- 押注数量
    self._selectNum = 0			-- 选择类型
    self._maxNum = 0			-- 最大押注数量
	self._canChange = true
	
	self._player1 = options.player1
	self._player2 = options.player2

	self._ccbOwner.frame_tf_title:setString("押 注")
	q.setButtonEnableShadow(self._ccbOwner.btn_bet)
	q.setButtonEnableShadow(self._ccbOwner.btn_plus1)
	q.setButtonEnableShadow(self._ccbOwner.btn_plus10)
	q.setButtonEnableShadow(self._ccbOwner.btn_plus100)
	q.setButtonEnableShadow(self._ccbOwner.btn_sub1)
	q.setButtonEnableShadow(self._ccbOwner.btn_sub10)
	q.setButtonEnableShadow(self._ccbOwner.btn_sub100)
	q.setButtonEnableShadow(self._ccbOwner.btn_look_zr)
end

function QUIDialogSanctuaryBetInfo:viewDidAppear()
	QUIDialogSanctuaryBetInfo.super.viewDidAppear(self)

	self._sanctuaryProxy = cc.EventProxy.new(remote.sanctuary)
	self._sanctuaryProxy:addEventListener(remote.sanctuary.EVENT_SANCTUARY_MY_UPDATE, handler(self, self._updateMyInfoHandler))

	self:updateInfo()
end

function QUIDialogSanctuaryBetInfo:viewWillDisappear()
	QUIDialogSanctuaryBetInfo.super.viewWillDisappear(self)
	
	if self._sanctuaryProxy ~= nil then
		self._sanctuaryProxy:removeAllEventListeners()
		self._sanctuaryProxy = nil
	end

	if self._calculatorScheduler then
		scheduler.unscheduleGlobal(self._calculatorScheduler)
		self._calculatorScheduler = nil
	end
end

function QUIDialogSanctuaryBetInfo:_updateMyInfoHandler(event)
	self:updateInfo()
end

function QUIDialogSanctuaryBetInfo:resetAll()
	for i = 1, 4 do
		self._ccbOwner["tf_jackpot_"..i]:setString(0)
		self._ccbOwner["tf_ratio_"..i]:setString("0%")
		self._ccbOwner["tf_num_"..i]:setString("0人")
	end
	self._nums = 0
	self._ccbOwner.tf_item_num:setString(self._nums)
end

function QUIDialogSanctuaryBetInfo:updateInfo()
	self:resetAll()
	self._fighter1 = self._player1.fighter
    self._fighter2 = self._player2.fighter

    local state = remote.sanctuary:getState()
	if state == remote.sanctuary.STATE_BETS_8 or state == remote.sanctuary.STATE_KNOCKOUT_8 then
    	self._maxNum = db:getConfiguration()["sanctuary_war_bet_max_8"].value
	elseif state == remote.sanctuary.STATE_BETS_4 or state == remote.sanctuary.STATE_KNOCKOUT_4 then
    	self._maxNum = db:getConfiguration()["sanctuary_war_bet_max_4"].value
	elseif (state == remote.sanctuary.STATE_BETS_2 or state == remote.sanctuary.STATE_FINAL) and self._player1.currRound == remote.sanctuary.ROUND_4 then
    	self._maxNum = db:getConfiguration()["sanctuary_war_bet_max_3"].value
	elseif (state == remote.sanctuary.STATE_BETS_2 or state == remote.sanctuary.STATE_FINAL) and self._player1.currRound == remote.sanctuary.ROUND_2 then
    	self._maxNum = db:getConfiguration()["sanctuary_war_bet_max_2"].value
	end
	local limitStr = string.format("押注上限：%d（预期收益为动态收益，实际奖励以押注时间截止后的收益为准）", self._maxNum)
	self._ccbOwner.tf_bet_limit:setString(limitStr)

	self:updatePlayer()
	self:updateSelect()

	self._canChange = true
	self._betInfo = remote.sanctuary:getBetInfoById(self._fighter1.userId, self._fighter2.userId)
	if not self._betInfo then
		self._ccbOwner.node_bet:setVisible(true)
		self._ccbOwner.node_bet_end:setVisible(false)
		return
	end

	if not self._betInfo.myScoreId or self._betInfo.myScoreId == 0 then
		self._ccbOwner.node_bet:setVisible(true)
		self._ccbOwner.node_bet_end:setVisible(false)
	else
		self._canChange = false
		self._ccbOwner.node_bet:setVisible(false)
		self._ccbOwner.node_bet_end:setVisible(true)
		self._selectNum = self._betInfo.myScoreId
		self._nums = self._betInfo.myBetAward
		self:updateSelect()

		makeNodeFromNormalToGray(self._ccbOwner.node_btn)
		self._ccbOwner.btn_plus1:setEnabled(false)
		self._ccbOwner.btn_plus10:setEnabled(false)
		self._ccbOwner.btn_plus100:setEnabled(false)
		self._ccbOwner.btn_sub1:setEnabled(false)
		self._ccbOwner.btn_sub10:setEnabled(false)
		self._ccbOwner.btn_sub100:setEnabled(false)

		self._ccbOwner.tf_sub10_1:disableOutline()
		self._ccbOwner.tf_sub10_2:disableOutline()
		self._ccbOwner.tf_sub100_1:disableOutline()
		self._ccbOwner.tf_sub100_2:disableOutline()
		self._ccbOwner.tf_plus10_1:disableOutline()
		self._ccbOwner.tf_plus10_2:disableOutline()
		self._ccbOwner.tf_plus100_1:disableOutline()
		self._ccbOwner.tf_plus100_2:disableOutline()
	end

	local scoreInfos = self._betInfo.scoreDetailInfos or {}
	local totalMoney = 0
	for i, scoreInfo in pairs(scoreInfos) do
		totalMoney = totalMoney + scoreInfo.totalMoney
	end
	for i, scoreInfo in pairs(scoreInfos) do
		local index = scoreInfo.scoreId
		local ratio = 0
		if totalMoney > 0 then
			ratio = scoreInfo.totalMoney/totalMoney*100
		end
		local ratioStr = string.format("%.1f%%", ratio)
		local num,unit = q.convertLargerNumber(scoreInfo.totalMoney or 0)
		self._ccbOwner["tf_jackpot_"..index]:setString(num..unit)
		self._ccbOwner["tf_ratio_"..index]:setString(ratioStr)
		self._ccbOwner["tf_num_"..index]:setString((scoreInfo.totalNum or 0).."人")
	end

	self:updateNums()
end

function QUIDialogSanctuaryBetInfo:updateGetNum()
	local betInfo = self._betInfo or {}
	local myBetNum = betInfo.myBetAward or 0	-- 已经押注
	local addNum = 0							-- 将要押注
	if self._canChange then
		addNum = self._nums
		myBetNum = addNum
	end

	local scoreInfos = betInfo.scoreDetailInfos or {}
	local totalMoney = addNum
	local cellMoney = addNum
	for i, scoreInfo in pairs(scoreInfos) do
		totalMoney = totalMoney + scoreInfo.totalMoney
		if self._selectNum == scoreInfo.scoreId then
			cellMoney = cellMoney + scoreInfo.totalMoney
		end
	end
	if cellMoney <= 0 then
		cellMoney = 1
	end
	
	local canGetNum = 0
	if self._selectNum > 0 then
		canGetNum = math.ceil(myBetNum/cellMoney*totalMoney)
		canGetNum = canGetNum - myBetNum
		if canGetNum > myBetNum*10 then
			canGetNum = myBetNum*10
		end
		if canGetNum < myBetNum then
			canGetNum = myBetNum
		end
	end

	local preStr = string.format("预期收益：%d", canGetNum)
	self._ccbOwner.tf_pre_get:setString(preStr)
end

function QUIDialogSanctuaryBetInfo:updatePlayer()
	local force1 = self._fighter1.force or 0
	local num,unit = q.convertLargerNumber(force1)
	self._ccbOwner.tf_force1:setString(num..unit)
	local str = "LV."..self._fighter1.level.." "..self._fighter1.name
	self._ccbOwner.tf_name1:setString(str)
	local avatar = QUIWidgetAvatar.new(self._fighter1.avatar)
	avatar:setSilvesArenaPeak(self._fighter1.championCount)
    self._ccbOwner.node_head1:addChild(avatar)

	local force2 = self._fighter2.force or 0
	local num,unit = q.convertLargerNumber(force2)
	self._ccbOwner.tf_force2:setString(num..unit)
	local str = "LV."..self._fighter2.level.." "..self._fighter2.name
	self._ccbOwner.tf_name2:setString(str)
	local avatar = QUIWidgetAvatar.new(self._fighter2.avatar)
	avatar:setSilvesArenaPeak(self._fighter2.championCount)
	avatar:setScaleX(-1)
    self._ccbOwner.node_head2:addChild(avatar)
end

function QUIDialogSanctuaryBetInfo:updateSelect()
	for i = 1, 4 do
		self._ccbOwner["sp_select_"..i]:setVisible(self._selectNum == i)
	end
	self:updateGetNum()
end

function QUIDialogSanctuaryBetInfo:updateNums()
	self._ccbOwner.tf_item_num:setString(self._nums)
	self:updateGetNum()
end

function QUIDialogSanctuaryBetInfo:_onUpHandler(num)
	self._isDown = false	
	self._isUp = true
	self:_subBuyNums(num)
end

function QUIDialogSanctuaryBetInfo:_onDownHandler(num)
	self._isDown = true
	self._isUp = false
	self._calculatorScheduler = scheduler.performWithDelayGlobal(function()
			self:_subBuyNums(num)
		end, 0.5)
end

function QUIDialogSanctuaryBetInfo:_subBuyNums(num)
	if self._calculatorScheduler then
		scheduler.unscheduleGlobal(self._calculatorScheduler)
		self._calculatorScheduler = nil
	end

	if self._isDown or self._isUp then
		if self._nums + num <= 0 then 
			self._nums = 1
		elseif self._nums + num > self._maxNum then 
			self._nums = self._maxNum
		elseif self._nums == 1 and num == 10 then
			self._nums = 10
		elseif self._nums == 1 and num == 100 then
			self._nums = 100
		else
			self._nums = self._nums + num
		end
		self:updateNums()

		-- 点击一次
		if self._isUp then
			return
		end

		self._calculatorScheduler = scheduler.performWithDelayGlobal(function()
			self:_subBuyNums(num)
		end, 0.05)
	end
end

function QUIDialogSanctuaryBetInfo:_onSub()
	app.sound:playSound("common_increase")

	if self._nums - 1 <= 0 then 
		self._nums = 1
	else
		self._nums = self._nums - 1
	end
	self:updateNums()
end

function QUIDialogSanctuaryBetInfo:_onPlus()
	app.sound:playSound("common_increase")

	if self._nums + 1 > self._maxNum then 
		self._nums = self._maxNum
	else
		self._nums = self._nums + 1
	end
	self:updateNums()
end

function QUIDialogSanctuaryBetInfo:_onSubTen(event)
	if tonumber(event) == CCControlEventTouchDown then
		self:_onDownHandler(-10)
	else
		app.sound:playSound("common_increase")
		self:_onUpHandler(-10)
	end
end

function QUIDialogSanctuaryBetInfo:_onPlusTen(event)
	if tonumber(event) == CCControlEventTouchDown then
		self:_onDownHandler(10)
	else
		app.sound:playSound("common_increase")
		self:_onUpHandler(10)
	end
end

function QUIDialogSanctuaryBetInfo:_onSubHundred(event)
	if tonumber(event) == CCControlEventTouchDown then
		self:_onDownHandler(-100)
	else
		app.sound:playSound("common_increase")
		self:_onUpHandler(-100)
	end
end

function QUIDialogSanctuaryBetInfo:_onPlusHundred(event)
	if tonumber(event) == CCControlEventTouchDown then
		self:_onDownHandler(100)
	else
		app.sound:playSound("common_increase")
		self:_onUpHandler(100)
	end
end

function QUIDialogSanctuaryBetInfo:_onTriggerClick1()
    app.sound:playSound("common_cancel")
    if self._canChange == false then
    	return
    end

    self._selectNum = 1
    self:updateSelect()
end

function QUIDialogSanctuaryBetInfo:_onTriggerClick2()
    app.sound:playSound("common_cancel")
    if self._canChange == false then
    	return
    end
    self._selectNum = 2
    self:updateSelect()
end

function QUIDialogSanctuaryBetInfo:_onTriggerClick3()
    app.sound:playSound("common_cancel")
    if self._canChange == false then
    	return
    end
    self._selectNum = 3
    self:updateSelect()
end

function QUIDialogSanctuaryBetInfo:_onTriggerClick4()
    app.sound:playSound("common_cancel")
    if self._canChange == false then
    	return
    end
    self._selectNum = 4
    self:updateSelect()
end

function QUIDialogSanctuaryBetInfo:_onTriggerBet()
	app.sound:playSound("common_confirm")
	if self._selectNum == 0 then 
		app.tip:floatTip("未选择押注比分")
		return
	end
	if self._nums == 0 then 
		app.tip:floatTip("购买数量不能为0")
		return
	end

	local betInfo = remote.sanctuary:getBetInfoById(self._fighter1.userId, self._fighter2.userId)
	if betInfo and betInfo.myScoreId and betInfo.myScoreId ~= 0 then 
		app.tip:floatTip("魂师大人，本次比赛您已经押过注了~")
		return
	end

	local state = remote.sanctuary:getState()
	if state == remote.sanctuary.STATE_BETS_8 or state == remote.sanctuary.STATE_BETS_4 or state == remote.sanctuary.STATE_BETS_2 then
		remote.sanctuary:sanctuaryWarBetRequest(self._fighter1.userId, self._fighter2.userId, self._selectNum, self._nums, function()
				app.tip:floatTip("押注成功~")
			end)
	else
		app.tip:floatTip("押注时间已过~")
		self:playEffectOut()
	end
end

-- 查询阵容对比
function QUIDialogSanctuaryBetInfo:_onTriggerVisit()
    app.sound:playSound("common_small")
	if not self._fighter1 or not self._fighter2 then
		return
	end
	local userId1 = self._fighter1.userId
	local userId2 = self._fighter2.userId
	remote.sanctuary:sanctuaryWarQueryFighterRequest(userId1, function(data)
		if data.sanctuaryWarQueryFighterResponse ~= nil and data.sanctuaryWarQueryFighterResponse.fighter ~= nil then
			local fighter1 = data.sanctuaryWarQueryFighterResponse.fighter
			remote.sanctuary:sanctuaryWarQueryFighterRequest(userId2, function(data)
				if data.sanctuaryWarQueryFighterResponse ~= nil and data.sanctuaryWarQueryFighterResponse.fighter ~= nil then
					local fighter2 = data.sanctuaryWarQueryFighterResponse.fighter
					app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTeamInfoCompare",
		    			options = {fighter1 = fighter1, fighter2 = fighter2}}, {isPopCurrentDialog = false})
				end
			end)
		end
	end)
end

function QUIDialogSanctuaryBetInfo:_onTriggerVisit1()
    app.sound:playSound("common_small")
	if not self._fighter1 then
		return
	end
	remote.sanctuary:sanctuaryWarQueryFighterRequest(self._fighter1.userId, function(data)
		if data.sanctuaryWarQueryFighterResponse ~= nil and data.sanctuaryWarQueryFighterResponse.fighter ~= nil then
			local fighterInfo = data.sanctuaryWarQueryFighterResponse.fighter
			--QReplayUtil:_createReplayFighterFromFighterInfo(fighterInfo, 1)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogStromArenaPlayerInfo",
		    	options = {fighterInfo = fighterInfo, specialTitle1 = "当前积分：", specialValue1 = fighterInfo.sanctuaryWarScore or 0, isPVP = true}}, {isPopCurrentDialog = false})
		end
	end)
end

function QUIDialogSanctuaryBetInfo:_onTriggerVisit2()
    app.sound:playSound("common_small")
	if not self._fighter2 then
		return
	end
	remote.sanctuary:sanctuaryWarQueryFighterRequest(self._fighter2.userId, function(data)
		if data.sanctuaryWarQueryFighterResponse ~= nil and data.sanctuaryWarQueryFighterResponse.fighter ~= nil then
			local fighterInfo = data.sanctuaryWarQueryFighterResponse.fighter
			--QReplayUtil:_createReplayFighterFromFighterInfo(fighterInfo, 2)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogStromArenaPlayerInfo",
		    	options = {fighterInfo = fighterInfo, specialTitle1 = "当前积分：", specialValue1 = fighterInfo.sanctuaryWarScore or 0, isPVP = true}}, {isPopCurrentDialog = false})
		end
	end)
end

function QUIDialogSanctuaryBetInfo:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
    app.sound:playSound("common_cancel")
    self:playEffectOut()
end

return QUIDialogSanctuaryBetInfo
