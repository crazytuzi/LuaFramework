HefuActivityData = HefuActivityData or BaseClass()

CSActState = {
	NO_START = 0,			-- 未开始
	OPEN = 1,				-- 进行中
	FINISH = 2,				-- 结束
}

function HefuActivityData:__init()
	if HefuActivityData.Instance ~= nil then
		ErrorLog("[HefuActivityData] attempt to create singleton twice!")
		return
	end
	HefuActivityData.Instance = self
	self.open_act_id_list = {
	}
	self.combine_person_info = {}
	self.combine_server_data = {}
	self.boss_info = {}
	self.refresh_state = 0
	self.combine_login_reward_info = {}
	--RemindManager.Instance:Register(RemindName.HeFu, BindTool.Bind(self.GetCombineServerRemind, self))
	RemindManager.Instance:Register(RemindName.ThreeDayAct, BindTool.Bind(self.ThreeDayRedPoint, self))
	RemindManager.Instance:Register(RemindName.DayTotal, BindTool.Bind(self.GetCombineServerTotalRemind, self))
	RemindManager.Instance:Register(RemindName.LoginReward, BindTool.Bind(self.LoginRewardRedPoint, self))
	RemindManager.Instance:Register(RemindName.CombineBoss, BindTool.Bind(self.IsShowBossLooyRedPoint, self))
end

function HefuActivityData:__delete()
	HefuActivityData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.ThreeDayAct)
	RemindManager.Instance:UnRegister(RemindName.DayTotal)
	RemindManager.Instance:UnRegister(RemindName.LoginReward)
	RemindManager.Instance:UnRegister(RemindName.CombineBoss)
	--RemindManager.Instance:UnRegister(RemindName.HeFu)
end

--根据不同平台获取相应合服配置
function HefuActivityData.GetCurrentCombineActivityConfig()
	--判断是否是ios版本
	local is_ios_plat = (UnityEngine.RuntimePlatform.IPhonePlayer == UnityEngine.Application.platform)
	local combineserveractivity_cfg = is_ios_plat and ConfigManager.Instance:GetAutoConfig("combineserveractivity_ios_auto") or ConfigManager.Instance:GetAutoConfig("combineserveractivity_auto")
	local is_enforce_cfg = GLOBAL_CONFIG.param_list.is_enforce_cfg
	if is_enforce_cfg == 1 then
		combineserveractivity_cfg = ConfigManager.Instance:GetAutoConfig("combineserveractivity_auto")
	elseif is_enforce_cfg == 2 then
		combineserveractivity_cfg = ConfigManager.Instance:GetAutoConfig("combineserveractivity_ios_auto")
	end
	return combineserveractivity_cfg
end

function HefuActivityData:GetKaifuActivityOpenCfg()
	if not self.open_cfg then
		self.open_cfg = HefuActivityData.GetCurrentCombineActivityConfig().activity_time
	end
	return self.open_cfg
end

function HefuActivityData:CacheActivityList(list)
	self.cache_open_activity_list = list
end

function HefuActivityData:DelCacheActivityList()
	self.cache_open_activity_list = nil
end

function HefuActivityData:SetCombineSubActivityState(protocol)
	self.activity_state_list = protocol.sub_activity_state_list
	self.open_act_id_list = {}
	local is_have_activity = false
	for k, v in pairs(self.activity_state_list) do
		local act_cfg = self:GetActIdBySubType(k)
		if nil ~= act_cfg then
			if v == CSActState.OPEN then
				table.insert(self.open_act_id_list, act_cfg)
			end
		end
	end
end

function HefuActivityData:GetCombineSubActivityList()
	return self.open_act_id_list or {}
end

function HefuActivityData:GetActIdBySubType(sub_type)
	for k, v in pairs(self:GetKaifuActivityOpenCfg()) do
		if v.sub_type == sub_type then
			return v
		end
	end
end

------------------------------------Remind----------------------
function HefuActivityData:GetShowRedPointBySubType(sub_type)
	local data = self:IsShowRedPointList()
	if data[sub_type] ~= nil then
		return data[sub_type]
	end
	return false
end

function HefuActivityData:IsShowRedPointList()
	local data = {}
	data[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_KILL_BOSS] = self:IsShowBossLooyRedPoint() == 1
	data[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_SANRIKUANGHUAN] = self:ThreeDayRedPoint() == 1
	data[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CAS_SUB_TYPE_TIANTIANFANLI] = self:GetCombineServerTotalRemind() == 1
	data[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_LOGIN_Gift] = self:LoginRewardRedPoint() == 1
	data[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CAS_SUB_TYPE_PVP] = self:GetCombinePVPRedPoint()
	return data
end

function HefuActivityData:IsShowBossLooyRedPoint()
	local other_cfg = self:GetCombineServerOtherCfg()
	local role_info = self:GetCombineRoleInfo()
	if other_cfg and role_info then
		local can_reward_count = other_cfg.kill_boss_fetch_reward_max_times or 0
		local reward_count = role_info.kill_boss_fetch_reward_times or 0
		local kill_boss_count = role_info.kill_boss_kill_count or 0
		local need_kill_boss_count = other_cfg.kill_boss_reward_cost or 0
		if can_reward_count > reward_count and kill_boss_count >= need_kill_boss_count then
			return 1
		end
	end
	return 0
end

----------------------------------------------------------------

function HefuActivityData:SetCombineRoleInfo(protocol)
	self.combine_person_info.rank_qianggou_buynum_list = protocol.rank_qianggou_buynum_list
	self.combine_person_info.roll_chongzhi_num = protocol.roll_chongzhi_num
	self.combine_person_info.chongzhi_rank_chongzhi_num = protocol.chongzhi_rank_chongzhi_num
	self.combine_person_info.consume_rank_consume_gold = protocol.consume_rank_consume_gold
	self.combine_person_info.kill_boss_kill_count = protocol.kill_boss_kill_count
	self.combine_person_info.personal_panic_buy_numlist = protocol.personal_panic_buy_numlist
	self.combine_person_info.server_panic_buy_numlist = protocol.server_panic_buy_numlist

	self.combine_person_info.login_days = protocol.login_days
	self.combine_person_info.has_fetch_accumulate_reward = protocol.has_fetch_accumulate_reward
	self.combine_person_info.fetch_common_reward_flag = bit:d2b(protocol.fetch_common_reward_flag)
	self.combine_person_info.fetch_vip_reward_flag = bit:d2b(protocol.fetch_vip_reward_flag)
	self.combine_person_info.login_gift_today_has_chongzhi = protocol.login_gift_today_has_chongzhi

	self.combine_person_info.srkh_chongzhi_gold_num = protocol.srkh_chongzhi_gold_num
	self.combine_person_info.srkh_reward_fetch_flag = bit:d2b(protocol.srkh_reward_fetch_flag)
	self.combine_person_info.ttlc_today_chongzhi_gold_num = protocol.ttlc_today_chongzhi_gold_num
	self.combine_person_info.ttlc_reward_fetch_flag = bit:d2b(protocol.ttlc_reward_fetch_flag)
	self.combine_person_info.combine_days = protocol.combine_days
	self.combine_person_info.kill_boss_fetch_reward_times = protocol.kill_boss_fetch_reward_times

	self.combine_login_reward_info = self:SetLoginRewardFlag()
end

function HefuActivityData:GetCombineRoleInfo()
	return self.combine_person_info
end

function HefuActivityData:GetCombineDays()
	return self.combine_person_info.combine_days or -1
end

function HefuActivityData:SetCombineActivityInfo(protocol)
	self.combine_server_data.qianggou_buynum_list = protocol.qianggou_buynum_list
	self.combine_server_data.rank_item_list = protocol.rank_item_list
	self.combine_server_data.csa_xmz_winner_roleid = protocol.csa_xmz_winner_roleid
	self.combine_server_data.csa_gcz_winner_roleid = protocol.csa_gcz_winner_roleid
	self.combine_server_data.server_panic_buy_num_list = protocol.server_panic_buy_num_list
end

function HefuActivityData:GetPanicBuyItemListData(sub_type)
	if self.combine_person_info == nil or next(self.combine_person_info) == nil then return end
	local item_data_list = {}
	if COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_PERSONAL_PANIC_BUY == sub_type then
		local combine_cfg = HefuActivityData.GetCurrentCombineActivityConfig()
		local personal_panic_buy = combine_cfg.personal_panic_buy
		for i = 0, table.maxn(personal_panic_buy) do
			local v = personal_panic_buy[i]
			local item_data = {}
			item_data.seq = v.seq
			item_data.gold_price = v.gold_price
			item_data.reward_item = v.reward_item
			item_data.get_callback = function()
				HefuActivityCtrl.Instance:SendCSARoleOperaReq(sub_type, v.seq)
			end
			item_data.is_no_item = 0
			local user_buy_count = self.combine_person_info.personal_panic_buy_numlist[i + 1]
			item_data.person_limit = v.limit_buy_count - user_buy_count
			if item_data.person_limit <= 0 then
				item_data.is_no_item = 1
			end
			table.insert(item_data_list, item_data)
		end
	elseif COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_SERVER_PANIC_BUY == sub_type then
		local combine_cfg = HefuActivityData.GetCurrentCombineActivityConfig()
		local server_panic_buy = combine_cfg.server_panic_buy
		for i = 0, table.maxn(server_panic_buy) do
			local v = server_panic_buy[i]
			local item_data = {}
			item_data.seq = v.seq
			item_data.gold_price = v.gold_price
			item_data.reward_item = v.reward_item
			item_data.maxperson = v.personal_limit_buy_count
			item_data.maxquanfu = v.server_limit_buy_count
			item_data.get_callback = function()
				HefuActivityCtrl.Instance:SendCSARoleOperaReq(sub_type, v.seq)
			end
			local user_buy_count = self.combine_person_info.server_panic_buy_numlist[i + 1]
			local server_buy_count = self.combine_server_data.server_panic_buy_num_list[i + 1]
			item_data.is_no_item = 0
			item_data.is_no_image = 0
			item_data.person_limit = v.personal_limit_buy_count - user_buy_count
			item_data.server_limit = v.server_limit_buy_count - server_buy_count
			if item_data.person_limit <= 0 or item_data.server_limit <= 0 then
				item_data.is_no_item = 1
			end
			if item_data.person_limit <= 0 then
				item_data.is_no_image = 1
			end
			table.insert(item_data_list, item_data)
		end
	end
	table.sort(item_data_list, SortTools.KeyLowerSorters("is_no_item", "seq") )
	return item_data_list
end

function HefuActivityData:SetQiangGouBuyNumList(qianggou_buynum_list)
	self.qianggou_buy_num_list = qianggou_buynum_list
end

function HefuActivityData:SetQiangGouAllBuyNumList(all_qianggou_buynum_list)
	self.all_qianggou_buynum_list = all_qianggou_buynum_list
end

function HefuActivityData:GetQiangGouAllBuyNumList()
	return self.all_qianggou_buynum_list or 0
end

function HefuActivityData:SetQiangGouRankList(rank_item_list)
	self.qianggou_rank_list = rank_item_list
end

function HefuActivityData:GetQiangGouInfo()
	return self.qianggou_buy_num_list or {}, self.qianggou_rank_list  or {}
end

function HefuActivityData:GetQiangGouFistReward()
	local data = self:GetCurrentCombineActivityConfig()["rank_reward"]
	for k,v in pairs(data) do
		if v.sub_type == COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_RANK_QIANGGOU then
			return v.reward_item_1
		end
	end
	return {}
end

function HefuActivityData:GetQiangGouListInfo()
	return self:GetCurrentCombineActivityConfig()["qianggou"] or {}
end

function HefuActivityData:GetLucklyTurnTableInfo()
	return self:GetCurrentCombineActivityConfig()["roll_cfg"] or {}
end

function HefuActivityData:SetRollResult(result)
	self.roll_result = result
end

function HefuActivityData:GetRollResult()
	return self.roll_result or 0
end

-- 得到其他配置
function HefuActivityData:GetCombineServerOtherCfg()
	local other_cfg = self:GetCurrentCombineActivityConfig()["other"]
	if other_cfg then
		return other_cfg[1]
	end
	return nil
end

function HefuActivityData:GetCityContendRewardInfo()
	local data = self:GetCurrentCombineActivityConfig()["other"][1]
	return data.gcz_chengzhu_reward or {}, data.gcz_camp_reward or {}
end

function HefuActivityData:GetPanicBuyNumList()
	return self.buy_num_list or {}
end

function HefuActivityData:SetPanicBuyNumList(buynumlist)
	self.buy_num_list = buynumlist
end

--获取时间配置
function HefuActivityData:GetCombineActTimeConfig(sub_type)
	local combine_cfg = HefuActivityData.GetCurrentCombineActivityConfig()
	local activity_time = combine_cfg.activity_time
	local time_cfg = nil
	for k, v in pairs(activity_time) do
		if v.sub_type == sub_type then
			time_cfg = v
		end
	end
	return time_cfg
end

--获取活动剩余时间
function HefuActivityData:GetCombineActTimeLeft(sub_type)
	local start_time = TimeCtrl.Instance:GetServerRealCombineTime()
	local time_cfg = self:GetCombineActTimeConfig(sub_type)
	--格式化剩余时间
	local time_left = 0
	if nil ~= time_cfg and nil ~= start_time then
		local act_end_time = start_time + (time_cfg.end_day - 1) * 60 * 60 * 24
		local format_time = os.date("*t", act_end_time)
		local end_hour, end_minute = math.floor(time_cfg.end_time / 100), time_cfg.end_time % 100
		local end_real_time = os.time{year=format_time.year, month=format_time.month, day=format_time.day, hour=end_hour, min = end_minute, sec=0}
		time_left = end_real_time - TimeCtrl.Instance:GetServerTime()
		if time_left < 0 then
			time_left = 0
		end
	end
	return time_left
end

---------------------------------------------------------------------------
--排行榜
function HefuActivityData:GetRankRewardCfgBySubType(sub_type)
	local rank_reward = self:GetCurrentCombineActivityConfig().rank_reward
	for k,v in pairs(rank_reward) do
		if v.sub_type == sub_type then
			return v
		end
	end
	return nil
end

-- 消费金额
function HefuActivityData:GetConsumeRankConsumeGold()
	return self.combine_person_info.consume_rank_consume_gold
end

--充值金额
function HefuActivityData:GetChongZhiRankNum()
	return self.combine_person_info.chongzhi_rank_chongzhi_num
end

function HefuActivityData:GetChongZhiRankInfo()
	if self.combine_server_data.rank_item_list then
		table.sort(self.combine_server_data.rank_item_list[2].user_list, SortTools.KeyUpperSorters("rank_value"))
		return self.combine_server_data.rank_item_list[2]
	end
end

function HefuActivityData:GetConsubeRankInfo()
	table.sort(self.combine_server_data.rank_item_list[3].user_list, SortTools.KeyUpperSorters("rank_value"))
	return self.combine_server_data.rank_item_list[3]
end

--单笔充值
function HefuActivityData:GetSingleChargeCfg()
	local single_charge = self:GetCurrentCombineActivityConfig().single_charge
	return single_charge
end

---------------------------------------------------------------------------
-- 登陆奖励cfg
function HefuActivityData:GetLoginGiftCfg()
	local cur_login_day = self:GetLoginDay()
	local login_gift = self:GetCurrentCombineActivityConfig().login_gift
	local other = self:GetCurrentCombineActivityConfig().other
	local data = {}
	for k,v in pairs(login_gift) do
		if v.need_login_days == cur_login_day then
			data.seq = v.seq
			data.need_login_days = v.need_login_days
			data.data_list ={}
			data.data_list[1] = v.reward_item
			data.data_list[2] = v.vip_reward_item
			data.data_list[3] = other[1].login_accumulate_reward
			data.need_accumulate_days = other[1].need_accumulate_days
		end
	end
	return data
end

-- 0未达到，1可领取， 2已领取
function HefuActivityData:SetLoginRewardFlag()
	local data = {
		[1] = 0,
		[2] = 0,
		[3] = 0,
	}
	if self.combine_person_info == nil or next(self.combine_person_info) == nil then return data end
	data[1] = self.combine_person_info.fetch_common_reward_flag[32 - self.combine_person_info.login_days + 1] == 0 and 1 or 2
	data[2] = self.combine_person_info.fetch_vip_reward_flag[32 - self.combine_person_info.login_days + 1] == 0 and 1 or 2
	data[3] = self.combine_person_info.has_fetch_accumulate_reward == 0 and 1 or 2

	if self.combine_person_info.login_gift_today_has_chongzhi == 0 then
		data[2] = 0
	end

	local other = self:GetCurrentCombineActivityConfig().other
	local cur_day = self:GetLoginDay()
	local need_days = other[1].need_accumulate_days or 0
	if cur_day < need_days then
		data[3] = 0
	end
	return data
end

-- 0未达到，1可领取， 2已领取
function HefuActivityData:GetLoginRewardFlag(index)
	return self.combine_login_reward_info[index] or 0
end

-- 登录奖励红点判断
function HefuActivityData:LoginRewardRedPoint()
	for i = 1, 3 do
		if self.combine_login_reward_info[i] and self.combine_login_reward_info[i] == 1 then
			return 1
		end
	end
	return 0
end

function HefuActivityData:GetLoginDay()
	return self.combine_person_info.login_days or 1
end

function HefuActivityData:GetHasFetchAccumulateReward()
	return self.combine_person_info.has_fetch_accumulate_reward or 1
end

function HefuActivityData:GetHasChongZhing()
	return self.combine_person_info.login_gift_today_has_chongzhi or 0
end

function HefuActivityData:GetFetchCommonRewardFlag()
	return self.combine_person_info.fetch_common_reward_flag or {}
end

function HefuActivityData:GetFetchVipRewardFlag()
	return self.combine_person_info.fetch_vip_reward_flag or {}
end
--------------------------------------------------------------------------

function HefuActivityData:SetCityContendWinnerInfo(role_id)
	self.csa_gcz_winner_roleid = role_id
end

function HefuActivityData:GetCityContendWinnerInfo()
	return self.csa_gcz_winner_roleid or 0
end

--转盘
function HefuActivityData:SetCombineRollResult(protocol)
	self.turntable_index = protocol.ret_seq
end

function HefuActivityData:GetTurntableIndex()
	return self.turntable_index or 0
end

function HefuActivityData:SetRollChongZhiCount(roll_chongzhi_num, roll_total_chongzhi_num)
	self.roll_chongzhi_num = roll_chongzhi_num
	self.roll_total_chongzhi_num = roll_total_chongzhi_num
end

function HefuActivityData:GetRollChongZhiCount()
	return self.roll_chongzhi_num or 0, self.roll_total_chongzhi_num or 0
end

function HefuActivityData:GetRollCost()
	return self:GetCurrentCombineActivityConfig()["other"][1].roll_cost or 1
end

function HefuActivityData:GetRollResult()
	local data = {}
	table.insert(data, self:GetLucklyTurnTableInfo()[self:GetTurntableIndex()].reward_item)
	return data
end
--boss
function HefuActivityData:SetCombineBossInfo(protocol)
	self.boss_info = protocol.boss_info
	self.refresh_state = protocol.refresh_state
	self.acquisitions_num = protocol.acquisitions_num
end

function HefuActivityData:SetCombineBossRank(protocol)
	self.personal_rank = protocol.personal_rank
	self.guild_rank = protocol.guild_rank
end

function HefuActivityData:SetCombineBossKillNum(protocol)
	self.kill_boss_num = protocol.kill_boss_num
	self.guild_killl_boss_num = protocol.guild_killl_boss_num
end

function HefuActivityData:GetCombineServerBossConfig()
	if not self.combine_server_boss_cfg then
		self.combine_server_boss_cfg = ConfigManager.Instance:GetAutoConfig("combine_server_boss_cfg_auto")
	end
	return self.combine_server_boss_cfg
end

function HefuActivityData:GetCombineServerBossCfg()
	local temp_cfg = {}
	for i = 1, #self.boss_info do
		if self.boss_info[i] and self.boss_info[i].boss_type == 0 then
			table.insert(temp_cfg, self.boss_info[i])
		end
	end
	local need_cfg = {}
	local monster_list = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
	for i = 1, #temp_cfg do
		local data = TableCopy(monster_list[temp_cfg[i].boss_id])
		data.next_refresh_time = temp_cfg[i].next_refresh_time
		table.insert(need_cfg, data)
	end
	return need_cfg
end

function HefuActivityData:GetCombineServerBossItemList()
	local other_cfg = self:GetCombineServerBossConfig().other[1] or {}
	local temp_cfg = {}
	for i = 1, 5 do
		local data = {}
		data.item_id = other_cfg["show_item_id"..i] or 0
		data.num = 1
		temp_cfg[i] = data
	end
	return temp_cfg
end

function HefuActivityData:GetCombineServerBossRankGiftList()
	local rank_reward_cfg = self:GetCombineServerBossConfig().rank_reward or {}
	local need_reward_cfg = self:GetRandActivityConfig(rank_reward_cfg)
	local temp_cfg = {}
	for i = 1, #need_reward_cfg do
		if need_reward_cfg[i] and need_reward_cfg[i].master_reward and need_reward_cfg[i].master_reward.item_id > 0 then
			table.insert(temp_cfg, need_reward_cfg[i].master_reward)
		end 
		if need_reward_cfg[i] and need_reward_cfg[i].reward_item and need_reward_cfg[i].reward_item.item_id > 0 then
			table.insert(temp_cfg, need_reward_cfg[i].reward_item)
		end
	end
	return temp_cfg
end

function HefuActivityData:GetCombineServerBossPersonRank()
	return self.personal_rank or {}
end

function HefuActivityData:GetCombineServerBossRankNum(list)
	local num = 0
	for k,v in pairs(list) do
		if v.id and v.id > 0 then
			num = num + 1
		end
	end
	return num
end

function HefuActivityData:GetCombineServerBossGuildRank()
	return self.guild_rank or {}
end

function HefuActivityData:GetCombineServerBossPersonKill()
	return self.kill_boss_num or 0
end

function HefuActivityData:GetCombineServerBossGuildKill()
	return self.guild_killl_boss_num or 0
end

function HefuActivityData:GetCombineServerPersonItemList()
	local rank_reward_cfg = self:GetCombineServerBossConfig().rank_reward or {}
	local need_reward_cfg = self:GetRandActivityConfig(rank_reward_cfg)
	local temp_cfg = {}
	for i = 1, 3 do
		if need_reward_cfg[i] then
			table.insert(temp_cfg, need_reward_cfg[i].reward_item)
		end
	end
	return temp_cfg
end

function HefuActivityData:GetCombineServerGuildItemList()
	local temp_cfg = {}
	local rank_reward_cfg = self:GetCombineServerBossConfig().rank_reward or {}
	local need_reward_cfg = self:GetRandActivityConfig(rank_reward_cfg)
	if need_reward_cfg[4] then  
		table.insert(temp_cfg, need_reward_cfg[4].master_reward or {})
		table.insert(temp_cfg, need_reward_cfg[4].reward_item or {})
	end
	return temp_cfg
end

function HefuActivityData:GetAllCombineBossList()
	local temp_cfg = {}
	local boss_type = self.refresh_state == 0 and 0 or 1
	for i = 1, #self.boss_info do
		if self.boss_info[i] and self.boss_info[i].boss_type == boss_type then
			table.insert(temp_cfg, self.boss_info[i])
		end
	end
	local need_cfg = {}
	local monster_list = self:GetCombineServerBossConfig().boss_cfg or {}
	local data = {}
	for i = 1, #monster_list do
		for i1 = 1, #temp_cfg do
			data = {}
			if monster_list[i].boss_type == temp_cfg[i1].boss_type and monster_list[i].boss_id == temp_cfg[i1].boss_id then
				data = TableCopy(monster_list[i])
				data.next_refresh_time = temp_cfg[i1].next_refresh_time
				table.insert(need_cfg, data)
			end
		end
	end

	table.sort(need_cfg, SortTools.KeyLowerSorters("next_refresh_time"))
	return need_cfg
end

function HefuActivityData:GetRefreshState()
	return self.refresh_state
end

function HefuActivityData:GetAcquisitionsNum()
	return self.acquisitions_num or 0
end

function HefuActivityData:GetRandActivityConfig(cfg)
	local open_day = HefuActivityData.GerCombineServerDay() + 1
	local rand_t = {}
	for i = 1, #cfg do
		if cfg[i] and cfg[i].day_index == open_day then
			table.insert(rand_t, cfg[i])
		end
	end
	return rand_t
end

function HefuActivityData.GerCombineServerDay()
	local activity_day = -1
	local format_time_start = os.date("*t", TimeCtrl.Instance:GetServerRealCombineTime())
	local end_zero_time_start = os.time{year=format_time_start.year, month=format_time_start.month, day=format_time_start.day, hour=0, min = 0, sec=0}

	local format_time_now = os.date("*t", TimeCtrl.Instance:GetServerTime())
	local end_zero_time_now = os.time{year=format_time_now.year, month=format_time_now.month, day=format_time_now.day, hour=0, min = 0, sec=0}

	local format_start_day = math.floor(end_zero_time_start / (60 * 60 * 24))
	local format_now_day =  math.floor(end_zero_time_now / (60 * 60 * 24))
	activity_day = format_now_day - format_start_day
	return activity_day
end


-- 三天狂欢
function HefuActivityData:GetThreeDayGoldNum()
	return 	self.combine_person_info.srkh_chongzhi_gold_num or 0
end

function HefuActivityData:GetThreeDayReward()
	for i = 1, 32 do
		if self.combine_person_info.srkh_reward_fetch_flag and self.combine_person_info.srkh_reward_fetch_flag[33 - i] == 1 then
			return true
		end
	end
	return false
end

function HefuActivityData:ThreeDayRedPoint()
	local need_gold_num = self:GetThreeDayNeedGold()
	if self.combine_person_info.srkh_chongzhi_gold_num and self.combine_person_info.srkh_chongzhi_gold_num >= need_gold_num and not self:GetThreeDayReward() then
		return 1
	end
	return 0
end

function HefuActivityData:GetThreeDayNeedGold()
	local config = self:GetCurrentCombineActivityConfig().other[1]
	if config then
		return config.srkh_fetch_reward_need_chongzhi or 0
	end
	return 0
end

function HefuActivityData:GetRewardItem()
	local config = self:GetCurrentCombineActivityConfig().other[1]
	local item = {item_id=26000,num=1,is_bind=1}
	if config then
		return config.srkh_reward or item
	end
	return item
end

function HefuActivityData:GetModel()
	local config = self:GetCurrentCombineActivityConfig().other[1]
	if config then
		return config.show_respath, config.show_resid
	end
end
-----------------------------------------------------------

--天天返利充值数额
function HefuActivityData:GetCombineServerTotalChongzhi()
	return 	self.combine_person_info.ttlc_today_chongzhi_gold_num or 0
end

--天天返利配置表
function HefuActivityData:GetCombineServerTotalConfig()
	local config = self:GetCurrentCombineActivityConfig().ttlc
	local list = {}
	for i,v in ipairs(config) do
		local data = TableCopy(v)
		table.insert(list, data)
	end
	return list
end

--天天返利标记
function HefuActivityData:GetCombineServerTotalFlag()
	local fetch_reward_t = self.combine_person_info.ttlc_reward_fetch_flag or {}
	local fetch_reward = {[1] = fetch_reward_t[32], [2] = fetch_reward_t[31], [3] = fetch_reward_t[30]}
	local reward_flag = {[1] = false, [2] = false, [3] = false}
	for k,v in pairs(fetch_reward) do
		if v == 0 then
			reward_flag[k] = true
		else
			reward_flag[k] = false
		end
	end
	return reward_flag
end

--天天返利红点
function HefuActivityData:GetCombineServerTotalRemind()
	local is_show_remind = false
	local chongzhi_total = self:GetCombineServerTotalChongzhi()

	local need_chongzhi
	if nil ~= self:GetCombineServerTotalConfig() and nil ~= self:GetCombineServerTotalConfig()[1] and nil ~= self:GetCombineServerTotalConfig()[1].need_chongzhi_gold_num then
		need_chongzhi = self:GetCombineServerTotalConfig()[1].need_chongzhi_gold_num
	end
	
	for k,v in pairs(self:GetCombineServerTotalFlag()) do
		if v == true and (chongzhi_total >= need_chongzhi) and (k == self:GetCombineDays() + 1) then
			return 1
		end
	end

	return 0
end

--合服pvp
function HefuActivityData:GetPvpActivity()
	return self.GetCurrentCombineActivityConfig().pvpactivity or {}
end

function HefuActivityData:GetCombinePVPRedPoint()
	local redpoint_list = {}
	redpoint_list[1] = ACTIVITY_TYPE.QUNXIANLUANDOU
	redpoint_list[2] = ACTIVITY_TYPE.GONGCHENGZHAN
	redpoint_list[3] = ACTIVITY_TYPE.GUILDBATTLE

	for k,v in pairs(redpoint_list) do
		local activity_info = ActivityData.Instance:GetActivityStatuByType(v)
		if activity_info  then
			if activity_info.status == ACTIVITY_STATUS.OPEN then
				return true
			end
		end
	end
	return false
end