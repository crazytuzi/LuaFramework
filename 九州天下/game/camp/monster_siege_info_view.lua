MonsterSiegeInfoView = MonsterSiegeInfoView or BaseClass(BaseView)

--没波怪物数量
local WAVE_MONSTER_NUM = 120
local MAX_WAVE_NUM = 20

function MonsterSiegeInfoView:__init()
	self.ui_config = {"uis/views/camp", "MonsterAckCitylInfoView"}

	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE,
		BindTool.Bind(self.MianUIOpenComlete, self))
	self.is_safe_area_adapter = true
end

function MonsterSiegeInfoView:LoadCallBack()
	self.wave_num = self:FindVariable("WaveNum")
	self.statue_hp = self:FindVariable("StatueHp")
	self.tower_num = self:FindVariable("TaNum")
	self.statue_pro = self:FindVariable("StatuePro")
	self.kill_num = self:FindVariable("KillNum")

	self.show_panel = self:FindObj("TaskParent")
	self.btn_text = self:FindVariable("Btn_Text")
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
	self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))

	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
	CampCtrl.Instance:SendGetCampInfo()
end

function MonsterSiegeInfoView:__delete()
	if self.main_view_complete ~= nil then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end
end

function MonsterSiegeInfoView:ReleaseCallBack()
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end	

	self.show_panel = nil
	self.wave_num = nil
	self.statue_hp = nil
	self.tower_num = nil
	self.statue_pro = nil
	self.kill_num = nil
	self.btn_text = nil
end

function MonsterSiegeInfoView:SwitchButtonState(enable)
	self.show_panel:SetActive(enable)
end

function MonsterSiegeInfoView:MianUIOpenComlete()
	self:Flush()
end

function MonsterSiegeInfoView:OpenCallBack()
	--MainUICtrl.Instance.view:SetViewState(false)
end

function MonsterSiegeInfoView:CloseCallBack()
	--FuBenData.Instance:ClearFBSceneLogicInfo()
	--MainUICtrl.Instance.view:SetViewState(true)
end

function MonsterSiegeInfoView:OnFlush(param_t)
	local data = CampData.Instance:GetMonsterSiegeFbAllInfo()
	if data == nil or next(data) == nil then
		return
	end

	if self.wave_num ~= nil then
		local cur_wave = math.ceil(data.created_attack_monster_count / WAVE_MONSTER_NUM)
		self.wave_num:SetValue(string.format(Language.Camp.MonsterWaveStr, cur_wave, MAX_WAVE_NUM))
	end

	if self.kill_num ~= nil then
		local kill_num = data.created_attack_monster_count - data.cur_attack_monster_count
		kill_num = kill_num < 0 and 0 or kill_num
		local kill_wave = math.floor(kill_num / WAVE_MONSTER_NUM)
		self.kill_num:SetValue(string.format(Language.Camp.MonsterWaveStr, kill_wave, MAX_WAVE_NUM))
	end

	if self.statue_hp ~= nil then
		self.statue_hp:SetValue(data.statues_hp_percent .. "%")
	end

	if self.tower_num ~= nil then
		self.tower_num:SetValue(data.cur_tower_count or 0)
	end

	if self.statue_pro ~= nil then
		self.statue_pro:SetValue(data.statues_hp_percent * 0.01)
	end
	if data.is_finish == 1 then
		local tip_str = ""
		local camp = PlayerData.Instance.role_vo.camp
		local is_interfere = false
		local str_tab = Language.Camp
		local other_camp = data.defend_camp
		if other_camp ~= nil and other_camp > 0 and other_camp ~= camp then
			is_interfere = true
		end
		if data.is_pass == 1 then
			if is_interfere then
				tip_str = string.format(str_tab.InterfereFailTip,Language.Convene.Nation[other_camp])
				ViewManager.Instance:Open(ViewName.FBFailFinishView, nil, "fail_tip", {leave_time = 3, tip_str = tip_str})
			else
				tip_str = str_tab.IsPassTip
				ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "finish", {leave_time = 3, tip_str = tip_str})
			end
		else
			if is_interfere then
				tip_str = string.format(str_tab.InterfereWinTip,Language.Convene.Nation[other_camp])
				ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "finish", {leave_time = 3, tip_str = tip_str})
			else
				tip_str = str_tab.DefenseFailTip
				ViewManager.Instance:Open(ViewName.FBFailFinishView, nil, "fail_tip", {leave_time = 3, tip_str = tip_str})
			end
		end
	end
	local camp = PlayerData.Instance.role_vo.camp
	local other_camp = data.defend_camp
	self.btn_text:SetValue(camp == other_camp and Language.Camp.Defend or Language.Camp.Attack)
end

function MonsterSiegeInfoView:ActivityCallBack(activity_type, status, next_time, open_type)
	if activity_type == ACTIVITY_TYPE.ACTIVITY_TYPE_MONSTER_SIEGE then
		if status == ACTIVITY_STATUS.OPEN then
			FuBenCtrl.Instance:SetCountDownByTotalTime(next_time - TimeCtrl.Instance:GetServerTime())
		else
			FuBenCtrl.Instance:SetCountDownByTotalTime(0)
		end
	end
end

function MonsterSiegeInfoView:OnClick()
	local sence_id, pos_list = CampData:GetMonsterSenceCfg()
	GuajiCtrl.Instance:MoveToPos(sence_id, pos_list[1], pos_list[2])
end