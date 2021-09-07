MeiRiZhanBeiView = MeiRiZhanBeiView or BaseClass(BaseRender)

function MeiRiZhanBeiView:__init()
	self.ui_config = {"uis/views/kaifuchargeview","MeiRiZhanBeiContent"}
end

function MeiRiZhanBeiView:__delete()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	self.is_Get = nil
	self.res_time = nil
	self.buy_num = nil
	self.time = nil
	self.gift_name = {}
	if self.item_cell then
		for k, v in pairs(self.item_cell) do
			v:DeleteMe()
		end
		self.item_cell = {}
	end

	if self.coin_item then
		self.coin_item:DeleteMe()
		self.coin_item = nil
	end
	self.show_redpoint = nil
end

function MeiRiZhanBeiView:LoadCallBack()
	self.select_index = 1
	self.is_Get = self:FindVariable("is_Get")
	self.buy_num = self:FindVariable("buy_num")
	self.show_redpoint = self:FindVariable("show_RedPoint")
	self.is_buy = self:FindVariable("is_buy")
	self.buy_rmb = self:FindVariable("buy_rmb")
	self.time = self:FindVariable("Time")
	self.gift_name = {}
	self.coin_item = {}
	for i = 1, 3 do
		self.gift_name[i] = self:FindVariable("gift_name_" .. i)
	end
	self:ListenEvent("ClickBuy", BindTool.Bind(self.OnClickBuy, self))
	self:ListenEvent("ClickGet", BindTool.Bind(self.OnClickGet, self))
	for i = 1, 3 do
		self:ListenEvent("ClickGift_" .. i, BindTool.Bind(self.OnClicKGift,self,i))
	end
	self.item_cell = {}
	for i = 1, 4 do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("itemcell_" .. i))
		self.item_cell[i] = item
	end
	self:ClearTimer()
	self.timer_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind2(self.Time, self), 1)
	self.coin_item = ItemCell.New()
	self.coin_item:SetInstanceParent(self:FindObj("ItemInfo"))
	self:Flush()
	self:ShowGiftName()
	self:SetData()
end

function MeiRiZhanBeiView:OnFlush()
	local buy_fetch = KaiFuChargeData.Instance:GetLiBaoBuyFetch()
	if buy_fetch then
		self.is_Get:SetValue(buy_fetch == 1)
		self.show_redpoint:SetValue(buy_fetch == 0)
	end
end

function MeiRiZhanBeiView:OnClickBuy()
	local data = KaiFuChargeData.Instance:GetKaiFuInFo(self.select_index - 1)
	if data == nil then return end
	local rmb_num = data.need_gold / 10
	local item_name = ToColorStr(data.gift_name, TEXT_COLOR.GREEN)
	local stree = string.format(Language.GifyInfo.BuySure,rmb_num)
	local auto_desc = stree .. item_name .. "\n\n\n" .. Language.Recharge.XianGouLiBao
	local func = function()
		KaiFuChargeCtrl.Instance:SendBuyType(RMB_BUY_TYPE.RMB_BUY_TYPE_RA_XIANGOULIBAO, self.select_index - 1)
		RechargeCtrl.Instance:Recharge(rmb_num)
	end
	TipsCtrl.Instance:ShowCommonAutoView(nil, auto_desc, func)
end

function MeiRiZhanBeiView:OnClickGet()
	KaiFuChargeCtrl.Instance:SendGiftReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MEIRI_ZHANBEI_GIFT,
		RA_DAILY_XIANGOULIBAO_OPERA_TYPE.RA_DAILY_XIANGOULIBAO_OPERA_TYPE_FETCH_COIN)
end

function MeiRiZhanBeiView:OnClicKGift(index)
	self.select_index = index
	self:ShowGiftInfo()
	self:SetData()
end

function MeiRiZhanBeiView:SetData()
	local data = KaiFuChargeData.Instance:GetKaiFuInFo(self.select_index - 1)
	if data == nil then return end
	local item_list = data.reward_items[0]
	local giftItemList = ItemData.Instance:GetGiftItemList(item_list.item_id)
	if item_list then
		for i = 1, #giftItemList do
			self.item_cell[i]:SetData({item_id = giftItemList[i].item_id,num = giftItemList[i].num})
		end	
	end
end

function MeiRiZhanBeiView:ShowGiftName()
	self:ShowGiftInfo()
	self:ShowCoinInfo()
	for i = 1, 3 do
		local data = KaiFuChargeData.Instance:GetKaiFuInFo(i - 1)
		if data then
			self.gift_name[i]:SetValue(data.gift_name)
		end
	end
end

function MeiRiZhanBeiView:ShowCoinInfo()
	local coin_data = KaiFuChargeData.Instance:GetCoinCfg()
	if coin_data then
		local coin_item = coin_data[1].daily_xiangoulibao_fetch_coin
		self.coin_item:SetData({item_id = coin_item.item_id,num = coin_item.num})
	end
end

function MeiRiZhanBeiView:ShowGiftInfo()
	local data = KaiFuChargeData.Instance:GetKaiFuInFo(self.select_index - 1)
	local buy_list = KaiFuChargeData.Instance:GetLiBaoBuyNum()
	local buy_num = buy_list[self.select_index]
	if data and buy_list and buy_num then
		local buy_max = data.daily_buy_count_limit
		local num = buy_max - buy_num
		self.buy_num:SetValue(num .. "/" .. buy_max)
		self.is_buy:SetValue(buy_num == buy_max)
		self.buy_rmb:SetValue(data.need_gold / 10)
	end
end

function MeiRiZhanBeiView:ClearTimer()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function MeiRiZhanBeiView:Time()
	local server_time = TimeCtrl.Instance:GetServerTime()
	local end_time = TimeUtil.NowDayTimeEnd(server_time)
	local time = end_time - server_time
	local str = TimeUtil.FormatSecond(time)
	self.time:SetValue(str)
end