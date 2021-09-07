
Config = Config or {}
Config.SCENE_TILE_HEIGHT = 0.5						-- 一格的高度（米）
Config.SCENE_TILE_WIDTH = 0.5						-- 一格的宽度（米）

Config.SCENE_ROLE_MOVE_SPEED = 1950					-- 角色模型默认移动(美术或策划调)
Config.SCENE_MOUNT_MOVE_SPEED = 2300				-- 坐骑模型默认移动(美术或策划调)


-- 场景类型
SceneType = {
	Common = 0,										-- 普通场景
	GuildStation = 1,								-- 军团驻地
	ZhuXie = 2,										-- 诛邪战场
	CoinFb = 3,										-- 铜钱副本
	ExpFb = 4,										-- 经验副本
	QunXianLuanDou = 5,								-- 三界战场
	TowerDefend = 6,								-- 塔防
	PhaseFb = 7,									-- 阶段副本
	GongChengZhan = 8,								-- 攻城战
	XianMengzhan = 9,								-- 仙盟战
	CampStation = 10,								-- 阵营驻地
	HunYanFb = 11,									-- 婚宴副本
	NationalBoss = 12,								-- 神兽禁地(全民boss)
	ChallengeFB = 13,								-- 挑战副本 （爬塔）
	GuildMonster = 14,								-- 仙盟神兽
	Field1v1 = 15, 									-- 1v1
	StoryFB = 16,									-- 剧情副本
	TeamFB = 17, 									-- 多人副本(妖兽祭坛)
	QingYuanFB = 18,								-- 情缘副本
	ZhanShenDianFB = 19,							-- 战神殿副本
	ShenMoZhiXiFB = 20,								-- 神魔之隙副本
	ChaosWar = 21,									-- 一战到底
	ManyTowerFB = 22,								-- 多人塔防(改个人塔防)
	GuildMiJingFB = 23,								-- 仙盟秘境
	WuXingFB = 24,									-- 五行打宝
	TransferProfTask = 25,							-- 闭关之境
	MiGongXianFu = 26,								-- 迷宫仙府
	Fb_Wushuang = 27,								-- 无双副本
	Kf_XiuLuoTower= 28,								-- 跨服修罗塔
	Kf_OneVOne= 29,									-- 跨服1v1
	Kf_PVP= 30,										-- 跨服3v3
	PataFB = 31,									-- 天宫试炼
	GuildBoss = 32,									-- 仙盟Boss
	YaoShouPlaza = 33,								-- 妖兽广场
	SuoYaoTa = 34,									-- 锁妖塔
	ShuiJing = 35,									-- 水晶
	ZhongKui = 36,									-- 密境降魔
	CampGaojiDuobao = 37,							-- 军团高级夺宝
	Kf_Teambattle = 38,								-- 跨服天庭战
	FarmHunting = 39,								-- 牧场
	VipFB = 40, 									-- VIP副本
	LingyuFb = 41, 									-- 现在的工会战
	Question = 42, 									-- 答题
	TianJiangCaiBao = 43,                           -- 天降财宝
	CrossBoss = 44,                           		-- 跨服Boss
	HotSpring = 45,        							-- 天山温泉
	TombExplore = 46,        						-- 王陵探险
	CrossFB = 47,        							-- 跨服副本
	ClashTerritory = 48,        					-- 领土战
	MountStoryFb = 50,								-- 坐骑剧情副本
	WingStoryFb = 51,								-- 羽翼剧情副本
	XianNvStoryFb = 52,								-- 仙女剧情副本
	CrossShuijing = 53,        						-- 跨服水晶幻境
	GuideFb = 54,        							-- 引导副本
	RuneTower = 55,                                 -- 挂机塔
	JunXian = 56,               	                -- 军衔副本
	Fishing = 57,									-- 钓鱼
	KfMining = 58,									-- 跨服挖矿
	DailyTaskFb = 59,								-- 日常任务副本
	TrunckTaskFb = 60,								-- 主线任务副本（没人就删）
	TeamEquipFb = 61,								-- 组队装备副本
	DaFuHao = 62,									-- 大富豪
	BranchFb = 63,									-- 支线任务副本
	XingZuoYiJi = 64,								-- 星座遗迹
	PushFuBen = 65, 								-- 推图副本
	Mining = 66,									-- 决斗场
	CrossGuildBattle = 67, 							-- 跨服帮派战
	MonsterSiegeFb = 68,							-- 怪物攻城
	DiMaiFb = 69,									-- 抢地脉
	ShengDiFB = 70,									-- 情缘圣地
	RoyalTombFB = 71,								-- 黄陵副本
	XianYangJuDian = 72,							-- 咸阳据点
	XianYangCheng = 73,								-- 咸阳城
	CrossServerSupremacy = 74,						-- 跨服大国争霸
	BabyBoss = 75,									-- 宝宝BOSS
	TeamSpecialFb = 76,								-- 组队副本(精英须臾幻境)
}

-- 跨服副本场景类型
CrossFbType = {
	SceneType.Kf_XiuLuoTower,
	SceneType.KfMining,
	SceneType.Fishing,
	SceneType.CrossGuildBattle,
}

--场景复活点
BossSceneRelivePoint = {
	[6001] = {scene_id = 104, x =72, y = 254},
	[6011] = {scene_id = 104, x = 240, y = 41},
	[6012] = {scene_id = 104, x = 38, y = 64},
	[6002] = {scene_id = 105, x = 209, y = 99},
	[6003] = {scene_id = 106, x = 22, y = 21},
}

--禁止飞行的普通场景
ForbidSceneIdList = {
	[6001] = 1,
	[6011] = 1,
	[6012] = 1,
	[6002] = 1,
	[6003] = 1,
	[130] = 1,
	[131] = 1,
	[132] = 1,
	[133] = 1,
    [134] = 1,
	[135] = 1,
	[136] = 1,
	[137] = 1,
	[138] = 1,
	[139] = 1,
	[200] = 1,
	[201] = 1,
	[202] = 1,
	[203] = 1,
	[204] = 1,
	[205] = 1,
	[206] = 1,
	[207] = 1,
	[208] = 1,
	[209] = 1,
	[605] = 1,
	[606] = 1,
	[607] = 1,
}

-- 恶名等级
EvilColorList = {
	NAME_COLOR_WHITE = 0,							-- 白色
	NAME_COLOR_RED_1 = 1,							-- 红色1
	NAME_COLOR_RED_2 = 2,							-- 红色2
	NAME_COLOR_RED_3 = 3,							-- 红色3
	NAME_COLOR_MAX = 4
}

-- 阵营场景对应关型
CampSceneIdList = {
	[GameEnum.ROLE_CAMP_1] = 109,
	[GameEnum.ROLE_CAMP_2] = 110,
	[GameEnum.ROLE_CAMP_3] = 108,
}

-- 阵营限制飞行对应场景id 
CampNotFlySceneIdList = {
	[GameEnum.ROLE_CAMP_1] = {						-- 齐
		[2000] = 1,
		[2001] = 1,
		[2002] = 1,
		[2003] = 1,
		[2004] = 1,
		[2005] = 1,
		[2006] = 1,
		[2303] = 1,
	},
	[GameEnum.ROLE_CAMP_2] = {						-- 楚
		[2100] = 1,
		[2101] = 1,
		[2102] = 1,
		[2103] = 1,
		[2104] = 1,
		[2105] = 1,
		[2106] = 1,
		[2303] = 1,
	},
	[GameEnum.ROLE_CAMP_3] = {						-- 魏
		[2200] = 1,
		[2201] = 1,
		[2202] = 1,
		[2203] = 1,
		[2204] = 1,
		[2205] = 1,
		[2206] = 1,
		[2303] = 1,
	},
}

-- 分等级段挂机地图
GuajiMapLimitList = {
	{s_level = 39, e_level = 55, id = {111}},
	{s_level = 56, e_level = 100, id = {114}},
}

-- 场景对象类型
SceneObjType = {
	Unknown = 0,
	Role = 1,										-- 角色
	Monster = 2,									-- 怪物
	FallItem = 3,									-- 掉落物
	GatherObj = 4,									-- 采集物
	ServerEffectObj = 6,							-- 服务端场景特效
	ShenShi = 9,									-- 战场神石

	MainRole = 20,									-- 主角
	SpriteObj = 30,									-- 精灵
	Npc = 31,										-- NPC
	Door = 32,										-- 传送点
	Decoration = 33,								-- 装饰物
	EffectObj = 34,									-- 特效
	TruckObj = 35,									-- 镖车
	EventObj = 36, 									-- 世界事件物品
	PetObj = 37, 									-- 宠物
	MultiMountObj = 38,								-- 双人坐骑
	GoddessObj = 39,								-- 女神
	FightMount = 40,								-- 战斗坐骑
	JumpPoint = 41,									-- 跳跃点
	Trigger = 42,									-- 触发物
	MingRen = 43, 									-- 名人堂
	BeautyObj = 44,									-- 美人
	BoatObj = 45, 									-- 温泉皮艇
	FollowObj = 46, 								-- 跟随物
	MingJiangObj = 47, 								-- 名将
	TestRole = 48, 									-- 测试角色
	CoupleHaloObj = 49, 							-- 夫妻光环
	FakeNpc = 50, 									-- 客户端假npc
	Baby = 51, 										-- 宝宝
}

-- 场景对象状态
SceneObjState = {
	Stand = "idle",									-- 站立
	Move = "run",									-- 移动
	Dead = "die",									-- 死亡
	Atk = "atk",									-- 攻击
}

ZoneType = {
	ShadowBegin = 97,								-- 阴影区起始值'a'
	ShadowDelta = 97 - string.byte("0"),			-- 阴影区差值'a' - '0'
}

-- 选择类型
SelectType = {
	All = 0,										-- 全部
	Friend = 1,										-- 友方
	Enemy = 2,										-- 敌方
	Alive = 3,										-- 活着的
}

-- 动作
SceneObjAnimator = {
	Idle = "idle",
	Idle2 = "idle2",
	Move = "run",
	Dead = "die",
	Dead2 = "die2",
	DeadImm = "die_imm",
	Hurt = "hurt",
	Atk1 = "attack1",
	Atk2 = "attack2",
	Atk3 = "attack3",
	FallImm = "fall_imm",
	Combo1_1 = "combo1_1",
	Combo1_2 = "combo1_2",
	Combo1_3 = "combo1_3",
}

-- 部件
SceneObjPart = {
	Main = 0,										-- 主体
	Weapon = 1,										-- 武器
	Weapon2 = 2,									-- 武器2
	Wing = 3,										-- 翅膀
	Mount = 4,										-- 坐骑
	Particle = 5,									-- 特效
	Halo = 6,										-- 光环
	FightMount = 7,									-- 战斗坐骑
	BaoJu = 8,										-- 宝具
	Mantle = 9,										-- 披风
	FaZhen = 10,									-- 法阵
	HoldBeauty = 11,								-- 抱美人
	Head = 12,										-- 头部
	Bag = 13,										-- 麻袋
	TouShi = 14,									-- 头饰
	Waist = 15,										-- 腰饰
	Mask = 16,										-- 面饰
}

-- 挂点
AttachPoint = {
	UI = 0,											-- UI挂点
	BuffTop = 1,									-- BUFF挂点上
	BuffMiddle = 2,									-- BUFF挂点中
	BuffBottom = 3,									-- BUFF挂点下
	Hurt = 4,										-- 受击胸口挂点
	HurtRoot = 5,									-- 受击脚底挂点
	Weapon = 6,										-- 武器挂点
	Weapon2 = 7,									-- 武器挂点
	Mount = 8,										-- 坐骑挂点
	Wing = 9,										-- 翅膀挂点
	FaZhen = 10,									-- 法阵挂点
	Head = 11,										-- 头部挂点
	Mask = 13,										-- 面饰挂点
	TouShi = 12,									-- 头饰挂点
	Waist = 14,										-- 腰饰挂点
}

-- Main身上挂的部件
PartAttachPoint = {
	[SceneObjPart.Weapon] = AttachPoint.Weapon,
	[SceneObjPart.Weapon2] = AttachPoint.Weapon2,
	[SceneObjPart.Halo] = AttachPoint.Hurt,
	[SceneObjPart.Particle] = AttachPoint.Hurt,
	[SceneObjPart.TouShi] = AttachPoint.TouShi,
	[SceneObjPart.Waist] = AttachPoint.Waist,
	[SceneObjPart.Mask] = AttachPoint.Mask,
}

-- Animator动作状态
ActionStatus = {
	Idle = 0,										-- 站立(闲置)
	Run = 1,										-- 跑步(奔跑)
	Die = 2,										-- 死亡
	Gather = 5,										-- 采集
	ChongFeng = 9,									-- 冲锋
	Hug = 20,										-- 抱美人站立
	HugRun = 21,									-- 抱美人跑步
	ShuaiGan = 24,									-- 甩杆
	ShangGou = 25,									-- 上钩
	ShouGan = 26,									-- 收杆
	Carry = 27,										-- 扛麻袋
	CarryRun = 28,									-- 扛麻袋移动
}


SceneConvertionArea = {
	SAFE_TO_WAY = 0,				-- 从安全区移动到野外
	WAY_TO_SAFE = 1,				-- 从野外移动到安全区
}

SceneIgnoreStatus = {
	MAIN_ROLE_IN_SAFE = "main_role_in_safe",			-- 忽略主角在安全区中
	OTHER_IN_SAFE = "other_in_safe",					-- 忽略其他对象在安全区中
}

SceneTargetSelectType = {
	SCENE = "scene",
	TASK = "task",
	SELECT = "select"
}

-- 传送点类型
SceneDoorType = {
	NORMAL = 0,
	FUBEN = 1,
	TEAM_FUBEN = 10,
	INVISIBLE = 100,
}


-- 战场
IsFightSceneType = {
	[SceneType.QunXianLuanDou] = true,
	[SceneType.GongChengZhan] = true,
	[SceneType.LingyuFb] = true,
	[SceneType.ClashTerritory] = true,
}

MASK_LAYER = {
	INVISIBLE = 31
}

-- 需要怪物面朝屏幕的场景
FaceToCameraSceneType = {
	[7] = -90,
	[40] = -90,
	[59] = -90,
}

-- 等级屏蔽其他玩家信息
LevelShieldOtherSceneId = {
	[2001] = true,
	[2101] = true,
	[2201] = true,
}

-- 场景需要改变朝向的怪物
CommonSceneTypeDirection = {
	[7028001] = -60,			-- 国旗
	[7029001] = -60,
	[7030001] = -60,
	[2129001] = -80,			-- 大臣
	[7034001] = -45,			-- 气运塔
	[7035001] = -45,
	[7036001] = -45,
	[5010] = 0,
	[5110] = 0,
	[5210] = 0,
	[901] = -80,			-- 大臣
	[902] = -80,			-- 大臣
	[903] = -80,			-- 大臣
	[907] = -45,			-- 气运塔
	[908] = -45,			-- 气运塔
	[909] = -45,			-- 气运塔
	[5015] = 0,			-- 国旗
	[5115] = 0,			-- 国旗
	[5215] = 0,			-- 国旗
	[5018] = -90,			-- 镖车
	[5118] = -90,			-- 镖车
	[5218] = -90,			-- 镖车
	[5020] = 0,
	[5120] = 0,
	[5220] = 0,
	[5005] = 30,
	[5105] = 30,
	[5205] = 30,
}


CommonSceneIdDirection = {
	[3151] = {
		[50230] = 180,
		[50231] = 180,
		[50232] = 180,
	},
	[3152] = {
		[50230] = 250,
		[50231] = 200,
		[50232] = 250,
	},
	[3153] = {
		[50230] = 250,
		[50231] = 200,
		[50232] = 210,
	},
	[3154] = {
		[50230] = 0,
		[50231] = 0,
		[50232] = 30,
	},
	[3155] = {
		[50230] = 230,
		[50231] = 200,
		[50232] = 250,
	},
}

-- 图腾柱的怪物id
TotemMonsterId = {
	[314] = true,
	[315] = true,
}

-- 取消俯冲镜头的场景
SceneCanNotChangeCamera = {
	[3800] = true,
}
