TipsGetNewSkillView = TipsGetNewSkillView or BaseClass(BaseView)

local prof_skill = {
	{121, 131, 141, 5},
	{221, 231, 241, 5},
	{321, 331, 341, 5},
	{421, 431, 441, 5},
}

local ignore_team_skill = {
	[702] = 1, 
	[703] = 1, 
	[704] = 1, 
	[705] = 1, 
	[706] = 1, 
	[707] = 1,
}

function TipsGetNewSkillView:__init()
	self.ui_config = {"uis/views/tips/getnewskilltips", "GetNewSkillTips"}
	self.delay_time = 1.5
	self.fade_speed = 1.5
	self.move_speed = 90
	self.play_audio = true
	self.view_layer = UiLayer.Pop
end

function TipsGetNewSkillView:__delete()

end

function TipsGetNewSkillView:LoadCallBack()
	self.skill_button_pos_list = MainUICtrl.Instance:GetSkillButtonPosition()
	self.skill_name = self:FindVariable("SkillName")
	self.show_bg = self:FindVariable("show_bg")
	self.skill_icon = self:FindObj("SkillIcon")
	self:ListenEvent("BlockClick", BindTool.Bind(self.BlockClick, self))
end

function TipsGetNewSkillView:ReleaseCallBack()
	-- 清理变量和对象
	self.skill_name = nil
	self.show_bg = nil
	self.skill_icon = nil
	self.target_icon = nil
end

function TipsGetNewSkillView:ShowView(skill_id)
	if skill_id < 100 and skill_id ~= 5 then
		return
	end

	if FamousGeneralData.Instance:CheckIsGeneralSkill(skill_id) then
		return
	end

	if ignore_team_skill[skill_id] then
		return
	end

	self.id_value = skill_id
	local skill_cfg = SkillData.GetSkillinfoConfig(self.id_value)
	if skill_cfg == nil then
		print('技能配置或ID为空',self.id_value)
		return
	end

	if not skill_cfg.skill_index or skill_cfg.skill_index == "" then return end

	self.index = (skill_cfg.skill_index - 1)
	self:Open()
end

function TipsGetNewSkillView:BlockClick()
	if self.fly_flag == false then
		self.fly_flag = true
		if self.timer > 0 then
			if self.timer_hide_quest then
			   GlobalTimerQuest:CancelQuest(self.timer_hide_quest)
			   self.timer_hide_quest = nil
			end
			self.show_bg:SetValue(false)
			self:MoveToTarget()
		end
	end
end

function TipsGetNewSkillView:OpenCallBack()
	local view_manager = ViewManager.Instance
	view_manager:CloseAll()
	if view_manager:IsOpen(ViewName.TaskDialog) then
		view_manager:Close(ViewName.TaskDialog)
	end
	self.fly_flag = false
	self.show_bg:SetValue(true)
	TaskCtrl.Instance:SetAutoTalkState(false)		--停止接受任务
	ViewManager.Instance:CloseAll()					--关闭所有界面
	GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)				--切换成带技能界面的状态

	local skill_cfg = SkillData.GetSkillinfoConfig(self.id_value)
	self.skill_name:SetValue(skill_cfg.skill_name)

	local icon_id = skill_cfg.skill_icon
	local prof = PlayerData.Instance:GetAttr("prof")
	if skill_cfg.skill_id == 5 then
		icon_id = icon_id + prof
	end
	self.skill_icon.image:LoadSprite(ResPath.GetRoleSkillIcon(icon_id))
	self.skill_icon:SetActive(true)
	self:CalTimeToHideBg()
	if nil == self.skill_button_pos_list then
		return
	end
	local target = self.skill_button_pos_list[self.index]
	self.target_icon = target.transform:FindHard("Icon")
	self.target_icon.gameObject:SetActive(false)
end

function TipsGetNewSkillView:CloseCallBack()
	GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
	GuajiCache.monster_id = 0
	TaskCtrl.Instance:SetAutoTalkState(true)
	self.fly_flag = false
	if self.timer_hide_quest then
	   GlobalTimerQuest:CancelQuest(self.timer_hide_quest)
	   self.timer_hide_quest = nil
	end
end


function TipsGetNewSkillView:MoveToTarget()
	local timer = 1
	if nil == self.skill_button_pos_list then
		self:Close()
		return
	end
	local target = self.skill_button_pos_list[self.index]
	if nil == target then
		self:Close()
		return
	end
	self.time_quest = GlobalTimerQuest:AddDelayTimer(function()
		local item = self.skill_icon
		local path = {}
		self.target_pos = target.transform.position
		table.insert(path, self.target_pos)
		local tweener = item.transform:DOPath(
			path,
			timer,
			DG.Tweening.PathType.Linear,
			DG.Tweening.PathMode.TopDown2D,
			1,
			nil)
		tweener:SetEase(DG.Tweening.Ease.Linear)
		tweener:SetLoops(0)
		local close_view = function()
			self:Close()
			self.skill_icon:SetActive(false)
			self.target_icon.gameObject:SetActive(true)
			GlobalTimerQuest:CancelQuest(self.time_quest)
			local main_view = ViewManager.Instance:GetView(ViewName.Main)
			if main_view and main_view.skill_view then
				main_view.skill_view:CheckNuqiEff()
			end
		end
		tweener:OnComplete(close_view)
		item.loop_tweener = tweener
	end, 0)
end

function TipsGetNewSkillView:CalTimeToHideBg()
	if self.timer_hide_quest then
	   GlobalTimerQuest:CancelQuest(self.timer_hide_quest)
	   self.timer_hide_quest = nil
	end
	self.timer = 2
	self.timer_hide_quest = GlobalTimerQuest:AddRunQuest(function()
		self.timer = self.timer - UnityEngine.Time.deltaTime
		if self.timer <= 0 then
			self.show_bg:SetValue(false)
			GlobalTimerQuest:CancelQuest(self.timer_hide_quest)
			self.timer_hide_quest = nil
			self:MoveToTarget()
		end
	end, 0)
end


