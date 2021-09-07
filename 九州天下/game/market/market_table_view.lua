MarketTableView = MarketTableView or BaseClass(BaseRender)

local ListViewDelegate = ListViewDelegate

function MarketTableView:__init(instance)
	if instance == nil then
		return
	end

	self.scroller = self:FindObj("Scroller")
	self.show_no_goods = self:FindVariable("ShowNoGoods")
	self:InitScroller()
end

function MarketTableView:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function MarketTableView:Flush()
	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end
	local count = self:GetNumberOfCells()
	if count < 1 then
		self.show_no_goods:SetValue(true)
	else
		self.show_no_goods:SetValue(false)
	end
end

--初始化滚动条
function MarketTableView:InitScroller()
	self.cell_list = {}

	self.list_view_delegate = ListViewDelegate()

	PrefabPool.Instance:Load(AssetID("uis/views/market_prefab", "Info"), function (prefab)
		if nil == prefab then
			return
		end
		local enhanced_cell_type = prefab:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))
		PrefabPool.Instance:Free(prefab)
		
		self.enhanced_cell_type = enhanced_cell_type
		self.scroller.scroller.Delegate = self.list_view_delegate

		self.list_view_delegate.numberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
		self.list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
		self.list_view_delegate.cellViewDel = BindTool.Bind(self.GetCellView, self)
	end)
end

--滚动条数量
function MarketTableView:GetNumberOfCells()
	return MarketData.Instance:GetSaleCount()
end

--滚动条大小
function MarketTableView:GetCellSize(data_index)
	return 126
end

--滚动条刷新
function MarketTableView:GetCellView(scroller, data_index, cell_index)
	local cell_view = scroller:GetCellView(self.enhanced_cell_type)
	local cell = self.cell_list[cell_view]
	if cell == nil then
		self.cell_list[cell_view] = MarketTableViewScrollCell.New(cell_view)
		cell = self.cell_list[cell_view]
	end
	local sale_item_list = MarketData.Instance:GetSaleItemList()
	if sale_item_list and sale_item_list[data_index + 1] then
		local data = sale_item_list[data_index + 1]
		data.data_index = data_index
		cell:SetData(data)
	end
	return cell_view
end

-------------------------------------- 动态生成Cell ----------------------------------------------
MarketTableViewScrollCell = MarketTableViewScrollCell or BaseClass(BaseCell)

function MarketTableViewScrollCell:__init()
	self.root_node.list_cell.refreshCell = BindTool.Bind(self.Flush, self)
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.name = self:FindVariable("Name")
	self.price = self:FindVariable("Price")
	self.total_price = self:FindVariable("TotalPrice")
	self:ListenEvent("OnClickRemove", BindTool.Bind(self.OnClickRemove, self))
end

function MarketTableViewScrollCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function MarketTableViewScrollCell:Flush()
	if not self.data then return end
	self.item_cell:SetData(self.data)
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	self.name:SetValue(ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color]))
	self.total_price:SetValue(self.data.gold_price)
	local one_price = math.floor(self.data.gold_price / self.data.num) >= 1 and math.floor(self.data.gold_price / self.data.num) or 1
	self.price:SetValue(one_price)
end

function MarketTableViewScrollCell:OnClickRemove()
	if self.data and self.data.sale_index then
		MarketCtrl.Instance:SendRemovePublicSaleItem(self.data.sale_index)
	end
end
