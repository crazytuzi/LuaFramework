BlackMarketView = BlackMarketView or BaseClass(BaseView)

function BlackMarketView:__init()
	self.ui_config = {"uis/views/randomact/blackmarket_prefab", "BlackMarketView"}
	self.play_audio = true
	self.cell_list = {}
end

function BlackMarketView:__delete()

end

function BlackMarketView:LoadCallBack()
	self:ListenEvent("Close",
		BindTool.Bind(self.Close, self))
	self.act_time = self:FindVariable("ActTime")
	self.bid_time = self:FindVariable("CoutdownTime")

	self:InitScroller()
	self.my_name = GameVoManager.Instance:GetMainRoleVo().name
end

function BlackMarketView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	-- 清理变量和对象
	self.scroller = nil
	self.act_time = nil
	self.bid_time = nil
	self.my_name = nil
end

function BlackMarketView:InitScroller()
	self.scroller = self:FindObj("ListView")
	self.data = BlackMarketData.Instance:GetItemInfoList()
	local delegate = self.scroller.list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	-- 格子刷新
	delegate.CellRefreshDel = BindTool.Bind(self.GetCellRefreshDel, self)
end

function BlackMarketView:GetNumberOfCells()
	local data_list = BlackMarketData.Instance:GetItemInfoList()
	return data_list and #data_list or 0
end

function BlackMarketView:GetCellRefreshDel(cell, data_index, cell_index)
	data_index = data_index + 1
	local target_cell = self.cell_list[cell]

	if nil == target_cell then
		self.cell_list[cell] = BlackMarketCell.New(cell.gameObject)
		target_cell = self.cell_list[cell]
	end

	local data_list = BlackMarketData.Instance:GetItemInfoList()
	target_cell:SetData(data_list[data_index])
	target_cell:SetMyName(self.my_name)
end

function BlackMarketView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BLACKMARKET_AUCTION, RA_BLACK_MARKET_OPERA_TYPE.RA_BLACK_MARKET_OPERA_TYPE_ALL_INFO)
end

function BlackMarketView:ShowIndexCallBack(index)

end

function BlackMarketView:CloseCallBack()

end

function BlackMarketView:OnFlush(param_t)
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end

	if self.scroller then
		self.scroller.scroller:ReloadData(0)
	end
end

function BlackMarketView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BLACKMARKET_AUCTION)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end

	if time > 3600 * 24 then
		self.act_time:SetValue("<color='#00ff00'>" .. TimeUtil.FormatSecond(time, 6) .. "</color>")
	elseif time > 3600 then
		self.act_time:SetValue("<color='#00ff00'>" .. TimeUtil.FormatSecond(time, 1) .. "</color>")
	else
		self.act_time:SetValue("<color='#00ff00'>" .. TimeUtil.FormatSecond(time, 2) .. "</color>")
	end

	local now_time = TimeCtrl.Instance:GetServerTime()
	local day_end_time = TimeUtil.NowDayTimeEnd(now_time) - now_time
	if day_end_time > 3600 * 24 then
		self.bid_time:SetValue("<color='#00ff00'>" .. TimeUtil.FormatSecond(day_end_time, 6) .. "</color>")
	elseif day_end_time > 3600 then
		self.bid_time:SetValue("<color='#00ff00'>" .. TimeUtil.FormatSecond(day_end_time, 1) .. "</color>")
	else
		self.bid_time:SetValue("<color='#00ff00'>" .. TimeUtil.FormatSecond(day_end_time, 2) .. "</color>")
	end
end

---------------------------------------------------------------
--滚动条格子

BlackMarketCell = BlackMarketCell or BaseClass(BaseCell)

function BlackMarketCell:__init()
	self.item_name = self:FindVariable("ItemName")
	self.low_price = self:FindVariable("LowPrice")
	self.cur_price = self:FindVariable("CurPrice")
	self.role_name = self:FindVariable("RoleName")
	self.desc = self:FindVariable("Descript")
	self.is_my = self:FindVariable("IsMy")

	self.reward_item = ItemCell.New()
	self.reward_item:SetInstanceParent(self:FindObj("Item"))
	self:ListenEvent("ClickBuy", BindTool.Bind(self.ClickBuy, self))
	self.my_name = GameVoManager.Instance:GetMainRoleVo().name
end

function BlackMarketCell:__delete()
	self.reward_item:DeleteMe()
	self.reward_item = nil

	self.item_name = nil
	self.low_price = nil
	self.cur_price = nil
	self.role_name = nil
	self.desc = nil
end

function BlackMarketCell:SetMyName(name)
	self.my_name = name
end

function BlackMarketCell:OnFlush()
	if nil == self.data then
		return
	end

	local cfg = BlackMarketData.Instance:GetItemConfigBuySeq(self.data.seq)
	if nil == cfg then
		self.root_node:SetActive(false)
		return
	end

	self.root_node:SetActive(true)
	self.reward_item:SetData(cfg.item)
	self.desc:SetValue(cfg.description)

	local item_cfg = ItemData.Instance:GetItemConfig(cfg.item.item_id)
	-- local name_str = string.format(Language.Common.ToColor, SOUL_NAME_COLOR[item_cfg.color], item_cfg.name)
	local name_str = item_cfg.name
	self.item_name:SetValue(name_str)
	self.low_price:SetValue(cfg.init_gold)
	self.cur_price:SetValue(self.data.cur_price)
	self.is_my:SetValue(self.data.buyer_name ~= self.my_name)
	self.role_name:SetValue(self.data.buyer_uid > 0 and self.data.buyer_name or Language.Activity.NoOneBuy)
end

function BlackMarketCell:ClickBuy()
	BlackMarketCtrl.Instance:OpenBlackMarketBidView(self.data)
end