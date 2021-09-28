HappyHitEggData = HappyHitEggData or BaseClass()

function HappyHitEggData:__init()
	if HappyHitEggData.Instance ~= nil then
		ErrorLog("[HappyHitEggData] attempt to create singleton twice!")
		return
	end
	HappyHitEggData.Instance = self
	self.count = -1
	self.chest_shop_mode = -1

	RemindManager.Instance:Register(RemindName.HappyEggRemind, BindTool.Bind(self.GetSecretTreasureHuntingRemind, self))
end

function HappyHitEggData:__delete()
	HappyHitEggData.Instance = nil
	self.count = nil 
	self.chest_shop_mode = nil
	RemindManager.Instance:UnRegister(RemindName.HappyEggRemind)
end

--获取整个配置表的配置
function HappyHitEggData:GetHappyHitEggConfigs()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig()
end


--根据开服时间获取配置  
function HappyHitEggData:GetOpenTakeTimeCfg()
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().huanlezadan
	local data = ActivityData.Instance:GetRandActivityConfig(config, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_ZADAN)
	return data
end

--获取欢乐的累计奖励配置表
function HappyHitEggData:GetHappyHitEggRewardConfig()
	local reward_cfg = {}
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	if config == nil then
		return reward_cfg
	end
	local reward_cfg = ActivityData.Instance:GetRandActivityConfig(config.huanlezadan_reward, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_ZADAN)
	return reward_cfg
end


function HappyHitEggData:SetRAHuanLeZaDanInfo(protocol)
	self.ra_mijingxunbao_next_free_tao_timestamp = protocol.ra_mijingxunbao_next_free_tao_timestamp
    self.chou_times = protocol.chou_times
    self.reward_flag = bit:d2b(protocol.reward_flag)
end


function HappyHitEggData:HappyHitEggBaoTaoResultInfo(protocol)
	 self.count = protocol.count
    self.mijingxunbao_tao_seq = protocol.mijingxunbao_tao_seq
end

--获取及奖励数量
function HappyHitEggData:GetRewardCount()
	return GetHappyHitEggConfigs()
end

--获取服务器上的抽奖次数
function HappyHitEggData:GetChouTimes()
	return self.chou_times or 0
end

--获取服务器上的下次免费的时间戳
function HappyHitEggData:GetNextFreeTaoTimestamp()
	return self.ra_mijingxunbao_next_free_tao_timestamp or 0
end

--从服务器上获取领取标准
function HappyHitEggData:GetCanFetchFlag(index)
	return (1 == self.reward_flag[33 - index]) and true or false
end

--设置奖励展示框模型
function HappyHitEggData:SetChestShopMode(mode)
	self.chest_shop_mode = mode
end

--获取奖励展示框模型
function HappyHitEggData:GetChestShopMode()
	return self.chest_shop_mode
end

--根据索引来找到配置表中对应的数据
function HappyHitEggData:GetHappyHitEggCfgBySeq(index)
	local cfg = self:GetOpenTakeTimeCfg()
	return ListToMap(cfg,"seq")
end

--获取奖励展示框的信息
function HappyHitEggData:GetChestShopItemInfo()
	local cfg = self:GetHappyHitEggCfgBySeq()
	local data = {}
	 for k,v in pairs(self.mijingxunbao_tao_seq) do
	 	table.insert(data,cfg[v].reward_item)
	 end
	 return data
end

function HappyHitEggData:GetRewardInfo()
	local alltimes = self:GetChouTimes()
	local configs = self:GetHappyHitEggConfigs()
	local reward_cfg = {}
	if configs then
		reward_cfg = configs.huanlezadan_reward
	end
	for i=1,6 do
		if alltimes >= reward_cfg[i].choujiang_times then
			if self.reward_flag[33 - i] == 0 then
				return 1
			end
		end
	end
	return 0 
end


--红点提示
function HappyHitEggData:GetSecretTreasureHuntingRemind()
	local next_free_tao_timestamp = self:GetNextFreeTaoTimestamp()
	local server_time = TimeCtrl.Instance:GetServerTime()
	local configs = HappyHitEggData.Instance:GetHappyHitEggConfigs()
	local key_num = 0
	if configs then
		key_num = ItemData.Instance:GetItemNumInBagById(configs.other[1].huanlezadan_thirtytimes_item_id)
	end
	local flag = self:GetRewardInfo()
	if flag == 1 then
		return 1
	end
	if next_free_tao_timestamp ~= 0 and (next_free_tao_timestamp < server_time) or key_num > 0 then
		return 1
	end
	return 0
end

--主界面红点刷新
function HappyHitEggData:FlushHallRedPoindRemind()
	local remind_num = self:GetSecretTreasureHuntingRemind()
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_ZADAN, remind_num > 0)
end
