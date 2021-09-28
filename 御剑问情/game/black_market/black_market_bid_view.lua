BlackMarketBidView = BlackMarketBidView or BaseClass(BaseView)

function BlackMarketBidView:__init()
	self.ui_config = {"uis/views/randomact/blackmarket_prefab", "BlackMarketBidView"}
	self.data = nil
end

function BlackMarketBidView:__delete()
	self.data = nil
end

function BlackMarketBidView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.Close, self))
	self:ListenEvent("OnClickBid", BindTool.Bind(self.OnClickBid, self))
	self:ListenEvent("OnClickNum", BindTool.Bind(self.OnClickNum, self))

	self.item_name = self:FindVariable("ItemName")
	self.cur_price = self:FindVariable("CurPrice")
	self.min_add_price = self:FindVariable("MinAddPrice")
	self.bid_price = self:FindVariable("BidPrice")

	self.reward_item = ItemCell.New()
	self.reward_item:SetInstanceParent(self:FindObj("Item"))

	self.bid_price_vallue = nil
end

function BlackMarketBidView:ReleaseCallBack()
	if self.reward_item then
		self.reward_item:DeleteMe()
		self.reward_item = nil
	end

	self.data = nil
	self.item_name = nil
	self.cur_price = nil
	self.min_add_price = nil
	self.bid_price = nil
end

function BlackMarketBidView:OpenCallBack()
	self:Flush()
end

function BlackMarketBidView:CloseCallBack()
	self.bid_price_vallue = nil
end

function BlackMarketBidView:OnClickBid()
	if PlayerData.Instance:GetRoleVo().gold < self.bid_price_vallue then
		TipsCtrl.Instance:ShowLackDiamondView()
		return
	end

	local func = function()
		KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BLACKMARKET_AUCTION,
		RA_BLACK_MARKET_OPERA_TYPE.RA_BLACK_MARKET_OPERA_TYPE_OFFER, self.data.seq, self.bid_price_vallue)
		TipsCtrl.Instance:CloseCommonTip()
		self:Close()
	end

	TipsCtrl.Instance:ShowCommonTip(func, nil, string.format(Language.Activity.ToCharge, self.bid_price_vallue), nil, nil, false)
end

function BlackMarketBidView:OnClickNum()
	TipsCtrl.Instance:OpenCommonInputView(self.bid_price_vallue, BindTool.Bind(self.NumPadOkCallBack, self), nil, 100000)
end

function BlackMarketBidView:NumPadOkCallBack(cur_num)
	cur_num = tonumber(cur_num)
	local cfg = BlackMarketData.Instance:GetItemConfigBuySeq(self.data.seq)
	local price = self.data.buyer_uid > 0 and (self.data.cur_price + cfg.min_add_gold) or self.data.cur_price
	self.bid_price_vallue = cur_num < price and price or cur_num
	self.bid_price:SetValue(self.bid_price_vallue)
end

function BlackMarketBidView:SetData(data)
	self.data = data
end

function BlackMarketBidView:OnFlush(param_t)
	if nil == self.data then
		return
	end

	local cfg = BlackMarketData.Instance:GetItemConfigBuySeq(self.data.seq)
	self.reward_item:SetData(cfg.item)

	local item_cfg = ItemData.Instance:GetItemConfig(cfg.item.item_id)
	local name_str = string.format(Language.Common.ToColor, SOUL_NAME_COLOR[item_cfg.color], item_cfg.name)
	self.item_name:SetValue(name_str)

	self.cur_price:SetValue(self.data.cur_price)
	self.min_add_price:SetValue(cfg.min_add_gold)

	local price = self.data.buyer_uid > 0 and (self.data.cur_price + cfg.min_add_gold) or self.data.cur_price
	self.bid_price_vallue = self.bid_price_vallue or price
	self.bid_price:SetValue(self.bid_price_vallue)
end
