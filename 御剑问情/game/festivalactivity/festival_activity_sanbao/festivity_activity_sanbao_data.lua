VersionThreePieceData = VersionThreePieceData or BaseClass()

function VersionThreePieceData:__init()
	if nil ~= VersionThreePieceData.Instance then
		return
	end

	VersionThreePieceData.Instance = self

	self.leichong_has_fetch = {}
end

function VersionThreePieceData:__delete()

end

function VersionThreePieceData:SetSanBaoInfo(protocol)
	self.sanbao_charge_value = protocol.cur_total_charge
	self.sanbao_has_fetch = bit:d2b(protocol.cur_total_charge_has_fetch_flag)
end

function VersionThreePieceData:GetSanBaoCfg()
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().grand_total_charge_five
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_TOTAL_CHARGE_FIVE)
	local act_open_days = ActivityData.GetActivityDays(FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_TOTAL_CHARGE_FIVE)
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local recharge_cfg = {}

	if act_open_days > 0 then
		open_day = open_day - act_open_days + 1
		for i,v in ipairs(config) do
			if (recharge_cfg[1] and recharge_cfg[1].opengame_day == v.opengame_day and recharge_cfg[1] and recharge_cfg[1].start_day == v.start_day)
			 or (recharge_cfg[1] == nil and v.opengame_day >= open_day and v.start_day + 1 >= act_open_days) then
				table.insert(recharge_cfg, v)
			end
		end
	end

	return recharge_cfg
end

function VersionThreePieceData:GetSanBaoChargeValue()
	return self.sanbao_charge_value or 0
end

function VersionThreePieceData:GetSanBaoFetchFlag(index)
	return self.sanbao_has_fetch[32 - index]
end