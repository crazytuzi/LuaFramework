RechargeRankData = RechargeRankData or BaseClass()

function RechargeRankData:__init()
	if RechargeRankData.Instance then
		ErrorLog("[RechargeRankData] attempt to create singleton twice!")
		return
	end
	RechargeRankData.Instance =self
	self.rand_act_rechange = 0
end

function RechargeRankData:__delete()
	RechargeRankData.Instance = nil
end

function RechargeRankData:SetRandActRecharge(num)
	self.rand_act_rechange = num
end

function RechargeRankData:GetRandActRecharge()
	return self.rand_act_rechange
end

function RechargeRankData:GetRechargeRankCfg()
	local rand_act_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	return ActivityData.Instance:GetRandActivityConfig(rand_act_cfg.chongzhi_rank, ACTIVITY_TYPE.RAND_CHONGZHI_RANK)
end
