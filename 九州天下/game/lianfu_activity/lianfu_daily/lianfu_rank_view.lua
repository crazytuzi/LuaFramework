LianFuRankView = LianFuRankView or BaseClass(BaseView)

function LianFuRankView:__init()
	self.ui_config = {"uis/views/lianfuactivity/lianfudaily", "LianFuRankView"}
	self.play_audio = true
	self.is_async_load = false
	self.active_close = false
	self:SetMaskBg(true)

	self.cell_list = {}
end

function LianFuRankView:__delete()
end

function LianFuRankView:ReleaseCallBack()
	self.name = nil
	self.server = nil
	self.level = nil
	self.power = nil
	self.contribution = nil
	self.reward = nil
	self.show_female = nil
	self.rank = nil
	self.show_rank_img = nil
	self.rank_img = nil
	self.rank_list = nil

	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}
end

function LianFuRankView:OpenCallBack()

end

function LianFuRankView:LoadCallBack()
	self.name = self:FindVariable("Name")
	self.server = self:FindVariable("Server")
	self.level = self:FindVariable("Level")
	self.power = self:FindVariable("Power")
	self.contribution  = self:FindVariable("Contribution")
	self.reward = self:FindVariable("Reward")
	self.show_female = self:FindVariable("ShowFeMale")
	self.rank = self:FindVariable("Rank")
	self.show_rank_img = self:FindVariable("ShowRankImg")
	self.rank_img = self:FindVariable("RankImg")
	self.rank_list = self:FindObj("RankList")

	local list_view_delegate = self.rank_list.list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self:ListenEvent("OnClickRank1", BindTool.Bind(self.OnClickRank, self, 0))
	self:ListenEvent("OnClickRank2", BindTool.Bind(self.OnClickRank, self, 1))
	self:ListenEvent("Close", BindTool.Bind(self.Close, self))

	RankCtrl.Instance:SendCrossGetPersonRankList(CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_SERVER_GROUP_1_CONTRIBUTE)
end

function LianFuRankView:GetNumberOfCells()
	return #RankData.Instance:GetCrossPersonRankList()
end

function LianFuRankView:RefreshView(cell, data_index)
	data_index = data_index + 1

	local rank_cell = self.cell_list[cell]
	if rank_cell == nil then
		rank_cell = LianFuRankItemCell.New(cell.gameObject)
		self.cell_list[cell] = rank_cell
	end
	rank_cell:SetIndex(data_index)
	local data = RankData.Instance:GetCrossPersonRankList()
	rank_cell:SetData(data[data_index])
end

function LianFuRankView:OnFlush(param_t)
	if self.rank_list then
		self.rank_list.scroller:ReloadData(0)
	end

	local rank, my_rank = LianFuDailyData.Instance:GetMyRankInfo()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if nil == next(my_rank) then
		self.name:SetValue(vo.name)
		local server_name = LoginData.Instance:GetShowServerNameById(vo.origin_merge_server_id)
		self.server:SetValue(server_name)
		self.level:SetValue(vo.level)
		self.power:SetValue(vo.capability)
		self.contribution:SetValue(0)
		self.reward:SetValue(0)
		self.show_female:SetValue(vo.sex == GameEnum.FEMALE)
		self.show_rank_img:SetValue(false)
		self.rank:SetValue(Language.LianFuDaily.WeiShangBang)
	else
		self.name:SetValue(my_rank.user_name)
		local server_name = LoginData.Instance:GetShowServerNameById(my_rank.server_id)
		self.server:SetValue(server_name)
		self.level:SetValue(my_rank.level)
		self.power:SetValue(my_rank.capability)
		self.contribution:SetValue(my_rank.rank_value)
		self.show_female:SetValue(my_rank.sex == GameEnum.FEMALE)
		self.show_rank_img:SetValue(rank <= 3)
		if rank <= 3 then
			self.rank_img:SetAsset(ResPath.GetImages("rank_" .. rank))
		else
			self.rank:SetValue(rank)
		end

		local source_item_list = LianFuDailyData.Instance:GetSourceItemList()
		local gold = source_item_list[vo.server_group + 1].server_gold
		local reward = LianFuDailyData.Instance:GetRewardByRank(rank - 1)
		self.reward:SetValue(math.floor(gold * reward / 10000))
	end
end

function LianFuRankView:OnClickRank(rank_type)
	if rank_type == 0 then
		RankCtrl.Instance:SendCrossGetPersonRankList(CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_SERVER_GROUP_1_CONTRIBUTE)
	else
		RankCtrl.Instance:SendCrossGetPersonRankList(CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_SERVER_GROUP_2_CONTRIBUTE)
	end
end

------------------------LianFuRankItemCell------------------------------
LianFuRankItemCell = LianFuRankItemCell or BaseClass(BaseCell)

function LianFuRankItemCell:__init()
	self.name = self:FindVariable("Name")
	self.server = self:FindVariable("Server")
	self.level = self:FindVariable("Level")
	self.power = self:FindVariable("FightPower")
	self.contribution  = self:FindVariable("Contribution")
	self.reward = self:FindVariable("Reward")
	self.show_female = self:FindVariable("ShowFemale")
	self.rank = self:FindVariable("Rank")
	self.show_rank_img = self:FindVariable("ShowRankImg")
	self.rank_img = self:FindVariable("RankImg")
	self.gray = self:FindVariable("Gray")
end

function LianFuRankItemCell:__delete()
	
end

function LianFuRankItemCell:OnFlush()
	if nil == self.data or nil == next(self.data) then return end

	self.name:SetValue(self.data.user_name)
	local server_name = LoginData.Instance:GetShowServerNameById(self.data.server_id)
	self.server:SetValue(server_name)
	self.level:SetValue(self.data.level)
	self.power:SetValue(self.data.capability)
	self.contribution:SetValue(self.data.rank_value)
	self.show_female:SetValue(self.data.sex == GameEnum.FEMALE)

	self.show_rank_img:SetValue(self.index <= 3)
	if self.index <= 3 then
		self.rank_img:SetAsset(ResPath.GetImages("rank_" .. self.index))
	else 
		self.rank:SetValue(self.index)
	end
	self.gray:SetValue(self.data.is_online == 1)

	local source_item_list = LianFuDailyData.Instance:GetSourceItemList()
	local gold = source_item_list[self.data.server_group + 1].server_gold
	local reward = LianFuDailyData.Instance:GetRewardByRank(self.index - 1)
	self.reward:SetValue(math.floor(gold * reward / 10000))
end