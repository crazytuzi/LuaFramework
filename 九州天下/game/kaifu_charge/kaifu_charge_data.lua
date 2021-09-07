KaiFuChargeData = KaiFuChargeData or BaseClass()

SYSTEM_TYPE = {
	MOUNT = 0,
	WING = 1,
	FIGHT_MOUNT = 2,
	HALO = 3,
	FABAO = 4,
	BEAUTY_HOLO = 5,
	PIFENG = 6,
	FAZHEN = 7,
}

function KaiFuChargeData:__init()
	if KaiFuChargeData.Instance then
		print_error("[KaiFuChargeData] Attempt to create singleton twice!")
		return
	end
	KaiFuChargeData.Instance = self
	self.mount_info = {}
	self.kaifu_bipin_list = {}
	self.bipin_rank_info = {}

	self.total_consume_info = {}
	self.xufu_info = {}				--折扣活动信息
	self.xufu_buy_back_info = {}	--折扣购买返回信息	
	self.active_list_stamp = {}		--折扣功能开启信息
	self.discount_cfg = nil			--折扣活动配置
	self.super_daily_config = {}	--始皇武库
	self.fenqi_info = {
		func_type = 0,
		func_grade = 0,
		func_is_max_grade = 0,
		is_fetch = 0,
		today_chongzhi_num = 0,
	}			--奋起直追
	self.fetch_times_list = {}
	self.daily_chongzhi_num = 0
	self.cur_day = -1
	self.discount_gift_cfg = ListToMapList(self:GetDiscountCfg().xufucili_cfg, "gift_type")				--折扣活动礼包配置
	self.oga_seven_total_chongzhi_reward_flag_list = {}										-- 开服七天累冲已拿取奖励标记
	self.leiji_chongzhi_info = {}
	self.leiji_new_chongzhi_info = {}

	self.rsing_star_info = {
		fetch_stall = 0,
		chognzhi_today = 0,
		func_level = 0,
		func_type = 0,
		is_max_level = 0,
		max_stall = 0,
	}
	self.seven_day_consume_gold_num_list = {}
	self.seven_day_reward_flag = 0

	self.rising_star_cfg = nil
	self.is_first = true
	self.is_open_daily_charge = false
	self.is_first_leiji = true
	self.xu_fu_first_remind = true
	self.libao_list = {}
	self.super_charge_feedback = {}
	RemindManager.Instance:Register(RemindName.KaiFuYueKa, BindTool.Bind(self.GetKaiFuYueKa, self))
	RemindManager.Instance:Register(RemindName.KaiFuYueKaGold, BindTool.Bind(self.GetKaiFuYueKaGold, self))
	RemindManager.Instance:Register(RemindName.KaiFuLoginTouzi, BindTool.Bind(self.GetKaiFuLoginTouzi, self))
	RemindManager.Instance:Register(RemindName.KaiFuLevelTouzi, BindTool.Bind(self.GetKaiFuLevelTouzi, self))
	RemindManager.Instance:Register(RemindName.KaiFuRiSingBtnRedPoint, BindTool.Bind(self.GetKaiFuRiSingBtnRedPoint, self))
	RemindManager.Instance:Register(RemindName.KaiFuChongZhiItem, BindTool.Bind(self.GetKaiFuChongZhiItem, self))
	RemindManager.Instance:Register(RemindName.DailyLeiJi, BindTool.Bind(self.GetDailyChargeRemind, self))
	RemindManager.Instance:Register(RemindName.KaiFuRedEquip, BindTool.Bind(self.CheckRedEquipRedPoint, self))
	RemindManager.Instance:Register(RemindName.KaiFuNewTotalReward, BindTool.Bind(self.FlushNewTotalConsumeHallRedPoindRemind, self))
	RemindManager.Instance:Register(RemindName.KaiFuLeiJiChongZhi, BindTool.Bind(self.GetIsTotalChongZhiRemind, self))
	RemindManager.Instance:Register(RemindName.RewardSeven, BindTool.Bind(self.IsRewardSevenRedPoindRemind, self))
	RemindManager.Instance:Register(RemindName.XuFuCiLi, BindTool.Bind(self.GetXuFuRemind, self))
	RemindManager.Instance:Register(RemindName.MeiRiZhanBei, BindTool.Bind(self.GetXianGouRedPoint, self))
	RemindManager.Instance:Register(RemindName.SuperChargeFeedback, BindTool.Bind(self.GetSuperChargeRemind, self))
end

function KaiFuChargeData:__delete()
	KaiFuChargeData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.KaiFuYueKa)
	RemindManager.Instance:UnRegister(RemindName.KaiFuYueKaGold)
	RemindManager.Instance:UnRegister(RemindName.KaiFuLoginTouzi)
	RemindManager.Instance:UnRegister(RemindName.KaiFuLevelTouzi)
	RemindManager.Instance:UnRegister(RemindName.KaiFuRiSingBtnRedPoint)
	RemindManager.Instance:UnRegister(RemindName.KaiFuChongZhiItem)
	RemindManager.Instance:UnRegister(RemindName.DailyLeiJi)
	RemindManager.Instance:UnRegister(RemindName.KaiFuRedEquip)
	RemindManager.Instance:UnRegister(RemindName.KaiFuNewTotalReward)
	RemindManager.Instance:UnRegister(RemindName.KaiFuLeiJiChongZhi)
	RemindManager.Instance:UnRegister(RemindName.RewardSeven)
	RemindManager.Instance:UnRegister(RemindName.XuFuCiLi)
	RemindManager.Instance:UnRegister(RemindName.MeiRiZhanBei)
	RemindManager.Instance:UnRegister(RemindName.SuperChargeFeedback)
end

------------------------ 月卡 ------------------------------------

function KaiFuChargeData:TouZiCfg()
	return ConfigManager.Instance:GetAutoConfig("touzijihua_auto").new_plan
end

function KaiFuChargeData:TouZiOtherCfg()
	return ConfigManager.Instance:GetAutoConfig("touzijihua_auto").other[1]
end

function KaiFuChargeData:ChongzhirewardCfg()
	local cfg = RechargeData.Instance:GetChongzhiCfg()
	return cfg.other[1]
end

function KaiFuChargeData:SetMonthCardInfo(protocol)
	self.mount_info.active_timestamp = protocol.active_timestamp			--月卡激活时间戳
	self.mount_info.is_active = protocol.is_active							--是否激活
	self.mount_info.reward_gold = protocol.reward_gold						--能够拿取的元宝数
	self.mount_info.buy_times = protocol.buy_times							--已经购买月卡的次数	
	self.mount_info.monthcard_first_reward_fetch_flag = protocol.monthcard_first_reward_fetch_flag	-- 月卡第一购买奖励拿取标记（1表示领取过）
end

function KaiFuChargeData:GetMonthCardInfo()
	return self.mount_info
end

-- 有没有月卡领取
function KaiFuChargeData:GetKaiFuYueKa()
	local yueka_info = self:GetMonthCardInfo()
	if yueka_info.is_active then				--是否激活
		if yueka_info.is_active >= 1 then 
			if yueka_info.monthcard_first_reward_fetch_flag and yueka_info.monthcard_first_reward_fetch_flag == 0 then  
				return 1		
			end 
		end
	end
	return 0
end

-- 领取每天的元宝奖励红点
function KaiFuChargeData:GetKaiFuYueKaGold()
	local yueka_info = self:GetMonthCardInfo()
	if yueka_info and yueka_info.reward_gold then
		if yueka_info.reward_gold > 0 then
			return 1
		else
			return 0
		end
	end
	return 0
end

------------------------- END ------------------------------------------

------------------------ 投资计划 ------------------------------------
function KaiFuChargeData:TouZiRewardCfg()
	return ConfigManager.Instance:GetAutoConfig("touzijihua_auto").touzi_reward
end

function KaiFuChargeData:LevelTouziLimit()
	local limit_charge = ConfigManager.Instance:GetAutoConfig("touzijihua_auto").other[1].buy_plan_need_chongzhi
	
	return limit_charge
end

function KaiFuChargeData:LevelTouZiNeedPrice()
	return self:TouZiOtherCfg().level_plan_need_gold
end

function KaiFuChargeData:LoginTouZiNeedPrice()
	local list = ConfigManager.Instance:GetAutoConfig("touzijihua_auto").other[1]
	if not list then return end
	-- 元宝换成rmb
	return list.login_plan_need_gold / 10
end
-- 月卡
function KaiFuChargeData:YueKaNeedPrice()
	local list = ConfigManager.Instance:GetAutoConfig("touzijihua_auto").other[1]
	if not list then return end
	-- 元宝换成rmb
	return list.new_plan_price / 10
end

-- 登陆投资红点
function KaiFuChargeData:GetKaiFuLoginTouzi()
	local data = self:GetLoginRewardList()
	local touzi_info = InvestData.Instance:GetInvestInfo()
	local is_touzi_login = touzi_info.touzi_active_flag == TOUZI_ACTIVE_TYPE.TOUZI_LOGIN or touzi_info.touzi_active_flag == TOUZI_ACTIVE_TYPE.TOUZI_ALL
	for k,v in ipairs(data) do
		local has_reward = InvestData.Instance:GetNormalLevelHasReward(v.touzi_type, v.seq)
		local level_flag = InvestData.Instance:GetNormalLevelFlag(v.touzi_type, v.seq)
		if level_flag > 0 then
			return 0
		else
			if is_touzi_login and has_reward > 0 then
				return 1
			end
		end
	end
	return 0 
end

function KaiFuChargeData:LoginTouZiNeedPrice1()
	return ConfigManager.Instance:GetAutoConfig("touzijihua_auto").other[1].login_plan_need_gold
end

-- 等级投资红点
function KaiFuChargeData:GetKaiFuLevelTouzi()
	local data = self:GetLevelRewardList()
	local role_level = PlayerData.Instance.role_vo.level
	local touzi_info = InvestData.Instance:GetInvestInfo()
	local is_touzi_level = touzi_info.touzi_active_flag == TOUZI_ACTIVE_TYPE.TOUZI_LEVEL or touzi_info.touzi_active_flag == TOUZI_ACTIVE_TYPE.TOUZI_ALL
	for k,v in ipairs(data) do
		local level_flag = InvestData.Instance:GetNormalLevelFlag(v.touzi_type, v.seq)
		if level_flag > 0 then
			return 0
		else
			local has_reward = InvestData.Instance:GetNormalLevelHasReward(v.touzi_type, v.seq)
			if is_touzi_level and (has_reward > 0) and (role_level >= v.need_level) then
				return 1
			end
		end
	end
	return 0
end

-- 投资是否已领取所有奖励
function KaiFuChargeData:GetKaiFuTouziAllRewardFlag(tabindex_touzi)
	local data = nil
	if tabindex_touzi == TabIndex.kaifu_touzi then
		data = self:GetLevelRewardList()
	elseif tabindex_touzi == TabIndex.kaifu_touzi_login then
		data = self:GetLoginRewardList()
	end
	if data then
		for k, v in pairs(data) do
			local level_flag = InvestData.Instance:GetNormalLevelFlag(v.touzi_type, v.seq)
			if level_flag <= 0 then
				return true
			end
		end
		return false
	end
	return true
end

-- 升星助力红点
function KaiFuChargeData:GetKaiFuRiSingBtnRedPoint()
	local rising_star_info = self:GetShengxingzhuliInfo()
	local day_num = TimeCtrl.Instance:GetCurOpenServerDay()
	if rising_star_info and rising_star_info.func_level > 0 then 	-- 系统开启了
		if 0 == rising_star_info.is_max_level then 		-- 系统没达到最高级
			-- local rising_star_cfg = self:GetRisingStarCfg()
			if day_num > 7 and rising_star_info.fetch_stall >= 1 then return 0 end
			if rising_star_info.fetch_stall < rising_star_info.max_stall then
				return 1
			else
				if KaiFuChargeData.Instance:GetNeedChongzhiByStage(rising_star_info.max_stall + 1) - rising_star_info.chognzhi_today <= 0 then
					return 1
				end
			end
		else
			return 0
		end
	end
	return 0
end

function KaiFuChargeData:IsOpenDailyCharge()
	local is_state = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_DAILY_LOVE)
	return self.is_open_daily_charge and is_state
end

function KaiFuChargeData:SetOpenDailyCharge(is_first)
	self.is_open_daily_charge = is_first
end

function KaiFuChargeData:QiTianOpen()
	self.is_first = false
end

function KaiFuChargeData:LeiJiOpen()
	self.is_first_leiji = false
	RemindManager.Instance:Fire(RemindName.DailyLeiJi)
end

-- 七天累充
function KaiFuChargeData:GetKaiFuChongZhiItem()
	if self.is_first then
		return 1
	end
	local data = self:GetSortSevendayConfig()
	if data then
		for k,v in ipairs(data) do
			local chong_cfg = self:GetogaSevenTotalChongzhiNum()
			if chong_cfg >= v.need_chongzhi then
				local result_cfg = self:ChongZhiSecenDayFlag()
				local is_got = result_cfg[v.seq + 1]
				if is_got == 0 then
					return 1
				end
			end
		end
	end
	return 0
end

function KaiFuChargeData:IsRewardQiTianChongZhi()
	local data = self:GetSortSevendayConfig()
	if data then
		for k,v in ipairs(data) do
			local is_got = self:GetQiTianChongzhiRewardFlagByIndex(v.seq)
			if is_got ~= nil and is_got == 0 then
				return true
			end
		end
	end
	return false
end

function KaiFuChargeData:TouZiRewardTypeCfg(type)
	local touzi_reward = self:TouZiRewardCfg()
	local type_reward = {}
	for k,v in pairs(touzi_reward) do
		if v.touzi_type == type then
			table.insert(type_reward, v)
		end
	end
	return type_reward
end


function KaiFuChargeData:GetLevelRewardList()
	local level_cfg = self:TouZiRewardTypeCfg(TOUZI_JIHUA_TYPE.TOUZI_JIHUA_TYPE_LEVEL)
	table.sort(level_cfg, function (a, b)
		local a_has_reward = InvestData.Instance:GetNormalLevelFlag(TOUZI_JIHUA_TYPE.TOUZI_JIHUA_TYPE_LEVEL,a.seq)
		local b_has_reward = InvestData.Instance:GetNormalLevelFlag(TOUZI_JIHUA_TYPE.TOUZI_JIHUA_TYPE_LEVEL,b.seq)	

		local a_can_reward = InvestData.Instance:GetNormalLevelHasReward(TOUZI_JIHUA_TYPE.TOUZI_JIHUA_TYPE_LEVEL,a.seq)
		local b_can_reward = InvestData.Instance:GetNormalLevelHasReward(TOUZI_JIHUA_TYPE.TOUZI_JIHUA_TYPE_LEVEL,b.seq)

		if a_can_reward == b_can_reward then
			if a_has_reward == b_has_reward then
				return a.need_level < b.need_level
			else
				return a_has_reward < b_has_reward
			end 
		else
			if a_has_reward == b_has_reward then
				return a.need_level < b.need_level
			else
				return a_can_reward > b_can_reward
			end
		end
	end)
	return level_cfg
end

function KaiFuChargeData:GetLevelRewardListSort()
	local level_cfg = TableCopy(self:TouZiRewardTypeCfg(TOUZI_JIHUA_TYPE.TOUZI_JIHUA_TYPE_LEVEL))
	for k,v in pairs(level_cfg) do
		local has_reward = InvestData.Instance:GetNormalLevelFlag(TOUZI_JIHUA_TYPE.TOUZI_JIHUA_TYPE_LEVEL, v.seq)
		local can_reward = InvestData.Instance:GetNormalLevelHasReward(TOUZI_JIHUA_TYPE.TOUZI_JIHUA_TYPE_LEVEL, v.seq)
		local falg = has_reward + can_reward
		-- 为了方便升序排序 调换可领取和未领取的标记
		if falg == 0 then
			v.reward_flag = 1
		elseif falg == 1 then
			v.reward_flag = 0
		else
			v.reward_flag = has_reward + can_reward
		end
	end
	SortTools.SortAsc(level_cfg, "reward_flag", "need_level")
	return level_cfg
end

function KaiFuChargeData:GetLoginRewardList()
	local level_cfg = self:TouZiRewardTypeCfg(TOUZI_JIHUA_TYPE.TOUZI_JIHUA_TYPE_LOGIN)
	table.sort(level_cfg, function (a, b)
		local a_has_reward = InvestData.Instance:GetNormalLevelFlag(TOUZI_JIHUA_TYPE.TOUZI_JIHUA_TYPE_LOGIN,a.seq)
		local b_has_reward = InvestData.Instance:GetNormalLevelFlag(TOUZI_JIHUA_TYPE.TOUZI_JIHUA_TYPE_LOGIN,b.seq)	

		local a_can_reward = InvestData.Instance:GetNormalLevelHasReward(TOUZI_JIHUA_TYPE.TOUZI_JIHUA_TYPE_LOGIN,a.seq)
		local b_can_reward = InvestData.Instance:GetNormalLevelHasReward(TOUZI_JIHUA_TYPE.TOUZI_JIHUA_TYPE_LOGIN,b.seq)

		if a_can_reward == b_can_reward then
			if a_has_reward == b_has_reward then
				return a.seq < b.seq
			else
				return a_has_reward < b_has_reward
			end 
		else
			if a_has_reward == b_has_reward then
				return a.seq < b.seq
			else
				return a_can_reward > b_can_reward
			end
		end
	end)
	return level_cfg
end
------------------------- END ------------------------------------------
-- 坐骑. 羽翼2144 光环2145   法印2146（战斗坐骑） 2147 美人光环 2148 法宝 2149 披风

------------------------ 开服七天累计充值 --------------------------

function KaiFuChargeData:SetOpenGameActivityInfo(protocol)
	self.oga_seven_total_chongzhi_num = protocol.oga_seven_total_chongzhi_num										-- 开服七天累冲总金额				
	self.oga_seven_total_chongzhi_reward_flag = protocol.oga_seven_total_chongzhi_reward_flag						-- 开服七天累冲已拿取奖励标记 		
	self.oga_seven_total_chongzhi_reward_flag_list = bit:d2b(protocol.oga_seven_total_chongzhi_reward_flag)			-- 开服七天累冲已拿取奖励标记 		
end

function KaiFuChargeData:GetogaSevenTotalChongzhiNum()
	return self.oga_seven_total_chongzhi_num or 0						
end

function KaiFuChargeData:GetTogaSevenTotalChongzhiRewardFlag()
	return self.oga_seven_total_chongzhi_reward_flag or 0						
end

function KaiFuChargeData:GetQiTianChongzhiRewardFlagByIndex(index)
	return self.oga_seven_total_chongzhi_reward_flag_list[32 - index]
end

function KaiFuChargeData:GetSevenDayChongZhiAuto()
	local spid = GLOBAL_CONFIG.package_info.config.agent_id
	local agent_cfg = ConfigManager.Instance:GetAutoConfig("agent_adapt_auto").shield_accumulate_recharge
	local shield = 0
	local charge_level = 0
	local total_charge = 0
	local shield_charge = 0
	local need_check = false
	for _, v in pairs(agent_cfg) do
		if v.spid == spid then
			shield_charge = v.seven_day_charge
			need_check = true
			break
		end
	end
	local seven_day_chongzhi = self:GetogaSevenTotalChongzhiNum()
	charge_level = shield_charge
	charge_level = seven_day_chongzhi > shield_charge and seven_day_chongzhi or shield_charge
	total_charge = seven_day_chongzhi

	local chongzhi_cfg = RechargeData.Instance:GetChongzhiCfg()
	local cfg = chongzhi_cfg.oga_seven_day_total_chongzhi
	local list = {}

	for _, v in pairs(cfg) do
		if need_check and (v.need_chongzhi <= charge_level or v.pre_chongzhi <= total_charge) then
			table.insert(list, v)
		elseif not need_check then
			table.insert(list, v)
		end
	end

	return list
end

-- 根据是否领取排序
function KaiFuChargeData:GetSortSevendayConfig()
	local cfg = self:GetSevenDayChongZhiAuto()
	local flag = self:ChongZhiSecenDayFlag()
	local result = {}
	local result_flag = {}
	local index = 1
	local last_index = 1
	for k,v in ipairs(cfg) do
		if flag[k] == 0 then
			result[index] = TableCopy(v)
			index = index + 1
		else
			result_flag[last_index] = TableCopy(v)
			last_index = last_index + 1
		end
	end
	for i,v in ipairs(result_flag) do
		result[index] = v
		index = index + 1
	end
	return result
end

-- 根据充值的金额数量获取展示的模型
function KaiFuChargeData:GetModelNumBerByChongZhi(c_money)
	local cfg = self:GetSevenDayChongZhiAuto()
	for k,v in ipairs(cfg) do
		if c_money < v.need_chongzhi then
			return v.show_item_id
		end
	end
	return 1
end

-- 获取累计充值金额差
function KaiFuChargeData:GetSevenDayChongZhiMoney()
	local money_num = self:GetogaSevenTotalChongzhiNum()
	return money_num
	-- local seven_day_cfg = self:GetSevenDayChongZhiAuto()
	-- for k,v in pairs(seven_day_cfg) do
	-- 	if money_num < v.need_chongzhi then
	-- 		return v.need_chongzhi - money_num
	-- 	end
	-- end
	-- return nil
end

function KaiFuChargeData:ChongZhiSecenDayFlag()
	local reward_flag = self:GetTogaSevenTotalChongzhiRewardFlag()
	local seq = self:GetSevenDayChongZhiAuto()
	local flag_list = {}
	for i=1,#seq do
		table.insert(flag_list, bit:_and(1, bit:_rshift(reward_flag, i - 1)))
	end
	return	flag_list
end

function KaiFuChargeData:GetChongZhiSeqCfg(seq)
	local cfg = self:GetSevenDayChongZhiAuto()
	for k, v in pairs(cfg) do
		if seq == v.seq then
			return v
		end
	end
end

------------------------ 全民比拼 ------------------------------------

function KaiFuChargeData:OpenserverCfg()
	-- return ConfigManager.Instance:GetAutoConfig("randactivityconfig_1_auto").openserver_reward    -- 5196 行
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().openserver_reward
end

-- 根据活动号获取排名奖励配置
function KaiFuChargeData:GetBiPinActCfg(type) 
	local openserver_cfg = self:OpenserverCfg()
	local item_list = {}
	for i,v in ipairs(openserver_cfg) do
		if v.activity_type == type then
			if v.cond2 == 0 then
				table.insert(item_list, v)
			end
		end
	end
	return item_list
end

-- 根据活动号和当前条件获取奖励配置
function KaiFuChargeData:GetBiPinActJieShuCfg(type) 
	local openserver_cfg = self:OpenserverCfg()
	local item_list = {}
	for i,v in ipairs(openserver_cfg) do
		if v.activity_type == type then
			if v.cond1 == 0 then
				table.insert(item_list, v)
			end
		end
	end
	return item_list
end

-- 根据服务端活动信息获取当天开的比拼活动号
function KaiFuChargeData:GetBiPinActivity()
	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local activity_info = ActivityData.Instance:GetActivityStatus()
	if server_day <= 7 then
		for k,v in pairs(activity_info) do
			if k == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_MOUNT_RANK              				-- 开服坐骑比拼
			 or k == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING_RANK 							-- 开服羽翼比拼
			 or k == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_HALO_RANK 							-- 开服光环比拼
			 or k == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FIGHT_MOUNT_RANK 						-- 开服战骑进阶榜--法印(开服活动)
			 or k == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_JL_GUANGHUAN_RANK 							-- 精灵光环--美人光环(开服活动)
			 or k == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_ZHIBAO_RANK 							-- 法宝进阶榜--圣物(开服活动)
			 or k == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENYI_RANK then 						-- 开服神翼(披风)比拼 
				if v.status == 2 then
					return v.type
				end
			end
		end
	end
end


-- 活动类型
function KaiFuChargeData:GetBiPinType()
	local kaifu_bipin_Type = {}
	kaifu_bipin_Type[2143] = BiPIN_RANK_TYPE.PERSON_RANK_TYPE_UPGRADE_MOUNT   										-- 坐骑进阶榜
	kaifu_bipin_Type[2144] = BiPIN_RANK_TYPE.PERSON_RANK_TYPE_UPGRADE_WING 											-- 羽翼进阶榜
	kaifu_bipin_Type[2145] = BiPIN_RANK_TYPE.PERSON_RANK_TYPE_UPGRADE_HALO 											-- 光环进阶榜
	kaifu_bipin_Type[2146] = BiPIN_RANK_TYPE.PERSON_RANK_TYPE_UPGRADE_FIGHTMOUNT 									-- 战骑进阶榜--法印(开服活动)
	kaifu_bipin_Type[2147] = BiPIN_RANK_TYPE.PERSON_RANK_TYPE_UPGRADE_JL_HALO 										-- 精灵光环  --美人光环(开服活动)
	kaifu_bipin_Type[2148] = BiPIN_RANK_TYPE.PERSON_RANK_TYPE_UPGRADE_ZHIBAO 										-- 法宝进阶榜--圣物(开服活动)
	kaifu_bipin_Type[2149] = BiPIN_RANK_TYPE.PERSON_RANK_TYPE_UPGRADE_SHENYI 										-- 神翼进阶榜--披风(开服活动)
	return kaifu_bipin_Type
end

-- 根据活动号返回活动类型
function KaiFuChargeData:GetBiPinTheDayActType()
	local activity = self:GetBiPinActivity()
	return self:GetBiPinType()[activity]
end


-- 根据开服前7天的天数请求对应的活动类型
function KaiFuChargeData:SendDayRankInfo()
	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local bipin_act = self:GetBiPinActivity()
	local bipin_type = self:GetBiPinTheDayActType()
	if server_day > 7 then return end
	for i = 1,7 do
		if server_day == i then 
			if ActivityData.Instance:GetActivityIsOpen(bipin_act) then
				RankCtrl.Instance:SendGetPersonRankListReq(bipin_type)
			end 
		end
	end
end

-- 根据当前阶数获取当前Seq
function KaiFuChargeData:GetCurBiPinActSeqCfg()
	local bipin_type = self:GetBiPinActivity()
	local xiajie_cfg = self:GetBiPinActJieShuCfg(bipin_type)
	local mount_info = MountData.Instance:GetMountInfo()     					-- 坐骑阶数
	local halo_info = HaloData.Instance:GetHaloInfo() 		  				 	-- 光环阶数
	local wind_info = WingData.Instance:GetWingGrade() 		  				 	-- 羽翼阶数
	local meiren_guanghuan_info = BeautyHaloData.Instance:GetBeautyHaloInfo()   -- 美人光环
	local shengong_info = ShengongData.Instance:GetShengongInfo() 			 	-- 神弓阶数（足迹）
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo() 					-- 神翼阶数 （披风）
	local fight_mount_info = FaZhenData.Instance:GetFightMountInfo()     	-- 战斗坐骑
	local halidom_info = HalidomData.Instance:GetHalidomInfo() 					-- 圣物
	local grade = KaiFuChargeData.Instance:ConvertGrade(mount_info.grade)
	for i,v in ipairs(xiajie_cfg) do
		if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_MOUNT_RANK) and mount_info.star_level then
			if mount_info.star_level <= v.cond2 then
				return v.seq
			else
				return 9
			end
		elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING_RANK) and wind_info.grade then
			if wind_info.star_level <= v.cond2 then
				return v.seq
			else
				return 9
			end
		elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_HALO_RANK) and halo_info.star_level then
			if halo_info.star_level <= v.cond2 then
				return v.seq
			else
				return 9
			end
		elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FIGHT_MOUNT_RANK) and fight_mount_info.grade then
			if fight_mount_info.grade <= v.cond2 then
				return v.seq
			else
				return 9
			end

		elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_JL_GUANGHUAN_RANK) and meiren_guanghuan_info.grade then
			if meiren_guanghuan_info.grade <= v.cond2 then
				return v.seq
			else
				return 9
			end

		elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_ZHIBAO_RANK) then
			if halidom_info.grade <= v.cond2 then
				return v.seq
			else
				return 9
			end

		elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENYI_RANK) and shenyi_info.grade then
			if shenyi_info.grade <= v.cond2 then
				return v.seq
			else
				return 9
			end
		end 
	end
end

-- 根据Seq获取吓阶的配置
function KaiFuChargeData:GetCurBiPinActJieShuCfg(seq)
	local bipin_type = self:GetBiPinActivity()
	local xiajie_cfg = self:GetBiPinActJieShuCfg(bipin_type)
	local mount_info = MountData.Instance:GetMountInfo()     					-- 坐骑阶数
	local halo_info = HaloData.Instance:GetHaloInfo() 		  				 	-- 光环阶数
	local wind_info = WingData.Instance:GetWingGrade() 		  				 	-- 羽翼阶数
	local meiren_guanghuan_info = BeautyHaloData.Instance:GetBeautyHaloInfo()   -- 美人光环
	local shengong_info = ShengongData.Instance:GetShengongInfo() 			 	-- 神弓阶数（足迹）
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo() 					-- 神翼阶数 （披风）
	local fight_mount_info = FaZhenData.Instance:GetFightMountInfo()     	-- 战斗坐骑
	local halidom_info = HalidomData.Instance:GetHalidomInfo() 					-- 圣物法宝
	local grade = KaiFuChargeData.Instance:ConvertGrade(mount_info.grade)

	for i,v in ipairs(xiajie_cfg) do
		if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_MOUNT_RANK) and mount_info.show_grade then
			if mount_info.show_grade <= v.cond2 and seq == v.seq and mount_info.show_grade > 1 then
				return v
			elseif mount_info.show_grade <= 1 and seq == v.seq then
				return v
			elseif seq == 10 then
				seq = 9
				if seq == v.seq then
					return v
				end
			end
		elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING_RANK) and wind_info then
			if wind_info <= v.cond2 and seq +1 == v.seq and wind_info > 1 then
				return v
			elseif wind_info <= 1 and seq == v.seq then
				return v
			elseif seq == v.seq then
				return v
			elseif seq == 10 then
				seq = 9
				if seq == v.seq then
					return v
				end
			end
		elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_HALO_RANK) and halo_info.star_level then
			if halo_info.star_level <= v.cond2 and seq +1 == v.seq and halo_info.star_level > 1 then
				return v
			elseif halo_info.star_level <= 1 and seq == v.seq then
				return v
			elseif seq == v.seq then
				return v
			elseif seq == 10 then
				seq = 9
				if seq == v.seq then
					return v
				end
			end

		elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FIGHT_MOUNT_RANK) and fight_mount_info.grade then
			if fight_mount_info.grade <= v.cond2 and seq +1 == v.seq and fight_mount_info.grade > 1 then
				return v
			elseif fight_mount_info.grade <= 1 and seq == v.seq then
				return v
			elseif seq == v.seq then
				return v
			elseif seq == 10 then
				seq = 9
				if seq == v.seq then
					return v
				end
			end

		elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_JL_GUANGHUAN_RANK) and meiren_guanghuan_info.grade then
			if wind_info <= v.cond2 and seq +1 == v.seq and wind_info > 1 then
				return v
			elseif wind_info <= 1 and seq == v.seq then
				return v
			elseif seq == v.seq then
				return v
			elseif seq == 10 then
				seq = 9
				if seq == v.seq then
					return v
				end
			end
		elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_ZHIBAO_RANK) then	
			if halidom_info.grade <= v.cond2 and seq +1 == v.seq and halidom_info.grade > 1 then
				return v
			elseif halidom_info.grade <= 1 and seq == v.seq then
				return v
			elseif seq == v.seq then
				return v
			elseif seq == 10 then
				seq = 9
				if seq == v.seq then
					return v
				end
			end

		elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENYI_RANK) and shenyi_info.grade then
			if shenyi_info.grade <= v.cond2 and seq +1 == v.seq and shenyi_info.grade > 1 then
				return v
			elseif shenyi_info.grade <= 1 and seq == v.seq then
				return v
			elseif seq == v.seq then
				return v
			elseif seq == 10 then
				seq = 9
				if seq == v.seq then
					return v
				end
			end
		end 
	end
end

-- 根据当前可领奖励返回当前的Seq
function KaiFuChargeData:BiPinActCurCompleteFlagSeq()
	local day_act_num = self:GetBiPinActivity()
	for i=1,5 do
		local complete_flag = KaiFuChargeData.Instance:BiPinActCompleteTypeFlag(day_act_num,i + 4) 		-- 是否可以领,seq从5开始
		if complete_flag == 1 then
			return i + 4 
		else
			return 5
		end
	end
end

-- 根据奖励是否领取返回当前的Seq
function KaiFuChargeData:BiPinActCurRewardFlagSeq()
	local seq = {}
	local day_act_num = self:GetBiPinActivity()
	for i=1,5 do
		local reward_flag = KaiFuChargeData.Instance:BiPinActTypeFlag(day_act_num,i + 4) 		-- 是否可以领,seq从5开始
		if reward_flag == 1 then
			table.insert(seq, reward_flag)
		end
	end
	return #seq + 5
end

-- 比拼奖励是否领过 0 没有 1 有
function KaiFuChargeData:BiPinActTypeFlag(act_type,seq)
	local act_cfg = KaifuActivityData.Instance:GetActivityInfo(act_type)
	if act_cfg then
		local reward_flag = act_cfg.reward_flag
		return bit:_and(1, bit:_rshift(reward_flag, seq))
	end
	return 0
end

-- 比拼奖励是否可以领 0不可以 1 可以
function KaiFuChargeData:BiPinActCompleteTypeFlag(act_type,seq)
	local complete_flag = KaifuActivityData.Instance:GetActivityInfo(act_type).complete_flag
	return	bit:_and(1, bit:_rshift(complete_flag, seq))
end

-- 阶数转换
function KaiFuChargeData:ConvertGrade(grade)
	if not grade or type(grade) ~= "number" then return "" end
	if grade <= 0 then
		return 1 .. Language.Competition.Jie
	else
		return math.floor((grade - 1) / 10) + 1 .. Language.Competition.Jie .. ( grade - 1) % 10 + 1 .. Language.Competition.Star
	end
end

------------------------- END ------------------------------------------

------------------------ 充值回馈活动（开服充值活动界面已经去掉了这个） ------------------------------------

function KaiFuChargeData:SetChongZhiDaHuiKui(protocol)
	self.is_first_chongzhi = protocol.is_first_chongzhi				-- 是否第一次充值
	self.chongzhi_num = protocol.chongzhi_num						--充值金额
	self.fetch_flag = bit:d2b(protocol.fetch_flag)							--拿取标记
end

function KaiFuChargeData:GetDailyLeiJiFlagList()
	return self.fetch_flag
end

function KaiFuChargeData:GetChongZhiDaHuiKuiIsFirst()
	return self.is_first_chongzhi
end
--是否显示首冲图标
function KaiFuChargeData:GetFirstChongZhiIcon()
	return self.is_first_chongzhi == 1 and (self:GetChongZhiFlag(1) == 0)
end

function KaiFuChargeData:GetChongZhiDaHuiKuiNun()
	return self.chongzhi_num
end

function KaiFuChargeData:GetChongZhiFlag(seq)
	if self.fetch_flag then
		-- return bit:_and(1, bit:_rshift(self.fetch_flag, seq))
		return self.fetch_flag[33 - seq]
	end
end

function KaiFuChargeData:GetChongZhiActCfg()
	local chongzhi_cfg = RechargeData.Instance:GetChongzhiCfg()
	return chongzhi_cfg.oga_seven_day_total_chongzhi    -- 9788 行
end

function KaiFuChargeData:GetDailyChargeRemind()
	if self.is_first_leiji then
		return 1
	end
	return self:GetDailyChargeFlag() and 1 or 0
end

function KaiFuChargeData:GetDailyChargeFlag()
	local list = self.fetch_flag
	local reward_cfg = DailyChargeData.Instance:GetHuikuiRewardCfg()
	max_seq = #reward_cfg
	local index = 1
	for i = 1, max_seq do
		local need_chongzhi = reward_cfg[index] and reward_cfg[index].need_chongzhi or 0
		index = index + 1
		if list and list[33 - i] == 0 and self.chongzhi_num >= need_chongzhi then
			return true
		end
	end
	return false
end

function KaiFuChargeData:CheckRedEquipRedPoint()
	local is_get = RedEquipData.Instance:GetReward()
	if is_get then 
		return 1
	end
	return 0
end

------------------------- END ------------------------------------------

------------------------- 折扣 ------------------------------------
function KaiFuChargeData:GetDiscountCfg()
	if not discount_cfg then 
		self.discount_cfg = ConfigManager.Instance:GetAutoConfig("xufucili_auto")
	end
	return self.discount_cfg
end

-- 折扣礼包配置
function KaiFuChargeData:GetDiscountInfoCfg(gift_type)
	if gift_type ~= nil then
		if self.discount_gift_cfg[gift_type] ~= nil then
			return self.discount_gift_cfg[gift_type]
		end
	end
	return nil
end

-- 单个功能信息
function KaiFuChargeData:SetXufuInfo(protocol)
	self.xufu_info.active_stamp = protocol.active_stamp 					--该功能激活的时间
	self.xufu_info.gift_buy_num_list = protocol.gift_buy_num_list
	self.xufu_info.gift_type = protocol.gift_type
	self.xufu_info.is_sold_out = protocol.is_sold_out
	-- self.xufu_info.bind_gold_buy_times = protocol.bind_gold_buy_times		--绑元购买次数
	-- self.xufu_info.gold_buy_times = protocol.gold_buy_times 				--元宝购买次数
	-- self.xufu_info.RMB_buy_times = protocol.RMB_buy_times				--人民币购买次数
end

function KaiFuChargeData:GetItemBuyState()
	if self.reward_flags == nil then
		self.reward_flags = {}
		local index = 32
		for i = 0, 15 do
			self.reward_flags[i] = self.gift_sold_out_flag[index]
			index = index - 1
		end
	end

	local gift_type = self.xufu_info.gift_type or 0
	local is_sold_out = self.xufu_info.is_sold_out or 0

	if is_sold_out > 0 then
		self.reward_flags[gift_type] = is_sold_out
	end

	return self.reward_flags
end

function KaiFuChargeData:GetXuFuRemind()
	local buy_state = self:GetItemBuyState()
	if self.xu_fu_first_remind then
		for i = 0, #buy_state do
			if buy_state[i] == 0 then
				return 1
			end
		end
	end

	return 0
end

function KaiFuChargeData:SetXuFuRemind()
	self.xu_fu_first_remind = false
end

function KaiFuChargeData:GetXufuInfo()
	return self.xufu_info
end

-- 购买结果
function KaiFuChargeData:SetXufuBuyResult(protocol)
	self.xufu_buy_back_info.is_succ = protocol.is_succ								--购买是否成功
	self.xufu_buy_back_info.gift_type = protocol.gift_type
	self.xufu_buy_back_info.bind_gold_rest_buy_num = protocol.bind_gold_rest_buy_num
	self.xufu_buy_back_info.gold_rest_buy_num = protocol.gold_rest_buy_num
	self.xufu_buy_back_info.RMB_rest_buy_num = protocol.RMB_rest_buy_num
end

function KaiFuChargeData:GetXufuBuyResult()
	return self.xufu_buy_back_info
end

-- 所有功能开启时间戳
function KaiFuChargeData:SetXufuActivityOpenInfo(protocol)
	self.active_list_stamp = protocol.active_stamp 				--功能开启情况列表
	self.gift_sold_out_flag = bit:d2b(protocol.gift_sold_out_flag)
end

function KaiFuChargeData:GetXufuActivityOpenInfo()
	return self.active_list_stamp
end

-- 得到折扣开启功能Index
function KaiFuChargeData:GetDiscountOpenIndex()
	local list = {}
	local active_list_stamp = self:GetXufuActivityOpenInfo()
	if active_list_stamp and #active_list_stamp > 0 then 
		for i = 1, #active_list_stamp do
			local gift_info_cfg = self:GetDiscountInfoCfg(i - 1)
			if gift_info_cfg then
				local active_time = active_list_stamp[i] + gift_info_cfg[1].last_time
				if active_list_stamp[i] > 0 and TimeCtrl.Instance:GetServerTime() < active_time then
					local vo = {}
					vo.index = i - 1
					table.insert(list, vo)
				end
			end
		end
	end
	return list
end

------------------------- END ------------------------------------------

------------------------- 升星助力begin --------------------------------
function KaiFuChargeData:SetShengxingzhuliInfo(protocol)
	self.rsing_star_info.fetch_stall = protocol.fetch_stall
	self.rsing_star_info.chognzhi_today = protocol.chognzhi_today
	self.rsing_star_info.func_level = protocol.func_level
	self.rsing_star_info.func_type = protocol.func_type
	self.rsing_star_info.is_max_level = protocol.is_max_level
	self.rsing_star_info.max_stall = protocol.max_stall
end

function KaiFuChargeData:GetShengxingzhuliInfo()
	return self.rsing_star_info
end

function KaiFuChargeData:GetRisingStarCfg()
	if not self.rising_star_cfg then
		self.rising_star_cfg = ConfigManager.Instance:GetAutoConfig("shengxingzhuli_config_auto").other[1]
	end
	return self.rising_star_cfg
end

-- 根据系统类型获取相应的系统配置
function KaiFuChargeData:GetSystemConfigByType(system_type, cur_grade)
	local config = {}
	local tab = {}
	if SYSTEM_TYPE.MOUNT == system_type then 					--坐骑
		config = MountData.Instance:GetGradeCfg()
	elseif	SYSTEM_TYPE.WING == system_type then 				--羽翼
		config = WingData.Instance:GetGradeCfg()
	elseif SYSTEM_TYPE.FIGHT_MOUNT == system_type then 			--战斗坐骑
		config = FaZhenData.Instance:GetGradeCfg()
	elseif SYSTEM_TYPE.HALO == system_type then 				--光环
		config = HaloData.Instance:GetGradeCfg()
	elseif SYSTEM_TYPE.FABAO == system_type then 				--法宝（圣物）
		config = HalidomData.Instance:GetGradeCfg()
	elseif SYSTEM_TYPE.BEAUTY_HOLO == system_type then 			--美人光环
		config = BeautyHaloData.Instance:GetGradeCfg()
	elseif SYSTEM_TYPE.PIFENG == system_type then 				--披风
		config = ShenyiData.Instance:GetGradeCfg()
	else
		return tab
	end
	tab = config[cur_grade]
	return tab
end

-- 根据系统类型和形象ID获取相应的形象列表
function KaiFuChargeData:GetImageListByImageId(system_type, image_id)
	local image_list = {}
	if SYSTEM_TYPE.MOUNT == system_type then
		image_list = MountData.Instance:GetImageListInfo(image_id)
		return image_list
	elseif SYSTEM_TYPE.WING == system_type then
		image_list = WingData.Instance:GetImageListInfo(image_id)
		return image_list
	elseif SYSTEM_TYPE.FIGHT_MOUNT == system_type then
		image_list = FaZhenData.Instance:GetImageListInfo(image_id)
		return image_list
	elseif SYSTEM_TYPE.HALO == system_type then
		image_list = HaloData.Instance:GetImageListInfo(image_id)
		return image_list
	elseif SYSTEM_TYPE.FABAO == system_type then
		image_list = HalidomData.Instance:GetImageCfg(image_id)
	--	image_list = HalidomData.Instance:GetImageListInfo(image_id)
		return image_list
	elseif SYSTEM_TYPE.BEAUTY_HOLO == system_type then
		image_list = BeautyHaloData.Instance:GetImageListInfo(image_id)
		return image_list
	elseif SYSTEM_TYPE.PIFENG == system_type then
		image_list = ShenyiData.Instance:GetImageListInfo(image_id)
		return image_list
	else
		return image_list
	end
end

--升星助力红点
function KaiFuChargeData:CheckRisindRed()
	if self.rsing_star_info.fetch_stall == 1 or self.rsing_star_info.func_level <= 0 then return 0 end

	local cfg = self:GetRisingStarCfg()
	if self.rsing_star_info.chognzhi_today >= cfg.need_chongzhi then
		return 1
	else
		return 0
	end
end

function KaiFuChargeData:GetNeedChongzhiByStage(stage)
	local chongzhi = 0
	local cfg = self:GetRisingStarCfg()

	for i = 1, stage < 3 and stage or 3  do
		chongzhi = chongzhi + cfg["need_chongzhi_" .. i - 1]
	end

	if stage > 3 then
		chongzhi = chongzhi +  (stage - 3) * cfg.add_valus
	end

	return chongzhi
end

------------------------- 升星助力end ----------------------------------

--------------------每日排行-----------------------
function KaiFuChargeData:SetDayChongzhiRankInfo(protocol)
	self.day_chongzhi = protocol.gold_num
end

function KaiFuChargeData:GetDayChongZhiCount()
	return self.day_chongzhi or 0
end

function KaiFuChargeData:SetDailyChongZhiRank(rank_list)
	if rank_list then
		self.rank_list = rank_list
	end
end

function KaiFuChargeData:GetDailyChongZhiRank()
	return self.rank_list or {}
end

function KaiFuChargeData:SetRank(rank)
	self.rank_level = rank
end

function KaiFuChargeData:GetRank()
	return self.rank_level or 0
end

------------------------每日消费排行----------------------
function KaiFuChargeData:SetDayConsumeRankInfo(protocol)
	self.day_xiaofei = protocol.gold_num
end


function KaiFuChargeData:SetRATotalConsumeGoldInfo(protocol)
	self.total_consume_info.consume_gold = protocol.consume_gold
	self.total_consume_info.fetch_reward_flag = bit:d2b(protocol.fetch_reward_flag)
end

function KaiFuChargeData:GetRATotalConsumeGoldInfo()
	return self.total_consume_info	
end

function KaiFuChargeData:GetDayConsumeRankInfo()
	return self.day_xiaofei or 0
end

function KaiFuChargeData:SetDailyXiaoFeiRank(rank_list)
	if rank_list then
		self.xiaofei_rank_list = rank_list
	end
end

function KaiFuChargeData:GetDailyXiaoFeiRank()
	return self.xiaofei_rank_list or {}
end

function KaiFuChargeData:SetRankLevel(rank)
	self.xiaofei_rank_level = rank
end

function KaiFuChargeData:GetRankLevel()
	return self.xiaofei_rank_level or 0
end

-- 百倍商城（个人抢购信息）
function KaiFuChargeData:SetPersonalBuyInfo(buy_numlist)
	self.personal_buy_info = buy_numlist
end

function KaiFuChargeData:GetPersonalBuyInfo()
	return self.personal_buy_info
end

-----------------------------------------红装收集奖励---------------------------------------------
function  KaiFuChargeData:GetOtherCfg()--其他杂项配置
	return ConfigManager.Instance:GetAutoConfig("other_config_auto")
end

function KaiFuChargeData:GetRedEquipInfo()
	local info = self:GetOtherCfg().red_equip_show
	local data_list = {}
	for k , v in pairs(info) do
		if nil == data_list[v.seq] then
			data_list[v.seq] = {}
		end
		table.insert(data_list[v.seq], v)
	end
	return data_list
end

function KaiFuChargeData:GetFashionEquip(seq)
	local info = self:GetOtherCfg().red_equip_collect_act
	if info[seq] then
		return info[seq].reward_show
	end
	return -1
end

---------------------------始皇武库
function KaiFuChargeData:SetSCSuperDailyTotalChongzhiInfo(protocol)
	self.daily_chongzhi_num = protocol.daily_chongzhi_num
	self.fetch_times_list = protocol.fetch_times_list
end

function KaiFuChargeData:GetTodayConfig()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if open_day ~= self.cur_day then
		self.super_daily_config = {}
		local rand_activity_config = ServerActivityData.Instance:GetCurrentRandActivityConfig().super_daily_total_chongzhi
		-- 服务端设计成可以让策划在同一天配多档位
		for k,v in pairs(rand_activity_config) do
			if open_day == v.opengame_day then
				table.insert(self.super_daily_config, v)
			elseif open_day > GameEnum.NEW_SERVER_DAYS and open_day < v.opengame_day then
				table.insert(self.super_daily_config, v)
			end
		end
		self.cur_day = open_day
	end
	return self.super_daily_config
end

function KaiFuChargeData:CanGetReward()
	local config = self:GetTodayConfig()
	local need_chongzhi = 0
	for k,v in pairs(config) do
		local can_get_num = math.floor(self.daily_chongzhi_num / v.need_chongzhi)
		local get_num = self.fetch_times_list[v.seq] or 0
		if can_get_num > get_num then
			return true, v.seq, can_get_num - get_num
		end
		local next_need = v.need_chongzhi - (self.daily_chongzhi_num % v.need_chongzhi )
		need_chongzhi = need_chongzhi == 0 and v.need_chongzhi or need_chongzhi
		if need_chongzhi > next_need then
			need_chongzhi = next_need
		end
	end
	return false, need_chongzhi, 0
end

function KaiFuChargeData:IsCanGetReward()
	local can_get, param, can_get_times = KaiFuChargeData.Instance:CanGetReward()
	local max_times = KaiFuChargeData.Instance:GetPinkMaxTimes()
	if can_get then
		local now_get_num =  KaiFuChargeData.Instance:GetFetchTimesBySeq(param)
		if now_get_num >= max_times then
			can_get_times = 0
		end
		if now_get_num + can_get_times > max_times then
			can_get_times = max_times - now_get_num
		end
	end
	return can_get_times > 0
end

function KaiFuChargeData:GetDailyCHongZhiNum()
	return self.daily_chongzhi_num or 0
end

function KaiFuChargeData:GetPinkMaxTimes()
	local today_config = self:GetTodayConfig()[1]
	if today_config then
		return today_config.can_fetch_times or 0
	end
	return 0
end

function KaiFuChargeData:GetFetchTimesBySeq(seq)
	return self.fetch_times_list[seq] or 0
end


------------------累计充值--------------------

function KaiFuChargeData:SetLeiJiChongZhiInfo(protocol)
	self.leiji_chongzhi_info.total_charge_value = protocol.total_charge_value
	self.leiji_chongzhi_info.reward_has_fetch_flag = protocol.reward_has_fetch_flag
end

function KaiFuChargeData:GetLeiJiChongZhiInfo()
	return self.leiji_chongzhi_info
end

-- 累计充值(2091)配置
function KaiFuChargeData:GetLeiJiChongZhiCfg()
	local list = {}
	for k,v in pairs(PlayerData.Instance:GetCurrentRandActivityConfig().rand_total_chongzhi) do
		if v.opengame_day <= 7 and v.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE then
			table.insert(list, v)
		end
	end
	table.sort(list, function(a, b)
		return a.seq < b.seq
	end)

	return list
end

function KaiFuChargeData:GetLeijiChongZhiFlagCfg()
	local list = self:GetLeiJiChongZhiCfg()
	local total_charge_value = self.leiji_chongzhi_info.total_charge_value or 0
	local temp_list = {}
	for k, v in pairs(list) do
		local temp_data = {}
		if v.need_chognzhi <= total_charge_value and not self:IsGetLeiJiChongZhiReward(v.seq) then
			temp_data.flag = 2
		elseif v.need_chognzhi <= total_charge_value and self:IsGetLeiJiChongZhiReward(v.seq) then
			temp_data.flag = 0
		else
			temp_data.flag = 1
		end
		temp_data.seq = v.seq
		temp_list[v.seq] = temp_data
	end

	return temp_list
end

-- 是否领取累计充值奖励
function KaiFuChargeData:IsGetLeiJiChongZhiReward(seq)
	if not seq then return false end

	local reward_has_fetch_flag = self.leiji_chongzhi_info.reward_has_fetch_flag

	if not reward_has_fetch_flag then return false end

	local sif_list = bit:d2b(reward_has_fetch_flag)

	for k, v in pairs(sif_list) do
		if 1 == v and (32 - k) == seq then
			return true
		end
	end

	return false
end

function KaiFuChargeData:GetOpenActTotalChongZhiReward()
	local info = self:GetLeiJiChongZhiInfo()
	local fetch_reward_t = bit:d2b(info.reward_has_fetch_flag) or {}

	--local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().total_gold_consume
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().rand_total_chongzhi
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE)
	local list = {}
	for i,v in ipairs(cfg) do
		local reward_has_fetch_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
		local data = TableCopy(v)
		data.reward_has_fetch_flag = reward_has_fetch_flag
		table.insert(list, data)
	end
	table.sort(list, SortTools.KeyLowerSorter("reward_has_fetch_flag", "need_chognzhi"))
	return list
end

function KaiFuChargeData:IsTotalChongZhiRemind()
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_TOTAL_CHONGZHI) then
		return false
	end
	local info = self:GetLeiJiChongZhiInfo()
	local list = self:GetOpenActTotalChongZhiReward()
	for i,v in ipairs(list) do
		if v.reward_has_fetch_flag == 0 then
			if info.total_charge_value >= v.need_chognzhi then
				return true
			end
		end
	end
	return false
	
end

function KaiFuChargeData:GetIsTotalChongZhiRemind()
	local remind_num = self:IsTotalChongZhiRemind() and 1 or 0
	--ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_TOTAL_CHONGZHI, remind_num > 0)
	return remind_num
end

function KaiFuChargeData:GetOpenNewTotalChongZhiReward()
	local info = self:GetNewTotalChongZhiInfo()
	local reward_fetch_flag = info.reward_fetch_flag and info.reward_fetch_flag or 0
	local fetch_reward_t = bit:d2b(reward_fetch_flag)

	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().daily_total_chongzhi
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAILY_TOTAL_CHONGZHI)
	local list = {}

	local spid = GLOBAL_CONFIG.package_info.config.agent_id
	local agent_cfg = ConfigManager.Instance:GetAutoConfig("agent_adapt_auto").shield_accumulate_recharge
	local shield = 0
	local charge_level = 0
	local total_charge = 0
	local shield_charge = 0
	local need_check = false
	for _, v in pairs(agent_cfg) do
		if v.spid == spid then
			shield_charge = v.day_charge_feedback
			need_check = true
			break
		end
	end

	if self.leiji_new_chongzhi_info ~= nil and self.leiji_new_chongzhi_info.chongzhi_num ~= nil then
		charge_level = self.leiji_new_chongzhi_info.chongzhi_num > shield_charge and self.leiji_new_chongzhi_info.chongzhi_num or shield_charge
		total_charge = self.leiji_new_chongzhi_info.chongzhi_num
	end

	local cur_day = ActivityData.Instance:GetActDayPassFromStart(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAILY_TOTAL_CHONGZHI) + 1

	for i,v in ipairs(cfg) do
		if v.day_index == cur_day then
			local reward_new_fetch_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
			local data = TableCopy(v)
			data.reward_new_fetch_flag = reward_new_fetch_flag
			if need_check and (v.need_chongzhi <= charge_level or v.pre_chongzhi <= total_charge) then
				table.insert(list, data)
			elseif not need_check then
				table.insert(list, data)
			end
		end
	end

	table.sort(list, SortTools.KeyLowerSorter("reward_new_fetch_flag", "need_chongzhi"))

	return list
end

------------------累计充值--------------------

function KaiFuChargeData:SetNewTotalChongZhiInfo(protocol)
	self.leiji_new_chongzhi_info.chongzhi_num = protocol.chongzhi_num
	self.leiji_new_chongzhi_info.reward_fetch_flag = protocol.reward_fetch_flag
end

function KaiFuChargeData:GetNewTotalChongZhiInfo()
	return self.leiji_new_chongzhi_info
end

function KaiFuChargeData:FlushNewTotalConsumeHallRedPoindRemind()
	local remind_num = self:IsNewTotalConsumeRedPoint() and 1 or 0
	ActivityData.Instance:SetActivityRedPointState(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAILY_TOTAL_CHONGZHI, remind_num > 0)
	return remind_num
end

function KaiFuChargeData:IsNewTotalConsumeRedPoint()
	if not ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAILY_TOTAL_CHONGZHI) then
		return false
	end

	local info = self:GetNewTotalChongZhiInfo()
	local fetch_reward_t = bit:d2b(info.reward_fetch_flag) or {}

	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().daily_total_chongzhi
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAILY_TOTAL_CHONGZHI)
	local flag = false
	for i,v in ipairs(cfg) do
	local fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
		if 0 == fetch_reward_flag and info.chongzhi_num and info.chongzhi_num >= v.need_chongzhi then
			flag = true
			return flag
		end
	end
	return flag
end

function KaiFuChargeData:SetSCFenqizhizhuiAllInfo(protocol)
	self.fenqi_info.func_type = protocol.func_type
	self.fenqi_info.func_grade = protocol.func_grade
	self.fenqi_info.func_is_max_grade = protocol.func_is_max_grade
	self.fenqi_info.is_fetch = protocol.is_fetch
	self.fenqi_info.today_chongzhi_num = protocol.today_chongzhi_num
end

function KaiFuChargeData:GetFenQiInfo()
	return self.fenqi_info
end

function KaiFuChargeData:GetFenQiCfg()
	local config = ConfigManager.Instance:GetAutoConfig("fenqizhizhui_cfg_auto").chongzhi_uplevel_cfg
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	for k,v in pairs(config) do
		if cur_day >= v.beg_opengame_day and cur_day <= v.end_opengame_day then
			return v
		end
	end
	return {}
end

function KaiFuChargeData:SetRARedEnvelopeGiftInfo(protocol)
	self.seven_day_consume_gold_num_list = protocol.consume_gold_num_list
	self.seven_day_reward_flag = bit:d2b(protocol.reward_flag)
end

function KaiFuChargeData:IsShowSevenDayActivity()
	for i,v in ipairs(self.seven_day_consume_gold_num_list) do
		if v ~= 0 and self.seven_day_reward_flag[33 - i] == 0 then
			return true
		end
	end
	return false
end

function KaiFuChargeData:IsRewardSeven(seq)
	if self.seven_day_reward_flag and self.seven_day_reward_flag[33 - seq]then
		return self.seven_day_reward_flag[33 - seq]
	end
	return 1
end

function KaiFuChargeData:IsRewardSevenRedPoindRemind()
	local remind_num = self:IsRewardSevenRedPoint() and 1 or 0
	return remind_num
end

function KaiFuChargeData:IsRewardSevenRedPoint()
	if TimeCtrl.Instance:GetCurOpenServerDay() <= GameEnum.NEW_SERVER_DAYS then
		return false
	end

	for i,v in ipairs(self.seven_day_consume_gold_num_list) do
		if v ~= 0 and self.seven_day_reward_flag[33 - i] == 0 then
			return true
		end
	end

	return false
end

function KaiFuChargeData:SetMeiRiLiBaoInfo(protocol)
	self.libao_list.buy_num_list = protocol.buy_num_list
	self.libao_list.buy_fetch = protocol.buy_fetch
	self.libao_list.has_open_view = protocol.has_open_view
	self.libao_list.xiangoulibao_reserve = protocol.xiangoulibao_reserve
end

function KaiFuChargeData:GetLiBaoBuyNum()
	return self.libao_list.buy_num_list
end

function KaiFuChargeData:GetHasOpenView()
	return self.libao_list.has_open_view
end
function KaiFuChargeData:GetLiBaoBuyFetch()
	return self.libao_list.buy_fetch
end

function KaiFuChargeData:GetLiBaoReserve(index)
	return self.libao_list.xiangoulibao_reserve
end

function KaiFuChargeData:GetXianGouLiBaoConfig()
	return ConfigManager.Instance:GetAutoConfig("randactivityconfig_1_auto")
end

function KaiFuChargeData:GetDailyXianGouLiBaoCfg()
	local cfg = self:GetXianGouLiBaoConfig()
	if cfg then
		return cfg.daily_xiangoulibao
	end
end

function KaiFuChargeData:GetKaiFuInFo(index)
	local cfg = self:GetDailyXianGouLiBaoCfg()
	local svene_day = ListToMap(cfg,"index")
	if cfg and svene_day[index] then
		return svene_day[index]
	end
	return nil
end

function KaiFuChargeData:GetCoinCfg()
	local cfg = self:GetXianGouLiBaoConfig()
	if cfg then
		return cfg.other
	end
	return nil
end

function KaiFuChargeData:GetXianGouRedPoint()
	local is_open = OpenFunData.Instance:CheckIsHide("daily_xiangoulibao")
	if is_open and self.libao_list.buy_fetch == 0 then
		return 1
	end
	return 0
end

function KaiFuChargeData:DailyLovePrecent()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().other
	local rand_t = {}
	local day = nil
	for k,v in ipairs(cfg) do
		if v and v.opengame_day and (nil == day or v.opengame_day == day) and open_day <= v.opengame_day then
			day = v.opengame_day
			table.insert(rand_t, v)
		end
	end
	local temp_data = rand_t[1] and rand_t[1].daily_love_reward_precent or 50
	return temp_data
end

function KaiFuChargeData:SetSuperChargeFeedback(protocol)
	self.super_charge_feedback.prize_times_remainder = protocol.prize_times_remainder
	self.super_charge_feedback.prize_reward_flag = bit:d2b(protocol.prize_reward_flag)
	self.super_charge_feedback.prize_reward_times_run_out_flag = bit:d2b(protocol.prize_reward_times_run_out_flag)
end

function KaiFuChargeData:GetSuperChargeCfg()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().single_charge_prize_2
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local act_day = ActivityData.GetActivityDays(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPER_CARGE_FEEDBACK)
	local cfg_list = {}
	local day_break = nil
	for _, v in pairs(cfg) do
		if cur_day <= v.opengame_day and v.activity_day == act_day then
			if day_break == nil then
				day_break = v.opengame_day
			elseif day_break ~= v.opengame_day then
				break
			end
			
			table.insert(cfg_list, TableCopy(v))
		end

	end

	return cfg_list
end

function KaiFuChargeData:GetSuperChargeRewards()
	if next(self.super_charge_feedback.prize_times_remainder) == nil or next(self.super_charge_feedback.prize_reward_times_run_out_flag) == nil then
		return {}
	end

	local reward_list = self:GetSuperChargeCfg()
	for i = 1, #reward_list do
		local up_flag = 1
		local down_flag = 0
		reward_list[i].remainder_times = self.super_charge_feedback.prize_times_remainder[i]
		reward_list[i].run_out_flag = self.super_charge_feedback.prize_reward_times_run_out_flag[33 - i]
		if reward_list[i].remainder_times > 0 and reward_list[i].run_out_flag == 0 then
			up_flag = 0
		end

		if reward_list[i].remainder_times <= 0 then
			down_flag = 1
		end
		reward_list[i].up_flag = up_flag
		reward_list[i].down_flag = down_flag
	end
	table.sort(reward_list, SortTools.KeyLowerSorters("up_flag", "down_flag", "charge_count"))
	
	return reward_list
end

function KaiFuChargeData:GetShieldSuperChargeRewards()
	local new_list = {}
	local reward_list = self:GetSuperChargeRewards()
	local spid = GLOBAL_CONFIG.package_info.config.agent_id
	local agent_cfg = ConfigManager.Instance:GetAutoConfig("agent_adapt_auto").shield_accumulate_recharge
	local shield_charge = 0
	local need_check = false
	for _, v in pairs(agent_cfg) do
		if v.spid == spid then
			if v.single_charge_prize_2 and v.single_charge_prize_2 ~= "" then
				shield_charge = v.single_charge_prize_2
				need_check = true
			end
			break
		end
	end
	for i = 1, #reward_list do
		if need_check and shield_charge > reward_list[i].charge_count then
			table.insert(new_list, reward_list[i])
		elseif not need_check then
			table.insert(new_list, reward_list[i])
		end
	end

	return new_list
end

function KaiFuChargeData:GetSuperChargeRemind()
	local remind_num = 0
	if next(self.super_charge_feedback) ~= nil then
		local reward_list = self:GetShieldSuperChargeRewards()
		for i = 1, #reward_list do
			if reward_list[i].remainder_times > 0 and reward_list[i].run_out_flag == 0 then
				remind_num = 1
				break
			end
		end
	end
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPER_CARGE_FEEDBACK, remind_num > 0)
	
	return remind_num
end

function KaiFuChargeData:GetSuperChargeActEndTime()
	local act_status = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPER_CARGE_FEEDBACK) or 0
	local server_time = TimeCtrl.Instance:GetServerTime() or 0
	local act_last_time = act_status.end_time - server_time

	return act_last_time
end