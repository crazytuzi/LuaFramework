TianshenhutiBossRankView = TianshenhutiBossRankView or BaseClass(BaseRender)
function TianshenhutiBossRankView:__init()
	-- 获取控件
	self.rank_data_list = {}
	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	self.item_t = {}
	self.rank = self:FindVariable("rank")
	self.name = self:FindVariable("name")
	self.hurt = self:FindVariable("hurt")
	self:Flush()
end

function TianshenhutiBossRankView.AssetBundle()
	return "uis/views/tianshenhutiview_prefab", "ScoreRank"
end

function TianshenhutiBossRankView:__delete()
	for k,v in pairs(self.item_t) do
		v:DeleteMe()
	end
	self.item_t = {}
	GameObject.Destroy(self.root_node.gameObject)
	self.root_node = nil
end

-----------------------------------
-- ListView逻辑
-----------------------------------
function TianshenhutiBossRankView:BagGetNumberOfCells()
	return math.max(#self.rank_data_list, 5)
end

function TianshenhutiBossRankView:BagRefreshCell(cell, data_index, cell_index)
	local item = self.item_t[cell]
	if nil == item then
		item = TianshenhutiBossRankItem.New(cell.gameObject)
		self.item_t[cell] = item
	end
	item:SetIndex(cell_index + 1)
	if self.rank_data_list[cell_index + 1] then
		item:SetData(self.rank_data_list[cell_index + 1])
	else
		item:SetData({name = "--", hurt = 0})
	end
end

function TianshenhutiBossRankView:OnFlush()
	local info = TianshenhutiData.Instance:GetBossPersonalHurtInfo()
	self.rank:SetValue(info.self_rank)
	self.name:SetValue(PlayerData.Instance.role_vo.name)
	self.hurt:SetValue(info.my_hurt)
	self.rank_data_list = info.rank_list
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshActiveCellViews()
	end
end

TianshenhutiBossRankItem = TianshenhutiBossRankItem or BaseClass(BaseRender)

function TianshenhutiBossRankItem:__init()
	self.rank = self:FindVariable("Rank")
	self.name = self:FindVariable("Name")
	self.score = self:FindVariable("Score")
end

function TianshenhutiBossRankItem:SetIndex(index)
	self.rank:SetValue(index)
end

function TianshenhutiBossRankItem:SetData(data)
	self.data = data
	self:Flush()
end

function TianshenhutiBossRankItem:Flush()
	if nil == self.data then
		return
	end
	self.name:SetValue(self.data.name)
	self.score:SetValue(self.data.hurt)
end