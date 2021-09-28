TimeLimitBigGiftData = TimeLimitBigGiftData or BaseClass()

function TimeLimitBigGiftData:__init()
	if TimeLimitBigGiftData.Instance then
		print_error("[TimeLimitBigGiftData] Attemp to create a singleton twice !")
	end
	TimeLimitBigGiftData.Instance = self
	self.reward_fetch_flag = 0
	self.time_limit_big_gift_info = {
		is_already_buy_flag = 0,
		join_vip_level = 0,
		open_flag = 0,
		begin_timestamp = 0,
	}
end

function TimeLimitBigGiftData:__delete()
	TimeLimitBigGiftData.Instance = nil
end

function TimeLimitBigGiftData:GetLimitGiftCfg()
	local table_data = {}
	local seq_data = 0
	---等候配表工作完成后，读取相应的随机活动表
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().timelimit_luxury_gift_bag
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local data = cfg
	local range = GetDataRange(cfg,"opengame_day")
	local rank = GetRangeRank(range,open_day)

	for i,v in ipairs(data) do
		if self.time_limit_big_gift_info.join_vip_level <= v.limit_vip_level and v.opengame_day == rank then
			return v
		end
	end

	return data[1]
end

function TimeLimitBigGiftData:GetLimitGiftCfgSeq()
	if self:GetLimitGiftCfg() then
		return self:GetLimitGiftCfg().seq or 0
	end

	return 0
end

function TimeLimitBigGiftData:GetHasFetchFlag()
	return self.reward_fetch_flag
end

function TimeLimitBigGiftData:SetRestTime(time)
	self.rest_time = time
end

function TimeLimitBigGiftData:GetRestTime()
	return self.rest_time or 0
end

function TimeLimitBigGiftData:SetTimeLimitGiftInfo(protocol)
	self.time_limit_big_gift_info.is_already_buy = protocol.is_already_buy or 0
	self.time_limit_big_gift_info.join_vip_level = protocol.join_vip_level or 0
	self.time_limit_big_gift_info.begin_timestamp = protocol.begin_timestamp or 0
	self.time_limit_big_gift_info.open_flag = protocol.time_limit_luxury_gift_open_flag or 0
end

function TimeLimitBigGiftData:GetTimeLimitGiftInfo()
	return self.time_limit_big_gift_info
end

function TimeLimitBigGiftData:GetOpenLevel()

end