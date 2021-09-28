--FunctionLevelConst.lua

local FunctionLevelConst = {
	STORY_DUNGEON 			= 1,	--剧情副本
	ARENA_SCENE 			= 2,	--竞技场	
	TREASURE_COMPOSE		= 3,	--夺宝
	TOWER_SCENE				= 4,	--闯关

	KNIGHT_STRENGTH			= 5,	--武将强化
	KNIGHT_JINGJIE			= 6,	--武将突破
	EQUIP_STRENGTH			= 7,	--装备强化
	SECRET_SHOP				= 8,	--神秘商店
	DUNGEON_SAODANG			= 9,	--扫荡

	BATTLE_ARRAY_2			= 10,	--第2阵位
	BATTLE_ARRAY_3			= 11,	--第3阵位
	BATTLE_ARRAY_4			= 12,	--第4阵位
	BATTLE_ARRAY_5			= 13,	--第5阵位
	BATTLE_ARRAY_6			= 14,	--第6阵位

	TREASURE_STRENGTH		= 15,	--宝物强化
	TREASURE_TRAINING		= 16,	--宝物精练
	EQUIP_TRAINING			= 17,	--装备精炼

	KNIGHT_GUANGHUAN		= 18,	--武将光环
	KNIGHT_TRAINING			= 19,	--武将培养

	MOSHENG_SCENE			= 20,	--叛军系统

	BATTLE_RATE_2			= 21,	--战斗播放
	BATTLE_RATE_3			= 22,	--战斗播放

	PARTNER_ARRAY_1			= 23, 	--小伙伴第1阵位
	PARTNER_ARRAY_2			= 24, 	--小伙伴第2阵位
	PARTNER_ARRAY_3			= 25, 	--小伙伴第3阵位
	PARTNER_ARRAY_4			= 26, 	--小伙伴第4阵位
	PARTNER_ARRAY_5			= 27, 	--小伙伴第5阵位
	PARTNER_ARRAY_6			= 28, 	--小伙伴第6阵位

	VIP_SCENE				= 29,	--vip副本

	CHAT					= 30,

	STRENGTH_FIVE_TIMES		= 31,

	MING_XING_MODULE		= 32,

	ZHEN_YING_ZHAO_MU		= 33,  --阵营招募

    HALLOFFRAME_SCENE       = 34,    --名人堂

    CITY_PLUNDER 			= 35,

    CARTOON_SHOW			= 36,

    LEGION					= 37,

    DRESS					= 38, --时装

    TREASURE_ROB_5_TIMES    = 39,   --夺宝5次

    AWAKEN                  = 40,
    
    HARDDUNGEON				= 44,
    
    TOWERFAST				= 45,

    CROSS_WAR				= 46, --跨服演武
    
  	TITLE 					= 47, --称号系统

  	TIMEDUNGEON				= 48, --限时挑战

  	ARENA_FIVE_CHALLENGE    = 49, --竞技场挑战5次

  	MOSHENG_BATTLE_SKIP     = 50, --叛军战斗跳过

  	HARD_DUNGEON_RIOT		= 51, --精英副本暴动

  	KNIGHT_FRIEND_ZHUWEI     = 52, --小伙伴护佑

  	WHEEL     = 53, --转盘开启
  	RICHMAN     = 54, --大富翁开启
  	FUMAIN     = 55, --富甲天下主界面开启

  	ROB_RICE   = 56, --夺粮战

  	REBEL_BOSS = 57, --世界Boss

  	INVITOR = 58, --推广福利
  	DRESSSTRENGTH = 59, --时装强化

  	TIME_PRIVILEGE = 60, --限时优惠

  	KNIGHT_TRANSFORM = 61, --武将变身

  	TREASURE_SMELT	= 62,	-- 宝物熔炼
  	TREASURE_FORGE	= 63,	-- 宝物铸造

  	THEME_DROP = 64, 		-- 限时抽将

  	ONE_KEY_ROB_TREASURE = 66, -- 一键夺宝

  	OPTIMIZE_LEVEL_UP = 67, -- 武将升级优化

    SET_AVATAR = 68, -- 设置头像

    CRUSADE = 69, --百战沙场

    PET = 70, --战宠背包

    PET_SHOP = 71, --战宠商店

    RECYCLE_PET        = 72, -- 战宠分解
    RECYCLE_PET_REBORN = 73, -- 战宠重生

    PET_STRENGTH   = 74, -- 战宠升级
    PET_STAR 	   = 75, -- 战宠升星
    PET_REFINE     = 76, -- 战宠神练

  	-----------------------
  	-- 新功能ID分隔线 发版本时有新功能function_id请往上累加
  	-- 并将该值改成上个版本上线功能最大值
  	NEW_FUNCTION_FLOOR = 78,    --对应1.8.0版本
  	-----------------------
  	
    EQUIP_STAR      = 77, -- 装备升星

    TRIGRAMS 		   = 78, --奇门八卦

    CROSS_PVP      = 79, --跨服选美

    ITEM_COMPOSE = 80, -- 道具合成

    PHONE_BIND = 82, -- 手机绑定

    PET_PROTECT1 = 83, -- 战宠护佑第1个位置
    PET_PROTECT2 = 84, -- 战宠护佑第2个位置
    PET_PROTECT3 = 85, -- 战宠护佑第3个位置
    PET_PROTECT4 = 86, -- 战宠护佑第4个位置
    PET_PROTECT5 = 87, -- 战宠护佑第5个位置
    PET_PROTECT6 = 88, -- 战宠护佑第6个位置

    KNIGHT_GOD = 89, -- 武将化神
    DAILY_PVP = 90, -- 组队pvp
  	
    FAST_COMPOSE_AWAKEN_ITEM = 91,  -- 一键合成觉醒道具

    CROSS_GROUP_KNIGHT_TRANSFORM = 92, --跨阵营武将变身

    AWAKEN_MARK = 93,
    
    FAST_REFINE = 94, --一键精炼

    CHANGE_ROLE_NAME = 95, -- 更改角色名

    CHANGE_CARD = 96, -- 充值翻牌

    HERO_SOUL = 97, -- 将灵

    VIP_LIBAO = 98, -- vip礼包

    RED_KNIGHT_TRANSFORM = 99, -- 红将变身

    WUSH_FAST = 100, -- 一键三星

    FORTUNE = 101, -- 招财符

    FUNCTION_MAX     = 102,


}


return FunctionLevelConst
