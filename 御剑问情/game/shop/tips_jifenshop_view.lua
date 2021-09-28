JiFenShopView = JiFenShopView or BaseClass(BaseView)
function JiFenShopView:__init()
	self.ui_config = {"uis/views/exchangeview_prefab", "JiFenShop"}
	self.full_screen = false
	self.play_audio = true
	self.cell_list = {}
	self.jifen_index = nil
	self.jifen_price = nil
	self.current_title_id = -1
end

function JiFenShopView:ReleaseCallBack()
	self.jifenshop = nil
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end

	self.jifen_index = nil
	self.jifen_price = nil
	self.my_jifen = nil
	self.buy_a = nil
	self.text_1 = nil
	self.text_2 = nil
	self.list_view = nil
	self.cell_list = {}
end

function JiFenShopView:OpenCallBack()
	self:Flush()
end

function JiFenShopView:LoadCallBack()
	self.my_jifen = self:FindVariable("my_jifen")
	self.buy_a = self:FindVariable("buy_a")
	self.text_1 = self:FindVariable("text_1")
	self.text_2 = self:FindVariable("text_2")

	self:ListenEvent("Close", BindTool.Bind(self.ShopClose, self))
	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

end

function JiFenShopView:OnFlush()
	self.my_jifen:SetValue(ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.JIFEN))
	self:FlushAllHL()
end


function JiFenShopView:SetCurrentId(title_id)
	self.current_title_id = title_id
	self:Flush()
end

function JiFenShopView:GetCurrentId()
	return self.current_title_id
end

function JiFenShopView:ShopClose()
	self:Close()
end

function JiFenShopView:FlushAllHL()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end

function JiFenShopView:GetNumberOfCells()
	local num = math.ceil(#ShopData.Instance:GetJifenItemListCfg() / 2)
	if nil ~= num then
		return num
	end
	return 0
end

function JiFenShopView:RefreshCell(cell, cell_index)
	local shop_cell = self.cell_list[cell]
	if nil == shop_cell then
		shop_cell = ShopItemCellGroup.New(cell.gameObject)
		shop_cell:SetToggleGroup(self.list_view.toggle_group)
		self.cell_list[cell] = shop_cell
	end

	for i = 1, 2 do
		local index = cell_index * 2 + i
		local data = ShopData.Instance:GetJifenItemCfg(index)
		shop_cell:SetData(i, data)
	end
end

-----------------------------ShopItemCellGroup--------------------------
ShopItemCellGroup = ShopItemCellGroup or BaseClass(BaseRender)

function ShopItemCellGroup:__init()
	self.cell_list = {}
	for i = 1, 2 do
		local cell = ShopItemCell.New(self:FindObj("item_" .. i))
		table.insert(self.cell_list, cell)
	end
end

function ShopItemCellGroup:__delete()
	for k, v in ipairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function ShopItemCellGroup:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function ShopItemCellGroup:SetToggleGroup(toggle_group)
	for i=1,2 do
		self.cell_list[i]:SetToggleGroup(toggle_group)
	end
end

function ShopItemCellGroup:SetData(i, data)
	self.cell_list[i]:SetData(data)
	self.cell_list[i]:SetCurindex(i)
end

function ShopItemCellGroup:FlushHL()
	for i=1,2 do
		self.cell_list[i]:FlushHL()
	end
end
-----------------------------ShopItemCell--------------------------
ShopItemCell = ShopItemCell or BaseClass(BaseCell)
function ShopItemCell:__init()
	self.name = self:FindVariable("name")
	self.picture = self:FindVariable("picture")
	self.price = self:FindVariable("price")
	self.is_buy = self:FindVariable("is_buy")
	self.buy_num = self:FindVariable("buy_num")
	self.show_hight_light = self:FindVariable("show_hl")

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item"))
	self.item_cell:ShowHighLight(false)

	self.cell_toggle = self.root_node.toggle
	self.cell_toggle:AddValueChangedListener(BindTool.Bind(self.TitleOnClick, self))

	self:ListenEvent("duihuan", BindTool.Bind(self.OnClickExchange, self))
end

function ShopItemCell:__delete()
	self.item_cell:DeleteMe()
end

function ShopItemCell:OnClickExchange()
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg then
		return
	end

	local item_id = self.data.item_id
	local price = ItemData.Instance:GetItemConfig(self.data.item_id).price

	ShopCtrl.Instance:SendMysteriosshopOperate(self.data.conver_type, self.data.seq, 1)
	ExchangeCtrl.Instance:SendGetSocreInfoReq()
end

function ShopItemCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function ShopItemCell:OnFlush()

	self.root_node:SetActive(true)
	if self.data == nil then
		self.root_node:SetActive(false)
		return
	end
	self:FlushHL()

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	self.root_node.gameObject:SetActive(item_cfg ~= nil)
	if nil == item_cfg then
		return
	end

	if self.data.limit_convert_count > 0 then
		self.is_buy:SetValue(true)
	else
		self.is_buy:SetValue(false)
	end

	self.price:SetValue(self.data.price)
	self.name:SetValue(ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color]))
	self.buy_num:SetValue(self.data.limit_convert_count)

	local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
	self.picture:SetAsset(bundle,asset)

	local m_data = {}
	m_data.item_id = self.data.item_id

	self.item_cell:SetData(m_data)
	self.item_cell:SetShowRedPoint(false)

end

function ShopItemCell:SetCurindex(i)
	self.cur_index = i
end

function ShopItemCell:TitleOnClick(is_click)	
	if is_click then
		local title_view = ShopCtrl.Instance:GetJiFenView()
		if title_view and title_view:GetCurrentId() ~= self.data then
			title_view:SetCurrentId(self.data)
		end
	end
end

function ShopItemCell:FlushHL()	
	local title_view = ShopCtrl.Instance:GetJiFenView()
	if title_view then
		local cur_seq = title_view:GetCurrentId()
		if cur_seq and cur_seq ~= -1 then
			self.show_hight_light:SetValue(self.data.seq  == cur_seq.seq)
		end
		
	end
end
