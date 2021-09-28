DuiHuanContentView = DuiHuanContentView or BaseClass(BaseRender)

function DuiHuanContentView:__init(instance)
	DuiHuanContentView.Instance = self
	self.contain_cell_list = {}
	self.current_sub_type = 1
	self.pagecount = self:FindVariable("PageCount")
	self.toggle1 = self:FindObj("toggle1")
	self:InitListView()
end

function DuiHuanContentView:__delete()
	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}
	self.current_sub_type = 1
	self.list_view = nil
end



function DuiHuanContentView:InitListView()
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.pagecount:SetValue(self:GetNumberOfCells())
end

function DuiHuanContentView:GetNumberOfCells()
	local item_id_list = ComposeData.Instance:GetItemIdListBySubType(10, self.current_sub_type)
	self.list_view.list_page_scroll:SetPageCount(math.ceil(#item_id_list/8))
	return math.ceil(#item_id_list/8)
end

function DuiHuanContentView:GetCellList()
	return self.contain_cell_list
end

function DuiHuanContentView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = DuiHuanContain.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	local item_id_list = ComposeData.Instance:GetItemListByTypeAndIndex(10, self.current_sub_type, cell_index)
	contain_cell:InitItems(item_id_list)
	contain_cell:SetIndex(cell_index)
end


function DuiHuanContentView:OnFlushListView(sub_type)
	self.current_sub_type = sub_type
	self.list_view.scroller:ReloadData(0)
	self.pagecount:SetValue(self:GetNumberOfCells())
end

------------------------------------------------------------------------
DuiHuanContain = DuiHuanContain  or BaseClass(BaseCell)

function DuiHuanContain:__init()
	self.exchange_contain_list = {}
	for i = 1, 4 do
		self.exchange_contain_list[i] = {}
		self.exchange_contain_list[i] = DuiHuanItem.New(self:FindObj("item_" .. i))
	end
end

function DuiHuanContain:__delete()
	for i=1,4 do
		self.exchange_contain_list[i]:DeleteMe()
		self.exchange_contain_list[i] = nil
	end
end

function DuiHuanContain:GetFirstCell()
	return self.exchange_contain_list[1]
end

function DuiHuanContain:InitItems(item_id_list)
	for i=1,4 do
		self.exchange_contain_list[i]:SetData(item_id_list[i])
		self.exchange_contain_list[i]:OnFlush()
	end
end

----------------------------------------------------------------------------
DuiHuanItem = DuiHuanItem or BaseClass(BaseCell)

function DuiHuanItem:__init()
	self.name = self:FindVariable("name")
	self.coin = self:FindVariable("coin")
	self.coin_icon = self:FindVariable("coin_icon")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item"))
	self.item_cell:ShowHighLight(false)
	self:ListenEvent("OnClick", BindTool.Bind(self.OnToggleClick, self))
end

function DuiHuanItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
	end
end

function DuiHuanItem:SetData(item_id_list)
	self.data = item_id_list
	if next(self.data) == nil then
		return
	end

	self.item_id = self.data.stuff_id_1
	self.stuff_count_1 = self.data.stuff_count_1
	self.product_id = self.data.product_id
end

function DuiHuanItem:OnFlush()
	self.root_node:SetActive(true)
	if next(self.data) == nil then
		self.root_node:SetActive(false)
		return
	end
	local my_count = ItemData.Instance:GetItemNumInBagById(self.item_id)
	local text = ""
	local green_text = ToColorStr(tostring(self.stuff_count_1), TEXT_COLOR.BLACK_1)
	local my_count_text = ""
	if my_count >= self.stuff_count_1 then
		my_count_text = ToColorStr(tostring(my_count), TEXT_COLOR.BLUE_SPECIAL)
		text = my_count_text .. " / " .. green_text
	else
		my_count_text = ToColorStr(tostring(my_count), TEXT_COLOR.RED)
		text = my_count_text .. " / " .. green_text
	end
	self.coin:SetValue(text)
	local item_cfg = ItemData.Instance:GetItemConfig(self.product_id)
	if item_cfg then
		self.name:SetValue(ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color]))
		self.item_cell:SetData({item_id = self.product_id})
	end

	local bundle, asset = ResPath.GetItemIcon(self.item_id)
	self.coin_icon:SetAsset(bundle, asset)
end


function DuiHuanItem:OnToggleClick()
	local function ok_callback()
		local compose_data = ComposeData.Instance
		local compose_item = compose_data:GetComposeItem(self.product_id)
		local duihuan_num = compose_data:GetCanByNum(self.product_id)
		if duihuan_num > 0 then
			ComposeCtrl.Instance:SendItemCompose(compose_item.producd_seq, 1, 0) --0合成类型
		else
			local is_shop_have = compose_data:GetIsHaveItemOfShop(self.product_id)
			if is_shop_have then
				for i=1,3 do
					local is_rich = compose_data:GetSingleMatRich(self.product_id, i)
					if not is_rich then
						local is_shop_exist = compose_data:GetIsHaveSingleItemOfShop(self.product_id, i)
						if is_shop_exist then
							self:OpenShopBuyTips(i)
						else
							TipsCtrl.Instance:ShowItemGetWayView(compose_item["stuff_id_"..i])
						end
					end
				end
			else
				TipsCtrl.Instance:ShowItemGetWayView(compose_item.stuff_id_1)
			end
		end
	end

	local count = ToColorStr(tostring(self.stuff_count_1), TEXT_COLOR.BLUE_4)
	local name = ToColorStr(ItemData.Instance:GetItemName(self.item_id), TEXT_COLOR.RED)
	local des = string.format(Language.DuiHuan.Desc, count, name)
	TipsCtrl.Instance:ShowCommonAutoView("duihuan", des, ok_callback, nil)

end







