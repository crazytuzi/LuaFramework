require("game/boss/world_boss_view")
require("game/boss/kf_boss_view")
require("game/boss/dabao_boss_view")
require("game/boss/miku_boss_view")
require("game/boss/boss_family_view")
require("game/boss/boss_active_view")
require("game/boss/neutral_boss_view")
require("game/boss/boss_baby_view")
BossView = BossView or BaseClass(BaseView)

function BossView:__init()
	self.full_screen = false								-- 是否是全屏界面
	self.ui_config = {"uis/views/bossview","BossView"}
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].OpenBoss)
	end
	self.play_audio = true
	self:SetMaskBg()
end

function BossView:ReleaseCallBack()
	FunctionGuide.Instance:DelWaitGuideListByName("BossGuide")
	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end

	if self.world_boss_view then
		self.world_boss_view:DeleteMe()
		self.world_boss_view = nil
	end

	if self.boss_family_view then
		self.boss_family_view:DeleteMe()
		self.boss_family_view = nil
	end

	if self.miku_boss_view then
		self.miku_boss_view:DeleteMe()
		self.miku_boss_view = nil
	end

	if self.neutral_boss_view then
		self.neutral_boss_view:DeleteMe()
		self.neutral_boss_view = nil
	end

	if self.baby_boss_view ~= nil then
		self.baby_boss_view:DeleteMe()
		self.baby_boss_view = nil
	end
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.Boss)
	end

	-- 清理变量和对象
	self.tab_world_boss = nil
	self.tab_boss_family = nil
	self.tab_miku_boss = nil
	self.tab_neutral_boss = nil
	self.tab_baby_boss = nil
	self.fatigue_guide = nil

	self.red_point_list = nil
	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end
end

function BossView:LoadCallBack()
	self.world_boss_view = WorldBossView.New()
	local world_boss_content = self:FindObj("WorldBossPanel")
	world_boss_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.world_boss_view:SetInstance(obj)
	end)

	self.boss_family_view = BossFamilyView.New()
	local boss_family_content = self:FindObj("FamilyPanel")
	boss_family_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.boss_family_view:SetInstance(obj)
	end)

	self.miku_boss_view = MikuBossView.New()
	local miku_boss_content = self:FindObj("MikuPanel")
	miku_boss_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.miku_boss_view:SetInstance(obj)

		--引导用按钮
		self.fatigue_guide = self.miku_boss_view.fatigue_guide
	end)

	self.neutral_boss_view = NeutralBossView.New()
	local neutral_boss_content = self:FindObj("NeutralityPanel")
	neutral_boss_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.neutral_boss_view:SetInstance(obj)
	end)

	self.baby_boss_view = BossBabyView.New()
	local baby_boss_content = self:FindObj("BabyBossPanel")
	baby_boss_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.baby_boss_view:SetInstance(obj)
	end)

	self.tab_world_boss = self:FindObj("TabWorldBoss")
	self.tab_boss_family = self:FindObj("TabFamily")
	self.tab_miku_boss = self:FindObj("TabMiku")
	self.tab_neutral_boss = self:FindObj("TabNeutrality")
	self.tab_baby_boss = self:FindObj("TabBabyBoss")

	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))

	self.red_point_list = {
		[RemindName.BossWelfareRemind] = self:FindVariable("show_welfare_red_point"),
		[RemindName.BossFamilyRemind] = self:FindVariable("show_family_red_point"),
	}

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

	self:ListenEvent("Close", BindTool.Bind(self.Close, self))

	self.tab_world_boss.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.world_boss))
	self.tab_boss_family.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.vip_boss))
	self.tab_miku_boss.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.miku_boss))
	self.tab_neutral_boss.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.neutral_boss))
	self.tab_baby_boss.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.baby_boss))
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Boss, BindTool.Bind(self.GetUiCallBack, self))

	--开始引导
	FunctionGuide.Instance:TriggerGuideByName("BossGuide")
end

function BossView:OnToggleChange(index, ison)
	if ison then
		self:ChangeToIndex(index)
	end
end

function BossView:ShowIndexCallBack(index)
	if index == TabIndex.world_boss then
		BossCtrl.Instance:SendGetWorldBossInfo(1)
		self.tab_world_boss.toggle.isOn = true
		if self.world_boss_view then
			self.world_boss_view:Flush()
		end
	elseif index == TabIndex.vip_boss then
		BossCtrl.Instance:SendGetBossInfoReq(BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY)
		self.tab_boss_family.toggle.isOn = true
		if self.boss_family_view then
			self.boss_family_view:Flush()
		end
		ClickOnceRemindList[RemindName.BossFamilyRemind] = 0
		RemindManager.Instance:CreateIntervalRemindTimer(RemindName.BossFamilyRemind)
	elseif index == TabIndex.miku_boss then
		BossCtrl.Instance:SendGetBossInfoReq(BOSS_ENTER_TYPE.TYPE_BOSS_MIKU)
		
		self.tab_miku_boss.toggle.isOn = true
		if self.miku_boss_view then
			self.miku_boss_view:Flush()
		end
	elseif index == TabIndex.neutral_boss then
		BossCtrl.Instance:SendGetBossInfoReq(BOSS_ENTER_TYPE.TYPE_BOSS_NEUTRAL)
		self.tab_neutral_boss.toggle.isOn = true
		if self.neutral_boss_view then
			self.neutral_boss_view:Flush()
		end
	elseif index == TabIndex.baby_boss then
		BossCtrl.SendBabyBossOpera(BABY_BOSS_OPERATE_TYPE.TYPE_BOSS_INFO_REQ)
		BossCtrl.SendBabyBossOpera(BABY_BOSS_OPERATE_TYPE.TYPE_ROLE_INFO_REQ)
		self.tab_baby_boss.toggle.isOn = true
		if self.baby_boss_view then
			self.baby_boss_view:Flush()
		end
	end
end

function BossView:CloseCallBack()
	if self.boss_family_view then
		self.boss_family_view:CloseBossView()
	end
	if self.miku_boss_view then
		self.miku_boss_view:CloseBossView()
	end
	if self.neutral_boss_view then
		self.neutral_boss_view:CloseBossView()
	end

	if self.baby_boss_view then
		self.baby_boss_view:CloseBossView()
	end

	if self.event_quest then
		GlobalEventSystem:UnBind(self.event_quest)
	end
end

function BossView:OpenCallBack()	
	-- 首次刷新数据
	self:ShowOrHideTab()

	self.event_quest = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.ShowOrHideTab, self))
end

function BossView:ShowOrHideTab()
	if not self:IsOpen() then return end
	local open_fun_data = OpenFunData.Instance
	self.tab_world_boss:SetActive(open_fun_data:CheckIsHide("world_boss"))
	self.tab_boss_family:SetActive(open_fun_data:CheckIsHide("vip_boss"))
	self.tab_miku_boss:SetActive(open_fun_data:CheckIsHide("miku_boss"))
	self.tab_neutral_boss:SetActive(open_fun_data:CheckIsHide("neutral_boss"))
	self.tab_baby_boss:SetActive(open_fun_data:CheckIsHide("baby_boss"))
end

function BossView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "world_boss" and self.tab_world_boss.toggle.isOn then
			if self.world_boss_view then
				self.world_boss_view:Flush()
			end
		elseif k == "boss_family" and self.tab_boss_family.toggle.isOn then
			if self.boss_family_view then
				self.boss_family_view:Flush()
			end
		elseif k == "miku_boss" and self.tab_miku_boss.toggle.isOn then
			if self.miku_boss_view then
				self.miku_boss_view:Flush()
			end
		elseif k == "neutral_boss" and self.tab_neutral_boss.toggle.isOn then
			if self.neutral_boss_view then
				self.neutral_boss_view:Flush()
			end
		elseif k == "baby_boss" and self.tab_baby_boss.toggle.isOn then
			if self.baby_boss_view then
				self.baby_boss_view:Flush()
			end
		elseif k == "baby_boss_role_info" and self.tab_baby_boss.toggle.isOn then
			if self.baby_boss_view then
				self.baby_boss_view:Flush("role_info")
			end
		end
	end
end

function BossView:OnChangeToggle(index)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if index == TabIndex.miku_boss then
		self.tab_miku_boss.toggle.isOn = true
	end
end

function BossView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.Tab then
		local index = TabIndex[ui_param]
		if index == TabIndex.miku_boss then
			if self.tab_miku_boss.gameObject.activeInHierarchy then
				if self.tab_miku_boss.toggle.isOn then
					return NextGuideStepFlag
				else
					local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.miku_boss)
					return self.tab_miku_boss, callback
				end
			end
		end
	elseif ui_name == GuideUIName.BossBtngo then
		return self.miku_boss_view:GetBossBtngo()
	end
end

function BossView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end
