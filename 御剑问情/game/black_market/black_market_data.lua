RA_BLACK_MARKET_OPERA_TYPE = {
	RA_BLACK_MARKET_OPERA_TYPE_ALL_INFO = 0,	--  请求信息
	RA_BLACK_MARKET_OPERA_TYPE_OFFER = 1,		--  竞价

	RA_BLACK_MARKET_OPERA_TYPE_MAX,
}

BlackMarketData = BlackMarketData or BaseClass()

function BlackMarketData:__init()
	if BlackMarketData.Instance then
		ErrorLog("[BlackMarketData] attempt to create singleton twice!")
		return
	end
	BlackMarketData.Instance =self

end

function BlackMarketData:__delete()
	BlackMarketData.Instance = nil
end

function BlackMarketData:GetBlackMarketCfg()
	local rand_act_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	return ActivityData.Instance:GetRandActivityConfig(rand_act_cfg.black_market, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BLACKMARKET_AUCTION)
end

function BlackMarketData:SetItemInfoData(item_info_list)
	self.item_info_list = item_info_list
end

function BlackMarketData:GetItemInfoList()
	return self.item_info_list
end

function BlackMarketData:GetItemConfigBuySeq(seq)
	local act_cfg = self:GetBlackMarketCfg()
	local pass_day = ActivityData.Instance:GetActDayPassFromStart(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BLACKMARKET_AUCTION)
	for k,v in pairs(act_cfg) do
		if v.day == pass_day and v.seq == seq then
			return v
		end
	end

	for k,v in pairs(act_cfg) do
		if v.seq == seq then
			return v
		end
	end
end
