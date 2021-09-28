IncreaseSuperiorData = IncreaseSuperiorData or BaseClass()

function IncreaseSuperiorData:__init()
	if IncreaseSuperiorData.Instance then
		print_error("[IncreaseSuperiorData] Attemp to create a singleton twice !")
	end
	IncreaseSuperiorData.Instance = self

end

function IncreaseSuperiorData:__delete()
	IncreaseSuperiorData.Instance = nil
end

function IncreaseSuperiorData:SetIncreastsuperiorInfo(protocl)
	-- body
end

--获取奖励列表
function IncreaseSuperiorData:GetRewardListDataByDay()
	local table_data = {}
	if nil == self.increase_superior_cfg then
		local increase_superior_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().single_charge_4
		self.increase_superior_cfg = ActivityData.Instance:GetRandActivityConfig(increase_superior_cfg, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_3)
	end
	for k,v in pairs(self.increase_superior_cfg) do
		table_data[k] = v.reward_item
	end
	return table_data
end

--获取需要充值的数量
function IncreaseSuperiorData:GetCostListByDay()
	local table_data = {}
	if nil == self.increase_superior_cfg then
		local increase_superior_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().single_charge_4
		self.increase_superior_cfg = ActivityData.Instance:GetRandActivityConfig(increase_superior_cfg, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_3)
	end

	for k,v in pairs(self.increase_superior_cfg) do
		table.insert(table_data, v.charge_value)
	end
	return table_data
end

function IncreaseSuperiorData:SetRestTime(time)
	self.rest_time = time
end

function IncreaseSuperiorData:GetRestTime()
	local act_info = ActivityData.Instance:GetActivityStatuByType(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_3)
	local next_time = act_info and act_info.next_time or 0
	return math.max(next_time - TimeCtrl.Instance:GetServerTime() , 0)
end
