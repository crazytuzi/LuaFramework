JinYinTaData = JinYinTaData or BaseClass()

function JinYinTaData:__init()
	if JinYinTaData.Instance ~= nil then
		ErrorLog("[JinYinTaData] Attemp to create a singleton twice !")
	end
	JinYinTaData.Instance = self

 	RemindManager.Instance:Register(RemindName.JINYINTA, BindTool.Bind(self.GetJinYinTaRemind, self))
 	self.can_show_treasure = false
end

function JinYinTaData:__delete()
	self:RemoveDelayTime()
	RemindManager.Instance:UnRegister(RemindName.JINYINTA)
	self.lotteryInfo = nil
	JinYinTaData.Instance = nil
end

--随机活动金银塔抽奖活动
function JinYinTaData:SetLevelLotteryInfo(protocol)
	self.lottery_cur_level = protocol.lottery_cur_level
	self.history_count = protocol.history_count
	self.history_list = protocol.history_list
end

--金银塔活动：获取玩家当前所在层
function JinYinTaData:GetLotteryCurLevel()
	return self.lottery_cur_level or 1
end

--获取金银塔历史奖励列表
function JinYinTaData:GetHistoryRewardList()
	if nil == self.history_list then return {} end
	return self.history_list
end

--随机活动金银塔抽奖活动
function JinYinTaData:SetLevelLotteryRewardList(protocol)
	local level_lottery_reward = self:GetRewardCfgByDay()
	self.lottery_reward_list = protocol.lottery_reward_list
	self.act_jinyinta_reward_list = {}
	for k,v in pairs(self.lottery_reward_list) do
		local item_index = self.lottery_reward_list[k] + 1
		local reward_item = level_lottery_reward[item_index].reward_item
		self.act_jinyinta_reward_list[k] = reward_item
	end
	self.can_show_treasure = true
end

function JinYinTaData:GetCanShowTreasure()
	return self.can_show_treasure
end

function JinYinTaData:ResetCanShowTreasure()
	self.can_show_treasure = false
end

-- 获取金银塔历史奖励信息
function JinYinTaData:GetHistoryRewardInfo(reward_index)
	reward_index = reward_index + 1
	local level_lottery_reward = self:GetRewardCfgByDay()
	if level_lottery_reward[reward_index] then
		local reward_item = level_lottery_reward[reward_index].reward_item
		return reward_item or {}
	end
	return {}
end


--获取金银塔奖励列表
function JinYinTaData:GetLevelLotteryRewardList()
	return self.act_jinyinta_reward_list or {}
end

--获取金银塔奖励列表Index
function JinYinTaData:GetLotteryRewardList()
	return self.lottery_reward_list or {}
end

--获取金银塔物品数据表
function JinYinTaData:GetLevelLotteryItemList()
	local rand_config =self:GetRewardCfgByDay()
	local reward_item_list = {}
	for i = 1, 21 do
		reward_item_list[i] = rand_config[i]
	end
	return reward_item_list
end

-- 获取活动奖励
function JinYinTaData:GetRewardCfgByDay()
	local rand_config = ServerActivityData.Instance:GetCurrentRandActivityConfig().level_lottery_reward
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local open_days = ActivityData.GetActivityDays(ACTIVITY_TYPE.RAND_JINYINTA)
	local temp_tab = {}
	local temp_index = 1
	
	if open_days > 0 then 
		open_day = open_day - open_days + 1		
		for k, v in pairs(rand_config) do
 			if open_day <= v.opengame_day then
 				temp_tab[temp_index] = v
 				temp_index = temp_index + 1
 		 	end
	 	end
	end
	return temp_tab
end

function JinYinTaData:GetFaLaoQuanZhangItemId()
	local act_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	return act_cfg.other[1].level_lottery_50_item_id or 0
end

-- 领取奖励次数与免费时间
function JinYinTaData:SetLotteryActivityInfo(protocol)
	self.lotteryInfo = protocol
end

function JinYinTaData:GetLotteryActivityInfo()
	 return self.lotteryInfo or {}
end

-- 获取抽一次所需的钻石
function JinYinTaData:GetChouNeedGold()
	local curr_level = self:GetLotteryCurLevel()
	local lottery_consume = ServerActivityData.Instance:GetCurrentRandActivityConfig().level_lottery_consume
	for k,v in pairs(lottery_consume) do
		if curr_level == v.level then
			return v.lottery_consume_gold
		end
	end
	return 30
end


-- 获取金银塔免费时间
function JinYinTaData:GetLeveLotteryMianFei()
	-- 金银塔免费次数与冷却时间
 	local lotteryInfo = self:GetLotteryActivityInfo()
 	if lotteryInfo then
		-- 下次免费时间
		local next_time = lotteryInfo.ra_lottery_next_free_timestamp or 0
		local time = math.max(next_time - TimeCtrl.Instance:GetServerTime() , 0)
 		return time
	end
	return 0
end

-- 获取累计次数累计奖励
function JinYinTaData:GetLeijiJiangli()
	local list = {}
	local rand_config = ServerActivityData.Instance:GetCurrentRandActivityConfig().level_lottery_total_reward
	local cfg = ActivityData.Instance:GetRandActivityConfig(rand_config, ACTIVITY_TYPE.RAND_JINYINTA)
	for i=#cfg, 1, -1 do
		flag = self:IsGetReward(cfg[i].reward_index)
		if flag then
			table.insert(list, cfg[i])
		else
			table.insert(list, 1, cfg[i])
		end
	end
	
	return list
end

--返回活动结束时间 
function JinYinTaData:GetActEndTime()
	local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_JINYINTA)
	if act_info then
		local next_time = act_info.next_time
		local time = math.max(next_time - TimeCtrl.Instance:GetServerTime() , 0)
 		return time
	end
	return 0
end

-- 获取累计抽奖次数
function JinYinTaData:GetLeiJiRewardNum()
	 local lotteryInfo = self:GetLotteryActivityInfo()
	 if lotteryInfo then
	 	return lotteryInfo.ra_lottery_buy_total_times or 0
	 end
	 return 0
end

-- 判断当前奖励是否可以领取，vip等级reward_vip，抽奖次数reward_count
function JinYinTaData:CanGetRewardByVipAndCount(reward_vip,reward_count)
	-- 获取当前玩家的vip等级
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	local curr_count = self:GetLeiJiRewardNum()
	if (vip_level >= reward_vip) and (curr_count >= reward_count) then
		-- 满足领取条件
		return true
	end
	return false
end

-- 获取最后领取的累计奖励物品
function JinYinTaData:GetLeiJiRewardList()	 
	-- 最后领取奖励的次数
	local reward_times = self:GetRewardLevel()
	local reward_cfg = self:GetLeijiJiangli()
	for k,v in pairs(reward_cfg) do
		if reward_times == v.total_times then
			return v.reward
		end
	end
	return {}
end

-- 判断玩家是否领取了某项累计奖励
function JinYinTaData:IsGetReward(reward_times)
	local reward_info = self:GetLotteryActivityInfo()
	if reward_info.ra_lottery_fetch_reward_flag then
		local bit_list = bit:d2b(reward_info.ra_lottery_fetch_reward_flag)
		if bit_list[32 - reward_times] == 1 then
			return true
		end
	end
	return false
end

-- 判断是否有累计奖励可以领取
function JinYinTaData:GetCanHuoReward()
	-- 可领取的奖励次数
	local get_count = 0
	local item_info = self:GetLeijiJiangli()
	for k,v in pairs(item_info) do
		local is_get = self:IsGetReward(v.reward_index)
		if not is_get then
			-- 玩家可不可以领取奖励
			local can_lin = self:CanGetRewardByVipAndCount(v.vip_level_limit,v.total_times)
			if can_lin then
				get_count = get_count + 1
			end
		end
	end
	return get_count
end

function JinYinTaData:SetShowReasureBool(bool)
	self.show_reasure = bool
end

function JinYinTaData:GetShowReasureBool(bool)
	return self.show_reasure or false
end

-- 获取玩家最后抽的奖励
function JinYinTaData:SetLenRewardLevel(total_count)
	self.total_count = total_count
end

function JinYinTaData:GetRewardLevel()
	return self.total_count or 0
end


-- 不许连续抽
function JinYinTaData:SetPlayNotClick(bool)
	self.wait_played = bool
end

function JinYinTaData:GetPlayNotClick()
	return self.wait_played
end

function JinYinTaData:SetTenNotClick(bool)
	self.ten_play = bool
end

function JinYinTaData:GetTenyNotClick()
	return self.ten_play
end

function JinYinTaData:SetOldLevel(old_level)
	self.old_level = old_level
end

function JinYinTaData:GetOldLevel()
	return self.old_level or 1
end

function JinYinTaData:GetJinYinTaRemind()
	local get_count = self:GetCanHuoReward()
 	local mianfei = self:GetLeveLotteryMianFei()
 	if mianfei <= 0 then
		return 1
 	end
 	if get_count > 0 then 
 		return 1
 	end
 	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_JINYINTA) and nil == self.remind_timer then
 		self.remind_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.UpdateRemind,self),mianfei)
 	end
 	return 0
end

function JinYinTaData:RemoveDelayTime()
	if self.remind_timer then
		GlobalTimerQuest:CancelQuest(self.remind_timer)
		self.remind_timer = nil
	end
end

function JinYinTaData:UpdateRemind()
	RemindManager.Instance:Fire(RemindName.JINYINTA)
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_JINYINTA,true)
end

function JinYinTaData:FlushHallRedPoindRemind()
	local remind_num = self:GetJinYinTaRemind()
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_JINYINTA,remind_num > 0)
end