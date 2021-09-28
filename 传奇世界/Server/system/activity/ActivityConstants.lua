ACTIVITY_REFRESH = 0 			--0点刷新
DAY_SECENDS = 24 * 60 * 60		--一天的秒数
WEEK_SECENDS = 7 * DAY_SECENDS
WEEK_START_TIME = time.totime("2016-08-01 00:00:00")	--周一为每周第一天
ACTIVITY_RESIGN_INGOT = 20 		--补签一次花费元宝
ACTIVITY_ADD_MONEY = 8888		--微信登录签到额外加成奖励金币数量
ACTIVITY_SEVEN_FESTIVAL_DAY = 7	--七日盛典结束日期(开服后第几天)
ACTIVITY_SEVEN_FESTIVAL_DAY2 = 14--十四日盛典结束日期(开服后第几天)

MONTH_CARD_ITEMID = 1441;		--续费普通月卡使用的物品ID
MONTH_CARD_LUXURY_ITENID = 1442;--续费豪华月卡使用的物品ID

-- 活动入口
ACTIVITY_TAB_OPERATER = 0 		--运营活动
ACTIVITY_TAB_WELFARE = 1 		--福利
ACTIVITY_TAB_FESTIVAL = 2		--盛典

--活动模型ID(福利:小于10 运营活动:大于10)
ACTIVITY_MODEL = {
	SIGNIN = 1,					--签到
	ONLINE = 2,					--在线礼包
	LEVEL = 3,					--等级礼包
	SEVEN_FESTIVAL = 4, 		--七日盛典
	MONTHCARD = 5,				--月卡
	SEVEN_FESTIVAL2 = 6, 		--十四日盛典

	LOGIN = 11,					--登陆送奖励
	TOTAL_LOGIN = 13,			--累计登陆送
	CONTINUOUS_LOGIN = 14,		--连续登陆送
	SPECIFIC_ONLINE = 16,		--指定时间段在线
	DISCOUNT = 31,				--购买资源打折
	COPY_REWARD = 52,			--副本收益限时调整
	MONSTER_REWARD = 54,		--怪物收益限时调整
	TASK_REWARD = 55,			--任务收益限时调整
	TOTAL_JOIN_COPY = 71,		--副本累计参与送
	JOIN_WORLD_BOSS = 72,		--世界BOSS参与送
	SMELT = 73,					--熔炼N次返利
	SMELT_SPECIAL = 74,			--熔炼指定部位返利
	STRENGTHEN = 75,			--强化N次返利
	STRENGTHEN_SPECIAL = 76,	--强化指定部位返利
	TASK = 78,					--任务送
	BAPTIZE = 79,				--洗练N次返利
	BAPTIZE_SPECIAL = 80,		--洗练指定部位返利
	SPECIFIC_ITEM = 91,			--上交指定物品集齐送礼　
	TOTALCHARGE = 111,			--累积充值促销
	FIRSTCHARGE = 112,			--首次充值x元赠送x奖励
	PAY = 113,					--消费返还活动
	ONLINE_ACTIVITY = 151,		--在线时长奖励
	TOTALCHARGE2 = 152,			--累计充值分段奖励
	TOTAL_KILL_MONSTER = 154,	--累计击杀怪物数
	LEVEL_ACTIVITY = 156,		--角色等级分段奖励
}

--只有单个活动的活动ID
ACTIVITY_SIGNIN_ID = 1
ACTIVITY_SEVEN_FESTIVAL_ID = 2
ACTIVITY_ONLIINE_ID = 3
ACTIVITY_LEVEL_ID = 4
ACTIVITY_MONTHCARD_ID = 5       --普通月卡ID
ACTIVITY_MONTHCARD_LUXURY_ID = 6--豪华月卡ID
ACTIVITY_SEVEN_FESTIVAL_ID2 = 7	--十四日盛典

-- 活动对应的名称
ACTIVITY_NAME_SIGNIN = "签到"
ACTIVITY_NAME_SEVEN_FESTIVAL = "七日盛典"
ACTIVITY_NAME_ONLINE = "在线礼包"
ACTIVITY_NAME_LEVEL = "等级礼包"
ACTIVITY_NAME_MONTHCARD = "尊享月卡"		--月卡
ACTIVITY_NAME_MONTHCARD_LUXURY = "豪华月卡"	--月卡
ACTIVITY_NAME_SEVEN_FESTIVAL2 = "双周盛典"

ACTIVITY_MIN_ID = 11			--运营活动活动最小ID
--运营活动活动最大ID(带符号整形最大值减三位[2147483])
ACTIVITY_MAX_ID = math.floor(FIELD_ACTIVITY_CHILD_INDEX_MAX / 1000)

--七日盛典事件ID
ACTIVITY_ACT = {
	LOGIN = 1,		--登录
	LEVELUP = 2,	--升级
	BATTLEUP = 3,	--提升战斗力
	EQUIP = 4,		--全身装备强化等级
	LUCK = 5,		--武器幸运
	MEDALUP = 6,	--勋章升级
	WINGUP = 7,		--仙翼升级
	TULONG = 8,		--参与屠龙传说
	ZHAOLIN = 9,	--完成诏令任务
	XUANSHUANG = 10,--完成悬赏任务
	WINGTASK = 11,	--完成仙翼任务
	TOWER = 12,		--通天塔达到层数
	PRECIOUS = 13,	--完成远古宝藏次数
	GUARD = 14,		--完成多人守卫次数
	DART = 15,		--完成运镖
	ENVOY = 16,		--参与勇闯炼狱次数
	LOUXIA = 17,	--参与落霞夺宝
	PICKLUOXIA = 18,--拾取落霞宝盒
	MIXIANZHEN = 19,--迷仙阵
	SHANGXIANG = 20,--行会上香
	DIGMINE = 21,	--兑换矿石
	BAODI = 22,		--全民宝地
	PVP	= 23,		--公平竞技场
	QUALITY2 = 24,	--穿戴X件品质绿色以上装备
	QUALITY3 = 25,	--穿戴X件品质蓝色以上装备
	QUALITY4 = 26,	--穿戴X件品质紫色以上装备
	QUALITY5 = 27,	--穿戴X件品质橙色以上装备
	GIVEWINE = 28,	--王城赐福
}
ACTIVITY_ACT_NAME = {
	[ACTIVITY_ACT.LOGIN]		= "登录",
	[ACTIVITY_ACT.LEVELUP]		= "升级",
	[ACTIVITY_ACT.BATTLEUP]		= "提升战斗力",
	[ACTIVITY_ACT.EQUIP]		= "全身装备强化",
	[ACTIVITY_ACT.LUCK]			= "武器幸运",
	[ACTIVITY_ACT.MEDALUP]		= "勋章升级",
	[ACTIVITY_ACT.WINGUP]		= "仙翼升级",
	[ACTIVITY_ACT.TULONG]		= "参与屠龙传说",
	[ACTIVITY_ACT.ZHAOLIN]		= "完成诏令任务",
	[ACTIVITY_ACT.XUANSHUANG]	= "完成悬赏任务",
	[ACTIVITY_ACT.WINGTASK]		= "完成仙翼任务",
	[ACTIVITY_ACT.TOWER]		= "通天塔",
	[ACTIVITY_ACT.PRECIOUS]		= "远古宝藏",
	[ACTIVITY_ACT.GUARD]		= "多人守卫",
	[ACTIVITY_ACT.DART]			= "完成运镖",
	[ACTIVITY_ACT.ENVOY]		= "勇闯炼狱",
	[ACTIVITY_ACT.LOUXIA]		= "落霞夺宝",
	[ACTIVITY_ACT.PICKLUOXIA]	= "拾取落霞宝盒",
	[ACTIVITY_ACT.MIXIANZHEN]	= "迷仙阵",
	[ACTIVITY_ACT.SHANGXIANG]	= "行会上香",
	[ACTIVITY_ACT.DIGMINE]		= "兑换矿石",
	[ACTIVITY_ACT.BAODI]		= "全民宝地",
	[ACTIVITY_ACT.PVP]			= "公平竞技场",
	[ACTIVITY_ACT.QUALITY2]		= "穿戴X件品质绿色以上装备",
	[ACTIVITY_ACT.QUALITY3]		= "穿戴X件品质蓝色以上装备",
	[ACTIVITY_ACT.QUALITY4]		= "穿戴X件品质紫色以上装备",
	[ACTIVITY_ACT.QUALITY5]		= "穿戴X件品质橙色以上装备",
	[ACTIVITY_ACT.GIVEWINE]		= "王城赐福",
}
--七日盛典宝箱掉落ID
ACTIVITY_BOX_DEOPID = {
	[-1] = {point = 8, dropID = 2279},
	[-2] = {point = 25, dropID = 2280},
	[-3] = {point = 55, dropID = 2281},
	[-4] = {point = 85, dropID = 2282},
}
--十四日盛典宝箱掉落ID
ACTIVITY_BOX_DEOPID2 = {
	[-1] = {point = 15, dropID = 46},
	[-2] = {point = 35, dropID = 47},
	[-3] = {point = 65, dropID = 48},
	[-4] = {point = 90, dropID = 49},
}

--任务送 悬赏任务操作类型
ACTIVITY_TASK_OPERATE = {
	PUBLISH_GET_REWARD = 1,	--发布任务的人领取奖励
	FINISH_GET_REWARD = 2,	--完成任务
}

ACTIVITY_ERR_SIGNIN = 1 		--已签到
ACTIVITY_ERR_NOSLOT = 2 		--背包空间不足
ACTIVITY_ERR_RESIGN = 3 		--补签错误
ACTIVITY_ERR_INGOT  = 4 		--元宝不足
ACTIVITY_ERR_SUCCESS = 5 		--领取成功
ACTIVITY_ERR_BUY_SUCCESS = 6	--购买成功
ACTIVITY_ERR_MONTHCARD_INVALID = 7 --普通月卡未开启
ACTIVITY_ERR_LUXURY_MONTHCARD_INVALID = 8 --豪华月卡未开启
ACTIVITY_ERR_MONTHCARD_REWARD_REPEAT = 9 --月卡重复领取奖励
ACTIVITY_ERR_MONTHCARD_TIMELIMIT = 10 --小于5天才可续费
ACTIVITY_ERR_MONTHCARD_BUYITEM_LIMIT = 11 --续费月卡物品不足
ACTIVITY_ERR_MONTHCARD_RENEW_SUCCESS = 12 --续费月卡成功