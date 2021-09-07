FastChargingData = FastChargingData or BaseClass()

function FastChargingData:__init()
	if FastChargingData.Instance then
		ErrorLog("[FastChargingData] attempt to create singleton twice!")
		return
	end
	FastChargingData.Instance =self

end

function FastChargingData:__delete()
	FastChargingData.Instance = nil
end

function FastChargingData:GetFastChargingCfg()
	local rand_act_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	return ActivityData.Instance:GetRandActivityConfig(rand_act_cfg.single_charge_2, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_2)
end