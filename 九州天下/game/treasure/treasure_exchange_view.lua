TreasureExchangeView = TreasureExchangeView or BaseClass(BaseRender)

function TreasureExchangeView:__init(instance)
	self.exchange_contain_list = {}
	self.coin_text = self:FindVariable("gold_text")
	self.item_cfg_list = TreasureData.Instance:GetItemIdListByJobAndType(TREASURE_EXCHANGE_CONVER_TYPE, EXCHANGE_PRICE_TYPE.TREASURE,GameVoManager.Instance:GetMainRoleVo().prof)
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function TreasureExchangeView:__delete()
	if self.exchange_contain_list ~= nil then
		for k, v in pairs(self.exchange_contain_list) do
			v:DeleteMe()
		end
	end
	self.exchange_contain_list = {}
end

function TreasureExchangeView:GetNumberOfCells()
	local count = #self.item_cfg_list
	if count%4 ~= 0 then
		return math.floor(count/4) + 1
	else
		return count/4
	end
end

function TreasureExchangeView:RefreshCell(cell, cell_index)
	local exchange_contain = self.exchange_contain_list[cell]
	if exchange_contain == nil then
		exchange_contain = TreasureExchangeContain.New(cell.gameObject, self)
		self.exchange_contain_list[cell] = exchange_contain
	end
	cell_index = cell_index + 1
	local item_id_list = TreasureData.Instance:GetItemListByJobAndIndex(TREASURE_EXCHANGE_CONVER_TYPE, EXCHANGE_PRICE_TYPE.TREASURE,GameVoManager.Instance:GetMainRoleVo().prof,cell_index)
	exchange_contain:SetData(item_id_list)
end

function TreasureExchangeView:OnFlush()
	for k,v in pairs(self.exchange_contain_list) do
		v:Flush()
	end
end

----------------------------------------------------------------------------
TreasureExchangeContain = TreasureExchangeContain or BaseClass(BaseCell)
function TreasureExchangeContain:__init()
	self.item_list = {}
	for i=1, 4 do
		self.item_list[i] = TreasureExchangeItem.New(self:FindObj("item_"..i))
	end
end
function TreasureExchangeContain:__delete()
	if self.item_list ~= nil then
		for k, v in pairs(self.item_list) do
			v:DeleteMe()
		end
	end
	self.item_list = {}
end

function TreasureExchangeContain:OnFlush()
	for i=1,4 do
		self.item_list[i]:SetData(self.data[i])
		self.item_list[i]:Flush()
	end
end
----------------------------------------------------------------------------
TreasureExchangeItem = TreasureExchangeItem or BaseClass(BaseCell)

function TreasureExchangeItem:__init()
	self.name = self:FindVariable("name")
	self.coin = self:FindVariable("coin")
	self.max_times = self:FindVariable("MaxTimes")
	self.had_use_times = self:FindVariable("HadUseTimes")
	self.max_times = self:FindVariable("MaxTimes")
	self.show_limit = self:FindVariable("ShowLimit")
	self.icon_image = self:FindVariable("IconImage")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("Item"))
	self:ListenEvent("click", BindTool.Bind(self.OnExchangeClick, self))
end

function TreasureExchangeItem:__delete()
	self.item_cell:DeleteMe()
	self.item_cell = nil
end

function TreasureExchangeItem:OnFlush()
	self.root_node:SetActive(true)
	if self.data == 0 then
		self.root_node:SetActive(false)
		return
	end
	local item_info = ExchangeData.Instance:GetExchangeCfg(self.data, EXCHANGE_PRICE_TYPE.TREASURE)
	local item_cfg = ItemData.Instance:GetItemConfig(self.data)
	local prop_name = "<color="..SOUL_NAME_COLOR[item_cfg and item_cfg.color or 1]..">"..item_cfg.name.."</color>"

	local bundle, asset = ResPath.GetItemIcon(TreasureData.Instance:GetOtherCfg().score_item_id)
	if bundle and asset then
		self.icon_image:SetAsset(bundle, asset)
	end

	self.name:SetValue(prop_name)
	self.coin:SetValue(item_info.price)
	self.item_cell:IsDestoryActivityEffect(item_info.price >= 1000)
	self.item_cell:SetActivityEffect()
	self.max_times:SetValue(item_info.limit_convert_count)
	local text = ""
	self.show_limit:SetValue(item_info.limit_convert_count ~= 0)
	if item_info.limit_convert_count ~= 0 then
		local conver_value = ExchangeData.Instance:GetConvertCount(item_info.seq, EXCHANGE_CONVER_TYPE.DAO_JU, EXCHANGE_PRICE_TYPE.TREASURE)
		if conver_value == item_info.limit_convert_count then
			text = tostring(conver_value)
			text = ToColorStr(text, TEXT_COLOR.RED)
		else
			text = tostring(conver_value)
			text = ToColorStr(text, TEXT_COLOR.GREEN)
		end
	end
	self.had_use_times:SetValue(text)
	local data = {}
	data.item_id = self.data
	data.is_bind = item_info.is_bind
	self.item_cell:SetData(data)
end

function TreasureExchangeItem:OnExchangeClick()
	local exchange_item_cfg = ExchangeData.Instance:GetExchangeCfg(self.data, EXCHANGE_PRICE_TYPE.TREASURE)
	local treasure_list = TreasureData.Instance:GetOtherCfg()
	local score_num = ItemData.Instance:GetItemNumInBagById(treasure_list.score_item_id)
	if score_num >= exchange_item_cfg.price then
		ExchangeCtrl.Instance:SendScoreToItemConvertReq(exchange_item_cfg.conver_type, exchange_item_cfg.seq, 1)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.LackTreasureScore)
	end
end