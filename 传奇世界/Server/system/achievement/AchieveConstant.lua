--AchieveConstant.lua

AchieveType = {}
AchieveEventType = {}



-- 成就通知类型
AchieveNotifyType = 
{
	sign = 1,		-- 签到
	supplementSign = 2,		-- 补签
	levelUp = 3,		-- 升级
	fightAbility = 4,	-- 战力
	getItem = 5,	-- 获得物品
	installEquip = 6,		-- 穿上装备
	getGold = 7,		-- 获得金币
	getRide = 8,		-- 获得坐骑
	finishTask = 9,		-- 完成任务
	acceptTask = 10,		-- 接受任务
	taskUpstar = 11,		-- 任务升星
	finishDailyTask1 = 12,			-- 完美完成诏令任务
	finishDailyTask2 = 13,			-- 一键完成诏令任务
	publishReward  = 14,		-- 发布悬赏任务
	finishReward = 15,			-- 完成悬赏
	beFinishReward = 16,		-- 被完成悬赏
	failedReward = 17,			-- 悬赏任务失败
	equipStrength = 18,		-- 装备强化
	getWing = 19,				-- 获得仙翼
	learnWingSkill = 20,				-- 学习仙翼技能
	upWingSkill = 21,			-- 升级仙翼技能
	learnSkill = 22,			-- 学习技能
	upSkill = 23,				-- 升级技能
	promotWing = 24,			-- 强化仙翼
	UpWing = 25,			-- 仙翼进阶
	autoPromotWing = 26,			-- 自动强化仙翼
	hideWing = 27,				-- 隐藏翅膀
	useSkillItem = 28,				-- 技能灵丹
	upMedal = 29,				-- 勋章升级
	blessEquip = 30,			-- 祝福
	hurtlWorldBoss = 31,			-- 参与挑战世界boss
	killWorldBoss = 32,				-- 击杀世界boss
	sufferSkill = 33,				-- 受到技能攻击
	joinEnvoy = 34,				-- 参加勇闯炼狱
	killMonster = 35,			-- 杀怪
	joinLuoxia = 36,			-- 参与落霞夺宝
	useItem = 37,				-- 使用物品
	DartSuccess = 38,				-- 成功护送镖车
	DartLoot = 39,			-- 劫镖
	TeamDart = 40,			-- 集体镖车
	killAttackCity1 = 41,		-- 击杀怪物攻城活动中X只普通怪物
	killAttackCity2 = 42,		-- 击杀怪物攻城活动中X只精英怪物
	killAttackCity3 = 43,		-- 击杀怪物攻城活动中X只BOSS
	joinWine = 44,				-- 参与仙翁赐酒
	digMineExchage = 45,		-- 兑换挖矿奖励
	playerDead = 46,				-- 玩家死亡
	pkChange = 47,				-- pk值改变
	reliveInRedCity = 48,		-- 红名村复活
	dropEquip = 49,				-- 使别人装备被爆
	dropBagItem = 50,			-- 使别人包裹物品被爆
	joinManorWar = 51,			-- 参加领地战
	winManorWar = 52,			-- 赢得领地战
	joinZhongzhouWar = 53,			-- 参加中州战
	winZhongzhouWar = 54,			-- 赢得中州战
	joinShaWar = 55,			-- 参加沙城战
	winShaWar = 56,				-- 赢得沙城战
	addFriend = 57,				-- 添加好友
	addBlack = 58,				-- 添加黑名单
	deleteEnemy = 59,			-- 删除仇敌
	studentOut = 60,			-- 出师 
	giveFlower = 61,			-- 送花
	addSkillExp = 62,			-- 增加技能熟练度
	addBuff = 63,				-- 增加buff通知
	luckChange = 64,			-- 幸运改变
	zhanShou = 65,				-- 斩首逆魔
	oneShotTongtian = 66,		-- 关键一击-通天
	oneShotAxiuluo = 67,		-- 关键一击-阿修罗
	killKuangbaoShiba = 68,		-- 击杀狂暴尸霸
	doneCopy = 69,				-- 完成副本
	doneTongtian = 70,			-- 完成通天塔
	tongtianLevel = 71,			-- 通天塔层数
	tongtianStar = 72,			-- 通天塔星数
	doneGuards = 73,			-- 通关多人守卫
	doneGuardsSingle = 74,		-- 通关多人守卫
	tulongFail = 75,			-- 屠龙传说失败
	createFaction = 76,			-- 创建帮会
	joinFation = 77,			-- 加入帮会
	hurtFactionBoss = 78,		-- 伤害行会boss
	factionFire = 79,			-- 薪火传承
	factionPray = 80,			-- 行会进香
	getEnvoyItem = 81,			-- 炼狱夺宝
	useArrow = 82,				-- 使用穿云箭
}

-- 成就条件类型
AchieveConditionType = 
{
	sign = 1,		-- 签到
	continueSign = 2,		-- 连续签到
	supplementSign = 3,		-- 补签
	levelUp = 4,		-- 升级
	fightAbility = 5,	-- 战力
	getEquip = 6,		-- 获得装备
	installSuit = 7,		-- 穿上套装
	getGold = 8,		-- 获得金币
	getRide = 9,		-- 获得坐骑
	finishTask = 10,		-- 完成任务
	accepDailytTask = 11,		-- 接受日常任务
	taskUpstar = 12,		-- 任务升星
	finishDailyTask1 = 13,			-- 完美完成诏令任务
	finishDailyTask2 = 14,			-- 一键完成诏令任务
	publishReward  = 15,		-- 发布悬赏任务
	finishReward = 16,			-- 完成悬赏
	beFinishReward = 17,		-- 被完成悬赏
	failedReward = 18,			-- 悬赏任务失败
	equipStrength = 19,		-- 装备强化
	continueEquipStrengthSuccess = 20,		-- 连续装备强化成功
	continueEquipStrengthFail = 21,		-- 连续装备强化失败
	getWing = 22,				-- 获得仙翼
	learnWingSkill = 23,				-- 学习仙翼技能
	upWingSkill = 24,			-- 升级仙翼技能
	minWingSkill = 25,			-- 最小的仙翼技能
	maxWingSkill = 26,			-- 最大的仙翼技能
	learnSkill = 27,			-- 学习技能
	promotWing = 28,			-- 强化仙翼
	UpWing = 29,			-- 仙翼进阶
	autoPromotWing = 30,			-- 自动强化仙翼
	hideWing = 31,				-- 隐藏翅膀
	upSkill1 = 32,				-- 任意技能升至X级
	upSkill2 = 33,				-- X个技能升到大师级
	useSkillItem = 34,				-- 技能灵丹
	upMedal = 35,				-- 勋章升级
	blessEquip = 36,			-- 祝福
	blessEquipSuccess = 37,			-- 祝福成功
	blessEquipLuck = 38,			-- 祝福武器后的幸运值
	hurtlWorldBoss = 39,			-- 参与挑战世界boss
	killWorldBoss = 40,				-- 击杀世界boss
	sufferSkill = 41,				-- 受到技能攻击
	joinEnvoy = 42,				-- 参加勇闯炼狱
	killMonster = 43,			-- 杀怪
	joinLuoxia = 44,			-- 参与落霞夺宝
	getItem = 45,			-- 获得物品
	useItem = 46,			-- 使用物品
	DartSuccess = 47,				-- 成功护送镖车
	DartLoot = 48,			-- 劫镖
	TeamDart = 49,			-- 集体镖车
	killAttackCity1 = 50,		-- 击杀怪物攻城活动中X只普通怪物
	killAttackCity2 = 51,		-- 击杀怪物攻城活动中X只精英怪物
	killAttackCity3 = 52,		-- 击杀怪物攻城活动中X只BOSS
	joinWine = 53,				-- 参与仙翁赐酒
	digMineExchage = 54,		-- 兑换挖矿奖励
	killHigherPlayer = 55,		-- 击杀X个等级不低于你的玩家
	beKillByPlayer = 56,		-- 被玩家击杀
	pkChange = 57,				-- pk值改变
	killEnemy = 58,				-- 击杀仇敌
	reliveInRedCity = 59,		-- 红名村复活
	killRedPlayer = 60,			-- 杀红名的玩家
	killZhongzhouKing = 61,			-- 杀中州王
	dropItem = 62,				-- 被爆物品
	dropEquip = 63,				-- 使别人装备被爆
	joinManorWar = 64,			-- 参加领地战
	winManorWar = 65,			-- 赢得领地战
	joinZhongzhouWar = 66,			-- 参加中州战
	winZhongzhouWar = 67,			-- 赢得中州战
	joinShaWar = 68,			-- 参加沙城战
	winShaWar = 69,				-- 赢得沙城战
	addFriend = 70,				-- 添加好友
	addBlack = 71,				-- 添加黑名单
	deleteEnemy = 72,			-- 删除仇敌
	studentOut = 73,			-- 出师 
	giveFlower = 74,			-- 送花
	receiveFlower = 75,			-- 收到花
	addSkillExp = 76,			-- 增加技能熟练度
	addBuff = 77,				-- 增加buff
	luckChange = 78,			-- 玩家幸运值改变
	zhanShou = 79,				-- 斩首逆魔
	oneShotTongtian = 80,		-- 关键一击-通天
	oneShotAxiuluo = 81,		-- 关键一击-阿修罗
	killKuangbaoShiba = 82,		-- 击杀狂暴尸霸
	doneCopy = 83,				-- 完成副本
	doneTongtian = 84,			-- 完成通天塔
	tongtianLevel = 85,			-- 通天塔层数
	tongtianStar = 86,			-- 通天塔星数
	doneGuards = 87,			-- 通关多人守卫
	doneGuardsSingle = 88,		-- 通关多人守卫
	tulongFail = 89,			-- 屠龙传说失败
	createFaction = 90,			-- 创建帮会
	joinFation = 91,			-- 加入帮会
	hurtFactionBoss = 92,		-- 伤害行会boss
	factionFire = 93,		-- 薪火传承
	killFactionEnemy = 94,		-- 击杀敌对行会玩家
	factionPray = 95,			-- 行会进香
	killPlayerInMap = 96,		-- 在特定地图被击杀玩家
	getEnvoyItem = 97,			-- 炼狱夺宝
	killCharming = 98,			-- 杀死鲜花榜榜首1次
	allStrength = 99,			-- 全身强化
	yellowName = 100,			-- 黄名
	redName = 101,				-- 红名
	useArrow = 102,				-- 使用穿云箭
}

-- 成就通知处理函数
AchieveNotifyFunc = 
{
	[AchieveNotifyType.sign] = {func = "dealSign"},
	[AchieveNotifyType.supplementSign] = {func = "dealCommon", conditionType = AchieveConditionType.supplementSign},
	[AchieveNotifyType.levelUp] = {func = "dealCommon", conditionType = AchieveConditionType.levelUp},
	[AchieveNotifyType.fightAbility] = {func = "dealCommon", conditionType = AchieveConditionType.fightAbility},
	[AchieveNotifyType.getItem] = {func = "dealGetItem"},
	[AchieveNotifyType.installEquip] = {func = "dealInstallEquip"},
	[AchieveNotifyType.getGold] = {func = "dealCommon", conditionType = AchieveConditionType.getGold},
	[AchieveNotifyType.getRide] = {func = "dealGetRide"},
	[AchieveNotifyType.finishTask] = {func = "dealFinishTask"},
	[AchieveNotifyType.acceptTask] = {func = "dealAcceptTask"},
	[AchieveNotifyType.taskUpstar] = {func = "dealCommon", conditionType = AchieveConditionType.taskUpstar},
	[AchieveNotifyType.finishDailyTask1] = {func = "dealCommon", conditionType = AchieveConditionType.finishDailyTask1},
	[AchieveNotifyType.finishDailyTask2] = {func = "dealCommon", conditionType = AchieveConditionType.finishDailyTask2},
	[AchieveNotifyType.publishReward] = {func = "dealCommon", conditionType = AchieveConditionType.publishReward},
	[AchieveNotifyType.finishReward] = {func = "dealCommon", conditionType = AchieveConditionType.finishReward},
	[AchieveNotifyType.beFinishReward] = {func = "dealCommon", conditionType = AchieveConditionType.beFinishReward},
	[AchieveNotifyType.failedReward] = {func = "dealCommon", conditionType = AchieveConditionType.failedReward},
	[AchieveNotifyType.equipStrength] = {func = "dealEquipStrength"},
	[AchieveNotifyType.getWing] = {func = "dealCommon", conditionType = AchieveConditionType.getWing},
	[AchieveNotifyType.learnWingSkill] = {func = "dealCommon", conditionType = AchieveConditionType.learnWingSkill},
	[AchieveNotifyType.upWingSkill] = {func = "dealUpWingSkill"},
	[AchieveNotifyType.learnSkill] = {func = "dealLearnSkill"},
	[AchieveNotifyType.promotWing] = {func = "dealCommon", conditionType = AchieveConditionType.promotWing},
	[AchieveNotifyType.UpWing] = {func = "dealCommon", conditionType = AchieveConditionType.UpWing},
	[AchieveNotifyType.autoPromotWing] = {func = "dealCommon", conditionType = AchieveConditionType.autoPromotWing},
	[AchieveNotifyType.hideWing] = {func = "dealCommon", conditionType = AchieveConditionType.hideWing},
	[AchieveNotifyType.upSkill] = {func = "dealUpSkill"},
	[AchieveNotifyType.useSkillItem] = {func = "dealCommon", conditionType = AchieveConditionType.useSkillItem},
	[AchieveNotifyType.upMedal] = {func = "dealCommon", conditionType = AchieveConditionType.upMedal},
	[AchieveNotifyType.blessEquip] = {func = "dealBlessEquip"},
	[AchieveNotifyType.hurtlWorldBoss] = {func = "dealCommon", conditionType = AchieveConditionType.hurtlWorldBoss},
	[AchieveNotifyType.killWorldBoss] = {func = "dealCommon", conditionType = AchieveConditionType.killWorldBoss},
	[AchieveNotifyType.sufferSkill] = {func = "dealCommon", conditionType = AchieveConditionType.sufferSkill},
	[AchieveNotifyType.joinEnvoy] = {func = "dealJoinEnvoy"},
	[AchieveNotifyType.killMonster] = {func = "dealKillMonster"},
	[AchieveNotifyType.joinLuoxia] = {func = "dealJoinLuoxia"},
	[AchieveNotifyType.useItem] = {func = "dealCommon", conditionType = AchieveConditionType.useItem},
	[AchieveNotifyType.DartSuccess] = {func = "dealCommon", conditionType = AchieveConditionType.DartSuccess},
	[AchieveNotifyType.DartLoot] = {func = "dealCommon", conditionType = AchieveConditionType.DartLoot},
	[AchieveNotifyType.TeamDart] = {func = "dealCommon", conditionType = AchieveConditionType.TeamDart},
	[AchieveNotifyType.killAttackCity1] = {func = "dealCommon", conditionType = AchieveConditionType.killAttackCity1},
	[AchieveNotifyType.killAttackCity2] = {func = "dealCommon", conditionType = AchieveConditionType.killAttackCity2},
	[AchieveNotifyType.killAttackCity3] = {func = "dealCommon", conditionType = AchieveConditionType.killAttackCity3},
	[AchieveNotifyType.joinWine] = {func = "dealCommon", conditionType = AchieveConditionType.joinWine},
	[AchieveNotifyType.digMineExchage] = {func = "dealCommon", conditionType = AchieveConditionType.digMineExchage},
	[AchieveNotifyType.playerDead] = {func = "dealPlayerDead"},
	[AchieveNotifyType.pkChange] = {func = "dealPkChange"},
	[AchieveNotifyType.reliveInRedCity] = {func = "dealCommon", conditionType = AchieveConditionType.reliveInRedCity},
	[AchieveNotifyType.dropEquip] = {func = "dealDropEquip"},
	[AchieveNotifyType.dropBagItem] = {func = "dealDropBagItem"},
	[AchieveNotifyType.joinManorWar] = {func = "dealCommon", conditionType = AchieveConditionType.joinManorWar},
	[AchieveNotifyType.winManorWar] = {func = "dealCommon", conditionType = AchieveConditionType.winManorWar},
	[AchieveNotifyType.joinZhongzhouWar] = {func = "dealCommon", conditionType = AchieveConditionType.joinZhongzhouWar},
	[AchieveNotifyType.winZhongzhouWar] = {func = "dealCommon", conditionType = AchieveConditionType.winZhongzhouWar},
	[AchieveNotifyType.joinShaWar] = {func = "dealCommon", conditionType = AchieveConditionType.joinShaWar},
	[AchieveNotifyType.winShaWar] = {func = "dealCommon", conditionType = AchieveConditionType.winShaWar},
	[AchieveNotifyType.addFriend] = {func = "dealCommon", conditionType = AchieveConditionType.addFriend},
	[AchieveNotifyType.addBlack] = {func = "dealCommon", conditionType = AchieveConditionType.addBlack},
	[AchieveNotifyType.deleteEnemy] = {func = "dealCommon", conditionType = AchieveConditionType.deleteEnemy},
	[AchieveNotifyType.studentOut] = {func = "dealCommon", conditionType = AchieveConditionType.studentOut},
	[AchieveNotifyType.giveFlower] = {func = "dealGiveFlower"},
	[AchieveNotifyType.addSkillExp] = {func = "dealCommon", conditionType = AchieveConditionType.addSkillExp},
	[AchieveNotifyType.addBuff] = {func = "dealCommon", conditionType = AchieveConditionType.addBuff},
	[AchieveNotifyType.luckChange] = {func = "dealCommon", conditionType = AchieveConditionType.luckChange},
	[AchieveNotifyType.zhanShou] = {func = "dealCommon", conditionType = AchieveConditionType.zhanShou},
	[AchieveNotifyType.oneShotTongtian] = {func = "dealCommon", conditionType = AchieveConditionType.oneShotTongtian},
	[AchieveNotifyType.oneShotAxiuluo] = {func = "dealCommon", conditionType = AchieveConditionType.oneShotAxiuluo},
	[AchieveNotifyType.killKuangbaoShiba] = {func = "dealCommon", conditionType = AchieveConditionType.killKuangbaoShiba},
	[AchieveNotifyType.doneCopy] = {func = "dealCommon", conditionType = AchieveConditionType.doneCopy},
	[AchieveNotifyType.doneTongtian] = {func = "dealCommon", conditionType = AchieveConditionType.doneTongtian},
	[AchieveNotifyType.tongtianLevel] = {func = "dealCommon", conditionType = AchieveConditionType.tongtianLevel},
	[AchieveNotifyType.tongtianStar] = {func = "dealCommon", conditionType = AchieveConditionType.tongtianStar},
	[AchieveNotifyType.doneGuards] = {func = "dealCommon", conditionType = AchieveConditionType.doneGuards},
	[AchieveNotifyType.doneGuardsSingle] = {func = "dealCommon", conditionType = AchieveConditionType.doneGuardsSingle},
	[AchieveNotifyType.tulongFail] = {func = "dealCommon", conditionType = AchieveConditionType.tulongFail},
	[AchieveNotifyType.createFaction] = {func = "dealCommon", conditionType = AchieveConditionType.createFaction},
	[AchieveNotifyType.joinFation] = {func = "dealCommon", conditionType = AchieveConditionType.joinFation},
	[AchieveNotifyType.hurtFactionBoss] = {func = "dealHurtFactionBoss"},
	[AchieveNotifyType.factionFire] = {func = "dealCommon", conditionType = AchieveConditionType.factionFire},
	[AchieveNotifyType.factionPray] = {func = "dealCommon", conditionType = AchieveConditionType.factionPray},
	[AchieveNotifyType.getEnvoyItem] = {func = "dealCommon", conditionType = AchieveConditionType.getEnvoyItem},
	[AchieveNotifyType.useArrow] = {func = "dealCommon", conditionType = AchieveConditionType.useArrow},
}


-- 更新成就值类型
AchieveValueUpdateType =
{
	add = 1,		-- 累加
	cover = 2,		-- 覆盖
	bigCover = 3,		-- 大于才覆盖
}


AchieveCustomValueMax = 3	-- 成就最大自定义值得个数
AchieveValueSetMax = 2 		-- 成就自定义值集合最大个数

-- 成就自定义值比较类型
AchieveCustomValueCmpType = 
{
	et = 1,			-- 等于
	bet = 2,			-- 大于等于
}

-- 称号属性类型
TitlePropType =
{
	maxHp = 1,		-- 最大血量
	maxMp = 2,		-- 最大魔量
	minAttack = 3,		-- 攻击力
	maxAttack = 4,		-- 攻击力
	minDf = 5,		-- 最小防御力
	maxDf = 6,		-- 最大防御力
	minMf = 7,		-- 最小魔法防御力
	maxMf = 8,		-- 最大魔法防御力
	hit = 9,		-- 命中
	dodge = 10,		-- 闪避
	crit = 11,		-- 暴击
	tenacity = 12,	-- 韧性
}	

TitlePropString = 
{
	[TitlePropType.maxHp] = "MaxHP",
	[TitlePropType.maxMp] = "MaxMP",
	[TitlePropType.minDf] = "MinDF",
	[TitlePropType.maxDf] = "MaxDF",
	[TitlePropType.minMf] = "MinMF",
	[TitlePropType.maxMf] = "MaxMF",
	[TitlePropType.hit] = "Hit",
	[TitlePropType.dodge] = "Dodge",
	[TitlePropType.crit] = "Crit",
	[TitlePropType.tenacity] = "Tenacity",
}

-- 沙城城主称号
ShaCityTitle = 
{
	[1] = 1064,
	[2] = 1065,
	[3] = 1066,
}

-- 人见人爱称号
CharmingTitle = 
{
	[1] = 1091,
	[2] = 1092,
	[3] = 1093,
}

-- 仙翼技能表
AchieveWingSkill = 
{
	10044, 10045, 10046, 10047
}

-- 物品称号
HasItemTitle = 
{
	[1] = 
	{
		startItemID = 5990000,
		endItemId = 5990199,

		title = 
		{
			[1] = 1097,
			[2] = 1098,
			[3] = 1099,
		}
	},

	[2] = 
	{
		startItemID = 5990200,
		endItemId = 5990399,

		title = 
		{
			[1] = 1103,
			[2] = 1104,
			[3] = 1105,
		}
	},

	[3] = 
	{
		startItemID = 5990400,
		endItemId = 5990599,

		title = 
		{
			[1] = 1100,
			[2] = 1101,
			[3] = 1102,
		}
	},
}

