
READ_TYPE = {
	INT = 0,
	UINT = 1,
	FLOAT = 2,
}

-- 对象属性定义
OBJ_ATTR = {
	ENTITY_ID						= 0,		-- uint actor id或者怪物ID
	ENTITY_X						= 1,		-- int 位置x
	ENTITY_Y						= 2,		-- int 位置y
	ENTITY_MODEL_ID					= 3,		-- int 模型ID
	ENTITY_AVATAR_ID				= 4,		-- uint 头像ID
	ENTITY_DIR						= 5,		-- int 朝向

	CREATURE_LEVEL					= 6,		-- uint 等级
	CREATURE_HP						= 7,		-- uint 当前血
	CREATURE_MP						= 8,		-- uint 当前蓝
	CREATURE_STATE					= 9,		-- uint 当前状态
	CREATURE_COLOR					= 10,		-- uint 颜色
	CREATURE_MAX_HP					= 11,		-- uint 最大血(生命)
	CREATURE_MAX_MP					= 12,		-- uint 最大蓝(内力)
	CREATURE_PHYSICAL_ATTACK_MIN	= 13,		-- int 最小物理攻击
	CREATURE_PHYSICAL_ATTACK_MAX	= 14,		-- int 最大物理攻击
	CREATURE_MAGIC_ATTACK_MIN		= 15,		-- int 最小魔法攻击
	CREATURE_MAGIC_ATTACK_MAX		= 16,		-- int 最大魔法攻击
	CREATURE_WIZARD_ATTACK_MIN		= 17,		-- int 最小道术攻击
	CREATURE_WIZARD_ATTACK_MAX		= 18,		-- int 最大道术攻击
	CREATURE_PHYSICAL_DEFENCE_MIN	= 19,		-- int 最小物理防御
	CREATURE_PHYSICAL_DEFENCE_MAX	= 20,		-- int 最大物理防御
	CREATURE_MAGIC_DEFENCE_MIN		= 21,		-- int 最小魔法防御
	CREATURE_MAGIC_DEFENCE_MAX		= 22,		-- int 最大魔法防御
	CREATURE_HIT_RATE				= 23,		-- int 准确
	CREATURE_DOGE_RATE				= 24,		-- int 敏捷
	CREATURE_MAGIC_HIT_RATE			= 25,		-- float 魔法命中
	CREATURE_MAGIC_DOGERATE			= 26,		-- float 魔法闪避
	CREATURE_TOXIC_DOGERATE			= 27,		-- float 毒物闪避
	CREATURE_HP_RENEW				= 28,		-- float 生命恢复
	CREATURE_MP_RENEW				= 29,		-- float 魔法恢复
	CREATURE_TOXIC_RENEW			= 30,		-- float 毒物恢复
	CREATURE_LUCK					= 31,		-- int 幸运
	CREATURE_CURSE					= 32,		-- int 诅咒
	CREATURE_MOVE_SPEED				= 33,		-- uint 移动速度，移动1格需要的时间
	CREATURE_ATTACK_SPEED			= 34,		-- uint 攻击速度
	ACTOR_CRITRATE 					= 35,		-- uint 暴击率
	ACTOR_RESISTANCECRIT 			= 36,		-- uint 暴击力
	
	-- 玩家的属性
	ACTOR_BAG_WEIGHT				= 37,		-- int 当前的背包的负重
	ACTOR_BAG_MAX_WEIGHT			= 38,		-- int 背包最大负重
	ACTOR_EQUIP_WEIGHT				= 39,		-- int 当前装备负重	-- Monster属性：盾次数
	ACTOR_EQUIP_MAX_WEIGHT			= 40,		-- int 装备最大负重
	ACTOR_WEAPON_WEIGHT				= 41,		-- int 武器的负重
	ACTOR_ARMPOWER					= 42,		-- int 玩家的腕力
	ACTOR_WEAPON_APPEARANCE			= 43,		-- int 武器的外观
	ACTOR_MOUNT_APPEARANCE			= 44,		-- int 坐骑的外观
	ACTOR_WING_APPEARANCE			= 45,		-- int 翅膀的外观
	ACTOR_PK_MODE					= 46,		-- uint 玩家的pk模式
	ACTOR_SEX						= 47,		-- uint 性别
	ACTOR_PROF						= 48,		-- uint 职业
	ACTOR_EXP_L						= 49,		-- uint 经验低位
	ACTOR_EXP_H						= 50,		-- uint 经验高位
	ACTOR_PK_VALUE					= 51,		-- int PK值
	ACTOR_BAG_BUY_GRID_COUNT		= 52,		-- uint 背包的格子数量
	ACTOR_STALL_GRID_COUNT			= 53,		-- uint 地摊格子数量
	ACTOR_ZHAN_HUN_VALUE 			= 54,		-- int 荣誉(战魂)值
	ACTOR_BIND_COIN					= 55,		-- uint 绑定金钱
	ACTOR_COIN						= 56,		-- uint 非绑定金钱
	ACTOR_BIND_GOLD					= 57,		-- uint 绑定元宝
	ACTOR_GOLD						= 58,		-- uint 非绑定元宝
	ACTOR_CHARM_VALUE				= 59,		-- uint 魅力值
	ACTOR_GUILD_ID					= 60,		-- uint 帮派的id
	ACTOR_TEAM_ID					= 61,		-- uint 队伍的ID
	ACTOR_SOCIAL_MASK				= 62,		-- uint 社会关系的mask，是一些bit位
	ACTOR_GUILD_CON					= 63,		-- uint 帮会贡献度
	ACTOR_ACTIVITY					= 64,		-- uint 活跃度
	ACTOR_DEFAULT_SKILL_ID			= 65,		-- uint 默认技能ID
	ACTOR_MAX_EXP_L					= 66,		-- uint 最大经验低位
	ACTOR_MAX_EXP_H					= 67,		-- uint 最大经验高位
	ACTOR_ACHIEVE_VALUE				= 68,		-- int 玩家的成就点
	ACTOR_CURTITLE					= 69,		-- int 称号 1-32
	ACTOR_VIP_EXPIRE_TIME			= 70,		-- uint vip到期时间
	ACTOR_VIP_FLAG					= 71,		-- uint VIP标记
	ACTOR_INNER_EXP					= 72,		-- uint 玩家的内功经验
	ACTOR_DRAW_GOLD_COUNT			= 73,		-- uint 提取元宝数目
	ACTOR_BATTLE_POWER				= 74,		-- uint 玩家的战力
	ACTOR_RUNEESSENCE				= 75,		-- uint 符文精华
	PROP_ACTOR_ONCE_MAX_LEVEL		= 76,		-- uint 角色曾经最高等级
	PROP_ACTOR_CHLLFBCOUNT			= 77,		-- uint bit1-2:勇者闯关的关数【只存一个short,最大关数255】bit3:轮回阶数,最大6 bit4:轮回等级,最大6
	ACTOR_DIERRFRESHCD				= 78,		-- 死亡以后复活的时间间隔（复活戒指）
	ACTOR_DEPORT_GRID_COUNT			= 79,		-- uint 仓库的格子数量（原始大小+购买大小+vip赠送的大小）
	ACTOR_CIRCLE					= 80,		-- uint 人物的转数
	ACTOR_CIRCLE_SOUL				= 81,		-- uint 转生灵魄
	ACTOR_ANGER						= 82,		-- uint 怒气值
	ACTOR_INNER						= 83,		-- uint 内功值
	ACTOR_CURRENT_HEAD_TITLE		= 84,		-- uint 当前选择的头衔（byte0:头衔1[0为没有选择],byte1:头衔2[0为没有选择])
	ACTOR_RIDE_LEVEL				= 85,		-- uint 当前坐骑的等级(改为图鉴经验)
	PROP_ACTOR_EQUIP_POWER			= 86,		-- uint 装备战力
	ACTOR_WARDROBE					= 87,		-- uint 衣橱(byte1-2:时装激活标志；byte3:穿戴的时装；byte4:衣橱等级)
	ACTOR_ACTOR_STOREPOINT			= 88,		-- uint 商城积分
	ACTOR_RIDE_EXPIRED_TIME			= 89,		-- uint 时效坐骑过期时间(改为 低位：注入翅膀魂石(血)数量)
	ACTOR_WORK_DAY_1_L				= 90,		-- uint 副本,活动等第一天没完成的次数
	ACTOR_WORK_DAY_1_H				= 91,		-- uint 副本,活动等第一天没完成的次数
	ACTOR_WORK_DAY_2_L				= 92,		-- uint 副本,活动等第二天没完成的次数
	ACTOR_WORK_DAY_2_H				= 93,		-- uint 副本,活动等第二天没完成的次数
	ACTOR_WORK_DAY_3_L				= 94,		-- uint 副本,活动等第三天没完成的次数
	ACTOR_WORK_DAY_3_H				= 95,		-- uint 副本,活动等第二天没完成的次数
	ACTOR_ACTOR_SIGNIN				= 96,		-- int 每日签到标记
	ACTOR_PROP_ACTOR_DEPOT_GOLD		= 97,		-- uint 仓库元宝
	ACTOR_PROP_ACTOR_DEPOT_COIN		= 98,		-- uint 仓库金币
	ACTOR_AVOIDINJURY_MAX			= 99,		-- uint 最大真气值
	ACTOR_AVOIDINJURY				= 100,		-- uint 当前真气
	ACTOR_ONLINE_TIME				= 101,		-- uint 当天累积在线时间（秒）
	ACTOR_VIP_GRADE					= 102,		-- uint vip等级
	ACTOR_VIP_POINT_L				= 103,		-- uint vip积分高位
	ACTOR_VIP_POINT_H				= 104,		-- uint vip积分低位
	ACTOR_ZS_VIP_L					= 105,		-- uint 砖石会员积分高位
	ACTOR_ZS_VIP_H					= 106,		-- uint 砖石会员积分低位
	ACTOR_MAGIC_EQUIPID				= 107,		-- uint 魔法装备ID
	ACTOR_MAGIC_EQUIPEXP			= 108,		-- uint 魔法装备当前经验
	ACTOR_OFFICE					= 109,		-- uint 官职
	ACTOR_PRESTIGE_VALUE			= 110,		-- uint 总威望值
	ACTOR_CROSS_KILL_DEVIL_TOKEN	= 111,		-- uint 跨服屠魔令
	ACTOR_SWING_LEVEL				= 112,		-- uint 翅膀等级
	ACTOR_SWING_EXP					= 113,		-- uint 翅膀经验
	ACTOR_FLAG						= 114,		-- uint 玩家标志
	ACTOR_SOUL1						= 115,		-- uint 兽魂总级数
	ACTOR_SOUL2						= 116,		-- uint 记录玩家试炼关卡数
	ACTOR_ENERGY					= 117,		-- uint BOSS积分(能量)
	ACTOR_IMMORTAL					= 118,		-- uint 修仙等级
	ACTOR_INNER_LEVEL				= 119,		-- uint 玩家的内功等级
	ACTOR_SPIRIT_VALUE				= 120,		-- uint 战功值
	ACTOR_MERCENA_LEVEL				= 121,		-- uint 雇佣军等级
	ACTOR_MERCENA_EXP				= 122,		-- uint 雇佣军经验
	ACTOR_APOTHEOSIZE_LEVEL			= 123,		-- uint 封神等级
	ACTOR_APOTHEOSIZE_EXP			= 124,		-- uint 封神经验
	ACTOR_TRIPOD_LEVEL				= 125,		-- uint 神鼎等级
	ACTOR_AVOIDINJURY_EXP			= 126,		-- uint 真气经验
	ACTOR_WARPATH_ID				= 127,		-- uint //ushort: 0经脉等级, ushort: 1官职等级
	ACTOR_COLOR_STONE				= 128,		-- uint 七彩石
	ACTOR_DRAGON_SPITIT				= 129,		-- uint 龙魂
	ACTOR_SHIELD_SPIRIT				= 130,		-- uint 神灵精魄
	ACTOR_KILL_DEVIL_TOKEN			= 131,		-- uint 灭魔令
	ACTOR_BRAVE_POINT				= 132,		-- uint 勇者积分
	ACTOR_ALCHEMY					= 133,		-- uint 炼金值
	ACTOR_STONE						= 134,		-- uint 书灵
	ACTOR_RING_CRYSTAL				= 135,		-- uint 试炼关数
	ACTOR_RED_DIAMONDS				= 136,		-- uint 红钻
	ACTOR_CUTTING_LEVEL				= 137,		-- uint: ushort: 0切割等级, ushort: 1(钻石会员等级)
	ACTOR_HONER						= 138,		-- uint 荣誉值
	ACTOR_GATHER_VALUE				= 139,		-- uint 采集力量
	ACTOR_KILL_COMBO_VALUE			= 140,		-- uint 连击的次数
	ACTOR_MOUNT_TYPE				= 141,		-- int 坐骑类型
	ACTOR_CAMP						= 142,		-- int 阵营
	ACTOR_HEAD_TITLE				= 143,		-- uint 人物头衔 33-64
	ACTOR_MAX_INNER					= 144,		-- uint 玩家最大内功值
	ACTOR_DIAMOND_POINT				= 145,		-- uint 魂石评分
	ACTOR_HERO_DIAMOND_POINT		= 146,		-- uint 英雄评分
	ACTOR_GM_LEVEL				= 147,		-- uint gm等级
	ACTOR_MAGIC_APPEARANCE			= 148,		-- uint 法宝外观
	ACTOR_FOOT_APPEARANCE			= 149,		-- uint 足迹斗笠外观 (byte0:足迹外观, byte1:足迹特效; byte2:斗笠外观, byte3:斗笠特效)
	ACTOR_RIDE_PETID				= 150,		-- uint 出战坐骑的ID
	ACTOR_RESISTANCECRITRATE 		= 151,		-- uint 抗暴比
	ACTOR_BOSSCRITRATE 				= 152,		-- uint 对BOSS暴击率
	ACTOR_BATTACKBOSSCRITVALUE 		= 153,		-- uint 对BOSS暴击力
	ACTOR_DAMAGE_UP 				= 154,		-- uint 伤害加成
	ACTOR_ABSORBHPRATE 				= 155,		-- uint 吸血机率
	ACTOR_ABOSRBHP 					= 156, 		-- uint 吸血值
	ACTOR_FLAMINTAPPEARANCEID 		= 157, 		-- uint 烈焰神力技能外观 
	ACTOR_ESCORT_FLAG 				= 158, 		-- uint 保驾护航称号标记 1:表示显示 0:不显示
	ACTOR_WINGEQUIP_APPEARANCE		= 159,		-- uint 翅膀装备幻化外观
	ACTOR_THANOSGLOVE_APPEARANCE 	= 160,		-- uint 灭霸手套外观
	ACTOR_DIAMONDSPETS_APPEARANCE 	= 161,		-- uint 钻石萌宠外观
	ACTOR_GENUINEQI_APPEARANCE		= 162,		-- uint 真气外观
	MAX								= 163,
	
	-- 特殊属性 不常用
	-- 对XX伤害增加比率（万分比) (0:所有 1：战 2 法 3道 4性物 5:boss)
	ACTOR_WARRIOR_DAMAGE_ADD 		= 1003,
	ACTOR_MAGICIAN_DAMAGE_ADD		= 1004,
	ACTOR_WIZARD_DAMAGE_ADD			= 1005,
	ACTOR_MONESTER_DAMAGE_ADD		= 1006,
	ACTOR_BOSS_DAMAGE_ADD			= 1007,
	
	-- 受XX伤害减少比率（万分比) (0:所有 1：战 2 法 3道 4性物 5:boss)
	ACTOR_WARRIOR_DAMAGE_DEC		= 1008,		
	ACTOR_MAGICIAN_DAMAGE_DEC		= 1009,		
	ACTOR_WIZARD_DAMAGE_DEC			= 1010,	
	ACTOR_MONESTER_DAMAGE_DEC		= 1011,
	ACTOR_BOSS_DAMAGE_DEC			= 1012,

	ACTOR_HP_PER					= 1050,	-- 弃用

	ACTOR_INNER_REDUCE_DAMAGE_ADD	= 1051, -- 内功免伤
	ACTOR_INNER_RENEW_ADD			= 1052, -- 内功恢复
	ACTOR_ARM_POWER_ADD				= 1053, -- 内功穿透
	ACTOR_DIZZY_RATE_ADD				= 1055, -- 麻痹
	ACTOR_DEF_DIZZY_RATE				= 1056, -- 防麻痹
	ACTOR_HP_DAMAGE_2_MP_DROP_RATE_ADD = 1057, -- 护身(万分比)
	ACTOR_BAG_MAX_WEIGHT_ADD			= 1058, -- 破护身
	ACTOR_DIE_REFRESH_HP_PRO			= 1059, -- 复活
	ACTOR_BROKEN_RELIVE_RATE			= 1060, -- 破复活
	ACTOR_EQUIP_MAX_WEIGHT_ADD		 = 1061, -- 抗破
	ACTOR_EQUIP_MAX_WEIGHT_POWER		= 1062, -- 抗破击
	ACTOR_RESISTANCE_CRIT_RATE		 = 1063, -- 抗暴率

	ACTOR_MOUNT_MIN_ATTACK_RATE				= 1064, -- 神圣一击几率	
	ACTOR_MOUNT_MIN_ATTACK_VALUE			= 1065, -- 神圣一击伤害
	ACTOR_FATAL_HIT_RATE					= 1066, -- 致命一击几率	
	ACTOR_FATAL_HIT_VALUE					= 1067, -- 致命一击伤害	
	ACTOR_PK_DAMAGE							= 1068, -- pk攻击
	ACTOR_REDUCE_PK_DAMAGE					= 1069, -- 抵消pk攻击伤害	
	ACTOR_MOUNT_MIN_PHY_DEFENCE_RATE_RATE	= 1070, -- 降低神圣一击几率	
	ACTOR_MOUNT_MIN_PHY_DEFENCE_RATE_VALUE	= 1071, -- 降低神圣一击伤害		
	ACTOR_REDUCE_FATAL_HIT_RATE 			= 1072, -- 降低致命一击几率	
	ACTOR_REFLECT_RATE 						= 1073, -- 降低致命一击伤害	
	ACTOR_MOUNT_HP_RATE_ADD 				= 1074, -- 物理穿透	
	ACTOR_REDUCE_BAOJI						= 1075, -- 暴击减伤
	ACTOR_REDUCE_BAOJI_REAT					= 1076, --韧性	
	ACTOR_1077								= 1077, --内功攻击 整数
	ACTOR_1078								= 1078, --切割伤害倍率增加(浮点数)百分比, 下发时先*100转为int, 前端要除100转回float
	ACTOR_1079								= 1079, --切割伤害(BOSS伤害)
	ACTOR_1080								= 1080, --物理免伤
	ACTOR_1081								= 1081, --物防穿透
	ACTOR_1082								= 1082, --减少伤害加成比(万分比)
	ACTOR_1083								= 1083, --反击伤害（万分比）
	ACTOR_1084								= 1084, --技能攻击的时候 攻击伤害追加n点
}

OBJ_ATTR_TYPE = {
	NORAML = 0,		-- 普通数值
	RATE = 1,		-- 几率数值
}

-- 对象数据格式信息 type数据类型，val_rate真实数据的比例
OBJ_ATTR_FORMAT = {
	[OBJ_ATTR.ACTOR_CRITRATE]		 			 			 = {type = OBJ_ATTR_TYPE.RATE, val_rate = 0.0001},
	[OBJ_ATTR.ACTOR_RESISTANCECRIT] 						 = {type = OBJ_ATTR_TYPE.NORAML, val_rate = 1},
	[OBJ_ATTR.ACTOR_MOUNT_MIN_ATTACK_RATE]					 = {type = OBJ_ATTR_TYPE.RATE, val_rate = 0.0001},
	[OBJ_ATTR.ACTOR_MOUNT_MIN_ATTACK_VALUE]					 = {type = OBJ_ATTR_TYPE.NORAML, val_rate = 1},
	[OBJ_ATTR.ACTOR_FATAL_HIT_RATE]							 = {type = OBJ_ATTR_TYPE.RATE, val_rate = 0.0001},
	[OBJ_ATTR.ACTOR_FATAL_HIT_VALUE]						 = {type = OBJ_ATTR_TYPE.NORAML, val_rate = 1},
	[OBJ_ATTR.ACTOR_ABSORBHPRATE]				 			 = {type = OBJ_ATTR_TYPE.RATE, val_rate = 0.0001},
	[OBJ_ATTR.ACTOR_ABOSRBHP]					 			 = {type = OBJ_ATTR_TYPE.NORAML, val_rate = 1},
	[OBJ_ATTR.ACTOR_BOSSCRITRATE]							 = {type = OBJ_ATTR_TYPE.RATE, val_rate = 0.0001},
	[OBJ_ATTR.ACTOR_BATTACKBOSSCRITVALUE]					 = {type = OBJ_ATTR_TYPE.NORAML, val_rate = 1},
	[OBJ_ATTR.ACTOR_PK_DAMAGE]					 			 = {type = OBJ_ATTR_TYPE.RATE, val_rate = 0.0001},
	[OBJ_ATTR.ACTOR_REDUCE_PK_DAMAGE] 						 = {type = OBJ_ATTR_TYPE.RATE, val_rate = 0.0001},
	[OBJ_ATTR.ACTOR_REDUCE_BAOJI_REAT]						 = {type = OBJ_ATTR_TYPE.RATE, val_rate = 0.0001},
	[OBJ_ATTR.ACTOR_REDUCE_BAOJI]							 = {type = OBJ_ATTR_TYPE.NORAML, val_rate = 1},
	[OBJ_ATTR.ACTOR_MOUNT_MIN_PHY_DEFENCE_RATE_RATE]		 = {type = OBJ_ATTR_TYPE.RATE, val_rate = 0.0001},
	[OBJ_ATTR.ACTOR_MOUNT_MIN_PHY_DEFENCE_RATE_VALUE]		 = {type = OBJ_ATTR_TYPE.NORAML, val_rate = 1},
	[OBJ_ATTR.ACTOR_REDUCE_FATAL_HIT_RATE]					 = {type = OBJ_ATTR_TYPE.RATE, val_rate = 0.0001},
	[OBJ_ATTR.ACTOR_REFLECT_RATE]		 					 = {type = OBJ_ATTR_TYPE.NORAML, val_rate = 1},
	[OBJ_ATTR.ACTOR_MOUNT_HP_RATE_ADD]						 = {type = OBJ_ATTR_TYPE.NORAML, val_rate = 1},
	[OBJ_ATTR.ACTOR_INNER_REDUCE_DAMAGE_ADD]				 = {type = OBJ_ATTR_TYPE.NORAML, val_rate = 1},
	[OBJ_ATTR.ACTOR_1077]									 = {type = OBJ_ATTR_TYPE.NORAML, val_rate = 1},
	[OBJ_ATTR.ACTOR_1078]									 = {type = OBJ_ATTR_TYPE.RATE, val_rate = 0.0001},
	[OBJ_ATTR.ACTOR_1079]									 = {type = OBJ_ATTR_TYPE.NORAML, val_rate = 1},
	[OBJ_ATTR.ACTOR_1080]									 = {type = OBJ_ATTR_TYPE.RATE, val_rate = 0.0001},
	[OBJ_ATTR.ACTOR_1081]									 = {type = OBJ_ATTR_TYPE.NORAML, val_rate = 1},
	[OBJ_ATTR.ACTOR_1082]									 = {type = OBJ_ATTR_TYPE.RATE, val_rate = 0.0001},
	[OBJ_ATTR.ACTOR_1083]									 = {type = OBJ_ATTR_TYPE.RATE, val_rate = 0.0001},
	[OBJ_ATTR.ACTOR_1084]									 = {type = OBJ_ATTR_TYPE.NORAML, val_rate = 1},
}

-- 内力攻击	151	1点等于1	
-- 切割几率	143	10000点等于100%	
-- 切割伤害	144	1点等于1	
-- 物攻免伤	100	10000点等于100%	
-- 物防穿透	102	1点等于1	
-- 伤害加成减少	244	10000点等于100%	
-- 伤害反弹增加	186	10000点等于100%	
-- 技能伤害追加	68	1点等于1	


-- 玩家身上的社会关系的bit位定义
SOCIAL_MASK_DEF = {
	GUILD_COMMON = 0,					-- 帮会普通成员
	GUILD_TANGZHU_FIR = 1,			-- 青龙堂主
	GUILD_TANGZHU_SRC = 2,				-- 朱雀堂主
	GUILD_TANGZHU_THI = 3,				-- 白虎堂主
	GUILD_TANGZHU_FOU = 4,				-- 玄武堂主
	GUILD_ASSIST_LEADER = 5, 			-- 副帮主
	GUILD_LEADER= 6,	 				-- 帮主
	TEAM_MEMBER = 7,	 				-- 是队伍的普通成员
	TEAM_CAPTIN = 8,	 				-- 是队长	
	STORE_BROADCAST_CLOSE = 9, 			-- 是否关闭，0表示开启的，1表示关闭的
	HIDE_FATION_CLOTH = 10,				-- 是否隐藏时装，1表示隐藏时装
	DARW_ACTIVITY_AWARD = 11, 			-- 活跃度是否领取奖励
	IS_WULIN_MASTER = 12,	 			-- 是武林盟主，0表示不是，1表示是
	HIDE_HEAD_MSG = 13,					-- 是否隐藏头顶的信息，1表示隐藏头顶信息（包括名字，头衔，称号，帮派等），0表示不限制
	SHOW_RED_WEAPON_EFFECT = 14,		-- 是否显示神器的特效，1表示显示，0表示不显示
	IS_IN_COMMON_SERVER = 15,	 		-- 是否在跨服的场景，1表示是，0表示否
	SAVE_GAME_ADDRESS = 16,				-- 是否保存了游戏网页
	FLUSH_STAR_TO_LV = 17,				-- 刷星到指定星级
	STAR_USE_GOLD = 18,					-- 刷星余额用元宝补充
	IS_SBK_CITY_MASTER = 19,			-- 是否是沙巴克城主, 0 表示不是，1表示是
	GM_FLAG = 20,						-- GM标记
	HIDE_WEAPON_EXTEND = 21,			-- 是否隐藏幻武外观，1表示隐藏
	IS_FAMOUS = 22,						-- 是否是名人堂会员
	IS_AFK_STATUS = 23,					-- 是否挂机状态
	IS_HAS_PET = 24,					-- 是否拥有宝宝(道士宝宝不计算)
	WARDROBE_HIDE_DRESS = 25,			-- 是否隐藏时装外观，1表示隐藏
	PEERLESS_WEAPON_HIDE = 26,			-- 是否隐藏绝世武器外观，1表示隐藏(没用了)
	PEERLESS_DRESS_HIDE = 27,			-- 是否隐藏绝世衣服外观，1表示隐藏(没用了)
}

EntityState =
{
	StateStand = 0 , 					--静止状态
	StateMove = 1,						--行走状态或者跳跃状态
	StateRide = 2,						--骑马状态
	StateZanzen = 3, 					--打坐状态
	StateStall = 4,					--摆摊状态
	StateSing = 5,						--吟唱状态
	StateBattle = 6, 					--战斗状态
	StateDeath = 7,					--死亡状态
	StateMoveForbid = 8,				--禁止移动状态,buff设置的
	StateDizzy = 9,	 				--晕眩状态
	StateAutoBattle = 10, 				--挂机状态
	StateReturnHome = 11, 				--回归状态(用于怪物)
	DisableSkillCD = 12,				--禁用技能CD标志（开发和测试用）
	Challenge = 13,						--擂台状态
	StateVehicle = 14,					--是否在交通工具上
	StateDoubleZanzen = 15,				--是否双修
	StateInMonsterState = 16,			--变身状态
	StateSwim = 17,					--游泳状态
	StateKiss = 18,						--接吻状态
	PaTaFubenBattle = 19,				--爬塔副本中
	KissInLand = 20,					--陆地接吻状态
	StateInCorpsBattle = 21,			--拥有球的状态（战队竞技活动需要用到）
	StateCarrier = 22,					--载体状态
	StatePassengger = 23,				--乘客状态
	StateDongFang = 24,					--洞房状态,就是睡觉
	StateOwnPet = 25,					--拥有宠物状态
	StateHeroMerge = 26,				--英雄附体状态
	StateGM = 27,						--GM状态
	StateWingTail = 28,					--翅膀残影
	StateShield = 29,					--护体状态
	StateHide = 30,						--隐身状态
	StateRideBattle = 31, 				--坐骑出战状态

	MaxStateCount = 32, 				--状态的数量
}

ATTR_READ_TYPE = {
	[OBJ_ATTR.ENTITY_X] = READ_TYPE.INT,
	[OBJ_ATTR.ENTITY_Y] = READ_TYPE.INT,
	[OBJ_ATTR.ENTITY_MODEL_ID] = READ_TYPE.INT,
	[OBJ_ATTR.ENTITY_DIR] = READ_TYPE.INT,
	[OBJ_ATTR.CREATURE_PHYSICAL_ATTACK_MIN] = READ_TYPE.INT,
	[OBJ_ATTR.CREATURE_PHYSICAL_ATTACK_MAX] = READ_TYPE.INT,
	[OBJ_ATTR.CREATURE_MAGIC_ATTACK_MIN] = READ_TYPE.INT,
	[OBJ_ATTR.CREATURE_MAGIC_ATTACK_MAX] = READ_TYPE.INT,
	[OBJ_ATTR.CREATURE_WIZARD_ATTACK_MIN] = READ_TYPE.INT,
	[OBJ_ATTR.CREATURE_WIZARD_ATTACK_MAX] = READ_TYPE.INT,
	[OBJ_ATTR.CREATURE_PHYSICAL_DEFENCE_MIN] = READ_TYPE.INT,
	[OBJ_ATTR.CREATURE_PHYSICAL_DEFENCE_MAX] = READ_TYPE.INT,
	[OBJ_ATTR.CREATURE_MAGIC_DEFENCE_MIN] = READ_TYPE.INT,
	[OBJ_ATTR.CREATURE_MAGIC_DEFENCE_MAX] = READ_TYPE.INT,
	[OBJ_ATTR.CREATURE_HIT_RATE] = READ_TYPE.INT,
	[OBJ_ATTR.CREATURE_DOGE_RATE] = READ_TYPE.INT,
	[OBJ_ATTR.CREATURE_LUCK] = READ_TYPE.INT,
	[OBJ_ATTR.CREATURE_CURSE] = READ_TYPE.INT,
	[OBJ_ATTR.ACTOR_BAG_WEIGHT] = READ_TYPE.INT,
	[OBJ_ATTR.ACTOR_BAG_MAX_WEIGHT] = READ_TYPE.INT,
	[OBJ_ATTR.ACTOR_EQUIP_WEIGHT] = READ_TYPE.INT,
	[OBJ_ATTR.ACTOR_EQUIP_MAX_WEIGHT] = READ_TYPE.INT,
	[OBJ_ATTR.ACTOR_WEAPON_WEIGHT] = READ_TYPE.INT,
	[OBJ_ATTR.ACTOR_ARMPOWER] = READ_TYPE.INT,
	[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE] = READ_TYPE.INT,
	[OBJ_ATTR.ACTOR_MOUNT_APPEARANCE] = READ_TYPE.INT,
	[OBJ_ATTR.ACTOR_WING_APPEARANCE] = READ_TYPE.INT,
	[OBJ_ATTR.ACTOR_PK_VALUE] = READ_TYPE.INT,
	[OBJ_ATTR.ACTOR_ZHAN_HUN_VALUE] = READ_TYPE.INT,
	[OBJ_ATTR.ACTOR_ACHIEVE_VALUE] = READ_TYPE.INT,
	[OBJ_ATTR.ACTOR_CURTITLE] = READ_TYPE.INT,
	[OBJ_ATTR.ACTOR_ACTOR_SIGNIN] = READ_TYPE.INT,
	[OBJ_ATTR.ACTOR_MOUNT_TYPE] = READ_TYPE.INT,
	[OBJ_ATTR.ACTOR_CAMP] = READ_TYPE.INT,
	[OBJ_ATTR.ACTOR_COLOR_STONE] = READ_TYPE.INT,
	[OBJ_ATTR.ACTOR_DRAGON_SPITIT] = READ_TYPE.INT,
	[OBJ_ATTR.CREATURE_MAGIC_HIT_RATE] = READ_TYPE.FLOAT,
	[OBJ_ATTR.CREATURE_MAGIC_DOGERATE] = READ_TYPE.FLOAT,
	[OBJ_ATTR.CREATURE_TOXIC_DOGERATE] = READ_TYPE.FLOAT,
	[OBJ_ATTR.CREATURE_HP_RENEW] = READ_TYPE.FLOAT,
	[OBJ_ATTR.CREATURE_MP_RENEW] = READ_TYPE.FLOAT,
	[OBJ_ATTR.CREATURE_TOXIC_RENEW] = READ_TYPE.FLOAT,
}

function GetAttrReadType(index)
	return ATTR_READ_TYPE[index] or READ_TYPE.UINT
end
