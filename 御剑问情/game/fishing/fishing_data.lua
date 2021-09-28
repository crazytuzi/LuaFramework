CrossFishingData = CrossFishingData or BaseClass()

function CrossFishingData:__init()
	if CrossFishingData.Instance ~= nil then
		print_error("[CrossFishingData] attempt to create singleton twice!")
		return
	end
	CrossFishingData.Instance = self

	-- 钓鱼配置
	self.fishing_cfg = nil					-- 请调用 GetFishingCfg() 来使用
	self.fishing_other_cfg = nil			-- 请调用 GetFishingOtherCfg() 来使用
	self.fishing_combination_cfg = nil		-- 请调用 GetFishingCombinationCfg() 来使用
	self.fishing_fish_cfg = nil				-- 请调用 GetFishingFishCfg() 来使用
	self.fish_bait_cfg = nil				-- 请调用 GetFishingFishBaitCfg() 来使用
	self.score_reward_cfg = nil				-- 请调用 GetFishingScoreRewardCfg() 来使用
	self.fishing_location_cfg = nil 		-- 请调用 GetFishingLocationCfg() 来使用
	self.creel_time_cfg = nil 				-- 请调用 GetFishingCreelTimeCfg() 来使用
	self.ratio_cfg = nil

	self.user_info = {						-- 钓鱼用户信息
		fishing_status = 0,					-- 钓鱼状态
	}
	self.check_result = {					-- 钓鱼检查结果
		param1 = 0,
		param2 = 0,
		param3 = 0,
	}
	self.cofirm_result = {					-- 钓鱼确认结果
		confirm_type = 0,
		short_param_1 = 0,
		param_2 = 0,
		param_3 = 0
	}
	self.gear_use_result = {}				-- 法宝使用结果
	self.fishing_owner_uid = 0				-- 拥有者role_id
	self.team_member_info = {}				-- 队伍信息
	self.fish_info = {}						-- 钓鱼信息
	self.rand_user_info = {}				-- 钓鱼随机展示角色
	self.steal_result = {}					-- 钓鱼偷窃结果
	self.fish_brocast = {}					-- 钓鱼广播
	self.score_rank_list = {				-- 钓鱼积分榜信息
		fish_rank_count = 0,
		fish_rank_list = {},
		self_rank = -1,
		self_rank_item = {}
	}

	self.fishing_score = {					-- 钓鱼积分信息
		cur_score_stage = 0,
		fishing_score = 0
	}


	self.fish_bait_count = {
		bait0 = 0,
		bait1 = 0,
		bait2 = 0,
	}  										--鱼饵数量

	self.steal_succ = false
	
	self.fishing_goal = {}					-- 钓鱼的目标点

	self.is_auto_fishing = 0				-- 是否自动钓鱼 0不自动 1自动
	self.is_auto_gofishing = 0 				-- 是否自动寻路 0不是 1是

	self.creel_view_time = 0				-- 鱼篓是否刷新自动关闭时间
end

function CrossFishingData:__delete()
	CrossFishingData.Instance = nil

end

function CrossFishingData:SetFishingUserInfo(protocol)
	self.user_info.uuid = protocol.uuid
	self.user_info.role_id = protocol.role_id																		-- 主角跨服id
	self.user_info.plat_id = protocol.plat_id
	self.user_info.fishing_status = protocol.fishing_status											-- 钓鱼状态
	self.user_info.special_status_flag = protocol.special_status_flag								-- 特殊状态标记
	self.user_info.least_count_cfg_index = protocol.least_count_cfg_index							-- 双倍积分配置索引
	self.user_info.is_fish_event = protocol.is_fish_event											-- 是否鱼上钩
	self.user_info.is_consumed_auto_fishing = protocol.is_consumed_auto_fishing						-- 是否消耗过元宝自动钓鱼
	self.user_info.auto_pull_timestamp = protocol.auto_pull_timestamp								-- 自动拉杆时间戳，没有触发事件则为0
	self.user_info.special_status_oil_end_timestamp = protocol.special_status_oil_end_timestamp		-- 特殊状态香油结束时间戳
	self.user_info.fish_num_list = protocol.fish_num_list											-- 当前钓上的各类鱼的数量
	self.user_info.gear_num_list = protocol.gear_num_list											-- 当前拥有的法宝数量
	self.user_info.steal_fish_count = protocol.steal_fish_count										-- 偷鱼次数
	self.user_info.be_stealed_fish_count = protocol.be_stealed_fish_count							-- 被偷鱼次数
	self.user_info.buy_steal_count = protocol.buy_steal_count										-- 购买偷鱼次数
	self.user_info.news_count = protocol.news_count													-- 日志数量
	self.user_info.news_list = protocol.news_list													-- 日志
end

function CrossFishingData:GetFishingUserInfo()
	return self.user_info or {}
end

-- 保存检查事件结果信息
function CrossFishingData:SetFishingCheckEventResult(protocol)
	self.check_result.event_type = protocol.event_type
	self.check_result.param1 = protocol.param1
	self.check_result.param2 = protocol.param2
	self.check_result.param3 = protocol.param3
end

function CrossFishingData:GetFishingCheckEventResult()
	return self.check_result
end

function CrossFishingData:SetFishingConfirmResult(protocol)
	self.cofirm_result.confirm_type = protocol.confirm_type
	self.cofirm_result.short_param_1 = protocol.short_param_1
	self.cofirm_result.param_2 = protocol.param_2
	self.cofirm_result.param_3 = protocol.param_3
end

function CrossFishingData:GetFishingConfirmResult()
	return self.cofirm_result
end

-- 保存法宝使用结果信息
function CrossFishingData:SetFishingGearUseResult(protocol)
	self.gear_use_result.gear_type = protocol.gear_type												-- 使用法宝类型
	self.gear_use_result.param1 = protocol.param1													-- 获得鱼的类型
	self.gear_use_result.param2 = protocol.param2													-- 获得鱼的数量
	self.gear_use_result.param3 = protocol.param3
end

function CrossFishingData:GetFishingGearUseResult()
	return self.gear_use_result
end

function CrossFishingData:SetFishingEventBigFish(protocol)
	self.fishing_owner_uid = protocol.owner_uid														-- 拥有者role_id
end

function CrossFishingData:GetFishingEventBigFish()
	return self.fishing_owner_uid
end

function CrossFishingData:SetFishingTeamMemberInfo(protocol)
	self.team_member_info.member_count = protocol.member_count										-- 队伍人数

	self.team_member_info.member_uid_1 = protocol.member_uid_1										-- 队伍玩家1 role_id
	self.team_member_info.least_count_cfg_index_1 = protocol.least_count_cfg_index_1				-- 玩家1的双倍积分配置下标
	self.team_member_info.fish_num_list_1 = protocol.fish_num_list_1								-- 玩家1的鱼数量，以鱼类型左右数组下标

	self.team_member_info.member_uid_2 = protocol.member_uid_2										-- 队伍玩家2 role_id
	self.team_member_info.least_count_cfg_index_2 = protocol.least_count_cfg_index_2				-- 玩家2的双倍积分配置下标
	self.team_member_info.fish_num_list_2 = protocol.fish_num_list_2								-- 玩家2的鱼数量，以鱼类型左右数组下标

	self.team_member_info.member_uid_3 = protocol.member_uid_3										-- 队伍玩家3 role_id
	self.team_member_info.least_count_cfg_index_3 = protocol.least_count_cfg_index_3				-- 玩家3的双倍积分配置下标
	self.team_member_info.fish_num_list_3 = protocol.fish_num_list_3								-- 玩家3的鱼数量，以鱼类型左右数组下标

end

function CrossFishingData:GetFishingEventBigFish()
	return self.team_member_info
end

function CrossFishingData:SetFishingFishInfo(protocol)
	self.fish_info.uid = protocol.uid																-- 玩家role_id
	self.fish_info.least_count_cfg_index = protocol.least_count_cfg_index							-- 双倍积分配置下标
	self.fish_info.fish_num_list = protocol.fish_num_list											-- 鱼数量，以鱼类型左右数组下标

end

function CrossFishingData:GetFishingFishInfo()
	return self.fish_info
end

function CrossFishingData:SetFishingRandUserInfo(protocol)
	self.rand_user_info.user_count = protocol.user_count											-- 玩家个数
	self.rand_user_info.user_info_list = protocol.user_info_list									-- 鱼数量，以鱼类型左右数组下标
end

function CrossFishingData:GetFishingFishInfo()
	return self.rand_user_info
end

function CrossFishingData:SetFishingStealResult(protocol)
	self.steal_result.is_succ = protocol.is_succ													-- 结果
	self.steal_result.fish_type = protocol.fish_type												-- 获得鱼类型
	self.steal_result.fish_num = protocol.fish_num													-- 获得鱼数量
end

function CrossFishingData:GetFishingStealResult()
	return self.steal_result
end

function CrossFishingData:SetFishingGetFishBrocast(protocol)
	self.fish_brocast.uid = protocol.uid															-- 获得鱼的玩家role_id
	self.fish_brocast.get_fish_type = protocol.get_fish_type										-- 获得鱼类型
end

function CrossFishingData:GetFishingScore()
	return self.fish_brocast
end

function CrossFishingData:SetCrossFishingScoreRankList(protocol)
	self.score_rank_list.fish_rank_count = protocol.fish_rank_count									-- 排行榜个数
	self.score_rank_list.fish_rank_list = protocol.fish_rank_list

	-- self.score_rank_list.self_rank = protocol.self_rank												-- 自己的排行名次，未上榜为-1
	-- self.score_rank_list.self_rank_item = protocol.self_rank_item									-- 自己的信息
end

function CrossFishingData:GetCrossFishingScoreRankList()
	return self.score_rank_list
end

-- 钓鱼积分信息
function CrossFishingData:SetFishingScoreStageInfo(protocol)
	self.fishing_score.cur_score_stage = protocol.cur_score_stage									-- 当前阶段
	self.fishing_score.fishing_score = protocol.fishing_score										-- 当前钓鱼积分
end

function CrossFishingData:GetFishingScoreStageInfo()
	return self.fishing_score
end
----------------------------------------------------------------------------------
-- 读配置区段
----------------------------------------------------------------------------------
function CrossFishingData:GetFishingCfg()
	if not self.fishing_cfg then
		self.fishing_cfg = ConfigManager.Instance:GetAutoConfig("cross_fishing_auto") or {}
	end
	return self.fishing_cfg
end

-- 其他配置
function CrossFishingData:GetFishingOtherCfg()
	if not self.fishing_other_cfg then
		self.fishing_other_cfg = self:GetFishingCfg().other[1] or {}
	end
	return self.fishing_other_cfg
end

-- 组合配置
function CrossFishingData:GetFishingCombinationCfg()
	if not self.fishing_combination_cfg then
		self.fishing_combination_cfg = self:GetFishingCfg().combination
	end
	return self.fishing_combination_cfg
end

-- 根据下表获取组合的配置
function CrossFishingData:GetFishingCombinationCfgByIndex(index)
	local combination_cfg = self:GetFishingCombinationCfg()
	return combination_cfg[index]
end

-- 鱼配置
function CrossFishingData:GetFishingFishCfg()
	if not self.fishing_fish_cfg then
		-- self.fishing_fish_cfg = self:GetFishingCfg().fish or {}
		self.fishing_fish_cfg = ListToMap(self:GetFishingCfg().fish, "type") or {}
	end
	return self.fishing_fish_cfg
end

-- 根据鱼的类型获取鱼的配置
function CrossFishingData:GetFishingFishCfgByType(fish_type)

	local fish = self:GetFishingFishCfg()
	if fish[fish_type] then
		return fish[fish_type]
	end
	return false
	-- for k,v in pairs(self:GetFishingFishCfg()) do
	-- 	if v.type == fish_type then
	-- 		return v
	-- 	end
	-- end
end

-- 鱼饵配置
function CrossFishingData:GetFishingFishBaitCfg()
	if not self.fish_bait_cfg then
		self.fish_bait_cfg = self:GetFishingCfg().fish_bait or {}
	end
	return self.fish_bait_cfg
end

-- 根据鱼饵的类型获取鱼饵的配置
function CrossFishingData:GetFishingFishBaitCfgByType(fish_type)
	for k,v in pairs(self:GetFishingFishBaitCfg()) do
		if v.type == fish_type then
			return v
		end
	end
end

-- 积分奖励配置
function CrossFishingData:GetFishingScoreRewardCfg()
	if not self.score_reward_cfg then
		self.score_reward_cfg = self:GetFishingCfg().score_reward or {}
	end
	return self.score_reward_cfg
end

-- 根据积分的阶段获取积分奖励的配置
function CrossFishingData:GetFishingScoreRewardCfgByStage(stage)
	for k,v in pairs(self:GetFishingScoreRewardCfg()) do
		if v.stage == stage then
			return v
		end
	end
end

-- 获得钓鱼点的配置
function CrossFishingData:GetFishinglocationCfg()
	if not self.fishing_location_cfg then
		self.fishing_location_cfg = self:GetFishingCfg().location or {}
	end
	return self.fishing_location_cfg
end

-- 获得鱼篓倒计时的配置
function CrossFishingData:GetFishingCreelTimeCfg()
	if not self.creel_time_cfg then
		self.creel_time_cfg = self:GetFishingOtherCfg().creeltime or {}
	end
	return self.creel_time_cfg
end

function CrossFishingData:GetFishingRatioCfg()
	if not self.ratio_cfg  then
		self.ratio_cfg  = self:GetFishingCfg().ratio or {}
	end
	return self.ratio_cfg 
end

----------------------------------------------------------------------------------
-- 其他逻辑
----------------------------------------------------------------------------------

function CrossFishingData:SetAutoFishing(param)
	self.is_auto_fishing = param
end

function CrossFishingData:GetAutoFishing()
	return self.is_auto_fishing
end

function CrossFishingData:SetAutoGoFishing(param)
	self.is_auto_gofishing = param
end

function CrossFishingData:GetAutoGoFishing()
	return self.is_auto_gofishing
end

function CrossFishingData:SetBaitFishing(bait, count)					--设置鱼饵（0普通鱼饵 1特级鱼饵 2黄金鱼饵）
	self.fish_bait_count[bait + 1] = count
end

function CrossFishingData:GetBaitFishing(bait)
	return self.fish_bait_count[bait + 1]
end

function CrossFishingData:BaitUpdate()
	for i = 0, #self.fish_bait_count do
		local fish_bait_cfg = self:GetFishingFishBaitCfgByType(i)
		if fish_bait_cfg then
		self.fish_bait_count[i + 1] = ItemData.Instance:GetItemNumInBagById(fish_bait_cfg.item_id)
		end
	end
end

function CrossFishingData:SetCreelViewtime(param)
	self.creel_view_time = param
end

function CrossFishingData:GetCreelViewtime()
	return self.creel_view_time
end

function CrossFishingData:SetFishingGoal(id, goal)
	self.fishing_goal.id = goal
end

function CrossFishingData:GetFishingGoal(id)
	if self.fishing_goal.id then
		return self.fishing_goal.id
	end
	return false
end

function CrossFishingData:GetFishingScene()
	local scene = Scene.Instance:GetSceneId()
	local fishing_cfg = self:GetFishingOtherCfg()
	if scene == fishing_cfg.sceneid then
		return true
	end
	return false
end

-- 获取自己排行榜信息
function CrossFishingData:GetMyRankInfo()
	local my_rank_data = {}
	local score_rank_list = self:GetCrossFishingScoreRankList().fish_rank_list
	local role_id = self:GetFishingUserInfo().role_id
	local plat_id = self:GetFishingUserInfo().plat_id

	for k,v in pairs(score_rank_list) do
		if v.role_id == role_id and v.plat_id == plat_id then
			my_rank_data = v
			return my_rank_data
		end
	end
	return my_rank_data
end

function CrossFishingData:IsFishing(pos_x, pos_y)
	local data = self:GetFishinglocationCfg()

	if nil == data then
		return false
	end

	for k, v in pairs(data) do
		if v.x == pos_x and v.y == pos_y then
			return true
		end
	end

	return false
end

function CrossFishingData:IsCanExchange()
	-- now > cfg true
	local cfg = self:GetFishingCombinationCfg()
	if nil == cfg then
		return false
	end

	local combination_cfg = TableCopy(self:GetFishingCombinationCfg())
	table.insert(combination_cfg, 1, combination_cfg[0])
	combination_cfg[0] = nil
	for i = 1, GetListNum(cfg) do
		local temp = combination_cfg[i]
		if nil ~= temp then
			local can_reward = true
			for k = 1, GameEnum.FISHING_FISH_TYPE_MAX_COUNT - 1 do
				local num = self:GetFishingUserInfo().fish_num_list[k + 1]
				local str_type = "fish_type_" .. k

				if (temp[str_type] and num < temp[str_type]) then
					can_reward = false
				end
			end
			if true == can_reward then
				return true
			end
		end
	end

	return false
end

function CrossFishingData:GetRewardWeight()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local ratio = self:GetFishingRatioCfg()
	if nil == ratio then
		return 1
	end

	for k,v in pairs(ratio) do
		if main_vo.level >= v.min_level and main_vo.level < v.max_level then
			return v.level_ratio
		end
	end
	
	return 0
end

function CrossFishingData:SetSteatStatus(is_succ)
	self.steal_succ = is_succ
end

function CrossFishingData:GetSteatStatus()
	return self.steal_succ
end

--通过X,Y的和值查找最近的点 ，以后可以改成 x^2 + y^2 查找
function CrossFishingData:FindNearPosIndex()
	local fishing_location_cfg = self:GetFishinglocationCfg()

	local main_role = Scene.Instance:GetMainRole()
	local pos_x, pos_y = main_role:GetLogicPos()

	local is_one = true
	local index = 1
	local direction = 0

	for k, v in pairs(fishing_location_cfg) do
		if is_one then
			direction = math.abs(pos_x - v.x) + math.abs(pos_y - v.y)
			index = k
			is_one = false
		else
			local temp_direction = math.abs(pos_x - v.x) + math.abs(pos_y - v.y)
			if direction > temp_direction then
				index = k
				direction = temp_direction
			end
		end
	end

	return index
end