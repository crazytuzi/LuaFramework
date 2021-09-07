
KuaFuMiningData = KuaFuMiningData or BaseClass()

function KuaFuMiningData:__init()
	if KuaFuMiningData.Instance ~= nil then
		print("[KuaFuMiningData] attempt to create singleton twice!")
		return
	end
	KuaFuMiningData.Instance = self
	self.mining_role_info = {
		uuid =	0,
		name = "",
		status = 0,
		combo_times = 0,
		max_combo_times = 0,
		used_mining_times = 0,
		add_mining_times = 0,
		score = 0,
		start_mining_timestamp = 0,
		enter_scene_timestamp = 0,
		hit_area_times_list = {},
		mine_num_list = {},
	}

	self.pos_list = {}
	self.item_list = {}
	self.obtain_item = {}
	self.mining_rank_info = {}

	self.result_type = 0
	self.max_combo = 0
	self.last_combo = 0

	self.other_cfg = nil
	self.mining_cfg = nil
	self.exchange_cfg = nil
	self.combo_reward_cfg = nil
	self.score_reward_cfg = nil

	self.mine_type_cfg = ListToMap(self:GetMiningCfg().mine_cfg, "mine_type")
end

function KuaFuMiningData:__delete()
	KuaFuMiningData.Instance = nil
end

function KuaFuMiningData:SetMiningRoleInfo(protocol)
	self.mining_role_info.uuid = protocol.uuid											--玩家唯一ID
	self.mining_role_info.name = protocol.name											--玩家名字
	self.mining_role_info.status = protocol.status										--玩家状态
	self.mining_role_info.combo_times = protocol.combo_times							--连击次数
	self.mining_role_info.max_combo_times = protocol.max_combo_times					--最大连击次数
	self.mining_role_info.used_mining_times = protocol.used_mining_times				--已经挖矿次数
	self.mining_role_info.add_mining_times = protocol.add_mining_times					--增加挖矿次数
	self.mining_role_info.score = protocol.score										--玩家积分
	self.mining_role_info.start_mining_timestamp = protocol.start_mining_timestamp		--玩家开始挖矿时间戳
	self.mining_role_info.enter_scene_timestamp = protocol.enter_scene_timestamp		--玩家进入场景时间戳
	self.mining_role_info.hit_area_times_list = protocol.hit_area_times_list			--玩家挖中各区域次数列表（以挖矿类型为下标）
	self.mining_role_info.mine_num_list = protocol.mine_num_list						--矿石个数列表（以矿石类型为下标）
end

function KuaFuMiningData:GetMiningIsAuto()
	return self.mining_role_info.status == SPECIAL_CROSS_MINING_ROLE_STATUS.SPECIAL_CROSS_MINING_ROLE_STATUS_AUTO_MINING
end

function KuaFuMiningData:GetMiningRoleInfo()
	return self.mining_role_info
end

function KuaFuMiningData:SetMiningRankInfo(protocol)
	local rank_need_num = 3
	self.mining_rank_info = {}
	if protocol.rank_item_count > rank_need_num then
		for i = 1, rank_need_num do
			self.mining_rank_info[i] = protocol.rank_item_list[i]
		end
	else
		self.mining_rank_info = protocol.rank_item_list
	end
end

function KuaFuMiningData:GetMiningRankInfo()
	return self.mining_rank_info
end

function KuaFuMiningData:SetMiningGatherPosInfo(protocol)
	self.pos_list = protocol.pos_list										--排行榜信息
end

function KuaFuMiningData:GetMiningGatherPosInfo()
	return self.pos_list
end

function KuaFuMiningData:SetMiningResultInfo(protocol)
	self.result_type = protocol.result_type
	local param_1, param_2 ,param_3 = protocol.param_1, protocol.param_2, protocol.param_3

	self.obtain_item = {item_id=param_1, num=param_2, is_bind=param_3}
end

--得到的物品
function KuaFuMiningData:GetMiningObtainItem()
	return self.obtain_item
end

function KuaFuMiningData:GetMiningResuleType()
	return self.result_type
end

function KuaFuMiningData:SetMiningBeStealedInfo(protocol)
	self.item_list = protocol.item_list
end

function KuaFuMiningData:GetMiningBeStealedInfo()
	return self.item_list
end

function KuaFuMiningData:GetMiningDistancePosList(pos_list)
	if not next(pos_list) then return end
	local new_pos_list = {}
	local x, y = Scene.Instance:GetMainRole():GetLogicPos()
	local target_x, target_y = 0, 0

	for k, v in pairs(pos_list) do
		target_x, target_y = v.x, v.y
		v.dis = GameMath.GetDistance(x, y, target_x, target_y, false)
		table.insert(new_pos_list, v)
	end

	if not next(new_pos_list) then return end

	SortTools.SortAsc(new_pos_list, "dis")

	return new_pos_list
end

----------------读取配置
function KuaFuMiningData:GetMiningCfg()
	if not self.mining_cfg then
		self.mining_cfg = ConfigManager.Instance:GetAutoConfig("cross_mining_auto") or {}
	end
	return self.mining_cfg
end

function KuaFuMiningData:GetMiningExchangeCfg()
	if not self.exchange_cfg then
		self.exchange_cfg = self:GetMiningCfg().exchange
	end
	return self.exchange_cfg
end

function KuaFuMiningData:GetMiningOtherCfg()
	if not self.other_cfg then
		self.other_cfg = self:GetMiningCfg().other[1]
	end
	return self.other_cfg
end

function KuaFuMiningData:GetMiningComboRewardCfg()
	if not self.combo_reward_cfg then
		self.combo_reward_cfg = self:GetMiningCfg().combo_reward_cfg
	end
	return self.combo_reward_cfg
end

function KuaFuMiningData:GetMiningMineCfg()
	return self.mine_type_cfg
end

function KuaFuMiningData:GetScoreRewardCfg()
	if not self.score_reward_cfg then
		self.score_reward_cfg = self:GetMiningCfg().score_reward
	end
	return self.score_reward_cfg
end

function KuaFuMiningData:GetScoreReward(need_score)
	local reward_cfg = self:GetScoreRewardCfg()
	if reward_cfg then
		for k,v in pairs(reward_cfg) do
			if need_score < v.need_score then
				return v
			end
		end
		return reward_cfg[#reward_cfg]
	end
	return nil
end

function KuaFuMiningData:GetIsMaxMiningTimes()
	local mining_info = KuaFuMiningData.Instance:GetMiningRoleInfo()
	local mining_other_cfg = KuaFuMiningData.Instance:GetMiningOtherCfg()
	if mining_info and mining_other_cfg then
		if mining_info.used_mining_times >= mining_other_cfg.mining_times + mining_info.add_mining_times then
			return true
		end
	end
	return false
end