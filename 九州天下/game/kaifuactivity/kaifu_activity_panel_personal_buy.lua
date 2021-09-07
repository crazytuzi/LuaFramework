KaifuActivityPanelPersonBuy = KaifuActivityPanelPersonBuy or BaseClass(BaseRender)

function KaifuActivityPanelPersonBuy:__init(instance)
	self.list = self:FindObj("ListView")
	self.list_delegate = self.list.list_simple_delegate
	-- list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	-- list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.cell_list = {}
end

function KaifuActivityPanelPersonBuy:__delete()
	self.temp_activity_type = nil
	self.activity_type = nil

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function KaifuActivityPanelPersonBuy:GetNumberOfCells()
	return #KaifuActivityData.Instance:GetPersonalActivitySortCfg()
end

function KaifuActivityPanelPersonBuy:RefreshCell(cell, data_index)
	local cell_item = self.cell_list[cell]
	if cell_item == nil then
		cell_item = PanelPersonBuyListCell.New(cell.gameObject)
		self.cell_list[cell] = cell_item
	end
	local sort_cfg = KaifuActivityData.Instance:GetPersonalActivitySortCfg()[data_index + 1]
	local cfg = KaifuActivityData.Instance:GetPersonalActivityCfgBySeq(sort_cfg.seq)
	local buy_info = KaifuActivityData.Instance:GetPersonalBuyInfo()
	cell_item:SetData(cfg, buy_info[cfg.seq + 1])
	cell_item:ListenClick(BindTool.Bind(self.OnClickBuy, self, cfg, buy_info[cfg.seq + 1]))
end

function KaifuActivityPanelPersonBuy:OnClickBuy(cfg, buy_num)
	if not cfg then
		return
	end

	if buy_num >= cfg.limit_buy_count then
		TipsCtrl.Instance:ShowSystemMsg(Language.Activity.BuyLimitTip)
		return
	end

	local func = function()
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(cfg.activity_type, RA_PERSONAL_PANIC_BUY_OPERA_TYPE.RA_PERSONAL_PANIC_BUY_OPERA_TYPE_BUY_ITEM, cfg.seq)
	end
	local str = string.format(Language.Activity.BuyGiftTip, cfg.gold_price)
	TipsCtrl.Instance:ShowCommonAutoView("personal_auto_buy", str, func)
end

function KaifuActivityPanelPersonBuy:Flush(activity_type)
	self.activity_type = activity_type or self.activity_type

	self.list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	if activity_type == self.temp_activity_type then
	-- 	self.list.scroller:RefreshActiveCellViews()
	-- else
	-- 	if self.list.scroller.isActiveAndEnabled then
			self.list.scroller:ReloadData(0)
		-- end
	end
	self.temp_activity_type = activity_type
end


PanelPersonBuyListCell = PanelPersonBuyListCell or BaseClass(BaseRender)

function PanelPersonBuyListCell:__init(instance)
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("Item"))

	self.gift_name = self:FindVariable("GiftName")
	self.price = self:FindVariable("Price")
	self.limit_num = self:FindVariable("LimitNum")
	self.had_buy_num = self:FindVariable("HadBuyNum")
	self.show_price = self:FindVariable("OldPrice")
	self.show_had_limit = self:FindVariable("HadLimit")
	self.discount = self:FindVariable("Discount")
	self.buy_button = self:FindObj("BuyButton")
end

function PanelPersonBuyListCell:__delete()
	if self.item ~= nil then
		self.item:DeleteMe()
		self.item = nil
	end
end

function PanelPersonBuyListCell:SetData(data, buy_num)
	if not data then return end
	local buy_num = buy_num or 0
	self.discount:SetValue(data.discount)
	self.show_price:SetValue(data.show_price)
	self.price:SetValue(data.gold_price)
	self.limit_num:SetValue(data.limit_buy_count)
	self.item:SetData(data.reward_item)
	local item_cfg = ItemData.Instance:GetItemConfig(data.reward_item.item_id)
	if item_cfg then
		local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
		self.gift_name:SetValue(name_str)
	end
	self.show_had_limit:SetValue(buy_num >= data.limit_buy_count)
	self.had_buy_num:SetValue(buy_num)
	
	self.buy_button.button.interactable = buy_num < data.limit_buy_count
end

function PanelPersonBuyListCell:ListenClick(handler)
	self:ClearEvent("OnClickBuy")
	self:ListenEvent("OnClickBuy", handler)
end