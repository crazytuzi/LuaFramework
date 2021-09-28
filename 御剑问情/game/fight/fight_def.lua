

-- 技能类型
SKILL_TYPE = {
	PROF = 1,										-- 职业技能
	COMMON = 2,										-- 普通攻击
}

-- 技能特效类型
SKILL_EFFECT_TYPE = {
	TARGET = 1,										-- 目标位置播放
	TRACE = 2,										-- 追踪目标
	INTERVAL = 3,									-- 等间隔
	SELF = 4,										-- 自身位置播放
	SYNC_TARGET = 5,								-- 同步跟随目标
	TRACE_FROM_PERI = 6, 							-- 跟踪目标（从仙女处开始）
	TARGET_IN_PERI = 7,								-- 目标位置播放(在仙女位置)
	SYNC_SELF = 8,									-- 同步跟随自己
}

FIGHT_TYPE = {
	SHANBI = 0,										-- 闪避
	NORMAL = 1,										-- 正常攻击
	DIDANG = 2,										-- 抵挡
	BAOJI = 3,										-- 暴击
	MIANYI = 4,										-- 免疫
	DIKANG = 5,										-- 抵抗
	POJI = 6,										-- 破击
	BAOPO = 7,										-- 破击加暴击
	YAZHI = 8,										-- 龙行天下头衔等级压制
	HUIXINYIJI = 9,									-- 会心一击
	LINGCHONG = 10,									-- 灵宠攻击
}

BUFF_TYPE = {
	XUANYUN = 1,									-- 眩晕
	DINGSHEN = 2,									-- 定身
	CHENMO = 3,										-- 沉默
	CHIHUAN = 4,									-- 迟缓
	EBT_MIANYI_XUANYUN = 5,							-- 免疫眩晕
	EBT_MIANYI_DINGSHEN = 6,						-- 免疫定身
	EBT_MIANYI_CHENMO = 7,							-- 免疫沉默
	EBT_MIANYI_CHIHUAN = 8,							-- 免疫迟缓
	WUDI = 9,										-- 无敌
	JIASU = 10,										-- 加速
	INVISIBLE = 11,									-- 隐身
	NUQI_BAOFA = 12,								-- 怒气暴发
	EBT_FIER = 13,									-- 火

	EBT_REDUCE_GONGJI = 14,							-- 降低攻击
	EBT_REDUCE_FANGYU = 15,							-- 降低防御

	XIANNV_ADD_GONGJI_BUFF = 16,					-- 增加攻击(女神)

	XIANNV_ADD_FANGYU_BUFF = 18,					-- 增加防御(女神)
	XIANNV_ADD_BAOJI_BUFF = 19,						-- 增加暴击(女神)
	EBT_WING_FENGDUN = 20,							-- 羽翼风盾技能特效
	EBT_WING_JIEJIE = 21,							-- 羽翼结界技能特效
	EBT_WING_SHOUHU = 22,							-- 羽翼守护技能特效
	EBT_SHENYI_JIUSHU = 23,							-- 神翼技能救赎
	EBT_SHENYI_SHENPAN = 24,						-- 神翼技能审判
	EBT_SHENGGONG_ZHUMO = 25,						-- 神弓技能诛魔
	EBT_REBOUNDHURT = 26, 							-- 反伤BUFF
	EBT_ADD_FANGYU = 27, 							-- 增加防御
	EBT_GATHER_NOT_STOP = 29,						-- 采集不打断

	SUPER_MIANYI = 40,								-- 免疫定身，眩晕，沉默，击退
	HPSTORE = 41,									-- 护盾
	WUDI_PROTECT = 42,								-- 无敌保护
	BIAN_XING = 43,									-- 变形 可攻击
	BIANXING_FOOL = 44,								-- 变形 不可攻击
	EBT_DEC_FANGYU = 45,							-- 减少防御
	EBT_DEC_SHANGHAI = 46,							-- 减少伤害
	EBT_BE_HURT_ADD = 47,							-- 受到伤害加深
	EBT_MOJIESTORE = 48,							-- 魔戒护盾
	EBT_TERRITORYWAR_TOWER_WUDI = 49,				-- 领土战防御塔无敌
	EBT_DROP_BLOOD = 50,							-- 流血
	EBT_ADD_BLOOD = 51,								-- 加血
	EBT_BIND_DONG = 52,								-- 冰冻
	EBT_DEADLY_ATTACK = 53,							-- 致命一击
	EBT_MOHUA = 54,									-- 形象赋灵-魔化
	EBT_ADD_ATTACK = 55,							-- 增加攻击

	SKILL144 = 144,
	UP_LEVEL = 10001,
	EBT_HOU = 10002,
	EBT_HUANG = 10003,
	EBT_LV = 10004,
	EBT_LAN = 10005,
}

MIX_BUFF_LIST = {
	[BUFF_TYPE.CHIHUAN] = 1,
	[BUFF_TYPE.JIASU] = 1,
	[BUFF_TYPE.WUDI] = 1,
	[BUFF_TYPE.EBT_ADD_FANGYU] = 1,
	[BUFF_TYPE.UP_LEVEL] = 1,
	[BUFF_TYPE.EBT_DEC_FANGYU] = 1,
	[BUFF_TYPE.EBT_ADD_ATTACK] = 1,
	[BUFF_TYPE.EBT_REDUCE_GONGJI] = 1,
}

--放在DrawPart层的特效
DRAW_PART_LAYER_BUFF_LIST = {
	[BUFF_TYPE.HPSTORE] = 1,
	[BUFF_TYPE.EBT_REBOUNDHURT] = 1,
	[BUFF_TYPE.EBT_DEC_SHANGHAI] = 1,
}

-- buff显示位置
BUFF_CHARACTER = {
	ROLE = 1,										-- 人物
	GODDESS = 2,									-- 女神
}

-- 挂点 see scene_config.lua
BUFF_CONFIG = {
	[BUFF_TYPE.XUANYUN] = {attach_index = 0, effect_id = 10001, buff_character = BUFF_CHARACTER.ROLE, is_noraml_effect = 1},
	-- [BUFF_TYPE.CHENMO] = {attach_index = 5, effect_id = 10003, buff_character = BUFF_CHARACTER.ROLE, is_noraml_effect = 1},
	[BUFF_TYPE.CHIHUAN] = {attach_index = 3, effect_id = "BUff_X_02", buff_character = BUFF_CHARACTER.ROLE, is_noraml_effect = 1},
	[BUFF_TYPE.JIASU] = {attach_index = 3, effect_id = "BUff_X_01", buff_character = BUFF_CHARACTER.ROLE, is_noraml_effect = 1},
	[BUFF_TYPE.XIANNV_ADD_GONGJI_BUFF] = {attach_index = 7, effect_id = 10016, buff_character = BUFF_CHARACTER.GODDESS, is_noraml_effect = 1},
	[BUFF_TYPE.XIANNV_ADD_FANGYU_BUFF] = {attach_index = 0, effect_id = 10018, buff_character = BUFF_CHARACTER.GODDESS, is_noraml_effect = 1},
	[BUFF_TYPE.XIANNV_ADD_BAOJI_BUFF] = {attach_index = 0, effect_id = 10019, buff_character = BUFF_CHARACTER.GODDESS, is_noraml_effect = 1},
	[BUFF_TYPE.HPSTORE] = {attach_index = 5, effect_id = 10042, buff_character = BUFF_CHARACTER.ROLE, is_noraml_effect = 1},
	[BUFF_TYPE.EBT_DEC_SHANGHAI] = {attach_index = 5, effect_id = 10042, buff_character = BUFF_CHARACTER.ROLE, is_noraml_effect = 1},
	[BUFF_TYPE.UP_LEVEL] = {attach_index = 5, effect_id = "SJEffect", buff_character = BUFF_CHARACTER.ROLE, is_noraml_effect = 1},
	-- [BUFF_TYPE.DINGSHEN] = {attach_index = 3, effect_id = "JG_01", buff_character = BUFF_CHARACTER.ROLE, is_noraml_effect = 1},
	[BUFF_TYPE.EBT_MOJIESTORE] = {attach_index = 5, effect_id = 10042, buff_character = BUFF_CHARACTER.ROLE, is_noraml_effect = 1},
	[BUFF_TYPE.EBT_TERRITORYWAR_TOWER_WUDI] = {attach_index = 3, effect_id = "ta_wudi", buff_character = BUFF_CHARACTER.ROLE, is_noraml_effect = 1},
	[BUFF_TYPE.WUDI] = {attach_index = 4, effect_id = "Effect_wudi", buff_character = BUFF_CHARACTER.ROLE, is_noraml_effect = 1},
	[BUFF_TYPE.EBT_ADD_BLOOD] = {attach_index = 4, effect_id = "BUF_huixie", buff_character = BUFF_CHARACTER.ROLE, is_noraml_effect = 1},
	[BUFF_TYPE.EBT_DEADLY_ATTACK] = {attach_index = 4, effect_id = "Buff_zhimingyiji", buff_character = BUFF_CHARACTER.ROLE, is_noraml_effect = 1},
	[BUFF_TYPE.EBT_BIND_DONG] = {attach_index = 5, effect_id = "14002_bing", buff_character = BUFF_CHARACTER.ROLE, is_noraml_effect = 0},
	[BUFF_TYPE.EBT_REBOUNDHURT] = {attach_index = 2, effect_id = "10042", buff_character = BUFF_CHARACTER.ROLE, is_noraml_effect = 1},
	[BUFF_TYPE.EBT_DEC_FANGYU] = {attach_index = 3, effect_id = "BUff_T_02", buff_character = BUFF_CHARACTER.ROLE, is_noraml_effect = 1},
	[BUFF_TYPE.EBT_ADD_FANGYU] = {attach_index = 3, effect_id = "BUff_T_01", buff_character = BUFF_CHARACTER.ROLE, is_noraml_effect = 1},
	[BUFF_TYPE.EBT_ADD_ATTACK] = {attach_index = 3, effect_id = "BUff_J_01", buff_character = BUFF_CHARACTER.ROLE, is_noraml_effect = 1},
	[BUFF_TYPE.EBT_REDUCE_GONGJI] = {attach_index = 3, effect_id = "BUff_J_02", buff_character = BUFF_CHARACTER.ROLE, is_noraml_effect = 1},
	[BUFF_TYPE.EBT_HOU] = {attach_index = 5, effect_id = "BUFF_JS_hou", buff_character = BUFF_CHARACTER.ROLE, is_noraml_effect = 1},
	[BUFF_TYPE.EBT_LAN] = {attach_index = 5, effect_id = "BUFF_JS_lan", buff_character = BUFF_CHARACTER.ROLE, is_noraml_effect = 1},
	[BUFF_TYPE.EBT_LV] = {attach_index = 5, effect_id = "BUFF_JS_L", buff_character = BUFF_CHARACTER.ROLE, is_noraml_effect = 1},
	[BUFF_TYPE.EBT_HUANG] = {attach_index = 5, effect_id = "BUFF_JS_huang", buff_character = BUFF_CHARACTER.ROLE, is_noraml_effect = 1},
	-- EBT_LIUXUE,											// 流血 new for 3d
	-- EBT_HURT_DEC,										// 伤害减免 new for 3d
	-- EBT_HURT_INTERVAL,									// 延迟伤害 new for 3d
}

PRODUCT_METHOD = {
	SKILL = 0,										-- 技能释放
	SCENE_SKILL = 1,								-- 场景skill
	SYSTEM = 2,										-- 系统 用于BOSS加无敌状态等
	TRIGGER = 3,									-- 触发器
	FRIEND = 4,										-- 好友
	HUSONG = 5,										-- 护送
	REBOUNDHURT = 6,								-- 伤害反弹
	FAZHEN_HALO = 7,								-- 法阵和光环
	SHENSHI = 8,									-- 运送神石

	CROSS_XIULUO_TOWER_DUR_DEAD = 9,				-- 跨服修罗塔连败
	CROSS_XIULUO_TOWER_BUY_BUFF = 10,				-- 跨服修罗塔Buff
	CROSS_1V1 = 11,									-- 跨服1V1
	NAME_COLOR = 12,								-- 红名
	GUILD_HALL = 13,								-- 仙盟建筑
	ITEM = 14,										-- 物品
	GONGCHENGZHAN = 15,								-- 攻城战
	SKILL_READDING = 16,							-- 技能读条释放
}

PRODUCT_ID = {
	GATHER_SPEED = 10000,							-- 采集速度上升
	GATHER_NOT_STOP = 10001,						-- 采集不打断
	TO_BUILDINF_INC_HURT = 10002,					-- 对建筑物提升伤害
	HP_CONTINUE = 10003,							-- 气血持续回复
	MP_CONTINUE = 10004,							-- mp持续回复
	INC_PUTON_LEVEL = 10005,						-- 增加穿戴等级
	INC_EXTRAL_EXP_PER = 10006,						-- 经验额外加成百分比

	ID_BASE_ATTR_BEGIN = 10100,
	BASE_ATTR_ADD_JINGZHUN = 10101,					-- 增加精准固定值
	BASE_ATTR_ADD_BAOJI = 10102,					-- 增加暴击固定值
	BASE_ATTR_END = 10103,
}

FIGHT_EFFECT_TYPE = {
	ATTRBUFF = 0,									-- 修改属性类，可同时最多改3种
	SPECIAL_STATE = 1,								-- 控制类，4职业晕，定身，沉默，各种免疫，暴走，无敌等
	INTERVAL_HP = 2,								-- 定时改HP
	COUNTER = 3,									-- 计数器
	INC_HURT = 4,									-- 伤害加深
	DEC_HURT = 5,									-- 伤害减弱
	DOUBLE_HURT = 6,								-- 二次伤害
	MOVESPEED = 7,									-- 速度类，加或减
	HPSTORE = 8,									-- 护盾
	BOMB = 9,										-- 炸弹
	WUDI_PROTECT = 10,								-- 无敌保护	受到的所有伤害都为1
	MODIFY_GLOBAL_CD = 11,							-- 修改全局CD
	REBOUND_HURT = 12,								-- 伤害反弹
	RECOVER_ON_ATKED = 13,							-- 被击回血
	GRADUAL_HURT = 14,								-- 渐增伤害
	JUHUAPIG = 15,									-- 菊花猪
	INVISIBLE = 16,									-- 隐身
	ATTR_RAND_INC_HURT = 17,						-- 加属性并随机伤害加深
	BIANSHEN = 18,									-- 变身
	MP_NO_COST = 19,								-- 内力零消耗
	SHENBING = 20,									-- 神兵
	ABSORB_HP = 21,									-- 吸血
	ATTR_PER = 22,									-- 修改属性百分比
	OTHER = 23,										-- 其他
}

-- buff资源放大倍数
BUFF_RES_SCALE = {
	[BUFF_TYPE.WUDI] = 1.5,
}

EFFECT_CLIENT_TYPE = {
	ECT_SKILL_BJ = 1001,							-- 刺客暴击
	ECT_SKILL_HD = 1002,							-- 法师盾
	ECT_SKILL_CM = 1003,							-- 琴师沉默
	ECT_SKILL_CF = 1004,							-- 战士嘲讽
	ECT_SKILL_GH = 1005,							-- 琴师光环

	ECT_SKILL_LIUXUE = 1006,						-- 流血
	ECT_SKILL_DINGSHEN = 1007,						-- 定身
	ECT_SKILL_JIANSHAGN = 1008,						-- 减伤
	ECT_SKILL_FANTAN = 1009,						-- 伤害反弹
	ECT_SKILL_REBOUNDHURT = 1012,					-- 女神反伤BUFF

	ECT_JL_SKILL_CJJS = 1101,						-- 精灵-采集加速
	ECT_JL_SKILL_CJKDD = 1102,						-- 精灵-采集抗打断
	ECT_JL_SKILL_JF = 1103,							-- 精灵-减防
	ECT_JL_SKILL_JG = 1104,							-- 精灵-减攻
	ECT_JL_SKILL_JSHAN = 1105,						-- 精灵-减伤
	ECT_JL_SKILL_JSHU = 1106,						-- 精灵-减速
	ECT_JL_SKILL_JZGS= 1107,						-- 精灵-建筑高伤
	ECT_JL_SKILL_WD = 1108,							-- 精灵-无敌
	ECT_JL_SKILL_XY = 1109,							-- 精灵-眩晕

	ECT_ITEM_HP1 = 2001,							-- 药水-回血药1
	ECT_ITEM_HP2 = 2002,							-- 药水-回血药2
	ECT_ITEM_HP3 = 2003,							-- 药水-回血药3
	ECT_ITEM_HP4 = 2004,							-- 药水-回血药4

	ECT_ITEM_MP1 = 2101,							-- 药水-回蓝药1
	ECT_ITEM_MP2 = 2102,							-- 药水-回蓝药2
	ECT_ITEM_MP3 = 2103,							-- 药水-回蓝药3
	ECT_ITEM_MP4 = 2104,							-- 药水-回蓝药4

	ECT_ITEM_EXP1 = 2201,							-- 药水-经验加成1
	ECT_ITEM_EXP2 = 2202,							-- 药水-经验加成2
	ECT_ITEM_EXP3 = 2203,							-- 药水-经验加成3
	ECT_ITEM_BJ = 2211,								-- 药水-会心一击
	ECT_ITEM_JZ = 2221,								-- 药水-加精准
	ECT_ITEM_YJ1 = 2231,							-- 药水-越级1
	ECT_ITEM_YJ2 = 2232,							-- 药水-越级2

	ECT_GUILD_BUFF1 = 3001,							-- 仙盟-建筑buff1
	ECT_GUILD_BUFF2 = 3002,							-- 仙盟-建筑buff2
	ECT_GUILD_BUFF3 = 3003,							-- 仙盟-建筑buff3
	ECT_GUILD_BUFF4 = 3004,							-- 仙盟-建筑buff4

	ECT_SZ_PROTECT = 3010,							-- 情缘副本攻击buff

	BCT_YZDD_GJ_BUFF = 3051,						-- 一战到底攻击鼓舞buff
	ECT_IMG_FULING_MOHUA = 4000,					-- 赋灵技能 魔化buff

	ECT_OTHER_VIP = 9001,							-- vip加成
	ECT_OTHER_FBGF = 9002,							-- 副本鼓舞
	ECT_OTHER_HMCF = 9003,							-- 红名惩罚
	ECT_OTHER_SJJC = 9004,							-- 世界加成
	ECT_BOSS_PILAO = 9005,							-- 世界boss死亡buff
}

-- 装备越级buff
EQUIP_LEVEL_ADD_BUFF = {50, 100}

-- 被动触发效果
PASSIVE_FLAG = {
	PASSIVE_FLAG_ZHIBAO_TIANLEI = 0,							-- 至宝天雷
	PASSIVE_FLAG_ZHIBAO_NULEI = 1,								-- 至宝怒雷
	PASSIVE_FLAG_MOUNT_JIANTA = 2,								-- 坐骑践踏
	PASSIVE_FLAG_MOUNT_NUTA = 3,								-- 坐骑怒踏
	PASSIVE_FLAG_SHENGONG_SHENGA = 4,							-- 神弓神罚
	PASSIVE_FLAG_SHENGONG_GUANGJIAN = 5,						-- 神弓光箭
	PASSIVE_FLAG_SHENGONG_ZHUMO = 6,							-- 神弓诛魔
	PASSIVE_FLAG_SHENYI_HUANYING = 7,							-- 神翼幻影
	PASSIVE_FLAG_XIANNV_1 = 8,									-- 仙女1
	PASSIVE_FLAG_XIANNV_2 = 9,									-- 仙女2
	PASSIVE_FLAG_XIANNV_3 = 10,									-- 仙女3
	PASSIVE_FLAG_XIANNV_4 = 11,									-- 仙女4
	PASSIVE_FLAG_XIANNV_5 = 12,									-- 仙女5
	PASSIVE_FLAG_XIANNV_6 = 13,									-- 仙女6
	PASSIVE_FLAG_XIANNV_7 = 14,									-- 仙女7
	PASSIVE_FLAG_JING_LING_XI_XUE = 15,							-- 精灵 血之盛宴
	PASSIVE_FLAG_JING_LING_LEI_TING = 16,						-- 精灵 雷霆一怒
}

PASSIVE_FLAG_RES = {
	[PASSIVE_FLAG.PASSIVE_FLAG_JING_LING_XI_XUE] = "Buff_nvshenzhufu",
	[PASSIVE_FLAG.PASSIVE_FLAG_JING_LING_LEI_TING] = "tongyong_lei",
}

-- Effect_daji   暴击特效，作用于敌方身上
-- Effect_fantanhudun  反伤甲，作用于自己身上
-- Buff_nvshenzhufu  吸血，作用于自己身上
-- tongyong_lei 雷，作用于敌人身上、
-- 施放魔法读条阶段
MAGIC_SKILL_PHASE = {
	READING = 0,
	PERFORM = 1,
	CONTINUE = 2,
	END = 3,
}

-- 施放魔法特殊状态
MAGIC_SPECIAL_STATUS_TYPE = {
	NONE = 0,
	READING = 1,					-- 读条
	CONTINUE_PERFORM = 2,			-- 持续施法
	PERFORM_SKILL_ANYWAY = 3,		-- 必定释放技能
}

-- AOE范围类型
AOE_RANGE_TYPE = {
	NONE = 0,							-- 单体
	SELF_CENTERED_QUADRATE = 1,			-- 方形，以自己为中心
	TARGET_CENTERED_QUADRATE = 2,		-- 方形，以目标为中心
	SELF_CENTERED_CIRCLE = 3,			-- 圆形，以自己为中心
	TARGET_CENTERED_CIRCLE = 4,			-- 圆形，以目标为中心
	SELF_BEGINNING_RECT = 5,			-- 矩形，以自己为起点
	SELF_BEGINNING_SECTOR = 6,			-- 扇形，以自己为起点
	MAX = 7,
}

-- AOE原因
AOE_REASON = {
	AOE_REASON_SKILL = 0,
	AOE_REASON_FAZHEN = 1,
}

-- 虚拟技能特效加载的位置
VIRTUAL_SKILL_EFFECT_POS = {
	MainRole = 1,
	Target = 2,
}

-- 虚拟技能
VIRTUAL_SKILL = {
	[12] = {pos = VIRTUAL_SKILL_EFFECT_POS.Target,scale = 1,
		bundle = "effects2/prefab/misc/t_zjjn_jian_prefab", asset = "T_zjjn_jian"},	-- 高攻（组队塔防）
	[6] = {pos = VIRTUAL_SKILL_EFFECT_POS.Target,scale = 1,
		bundle = "effects2/prefab/misc/tongyong_yunsi_prefab", asset = "tongyong_yunsi"},	-- 群攻（组队塔防）
	[7] = {pos = VIRTUAL_SKILL_EFFECT_POS.Target,scale = 1,
		bundle = "effects2/prefab/misc/boss_jinlei_t_prefab", asset = "Boss_jinlei_T"},	-- 范围持续伤害（组队塔防）
	[2] = {pos = VIRTUAL_SKILL_EFFECT_POS.Target,scale = 1,
		bundle = "effects2/prefab/buff_prefab", asset = "BUFF_nvshenzhinu"},	-- 嘲讽（组队塔防）
	[3] = {pos = VIRTUAL_SKILL_EFFECT_POS.Target,scale = 1,
		bundle = "effects2/prefab/misc/tongyong_yunsi_prefab", asset = "tongyong_yunsi"},	-- 降低敌人攻击（组队塔防）
	[1] = {pos = VIRTUAL_SKILL_EFFECT_POS.MainRole,scale = 1,
		bundle = "effects2/prefab/buff_prefab", asset = "10042"},	-- 无敌（组队塔防）
	[8] = {pos = VIRTUAL_SKILL_EFFECT_POS.Target,scale = 1,
		bundle = "effects2/prefab/misc/t_zjjn_shuilonjuan_prefab", asset = "T_zjjn_shuilonjuan"},	-- 高攻（组队塔防）
	[9] = {pos = VIRTUAL_SKILL_EFFECT_POS.MainRole,scale = 1,
		bundle = "effects2/prefab/buff_prefab", asset = "BUF_huixie"},	-- 群体回血（组队塔防）
	[10] = {pos = VIRTUAL_SKILL_EFFECT_POS.MainRole,scale = 1,
		bundle = "effects2/prefab/buff_prefab", asset = "BUFF_nvshenzhiqiang"},	-- 提升攻击、防御（组队塔防）
	[11] = {pos = VIRTUAL_SKILL_EFFECT_POS.Target, scale = 1,
		bundle = "effects2/prefab/buff_prefab", asset = "BUFF_bing"},	-- 冰冻（组队塔防）
}