HappyRechargeData = HappyRechargeData or BaseClass()

function HappyRechargeData:__init()
	if HappyRechargeData.Instance then
		print_error("[HappyRechargeData] Attemp to create a singleton twice !")
	end
	HappyRechargeData.Instance = self

	self.cur_can_niu_egg_chongzhi_value = 0
	self.server_total_niu_egg_times = 0
	self.server_reward_has_fetch_reward_flag = 0
	self.history_count = 0
	self.history_list = {}
end

function HappyRechargeData:__delete()
	HappyRechargeData.Instance = nil
end

function HappyRechargeData:GetItemListInfo()
	local table_data = {}
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().charge_niu_egg
	local data = ActivityData.Instance:GetRandActivityConfig(cfg, ACTIVITY_TYPE.RAND_HAPPY_RECHARGE)
	for k,v in pairs(data) do
		if v.show_item == 1 then
			table.insert(table_data, v)
		end
	end
	return table_data
end

function HappyRechargeData:GetCost()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().other
	return cfg[1].niu_egg_need_charge or 0
end

function HappyRechargeData:SetNiuEggInfo(protocol)
	self.cur_can_niu_egg_chongzhi_value = protocol.cur_can_niu_egg_chongzhi_value
	self.server_total_niu_egg_times = protocol.server_total_niu_egg_times
	self.server_reward_has_fetch_reward_flag = protocol.server_reward_has_fetch_reward_flag
	self.history_count = protocol.history_count
	self.history_list = protocol.history_list
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_HAPPY_RECHARGE, self:GetFreeTimes() >0)
end

function HappyRechargeData:GetChongZhiVlaue()
	return self.cur_can_niu_egg_chongzhi_value
end

function HappyRechargeData:GetTotalTimes()
	return self.server_total_niu_egg_times
end

function HappyRechargeData:GetHistoryCount()
	return self.history_count
end

function HappyRechargeData:GetHistoryList()
	return self.history_list
end

function HappyRechargeData:GetFetchFlag()
	return self.server_reward_has_fetch_reward_flag
end

function HappyRechargeData:SetRestTime(time)
	self.rest_time = time
end

function HappyRechargeData:GetRestTime()
	return self.rest_time or 0
end

function HappyRechargeData:SetRewardListInfo(list_info)
	self.reward_list_info = list_info
end

function HappyRechargeData:GetRewardListInfo()
	local table_data = {}
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().charge_niu_egg
	local data = ActivityData.Instance:GetRandActivityConfig(cfg, ACTIVITY_TYPE.RAND_HAPPY_RECHARGE)
	for k,v in pairs(self.reward_list_info) do
		table.insert(table_data, data[v + 1].reward_item)
	end
	return table_data
end

function HappyRechargeData:GetFreeTimes()
    local num = math.floor(self.cur_can_niu_egg_chongzhi_value / self:GetCost())
    return num
end