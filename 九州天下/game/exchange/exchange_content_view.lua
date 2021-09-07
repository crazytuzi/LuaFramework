ExchangeContentView = ExchangeContentView or BaseClass(BaseRender)

function ExchangeContentView:__init(instance)
	ExchangeContentView.Instance = self
	self.contain_cell_list = {}
	self.current_price_type = 9
end

function ExchangeContentView:__delete()
	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}
	self.current_price_type = nil
	ExchangeContentView.Instance = nil
end

function ExchangeContentView:LoadCallBack()
	self:InitListView()
end

function ExchangeContentView:InitListView()
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function ExchangeContentView:GetNumberOfCells()
	local item_id_list = ExchangeData.Instance:GetItemIdListByJobAndType(2, self.current_price_type, GameVoManager.Instance:GetMainRoleVo().prof)
	if self.current_price_type == 12 then --金锭
		item_id_list = ExchangeData.Instance:GetItemIdListByJobAndType(8, self.current_price_type, GameVoManager.Instance:GetMainRoleVo().prof)
	end
	if #item_id_list % ExchangeData.EXCHANGE_COL_ITEM ~= 0 then
		return math.ceil(#item_id_list / ExchangeData.EXCHANGE_COL_ITEM)
	else
		return #item_id_list / ExchangeData.EXCHANGE_COL_ITEM
	end
end

function ExchangeContentView:GetCellList()
	return self.contain_cell_list
end

function ExchangeContentView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = ExchangeContain.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
		contain_cell:SetToggleGroup(self.list_view.toggle_group)
	end
	cell_index = cell_index + 1

	local item_id_list, item_seq_list = ExchangeData.Instance:GetItemListByJobAndIndex(2, self.current_price_type, GameVoManager.Instance:GetMainRoleVo().prof, cell_index)
	if self.current_price_type == 12 then --金锭
		item_id_list, item_seq_list = ExchangeData.Instance:GetItemListByJobAndIndex(8, self.current_price_type, GameVoManager.Instance:GetMainRoleVo().prof, cell_index)
	end
	contain_cell:InitItems(item_id_list, item_seq_list)
	contain_cell:SetIndex(cell_index)
end

function ExchangeContentView:SetCurrentPriceType(price_type)
	self.current_price_type = price_type
end

function ExchangeContentView:GetCurrentPriceType()
	return self.current_price_type
end

function ExchangeContentView:OnFlushListView()
	self.list_view.scroller:ReloadData(0)
end

function ExchangeContentView:FlushAllFrame()
	for k,v in pairs(self.contain_cell_list) do
		v:FlushAllFrame()
	end
end

function ExchangeContentView:SetIsOpen(is_open)
	self.is_open = is_open
end

------------------------------------------------------------------------
ExchangeContain = ExchangeContain  or BaseClass(BaseCell)

function ExchangeContain:__init()
	self.exchange_contain_list = {}
	for i = 1, ExchangeData.EXCHANGE_COL_ITEM do
		self.exchange_contain_list[i] = {}
		self.exchange_contain_list[i] = ExchangeItem.New(self:FindObj("item_" .. i))
	end
end

function ExchangeContain:__delete()
	for i = 1, ExchangeData.EXCHANGE_COL_ITEM do
		self.exchange_contain_list[i]:DeleteMe()
		self.exchange_contain_list[i] = nil
	end
end

function ExchangeContain:GetFirstCell()
	return self.exchange_contain_list[1]
end

function ExchangeContain:InitItems(item_id_list, item_seq_list)
	for i = 1, ExchangeData.EXCHANGE_COL_ITEM do
		self.exchange_contain_list[i]:SetItemId(item_id_list[i], item_seq_list[i])
		self.exchange_contain_list[i]:OnFlush()
	end
end

function ExchangeContain:FlushItems(item_id_list, toggle_group)
	for i = 1, ExchangeData.EXCHANGE_COL_ITEM do
		local consume_type = ShopData.Instance:GetConsumeType(ShopContentView.Instance:GetCurrentShopType())
		if item_id_list[i] ~= 0 then
			local data = ItemData.Instance:GetItemConfig(item_id_list[i]) or {}
			data.item_id = data.id
			if consume_type == SHOP_BIND_TYPE.BIND then
				data.is_bind = 1
			elseif consume_type == SHOP_BIND_TYPE.NO_BIND then
				data.is_bind = 0
			end
			self.shop_contain_list[i].item_cell:SetData(data)
		end
		self.shop_contain_list[i].item_frame:FlushFrame(item_id_list[i])
	end
end

function ExchangeContain:SetToggleGroup(toggle_group)
	for i = 1, ExchangeData.EXCHANGE_COL_ITEM do
		self.exchange_contain_list[i]:SetToggleGroup(toggle_group)
	end
end

function ExchangeContain:FlushAllFrame()
	for i = 1, ExchangeData.EXCHANGE_COL_ITEM do
		self.exchange_contain_list[i]:OnFlush()
	end
end
----------------------------------------------------------------------------
ExchangeItem = ExchangeItem or BaseClass(BaseCell)

function ExchangeItem:__init()
	self.name = self:FindVariable("name")
	self.coin = self:FindVariable("coin")
	self.coin_icon = self:FindVariable("coin_icon")
	self.remain_text = self:FindVariable("remain_text")
	self.limit_text = self:FindVariable("limit_text")
	self:ListenEvent("OnClickToggle", BindTool.Bind(self.OnToggleClick, self))
	self.item_id = 0
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item"))
	self.item_cell:ShowHighLight(false)
	self.price_multile = 0
	self.cur_multile_price = 0
	self.multiple_time = 0
	self.is_max_multiple = false
end

function ExchangeItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ExchangeItem:SetItemId(item_id, item_seq)
	self.item_id = item_id
	self.item_seq = item_seq
end

function ExchangeItem:OnFlush()
	self.price_multile = 0
	self.cur_multile_price = 0
	self.multiple_time = 0
	self.is_max_multiple = false
	self.root_node:SetActive(true)
	if self.item_id == 0 then
		self.root_node:SetActive(false)
		return
	end
	local item_info = ExchangeData.Instance:GetExchangeCfg(self.item_id, ExchangeContentView.Instance:GetCurrentPriceType())
	if not item_info then return end
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local text = ""
	local price_type = ExchangeContentView.Instance:GetCurrentPriceType()
	local conver_value = ExchangeData.Instance:GetCurConvertCount(self.item_seq, item_info.conver_type)
	local multiple_cfg = ExchangeData.Instance:GetMultipleCostCfg(conver_value + 1, item_info.multiple_cost_id)
	if multiple_cfg then
		self.multiple_time = multiple_cfg.times_max - conver_value
		text = 0 == multiple_cfg.is_max_times and Language.Exchange.Change .. self.multiple_time .. Language.Exchange.TwoMoney or Language.Exchange.MaxTime
		self.price_multile = multiple_cfg.price_multile
		self.is_max_multiple = 1 == multiple_cfg.is_max_times
	end

	if item_info.require_type == REQUIRE_TYPE.LEVEL and main_role_vo.level < item_info.require_value then
		local lv, zhuan = PlayerData.GetLevelAndRebirth(item_info.require_value)
		local level_des = string.format(Language.Common.LevelFormat, lv, zhuan)
		text = string.format(Language.Exchange.NeedLevel, level_des)
	end

	local desc = item_info.lifetime_convert_count > 0 and Language.Exchange.CanExchange or Language.Exchange.LimitValue
	local limit_value = desc .. ToColorStr(item_info.limit_convert_count - conver_value, COLOR.GREEN).. "/" .. item_info.limit_convert_count
	
	self.limit_text:SetValue((item_info.limit_convert_count == 0 or text ~= "") and "" or limit_value)

	self.remain_text:SetValue(text)
	
	local res = ExchangeData.Instance:GetExchangeRes(ExchangeContentView.Instance:GetCurrentPriceType())
	local bundle, asset = ResPath.GetExchangeNewIcon(res)
	self.coin_icon:SetAsset(bundle, asset)

	local price = item_info.price * (self.price_multile == 0 and 1 or self.price_multile)
	self.cur_multile_price = price

	local tab_index = ExchangeCtrl.Instance:GetToggleIndex()
	local top_coin = ExchangeData.Instance:GetCurrentScore(tab_index)
	price = top_coin < price and ToColorStr(price, TEXT_COLOR.RED) or ToColorStr(price, TEXT_COLOR.Kill_COLOR)
	self.coin:SetValue(price)
	local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)
	if item_cfg then
		self.name:SetValue(item_cfg.name)
		self.item_cell:SetData({item_id = self.item_id, is_bind = item_info.is_bind})
		self.item_cell:IsDestoryActivityEffect(not ExchangeData.Instance:IsShowEffect(self.item_id))
	end
end

function ExchangeItem:SelectToggle()
	self.root_node.toggle.isOn = true
end

function ExchangeItem:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
	self.root_node.toggle.isOn = false
end

function ExchangeItem:OnToggleClick()
	local buy_num = 1
	local item_info = ExchangeData.Instance:GetExchangeCfg(self.item_id, ExchangeContentView.Instance:GetCurrentPriceType())
	if item_info.item_id ~= 26615 then
		ExchangeCtrl.Instance:SendScoreToItemConvertReq(item_info.conver_type, item_info.seq, buy_num)
	else
		TipsCtrl.Instance:OpenCommonInputView(1, BindTool.Bind(self.InputNumBuy, self), nil, self.multiple_time > 999 and 999 or self.multiple_time)
	end
end

function ExchangeItem:InputNumBuy(value)
	local num = tonumber(value)
	local item_info = ExchangeData.Instance:GetExchangeCfg(self.item_id, ExchangeContentView.Instance:GetCurrentPriceType())
	ExchangeCtrl.Instance:SendScoreToItemConvertReq(item_info.conver_type, item_info.seq, num)
end