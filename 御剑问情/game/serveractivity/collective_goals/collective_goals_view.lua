CollectiveGoalsView = CollectiveGoalsView or BaseClass(BaseView)

INDEXTOACTIVITYID = {
	[1] = ACTIVITY_TYPE.QUNXIANLUANDOU,
	[2] = ACTIVITY_TYPE.GUILDBATTLE,
	[3] = ACTIVITY_TYPE.GONGCHENGZHAN,
	[4] = ACTIVITY_TYPE.CLASH_TERRITORY,
}
function CollectiveGoalsView:__init()
	self.ui_config = {"uis/views/serveractivity/goals_prefab", "CollectiveGoalsView"}
	self.full_screen = true								-- 是否是全屏界面
	self.play_audio = true
	self.cell_list = {}
	self.select_index = 1
	self.act_sep = 1
	self.active_countdown = nil
	self.is_fist_open = true
end

function CollectiveGoalsView:ReleaseCallBack()
	if self.role_model  then
		self.role_model:DeleteMe()
		self.role_model = nil
	end
	if self.reward_item  then
		self.reward_item:DeleteMe()
		self.reward_item = nil
	end
	if self.effect_obj then
		GameObject.Destroy(self.effect_obj)
		self.effect_obj = nil
	end
	self.is_load_effect = nil
	
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	if self.reward_item then
		self.reward_item:DeleteMe()
		self.reward_item = nil
	end
	if self.active_countdown then
		GlobalTimerQuest:CancelQuest(self.active_countdown)
		self.active_countdown = nil
	end
end

-- 切换标签调用
function CollectiveGoalsView:ShowIndexCallBack(index)
	-- if self.is_fist_open then
	-- 	self.show_content:SetValue(false)
	-- 	self:FistOpenCallBack()
	-- end
	local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	self:SelectIndex(server_open_day)
end

function CollectiveGoalsView:FistOpenCallBack()
	TipsCtrl.Instance:OpenEffectView("effects2/prefab/ui_x/ui_chenggongtongyong_prefab", "UI_ChengGongTongYong", 1.5)
end

function CollectiveGoalsView:CloseCallBack()
	if self.active_countdown then
		GlobalTimerQuest:CancelQuest(self.active_countdown)
		self.active_countdown = nil
	end
end

function CollectiveGoalsView:LoadCallBack()
	self.effect_obj = nil
	self.is_load_effect = false

	self.first_effect = self:FindObj("FirstEffect")
	self.show_content = self:FindVariable("show_content")
	self:ListenEvent("Close", BindTool.Bind(self.Close, self))
	self:ListenEvent("GetReward", BindTool.Bind(self.OnClickGetReward, self))
	self:ListenEvent("ClickSkill", BindTool.Bind(self.OnClickSkill, self))
	self:ListenEvent("JumpTo", BindTool.Bind(self.OnClickJumpTo, self))
	self.end_time = self:FindVariable("times")
	self.top_title = self:FindVariable("TopTitle")
	self.plot_desc = self:FindVariable("PlotDesc")
	self.reward_title = self:FindVariable("RewardTitle")
	self.reward_desc = self:FindVariable("RewardDesc")
	self.reward_duck = self:FindVariable("RewardDuck")
	self.role_name = self:FindVariable("RoleName")
	self.is_item = self:FindVariable("is_item")
	self.can_press = self:FindVariable("CanPress")
	self.btn_text = self:FindVariable("BtnText")
	self.skill_icon = self:FindVariable("SkillIcon")
	self.title_icon = self:FindVariable("TitleIcon")
	self.role_desc = self:FindVariable("RoleDesc")
	self.time_end = self:FindVariable("TimeEnd")
	self.black_bg = self:FindVariable("BlackBg")
	self.jump_icon = self:FindVariable("JumpIcon")
	self.activity_icon = self:FindVariable("ActivityIcon")
	self.role_display = self:FindObj("Display")
	self.role_model = RoleModel.New()
	self.role_model:SetDisplay(self.role_display.ui3d_display)

	self.reward_item = ItemCell.New(self:FindObj("RewardItem"))

	self.btn_list = self:FindObj("BtnList")
	local list_delegate = self.btn_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.CellRefresh, self)
end

function CollectiveGoalsView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ZHENG_BA,
		RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH_BATTE_INFO)

	if self.active_countdown then
		GlobalTimerQuest:CancelQuest(self.active_countdown)
		self.active_countdown = nil
	end
	self.active_countdown = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateCountDown, self), 0.5)
	self:Flush()
end

function CollectiveGoalsView:OnFlush()
	local title_data = CollectiveGoalsData.Instance:GetTitleSingleCfg(self.act_sep)
	local goals_data = CollectiveGoalsData.Instance:GetGoalsSingleCfg(self.act_sep)

	self:FlushAllCell()
	if not title_data or not goals_data then return end

	self.top_title:SetValue(goals_data.chapter_title)
	self.plot_desc:SetValue(goals_data.chapter_describe)
	self.reward_title:SetValue(Language.CollectiveGoals.ChapterReward)
	self.jump_icon:SetValue(CollectiveGoalsData.Instance:IsShowJumpIcon(self.act_sep))

	local bundle, asset = ResPath.GetJumpIcon(self.act_sep)
	self.activity_icon:SetAsset(bundle, asset)
	local bundle, asset = ResPath.GetTitleIcon(title_data.title_id)
	self.title_icon:SetAsset(bundle, asset)
	local bundle, asset = ResPath.GetSkillGoalsIcon(goals_data.skill_type)
	self.skill_icon:SetAsset(bundle, asset)

	self:FlushBtn()
	-- 优先显示物品 有多个物品只显示第一个
	local reward_desc_str = string.format(Language.CollectiveGoals.GetWay, title_data.act_name, goals_data.complete_score)
	local skill_desc_str = ""
	if goals_data.is_has_reward == 1 then
		self.reward_item:SetData(goals_data.item_reward[0])
		self.is_item:SetValue(true)
		skill_desc_str = goals_data.skill_desc
	elseif goals_data.skill_type > 0 then
		self.is_item:SetValue(false)
		skill_desc_str = string.gsub(goals_data.skill_desc, "%b()%%", function (str)
			return (tonumber(goals_data[string.sub(str, 2, -3)]) / 100) .. "%"
		end)
		skill_desc_str = string.gsub(skill_desc_str, "%b[]%%", function (str)
			return goals_data[string.sub(str, 2, -3)] / 100 .. "%"
		end)
		skill_desc_str = string.gsub(skill_desc_str, "%[.-%]", function (str)
			return goals_data[string.sub(str, 2, -2)]
		end)
	end
	self.reward_desc:SetValue(reward_desc_str)
	self.reward_duck:SetValue(skill_desc_str)
	self.role_desc:SetValue(string.format(Language.CollectiveGoals.First, title_data.act_name))

	local role_info_list = KaifuActivityData.Instance:GetBattleRoleInfo()
	local single_role_info = role_info_list[self.act_sep]
	if not single_role_info then
		self.role_model:ClearModel()
		self.role_name:SetValue("")
		self.black_bg:SetValue(true)
		return
	end
	self:SetRoleModelInfo(single_role_info)
	self.black_bg:SetValue(false)
end

function CollectiveGoalsView:SetRoleModelInfo(role_info)
	self.role_model:SetModelResInfo(role_info, nil, nil, true)
	self.role_name:SetValue(role_info.role_name)
end

function CollectiveGoalsView:OnClickGetReward()
	local goals_data = CollectiveGoalsData.Instance:GetGoalsSingleCfg(self.act_sep)
	PersonalGoalsCtrl.Instance:SendRoleGoalOperaReq(PERSONAL_GOAL_OPERA_TYPE.FETCH_BATTLE_FIELD_GOAL_REWARD_REQ, goals_data.field_type)
	local can_get_flag = PersonalGoalsData.Instance:GetGolasRewardFlag()

	if can_get_flag and goals_data.skill_type ~= 0 then
		-- TipsCtrl.Instance:ShowOpenFunFlyView(nil, true, goals_data.skill_type)
	end
end

function CollectiveGoalsView:GetNumberOfCells()
	return #CollectiveGoalsData.Instance:GetActiveCfg()
end

function CollectiveGoalsView:CellRefresh(cell, data_index)
	data_index = data_index + 1
	local tmp_cell = self.cell_list[cell]
	if tmp_cell == nil then
		self.cell_list[cell] = CollectiveGoalsBtn.New(cell)
		tmp_cell = self.cell_list[cell]
		tmp_cell:SetParent(self)
	end
	local title_data = KaifuActivityData.Instance:GetBattleTitleCfg()
	local data = {}
	data.data_index = data_index
	data.act_seq = 0
	if title_data[data_index] then
		data.act_sep = title_data[data_index].act_sep
	end
	tmp_cell:SetData(data)
end

function CollectiveGoalsView:OnCellSelect(data_index, act_sep)
	self.select_index = data_index
	self.act_sep = act_sep
end

function CollectiveGoalsView:SelectIndex(data_index)
	self.select_index = data_index
	local title_data = KaifuActivityData.Instance:GetBattleTitleCfg()
	if title_data[data_index] then
		self.act_sep = title_data[data_index].act_sep
	end
end

function CollectiveGoalsView:GetCurSelectIndex()
	return self.select_index
end

function CollectiveGoalsView:FlushAllHL()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end

function CollectiveGoalsView:FlushAllCell()
	for k,v in pairs(self.cell_list) do
		v:Flush()
	end
end

function CollectiveGoalsView:UpdateCountDown()
	local str, _ = CollectiveGoalsData.Instance:GetNextTime()
	self.end_time:SetValue(str)
	if str == "" then
		self.time_end:SetValue(false)
	end
end

function CollectiveGoalsView:FlushBtn()
	local goals_data = CollectiveGoalsData.Instance:GetGoalsSingleCfg(self.act_sep)
	local can_get_flag = PersonalGoalsData.Instance:GetGolasRewardFlag()
	local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()

	can_get_flag =  0 ~= bit:_and(can_get_flag, bit:_lshift(1, goals_data.field_type))
	local has_get_flag = PersonalGoalsData.Instance:GetGolasHasGetFlag()
	has_get_flag =  0 ~= bit:_and(has_get_flag, bit:_lshift(1, goals_data.field_type))
	self.can_press:SetValue(can_get_flag and not has_get_flag)

	local brn_str = Language.CollectiveGoals.CanNotGet
	if can_get_flag and goals_data.open_server_day == server_open_day then
		brn_str = Language.CollectiveGoals.CanGet
	end
	if has_get_flag or goals_data.open_server_day < server_open_day then
		brn_str = Language.CollectiveGoals.HasGet
		self.can_press:SetValue(false)
	end
	self.btn_text:SetValue(brn_str)
end

function CollectiveGoalsView:OnClickSkill()

end

function CollectiveGoalsView:OnClickJumpTo()
	self:OpenView()
	self:Close()
end

function CollectiveGoalsView:OpenView()
	self:OpenActivityView(INDEXTOACTIVITYID[self.act_sep])
end

--打开活动面板
function CollectiveGoalsView:OpenActivityView(activity_type)
	if activity_type == ACTIVITY_TYPE.CLASH_TERRITORY then
	-- 	ViewManager.Instance:Open(ViewName.ClashTerritory)
	-- else
		ActivityCtrl.Instance:ShowDetailView(activity_type)
	end
end

------------------------------ CollectiveGoalsBtn -------------------------
CollectiveGoalsBtn = CollectiveGoalsBtn or BaseClass(BaseCell)
function CollectiveGoalsBtn:__init()
	self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))
	self.show_hl = self:FindVariable("show_hl")
	self.top_title = self:FindVariable("TopTitle")
	self.show_red_point = self:FindVariable("show_red_point")
end

function CollectiveGoalsBtn:__delete()
	self.parent = nil
end

function CollectiveGoalsBtn:SetParent(parent)
	self.parent = parent
end

function CollectiveGoalsBtn:OnClick()
	if self.data.data_index <= TimeCtrl.Instance:GetCurOpenServerDay() then
		local select_index = self.parent:GetCurSelectIndex()
		if select_index == self.data.data_index then
			return
		end
		self.parent:OnCellSelect(self.data.data_index, self.data.act_sep)
		self.parent:FlushAllHL()
		self.parent:Flush()
		self:Flush()
	end
end

function CollectiveGoalsBtn:OnFlush()
	local title_data = CollectiveGoalsData.Instance:GetTitleSingleCfg(self.data.act_sep)
	local goals_data = CollectiveGoalsData.Instance:GetGoalsSingleCfg(self.data.act_sep)
	if not title_data or not goals_data then return end
	if self.data.data_index > TimeCtrl.Instance:GetCurOpenServerDay() then
		self.top_title:SetValue("????")
	else
		self.top_title:SetValue(goals_data.chapter_title)
	end
	self.show_red_point:SetValue(CollectiveGoalsData.Instance:GetRedPointBySeq(self.data.data_index))
	self:FlushHL()
end

function CollectiveGoalsBtn:FlushHL()
	local select_index = self.parent:GetCurSelectIndex()
	self.show_hl:SetValue(select_index == self.data.data_index)
end