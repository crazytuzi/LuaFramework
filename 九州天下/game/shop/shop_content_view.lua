require("game/shop/shop_info_view")
ShopContentView = ShopContentView or BaseClass(BaseRender)

function ShopContentView:__init(instance)
	ShopContentView.Instance = self
	self.contain_cell_list = {}
	self.current_shop_type = 1
	
	self.is_show_info = self:FindVariable("is_show_info")
	self.is_show_info:SetValue(false)
	self:InitListView()
end

function ShopContentView:LoadCallBack()
	self.shop_info_view = ShopInfoView.New(self:FindObj("item_info"))
end

function ShopContentView:__delete()
	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}

	if nil ~= self.shop_info_view then
		self.shop_info_view:DeleteMe()
		self.shop_info_view = nil
	end

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
	if #item_id_list % ShopData.SHOP_COL_ITEM ~= 0 then
		return math.floor(#item_id_list / ShopData.SHOP_COL_ITEM) + 1
	else
		return #item_id_list / ShopData.SHOP_COL_ITEM
	end
end

function ShopContentView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = ShopContain.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	local item_id_list = ShopData.Instance:GetItemListByTypeAndIndex(self.current_shop_type, cell_index)
	contain_cell:InitItems(item_id_list, cell_index)
end

function ShopContentView:ResetSelectIndex()
	self.select_index = nil
end

function ShopContentView:SetCurrentShopType(shop_type)
	self.current_shop_type = shop_type
end

function ShopContentView:GetCurrentShopType()
	return self.current_shop_type
end

function ShopContentView:SetJumpItem(item)
	self.jump_item = item
end

function ShopContentView:GetJumpItem()
	return self.jump_item
end

function ShopContentView:OnFlushListView()
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function ShopContentView:OnFlushListReload()
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:ReloadData(0)
	end

	if self.jump_item then
		self:SelectCellByItemId(self.jump_item)
		self.jump_item = nil
	end
end

function ShopContentView:GetShopInfoView()
	if nil ~= self.shop_info_view then
		return self.shop_info_view
	end
end

function ShopContentView:OnFlushShopInfoView()
	if nil ~= self.shop_info_view then
		self.shop_info_view:Flush()
	end
end

function ShopContentView:SetShowInfoView(value)
	if nil ~= value and nil ~= self.is_show_info then 
		self.is_show_info:SetValue(value)
	end
end

function ShopContentView:SetCurIndex(index)
	if index ~= nil then
		self.cur_index = index
	end
end

function ShopContentView:GetCurIndex()
	if self.cur_index ~= nil then
		return self.cur_index
	end
end

function ShopContentView:ClearCurIndex()
	if self.cur_index ~= nil then
		self.cur_index = nil
	end
end

function ShopContentView:SelectCellByItemId(item_id)
	if item_id ~= nil then
		local item_id_list = ShopData.Instance:GetItemIdListType(self.current_shop_type)
		local max = 0
		if #item_id_list % ShopData.SHOP_COL_ITEM ~= 0 then
			max = math.floor(#item_id_list / ShopData.SHOP_COL_ITEM) + 1
		else
			max = #item_id_list / ShopData.SHOP_COL_ITEM
		end

		local index = 0
		for k,v in pairs(item_id_list) do
			if v == item_id then
				index = k
				break
			end
		end

		self:SetCurIndex(index)
		if self.list_view ~= nil then
			local index = math.floor((index - 1) / ShopData.SHOP_COL_ITEM) or 1
			self.list_view.scroller:JumpToDataIndex(index)
		end

		for k,v in pairs(self.contain_cell_list) do
			if v ~= nil then
				local flag = v:SelectCellByItemId(item_id)
				if flag then
					break
				end
			end
		end
	end
end
-----------------------------------------------------------------------
ShopContain = ShopContain  or BaseClass(BaseCell)

function ShopContain:__init()
	self.shop_contain_list = {}
	for i = 1, ShopData.SHOP_COL_ITEM do
		self.shop_contain_list[i] = ShopItem.New(self:FindObj("item_" .. i))
	end
end

function ShopContain:__delete()
	for i = 1, ShopData.SHOP_COL_ITEM do
		self.shop_contain_list[i]:DeleteMe()
		self.shop_contain_list[i] = nil
	end
end

function ShopContain:InitItems(item_id_list, cell_index)
	for i = 1, ShopData.SHOP_COL_ITEM do
		self.shop_contain_list[i]:SetItemId(item_id_list[i])
		self.shop_contain_list[i]:SetIndex(cell_index >= 2 and cell_index + i + cell_index - 2 or i)
		local cur_select = ShopContentView.Instance:GetCurIndex()
		local jump_item = ShopContentView.Instance:GetJumpItem()
		self.shop_contain_list[i]:SetShowHighLight(cur_select)
		if cur_select == self.shop_contain_list[i].index then
			self.shop_contain_list[i]:OnToggleClick(2)
		end
		self.shop_contain_list[i]:Flush()
	end
end

function ShopContain:SelectCellByItemId(item_id)
	local flag = false
	if item_id ~= nil and self.shop_contain_list ~= nil then
		for k,v in pairs(self.shop_contain_list) do
			if v ~= nil and v.item_id > 0 and v.item_id == item_id then
				--v:OnToggleClick(0)
				flag = true
				v:SetShowHighLight(nil, true)
				v:OnToggleClick(2)
				break
			end
		end
	end

	return flag
end

---------------------------------------------------------------------
ShopItem = ShopItem or BaseClass(BaseCell)
function ShopItem:__init()
	
	self.name = self:FindVariable("name")
	self.icon = self:FindVariable("icon")
	self.price = self:FindVariable("price")
	self.limit_num = self:FindVariable("limit_num")
	self.show_highlight = self:FindVariable("show_highlight")
	self.show_limit_num = self:FindVariable("show_limit_num")
	self.vip_num = self:FindVariable("vip_num")
	self.show_vip_num = self:FindVariable("show_vip_num")
	self.show_limit_num:SetValue(false)
	self.show_vip_num:SetValue(false)

	self:ListenEvent("OnClickToggle", BindTool.Bind2(self.OnToggleClick, self, 0))
	
	self.item_id = 0
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item"))
	self.item_cell:ShowHighLight(false)

	local handler = function()
	 	self:OnToggleClick(1)
	end
	self.item_cell:ListenClick(handler)
end

function ShopItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	self.item_id = nil
end

function ShopItem:SetItemId(item_id)
	self.item_id = item_id or 0
end

function ShopItem:OnFlush()
	self.root_node:SetActive(true)
	local shop_item_data = ShopData.Instance:GetShopItemCfg(self.item_id)
	if self.item_id == 0 or shop_item_data == nil then
		self.root_node:SetActive(false)
		return
	end

	if shop_item_data.vip_limit > 0 then
		self.show_vip_num:SetValue(true)
		self.vip_num:SetValue(string.format(Language.Shop.ShopVipLimit, shop_item_data.vip_limit))
	else
		self.show_vip_num:SetValue(false)
		self.vip_num:SetValue("")
	end

	if ShopContentView.Instance:GetCurrentShopType() == SHOP_BIND_TYPE.IS_LIMUIT then --限购商城
		self.show_limit_num:SetValue(true)
		self.limit_num:SetValue(shop_item_data.buy_limit - ShopData.Instance:GetShopBuyNum(self.item_id))
		self.price:SetValue(shop_item_data.vip_gold or 0)
	elseif ShopContentView.Instance:GetCurrentShopType() == SHOP_BIND_TYPE.BIND then
		self.show_limit_num:SetValue(false)
		self.price:SetValue(shop_item_data.bind_gold or 0)
	else
		self.show_limit_num:SetValue(false)
		self.price:SetValue(shop_item_data.gold or 0)
	end
	local consume_type = ShopData.Instance:GetConsumeType(ShopContentView.Instance:GetCurrentShopType())
	local cfg = ItemData.Instance:GetItemConfig(self.item_id)
	local data = {}
	data.item_id = self.item_id
	local res_id = 0
	if consume_type == 1 then
		res_id = 1001
		data.is_bind = 1
	else
		res_id = 1000
		data.is_bind = 0
	end
	local bundle, asset = ResPath.GetGoldIcon(res_id)
	self.icon:SetAsset(bundle, asset)

	self.name:SetValue(ToColorStr(cfg.name, ITEM_COLOR[cfg.color]))
	self.item_cell:SetData(data)
end

function ShopItem:OnToggleClick(flag)
	local data = {}
	data.item_id = self.item_id
	local res_id = 0
	if consume_type == 1 then
		res_id = 1001
		data.is_bind = 1
	else
		res_id = 1000
		data.is_bind = 0
	end

	if 1 == flag then
		self.item_cell:OnClickItemCell(data)
	end
	ShopContentView.Instance:SetCurIndex(self.index)
	local consume_type = ShopContentView.Instance:GetCurrentShopType() == SHOP_BIND_TYPE.IS_LIMUIT and SHOP_BIND_TYPE.IS_LIMUIT or ShopData.Instance:GetConsumeType(ShopContentView.Instance:GetCurrentShopType())

	ShopContentView.Instance:SetShowInfoView(true)
	ShopContentView.Instance:GetShopInfoView():SetItemId(self.item_id, consume_type)
	if flag ~= 2 then
		ShopContentView.Instance:OnFlushListView()
	end
end

function ShopItem:SetShowHighLight(index, flag)
	if flag ~= nil then
		self.show_highlight:SetValue(flag)
		return
	end

	if index ~= nil then
		self.show_highlight:SetValue(index == self.index)
	else
		self.show_highlight:SetValue(false)
	end
end