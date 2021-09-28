SingleRebateData = SingleRebateData or BaseClass()

function SingleRebateData:__init()
	if SingleRebateData.Instance then
		ErrorLog("[SingleRebateData] Attemp to create a singleton twice !")
	end
	SingleRebateData.Instance = self
	self.single_rebate_is_open = false
end

function SingleRebateData:__delete()
	SingleRebateData.Instance = nil
end

function SingleRebateData:GetCfg()
	local rand_act_other_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfigOtherCfg()
	return rand_act_other_cfg
end

function SingleRebateData:GetRewardPrecent()
	local cfg = self:GetCfg()
	if cfg then
		return cfg.single_rebate_reward_precent
	end
	return 0
end

function SingleRebateData:GetLimitLevel()
	local show_cfg = ActivityData.Instance:GetActivityConfig(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_REBATE)
	if show_cfg then
		return show_cfg.min_level
	end
	return 0
end

function SingleRebateData:IsFunOpen()
	local limit_level = self:GetLimitLevel()
	if limit_level <= GameVoManager.Instance:GetMainRoleVo().level then
		return true
	else
		return false
	end
end