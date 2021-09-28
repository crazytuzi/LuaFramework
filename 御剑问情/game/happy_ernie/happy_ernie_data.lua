HappyErnieData = HappyErnieData or BaseClass()
--初始化
function HappyErnieData:__init()
	if HappyErnieData.Instance ~= nil then
		ErrorLog("[HappyErnieData] attempt to create singleton twice!")
		return
	end
	HappyErnieData.Instance = self
	self.count = -1
	self.chest_shop_mode = -1
	self.chou_times = 0

	RemindManager.Instance:Register(RemindName.HappyErnieRemind, BindTool.Bind(self.GetHappyErnieRemind, self))
end

--释放
function HappyErnieData:__delete()
	HappyErnieData.Instance = nil
	self.count = nil 
	self.chest_shop_mode = nil
	RemindManager.Instance:UnRegister(RemindName.HappyErnieRemind)

end

-- 其他配置
function HappyErnieData:GetOtherCfgByOpenDay()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfigOtherCfg()
	return cfg
end

--根据开服时间获取欢乐摇奖配置  
function HappyErnieData:GetOpenTakeTimeCfg()
	local happy_ernie_cfg = {}
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	if nil == cfg then
		return happy_ernie_cfg
	end
	
	happy_ernie_cfg = ActivityData.Instance:GetRandActivityConfig(cfg.huanleyaojiang, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPY_ERNIE) or {}
	return happy_ernie_cfg
end

--获取欢乐摇奖的累计奖励配置表
function HappyErnieData:GetHappyErnieRewardConfig()
	local reward_cfg = {}
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	if nil == cfg then
		return reward_cfg
	end

	reward_cfg = ActivityData.Instance:GetRandActivityConfig(cfg.huanleyaojiang_reward, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPY_ERNIE) or {}
	return reward_cfg
end

function HappyErnieData:GetHappyErnieCfgByList()
	local cfg = self:GetOpenTakeTimeCfg()
	local list = {}
	if nil == next(cfg) then
		return list
	end

	for k,v in pairs(cfg) do
		if v.is_show == 1 then
			table.insert(list, v)
		end
	end
	return list
end

--获取抽取消耗金额
function HappyErnieData:GetHappyErnieDrawCost()
	local happy_ernie_other_configs = self:GetOtherCfgByOpenDay()
	if nil == happy_ernie_other_configs then
		return nil
	end
	local draw_gold_list = {}
	draw_gold_list.once_gold = happy_ernie_other_configs.huanleyaojiang_once_gold or 0
	draw_gold_list.tenth_gold = happy_ernie_other_configs.huanleyaojiang_tentimes_gold or 0
	draw_gold_list.thirtieth_gold = happy_ernie_other_configs.huanleyaojiang_thirtytimes_gold or 0

	return draw_gold_list
end

function HappyErnieData:GetHappyErnieKeyNum()
	local happy_ernie_other_configs = self:GetOtherCfgByOpenDay()
	if nil == happy_ernie_other_configs then
		return 0
	end

	local key_id = happy_ernie_other_configs.huanleyaojaing_thirtytimes_item_id or 0
	local key_num = ItemData.Instance:GetItemNumInBagById(key_id) or 0
	local key_cfg = ItemData.Instance:GetItemConfig(key_id)
	return key_num, key_cfg
end

--获取欢乐摇奖的累计奖励配置表
function HappyErnieData:GetHappyErnieRewardItemConfig()
	local happy_ernie_activity_reward_cfg = self:GetHappyErnieRewardConfig()
	if nil == happy_ernie_activity_reward_cfg or nil == self.reward_flag then
		return {}
	end
	local has_got_data_list = {}
	local not_got_data_list = {}
	for i,v in ipairs(happy_ernie_activity_reward_cfg) do
		if self.reward_flag[33 - i] == 1 then
			table.insert(has_got_data_list, v)
		else
			table.insert(not_got_data_list, v)
		end
	end
	for i,v in ipairs(has_got_data_list) do
		table.insert(not_got_data_list, v)
	end
	return not_got_data_list
end

-- 获取欢乐摇奖珍稀展示配置
function HappyErnieData:GetHappyErnieRareRewardCfg()
	local happy_ernie_rare_reward = self:GetHappyErnieRareReward()
	return happy_ernie_rare_reward or {}
end

--获取协议下的数据
function HappyErnieData:SetRAHappyErnieInfo(protocol)
	self.happy_ernie_next_free_tao_timestamp = protocol.happy_ernie_next_free_tao_timestamp
    self.chou_times = protocol.chou_times
    self.reward_flag = bit:d2b(protocol.reward_flag)
end

--获取协议下的数据
function HappyErnieData:SetRAHappyErnieTaoResultInfo(protocol)
	self.count = protocol.count
    self.happy_ernie_tao_seq = protocol.happy_ernie_tao_seq
end

--获取服务器上的抽奖次数
function HappyErnieData:GetChouTimes()
	return self.chou_times
end

--获取服务器上的下次免费的时间戳
function HappyErnieData:GetNextFreeTaoTimestamp()
	return self.happy_ernie_next_free_tao_timestamp or 0
end

--是否已领取
function HappyErnieData:GetIsFetchFlag(index)
	return (1 == self.reward_flag[32 - index]) and true or false
end

--获取可获取奖励的抽奖次数
function HappyErnieData:GetCanFetchFlagByIndex(index)
	local happy_ernie_activity_reward_cfg = self:GetHappyErnieRewardConfig()
	if nil == happy_ernie_activity_reward_cfg then
		return 0
	end
	for k,v in pairs(happy_ernie_activity_reward_cfg) do
		if index == v.index then
			return v.choujiang_times or 0
		end
	end
	return 0
end

--设置奖励展示框模式
function HappyErnieData:SetChestShopMode(mode)
	self.chest_shop_mode = mode
end

--获取奖励展示框模式
function HappyErnieData:GetChestShopMode()
	return self.chest_shop_mode
end

--获取奖励展示框的格子数量
function HappyErnieData:GetChestCount()
	return self.count
end

--获取奖励展示框的信息
function HappyErnieData:GetChestShopItemInfo()
	local happy_ernie_reward_item = self:GetOpenTakeTimeCfg()
	if nil == next(happy_ernie_reward_item) then
		return {}
	end

	local data = {}
	for k,v in pairs(self.happy_ernie_tao_seq) do
		if happy_ernie_reward_item[v] then
			table.insert(data, happy_ernie_reward_item[v].reward_item)
		end
	end
	return data
end

--红点提示
function HappyErnieData:GetHappyErnieRemind()
	local happy_ernie_activity_reward_cfg = self:GetHappyErnieRewardConfig()
	if nil == happy_ernie_activity_reward_cfg or nil == self.reward_flag then
		return 0
	end
	-- 是否有免费次数
	local next_free_tao_timestamp = self:GetNextFreeTaoTimestamp()
	local server_time = TimeCtrl.Instance:GetServerTime()

	if next_free_tao_timestamp ~= 0 then
		if next_free_tao_timestamp < server_time then
			return 1
		end
	end

	-- 是否有摇奖钥匙
	local key_num, key_cfg = self:GetHappyErnieKeyNum()
	if key_num > 0 then
		return 1
	end

	-- 是否有可领取奖励
	if self.reward_flag == nil then
		return 0
	end
	local get_reward_times = 0
	for k,v in pairs(self.reward_flag) do
		if v == 1 then
			get_reward_times = get_reward_times + 1
		end
	end
	local can_reward_times = 0
	for k,v in pairs(happy_ernie_activity_reward_cfg) do
		if self.chou_times >= v.choujiang_times then
			can_reward_times = v.index + 1
		end
	end
	return can_reward_times > get_reward_times and 1 or 0
end

--主界面红点刷新
function HappyErnieData:FlushHallRedPoindRemind()
	local remind_num = self:GetHappyErnieRemind()
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPY_ERNIE, remind_num > 0)
end