ActivityPanelLoginRewardData = ActivityPanelLoginRewardData or BaseClass(BaseEvent)

ActivityPanelLoginRewardData.RewardStatus = {
	CanGet = 0, 						--表示可领取
	CanGetAfter = 1, 					--表示之后登录才能领
	AlreadyGet = 2, 					--表示已领取
	Overdue = 3, 						--表示未领取已过期
}

function ActivityPanelLoginRewardData:__init()
	if nil ~= ActivityPanelLoginRewardData.Instance then
		return
	end
	ActivityPanelLoginRewardData.Instance = self
	self.login_reward_info_list = {
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT_0] = nil,
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT_1] = nil,
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT_2] = nil,
	}
	self.login_reward_cfg_list = {
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT_0] = ServerActivityData.Instance:GetCurrentRandActivityConfig().login_gift_0,
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT_1] = ServerActivityData.Instance:GetCurrentRandActivityConfig().login_gift_1,
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT_2] = ServerActivityData.Instance:GetCurrentRandActivityConfig().login_gift_2,
	}
	self.login_reward_cfg_list_count = {
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT_0] = GetListNum(self.login_reward_cfg_list[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT_0]),
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT_1] = GetListNum(self.login_reward_cfg_list[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT_1]),
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT_2] = GetListNum(self.login_reward_cfg_list[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT_2]),
	}
	RemindManager.Instance:Register(RemindName.RewardGift0, BindTool.Bind(self.GetLoginGiftRemind0, self))
	RemindManager.Instance:Register(RemindName.RewardGift1, BindTool.Bind(self.GetLoginGiftRemind1, self))
	RemindManager.Instance:Register(RemindName.RewardGift2, BindTool.Bind(self.GetLoginGiftRemind2, self))
end

function ActivityPanelLoginRewardData:__delete()
	RemindManager.Instance:UnRegister(RemindName.RewardGift0)
	RemindManager.Instance:UnRegister(RemindName.RewardGift1)
	RemindManager.Instance:UnRegister(RemindName.RewardGift2)
	ActivityPanelLoginRewardData.Instance = nil
end

function ActivityPanelLoginRewardData:SetLoginRewardInfo_0(protocol)
	local common_bit_list = bit:d2b(protocol.fetch_common_reward_flag)
	local vip_bit_list = bit:d2b(protocol.fetch_vip_reward_flag)
	self.login_reward_info_list[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT_0] = {
		login_days = protocol.login_days,											-- 连续登陆天数
		has_login = protocol.has_login, 											-- 最后登录的dayid
		has_fetch_accumulate_reward = protocol.has_fetch_accumulate_reward, 		-- 是否领取累计充值
		fetch_common_reward_flag = common_bit_list,									-- 普通奖励领取标识
		fetch_vip_reward_flag = vip_bit_list,										-- vip奖励领取标识
	}
end

function ActivityPanelLoginRewardData:SetLoginRewardInfo_1(protocol)
	local common_bit_list = bit:d2b(protocol.fetch_common_reward_flag)
	local vip_bit_list = bit:d2b(protocol.fetch_vip_reward_flag)
	self.login_reward_info_list[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT_1] = {
		login_days = protocol.login_days,											-- 连续登陆天数
		has_login = protocol.has_login, 											-- 最后登录的dayid
		has_fetch_accumulate_reward = protocol.has_fetch_accumulate_reward, 		-- 是否领取累计充值
		fetch_common_reward_flag = common_bit_list,									-- 普通奖励领取标识
		fetch_vip_reward_flag = vip_bit_list,										-- vip奖励领取标识
	}
end

function ActivityPanelLoginRewardData:SetLoginRewardInfo_2(protocol)
	local common_bit_list = bit:d2b(protocol.fetch_common_reward_flag)
	local vip_bit_list = bit:d2b(protocol.fetch_vip_reward_flag)
	self.login_reward_info_list[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT_2] = {
		login_days = protocol.login_days,											-- 连续登陆天数
		has_login = protocol.has_login, 											-- 最后登录的dayid
		has_fetch_accumulate_reward = protocol.has_fetch_accumulate_reward, 		-- 是否领取累计充值
		fetch_common_reward_flag = common_bit_list,									-- 普通奖励领取标识
		fetch_vip_reward_flag = vip_bit_list,										-- vip奖励领取标识
	}
end

function ActivityPanelLoginRewardData:GetLoginRewardInfo(act_id)
	return self.login_reward_info_list[act_id]
end

function ActivityPanelLoginRewardData:GetLoginRewardCfg(act_id)
	return self.login_reward_cfg_list[act_id]
end

function ActivityPanelLoginRewardData:GetCurLoginDays(act_id)
	local info = self:GetLoginRewardInfo(act_id)
	if info then
		return info.login_days
	end
	return 1
end

function ActivityPanelLoginRewardData:GetRewardCfg(act_id, index)
	local cfg = self:GetSortRewardList(act_id)
	if not cfg then
		return nil
	end
	return cfg[index]
end

-- 当前格子能否领取
function ActivityPanelLoginRewardData:CanGetReward(act_id, index)
	local reward_cfg = self:GetRewardCfg(act_id, index)
	local reward_status = self:GetRewardStatus(act_id, reward_cfg.need_login_days)
	if reward_status == ActivityPanelLoginRewardData.RewardStatus.CanGet then
		return true
	end
	return false
end

-- 当前格子是否已过期
function ActivityPanelLoginRewardData:IsOverdue(act_id, index)
	local reward_cfg = self:GetRewardCfg(act_id, index)
	local reward_status = self:GetRewardStatus(act_id, reward_cfg.need_login_days)
	if reward_status == ActivityPanelLoginRewardData.RewardStatus.Overdue then
		return true
	end
	return false
end

-- 当前格子是否已领取
function ActivityPanelLoginRewardData:IsGet(act_id, index)
	local reward_cfg = self:GetRewardCfg(act_id, index)
	local reward_status = self:GetRewardStatus(act_id, reward_cfg.need_login_days)
	if reward_status == ActivityPanelLoginRewardData.RewardStatus.AlreadyGet then
		return true
	end
	return false
end

-- 格子数目
function ActivityPanelLoginRewardData:GetRewardNum(act_id)
	return self.login_reward_cfg_list_count[act_id]
end

-- 获取排序后的奖励配置
function ActivityPanelLoginRewardData:GetSortRewardList(act_id)
	local result_list = {}
	local cfg = self:GetLoginRewardCfg(act_id)
	for k,v in pairs(cfg) do
		table.insert(result_list,TableCopy(v))
		result_list[#result_list].sort_key = self:GetRewardStatus(act_id, v.need_login_days)
	end
	self.login_reward_cfg_list_count[act_id] = #result_list
	table.sort(result_list, SortTools.KeyLowerSorters("sort_key","need_login_days"))
	return result_list
end

-- 对应天数领取状态，true表示玩家未领取
function ActivityPanelLoginRewardData:GetGetStatus(act_id ,login_days)
	local info = self:GetLoginRewardInfo(act_id)
	if not info then
		return false
	end
	return info.fetch_common_reward_flag[33 - login_days] == 0
end

-- 对应天数的按钮状态，0表示可领取，1表示明天之后才能领，2表示已领取，3表示未领取已过期
function ActivityPanelLoginRewardData:GetRewardStatus(act_id, login_days)
	if login_days == self:GetCurLoginDays(act_id) then --当天
		if self:GetGetStatus(act_id, login_days) then
			return ActivityPanelLoginRewardData.RewardStatus.CanGet
		else
			return ActivityPanelLoginRewardData.RewardStatus.AlreadyGet
		end
	end
	if login_days < self:GetCurLoginDays(act_id) then  --过期
		if self:GetGetStatus(act_id,login_days) then
			return ActivityPanelLoginRewardData.RewardStatus.Overdue
		else
			return ActivityPanelLoginRewardData.RewardStatus.AlreadyGet
		end
	end
	return ActivityPanelLoginRewardData.RewardStatus.CanGetAfter
end

function ActivityPanelLoginRewardData:GetLoginGiftRemind0()
	return self:GetRemind(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT_0)
end

function ActivityPanelLoginRewardData:GetLoginGiftRemind1()
	return self:GetRemind(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT_1)
end

function ActivityPanelLoginRewardData:GetLoginGiftRemind2()
	return self:GetRemind(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT_2)
end

function ActivityPanelLoginRewardData:GetRemind(act_id)
	local cur_days = self:GetCurLoginDays(act_id)
	if self:GetRewardStatus(act_id, cur_days) == ActivityPanelLoginRewardData.RewardStatus.CanGet then
		return 1
	end
	return 0
end