ConsumeRewardData = ConsumeRewardData or BaseClass()

function ConsumeRewardData:__init()
	if ConsumeRewardData.Instance then
		print_error("[ConsumeRewardData] Attemp to create a singleton twice !")
	end
	ConsumeRewardData.Instance = self
	self.reward_fetch_flag = 0
	self.consume_reward_info = {
		consume_gold = 0,
		fetch_reward_flag = 0,
		vip_level = 0,
		reserve_sh = 0,
	}
end

function ConsumeRewardData:__delete()
	ConsumeRewardData.Instance = nil
end

function ConsumeRewardData:GetRewardGiftCfg() --获得礼物配置信息
	local table_data = {}
	local seq_data = 0
	---等候配表工作完成后，读取相应的随机活动表
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().consume_gold_reward
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local data = cfg
	local range = GetDataRange(cfg, "opengame_day")
	local rank = GetRangeRank(range,open_day)
	local activity_day = 0
	if self:GetRewardGiftInfo() then 
        activity_day = self:GetRewardGiftInfo().activity_day 
	end
	
	for i,v in ipairs(data) do
		if self.consume_reward_info.vip_level <= v.limit_vip_level and v.opengame_day == rank and activity_day == v.activity_day then		
	        return v
		end
	end
	return data[1]
end

function ConsumeRewardData:GetHasFetchFlag()
	return self.reward_fetch_flag
end

function ConsumeRewardData:SetRestTime(time)
	self.rest_time = time
end

function ConsumeRewardData:GetRestTime()
	return self.rest_time or 0
end

function ConsumeRewardData:SetConsumeRewardGiftInfo(protocol)
	self.consume_reward_info.consume_gold = protocol.consume_gold
	self.consume_reward_info.fetch_reward_flag = protocol.fetch_reward_flag
	self.consume_reward_info.vip_level = protocol.vip_level
	self.consume_reward_info.activity_day = protocol.activity_day
	local cfg = self:GetRewardGiftCfg()
	local can_reward = false
	if cfg and cfg.consume_gold then
	    can_reward = protocol.fetch_reward_flag == 0 and protocol.consume_gold >= cfg.consume_gold
	end

    ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_GOLD_FANLI, can_reward)
end

function ConsumeRewardData:GetRewardGiftInfo()
	return self.consume_reward_info
end

function ConsumeRewardData:GetOpenLevel()

end