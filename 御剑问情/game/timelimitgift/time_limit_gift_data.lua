TimeLimitGiftData = TimeLimitGiftData or BaseClass()

function TimeLimitGiftData:__init()
	if TimeLimitGiftData.Instance then
		print_error("[TimeLimitGiftData] Attemp to create a singleton twice !")
	end
	TimeLimitGiftData.Instance = self
	self.reward_fetch_flag = 0
	self.time_limit_gift_info = {
		reward_can_fetch_flag = 0,
		reward_fetch_flag = 0,
		join_vip_level = 0,
		open_flag = 0,
		begin_timestamp = 0,
	}
end

function TimeLimitGiftData:__delete()
	TimeLimitGiftData.Instance = nil
end

function TimeLimitGiftData:GetLimitGiftCfg()
	local table_data = {}
	local seq_data = 0
	---等候配表工作完成后，读取相应的随机活动表
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().timelimit_gift
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local data = cfg
	local range = GetDataRange(cfg,"opengame_day")
	local rank = GetRangeRank(range,open_day)
	for i,v in ipairs(data) do
		if self.time_limit_gift_info.join_vip_level <= v.limit_vip_level and v.opengame_day == rank then
			return v
		end
	end
	return data[1]
end

function TimeLimitGiftData:GetHasFetchFlag()
	return self.reward_fetch_flag
end

function TimeLimitGiftData:SetRestTime(time)
	self.rest_time = time
end

function TimeLimitGiftData:GetRestTime()
	return self.rest_time or 0
end

function TimeLimitGiftData:SetTimeLimitGiftInfo(protocol)
	self.time_limit_gift_info.reward_can_fetch_flag = protocol.reward_can_fetch_flag
	self.time_limit_gift_info.reward_fetch_flag = protocol.reward_fetch_flag
	self.time_limit_gift_info.join_vip_level = protocol.join_vip_level
	self.time_limit_gift_info.open_flag = protocol.open_flag
	self.time_limit_gift_info.begin_timestamp = protocol.begin_timestamp
	local can_reward = protocol.reward_can_fetch_flag > 0 and protocol.reward_fetch_flag == 0
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_GIFT, can_reward)
end

function TimeLimitGiftData:GetTimeLimitGiftInfo()
	return self.time_limit_gift_info
end

function TimeLimitGiftData:GetOpenLevel()

end