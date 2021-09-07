IncreaseCapabilityData = IncreaseCapabilityData or BaseClass()

function IncreaseCapabilityData:__init()
	if IncreaseCapabilityData.Instance then
		print_error("[IncreaseCapabilityData] Attemp to create a singleton twice !")
	end
	IncreaseCapabilityData.Instance = self
	--RemindManager.Instance:Register(RemindName.ZhenBaoge, BindTool.Bind(self.GetZhenBaogeRemind, self))

	-- self.increase_capability_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().single_charge_3
	self.rest_time = 0
end

function IncreaseCapabilityData:__delete()
	--RemindManager.Instance:UnRegister(RemindName.ZhenBaoge)
	IncreaseCapabilityData.Instance = nil
end

function IncreaseCapabilityData:SetIncreastCapabilityInfo(protocl)
	-- body
end

--获取奖励列表
function IncreaseCapabilityData:GetRewardListDataByDay()
	if self.increase_capability_cfg == nil then
		self.increase_capability_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().single_charge_3
	end
	local table_data = {} 
	local data = ActivityData.Instance:GetRandActivityConfig(self.increase_capability_cfg, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_2)
	for k,v in pairs(data) do
		table.insert(table_data, v.reward_item)
	end
	return table_data
end

--获取需要充值的数量
function IncreaseCapabilityData:GetCostListByDay()
	if self.increase_capability_cfg == nil then
		self.increase_capability_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().single_charge_3
	end
	local table_data = {} 
	local data = ActivityData.Instance:GetRandActivityConfig(self.increase_capability_cfg, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_2)
	for k,v in pairs(data) do
		table.insert(table_data, v.charge_value)
	end
	return table_data
end

function IncreaseCapabilityData:SetRestTime(time)
	self.rest_time = time
end

function IncreaseCapabilityData:GetRestTime()
	return self.rest_time
end
