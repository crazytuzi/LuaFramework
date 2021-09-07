ExpRefineData = ExpRefineData or BaseClass()

function ExpRefineData:__init()
	if ExpRefineData.Instance ~= nil then
		ErrorLog("[ExpRefineData] Attemp to create a singleton twice !")
	end
	ExpRefineData.Instance = self

	-- 经验炼制信息
	self.exp_refine_info = {
		refine_today_buy_time = 0,				-- 每日炼制次数
		refine_reward_gold = 0,					-- 总奖励金额
	}
	RemindManager.Instance:Register(RemindName.ExpRefine, BindTool.Bind(self.GetExpRefineRemind, self))
end

function ExpRefineData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ExpRefine)
	
	ExpRefineData.Instance = nil
end

function ExpRefineData:SetRAExpRefineInfo(protocol)
	self.exp_refine_info.refine_today_buy_time = protocol.refine_today_buy_time
	self.exp_refine_info.refine_reward_gold = protocol.refine_reward_gold
end

function ExpRefineData:GetRAExpRefineInfo()
	return self.exp_refine_info
end

function ExpRefineData:GetRAExpRefineCfgMaxNum()
	local num = 0
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	if config and config.exp_refine then
		num = #config.exp_refine
	end
	return num
end

function ExpRefineData:GetRAExpRefineCfgBySeq(seq)
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	if config and config.exp_refine then
		for k,v in pairs(config.exp_refine) do
			if v.seq == seq then
				return v
			end
		end
	end
end

-- 获取经验炼制活动是否还在开启中(哪怕已经过了时间，但只要奖励没领取就一直显示)
function ExpRefineData:GetExpRefineIsOpen()
	local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_REFINE) or {}
	if act_info.status == ACTIVITY_STATUS.OPEN or self.exp_refine_info.refine_reward_gold > 0 then
		local act_cfg = ActivityData.Instance:GetActivityConfig(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_REFINE)
		local level = PlayerData.Instance.role_vo.level
		if act_cfg and act_cfg.min_level <= level then
			return true
		end
	end
	return false
end

function ExpRefineData:GetExpRefineRemind()
	return self:GetExpRefineRedPoint() and 1 or 0
end

function ExpRefineData:GetExpRefineRedPoint()
	local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_REFINE) or {}
	if act_info.status ~= ACTIVITY_STATUS.OPEN and self.exp_refine_info.refine_reward_gold > 0 then
		return true
	end
	return false
end