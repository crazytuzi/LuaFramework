PersonalGoalsData = PersonalGoalsData or BaseClass()

PersonalGoal = {
		MinUpgrade = 24,
		MaxUpgrade = 29,
}

function PersonalGoalsData:__init()
	if PersonalGoalsData.Instance then
		print_error("[PersonalGoalsData] Attempt to create singleton twice!")
		return
	end
	PersonalGoalsData.Instance = self

	self.role_goal_cfg = ConfigManager.Instance:GetAutoConfig("rolegoalconfig_auto")
	self.personal_goal_cfg = self.role_goal_cfg.personal_goal
	self.open_panel_cfg = self.role_goal_cfg.other

	self.cur_chapter = 0
	self.old_chapter = 0
	self.goal_data_list = {}
	self.field_goal_can_fetch_flag = 0
	self.field_goal_fetch_flag = 0

	RemindManager.Instance:Register(RemindName.PersonalGoals, BindTool.Bind(self.GetIsShowRedPoint, self))
end

function PersonalGoalsData:__delete()
	RemindManager.Instance:UnRegister(RemindName.PersonalGoals)
	
	PersonalGoalsData.Instance = nil
end

function PersonalGoalsData:SetRoleGoalInfo(protocol)
	local falg = false
	if self.cur_chapter > self.old_chapter and protocol.cur_chapter == protocol.old_chapter then
		falg = true
	end
	self.cur_chapter = protocol.cur_chapter
	self.old_chapter = protocol.old_chapter
	self.goal_data_list = protocol.goal_data_list
	self.field_goal_can_fetch_flag = protocol.field_goal_can_fetch_flag
	self.field_goal_fetch_flag = protocol.field_goal_fetch_flag
	self.skill_level_list = protocol.skill_level_list
	GlobalEventSystem:Fire(OtherEventType.VIRTUAL_TASK_CHANGE, self.old_chapter, falg)
end

function PersonalGoalsData:GetSkillLevelList()
	local data_table = {}
	if not self.skill_level_list then return {} end
	for i = 2, 4 do
		local level = self.skill_level_list[i] or 0
		table.insert(data_table, level)
	end
	return data_table
end

function PersonalGoalsData:GetPersonalGoalCfgByChapter(chapter)
	local cfg = {}
	for k, v in pairs(self.personal_goal_cfg) do
		if v.chapter == chapter then
			cfg = v
		end
	end
	return cfg
end

function PersonalGoalsData:GetCurChapterTotalNum()
	local goal_cfg = self:GetGoalDescByChapter(self.old_chapter + 1)
	local max_count = 0
	for i = 1 , 3 do
		if goal_cfg[i].cond_type ~= 0 then
			max_count = max_count + 1
		end
	end
	return max_count
end

function PersonalGoalsData:GetCurchapterFinishNum()
	if self.cur_chapter > self.old_chapter then
		return self:GetCurChapterTotalNum()
	end
	local finish_count = 0
	local goal_cfg = self:GetGoalDescByChapter(self.old_chapter + 1)
	local gold_data_list = self:GetGoalDataList()
	for i = 1 , 3 do
		if nil ~= gold_data_list[i - 1] then
			local is_finish = gold_data_list[i - 1] >= goal_cfg[i].cond_param1
			if is_finish and goal_cfg[i].cond_type ~= 0 then
				finish_count = finish_count + 1
			end
		end

	end
	return finish_count
end

function PersonalGoalsData:GetMaxChapter()
	local max_chapter = 0
	for k,v in pairs(self.personal_goal_cfg) do
		max_chapter = max_chapter + 1
	end
	return max_chapter
end

function PersonalGoalsData:GetOpenPanelByType(open_type)
	local open_panel = ""
	for k,v in pairs(self.open_panel_cfg) do
		if v.type == open_type then
			open_panel = v.goto_panel
		end
	end
	return open_panel
end

function PersonalGoalsData:GetCurChapter()
	return self.cur_chapter
end

function PersonalGoalsData:GetOldChapter()
	return self.old_chapter
end

function PersonalGoalsData:GetGoalDataList()
	return self.goal_data_list
end

function PersonalGoalsData:GetGoalDescByChapter(chapter)
	local datalist = {}
	local cfg = self:GetPersonalGoalCfgByChapter(chapter)
	for i = 1, 3 do
		local data = {}
		data.target_desc = cfg["target" .. i .. "_dec"]
		data.cond_type = cfg["cond_type" .. i]
		data.goto_panel_type = cfg["goto_panel_" .. i]
		data.cond_param1 = cfg["cond_param" .. i .. "_1"]
		data.cond_param2 = cfg["cond_param" .. i .. "_2"]
		table.insert(datalist, data)
	end

	return datalist
end

function PersonalGoalsData:GetGolasRewardFlag()
	return self.field_goal_can_fetch_flag
end

function PersonalGoalsData:GetGolasHasGetFlag()
	return self.field_goal_fetch_flag
end

function PersonalGoalsData:GetIsShowRedPoint()
	local old_chapter = self:GetOldChapter()
	local cur_chapter = self:GetCurChapter()
	for i = 1, cur_chapter + 1 do
		if i > old_chapter and cur_chapter == i then
			return 1
		end
	end

	return 0
end

function PersonalGoalsData:GetIsUpgrade(cond_type)
	if cond_type >= PersonalGoal.MinUpgrade and cond_type <= PersonalGoal.MaxUpgrade then
		return true
	else
		return false
	end
end

function PersonalGoalsData:SetReWardIndex(reward_index)
	self.reward_index = reward_index
end

function PersonalGoalsData:GetReWardIndex()
	return self.reward_index or -1
end