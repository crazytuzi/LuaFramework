KaifuActivityPanelMarryGift = KaifuActivityPanelMarryGift or BaseClass(BaseRender)

function KaifuActivityPanelMarryGift:__init(instance)
	self.cell_list = {}
end

function KaifuActivityPanelMarryGift:LoadCallBack()
	self.rank_desc_list = self:FindObj("RankDescList")
	self.rank_str = self:FindVariable("RankStr")
	self.list_view_delegate = self.rank_desc_list.list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self:ListenEvent("OnClickMarry", BindTool.Bind(self.OnClickMarry, self))
end

function KaifuActivityPanelMarryGift:__delete()
	for k, v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
			v = nil
		end
	end

	self.cell_list = {}
end

function KaifuActivityPanelMarryGift:GetNumberOfCells()
	return #KaifuActivityData.Instance:GetMarryGiftCfg()
end

function KaifuActivityPanelMarryGift:RefreshView(cell, data_index)
	data_index = data_index + 1

	local goals_cell = self.cell_list[cell]
	if goals_cell == nil then
		goals_cell = MarryGiftRankDescItem.New(cell.gameObject)
		self.cell_list[cell] = goals_cell
	end
	goals_cell:SetIndex(data_index)
	local cfg = KaifuActivityData.Instance:GetMarryGiftCfg()
	goals_cell:SetData(cfg[data_index])
end

function KaifuActivityPanelMarryGift:SetCurTyoe(cur_type)
	self.cur_type = cur_type
end

function KaifuActivityPanelMarryGift:OnFlush()
	local activity_type = self.cur_type
	self.activity_type = activity_type or self.activity_type

	if self.rank_str ~= nil then
		self.rank_str:SetValue(KaifuActivityData.Instance:GetMarryGiftSelfRank())
	end
end

function KaifuActivityPanelMarryGift:OnClickMarry()
	ViewManager.Instance:Open(ViewName.Marriage, TabIndex.marriage_honeymoon)
end

-----------------MarryGiftRankDescItem-------------------------------
MarryGiftRankDescItem = MarryGiftRankDescItem or BaseClass(BaseCell)
function MarryGiftRankDescItem:__init()
	self.rank = self:FindVariable("rank")
	self.desc = self:FindVariable("desc")
end

function MarryGiftRankDescItem:__delete()
	
end

function MarryGiftRankDescItem:OnFlush()
	if nil == self.data or nil == next(self.data) then return end
	local rank_desc = string.format(Language.MarryGift.RankDesc, self.data.min_place, self.data.max_place)
	self.rank:SetValue(rank_desc)
	self.desc:SetValue(self.data.description)
end