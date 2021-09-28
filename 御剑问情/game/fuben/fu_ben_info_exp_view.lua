FuBenInfoExpView = FuBenInfoExpView or BaseClass(BaseView)

local ALL_WAVE = 3
function FuBenInfoExpView:__init()
	self.ui_config = {"uis/views/fubenview_prefab", "ExpFBInFoView"}
	self.active_close = false
	self.fight_info_view = true
	self.view_layer = UiLayer.FloatText

	self.fight_effect_change = GlobalEventSystem:Bind(ObjectEventType.FIGHT_EFFECT_CHANGE,
		BindTool.Bind1(self.Flush, self))
	self.menu_toggle_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.PortraitToggleChange, self))
end

function FuBenInfoExpView:LoadCallBack()
	self.cur_process = self:FindVariable("cur_process")
	self.kill_monster_text = self:FindVariable("kill_monster_text")
	self.inspire_damage_text = self:FindVariable("inspire_damage_text")
	self.drug_add_text = self:FindVariable("drug_add_text")
	self.team_exp_text = self:FindVariable("team_exp_text")
	self.exp_text = self:FindVariable("exp_text")
	self.all_wave = self:FindVariable("all_wave")
	self.show_panel = self:FindVariable("show_panel")
	self.next_time = self:FindVariable("next_time")
	self.count_down_time = self:FindVariable("count_down_time")
	self.is_text = self:FindVariable("is_text")
	self.is_text:SetValue(true)
	self.all_wave:SetValue(ALL_WAVE)
end

function FuBenInfoExpView:PortraitToggleChange(state)
	if state == true then
		self:Flush()
	end
	if self.show_panel then
		self.show_panel:SetValue(state)
	end
end

function FuBenInfoExpView:__delete()
	if self.fight_effect_change then
		GlobalEventSystem:UnBind(self.fight_effect_change)
		self.fight_effect_change = nil
	end

	if self.menu_toggle_event then
		GlobalEventSystem:UnBind(self.menu_toggle_event)
		self.menu_toggle_event = nil
	end
end

function FuBenInfoExpView:ReleaseCallBack()
	if self.fight_effect_change then
		GlobalEventSystem:UnBind(self.fight_effect_change)
		self.fight_effect_change = nil
	end
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	-- 清理变量和对象
	self.cur_process = nil
	self.kill_monster_text = nil
	self.inspire_damage_text = nil
	self.drug_add_text = nil
	self.team_exp_text = nil
	self.exp_text = nil
	self.all_wave = nil
	self.show_panel = nil
	self.next_time = nil
	self.count_down_time = nil
	self.is_text = nil
	self.time = nil
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
end

function FuBenInfoExpView:CloseCallBack()

end

function FuBenInfoExpView:OnClickOpenBuff()
	TipsCtrl.Instance:TipsExpInSprieFuBenView()
end

function FuBenInfoExpView:OnClickOpenPotion()
	TipsCtrl.Instance:ShowTipExpFubenView()
end

function FuBenInfoExpView:OpenCallBack()
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	MainUICtrl.Instance:SetViewState(false)

	local fb_view = FuBenCtrl.Instance:GetFuBenView()
	if fb_view:IsOpen() then
		fb_view:Close()
	end
	self:Flush()
end

function FuBenInfoExpView:OnFlush()
	local exp_fb_info = FuBenData.Instance:GetExpFBInfo()
	self.kill_monster_text:SetValue(exp_fb_info.kill_allmonster_num)
	self.drug_add_text:SetValue(FightData.Instance:GetMainRoleDrugAddExp())
	local team_info = ScoietyData.Instance:GetTeamInfo()
	local team_member_list = team_info.team_member_list or {}
	local team_user_list = ScoietyData.Instance:GetTeamUserList()
	local member_list = {}
	for k, v in ipairs(team_user_list) do
		for i, j in ipairs(team_member_list) do
			if v == j.role_id then
				table.insert(member_list, j)
			end
		end
	end
	local cfg = exp_fb_info.team_member_num
	local exp = 0
	if  cfg == 1 then
		exp = 0
 	elseif cfg == 2 then
		exp = 30
	elseif cfg == 3 then
		exp = 60
	elseif cfg == 4 then
		exp = 100
	end
	self.team_exp_text:SetValue(exp)
	self.cur_process:SetValue(exp_fb_info.wave)
	self.inspire_damage_text:SetValue(FuBenData.Instance:GetInSpireDamage())
	local count = self:ChangeNum(exp_fb_info.exp)
	local start_time = exp_fb_info.start_time or 0
	local sever_time = TimeCtrl.Instance:GetServerTime()
	local fb_time = FuBenData.Instance:GetExpFBTime()
	self.time = start_time - sever_time + 8 or 0
	if self.time > 0 then
		self:SetAutoTalkTime()
		self.is_text:SetValue(false)
	end
	local exp = CommonDataManager.ConverNum(exp_fb_info.exp)
	local data_list= {string.format(Language.FB.GetExp, exp), {item_id = ResPath.CurrencyToIconId.exp or 0,num = 0,is_bind = 0}}
	if exp_fb_info.is_finish == 1 then
		local call_back = function ()
			if self.upgrade_timer_quest == nil then
				self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(function()
					ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "expfinish", {data = data_list})
				end, 2)
			end
		end
		TimeScaleService.StartTimeScale(call_back)
	end
end

function FuBenInfoExpView:ChangeNum(count)
	self.exp_text:SetValue(CommonDataManager.ConverTenNum(count))
end

function FuBenInfoExpView:SetAutoTalkTime()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.count_down = CountDown.Instance:AddCountDown(self.time, 1, BindTool.Bind(self.CountDown, self))
end

function FuBenInfoExpView:CountDown(elapse_time, total_time)
	self.next_time:SetValue(math.floor(total_time - elapse_time))
	if total_time - elapse_time < 6 then
		self.count_down_time:SetValue(true)
	end
	if elapse_time >= total_time then
		self.count_down_time:SetValue(false)
		self.is_text:SetValue(true)
	end
end