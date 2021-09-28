
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_millionsAnswer = i3k_class("wnd_millionsAnswer",ui.wnd_base)

local e_Advance_Satge 	= 0
local e_Pre_Stage 		= 1
local e_Start_Stage 	= 2
local e_Result_Stage	= 3
local e_End_Stage		= 4
local e_Reward_Stage	= 5

local IMG_NUM = { [0]=3690,[1]=3691,[2]=3692,[3]=3693,[4]=3694,[5]=3695,[6]=3696,[7]=3697,[8]=3698,[9]=3699 } -- 显示奖励数量的数字图片

function wnd_millionsAnswer:ctor()
	self._timeCounter = 0
	self._anwer_cfg = nil
	self._state = e_Advance_Satge

	self._isJump = {false, false, false, false, false}

	self._isWatchMode = false

	self._info = {}
	self._allPlayer = 0

	self._rewardCnt = 0

	self._curIndex = 1

	self._co = nil

	self._singleTime = 0
	self._openTime = 0
	self._endTime = 0
	self._rewardTime = 0
	self._curtime = 0
end

function wnd_millionsAnswer:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)

	self.ui = widgets

	self.root = 
	{
		self.ui.preRoot,
		self.ui.startRoot,
		self.ui.resultRoot,
		self.ui.endRoot,
		self.ui.rewardRoot
	}

	self.ui.des:setText(i3k_get_string(17147, i3k_db_millions_answer_cfg.answerCnt))
	self.ui.des1:setText(i3k_get_string(17148, i3k_db_millions_answer_cfg.activePoint))
	self.ui.dess:setText(i3k_get_string(17235))

	self.ui.advanceBtn:onClick(self, function()
		i3k_sbean.million_answer_reserve()
	end)

	local cfg = g_i3k_game_context:GetUserCfg()
	self.ui.tipsIcon:setVisible(cfg:GetIsShowAnswerTips())
	self.ui.tipsBtn:onClick(self, function()
		local isShow = self.ui.tipsIcon:isVisible()
		cfg:SetIsShowAnswerTips(not isShow)
		self.ui.tipsIcon:setVisible(not isShow)
	end)

	self.ui.preText:setText("请淮备")

	self.select = {}
	for i = 1, 3 do
		self.select[i] = {
            select_desc = widgets["select" .. i],
            select_icon = widgets["selectIcon" .. i],
            select_btn  = widgets["selectBtn" .. i],
        }
	end

	self.result = {}
	for i = 1, 3 do
		self.result[i] = {
            result_desc = widgets["select1" .. i],
            result_icon = widgets["selectIcon1" .. i],
            result_num  = widgets["selectNum1" .. i]
        }
	end

	self.ui.desBtn1:onClick(self, function()
		g_i3k_ui_mgr:ShowMessageBox1(i3k_get_string(17146, i3k_db_millions_answer_cfg.activePoint))
	end)

	self.ui.desBtn2:onClick(self, function()
		g_i3k_ui_mgr:ShowMessageBox1(i3k_get_string(17145))
	end)
end

--InvokeUIFunction
function wnd_millionsAnswer:updateAdvanceBtnState()
	self.ui.advanceBtn:disableWithChildren()
	self._info.sign = 1  --预约成功置为1
end

function wnd_millionsAnswer:refresh(info)
	self._anwer_cfg = i3k_db_millions_answer_cfg
	self._singleTime = self._anwer_cfg.limitTime + self._anwer_cfg.readyTime + self._anwer_cfg.publishTime  --每题所需时间
	self._openTime = g_i3k_get_day_time(self._anwer_cfg.openTime)  --活动开启时间
	self._endTime = g_i3k_get_day_time(self._anwer_cfg.openTime + self._singleTime * self._anwer_cfg.answerCnt)  --答题结束时间
	self._rewardTime = g_i3k_get_day_time(self._anwer_cfg.rewardTime)  --活动发奖时间

	self._info = info.roleInfo
	self._allPlayer = info.allPlayer

	self._curtime = i3k_game_get_time()
	self._state = self:getAnswerState(self._curtime)
	self:updateRootByState()
	if self._state == e_Advance_Satge then
		self:updateAnvanceRoot()
	else
		self:showAnswerRootByState(self._state)
		self:updateCurIndex(self._state)
		self:updateAnswerRoot()
	end
end

function wnd_millionsAnswer:updateRootByState()
	self.ui.root1:setVisible(self._state == e_Advance_Satge)
	self.ui.root2:setVisible(self._state ~= e_Advance_Satge)
end

--预约阶段
function wnd_millionsAnswer:updateAnvanceRoot()
	self.ui.cardCnt:setText("x" .. self:getHaveReviveCnt())
	self.ui.cardIcon:setImage(g_i3k_db.i3k_db_get_icon_path(5994))

	if self._info.sign == 1 then  --是否预约
		self.ui.advanceBtn:disableWithChildren()
	end
	self.ui.rewardPool:removeAllChildren()

	local itemId = self._anwer_cfg.rewardType
	local rewardCnt = self:getAnwserRewardCnt()

	local vNum = {}
	while (rewardCnt >= 10)
	do
		table.insert(vNum, 1, i3k_integer(rewardCnt % 10))
		rewardCnt = i3k_integer(rewardCnt / 10)
	end
	table.insert(vNum, 1, i3k_integer(rewardCnt % 10))
	for i = 1, #vNum do
		local item = require("ui/widgets/baiwandatit3")()
		item.vars.numIcon:setImage(g_i3k_db.i3k_db_get_icon_path(IMG_NUM[vNum[i]]))
		self.ui.rewardPool:addItem(item)
	end
	
	local item = require("ui/widgets/baiwandatit2")()
	item.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(itemId))
	item.vars.suo:setVisible(itemId > 0)
	self.ui.rewardPool:addItem(item)

	self.ui.rewardPool:stateToNoSlip()
	
	self:updateAnvanceTime()
end

function wnd_millionsAnswer:updateAnvanceTime()
	local openTime = self._anwer_cfg.openTime
	local todaySecond = self._curtime % (3600 * 24)
	if openTime - todaySecond > 0 then
		self.ui.time:setText(i3k_get_time_show_text(openTime - todaySecond))
	else
		self.ui.time:setText("00:00:00")
	end
end

function wnd_millionsAnswer:updateAnswerRoot()
	if self._state == e_Pre_Stage then
		self:updatePreRoot()
	elseif self._state == e_Start_Stage then
		self:updateStartRoot()
	elseif self._state == e_Result_Stage then
		self:updateResultRoot()
	elseif self._state == e_End_Stage then
		self:updateEndRoot()
	else
		self:updateRewardRoot()
	end

	self:updateAnswerTime()
end

--开始答题阶段
function wnd_millionsAnswer:updateAnswerTime()
	if self._state == e_Pre_Stage then
		self:updatePreTime()
	elseif self._state == e_Start_Stage then
		self:updateQuestionTime()
	end
end

function wnd_millionsAnswer:updatePreTime()
	local questionTime = self:getQuestionTime(self._curtime)
	local readyTime = self._anwer_cfg.readyTime
	if questionTime <= readyTime then
		local have_time = readyTime - questionTime
		self.ui.expbar2:setPercent(have_time / readyTime * 100)
	else
		self.ui.expbar2:setPercent(100)
	end
end

function wnd_millionsAnswer:updateQuestionTime()
	local questionTime = self:getQuestionTime(self._curtime)
	local answerTime = self._anwer_cfg.limitTime + self._anwer_cfg.readyTime
	if questionTime <= answerTime then
		local have_time = answerTime - questionTime
		self.ui.expbar:setPercent(have_time / self._anwer_cfg.limitTime * 100)
		self.ui.countDown:setText(i3k_get_format_time_to_show(have_time))
		if have_time <= self._anwer_cfg.limitTime / 2 then
			self.ui.countDown:setTextColor(g_i3k_get_red_color())
		else
			self.ui.countDown:setTextColor(g_i3k_get_green_color())
		end
	else
		self.ui.expbar:setPercent(100)
		self.ui.countDown:setText(i3k_get_format_time_to_show(self._anwer_cfg.limitTime))
		self.ui.countDown:setTextColor(g_i3k_get_green_color())
	end
end

function wnd_millionsAnswer:refreshData(state)
	self:setJumpState(state, true)
	self:resetJumpState(state)
	self:showAnswerRootByState(state)
	self:updateCurIndex(state)
	self:setWatchState(self:getAnswerIsFail())
end

function wnd_millionsAnswer:showAnswerRootByState(state)
	for i, v in ipairs(self.root) do
		v:hide()
	end
	self.root[state]:show()
end

function wnd_millionsAnswer:updateCurIndex(state)
	if state ~= e_End_Stage and state ~= e_Reward_Stage then
		local curIndex = self:getQuestionIndex()
		self._curIndex = curIndex
		self.ui.curSeq:setText(string.format("第%s题", curIndex))
	else
		self._curIndex = i3k_db_millions_answer_cfg.answerCnt
	end
end

--准备答题阶段
function wnd_millionsAnswer:updatePreRoot()
	if self._isJump[e_Pre_Stage] then
		return
	end
	self:refreshData(e_Pre_Stage)

	self.ui.expbar:setPercent(100)
	self.ui.countDown:setText(i3k_get_format_time_to_show(self._anwer_cfg.limitTime))
	self.ui.countDown:setTextColor(g_i3k_get_green_color())

	self._layout.anis.c_djs.play()

	i3k_sbean.million_answer_sync()
end

function wnd_millionsAnswer:refreshInfoData(info)
	self._info = info.roleInfo
	self._allPlayer = info.allPlayer
end

--正在答题阶段
function wnd_millionsAnswer:updateStartRoot()
	if self._isJump[e_Start_Stage] then
		return
	end
	self:refreshData(e_Start_Stage)

	local groupId = self._info.curQustionGroup
	local questionId = self._curIndex

	local myOption = g_i3k_game_context:getMillionsAnswerSelectOption(questionId)

	if (not myOption) and (self:getQuestionTime(self._curtime) == self._anwer_cfg.readyTime + 1) then
		if questionId == 1 then
			self._layout.anis.c_ks.play()
		elseif questionId == i3k_db_millions_answer_cfg.answerCnt then
			self._layout.anis.c_zh.play()
		end
	end

	local question = g_i3k_db.i3k_db_get_millions_answer_question(groupId, questionId)
	if question then
		self.ui.startText:setText(question.content)
		for i, v in ipairs(self.select) do
			v.select_desc:setText(question.choose[i])
			v.select_icon:setVisible(myOption and myOption == i)
			if myOption then
				v.select_btn:disableWithChildren()
			else
				v.select_btn:enableWithChildren()
			end
			v.select_btn:onClick(self, function()
				--当前是观题模式或者没有预约
				if self._isWatchMode or (self._info.sign ~= 1) then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17149))
					return
				end
				--点击选项
				i3k_sbean.million_answer_click(questionId, i)

				self.select[i].select_icon:show()
				for i = 1, #self.select do
					self.select[i].select_btn:disableWithChildren()
				end
				g_i3k_game_context:setMillionsAnswerSelectOption(questionId, i)
			end)
		end
	end
end

--查看正确率阶段
function wnd_millionsAnswer:updateResultRoot()
	if self._isJump[e_Result_Stage] then
		return
	end
	self:refreshData(e_Result_Stage)

	self.ui.expbar:setPercent(0)
	self.ui.countDown:setText(i3k_get_format_time_to_show(0))
	self.ui.countDown:setTextColor(g_i3k_get_red_color())

	local groupId = self._info.curQustionGroup
	local questionId = self._curIndex

	local myOption = g_i3k_game_context:getMillionsAnswerSelectOption(questionId)

	local question = g_i3k_db.i3k_db_get_millions_answer_question(groupId, questionId)
	if question then
		self.ui.resultText:setText(question.content)
		for i, v in ipairs(self.result) do
			v.result_desc:setText(question.choose[i])
			v.result_icon:setImage(g_i3k_db.i3k_db_get_icon_path((i == question.rightChoose) and 4688 or 4689))
			v.result_num:hide()
		end
	end

	self._co = g_i3k_coroutine_mgr:StartCoroutine(function ()
		g_i3k_coroutine_mgr.WaitForNextFrame()

		if myOption and myOption == question.rightChoose then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17150))
		else
			local isFail = false
			local haveReviveCnt = self:getHaveReviveCnt()
			if haveReviveCnt == 0 then
				isFail = true
			else
				if questionId == self._info.curQustionIndex then  --答题后重新同步数据
					if self._info.dayWrongTime - 1 >= i3k_db_millions_answer_cfg.maxRevive then
						isFail = true
					end
				else
					if self._info.dayWrongTime >= i3k_db_millions_answer_cfg.maxRevive then --错误次数大于等于最大复活卡数就死了
						isFail = true
					end
					if questionId - self._info.curQustionIndex >= i3k_db_millions_answer_cfg.maxRevive + 1 then
						isFail = true
					end
				end
			end
			if (not isFail) and (self._info.sign == 1) then
				g_i3k_ui_mgr:ShowMessageBox1(i3k_get_string(17160))
			end
			local usercfg = g_i3k_game_context:GetUserCfg()
			if isFail and not usercfg:GetIsShowAnswerResult() and (self._info.sign == 1) then
				usercfg:SetIsShowAnswerResult(true)
				g_i3k_ui_mgr:OpenUI(eUIID_MillionsAnswerFailure)
			end
		end

		i3k_sbean.million_answer_sync()
		
        g_i3k_coroutine_mgr:StopCoroutine(self._co)
		self._co = nil
	end)
end

--结束阶段
function wnd_millionsAnswer:updateEndRoot()
	if self._isJump[e_End_Stage] then
		return
	end
	self:refreshData(e_End_Stage)

	self.ui.curSeq:hide()
	self.ui.expbar:setPercent(0)
	self.ui.countDown:setText(i3k_get_format_time_to_show(0))
	self.ui.countDown:setTextColor(g_i3k_get_red_color())
	self.ui.endText3:setText(i3k_get_string(17151))
	g_i3k_game_context:clearMillionsAnswerSelectOption()

	self._co = g_i3k_coroutine_mgr:StartCoroutine(function ()
		g_i3k_coroutine_mgr.WaitForNextFrame()

		local usercfg = g_i3k_game_context:GetUserCfg()
		if not self:getAnswerIsFail() and not usercfg:GetIsShowAnswerResult() then
			usercfg:SetIsShowAnswerResult(true)
			g_i3k_ui_mgr:OpenUI(eUIID_MillionsAnswerSuccess)
		end

		g_i3k_coroutine_mgr:StopCoroutine(self._co)
		self._co = nil
	end)
end

--发奖阶段
function wnd_millionsAnswer:updateRewardRoot()
	if self._isJump[e_Reward_Stage] then
		return
	end
	self:refreshData(e_Reward_Stage)

	self.ui.curSeq:hide()
	self.ui.expbar:setPercent(0)
	self.ui.countDown:setText(i3k_get_format_time_to_show(0))
	self.ui.countDown:setTextColor(g_i3k_get_red_color())
	self.ui.endText1:setText(i3k_get_string(17151))

	g_i3k_game_context:clearMillionsAnswerSelectOption()

	local function callback(names, players)
		local rewardCnt = self:getAnwserRewardCnt()
		if players == 0 then
			self.ui.endText2:setText(i3k_get_string(17154))
		else
			if #names == 0 then
				self.ui.endText2:setText(i3k_get_string(17159, players, rewardCnt))
			else
				self.ui.endText2:setText(i3k_get_string(17152, players, rewardCnt))
			end
		end
		
		self.ui.winScroll:removeAllChildren()

		local allBars = self.ui.winScroll:addChildWithCount("ui/widgets/baiwandatit", 2, #names)
		for i, v in ipairs(allBars) do
			v.vars.name:setText(names[i])
		end
	end
	i3k_sbean.million_answer_name(callback)
end

function wnd_millionsAnswer:getAnwserRewardCnt()
	local rewardCnt = 0  --奖池数目
	local playerCnt = self._allPlayer
	for i = 1, #i3k_db_millions_answer_reward do
		if i3k_db_millions_answer_reward[i].playerCnt > playerCnt then
			rewardCnt = i3k_db_millions_answer_reward[i - 1].rewardCnt
			break
		end
	end
	return rewardCnt
end

function wnd_millionsAnswer:getAnswerIsFail()
	local haveReviveCnt = self:getHaveReviveCnt()
	local cond1 = (haveReviveCnt - self._info.dayWrongTime) < 0-- 0 1 or 1 2
	local cond2 = false
	if self._info.dayWrongTime >= i3k_db_millions_answer_cfg.maxRevive then --如果错误次数大于等于复活次数
		cond2 = self._curIndex - self._info.curQustionIndex > 1
	else
		cond2 = self._curIndex - self._info.curQustionIndex > haveReviveCnt + 1
	end
	return (cond1 or cond2)
end

function wnd_millionsAnswer:getHaveReviveCnt()
	local haveRevive = 0
	local scheduleInfo = g_i3k_game_context:GetScheduleInfo()
	if scheduleInfo.activity >= self._anwer_cfg.activePoint then
		haveRevive = self._anwer_cfg.maxRevive
	end
	return haveRevive
end

function wnd_millionsAnswer:getQuestionTime(curtime)
	local curtime = curtime
	local openTime = self._openTime

	local questionTime = ((curtime - openTime) % self._singleTime) + 1  --1-16
	return questionTime
end

function wnd_millionsAnswer:getQuestionIndex()
	local curtime = self._curtime
	local openTime = self._openTime

	local questionIndex = math.modf((curtime - openTime) / self._singleTime) + 1 --1-12
	return questionIndex
end

function wnd_millionsAnswer:getAnswerState(curtime)
	local curtime = curtime
	local openTime = self._openTime
	local endTime = self._endTime
	local rewardTime = self._rewardTime

	if curtime < openTime then
		return e_Advance_Satge
	end

	if curtime >= endTime and curtime < rewardTime then
		return e_End_Stage
	end

	if curtime >= rewardTime then
		return e_Reward_Stage
	end

	local questionTime = self:getQuestionTime(curtime)
	if questionTime <= self._anwer_cfg.readyTime then  --1-3
		return e_Pre_Stage
	elseif questionTime <= self._anwer_cfg.limitTime + self._anwer_cfg.readyTime then  --4-13
		return e_Start_Stage
	elseif questionTime <= self._singleTime then  --14-16
		return e_Result_Stage
	else
		return e_Pre_Stage
	end
end

function wnd_millionsAnswer:onUpdate(dTime)
	self._timeCounter = self._timeCounter + dTime
	if self._timeCounter >= 1 then
		self._curtime = i3k_game_get_time()
		self._state = self:getAnswerState(self._curtime)

		self:updateRootByState()
		if self._state == e_Advance_Satge then  --预约
			self:updateAnvanceTime()
		else
			self:updateAnswerRoot()
		end
		self._timeCounter = 0
	end
end

function wnd_millionsAnswer:setJumpState(state, isJump)
	self._isJump[state] = isJump
end

function wnd_millionsAnswer:resetJumpState(state)
	for i, v in ipairs(self._isJump) do
		if i ~= state then
			self:setJumpState(i, false)
		end
	end
end

function wnd_millionsAnswer:setWatchState(state)
	self._isWatchMode = state
end

function wnd_millionsAnswer:onHide()
	if self._co then
		g_i3k_coroutine_mgr:StopCoroutine(self._co)
		self._co = nil
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_millionsAnswer.new()
	wnd:create(layout, ...)
	return wnd;
end

