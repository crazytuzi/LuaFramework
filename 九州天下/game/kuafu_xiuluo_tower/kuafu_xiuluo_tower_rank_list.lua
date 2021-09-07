KuaFuXiuLuoTowerRankList = KuaFuXiuLuoTowerRankList or BaseClass(BaseRender)

function KuaFuXiuLuoTowerRankList:__init()
	self.scroller_data = {}
	self:InitScroller()
end

function KuaFuXiuLuoTowerRankList:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function KuaFuXiuLuoTowerRankList:Flush()
	self.scroller.scroller:ReloadData(0)
end

function KuaFuXiuLuoTowerRankList:InitScroller()
	self.cell_list = {}
	self.scroller_data = KuaFuXiuLuoTowerData.Instance:GetRankList()
	self.scroller = self:FindObj("Scroller")
	local delegate = self.scroller.list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #self.scroller_data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1

		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] = XiuLuoRankScrollerCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
			target_cell.mother_view = self
		end
		local cell_data = self.scroller_data[data_index]
		cell_data.data_index = data_index
		target_cell:SetData(cell_data)
	end
end

---------------------------------------------------------------
--滚动条格子

XiuLuoRankScrollerCell = XiuLuoRankScrollerCell or BaseClass(BaseCell)

function XiuLuoRankScrollerCell:__init()
	self.is_top_three = self:FindVariable("IsTopThree")
	self.is_self = self:FindVariable("IsSelf")
	self.rank = self:FindVariable("Rank")
	self.player_name = self:FindVariable("Name")
	self.score = self:FindVariable("Score")
	self.rank_icon = self:FindVariable("RankIcon")
end

function XiuLuoRankScrollerCell:__delete()
end

function XiuLuoRankScrollerCell:OnFlush()
	local rank_is_self = (self.data.user_name == GameVoManager.Instance:GetMainRoleVo().name)
	self.is_self:SetValue(rank_is_self)
	local rank_num = self.data.data_index
	self.is_top_three:SetValue(rank_num < 4)
	if rank_num < 4 then
		self.rank_icon:SetAsset(ResPath.GetRankIcon(rank_num))
	else
		self.rank:SetValue(rank_num)
	end
	self.player_name:SetValue(self.data.user_name)
	self.score:SetValue(self.data.max_layer)
end