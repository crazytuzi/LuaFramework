SecretTreasureHuntingData = SecretTreasureHuntingData or BaseClass()

local SHOP_MODE = {
	[1] = CHEST_SHOP_MODE.CHEST_MIJINGXUNBAO3_MODE_1,					
	[2] = CHEST_SHOP_MODE.CHEST_MIJINGXUNBAO3_MODE_10,
	[3] = CHEST_SHOP_MODE.CHEST_MIJINGXUNBAO3_MODE_30,
}

local SILDER_MAX_CHOU_TIME = 3000

function SecretTreasureHuntingData:__init()
	if SecretTreasureHuntingData.Instance ~= nil then
		ErrorLog("[SecretTreasureHuntingData] attempt to create singleton twice!")
		return
	end
	SecretTreasureHuntingData.Instance = self

	self.count = 0
	self.chou_times = 0
	self.chest_shop_mode = SHOP_MODE[1]
	self.ra_mijingxunbao_next_free_tao_timestamp = 0
	
	self.reward_flag = {}
	self.mijingxunbao_tao_seq_list = {}

	RemindManager.Instance:Register(RemindName.SecretTreasureHuntingRemind, BindTool.Bind(self.GetSecretTreasureHuntingRemind, self))
end

function SecretTreasureHuntingData:__delete()
	SecretTreasureHuntingData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.SecretTreasureHuntingRemind)
end

function SecretTreasureHuntingData:GetOtherCfgByOpenDay()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfigOtherCfg()
	return cfg
end

--根据开服时间获取配置  
function SecretTreasureHuntingData:GetOpenTakeTimeCfg()
	local data_cfg = {}
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	if nil == cfg then
		return data_cfg
	end
	
	data_cfg = ActivityData.Instance:GetRandActivityConfig(cfg.mijingxunbao3, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MIJINGXUNBAO3) or {}
	return data_cfg
end

--获取秘境寻宝的累计奖励配置表
function SecretTreasureHuntingData:GetMiJingXunBaoRewardConfig()
	local reward_cfg = {}
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	if nil == cfg then
		return reward_cfg
	end

	reward_cfg = ActivityData.Instance:GetRandActivityConfig(cfg.mijingxunbao3_reward, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MIJINGXUNBAO3) or {}
	return reward_cfg
end

function SecretTreasureHuntingData:GetMiJingXunBaoCfgByList()
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

function SecretTreasureHuntingData:SetRAMiJingXunBaoInfo(protocol)
	self.ra_mijingxunbao_next_free_tao_timestamp = protocol.ra_mijingxunbao3_next_free_tao_timestamp or 0
	self.chou_times = protocol.chou_times or 0
	self.reward_flag = bit:d2b(protocol.reward_flag) or {}
end

function SecretTreasureHuntingData:MiJingXunBaoTaoResultInfo(protocol)
	self.count = protocol.count or 0
    self.mijingxunbao_tao_seq_list = protocol.mijingxunbao3_tao_seq or {}
end

function SecretTreasureHuntingData:GetChouTimesByInfo()
	return self.chou_times or 0
end

function SecretTreasureHuntingData:GetNextFreeTaoTimestampByInfo()
	return self.ra_mijingxunbao_next_free_tao_timestamp or 0
end

function SecretTreasureHuntingData:GetCanFetchFlag(index)
	return self.reward_flag and self.reward_flag[32 - index] >= 1
end

--设置奖励展示框类型
function SecretTreasureHuntingData:SetChestShopMode(mode)
	local mode_type = mode and SHOP_MODE[mode]
	self.chest_shop_mode = mode_type
end

function SecretTreasureHuntingData:SetChestShopModeByTreasureView(mode)
	self.chest_shop_mode = mode
end

--获取奖励展示类型
function SecretTreasureHuntingData:GetChestShopMode()
	return self.chest_shop_mode
end

--获取奖励展示框的信息
function SecretTreasureHuntingData:GetChestShopItemInfo()
	local cfg = self:GetOpenTakeTimeCfg()
	local data = {}
	for k,v in pairs(self.mijingxunbao_tao_seq_list) do
	 	table.insert(data,cfg[v].reward_item)
	end
	return data
end

function SecretTreasureHuntingData:GetSecretTreasureHuntingRemind()
	local is_free = self:IsFree()
	if is_free then
		return 1
	end

	local is_have_thirty_key = self:IsHaveThirtyKey()
	if is_have_thirty_key > 0 then
		return 1
	end

	local is_can_get = self:IsCanGet()
	if is_can_get then
		return 1
	end

	return 0
end

--主界面红点刷新
function SecretTreasureHuntingData:FlushHallRedPoindRemind()
	local remind_num = self:GetSecretTreasureHuntingRemind()
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MIJINGXUNBAO3, remind_num > 0)
end


function SecretTreasureHuntingData:IsHaveThirtyKey()
	local key_cfg = self:GetOtherCfgByOpenDay()
	local key_id = key_cfg and key_cfg.mijingxunbao3_thirtytimes_item_id or 0
	local key_num = ItemData.Instance:GetItemNumInBagById(key_id)
	local item_cfg = ItemData.Instance:GetItemConfig(key_id)
	local color = SOUL_NAME_COLOR[1]
	local item_name = ""

	if key_num > 0 and nil ~= item_cfg and item_cfg.color then
		color = SOUL_NAME_COLOR[item_cfg.color] or SOUL_NAME_COLOR[1]
		item_name = item_cfg.name
	end

	return key_num, color, item_name
end

function SecretTreasureHuntingData:IsFree()
	local is_free = false
	local next_free_tao_timestamp = self:GetNextFreeTaoTimestampByInfo()
	local server_time = TimeCtrl.Instance:GetServerTime()

	if next_free_tao_timestamp ~= 0 and next_free_tao_timestamp <= server_time then
		is_free = true
	end

	return is_free
end

function SecretTreasureHuntingData:IsCanGet()
	local total_config = self:GetMiJingXunBaoRewardConfig()
	local info_choujiang_times = self:GetChouTimesByInfo()
	local is_can_get = false

	for k,v in pairs(total_config) do
		local is_get = self:GetCanFetchFlag(k - 1)
		if total_config[k].choujiang_times and info_choujiang_times >= total_config[k].choujiang_times and not is_get then
			is_can_get = true
			break
		end
	end

	return is_can_get
end

function SecretTreasureHuntingData:GetProValueByTimes(times)
	local silder_num = 0
	local chou_jiang_time = times
	local data = self:GetMiJingXunBaoRewardConfig()
	local list = {0.1, 0.2, 0.4, 0.5, 0.7, 0.85, 1}			--对应的进度条值

	if chou_jiang_time == 0  or  nil == next(data) then
		return silder_num 
	end
	
	for i= #data, 1, -1 do
		if data[i].choujiang_times and chou_jiang_time >= data[i].choujiang_times and chou_jiang_time < SILDER_MAX_CHOU_TIME then
			local next_level_times = data[i+1] and data[i+1].choujiang_times or SILDER_MAX_CHOU_TIME
			local cur_level_times = data[i].choujiang_times or 0
			local next_level_silder = list[i+1] or 1
			local cur_level_slider = list[i] or 0
			local diff = chou_jiang_time - cur_level_times
			local bili = (next_level_silder - cur_level_slider) / (next_level_times - cur_level_times)

			silder_num = cur_level_slider + diff * bili
			break
		elseif data[1].choujiang_times and chou_jiang_time < data[1].choujiang_times then
			local diff = chou_jiang_time
			local bili = list[1] / data[1].choujiang_times

			silder_num = diff * bili
			break
		elseif chou_jiang_time >= SILDER_MAX_CHOU_TIME then
			silder_num = list[#list]
			break
		end
	end

	return silder_num
end