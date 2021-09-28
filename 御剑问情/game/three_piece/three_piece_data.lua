ThreePieceData = ThreePieceData or BaseClass()

function ThreePieceData:__init()
	if ThreePieceData.Instance then
		ErrorLog("[ThreePieceData] attempt to create singleton twice!")
		return
	end
	ThreePieceData.Instance =self
	self.rechange_info = {
		cur_total_charge = 0,
		cur_total_charge_has_fetch_flag = 0,
	}
end

function ThreePieceData:__delete()
	ThreePieceData.Instance = nil
end

function ThreePieceData:SetChargeInfo(info)
	self.rechange_info.cur_total_charge = info.cur_total_charge
	self.rechange_info.cur_total_charge_has_fetch_flag = info.cur_total_charge_has_fetch_flag
end

function ThreePieceData:GetRechargeInfo()
	return self.rechange_info
end

function ThreePieceData:GetRechargeCfg()
	local rand_act_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local open_days = ActivityData.GetActivityDays(ACTIVITY_TYPE.RAND_ACTIVITY_NEW_THREE_SUIT)
	local recharge_cfg = {}
	if open_days > 0 then
		open_day = open_day - open_days + 1
		for i,v in ipairs(rand_act_cfg.total_charge4) do
			if (recharge_cfg[1] and recharge_cfg[1].opengame_day == v.opengame_day and recharge_cfg[1] and recharge_cfg[1].start_day == v.start_day)
			 or (recharge_cfg[1] == nil and v.opengame_day >= open_day and v.start_day + 1 >= open_days) then
				table.insert(recharge_cfg, v)
			end
		end
	end
	return recharge_cfg
end
