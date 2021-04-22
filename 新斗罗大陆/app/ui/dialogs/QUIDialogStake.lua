-- 
-- Kumo.Wang
-- 押注界面
--

local QUIDialog = import(".QUIDialog")
local QUIDialogStake = class("QUIDialogStake", QUIDialog)
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIViewController = import("...ui.QUIViewController")
local QReplayUtil = import("...utils.QReplayUtil")

-- 注意，比分顺序： 2:0 2:1 1:2 0:2
function QUIDialogStake:ctor(options)
    local ccbFile = "ccb/Dialog_Stake.ccbi"
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
	QUIDialogStake.super.ctor(self,ccbFile,callBacks,options)
    self.isAnimation = true --是否动画显示

	self._ccbOwner.frame_tf_title:setString("押 注")

    self._nums = 0				-- 押注数量
    self._selectNum = 0			-- 选择类型
    self._maxNum = 0			-- 最大押注数量
	self._canChange = true
		
	if options then
		self._player1 = options.player1
		self._player2 = options.player2
		self._maxNum = options.maxNum -- 最大押注
		self._maxBet = options.maxBet -- 最大倍率
		self._minBet = options.minBet -- 最小倍率
		self._betInfo = options.betInfo
		self._callback = options.callback
	end

	q.setButtonEnableShadow(self._ccbOwner.btn_bet)
	q.setButtonEnableShadow(self._ccbOwner.btn_plus1)
	q.setButtonEnableShadow(self._ccbOwner.btn_plus10)
	q.setButtonEnableShadow(self._ccbOwner.btn_plus100)
	q.setButtonEnableShadow(self._ccbOwner.btn_sub1)
	q.setButtonEnableShadow(self._ccbOwner.btn_sub10)
	q.setButtonEnableShadow(self._ccbOwner.btn_sub100)
	q.setButtonEnableShadow(self._ccbOwner.btn_look_zr)

end

function QUIDialogStake:viewDidAppear()
	QUIDialogStake.super.viewDidAppear(self)

	self:updateInfo()
end

function QUIDialogStake:viewWillDisappear()
	QUIDialogStake.super.viewWillDisappear(self)
	
	if self._calculatorScheduler then
		scheduler.unscheduleGlobal(self._calculatorScheduler)
		self._calculatorScheduler = nil
	end
end

function QUIDialogStake:resetAll()
	for i = 1, 4 do
		self._ccbOwner["tf_jackpot_"..i]:setString(0)
		self._ccbOwner["tf_ratio_"..i]:setString("0%")
		self._ccbOwner["tf_num_"..i]:setString("0人")
	end
	self._nums = 0
	self._ccbOwner.tf_item_num:setString(self._nums)
end

function QUIDialogStake:updateInfo()
	self:resetAll()

	if not self._fighter1 then
		self._fighter1 = self._player1.fighter
	end
	if not self._fighter2 then
    	self._fighter2 = self._player2.fighter
    end

	local limitStr = string.format("押注上限：%d（预期收益为动态收益，实际奖励以押注时间截止后的收益为准）", self._maxNum)
	self._ccbOwner.tf_bet_limit:setString(limitStr)

	self:updatePlayer()
	self:updateSelect()

	self._canChange = true
	
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

function QUIDialogStake:updateGetNum()
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
		if self._maxBet and canGetNum > myBetNum * self._maxBet then
			canGetNum = myBetNum * self._maxBet
		end
		if self._minBet and canGetNum < myBetNum * self._minBet then
			canGetNum = myBetNum * self._minBet
		end
	end

	local preStr = string.format("预期收益：%d", canGetNum)
	self._ccbOwner.tf_pre_get:setString(preStr)
end

function QUIDialogStake:updatePlayer()
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

function QUIDialogStake:updateSelect()
	for i = 1, 4 do
		self._ccbOwner["sp_select_"..i]:setVisible(self._selectNum == i)
	end
	self:updateGetNum()
end

function QUIDialogStake:updateNums()
	self._ccbOwner.tf_item_num:setString(self._nums)
	self:updateGetNum()
end

function QUIDialogStake:_onUpHandler(num)
	self._isDown = false	
	self._isUp = true
	self:_subBuyNums(num)
end

function QUIDialogStake:_onDownHandler(num)
	self._isDown = true
	self._isUp = false
	self._calculatorScheduler = scheduler.performWithDelayGlobal(function()
			self:_subBuyNums(num)
		end, 0.5)
end

function QUIDialogStake:_subBuyNums(num)
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

function QUIDialogStake:_onSub()
	app.sound:playSound("common_increase")

	if self._nums - 1 <= 0 then 
		self._nums = 1
	else
		self._nums = self._nums - 1
	end
	self:updateNums()
end

function QUIDialogStake:_onPlus()
	app.sound:playSound("common_increase")

	if self._nums + 1 > self._maxNum then 
		self._nums = self._maxNum
	else
		self._nums = self._nums + 1
	end
	self:updateNums()
end

function QUIDialogStake:_onSubTen(event)
	if tonumber(event) == CCControlEventTouchDown then
		self:_onDownHandler(-10)
	else
		app.sound:playSound("common_increase")
		self:_onUpHandler(-10)
	end
end

function QUIDialogStake:_onPlusTen(event)
	if tonumber(event) == CCControlEventTouchDown then
		self:_onDownHandler(10)
	else
		app.sound:playSound("common_increase")
		self:_onUpHandler(10)
	end
end

function QUIDialogStake:_onSubHundred(event)
	if tonumber(event) == CCControlEventTouchDown then
		self:_onDownHandler(-100)
	else
		app.sound:playSound("common_increase")
		self:_onUpHandler(-100)
	end
end

function QUIDialogStake:_onPlusHundred(event)
	if tonumber(event) == CCControlEventTouchDown then
		self:_onDownHandler(100)
	else
		app.sound:playSound("common_increase")
		self:_onUpHandler(100)
	end
end

function QUIDialogStake:_onTriggerClick1()
    app.sound:playSound("common_cancel")
    if self._canChange == false then
    	return
    end

    self._selectNum = 1
    self:updateSelect()
end

function QUIDialogStake:_onTriggerClick2()
    app.sound:playSound("common_cancel")
    if self._canChange == false then
    	return
    end
    self._selectNum = 2
    self:updateSelect()
end

function QUIDialogStake:_onTriggerClick3()
    app.sound:playSound("common_cancel")
    if self._canChange == false then
    	return
    end
    self._selectNum = 3
    self:updateSelect()
end

function QUIDialogStake:_onTriggerClick4()
    app.sound:playSound("common_cancel")
    if self._canChange == false then
    	return
    end
    self._selectNum = 4
    self:updateSelect()
end

function QUIDialogStake:_onTriggerBet()
	app.sound:playSound("common_confirm")
	if self._selectNum == 0 then 
		app.tip:floatTip("未选择押注比分")
		return
	end
	if self._nums == 0 then 
		app.tip:floatTip("购买数量不能为0")
		return
	end
	-- to do
end

-- 查询阵容对比
function QUIDialogStake:_onTriggerVisit()
    app.sound:playSound("common_small")
	if not self._fighter1 or not self._fighter2 then
		return
	end
	-- to do
end

function QUIDialogStake:_onTriggerVisit1()
    app.sound:playSound("common_small")
	if not self._fighter1 then
		return
	end
	-- to do
end

function QUIDialogStake:_onTriggerVisit2()
    app.sound:playSound("common_small")
	if not self._fighter2 then
		return
	end
	-- to do
end

function QUIDialogStake:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
    app.sound:playSound("common_cancel")
    self:playEffectOut()
end

function QUIDialogStake:viewAnimationOutHandler()
	local callback = self._callback

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogStake
