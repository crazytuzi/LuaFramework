ShopContentView = ShopContentView or BaseClass(BaseRender)

function ShopContentView:__init(instance)
	ShopContentView.Instance = self
	self.contain_cell_list = {}
	self.current_item_id = -1
	self.current_shop_type = 1
	self:InitListView()
	self.coin_icon = self:FindVariable("coin_icon")
	self.coin_text = self:FindVariable("coin_text")
	self.botom_text = self:FindVariable("botom_text")
	self.bind_coin_text = self:FindVariable("bind_coin_text")
	self.item_data_event = nil
	self:SetNotifyDataChangeCallBack()
	self.coin_text:SetValue(self:FormatMoney(GameVoManager.Instance:GetMainRoleVo().gold))
	self.bind_coin_text:SetValue(self:FormatMoney(GameVoManager.Instance:GetMainRoleVo().bind_gold))
	self.cellitem_id = 0
end

function ShopContentView:__delete()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}

	ShopContentView.Instance = nil
end

function ShopContentView:InitListView()
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function ShopContentView:GetNumberOfCells()
	local item_id_list = ShopData.Instance:GetItemIdListType(self.current_shop_type)
	if #item_id_list % SHOP_COL_ITEM ~= 0 then
		return math.floor(#item_id_list / SHOP_COL_ITEM) + 1
	else
		return #item_id_list / SHOP_COL_ITEM
	end
end

function ShopContentView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = ShopContain.New(cell.gameObject)
		contain_cell:SetClickCallBack(BindTool.Bind(self.ShopItemClick, self))
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	local item_id_list = ShopData.Instance:GetItemListByTypeAndIndex(self.current_shop_type, cell_index)
	contain_cell:InitItems(item_id_list, cell_index)
end

function ShopContentView:ShopItemClick(cell)
	local item_id = cell.item_id
	self.cur_item_id = cell.item_id
	if nil ~= cell.item_index then
		for k,v in pairs(self.contain_cell_list) do
			v:FlushHighLight(cell.item_index)
		end
	end
	ViewManager.Instance:FlushView(ViewName.Shop, "xin_xi", {item_id, ShopData.Instance:GetConsumeType(self:GetCurrentShopType())})
end

function ShopContentView:SetCurrentShopType(shop_type)
	self.current_shop_type = shop_type
	local res_id = 0
	local consume_type = ShopData.Instance:GetConsumeType(shop_type)
	if consume_type == 1 then
		res_id = 3
		self.bind_coin_text:SetValue(self:FormatMoney(GameVoManager.Instance:GetMainRoleVo().bind_gold))
		self.botom_text:SetValue(Language.Shop.BindGoldTips)
	else
		res_id = 2
		self.coin_text:SetValue(self:FormatMoney(GameVoManager.Instance:GetMainRoleVo().gold))
		self.botom_text:SetValue("")
	end
	local bundle, asset = ResPath.GetDiamonIcon(res_id)
	self.coin_icon:SetAsset(bundle, asset)
end

function ShopContentView:FormatMoney(value)
	return CommonDataManager.ConverMoney(value)
end

function ShopContentView:GetCurrentShopType()
	return self.current_shop_type
end

function ShopContentView:OnFlushListView()
	self.list_view.scroller:ReloadData(0)
	for k,v in pairs(self.contain_cell_list) do
		v:FlushHighLight()
	end
end

function ShopContentView:OnFlushItemView()
	for k,v in pairs(self.contain_cell_list) do
		v:FlushHighLight()
	end
end

function ShopContentView:FlushCoin()
	local consume_type = ShopData.Instance:GetConsumeType(ShopContentView.Instance:GetCurrentShopType())
	self.bind_coin_text:SetValue(self:FormatMoney(GameVoManager.Instance:GetMainRoleVo().bind_gold))
	self.coin_text:SetValue(self:FormatMoney(GameVoManager.Instance:GetMainRoleVo().gold))
end

--移除物品回调
function ShopContentView:RemoveNotifyDataChangeCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

-- 设置物品回调
function ShopContentView:SetNotifyDataChangeCallBack()
	-- 监听系统事件
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function ShopContentView:ItemDataChangeCallback()
	self:FlushCoin()
end

-----------------------------------------------------------------------
ShopContain = ShopContain  or BaseClass(BaseRender)

function ShopContain:__init()
	self.shop_contain_list = {}
	for i = 1, SHOP_COL_ITEM do
		self.shop_contain_list[i] = ShopItem.New(self:FindObj("item_" .. i))
	end
end

function ShopContain:__delete()
	for i=1, SHOP_COL_ITEM do
		self.shop_contain_list[i]:DeleteMe()
		self.shop_contain_list[i] = nil
	end
end

function ShopContain:InitItems(item_id_list, index)
	for i=1, SHOP_COL_ITEM do
		self.shop_contain_list[i]:SetItemId(item_id_list[i])
		self.shop_contain_list[i]:SetItemIndex(i + 10 * index)
		self.shop_contain_list[i]:OnFlush()
	end
end

function ShopContain:OnFlushItems()
	for i=1, SHOP_COL_ITEM do
		self.shop_contain_list[i]:OnFlush()
	end
end

function ShopContain:FlushHighLight(item_index)
	for i=1, SHOP_COL_ITEM do
		self.shop_contain_list[i]:FlushHighLight(item_index)
	end
end

function ShopContain:SetClickCallBack(callback)
	for i=1, SHOP_COL_ITEM do
		self.shop_contain_list[i]:SetClickCallBack(callback)
	end
end

---------------------------------------------------------------------
ShopItem = ShopItem or BaseClass(BaseCell)
function ShopItem:__init()
	self.name = self:FindVariable("name")
	self.coin = self:FindVariable("coin")
	-- self.root_node.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleClick, self))
	self:ListenEvent("OnItemClick", BindTool.Bind(self.OnClick, self))
	self:ListenEvent("OnClickItem", BindTool.Bind(self.OnClickItem, self))

	self.show_exchange_text = self:FindVariable("show_exchange_text")
	self.show_exchange_text:SetValue(false)
	self.coin_icon = self:FindVariable("coin_icon")
	self.show_hl = self:FindVariable("show_hl")
	self.item_id = 0
	self.item_index = nil
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item"))
	self.item_cell:ShowHighLight(false)

end


function ShopItem:OnClickItem()
	ShopContentView.Instance.cellitem_id = self.item_id
	ShopContentView.Instance:OnFlushItemView()
end

function ShopItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	self.item_index = nil
	self.item_id = 0
end

function ShopItem:SetItemId(item_id)
	self.item_id = item_id or 0
end

function ShopItem:SetItemIndex(item_index)
	self.item_index = item_index
end

function ShopItem:FlushHighLight(item_index)
	self.show_hl:SetValue(ShopContentView.Instance.cellitem_id == self.item_id)
end

function ShopItem:OnFlush()
	self.root_node:SetActive(true)
	local shop_item_data = ShopData.Instance:GetShopItemCfg(self.item_id)
	if self.item_id == 0 or shop_item_data == nil then
		self.root_node:SetActive(false)
		return
	end
	local consume_type = ShopData.Instance:GetConsumeType(ShopContentView.Instance:GetCurrentShopType())
	local cfg = ItemData.Instance:GetItemConfig(self.item_id)
	local data = {}
	data.item_id = self.item_id
	local res_id = 0
	if consume_type == 1 then
		res_id = 3
		data.is_bind = 1
	else
		res_id = 2
		data.is_bind = 0
	end
	local bundle, asset = ResPath.GetDiamonIcon(res_id)
	self.coin_icon:SetAsset(bundle, asset)
	local gold = shop_item_data.gold or 0
	self.coin:SetValue(gold)
	self.name:SetValue(ToColorStr(cfg.name, ITEM_COLOR[cfg.color]))
	self.item_cell:SetData(data)
	self.item_cell:SetShowRedPoint(false)
	self.show_hl:SetValue(ShopContentView.Instance.cellitem_id == self.item_id)
end