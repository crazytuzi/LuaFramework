FestivalLeiChongData = FestivalLeiChongData or BaseClass()

function FestivalLeiChongData:__init()
	if nil ~= FestivalLeiChongData.Instance then
		return
	end

	FestivalLeiChongData.Instance = self

	self.leichong_has_fetch = {}
end

function FestivalLeiChongData:__delete()

end

function FestivalLeiChongData:SetFesLeiChongInfo(protocol)
	self.charge_value = protocol.total_charge_value
	self.leichong_has_fetch = bit:d2b(protocol.reward_has_fetch_flag)
end

function FestivalLeiChongData:GetVesTotalChargeCfg()
	local grand_total_charge_config = ServerActivityData.Instance:GetCurrentRandActivityConfig().versions_grand_total_charge
	local cfg = ActivityData.Instance:GetRandActivityConfig(grand_total_charge_config, FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_VERSIONS_GRAND_TOTAL_CHARGE)
	
	return cfg
end

function FestivalLeiChongData:GetChargeValue()
	return self.charge_value or 0
end

function FestivalLeiChongData:GetFetchFlag(index)
	return self.leichong_has_fetch[32 - index]
end