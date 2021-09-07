MoonGiftData = MoonGiftData or BaseClass()

RA_MYYL_MAX_REWARD_COUNT = 16

function MoonGiftData:__init()
	if MoonGiftData.Instance then
		ErrorLog("[MoonGiftData] attempt to create singleton twice!")
		return
	end
	MoonGiftData.Instance =self

	self.ra_myyl_today_chongzhi_num = 0
	self.ra_myyl_reward_fetch_flag = {}
	self.ra_myyl_meet_condition_days = {}
	self.reward_flag = {}
	RemindManager.Instance:Register(RemindName.MidAutumnMoonGift, BindTool.Bind(self.GetRemind, self))
end

function MoonGiftData:__delete()
	RemindManager.Instance:UnRegister(RemindName.MidAutumnMoonGift)
	MoonGiftData.Instance = nil
end

function MoonGiftData:SetRewardInfo(protocol)
	self.ra_myyl_today_chongzhi_num = protocol.ra_myyl_today_chongzhi_num
	self.ra_myyl_reward_fetch_flag = protocol.ra_myyl_reward_fetch_flag
	self.ra_myyl_meet_condition_days = protocol.ra_myyl_meet_condition_days
	self.reward_flag = protocol.reward_flag
end

function MoonGiftData:GetChongZhiInfo()
	return self.ra_myyl_today_chongzhi_num
end

function MoonGiftData:GetConditionDays()
	return self.ra_myyl_meet_condition_days
end

function MoonGiftData:GetRewardFlag(seq)
	if nil ~= seq then
		return self.reward_flag[64 - seq]
	end
end

function MoonGiftData:GeReceiveFlag(seq)
	if nil ~= seq then
		return self.ra_myyl_reward_fetch_flag[32 - seq]
	end	
end

function MoonGiftData:SetLeftTagRetPoint(index)
	local act_day = ActivityData.GetActivityDays(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MIDAUTUMNMYYL)
	if nil ~= act_day then
		local rolo_chongzhi = self:GetChongZhiInfo()
		local chongzhi_cfg, chongzhi_num = self:GetRewardInfo(act_day)
		local need_chongzhi = chongzhi_cfg[index].need_chongzhi
		if need_chongzhi and need_chongzhi <= rolo_chongzhi then
			local seq = chongzhi_cfg[index].reward_seq
			local receive_flag = self:GeReceiveFlag(seq)
			if receive_flag == 0 then
				return true
			end
		end
	end
	return false
end

-- 单充
function MoonGiftData:ShowDanChongRedPoint()
	local flag = false
	local act_day = ActivityData.GetActivityDays(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MIDAUTUMNMYYL)
	if nil ~= act_day then
		local chongzhi_cfg, chongzhi_num = self:GetRewardInfo(act_day)
		if chongzhi_num then
			for i = 1, chongzhi_num do
				flag = self:SetLeftTagRetPoint(i)
				if flag then
					break
				end
			end
		end
	end
	return flag
end

function MoonGiftData:SetDownTagRedPoint(index)
	local flag = false
	local ra_myyl_meet_condition_days = self:GetConditionDays()
	local myyl_continue_chongzhi = self:GetMyylContinueCfg()
	if nil == myyl_continue_chongzhi or nil == next(myyl_continue_chongzhi) then
		return flag
	end
	local reward_seq = myyl_continue_chongzhi[index][1].reward_seq
	local chongzhi_day = ra_myyl_meet_condition_days[reward_seq]
	if reward_seq and chongzhi_day then
		for i = 1, 2 do
			if chongzhi_day >= myyl_continue_chongzhi[index][i].meet_condition_days then
				local seq = myyl_continue_chongzhi[index][i].seq
				local receive_flag = self:GetRewardFlag(seq)
				if receive_flag == 0 then
					flag = true
				end
			end
		end
	end
	return flag
end

-- 连冲
function MoonGiftData:ShowLianChongRedPoint()
	local flag = false
	for i = 1, 2 do
		flag = self:SetDownTagRedPoint(i)
		if flag then
			break
		end
	end
	return flag
end

function MoonGiftData:GetRemind()
	local flag  = 0
	flag = (self:ShowDanChongRedPoint() or self:ShowLianChongRedPoint()) and 1 or 0
	return flag
end

function MoonGiftData:GetMyylCfg()
	local randactivity_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().myyl
	if not self.chongzhi_cfg then
		self.chongzhi_cfg = ListToMapList(randactivity_cfg,"act_days")
	end
	return self.chongzhi_cfg
end

function MoonGiftData:GetMyylContinueCfg()
	local randactivity_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().myyl_continue_chongzhi
	if not self.myyl_continue_chongzhi then
		self.myyl_continue_chongzhi = ListToMapList(randactivity_cfg,"reward_seq")
	end
	return self.myyl_continue_chongzhi
end

function MoonGiftData:GetRewardInfo(act_day)
	if nil == act_day then
		return  nil, nil
	end
	local chongzhi_cfg = self:GetMyylCfg()[act_day]
	if chongzhi_cfg and nil ~= next(chongzhi_cfg) then
		return chongzhi_cfg, #chongzhi_cfg
	end
end

function MoonGiftData:GetRewardContinueInfo(reward_seq)
	if nil == reward_seq then
		return
	end
	local continue_chongzhi = self:GetMyylContinueCfg()[reward_seq]
	if continue_chongzhi then
		return continue_chongzhi
	end
end