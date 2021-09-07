HappyBargainData = HappyBargainData or BaseClass()

function HappyBargainData:__init()
	if HappyBargainData.Instance then
		print_error("[HappyBargainData] Attempt to create singleton twice!")
		return
	end
	HappyBargainData.Instance = self
	self.rebate_act_type = 0
	self.rebate_draw_count = 0
	self.rebate_fetch_flags = 0
	self.rebate_server_is_change = false
	self.anim_state = true

	self.day_target = {}
	self.player_info_lsit = {
		rank_count = 0,
		rank_list = {},
	}

	self.danbi_reward_getnum = {}
	RemindManager.Instance:Register(RemindName.DayTarget, BindTool.Bind(self.DayTargetGetRemind, self))
	RemindManager.Instance:Register(RemindName.SingleCharge, BindTool.Bind(self.GetSinglChargeRemind, self))
	RemindManager.Instance:Register(RemindName.HappyLottery, BindTool.Bind(self.GetHappyLotteryRemind, self))
	RemindManager.Instance:Register(RemindName.RebateAct, BindTool.Bind(self.GetRebateActRedPoint, self))
end

function HappyBargainData:__delete()
	HappyBargainData.Instance = nil
	self.rebate_server_is_change = false
	RemindManager.Instance:UnRegister(RemindName.DayTarget)
	RemindManager.Instance:UnRegister(RemindName.SingleCharge)
	RemindManager.Instance:UnRegister(RemindName.HappyLottery)
	RemindManager.Instance:UnRegister(RemindName.RebateAct)
end

function HappyBargainData:SetHappyBargainDayTargetProtocols(protocol)
	self.day_target.has_fetch_flag = bit:d2b(protocol.has_fetch_flag)
	self.day_target.can_fetch_flag = bit:d2b(protocol.can_fetch_flag)
	self.day_target.task_achieve_count = protocol.task_achieve_count
end

function HappyBargainData:SetPersonRankListProtocols(protocol)
	self.player_info_lsit.rank_count = protocol.rank_count
	self.player_info_lsit.rank_list = protocol.rank_list
	AvatarManager.Instance:SetAvatarKey(protocol.rank_list.role_id, protocol.rank_list.avatar_key_big, protocol.rank_list.avatar_key_small)
end

function HappyBargainData:SetCrossRAChongzhiRankChongzhiInfo(protocol)
	self.total_chongzhi = protocol.total_chongzhi
end

function HappyBargainData:GetKuaFuRechargeRankConfig()
	return ConfigManager.Instance:GetAutoConfig("cross_randactivity_cfg_1_auto") or {}
end

function HappyBargainData:GetChongZhiRankCfg()
	local cross_randactivity_cfg = self:GetKuaFuRechargeRankConfig()
	if not self.chongzhi_rank then
		self.chongzhi_rank = ListToMapList(cross_randactivity_cfg.chongzhi_rank, "activity_day")
	end
	return self.chongzhi_rank	
end

function HappyBargainData:GetChongZhiRankInfo(open_day)
	if nil == open_day then
		return nil, nil, nil
	end
	local chongzhi_rank_cfg = self:GetChongZhiRankCfg()[open_day]
	local reward_list = {}
	local coset_list = {}
	local rank_list = {}
	if chongzhi_rank_cfg then
		for k, v in pairs(chongzhi_rank_cfg) do
			table.insert(reward_list, v.person_reward_item)
			table.insert(coset_list, v.need_total_chongzhi)
			table.insert(rank_list, v.rank)	
		end
	end
	return reward_list, coset_list, rank_list
end

function HappyBargainData:GetPersonRankListProtocols()
	return self.player_info_lsit
end

function HappyBargainData:GetCrossRAChongzhiRankChongzhiInfo()
	return self.total_chongzhi
end

function HappyBargainData:GetHappyActivityList()
	-- 开服活动排序
	local happy_activity_sort_index_list = {
		[1] = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_TARGET, -- 每日目标
		[2] = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_REWARD, -- 每日单笔充值
		[3] = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPY_LOTTERY, -- 欢乐抽
		[4] = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_REBATE_ACTIVITY, -- 寻宝返利
		[5] = ACTIVITY_TYPE.CROSS_RAND_ACTIVITY_TYPE_CHONGZHI_RANK, -- 跨服充值排行
	}
	return happy_activity_sort_index_list
end

function HappyBargainData:GetOpenActivityList()
	local temp_list = {}
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local activity, camp 
	for _, v in ipairs(self:GetHappyActivityList()) do
		activity = ActivityData.Instance:GetActivityConfig(v)
		if nil ~= activity and ActivityData.Instance:GetActivityIsOpen(v)then
			if (not (self:GetRebateOpenState(cur_day) == 0 and activity.act_id == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_REBATE_ACTIVITY)) and
			   (not (self:GetHappyLotteryOpenState(cur_day) == 0 and activity.act_id == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPY_LOTTERY)) then
				camp = TableCopy(activity)
				camp.activity_type = activity.act_id
				table.insert(temp_list, camp)
			end
		end
	end
	return temp_list
end

function HappyBargainData:GetPanelIndex(activity_type)
	local panel_index = 1
	for i,v in ipairs(self:GetHappyActivityList()) do
		if v == activity_type then
			panel_index = i
			return panel_index
		end
	end
	return panel_index
end

--获取活动剩余时间
function HappyBargainData:GetActEndTime(act_type)
	local act_status = ActivityData.Instance:GetActivityStatuByType(act_type)
	local server_time = TimeCtrl.Instance:GetServerTime()
	local act_last_time = act_status.end_time - server_time

	return act_last_time
end

function HappyBargainData:DayTargetGetCfg()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().consume_aim
	local list = {}

	for _, v in pairs(cfg) do
		if v.opengame_day == self:GetCurServerOpenServerDay() then
			table.insert(list, v)
		end
	end
	
	return list
end

function HappyBargainData:SortDayTargetGetCfg()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().consume_aim
	local flags = self.day_target.has_fetch_flag
	local target_count = self.day_target.task_achieve_count
	local list = {}

	if not cfg and not flags and not target_count then
		return list
	end
	local temp, fetch_reward_flag, count
	for _, v in ipairs(cfg) do
		if v.opengame_day == self:GetCurServerOpenServerDay() then
			fetch_reward_flag = (flags[32 - v.seq] and 1 == flags[32 - v.seq]) and 1 or 0
			temp = TableCopy(v)
			temp.fetch_reward_flag = fetch_reward_flag
			count = target_count[v.seq + 1] or 0
			temp.task_achieve_count = count < v.task_conditions and 1 or 0
			table.insert(list, temp)
		end
	end

	table.sort(list, SortTools.KeyLowerSorters("fetch_reward_flag", "task_achieve_count", "seq"))
	return list
end

function HappyBargainData:IsDayTargetGetProcess(seq, need_process)
	local count = 0
	if not self.day_target.task_achieve_count then
		return false, count
	end
	count = self.day_target.task_achieve_count[seq + 1] or 0
	if count >= need_process then
		return true ,count
	end
	return false ,count
end  

function HappyBargainData:GetCurServerOpenServerDay()
	local opengame_day = TimeCtrl.Instance:GetCurOpenServerDay()

	if opengame_day ~= nil then
		return opengame_day
	end

	return 8
end

function HappyBargainData:DayTargetGetRemind()
	local has_fetch_flag = self:DayTargetGetFlags()
	local can_fetch_flag = self:DayTargetGetCanFlags()

	if has_fetch_flag == nil and next(has_fetch_flag) == nil and can_fetch_flag == nil and next(can_fetch_flag) == nil then
		return 0
	end

	for k = 1, #has_fetch_flag do
		if has_fetch_flag[k] == 0 and can_fetch_flag[k] == 1 then
			return 1
		end
	end

	return 0
end

function HappyBargainData:DayTargetGetProcess()
	local process = {}

	for k = 1, #self:DayTargetGetCfg() do
		table.insert(process, self.day_target.task_achieve_count[k] or 0)
	end

	return process
end

function HappyBargainData:DayTargetGetFlags()
	local index = 32
	local flags = {}
	for k = 1, #self:DayTargetGetCfg() do
		table.insert(flags, self.day_target.has_fetch_flag[index] or 0)
		index = index - 1
	end
	
	return flags;
end

function HappyBargainData:DayTargetGetCanFlags()
	local index = 32
	local flags = {}
	for k = 1, #self:DayTargetGetCfg() do
		table.insert(flags, self.day_target.can_fetch_flag[index] or 0)
		index = index - 1
	end
	
	return flags;
end

--单笔大奖；
function HappyBargainData:SetSingleChargeInfo(protocol)
	local prize_times_list = protocol.prize_times_list
    local reward_flag_list = bit:d2b(protocol.prize_reward_flag)
    local times_run_out_list = bit:d2b(protocol.prize_reward_times_run_out)

	local vo = {}
	self.danbi_reward_getnum = {}
    for i,v in pairs(prize_times_list) do
    	vo = {}
    	vo.prize_times = v
    	vo.prize_reward_flag = reward_flag_list[33 - i]
    	vo.reward_run_out_flag = times_run_out_list[33 - i]
    	self.danbi_reward_getnum[i] = vo
    end
end

function HappyBargainData:GetSingleChargeInfo()
	return self.danbi_reward_getnum 
end

function HappyBargainData:GetSingleRewardinfo(type)
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().single_charge_prize
	local pass_day = ActivityData.Instance.GetActivityDays(type)
	local rand_t = {}
	
	for i,v in ipairs(cfg) do
		if v.activity_day == pass_day and v.opengame_day <= 7 then	
			table.insert(rand_t, v)
		end
	end
	return rand_t
end

function HappyBargainData:GetDrawResultLists()
	local spid = ServerActivityData.Instance:GetCurrentRandActivityConfig().single_charge_prize
	local agent_cfg = ConfigManager.Instance:GetAutoConfig("agent_adapt_auto").shield_accumulate_recharge
	local shield = 9999999
	for _, v in pairs(agent_cfg) do
		if spid == v.spid then
			shield = v.single_charge_prize
		end
	end
	return shield
end

function HappyBargainData:GetSinglChargeRemind()
	local is_red = 0
	if #self.danbi_reward_getnum > 0 then
		for i,v in ipairs(self.danbi_reward_getnum) do
			if v.reward_run_out_flag == 0 then
			    is_red = 1
		    end 
		end
	end
	return is_red
end

--------------------------------------欢乐抽---------------------------------------------
function HappyBargainData:GetHappyDrawCfg()
	if ConfigManager.Instance:GetAutoConfig("randactivityconfig_1_auto") then
		return ConfigManager.Instance:GetAutoConfig("randactivityconfig_1_auto").happy_draw
	end
end

function HappyBargainData:GetHappyDrawOtherCfg()
	if ConfigManager.Instance:GetAutoConfig("randactivityconfig_1_auto") then
		return ConfigManager.Instance:GetAutoConfig("randactivityconfig_1_auto").happy_draw_other
	end
end

function HappyBargainData:GetHappyLotteryCfg()
	if self:GetHappyDrawCfg() then
		return ListToMap(self:GetHappyDrawCfg(), "opengame_day","seq")
	end
end

function HappyBargainData:GetHappyLotteryOtherCfg()
	if self:GetHappyDrawOtherCfg() then
		return ListToMap(self:GetHappyDrawOtherCfg(), "opengame_day")
	end
end

function HappyBargainData:SetChestShopMode(mode)
	self.chest_shop_mode = mode 
end

function HappyBargainData:GetChestShopMode()
	return self.chest_shop_mode
end
-- 从协议设置抽奖结果
function HappyBargainData:SetDrawResultList(protocol)
	self.result_list = protocol.item_info_list                     
end

--获取抽奖结果
function HappyBargainData:GetDrawResultList()
	return self.result_list                  
end

--从协议设置珍稀榜列表
function HappyBargainData:SetDrawRareRankInfo(protocol)
	self.record_list = protocol.rare_item_list                     
end

--获取抽奖记录列表
function HappyBargainData:GetRecordInfo()
	return self.record_list or {}                    
end

-- 根据天数和抽奖次数获取消耗道具信息
function HappyBargainData:GetConsumeInfo(day,times) 
	local other_cfg = self:GetHappyLotteryOtherCfg()
	if nil == other_cfg then return end
	local info = {}
	if other_cfg[day] then
		info = other_cfg[day].one_draw_consume_item
		if times == 10 then 
			info = other_cfg[day].ten_draw_consume_item
		end
	end
	return info
end

-- 根据天数获取预览物品列表
function HappyBargainData:GetPreviewItems(day)
	if self:GetHappyLotteryCfg() then
		return self:GetHappyLotteryCfg()[day]
	end
end

function HappyBargainData:SetAniState(value)
	self.anim_state = value
end

function HappyBargainData:GetAniState()
	return self.anim_state
end

function HappyBargainData:SetHappyLotteryRemind(value)
	self.happy_lottery_remind = value
end

function HappyBargainData:GetHappyLotteryRemind()
	return self.happy_lottery_remind and 1 or 0
end

function HappyBargainData:GetHappyLotteryOpenState(day)
    local state = 0
    if day == nil then
  		return state
    end

    local cfg = self:GetHappyLotteryOtherCfg()
    if cfg and cfg[day] then
    	state = cfg[day].is_show
    end
    return state
end

------------------------------------------------------------------
-- 返利活动协议
function HappyBargainData:SetHappyBargainRebateProtocols(protocol)
	self.rebate_act_type = protocol.hunting_type
	self.rebate_draw_count = protocol.hunting_count
	self.rebate_fetch_flags = protocol.fetch_flags
	self.rebate_server_is_change = true
end

function HappyBargainData:SetHappyBargainProtocolsIsChange(bool)
	self.rebate_server_is_change = bool
end

function HappyBargainData:GetHappyBargainProtocolsIsChange()
	return self.rebate_server_is_change
end

local last_rebate_day = 0
function HappyBargainData:GetRebateActCfgByDay()
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().hunting_reward
	if self.rebate_act_cfg == nil or (last_rebate_day ~= cur_day) then
		self.rebate_act_cfg = {}
		last_rebate_day = cur_day
		if cfg then
			for _, v in pairs(cfg) do
				if (v.activie_days == cur_day) then
					table.insert(self.rebate_act_cfg, v)
				end
			end
		end
	end
	return self.rebate_act_cfg
end

-- 返利活动cfg排序
-- 按 可领取0、未达成1、已领取2 和 要求次数 排序 
function HappyBargainData:GetRebateActCfgBySort()
	local fetch_reward_flag = bit:d2b(self.rebate_fetch_flags)
	local config = self:GetRebateActCfgByDay()
	local list = {}
	local num = 0
	for k,v in ipairs(config) do
		local reward_has_fetch_flag = 1
		if self.rebate_draw_count >= v.require_hunting_count then
			reward_has_fetch_flag = (fetch_reward_flag[32 - v.seq] and 1 == fetch_reward_flag[32 - v.seq]) and 2 or 0
		end
		local data = TableCopy(v)
		data.reward_has_fetch_flag = reward_has_fetch_flag
		num = num + 1
		table.insert(list, data)
	end
	table.sort(list, SortTools.KeyLowerSorter("reward_has_fetch_flag", "require_hunting_count"))
	return list,num
end

function HappyBargainData:GetRebateActType()
	return self.rebate_act_type
end

function HappyBargainData:GetRebateActDrawCount()
	return self.rebate_draw_count
end

function HappyBargainData:GetRebateActRedPoint()
	local list , num = self:GetRebateActCfgBySort()
	for i = 1, num do
		if (next(list) ~= nil) and (list[i].reward_has_fetch_flag == 0) then
			return 1
		end
	end
	return 0
end

function HappyBargainData:GetRebateActStayDay()
	local list = self:GetRebateActCfgByDay()
	local stay_day = (next(list) ~= nil) and list[1].duration or 1
	return stay_day
end

function HappyBargainData:GetDrawActPanel()
	local panel_list = {}
	if next(self:GetRebateActCfgByDay()) ~= nil then
		panel_list = Split(self:GetRebateActCfgByDay()[1].open_pannal, "#") 
	end
	return panel_list
end

function HappyBargainData:GetRebateOpenState(day)
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().hunting_reward_other
	for k,v in ipairs(cfg) do
		if v.opengame_day == day then
			return v.is_show
		end
	end
	return 0
end

-------------------------------------------------------------------


