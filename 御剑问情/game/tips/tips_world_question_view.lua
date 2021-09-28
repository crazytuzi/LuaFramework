TipWorldQuestionView = TipWorldQuestionView or BaseClass(BaseView)

function TipWorldQuestionView:__init()
	self.ui_config = {"uis/views/tips/worldquestiontips_prefab", "WorldQuestionTip"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
end

function TipWorldQuestionView:LoadCallBack()
	self.is_answer = false
	self.question_title = self:FindVariable("question_title")
	self.auto_answer_vip_text = self:FindVariable("auto_answer_vip_text")
	self.time_text = self:FindVariable("time_text")

	self.answer_list = {}
	for i=1,4 do
		self.answer_list[i] = {}
		self.answer_list[i].answer_text = self:FindVariable("answer_text_" .. i)
		self.answer_list[i].answer_right = self:FindVariable("answer_right_" .. i)  --是否正确
		self.answer_list[i].show_answer = self:FindVariable("show_answer_" .. i) 	--显示 正确与错误图标
	end
	self:ListenEvent("close_click", BindTool.Bind(self.OnCloseClick, self))
end

function TipWorldQuestionView:OpenCallBack()
	if self.count_down == nil then
		self.count_down = CountDown.Instance:AddCountDown(30, 1, BindTool.Bind(self.CountDown, self))
	end
	-- self.auto_answer_vip_text:SetValue(vip_limit)
end

function TipWorldQuestionView:ReleaseCallBack()
	self.is_answer = false
end

function TipWorldQuestionView:CloseCallBack()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	local vip_limit = 3
end

function TipWorldQuestionView:OnCloseClick()
	self:Close()
end

function TipWorldQuestionView:SetData()
	self:Flush()
end

function TipWorldQuestionView:OnFlush()
	local info = WorldQuestionData:GetInfo()
	if info.is_answer == false then
		self.question_title:SetValue(info.question)
		for i=1,4 do
			self.answer_list[i].answer_text:SetValue(info.answer_list[i])
			self.answer_list[i].show_answer:SetValue(false)
		end
	else
		local is_true = true
		for i=1,4 do
			if self.select_index == i then
				self.answer_list[i].show_answer:SetValue(true)
				self.answer_list[i].answer_right:SetValue(is_true)
			else
				self.answer_list[i].show_answer:SetValue(false)
			end
		end
	end
end

function TipWorldQuestionView:CountDown(elapse_time, total_time)
	self.time_text:SetValue(total_time - elapse_time)
	if elapse_time >= total_time then
		self:Close()
	end
end

function TipWorldQuestionView:AnswerClick(i)
	self.is_answer = true
	self.select_index = i
end
