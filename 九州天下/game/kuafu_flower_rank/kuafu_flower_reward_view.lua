KuaFuFlowerRewardView = KuaFuFlowerRewardView or BaseClass(BaseView)

function KuaFuFlowerRewardView:__init()
	self.ui_config = {"uis/views/kuafuflowerrank", "RewardTips"}
	self.play_audio = true
	self.is_async_load = false
	self:SetMaskBg(true)
end

function KuaFuFlowerRewardView:__delete()
end

function KuaFuFlowerRewardView:ReleaseCallBack()
	self.title_res = nil
	self.display = nil
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	self.reward_list = nil
	for _,v in pairs(self.reward_cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.reward_cell_list = {}
end

function KuaFuFlowerRewardView:OpenCallBack()
	
end

function KuaFuFlowerRewardView:CloseCallBack()
	
end

function KuaFuFlowerRewardView:LoadCallBack()
	self.title_res = self:FindVariable("TitleRes")
	self.display = self:FindObj("Display")
	self.model = RoleModel.New()
	self.model:SetDisplay(self.display.ui3d_display)

	self.reward_cell_list = {}
	self.reward_list = self:FindObj("RewarList")
	local list_view_delegate = self.reward_list.list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self:ListenEvent("Close", BindTool.Bind(self.Close, self))

	self:Flush()
end

function KuaFuFlowerRewardView:GetNumberOfCells()
	local data = KuaFuFlowerRankData.Instance:GetKuaFuRechargeRankConfig()
	return #data.flower_rank_c
end

function KuaFuFlowerRewardView:RefreshView(cell, data_index)
	local reward_cell = self.reward_cell_list[cell]
	if reward_cell == nil then
		reward_cell = KuaFuFlowerRewardItemCell.New(cell.gameObject)
		self.reward_cell_list[cell] = reward_cell
	end
	local data = KuaFuFlowerRankData.Instance:GetKuaFuRechargeRankConfig()
	data_index = data_index + 1
	reward_cell:SetData(data.flower_rank_c[data_index])
end

function KuaFuFlowerRewardView:OnFlush()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.title_res:SetAsset(ResPath.GetKuaFuFlowerRankImage("title" .. vo.sex))
	if self.model then
		self.model:SetRoleResid("120" .. vo.prof .. "026")
	end
end


KuaFuFlowerRewardItemCell = KuaFuFlowerRewardItemCell or BaseClass(BaseCell)
function KuaFuFlowerRewardItemCell:__init()
	self.rank = self:FindVariable("rank")
	self.item_cell = {}
	for i = 1, 3 do
		self.item_cell[i] = ItemCell.New()
		self.item_cell[i]:SetInstanceParent(self:FindObj("item_cell" .. i))
	end
end

function KuaFuFlowerRewardItemCell:__delete()
	for i = 1, 3 do
		if self.item_cell[i] then
			self.item_cell[i]:DeleteMe()
		end
	end
	self.item_cell = {}
end

function KuaFuFlowerRewardItemCell:OnFlush()
	if nil == self.data or nil == next(self.data) then return end

	if self.data.min_rank == self.data.max_rank then
		self.rank:SetValue(string.format(Language.KuaFuFlowerRank.RankFirst, self.data.min_rank))
	else
		self.rank:SetValue(string.format(Language.KuaFuFlowerRank.RankOther, self.data.min_rank, self.data.max_rank))
	end
	
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local reward_data = {}
	if vo.sex == GameEnum.FEMALE then
		reward_data = ItemData.Instance:GetGiftItemList(self.data.reward_item_female.item_id)
	else
		reward_data = ItemData.Instance:GetGiftItemList(self.data.reward_item_male.item_id)
	end
	for i = 1, 3 do
		if nil == reward_data[i] then
			self.item_cell[i]:SetActive(false)
		else
			self.item_cell[i]:SetActive(true)
			self.item_cell[i]:SetData(reward_data[i])
		end
	end
end