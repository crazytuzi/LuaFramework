ShenMiContentView = ShenMiContentView or BaseClass(BaseRender)

function ShenMiContentView:__init()
	self:InitListView()
end

function ShenMiContentView:__delete()
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end

	self.cell_list = {}
end

function ShenMiContentView:InitListView()
	self.cell_list = {}
	self.list_view = self:FindObj("shenmi_list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function ShenMiContentView:GetNumberOfCells()
	return math.ceil(#ShopData.Instance:GetShenMiShop().seq_list / 2)
end

function ShenMiContentView:RefreshCell(cell, cell_index)
	local shop_cell = self.cell_list[cell]
	if nil == shop_cell then
		shop_cell = ShenMiItemCellGroup.New(cell.gameObject)
		self.cell_list[cell] = shop_cell
	end

	for i = 1, 2 do
		local index = cell_index * 2 + i
		local data = ShopData.Instance:GetMysteriousShopItemCfg(index)
		shop_cell:SetIndex(i, index)
		shop_cell:SetData(i, data)
	end
end

function ShenMiContentView:FlushView()
	self.list_view.scroller:ReloadData(0)
end

-----------------------------ShenMiItemCellGroup--------------------------
ShenMiItemCellGroup = ShenMiItemCellGroup or BaseClass(BaseRender)

function ShenMiItemCellGroup:__init()
	self.cell_list = {}
	for i = 1, 2 do
		local cell = ShenMiItemCell.New(self:FindObj("item_" .. i))
		table.insert(self.cell_list, cell)
	end
end

function ShenMiItemCellGroup:__delete()
	for k, v in ipairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function ShenMiItemCellGroup:SetToggleGroup()

end

function ShenMiItemCellGroup:SetData(i, data)
	self.cell_list[i]:SetData(data)
end

function ShenMiItemCellGroup:SetIndex(i, index)
	self.cell_list[i]:SetIndex(index)
end

-----------------------------ShenMiItemCell--------------------------
ShenMiItemCell = ShenMiItemCell or BaseClass(BaseCell)
function ShenMiItemCell:__init()
	self.normal_coin = self:FindVariable("normal_coin")
	self.zhekou_coin = self:FindVariable("zhekou_coin")
	self.shenmi_name = self:FindVariable("shenmi_name")
	self.shnemi_zhekou = self:FindVariable("shnemi_zhekou")
	self.is_buy = self:FindVariable("is_buy")
	self.item_zhekou = self:FindVariable("zhekou")
	self.is_zhekou_1 = self:FindVariable("is_zhekou_1")
	self.is_zhekou_2 = self:FindVariable("is_zhekou_2")
	self.is_zhekou_3 = self:FindVariable("is_zhekou_3")
	 -- self:ListenEvent("OnItemClick", BindTool.Bind(self.OnClick, self))
	self:ListenEvent("item_click", BindTool.Bind(self.OnClick, self))

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item"))
	self.item_cell:ShowHighLight(false)
end

function ShenMiItemCell:__delete()
	self.item_cell:DeleteMe()
end

function ShenMiItemCell:OnClick()
	if nil ~= self.data.item then
		local item_cfg = ItemData.Instance:GetItemConfig(self.data.item.item_id)
		local zhekou = self.data.dicount * 0.001
		local zhekou_price = math.max(math.floor(self.data.dicount * 0.0001 * self.data.price), 1)
		ViewManager.Instance:FlushView(ViewName.Shop, "shenmishop_view", {item_cfg, zhekou_price, self.index, self.data.item.num})
	end
end

function ShenMiItemCell:OnFlush()
	if nil == self.data then
		return
	end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item.item_id)
	self.root_node.gameObject:SetActive(item_cfg ~= nil)
	if nil == item_cfg then
		return
	end
	local zhekou = self.data.dicount * 0.001
	local zhekou_price = math.max(math.floor(self.data.dicount * 0.0001 * self.data.price), 1)
	local shenmi_shop_info = ShopData.Instance:GetShenMiShop()
	-- local m_data = {}
	-- m_data.item_id = self.data.item.item_id
	self.shenmi_name:SetValue(ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color]))
	self.normal_coin:SetValue(self.data.price)
	self.zhekou_coin:SetValue(zhekou_price)
	self.item_cell:SetData(self.data.item)
	self.item_cell:SetShowRedPoint(false)
	self.is_buy:SetValue(shenmi_shop_info.seq_list[self.index].state == 1)

	if zhekou >= 10 then
		self.is_zhekou_1:SetValue(false)
		self.is_zhekou_2:SetValue(false)
		self.is_zhekou_3:SetValue(false)
	end

	if zhekou < 10 then
		self.shnemi_zhekou:SetValue(zhekou)
		self.is_zhekou_3:SetValue(true)
		if self.data.banner == 5 then
			local bundle, asset = ResPath.GetZheKou(self.data.banner)
			self.is_zhekou_1:SetValue(false)
			self.is_zhekou_2:SetValue(true)
			self.item_zhekou:SetAsset(bundle, asset)
		else
			local bundle, asset = ResPath.GetZheKou(self.data.banner)
			self.is_zhekou_1:SetValue(true)
			self.is_zhekou_2:SetValue(false)
			self.item_zhekou:SetAsset(bundle, asset)
		end
	end

end