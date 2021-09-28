AutumnHappyErnieData = AutumnHappyErnieData or BaseClass()
--初始化
function AutumnHappyErnieData:__init()
	if AutumnHappyErnieData.Instance ~= nil then
		ErrorLog("[AutumnHappyErnieData] attempt to create singleton twice!")
		return
	end
	AutumnHappyErnieData.Instance = self
	self.count = -1
	self.chest_shop_mode = -1
	self.chou_times = 0
end

--释放
function AutumnHappyErnieData:__delete()
	AutumnHappyErnieData.Instance = nil
	self.count = nil 
	self.chest_shop_mode = nil
end

-- 其他配置
function AutumnHappyErnieData:GetOtherCfgByOpenDay()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfigOtherCfg()
	return cfg
end

--根据开服时间获取欢乐摇奖配置  
function AutumnHappyErnieData:GetOpenTakeTimeCfg()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local happy_ernie_cfg = {}
	if nil == cfg then
		return nil
	end
	
	happy_ernie_cfg = ActivityData.Instance:GetRandActivityConfig(cfg.huanleyaojiang2, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPY_ERNIE) or {}
	return happy_ernie_cfg
end

--获取欢乐摇奖的累计奖励配置表
function AutumnHappyErnieData:GetHappyErnieRewardConfig()
	local reward_cfg = {}
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	if nil == cfg then
		return nil
	end

	reward_cfg = ActivityData.Instance:GetRandActivityConfig(cfg.huanleyaojiang2_reward, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPY_ERNIE)
	return reward_cfg
end

function AutumnHappyErnieData:GetHappyErnieCfgByList()
	local cfg = self:GetOpenTakeTimeCfg()
	local list = {}
	if nil == next(cfg) then
		return nil
	end

	for k,v in pairs(cfg) do
		if v.is_show == 1 then
			table.insert(list, v)
		end
	end

    if nil == next(list) then
		return nil
	end

	return list
end

--获取抽取消耗金额
function AutumnHappyErnieData:GetHappyErnieDrawCost()
	local happy_ernie_other_configs = self:GetOtherCfgByOpenDay()
	if nil == happy_ernie_other_configs then
		return nil
	end
	local draw_gold_list = {}
	draw_gold_list.once_gold = happy_ernie_other_configs.huanleyaojiang2_once_gold or 0
	draw_gold_list.tenth_gold = happy_ernie_other_configs.huanleyaojiang2_tentimes_gold or 0
	draw_gold_list.thirtieth_gold = happy_ernie_other_configs.huanleyaojiang2_thirtytimes_gold or 0

	return draw_gold_list
end

function AutumnHappyErnieData:GetHappyErnieKeyNum()
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
function AutumnHappyErnieData:GetHappyErnieRewardItemConfig()
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

--获取协议下的数据
function AutumnHappyErnieData:SetRAHappyErnieInfo(protocol)
	self.ra_huanleyaojiang_next_free_tao_timestamp = protocol.ra_huanleyaojiang_next_free_tao_timestamp
    self.chou_times = protocol.chou_times
    self.reward_flag = bit:d2b(protocol.reward_flag)
end

--获取协议下的数据
function AutumnHappyErnieData:SetRAHappyErnieTaoResultInfo(protocol)
	self.count = protocol.count
    self.huanleyaojiang_tao_seq = protocol.huanleyaojiang_tao_seq
end

--获取服务器上的抽奖次数
function AutumnHappyErnieData:GetChouTimes()
	return self.chou_times
end

--获取服务器上的下次免费的时间戳
function AutumnHappyErnieData:GetNextFreeTaoTimestamp()
	return self.ra_huanleyaojiang_next_free_tao_timestamp or 0
end

--是否已领取
function AutumnHappyErnieData:GetIsFetchFlag(index)
	return (1 == self.reward_flag[32 - index]) and true or false
end

--获取可获取奖励的抽奖次数
function AutumnHappyErnieData:GetCanFetchFlagByIndex(index)
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
function AutumnHappyErnieData:SetChestShopMode(mode)
	self.chest_shop_mode = mode
end

--获取奖励展示框模式
function AutumnHappyErnieData:GetChestShopMode()
	return self.chest_shop_mode
end

--获取奖励展示框的格子数量
function AutumnHappyErnieData:GetChestCount()
	return self.count
end

--获取奖励展示框的信息
function AutumnHappyErnieData:GetChestShopItemInfo()
	local happy_ernie_reward_item = self:GetOpenTakeTimeCfg()
	if nil == next(happy_ernie_reward_item) then
		return {}
	end

	local data = {}
	for k,v in pairs(self.huanleyaojiang_tao_seq) do
		if happy_ernie_reward_item[v] then
			table.insert(data, happy_ernie_reward_item[v].reward_item)
		end
	end

	if nil == next(data) then
		return nil
	end

	return data
end
