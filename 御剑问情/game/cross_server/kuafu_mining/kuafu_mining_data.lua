KuaFuMiningData = KuaFuMiningData or BaseClass()

KuaFuMiningData.GatherStatus = {
	can_gather = 0, 					-- 没人采集
	in_gather = 1,						-- 被人采集中
}

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

	self.pos_list = {}					--
	self.item_list = {} 				--被抢物品列表
	self.obtain_item = {} 				--获得的物品
	self.mining_rank_info = {} 			--排行榜信息

	self.result_type = 0 				--获得的物品类型
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

	if self.buff_count_down then
		CountDown.Instance:RemoveCountDown(self.buff_count_down)
		self.buff_count_down = nil
	end
end

function KuaFuMiningData:SetMiningRoleInfo(protocol)
	self.mining_role_info.role_id = protocol.role_id
	self.mining_role_info.plat_id = protocol.plat_id
	self.mining_role_info.uuid = protocol.uuid													--玩家唯一ID
	self.mining_role_info.name = protocol.name													--玩家名字
	self.mining_role_info.status = protocol.status												--玩家状态
	self.mining_role_info.combo_times = protocol.combo_times									--连击次数
	self.mining_role_info.max_combo_times = protocol.max_combo_times							--最大连击次数
	self.mining_role_info.used_mining_times = protocol.used_mining_times						--已经挖矿次数
	self.mining_role_info.add_mining_times = protocol.add_mining_times							--增加挖矿次数
	self.mining_role_info.score = protocol.score												--玩家积分
	self.mining_role_info.start_mining_timestamp = protocol.start_mining_timestamp				--玩家开始挖矿时间戳
	self.mining_role_info.enter_scene_timestamp = protocol.enter_scene_timestamp				--玩家进入场景时间戳
	self.mining_role_info.hit_area_times_list = protocol.hit_area_times_list					--玩家挖中各区域次数列表（以挖矿类型为下标）
	self.mining_role_info.mine_num_list = protocol.mine_num_list								--矿石个数列表（以矿石类型为下标）
	self.mining_role_info.buy_buff_times = protocol.buy_buff_times 								--buff购买次数
	self.mining_role_info.buff_end_time = protocol.buff_end_time     							--buff结束时间
	self.mining_role_info.use_skill_times = protocol.use_skill_times     						--技能已使用次数
	self.mining_role_info.next_skill_perfrom_timestamp = protocol.next_skill_perfrom_timestamp 	--下一次技能可使用时间

	-- local now_time = TimeCtrl.Instance:GetServerTime()
	-- local seconds = math.floor(self.buff_end_time - now_time)
	-- if seconds >= 0 then
	-- 	local main_role = Scene.Instance:GetMainRole()
	-- 	main_role:ChangeKuaFuMiningWuDiGather(1)
	-- end
	self:IsShowTitle(protocol.buff_end_time)
	local main_role = Scene.Instance:GetMainRole()
	main_role:ChangeKuaFuMiningWuDiGather()
	self:SetPackageEffectState()
end

-- 是否是托管状态
function KuaFuMiningData:GetMiningIsAuto()
	return self.mining_role_info.status == SPECIAL_CROSS_MINING_ROLE_STATUS.SPECIAL_CROSS_MINING_ROLE_STATUS_AUTO_MINING
end

function KuaFuMiningData:GetMiningRoleInfo()
	return self.mining_role_info
end

function KuaFuMiningData:SetMiningRankInfo(protocol)
	local rank_need_num = 10
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

--设置采集物状态
function KuaFuMiningData:SetGatherStatus(pos_x, pos_y, status)
 	for k,v in pairs(self.pos_list) do
 		if pos_x == v.x and pos_y == v.y then
 			self.pos_list[k].gather_status = status
 			return
 		end
 	end
end

function KuaFuMiningData:SetMiningGatherPosInfo(protocol)
	self.pos_list = protocol.pos_list												--采集物信息
	for k,v in pairs(self.pos_list) do
		self.pos_list[k].gather_status = KuaFuMiningData.GatherStatus.can_gather 	--默认该位置的采集物未被采集
	end
end

--采集物坐标列表
function KuaFuMiningData:GetMiningGatherPosInfo()
	return self.pos_list
end

--设置获得的物品
function KuaFuMiningData:SetMiningResultInfo(protocol)
	self.result_type = protocol.result_type
	local param_1, param_2 ,param_3 = protocol.param_1, protocol.param_2, protocol.param_3

	self.obtain_item = {item_id=param_1, num=param_2, is_bind=param_3, mining_area = protocol.mining_area}
end

--得到获得的物品
function KuaFuMiningData:GetMiningObtainItem()
	return self.obtain_item
end

function KuaFuMiningData:GetMiningResuleType()
	return self.result_type
end

--设置被抢信息
function KuaFuMiningData:SetMiningBeStealedInfo(protocol)
	self.item_list = protocol.item_list
end

--获得被抢信息
function KuaFuMiningData:GetMiningBeStealedInfo()
	return self.item_list
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

function KuaFuMiningData:GetMiningGatherCfg()
	if not self.gather_cfg then
		self.gather_cfg = self:GetMiningCfg().gather_cfg
	end
	return self.gather_cfg
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

--各区域对应积分配置
function KuaFuMiningData:GetAreaScoreCfg()
	if not self.area_score_cfg then
		self.area_score_cfg = self:GetMiningCfg().area_score_cfg
	end
	return self.area_score_cfg
end

--根据区域获得对应的区分
function KuaFuMiningData:GetAreaScoreByArea(area_index)
	local area_score_cfg = self:GetAreaScoreCfg()
	for k,v in pairs(area_score_cfg) do
		if v.area_index == area_index then
			return v.area_score
		end
	end
	return 0
end

--奖励配置
function KuaFuMiningData:GetScoreRewardCfg()
	if not self.score_reward_cfg then
		self.score_reward_cfg = self:GetMiningCfg().score_reward
	end
	return self.score_reward_cfg
end

--根据积分获得对应奖励配置
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

--根据积分获得奖励物品数据，包括经验
function KuaFuMiningData:GetScoreRewardList(need_score)
	local reward_cfg = self:GetScoreReward(need_score)					--积分对应奖励配置
	local reward_item_list = TableCopy(reward_cfg.reward_item) 			--奖励物品列表
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local exp = CommonDataManager.GetExpNumber(reward_cfg.exp or 0, main_vo.level) 	--计算经验
	table.insert(reward_item_list, {item_id = ResPath.CurrencyToIconId.exp or 0, num = exp, is_bind = 0})
	return reward_item_list
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

function KuaFuMiningData:GetMinDistancePosList(pos_list)
	pos_list = pos_list or self:GetMiningGatherPosInfo()
	--排除正在被采集的采集物
	local cut_is_gather_list = {}
	if not next(pos_list) then return end
	for k,v in pairs(pos_list) do 			
		if v.gather_status == KuaFuMiningData.GatherStatus.can_gather then
			table.insert(cut_is_gather_list, v)
		end
	end

	--按照主角与采集物的距离进行排序
	local new_pos_list = {}
	if not next(cut_is_gather_list) then return end
	local x, y = Scene.Instance:GetMainRole():GetLogicPos()
	local target_x, target_y = 0, 0

	for k, v in pairs(cut_is_gather_list) do
		target_x, target_y = v.x, v.y
		v.dis = GameMath.GetDistance(x, y, target_x, target_y, false)
		table.insert(new_pos_list, v)
	end

	if not next(new_pos_list) then return end

	SortTools.SortAsc(new_pos_list, "dis")
	return new_pos_list
end

--购买buff所需元宝
function KuaFuMiningData:GetBuffBuyGold()
	return self:GetMiningOtherCfg().buy_buff_cost
end

--buff持续时间
function KuaFuMiningData:GetBuffDurationTime()
	return self:GetMiningOtherCfg().buff_duration_time
end

--获得技能冷却时间
function KuaFuMiningData:GetSkillColdDown()
	return self:GetMiningOtherCfg().skill_cd
end

--获得技能可使用的总次数
function KuaFuMiningData:GetSkillTotalTimes()
	return self:GetMiningOtherCfg().skill_limit_times or 0
end

--技能攻击范围
function KuaFuMiningData:GetSkillDistance()
	return self:GetMiningOtherCfg().skill_distance or 15
end

--盗贼气泡框体文字内容
function KuaFuMiningData:GetBanditText()
	return self:GetMiningOtherCfg().bandit_text or ""
end

--判断是否属于跨服挖矿的矿石采集物ID
function KuaFuMiningData:IsMiningGather(gather_id)
	local gather_cfg = self:GetMiningGatherCfg()
	for k,v in pairs(gather_cfg) do
		if v.gather_id == gather_id then
			return true
		end
	end
	return false
end

--判断是否属于跨服挖矿的双倍矿
function KuaFuMiningData:IsMiningDoubleGather(gather_id)
	local gather_cfg = self:GetMiningGatherCfg()
  	for k,v in pairs(gather_cfg) do
  		if v.gather_id == gather_id then
  			if v.extra_reward_times ~= 0 then
  				return true
  			end
  		end
  	end
  	return false
end


function KuaFuMiningData:IsShowTitle(time)
	if nil == time then
		time = 0
	end

	local now_time = TimeCtrl.Instance:GetServerTime()
	local seconds = math.floor(time - now_time)
	if self.buff_count_down then
		CountDown.Instance:RemoveCountDown(self.buff_count_down)
		self.buff_count_down = nil
	end
	self.buff_count_down = CountDown.Instance:AddCountDown(seconds, 1, BindTool.Bind(self.TitleBuffTimeCountDown, self))
end

function KuaFuMiningData:TitleBuffTimeCountDown(elapse_time, total_time)
	local diff_timer = total_time - elapse_time
	if diff_timer <= 0 then
		local main_role = Scene.Instance:GetMainRole()
		main_role:ChangeKuaFuMiningWuDiGather(0)
		if self.buff_count_down then
			CountDown.Instance:RemoveCountDown(self.buff_count_down)
			self.buff_count_down = nil
		end
	end
end

--获取无敌采集Buff结束时间
function KuaFuMiningData:GetGatherBuffEndTime()
	return self:GetMiningRoleInfo().buff_end_time or 0
end

--获取无敌采集buff剩余时间
function KuaFuMiningData:GetGatherBuffRemainTime()
	local  remain_time = math.floor(self:GetGatherBuffEndTime() - TimeCtrl.Instance:GetServerTime())
	if remain_time > 0 then
		return remain_time
	end
	return 0
end

--获得技能剩余使用次数
function KuaFuMiningData:GetSkillRemainTimes()
	local total_times = self:GetSkillTotalTimes() 							--技能可使用总次数
	local use_skill_times = self:GetMiningRoleInfo().use_skill_times or 0 	--技能已使用次数
	local remain_times =  total_times - use_skill_times 					--技能剩余使用次数
	if remain_times >= 0 then
		return remain_times
	end
	return 0
end

--获得下一次技能可使用时间
function KuaFuMiningData:GetNextSkillPerfromTimestamp()
	return self:GetMiningRoleInfo().next_skill_perfrom_timestamp or 0
end

--获得技能当前冷却时间
function KuaFuMiningData:GetSkillRemainColdDown()
	local next_use_time = self:GetNextSkillPerfromTimestamp()
	local cur_time = TimeCtrl.Instance:GetServerTime()
	local remain_time =  math.floor(next_use_time - cur_time)
	if remain_time > 0 then
		return remain_time
	end
	return 0
end

--设置矿包特效
function KuaFuMiningData:SetPackageEffectState()
	local is_show = self:GetGiftPanelRedPoint()
	KuaFuMiningCtrl.Instance:SwitchPackageEffectState(is_show)
end

--得到矿包红点是否显示
function KuaFuMiningData:GetGiftPanelRedPoint()
  	local mining_info = self:GetMiningRoleInfo()
	local combination_cfg = KuaFuMiningData.Instance:GetMiningExchangeCfg()
	if not mining_info or not combination_cfg then
		return
	end
	local is_show = false
	for i,v in ipairs(combination_cfg) do
		local cur_type_enough = true
		for j = 1, 5 do
			local need_num = v["mine_type_" .. (j - 1)]
			local my_num = mining_info.mine_num_list[j]

			if my_num and need_num then
				if my_num < need_num then
					cur_type_enough = false
				end
			end
		end
		if cur_type_enough == true then
			is_show = true
		end
	end
	return is_show
end

-- 获得兑换矿石面板每个按钮的红点
function KuaFuMiningData:GetGiftPanelBtnRedPointBySeq(seq)
	local mining_info = self:GetMiningRoleInfo()
	local combination_cfg = KuaFuMiningData.Instance:GetMiningExchangeCfg()
	if not next(mining_info.mine_num_list) or not combination_cfg then
		return false
	end
	local cur_type_enough = true
	for i,v in ipairs(combination_cfg) do
		if v.seq == seq then
			--判断每种兑换所需矿石是否足够
			for j = 1, 5 do
				if v["mine_type_" .. (j - 1)] then
					local need_num = v["mine_type_" .. (j - 1)]   	--所需矿石数量
					local my_num = mining_info.mine_num_list[j]		--已有矿石数目
					if my_num and need_num then
						if my_num < need_num then
							cur_type_enough = false
						end
					end
				end
			end
			break
		end
	end
	return cur_type_enough
end