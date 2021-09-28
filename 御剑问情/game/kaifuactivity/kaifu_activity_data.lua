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
	RAND_ACTIVITY_TYPE_DAILY_LOVE = 2104,					-- 每日一爱(开服活动))
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
	RAND_ACTIVITY_TYPE_UPGRADE_FOOT_RANK = 2144,			-- 足迹进阶榜(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_WING_RANK = 2145,			-- 羽翼进阶榜(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_SHENGONG_RANK = 2146,		-- 神弓进阶榜(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_SHENYI_RANK = 2147,			-- 神翼进阶榜(开服活动)
	RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN = 2148,				-- 装备强化(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE = 2149,				-- 宝石升级(开服活动)
	RAND_ACTIVITY_TYPE_HALO_RANK = 2150,					-- 光环进阶冲榜(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE_RANK = 2151,		-- 宝石等级冲榜(开服活动)
	RAND_ACTIVITY_TYPE_BOSS_LIESHOU = 2152,					-- boss猎手(开服活动)
	RAND_ACTIVITY_TYPE_ZHENG_BA = 2153,						-- 开服争霸(开服活动)
	RAND_ACTIVITY_TYPE_GODDES = 2154,						-- 女神战力榜
	RAND_ACTIVITY_TYPE_SPIRIT = 2155,						-- 精灵战力榜
	RAND_ACTIVITY_TYPE_FIGHT_MOUNT = 2156,					-- 魔骑战力榜
	RAND_ACTIVITY_TYPE_PERSON_CAPABILITY = 2157,			-- 个人总战力榜
	RAND_ACTIVITY_TYPE_SUPPER_GIFT = 2171,					-- 开服礼包限购(开服活动)
	RAND_ACTIVITY_TYPE_HUNDER_TIMES_SHOP = 2056,			-- 开服百倍商城(开服活动)
	RAND_ACTIVITY_TYPE_MARRY_ME = 2169,						-- 我们结婚吧

	-- RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI = 2115,			-- 连充特惠
	-- RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU = 2174,		-- 连充特惠初
	-- RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO = 2175,		-- 连充特惠高

	RAND_ACTIVITY_TYPE_KAIFU_INVEST = 2176,                 -- 开服投资
	RAND_ACTIVITY_TYPE_GOLDEN_PIG =	2173,					-- 金猪召唤(龙神夺宝)
	RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU = 2174,		-- 连充特惠初(开服活动)
	RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO = 2175,		-- 连充特惠高(开服活动)

	RAND_ACTIVITY_TYPE_HONG_BAO = 2170, 					-- 7日红包
	RAND_ACTIVITY_TYPE_RARE_CHANGE = 2177,					-- 珍宝兑换(开服活动)
	RAND_ACTIVITY_TYPE_SINGLE_CHARGE_2 = 2182,				-- 冲战达人
	RAND_ACTIVITY_TYPE_SINGLE_CHARGE_3 = 2183,				-- 冲战高手
	RAND_ACTIVITY_TYPE_DAY_DANBI_CHONGZHI = 2085,			-- 每日单笔
	RAND_ACTIVITY_TYPE_DAY_ACTIVIE_DEGREE = 2052, 			-- 日常活跃奖励
	RAND_ACTIVITY_TYPE_DAY_CHONGZHI_RANK = 2089, 			-- 每日充值排行榜
	RAND_ACTIVITY_TYPE_DAY_XIAOFEI_RANK = 2090, 			-- 每日消费排行榜
	-- RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_PASSIVE_RANK = 2107, 			-- 被动变身榜
	-- RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_RANK = 2108, 			-- 变身榜
	RAND_ACTIVITY_TYPE_DAY_CONSUME = 2050,					-- 每日消费
	RAND_ACTIVITY_TYPE_TOTAL_CONSUME = 2051, 	  	      	-- 累计消费
	RAND_ACTIVITY_TYPE_CHARGE_REPALMENT = 2081,				-- 累充回馈
	RAND_ACTIVITY_TYPE_DANBI_CHONGZHI = 2082,				-- 单笔充值
	RAND_DAY_CHONGZHI_FANLI = 2049,                         -- 充值返利
	RAND_ACTIVITY_TYPE_TOTAL_CHARGE = 2187, 	  	      	-- 累计充值
	RAND_ACTIVITY_TYPE_FULL_SERVER_SNAP = 2055,				-- 全服抢购
	RAND_ACTIVITY_TYPE_EXPENSE_NICE_GIFT_2 = 2236,			-- 消费好礼2
}

OPEN_SERVER_RA_ACTIVITY_TYPE = {
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_ACTIVIE_DEGREE,
	-- RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_RANK,
	-- RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_PASSIVE_RANK,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CONSUME,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHARGE_REPALMENT,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBI_CHONGZHI,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_DAY_CHONGZHI_FANLI,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CHARGE,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FULL_SERVER_SNAP,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CONSUME,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAILY_LOVE,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DANBI_CHONGZHI,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_NICE_GIFT_2,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CHONGZHI_RANK,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_XIAOFEI_RANK,
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

TEMP_ADD_ACT_TYPE = {
	WELFARE_LEVEL_ACTIVITY_TYPE = 9000,		-- 冲级豪礼
	RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU = 2174,		-- 连充特惠初
	RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO = 2175,		-- 连充特惠高
	RAND_DAY_CHONGZHI_FANLI = 2049,			--充值返利
	RAND_ACTIVITY_TYPE_SUPPER_GIFT = 2171,	-- 礼包限购
	ZHIZUN_HUIYUAN_ACTIVITY_TYPE = 9100,	-- 至尊会员
	LEVEL_INVEST_ACTIVITY_TYPE = 9200,		-- 等级投资
	TOUZI_PLAN_ACTIVITY_TYPE = 9300,		-- 投资计划
}

TempAddActivityType = {
	{activity_type = TEMP_ADD_ACT_TYPE.WELFARE_LEVEL_ACTIVITY_TYPE, name = Language.Activity.WelfareLevel},
	{activity_type = TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU, name = Language.Activity.LianChongTeHuiChu},
	{activity_type = TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO, name = Language.Activity.LianChongTeHuiGao},
	{activity_type = TEMP_ADD_ACT_TYPE.ZHIZUN_HUIYUAN_ACTIVITY_TYPE, name = Language.Activity.ZhiZunHuiYuan},
	{activity_type = TEMP_ADD_ACT_TYPE.LEVEL_INVEST_ACTIVITY_TYPE, name = Language.Activity.LevelInvest},
	{activity_type = TEMP_ADD_ACT_TYPE.TOUZI_PLAN_ACTIVITY_TYPE, name = Language.Activity.TouZiPlan},
}

-- 在开服活动界面和精彩活动界面都要显示的随机活动
RandActivityInKaifuView = {
	{activity_type = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GOLDEN_PIG, name = Language.Activity.GoldenPigCall},
	{activity_type = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_KAIFU_INVEST, name = Language.Activity.KaiFuInvest},
}

SYSTEM_TYPE = {
	MOUNT = 0,
	WING = 1,
	FOOT = 6,
	HALO = 3,
	FIGHT_MOUNT = 5,
	SHEN_GONG = 2,
	SHEN_YI = 4,
}

NotShowHeFuActivity =
{
	[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_GONGCHENGZHAN] = 1,
	[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_XIANMENGZHAN] = 1,
}

local MAX_ACTIVITY_TYPE = 29 	-- 最大活动数
local hefu_touzi = {reward_desc = "投资计划", end_day = 3, sub_type = 15, name = "合服投资"}		--防止玩家买了但活动结束了页面没了，得手动加上去

-- 开服活动排序
local ACTIVITY_SORT_INDEX_LIST = {
	[1] = TEMP_ADD_ACT_TYPE.ZHIZUN_HUIYUAN_ACTIVITY_TYPE,						--至尊会员
	[2] = TEMP_ADD_ACT_TYPE.TOUZI_PLAN_ACTIVITY_TYPE,							--成长基金
	[3] = TEMP_ADD_ACT_TYPE.LEVEL_INVEST_ACTIVITY_TYPE,							--等级投资
	[4] = TEMP_ADD_ACT_TYPE.WELFARE_LEVEL_ACTIVITY_TYPE, 						--冲级豪礼
	[5]	= TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU,			-- 连充特惠
	[6]	= TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO,			-- 连充特惠高
	[7]	= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GOLDEN_PIG,			-- 龙神召唤（原金猪召唤）
	[8] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPPER_GIFT,			-- 礼包限购
	[9] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUNDER_TIMES_SHOP,	-- 个人抢购
	[10] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_NICE_GIFT_2,	-- 消费好礼2
	[11] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIRST_CHARGE_TUAN,	-- 首充团购
	[12] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BOSS_LIESHOU,		-- Boo猎手
	[13] = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION,					-- 集字活动
	[14] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_KAIFU_INVEST,		-- 活跃投资
	[15] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HONG_BAO,			-- 红包好礼
	[16] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RARE_CHANGE,			-- 珍宝兑换
}

FASHION_SHOW_TYPE = {
	ROLE = 1,
	WEAPON = 2,
	MOUNT = 3,
	WING = 4,
	HALO = 5,
	FOOT = 6,
	FIGHTMOUNT = 7,
	GODDRESS = 8,
	GODDRESS_HALO = 9,
	GODDRESS_FAZHEN = 10,
	SPIRIT = 11,
	SHENG_WU = 12,
}

INVEST_STATE = {outtime = 1, no_finish = 2, finish = 3, complete = 4, no_invest = 5}

INVEST_TYPE_TYPE_POSION = {BOSS = 32, ACTIVE = 24, COMPETITION = 16}

KAIFU_INVEST_TYPE = {
    ["BOSS"] = 0,
    ["ACTIVE"] = 1,
    ["COMPETITION"] = 2,
}


function KaifuActivityData:__init()
	if KaifuActivityData.Instance ~= nil then
		print_error("[KaifuActivityData] Attemp to create a singleton twice !")
		return
	end
	KaifuActivityData.Instance = self
	self.touzi_min_level = 2000
	self.touzi_close_state = false
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
	self.golden_pig_call_info = {}
	self.golden_pig_boss_info = {}
	self.golden_pig_monster_list = {}
	self.fetch_reward_flag = 0
	self.reward_fetch_flag = {}
	self.reward_active_flag = {}
	self.can_reward = {}
    self.fetch_reward = {}
    self.rare_reward_fetch = {}

	self.role_change_times = 0
	self.rank_count = 0
	self.bei_bianshen_rank_list = {}

	self.total_consume_info = {}
	self.recharge_rebate_info = {}

	self.total_charge_info = {}

	self.special_appearance_role_change_times = 0
	self.special_appearance_rank_count = 0

	self.open_cfg = ConfigManager.Instance:GetAutoConfig("randactivityopencfg_auto").open_cfg

	self.opengameactivity_cfg = ConfigManager.Instance:GetAutoConfig("opengameactivity_auto")

	self.leiji_chongzhi_info = {}

	self.special_tab_name = self:GetSpecialName()

	self.rsing_star_info = {}
 	self.rsing_star_info.is_get_reward_today = 0
	self.rsing_star_info.chognzhi_today = 0
	self.rsing_star_info.func_level = 0
	self.rsing_star_info.func_type = 0
	self.rsing_star_info.is_max_level = 0
	self.rsing_star_info.stall = 0

	self.daily_love_is_open = false 	--用于记录本次登录，每日一爱面板是否被打开过
	self.item_collection_Last_remindTime = 0 --红包上次打开时间

	self.zhengba_red_point_state = true
	RemindManager.Instance:Register(RemindName.KaiFu, BindTool.Bind(self.GetNewServerRemind, self))
	RemindManager.Instance:Register(RemindName.KfLeichong, BindTool.Bind(self.GetKfLeichongRemind, self))
	RemindManager.Instance:Register(RemindName.LianChongTeHuiChu, BindTool.Bind(self.GetLianChongTeHuiChuRemind, self))
	RemindManager.Instance:Register(RemindName.LianChongTeHuiGao, BindTool.Bind(self.GetLianChongTeHuiGaoRemind, self))
	RemindManager.Instance:Register(RemindName.RisingStar, BindTool.Bind(self.GetRisingStarRemind, self))
	RemindManager.Instance:Register(RemindName.ExpenseNiceGiftRemind_2,BindTool.Bind(self.IsShowExpenseNiceGiftRedPoint,self))
end

function KaifuActivityData:__delete()
	RemindManager.Instance:UnRegister(RemindName.KaiFu)
	RemindManager.Instance:UnRegister(RemindName.KfLeichong)
	RemindManager.Instance:UnRegister(RemindName.LianChongTeHuiChu)
	RemindManager.Instance:UnRegister(RemindName.LianChongTeHuiGao)
	RemindManager.Instance:UnRegister(RemindName.RisingStar)
	RemindManager.Instance:UnRegister(RemindName.ExpenseNiceGiftRemind_2)

	self.info = {}
	self.upgrade_info = {}
	self.rank_info = {}
	self.boss_lieshou_info = {}
	self.activity_reward_cfg = {}
	self.degree_rewards_cfg = {}
	self.opengameactivity_cfg = {}
	self.battle_uid_info = {}
	self.open_cfg = {}
	self.battle_role_info = {}
	self.battle_activity_info = {}
	self.act_change_callback = {}
	self.leiji_chongzhi_info = {}
	self.golden_pig_call_info = {}
	self.golden_pig_boss_info = {}
	self.golden_pig_monster_list = {}
	self.total_consume_info = {}
	self.total_charge_info = {}
	self.recharge_rebate_info = {}
	self.can_reward = {}
    self.fetch_reward = {}
	self.info_chu = nil
	self.info_gao = nil
	KaifuActivityData.Instance = nil
end

function KaifuActivityData:ClearActivityInfo()
	self.info = {}
	self.battle_uid_info = {}
	self.battle_role_info = {}
	self.expense_nice_gift_page_cfg = {}
end

-- 开服活动信息
function KaifuActivityData:SetActivityInfo(protocol)
	local type_info = {}
	type_info.rand_activity_type = protocol.rand_activity_type
	type_info.reward_flag = protocol.reward_flag
	type_info.complete_flag = protocol.complete_flag
	type_info.today_chongzhi_role_count = protocol.today_chongzhi_role_count
	--  装备强化活动不要了 不接受数据
	if type_info.rand_activity_type ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN then
		self.info[type_info.rand_activity_type] = type_info
	end
end

function KaifuActivityData:GetActivityInfo(rand_activity_type)
	return self.info[rand_activity_type]
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
	type_info.capability = protocol.capability
	type_info.avatar_key_big = protocol.avatar_key_big
	type_info.avatar_key_small = protocol.avatar_key_small
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
	self.leiji_chongzhi_info = protocol
	ViewManager.Instance:FlushView(ViewName.Main, "leiji_charge")
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

-- 金猪召唤(召唤积分信息)
function KaifuActivityData:SetGoldenPigCallInfo(protocol)
	self.golden_pig_call_info = protocol

end

function KaifuActivityData:GetGoldenPigCallInfo()
	return self.golden_pig_call_info
end

-- 金猪召唤(召唤boss状态信息)
function KaifuActivityData:SetGoldenPigCallBossInfo(protocol)
	self.golden_pig_boss_info = protocol
end

function KaifuActivityData:GetGoldenPigCallBossInfo()
	return self.golden_pig_boss_info
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

	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_NICE_GIFT_2 and status == ACTIVITY_STATUS.OPEN then
       	RemindManager.Instance:Fire(RemindName.ExpenseNiceGiftRemind_2)
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
function KaifuActivityData:GetKaifuActivityCfg()
	if not self.activity_reward_cfg then
		self.activity_reward_cfg = PlayerData.Instance:GetCurrentRandActivityConfig().openserver_reward
	end
	return self.activity_reward_cfg
end

function KaifuActivityData:GetKaifuActivityOpenCfg()
	if not self.open_cfg then
		self.open_cfg = ConfigManager.Instance:GetAutoConfig("randactivityopencfg_auto").open_cfg
	end
	return self.open_cfg
end

function KaifuActivityData:GetKaifiBiPinCfg()
	if not self.bipin_cfg then
		self.bipin_cfg = ConfigManager.Instance:GetAutoConfig("randactivityopencfg_auto").bipin_cfg
	end
	return self.bipin_cfg
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
	local now_cfg_day = 0
	for k, v in pairs(self.personal_panic_buy_cfg) do
		if v.opengame_day >= server_day then
			now_cfg_day = v.opengame_day
			break
		end
	end
	for k, v in pairs(self.personal_panic_buy_cfg) do
		if v.opengame_day == now_cfg_day then
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
	for k, v in pairs(self.opengameactivity_cfg.gift_shop) do
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
	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	for k, v in pairs(self:GetKaifuActivityCfg()) do
		if v.activity_type == activity_type and (tonumber(v.opengame_day) > 100 or tonumber(v.opengame_day) == server_day) then
			table.insert(list, v)
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
	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MARRY_ME
		--or activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HONG_BAO
		or activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE
		or self:IsAdvanceRankType(activity_type)
		or activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE_RANK
		or self:IsZhengBaType(activity_type)
		or activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CORNUCOPIA
		or activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GODDES
		or activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPIRIT
		or activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIGHT_MOUNT
		or activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PERSON_CAPABILITY then

		return true
	end

	return false
end

function KaifuActivityData:CacheActivityList(list)
	self.cache_open_activity_list = list
end

function KaifuActivityData:DelCacheActivityList()
	self.cache_open_activity_list = nil
end

-- activity_type 小于100的用作合服活动
function KaifuActivityData:GetOpenActivityList(day)
	if nil ~= self.cache_open_activity_list then
		return self.cache_open_activity_list
	end

	local list = {}
	-- list[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_NICE_GIFT_2] =
	-- {activity_type = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_NICE_GIFT_2,name = "消费好礼",open_type = 0}
	for k, v in pairs(self:GetKaifuActivityOpenCfg()) do
		if v.activity_type ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HONG_BAO and ActivityData.Instance:GetActivityIsOpen(v.activity_type) and v.is_openserver == 1 and not self:IsIgnoreType(v.activity_type) then
			if self:IsBossLieshouType(v.activity_type) then
				if self:IsShowBossTab() then
					--table.insert(list, v)
					list[v.activity_type] = v
				end
			else
				--table.insert(list, v)
				list[v.activity_type] = v
			end
		elseif v.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HONG_BAO then
		 	if TimeCtrl.Instance:GetCurOpenServerDay() < 8 or (not ActiviteHongBaoData.Instance:IsGetAll() or ActiviteHongBaoData.Instance:IsRead()) then
				list[v.activity_type] = v
			end
		end
	end
	for i,v in ipairs(OPEN_SERVER_RA_ACTIVITY_TYPE) do
		if ActivityData.Instance:GetActivityIsOpen(v) then
			-- table.insert(list, {activity_type=v, name=Language.Activity.KaiFuActivityName[v]})
			list[v] = {activity_type=v, name=Language.Activity.KaiFuActivityName[v]}
		end
	end

	for _, v in pairs(self:GetTempAddActivityTypeList()) do
		list[v.activity_type] = v
	end

	for k,v in pairs(RandActivityInKaifuView) do
		if ActivityData.Instance:GetActivityIsOpen(v.activity_type) then

			list[v.activity_type] = v
		end
	end

	-- 合服活动
	local hefu_list = HefuActivityData.Instance:GetCombineSubActivityList()
	for i,v in ipairs(hefu_list) do
		if nil == NotShowHeFuActivity[v.sub_type] then
			list[v.sub_type] = v
		end
	end


	local temp_list = {}
	for _, v in ipairs(ACTIVITY_SORT_INDEX_LIST) do
		local activity = list[v]
		if activity ~= nil then
			table.insert(temp_list, activity)
			list[v] = nil
		end
	end

	for _, v in pairs(list) do
		table.insert(temp_list, v)
	end

	--暂时不开启珍宝兑换活动
	for k,v in pairs(temp_list) do
		if v.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RARE_CHANGE then
			table.remove(temp_list, k)
		end
	end

	--投资计划，等级超出并且领完返利则不显示该活动
	local plan_index = InvestData.Instance:GetNormalActivePlan()
	if plan_index < 0 then
		plan_index = 2
	end

	for k, v in pairs(temp_list) do
		if v.activity_type == TEMP_ADD_ACT_TYPE.LEVEL_INVEST_ACTIVITY_TYPE then
			if not InvestData.Instance:CanInvestLevel(0) and not InvestData.Instance:CanInvestLevel(1) and not InvestData.Instance:CanInvestLevel(2)
			and (InvestData.Instance:GetRewardStateInfo(plan_index) or InvestData.Instance:GetActiveHighestPlan() == -1) then

				table.remove(temp_list, k)
			end
		end
	end

	--成长基金，等级超出并且领完返利则不显示该活动
	for k, v in pairs(temp_list) do
		if v.activity_type == TEMP_ADD_ACT_TYPE.TOUZI_PLAN_ACTIVITY_TYPE then
			if self:CanShowTouZiPlan() then
				MainUIView.Instance:CloseTouZiButton()
				table.remove(temp_list, k)
			end
		end
	end

	--每日一爱，如果玩家充值了，则不显示该活动
	local chong_zhi_info = DailyChargeData.Instance:GetChongZhiInfo()
	local chongzhi_info_is_not_nil = next(chong_zhi_info)
	for k,v in pairs(temp_list) do
		if v.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAILY_LOVE and DailyChargeData.Instance then
			if chongzhi_info_is_not_nil and chong_zhi_info.today_recharge > 0 then
				table.remove(temp_list, k)
			end
		end
	end

	-- 合服投资，领完消失, hefu_touzi_state 为false就关闭
	local hefu_touzi_state = HefuActivityData.Instance:HeFuTouZiIsClose()
	if not hefu_touzi_state then
		for k,v in pairs(temp_list) do
			if v.sub_type == COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_TOUZI then
				table.remove(temp_list, k)
				break
			end
		end
	end

	-- 这里是玩家购买了合服投资但没领完，手动加上去显示界面
	local can_show_touzi = HefuActivityData.Instance:HeFuTouZiCloseCanGet()
	local show_touzi_state = true
	if can_show_touzi then
		for k,v in pairs(temp_list) do
			if v.sub_type == COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_TOUZI then
				show_touzi_state = false
			end
		end

		if show_touzi_state then
			table.insert(temp_list, hefu_touzi)
		end
	end

	-- IOS审核时，需要屏蔽至尊会员
	if IS_AUDIT_VERSION then
		for k,v in pairs(temp_list) do
			if v.activity_type == TEMP_ADD_ACT_TYPE.ZHIZUN_HUIYUAN_ACTIVITY_TYPE then
				table.remove(temp_list, k)
				break
			end
		end
	end
	return temp_list
end

-- 从别的地方加进来的，类似冲级豪礼
function KaifuActivityData:GetTempAddActivityTypeList()
	local list = {}
	local openchu_start, openchu_end = KaifuActivityData.Instance:GetActivityOpenDay(TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU)
	local opengao_start, opengao_end = KaifuActivityData.Instance:GetActivityOpenDay(TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO)
	local openchu_time = openchu_end - TimeCtrl.Instance:GetServerTime()
	local opengao_time = opengao_end - TimeCtrl.Instance:GetServerTime()
	for i = 1, #TempAddActivityType do
		local cfg = {}
		if opengao_time <= 0 and openchu_time > 0 then
			if TempAddActivityType[i].activity_type ~= TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO then
				cfg.activity_type = TempAddActivityType[i].activity_type
				cfg.name = TempAddActivityType[i].name
				table.insert(list, cfg)
			end
		elseif opengao_time > 0 and openchu_time <= 0 then
			if TempAddActivityType[i].activity_type ~= TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU then
				cfg.activity_type = TempAddActivityType[i].activity_type
				cfg.name = TempAddActivityType[i].name
				table.insert(list, cfg)
			end
		elseif opengao_time <= 0 and openchu_time <= 0 then
			if TempAddActivityType[i].activity_type ~= TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO and TempAddActivityType[i].activity_type ~= TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU then
				cfg.activity_type = TempAddActivityType[i].activity_type
				cfg.name = TempAddActivityType[i].name
				table.insert(list, cfg)
			end
		elseif opengao_time > 0 and openchu_time > 0 then
			cfg.activity_type = TempAddActivityType[i].activity_type
			cfg.name = TempAddActivityType[i].name
			table.insert(list, cfg)
		end

	end
	-- if openchu_time <= 0 then
	-- 	for i = 1, #list do
	-- 		if list[i].activity_type == TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU then
	-- 			table.remove(list, i)
	-- 			print_error(list)
	-- 		end
	-- 	end
	-- end

	-- if opengao_time <= 0 then
	-- 	for i = 1, #list do
	-- 		if list[i].activity_type == TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO then
	-- 			table.remove(list, i)
	-- 			print_error(list)
	-- 		end
	-- 	end
	-- end
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

	if RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GOLDEN_PIG == activity_type then
		return true
	end
	return false
end

function KaifuActivityData:ShowWhichPanelByType(activity_type)
	if activity_type == nil then return nil end

	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION then
		return TabIndex.kaifu_panel_two
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE then
		return TabIndex.kaifu_panel_ten
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPPER_GIFT then
		return TabIndex.kaifu_panel_twelve
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUNDER_TIMES_SHOP then
		return TabIndex.kaifu_personbuy
	end

	if activity_type == TEMP_ADD_ACT_TYPE.WELFARE_LEVEL_ACTIVITY_TYPE then
		return TabIndex.kaifu_levelreward
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HONG_BAO then
		return TabIndex.kaifu_7dayredpacket
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GOLDEN_PIG  then
		return TabIndex.kaifu_goldenpigcall
	end

	if activity_type == TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO then
		return TabIndex.kaifu_lianxuchongzhigao
	end


	if activity_type == TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU then
		return TabIndex.kaifu_lianxuchongzhichu
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_KAIFU_INVEST then
		return TabIndex.kaifu_panel_fifteen
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RARE_CHANGE then
		return TabIndex.kaifu_panel_sixteen
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_ACTIVIE_DEGREE then
		return TabIndex.kaifu_dailyactivereward
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DANBI_CHONGZHI then
		return TabIndex.kaifu_daychongzhi
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CHONGZHI_RANK then
		return TabIndex.kaifu_congzhirank
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_XIAOFEI_RANK then
		return TabIndex.kaifu_xiaofeirank
	end

	-- if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_RANK then
	-- 	return TabIndex.kaifu_bianshenrank
	-- end

	-- if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_PASSIVE_RANK then
	-- 	return TabIndex.kaifu_beibianshenrank
	-- end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CONSUME then 		--每日消费
		return TabIndex.kaifu_dayconsume
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAILY_LOVE then 		--每日一爱
		return TabIndex.kaifu_daily_love
	end

	if activity_type == TEMP_ADD_ACT_TYPE.ZHIZUN_HUIYUAN_ACTIVITY_TYPE then 					--至尊会员
		return TabIndex.kaifu_ZhiZunHuiYuan
	end

	if activity_type == TEMP_ADD_ACT_TYPE.LEVEL_INVEST_ACTIVITY_TYPE then 						--等级投资
		return TabIndex.kaifu_levelinvest
	end

	if activity_type == TEMP_ADD_ACT_TYPE.TOUZI_PLAN_ACTIVITY_TYPE then 						--成长基金
		return TabIndex.kaifu_touziplan
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CONSUME then     	--累计消费
		return TabIndex.kaifu_totalconsume
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHARGE_REPALMENT then
		return TabIndex.kaifu_leijireward
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBI_CHONGZHI then
		return TabIndex.kaifu_danbichongzhi
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_DAY_CHONGZHI_FANLI then
		return TabIndex.kaifu_rechargerebate
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CHARGE then
		return TabIndex.kaifu_totalcharge
	end
	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FULL_SERVER_SNAP then
		return TabIndex.kaifu_fullserversnap
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_NICE_GIFT_2 then
		return TabIndex.expense_nice_gift
	end

	for i = 1, MAX_ACTIVITY_TYPE do
		if AdvanceType[i] == activity_type or NormalType[i] and NormalType[i] == activity_type or
			activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_TOTAL_CHARGE
			or activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN
			or activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE then
			return TabIndex.kaifu_panel_one
		end
		if RankType[i] and RankType[i] == activity_type or activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE_RANK then
			return TabIndex.kaifu_panel_six
		end
		if ChongzhiType[i] and ChongzhiType[i] == activity_type and ChongzhiType[i] ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_TOTAL_CHARGE then
			return TabIndex.kaifu_panel_three
		end

		if self:IsZhengBaType(activity_type) then
			return TabIndex.kaifu_panel_seven
		end

		if BossType[i] and BossType[i] == activity_type then
			return TabIndex.kaifu_panel_eight
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
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN then
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
	if self:IsShowGoldenPigRedPoint() then
		num = num + 1
	end

	for k, v in pairs(self.info or {}) do
		-- 冲级豪礼上面有判断 WelfareData.Instance:GetLevelRewardRemind() ，故这里剔除
		if k ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ROLE_UPLEVEL then
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
	end
	-- if next(self.boss_lieshou_info) and self:IsShowBossRedPoint() then
	-- 	num = num + 1
	-- end

	-- if ActiviteHongBaoData.Instance:GetHongBaoRemind() then
	-- 	num = num + 1
	-- end
	-- if self:IsShowZhengbaRedPoint() then
	-- 	return true
	-- end

	-- if self:IsShowLeiJiChongZhiRedPoint() then
	-- 	return true
	-- end
	if self:ShowInvestRedPoint() then
		num = num + 1
	end
	if self:IsShowDayActiveRedPoint() then
		num = num +1
	end

	if self:IsDayConsumeRedPoint() then
		num = num + 1
	end

	if self:IsDailyDanBiRedPoint() then
		num = num +1
	end

	if self:IsTotalConsumeRedPoint() then
		num = num +1
	end

	if self:GetLeiJiChargeRewardRedPoint() then
		num = num + 1
	end

	if self:IsTotalChargeRedPoint() then
		num = num +1
	end

	if self:IsRechargeRebateRedPoint() then
		num = num + 1
	end

	if self:IsZhiZunHuiYuanRedPoint() then
		num = num + 1
	end
	if self:IsLevelInvestRedPoint() then
		num = num +1
	end

	if self:IsTouZiPlanRedPoint() then
		num = num +1
	end

	if self:LianChongTeHuiGaoRedPoint() then
		num = num + 1
	end

	if self:LianChongTeHuiChuRedPoint() then
		num = num + 1
	end

	-------------------合服的小红点---------------
	if self:IsHeFu(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_LOGIN_Gift) and
		HefuActivityData.Instance:GetShowRedPointBySubType(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_LOGIN_Gift) == true then
		num = num + 1
	end

	if self:IsHeFu(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_KILL_BOSS) and
		HefuActivityData.Instance:GetShowRedPointBySubType(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_KILL_BOSS) == true then
		num = num + 1
	end

	if self:IsHeFu(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_TOUZI) and
		HefuActivityData.Instance:GetShowRedPointBySubType(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_TOUZI) == true then
		num = num + 1
	end

	if self:IsHeFu(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_JIJIN) and
		HefuActivityData.Instance:GetShowRedPointBySubType(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_JIJIN) == true then
		num = num + 1
	end
	----------------------------------------------

	return num
end

function KaifuActivityData:IsHeFu(sub_type)
	local data = self:GetOpenActivityList()
	for i,v in pairs(data) do
		if v.sub_type ~= nil and v.sub_type == sub_type then
			return true
		end
	end
	return false
end

function KaifuActivityData:IsShowNewServerRedPoint()
	if self:IsShowJiZiRedPoint() then
		return true
	end

	if WelfareData.Instance:GetLevelRewardRemind() > 0 then
		return true
	end

	if self:IsShowGoldenPigRedPoint() then
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

	if self:ShowInvestRedPoint() then
		return true
	end
	-- if self:IsShowZhengbaRedPoint() then
	-- 	return true
	-- end

	-- if self:IsShowLeiJiChongZhiRedPoint() then
	-- 	return true
	-- end

	if self:IsShowDayActiveRedPoint() then
		num = num +1
	end
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

		v.flag = 1

		if is_get and is_complete then
			v.flag = 0
		end
		if is_complete and not is_get then
			v.flag = 2
		end
		-- if not is_complete and not is_get then
		-- 	v.flag = 1
		-- end
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

function KaifuActivityData:LianChongTeHuiGaoRedPoint()
	local chongzhi_info = self:GetChongZhiGao()
	local cfg = self:ChongZhiTeHuiGao() or {}
	local is_red = false
	if nil == chongzhi_info then
		return false
	end

	if chongzhi_info.can_fetch_reward_flag == chongzhi_info.has_fetch_reward_falg then
		is_red = false
	elseif chongzhi_info.can_fetch_reward_flag ~= chongzhi_info.has_fetch_reward_falg then
		for k, v in pairs(cfg) do
			if bit:d2b(chongzhi_info.has_fetch_reward_falg)[32-v.day_index] ~= bit:d2b(chongzhi_info.can_fetch_reward_flag)[32-v.day_index] then
				is_red = true
			end
		end
	end
	return is_red
end

function KaifuActivityData:GetLianChongTeHuiChuRemind()
	if not ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU) then return 0 end
	local is_first_open = self:IsFirstChuOpen()
	local is_show = is_first_open == true and (is_first_open or self:LianChongTeHuiChuRedPoint())
	return is_show and 1 or 0
end

function KaifuActivityData:GetLianChongTeHuiGaoRemind()
	if not ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO) then return 0 end
	local is_first_open = self:IsFirstGaoOpen()
	local is_show = is_first_open or self:LianChongTeHuiGaoRedPoint()

	return is_show and 1 or 0
end

function KaifuActivityData:GetRisingStarRemind()
	local is_remind_today = RemindManager.Instance:RemindToday(RemindName.RisingStar)
	local cond_1 = 0 == self.rsing_star_info.is_max_level
	local cond_2 = self.rsing_star_info.stall - self.rsing_star_info.is_get_reward_today > 0
	local cond_3 = OpenFunData.Instance:CheckIsHide("risingstar")

	local cond_value = (not is_remind_today) or (cond_1 and cond_2 and cond_3)
	return cond_value and 1 or 0
end

function KaifuActivityData:IsFirstGaoOpen()
	local is_red = false
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local remind_day = UnityEngine.PlayerPrefs.GetInt(main_role_id .. "lianchongtehui_gao")
	if remind_day == cur_day then
		is_red = false
	else
		is_red = true
	end
	return is_red
end

function KaifuActivityData:IsFirstChuOpen()
	local is_red = false
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local remind_day = UnityEngine.PlayerPrefs.GetInt(main_role_id .. "lianchongtehui_chu")
	if remind_day == cur_day then
		is_red = false
	else
		is_red = true
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

	if chongzhi_info.can_fetch_reward_flag == chongzhi_info.has_fetch_reward_falg then
		is_red = false
	elseif chongzhi_info.can_fetch_reward_flag ~= chongzhi_info.has_fetch_reward_falg then
		for k, v in pairs(cfg) do
			if bit:d2b(chongzhi_info.has_fetch_reward_falg)[32-v.day_index] ~= bit:d2b(chongzhi_info.can_fetch_reward_flag)[32-v.day_index] then
				is_red = true
			end
		end
	end
	return is_red
end


function KaifuActivityData:IsShowGoldenPigRedPoint()
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GOLDEN_PIG) then return false end
	local boss_state_info = KaifuActivityData.Instance:GetGoldenPigCallBossInfo()
	local level = GameVoManager.Instance:GetMainRoleVo().level
	for i,v in ipairs(boss_state_info) do
		--等级超过170级出现红点
    	if v == 1 and level >= 170 then
			return true
    	end
    end

	local godlen_info = self:GetGoldenPigCallInfo()
	if nil ~= godlen_info.summon_credit and godlen_info.summon_credit > 0 and level >= 170 then
		return true
	end

	return false
end

function KaifuActivityData:SetCollectionLastRemindTime(time)
	self.item_collection_Last_remindTime = time
end

function KaifuActivityData:IsShowJiZiRedPoint()
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION) then return false end


	local time_conditon = TimeCtrl.Instance:GetServerTime() - self.item_collection_Last_remindTime > GameEnum.ZIJI_INTERVAL_TIME - 1

	local times_t = KaifuActivityData.Instance:GetCollectExchangeInfo()
	local rand_act_cfg = PlayerData.Instance:GetCurrentRandActivityConfig()
	if nil == times_t or nil == rand_act_cfg or nil == rand_act_cfg.item_collection then
		return false
	end

	local can_get = nil
	for k, v in pairs(rand_act_cfg.item_collection) do
		local times = times_t[v.seq + 1] or 0
		if times < v.exchange_times_limit then
			can_get = true
			for i = 1, 4 do
				local num = ItemData.Instance:GetItemNumInBagById(v["stuff_id" .. i].item_id)
				if v["stuff_id" .. i].item_id > 0 and num < v["stuff_id" .. i].num then
					can_get = false
				end
			end
			if can_get then
				break
			end
		end
	end

	local is_remind_today = RemindManager.Instance:RemindToday(RemindName.JiZiAct)
	if not is_remind_today then
		return true
	end

	return time_conditon and can_get
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
	local list = ActivityData.Instance:GetRandActivityConfig(PlayerData.Instance:GetCurrentRandActivityConfig().rand_total_chongzhi, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE)
	-- for k,v in pairs(PlayerData.Instance:GetCurrentRandActivityConfig().rand_total_chongzhi) do
	-- 	if v.opengame_day <= 7 and v.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE then
	-- 		table.insert(list, v)
	-- 	end
	-- end
	-- table.sort(list, function(a, b)
	-- 	return a.seq < b.seq
	-- end)
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
	return {}
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
	if not self:IsShowLeiJiRechargeIcon() or
		not ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE) then
		return false
	end
	if not RemindManager.Instance:RemindToday(RemindName.KfLeichong) then
		return true
	end
	for k, v in pairs(self:GetLeijiChongZhiFlagCfg()) do
		if v.flag and v.flag == 2 then
			return true
		end
	end
	return false
end

-- 是否显示主界面图标
function KaifuActivityData:IsShowKaifuIcon()
	if not IS_ON_CROSSSERVER and (ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.OPEN_SERVER) or
		(ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BOSS_LIESHOU) and self:IsShowBossTab())
		or #self:GetTempAddActivityTypeList() > 0) then

		return true
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

----------------------------------------------------
--金猪召唤相关配置（基础配置）
function KaifuActivityData:GetGoldenPigBasisCfg()
	if not self.golden_pig_summon_basis_cfg then
		self.golden_pig_summon_basis_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().golden_pig_summon_basis
	end

	return self.golden_pig_summon_basis_cfg
end

--（召唤配置）
function KaifuActivityData:GetGoldenPigCallCfg()
	if not self.golden_pig_call_cfg then
		self.golden_pig_call_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().golden_pig_reward
	end

	return self.golden_pig_call_cfg

end

--(召唤成功获取奖励坐标)
function KaifuActivityData:GetGoldenCallPositionCfg(id)
	local cfg = self:GetGoldenPigBasisCfg()
	local name_list = {
		[0] = "junior",
		[1] = "medium",
		[2] = "senior",
	}
	local pos_list = {}
	pos_list.scene_id = cfg[1].scene_id
	pos_list.pos_x = cfg[1][name_list[id] .. "_summon_pos_x"]
	pos_list.pos_y = cfg[1][name_list[id] .. "_summon_pos_y"]

	return pos_list
end

function KaifuActivityData:GetIsGoldenPigMonsterById(monster_id)
	if nil == monster_id then return false end

	if nil == next(self.golden_pig_monster_list) then
		local cfg = self:GetGoldenPigCallCfg()
		for k,v in pairs(cfg) do
			self.golden_pig_monster_list[v.monster_id] = 1
		end
	end

	return self.golden_pig_monster_list[monster_id] == 1

end

function KaifuActivityData:GetCurCallCfg()
	local call_cfg = self:GetGoldenPigCallCfg()
	local item_img_list = {}
	local cur_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	for i,v in ipairs(call_cfg) do
		if cur_server_day <= v.opengame_day then
			if nil ~= item_img_list[1] and v.opengame_day ~= item_img_list[1].opengame_day then
				break
			end
			item_img_list[v.summon_type + 1] = v
		end
	end
	return item_img_list
end

-- 我们结婚吧配置表
function KaifuActivityData:GetMarryMeCfg()
	if not self.marry_me_cfg then
		self.marry_me_cfg = PlayerData.Instance:GetCurrentRandActivityConfig().marry_me
	end
	return self.marry_me_cfg
end

-- 我们结婚吧配置表
function KaifuActivityData:GetZhenBaoGeCfg()
	if not self.zhenbaoge_cfg then
		self.zhenbaoge_cfg = PlayerData.Instance:GetCurrentRandActivityConfig().zhenbaoge
	end
	local config = ActivityData.Instance:GetRandActivityConfig(self.zhenbaoge_cfg, ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT)
	return config
end

-- 至尊豪礼
function KaifuActivityData:GetZhenBaoGe2Cfg()
	if not self.zhenbaoge2_cfg then
		local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().zhenbaoge2
		self.zhenbaoge2_cfg = ActivityData.Instance:GetRandActivityConfig(randact_cfg, ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_BUSINESSMAN)
	end
	return self.zhenbaoge2_cfg
end

function KaifuActivityData:ShowCurIndex()
	local chongzhi_cfg = self:GetLeijiChongZhiFlagCfg()
	for i = 0, 9 do
		if chongzhi_cfg[i] and chongzhi_cfg[i].flag == 2 then
			return i
		end
	end
	for i=0, 9 do
		if chongzhi_cfg[i] and chongzhi_cfg[i].flag == 1 then
			return i
		end
	end
	return -1
end

-- 连充特惠高配置
function KaifuActivityData:ChongZhiTeHuiGao()
	local list_gao = {}
	local temp_table = {}
	local openday = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig() or {}
	local today = self:ChongZhiTeHuiGaoList()
	if nil == cfg then
		return list_gao
	end

 	if ServerActivityData.Instance then
 		for k, v in pairs(cfg.continue_chonghzi_gao) do
 			if v.open_server_day == today then
 				table.insert(temp_table, cfg.continue_chonghzi_gao[k])
 			end
 		end
 		self.teihuigao = temp_table
 	end

	if nil ~= self:GetChongZhiGao() and nil ~= self.teihuigao then
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

function KaifuActivityData:ChongZhiTeHuiChuList()
	local openday = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig() or {}
	for k, v in pairs(cfg.continue_chonghzi_chu) do
		if openday <= v.open_server_day then
			return v.open_server_day
		end
	end
end

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

function KaifuActivityData:GetActivityOpenDay(openday_type)
	local openday_start = 0
	local openday_end = 0
	local openday_info = ActivityData.Instance:GetActivityStatus()
	if nil ~= openday_info[openday_type] then
		openday_start = openday_info[openday_type].start_time
		openday_end = openday_info[openday_type].end_time
	end
	return openday_start, openday_end

end

----------------- 每日单笔 -------------------------

function KaifuActivityData:SetDailyDanBiInfo(protocol)
	self.daily_danbi_info = {}
	self.daily_danbi_info.can_fetch_reward_flag = bit:d2b(protocol.can_fetch_reward_flag)
	self.daily_danbi_info.fetch_reward_flag = bit:d2b(protocol.fetch_reward_flag)
end

function KaifuActivityData:GetDailyDanBiInfo()
	return self.daily_danbi_info
end

function KaifuActivityData:FlushDailyDanBiHallRedPoindRemind()
	local remind_num = self:IsDailyDanBiRedPoint() and 1 or 0
	ActivityData.Instance:SetActivityRedPointState(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DANBI_CHONGZHI, remind_num > 0)
end

function KaifuActivityData:GetOpenActDailyDanBiReward()
	local info = KaifuActivityData.Instance:GetDailyDanBiInfo()
	local fetch_reward_t = info.fetch_reward_flag or {}
	local can_fetch_reward_t =  info.can_fetch_reward_flag or {}

	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().danbichongzhi
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DANBI_CHONGZHI)
	local day_index = ActivityData.Instance:GetActDayPassFromStart(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DANBI_CHONGZHI)

	local real_cfg = {}
	for k,v in pairs(cfg) do
		if day_index == v.activity_day then
			table.insert(real_cfg, v)
		end
	end

	local list = {}
	for i,v in ipairs(real_cfg) do
		fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
		local data = TableCopy(v)
		data.fetch_reward_flag = fetch_reward_flag
		data.can_fetch_reward_flag = can_fetch_reward_t[32 - v.seq]

		table.insert(list, data)
	end
	table.sort(list, SortTools.KeyLowerSorter("fetch_reward_flag", "seq"))
	return list
end

function KaifuActivityData:IsDailyDanBiRedPoint()
	if not ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DANBI_CHONGZHI) then
		return false
	end

	local info = KaifuActivityData.Instance:GetDailyDanBiInfo()
	if nil == info then
		return
	end

	local fetch_reward_t = info.fetch_reward_flag or {}
	local can_fetch_reward_t =  info.can_fetch_reward_flag or {}

	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().danbichongzhi
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DANBI_CHONGZHI)
    local day_index = ActivityData.Instance:GetActDayPassFromStart(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DANBI_CHONGZHI)
	local real_cfg = {}
	for k,v in pairs(cfg) do
		if day_index == v.activity_day then
			table.insert(real_cfg, v)
		end
	end
	local flag = false
	for i,v in ipairs(real_cfg) do
		fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
		if 0 == fetch_reward_flag and 1 == can_fetch_reward_t[32 - v.seq] then
			flag = true
			return flag
		end
	end
	return flag
end
----------------------------------END----------------------------------------

-----------------开服投资数据---------------------------

------------ 开服投资数据获取数据-------------------
function KaifuActivityData:GetInvestConfig()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().openserver_invest_basis
end

function KaifuActivityData:GetTargetConfig()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().openserver_return_reward
end

function KaifuActivityData:GetInvestCfgByType(invest_type)
	local  cfg = self:GetInvestConfig()
	for k,v in pairs(cfg) do
		if v.invest_type == invest_type then
			return v
		end
	end
end

function KaifuActivityData:GetInvestTargetInfoByType(invest_type)
	local  cfg = self:GetTargetConfig()
	local target_info_list = {}
	for k,v in pairs(cfg) do
		if v.invest_type == invest_type then
			table.insert(target_info_list,v)
		end
	end
	return target_info_list
end

function KaifuActivityData:GetInvestData()
	return self.invest_data
end

function KaifuActivityData:GetFinishNum(invest_type)
	local num = 0
	local cfg = self:GetTargetConfig()
	for k,v in pairs(cfg) do
		if v.invest_type == invest_type then
			if v.param <= self.invest_data.finish_param[invest_type + 1] then
				num = num + 1
			end
		end
	end
	return num
end

function KaifuActivityData:GetLeastTime(index)
	return self.invest_data.time_limit[index] - TimeCtrl.Instance:GetServerTime()
end

function KaifuActivityData:GetReciveNum()
	local type_recive_num = {boss=0, active=0, competition=0}
	local list = bit:d2b(self.invest_data.reward_flag)
	for i=9,32 do
		if i <= INVEST_TYPE_TYPE_POSION.COMPETITION  then
			if i ~= INVEST_TYPE_TYPE_POSION.COMPETITION and list[i] ~= 0 then
				type_recive_num.competition = type_recive_num.competition + 1
			end
		elseif i <= INVEST_TYPE_TYPE_POSION.ACTIVE  then
			if i ~= INVEST_TYPE_TYPE_POSION.ACTIVE and list[i] ~= 0 then
				type_recive_num.active = type_recive_num.active + 1
			end
		elseif i <= INVEST_TYPE_TYPE_POSION.BOSS then
			if i ~= INVEST_TYPE_TYPE_POSION.BOSS and list[i] ~= 0 then
				type_recive_num.boss = type_recive_num.boss + 1
			end
		end
	end
	return type_recive_num
end

function KaifuActivityData:GetParam(invest_type)
	if invest_type == KAIFU_INVEST_TYPE.ACTIVE then
		return ZhiBaoData.Instance:GetActiveDegreeInfo().total_degree
	end
	return self.invest_data.finish_param[invest_type + 1]
end

function KaifuActivityData:GetKaiFuName()
	for k,v in pairs(self.open_cfg) do
		if v.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_KAIFU_INVEST then
			return v.name
		end
	end
	return ""
end

function  KaifuActivityData:GetSpecialName()
	local special_tab_name = {}
	special_tab_name[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_KAIFU_INVEST] = self:GetKaiFuName()
	return special_tab_name
end

function KaifuActivityData:SetDailyActiveRewardInfo(protocol)
	local table_info = {}

end

function KaifuActivityData:GetDailyActiveRewardInfo()

end

-- 充值排行榜奖励
function KaifuActivityData:GetDayChongZhiRankInfoListByDay(day, opengameday)
	local table_data = {}
	local table_data_2 = {}
	local table_data_3 = {}
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().day_chongzhi_rank
	local data = ActivityData.Instance:GetRandActivityConfig(cfg, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CHONGZHI_RANK)

	for k,v in ipairs(data) do
		if day == v.activity_day then
			table.insert(table_data, v.reward_item)
	 		table.insert(table_data_2, v.min_gold)
	 		table.insert(table_data_3, (v.rank + 1))
	 	end
	end
	return table_data, table_data_2, table_data_3
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
	for k,v in ipairs(cfg) do
	 	if temp <= 5 and v.activity_day == day then
	 		--temp = temp + 1
	 		table.insert(data, v.reward_item)
	 		table.insert(data_2, v.min_gold)
	 		table.insert(data_3, (v.rank + 1))
	 		table.insert(data_4, v.fanli_rate)
	 	end
	end
	return data, data_2, data_3, data_4
end
---------------开服投资数据判断数据------------


-- 开服活动-累计消费奖励
function KaifuActivityData:GetOpenActTotalConsumeReward()
	local info = KaifuActivityData.Instance:GetRATotalConsumeGoldInfo()
	local fetch_reward_t = info.fetch_reward_flag or {}

	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().total_gold_consume
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CONSUME)
	local list = {}
	for i,v in ipairs(cfg) do
		fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
		local data = TableCopy(v)
		data.fetch_reward_flag = fetch_reward_flag
		table.insert(list, data)
	end
	table.sort(list, SortTools.KeyLowerSorter("fetch_reward_flag", "need_consume_gold"))
	return list
end

-- 充值返利
function KaifuActivityData:GetKaifuActivityRechargeRebateReward()
	local info = KaifuActivityData.Instance:GetRARechargeRebateInfo()
	local fetch_reward_t = info.fetch_reward_flag or {}

	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().day_chongzhi_fanli
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_DAY_CHONGZHI_FANLI)
	local list = {}
	for i,v in ipairs(cfg) do
		fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
		local data = TableCopy(v)
		data.fetch_reward_flag = fetch_reward_flag
		table.insert(list, data)
	end
	table.sort(list, SortTools.KeyLowerSorter("fetch_reward_flag", "need_gold"))
	return list
end

function KaifuActivityData:ShowInvestRedPoint()
	for k,v in pairs(KAIFU_INVEST_TYPE) do
		if self:ShowInvestTypeRedPoint(v) then
			return true
		end
	end
	return false
end

function KaifuActivityData:GetInvestStateByType(invest_type)
	local state = 1
	if self.invest_data then
		local list = bit:d2b(self.invest_data.reward_flag)

		if invest_type == 0 and list[INVEST_TYPE_TYPE_POSION.BOSS] == 1 then
			state = self:IsFinish("boss",KAIFU_INVEST_TYPE.BOSS)
		elseif invest_type == 1 and list[INVEST_TYPE_TYPE_POSION.ACTIVE] == 1 then
			state = self:IsFinish("active",KAIFU_INVEST_TYPE.ACTIVE)
		elseif invest_type == 2 and list[INVEST_TYPE_TYPE_POSION.COMPETITION] == 1 then
			state =  self:IsFinish("competition",KAIFU_INVEST_TYPE.COMPETITION)
		elseif self:GetLeastTime(invest_type + 1) <= 0 then
			state =  INVEST_STATE.outtime
		else
			state = INVEST_STATE.no_invest
		end
	end
	return state
end

function KaifuActivityData:IsFinish(invest_type,index)
	if self.invest_data == nil then return end
	if self:GetReciveNum()[invest_type] < self:GetFinishNum(index) then
		return INVEST_STATE.finish
	elseif self:GetReciveNum()[invest_type] == 7 then
		return INVEST_STATE.complete
	else
		return INVEST_STATE.no_finish
	end
end

function KaifuActivityData:ShowInvestTypeRedPoint(invest_type)
	local state = self:GetInvestStateByType(invest_type)
	return state == INVEST_STATE.finish
end


---------------开服投资数据处理数据------------
function KaifuActivityData:FlushInvestData(protocol)
	self.invest_data = {}
	self.invest_data.max_type = protocol.max_type
	self.invest_data.reward_flag = protocol.reward_flag
	self.invest_data.time_limit = protocol.time_limit
	self.invest_data.finish_param = protocol.finish_param
	ViewManager.Instance:FlushView(ViewName.KaifuActivityView)
end
--------------开服投资数据部分结束--------------------

--------------------每日排行-----------------------
function KaifuActivityData:SetDayChongzhiRankInfo(protocol)
	self.day_chongzhi = protocol.gold_num
end

function KaifuActivityData:GetDayChongZhiCount()
	return self.day_chongzhi or 0
end

function KaifuActivityData:SetDailyChongZhiRank(rank_list)
	if rank_list then
		self.rank_list = rank_list
	end
end

function KaifuActivityData:GetDailyChongZhiRank()
	return self.rank_list or {}
end

function KaifuActivityData:SetRank(rank)
	self.rank_level = rank
end

function KaifuActivityData:GetRank()
	return self.rank_level or 0
end
------------------------每日消费排行----------------------
function KaifuActivityData:SetDayConsumeRankInfo(protocol)
	self.day_xiaofei = protocol.gold_num
end


function KaifuActivityData:SetRATotalConsumeGoldInfo(protocol)
	self.total_consume_info.consume_gold = protocol.consume_gold
	self.total_consume_info.fetch_reward_flag = bit:d2b(protocol.fetch_reward_flag)
end

function KaifuActivityData:GetRATotalConsumeGoldInfo()
	return self.total_consume_info
end

function KaifuActivityData:SetRARechargeRebateInfo(protocol)
	self.recharge_rebate_info.chongzhi_gold = protocol.chongzhi_gold
	self.recharge_rebate_info.fetch_reward_flag = bit:d2b(protocol.fetch_reward_flag)
end

function KaifuActivityData:GetRARechargeRebateInfo()
	return self.recharge_rebate_info
end

function KaifuActivityData:GetDayConsumeRankInfo()
	return self.day_xiaofei or 0
end

function KaifuActivityData:SetDailyXiaoFeiRank(rank_list)
	if rank_list then
		self.xiaofei_rank_list = rank_list
	end
end

function KaifuActivityData:GetDailyXiaoFeiRank()
	return self.xiaofei_rank_list or {}
end

function KaifuActivityData:SetRankLevel(rank)
	self.xiaofei_rank_level = rank
end

function KaifuActivityData:GetRankLevel()
	return self.xiaofei_rank_level or 0
end

----------------------活跃奖励--------------------------
function KaifuActivityData:SetDayActiveDegreeInfo(protocol)
	self.active_degree = protocol.active_degree   --当前活跃值
	self.fetch_reward_flag = protocol.fetch_reward_flag
end

function KaifuActivityData:GetFetchRewardFlag()
	if self.fetch_reward_flag == 3 then
		return 2
	end
	if self.fetch_reward_flag == 7 then
		return 3
	end


	return self.fetch_reward_flag
end

function KaifuActivityData:GetCurrentActive()
	return self.active_degree or 0
end

function KaifuActivityData:GetDayActiveDegreeInfoList(opengameday)
	local table_data = {}
	local table_data_2 = {}
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().day_active_degree
	local data = ActivityData.Instance:GetRandActivityConfig(cfg, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_ACTIVIE_DEGREE)

	if self.fetch_reward_flag == 3 then
		self.fetch_reward_flag = 2
	end
	if self.fetch_reward_flag == 7 then
		self.fetch_reward_flag = 3
	end

	for k,v in ipairs(data) do
		if day == v.activity_day then
			table.insert(table_data, v.reward_item)
			table.insert(table_data_2, v.need_active)
			table_data[k].need_active = v.need_active
	 		if k <= self.fetch_reward_flag then
	 			table_data[k].fetch = 1
			else
				table_data[k].fetch = 0
			end
	 	end
	end
	table.sort(table_data, SortTools.KeyLowerSorters("fetch", "need_active"))
	return table_data, table_data_2
end

function KaifuActivityData:IsShowDayActiveRedPoint()
	local fetch_reward_flag =  KaifuActivityData.Instance:GetFetchRewardFlag()
	local opengameday = TimeCtrl.Instance:GetCurOpenServerDay()
	local reward_list, coset_list = self:GetDayActiveDegreeInfoList(opengameday)
	local current_active = self:GetCurrentActive()

	for k,v in pairs(coset_list) do
		if fetch_reward_flag < k then
			if current_active >= v then
				return true
			end
		end
	end
	return false
end

function KaifuActivityData:IsDayConsumeRedPoint()
	if not ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CONSUME) then
		return false
	end

	local info = KaifuActivityData.Instance:GetDailyTotalConsumeInfo()
	local fetch_reward_t = info.fetch_reward_flag or {}

	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().day_gold_consume
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CONSUME)
	local flag = false
	for i,v in ipairs(cfg) do
		fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
		if 0 == fetch_reward_flag and info.consume_gold and info.consume_gold >= v.need_consume_gold then
			flag = true
			return flag
		end
	end
	return flag
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
		fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
		if 0 == fetch_reward_flag and info.consume_gold and info.consume_gold >= v.need_consume_gold then
			flag = true
			return flag
		end
	end
	return flag
end

function KaifuActivityData:IsZhiZunHuiYuanRedPoint()
	local is_show_rpt = false
	if not self.zhizhun_state then
		local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
		local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
		local remind_day = UnityEngine.PlayerPrefs.GetInt(main_role_id.."zhizunhuiyuanred") or cur_day						--红点一天只提醒一次

		if cur_day ~= -1 and cur_day ~= remind_day then
			is_show_rpt = true
		end
		return is_show_rpt
	end

	return self.zhizhun_flag or false
end

function KaifuActivityData:ZhiZunHuiYuanRedPointInfo(flag, state)
	self.zhizhun_state = state
	if flag == 0 then
		flag = true
	elseif flag == 1 then
		flag = false
	end

	self.zhizhun_flag = flag
end

function KaifuActivityData:IsLevelInvestRedPoint()
	local red_state = false
	local plan_index = InvestData.Instance:GetNormalActivePlan()
	if plan_index < 0 then
		plan_index = 2
	end
	local info = InvestData.Instance:GetNormalInvestRemind() or 0
	red_state = info > 0

	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local remind_day = UnityEngine.PlayerPrefs.GetInt(main_role_id.."LevelInvest") or cur_day						--红点一天只提醒一次
	local plan_flag = InvestData.Instance:GetNormalActivePlan()
	if cur_day ~= -1 and cur_day ~= remind_day and plan_flag < 0 then
		red_state = true
	end

	if InvestData.Instance:GetRewardStateInfo(plan_index) then
		red_state = false
	end

	if (InvestData.Instance:GetActiveHighestPlan() == -1) and not InvestData.Instance:CanInvestLevel(2) then
		red_state = false
	end

	return red_state
 end

function KaifuActivityData:IsRechargeRebateRedPoint()
	if not ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_DAY_CHONGZHI_FANLI) then
		return false
	end

	local info = KaifuActivityData.Instance:GetRARechargeRebateInfo()
	local fetch_reward_t = info.fetch_reward_flag or {}

	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().day_chongzhi_fanli
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_DAY_CHONGZHI_FANLI)
	local flag = false
	for i,v in ipairs(cfg) do
		fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
		if 0 == fetch_reward_flag and info.chongzhi_gold and info.chongzhi_gold >= v.need_gold then
			flag = true
			return flag
		end
	end
	return flag
end

function KaifuActivityData:IsShowLeiJiRechargeIcon()
	if not DailyChargeData.Instance:GetIsThreeRecharge() then
		return false
	end

	local list = self:GetLeiJiChongZhiCfg()
	local total_charge_value = self.leiji_chongzhi_info.total_charge_value or 0
	for i = 1, GetListNum(list) do
		if not (list[i].need_chognzhi <= total_charge_value and self:IsGetLeiJiChongZhiReward(list[i].seq)) then
			return true
		end
	end
	return false
end

-- 累积充值金额大于首冲的最高档就显示累计充值图标
function KaifuActivityData:ShowMainLeiJiRechargeIcon()
	local total_charge_value = self.leiji_chongzhi_info.total_charge_value or 0
	if total_charge_value == 0 then
		return false
	end

	local shouchong_cfg = DailyChargeData.Instance:GetThreeRechargeAuto()
	if total_charge_value >= shouchong_cfg[#shouchong_cfg].need_danbi_chongzhi then
		return true
	end
	return false
end

function KaifuActivityData:FlushTotalConsumeHallRedPoindRemind()
	local remind_num = self:IsTotalConsumeRedPoint() and 1 or 0
	ActivityData.Instance:SetActivityRedPointState(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CONSUME, remind_num > 0)
end

function KaifuActivityData:FlushDailyTotalConsumeHallRedPoindRemind()
	local remind_num = self:IsDayConsumeRedPoint() and 1 or 0
	ActivityData.Instance:SetActivityRedPointState(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CONSUME, remind_num > 0)
end

function KaifuActivityData:FlushChongZhiFanLiRedPoindRemind()
	local remind_num = self:IsRechargeRebateRedPoint() and 1 or 0
	ActivityData.Instance:SetActivityRedPointState(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_DAY_CHONGZHI_FANLI, remind_num > 0)
end

function KaifuActivityData:SetChargeRewardInfo(protocol)
	self.reward_active_flag = bit:d2b(protocol.can_fetch_reward_flag)
	self.reward_fetch_flag = bit:d2b(protocol.fetch_reward_flag)
	self.history_charge_during_act = protocol.charge_value
end

function KaifuActivityData:GetLeiJiChargeRewardCfg()
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
	for i=0,4 do
		if self:GetLeiJiChargeRewardIsActive(i) == 1 and self:GetLeiJiChargeRewardIsFetch(i) == 0 then
			return true
		end
	end
	return false
end

function KaifuActivityData:FlushLeiJiChargeRewardRedPoint()
	local remind_num = self:GetLeiJiChargeRewardRedPoint() and 1 or 0
	ActivityData.Instance:SetActivityRedPointState(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHARGE_REPALMENT, remind_num > 0)
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

------------------------------累计充值--------------------------------------------

function KaifuActivityData:SetRANewTotalChargeInfo(protocol)
	self.total_charge_info.total_charge_value = protocol.total_charge_value
	self.total_charge_info.reward_has_fetch_flag = bit:d2b(protocol.reward_has_fetch_flag)
end

function KaifuActivityData:GetOpenActTotalChargeRewardCfg()
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().new_rand_total_chongzhi
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CHARGE)

	local fetch_reward_t = self.total_charge_info.reward_has_fetch_flag or {}
	local list = {}
	for i,v in ipairs(cfg) do
		fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
		local data = TableCopy(v)
		data.fetch_reward_flag = fetch_reward_flag
		table.insert(list, data)
	end
	table.sort(list, SortTools.KeyLowerSorter("fetch_reward_flag", "need_chognzhi"))
	return list
end

function KaifuActivityData:GetTotalChargeInfo()
	return self.total_charge_info
end


function KaifuActivityData:FlushTotalChargeHallRedPoindRemind()
	local remind_num = self:IsTotalChargeRedPoint() and 1 or 0
	ActivityData.Instance:SetActivityRedPointState(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CHARGE, remind_num > 0)
end

function KaifuActivityData:IsTotalChargeRedPoint()
	if not ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CHARGE) then
		return false
	end

	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().new_rand_total_chongzhi
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CHARGE)
	local flag = false

	local fetch_reward_t = self.total_charge_info.reward_has_fetch_flag or {}
	for i,v in ipairs(cfg) do
		fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
		if 0 == fetch_reward_flag and self.total_charge_info.total_charge_value and self.total_charge_info.total_charge_value >= v.need_chognzhi then
			flag = true
			return flag
		end
	end
	return flag
end

function KaifuActivityData:SetFullServerSnapInfo(protocol)
	self.user_buy_numlist = protocol.user_buy_numlist or {}
	self.server_buy_numlist = protocol.server_buy_numlist or {}
end

function KaifuActivityData:GetSnapUserBuyNumlist()
	return self.user_buy_numlist or {}
end

function KaifuActivityData:GetSnapServerBuyNumlist()
	return self.server_buy_numlist or {}
end

function KaifuActivityData:GetSnapServerItemlist()
	if self.server_buy_numlist == nil or self.user_buy_numlist == nil then return end
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().server_panic_buy or {}
	local list = ActivityData.Instance:GetRandActivityConfig(cfg, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FULL_SERVER_SNAP)
	local temp_list = {}
	for i = 1, #list do
		local data = TableCopy(list[i])
		data.is_no_item = 0
		data.server_limit_buy_count = (list[i].server_limit_buy_count - self.server_buy_numlist[i]) or 0
		data.personal_limit_buy_count = (list[i].personal_limit_buy_count - self.user_buy_numlist[i]) or 0
		if data.server_limit_buy_count <= 0 or data.personal_limit_buy_count <= 0 then
			data.is_no_item = 1
		end
		table.insert(temp_list, data)
	end
	table.sort(temp_list, SortTools.KeyLowerSorters("is_no_item", "seq") )
	return temp_list
end


--每日累计消费
function KaifuActivityData:DailyTotalConsumeInfo(protocol)
	self.daily_total_consume_info = {}
	self.daily_total_consume_info.consume_gold = protocol.consume_gold
	self.daily_total_consume_info.fetch_reward_flag = bit:d2b(protocol.fetch_reward_flag)
end

function KaifuActivityData:GetOpenActDailyTotalConsumeReward()
	local info = self.daily_total_consume_info or {}
	local fetch_reward_t = info.fetch_reward_flag or {}

	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().day_gold_consume
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CONSUME)
	local list = {}
	for i,v in ipairs(cfg) do
		fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
		local data = TableCopy(v)
		data.fetch_reward_flag = fetch_reward_flag
		table.insert(list, data)
	end
	table.sort(list, SortTools.KeyLowerSorter("fetch_reward_flag", "need_consume_gold"))
	return list
end

function KaifuActivityData:GetDailyTotalConsumeInfo()
	return self.daily_total_consume_info
end

-----------------------升星助力----------------------
function KaifuActivityData:SetShengxingzhuliInfo(protocol)
	self.rsing_star_info.is_get_reward_today = protocol.is_get_reward_today
	self.rsing_star_info.chognzhi_today = protocol.chognzhi_today
	self.rsing_star_info.func_level = protocol.func_level
	self.rsing_star_info.func_type = protocol.func_type
	self.rsing_star_info.is_max_level = protocol.is_max_level
	self.rsing_star_info.stall = protocol.stall
end

function KaifuActivityData:GetShengxingzhuliInfo()
	return self.rsing_star_info
end

function KaifuActivityData:GetRisingStarCfg()
	if not self.rising_star_cfg then
		self.rising_star_cfg = ConfigManager.Instance:GetAutoConfig("shengxingzhuli_config_auto").other[1]
	end
	return self.rising_star_cfg
end

-- 根据系统类型获取相应的系统配置
function KaifuActivityData:GetSystemConfigByType(system_type, star_level)
	local res_id, grade, level = 0
	local is_max = false
	grade = math.floor(star_level / 10) + 1
	level = star_level % 10
	if SYSTEM_TYPE.MOUNT == system_type then 					--坐骑
		local image_cfg = MountData.Instance:GetMountImageCfg()
		local mount_grade_cfg = MountData.Instance:GetMountGradeCfg(grade)
		res_id = image_cfg[mount_grade_cfg.image_id].res_id
		if grade >= MountData.Instance:GetMaxGrade() then
			is_max = true
		end
		grade = mount_grade_cfg.gradename
	elseif SYSTEM_TYPE.WING == system_type then 				--羽翼
		local image_cfg = WingData.Instance:GetWingImageCfg()
		local wing_grade_cfg = WingData.Instance:GetWingGradeCfg(grade)
		res_id = image_cfg[wing_grade_cfg.image_id].res_id
		if grade >= WingData.Instance:GetMaxGrade() then
			is_max = true
		end
		grade = wing_grade_cfg.gradename
	elseif SYSTEM_TYPE.FIGHT_MOUNT == system_type then 			--战斗坐骑
		local mount_grade_cfg = FightMountData.Instance:GetMountGradeCfg(grade)
		local image_cfg = FightMountData.Instance:GetMountImageCfg()
		res_id = image_cfg[mount_grade_cfg.image_id].res_id
		if grade >= FightMountData.Instance:GetMaxGrade() then
			is_max = true
		end
		grade = mount_grade_cfg.gradename
	elseif SYSTEM_TYPE.HALO == system_type then 				--光环
		local halo_grade_cfg = HaloData.Instance:GetHaloGradeCfg(grade)
		local image_cfg = HaloData.Instance:GetHaloImageCfg()
		res_id = image_cfg[halo_grade_cfg.image_id].res_id
		if grade >= HaloData.Instance:GetMaxGrade() then
			is_max = true
		end
		grade = halo_grade_cfg.gradename
	elseif SYSTEM_TYPE.FOOT == system_type then 				--足迹
		local foot_grade_cfg = FootData.Instance:GetFootGradeCfg(grade)
		local image_cfg = FootData.Instance:GetFootImageCfg()
		res_id = image_cfg[foot_grade_cfg.image_id].res_id
		if grade >= FootData.Instance:GetMaxGrade() then
			is_max = true
		end
		grade = foot_grade_cfg.gradename
	elseif SYSTEM_TYPE.SHEN_GONG == system_type then 			--神弓
		local shengong_grade_cfg = ShengongData.Instance:GetShengongGradeCfg(grade)
		local image_list = ShengongData.Instance:GetShengongImageCfg()
		res_id = image_list[shengong_grade_cfg.image_id].res_id
		if grade >= ShengongData.Instance:GetMaxGrade() then
			is_max = true
		end
		grade = shengong_grade_cfg.gradename
	elseif SYSTEM_TYPE.SHEN_YI == system_type then 				--神翼
		local image_list = ShenyiData.Instance:GetShenyiImageCfg()
		local shenyi_grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(grade)
		res_id = image_list[shenyi_grade_cfg.image_id].res_id
		if grade >= ShenyiData.Instance:GetMaxGrade() then
			is_max = true
		end
		grade = shenyi_grade_cfg.gradename
	end
	return res_id, grade, level, is_max
end

-- 根据系统类型和形象ID获取相应的形象列表
function KaifuActivityData:GetImageListByImageId(system_type, image_id)
	local image_list = {}
	if SYSTEM_TYPE.MOUNT == system_type then
		image_list = MountData.Instance:GetImageListInfo(image_id)
		return image_list
	elseif SYSTEM_TYPE.WING == system_type then
		image_list = WingData.Instance:GetImageListInfo(image_id)
		return image_list
	elseif SYSTEM_TYPE.FIGHT_MOUNT == system_type then
		image_list = FightMountData.Instance:GetImageListInfo(image_id)
		return image_list
	elseif SYSTEM_TYPE.HALO == system_type then
		image_list = HaloData.Instance:GetImageListInfo(image_id)
		return image_list
	elseif SYSTEM_TYPE.FOOT == system_type then
		image_list = FootData.Instance:GetImageListInfo(image_id)
		return image_list
	elseif SYSTEM_TYPE.SHEN_GONG == system_type then
		image_list = ShengongData.Instance:GetImageListInfo(image_id)
		return image_list
	elseif SYSTEM_TYPE.SHEN_YI == system_type then
		image_list = ShenyiData.Instance:GetImageListInfo(image_id)
		return image_list
	else
		return image_list
	end
end

--升星助力红点
function KaifuActivityData:CheckRisindRed()
	if self.rsing_star_info.is_get_reward_today == 1 or self.rsing_star_info.func_level <= 0 then return 0 end

	local cfg = self:GetRisingStarCfg()
	if self.rsing_star_info.chognzhi_today >= cfg.need_chongzhi then
		return 1
	else
		return 0
	end
end

function KaifuActivityData:GetNeedChongzhiByStage(stage)
	local chongzhi = 0
	local cfg = self:GetRisingStarCfg()

	for i = 1, stage < 4 and stage or 4  do
		chongzhi = chongzhi + cfg["need_chongzhi_" .. i - 1]
	end

	if stage > 4 then
		chongzhi = chongzhi +  (stage - 4) * cfg.add_valus
	end

	return chongzhi
end

--升星助力
function KaifuActivityData:GetIsShowUpStarBtn(index)
	local system_type = self.rsing_star_info.func_type
	if ((index == TabIndex.mount_jinjie and SHENGXINGZHULI_SYSTEM_TYPE.SHENGXINGZHULI_SYSTEM_TYPE_MOUNT == system_type)				--坐骑进阶
		or (index == TabIndex.wing_jinjie and SHENGXINGZHULI_SYSTEM_TYPE.SHENGXINGZHULI_SYSTEM_TYPE_WING == system_type)			--羽翼进阶
		or (index == TabIndex.halo_jinjie and SHENGXINGZHULI_SYSTEM_TYPE.SHENGXINGZHULI_SYSTEM_TYPE_HALO == system_type)		--足迹进阶
		or (index == TabIndex.foot_jinjie and SHENGXINGZHULI_SYSTEM_TYPE.SHENGXINGZHULI_SYSTEM_TYPE_FOOT_PRINT == system_type)			--光环进阶
		or (index == TabIndex.fight_mount and SHENGXINGZHULI_SYSTEM_TYPE.SHENGXINGZHULI_SYSTEM_TYPE_FIGHT_MOUNT == system_type)		--战斗坐骑
		or (index == TabIndex.goddess_shengong and SHENGXINGZHULI_SYSTEM_TYPE.SHENGXINGZHULI_SYSTEM_TYPE_SHENGONG == system_type)	--神弓进阶
		or (index == TabIndex.goddess_shenyi and SHENGXINGZHULI_SYSTEM_TYPE.SHENGXINGZHULI_SYSTEM_TYPE_PIFENG == system_type)) then	--神翼进阶
		return system_type
	else
		return -1
	end
end

function KaifuActivityData:GetTodayOpenUpStarSystemType()
	local cfg = ConfigManager.Instance:GetAutoConfig("shengxingzhuli_config_auto")
	weekday_to_system_cfg = cfg.weekday_to_system[1]

	local system_type_list = {
		[0] = weekday_to_system_cfg.sunday_sys,
		[1] = weekday_to_system_cfg.monday_sys,
		[2] = weekday_to_system_cfg.tuesday_sys,
		[3] = weekday_to_system_cfg.wednesday_sys,
		[4] = weekday_to_system_cfg.thursday_sys,
		[5] = weekday_to_system_cfg.friday_sys,
		[6] = weekday_to_system_cfg.saturday_sys }

	local server_time = TimeCtrl.Instance:GetServerTime()
	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()

	local system_type = 0
	if open_server_day < 7 then
		system_type = system_type_list[open_server_day]
	else
		local date_day = tonumber(os.date("%w", server_time))
		system_type = system_type_list[date_day]
	end

	return system_type
end

--改变幻化模型形象
function KaifuActivityData:ModelSet(display, model, model_type, show_item)
	if nil == display or nil == model then return end
	local main_role = Scene.Instance:GetMainRole()
  	model:SetRoleResid(main_role:GetRoleResId())
	if model_type == FASHION_SHOW_TYPE.ROLE and FashionData.Instance then
		local res_id = FashionData.GetFashionResByItemId(show_item, main_role.vo.sex, main_role.vo.prof) or 0
  		model:SetMainAsset(ResPath.GetRoleModel(res_id))
	elseif model_type == FASHION_SHOW_TYPE.WEAPON and FashionData.Instance then
  		local wuqi_id = FashionData.GetFashionResByItemId(show_item, main_role.vo.sex, main_role.vo.prof) or 0
  		model:SetWeaponResid(wuqi_id)
	elseif model_type == FASHION_SHOW_TYPE.MOUNT and MountData.Instance then
		local image_cfg = MountData.Instance:GetSpecialImagesCfg() or 0
		model:SetMainAsset(ResPath.GetMountModel(self:ResidByItemid(image_cfg, show_item)))
	elseif model_type == FASHION_SHOW_TYPE.WING and WingData.Instance then
		local image_cfg = WingData.Instance:GetSpecialImagesCfg() or 0
		model:SetWingResid(self:ResidByItemid(image_cfg, show_item))
		display.ui3d_display:SetRotation(Vector3(0, -180, 0))
	elseif model_type == FASHION_SHOW_TYPE.HALO and HaloData.Instance then
		local image_cfg = HaloData.Instance:GetSpecialImagesCfg() or 0
		model:SetHaloResid(self:ResidByItemid(image_cfg, show_item))
	elseif model_type == FASHION_SHOW_TYPE.FOOT and FootData.Instance then
		local image_cfg = FootData.Instance:GetSpecialImagesCfg() or 0
		model:SetFootResid(self:ResidByItemid(image_cfg, show_item))
		model:SetInteger("status", 1)
		display.ui3d_display:SetRotation(Vector3(0, -90, 0))
	elseif model_type == FASHION_SHOW_TYPE.FIGHTMOUNT and FightMountData.Instance then
		local image_cfg = FightMountData.Instance:GetSpecialImagesCfg() or 0
		model:SetMainAsset(ResPath.GetFightMountModel(self:ResidByItemid(image_cfg, show_item)))
	elseif model_type == FASHION_SHOW_TYPE.GODDRESS and GoddessData.Instance then
		local res_id = GoddessData.Instance:GetCurXiannvResId(GoddessData.Instance:GetXianIdByActiveId(show_item) or 1)
		model:SetTrigger("show_idle_1")
		model:SetMainAsset(ResPath.GetGoddessModel(res_id))
	elseif model_type == FASHION_SHOW_TYPE.GODDRESS_HALO and ShengongData.Instance then
		local image_cfg = ShengongData.Instance:GetSpecialImagesCfg() or 0
		model:SetTrigger("show_idle_1")
		model:SetMainAsset(ResPath.GetGoddessWeaponModel(image_cfg, show_item))
	elseif model_type == FASHION_SHOW_TYPE.GODDRESS_FAZHEN and ShenyiData.Instance then
		local image_cfg = ShenyiData.Instance:GetSpecialImagesCfg() or 0
		model:SetTrigger("show_idle_1")
		model:SetMainAsset(ResPath.GetGoddessWingModel(image_cfg, show_item))
	elseif model_type == FASHION_SHOW_TYPE.SPIRIT and SpiritData.Instance then
		local image_cfg = SpiritData.Instance:GetSpiritHuanImageConfig() or 0
		model:SetMainAsset(ResPath.GetSpiritModel(image_cfg, show_item))
	elseif model_type == FASHION_SHOW_TYPE.SHENG_WU and ZhiBaoData.Instance then
		local res_id = ZhiBaoData.Instance:GetSpecialResIdByItem(show_item) or 0
		model:SetMainAsset(ResPath.GetHighBaoJuModel(res_id))
	end
end

function KaifuActivityData:ResidByItemid(cfg, item)
	for _,v in pairs(cfg) do
		if v.item_id == item or v.active_item == item then
			return v.res_id
		end
	end
	return 0
end

function KaifuActivityData:IsTouZiPlanRedPoint()
	local svr_info = InvestData.Instance:GetTouZiPlanInfo()
	local cfg_num = InvestData.Instance:GetTouZiPlanInfoNum() or 0
	local level_cfg = self:GetTouZicfg()
	local role_level = PlayerData.Instance:GetRoleVo().level
	if nil == svr_info then
		return false
	end

	if self:CanShowTouZiPlan() then
		return false
	end

	for i = 1, cfg_num do
		if svr_info[i] == 1 then
			for k, v in pairs(level_cfg) do
				if v.seq == i - 1 and v.sub_index == 0 then
					if role_level >= v.reward_level then
						return true
					end
				end
			end

		elseif svr_info[i] == 2 then
			for k, v in pairs(level_cfg) do
				if v.seq == i - 1 and v.sub_index == 1 then
					if role_level >= v.reward_level then
						return true
					end
				end
			end

		elseif svr_info[i] == 3 then
			for k, v in pairs(level_cfg) do
				if v.seq == i - 1 and v.sub_index == 2 then
					if role_level >= v.reward_level then
						return true
					end
				end
			end
		end
	end
	return false
end

function KaifuActivityData:GetTouZiState(index)
	local role_level = PlayerData.Instance:GetRoleVo().level
	local level_cfg = self:GetTouZicfg()
	local svr_info = InvestData.Instance:GetTouZiPlanInfo()

	if nil == index or nil == svr_info or nil == svr_info[index] or nil == level_cfg then
		return 0
	end
	if svr_info[index] == 4 then
		return 5
	end

 	-- return 0 代表可购买， 1 代表已购买可领取， 2 代表已购买不能领取， 3 代表未购买过期, 4 代表等级不够不能购买, 5 代表已经领完
 	for k, v in pairs(level_cfg) do
 		if v.seq == index - 1 then
 			if svr_info[index] == 0 then  -- 如果我没买
 				if role_level < v.active_level_min then
					return 4
				elseif role_level > v.active_level_max then
					return 3
				else
					return 0
				end
 			elseif svr_info[index] == 1 or svr_info[index] == 2 or svr_info[index] == 3 then -- 如果我买了，处于领取 1，2，3阶段
 				if v.sub_index == svr_info[index] - 1 then
 					if role_level >= v.reward_level then
						return 1
					else
						return 2
					end
 				end
 			end
 		end
 	end


	return 3
end

function KaifuActivityData:CanShowTouZiPlan()
	local cfg = InvestData.Instance:GetTouZiPlanInfo()
	local cfg_num = InvestData.Instance:GetTouZiPlanInfoNum() or 0
	local role_level = PlayerData.Instance:GetRoleVo().level
	if role_level < self.touzi_min_level then
		self.touzi_min_level = role_level
	end

	local level_cfg = self:GetTouZicfg()
	local state = false
	if nil == cfg then
		return false
	end

	for i = 1, cfg_num do
		if cfg[i] < 4 and cfg[i] > 0 then
			self.touzi_close_state = true
			return false
		end
	end

	if self.touzi_close_state then
		return false
	end

	for k, v in pairs(level_cfg) do
		if v.seq == cfg_num - 1 then
			if self.touzi_min_level > v.active_level_max then
				state = true
			end
		end
	end

	-- 封测期间不显示该活动
	if LoginData.Instance:IsClosedTest() then
		return true
	end

	return state
end

function KaifuActivityData:TouZiButtonInfo()
	local role_level = PlayerData.Instance:GetRoleVo().level
	local cfg_num = InvestData.Instance:GetTouZiPlanInfoNum() or 0
	local level_cfg = self:GetTouZicfg()

	for k, v in pairs(level_cfg) do
		if role_level == v.active_level_min then
			return true
		end
	end

	return false
end
function KaifuActivityData:GetTouZiNowPage()

end

function KaifuActivityData:GetTouZicfg()
	return ConfigManager.Instance:GetAutoConfig("touzijihua_auto").foundation
end

function KaifuActivityData:GetNewTouZicfg()
	local cfg = self:GetTouZicfg()
	local touzi_list = {}
	local touzi_list2 = {}

	for k, v in pairs(cfg) do
		if self:IsGuoQiOrLingQu(v) then
			table.insert(touzi_list2, v)
		else
			table.insert(touzi_list, v)
		end
	end

	for k, v in ipairs(touzi_list2) do
		table.insert(touzi_list, v)
	end

	return touzi_list
end

-- 是否过期或者是已经领取完
function KaifuActivityData:IsGuoQiOrLingQu(cfg)
	local svr_info = InvestData.Instance:GetTouZiPlanInfo()
	local svr_infonum = InvestData.Instance:GetTouZiPlanInfoNum() or 0
	local role_level = PlayerData.Instance:GetRoleVo().level
	local flag = false
	for i = 1, svr_infonum do
		if cfg.seq == i - 1 then
			if svr_info[i] >= 4 or (svr_info[i] == 0 and role_level > cfg.active_level_max) then
				flag = true
			end
			break
		end
	end

	return flag
end

-----------------消费好礼-------------------
function KaifuActivityData:GetExpenseNiceGiftCfg()
	local expense_nice_gift_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().expense_nice_gift2
	local cfg = ActivityData.Instance:GetRandActivityConfig(expense_nice_gift_cfg, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_NICE_GIFT_2)
	local pass_day = ActivityData.Instance:GetActDayPassFromStart(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_NICE_GIFT_2)
	local rand_t = {}
	local max_activity_day = -1
	local last_open_game_day = 0
	local activity_day = -1
	pass_day = pass_day + 1
	for i,v in ipairs(cfg) do
		if v.activity_day > max_activity_day then
			max_activity_day = v.activity_day
		end
	end

	for i,v in ipairs(cfg) do
		-- if open_day == v.opengame_day then
		if activity_day == -1 or v.activity_day == activity_day then
			if pass_day == v.activity_day or (pass_day > max_activity_day and v.activity_day == max_activity_day) then
				table.insert(rand_t, v)
				activity_day = v.activity_day
			end
		end
	end
	self.expense_nice_gift_cfg = rand_t

	return self.expense_nice_gift_cfg
end

function KaifuActivityData:GetExpenseNiceGiftCfgLength()
	if not self.expense_nice_gift_cfg_length then
		local cfg = self:GetExpenseNiceGiftCfg()
		self.expense_nice_gift_cfg_length = #cfg
	end

	return self.expense_nice_gift_cfg_length
end

function KaifuActivityData:GetExpenseNiceGiftInfo()
	return self.expense_nice_gift_info
end

function KaifuActivityData:GetRandActivityOtherCfg()
	if not self.other_cfg then
		self.other_cfg = ConfigManager.Instance:GetAutoConfig("randactivityconfig_1_auto").other_default_table
	end
	return self.other_cfg
end

function KaifuActivityData:GetExpenseNiceGiftTotalRwardCfgLength()
	local cfg = self:GetExpenseNiceGiftTotalRwardCfg()

	if cfg then
		if not self.total_reward_cfg_length then
			self.total_reward_cfg_length = #cfg
		end

		return self.total_reward_cfg_length
	end

	return 0
end

function KaifuActivityData:GetExpenseNiceGiftResultInfo()
	return self.expense_nice_gift_result_info
end

function KaifuActivityData:ExpenseInfoRewardHasFetchFlagByIndex(index)
	if not index then
		return 0
	end

	local info = self:GetExpenseNiceGiftInfo()
	if info and info.reward_has_fetch_flag then
		return info.reward_has_fetch_flag[32 - index]
	end

	return 0
end

function KaifuActivityData:GetTotalRwardCfg()
	local length = self:GetExpenseNiceGiftTotalRwardCfgLength()
	local cfg = self:GetExpenseNiceGiftTotalRwardCfg()
	local list = {}
	local fetch_list = {}
	local num1 = 0
	local num2 = 0

	if not cfg then return nil end

	if not self:GetExpenseNiceGiftInfo() then
		return cfg
	end

	for i = 1, length do
		local flag = self:ExpenseInfoRewardHasFetchFlagByIndex(i)
		if cfg[i] then
			if flag == 0 then
				num1 = num1 + 1
				list[num1] = cfg[i]
			else
				num2 = num2 + 1
				fetch_list[num2] = cfg[i]
			end
		end
	end

	if num2 > 0 then
		for i = 1, num2 do
			list[i + num1] = fetch_list[i]
		end
	end

	self.sorted_total_reward_cfg = list

	return self.sorted_total_reward_cfg
end

function KaifuActivityData:SetExpenseNiceGiftInfo(protocol)
	if not protocol then
		return
	end

	if not self.expense_nice_gift_info then
		self.expense_nice_gift_info = {}
	end

	self.expense_nice_gift_info.grand_total_consume_gold_num = protocol.grand_total_consume_gold_num
	self.expense_nice_gift_info.yao_jiang_num = protocol.yao_jiang_num
	self.expense_nice_gift_info.reward_has_fetch_flag = bit:d2b(protocol.reward_has_fetch_flag)
	self.expense_nice_gift_info.reward_can_fetch_flag = bit:d2b(protocol.reward_can_fetch_flag)
	self.expense_nice_gift_info.yaojiang_total_times = protocol.yaojiang_total_times

end

function KaifuActivityData:GetExpenseNiceGiftTotalRwardCfg()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().expense_nice_gift2_grand_total_reward
	cfg = ActivityData.Instance:GetRandActivityConfig(cfg, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_NICE_GIFT_2)
	local pass_day = ActivityData.Instance:GetActDayPassFromStart(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_NICE_GIFT_2)
	local rand_t = {}
	local max_activity_day = -1
	local last_open_game_day = 0
	local activity_day = -1
	-- for i,v in ipairs(cfg) do
	-- 	if open_day <= v.opengame_day then
	-- 		open_day = v.opengame_day
	-- 		break
	-- 	end
	-- end
	pass_day = pass_day + 1
	for i,v in ipairs(cfg) do
		if v.activity_day > max_activity_day then
			max_activity_day = v.activity_day
		end
	end

	for i,v in ipairs(cfg) do
		-- if open_day == v.opengame_day then
		if activity_day == -1 or v.activity_day == activity_day then
			if pass_day == v.activity_day or (pass_day > max_activity_day and v.activity_day == max_activity_day) then
				table.insert(rand_t, v)
				activity_day = v.activity_day
			end
		end
	end
	self.expense_nice_gift_grand_total_reward_cfg = rand_t

	return self.expense_nice_gift_grand_total_reward_cfg
end

function KaifuActivityData:SetExpenseNiceGiftResultInfo(protocol)
	if not protocol then
		return
	end

	if not self.expense_nice_gift_result_info then
		self.expense_nice_gift_result_info = {}
	end

	self.expense_nice_gift_result_info.reward_item_id = protocol.reward_item_id
	self.expense_nice_gift_result_info.reward_item_num = protocol.reward_item_num
end

function KaifuActivityData:ExpenseInfoRewardCanFetchFlagByIndex(index)
	if not index then
		return 0
	end

	local info = self:GetExpenseNiceGiftInfo()

	if info and info.reward_can_fetch_flag then
		return info.reward_can_fetch_flag[32 - index]
	end

	return 0
end

function KaifuActivityData:GetExpenseNiceGiftPageCount()
	if self.expense_nice_gift_page_count then
		return self.expense_nice_gift_page_count
	end

	local cfg = self:GetExpenseNiceGiftCfg()

	if cfg then
		local count = self:GetExpenseNiceGiftCfgLength()

		if count > 0 then
			local remainder = math.floor((count % 9))
			local divider = math.floor((count / 9))
			num = remainder == 0 and divider or (1 + divider)
			self.expense_nice_gift_page_count = num

			return self.expense_nice_gift_page_count
		end
	end

	return 0
end

function KaifuActivityData:GetExpenseNiceGiftPageCfgByIndex(index)
	if not index or index < 0 then
		return nil
	end

	if not self.expense_nice_gift_page_cfg then
		self.expense_nice_gift_page_cfg = {}
	end

	if self.expense_nice_gift_page_cfg[index] then
		return self.expense_nice_gift_page_cfg[index]
	end

	local num = self:GetExpenseNiceGiftPageCount() or 0
	local cfg = self:GetExpenseNiceGiftCfg()
	local list = {}

	if num > 0 then
		local count = 0
		local max_range = index * 9
		local min_range = (max_range - 8) > 0 and (max_range - 8) or 1

		for i = min_range, max_range do
			if cfg[i] then
				table.insert(list, cfg[i])
				count = count + 1
			end
		end

		if count > 0 then
			self.expense_nice_gift_page_cfg[index] = list
			return self.expense_nice_gift_page_cfg[index]
		end
	end

	return nil
end


function KaifuActivityData:IsShowExpenseNiceGiftRedPoint()
	if not ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_NICE_GIFT_2) then
		return 0
	end

	local flag = 0
	local length = self:GetExpenseNiceGiftTotalRwardCfgLength()
	local info = self:GetExpenseNiceGiftInfo()

	if info and info.yao_jiang_num then
		flag = (info.yao_jiang_num > 0) and 1 or 0
	end

	for i = 1, length do
		local can_fetch = self:ExpenseInfoRewardCanFetchFlagByIndex(i)
		local has_fetch = self:ExpenseInfoRewardHasFetchFlagByIndex(i)
		if can_fetch == 1 and has_fetch == 0 then
			flag = 1
			break
		end
	end

	return flag
end