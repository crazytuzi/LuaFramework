WorldQuestionView = WorldQuestionView or BaseClass(BaseView)

local FIX_EXIT_TIME = 3
function WorldQuestionView:__init()
	self.ui_config = {"uis/views/worldquestionview", "WorldQuestionView"}
	self:SetMaskBg()
	self.full_screen = false
	self.play_audio = true
end

function WorldQuestionView:LoadCallBack()
	self.question_title = self:FindVariable("question_title")
	self.auto_answer_vip_text = self:FindVariable("auto_answer_vip_text")
	self.time_text = self:FindVariable("time_text")

	self.answer_list = {}
	for i=1,4 do
		self.answer_list[i] = {}
		self.answer_list[i].answer_text = self:FindVariable("answer_text_" .. i)
		self.answer_list[i].answer_right = self:FindVariable("answer_right_" .. i)  --是否正确
		self.answer_list[i].show_answer = self:FindVariable("show_answer_" .. i) 	--显示 正确与错误图标
		self:ListenEvent("answer_click" .. i, BindTool.Bind2(self.OnAnswerClick, self, i))
	end
	self:ListenEvent("close_click", BindTool.Bind(self.OnCloseClick, self))
end

function WorldQuestionView:SetType(question_type, question_name_type)
	self.question_type = question_type or WORLD_GUILD_QUESTION_TYPE.WORLD
	self.question_name_type = question_name_type or WORLD_GUILD_QUESTION_NAME_TYPE.WORLD
end

function WorldQuestionView:OpenCallBack()
	self:Flush()
end

function WorldQuestionView:ReleaseCallBack()
	self.question_type = nil
	self.question_name_type = nil
	self.question_title = nil
	self.auto_answer_vip_text = nil
	self.time_text = nil
	for i=1,4 do
		self.answer_list[i].answer_text = nil
		self.answer_list[i].answer_right = nil
		self.answer_list[i].show_answer = nil
		self.answer_list[i] = {}
	end
	self.answer_list = {}
end

function WorldQuestionView:CloseCallBack()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function WorldQuestionView:OnCloseClick()
	self:Close()
end

function WorldQuestionView:OnAnswerClick(index)
	local select_index = WorldQuestionData.Instance:GetSelectQuestion(self.question_type)
	if select_index == 0 then
		WorldQuestionData.Instance:SetSelectQuestion(index, self.question_type)
		WorldQuestionCtrl.SendQuestionAnswerReq(self.question_type, index - 1)
	end
end

function WorldQuestionView:OpenCallBack()
	self:Flush()
end

function WorldQuestionView:OnFlush()
	local question_data = WorldQuestionData.Instance
	local world_result_list = question_data:GetResultListByType(self.question_name_type)
	local world_answer_list = question_data:GetAnswerListByType(self.question_name_type)
	local select_index = question_data:GetSelectQuestion(self.question_type)

	--显示限制vip
	local is_can_auto = question_data:GetCanAutoAnswer()
	local color_value = is_can_auto and TEXT_COLOR.GREEN or TEXT_COLOR.RED
	local vip_limit = question_data:GetAutoAnswerVip()
	local vip_text = ToColorStr(tostring(vip_limit), color_value)
	self.auto_answer_vip_text:SetValue(vip_text)

	--答案状态
	if world_result_list and next(world_result_list) then
		for i=1,4 do
			self.answer_list[i].show_answer:SetValue(select_index == i or world_result_list.result + 1 == i)
		end

		--显示正确与错误
		self.answer_list[select_index].answer_right:SetValue(world_result_list.result + 1 == select_index)
		self.answer_list[world_result_list.result + 1].answer_right:SetValue(true)

		--提前结束答题
		local time = world_answer_list.cur_question_end_time - TimeCtrl.Instance:GetServerTime()
		if time > FIX_EXIT_TIME then
			if self.count_down then
				CountDown.Instance:RemoveCountDown(self.count_down)
				self.count_down = nil
			end
			self.time_text:SetValue(FIX_EXIT_TIME)
			self.count_down = CountDown.Instance:AddCountDown(FIX_EXIT_TIME, 1, BindTool.Bind(self.CountDown, self))
		end

		--弹出正确或错误提示
		if world_result_list.result + 1 == select_index then
			TipsCtrl.Instance:ShowSystemMsg(Language.Answer.Correct)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Answer.Wrong)
		end

		return
	end

	--答题状态
	if world_answer_list and next(world_answer_list) then
		self.question_title:SetValue(world_answer_list.question)
		--显示选项
		for i=1,4 do
			self.answer_list[i].show_answer:SetValue(false)
			self.answer_list[i].answer_text:SetValue(world_answer_list.question_list[i])
		end

		--结束倒计时
		local time = math.ceil(world_answer_list.cur_question_end_time - TimeCtrl.Instance:GetServerTime() - 2) --提早2s关闭
		self.time_text:SetValue(time)
		if self.count_down then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		self.count_down = CountDown.Instance:AddCountDown(time, 1, BindTool.Bind(self.CountDown, self))
	end
end

function WorldQuestionView:CountDown(elapse_time, total_time)
	self.time_text:SetValue(total_time - elapse_time)
	if elapse_time >= total_time then
		self:Close()
	end
end
