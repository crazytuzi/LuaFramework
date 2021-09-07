RechargeCapacityData = RechargeCapacityData or BaseClass()

function RechargeCapacityData:__init()
	if RechargeCapacityData.Instance then
		ErrorLog("[RechargeCapacityData] attempt to create singleton twice!")
		return
	end
	RechargeCapacityData.Instance =self
end

function RechargeCapacityData:__delete()
	RechargeCapacityData.Instance = nil
end

function RechargeCapacityData:GetRechargeCapacityCfg()
	local rand_act_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local capacity_cfg = ActivityData.Instance:GetRandActivityConfig(rand_act_cfg.single_charge_5, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RECHARGE_CAPACITY) or {}

	return capacity_cfg
end
