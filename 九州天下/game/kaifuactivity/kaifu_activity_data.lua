KaifuActivityData = KaifuActivityData or BaseClass()

-- 开服活动操作类型
RA_OPEN_SERVER_OPERA_TYPE = {
	RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO = 0,			-- 请求信息
	RA_OPEN_SERVER_OPERA_TYPE_FETCH = 1,			-- 领取奖励
	RA_OPEN_SERVER_OPERA_TYPE_REQ_BOSS_INFO = 2,	-- 获取boss猎手信息
	RA_OPEN_SERVER_OPERA_TYPE_FETCH_BOSS = 3,		-- 领取boss猎手奖励
	RA_OPEN_SERVER_OPERA_TYPE_FETCH_BATTE_INFO = 4,	-- 请求开服争霸信息
}

-- 百倍商城(个人抢购)
RA_PERSONAL_PANIC_BUY_OPERA_TYPE = {
	RA_PERSONAL_PANIC_BUY_OPERA_TYPE_QUERY_INFO = 0,
	RA_PERSONAL_PANIC_BUY_OPERA_TYPE_BUY_ITEM = 1,
}


RA_OPEN_SERVER_ACTIVITY_TYPE = {
	RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE = 2091,			-- 7天累积充值(开服活动))
	RAND_ACTIVITY_TYPE_ROLE_UPLEVEL = 2128,					-- 冲级大礼(开服活动)
	RAND_ACTIVITY_TYPE_PATA = 2129,							-- 勇者之塔(开服活动)
	RAND_ACTIVITY_TYPE_EXP_FB = 2130,						-- 经验副本(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_MOUNT = 2131,				-- 坐骑进阶(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_HALO = 2132,					-- 光环进阶(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_WING = 2133,					-- 羽翼进阶(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_SHENGONG = 2134,				-- 神弓进阶(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_SHENYI = 2135,				-- 神翼进阶(开服活动)
	RAND_ACTIVITY_TYPE_FIRST_CHARGE_TUAN = 2136,			-- 首充团购(开服活动)
	RAND_ACTIVITY_TYPE_DAY_TOTAL_CHARGE = 2137,				-- 每日累计充值(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_MOUNT_TOTAL = 2138,			-- 全服坐骑进阶(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_HALO_TOTAL = 2139,			-- 全服光环进阶(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_WING_TOTAL = 2140,			-- 全服羽翼进阶(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_SHENGONG_TOTAL = 2141,		-- 全服神弓进阶(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_SHENYI_TOTAL = 2142,			-- 全服神翼进阶(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_MOUNT_RANK = 2143,			-- 坐骑进阶榜(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_HALO_RANK = 2144,			-- 光环进阶榜(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_WING_RANK = 2145,			-- 羽翼进阶榜(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_SHENGONG_RANK = 2146,		-- 神弓进阶榜(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_SHENYI_RANK = 2147,			-- 神翼进阶榜(开服活动)
	RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN = 2148,				-- 装备强化(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE = 2149,				-- 宝石升级(开服活动)
	RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN_RANK = 2150,		-- 装备强化冲榜(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE_RANK = 2151,		-- 宝石等级冲榜(开服活动)
	RAND_ACTIVITY_TYPE_BOSS_LIESHOU = 2152,					-- boss猎手(开服活动)
	RAND_ACTIVITY_TYPE_ZHENG_BA = 2153,						-- 开服争霸(开服活动)
	RAND_ACTIVITY_TYPE_SUPPER_GIFT = 2158,					-- 开服礼包限购(开服活动)
	RAND_ACTIVITY_TYPE_HUNDER_TIMES_SHOP = 2056,			-- 开服百倍商城(开服活动)
	RAND_ACTIVITY_TYPE_MARRY_ME = 2156,						-- 我们结婚吧
	RAND_ACTIVITY_TYPE_ROB_KING = 2165,						-- 抢国君

	RAND_ACTIVITY_TYPE_HONG_BAO = 2170, 					-- 7日红包
	RAND_ACTIVITY_TYPE_CHARGE_REPALMENT = 2081,				-- 累充返利
	RAND_ACTIVITY_TYPE_DANBI_CHONGZHI = 2082,				-- 单笔充值
	RAND_ACTIVITY_TYPE_DAY_CHONGZHI_RANK = 2089, 			-- 每日充值排行榜
	RAND_ACTIVITY_TYPE_DAY_XIAOFEI_RANK = 2090, 			-- 每日消费排行榜
	RAND_ACTIVITY_TYPE_DAY_ACTIVIE_DEGREE = 2052, 			-- 日常活跃奖励
	RAND_ACTIVITY_TYPE_TOTAL_CONSUME = 2051, 	  	      	-- 累计消费
	RAND_ACTIVITY_TYPE_SINGLE_CHARGE_2 = 2181,				-- 单笔大放送(极速冲战)
	RAND_ACTIVITY_TYPE_DAILY_TOTAL_CHONGZHI = 2187,		-- 每日累冲
	RAND_ACTIVITY_TYPE_APPRECIATION_REWARD = 2195,		-- 感恩回馈
}

AdvanceType = {
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_MOUNT,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_HALO,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENGONG,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENYI,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_MOUNT_TOTAL,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_HALO_TOTAL,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENGONG_TOTAL,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENYI_TOTAL,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING_TOTAL,
}

ChongzhiType = {
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIRST_CHARGE_TUAN,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_TOTAL_CHARGE,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE,
}

RankType = {
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_MOUNT_RANK,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_HALO_RANK,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING_RANK,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENGONG_RANK,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENYI_RANK,
}

StrengthenType = {
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN_RANK,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE_RANK,
}

NormalType = {
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ROLE_UPLEVEL,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PATA,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_FB,
}

BossType = {
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BOSS_LIESHOU,
}

BattleType = {
	YUAN_SU_ZHANCHANG = 1,			-- 元素战场
	GUILD_BATTLE  =2,				-- 公会争霸
	GONG_CHENG_ZHAN = 3,			-- 攻城战
	TERRITORYWARU = 4,				-- 领土战
}

-- 开服争霸每个子活动ID
BattleActivityId = {
	[BattleType.YUAN_SU_ZHANCHANG] = 5,		-- 元素战场
	[BattleType.GUILD_BATTLE] = 21,			-- 公会争霸
	[BattleType.GONG_CHENG_ZHAN] = 6,		-- 攻城战
	[BattleType.TERRITORYWARU] = 19,		-- 领土战
}

RA_WAR_GOAL_REQ_TYPE = {
	RA_WAR_GOAL_REQ_TYPE_ALL_INFO = 0,
	RA_WAR_GOAL_REQ_TYPE_FETCH_REWARD = 1,           -- 拿取奖励  参数1：拿取任务类型
	RA_WAR_GOAL_REQ_TYPE_FETCH_FINAL_REWARD = 2,	 -- 拿取最终奖励
	RA_WAR_GOAL_REQ_TYPE_MAX = 3,
}

TEMP_ADD_ACT_TYPE = {
	WELFARE_LEVEL_ACTIVITY_TYPE = 9000,		-- 冲级豪礼
}

TempAddActivityType = {
	-- {activity_type = TEMP_ADD_ACT_TYPE.WELFARE_LEVEL_ACTIVITY_TYPE, name = Language.Activity.WelfareLevel},
}

RA_TOTAL_CHARGE_OPERA_TYPE_KAIFU = {
	RA_TOTAL_CHARGE_OPERA_TYPE_QUERY_INFO = 0,
	RA_TOTAL_CHARGE_OPERA_TYPE_FETCH_REWARD = 1,
 }

RA_DAILY_TOTAL_CHONGZHI_OPERA_TYPE = {
	RA_DAILY_TOTAL_CHONGZHI_OPERA_TYPE_ALL_INFO = 0,
	RA_DAILY_TOTAL_CHONGZHI_OPERA_TYPE_FETCH_REWARD = 1,
}

local MAX_ACTIVITY_TYPE = 29 	-- 最大活动数

-- 开服活动排序
local ACTIVITY_SORT_INDEX_LIST = {
	[1] = TEMP_ADD_ACT_TYPE.WELFARE_LEVEL_ACTIVITY_TYPE,
	[2] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BOSS_LIESHOU,
	[3] = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION,
	[4] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPPER_GIFT,
	[5] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUNDER_TIMES_SHOP,
}

local ACTIVITY_TYPE_TO_PANEL_INDEX = {
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION] = 6,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE] = 7,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPPER_GIFT] = 8,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUNDER_TIMES_SHOP] = 9,
	[TEMP_ADD_ACT_TYPE.WELFARE_LEVEL_ACTIVITY_TYPE] = 10,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BOSS_XUANSHANG] = 11,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WAR_GOALS] = 12,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHUJUN_GIFT] = 13,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MARRY_GIFT] = 14,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAILY_NATION_WAR] = 15,
	[ACTIVITY_TYPE.RAND_DAY_ACTIVIE_DEGREE] = 16,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_REFINE] = 17,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CONSUME] = 20,
}

OPEN_SERVER_RA_ACTIVITY_TYPE = {
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CONSUME,
}

KaifuActivityType = {TYPE = 1025}

function KaifuActivityData:__init()
	if KaifuActivityData.Instance ~= nil then
		print_error("[KaifuActivityData] Attemp to create a singleton twice !")
		return
	end
	KaifuActivityData.Instance = self
	self.info = {}
	self.upgrade_info = {}
	self.rank_info = {}
	self.boss_lieshou_info = {}
	self.battle_uid_info = {}
	self.battle_role_info = {}
	self.battle_activity_info = {}
	self.act_change_callback = {}
	self.personal_buy_info = {}
	self.collect_exchange_info = {}
	self.boss_xuanshang_info = {}
	self.war_goal_info = {}
	self.cur_national_type = 0
	self.total_consume_info = {}
	self.total_chongzhi_info = {}
	self.thanks_feed_back_fetch = {}
	self.thanks_feed_back_data = {}
	self.thanks_feed_back_time = {}
	self.thanks_reward_cfg = {}


	-- self.open_cfg = ConfigManager.Instance:GetAutoConfig("randactivityopencfg_auto").open_cfg
	-- self.randactivityconfig_1_cfg = PlayerData.Instance:GetCurrentRandActivityConfig()--ConfigManager.Instance:GetAutoConfig("randactivityconfig_1_auto")
	-- self.activity_reward_cfg = self.randactivityconfig_1_cfg.openserver_reward
	-- self.opengameactivity_cfg = ConfigManager.Instance:GetAutoConfig("opengameactivity_auto")
	-- self.personal_panic_buy_cfg = self.randactivityconfig_1_cfg.personal_panic_buy
	-- self.activity_reward_cfg = ConfigManager.Instance:GetAutoConfig("randactivityconfig_1_auto")
	-- self.openserver_reward_cfg = ListToMapList(self.activity_reward_cfg.openserver_reward, "activity_type")
	self.leiji_chongzhi_info = {}

	self.zhengba_red_point_state = true
	self.is_first = true
	RemindManager.Instance:Register(RemindName.KaiFu, BindTool.Bind(self.GetNewServerRemind, self))
	RemindManager.Instance:Register(RemindName.KfLeichong, BindTool.Bind(self.GetKfLeichongRemind, self))
	RemindManager.Instance:Register(RemindName.KaiFuLeiJiReward, BindTool.Bind(self.FlushLeiJiChargeRewardRedPoint, self))
	RemindManager.Instance:Register(RemindName.KaiFuTotalReward, BindTool.Bind(self.FlushTotalConsumeHallRedPoindRemind, self))
	RemindManager.Instance:Register(RemindName.LianChongTeHuiChu, BindTool.Bind(self.LianChongTeHuiChuHongDian, self))
	RemindManager.Instance:Register(RemindName.LianChongTeHuiGao, BindTool.Bind(self.LianChongTeHuiGaoHongDian, self))
	RemindManager.Instance:Register(RemindName.WarGoals, BindTool.Bind(self.GetWarGoalsRedPoint, self))
	RemindManager.Instance:Register(RemindName.KaiFuIsFirst, BindTool.Bind(self.CheckKaiFuRedPoint, self))
	RemindManager.Instance:Register(RemindName.RemindGroupBuyRedpoint, BindTool.Bind(self.GetGroupBuyRedpoint, self))
	RemindManager.Instance:Register(RemindName.ThanksFeedBackRedPoint, BindTool.Bind(self.GetThanksFeedBackRedpoint, self))
end

function KaifuActivityData:__delete()
	RemindManager.Instance:UnRegister(RemindName.KaiFu)
	RemindManager.Instance:UnRegister(RemindName.KfLeichong)
	RemindManager.Instance:UnRegister(RemindName.KaiFuLeiJiReward)
	RemindManager.Instance:UnRegister(RemindName.KaiFuTotalReward)
	RemindManager.Instance:UnRegister(RemindName.LianChongTeHuiChu)
	RemindManager.Instance:UnRegister(RemindName.LianChongTeHuiGao)
	RemindManager.Instance:UnRegister(RemindName.WarGoals)
	RemindManager.Instance:UnRegister(RemindName.KaiFuIsFirst)
	RemindManager.Instance:UnRegister(RemindName.RemindGroupBuyRedpoint)
	RemindManager.Instance:UnRegister(RemindName.ThanksFeedBackRedPoint)

	self.info = {}
	self.upgrade_info = {}
	self.rank_info = {}
	self.boss_lieshou_info = {}
	self.activity_reward_cfg = {}
	self.opengameactivity_cfg = {}
	self.battle_uid_info = {}
	self.open_cfg = {}
	self.battle_role_info = {}
	self.battle_activity_info = {}
	self.act_change_callback = {}
	self.leiji_chongzhi_info = {}
	KaifuActivityData.Instance = nil
	self.boss_xuanshang_info = {}
	self.war_goal_info = {}
	self.thanks_feed_back_fetch = nil
	self.thanks_feed_back_data = nil
	self.thanks_feed_back_time = nil
	self.thanks_reward_cfg = nil
end

function KaifuActivityData:ClearActivityInfo()
	self.info = {}
	self.battle_uid_info = {}
	self.battle_role_info = {}
end

-- 开服活动信息
function KaifuActivityData:SetActivityInfo(protocol)
	local type_info = {}
	type_info.rand_activity_type = protocol.rand_activity_type
	type_info.reward_flag = protocol.reward_flag
	type_info.complete_flag = protocol.complete_flag
	type_info.today_chongzhi_role_count = protocol.today_chongzhi_role_count
	self.info[type_info.rand_activity_type] = type_info
	RemindManager.Instance:Fire(RemindName.RemindGroupBuyRedpoint)
end

function KaifuActivityData:GetOpenServerRewardCfg()
	if self.openserver_reward_cfg == nil then
		local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
		self.openserver_reward_cfg = ListToMapList(cfg.openserver_reward, "activity_type")
	end
	return self.openserver_reward_cfg
end

function KaifuActivityData:GetActivityInfo(rand_activity_type)
	return self.info[rand_activity_type]
end

-- 开服活动-累计消费奖励
function KaifuActivityData:GetOpenActTotalConsumeReward()
	local info = self:GetRATotalConsumeGoldInfo()
	local fetch_reward_t = info.fetch_reward_flag or {}

	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().total_gold_consume
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CONSUME)
	local list = {}
	for i,v in ipairs(cfg) do
	local fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
		local data = TableCopy(v)
		data.fetch_reward_flag = fetch_reward_flag
		table.insert(list, data)
	end
	table.sort(list, SortTools.KeyLowerSorter("fetch_reward_flag", "need_consume_gold"))
	return list
end

function KaifuActivityData:FlushTotalConsumeHallRedPoindRemind()
	local remind_num = self:IsTotalConsumeRedPoint() and 1 or 0
	ActivityData.Instance:SetActivityRedPointState(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CONSUME, remind_num > 0)
	return remind_num
end

function KaifuActivityData:GetRATotalConsumeGoldInfo()
	return self.total_consume_info
end

function KaifuActivityData:GetRATotalChongZhiGoldInfo()
	return self.total_chongzhi_info
end

function KaifuActivityData:IsTotalConsumeRedPoint()
	if not ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CONSUME) then
		return false
	end

	local info = KaifuActivityData.Instance:GetRATotalConsumeGoldInfo()
	local fetch_reward_t = info.fetch_reward_flag or {}

	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().total_gold_consume
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CONSUME)
	local flag = false
	for i,v in ipairs(cfg) do
	local fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
		if 0 == fetch_reward_flag and info.consume_gold and info.consume_gold >= v.need_consume_gold then
			flag = true
			return flag
		end
	end
	return flag
end

function KaifuActivityData:SetRATotalConsumeGoldInfo(protocol)
	self.total_consume_info.consume_gold = protocol.consume_gold
	self.total_consume_info.fetch_reward_flag = bit:d2b(protocol.fetch_reward_flag)
end

-- 开服进阶信息
function KaifuActivityData:SetActivityUpgradeInfo(protocol)
	local type_info = {}
	type_info.rand_activity_type = protocol.rand_activity_type
	type_info.total_upgrade_record_list = protocol.total_upgrade_record_list
	self.upgrade_info[type_info.rand_activity_type] = type_info
end

function KaifuActivityData:GetActivityUpgradeInfo(rand_activity_type)
	return self.upgrade_info[rand_activity_type]
end

-- 开服进阶排行榜信息
function KaifuActivityData:SetOpenServerRankInfo(protocol)
	local type_info = {}
	type_info.rand_activity_type = protocol.rand_activity_type
	type_info.myself_rank = protocol.myself_rank
	type_info.top1_uid = protocol.top1_uid
	type_info.role_name = protocol.role_name
	type_info.role_sex = protocol.role_sex
	type_info.role_prof = protocol.role_prof
	type_info.top1_param = protocol.top1_param
	self.rank_info[type_info.rand_activity_type] = type_info
end

function KaifuActivityData:GetOpenServerRankInfo(rand_activity_type)
	return self.rank_info[rand_activity_type]
end

-- 开服活动boss猎手信息
function KaifuActivityData:SetBossLieshouInfo(protocol)
	self.boss_lieshou_info.oga_kill_boss_reward_flag = protocol.oga_kill_boss_reward_flag
	self.boss_lieshou_info.oga_kill_boss_flag_hight = protocol.oga_kill_boss_flag_hight
	self.boss_lieshou_info.oga_kill_boss_flag_low = protocol.oga_kill_boss_flag_low
end

function KaifuActivityData:GetBossLieshouInfo()
	return self.boss_lieshou_info
end

-- 开服活动战场争霸信息
function KaifuActivityData:SetBattleUidInfo(protocol)
	self.battle_uid_info[BattleType.YUAN_SU_ZHANCHANG] = protocol.yuansu_uid
	self.battle_uid_info[BattleType.GUILD_BATTLE] = protocol.guildbatte_uid
	self.battle_uid_info[BattleType.GONG_CHENG_ZHAN] = protocol.gongchengzhan_uid
	self.battle_uid_info[BattleType.TERRITORYWARU] = protocol.territorywar_uid
end

function KaifuActivityData:GetBattleUidInfo()
	return self.battle_uid_info
end

-- 开服活动战场争霸人物信息
function KaifuActivityData:SetBattleRoleInfo(ac_type, protocol)
	local temp_info = {}
	temp_info.role_name = protocol.role_name
	temp_info.appearance = protocol.appearance
	temp_info.wing_info = protocol.wing_info
	temp_info.prof = protocol.prof
	temp_info.sex = protocol.sex

	self.battle_role_info[ac_type] = protocol
end

function KaifuActivityData:GetBattleRoleInfo()
	return self.battle_role_info
end

-- 累计充值活动信息
function KaifuActivityData:SetLeiJiChongZhiInfo(protocol)
	self.leiji_chongzhi_info.total_charge_value = protocol.total_charge_value
	self.leiji_chongzhi_info.reward_has_fetch_flag = protocol.reward_has_fetch_flag
end

function KaifuActivityData:GetLeiJiChongZhiInfo()
	return self.leiji_chongzhi_info
end

-- 礼包限购活动信息
function KaifuActivityData:SetGiftShopFlag(protocol)
	self.oga_gift_shop_flag = protocol.oga_gift_shop_flag
end

function KaifuActivityData:GetGiftShopFlag()
	return bit:d2b(self.oga_gift_shop_flag or 0) or {}
end

-- 百倍商城（个人抢购信息）
function KaifuActivityData:SetPersonalBuyInfo(buy_numlist)
	self.personal_buy_info = buy_numlist
end

function KaifuActivityData:GetPersonalBuyInfo()
	return self.personal_buy_info
end

-- 集字活动兑换次数
function KaifuActivityData:SetCollectExchangeInfo(exchange_times)
	self.collect_exchange_info = exchange_times
end

function KaifuActivityData:GetCollectExchangeInfo()
	return self.collect_exchange_info
end


-- 战场争霸活动信息
function KaifuActivityData:SetActivityStatus(activity_type, status, next_time, start_time, end_time, open_type)
	self.battle_activity_info[activity_type] = {
		["type"] = activity_type,
		["status"] = status,
		["next_time"] = next_time,
		["start_time"] = start_time,
		["end_time"] = end_time,
		["open_type"] = open_type,
	}

	for k, v in pairs(self.act_change_callback) do
		v(activity_type, status, next_time, open_type)
	end
end

function KaifuActivityData:GetActivityStatuByType(activity_type)
	return self.battle_activity_info[activity_type]
end

-- 注册监听活动状态改变
function KaifuActivityData:NotifyActChangeCallback(callback)
	self.act_change_callback[callback] = callback
end

-- 取消注册
function KaifuActivityData:UnNotifyActChangeCallback(callback)
	self.act_change_callback[callback] = nil
end


-- 配置表
-- function KaifuActivityData:GetKaifuActivityCfg()
-- 	if not self.activity_reward_cfg then
-- 		self.activity_reward_cfg = PlayerData.Instance:GetCurrentRandActivityConfig().openserver_reward
-- 	end
-- 	return self.activity_reward_cfg
-- end

function KaifuActivityData:GetKaifuActivityOpenCfg()
	if not self.open_cfg then
		self.open_cfg = ConfigManager.Instance:GetAutoConfig("randactivityopencfg_auto").open_cfg
	end
	return self.open_cfg
end

-- 我们结婚吧配置表
function KaifuActivityData:GetZhenBaoGeCfg()
	if not self.zhenbaoge_cfg then
		self.zhenbaoge_cfg = PlayerData.Instance:GetCurrentRandActivityConfig().zhenbaoge
	end
	local config = ActivityData.Instance:GetRandActivityConfig(self.zhenbaoge_cfg, ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT)
	return config
end

-- 获取战场争霸称号配置
function KaifuActivityData:GetBattleTitleCfg()
	if not self.opengameactivity_cfg then
		self.opengameactivity_cfg = ConfigManager.Instance:GetAutoConfig("opengameactivity_auto")
	end
	return self.opengameactivity_cfg.zhanchang_zhengba
end

function KaifuActivityData:GetOpenGameActCfg()
	if not self.opengameactivity_cfg then
		self.opengameactivity_cfg = ConfigManager.Instance:GetAutoConfig("opengameactivity_auto")
	end
	return self.opengameactivity_cfg
end

function KaifuActivityData:GetPersonalActivityCfgBySeq(seq)
	local list = self:GetPersonalActivityCfg()

	for k, v in pairs(list) do
		if v.seq == seq then
			return v
		end
	end
	return nil
end

function KaifuActivityData:GetPersonalActivityCfgBuyItem(item_id)
	if not OpenFunData.Instance:CheckIsHide("kaifuactivityview") then
		return {}
	end
	local list = self:GetPersonalActivityCfg()
	local data_list = {}
	for k, v in pairs(list) do
		if ShenyiData.Instance:IsShenyiStuff(item_id) then
			for k1,v1 in pairs(ShenyiData.Instance:GetShenyiUpStarPropCfg()) do
				if v.reward_item.item_id == v1.up_star_item_id then
					table.insert(data_list, v)
				end
			end
		elseif ShengongData.Instance:IsShengongStuff(item_id) then
			for k1,v1 in pairs(ShengongData.Instance:GetShengongUpStarPropCfg()) do
				if v.reward_item.item_id == v1.up_star_item_id then
					table.insert(data_list, v)
				end
			end
		elseif v.reward_item.item_id == item_id then
			table.insert(data_list, v)
		end
	end
	return data_list
end

function KaifuActivityData:GetPersonalActivityCfg()
	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local list = {}
	if not self.personal_panic_buy_cfg then
		self.personal_panic_buy_cfg = PlayerData.Instance:GetCurrentRandActivityConfig().personal_panic_buy
	end

	local cur_day = nil
	-- for k, v in pairs(self.personal_panic_buy_cfg) do
	-- 	if server_day <= v.opengame_day then
	-- 		table.insert(list, v)
	-- 	end
	-- end

	-- for k, v in pairs(self.personal_panic_buy_cfg) do
	-- 	if server_day < v.opengame_day and cur_day == nil then
	-- 		cur_day = v.opengame_day
	-- 	end

	-- 	if cur_day ~= nil and v.opengame_day == cur_day then
	-- 		table.insert(list, v)
	-- 	end

	-- 	if cur_day ~= nil and cur_day < v.opengame_day then
	-- 		break
	-- 	end
	-- end
	for k,v in ipairs(self.personal_panic_buy_cfg) do
		if v and v.opengame_day and (nil == cur_day or v.opengame_day == cur_day) and server_day <= v.opengame_day then
			cur_day = v.opengame_day
			table.insert(list, v)
		end
	end

	return list
end

-- 获取百倍商城当天配置
function KaifuActivityData:GetPersonalActivitySortCfg()
	local list = self:GetPersonalActivityCfg()

	local sort_list = {}

	for k, v in pairs(self.personal_buy_info) do
		if list[k] then
			local temp_cfg = {}
			temp_cfg.seq = list[k].seq
			if v >= list[k].limit_buy_count then
				temp_cfg.flag = 0
			else
				temp_cfg.flag = 1
			end
			table.insert(sort_list, temp_cfg)
		end
	end

	table.sort(sort_list, function(a, b)
		if a.flag ~= b.flag then
			return a.flag > b.flag
		end
		return a.seq < b.seq
	end)

	return sort_list
end

-- 礼包限购配置
function KaifuActivityData:GetGiftShopCfg()
	local cfg = {}
	for k, v in pairs(self:GetOpenGameActCfg().gift_shop) do
		local temp_cfg = {}

		temp_cfg.reward_item_list = temp_cfg.reward_item_list or {}
		for k2, v2 in pairs(v) do
			if type(v2) == "table" and v2.item_id and v2.item_id > 0 then
				local data = {item_id = v2.item_id, num = v2.num, is_bind = v2.is_bind}
				local index = tonumber(string.sub(k2, -1))
				temp_cfg.reward_item_list[index + 1] = data
				-- table.insert(temp_cfg.reward_item_list, data)
			else
				temp_cfg[k2] = v2
			end
		end

		table.insert(cfg, temp_cfg)
	end
	table.sort(cfg, function(a, b)
		return a.seq < b.seq
	end)
	return cfg
end

function KaifuActivityData:GetKaifuActivityCfgByType(activity_type)
	local list = {}
	if activity_type == nil then return nil end
	local open_cfg = self:GetOpenServerRewardCfg()
	local cfg = open_cfg[activity_type]
	if cfg then
		for k, v in pairs(cfg) do
			if (tonumber(v.opengame_day) > 100 or tonumber(v.opengame_day) == server_day) then
				table.insert(list, v)
			end
		end
	end
	return list
end

function KaifuActivityData:IsKaifuActivity(activity_type)
	if not activity_type then return false end

	for k, v in pairs(self:GetKaifuActivityOpenCfg()) do
		if v.activity_type == activity_type and v.is_openserver == 1 then
			return true
		end
	end

	return false
end

-- 不需要在开服活动面板上显示的活动
function KaifuActivityData:IsIgnoreType(activity_type)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HONG_BAO or
		activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MARRY_ME or
		activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE or
		self:IsAdvanceRankType(activity_type) or activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN_RANK or
		activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE_RANK or self:IsZhengBaType(activity_type)
		or activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CORNUCOPIA then
		return true
	end

	return false
end

function KaifuActivityData:GetOpenActivityList(day)
	local list = {}
	-- if day == nil then return nil end
	for k, v in pairs(self:GetKaifuActivityOpenCfg()) do
		if ActivityData.Instance:GetActivityIsOpen(v.activity_type) and v.is_openserver == 1 and not self:IsIgnoreType(v.activity_type) and v.activity_panel == RAND_ACTIVITY_PANEL_TYPE.ACTIVE_PANEL then
			if self:IsBossLieshouType(v.activity_type) then
				if self:IsShowBossTab() then
					--table.insert(list, v)
					list[v.activity_type] = v
				end
			else
				--table.insert(list, v)
				list[v.activity_type] = v
			end
		end
		-- if v.begin_day_idx <= day and v.end_day_idx >= day then
		-- 	table.insert(list, v)
		-- end
	end

	-- for i,v in ipairs(OPEN_SERVER_RA_ACTIVITY_TYPE) do
	-- 	if ActivityData.Instance:GetActivityIsOpen(v) then
	-- 		list[v] = {activity_type=v, name=Language.Activity.KaiFuActivityName[v]}
	-- 		-- table.insert(list, {activity_type=v, name=Language.Activity.KaiFuActivityName[v]})
	-- 	end
	-- end

	for _, v in pairs(self:GetTempAddActivityTypeList()) do
		--table.insert(list, v)
		list[v.activity_type] = v
	end

	local temp_list = {}
	for _, v in ipairs(ACTIVITY_SORT_INDEX_LIST) do
		local activity = list[v]
		if activity ~= nil then
			table.insert(temp_list, activity)
			list[v] = nil
		end
	end

	local hefu_list = HefuActivityData.Instance:GetCombineSubActivityList()
	for i,v in ipairs(TableCopy(hefu_list)) do
		v.activity_type = v.sub_type
		list[v.activity_type] = v
	end

	for _, v in pairs(list) do
		table.insert(temp_list, v)
	end

	return temp_list
end

-- 从别的地方加进来的，类似冲级豪礼
function KaifuActivityData:GetTempAddActivityTypeList()
	local list = {}
	for i = 1, #TempAddActivityType do
		local cfg = {}
		cfg.activity_type = TempAddActivityType[i].activity_type
		cfg.name = TempAddActivityType[i].name
		table.insert(list, cfg)
	end
	return list
end

function KaifuActivityData:GetTempActivityCfg(activity_type)
	if not activity_type then return nil end

	if activity_type == TEMP_ADD_ACT_TYPE.WELFARE_LEVEL_ACTIVITY_TYPE then
		return
	end
	return nil
end

function KaifuActivityData:IsTempAddType(activity_type)
	if activity_type == nil then return false end
	for k, v in pairs(TempAddActivityType) do
		if v.activity_type == activity_type then
			return true
		end
	end
	return false
end

function KaifuActivityData:IsAdvanceType(activity_type)
	if activity_type == nil then return false end
	for k, v in pairs(AdvanceType) do
		if RankType[k] and RankType[k] == activity_type then
			return true
		end
		if v == activity_type then
			return true
		end
	end
	return false
end

function KaifuActivityData:IsAdvanceRankType(activity_type)
	if activity_type == nil then return false end
	for k, v in pairs(RankType) do
		if v == activity_type then
			return true
		end
	end
	return false
end

function KaifuActivityData:IsNomalType(activity_type)
	if activity_type == nil then return false end
	for k, v in pairs(NormalType) do
		if NormalType[k] and NormalType[k] == activity_type then
			return true
		end
		if v == activity_type then
			return true
		end
	end
	return false
end
function KaifuActivityData:IsChongJiType(activity_type)
	if activity_type == nil then return false end
	if RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ROLE_UPLEVEL == activity_type then
		return true
	end
	return false
end

function KaifuActivityData:IsPaTaType(activity_type)
	if activity_type == nil then return false end
	if RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PATA == activity_type then
		return true
	end
	return false
end

function KaifuActivityData:IsExpChallengeType(activity_type)
	if activity_type == nil then return false end
	if RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_FB == activity_type then
		return true
	end
	return false
end

function KaifuActivityData:IsChongzhiType(activity_type)
	if activity_type == nil then return false end
	for k, v in pairs(ChongzhiType) do
		if v == activity_type then
			return true
		end
	end
	return false
end

function KaifuActivityData:IsStrengthenType(activity_type)
	if activity_type == nil then return false end
	for k, v in pairs(StrengthenType) do
		if v == activity_type then
			return true
		end
	end
	return false
end

function KaifuActivityData:IsBossLieshouType(activity_type)
	if activity_type == nil then return false end
	for k, v in pairs(BossType) do
		if v == activity_type then
			return true
		end
	end
	return false
end

function KaifuActivityData:IsZhengBaType(activity_type)
	if activity_type == nil then return false end

	if RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ZHENG_BA == activity_type then
		return true
	end
	return false
end

function KaifuActivityData:ShowWhichPanelByType(activity_type)
	if activity_type == nil then return nil end

	if ACTIVITY_TYPE_TO_PANEL_INDEX[activity_type] then
		return ACTIVITY_TYPE_TO_PANEL_INDEX[activity_type]
	end

	for i = 1, MAX_ACTIVITY_TYPE do
		if AdvanceType[i] == activity_type or NormalType[i] and NormalType[i] == activity_type or
			activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_TOTAL_CHARGE
			or activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN
			or activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE then
			return 1
		end
		if RankType[i] and RankType[i] == activity_type or activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN_RANK or
			activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE_RANK then
			return 3
		end
		if ChongzhiType[i] and ChongzhiType[i] == activity_type and ChongzhiType[i] ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_TOTAL_CHARGE then
			return 2
		end

		if self:IsZhengBaType(activity_type) then
			return 4
		end

		if BossType[i] and BossType[i] == activity_type then
			return 5
		end
	end

	return nil
end

function KaifuActivityData:GetCondByType(activity_type)
	if activity_type == nil then return nil end
	local mount_grade = MountData.Instance:GetMountInfo().grade
	local mount_grade_cfg = MountData.Instance:GetMountGradeCfg(mount_grade)

	local wing_grade = WingData.Instance:GetWingInfo().grade
	local wing_grade_cfg = WingData.Instance:GetWingGradeCfg(wing_grade)

	local halo_grade = HaloData.Instance:GetHaloInfo().grade
	local halo_grade_cfg = WingData.Instance:GetWingGradeCfg(halo_grade)

	local shengong_grade = ShengongData.Instance:GetShengongInfo().grade
	local shengong_grade_cfg = ShengongData.Instance:GetShengongGradeCfg(shengong_grade)

	local shenyi_grade = ShenyiData.Instance:GetShenyiInfo().grade
	local shenyi_grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(shenyi_grade)

	local game_vo = GameVoManager.Instance:GetMainRoleVo()

	local gemstone_level = ForgeData.Instance:GetGemTotalLevel()

	-- 坐骑进阶
	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_MOUNT then
		return mount_grade_cfg and mount_grade_cfg.show_grade or 0, 1

	-- 羽翼进阶
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING then
		return wing_grade_cfg and wing_grade_cfg.show_grade or 0, 2

	-- 光环进阶
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_HALO then
		return halo_grade_cfg and halo_grade_cfg.show_grade or 0, 3

	-- 神弓进阶
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENGONG then
		return shengong_grade_cfg and shengong_grade_cfg.show_grade or 0, 4

	-- 神翼进阶
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENYI then
		return shenyi_grade_cfg and shenyi_grade_cfg.show_grade or 0, 5

	-- 冲级大礼
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ROLE_UPLEVEL then
		return game_vo.level or 0, 6

	-- 爬塔副本
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PATA then
		return FuBenData.Instance:GetTowerFBInfo().pass_level or 0, 7

	-- 经验副本
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_FB then
		return FuBenData.Instance:GetExpFBInfo().expfb_pass_wave or 0, 8

	-- 每日累充
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_TOTAL_CHARGE then
		return DailyChargeData.Instance:GetChongZhiInfo().today_recharge

	-- 首充团购
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIRST_CHARGE_TUAN then
		if self.info[activity_type] and self.info[activity_type].rand_activity_type and self.info[activity_type].rand_activity_type == activity_type then
			return  DailyChargeData.Instance:GetChongZhiInfo().today_recharge, self.info[activity_type].today_chongzhi_role_count
		end
		return DailyChargeData.Instance:GetChongZhiInfo().today_recharge

	-- 累计充值
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE then
		if self.leiji_chongzhi_info and self.leiji_chongzhi_info.total_charge_value then
			return self.leiji_chongzhi_info.total_charge_value
		end
		return 0

	-- 全服坐骑进阶
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_MOUNT_TOTAL then
		if self.upgrade_info[activity_type] and self.upgrade_info[activity_type] and self.upgrade_info[activity_type].rand_activity_type == activity_type then
			return mount_grade_cfg and mount_grade_cfg.show_grade or 0, 1, self.upgrade_info[activity_type].total_upgrade_record_list
		end
		return mount_grade_cfg and mount_grade_cfg.show_grade or 0, 1

	-- 全服羽翼进阶
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING_TOTAL then
		if self.upgrade_info[activity_type] and self.upgrade_info[activity_type].rand_activity_type == activity_type then
			return wing_grade_cfg and wing_grade_cfg.show_grade or 0, 2, self.upgrade_info[activity_type].total_upgrade_record_list
		end
		return wing_grade_cfg and wing_grade_cfg.show_grade or 0, 2

	-- 全服光环进阶
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_HALO_TOTAL then
		if self.upgrade_info[activity_type] and self.upgrade_info[activity_type].rand_activity_type == activity_type then
			return halo_grade_cfg and halo_grade_cfg.show_grade or 0, 3, self.upgrade_info[activity_type].total_upgrade_record_list
		end
		return halo_grade_cfg and halo_grade_cfg.show_grade or 0, 3

	-- 全服神弓进阶
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENGONG_TOTAL then
		if self.upgrade_info[activity_type] and self.upgrade_info[activity_type].rand_activity_type == activity_type then
			return shengong_grade_cfg and shengong_grade_cfg.show_grade or 0, 4, self.upgrade_info[activity_type].total_upgrade_record_list
		end
		return shengong_grade_cfg and shengong_grade_cfg.show_grade or 0, 4

	-- 全服神翼进阶
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENYI_TOTAL then
		if self.upgrade_info[activity_type] and self.upgrade_info[activity_type].rand_activity_type == activity_type then
			return shenyi_grade_cfg and shenyi_grade_cfg.show_grade or 0, 5, self.upgrade_info[activity_type].total_upgrade_record_list
		end
		return shenyi_grade_cfg and shenyi_grade_cfg.show_grade or 0, 5

	-- 坐骑进阶排行榜
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_MOUNT_RANK then
		return mount_grade_cfg and mount_grade_cfg.show_grade or 0, 1

	-- 羽翼进阶排行榜
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING_RANK then
		return wing_grade_cfg and wing_grade_cfg.show_grade or 0, 2

	-- 光环进阶排行榜
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_HALO_RANK then
		return halo_grade_cfg and halo_grade_cfg.show_grade or 0, 3

	-- 神弓进阶排行榜
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENGONG_RANK then
		return shengong_grade_cfg and shengong_grade_cfg.show_grade or 0, 4

	-- 神翼进阶排行榜
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENYI_RANK then
		return shenyi_grade_cfg and shenyi_grade_cfg.show_grade or 0, 5

	-- 装备强化
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN
			or activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN_RANK then
		return game_vo.total_strengthen_level or 0, 9

	-- 宝石升级
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE
			or activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE_RANK then
		return gemstone_level, 10
	end
	return nil
end

function KaifuActivityData:GetJinjieTypeShowGrade(jinjie_type, grade)
	if jinjie_type == nil then return nil end
	if jinjie_type == 1 then
		return (MountData.Instance:GetMountGradeCfg(grade) ~= nil) and MountData.Instance:GetMountGradeCfg(grade).show_grade or 0
	elseif jinjie_type == 2 then
		return (WingData.Instance:GetWingGradeCfg(grade) ~= nil) and WingData.Instance:GetWingGradeCfg(grade).show_grade or 0
	elseif jinjie_type == 3 then
		return (HaloData.Instance:GetHaloGradeCfg(grade) ~= nil) and HaloData.Instance:GetHaloGradeCfg(grade).show_grade or 0
	elseif jinjie_type == 4 then
		return (ShengongData.Instance:GetShengongGradeCfg(grade) ~= nil) and ShengongData.Instance:GetShengongGradeCfg(grade).show_grade or 0
	elseif jinjie_type == 5 then
		return (ShenyiData.Instance:GetShenyiGradeCfg(grade) ~= nil) and ShenyiData.Instance:GetShenyiGradeCfg(grade).show_grade or 0
	end
	return nil
end

function KaifuActivityData:GetNewServerRemind()
	local num = 0
	if self:IsShowJiZiRedPoint() then
		num = num + 1
	end

	if WelfareData.Instance:GetLevelRewardRemind() > 0 then
		num = num + 1
	end

	if (self.info == nil or next(self.info) == nil) and (not self.boss_lieshou_info or not next(self.boss_lieshou_info)) then
		return 0
	end

	for k, v in pairs(self.info) do
		local bit_reward_list = nil
		local bit_complete_list = nil
		if v.complete_flag and not self:IsIgnoreType(k) then
			if v.reward_flag then
				bit_reward_list = bit:d2b(v.reward_flag)
			end
			bit_complete_list = bit:d2b(v.complete_flag)
			if bit_complete_list and bit_reward_list then
				for k2, v2 in pairs(bit_complete_list) do
					if v2 == 1 and bit_reward_list[k2] ~= 1 then
						num = num + 1
					end
				end
			end
		end
	end

	if self:IsShowBossRedPoint() then
		num = num + 1
	end

	-- if self:IsShowZhengbaRedPoint() then
	-- 	return true
	-- end

	-- if self:IsShowLeiJiChongZhiRedPoint() then
	-- 	return true
	-- end

	return num
end


function KaifuActivityData:IsShowNewServerRedPoint()
	if self:IsShowJiZiRedPoint() then
		return true
	end

	if WelfareData.Instance:GetLevelRewardRemind() > 0 then
		return true
	end

	if (self.info == nil or next(self.info) == nil) and (not self.boss_lieshou_info or not next(self.boss_lieshou_info)) then
		return false
	end

	for k, v in pairs(self.info) do
		local bit_reward_list = nil
		local bit_complete_list = nil
		if v.complete_flag and not self:IsIgnoreType(k) then
			if v.reward_flag then
				bit_reward_list = bit:d2b(v.reward_flag)
			end
			bit_complete_list = bit:d2b(v.complete_flag)
			if bit_complete_list and bit_reward_list then
				for k2, v2 in pairs(bit_complete_list) do
					if v2 == 1 and bit_reward_list[k2] ~= 1 then
						return true
					end
				end
			end
		end
	end

	if self:IsShowBossRedPoint() then
		return true
	end

	-- if self:IsShowZhengbaRedPoint() then
	-- 	return true
	-- end

	-- if self:IsShowLeiJiChongZhiRedPoint() then
	-- 	return true
	-- end

	return false
end

function KaifuActivityData:IsGetReward(index, activity_type)
	if index == nil or activity_type == nil then return false end
	if self.info[activity_type] and self.info[activity_type].reward_flag then
		local bit_reward_list = bit:d2b(self.info[activity_type].reward_flag)
		if bit_reward_list then
			for k, v in pairs(bit_reward_list) do
				if v == 1 and (32 - k) == index then
					return true
				end
			end
		end
	end
	return false
end

function KaifuActivityData:GetRewardSeq(activity_type)
	local seq = 5
	if self.info[activity_type] and self.info[activity_type].reward_flag then
		local bit_reward_list = bit:d2b(self.info[activity_type].reward_flag)
		if bit_reward_list then
			for k, v in pairs(bit_reward_list) do
				if bit_reward_list[28 - k] == 0 then
					seq = seq + k - 1
					return seq
				end
			end
		end
	end
	return seq
end

function KaifuActivityData:IsComplete(index, activity_type)
	if index == nil or activity_type == nil then return false end

	if self.info[activity_type] and self.info[activity_type].complete_flag then
		local bit_complete_list = bit:d2b(self.info[activity_type].complete_flag)
		if bit_complete_list then
			for k, v in pairs(bit_complete_list) do
				if v == 1 and (32 - k) == index then
					return true
				end
			end
		end
	end
	return false
end

function KaifuActivityData:SortList(activity_type, cfg_list)
	if activity_type == nil then return nil end

	cfg_list = cfg_list or self:GetKaifuActivityCfgByType(activity_type)
	local temp_list = {}
	for k, v in pairs(cfg_list) do
		if self:IsGetReward(v.seq, activity_type) and self:IsComplete(v.seq, activity_type) then
			temp_list[k] = {}
			temp_list[k].sort_value = 2
			temp_list[k].seq = v.seq
			temp_list[k].k = k
		elseif not self:IsGetReward(v.seq, activity_type) and self:IsComplete(v.seq, activity_type) then
			temp_list[k] = {}
			temp_list[k].sort_value = 0
			temp_list[k].seq = v.seq
			temp_list[k].k = k
		elseif not self:IsGetReward(v.seq, activity_type) and not self:IsComplete(v.seq, activity_type) then
			temp_list[k] = {}
			temp_list[k].sort_value = 1
			temp_list[k].seq = v.seq
			temp_list[k].k = k
		elseif self:IsGetReward(v.seq, activity_type) and not self:IsComplete(v.seq, activity_type) then
			temp_list[k] = {}
			temp_list[k].sort_value = 2
			temp_list[k].seq = v.seq
			temp_list[k].k = k
		end
	end

	table.sort(temp_list, function (a, b)
		if a and b then
			return a.sort_value == b.sort_value and a.seq < b.seq or a.sort_value < b.sort_value
		end
	end)
	local sort_list = {}
	for k,v in ipairs(temp_list) do
		table.insert(sort_list, cfg_list[v.k])
	end
	return sort_list
end

-- 获取显示boss列表
-- is_show_reward 是否获取奖励配置,默认获取boss列表
function KaifuActivityData:GetShowBossList(index, is_show_reward)
	if not index then return {} end

	local all_list = {}

	-- index 从 0 开始
	for k, v in pairs(self:GetOpenGameActCfg().kill_boss_reward) do
		-- if v.seq == index then
			local list = {}
			for i = 1, 4 do
				if v["boss_seq_"..i] and self:GetOpenGameActCfg().kill_boss[v["boss_seq_"..i]] then
					-- if not is_show_reward then
						table.insert(list, self:GetOpenGameActCfg().kill_boss[v["boss_seq_"..i]])
					-- end
				end
			end
			all_list[v.seq + 1] = list
			all_list[v.seq + 1].seq = v.seq
		-- end
	end

	for k, v in pairs(all_list) do
		local is_complete, count = self:GetBossIsComplete(k - 1)
		local is_get = self:GetBossRewardIsGet(k - 1)
		if is_get and is_complete then
			v.flag = 0
		end
		if is_complete and not is_get then
			v.flag = 2
		end
		if not is_complete and not is_get then
			v.flag = 1
		end
		v.count = count
	end

	table.sort(all_list, function(a, b)
		if a.flag ~= b.flag then
			return a.flag > b.flag
		end

		if a.count ~= b. count then
			return a.count > b. count
		end

		return a.seq < b.seq
	end)


	for k, v in pairs(all_list) do
		if v.seq == index then
			if is_show_reward then
				return self:GetOpenGameActCfg().kill_boss_reward[index]
			else
				return v
			end
		end
	end

	return {}
	-- return all_list[index + 1] or {}
end

function KaifuActivityData:MaxBossPageNum()
	local count = 0
	for k, v in pairs(self:GetOpenGameActCfg().kill_boss_reward) do
		count = count + 1
	end
	return count
end

-- 判断是否已经完成了boss猎手
function KaifuActivityData:GetBossIsComplete(index)
	if not index then return false, 0 end

	local count = 0
	local oga_kill_boss_flag_hight = self.boss_lieshou_info.oga_kill_boss_flag_hight
	local oga_kill_boss_flag_low = self.boss_lieshou_info.oga_kill_boss_flag_low

	if not oga_kill_boss_flag_hight or not oga_kill_boss_flag_low then return false end

	local sif_list = bit:ll2b(oga_kill_boss_flag_hight, oga_kill_boss_flag_low)

	-- index 从 0 开始
	for k, v in pairs(self:GetOpenGameActCfg().kill_boss_reward) do
		if v.seq == index then
			for i, j in ipairs(sif_list) do
				if 1 == j then
					local tem_index = (64 - i) - 4 * index
					if v["boss_seq_"..tem_index] then
						count = count + 1
					end
				end
			end
		end
	end
	if count >= 4 then
		return true, count
	end
	return false, count
end

-- 判断是否已经领取了boss猎手奖励
function KaifuActivityData:GetBossRewardIsGet(index)
	if not index then return false end

	local oga_kill_boss_reward_flag = self.boss_lieshou_info.oga_kill_boss_reward_flag

	if not oga_kill_boss_reward_flag then return false end

	local sif_list = bit:d2b(oga_kill_boss_reward_flag)

	-- index 从 0 开始
	for k, v in pairs(sif_list) do
		if 1 == v and index == (32 - k) then
			return true
		end
	end
	return false
end

function KaifuActivityData:BossIsKill(req_index)
	if not req_index then return false end

	local oga_kill_boss_flag_hight = self.boss_lieshou_info.oga_kill_boss_flag_hight
	local oga_kill_boss_flag_low = self.boss_lieshou_info.oga_kill_boss_flag_low

	if not oga_kill_boss_flag_hight or not oga_kill_boss_flag_low then return false end

	local sif_list = bit:ll2b(oga_kill_boss_flag_hight, oga_kill_boss_flag_low)

	for k, v in pairs(sif_list) do
		if 1 == v and (64 - k) == req_index then
			return true
		end
	end
	return false
end

function KaifuActivityData:IsShowBossRedPoint()
	for i = 0, 3 do
		local is_complete = self:GetBossIsComplete(i)
		local is_get = self:GetBossRewardIsGet(i)
		if is_complete and not is_get then
			return true
		end
	end
	return false
end

function KaifuActivityData:IsShowJiZiRedPoint()
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION) then return false end
	local can_get = nil
	local times_t = KaifuActivityData.Instance:GetCollectExchangeInfo()
	for k,v in pairs(PlayerData.Instance:GetCurrentRandActivityConfig().item_collection) do
		local times = times_t[v.seq + 1] or 0
		if times < v.exchange_times_limit then
			can_get = true
			for i = 1, 4 do
				if v["stuff_id" .. i].item_id > 0 then
					if ItemData.Instance:GetItemNumInBagById(v["stuff_id" .. i].item_id) < v["stuff_id" .. i].num then
						can_get = false
					end
				end
			end
			if can_get then
				if ClickOnceRemindList[RemindName.ItemCollection] and ClickOnceRemindList[RemindName.ItemCollection] == 0 then
					return false
				end
				return true
			end
		end
	end
	return false
end

function KaifuActivityData:GetBossInfoById(boss_id)
	if not boss_id then return end

	for k, v in pairs(self:GetOpenGameActCfg().kill_boss) do
		if v.boss_id == boss_id then
			return v
		end
	end

	return nil
end

function KaifuActivityData:SetZhengBaRedPointState(value)
	self.zhengba_red_point_state = value
end

function KaifuActivityData:IsShowZhengbaRedPoint()
	if not ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ZHENG_BA) then
		return false
	end

	for k, v in pairs(self.battle_activity_info) do
		if v.status == ACTIVITY_STATUS.OPEN and self.zhengba_red_point_state then
			return true
		end
	end
	return false
end

-- 累计充值(2091)配置
function KaifuActivityData:GetLeiJiChongZhiCfg()
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

function KaifuActivityData:GetLeijiChongZhiFlagCfg()
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

function KaifuActivityData:RechargeProgressValue()
	local chongzhi_cfg = self:GetLeiJiChongZhiCfg()
	local total_charge_value = self.leiji_chongzhi_info.total_charge_value or 0  -- 当前充值金额

	for i,v in ipairs(chongzhi_cfg) do
		if total_charge_value < chongzhi_cfg[1].need_chognzhi then
			return 0
		elseif total_charge_value >= chongzhi_cfg[#chongzhi_cfg].need_chognzhi then
				return #chongzhi_cfg
		elseif total_charge_value >= chongzhi_cfg[i].need_chognzhi and total_charge_value < chongzhi_cfg[i + 1].need_chognzhi then
			return i
		end
	end
	return 0
end

-- function KaifuActivityData:RechargeProgressValue(index)
-- 	local cur_charge_value = 0
-- 	local total_charge_value = self.leiji_chongzhi_info.total_charge_value or 0  -- 当前充值金额
-- 	for i=0,9 do
-- 		local charge_cfg .. i = self:GetLeiJiChongZhiDes(i).need_chognzhi
-- 	end
-- 	if total_charge_value ==
-- end

-- 进度条显示数值转换
function KaifuActivityData:GetLeiJiChongZhiDes(index)
	local chongzhi_cfg = self:GetLeiJiChongZhiCfg()
	for i,v in ipairs(chongzhi_cfg) do
		if v.seq == index then
			return v
		end
	end
end



-- 是否领取累计充值奖励
function KaifuActivityData:IsGetLeiJiChongZhiReward(seq)
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

function KaifuActivityData:GetKfLeichongRemind()
	return self:IsShowLeiJiChongZhiRedPoint() and 1 or 0
end

function KaifuActivityData:IsShowLeiJiChongZhiRedPoint()
	if not ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE) then return false end

	for k, v in pairs(self:GetLeijiChongZhiFlagCfg()) do
		if v.flag and v.flag == 2 then
			return true
		end
	end
	return false
end

-- 是否显示主界面图标
function KaifuActivityData:IsShowKaifuIcon()
	for k, v in pairs(self:GetKaifuActivityOpenCfg()) do
		if ActivityData.Instance:GetActivityIsOpen(v.activity_type) then
			return true
		end
	end

	return false
end

function KaifuActivityData:IsShowBossTab()
	for k, v in pairs(self:GetOpenGameActCfg().kill_boss_reward) do
		if self:GetBossIsComplete(v.seq) and not self:GetBossRewardIsGet(v.seq) then
			return true
		end
		if not self:GetBossIsComplete(v.seq) and not self:GetBossRewardIsGet(v.seq) then
			return true
		end
	end
	return false
end

-- 我们结婚吧配置表
function KaifuActivityData:GetMarryMeCfg()
	if not self.marry_me_cfg then
		self.marry_me_cfg = PlayerData.Instance:GetCurrentRandActivityConfig().marry_me
	end
	return self.marry_me_cfg
end


function KaifuActivityData:ShowCurIndex()
	local chongzhi_cfg = self:GetLeijiChongZhiFlagCfg()
	for i = 0, 9 do
		if chongzhi_cfg[i] and chongzhi_cfg[i].flag == 2 then
			return i
		end
	end
	return -1
end

--------------------------Boss悬赏--------------------------------
function KaifuActivityData:SetBossXuanshangInfo(protocol)
	self.boss_xuanshang_info = protocol
end

function KaifuActivityData:GetBossXuanshangInfo()
	return self.boss_xuanshang_info or {}
end

function KaifuActivityData:GetBossIsKillByPhase(phase, task_id)
	local data = self:GetBossXuanshangInfo()
	if nil == data or nil == next(data) then return end
	local reward_flag = data.task_reward_flag_list[phase]
	return 1 == bit:_and(1, bit:_rshift(reward_flag, task_id))
end

function KaifuActivityData:GetBossRewardCfgByPhase(phase, task_id)
	local data = {}
	local cfg = PlayerData.Instance:GetCurrentRandActivityConfig()
	local boss_xuanshang_cfg = cfg.boss_xuanshang
	if nil == boss_xuanshang_cfg or nil == next(boss_xuanshang_cfg) then return end
	for k, v in pairs(boss_xuanshang_cfg) do
		if v.phase == phase and v.task_id == task_id then
			data = TableCopy(v)
			data.reward_list = ItemData.Instance:GetGiftItemList(v.reward_item.item_id)
			data.is_kill = self:GetBossIsKillByPhase(v.phase, v.task_id)
			return data
		end
	end

	return data
end

function KaifuActivityData:GetBossRewardRedPoint()
	for i = 1, 4 do
		if self:GetBossRewardCanReceive(i-1) then
			local reward_flag = self.boss_xuanshang_info.task_reward_flag_list[i - 1]
			if 0 == bit:_and(1, bit:_rshift(reward_flag, 0)) then
				return true
			end
		end
	end
	return false
end

function KaifuActivityData:GetBossRewardCanReceive(phase)
	local data = self:GetBossXuanshangInfo()
	for i = 1, 3 do
		local reward_flag = data.task_reward_flag_list[phase]
		if 0 == bit:_and(1, bit:_rshift(reward_flag, i)) then
			return false
		end
	end

	return true
end

function KaifuActivityData:GetBossRewardFinishNum(phase)
	local num = 0
	local data = self:GetBossXuanshangInfo()
	for i = 1, 3 do
		local reward_flag = data.task_reward_flag_list[phase]
		if 1 == bit:_and(1, bit:_rshift(reward_flag, i)) then
			num = num + 1
		end
	end

	return num
end

------------ 战事目标 -----------------------------
--获取战事目标itemcell内容
function KaifuActivityData:GetWarGoalsItemCellInfoCfg()
	if not self.randactivityconfig_1_cfg then
		self.randactivityconfig_1_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	end
	return self.randactivityconfig_1_cfg.war_goal
end

-- 获取战事目标终极奖励
function KaifuActivityData:GetWarGoalsFinalRewardCfg()
	if not self.randactivityconfig_1_cfg then
		self.randactivityconfig_1_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	end
	return self.randactivityconfig_1_cfg.other
end

function KaifuActivityData:SetWarGoalsInfo(protocol)
	local war_goals_info = {}
	war_goals_info.task_progress_list = protocol.task_progress_list
	war_goals_info.final_reward_can_fetch_flag = protocol.final_reward_can_fetch_flag
	war_goals_info.final_reward_fetch_flag = protocol.final_reward_fetch_flag
	war_goals_info.task_fetch_reward_flag = bit:d2b(protocol.task_fetch_reward_flag) 	--是否已经领取

	--self.war_goal_info = protocol
	self.war_goals_info = war_goals_info
end

function KaifuActivityData:GetWarGoalsInfo()
	return self.war_goals_info or {}
end

function KaifuActivityData:GetWarGoalsRedPoint()
	local flag = 0
	for k,v in pairs(self.war_goals_info.task_progress_list) do
		if v == 1 and self.war_goals_info.task_fetch_reward_flag[33 - k] ~= 1 then
			flag = 1
			return flag
		end

	end
	return flag
end

function KaifuActivityData:GetWarGoalsFinishNum()
	local num = 0
	local info = self:GetWarGoalsInfo()
	for k, v in pairs(info.task_progress_list) do
		if v == 1 then
			num = num + 1
		end
	end
	return num
end

function KaifuActivityData:CheckKaiFuRedPoint()
	if self.is_first then
		self.is_first = false
		return 1
	end
	return 0
end

---------------------------------------------------
--每日国事 - 获取活动开启的天数
function KaifuActivityData:GetActivityOpenDay()
	local activity_statr_time = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAILY_NATION_WAR).start_time
	local server_time = TimeCtrl.Instance:GetServerTime()
	local daily_national_cur_time = server_time - activity_statr_time

	return math.ceil(daily_national_cur_time / (24 * 3600))  or 0
end

--每日国事 根据天数判断该显示的类型，获取当日国事信息
function KaifuActivityData:GetShowCurNationalInfo()
	--控制天数，根据天数显示类型
	local cur_national_day = self:GetActivityOpenDay()
	--local cur_national_day = 5

	--不同天数显示的每日国事信息
	if cur_national_day == 1 or cur_national_day == 4 or cur_national_day == 7 then
		self.cur_national_type = 0
		if not self.qunxianlundou_cfg then
			self.qunxianlundou_cfg = ConfigManager.Instance:GetAutoConfig("qunxianlundouconfig_auto")
		end
		for k,v in pairs(self.qunxianlundou_cfg.daily_nation_war_explain) do
			if cur_national_day == v.date then
				return v
			end
		end
	end
	if cur_national_day == 2 or cur_national_day == 5 then
		self.cur_national_type = 1
		if not self.guildbattle_cfg then
			self.guildbattle_cfg = ConfigManager.Instance:GetAutoConfig("guildbattle_auto")
		end
		for k,v in pairs(self.guildbattle_cfg.daily_nation_war_explain) do
			if cur_national_day == v.date then
				return v
			end
		end
	end
	if cur_national_day == 3 or cur_national_day == 6 then
		self.cur_national_type = 2
		if not self.gongchengzhan_cfg then
			self.gongchengzhan_cfg = ConfigManager.Instance:GetAutoConfig("gongchengzhan_auto")
		end
		for k,v in pairs(self.gongchengzhan_cfg.daily_nation_war_explain) do
			if cur_national_day == v.date then
				return v
			end
		end
	end

	--如果都不等于上面的值，默认为元素战场
	if not self.qunxianlundou_cfg then
		self.qunxianlundou_cfg = ConfigManager.Instance:GetAutoConfig("qunxianlundouconfig_auto")
	end
	return self.qunxianlundou_cfg.daily_nation_war_explain[1]
end

--获得当前国事的类型，显示对应prefab
function KaifuActivityData:GetTodayNationalType()
	return self.cur_national_type or 0
end

--设置当前国事的协议
function KaifuActivityData:SetDailyNationalInfo(protocol)
	self.daily_national_info = protocol.daily_nation_war_info_list
end

function KaifuActivityData:GetDailyNationalInfo()
	return self.daily_national_info or {}
end

--获得元素战场奖励
function KaifuActivityData:GetQunXianLunDouReward()
	if not self.qunxianlundou_cfg then
		self.qunxianlundou_cfg = ConfigManager.Instance:GetAutoConfig("qunxianlundouconfig_auto")
	end
	return self.qunxianlundou_cfg.daily_nation_war_reward
end

--获得抢国王奖励
function KaifuActivityData:GetGuildBattleReward()
	if not self.guildbattle_cfg then
		self.guildbattle_cfg = ConfigManager.Instance:GetAutoConfig("guildbattle_auto")
	end
	return self.guildbattle_cfg.daily_nation_war_reward
end

--获得抢皇帝奖励
function KaifuActivityData:GetGrabEmperorReward()
	if not self.gongchengzhan_cfg then
		self.gongchengzhan_cfg = ConfigManager.Instance:GetAutoConfig("gongchengzhan_auto")
	end
	return self.gongchengzhan_cfg.daily_nation_war_reward
end

function KaifuActivityData:GetGrabEmperorRewardBySide(side)
	local cfg = {}
	for k, v in pairs(self:GetGrabEmperorReward()) do
		if v.side == side then
			table.insert(cfg, v)
		end
	end
	return cfg
end

function KaifuActivityData:GetDailyNationalPoint()
	local daily_national_info = self:GetDailyNationalInfo()
	local cur_national = self:GetTodayNationalType()
	local cur_daily_national_info = daily_national_info[cur_national]
	local data = {}
	if self:GetTodayNationalType() == 0 then
		data = self:GetQunXianLunDouReward()
	elseif self:GetTodayNationalType() == 1 then
		data = self:GetGuildBattleReward()
	elseif self:GetTodayNationalType() == 2 then
		data = self:GetGrabEmperorReward()
	end
	--设置按钮可领取状态

	for k,v in pairs(data) do
		if v.rank_mix and v.rank_max  then
			if cur_daily_national_info.param_1 >= v.rank_mix and cur_daily_national_info.param_1 <= v.rank_max then
				if cur_daily_national_info.is_fetch ~= 1 then
					return 1
				end
			end
		else
			if cur_daily_national_info.param_2 > 0 then
				if cur_daily_national_info.param_1 == v.post then
					if cur_daily_national_info.is_fetch ~= 1 then
						return 1
					end
				end
			end
		end
	end


	return 0
end
---------------------------------------------------

----------- 储君有礼 ------------------------------
function KaifuActivityData:SetChujunGiftInfo(protocol)
	self.chujun_info = protocol
end

function KaifuActivityData:GetChujunGiftInfo()
	return self.chujun_info or {}
end

function KaifuActivityData:GetChujunIdList()
	local list = {}
	local chujun_info = self:GetChujunGiftInfo()
	for i = 1, CAMP_TYPE.CAMP_TYPE_MAX - 1 do
		if chujun_info.crown_prince_info_list and chujun_info.crown_prince_info_list[i] and chujun_info.crown_prince_info_list[i].uid then
			table.insert(list, chujun_info.crown_prince_info_list[i].uid)
		end
	end

	return list
end

function KaifuActivityData:GetChujunGiftCfg()
	local cfg = PlayerData.Instance:GetCurrentRandActivityConfig()
	return cfg.chujun_gift[1] or {}
end

function KaifuActivityData:GetChujunGiftDesCfg()
	local cfg = PlayerData.Instance:GetCurrentRandActivityConfig()
	return cfg.chujun_gift_des or {}
end

function KaifuActivityData:GetChujunTaskList()
	local cfg = PlayerData.Instance:GetCurrentRandActivityConfig()
	local chujun_cfg = cfg.chujun_gift[1]
	local chujun_info = self:GetChujunGiftInfo()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local list = {}
	local data = {}
	data.desc = chujun_cfg.kill_boss_des
	data.gold_num = chujun_cfg.kill_boss_reward_gold
	data.is_finish_task = chujun_info.crown_prince_info_list[vo.camp].is_complete_kill_boss
	data.is_fetch_reward = chujun_info.crown_prince_info_list[vo.camp].is_fetch_kill_boss_reward
	table.insert(list, data)

	local data = {}
	data.desc = chujun_cfg.kill_flag_des
	data.gold_num = chujun_cfg.kill_flag_reward_gold
	data.is_finish_task = chujun_info.crown_prince_info_list[vo.camp].is_complete_kill_flag
	data.is_fetch_reward = chujun_info.crown_prince_info_list[vo.camp].is_fetch_kill_flag_reward
	table.insert(list, data)

	return list
end
---------------------------------------------------

----------- 结婚礼金 ------------------------------
function KaifuActivityData:GetMarryGiftCfg()
	local cfg = PlayerData.Instance:GetCurrentRandActivityConfig()
	return cfg.marry_gift or {}
end
-----------------

function KaifuActivityData:SetMarryGiftInfo(protocol)
	self.marry_gift_cur_place = protocol.cur_place
	self.marry_gift_self_rank_place = protocol.self_rank_place
end

function KaifuActivityData:GetMarryGiftSelfRank()
	local str = Language.Activity.NoMarryRank
	if self.marry_gift_self_rank_place ~= nil and self.marry_gift_self_rank_place > 0 then
		str = string.format(Language.Activity.MarryRankValue, self.marry_gift_self_rank_place)
	end

	return str
end

-- 充值排行榜奖励
function KaifuActivityData:GetDayChongZhiRankInfoListByDay(day, opengameday)
	opengameday = opengameday - ActivityData.Instance:GetActDayPassFromStart(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CHONGZHI_RANK)
	local data = {}
	local data_2 = {}
	local data_3 = {}
	local temp = 1
	local day_chongzhi_rank = ServerActivityData.Instance:GetCurrentRandActivityConfig().day_chongzhi_rank
	for k,v in pairs(day_chongzhi_rank) do
	 	if v.opengame_day >= opengameday and temp <= 5 and v.activity_day == day then
	 		temp = temp + 1
	 		table.insert(data, v.reward_item)
	 		table.insert(data_2, v.min_gold)
	 		table.insert(data_3, (v.rank + 1))
	 	end
	end

	return data, data_2, data_3
end

-- 消费排行榜奖励
function KaifuActivityData:GetDayConsumeRankRewardInfoListByDay(day)
	local data = {}
	local data_2 = {}
	local data_3 = {}
	local data_4 = {}
	local temp = 1
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().day_consume_rank
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_XIAOFEI_RANK)
	for k,v in pairs(cfg) do
	 	if temp <= 5 and v.activity_day == day then
	 		temp = temp + 1
	 		table.insert(data, v.reward_item)
	 		table.insert(data_2, v.min_gold)
	 		table.insert(data_3, (v.rank + 1))
	 		table.insert(data_4, v.fanli_rate)
	 	end
	end
	return data, data_2, data_3, data_4
end
-----

-----------活跃奖励
-------------------------------------
function KaifuActivityData:SetDayActiveDegreeInfo(protocol)
	self.active_degree = protocol.active_degree
	self.fetch_reward_flag = protocol.fetch_reward_flag
end

function KaifuActivityData:GetFetchRewardFlag()
	if self.fetch_reward_flag == 3 then
		return 2
	end
	if self.fetch_reward_flag == 7 then
		return 3
	end
	if self.fetch_reward_flag == 15 then
		return 4
	end
	return self.fetch_reward_flag or 0
end

function KaifuActivityData:GetCurrentActive()
	return self.active_degree or 0
end

function KaifuActivityData:GetDayActiveDegreeInfoList(opengameday)
	opengameday = opengameday - ActivityData.Instance:GetActDayPassFromStart(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_ACTIVIE_DEGREE)
	local fetch_reward_flag = self:GetFetchRewardFlag()
	local current_active =  self:GetCurrentActive()
	local table_data = {}
	local table_data_2 = {}
	local temp = 1
	local index = 1
	local data = ServerActivityData.Instance:GetCurrentRandActivityConfig().day_active_degree
	local sort_tab = {}
	for k,v in pairs(data) do
		if v.opengame_day >= opengameday and temp <= 4 then
			local order = v.need_active
			local temp_data = {}
			if temp <= fetch_reward_flag and current_active >= v.need_active then
				order = order + 10000
				-- table_data[5 - temp] = v.reward_item
				temp_data.reward_item = v.reward_item
				temp_data.data_index = temp
				table_data[5 - temp] = temp_data
	 			table_data_2[5 - temp] = v.need_active
	 		else
				temp_data.reward_item = v.reward_item
				temp_data.data_index = temp
				table_data[index] = temp_data
	 			table_data_2[index] = v.need_active
	 			index = index + 1
			end
	 		temp = temp + 1
		end
	end

	return table_data, table_data_2
end

function KaifuActivityData:IsShowDayActiveRedPoint()
	local fetch_reward_flag =  KaifuActivityData.Instance:GetFetchRewardFlag()
	local opengameday = TimeCtrl.Instance:GetCurOpenServerDay()
	local reward_list, coset_list = self:GetDayActiveDegreeInfoList(opengameday)
	local current_active = self:GetCurrentActive()
	local real_data = TableCopy(coset_list)
	SortTools.SortAsc(real_data)
	for k,v in pairs(real_data) do
		if fetch_reward_flag < k then
			if current_active >= v then
				return true
			end
		end
	end
	return false
end

--------------------------------单笔充值---------------------------------
function KaifuActivityData:GetDanBiChongZhiRankInfoListByDay()
	local table_data = {}
	local table_data_2 = {}
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().single_charge
	local data = ActivityData.Instance:GetRandActivityConfig(cfg, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_ACTIVIE_DEGREE)
	for k,v in pairs(data) do
		table.insert(table_data, v.reward_item)
	 	table.insert(table_data_2, v.charge_value)
	end
	return table_data, table_data_2
end

--------------------------------累充返利---------------------------------
function KaifuActivityData:SetChargeRewardInfo(protocol)
	self.reward_active_flag = bit:d2b(protocol.can_fetch_reward_flag)
	self.reward_fetch_flag = bit:d2b(protocol.fetch_reward_flag)
	self.history_charge_during_act = protocol.charge_value
end

function KaifuActivityData:GetLeiJiChargeRewardCfg()
	if not self.reward_fetch_flag then return nil end
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().charge_repayment
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHARGE_REPALMENT)
	local list = {}
	for k,v in pairs(cfg) do
		local data = {}
		data = TableCopy(v)
		data.reward_fetch = self:GetLeiJiChargeRewardIsFetch(v.seq)
		table.insert(list, data)
	end
	table.sort(list, SortTools.KeyLowerSorters("reward_fetch", "charge_value"))
	return list
end

function KaifuActivityData:GetLeiJiChargeValue()
	return self.history_charge_during_act or 0
end

function KaifuActivityData:GetLeiJiChargeRewardIsActive(seq)
	return self.reward_active_flag[32 - seq] or 0
end

function KaifuActivityData:GetLeiJiChargeRewardIsFetch(seq)
	return self.reward_fetch_flag[32 - seq] or 0
end

function KaifuActivityData:GetLeiJiChargeRewardRedPoint()
	local config = self:GetLeiJiChargeRewardCfg()
	for k,v in pairs(config) do
		if self:GetLeiJiChargeRewardIsActive(v.seq) == 1 and self:GetLeiJiChargeRewardIsFetch(v.seq) == 0 then
			return true
		end
	end
	-- for i=0,4 do
	-- 	if self:GetLeiJiChargeRewardIsActive(i) == 1 and self:GetLeiJiChargeRewardIsFetch(i) == 0 then
	-- 		return true
	-- 	end
	-- end
	return false
end

function KaifuActivityData:FlushLeiJiChargeRewardRedPoint()
	local remind_num = self:GetLeiJiChargeRewardRedPoint() and 1 or 0
	ActivityData.Instance:SetActivityRedPointState(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHARGE_REPALMENT, remind_num > 0)
	return remind_num
end
-------------------------------------------------------------

function KaifuActivityData:SetChongZhiChu(protocol)
	self.info_chu = protocol
end

function KaifuActivityData:SetChongZhiGao(protocol)
	self.info_gao = protocol
end

function KaifuActivityData:GetChongZhiChu()
	return self.info_chu
end

function KaifuActivityData:GetChongZhiGao()
	return self.info_gao
end

function KaifuActivityData:GetActivityOpenDayLianChong(openday_type)
	local openday_info = ActivityData.Instance:GetActivityStatus()
	local str = ""
	if nil ~= openday_info[openday_type] then
		local openday_end = openday_info[openday_type].end_time
		local opengao_time = openday_end - TimeCtrl.Instance:GetServerTime()
		local time_tab = TimeUtil.Format2TableDHMS(opengao_time)
		local temp = {}
		for k,v in pairs(time_tab) do
			if k ~= "day" then
				if v < 10 then
					v = tostring('0'..v)
				end
			end
			temp[k] = v
		end
		str = string.format(Language.Activity.ChongZhiRankRestTime, temp.day, temp.hour, temp.min)
	end
	return str
end

-- 连充特惠高配置
function KaifuActivityData:ChongZhiTeHuiGao()
	local list_gao = {}
	local temp_table = {}
	local openday = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig() or {}
	local today = self:ChongZhiTeHuiGaoList()
	if nil == cfg then
		return
	end

 	if ServerActivityData.Instance then
 		for k, v in pairs(cfg.continue_chonghzi_gao) do
 			if v.open_server_day == today then
 				table.insert(temp_table, cfg.continue_chonghzi_gao[k])

 			end
 		end
 		self.teihuigao = temp_table
 	end

	if nil ~= self:GetChongZhiGao() then
		local has_reward_falg = bit:d2b(self:GetChongZhiGao().has_fetch_reward_falg)
		local can_reward = {}
		local has_reward = {}

		for i = #self.teihuigao, 1, -1  do
			if has_reward_falg[32 - self.teihuigao[i].day_index] == 1 then
				table.insert(list_gao, self.teihuigao[i])
			else
				table.insert(list_gao, 1, self.teihuigao[i])
			end
		end
	end
 	return list_gao
end

function KaifuActivityData:ChongZhiTeHuiGaoList()
	local openday = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig() or {}
	for k, v in pairs(cfg.continue_chonghzi_gao) do
		if openday <= v.open_server_day then
			return v.open_server_day
		end
	end
end

function KaifuActivityData:ChongZhiTeHuiChuList()
	local openday = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig() or {}
	for k, v in pairs(cfg.continue_chonghzi_chu) do
		if openday <= v.open_server_day then
			return v.open_server_day
		end
	end
end

-- 连充特惠初配置
function KaifuActivityData:ChongZhiTeHuiChu()
	local list_chu = {}
	local temp_table = {}
	local openday = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig() or {}
	local today = self:ChongZhiTeHuiChuList()
	if nil == cfg then
		return
	end

	if ServerActivityData.Instance then
		for k, v in pairs(cfg.continue_chonghzi_chu) do
			if v.open_server_day == today then
				table.insert(temp_table, cfg.continue_chonghzi_chu[k])
			end
		end
		self.teihuichu = temp_table
	end
	if nil ~= self:GetChongZhiChu() and nil ~= self.teihuichu then
		local has_reward_falg = bit:d2b(self:GetChongZhiChu().has_fetch_reward_falg)
		for i = #self.teihuichu, 1, -1  do
			if has_reward_falg[32 - self.teihuichu[i].day_index] == 1 then
				table.insert(list_chu, self.teihuichu[i])
			else
				table.insert(list_chu, 1, self.teihuichu[i])
			end
		end
	end

 	return list_chu
end

function KaifuActivityData:LianChongTeHuiChuHongDian()
	local remind_num = self:LianChongTeHuiChuRedPoint() and 1 or 0
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU, remind_num > 0)
	return remind_num
end

function KaifuActivityData:LianChongTeHuiGaoHongDian()
	local remind_num = self:LianChongTeHuiGaoRedPoint() and 1 or 0
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO, remind_num > 0)
	return remind_num
end

function KaifuActivityData:LianChongTeHuiGaoRedPoint()
	local chongzhi_info = self:GetChongZhiGao()
	local cfg = self:ChongZhiTeHuiGao() or {}
	local is_red = false
	if nil == chongzhi_info then
		return false
	end
	if chongzhi_info.can_fetch_reward_flag ~= chongzhi_info.has_fetch_reward_falg then
		for k, v in pairs(cfg) do
			if v.day_index == chongzhi_info.continue_chongzhi_days then
				is_red = true
			end
		end
	elseif chongzhi_info.can_fetch_reward_flag == chongzhi_info.has_fetch_reward_falg then
		-- 今日充值没达到指定额度提示红点
		if not self.lianchong_2_point then
			return false
		end

		if cfg[1] and chongzhi_info.today_chongzhi < cfg[1].need_chongzhi then
			is_red = true
		else
			is_red = false
		end
	end

	return is_red
end

function KaifuActivityData:LianChongTeHuiChuRedPoint()
	local chongzhi_info = self:GetChongZhiChu()
	local cfg = self:ChongZhiTeHuiChu() or {}
	local is_red = false
	if nil == chongzhi_info then
		return false
	end

	if chongzhi_info.can_fetch_reward_flag ~= chongzhi_info.has_fetch_reward_falg then
		for k, v in pairs(cfg) do
			if v.day_index == chongzhi_info.continue_chongzhi_days then
				is_red = true
			end
		end
	elseif chongzhi_info.can_fetch_reward_flag == chongzhi_info.has_fetch_reward_falg then
		if not self.lianchong_1_point then
			return false
		end

		-- 今日充值没达到指定额度提示红点
		if cfg[1] and chongzhi_info.today_chongzhi < cfg[1].need_chongzhi then
			is_red = true
		else
			is_red = false
		end
	end
	return is_red
end

function KaifuActivityData:GetGroupBuyRedpoint()
	local activity_type = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIRST_CHARGE_TUAN
	local activity_list = self:GetKaifuActivityCfgByType(activity_type)

	local temp_list = {}
	local cond_list = {}
	for k, v in pairs(activity_list) do
		if not temp_list[v.cond2] then
			temp_list[v.cond2] = v.cond2
			table.insert(cond_list, v.cond2)
		end
	end

	table.sort(cond_list, function(a, b)
		return a < b
	end)

	for k, v in pairs(cond_list) do
		local list = self:GetShowCfgList(v)
		for i , j in ipairs(list) do
			if not self:IsGetReward(j.seq, activity_type) and
				self:IsComplete(j.seq, activity_type) then
				return 1
			end
		end
	end
	return 0
end

function KaifuActivityData:GetShowCfgList(cond)
	local list = {}
	local activity_type = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIRST_CHARGE_TUAN
	if not cond then return list end

	local activity_list = self:GetKaifuActivityCfgByType(activity_type)
	for k, v in pairs(activity_list) do
		if v.cond2 == cond then
			table.insert(list, v)
		end
	end
	return list
end

function KaifuActivityData:SetThanksFeedBackData(protocol)
	local reward_fetch_flag = protocol.reward_fetch_flag or 0
	local reward_remainder = protocol.reward_remainder or {}
	local reward_accumulative = protocol.reward_accumulative or {}

	for i=1,GameEnum.RA_APPRECIATION_REWARD_RANGE_MAX do
		if reward_remainder[i] ~= nil then
			self.thanks_feed_back_time[i] = reward_remainder[i]
		else
			self.thanks_feed_back_time[i] = 0
		end
	end

	for i=1,GameEnum.RA_APPRECIATION_REWARD_RANGE_MAX do
		if reward_accumulative[i] ~= nil then
			self.thanks_feed_back_data[i] = reward_accumulative[i]
		else
			self.thanks_feed_back_data[i] = 0
		end
	end

	self.thanks_feed_back_fetch = bit:d2b(reward_fetch_flag)
end

function KaifuActivityData:GetThanksFeedBackData()
	return self.thanks_feed_back_data or {}
end

function KaifuActivityData:GetThanksFeedBackTime()
	return self.thanks_feed_back_time or {}
end

function KaifuActivityData:GetThanksFeedBackFetch()
	return self.thanks_feed_back_fetch or {}
end

function KaifuActivityData:GetThanksTimeByIndex(index)
	if index == nil then return 0 end
	if nil ~= self.thanks_feed_back_time and index <= GameEnum.RA_APPRECIATION_REWARD_RANGE_MAX and index >= 0 then
		local limit_times = 1
		if nil ~= used and next(used) and nil ~= used[i] then
			return used[i] or 0
		end
	end
	return 0
end

-- 按钮有三种状态
function KaifuActivityData:GetThanksFeedBackActive(index)
	local fetch = self:GetThanksFeedBackFetch()
	local time = self:GetThanksFeedBackTime()
	local limit_times = self:GetThanksFeedBackLimitByIndex(index)
	if next(fetch) and next(time) then
		if fetch[32 - index] and fetch[32 - index] == 1 then
			return THANKS_FEED_BACK_BUTTON_STATE.CAN_FETCH
		elseif time[index + 1] and time[index + 1] >= limit_times then
			return THANKS_FEED_BACK_BUTTON_STATE.HAS_FETCH
		end
	end
	return THANKS_FEED_BACK_BUTTON_STATE.CAN_NOT_FETCH
end

function KaifuActivityData:GetThanksFeedBackChongZhiCount()
	if self.thanks_feed_back_data and next(self.thanks_feed_back_data) then
		local count = 0
		for k,v in pairs(self.thanks_feed_back_data) do
			count = count + v
		end
		return count
	else
		return 0
	end
end

function KaifuActivityData:GetThanksFeedBackDataByIndex(index)
	if self.thanks_feed_back_data and next(self.thanks_feed_back_data) and self.thanks_feed_back_data[index] then
		return self.thanks_feed_back_data[index]
	else
		return 0
	end
end

function KaifuActivityData:GetThanksFeedBackConfig()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().appreciation_reward or {}
end

function KaifuActivityData:GetCurThaksConfig()
	local tmp_cfg = {}
	self.thanks_reward_cfg = {}
	local openday = TimeCtrl.Instance:GetCurOpenServerDay()
	local act_data = self:GetThanksFeedBackConfig()

	if next(act_data) then
		tmp_cfg = ListToMap(act_data, "opengame_day","index")
		local use_day = nil
		for k,v in pairs(tmp_cfg) do
			if openday < k then
				--self.thanks_reward_cfg = tmp_cfg[k]
				--return self.thanks_reward_cfg
				if use_day == nil then
					use_day = k
				else
					if use_day > k then
						use_day = k
					end
				end
			end
		end

		if use_day ~= nil then
			self.thanks_reward_cfg = tmp_cfg[use_day]
			return self.thanks_reward_cfg
		end
	end

	return	{}
end

-- 是否可领取
function KaifuActivityData:GetThanksIsUsedByIndex(index)
	local fetch = self:GetThanksFeedBackFetch()
	if next(fetch) then
		if fetch[32 - index] and fetch[32 - index] == 1 then
			return true
		end
	end
	return false
end

function KaifuActivityData:GetThanksSortCfg()
	local temp_table = TableCopy(KaifuActivityData.Instance:GetCurThaksConfig())
	local tem =  {}
	if not next(temp_table) then
		return {}
	end
	for k,v in pairs(temp_table) do
		tem[k+1] = v
	end
	local data_list = {}
	for k,v in pairs(tem) do
		if nil ~= v.index then
			local temp = v
			temp.can_fetch = self:GetThanksIsUsedByIndex(v.index) and 0 or 1
			temp.has_fetch = self:GetThanksFeedBackHasFetchByIndex(v.index) and 1 or 0
			table.insert(data_list, temp)
		end
	end
	SortTools.SortAsc(data_list, "can_fetch", "has_fetch","index")
	return data_list or {}
end

function KaifuActivityData:GetThanksFeedBackHasFetchByIndex(index)
	local fetch = self:GetThanksFeedBackFetch()
	local time = self:GetThanksFeedBackTime()
	local limit_times = self:GetThanksFeedBackLimitByIndex(index)
	if next(fetch) and next(time) then
		if fetch[32 - index] and fetch[32 - index] == 0 and time[index + 1] >= limit_times then
			return true
		end
	end
	return false
end

function KaifuActivityData:GetThanksFeedBackPageCount(page_column)
	if nil ~= self.thanks_reward_cfg then
		return math.ceil(#self.thanks_reward_cfg / page_column) or 1
	else
		return 1
	end
end
-- 获取配置剩余次数
function KaifuActivityData:GetThanksFeedBackLimitByIndex(index)
	if nil == index then
		if self.thanks_reward_cfg and self.thanks_reward_cfg[0] then
			return self.thanks_reward_cfg[0].limit_times or 1
		end
	else
		if self.thanks_reward_cfg and self.thanks_reward_cfg[index] then
			return self.thanks_reward_cfg[index].limit_times or 1
		end
	end
	return 0
end

-- 获取显示的剩余次数
function KaifuActivityData:GetThanksFeedBackCurLimitTimeByIndex(index)
	local time = self:GetThanksFeedBackTime() or {}
	local limit_times = 0
	if next(time) and index ~= nil then
		limit_times = time[index + 1]
	end
	if nil == index then
		if self.thanks_reward_cfg and self.thanks_reward_cfg[1] then
			return (self.thanks_reward_cfg[1].limit_times or 1) - limit_times
		end
	else
		if self.thanks_reward_cfg and self.thanks_reward_cfg[index] then
			return (self.thanks_reward_cfg[index].limit_times or 1) - limit_times
		end
	end
	return 0
end

function KaifuActivityData:GetThanksFeedBackRedpoint()
	local cfg = self:GetThanksFeedBackData()
	if cfg and next(cfg) then
		local fetch = self:GetThanksFeedBackFetch()
		for i = 0, #cfg - 1 do
			if fetch[32 - i] == 1 then return 1 end
		end
	end
	return 0
end