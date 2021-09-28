RepeatRechargeData = RepeatRechargeData or BaseClass()

function RepeatRechargeData:__init()
	if RepeatRechargeData.Instance ~= nil then
		print("[RepeatRechargeData] attempt to create singleton twice!")
		return		
	end
	RepeatRechargeData.Instance = self
	self.circulation_chongzhi_info = {}
	self.circulation_chongzhi_info.total_chongzhi = 0
	self.circulation_chongzhi_info.cur_chongzhi = 0
	RemindManager.Instance:Register(RemindName.RepeatRecharge, BindTool.Bind(self.CheckChongzhi, self))
end

function RepeatRechargeData:__delete()
	RepeatRechargeData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.RepeatRecharge)
end

function RepeatRechargeData:UpdateInfoData(protocol)
	self.circulation_chongzhi_info.total_chongzhi = protocol.total_chongzhi
	self.circulation_chongzhi_info.cur_chongzhi = protocol.cur_chongzhi
end

function RepeatRechargeData:GetCirculationChongzhiRewardShowData()
	local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
    if randact_cfg.circulation_chongzhi == nil then return end
    local config = ActivityData.Instance:GetRandActivityConfig(randact_cfg.circulation_chongzhi, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_REPEAT_RECHARGE)
    return  config[0] or config[1] 
end

function RepeatRechargeData:GetCirculationChongzhiInfo()
	return self.circulation_chongzhi_info or {}
end

function RepeatRechargeData:CheckChongzhi()
		local day_cfg = self:GetCirculationChongzhiRewardShowData()
		local chongzhi_info = RepeatRechargeData.Instance:GetCirculationChongzhiInfo()

		return chongzhi_info.cur_chongzhi >= day_cfg.need_chongzhi_gold and 1 or 0
end