TipOpenFunctionFlyView = TipOpenFunctionFlyView or BaseClass(BaseView)

local FIX_TIME_TO_HIDE = 5

function TipOpenFunctionFlyView:__init()
	self.ui_config = {"uis/views/tips/openfunflytips", "OpenFunctionFlyTips"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.timer = 0
end

function TipOpenFunctionFlyView:__delete()
end

--写在open中是因为需要解决打开界面时会有延迟,而导致停下任务也有延迟的问题。
function TipOpenFunctionFlyView:Open(index)
	BaseView.Open(self, index)
	TaskCtrl.Instance:SetAutoTalkState(false)
end

function TipOpenFunctionFlyView:LoadCallBack()
	self.icon_image = self:FindVariable("icon_image")
	self.show_bg = self:FindVariable("show_bg")
	self.Caption_flag = self:FindVariable("Caption_flag")
	self.item_name = self:FindVariable("item_name")
	self.icon_go = self:FindObj("icon_go")
	self.first_pos = self:FindObj("first_go")
	self.default_pos = self:FindObj("default_pos")
	self:ListenEvent("block_click", BindTool.Bind(self.BlockClick, self))
end

function TipOpenFunctionFlyView:ReleaseCallBack()
	-- 清理变量和对象
	self.icon_image = nil
	self.show_bg = nil
	self.Caption_flag = nil
	self.item_name = nil
	self.icon_go = nil
	self.first_pos = nil
	self.default_pos = nil
end

function TipOpenFunctionFlyView:OpenCallBack()
	if self.cfg == nil and self.collective_flag == nil  then
		return
	end
	self.fly_flag = false
	self.show_bg:SetValue(true)
	self.item_name:SetValue(self.cfg.show_tips)
	if not IsNil(self.icon_go.gameObject) then
		self.icon_go.transform.position = self.first_pos.transform.position
		self.icon_go.rect.sizeDelta = Vector2(90, 90)
	end

	local bundle, asset = nil, nil
	if self.cfg then
		bundle, asset = ResPath.GetMainUIButton(self.cfg.icon)
		self.Caption_flag:SetValue(false)
	elseif self.collective_flag then
		bundle, asset = ResPath.GetSkillGoalsIcon(self.skilledness_glag)
		self.Caption_flag:SetValue(true)
	end
	self.icon_image:SetAsset(bundle, asset)
	if self.collective_flag then
		self.target_pos = self.default_pos.transform.position
	else
		self.target_pos = MainUICtrl.Instance:GetView():GetButtonPos(OpenFunData.Instance:GetName(self.cfg.open_param))
	end
	if self.cfg.open_type == FunOpenType.OpenTipView or self.target_pos == nil then
		GlobalTimerQuest:AddDelayTimer(function()
						self:Close()
					end, 2.0)
	else
		self:CalTimeToHideBg()
	end
end

function TipOpenFunctionFlyView:CloseCallBack()
	self.cfg = nil
	GlobalEventSystem:Fire(FinishedOpenFun, false)
	GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_SHRINK_BUTTON, false)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if self.timer_hide_quest then
		GlobalTimerQuest:CancelQuest(self.timer_hide_quest)
		self.timer_hide_quest = nil
	end
	if self.timer_quest_2 then
		GlobalTimerQuest:CancelQuest(self.timer_quest_2)
		self.timer_quest_2 = nil
	end
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	self.fly_flag = false
	self.collective_flag = nil
	self.skilledness_glag = nil
	TaskCtrl.Instance:SetAutoTalkState(true)
end

function TipOpenFunctionFlyView:SetData(cfg, collective_flag, skilledness_glag)
	self.collective_flag = collective_flag
	self.cfg = cfg
	self.skilledness_glag = skilledness_glag
end

function TipOpenFunctionFlyView:MoveToTarget(timer)
	local timer = timer
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	self.time_quest = GlobalTimerQuest:AddDelayTimer(function()
		local item = self.icon_go
		local path = {}
		-- table.insert(path, self.icon_go.transform.position)
		if self.collective_flag then
			self.target_pos = self.default_pos.transform.position
		else
			local main_view = MainUICtrl.Instance:GetView()
			if FuBenCtrl.Instance:GetFuBenIconView():IsOpen() then
				if self.cfg.with_param == FunWithType.Up then
					main_view:SetShrinkToggle(true)
				end
			end
			self.target_pos = main_view:GetButtonPos(OpenFunData.Instance:GetName(self.cfg.open_param))
		end
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
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
			if self.collective_flag then
				self:Close()
			end
		end
		tweener:OnComplete(close_view)
		item.loop_tweener = tweener
	end, 0)
end

function TipOpenFunctionFlyView:BlockClick()
	if  self.cfg.open_type == FunOpenType.OpenTipView then
		self:Close()
	else
		if self.fly_flag == false then
			self.fly_flag = true
			if self.timer > 3 then
				self:CalTimeToHideBg(3)
			end
		end
	end
end

function TipOpenFunctionFlyView:CalTimeToHideBg(time)
	if self.timer_hide_quest then
	   GlobalTimerQuest:CancelQuest(self.timer_hide_quest)
	   self.timer_hide_quest = nil
	end
	self.timer = time or FIX_TIME_TO_HIDE
	local move_icon_flag = false
	local set_icon_alpha_flag = false
	local set_icon_width_flag = false
	self.timer_hide_quest = GlobalTimerQuest:AddRunQuest(function()
		self.timer = self.timer - UnityEngine.Time.deltaTime
		if self.collective_flag == nil then
			if self.timer <= 2.2 and move_icon_flag == false then
				move_icon_flag = true
				if self.cfg.open_type == FunOpenType.Fly then
					MainUICtrl.Instance:GetView():MoveMainIcon(self.cfg)
				end
			end
			if self.timer < 3 and self.timer > 1.8 then
				self.show_bg:SetValue(false)
				self:MoveToTarget(self.timer - 1.8)
				if self.cfg.with_param == OPEN_FLY_DICT_TYPE.UP and set_icon_width_flag == false then
					set_icon_width_flag = true
					self:SetWidth()
				end
			elseif self.timer <= 1.5 and set_icon_alpha_flag == false then
				set_icon_alpha_flag = true
				MainUICtrl.Instance:GetView():SetButtonAlpha(OpenFunData.Instance:GetName(self.cfg.open_param), 1)
				self:Close()
				GlobalTimerQuest:CancelQuest(self.timer_hide_quest)
				self.timer_hide_quest = nil
			end
		else
			if self.timer < 3 and self.timer > 1 then
				self.show_bg:SetValue(false)
				self:MoveToTarget(self.timer - 1)
			end
		end
	end, 0)
end

function TipOpenFunctionFlyView:SetWidth()
	if self.timer_quest_2 then
	   GlobalTimerQuest:CancelQuest(self.timer_quest_2)
	   self.timer_quest_2 = nil
	end
	local the_time = 0
	self.timer_quest_2 = GlobalTimerQuest:AddRunQuest(function()
		the_time = the_time + UnityEngine.Time.deltaTime
		if the_time <= 0.5 then
			if not IsNil(self.icon_go.gameObject) then
				self.icon_go.rect.sizeDelta = Vector2(90 - 20*the_time * 2, 90 - 20*the_time * 2)
			end
		elseif the_time > 0.5 then
			if not IsNil(self.icon_go.gameObject) then
				self.icon_go.rect.sizeDelta = Vector2(70, 70)
			end
			GlobalTimerQuest:CancelQuest(self.timer_quest_2)
			self.timer_quest_2 = nil
		end
	end, 0)
end


