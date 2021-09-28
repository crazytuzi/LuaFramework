WorldBossRankRewardView = WorldBossRankRewardView or BaseClass(BaseView)

function WorldBossRankRewardView:__init()
	self.ui_config = {"uis/views/bossview_prefab","WordBossRankRewardView"}
	self.view_layer = UiLayer.Pop
	self.reward_data = {}
end

function WorldBossRankRewardView:__delete()

end

function WorldBossRankRewardView:ReleaseCallBack()
	for k,v in pairs(self.item_panel_list) do
		v:DeleteMe()
	end
	self.item_panel_list = {}
	self.reward_data = {}
	self.list_view = nil
end

function WorldBossRankRewardView:LoadCallBack()
	self.item_panel_list = {}
	self.list_view = self:FindObj("ListView")
	local list_view_delegate = self.list_view.list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
	self:ListenEvent("OnClickClose",
		BindTool.Bind(self.Close, self))
end

function WorldBossRankRewardView:GetNumberOfCells()
	return #self.reward_data
end

function WorldBossRankRewardView:RefreshView(cell, data_index)
	data_index = data_index + 1
	local boss_cell = self.item_panel_list[cell]
	if boss_cell == nil then
		boss_cell = WorldBossRankRewardCell.New(cell.gameObject)
		self.item_panel_list[cell] = boss_cell
	end
	boss_cell:SetIndex(data_index)
	boss_cell:SetData(self.reward_data[data_index])
end

function WorldBossRankRewardView:OpenCallBack()
	self:Flush()
end

function WorldBossRankRewardView:CloseCallBack()
	self.reward_data = {}
end

function WorldBossRankRewardView:OnFlush()
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshActiveCellViews()
	end
end

function WorldBossRankRewardView:GetActiveBossRewardList(scene_id)
	local boss_id = BossData.Instance:GetActiveBossIdBySceneId(scene_id)
	local list = BossData.Instance:GetActiveBossHurtRewardList(boss_id)
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local prof = main_vo.prof or 1
	local reward_list = {}
	if nil == list or nil == next(list) then
		return reward_list
	end

	for k,v in pairs(list) do
		local reward_single_list = {}
		reward_single_list.bossid = v.bossid
		reward_single_list.rank = v.rank
		reward_single_list.reward_item = v["reward_item_" .. prof]
		reward_list[k] = reward_single_list
	end

	return reward_list
end

function WorldBossRankRewardView:SetData(open_type)
	local scene_id = Scene.Instance:GetSceneId()
	if open_type and open_type == BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE then
		self.reward_data = self:GetActiveBossRewardList(scene_id)
	else
		local boss_id = BossData.Instance:GetWorldBossIdBySceneId(scene_id)
		self.reward_data = BossData.Instance:GetBossHurtRewardList(boss_id)
	end

	self:Flush()
end

--------------------------------------WorldBossRankRewardCell-----------------------------------------

WorldBossRankRewardCell = WorldBossRankRewardCell or BaseClass(BaseCell)

function WorldBossRankRewardCell:__init()
	self.rank = self:FindVariable("rank")
	self.item_cell_list = {}
	for i = 1, 3 do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self:FindObj("ItemCell" .. i))
	end
end

function WorldBossRankRewardCell:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function WorldBossRankRewardCell:OnFlush()
	if self.data then
		local rank = self.data.rank_value or self.data.rank
		self.rank:SetValue(rank)
		for i = 1, 3 do
			local data = self.data.reward_item[i - 1]
			self.item_cell_list[i]:SetParentActive(data ~= nil)
			if data then
				self.item_cell_list[i]:SetData(data)
			end
		end
	end
end