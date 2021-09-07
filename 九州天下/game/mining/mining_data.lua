MiningData = MiningData or BaseClass()

MINING_VIEW_TYPE = {
	MINE = 0,		--挖矿
	SEA = 1,		--航海
}

MINING_TARGET_TYPE = {
	QIANG_DUO = 0,		--抢夺
	FU_CHOU = 1,		--复仇
}

MINING_MINE_REQ_TYPE =
{
	-- 挖矿
	REQ_TYPE_MINING_INFO = 0,		-- 拉取能抢的矿点信息（服务端默认下发N个，不发所有的，够用就行）
	REQ_TYPE_M_BEEN_ROB_INFO = 1,	-- 挖矿-拉取被抢劫的信息
	REQ_TYPE_REFLUSH_MINING = 2,	-- 刷新矿的颜色
	REQ_TYPE_START_MINING = 3,		-- 开始挖矿
	REQ_TYPE_BUY_TIMES = 4,			-- 购买挖矿次数
	REQ_TYPE_ROB_MINE = 5,			-- 抢矿，param1 NULL  param2 玩家UID（保证不会抢错）
	REQ_TYPE_ROB_ROBOT = 6,			-- 抢矿 -- 抢夺机器人，param1 机器人下标（0 - 7）
	REQ_TYPE_REVENGE = 7,			-- 复仇，param1 被抢矿记录index
	REQ_TYPE_FETCH_REWARD = 8,		-- 领取挖矿奖励

	-- 航海
	REQ_TYPE_SEA_MINING_INFO = 9,		-- 拉取能抢的矿点信息（服务端默认下发N个，不发所有的，够用就行）
	REQ_TYPE_SEA_BEEN_ROB_INFO = 10,	-- 挖矿-拉取被抢劫的信息
	REQ_TYPE_SEA_REFLUSH_MINING = 11,	-- 刷新矿的颜色
	REQ_TYPE_SEA_START_MINING = 12,		-- 开始挖矿
	REQ_TYPE_SEA_BUY_TIMES = 13,		-- 购买挖矿次数
	REQ_TYPE_SEA_ROB_MINE = 14,			-- 抢矿，param1 NULL  param2 玩家UID（保证不会抢错）
	REQ_TYPE_SEA_ROB_ROBOT = 15,		-- 抢矿 -- 抢夺机器人，param1 机器人下标（0 - 7）
	REQ_TYPE_SEA_REVENGE = 16,			-- 复仇，param1 被抢矿记录index
	REQ_TYPE_SEA_FETCH_REWARD = 17,		-- 领取挖矿奖励

	REQ_TYPE_C_INFO = 18,				-- 挑衅-请求列表信息
	REQ_TYPE_C_REFLUSH = 19,			-- 挑衅-刷新列表
	REQ_TYPE_C_BUY_FIGHTING_TIMES = 20, -- 挑衅-VIP购买挑战次数
	REQ_TYPE_C_FIGHTING = 21,			-- 挑衅-挑战对手
}

function MiningData:__init()
	if MiningData.Instance ~= nil then
		print_error("[MiningData] attempt to create singleton twice!")
		return
	end
	MiningData.Instance = self

	self.other_cfg = ConfigManager.Instance:GetAutoConfig("fighting_cfg_auto").other[1]
	self.random_name_cfg = ConfigManager.Instance:GetAutoConfig("randname_auto").random_name[1]

	self.red_point_list = {
		["MiningMine"] = 0,
		["MiningSea"] = 0,
		["MiningMineRecord"] = 0,
		["MiningSeaRecord"] = 0,
		["MiningMineRob"] = 0,
		["MiningSeaRob"] = 0,
	}

	self.opponent_list = {}

	-- 挖矿
	self.mine_list = {} 					-- 矿数量
	self.mine_count = 0 					-- 矿列表

	self.today_buy_times = 0 				-- 今日已购买次数
	self.today_mining_times = 0 			-- 今日已挖矿次数
	self.today_rob_mine_times = 0 			-- 今日已抢劫矿次数

	self.my_mining_mine_info =
	{
		mining_type = 0, 					-- 当前矿类型
		mining_been_rob_times = 0, 			-- 当前矿被挖的次数
		mining_end_time = 0, 				-- 当前矿结束挖的时间戳
	}

	self.mining_mine_rob_list = {}

	-- 航海
	self.sea_list = {} 					-- 矿数量
	self.sea_count = 0 					-- 矿列表

	self.today_sea_buy_times = 0 				-- 今日已购买次数
	self.today_sea_mining_times = 0 			-- 今日已挖矿次数
	self.today_sea_rob_mine_times = 0 			-- 今日已抢劫矿次数

	self.my_mining_sea_info =
	{
		mining_type = 0, 					-- 当前矿类型
		mining_been_rob_times = 0, 			-- 当前矿被挖的次数
		mining_end_time = 0, 				-- 当前矿结束挖的时间戳
	}

	self.mining_sea_rob_list = {}

	self.fight_open_times = 0 				-- 战斗开始时间
	self.fighting_result =
	{
		is_win = 0,
		fighting_type = 0,
		reward_exp = 0,
		item_list = {},
		show_item_list = {},
	}

	self.fighting_challenge_base_info = {
		challenge_score = 0,				-- 分數
		challenge_day_times = 0,			-- 剩余挑战次数
		vip_buy_times = 0,					-- vip购买了的次数
		next_add_challenge_timestamp = 0,	-- 剩余增加次数时间戳
		next_auto_reflush_time = 0,			-- 自动刷新角色时间戳
	}

	self.is_has_mine_rob = false 				-- 是否提示挖矿复仇红点
	self.is_has_sea_rob = false 				-- 是否提示航海复仇红点
	self.mine_record_client_list = {}			-- 挖矿复仇列表
	self.sea_record_client_list = {}			-- 航海复仇列表

	RemindManager.Instance:Register(RemindName.MiningMine, BindTool.Bind(self.GetMiningMineRemind, self))
	RemindManager.Instance:Register(RemindName.MiningSea, BindTool.Bind(self.GetMiningSeaRemind, self))
	RemindManager.Instance:Register(RemindName.MiningChallenge, BindTool.Bind(self.GetChallengeRedPoint, self))
end

function MiningData:__delete()
	RemindManager.Instance:UnRegister(RemindName.MiningMine)
	RemindManager.Instance:UnRegister(RemindName.MiningSea)
	RemindManager.Instance:UnRegister(RemindName.MiningChallenge)

	self.my_mining_mine_info = nil
	self.mining_mine_rob_list = nil
	self.mine_record_client_list = {}
	self.sea_record_client_list = {}
	MiningData.Instance = nil
end

function MiningData:InitOtherCfg()
	--self.other_cfg.dm_day_times  每天挖矿次数
	--self.other_cfg.dm_buy_time_need_gold  购买一次上限需要元宝
	--self.other_cfg.dm_cost_time_m  采矿一次耗时（分钟）
	--self.other_cfg.dm_rob_times  每天掠夺别人次数
	--self.other_cfg.dm_been_rob_times  每天最多被别人掠夺次数
	--self.other_cfg.dm_rob_reward_rate  掠夺成功后获取对方奖励百分比

	--self.other_cfg.sl_day_times  每天挖矿次数
	--self.other_cfg.sl_buy_time_need_gold  购买一次上限需要元宝
	--self.other_cfg.sl_cost_time_m  采矿一次耗时（分钟）
	--self.other_cfg.sl_rob_times  每天掠夺别人次数
	--self.other_cfg.sl_been_rob_times  每天最多被别人掠夺次数
	--self.other_cfg.sl_rob_reward_rate  掠夺成功后获取对方奖励百分比
end

--检查红点
function MiningData:GetMiningMineRemind()
	if self.red_point_list["MiningMine"] == 1 or self.red_point_list["MiningMineRecord"] == 1 or self.red_point_list["MiningMineRob"] == 1 then
		return 1
	end

	return 0
end

--检查红点
function MiningData:GetMiningSeaRemind()
	if self.red_point_list["MiningSea"] == 1 or self.red_point_list["MiningSeaRecord"] == 1 or self.red_point_list["MiningSeaRob"] == 1  then
		return 1
	end

	return 0
end

function MiningData:GetMiningMineRemindView()
	return self.red_point_list["MiningMine"]
end

function MiningData:GetMiningSeaRemindView()
	return self.red_point_list["MiningSea"]
end

--检查红点
function MiningData:CheckRedPoint()
	local add_mine = self:UpdateMiningMineCan()
	local add_sea = self:UpdateMiningSeaCan()
	if add_mine == 1 or add_sea == 1 then
		self:ShowMiningTime(true)
	else
		self:ShowMiningTime(false)
	end
end

function MiningData:FireMiningMineRed(type, index)
	if self.red_point_list[type] ~= nil then
		if self.red_point_list[type] ~= nil then
			self.red_point_list[type] = index
			if type == "MiningMine" or type ==  "MiningMineRob" then
				RemindManager.Instance:Fire(RemindName.MiningMine)
			elseif type == "MiningSea" or type == "MiningSeaRob" then
				RemindManager.Instance:Fire(RemindName.MiningSea)
			end
		end
	end
end

--检查红点矿物
function MiningData:UpdateMiningMineCan()
	if OpenFunData.Instance:CheckIsHide("mining_mine") == false then return 0 end

	local is_add_time = 0
	local info_data = self:GetMiningMineMyInfo()
	if info_data and info_data.mining_end_time > 0 then
		local time = math.max(info_data.mining_end_time - TimeCtrl.Instance:GetServerTime(), 0)
		if time == 0 then
			self:FireMiningMineRed("MiningMine", 1)
		else
			self:FireMiningMineRed("MiningMine", 0)
			is_add_time = 1
		end
	else
		local times = self:GetMiningMineDayTimes()
		if times > 0 then
			self:FireMiningMineRed("MiningMine", 1)
		else
			self:FireMiningMineRed("MiningMine", 0)
		end
	end
	return is_add_time
end

--检查红点矿物
function MiningData:UpdateMiningSeaCan()
	if OpenFunData.Instance:CheckIsHide("mining_sea") == false then return 0 end
	
	local is_add_time = 0
	local info_data = self:GetMiningSeaMyInfo()
	if info_data and info_data.mining_end_time > 0 then
		local time = math.max(info_data.mining_end_time - TimeCtrl.Instance:GetServerTime(), 0)
		if time == 0 then
			self:FireMiningMineRed("MiningSea", 1)
		else
			self:FireMiningMineRed("MiningSea", 0)
			is_add_time = 1
		end
	else
		local times = self:GetMiningSeaDayTimes()
		if times > 0 then
			self:FireMiningMineRed("MiningSea", 1)
		else
			self:FireMiningMineRed("MiningSea", 0)
		end
	end
	return is_add_time
end

--检查红点矿物(掠夺)
function MiningData:UpdateMiningMineRobCan()
	if OpenFunData.Instance:CheckIsHide("mining_mine") == false then return 0 end

	local times = self:GetMiningMineRobTimes()
	if times > 0 then
		self:FireMiningMineRed("MiningMineRob", 1)
	else
		self:FireMiningMineRed("MiningMineRob", 0)
	end
end

--检查红点矿物(掠夺)
function MiningData:UpdateMiningSeaRobCan()
	if OpenFunData.Instance:CheckIsHide("mining_sea") == false then return 0 end
	
	local times = self:GetMiningSeaRobTimes()
	if times > 0 then
		self:FireMiningMineRed("MiningSeaRob", 1)
	else
		self:FireMiningMineRed("MiningSeaRob", 0)
	end
end

-- 是否需要启动红点定时器刷新红点
function MiningData:ShowMiningTime(state)
	if state then
		if self.time_quest == nil then
			self.time_quest = GlobalTimerQuest:AddRunQuest(
				BindTool.Bind2(self.CheckRedPoint, self), 10)
		end
	else
		self:RemoveMiningTime()
	end
end

-- 挖矿，航海-有新的抢夺记录
function MiningData:CheckRedRecordPoint(view_type)
	if view_type == MINING_VIEW_TYPE.MINE then
		local times = self:GetMiningMineRobTimes()
		if times > 0 and self.is_has_mine_rob then
			self:FireMiningMineRed("MiningMineRecord", 1)
		else
			self.is_has_mine_rob = false
			self:FireMiningMineRed("MiningMineRecord", 0)
		end
	elseif view_type == MINING_VIEW_TYPE.SEA then
		local times = self:GetMiningSeaRobTimes()
		if times > 0 and self.is_has_sea_rob then
			self:FireMiningMineRed("MiningSeaRecord", 1)
		else
			self.is_has_sea_rob = false
			self:FireMiningMineRed("MiningSeaRecord", 0)
		end
	end
end

-- 移除启动红点定时器刷新红点
function MiningData:RemoveMiningTime()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function MiningData:GetOtherCfg()
	return self.other_cfg
end

-------挖矿----------
--矿物奖励配置
function MiningData:GetMiningMineCfg(index)
	if index == nil then return nil end
	local mining_reward_cfg = ConfigManager.Instance:GetAutoConfig("fighting_cfg_auto").mining_reward
	for k, v in pairs(mining_reward_cfg) do
		if v.quality == index then
			return v
		end
	end
	return nil
end

-- 剩余挖矿次数
function MiningData:GetMiningMineDayTimes()
	local dm_day_times = self.other_cfg.dm_day_times or 0
	local totle_time = dm_day_times + self.today_buy_times - self.today_mining_times
	return totle_time
end

-- 剩余抢夺次数
function MiningData:GetMiningMineRobTimes()
	local dm_rob_times = self.other_cfg.dm_rob_times or 0
	local totle_time = dm_rob_times - self.today_rob_mine_times
	return totle_time
end

-- 购买次数
function MiningData:GetMiningMineTodayBuyTimes()
	return self.today_buy_times
end

-- 矿列表
function MiningData:SetMiningMineList(protocol)
	self.mine_count = protocol.mine_count
	self.mine_list = protocol.mine_list
end

-- 获取矿列表 数量
function MiningData:GetMiningMineList()
	return self.mine_list, self.mine_count
end

-- 挖矿基础信息
function MiningData:SetMiningMineInfo(protocol)
	self.today_mining_times = protocol.today_mining_times
	self.today_buy_times = protocol.today_buy_times
	self.today_rob_mine_times = protocol.today_rob_mine_times
	self.my_mining_mine_info.mining_type = protocol.mining_type
	self.my_mining_mine_info.mining_been_rob_times = protocol.mining_been_rob_times
	self.my_mining_mine_info.mining_end_time = protocol.mining_end_time
end

-- 获取自己的矿物
function MiningData:GetMiningMineMyInfo()
	return self.my_mining_mine_info
end

-- 设置自己的矿物index
function MiningData:SetMiningMineMyLine(index)

end

-- 设置的矿物记录
function MiningData:SetMiningBeenRobList(protocol)
	self.mining_mine_rob_list = protocol.mining_rob_list
end
-------挖矿end----------

-------航海----------
--航海奖励配置
function MiningData:GetMiningSeaCfg(index)
	if index == nil then return nil end
	local mining_reward_cfg = ConfigManager.Instance:GetAutoConfig("fighting_cfg_auto").sailing_reward
	for k, v in pairs(mining_reward_cfg) do
		if v.quality == index then
			return v
		end
	end
	return nil
end

-- 剩余航海次数
function MiningData:GetMiningSeaDayTimes()
	local sl_day_times = self.other_cfg.sl_day_times or 0
	local totle_time = sl_day_times + self.today_sea_buy_times - self.today_sea_mining_times
	return totle_time
end

-- 剩余航海次数
function MiningData:GetMiningSeaRobTimes()
	local sl_rob_times = self.other_cfg.sl_rob_times or 0
	local totle_time = sl_rob_times - self.today_sea_rob_mine_times
	return totle_time
end

-- 购买次数
function MiningData:GetMiningSeaTodayBuyTimes()
	return self.today_sea_buy_times
end

-- 航海列表
function MiningData:SetMiningSeaList(protocol)
	self.sea_count = protocol.mine_count
	self.sea_list = protocol.mine_list
end

-- 获取航海列表 数量
function MiningData:GetMiningSeaList()
	return self.sea_list, self.sea_count
end

-- 航海基础信息
function MiningData:SetMiningSeaInfo(protocol)
	self.today_sea_mining_times = protocol.today_mining_times
	self.today_sea_buy_times = protocol.today_buy_times
	self.today_sea_rob_mine_times = protocol.today_rob_mine_times
	self.my_mining_sea_info.mining_type = protocol.mining_type
	self.my_mining_sea_info.mining_been_rob_times = protocol.mining_been_rob_times
	self.my_mining_sea_info.mining_end_time = protocol.mining_end_time
end

-- 获取自己的航海
function MiningData:GetMiningSeaMyInfo()
	return self.my_mining_sea_info
end

-- 设置自己的航海index
function MiningData:SetMiningSeaMyLine(index)

end

-- 设置的航海记录
function MiningData:SetMiningSeaBeenRobList(protocol)
	self.mining_sea_rob_list = protocol.mining_rob_list
end
-------------航海、end------------

-- 获取经验值
function MiningData:GetMiningExpValue(value, level)
	local show_value = value or 0
	local show_level = level or 0
	return (show_level + 50) * value
end

-- 设置战斗时间
function MiningData:SetMiningFightStartTime(protocol)
	self.fight_open_times = protocol.start_fighting_time
end

function MiningData:GetMiningFightStartTime()
	return self.fight_open_times
end

-- 是否自己的
function MiningData:GetIsMyMining(owner_uid)
	return PlayerData.Instance.role_vo.role_id == owner_uid
end

-- 根据类型获取目录
function MiningData:GetMiningBeenRobListByViewType(view_type)
	if view_type == MINING_VIEW_TYPE.MINE then
		return self.mining_mine_rob_list
	elseif view_type == MINING_VIEW_TYPE.SEA then
		return self.mining_sea_rob_list
	end
	return nil
end

function MiningData:GetMiningRewardByViewType(view_type, index, mining_type, level)
	local reward_data = nil
    local rate = 0
    local rob_get_item_count = 1
    local show_level = level or 1
	if view_type == MINING_VIEW_TYPE.MINE then
		reward_data = self:GetMiningMineCfg(mining_type)
		rate = self.other_cfg.dm_rob_reward_rate
		rob_get_item_count = reward_data.rob_get_item_count
	elseif view_type == MINING_VIEW_TYPE.SEA then
		reward_data = self:GetMiningSeaCfg(mining_type)
		rate = self.other_cfg.sl_rob_reward_rate
		rob_get_item_count = reward_data.rob_get_item_count
	end

	if MINING_TARGET_TYPE.FU_CHOU == index then
		rate = rate * 2
		rob_get_item_count = rob_get_item_count * 2
	end
	rate = string.format("%.2f", rate / 100.0)
	if reward_data ~= nil then
		local item_1 = TableCopy(reward_data.reward_item[0])
		if item_1 ~= nil then
			item_1.num = rob_get_item_count--math.floor(item_1.num * rate)
		end

		local item_2_exp = self:GetMiningExpValue(reward_data.reward_exp, show_level)
		local item_2_num = math.floor(item_2_exp * rate)
		local item_2 = {item_id = ResPath.CurrencyToIconId.exp or 0, num = item_2_num, is_bind = 0}

		return item_1, item_2, rate
	end
	return nil, nil, rate
end

-----------------挑衅-------------------
function MiningData:SetChallengeRoleInfo(opponent_list)
	self.opponent_list = opponent_list
end

function MiningData:GetChallengeRoleInfo(opponent_list)
	return self.opponent_list
end

function MiningData:SetChallengeTimes(times)
	self.challenge_day_times = times
end

function MiningData:GetChallengeTimes(times)
	return self.challenge_day_times
end

function MiningData:SetFightingChallengeBaseInfo(protocol)
	self.fighting_challenge_base_info.challenge_score = protocol.challenge_score
	self.fighting_challenge_base_info.challenge_day_times = protocol.challenge_day_times
	self.fighting_challenge_base_info.next_add_challenge_timestamp = protocol.next_add_challenge_timestamp
	self.fighting_challenge_base_info.next_auto_reflush_time = protocol.next_auto_reflush_time
	self.fighting_challenge_base_info.vip_buy_times = protocol.vip_buy_times
end

function MiningData:GetFightingChallengeBaseInfo()
	return self.fighting_challenge_base_info
end

function MiningData:GetRandomNameByRandNum(rand_num)
	local name_cfg = self.random_name_cfg
	local sex = rand_num % 2

	local name_first_list = {}	-- 前缀
	local name_last_list = {}	-- 后缀
	if sex == GameEnum.FEMALE then
		name_first_list = name_cfg.female_first
		name_last_list = name_cfg.female_last
	else
		name_first_list = name_cfg.male_first
		name_last_list = name_cfg.male_last
	end

	local name_first_index = (rand_num % #name_first_list) + 1
	local name_last_index = (rand_num % #name_last_list) + 1
	local first_name = name_first_list[name_first_index] or ""
	local last_name = name_last_list[name_last_index] or ""
	return first_name .. last_name
end

function MiningData:GetChallengeLeftTimes()
	local left_times =  self.fighting_challenge_base_info.challenge_day_times
	return left_times
end

function MiningData:GetChallengeRewardByRank(rank)
	local reward_cfg = ConfigManager.Instance:GetAutoConfig("fighting_cfg_auto").challenge_rank_reward
	for i,v in ipairs(reward_cfg) do
		if rank <= v.rank then
			return v
		end
	end

	return {}
end

function MiningData:GetBuyChallengeTimesCost()
	return self.other_cfg.cf_buy_time_need_gold
end

function MiningData:GetChallengeFightResuleReward()
	local reward_list = {}
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	if self.other_cfg.cf_win_add_exp > 0 then
		local reward = {item_id = ResPath.CurrencyToIconId.exp, num = self.other_cfg.cf_win_add_exp * math.floor(1 + role_level / 100), is_bind = 0}
		table.insert(reward_list, reward)
	end

	if self.other_cfg.cf_win_add_mojing > 0 then
		local reward = {item_id = ResPath.CurrencyToIconId.shengwang, num = self.other_cfg.cf_win_add_mojing, is_bind = 0}
		table.insert(reward_list, reward)
	end

	return reward_list
end

function MiningData:GetChallengeRedPoint()
	local left_times = self.fighting_challenge_base_info.challenge_day_times
	return left_times
end

function MiningData:GetChallengeLeftBuyTimes()
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	local cur_vip_max_times = VipData.Instance:GetVipPowerList(vip_level)[VIPPOWER.MINING_CHALLENGE] or 0
	local cur_buy_times = self.fighting_challenge_base_info.vip_buy_times
	return cur_vip_max_times - cur_buy_times
end

-----------------挑衅/end-------------------

-- 战斗结果
function MiningData:SetFightingResultNotify(protocol)
	self.fighting_result.is_win = protocol.is_win
	self.fighting_result.fighting_type = protocol.fighting_type
	self.fighting_result.reward_exp = protocol.reward_exp
	self.fighting_result.item_list = protocol.item_list
	self.fighting_result.show_item_list[1] = {item_id = ResPath.CurrencyToIconId.exp or 0, num = self.fighting_result.reward_exp, is_bind = 0}
	if self.fighting_result.item_list[1] and self.fighting_result.item_list[1].num > 0 then
		self.fighting_result.show_item_list[2] = self.fighting_result.item_list[1]
	end

	-- 挑衅战斗结果特殊处理，奖励客户端自己去配置拿
	if self.fighting_result.fighting_type == MiningChallengeType.CHALLENGE_TYPE_FIGHTING then
		self.fighting_result.show_item_list = self:GetChallengeFightResuleReward()
	end
end

-- 战斗结果
function MiningData:GetFightingResultNotify()
	return self.fighting_result
end

-- 战斗结果初始化
function MiningData:SetFightingResultNotifyNo()
	self.fighting_result.is_win = 0
	self.fighting_result.fighting_type = 0
	self.fighting_result.reward_exp = 0
	self.fighting_result.item_list = {}
	self.fighting_result.show_item_list = {}
end

------------------ 记录-------------
-- 挖矿，航海-有新的抢夺记录
function MiningData:SetFightingBeenRobNotify(protocol)
	if protocol.type == MINING_VIEW_TYPE.MINE then
		local times = self:GetMiningMineRobTimes()
		if times > 0 then
			self.is_has_mine_rob = true
			self:FireMiningMineRed("MiningMineRecord", 1)
		else
			self.is_has_mine_rob = false
			self:FireMiningMineRed("MiningMineRecord", 0)
		end
	elseif protocol.type == MINING_VIEW_TYPE.SEA then
		local times = self:GetMiningSeaRobTimes()
		if times > 0 then
			self.is_has_sea_rob = true
			self:FireMiningMineRed("MiningSeaRecord", 1)
		else
			self.is_has_sea_rob = false
			self:FireMiningMineRed("MiningSeaRecord", 0)
		end
	end
end

-- 已经查看过
function MiningData:SetFightingBeenRobNo(type)
	if type == MINING_VIEW_TYPE.MINE then
		self.is_has_mine_rob = false
		self:FireMiningMineRed("MiningMineRecord", 0)
	elseif type == MINING_VIEW_TYPE.SEA then
		self.is_has_sea_rob = false
		self:FireMiningMineRed("MiningSeaRecord", 0)
	end
end

-- 挖矿记录是否提示
function MiningData:GetFightingBeenRobMine()
	return self.is_has_mine_rob
end

-- 航海记录是否提示
function MiningData:GetFightingBeenRobSea()
	return self.is_has_sea_rob
end

-- 挖矿，航海-有新的抢夺记录
function MiningData:SetSCFightingRobingNotify(protocol)
	if protocol.type == MINING_VIEW_TYPE.MINE then
		self:SetMineRecordClientList(protocol)
	elseif protocol.type == MINING_VIEW_TYPE.SEA then
		self:SetSeaRecordClientList(protocol)
	end
end

-- 挖矿记录
function MiningData:SetMineRecordClientList(protocol)
	local show_protocol = TableCopy(protocol)
	table.insert(self.mine_record_client_list, 1, show_protocol)
	local len = #self.mine_record_client_list or 0
	if len > 20 then
		table.remove(self.mine_record_client_list, len)
	end
	show_protocol = nil
end

-- 挖矿记录
function MiningData:GetMineRecordClientList()
	return self.mine_record_client_list
end

-- 航海记录
function MiningData:SetSeaRecordClientList(protocol)
	local show_protocol = TableCopy(protocol)
	table.insert(self.sea_record_client_list, 1, show_protocol)
	local len = #self.sea_record_client_list or 0
	if len > 20 then
		table.remove(self.sea_record_client_list, len)
	end
	show_protocol = nil
end

-- 航海记录
function MiningData:GetSeaRecordClientList()
	return self.sea_record_client_list
end

-- 名字颜色
function MiningData:GetMiningNameColor(type)
	local color = TEXT_COLOR.GREEN
	if type == nil then return color end

	if type == 0 then
		color = TEXT_COLOR.GREEN
	elseif type == 1 then
		color = TEXT_COLOR.BLUE
	elseif type == 2 then
		color = TEXT_COLOR.PURPLE
	elseif type == 3 then
		color = TEXT_COLOR.ORANGE
	end
	return color
end
