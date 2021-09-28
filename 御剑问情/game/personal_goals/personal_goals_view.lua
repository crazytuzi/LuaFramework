PersonalGoalsView = PersonalGoalsView or BaseClass(BaseView)

function PersonalGoalsView:__init()
	self.ui_config = {"uis/views/serveractivity/goals_prefab", "PersonalGoalsView"}

	self.cell_list = {}
	self.select_index = 1
	self.goal_desc = {}
	self.goal_param = {}
	self.show_desc = {}
	self.is_fist_open = true

end

function PersonalGoalsView:__delete()
	self.is_fist_open = true
end

function PersonalGoalsView:ReleaseCallBack()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.PersonalGoals)
	end
	self:RemoveDelayTime()
	if nil ~= self.reward_item then
		self.reward_item:DeleteMe()
		self.reward_item = nil
	end

	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}
	self.finish_list = {}

	if self.effect_obj then
		GameObject.Destroy(self.effect_obj)
		self.effect_obj = nil
	end
	self.is_load_effect = nil

	-- 清理变量和对象
	self.first_effect = nil
	self.word_effect = nil
	self.btn_close = nil
	self.target_reward_btn = nil
	self.chapter_name = nil
	self.chapter_desc = nil
	self.chapter_time = nil
	self.can_reward = nil
	self.reward_text = nil
	self.show_rp = nil
	self.reward_gold_num = nil
	self.show_content = nil
	self.show_word_content = nil
	self.bubbles_box = nil
	self.bubbles_text = nil
	self.finish_list = nil
	self.need_go_list = nil
	self.arrow_list = nil
	for i = 1, 3 do
		self.goal_desc[i] = nil
		self.show_desc[i] = nil
	end
	self.list_view = nil
end

function PersonalGoalsView:ShowIndexCallBack(index)
	-- if self.is_fist_open then
	-- 	self.show_content:SetValue(false)
	-- 	self:FistOpenCallBack()
	-- end
	local max_chaper = PersonalGoalsData.Instance:GetMaxChapter()
	local old_chapter = PersonalGoalsCtrl.Instance.data:GetOldChapter()
	self:SetSelectIndex(old_chapter + 1 <= max_chaper and old_chapter + 1 or old_chapter)
	local delay_time = self.is_fist_open and 1.8 or 0.3
	self:DelayFlushList(0.3)
end

function PersonalGoalsView:DelayFlushList(delay_time)
	self.delay_flush_list = GlobalTimerQuest:AddDelayTimer(function()
		self.list_view.scroll_rect.verticalNormalizedPosition = 0
		self:RemoveDelayTime()
	end, delay_time)
end

function PersonalGoalsView:RemoveDelayTime()
	if self.delay_flush_list then
		GlobalTimerQuest:CancelQuest(self.delay_flush_list)
		self.delay_flush_list = nil
	end
end

function PersonalGoalsView:FistOpenCallBack()
	TipsCtrl.Instance:OpenEffectView("effects2/prefab/ui_x/ui_chenggongtongyong_prefab", "UI_ChengGongTongYong", 1.5)
end

function PersonalGoalsView:AfterRewardCallBack()
	TipsCtrl.Instance:OpenEffectView("effects2/prefab/ui_x/ui_chenggongtongyong_prefab", "UI_ChengGongTongYong", 1.5)
end

function PersonalGoalsView:LoadCallBack()
	self.effect_obj = nil
	self.is_load_effect = false

	self.first_effect = self:FindObj("FirstEffect")
	self.word_effect = self:FindObj("WordEffect")

	--引导用函数
	self.btn_close = self:FindObj("BtnClose")
	self.target_reward_btn = self:FindObj("RewardBtn")

	self.chapter_name = self:FindVariable("chapter_name")
	self.chapter_desc = self:FindVariable("chapter_desc")
	self.chapter_time = self:FindVariable("time_text")
	self.can_reward = self:FindVariable("can_reward")
	self.reward_text = self:FindVariable("reward_text")
	self.show_rp = self:FindVariable("show_rp")
	self.reward_gold_num = self:FindVariable("reward_gold_num")
	self.show_content = self:FindVariable("show_content")
	self.show_word_content = self:FindVariable("show_word_content")
	self.bubbles_box = self:FindVariable("bubbles_box")
	self.bubbles_text = self:FindVariable("bubbles_text")
	self.finish_list = {}
	self.need_go_list = {}
	self.arrow_list = {}
	for i = 1, 3 do
		self.goal_desc[i] = self:FindVariable("goal_desc_" .. i)
		self.show_desc[i] = self:FindVariable("show_goal_desc" .. i)
		self.finish_list[i] = self:FindVariable("show_finish_" .. i)
		self.arrow_list[i] = self:FindVariable("show_arrow" .. i)
		self:ListenEvent("OnClickGo" .. i,
			BindTool.Bind(self.OnGoClick, self, i))
		self.need_go_list[i] = self:FindVariable("need_go" .. i)
	end
	self.reward_item = ItemCell.New()
	self.reward_item:SetInstanceParent(self:FindObj("RewardCell"))

	self.list_view = self:FindObj("ChapterList")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self:ListenEvent("Close", BindTool.Bind(self.HandleClose, self))
	self:ListenEvent("OnClickReward", BindTool.Bind(self.OnClickReward, self))

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.PersonalGoals, BindTool.Bind(self.GetUiCallBack, self))
end

function PersonalGoalsView:HandleClose()
	self:Close()
end

function PersonalGoalsView:OnClickReward()
	PersonalGoalsData.Instance:SetReWardIndex(self.select_index)
	PersonalGoalsCtrl.Instance:SendRoleGoalOperaReq(PERSONAL_GOAL_OPERA_TYPE.FETCH_PERSONAL_GOAL_REWARD_REQ, self.select_index)
end

function PersonalGoalsView:OpenCallBack()
	PersonalGoalsCtrl.Instance:SendRoleGoalOperaReq(PERSONAL_GOAL_OPERA_TYPE.PERSONAL_GOAL_INFO_REQ)
end

function PersonalGoalsView:CloseCallBack()
	PersonalGoalsData.Instance:SetReWardIndex(-1)
end

function PersonalGoalsView:GetNumberOfCells()
	local chapter = PersonalGoalsCtrl.Instance.data:GetCurChapter()
	local old_chapter = PersonalGoalsCtrl.Instance.data:GetOldChapter()
	local max_chaper = PersonalGoalsData.Instance:GetMaxChapter()
	if old_chapter + 1 < max_chaper then
		return old_chapter + 1
	end
	return max_chaper
end

function PersonalGoalsView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local chapter_cell = self.cell_list[cell]
	if chapter_cell == nil then
		chapter_cell = PerSonalGoalsItem.New(cell.gameObject)
		chapter_cell.root_node.toggle.group = self.list_view.toggle_group
		chapter_cell.goal_view = self
		self.cell_list[cell] = chapter_cell
	end

	chapter_cell:SetItemIndex(data_index)
	chapter_cell:SetData({})
end

function PersonalGoalsView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function PersonalGoalsView:GetSelectIndex()
	return self.select_index or 1
end

function PersonalGoalsView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "after_reward" then
			-- self.show_word_content:SetValue(false)
			-- self:AfterRewardCallBack()
			local max_chaper = PersonalGoalsData.Instance:GetMaxChapter()
			local cur_chapter = PersonalGoalsData.Instance:GetOldChapter()
			if cur_chapter + 1 <= max_chaper then
				self:SetSelectIndex(cur_chapter + 1)
				self:DelayFlushList(1.8 - 1.5)
			end
		end
	end
	self:FlushInfo(self.select_index)
	self:FlushChapterListNum()
end

function PersonalGoalsView:BubblesBox(index)
	local old_chapter = PersonalGoalsCtrl.Instance.data:GetOldChapter()
	local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if old_chapter == 2 and server_open_day <= 4 and index == old_chapter + 1 then
		self.bubbles_box:SetValue(true)
		self.bubbles_text:SetValue(Language.PersonalGoal.Getcollective)
	elseif
		old_chapter == 3 and index == old_chapter + 1 then
		self.bubbles_box:SetValue(true)
		self.bubbles_text:SetValue(Language.PersonalGoal.Getmolongmibao)
	else
		self.bubbles_box:SetValue(false)
		self.bubbles_text:SetValue("")
	end
	-- if old_chapter == 3 and index == old_chapter + 1 then
	-- 	self.bubbles_box:SetValue(true)
	-- 	self.bubbles_text:SetValue(Language.PersonalGoal.Getmolongmibao)
	-- else
	-- 	self.bubbles_box:SetValue(false)
	-- 	self.bubbles_text:SetValue("")
	-- end
end

function PersonalGoalsView:FlushInfo(index)
	local max_chaper = PersonalGoalsData.Instance:GetMaxChapter()
	if index > max_chaper then return end
	local prof = PlayerData.Instance:GetRoleBaseProf()
	local chapter_cfg = PersonalGoalsCtrl.Instance.data:GetPersonalGoalCfgByChapter(index)
	local goal_cfg = PersonalGoalsCtrl.Instance.data:GetGoalDescByChapter(index)
	local gold_data_list = PersonalGoalsCtrl.Instance.data:GetGoalDataList()
	local cur_chapter = PersonalGoalsCtrl.Instance.data:GetCurChapter()

	self.chapter_name:SetValue(chapter_cfg.chapter_title)
	self.chapter_desc:SetValue(chapter_cfg.chapter_describe)
	self.reward_item:SetData(chapter_cfg["prof_reward" .. prof][0])
	local item_cfg = ItemData.Instance:GetItemConfig(chapter_cfg["prof_reward" .. prof][0].item_id)
	if item_cfg.param1 then
		self.reward_gold_num:SetValue(item_cfg.param1)
	end
	self.chapter_time:SetValue(chapter_cfg.time)
	self.show_arrow_index = 0
	for i = 1, 3 do
		local desc = string.format(goal_cfg[i].target_desc, index == cur_chapter + 1 and gold_data_list[i - 1] or goal_cfg[i].cond_param1, goal_cfg[i].cond_param1)
		if PersonalGoalsData.Instance:GetIsUpgrade(goal_cfg[i].cond_type) then
			if index ~= cur_chapter + 1 then
				desc = string.format(goal_cfg[i].target_desc, goal_cfg[i].cond_param1 - 1, goal_cfg[i].cond_param1 - 1)
			else
				if gold_data_list[i - 1] ~= 0 then
					desc = string.format(goal_cfg[i].target_desc, gold_data_list[i - 1] - 1, goal_cfg[i].cond_param1 - 1)
				end
			end
		end
		if goal_cfg[i].cond_type == 22 then
			desc = string.format(goal_cfg[i].target_desc, index == cur_chapter + 1 and gold_data_list[i - 1] >= goal_cfg[i].cond_param1
			and  gold_data_list[i - 1] or 0, goal_cfg[i].cond_param1)
		end
		local perpose_num = index == cur_chapter + 1 and gold_data_list[i - 1] or goal_cfg[i].cond_param1
		self.goal_desc[i]:SetValue(ToColorStr(desc, perpose_num >= goal_cfg[i].cond_param1 and TEXT_COLOR.GRAY_1 or TEXT_COLOR.RED))
		self.show_desc[i]:SetValue(goal_cfg[i].cond_type ~= 0)
		self.finish_list[i]:SetValue(perpose_num >= goal_cfg[i].cond_param1)
		local goto_panel = PersonalGoalsData.Instance:GetOpenPanelByType(goal_cfg[i].goto_panel_type)
		self.need_go_list[i]:SetValue(goto_panel ~= "")
		if goto_panel ~= "" and perpose_num < goal_cfg[i].cond_param1 then
			if 0 == self.show_arrow_index then
				self.show_arrow_index = i
			end
		end
	end
	for i = 1 ,3 do
		self.arrow_list[i]:SetValue(self.show_arrow_index == i)
	end
	local old_chapter = PersonalGoalsCtrl.Instance.data:GetOldChapter()
	self.can_reward:SetValue(index > old_chapter and index <= cur_chapter)
	self.show_rp:SetValue(index > old_chapter and cur_chapter == index)
	self.reward_text:SetValue(index > old_chapter and Language.PersonalGoal.Fetch or Language.PersonalGoal.HasFetch)
	-- self:BubblesBox(self.select_index)
end

function PersonalGoalsView:FlushChapterListNum()
	if self.list_view then
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function PersonalGoalsView:FlushAllHL()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end

function PersonalGoalsView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end

function PersonalGoalsView:OnGoClick(i)
	local goal_cfg = PersonalGoalsCtrl.Instance.data:GetGoalDescByChapter(self.select_index)
	local goto_panel = PersonalGoalsData.Instance:GetOpenPanelByType(goal_cfg[i].goto_panel_type)
	if goto_panel == 34 or goto_panel == 35 or goto_panel == 38 then
		local func = function ()
			StoryCtrl.Instance:DirectEnter(goto_panel)
		end
		local str = ""
		if goto_panel == 34 then
			str = Language.PersonalGoal.GetInHusong
		elseif goto_panel == 35 then
			str = Language.PersonalGoal.GetInShuiJing
		elseif goto_panel == 38 then
			str = Language.PersonalGoal.GetInBOSS
		end
		TipsCtrl.Instance:ShowCommonAutoView(nil, str, func)
		return
	end
	if goto_panel ~= "" then
		if goto_panel == "GuildTask" then
			local task_id = TaskData.Instance:GetRandomTaskIdByType(TASK_TYPE.GUILD)
			if task_id == nil or task_id == 0 then
				TipsCtrl.Instance:ShowSystemMsg(Language.BaoJu.NotGuildTask)
				return
			end
			TaskCtrl.Instance:DoTask(task_id)
			ViewManager.Instance:Close(ViewName.PersonalGoals)
			return
		elseif goto_panel == "DailyTask"then
			local task_id = TaskData.Instance:GetRandomTaskIdByType(TASK_TYPE.RI)
			if task_id == nil or task_id == 0 then
				TipsCtrl.Instance:ShowSystemMsg(Language.BaoJu.NotDailyTask)
				return
			end
			TaskCtrl.Instance:DoTask(task_id)
			ViewManager.Instance:Close(ViewName.PersonalGoals)
			return
		elseif goto_panel == "HuSong"then
			ViewManager.Instance:Close(ViewName.PersonalGoals)
			YunbiaoCtrl.Instance:MoveToHuShongReceiveNpc()
			return
		end
		if goto_panel ~= "PersonalTips" then
			ViewManager.Instance:Close(ViewName.PersonalGoals)
		end
		local t = Split(goto_panel, "#")
		local view_name = t[1]
		local tab_index = t[2]
		if view_name == "FuBen" then
			FuBenCtrl.Instance:SendGetPhaseFBInfoReq()
			FuBenCtrl.Instance:SendGetExpFBInfoReq()
			FuBenCtrl.Instance:SendGetStoryFBGetInfo()
			FuBenCtrl.Instance:SendGetVipFBGetInfo()
			FuBenCtrl.Instance:SendGetTowerFBGetInfo()
		elseif view_name == "Activity" then
			ActivityCtrl.Instance:ShowDetailView(ACTIVITY_TYPE[tab_index])
			return
		end
		ViewManager.Instance:Open(view_name, TabIndex[tab_index])
	end
end

---------------------PerSonalGoalsItem--------------------------------
PerSonalGoalsItem = PerSonalGoalsItem or BaseClass(BaseCell)

function PerSonalGoalsItem:__init(instance)
	self.goal_view = nil
	self.show_hl = self:FindVariable("show_hl")
	self.show_rp = self:FindVariable("show_rp")
	self.chapter_text = self:FindVariable("chapter_text")

	self:ListenEvent("ClickItem", BindTool.Bind(self.OnClickItem, self))
end

function PerSonalGoalsItem:__delete()
	self.goal_view = nil
end

function PerSonalGoalsItem:SetItemIndex(index)
	self.item_index = index
end

function PerSonalGoalsItem:OnFlush()
	self:FlushHL()
	local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local old_chapter = PersonalGoalsCtrl.Instance.data:GetOldChapter()
	local cur_chapter = PersonalGoalsCtrl.Instance.data:GetCurChapter()
	-- if old_chapter == 2 and server_open_day <= 4 and self.item_index == old_chapter + 1 then  -- 屏蔽灭世之战
	-- 	self.chapter_text:SetValue(Language.PersonalGoal.CollectiveText)
	-- elseif
	if old_chapter == 3 and self.item_index == old_chapter + 1 then
		self.chapter_text:SetValue(Language.PersonalGoal.MolongmibaoText)
	else
		self.chapter_text:SetValue(string.format(Language.PersonalGoal.Chapter, CommonDataManager.GetDaXie(self.item_index)))
	end
	self.show_rp:SetValue(self.item_index > old_chapter and cur_chapter >= self.item_index)
end

function PerSonalGoalsItem:OnClickItem(is_click)
	if is_click then
		local select_index = self.goal_view:GetSelectIndex()
		local has_reward_index = PersonalGoalsCtrl.Instance.data:GetOldChapter()
		-- if has_reward_index + 1 < self.item_index then
		-- 	SysMsgCtrl.Instance:ErrorRemind(Language.PersonalGoal.GetPrevReward)
		-- 	return
		-- end
		if select_index == self.item_index then
			return
		end
		self.goal_view:SetSelectIndex(self.item_index)
		self.goal_view:FlushAllHL()
		self.goal_view:FlushInfo(self.item_index)
	end
end

function PerSonalGoalsItem:FlushHL()
	local select_index = self.goal_view:GetSelectIndex()
	self.show_hl:SetValue(select_index == self.item_index)
end