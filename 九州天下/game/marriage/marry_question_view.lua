MarryQuestionView = MarryQuestionView or BaseClass(BaseView)

function MarryQuestionView:__init()
	self.ui_config = {"uis/views/marriageview", "MarryQuestionlview"}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self:SetMaskBg(true)
	self.the_index = 0
end

function MarryQuestionView:__delete()

end

function MarryQuestionView:ReleaseCallBack()
	self.item_list = {}

	self.the_title = nil
	self.btn_gray = nil
	self.integral = nil
	self.coin = nil
end

-- 创建完调用
function MarryQuestionView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.OnClose, self))
	self:ListenEvent("NextTheGo", BindTool.Bind(self.OnNextTheGo, self))
	for i=1,4 do
		self:ListenEvent("TheItemBtn" .. i, BindTool.Bind(self.TheItemBtn, self, i))
	end
	self.the_title = self:FindVariable("TheTitle")
	self.btn_gray = self:FindVariable("BtnGray")
	self.integral = self:FindVariable("Integral")
	self.coin = self:FindVariable("Coin")

	self.item_list = {}
	for i = 1, 4 do
		local item = self:FindObj("TheItem"..i)
		local icon = item:FindObj("Image")
		local text = item:FindObj("Text")
		
		table.insert(self.item_list, {item = item, skill = skill, icon = icon, text = text})
	end
	self.user_info, self.question_list = MarriageData.Instance:GetHunyanQuestionUserInfo()

	local other_cfg = MarriageData.Instance:GetMarriageConditions()
	if other_cfg then
		self.integral:SetValue(other_cfg.question_right_answer_exp)
		self.coin:SetValue(other_cfg.question_right_answer_coin)
	end
end


function MarryQuestionView:ReleaseCallBack()

end

function MarryQuestionView:SetData(index)
	self.the_index = index
	self:Flush()
end

function MarryQuestionView:OnClose()
	self:Close()
end

function MarryQuestionView:OnFlush(param_list)
	self.user_info, self.question_list = MarriageData.Instance:GetHunyanQuestionUserInfo()
	if self.question_list[self.the_index + 1] then
		local topic_info = MarriageData.Instance:GetCurQuestionThe(self.question_list[self.the_index + 1].question_id)
		if topic_info then
			self.the_title:SetValue(string.format(Language.Marriage.QuestionTheTitle, self.the_index + 1, topic_info.question_content))
			self:TopicFlush(topic_info)
			self.btn_gray:SetValue(self.question_list[self.the_index + 1].answer_status == 1)
		end
	end
end

function MarryQuestionView:OnNextTheGo()
	local info = self.question_list[self.user_info.cur_question_idx + 1]
	if info then
		local npc_id = MarriageData.Instance:GetQuestionNpc(self.user_info.cur_question_idx + 1)
		local pos = MarriageData.Instance:GetQuestionNpcPos(info.npc_pos_seq)
		MoveCache.end_type = MoveEndType.NpcTask
		MoveCache.param1 = npc_id
		GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), pos.pos_x, pos.pos_y, 1, 1, false)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.AchieveQuestion)
	end
	self:Close()
end

function MarryQuestionView:TheItemBtn(index)
	if nil == self.question_list[self.the_index + 1] or self.question_list[self.the_index+ 1].answer_status == 1 then
		return
	end
	self.cur_select = index
	MarriageCtrl.Instance:SendMarryOpera(GameEnum.HUNYAN_OPERA_ANSWER_QUESTION, 0, 0, nil, index - 1)
end

function MarryQuestionView:TopicFlush(topic_info)
	local topic_answer = MarriageData.Instance:GetTopicAnswer()
	local topic_t = {"A，", "B，", "C，", "D，"}
	for k,v in pairs(self.item_list) do
		if self.cur_select and k == self.cur_select and self.question_list[self.the_index + 1] then
			if topic_answer and topic_answer.npc_seq == self.question_list[self.the_index + 1].npc_pos_seq then
				local bundle, asset = ResPath.GetImages(topic_answer.is_righ == 1 and "yes_1001" or "no_1001")
				v.icon.image:LoadSprite(bundle, asset)
				v.icon:SetActive(true)
			else
				v.icon:SetActive(false)
			end
		end
		v.text.text.text = topic_t[k] .. topic_info["answer_" .. (k-1)]
	end
end
