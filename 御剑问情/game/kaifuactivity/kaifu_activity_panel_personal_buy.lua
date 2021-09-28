KaifuActivityPanelPersonBuy = KaifuActivityPanelPersonBuy or BaseClass(BaseRender)

function KaifuActivityPanelPersonBuy:__init(instance)
	self.list = self:FindObj("ListView")
	local list_delegate = self.list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.cell_list = {}

	self.page_num = self:FindVariable("page_num")
	self.rest_time=self:FindVariable("rest_time")

 	local rest_time = ActivityData.Instance:GetActivityResidueTime(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUNDER_TIMES_SHOP)
	self:SetTime(0, rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, BindTool.Bind(self.SetTime, self))
end

function KaifuActivityPanelPersonBuy:SetTime(elapse_time, total_time)
	local rest_time = math.floor(total_time - elapse_time)
	-- local time_str = ""
	-- local left_day = math.floor(rest_time / 86400)
	-- if left_day > 0 then
	-- 	time_str = TimeUtil.FormatSecond(rest_time, 8)
	-- else
	-- 	time_str = TimeUtil.FormatSecond(rest_time)
	-- end
	local time_str = ""
	local day_second = 24 * 60 * 60         -- 一天有多少秒
	local left_day = math.floor(rest_time / day_second)
	if left_day > 0 then
		time_str = TimeUtil.FormatSecond(rest_time, 7)
	elseif rest_time < day_second then
		if math.floor(rest_time / 3600) > 0 then
			time_str = TimeUtil.FormatSecond(rest_time, 1)
		else
			time_str = TimeUtil.FormatSecond(rest_time, 2)
		end
	end
	self.rest_time:SetValue(time_str)
end

function KaifuActivityPanelPersonBuy:__delete()
	self.temp_activity_type = nil
	self.activity_type = nil

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

local PAGE_COUNT = 3

function KaifuActivityPanelPersonBuy:GetNumberOfCells()
	local count = math.ceil(#self.reward_list / PAGE_COUNT)
	if self.page_num then
		self.page_num:SetValue(count)
		self.list.list_page_scroll:SetPageCount(count)
	end
	return math.ceil(#self.reward_list / 3) * 3
end

function KaifuActivityPanelPersonBuy:RefreshCell(cell, data_index)
	local cell_item = self.cell_list[cell]
	if cell_item == nil then
		cell_item = PanelPersonBuyListCell.New(cell.gameObject)
		self.cell_list[cell] = cell_item
	end

	data_index = data_index + 1
	if nil ~= self.reward_list[data_index] then
		local sort_cfg = self.reward_list[data_index]
		local cfg = KaifuActivityData.Instance:GetPersonalActivityCfgBySeq(sort_cfg.seq)
		local buy_info = KaifuActivityData.Instance:GetPersonalBuyInfo()
		cell_item:SetData(cfg, buy_info[cfg.seq + 1])
		cell_item:ListenClick(BindTool.Bind(self.OnClickBuy, self, cfg, buy_info[cfg.seq + 1]))
	else
		cell_item:SetData()
	end
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

function KaifuActivityPanelPersonBuy:OnFlush()
	self.reward_list = KaifuActivityData.Instance:GetPersonalActivitySortCfg() or {}
	if self.list then
		self.list.scroller:RefreshAndReloadActiveCellViews(true)
	end
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
	self.been_gray = self:FindVariable("BeenGray")
	self.set_active = self:FindVariable("SetActive")
end

function PanelPersonBuyListCell:__delete()
	if self.item ~= nil then
		self.item:DeleteMe()
		self.item = nil
	end
end

function PanelPersonBuyListCell:SetData(data, buy_num)
	if not data then
		self.set_active:SetValue(false)
		return
	end
	self.set_active:SetValue(true)
	local buy_num = buy_num or 0
	self.discount:SetValue(data.discount)
	self.show_price:SetValue(data.show_price)
	self.price:SetValue(data.gold_price)
	self.limit_num:SetValue(data.limit_buy_count - buy_num)
	self.item:SetData(data.reward_item)
	local item_cfg = ItemData.Instance:GetItemConfig(data.reward_item.item_id)
	if item_cfg then
		-- local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
		local name_str = item_cfg.name
		self.gift_name:SetValue(name_str)
	end
	self.show_had_limit:SetValue(buy_num >= data.limit_buy_count)
	self.had_buy_num:SetValue(buy_num)

	self.buy_button.button.interactable = buy_num < data.limit_buy_count
	self.been_gray:SetValue(buy_num < data.limit_buy_count)
end

function PanelPersonBuyListCell:ListenClick(handler)
	self:ClearEvent("OnClickBuy")
	self:ListenEvent("OnClickBuy", handler)
end