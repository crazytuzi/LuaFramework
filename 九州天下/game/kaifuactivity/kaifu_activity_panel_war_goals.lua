KaifuActivityPanelWarGoals = KaifuActivityPanelWarGoals or BaseClass(BaseRender)

function KaifuActivityPanelWarGoals:__init(instance)
	self.cell_list = {}
	self.item_cell = {}
	self.temp_activity_type = {}
	self.war_goals_reward_item_list = {}
end

function KaifuActivityPanelWarGoals:LoadCallBack()
	self.task_state_desc = self:FindVariable("task_state_desc")
	self.goals_list = self:FindObj("GoalsList")

	self.list_view_delegate = self.goals_list.list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	for i = 1, 4 do
		self.item_cell[i] = ItemCell.New(self:FindObj("ItemCell" .. i))
		self.item_cell[i]:SetActive(false)
	end

	
	self.war_goal_info = KaifuActivityData.Instance:GetWarGoalsInfo()

	--self.get_reward_btn = self:FindObj("GetReward")
	self.show_get_reward_btn = self:FindVariable("show_get_reward")								--按钮状态
	self.show_un_get = self:FindVariable("show_un_get")
	self.show_had_get = self:FindVariable("show_had_get")
	self:ListenEvent("OnClickReceive", BindTool.Bind(self.OnClickReceive, self))
end

function KaifuActivityPanelWarGoals:__delete()
	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
			v = nil
		end
	end
	self.cell_list = {}

	if self.item_cell then 
		for k,v in pairs(self.item_cell) do
			v:DeleteMe()
		end
		self.item_cell = {}
	end
end

function KaifuActivityPanelWarGoals:SetCurTyoe(cur_type)
	self.cur_type = cur_type
end

function KaifuActivityPanelWarGoals:GetCurTyoe()
	return self.cur_type
end

function KaifuActivityPanelWarGoals:OnFlush()
	local activity_type = self.cur_type
	self.activity_type = activity_type or self.activity_type

	local num = KaifuActivityData.Instance:GetWarGoalsFinishNum()
	local str = Language.Activity.TaskReward
	if num < 5 then
		str = Language.Activity.TaskReward1
	else
		str = Language.Activity.TaskReward2
	end
	if self.goals_list ~= nil then
		self.goals_list.scroller:ReloadData(0)
	end
	self.task_state_desc:SetValue(string.format(str, num, 5))
	--self:SetGetRewardBtnState()
	self.temp_activity_type = activity_type
	self:SetWarGoalsFinalRewardItemData()
	self:SetGetRewardBtnState()
end

--创建item
function KaifuActivityPanelWarGoals:GetNumberOfCells()
	return 7
end

function KaifuActivityPanelWarGoals:RefreshView(cell, data_index)
	data_index = data_index + 1

	local goals_cell = self.cell_list[cell]
	if goals_cell == nil then
		goals_cell = WarGoalsItemCell.New(cell.gameObject,self)
		-- goals_cell.root_node.toggle.group = self.boss_list.toggle_group

		self.cell_list[cell] = goals_cell
	end
	goals_cell:SetIndex(data_index)				--把data_index  放到了单条item里的self.index里
	goals_cell:SetData()
end

--点击获取奖励
function KaifuActivityPanelWarGoals:OnClickReceive()
	local cfg = KaifuActivityData.Instance:GetWarGoalsInfo() or {}
	if cfg and cfg.final_reward_can_fetch_flag == 1 then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.temp_activity_type, RA_WAR_GOAL_REQ_TYPE.RA_WAR_GOAL_REQ_TYPE_FETCH_FINAL_REWARD)
		return
	end
	TipsCtrl.Instance:ShowSystemMsg(Language.Common.NoComplete)
end

--设置按钮状态
function KaifuActivityPanelWarGoals:SetGetRewardBtnState()
	-- --self.get_rewar_btn.button.interactable = flag == 2		--	设置按钮是否可点击 真则显示
	local flag = KaifuActivityData.Instance:GetWarGoalsInfo() or {}
	if next(flag)  then
		self.show_get_reward_btn:SetValue(flag.final_reward_can_fetch_flag == 1 and flag.final_reward_fetch_flag == 0) --任务完成且奖励未领取
		self.show_un_get:SetValue(flag.final_reward_can_fetch_flag == 0 and flag.final_reward_fetch_flag == 0)
		self.show_had_get:SetValue(flag.final_reward_fetch_flag == 1)
	end
end

--设置战事目标的终极奖励
function KaifuActivityPanelWarGoals:SetWarGoalsFinalRewardItemData()
	local reward_cfg = KaifuActivityData.Instance:GetWarGoalsFinalRewardCfg() or {}
	if reward_cfg == nil or reward_cfg[1].war_goal_final_reward == nil then return end
	local gift_list = reward_cfg[1].war_goal_final_reward
	for i=1,3 do
		self.item_cell[i]:SetData(gift_list[i - 1])
		self.item_cell[i]:SetActive(true)
	end
end

----------------------WarGoalsItemCell------------------------------
WarGoalsItemCell = WarGoalsItemCell or BaseClass(BaseCell)

WarGoalsItemCell.TabIndex = {
	TabIndex.national_warfare_dart,
	TabIndex.national_warfare_rescue,
	TabIndex.national_warfare_minister,
	TabIndex.national_warfare_flag,
	TabIndex.national_warfare_spy,
	TabIndex.national_warfare_brick,
	TabIndex.national_warfare_luck
}

function WarGoalsItemCell:__init(obj, parent_view)
	self.is_finish = self:FindVariable("is_finish")
	self.is_get = self:FindVariable("is_get")
	self.word_res = self:FindVariable("word_res")
	self.war_goals_item_cell = ItemCell.New()							--要用itemcell new出来才可以setdata
	self.war_goals_item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.war_goals_content = self:FindVariable("content")

	self:ListenEvent("OnClickGoto", BindTool.Bind(self.OnClickGoto, self))
	self.parent_view = parent_view
end

function WarGoalsItemCell:__delete()
	if self.war_goals_item_cell then
		self.war_goals_item_cell:DeleteMe()
		self.war_goals_item_cell = nil
	end
end

function WarGoalsItemCell:OnClickGoto()
	local war_goal_info = KaifuActivityData.Instance:GetWarGoalsInfo() or {}
	if war_goal_info.task_progress_list[self.index] == 1 then
		KaifuActivityCtrl.Instance:SendRandActivityOperaReq(self.parent_view:GetCurTyoe(), RA_WAR_GOAL_REQ_TYPE.RA_WAR_GOAL_REQ_TYPE_FETCH_REWARD, self.index - 1)
		return
	end

	ViewManager.Instance:Open(ViewName.NationalWarfare, WarGoalsItemCell.TabIndex[self.index])
	ViewManager.Instance:Close(ViewName.KaifuActivityView)
	self:Flush()
end

function WarGoalsItemCell:OnFlush()
	--if not self.data or not next(self.data) then return end
	local war_goal_info = KaifuActivityData.Instance:GetWarGoalsInfo() or {}
	local war_goals_item_info = KaifuActivityData.Instance:GetWarGoalsItemCellInfoCfg() or {}
	if war_goal_info then
		self.is_finish:SetValue( war_goal_info.task_fetch_reward_flag[33 - self.index] == 1)				
		self.is_get:SetValue(war_goal_info.task_progress_list[self.index] == 1)
	end

	self.war_goals_content:SetValue(war_goals_item_info[self.index].description)				--war_goals_item_info[self.index].description
	self.war_goals_item_cell:SetData(war_goals_item_info[self.index].reward_item)				--war_goals_item_info[self.index].reward_item
	self.word_res:SetAsset(ResPath.GetKaiFuActivityRes("word_" .. self.index))
end
