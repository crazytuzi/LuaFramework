QuestionView = QuestionView or BaseClass(BaseView)

function QuestionView:__init()
	self.ui_config =  {"uis/views/chatroom", "QuestionView"}
	self.view_layer = UiLayer.MainUI
end

function QuestionView:__delete()

end

function QuestionView:ReleaseCallBack()
	self:RemoveCountDown()
	self:RemoveDelayTime()

	self.title = nil
    self.question = nil
    self.answer_a = nil
    self.answer_b = nil
    self.corrent_count = nil
    self.time = nil
    self.yes_a = nil
    self.no_a = nil
    self.yes_b = nil
    self.no_b = nil
    self.reminder_time = nil
    self.show_count_down = nil
    self.remind = nil
end

function QuestionView:LoadCallBack()
	self.title = self:FindVariable("Title")
    self.question = self:FindVariable("Question")
    self.answer_a = self:FindVariable("AnswerA")
    self.answer_b = self:FindVariable("AnswerB")
    self.corrent_count = self:FindVariable("CorrentCount")
    self.time = self:FindVariable("Time")
    self.yes_a = self:FindVariable("YesA")
    self.no_a = self:FindVariable("NoA")
    self.yes_b = self:FindVariable("YesB")
    self.no_b = self:FindVariable("NoB")
    self.reminder_time = self:FindVariable("ReminderTime")
    self.show_count_down = self:FindVariable("ShowCountDown")
    self.remind = self:FindVariable("Remind")

    self:ListenEvent("OnClickA",
        BindTool.Bind(self.OnClickAnswer, self, 0))
    self:ListenEvent("OnClickB",
        BindTool.Bind(self.OnClickAnswer, self, 1))
end

function QuestionView:OpenCallBack()

end

function QuestionView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "question" then
			self:SetNewQuestion()
		elseif k == "result" then
			self:SetResult(v.result, v.right_result, v.last_choose)
		elseif k == "role_info" then
			self:FlushRoleInfo()
		end
	end
end

function QuestionView:OnClickAnswer(answer)
    GuajiCtrl.Instance:StopGuaji()
    self.choose_answer = answer
    local scene_logic = Scene.Instance:GetSceneLogic()
    if scene_logic then
        if scene_logic:GetSceneType() == SceneType.HotSpring then
            local pos = {}
            if answer == 0 then
                pos = scene_logic:GetPosA()
            else
                pos = scene_logic:GetPosB()
            end
            if pos and next(pos) then
                GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), pos.x, pos.y, 1, 1)
            end
        end
    end
end

function QuestionView:SetNewQuestion()
	self.show_count_down:SetValue(false)
    self.yes_a:SetValue(false)
    self.yes_b:SetValue(false)
    self.no_a:SetValue(false)
    self.no_b:SetValue(false)

    self:FlushAnswerPanel()
end

function QuestionView:FlushAnswerPanel()
    local question_info = HotStringChatData.Instance:GetQuestionInfo()
    if question_info then
	    local current_count = question_info.broadcast_question_total
	    self.title:SetValue(string.format(Language.Answer.DiJiTi, current_count))
	    self.question:SetValue(question_info.curr_question_str)
	    self.answer_a:SetValue(question_info.curr_answer0_desc_str)
	    self.answer_b:SetValue(question_info.curr_answer1_desc_str)

	    local rest_time = question_info.curr_question_end_time - TimeCtrl.Instance:GetServerTime()
	    self:ChangeRestTime(rest_time)
	    if rest_time > 0 then
	    	self:RemoveCountDown()
	        self.count_down = CountDown.Instance:AddCountDown(rest_time, 0.1, BindTool.Bind(self.UpdateTime, self))
	    end
	end
    self.remind:SetValue(Language.Answer.ShengYuShiJian)
end

function QuestionView:UpdateTime(elapse_time, total_time)
	local rest_time = total_time - elapse_time
	self:ChangeRestTime(rest_time)
end

function QuestionView:ChangeRestTime(rest_time)
	rest_time = math.max(rest_time, 0)
	local rest_time_str = string.format("%.1f", rest_time)
    if rest_time < 10 then
        rest_time_str = "00:0" .. rest_time_str
    else
        rest_time_str = "00:" .. rest_time_str
    end
    if rest_time < 5 then
    	rest_time_str = ToColorStr(rest_time_str, TEXT_COLOR.RED)
    end
    self.time:SetValue(rest_time_str)
end

function QuestionView:RemoveCountDown()
    if self.count_down then
        CountDown.Instance:RemoveCountDown(self.count_down)
        self.count_down = nil
    end
end

function QuestionView:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function QuestionView:SetResult(result, right_result, choose)
    if result == 0 then -- 回答错误
        SysMsgCtrl.Instance:ErrorRemind(Language.Answer.Wrong)
    else
        SysMsgCtrl.Instance:ErrorRemind(Language.Answer.Correct)
    end
    -- 如果选择弃权
    if choose == 2 then
        if right_result == 0 then
            self.yes_a:SetValue(true)
            self.no_b:SetValue(true)
        else
            self.yes_b:SetValue(true)
            self.no_a:SetValue(true)
        end
    -- 选择B
    elseif choose == 1 then
        if right_result == 0 then
            self.no_b:SetValue(true)
        else
            self.yes_b:SetValue(true)
        end
   	-- 选择A
    else
        if right_result == 0 then
            self.yes_a:SetValue(true)
        else
            self.no_a:SetValue(true)
        end
    end

	local question_info = HotStringChatData.Instance:GetQuestionInfo()
    local total_question_count = HotStringChatData.Instance:GetTotalQuestionCount() or 0
    if question_info.broadcast_question_total >= total_question_count then
        -- 如果是跟随榜首
        if HotStringChatCtrl.Instance.is_follow then
            GuajiCtrl.Instance:StopGuaji()
        end
    	self:RemoveDelayTime()
        self.delay_time = GlobalTimerQuest:AddDelayTimer(function() self:Close() end, 5)
    else
    	self:RemoveCountDown()
        local answer_prepare_time = question_info.next_question_start_time - TimeCtrl.Instance:GetServerTime()
		self.count_down = CountDown.Instance:AddCountDown(answer_prepare_time, 0.1, BindTool.Bind(self.UpdateTime, self))
    end
    self.remind:SetValue(Language.Answer.ZhunBeiShiJian)
end

function QuestionView:FlushRoleInfo()
	local role_info = HotStringChatData.Instance:GetRoleAnswerInfo()
    if role_info then
        self.corrent_count:SetValue(role_info.question_right_count)
    end
end