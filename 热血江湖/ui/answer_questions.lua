-------------------------------------------------------
module(..., package.seeall)

local require = require;

-- local ui = require("ui/base");
local ui = require("ui/chatBase")
-------------------------------------------------------
wnd_answer_questions = i3k_class("wnd_answer_questions", ui.wnd_chatBase)


local NORMALCOLOR = "ff4027"--褐色
local SELECTRIGHT = "FFe9ff80"
local SELECTERROR = "ffdf661d"
--[[
local FIRSTCOLOR = "FFffec69"
local SECONDCOLOR = "FFc290ff"
local THIRDCOLOR = "FF39d3ff"
local first_Icon = 1659
local second_Icon = 1660
local third_Icon = 1661]]
local specialTb =
{
	[1] = {icon = 1659 , textcolor = "FFFF4027"},--红色
	[2] = {icon = 1660 , textcolor = "FFFF4027"},
	[3] = {icon = 1661 , textcolor = "FFFF4027"},
}

local COMMON_ICON = 1664
local SELECTON_ICON = 1665
--[[
local zero_Icon = 1666
local one_Icon = 1667
local two_Icon = 1668
local three_Icon = 1669
local four_Icon = 1670
local five_Icon = 1671
local six_Icon = 1672
local seven_Icon = 1673
local eight_Icon = 1674
local nine_Icon = 1675
]]
local activitySyncTbl =
{
	[0] = 1666,
	[1] = 1667,
	[2] = 1668,
	[3] = 1669,
	[4] = 1670,
	[5] = 1671,
	[6] = 1672,
	[7] = 1673,
	[8] = 1674,
	[9] = 1675,
}


local CORRECT_ICON = 1831
local ERROR_ICON = 1832

function wnd_answer_questions:ctor()

	self._alreadyTime = 0
	self._doubleBonusUsed = 0
	self._bonus  = 0
	self._beforebonus = 0
	self.roleRankTb = {}
	self._select  = 0
	self._correctAnswer  = 0
	self.rankid = 0
	self._selectA  = false----标记的一种状态

	self._canSend = false
	self._canNext = false
	self._canShow = false
	self._canUse = false
	self._canMid = false
	self._againRefresh = true
	self._end = false

	self._quizActivity = i3k_db_answer_questions_activity

	self._controls = {}

	--[[
	activitySyncTbl =
	{
	[0] = {index = zero_Icon},
	[1] = {index = one_Icon},
	[2] = {index = two_Icon},
	[3] = {index = three_Icon},
	[4] = {index = four_Icon},
	[5] = {index = five_Icon},
	[6] = {index = six_Icon},
	[7] = {index = seven_Icon},
	[8] = {index = eight_Icon},
	[9] = {index = nine_Icon}
	}



	self.select_btn = {}
	self.select_bg = {}
	self.select_head = {}
	self.select_content = {}
	self.select_isOk = {}
	self.select_isError = {}
	]]
	self.minRank = {}
end
function wnd_answer_questions:configure()
	self._layout.vars.close:onClick(self, self.onCloseUI)
	local vars = self._layout.vars
	self.editBox = vars.editBox
	self.editBox:setMaxLength(i3k_db_common.inputlen.chatlen)
	vars.sendBtn:onClick(self, self.sendMessage)
	self.chatLog = vars.chatLog
end


function wnd_answer_questions:refresh(info)
	local curtime = math.modf(i3k_game_get_time())
	local date = g_i3k_logic:GetCurrentDate(curtime)
	local date1 = g_i3k_logic:GetCurrentDate(info.startTime)

	self._canSend = true
	self._end = false
	self._curSeq = info.curSeq
	self._startTime = info.startTime
	g_i3k_game_context:SetkeJuStartTime(self._startTime)
	self._lastAnsweredQuestionSeq = info.data.lastAnsweredQuestionSeq
	local time_sever =  g_i3k_get_day_time(self._quizActivity.startTime)
	--i3k_log("-----------refresh = -------",date,date1,self._startTime,time_sever, g_i3k_logic:GetCurrentDate(time_sever))----
	self:updateQuizState(info)
	self:onRefreshChatLog()
end
--当前状态
function wnd_answer_questions:updateQuizState(logs)
	local openTime = 0
	if self._startTime > g_i3k_get_day_time(self._quizActivity.startTime) then
		openTime = logs.startTime
	else
		openTime = g_i3k_get_day_time(self._quizActivity.startTime)
	end

	local time = self._quizActivity.itemCount * self._quizActivity.limitTime + openTime
	local curtime = math.modf(i3k_game_get_time())
	--i3k_log("refresh = -------",openTime,self._startTime,g_i3k_get_day_time(self._quizActivity.startTime),time,curtime,logs.startTime)----
	if curtime >= openTime then
		if  curtime >= time and curtime < time + self._quizActivity.showTime then
			--答题结束
			--i3k_sbean.activities_quizgift_qrank(logs.startTime)
			self:updateQuizGiftFinishInfo(logs)
		elseif curtime >= time + self._quizActivity.showTime then
			--未开始
		elseif curtime < time and curtime >= openTime then
			--开始答题
			self:updateQuizGiftInfo(logs)
			self._canUse = true---new
		end
	else
		self:updateQuizGiftBeforeInfo(logs)
	end
end



--左侧排名框
function wnd_answer_questions:updateRankList(rank)


	self._canShow = true
	local activitiesList = self._layout.vars.scroll
	self._layout.vars.scroll:removeAllChildren()
	self.roleRankTb = {}
	local bonusrank = {}

	local index = 0
	--如果有积分就排序，否则显示空
	for k,v in ipairs (rank) do
		local LAYER_SBLBT = require("ui/widgets/qfdtt")()--名字信息框

		table.insert(self.roleRankTb, {sortid = v.bonus,id = v.roleId , name = v.roleName,rankid = k ,layer = LAYER_SBLBT} )

	end

	for k,v in ipairs (self.roleRankTb) do
		local widget = v.layer.vars
		if k <= 3 then
			widget.image:setImage(g_i3k_db.i3k_db_get_icon_path(specialTb[k].icon))--first_Icon
			widget.bonus:setTextColor(specialTb[k].textcolor)--"FFffec69"
			widget.roleName:setTextColor(specialTb[k].textcolor)--"FFffec69"
			widget.roleId:hide()
		--[[
		elseif k == 2 then
			widget.image:setImage(g_i3k_db.i3k_db_get_icon_path(second_Icon))
			widget.bonus:setTextColor(SECONDCOLOR)--"FFc290ff"
			widget.roleName:setTextColor(SECONDCOLOR)--"FFc290ff"
			widget.roleId:hide()
		elseif k ==3 then
			widget.image:setImage(g_i3k_db.i3k_db_get_icon_path(third_Icon))
			widget.bonus:setTextColor(THIRDCOLOR)--"FF39d3ff"
			widget.roleName:setTextColor(THIRDCOLOR)--"FF39d3ff"
			widget.roleId:hide()]]
		else
			widget.image:hide()
			widget.roleId:setText(v.rankid)
			widget.bonus:setTextColor(NORMALCOLOR)--"FF89ffdf"
			widget.roleName:setTextColor(NORMALCOLOR)
		end
		v.rankid = k
		widget.bonus:setText(v.sortid)
		widget.roleName:setText(v.name)
		activitiesList:addItem(v.layer)
	end
end
-----
function wnd_answer_questions:changeContentSize(control)

	local size = self._layout.vars.answerSheet:getContentSize()
	control.rootVar:setContentSize(size.width, size.height)
end
function wnd_answer_questions:updateRightView(control)

	local AddChild = self._layout.vars.answerSheet:getAddChild()
	for i,v in ipairs (AddChild) do

		--self._layout.vars.answerSheet:removeChild(v)
		v.vars.rootImage:hide()
	end
	self._layout.vars.answerSheet:addChild(control)
end
--答题前 描述和倒计时
function wnd_answer_questions:updateQuizGiftBeforeInfo(info)

	local quizGift = require("ui/widgets/datidaojishi")()
	self:updateRightView(quizGift)
	self:changeContentSize(quizGift)
	self:updateQuizGiftBeforeMainInfo(quizGift, info)
end
function wnd_answer_questions:updateQuizGiftBeforeMainInfo(control, info)

	--描述和倒计时
	self._quizBeforeControl = control
end

----题目内容板 每答一道刷新一次并显示排名 有协议
function wnd_answer_questions:updateQuizGiftInfo(info)
	self._startTime = info.startTime
	local quizGiftUI = require("ui/widgets/dati")()
	self:updateRightView(quizGiftUI)
	self:changeContentSize(quizGiftUI)
	self._item = quizGiftUI

	self:updateQuizGiftMainInfo(info)
end
function wnd_answer_questions:selectQuizGiftInfo(control)
	local widgets = control.vars
	for i=1,4 do
		--[[
		local temp_select_bg = "select"..i
		local temp_select_content = "selectContent"..i
		local temp_select_btn = "selectA"..i
		local temp_select_isOk = "showSelect"..i
		local temp_select_head = "selecta"..i
		local temp_select_isError = "show"..i

		table.insert(self.select_btn, widgets[temp_select_btn])
		table.insert(self.select_bg, widgets[temp_select_bg])
		table.insert(self.select_head, widgets[temp_select_head])
		table.insert(self.select_content, widgets[temp_select_content])
		table.insert(self.select_isOk, widgets[temp_select_isOk])
		table.insert(self.select_isError, widgets[temp_select_isError])]]


		local temp_select_bg = string.format("select%s",i)
		local temp_select_content = string.format("selectContent%s",i)
		local temp_select_btn = string.format("selectA%s",i)
		local temp_select_isOk = string.format("showSelect%s",i)
		local temp_select_head = string.format("selecta%s",i)
		local temp_select_isError = string.format("show%s",i)

		--table.insert(self._controls, { btn = widgets[temp_select_btn], bg= widgets[temp_select_bg],content = widgets[temp_select_content],head = widgets[temp_select_head],isOk = widgets[temp_select_isOk],isError = widgets[temp_select_isError]})

		self._controls[i]= { btn = widgets[temp_select_btn], bg= widgets[temp_select_bg],content = widgets[temp_select_content],head = widgets[temp_select_head],isOk = widgets[temp_select_isOk],isError = widgets[temp_select_isError]}

	end
end

-- 设置四个选项
function wnd_answer_questions:setOption(result)
	for i, e in ipairs(self._controls) do
		if result == i then

			e.head:setTextColor(SELECTRIGHT)
			e.content:setTextColor(SELECTRIGHT)
			e.bg:setImage(g_i3k_db.i3k_db_get_icon_path(SELECTON_ICON))
			self:setImageScale9Bg(e.bg)
			e.isOk:show()
		else
			e.head:setTextColor(SELECTERROR)
			e.content:setTextColor(SELECTERROR)
			e.bg:setImage(g_i3k_db.i3k_db_get_icon_path(COMMON_ICON))
			self:setImageScale9Bg(e.bg)
		end
		--i3k_log("jxw---btn:setTouch-------false----1")
		e.btn:disable()--setTouchEnabled(false)
	end
end

function wnd_answer_questions:updateQuizGiftMainInfo(info)
	local control = self._item
	self._selectA = false--标记的一种状态

	self._select  = 0
	self._alreadyTime = 0

	self:selectQuizGiftInfo(control)
	self._bonus = info.data.bonus

	local curtime = math.modf(i3k_game_get_time())
	self._quizTimes = math.modf((curtime - info.startTime) %  self._quizActivity.limitTime)--limittime



	--开始答题 判断答题状态
	if self._quizTimes >= self._quizActivity.limitTime - self._quizActivity.showAnswerlimitTime then--self._quizTimes >= self._quizActivity.limitTime-1
		--公布答案状态
		local alreadyTime = self._quizActivity.limitTime - self._quizTimes

		self:showQuizGiftMainInfo(control,info)---new

	else--答题状态
		if info.curSeq == info.data.lastAnsweredQuestionSeq then --本题答完中途再次进入需要记录状态
			--记录上次积分与本次相比较,有变化 就是勾选
			if info.data.doubleBonusUsed == g_i3k_game_context:GetQuizGiftUseDoubleBonus() then
				g_i3k_game_context:SetQuizGiftIsUseDoubleBonus(0)
			else
				if g_i3k_game_context:GetQuizGiftUseDoubleBonus() < info.data.doubleBonusUsed then

					g_i3k_game_context:SetQuizGiftIsUseDoubleBonus(1)
				end
			end

			self:showTheSameQuiz(control,info)
		else
			g_i3k_game_context:SetQuizGiftUseDoubleBonus(info.data.doubleBonusUsed)
			if self._bonus >  g_i3k_game_context:GetQuizGiftBonus() then
				g_i3k_game_context:SetQuizGiftBonus(self._bonus)
			end
			g_i3k_game_context:SetQuizGiftIsUseDoubleBonus(0)
			self:joinQuizGiftMainInfo(control,info)
		end
	end


end
--本题中途再次进入需要记录状态
function wnd_answer_questions:showTheSameQuiz(control,info)
	self:showQuestionBankInfo(control,info)
	if info.data.lastAnsweredQuestionResult ~= 0 then--有答案 记录状态
		--[[
		for i=1,4 do
			if info.data.lastAnsweredQuestionResult == i then
				self._select = i
				self.select_head[i]:setTextColor(SELECTRIGHT)--"FFe9ff80"
				self.select_content[i]:setTextColor(SELECTRIGHT)--"FFe9ff80"
				self.select_isOk[i]:show()
				self.select_bg[i]:setImage(g_i3k_db.i3k_db_get_icon_path(SELECTON_ICON))
			else
				self.select_head[i]:setTextColor(SELECTERROR)--"FF6cffbc"
				self.select_content[i]:setTextColor(SELECTERROR)--"FF6cffbc"
				self.select_bg[i]:setImage(g_i3k_db.i3k_db_get_icon_path(COMMON_ICON))
			end
			self.select_btn[i]:setTouchEnabled(false)
		end]]
		self._select = info.data.lastAnsweredQuestionResult
		self:setOption(info.data.lastAnsweredQuestionResult)

		control.vars.isSelect:disable()
	end
	local bonus = g_i3k_game_context:GetQuizGiftBonus()
	control.vars.getScore:setText(bonus)--积分
	control.vars.show:hide()
	if g_i3k_game_context:GetQuizGiftIsUseDoubleBonus() == 1 then
		control.vars.selectShow:show()
	else
		control.vars.selectShow:hide()
	end
end
----遍历题库显示题
function wnd_answer_questions:showQuestionBankInfo(control,info)
	local question = {}
	if info.curQuestion < 0 then
		question = i3k_db_question_daily_bank[-info.curQuestion]
	else
		question = i3k_db_question_bank[info.curQuestion]
	end
	if question then
		if info.curSeq and self._quizActivity.itemCount then
			local goal = string.format("(%d/%d)",info.curSeq,  self._quizActivity.itemCount)
			control.vars.currentSeq:setText(goal)
		end
		control.vars.content:setText(question.content)
		if  info.data.doubleBonusUsed then
			local doubleIntegralTimes = string.format("使用双倍积分(%s/%s)",  info.data.doubleBonusUsed,self._quizActivity.maxDoubleIntegralTimes)
			control.vars.dda:setText(doubleIntegralTimes)--剩余双倍积分次数
		end
		control.vars.selectContent1:setText(question.selectA)
		control.vars.selectContent2:setText(question.selectB)
		control.vars.selectContent3:setText(question.selectC)
		control.vars.selectContent4:setText(question.selectD)
		self._correctAnswer  = question.correct
	end
end
----进入答题时间段
function wnd_answer_questions:joinQuizGiftMainInfo(control,info)
	self:showQuestionBankInfo(control,info)
	control.vars.selectShow:hide()
	control.vars.show:hide()
	local needValue = {control = control, doubleBonusUsed= info.data.doubleBonusUsed + 1}
	if info.data.doubleBonusUsed < self._quizActivity.maxDoubleIntegralTimes then
		control.vars.isSelect:enable()
		control.vars.isSelect:setTouchEnabled(true)
		control.vars.isSelect:onClick(self, self.selectdoubleIntegral,needValue)--使用双倍积分
	else
		control.vars.isSelect:disable()
		control.vars.isSelect:setTouchEnabled(false)
	end
	control.vars.getScore:setText(info.data.bonus)--积分
	self._needValue = {time = info.startTime , index = info.curSeq ,item = control }
	--[[
	for i=1,4 do
		self.select_isOk[i]:hide()
		self.select_isError[i]:hide()
		self.select_head[i]:setTextColor(SELECTERROR)--"FF6cffbc"
		self.select_content[i]:setTextColor(SELECTERROR)--"FF6cffbc"
		self.select_bg[i]:setImage(g_i3k_db.i3k_db_get_icon_path(COMMON_ICON))
		self.select_btn[i]:enable()--
		self.select_btn[i]:setTouchEnabled(true)
	end]]
	self:clearQuizGiftAnswer()

	control.vars.selectA1:onClick(self, self.selectAnswer,{time = info.startTime , index = info.curSeq ,item = control,tag = 1 })--选项selectAAnswer ,self._needValue
	control.vars.selectA2:onClick(self, self.selectAnswer,{time = info.startTime , index = info.curSeq ,item = control,tag = 2 })
	control.vars.selectA3:onClick(self, self.selectAnswer,{time = info.startTime , index = info.curSeq ,item = control,tag = 3 })
	control.vars.selectA4:onClick(self, self.selectAnswer,{time = info.startTime , index = info.curSeq ,item = control,tag = 4 })
end
----公布答案界面
function wnd_answer_questions:showQuizGiftMainInfo(control,info)

	control.vars.isSelect:disable()
	control.vars.show:show()
	local addExp = g_i3k_game_context:GetQuizGiftBonusExp()

	if self._addExp then
		g_i3k_ui_mgr:OpenUI(eUIID_QuizShowExp)
		g_i3k_ui_mgr:RefreshUI(eUIID_QuizShowExp,self._addExp)
	end
	if info.curSeq == info.data.lastAnsweredQuestionSeq then--已做答
		self:showQuizGiftAnswerQuestion(control,info)
	else--未答题
		self:showQuizGiftCorrectAnswer(control,info)
	end

end
----公布答案 已做答
function wnd_answer_questions:showQuizGiftAnswerQuestion(control,info)
	local answer = info.data.lastAnsweredQuestionResult
	--如果使用双倍积分，显示
	if g_i3k_game_context:GetQuizGiftIsUseDoubleBonus() == 1 then
		control.vars.selectShow:show()
	else
		control.vars.selectShow:hide()
	end
	local question = {}
	if info.curQuestion < 0 then
		question = i3k_db_question_daily_bank[-info.curQuestion]
	else
		question = i3k_db_question_bank[info.curQuestion]
	end
	if question then
	if info.curSeq and self._quizActivity.itemCount then
		local goal = string.format("(%d/%d)",info.curSeq,  self._quizActivity.itemCount)
		control.vars.currentSeq:setText(goal)
	end
	control.vars.content:setText(question.content)
	if  info.data.doubleBonusUsed then
		local doubleIntegralTimes = string.format("使用双倍积分(%s/%s)",  info.data.doubleBonusUsed,self._quizActivity.maxDoubleIntegralTimes)
		control.vars.dda:setText(doubleIntegralTimes)--剩余双倍积分次数
	end
	control.vars.selectContent1:setText(question.selectA)
	control.vars.selectContent2:setText(question.selectB)
	control.vars.selectContent3:setText(question.selectC)
	control.vars.selectContent4:setText(question.selectD)
	control.vars.getScore:setText(info.data.bonus)--积分

	if question.correct ==  answer then--答对
		control.anis.c_zq.play()
		control.vars.show:setImage(g_i3k_db.i3k_db_get_icon_path(CORRECT_ICON))
		self:setOption(answer)
	else --答错
		control.anis.c_cw.play()
		control.vars.show:setImage(g_i3k_db.i3k_db_get_icon_path(ERROR_ICON))
		for i, e in ipairs(self._controls) do
			if answer == i then
				e.head:setTextColor(SELECTRIGHT)
				e.content:setTextColor(SELECTRIGHT)
				e.bg:setImage(g_i3k_db.i3k_db_get_icon_path(SELECTON_ICON))
				self:setImageScale9Bg(e.bg)
				e.isOk:hide()
				e.isError:show()
			elseif question.correct == i then
				e.head:setTextColor(SELECTRIGHT)
				e.content:setTextColor(SELECTRIGHT)
				e.bg:setImage(g_i3k_db.i3k_db_get_icon_path(SELECTON_ICON))
				self:setImageScale9Bg(e.bg)
				e.isOk:show()
			else
				e.head:setTextColor(SELECTERROR)
				e.content:setTextColor(SELECTERROR)
				e.bg:setImage(g_i3k_db.i3k_db_get_icon_path(COMMON_ICON))
				self:setImageScale9Bg(e.bg)
			end
			--i3k_log("jxw---btn:setTouch-------false----2")
			e.btn:disable()--setTouchEnabled(false)--
		end
	end
end
end
----公布答案 未答
function wnd_answer_questions:showQuizGiftCorrectAnswer(control,info)
	control.vars.selectShow:hide()
	local question = {}
	if info.curQuestion < 0 then
		question = i3k_db_question_daily_bank[-info.curQuestion]
	else
		question = i3k_db_question_bank[info.curQuestion]
	end
	if question then
	if info.curSeq and self._quizActivity.itemCount then
		local goal = string.format("(%d/%d)",info.curSeq,  self._quizActivity.itemCount)
		control.vars.currentSeq:setText(goal)
	end
	control.vars.content:setText(question.content)
	if  info.data.doubleBonusUsed then
		local doubleIntegralTimes = string.format("使用双倍积分(%s/%s)",  info.data.doubleBonusUsed,self._quizActivity.maxDoubleIntegralTimes)
		control.vars.dda:setText(doubleIntegralTimes)--剩余双倍积分次数
	end
	control.vars.selectContent1:setText(question.selectA)
	control.vars.selectContent2:setText(question.selectB)
	control.vars.selectContent3:setText(question.selectC)
	control.vars.selectContent4:setText(question.selectD)
	control.vars.getScore:setText(info.data.bonus)--积分
	local answer  = question.correct
	control.anis.c_cw.play()
	control.vars.show:setImage(g_i3k_db.i3k_db_get_icon_path(ERROR_ICON))
		self:setOption(answer)
		end
end
--答题结束 显示排名和奖励
function wnd_answer_questions:updateQuizGiftFinishInfo(info)

	local quizGiftFinish = require("ui/widgets/datijieshu")()
	self:updateRightView(quizGiftFinish)
	self:changeContentSize(quizGiftFinish)

	self:updateQuizGiftFinishMainInfo(quizGiftFinish,info)
	self._end = true
end
function wnd_answer_questions:updateQuizGiftFinishMainInfo(item,info)

	--显示排名和奖励
	local roleID = g_i3k_game_context:GetRoleId()
	local cur_rankid = 0
	local cur_rewards = {}
	for k,v in ipairs (self.roleRankTb) do

		if roleID == v.id then
			self.rankid = v.rankid

		end
	end
	--i3k_log("-----updateQuizGiftFinishMainInfo = -------",self.roleRankTb,self.rankid)----
	for i,v in pairs (self._quizActivity.bestReward) do
		if self.rankid <= v.minRank then

			self:appendQuizGiftItem(item, v.rewards,  self.rankid,info)
			break
			--i3k_log("%%%%%%%%%%%%% updateQuizGiftFinishMainInfo = -------",cur_rankid,cur_rewards,self.rankid)----
		end

	end

end
function wnd_answer_questions:appendQuizGiftItem(item, gifts, minRank,info)

	self._minRank = minRank
	local quizGiftFinishTb = {
	[1] = {root = item.vars.item_bg, icon = item.vars.item_icon ,btn = item.vars.Btn1, count = item.vars.item_count,suo = item.vars.Item_suo},--bg = item.vars.count_bg},
	[2] = {root = item.vars.item_bg2, icon = item.vars.item_icon2 ,btn = item.vars.Btn2, count = item.vars.item_count2,suo = item.vars.Item_suo2},--bg = item.vars.count_bg2},
	[3] = {root = item.vars.item_bg3, icon = item.vars.item_icon3 ,btn = item.vars.Btn3, count = item.vars.item_count3,suo = item.vars.Item_suo3},--bg = item.vars.count_bg3},
	[4] = {root = item.vars.item_bg4, icon = item.vars.item_icon4 ,btn = item.vars.Btn4, count = item.vars.item_count4,suo = item.vars.Item_suo4}--bg = item.vars.count_bg4}
	}
	local nohaverank_bg  = item.vars.nohaverank_bg
	local noHaveRank_label  = item.vars.noHaveRank_label
	nohaverank_bg:show()
	noHaveRank_label:hide()
	local quizGiftRankTb = {
	[1] = {root = item.vars.firstDigit},
	[2] = {root = item.vars.secondDigit},
	[3] = {root = item.vars.thirdDigit},
	[4] = {root = item.vars.fourthDigit},
	[5] = {root = item.vars.fifthDigit}
	}
	--i3k_log("%%%%%%%%%%%%% --info.data.expReward = -------%%%%%%%%",info.data.expReward,minRank)----
	item.vars.getExp:setText("+"..info.data.expReward)
	local count = 0
	if minRank == 0 then--排名
		nohaverank_bg:hide()
		noHaveRank_label:show()
		--quizGiftRankTb[1].root:show()
		--quizGiftRankTb[1].root:setImage(g_i3k_db.i3k_db_get_icon_path(activitySyncTbl[0]))--activitySyncTbl[0].index
	end
	while minRank ~= 0 do

		local n =  minRank % 10
		count = count + 1
		table.insert(self.minRank, n)
		minRank = math.floor(minRank / 10)

	end

	for k,v in ipairs (self.minRank) do
		if count > 0 then

			quizGiftRankTb[count].root:show()
			quizGiftRankTb[count].root:setImage(g_i3k_db.i3k_db_get_icon_path(activitySyncTbl[v]))--activitySyncTbl[v].index
			count = count - 1
		end

	end

	if minRank <= self._quizActivity.numberReward and  minRank >= 0 then
		for k,v in ipairs(gifts) do

			quizGiftFinishTb[k].root:show()
			quizGiftFinishTb[k].root:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.itemid) )
			quizGiftFinishTb[k].icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.itemid,i3k_game_context:IsFemaleRole()))
			if v.itemCount > 1 then
				quizGiftFinishTb[k].count:setText("x"..v.itemCount)
			else
				--quizGiftFinishTb[k].bg:hide()
				quizGiftFinishTb[k].count:hide()
			end

			if v.itemid == 3 or v.itemid == 4 or v.itemid == 31 or v.itemid == 32 or v.itemid == 33 or v.itemid < 0 then
				quizGiftFinishTb[k].suo:hide()
			else
				quizGiftFinishTb[k].suo:show()
			end

			quizGiftFinishTb[k].btn:onClick(self, self.onTips,v.itemid)
		end
	else
		--不在奖励范围
	end


end
--[[
function wnd_answer_questions:selectAAnswer(sender,needValue)
	--选中
	if self._selectA  then
		needValue.item.vars.selectA1:disable()
	else
		self._selectA  = true
		self._select  = 1
		needValue.item.vars.showSelect1:show()
		needValue.item.vars.isSelect:disable()--setTouchEnabled(false)
		needValue.item.vars.select1:setImage(g_i3k_db.i3k_db_get_icon_path(SELECTON_ICON))
		needValue.item.vars.selecta1:setTextColor(SELECTRIGHT)--"FFe9ff80"
		needValue.item.vars.selectContent1:setTextColor(SELECTRIGHT)--"FFe9ff80"
		i3k_sbean.activities_quizgift_answer(needValue.time,needValue.index,self._select,g_i3k_game_context:GetQuizGiftIsUseDoubleBonus(),needValue.item)
	end
end
function wnd_answer_questions:selectBAnswer(sender,needValue)

	if self._selectA  then
		needValue.item.vars.selectA1:disable()
	else
		self._selectA  = true
		self._select  = 2
		needValue.item.vars.showSelect2:show()
		needValue.item.vars.isSelect:disable()--setTouchEnabled(false)
		needValue.item.vars.select2:setImage(g_i3k_db.i3k_db_get_icon_path(SELECTON_ICON))
		needValue.item.vars.selecta2:setTextColor(SELECTRIGHT)--"FFe9ff80"
		needValue.item.vars.selectContent2:setTextColor(SELECTRIGHT)--"FFe9ff80"
		i3k_sbean.activities_quizgift_answer(needValue.time,needValue.index,self._select,g_i3k_game_context:GetQuizGiftIsUseDoubleBonus(),needValue.item)
	end
end
function wnd_answer_questions:selectCAnswer(sender,needValue)


	if self._selectA  then
		needValue.item.vars.selectA1:disable()
	else
		self._selectA  = true
		self._select  = 3
		needValue.item.vars.showSelect3:show()
		needValue.item.vars.isSelect:disable()--setTouchEnabled(false)
		needValue.item.vars.select3:setImage(g_i3k_db.i3k_db_get_icon_path(SELECTON_ICON))
		needValue.item.vars.selecta3:setTextColor(SELECTRIGHT)--"FFe9ff80"
		needValue.item.vars.selectContent3:setTextColor(SELECTRIGHT)--"FFe9ff80"
		i3k_sbean.activities_quizgift_answer(needValue.time,needValue.index,self._select,g_i3k_game_context:GetQuizGiftIsUseDoubleBonus(),needValue.item)
	end
end
function wnd_answer_questions:selectDAnswer(sender,needValue)

	if self._selectA  then
		needValue.item.vars.selectA1:disable()
	else
		self._selectA  = true
		self._select  = 4
		needValue.item.vars.showSelect4:show()
		needValue.item.vars.isSelect:disable()--setTouchEnabled(false)
		needValue.item.vars.select4:setImage(g_i3k_db.i3k_db_get_icon_path(SELECTON_ICON))
		needValue.item.vars.selecta4:setTextColor(SELECTRIGHT)--
		needValue.item.vars.selectContent4:setTextColor(SELECTRIGHT)--"FFe9ff80"
		i3k_sbean.activities_quizgift_answer(needValue.time,needValue.index,self._select,g_i3k_game_context:GetQuizGiftIsUseDoubleBonus(),needValue.item)

	end
end
]]

function wnd_answer_questions:setImageScale9Bg(control)
	if control.propScale9Rect then
		control.ccNode_:setCapInsets(control.propScale9Rect)
	end
end

---点击选择答案选项
function wnd_answer_questions:selectAnswer(sender,needValue)
	--选中
	--i3k_log("-----------selectAnswer =-------",needValue.tag)----
	local l_tag = needValue.tag
	if self._selectA  then
		--needValue.item.vars.selectA1:disable()
		self._controls[l_tag].btn:disable()
	else
		self._selectA  = true
		self._select  = l_tag
		needValue.item.vars.isSelect:disable()
		--[[
		needValue.item.vars.showSelect1:show()
		needValue.item.vars.isSelect:disable()--setTouchEnabled(false)
		needValue.item.vars.select1:setImage(g_i3k_db.i3k_db_get_icon_path(SELECTON_ICON))
		needValue.item.vars.selecta1:setTextColor(SELECTRIGHT)--"FFe9ff80"
		needValue.item.vars.selectContent1:setTextColor(SELECTRIGHT)--"FFe9ff80"]]
		self._controls[l_tag].isOk:show()
		self._controls[l_tag].head:setTextColor(SELECTRIGHT)

		self._controls[l_tag].bg:setImage(g_i3k_db.i3k_db_get_icon_path(SELECTON_ICON))
		self:setImageScale9Bg(self._controls[l_tag].bg)

		self._controls[l_tag].content:setTextColor(SELECTRIGHT)
		i3k_sbean.activities_quizgift_answer(needValue.time,needValue.index,self._select,g_i3k_game_context:GetQuizGiftIsUseDoubleBonus(),needValue.item)
	end
end
function wnd_answer_questions:selectdoubleIntegral(sender,needValue)

	--先选中双倍积分 再答题 双倍积分有效
	if g_i3k_game_context:GetQuizGiftIsUseDoubleBonus() == 1 then
		--self._doubleIntegralTimes = 0
		g_i3k_game_context:SetQuizGiftIsUseDoubleBonus(0)
		needValue.control.vars.selectShow:hide()
		needValue.control.vars.isSelect:enable()--setTouchEnabled(true)
		local doubleIntegralTimes = string.format("使用双倍积分(%d/%d)", needValue.doubleBonusUsed - 1, self._quizActivity.maxDoubleIntegralTimes)
		needValue.control.vars.dda:setText(doubleIntegralTimes)--剩余双倍积分次数
	else
		--self._doubleIntegralTimes = 1
		g_i3k_game_context:SetQuizGiftIsUseDoubleBonus(1)
		needValue.control.vars.selectShow:show()
		needValue.control.vars.isSelect:enable()--setTouchEnabled(false)
		local doubleIntegralTimes = string.format("使用双倍积分(%d/%d)", needValue.doubleBonusUsed, self._quizActivity.maxDoubleIntegralTimes)
		needValue.control.vars.dda:setText(doubleIntegralTimes)--剩余双倍积分次数
	end

end

function wnd_answer_questions:clearQuizGiftAnswer()
	self._item.vars.show:hide()
	--[[
	for i=1,4 do

		self.select_isOk[i]:hide()
		self.select_isError[i]:hide()
		self.select_head[i]:setTextColor(SELECTERROR)--"FF6cffbc"
		self.select_content[i]:setTextColor(SELECTERROR)--"FF6cffbc"
		self.select_bg[i]:setImage(g_i3k_db.i3k_db_get_icon_path(COMMON_ICON))
		self.select_btn[i]:setTouchEnabled(true)
	end]]
	for i, e in ipairs(self._controls) do

		e.isOk:hide()
		e.isError:hide()
		e.head:setTextColor(SELECTERROR)
		e.content:setTextColor(SELECTERROR)
		e.bg:setImage(g_i3k_db.i3k_db_get_icon_path(COMMON_ICON))
		self:setImageScale9Bg(e.bg)
		--i3k_log("jxw---btn:setTouch-------true----3")
		e.btn:enable()--setTouchEnabled(true)
	end
end

----活动倒计时
function wnd_answer_questions:excessTime()

	local cur_Time = i3k_game_get_time()
	--cur_Time = i3k_integer(cur_Time) - g_i3k_game_context:getOffsetTime() * 3600 --减去服务器偏移时间

	local openTime = 0
	if self._startTime >  g_i3k_get_day_time(self._quizActivity.startTime) then
		openTime = self._startTime
	else
		openTime =  g_i3k_get_day_time(self._quizActivity.startTime)
	end

	local havetime =( openTime - cur_Time )  /60
	local sec = (openTime - cur_Time ) %60
	local min = havetime  % 60
	local hour = math.floor(havetime/60%24)
	-- local day = havetime/3600/24

	local str = string.format("%d时%d分%d秒",hour,min,sec)
	if self._quizBeforeControl and self._quizBeforeControl.vars then
		self._quizBeforeControl.vars.ActivitiesTime:setText(str)
	end
end
----[[
function wnd_answer_questions:onUpdate(dTime)
	--local openTime = g_i3k_get_day_time(self._quizActivity.startTime)
	local openTime = 0
	if self._startTime > g_i3k_get_day_time(self._quizActivity.startTime) then
		openTime = self._startTime
	else
		openTime =  g_i3k_get_day_time(self._quizActivity.startTime)
	end

	local curtime = math.modf(i3k_game_get_time())
	local curtime2 = i3k_game_get_time()
	local time = self._quizActivity.itemCount * self._quizActivity.limitTime + openTime
	local showTime = time + self._quizActivity.showTime

	if curtime < openTime then

		self:excessTime()
		local activitiesList = self._layout.vars.scroll
		self._layout.vars.scroll:removeAllChildren()

	else	--开始答题
		if  curtime >= time and curtime < showTime then
			--答题结束
			--if curtime == time then
				if not self._end then

					self._againRefresh = false
					local date = g_i3k_logic:GetCurrentDate(curtime)
					i3k_sbean.sync_activities_quizgift(4)---new add
				end
			-- else
			-- 	if self._canShow and self._curSeq <= 0 and self._againRefresh then
			-- 		--i3k_log("==================over refresh = -------",self._info)----
			-- 	 	self:updateQuizGiftFinishInfo(self._info)
			-- 	 	self._canShow = false
			-- 	end
			--end

		elseif curtime >= showTime then
			--i3k_log("-----------over = -------",curtime,showTime,openTime,self._startTime, self._quizActivity.startTime)----
			g_i3k_ui_mgr:CloseUI(eUIID_AnswerQuestions)--关闭当前

		elseif curtime < time and curtime >= openTime then
			--开始答题
			g_i3k_game_context:SetIsExistOnlineGift(1)
			if curtime == openTime  then
				if self._canSend then
					self._canSend = false
					--self._quizBeforeControl.vars.rootImage:hide()
					--local quizGiftUI = require("ui/widgets/dati")()
					--self._item = quizGiftUI

					i3k_sbean.sync_activities_quizgift()

				end
			end
			if self._canUse then
				if not self._item then
					self._canUse = false
					i3k_sbean.sync_activities_quizgift()
				else
					self:onUpdateCurrentMid(dTime,curtime)
				end
			end
			--i3k_log("-----------over = -------",openTime,self._startTime)
		end

	end
end

function wnd_answer_questions:onUpdateCurrentMid(dTime,curtime)
	self._alreadyTime = self._alreadyTime + dTime

	local quizTimeSeq = math.modf((curtime - self._startTime) /  i3k_db_answer_questions_activity.limitTime)
	local curtime2 = i3k_game_get_time()

	local curtime1 =(curtime2 - self._startTime ) %  self._quizActivity.limitTime

		if curtime1 == 0 and  curtime2 ~= self._startTime  then --切题发协议 --
			--i3k_log("----------------curtime1 = ",curtime1,quizTimeSeq,self._curSeq)----
			if self._item then
				self._item.vars.currentTime:setText(0)

				if self._canNext then
					self._canNext = false
					--self:clearQuizGiftAnswer()
					i3k_sbean.sync_activities_quizgift(3)
				end
			end

		elseif curtime1 >= self._quizActivity.limitTime - self._quizActivity.showAnswerlimitTime  then
			--公布答案状态
			local alreadyTime = self._quizActivity.limitTime - curtime1
			if self._canMid  then
				self._canMid  = false
				--[[
				if next(self.select_btn) ~= nil then
					for i=1,4 do
					--self.select_btn[i]:disable()
					self.select_btn[i]:setTouchEnabled(false)
					end
				end
				]]
				for i, e in ipairs(self._controls) do
					--i3k_log("jxw---btn:setTouch-------false----4")
					e.btn:disable()--setTouchEnabled(false)

				end

				i3k_sbean.sync_activities_quizgift(2)
			end
			self:updatesetschedule(dTime,self._item ,alreadyTime)
			self._canNext = true
		else

			local have_timesum =  self._quizActivity.limitTime - self._quizActivity.showAnswerlimitTime - curtime1
			self:updatesetQuizSchedule(dTime,self._item ,have_timesum)
			self._canMid  = true
			--i3k_log("---------da ti zhong = ",curtime1,quizTimeSeq,self._curSeq)----
		end

end
--答题倒计时
function wnd_answer_questions:updatesetQuizSchedule(dTime,control,quiztime)


	local have_time =  quiztime -- -

	self.timePercent = (have_time)/(self._quizActivity.limitTime- self._quizActivity.showAnswerlimitTime )
	local progressAction = control.vars.progress:createProgressAction(have_time, 100*self.timePercent, 0)
	control.vars.progress:show()
	control.vars.progress:runAction(progressAction)--
	control.vars.currentTime:setText(have_time)----本题倒计时   math.round(have_time)
	--i3k_log("--quiztime = -------",quiztime,have_time)----22-1

end
--答案倒计时
function wnd_answer_questions:updatesetschedule(dTime,control,time)


	local have_showAnswertime  =  time -- - showAnswer--self._quizActivity.showAnswerlimitTime

	self.showAnswertimePercent = (have_showAnswertime)/self._quizActivity.showAnswerlimitTime
	local progressAction = control.vars.progress:createProgressAction(have_showAnswertime, 100*self.showAnswertimePercent, 0)
	control.vars.progress:show()
	control.vars.progress:runAction(progressAction)
	control.vars.currentTime:setText(have_showAnswertime)----本题倒计时 math.floor(x + .5)       math.round(have_showAnswertime)
	--i3k_log("-----------------++++time = -------",time,have_showAnswertime)----8-1


end
--添加经验
function wnd_answer_questions:addExpShow(iexp)
	self._addExp = iexp
	g_i3k_game_context:SetQuizGiftBonusExp(iexp)

end


function wnd_answer_questions:setCanUse(canUse,time)
	--i3k_log("setCanUse  = ------",time)----
	self._canUse = canUse
	self._startTime = time

end
function wnd_answer_questions:setCanMid(canUse,time)
	--i3k_log("setCanMid  = ------",time)----
	self._canMid  = canUse
	self._startTime = time

end
function wnd_answer_questions:setNextquestion(canUse,time)
	self._canNext  = canUse
	self._startTime = time

end
function wnd_answer_questions:onTips(sender,itemId)

	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

-------------------聊天部分
function wnd_answer_questions:updatelb()
	self._layout.vars.lbNum:setText(self:getlbNum())
end

function wnd_answer_questions:sendMessage(sender)
	local editBox = self.editBox
	local message = editBox:getText()

	local textcount = i3k_get_utf8_len(message)
	if textcount > i3k_db_common.inputlen.chatlen then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(747))
	elseif self:canSendMessage() then
		editBox:setText("")
		self:checkInput(false, global_world, message, g_i3k_game_context:GetRoleId())
	end
end

--聊天显示内容
function wnd_answer_questions:onRefreshChatLog()
	self:updatelb()
	local chatScroll = self.chatLog
	chatScroll:removeAllChildren()
	local contentSize = chatScroll:getContentSize()
	chatScroll:setContainerSize(contentSize.width, contentSize.height)
	local chatData = g_i3k_game_context:GetChatData()--获取数据
	for i,v in chatData[2]:ipairs() do
		self:createQuestionsChatItem(v)
	end
end

function wnd_answer_questions:receiveNewMsg(message)
	if message.type == global_world then
		self:createQuestionsChatItem(message)
	end
end

function wnd_answer_questions:createQuestionsChatItem(message)
	self:createChatItem(message, self.chatLog)
end

function wnd_create(layout)
	local wnd = wnd_answer_questions.new();
	wnd:create(layout);
	return wnd;
end
