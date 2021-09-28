FamousGeneralWakeUpView = FamousGeneralWakeUpView or BaseClass(BaseRender)

function FamousGeneralWakeUpView:__init()

	self.skill_prob_tips = self:FindVariable("Skill_Prob_Tips")
	self.prog_value = self:FindVariable("Prog_Value")
	self.gold_text_1 = self:FindVariable("Gold_Text_1")
	self.gold_text_9 = self:FindVariable("Gold_Text_9")
	self.prog_num_text = self:FindVariable("Prog_Num_Text")
	self.has_free_times = self:FindVariable("Has_Free_Times")
	self.free_times = self:FindVariable("Free_Times")
	self.awake_remind = self:FindVariable("Awake_Remind")


	self.gold_text_1:SetValue(FamousGeneralWakeUpData.Instance:GetTalentFlushCost(1))
	self.gold_text_9:SetValue(FamousGeneralWakeUpData.Instance:GetTalentFlushCost(9))

	self:ListenEvent("OnFlushOne", BindTool.Bind(self.OnFlushOne, self))
	self:ListenEvent("OnFlushNine", BindTool.Bind(self.OnFlushNine, self))
	self:ListenEvent("ClickFocus", BindTool.Bind(self.ClickFocus, self))


	self.flush_skill_cell_list = {}
	self.flush_skill_obj_list = {}
	for i=1, GameEnum.TALENT_CHOUJIANG_GRID_MAX_NUM do
		self.flush_skill_obj_list[i] = self:FindObj("SkillCell"..i)
		self.flush_skill_cell_list[i] = FuLingTalentSkillCell.New(self.flush_skill_obj_list[i])
	end
end

function FamousGeneralWakeUpView:__delete()
	if self.flush_skill_cell_list then
		for i,v in ipairs(self.flush_skill_cell_list) do
			v:DeleteMe()
		end
		self.flush_skill_cell_list = nil
	end
	if self.tweener1 then
		self.tweener1:Pause()
		self.tweener1 = nil
	end
	if self.tweener2 then
		self.tweener2:Pause()
		self.tweener2 = nil
	end
end


function FamousGeneralWakeUpView:OpenCallBack()
	self:Flush()
end

function FamousGeneralWakeUpView:CloseCallBack()
	self.flush_one = false
	self.flush_nine = false
end

function FamousGeneralWakeUpView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "anim" then
			if self.flush_one then
				self.flush_one = false
				self:RollSkillCell(0)
			elseif self.flush_nine then
				self.flush_nine = false
				self:RollSkillCell(1)
			end
		elseif k == "all" then
			if not self.is_rotation then
				self:OnFlushAll()
			end
		end
	end
end

function FamousGeneralWakeUpView:OnFlushOne()
	if self.button_flag then
		return
	end
	if WakeUpFocusData.Instance:IsFocusCorrect() then
		TipsCtrl.Instance:ShowCommonTip(function ()
			self.flush_one = true
			FamousGeneralCtrl.Instance:SendTalentOperaReq(TALENT_OPERATE_TYPE.TALENT_OPERATE_TYPE_CHOUJIANG_REFRESH, 0)
			self.button_flag = false
			if self.delay_button_timer then
				GlobalTimerQuest:CancelQuest(self.delay_button_timer)
			end
			self.delay_button_timer = GlobalTimerQuest:AddDelayTimer(function ()
				if self.button_flag then
					self.button_flag = false
				end
			end,0.5)
		end, nil, Language.FocusTips.GetCorrect)
		return
	end
	self.flush_one = true
	self.button_flag = true
	FamousGeneralCtrl.Instance:SendTalentOperaReq(TALENT_OPERATE_TYPE.TALENT_OPERATE_TYPE_CHOUJIANG_REFRESH, 0)
	-- self:RollSkillCell(0)
end

function FamousGeneralWakeUpView:OnFlushNine()
	if self.button_flag then
		return
	end
	if WakeUpFocusData.Instance:IsFocusCorrect() then
		TipsCtrl.Instance:ShowCommonTip(function ()
			self.flush_nine = true
			FamousGeneralCtrl.Instance:SendTalentOperaReq(TALENT_OPERATE_TYPE.TALENT_OPERATE_TYPE_CHOUJIANG_REFRESH, 1)
			self.button_flag = false
			if self.delay_button_timer then
				GlobalTimerQuest:CancelQuest(self.delay_button_timer)
			end
			self.delay_button_timer = GlobalTimerQuest:AddDelayTimer(function ()
				if self.button_flag then
					self.button_flag = false
				end
			end,0.5)
		end, nil, Language.FocusTips.GetCorrect)
		return
	end

	self.flush_nine = true
	FamousGeneralCtrl.Instance:SendTalentOperaReq(TALENT_OPERATE_TYPE.TALENT_OPERATE_TYPE_CHOUJIANG_REFRESH, 1)
	-- self:RollSkillCell(1)
	self.button_flag = true
	if self.delay_button_timer then
		GlobalTimerQuest:CancelQuest(self.delay_button_timer)
	end
	self.delay_button_timer = GlobalTimerQuest:AddDelayTimer(function ()
		if self.button_flag then
			self.button_flag = false
		end
	end,0.5)
end

function FamousGeneralWakeUpView:SetDataFlag(flag)
	self.button_flag = flag
end

function FamousGeneralWakeUpView:RollSkillCell(roll_type)
	self.is_rotation = true
	if roll_type == 1 then --1：所有，0：第一个
		for i=1, GameEnum.TALENT_CHOUJIANG_GRID_MAX_NUM do
			self.flush_skill_obj_list[i].rect:SetLocalScale(1, 1, 1)
			local target_scale = Vector3(0, 1, 1)
			local target_scale2 = Vector3(1, 1, 1)
			self.tweener1 = self.flush_skill_obj_list[i].rect:DOScale(target_scale, 0.3)

			local func2 = function()
				self.tweener2 = self.flush_skill_obj_list[i].rect:DOScale(target_scale2, 0.3)
				self.is_rotation = false
				self:OnFlushAll()
			end
			self.tweener1:OnComplete(func2)

		end
	elseif roll_type == 0 then
		self.flush_skill_obj_list[1].rect:SetLocalScale(1, 1, 1)
		local target_scale = Vector3(0, 1, 1)
		local target_scale2 = Vector3(1, 1, 1)
		self.tweener1 = self.flush_skill_obj_list[1].rect:DOScale(target_scale, 0.3)

		local func2 = function()
			self.tweener2 =self.flush_skill_obj_list[1].rect:DOScale(target_scale2, 0.3)
			self.is_rotation = false
			self:OnFlushAll()
		end
		self.tweener1:OnComplete(func2)
	end
end

function FamousGeneralWakeUpView:OnFlushAll()
	self:OnFlushChouJiangView()

	self:OnFlushRedPoint()
end

function FamousGeneralWakeUpView:OnFlushRedPoint()
	--self.awake_remind:SetValue(ImageFuLingData.Instance:GetFreeChouJiangTimes() > 0)
end

function FamousGeneralWakeUpView:OnFlushChouJiangView()
	local choujiang_info = FamousGeneralWakeUpData.Instance:GetTalentChoujiangPageInfo()
	if nil == choujiang_info then
		return
	end

	for i=1, GameEnum.TALENT_CHOUJIANG_GRID_MAX_NUM do
		local data = choujiang_info[i]
		if self.flush_skill_cell_list[i] then
			self.flush_skill_cell_list[i]:SetData(data)
		end
	end

	local stage_cfg = FamousGeneralWakeUpData.Instance:GetTalentStageConfigByTimes(FamousGeneralWakeUpData.Instance:GetCurChouJiangTimes())
	self.skill_prob_tips:SetValue(nil ~= stage_cfg and stage_cfg.dess or "")
	
	local max_stage_cfg = FamousGeneralWakeUpData.Instance:GetTalentChouJiangMaxtStageConfig()
	local cur_count = FamousGeneralWakeUpData.Instance:GetCurChouJiangTimes()
	self.prog_num_text:SetValue(cur_count)
	self.prog_value:SetValue(cur_count / max_stage_cfg.min_count)

	-- local free_count = FamousGeneralWakeUpData.Instance:GetFreeChouJiangTimes()
	-- self.has_free_times:SetValue(free_count > 0)
	-- self.free_times:SetValue(free_count)
end

function FamousGeneralWakeUpView:ClickFocus()
	ViewManager.Instance:Open(ViewName.WakeUpFocusView)
end

-----------------------------------------------------------------------------------------------------------------------
--FuLingTalentSkillCell
-----------------------------------------------------------------------------------------------------------------------

FuLingTalentSkillCell = FuLingTalentSkillCell or BaseClass(BaseCell)

function FuLingTalentSkillCell:__init()
	self.text_skill_name = self:FindVariable("text_skill_name")

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))

	self:ListenEvent("OnClickBtn", BindTool.Bind(self.OnClickBtn, self))
end

function FuLingTalentSkillCell:__delete()
	if nil ~= self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	self.text_skill_name = nil

end

function FuLingTalentSkillCell:OnFlush()
	if nil == self.data then
		return
	end
	local skill_cfg = FamousGeneralWakeUpData.Instance:GetTalentSkillConfig(self.data.skill_id, 0)

	if nil ~= skill_cfg then
		self.item_cell:ShowQuality(true)
		self.item_cell:SetData({item_id = skill_cfg.book_id})

		local item_cfg = ItemData.Instance:GetItemConfig(skill_cfg.book_id)
		if not item_cfg then
			return
		end
		local color = ITEM_COLOR[item_cfg.color or 0]
		if item_cfg.color and item_cfg.color == GameEnum.ITEM_COLOR_GREEN then
			color = TEXT_COLOR.GREEN
		end
		self.text_skill_name:SetValue(ToColorStr(item_cfg.name, color))
	elseif self.data.item_id then
		self.item_cell:ShowQuality(true)
		self.item_cell:SetData({item_id = self.data.item_id})
		local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
		if item_cfg then
			local color = ITEM_COLOR[item_cfg.color or 0]
			if item_cfg.color and item_cfg.color == GameEnum.ITEM_COLOR_GREEN then
				color = TEXT_COLOR.GREEN
			end
			self.text_skill_name:SetValue(ToColorStr(item_cfg.name, color))
		end
	else
		self.item_cell:ShowQuality(false)
		self.item_cell:SetData(nil)
		self.text_skill_name:SetValue("")
	end
end

function FuLingTalentSkillCell:OnClickBtn()
	if nil == self.data then
		return
	end

	FamousGeneralCtrl.Instance:SendTalentOperaReq(TALENT_OPERATE_TYPE.TALENT_OPERATE_TYPE_AWAKE, self.data.seq)
end

function FuLingTalentSkillCell:AddEffect()

end