-----------------------------------------------------
-- 游戏中的枚举
-----------------------------------------------------
GameEnum =
{
	--背包分类Toggle类型
	TOGGLE_INFO ={
		ALL_TOGGLE ="all",
		EQUIP_TOGGLE = "equip",
		MATERIAL_TOGGLE = "material",
		CONSUME_TOGGLE = "consume",
		SPIRIT_TOGGLE = "spirit",
		MAGIC_WEAPON_TOGGLE = "magic_weapon",
		MAGIC_CARD_TOGGLE = "magic_card"
	},

	--不需要屏蔽怪物场景ID
	NOT_SHIELD_ENEMY_SCENE_ID = {
		QINGYUAN_FU_BEN = 520,
		GONG_HUI_ZHENG_BA = 1000,
		GONG_CHENG_ZHAN = 1002,
		LING_TU_ZHAN = 1003,
		DA_TI = 1100,
		WEN_QUAN = 1110,
		TIAN_JIANG_CAI_BAO = 1120,
		WANG_LING_TANG_XIAN = 1130,
		KUA_FU_ZU_DUI = 1140,
		JIE_DUAN_FU_BEN = 4001,
		JU_QING_FU_BEN = 4100,
		VIP_FU_BEN = 4400,
		-- JINGYAN_FU_BEN = 4501,
		KUA_FU_1V1 = 5002,
		YONG_SHI_ZHI_TA = 5101,
		HUN_YAN = 8050,
		XIU_LUO_TA = 7010,
	},

	-- 40等级以下屏蔽其他玩家信息
	SHIELD_OTHER_LEVEL= 40,

	MONEY_BAR = {
		BIND_GOLD = 1,											-- 绑定元宝
		GOLD = 2,												-- 元宝
		BIND_COIN = 3,											-- 绑定铜币
		COIN = 4,												-- 铜币
		OTHER = 5,												-- 其他

		MAX_TYPE = 5,
	},


	--不显示别人掉落的场景
	SHIELD_OTHERS_FALLITEM_SCENE_ID = {
		[101] = true,
		[102] = true,
		[104] = true,
		[105] = true,
		[106] = true,
		[107] = true,
		[108] = true,
	},

	-- 天降财宝最大任务
	TIANJIANGCAIBAO_TASK_MAX = 10,
	MAX_REWARD_ITEM_COUNT = 10,
	TIANJIANGCAIBAO_GOLD_RANK_MAX = 10,

	NEW_SERVER_DAYS = 7,							-- 开服活动天数
	FORECAST_CFG_COUNT = 32,						-- 开启活动数量

	NOVICE_LEVEL = 70, 								--新手最大等级
	MIN_NOVICE_LEVEL = 31,							--新手箭头最小等级
	AVTAR_REMINDER_LEVEL = 140, 					--头像红点提示等级

	MINGREN_REMINDER_LEVEL = 150, 					--名人红点提示等级

	-- 转盘基本信息
	TURNTABLE_TYPE_MAX_COUNT = 16,
	TURNTABLE_OPERA_TYPE = 0,

	--婚宴操作
	HUNYAN_OPERA_TYPE_INVITE = 1,					-- 婚宴邀请
	HUNYAN_OPERA_TYPE_HONGBAO = 2,					-- 婚宴发红包
	HUNYAN_OPERA_TYPE_HUAYU = 3,					-- 浪漫花雨
	HUNYAN_OPERA_TYPE_YANHUA = 4,					-- 婚宴燃放烟花
	HUNYAN_OPERA_TYPE_PAOHUAQIU = 5,				-- 婚宴抛花球
	HUNYAN_OPERA_TYPE_SAXIANHUA = 6,				-- 婚宴撒鲜花
	HUNYAN_OPERA_GUEST_BLESS = 7,					-- 宾客祝福
	HUNYAN_OPERA_TYPE_RED_BAG = 8,					-- 婚宴送红包  param1  目标uid  param2  seq
	HUNYAN_OPERA_TYPE_FOLWER = 9,					-- 婚宴送花  param1  目标uid  param2  seq
	HUNYAN_OPERA_TYPE_BAITANG_REQ = 10,				-- 请求拜堂
	HUNUAN_OPERA_TYPE_BAITANG_RET = 11,				-- 收到拜堂  param1  1:同意  0:拒绝
	HUNYAN_OPERA_TYPE_APPLY = 12,					-- 申请参加婚礼
	HUNYAN_OPERA_TYPE_IS_AGREE_APPLY = 13,			-- 是否同意请求  param1  目标uid  param2  1:同意  0:拒绝
	HUNYAN_GET_BLESS_RECORD_INFO = 14,				-- 获取祝福历史
	HUNYAN_GET_APPLICANT_INFO = 15,					-- 获取申请者信息
	HUNYAN_GET_WEDDING_INFO = 16,					-- 获取婚礼信息	
	HUNYAN_GET_WEDDING_ROLE_INFO = 17,				-- 获取婚礼个人信息
	HUNYAN_OPERA_APPLICANT_OPERA = 18,				-- 申请者操作  param1  目标uid  param2  1:同意  0:拒绝
	HUNYAN_OPERA_ANSWER_QUESTION = 19,				-- 答题操作 param1 答案id

	HUNYAN_QUESTION_COUNT_PER_PERSON_MAX = 20,

	--婚宴邀请类型
	HUNYAN_INVITE_TYPE_ALL_FRIEND = 0,				--邀请所有好友
	HUNYAN_INVITE_TYPE_ONE_FRIEND = 1,				--邀请单个好友
	HUNYAN_INVITE_TYPE_ALL_GUILD_MEMBER = 2,		--邀请所有公会成员
	HUNYAN_INVITE_TYPE_ONE_GUILD_MEMBER = 3,		--邀请单个公会成员

	--货币
	CURRENCY_COIN = 206003,								--金币（铜币）
	CURRENCY_BIND_COIN = 206004,						--绑定金币(绑定铜币)
	CURRENCY_BIND_GOLD = 206002,						--绑定钻石（绑定元宝）
	CURRENCY_GOLD = 206001,								--钻石（元宝）
	CURRENCY_NV_WA_SHI = 206005,						--水晶（女娲石）
	CURRENCY_KUA_FU = 206006,							--跨服
	CURRENCY_LING_JING = 206010,						--灵精

	NOVICE_WARM_TIP = 35,								--新手温馨提示

	--职业
	ROLE_PROF_1 = 1, 								--破军
	ROLE_PROF_2 = 2, 								--女枪
	ROLE_PROF_3 = 3, 								--弓箭手
	ROLE_PROF_4 = 4, 								--琴女
	ROLE_PROF_11 = 11,								--狱血魔神
	ROLE_PROF_12 = 12,								--灵魂猎手
	ROLE_PROF_13 = 13,								--妙笔生花
	ROLE_PROF_14 = 14,								--寒冰尊者

	--性别
	FEMALE = 0,										--女性
	MALE = 1,										--男性

	-- 阵营
	ROLE_CAMP_0 = 0, 								-- 无
	ROLE_CAMP_1 = 1,								-- 齐国
	ROLE_CAMP_2 = 2, 								-- 楚国
	ROLE_CAMP_3 = 3, 								-- 魏国
	
	MAX_CAMP_NUM = 3, 								-- 阵营最大数


	--物品颜色
	ITEM_COLOR_WHITE = 0,							-- 白
	ITEM_COLOR_GREEN = 1,							-- 绿
	ITEM_COLOR_BLUE = 2,							-- 蓝
	ITEM_COLOR_PURPLE = 3,							-- 紫
	ITEM_COLOR_ORANGE = 4,							-- 橙
	ITEM_COLOR_RED = 5,								-- 红
	ITEM_COLOR_GLOD = 6,							-- 金

	--符文物品颜色
	RUNE_COLOR_WHITE = 0,							-- 白
	RUNE_COLOR_BLUE = 1,							-- 蓝
	RUNE_COLOR_PURPLE = 2,							-- 紫
	RUNE_COLOR_ORANGE = 3,							-- 橙
	RUNE_COLOR_RED = 4,								-- 红

	--装备品质颜色
	EQUIP_COLOR_GREEN = 0,							-- 绿
	EQUIP_COLOR_BLUE = 1,							-- 蓝
	EQUIP_COLOR_PURPLE = 2,							-- 紫
	EQUIP_COLOR_ORANGE = 3,							-- 橙
	EQUIP_COLOR_RED = 4,							-- 红
	EQUIP_COLOR_TEMP = 5,							-- 金

	--运镖品质颜色
	YUNBIAO_COLOR_GREEN = 1,						-- 绿
	YUNBIAO_COLOR_BLUE = 2,							-- 蓝
	YUNBIAO_COLOR_PURPLE = 3,						-- 紫
	YUNBIAO_COLOR_ORANGE = 4,						-- 橙
	YUNBIAO_COLOR_RED = 5,							-- 红

	--物品大类型
	ITEM_BIGTYPE_MEDICINE = 0, 						--回复药品类型
	ITEM_BIGTYPE_BUFF = 1, 							--buff类型
	ITEM_BIGTYPE_EXPENSE = 2, 						--消耗类型 能直接使用
	ITEM_BIGTYPE_GEMSTONE = 3, 						--宝石类型
	ITEM_BIGTYPE_POSITION = 4,						--坐标相关类型
	ITEM_BIGTYPE_OTHER = 5,							--被动使用类型 type value 最好不要直接实用
	ITEM_BIGTYPE_TASK = 6,							--人物类型
	ITEM_BIGTYPE_GIF = 7,							--礼包类型	能直接使用
	ITEM_BIGTYPE_SCENE_BUFF = 8,					--场景buff类型
	ITEM_BIGTYPE_EQUIPMENT = 100,					--装备类型
	ITEM_BIGTYPE_VIRTUAL = 101,						--虚拟类型 金币 铜币
	ITEM_BIGTYPE_JL = 102,							--精灵类型

	EQUIP_TYPE_TOUKUI = 100,						--头盔
	EQUIP_TYPE_YIFU = 101,							--衣服
	EQUIP_KUZI = 102,								--裤子
	EQUIP_TYPE_XIEZI = 103,							--鞋子
	EQUIP_TYPE_HUSHOU = 104,						--护手
	EQUIP_TYPE_XIANGLIAN = 105,						--项链
	EQUIP_TYPE_WUQI = 106,							--武器
	EQUIP_TYPE_JIEZHI = 107,						--戒指
	EQUIP_TYPE_YAODAI = 108,						--腰带

	ZS_EQUIP_TYPE_TOUKUI = 900,						--转生头盔
	ZS_EQUIP_TYPE_YIFU = 901,						--转生衣服
	ZS_EQUIP_KUZI = 902,							--转生裤子
	ZS_EQUIP_TYPE_XIEZI = 903,						--转生鞋子
	ZS_EQUIP_TYPE_HUSHOU = 904,						--转生护手
	ZS_EQUIP_TYPE_XIANGLIAN = 905,					--转生项链
	ZS_EQUIP_TYPE_WUQI = 906,						--转生武器
	ZS_EQUIP_TYPE_JIEZHI = 907,						--转生戒指

	EQUIP_TYPE_JINGLING = 201,						-- 精灵
	EQUIP_TYPE_HUNJIE = 202,						-- 婚戒
	E_TYPE_QINGYUAN_1 = 1000,						--结婚1
	E_TYPE_QINGYUAN_2 = 1001,						--结婚2
	E_TYPE_QINGYUAN_3 = 1002,						--结婚3
	E_TYPE_QINGYUAN_4 = 1003,						--结婚4
	E_TYPE_LITTLEPET_1 = 1100,						--小宠物玩具1
	E_TYPE_LITTLEPET_2 = 1101,						--小宠物玩具2
	E_TYPE_LITTLEPET_3 = 1102,						--小宠物玩具3
	E_TYPE_LITTLEPET_4 = 1103,						--小宠物玩具4
	QINGYUAN_TYPE_0 = 0,							--结婚类型1
	QINGYUAN_TYPE_1 = 1,							--结婚类型2
	QINGYUAN_TYPE_2 = 2,							--结婚类型3
	BABY_MAX_COUNT = 20,							-- 最大可拥有的宝宝数量限制
	BABY_MAX_LEVEL = 50,							-- 宝宝最大等级
	BABY_MAX_GRADE = 10, 							-- 宝宝最大阶级
	BABY_SPIRIT_COUNT = 4,							-- 最大守护精灵数量


	--神州六器
	SHENZHOU_WEAPON_TYPE = 41,						 	--神州六器
	SHENZHOU_WEAPON_SLOT_COUNT = 6,						--神州六器槽数量
	SHENZHOU_WEAPON_BACKPACK_COUNT = 30,				--神州六器背包数量
	EQUIP_MAX_LEVEL = 50,								--神州六器最大等级
	MELT_MAX_LEVEL = 100,								--神州六器熔炼最大等级
	IDENTIFY_MAX_LEVEL = 10,							--神州六器鉴定最大等级
	IDENTIFY_STAR_MAX_LEVEL = 10,						--神州六器鉴定最大星级

	--转生装备使用类型
	ZHUANSHENG_SUB_TYPE_MIN = 900,
	ZHUANSHENG_SUB_TYPE_MAX = 907,

	E_TYPE_CAMP_MIN = 300,
	E_TYPE_CAMP_TOUKUI = 301,						-- 军团头盔
	E_TYPE_CAMP_YIFU = 302,							-- 军团衣服
	E_TYPE_CAMP_HUTUI = 303,						-- 军团护腿
	E_TYPE_CAMP_XIEZI = 304,						-- 军团鞋子
	E_TYPE_CAMP_HUSHOU = 305,						-- 军团护手
	E_TYPE_CAMP_XIANGLIAN = 306,					-- 军团项链
	E_TYPE_CAMP_WUQI = 307,							-- 军团武器
	E_TYPE_CAMP_JIEZHI = 308,						-- 军团戒指

	-- 装备位置索引
	EQUIP_INDEX_TOUKUI = 0,							--头盔
	EQUIP_INDEX_YIFU = 1,							--衣服
	EQUIP_INDEX_KUZI = 2,							--裤子
	EQUIP_INDEX_XIEZI = 3,							--鞋子
	EQUIP_INDEX_HUSHOU = 4,							--护手
	EQUIP_INDEX_XIANGLIAN = 5,						--项链
	EQUIP_INDEX_WUQI = 6,							--武器
	EQUIP_INDEX_JIEZHI = 7,							--戒指
	EQUIP_INDEX_YAODAI = 8,							--腰带
	EQUIP_INDEX_JIEZHI_2 = 9,						--戒指2

	EQUIP_INDEX_JINGLING = 21,						--精灵
	EQUIP_INDEX_HUNJIE = 22,						--婚戒

	--军团装备位置索引
	E_INDEX_CAMP_TOUKUI = 0,						--军团头盔
	E_INDEX_CAMP_YIFU = 1,							--军团衣服
	E_INDEX_CAMP_HUTUI = 2,							--军团护腿
	E_INDEX_CAMP_XIEZI = 3,							--军团鞋子
	E_INDEX_CAMP_HUSHOU = 4,						--军团护手
	E_INDEX_CAMP_XIANGLIAN = 5,						--军团项链
	E_INDEX_CAMP_WUQI = 6,							--军团武器
	E_INDEX_CAMP_JIEZHI = 7,						--军团戒指

	E_TYPE_ZHUANSHENG_1 = 900,						-- 转生武器
	E_TYPE_ZHUANSHENG_2 = 901,						-- 转生衣服
	E_TYPE_ZHUANSHENG_3 = 902,						-- 转生项链
	E_TYPE_ZHUANSHENG_4 = 903,						-- 转生吊坠
	E_TYPE_ZHUANSHENG_5 = 904,						-- 转生戒指
	E_TYPE_ZHUANSHENG_6 = 905,						-- 转生头盔
	E_TYPE_ZHUANSHENG_7 = 906,						-- 转生护肩
	E_TYPE_ZHUANSHENG_9 = 907,						-- 转生护腕
	E_TYPE_ZHUANSHENG_9 = 908,						-- 转生护腿
	E_TYPE_ZHUANSHENG_10 = 909,						-- 转生鞋子

	-- 宝石类型
	STONE_FANGYU = 1,								-- 防御类型宝石
	STONE_GONGJI = 2,								-- 攻击类型宝石
	STONE_HP = 3,									-- 血气类型的宝石

	STONE_TOTAL_NUM = 8,							-- 宝石数量

	--人物属性类型
	FIGHT_CHARINTATTR_TYPE_GLOBAL_COOLDOWN = 1,		--全局cooldown时间
	FIGHT_CHARINTATTR_TYPE_HP = 2,					--血量
	FIGHT_CHARINTATTR_TYPE_MP = 3,					--魔法
	FIGHT_CHARINTATTR_TYPE_MAXHP = 4,				--最大血量
	FIGHT_CHARINTATTR_TYPE_MAXMP = 5,				--最大魔法
	FIGHT_CHARINTATTR_TYPE_GONGJI = 6,				--攻击
	FIGHT_CHARINTATTR_TYPE_FANGYU = 7,				--防御
	FIGHT_CHARINTATTR_TYPE_MINGZHONG = 8,			--命中
	FIGHT_CHARINTATTR_TYPE_SHANBI = 9,				--闪避
	FIGHT_CHARINTATTR_TYPE_BAOJI = 10,				--暴击
	FIGHT_CHARINTATTR_TYPE_JIANREN = 11,			--坚韧（抗暴）
	FIGHT_CHARINTATTR_TYPE_MOVE_SPEED = 12,			--移动速度
	FIGHT_CHARINTATTR_TYPE_FUJIA_SHANGHAI = 13,		--附加伤害（女神攻击）
	FIGHT_CHARINTATTR_TYPE_DIKANG_SHANGHAI = 14,	--抵抗伤害（废弃）
	FIGHT_CHARINTATTR_TYPE_IGNORE_FANGYU = 15,		--无视防御
	FIGHT_CHARINTATTR_TYPE_HURT_INCREASE = 16,		--伤害追加
	FIGHT_CHARINTATTR_TYPE_HURT_REDUCE = 17,		--伤害减免

	JUMP_ROLE_LEVEL = 10,							--跳跃的最小角色等级
	JUMP_MAX_COUNT = 4,								--最大跳跃次数
	JUMP_RECOVER_TIME = 5,							--跳跃恢复时间
	JUMP_RANGE = 17,								--跳跃的距离

	FIGHT_CHARINTATTR_TYPE_ICE_MASTER = 18,				--冰精通
	FIGHT_CHARINTATTR_TYPE_FIRE_MASTER = 19,			--火精通
	FIGHT_CHARINTATTR_TYPE_THUNDER_MASTER = 20,			--雷精通
	FIGHT_CHARINTATTR_TYPE_POISON_MASTER = 21,			--毒精通
	
	FIGHT_CHARINTATTR_TYPE_PER_MINGZHONG = 22,			--命中率
	FIGHT_CHARINTATTR_TYPE_PER_SHANBI = 23,				--闪避率
	FIGHT_CHARINTATTR_TYPE_PER_JINGZHUN = 24,			--精准（破甲率）
	FIGHT_CHARINTATTR_TYPE_PER_BAOJI = 25,				--暴击率
	FIGHT_CHARINTATTR_TYPE_PER_BAOJI_HURT = 26,			--暴击伤害率
	FIGHT_CHARINTATTR_TYPE_PER_KANGBAO = 27,			--抗暴率
	FIGHT_CHARINTATTR_TYPE_PER_POFANG = 28,				--伤害增加率
	FIGHT_CHARINTATTR_TYPE_PER_MIANSHANG = 29,			--伤害减少率
	FIGHT_CHARINTATTR_TYPE_PER_PVP_HURT_INCREASE = 30,	--PVP伤害增加率
	FIGHT_CHARINTATTR_TYPE_PER_PVP_HURT_REDUCE = 31,	--PVP受伤减免率
	FIGHT_CHARINTATTR_TYPE_PER_XIXUE = 32,				--吸血率
	FIGHT_CHARINTATTR_TYPE_PER_STUN = 33,				--击晕率
	FIGHT_CHARINTATTR_TYPE_PER_BOSSHURT = 34,			--对世界BOSS伤害
	FIGHT_CHARINTATTR_TYPE_ZHIBAO = 35,					--至宝伤害
	FIGHT_CHARINTATTR_TYPE_CONSTANT_ZENGSHANG = 36,		--固定增伤
	FIGHT_CHARINTATTR_TYPE_CONSTANT_MIANSHANG = 37,		--固定免伤

	BASE_CHARINTATTR_TYPE_MAXHP = 51,				--基础最大血量
	BASE_CHARINTATTR_TYPE_MAXMP = 52,				--基础最大魔法
	BASE_CHARINTATTR_TYPE_GONGJI = 53,				--基础攻击
	BASE_CHARINTATTR_TYPE_FANGYU = 54,				--基础防御
	BASE_CHARINTATTR_TYPE_MINGZHONG = 55,			--基础命中
	BASE_CHARINTATTR_TYPE_SHANBI = 56,				--基础闪避
	BASE_CHARINTATTR_TYPE_BAOJI = 57,				--基础暴击
	BASE_CHARINTATTR_TYPE_JIANREN = 58,				--基础坚韧(抗暴)
	BASE_CHARINTATTR_TYPE_IGNORE_FANGYU = 59,		--基础无视防御

	BASE_HURT_INCREASE = 60,						--基础伤害追加
	BASE_HURT_REDUCE = 61,							--基础伤害减免
	BASE_ICE_MASTER = 62,							--基础冰精通
	BASE_FIRE_MASTER = 63,							--基础火精通
	BASE_THUNDER_MASTER = 64,						--基础雷精通
	BASE_POISON_MASTER = 65,						--基础毒精通
	BASE_CHARINTATTR_TYPE_MOVE_SPEED = 66,			--基础移动速度
	BASE_CHARINTATTR_TYPE_FUJIA_SHANGHAI = 67,		--附加伤害（女神攻击）
	BASE_CHARINTATTR_TYPE_DIKANG_SHANGHAI = 68,		--抵抗伤害(废弃)
	BASE_CHARINTATTR_TYPE_PER_MINGZHONG = 69,		--命中率
	BASE_CHARINTATTR_TYPE_PER_SHANBI = 70,			--闪避率
	BASE_CHARINTATTR_TYPE_PER_JINGZHUN = 71,		--精准(破甲率)
	BASE_CHARINTATTR_TYPE_PER_BAOJI = 72,			--暴击率
	BASE_CHARINTATTR_TYPE_PER_BAOJI_HURT = 73,		--暴击伤害率
	BASE_CHARINTATTR_TYPE_PER_KANGBAO = 74,			--抗暴率（废弃）

	BASE_CHARINTATTR_TYPE_PER_POFANG = 75,			-- 伤害增加率
	BASE_CHARINTATTR_TYPE_PER_MIANSHANG = 76,		-- 伤害减少率
	BASE_PER_PVP_HURT_INCREASE = 77,				-- PVP伤害增加率
	BASE_PER_PVP_HURT_REDUCE = 78,					-- PVP受伤减免率
	BASE_CHARINTATTR_TYPE_PER_XIXUE = 79,			--吸血率
	BASE_CHARINTATTR_TYPE_PER_STUN = 80,			--击晕率

	BASE_CHARINTATTR_TYPE_CONSTANT_ZENGSHANG = 81,	--固定增伤
	BASE_CHARINTATTR_TYPE_CONSTANT_MIANSHANG = 82,	--固定免伤

	--切换攻击模式
	SET_ATTACK_MODE_SUCC = 0,						-- 成功
	SET_ATTACK_MODE_PROTECT_LEVEL = 1,				-- 新手保护期
	SET_ATTACK_MODE_NO_CAMP = 2,					-- 没有加入阵营
	SET_ATTACK_MODE_NO_GUILD = 3,					-- 没有加入军团
	SET_ATTACK_MODE_NO_TEAM = 4,					-- 没有组队
	SET_ATTACK_MODE_PEACE_INTERVAL = 5,				-- 小于和平模式切换时间间隔
	SET_ATTACK_MODE_NO_GUILD_UNION = 6,				-- 没有军团联盟
	SET_ATTACK_MODE_STATUS_LIMIT = 7,				-- 当前状态下不允许切换攻击模式
	SET_ATTACK_MODE_MAX = 8,

	--攻击模式
	ATTACK_MODE_PEACE = 0,							-- 和平模式
	ATTACK_MODE_TEAM = 1,							-- 组队模式(可伤害非同队玩家)
	ATTACK_MODE_GUILD = 2,							-- 军团模式
	ATTACK_MODE_ALL = 3,							-- 全体模式
	ATTACK_MODE_NAMECOLOR = 4,						-- 善恶模式(只攻击红名玩家)
	ATTACK_MODE_CAMP = 5,							-- 阵营模式
	ATTACK_MODE_CROSS = 6,							-- 跨服模式，只能攻击其他服的玩家
	ATTACK_MODE_ALLIANCE = 7,						-- 同盟模式(只攻击非同盟玩家)
	ATTACK_MODE_MAX = 8,


	--名字颜色
	NAME_COLOR_WHITE = 0,							-- 白名
	NAME_COLOR_RED_1 = 1,							-- 红名
	NAME_COLOR_RED_2 = 2,							-- 红名
	NAME_COLOR_RED_3 = 3,							-- 红名
	NAME_COLOR_MAX = 0,

	MAX_FB_NUM = 60,								-- 副本数量
	FB_PHASE_MAX_COUNT = 100,						-- 阶段副本最大数量
	FB_STORY_MAX_COUNT = 20,						-- 剧情副本长度
	FB_VIP_MAX_COUNT = 16,							-- VIP副本长度
	FB_TOWER_MAX_COUNT = 100,						-- 爬塔副本长度

	FB_CHECK_TYPE = {
		FBCT_DAILY_FB = 1,							-- 日常副本
		FBCT_STORY_FB = 2,							-- 剧情副本
		FBCT_CHALLENGE = 3,							-- 挑战副本
		FBCT_PHASE = 4,								-- 阶段副本
		FBCT_FUN_MOUNT_FB = 5,						-- 功能开启副本坐骑
		FBCT_DAILY_TASK_FB = 6,						-- 日常任务副本
		FBCT_YAOSHOUJITANG_TEAM = 8,				-- 妖兽祭坛组队本
		FBCT_QINGYUAN = 9,							-- 情缘副本
		FBCT_ZHANSHENDIAN = 10,						-- 战神殿副本
		FBCT_HUNYAN = 11,							-- 婚宴副本
		FBCT_TOWERDEFEND_PERSONAL = 12,				-- 组队塔防
		FBCT_ZHUANZHI_PERSONAL = 13,				-- 个人转职副本
		FBCT_MIGONGXIANFU_TEAM = 14,				-- 迷宫仙府副本
		FBCT_WUSHUANG = 15,							-- 无双副本
		FBCT_PATAFB = 16,							-- 爬塔副本
		FBCT_CAMPGAOJIDUOBAO = 17,					-- 师门高级夺宝
		FBCT_VIPFB = 18,							-- VIP副本
		FBCT_GUIDE = 21,							-- 引导副本
		FBCT_GUAJI_TA = 22,							-- 挂机塔
		FBCT_JUNXIAN = 23,							-- 军衔副本
		FBCT_TUITU_NORMAL_FB = 25,					-- 推图副本
		FBCT_MONSTER_SIEGE = 26,					-- 怪物攻城
		FBCT_DIMAI = 27,							-- 抢地脉
		FBCT_SHENGDI_FB = 28,						-- 情缘圣地
		FBCT_HUANGLING = 29,            		 	-- 皇陵挂机
	},

	-- 购买类型
	CONSUME_TYPE_BIND = 1,							--绑定元宝
	CONSUME_TYPE_NOTBIND = 2,						--元宝

	-- 商店类型
	SHOP = 1,										--商城
	SECRET_SHOP = 2,								--神秘商店

	--存储类型
	STORAGER_TYPE_BAG = 0,							--背包
	STORAGER_TYPE_STORAGER = 1,						--仓库

	DISCOUNT_BUY_PHASE_MAX_COUNT = 24,				--一折抢购数量
	DISCOUNT_BUY_ITEM_PER_PHASE = 10, 				--一折抢购阶段

	STORAGER_SLOT_NUM = 125,						--仓库格子个数
	ROLE_BAG_SLOT_NUM = 125, 						--背包格子个数

	WORLD_EVENT_TYPE_MAX = 7, 						--世界事件类型数


	CARD_MAX = 12, 									--卡牌数
	NEW_BOSS_COUNT = 3, 							--镜像boss数

	MENTALITY_SHUXINGDAN_MAX_TYPE = 3, 				--属性丹种类

	--随机活动的常量
	RAND_ACTIVITY_SERVER_PANIC_BUY_ITEM_MAX_COUNT = 16, 	--全民疯抢
	RAND_ACTIVITY_PERSONAL_PANIC_BUY_ITEM_MAX_COUNT = 8,	--个人疯抢
	RAND_ACTIVITY_DANBI_CHONGZHI_REWARD_MAX_COUNT_PER_DAY = 8,

	HONGBAO_SEND = 0,							--发送红包
	HONGBAO_GET = 1,							--领取红包

	WUXINGGUAJI_STUFF_MAX = 5,						-- 材料个数
	WUXINGGUAJI_TARGET_MAX = 5,						-- 目标个数
	WUXINGGUAJI_BOSS_NUM = 1,						-- BOSS的最大数量

	MENTALITY_WUXING_MAX_COUNT = 35,				-- 五行个数

	NOTIFY_REASON_GET = 0,							--仙盟运势 所有人
	NOTIFY_REASON_CHANGE = 1,						--仙盟运势 改变的人

	--------------------符文系统------------------------------
	RUNE_SYSTEM_BAG_MAX_GRIDS = 200,				--背包最大格子数量不可变 数据库
	RUNE_SYSTEM_SLOT_MAX_NUM = 10,					--符文槽最大数
	RUNE_SYSTEM_XUNBAO_RUNE_MAX_COUNT = 10,			--寻宝得符文最大数量
	RUNE_JINGHUA_TYPE = 19,							--符文精华类型
	RUNE_MAX_LEVEL = 500,							--符文最大等级
	------------------------------------------------------------

	TEAM_MAX_COUNT = 3,								--组队最大人数

	HUANHUA_MAX_COUNT = 20,							--最大幻化数量
	MAX_IMAGE_ID = 20, 								--最大形象ID
	MOUNT_EQUIP_COUNT = 4,							--坐骑装备数量
	EQUIP_UPGRADE_PERCENT = 0.00006,				--装备升级乘以的百分比
	MOUNT_EQUIP_ATTR_COUNT = 3,						--坐骑装备属性数量
	MOUNT_EQUIP_MAX_LEVEL = 200,					--坐骑装备最大等级
	MAX_MOUNT_LEVEL = 100,							--坐骑最大等级
	MAX_MOUNT_GRADE = 30,							--坐骑最大阶数
	MAX_MOUNT_SPECIAL_IMAGE_ID_NEW = 256,            --可进阶坐骑特殊形象ID（拓展，幻化用）
	MAX_MOUNT_SPECIAL_IMAGE_ID = 31,                --可进阶坐骑特殊形象ID
	MAX_DRESS_SPECIAL_IMAGE_ID = 255,               --可进阶装扮特殊形象ID
	MAX_WING_SPECIAL_IMAGE_ID = 256,                	--可进阶羽翼特殊形象ID
	MAX_UPGRADE_LIMIT = 10,							--坐骑特殊形象进阶最大等级
	MOUNT_SKILL_COUNT = 4,							--坐骑技能数量
	MOUNT_SKILL_MAX_LEVEL = 100,					--坐骑技能最大等级
	MOUNT_SPECIAL_IMA_ID = 1000,					--坐骑特殊形象ID换算
	MAX_MOUNT_SPECIAL_IMAGE_COUNT = 16,             --坐骑特殊形象数量

	MAX_XIANJIAN_COUNT = 8,							--仙剑把数（原先是8）
	JIANXIN_SLOT_PER_XIANJIAN = 7,					--每把剑的剑心孔数

	CSA_RANK_TYPE_MAX = 4,									--合服活动-排行榜MAX
	COMBINE_SERVER_ACTIVITY_RANK_REWARD_ROLE_NUM = 3,		--合服排行前几
	COMBINE_SERVER_RANK_QIANGOU_ITEM_MAX_TYPE = 3,			--合服抢购第一
	COMBINE_SERVER_SERVER_PANIC_BUY_ITEM_MAX_COUNT = 16,	--合服疯狂抢购全服物品数量
	COMBINE_SERVER_PERSONAL_PANIC_BUY_ITEM_MAX_COUNT = 8,	--合服疯狂抢购个人物品数量
	
	COMBINE_SERVER_ACTIVITY_RANK_REWARD_ROLE_NUM = 3,		--合服排行前几
	COMBINE_SERVER_RANK_QIANGOU_ITEM_MAX_TYPE = 3,			--合服抢购第一
	COMBINE_SERVER_SERVER_PANIC_BUY_ITEM_MAX_COUNT = 16,	--合服疯狂抢购全服物品数量
	COMBINE_SERVER_PERSONAL_PANIC_BUY_ITEM_MAX_COUNT = 8,	--合服疯狂抢购个人物品数量

	WUSHUANG_EQUIP_MAX_COUNT = 8,				-- 无双装备数量
	WUSHUANG_JINGLIAN_ATTR_COUNT = 3,			-- 武装精炼属性数量
	WUSHUANG_FUMO_SLOT_COUNT = 3,				-- 无双附魔槽数量
	WUSHUANG_FUHUN_SLOT_COUNT = 5,				-- 无双附魂槽数量
	WUSHUANG_FUHUN_COLOR_COUNT = 5,				-- 无双附魂颜色
	WUSHUANG_LIEHUN_POOL_MAX_COUNT = 18,		-- 猎魂池
	WUSHUANG_HUNSHOU_BAG_GRID_MAX_COUNT = 36,	-- 魂兽背包格子最大数
	HUNSHOU_EXP_ID = 30000,						-- 经验魂兽ID

	ZHUANSHENG_EQUIP_TYPE_MAX = 8,				-- 转生装备最大数量

	CARDZU_MAX_CARD_ID = 177,					-- 卡牌最大卡牌ID
	CARDZU_MAX_ZUHE_ID = 63,					-- 卡牌组合最大数量
	CARDZU_TYPE_MAX_COUNT = 4,					-- 卡牌类型最大数量

	QINGYUAN_CARD_MAX_ID = 19,					-- 情缘卡牌最大卡号

	CHINESE_ZODIAC_SOUL_MAX_TYPE_LIMIT = 12,				-- 生肖精魄类型数量限制
	CHINESE_ZODIAC_LEVEL_MAX_LIMIT = 100,					-- 生肖精魄等级上限
	CHINESE_ZODIAC_EQUIP_SLOT_MAX_LIMIT = 8,				-- 生肖装备槽数量上限
	MIJI_KONG_NUM = 8,										-- 秘籍空数
	CHINESE_ZODIAC_XINGHUN_LEVEL_MAX = 12,					-- 生肖星魂等级最大值
	CHINESE_ZODIAC_XINGHUN_TITLE_COUNT_MAX = 6,			    -- 星魂称号最大数量
	CHINESE_ZODIAC_MAX_EQUIP_LEVEL = 40,					-- 装备最高等级
	TIAN_XIANG_COMBINE_MEX_BEAD_NUM = 15, 					--每个组合最多的珠子数

	TIAN_XIANG_TABEL_ROW_COUNT = 7,			-- 行
	TIAN_XIANG_TABEL_MIDDLE_GRIDS = 7,		-- 列
	TIAN_XIANG_ALL_CHAPTER_COMBINE = 3,		-- 每个章节的组合数
	TIAN_XIANG_CHAPTER_NUM = 10,				-- 章节最大数

	CROSS_MULTIUSER_CHALLENGE_SIDE_MEMBER_COUNT = 3, 	-- 跨服3v3一方参赛人数
	CROSS_MULTIUSER_CHALLENGE_STRONGHOLD_NUM = 3, 		-- 跨服3V3据点数量
	MAX_XIANJIAN_SOUL_SKILL_SLOT_COUNT = 8,				-- 剑魂格子总数
	MAX_XIANJIAN_SOUL_COUNT = 14,				-- 剑魂技能总数
	SUOYAOTA_TASK_MAX = 4,						-- 锁妖塔任务数
	LIFESKILL_COUNT = 4,						-- 生活技能数量
	MAX_TEAM_MEMBER_NUM = 4,					-- 钟馗捉鬼最大人数
	NEW_FB_REWARD_ITEM_SC_MAX = 30,					-- 钟馗捉鬼最大物品数
	TIME_LIMIT_EXCHANGE_ITEM_COUNT = 10, 		-- 随机活动兑换数组长度
	SHUXINGDAN_MAX_TYPE = 3, 					-- 属性丹最大类型
	JINGLING_PTHANTOM_MAX_TYPE = 10, 			-- 精灵幻化升级最大等级
	JINGLING_PTHANTOM_MAX_TYPE_NEW = 22,        -- 新增精灵幻化升级等级
	JINGLING_EQUIP_MAX_PART = 8,
	JINGLING_CARD_MAX_TYPE = 16,
	LIEMING_SLOT_COUNT  =  8,                   -- 精灵装备数量   
	LIEMING_FUHUN_SLOT_COUNT = 8,				-- 精灵命魂曹数量
	LIEMING_LIEHUN_POOL_MAX_COUNT = 18,			-- 精灵命魂猎取池
	LIEMING_HUNSHOU_BAG_GRID_MAX_COUNT = 36,	-- 精灵命魂背包最大格子数量
	RAND_ACTIVITY_ZHENBAOGE_ITEM_COUNT = 9,				--珍宝阁格子数量
	RAND_ACTIVITY_TREASURE_BUSINESSMAN_REWARD_COUNT = 6, --秘宝商人奖励物品数量
	BIG_CHATFACE_GRID_COUNT = 9,						--表情拼图数目
	SC_RA_MONEYTREE_CHOU_MAX_COUNT_LIMIT = 10,			-- 摇钱树奖励最大数量
	RA_KING_DRAW_LEVEL_COUNT = 3,						--陛下请翻牌最大牌组数
	RA_KING_DRAW_MAX_SHOWED_COUNT = 9,					-- 陛下请翻牌最大牌数
	LIEMING_HUNSHOU_OPERA_TYPE_ORDER_BAG = 13,		-- 整理背包



	RA_MINE_MAX_TYPE_COUNT = 12,				--当前挖到的矿石数
	RA_MINE_MAX_REFRESH_COUNT = 8,              --当前矿场的矿石
	RA_MINE_REFRESH_MAX_COUNT = 4,				-- 一次刷新出的最大矿石数目
	RA_MINE_TYPE_MAX_COUNT = 12,				-- 矿石类型最大数目
	RA_MINE_SERVER_REWARD_MAX_COUNT = 6,		-- 全服礼包最大数

	RA_GUAGUA_REWARD_AREA_COUNT = 5,			--刮奖区域数目
	RA_GUAGUA_AREA_ICON_COUNT = 3,				--刮奖区域的图标数

	RA_TIANMING_LOT_COUNT = 6,							--天命卜卦可加注标签数量
	RA_TIANMING_REWARD_HISTORY_COUNT = 20,				--天命卜卦奖励历史记录数量

	HUASHEN_MAX_ID = 10,                                 --化神最大数量
	HUASHEN_SPIRIT_MAX_ID_LIMIT = 5,					-- 化神守护精灵数量限制

	MAX_WING_FUMO_TYPE = 4,							--羽翼附魔数
	MAX_WING_FUMO_LEVEL = 100,						--羽翼附魔最大等级
	WING_SPECIAL_UPGRADE_COUNT = 16,             --特殊羽翼进阶最大数
	QINGYUAN_COUPLE_HALO_MAX_COUNT = 16, 				--情缘夫妻光环当前数量
	QINGYUAN_COUPLE_HALO_MAX_TYPE = 15,					--情缘夫妻光环最大数量
	QINGYUAN_COUPLE_HALO_MAX_ACTIVE_LIMIT = 8,			--一个夫妻光环需激活图标数量
	QINGYUAN_COUPLE_HALO_MAX_LEVEL = 10,                --夫妻光环最大升级数

	MULTIMOUNT_MAX_ID = 5, 								--双人坐骑最大数量
	MULTIMOUNT_EQUIP_TYPE_NUM = 8,						--双人坐骑装备数量

	RA_FANFAN_MAX_ITEM_COUNT = 50,						-- 最大奖励数量
	RA_FANFAN_MAX_WORD_COUNT = 10,						-- 最大字组数量
	RA_FANFAN_CARD_COUNT = 40,							-- 可翻牌数
	RA_FANFAN_CARD_COLUMN = 8,							-- 可翻牌列数
	RA_FANFAN_CARD_ROW = 5,								-- 可翻牌行数
	RA_FANFAN_LETTER_COUNT_PER_WORD = 4,				-- 每个字组字数
	RA_FANFAN_MAX_WORD_ACTIVE_COUNT = 99,				-- 最多激活字组数量
	CROSS_TUANZHAN_PILLA_MAX_COUNT = 6,					-- 柱子最大数量

	PASTURE_SPIRIT_MAX_COUNT = 12,						--牧场精灵最大数量
	SC_PASTURE_SPIRIT_LUCKY_DRAW_RESULT_MAX_COUNT = 50, --牧场抽奖数量

	GODDESS_ANIM_SHORT_TIME = 2,						--女神动画短间隔时间
	GODDESS_ANIM_LONG_TIME = 8,							--女神动画播放完是三个动画后的时间间隔

	PERSONALIZE_WINDOW_MAX_TYPE = 2,					--个性化聊天窗口类型
	PERSONALIZE_WINDOW_MAX_INDEX = 31,					--单个个性化聊天窗口数量

	RA_EXTREME_LUCKY_REWARD_COUNT = 10,                 -- 至尊幸运星每次抽奖物品数量

	WUSHANGEQUIP_MAX_TYPE_LIMIT = 4,					--跨服神器类型最大限制
	KUAFU_STRENGTH_LEVEL = 20,							--跨服强化等级
	KUAFU_STAT_LEVEL = 10,								--跨服升星等级
	RARE_CHEST_SHOP_MODE = 10,                       	--至尊寻宝十连抽
	MITAMA_MAX_MITAMA_COUNT = 5,						--御魂最大数量
	MITAMA_MAX_SPIRIT_COUNT = 5,						--御魂等级
	HOT_SPRING_MONSTER_COUNT = 9,                       --温泉里面怪物三消的怪物数量
	BLACK_MARKET_MAX_ITEM_COUNT = 3, 					-- 黑市竞拍物品数量
	MAGIC_EQUIP_MAX_COUNT = 5,			                -- 魔器装备最大数量
	MAGIC_EQUIP_STONE_SLOT_COUNT = 6,		            -- 魔器能镶嵌的宝石孔个数

	MAX_XIANNV_ID = 6,								--最大仙女id
	MIN_XIANNV_ID = 0, 								--最小仙女id
	ZHUZHAN_XIANNV_SHANGHAI_PRECENT = 0.8,      	--助战仙女伤害百分比
	WEI_ZHUZHAN_XIANNV_SHANGHAI_PRECENT = 0.2,      --未出战仙女伤害百分比
	ACTIVE_ITEM_NUM	= 1,							--激活仙女需要物品数量

	USE_TYPE_LITTLE_PET = 57,						-- 小宠物（Item使用类型）
	USE_TYPE_LITTLE_PET_FEED = 706,					-- 小宠物喂养道具
	RECYCLE_TYPE_LITTLE_PET = 10,					-- 小宠物回收类型

	BAG_INFO = {
		BAG_CELL_WIDTH =91, 				-- 背包一个cell单元的宽度
		BAG_MAX_GRID_NUM = 100,				-- 背包格子总数
		BAG_MAX_GRID_NUM_125 = 125,          -- 背包格子总数 125
		BAG_ROW = 4,						-- 背包一页行数
		BAG_ROW_FIVE = 5,					-- 背包一页 5 行
		BAG_COLUMN = 5,						-- 背包一页列数
		BAG_PAGE_COUNT = 5, 				-- 背包页数
	},
	--市场寄售的背包
	MARKET_INFO = {
		BAG_CELL_WIDTH = 80, 				-- 背包一个cell单元的宽度
		BAG_MAX_GRID_NUM = 100,				-- 背包格子总数
		BAG_ROW = 5,						-- 背包一页行数
		BAG_COLUMN = 4,						-- 背包一页列数
		BAG_PAGE_COUNT = 5, 				-- 背包页数
		CANSELL = 1,						-- 允许出售
		NOTSELL = 0,						-- 不允许出售
	},
	MAIL_BAG_INFO = {						-- 邮件中的背包
		BAG_CELL_WIDTH = 85, 				-- 背包一个cell单元的宽度
		BAG_MAX_GRID_NUM = 100,				-- 背包格子总数
		BAG_ROW = 5,						-- 背包一页行数
		BAG_COLUMN = 4,						-- 背包一页列数
		BAG_PAGE_COUNT = 5, 				-- 背包页数
	},

	GRID_TYPE_BAG = "bag", 					-- 格子类型(背包)
	GRID_TYPE_STORAGE = "storge",			-- 格子类型(仓库)

	CARD_INFO = {
		CARD_CELL_WIDTH = 220, 				-- 怪物图鉴一个cell单元的宽度
		CARD_MAX_GRID_NUM = 16,				-- 怪物图鉴格子总数
		CARD_ROW = 4,						-- 怪物图鉴一页个数
		CARD_PAGE_COUNT = 4, 				-- 怪物图鉴页数

		CARD_MAX_ITEM_NUM = 64,				-- 怪物图鉴碎片格子总数
		CARD_ITEM_ROW = 4,					-- 怪物图鉴碎片一页行数
		CARD_ITEM_COLUMN = 4,				-- 怪物图鉴碎片一页列数
		CARD_ITEM_PAGE_COUNT = 4, 			-- 怪物图鉴碎片页数
		CARD_ITEM_CELL_WIDTH = 91,			-- 怪物图鉴碎片一个cell单元的宽度
	},

	SHENQI_SUIT_NUM_MAX = 64,				-- 神器最大个数
	SHENQI_PART_TYPE_MAX = 4,				-- 神器的部位的最大个数


	XING_MAI_SLIDER_TIME = 3,				-- x星脉冷却条充满时间
	MAX_CROSS_BOSS_PER_SCENE = 20,			-- 场景内最大boss数量

	MAX_NOTICE_COUNT = 30,					-- 爱情契约聊天最大数

	PERSONAL_GOAL_COND_MAX = 3,				-- 个人目标条件

	-------------------福利---------------------------
	MAX_GROWTH_VALUE_GET_TYPE = 4,			--欢乐果树成长值最大数量
	MAX_CHONGJIHAOLI_RECORD_COUNT = 30,		--冲级豪礼最大数量

	SALE_TYPE_COUNT_MAX = 100,				-- 拍卖种类
	Lock_Time = 120,						-- 自动锁屏时间
	

	ITEM_COUNT_PER_PAGE = 8,				-- 国家成员信息一页有多少个
	MAX_ITEM_COUNT_PER_PAGE = 6,			-- 拍卖一页有多少个物品
	CAMP_POST_UNIQUE_TYPE_COUNT = 5,		-- 阵营官职列表(本国官职列表)
	BATTLE_REPORT_ITEM_MAX_COUNT = 50,		-- 最多战报数目
	MAX_REPORT_COUNT = 5,					-- 最大气运战报数量
	MAX_JUNXIAN_LEVEL = 20,					-- 军衔时间戳数组长度
	MAX_YUNBIAO_USER_COUNT = 100,			-- 运镖最大人数
	CAMP_TYPE_COUNT = 3,					-- 国家个数
	MILLIONARE_RANK_ITEM_MAX_COUNT = 10,	-- 大富豪排行榜个数
	MAX_VIP_LEVEL = 15, 					-- vip最大等级
	
	MAX_CAMERA_MODE = 2,					-- 摄像机模式

	FISHING_FISH_TYPE_MAX_COUNT = 8,		-- 鱼的种类数
	FISHING_GEAR_MAX_COUNT = 3,				-- 法宝种类数
	FISHING_BE_STEAL_NEWS_MAX = 5,			-- 钓鱼被偷日志数量
	FISHING_SCORE_MAX_RANK = 10,			-- 钓鱼积分排行榜最大数量

	RA_BOSS_XUANSHANG_MAX_PHASE_NUM = 4,	-- Boss悬赏阶段数

	TUTUI_FB_TYPE_NUM_MAX = 2, 				-- 推图副本类型数量
	FIGHTING_CHALLENGE_OPPONENT_COUNT = 4,	-- 挖矿挑战角色人数

	BEAUT_TRYST_TYPE = 193,					-- 美人幽会兑换物品
	CHECK_DIS_ATTR_TYPE_NUM = 12,   		-- 角色查看形象界面属性数量
	MAX_USE_TITLE_COUNT = 3,				-- 称号列表最大数量
	MAX_ORNAMENT_NUM = 3,					--饰品列表长度
	RA_DAILY_NATION_WAR_NUM_MAX = 3, 		-- 每日国事活动数量

	SHENGE_SYSTEM_SHENGESHENQU_MAX_NUM = 10,
	SHENGE_SYSTEM_SHENGESHENQU_ATTR_MAX_NUM = 7,
	SHENGE_SYSTEM_SHENGESHENQU_XILIAN_SLOT_MAX_NUM = 3,

	IMAGE_SYSTEM_MAX = 8, 						-- 形象技能最大数量
	JING_LING_SKILL_STORAGE_MAX = 50, 			
	JING_LING_SKILL_REFRESH_ITEM_MAX = 4,
	JING_LING_SKILL_COUNT_MAX = 10,
	JING_LING_SKILL_REFRESH_SKILL_MAX = 11, 	

	RA_APPRECIATION_REWARD_RANGE_MAX = 10, 		-- 感恩回馈最大兑换数量

	ITEM_GIFT_TYPE = {							-- 礼包类型
		COMMON = 0,								-- 普通
		WEAPON = 1,								-- 武器
	},

	SHIZHUANG_TYPE_MAX = 2,					-- 时装类型数量

	CROSS_XYJD_MAX_ID_COUNT = 18,			-- 咸阳据点数量

	ZHUANSHENGSYSTEM_SLOT_COUNT_MAX = 10,	-- 转生系统10个槽
	ZHUANSHENGSYSTEM_ATTR_VALUE = 4,		-- 属性最大个数
	BABY_BOSS_KILLER_LIST_MAX_COUNT = 5,	-- 宝宝BOSS击杀信息最大数量

	AVATAR_WINDOW_MAX_TYPE = 50,			-- 头像框

	-----------------------小宠物相关-------------------------------
	LITTLEPET_QIANGHUAGRID_MAX_NUM = 5,
	LITTLE_PET_COUPLE_MAX_SHARE_NUM = 10, 				--夫妻共享宠物最大数量
	LITTLE_PET_MAX_CHOU_COUNT = 10, 					--抽奖次数最大值
	LITTLE_PET_SHARE_MAX_LOG_NUM = 20,
	MAX_FRIEND_NUM = 100, 								--最大好友数量
	LITTLEPET_QIANGHUAPOINT_CURRENT_NUM = 8, 			--当前强化点数量
	LITTLEPET_EQUIP_INDEX_MAX_NUM = 4, 					--小宠物玩具装备下标数
	MINING_AREA_TYPE_NUM = 3, 						--玩家挖中各区域次数列表（以挖矿类型为下标）
	MINING_MINE_TYPE_NUM = 5, 						--矿石个数列表（以矿石类型为下标）
	MINING_RANK_ITEM_NUM_MAX = 10, 					--跨服挖矿排行榜个数
--------------------------------------------------------------

	ELEMENT_HEART_WUXING_TYPE_MAX = 5,					-- 五行之灵五行最大数量
	ELEMENT_HEART_MAX_COUNT = 5,						-- 五行之灵槽最大数量
	ELEMENT_HEART_MAX_XILIAN_SLOT = 10,					-- 五行之灵洗练最大数量
	ELEMENT_HEART_MAX_GRID_COUNT = 100, 				-- 元素之涌背包格子数
	ELEMENT_SHOP_ITEM_COUNT = 10,						-- 商店当前刷新出来的物品数量
	ELEMENT_MAX_EQUIP_SLOT = 6,							-- 五行之灵最大装备格子数量
	
}

--公会争霸
GUILD_BATTLE = {
	GUILD_BATTLE_TASK_TYPE_COUNT_MAX = 5,	-- 任务类型最大数
	POS_NUM_MAX = 10,						-- 金箱子位置信息最大数
	CAMP_TYPE_NUM = 3,						-- 国家个数
}

--特殊活动状态
COMMON_ACTIVITY_STATUS_TYPE = {
	COMMON_ACTIVITY_STATUS_TYPE_CLOSE = 0,			--关闭
	COMMON_ACTIVITY_STATUS_TYPE_STANDBY = 1,		--准备中
	COMMON_ACTIVITY_STATUS_TYPE_OPEN = 2,			--开启中

	COMMON_ACTIVITY_STATUS_TYPE_MAX,
}

--特殊活动类型
COMMON_ACTIVITY_TYPE = {
	COMMON_ACTIVITY_TYPE_WORLD_BOSS = 0,			--世界BOSS

	COMMON_ACTIVITY_TYPE_MAX,
}

--水晶幻境
CROSS_CRYSTAL = {
	SHUIJING_LIST_MAX_NUM = 50,				-- 水晶列表最大数
}


LIEMING_BAG_NOTIFY_REASON = {
	LIEMING_BAG_NOTIFY_REASON_INVALID = 0,
	LIEMING_BAG_NOTIFY_REASON_BAG_MERGE = 1,
	LIEMING_BAG_NOTIFY_REASON_MAX = 2,
}

THANKS_FEED_BACK_BUTTON_STATE = {
	CAN_FETCH = 1,
	CAN_NOT_FETCH = 2,
	HAS_FETCH = 3,
}

-- 每日次数
DAY_COUNT = {
	DAYCOUNT_ID_FB_START = 0,						--  副本开始
	DAYCOUNT_ID_FB_XIANNV = 1,						-- 仙女
	DAYCOUNT_ID_FB_COIN = 2, 						-- 铜币
	DAYCOUNT_ID_FB_WING = 3,						-- 羽翼
	DAYCOUNT_ID_FB_XIULIAN = 4,						-- 修炼
	DAYCOUNT_ID_FB_QIBING = 5,						-- 骑兵
	DAYCOUNT_ID_FB_EXP = 6,							-- 经验副本		

	DAYCOUNT_ID_FB_END = GameEnum.MAX_FB_NUM - 1,	-- 副本结束

	VAT_TOWERDEFEND_FB_FREE_AUTO_TIMES = 18,

	DAYCOUNT_ID_EVALUATE = 61,											-- 评价次数
	DAYCOUNT_ID_JILIAN_TIMES = 62,										-- 祭炼次数
	DAYCOUNT_ID_ACCEPT_HUSONG_TASK_COUNT = 63,							-- 护送任务 领取个数
	DAYCOUNT_ID_SHUIJING_GATHER = 64,									-- 采集物
	DAYCOUNT_ID_YAOSHOUJITAN_JOIN_TIMES = 65,							-- 妖兽祭坛参加次数
	DAYCOUNT_ID_FREE_CHEST_BUY_1 = 66,									-- 一次寻宝免费次数
	DAYCOUNT_ID_COMMIT_DAILY_TASK_COUNT = 67,							-- 日常任务 提交个数
	DAYCOUNT_ID_HUSONG_ROB_COUNT = 68,									-- 护送抢劫次数
	DAYCOUNT_ID_HUSONG_TASK_VIP_BUY_COUNT = 69,							-- 护送任务 vip购买次数
	DAYCOUNT_ID_HUSONG_REFRESH_COLOR_FREE_TIMES = 70,					-- 护送任务 免费刷新次数
	DAYCOUNT_ID_CAMP_TASK_COMPLETE_COUNT = 71,							-- 阵营任务完成次数
	DAYCOUNT_ID_GUILD_TASK_COMPLETE_COUNT = 72,							-- 仙盟任务完成次数
	DAYCOUNT_ID_FETCH_DAILY_COMPLETE_TASK_REWARD_TIMES = 73,			-- 日常领取全部任务完成奖励次数
	DAYCOUNT_ID_ANSWER_QUESTION_COUNT = 74,								-- 答题次数
	DAYCOUNT_ID_VIP_FREE_REALIVE = 75,									-- vip免费复活次数
	DAYCOUNT_ID_CHALLENGE_BUY_JOIN_TIMES = 76,							-- 挑战副本购买参与次数
	DAYCOUNT_ID_CHALLENGE_FREE_AUTO_FB_TIMES = 77,						-- 挑战副本免费扫荡次数
	DAYCOUNT_ID_BUY_ENERGY_TIMES = 78,									-- 购买体力次数
	DAYCOUNT_KILL_OTHER_CAMP_COUNT,										-- 击杀其他阵营玩家 双倍奖励次数
	DAYCOUNT_ID_GONGCHENGZHAN_REWARD,									-- 攻城战奖励
	DAYCOUNT_ID_TEAM_TOWERDEFEND_JOIN_TIMES = 82,						-- 组队塔防参与次数
	DAYCOUNT_ID_GCZ_DAILY_REWARD_TIMES = 83,							-- 攻城战领取每日奖励次数
	DAYCOUNT_ID_XIANMENGZHAN_RANK_REWARD_TIMES = 84,					-- 仙盟战排名奖励次数
	DAYCOUNT_ID_MOBAI_CHENGZHU_REWARD_TIMES = 85,						-- 膜拜城主次数
	DAYCOUNT_ID_GUILD_ZHUFU_TIMES = 86,									-- 仙盟运势祝福次数
	DAYCOUNT_ID_MIGOGNXIANFU_JOIN_TIMES = 92,							-- 迷宫仙府参与次数
	DAYCOUNT_ID_JOIN_YAOSHOUGUANGCHANG = 93,       						-- 参加妖兽广场每日次数
	DAYCOUNT_ID_JOIN_SUOYAOTA = 94,       								-- 参加锁妖塔每日次数
	DAYCOUNT_ID_GATHER_SELF_BONFIRE = 95,       						-- 采集自己仙盟篝火每日次数
	DAYCOUNT_ID_BONFIRE_TOTAl = 96,       								-- 采集仙盟篝火总次数
	DAYCOUNT_ID_DABAO_BOSS_BUY_COUNT = 97,       						-- 购买打宝地图进入次数
	DAYCOUNT_ID_DABAO_ENTER_COUNT = 98,       							-- 打宝地图进入次数
	DAYCOUNT_ID_JINGHUA_GATHER_COUNT = 101,								-- 精华采集次数
	DAYCOUNT_ID_CAMP_GAOJIDUOBAO = 102,									-- 军团高级夺宝
	DAYCOUNT_ID_GUILD_REWARD = 104,										-- 仙盟奖励
	DAYCOUNT_ID_GUILD_BONFIRE_ADD_MUCAI = 105,							-- 仙盟篝火捐献木材次数
	DAYCOUNT_ID_ACTIVE_ENTER_COUNT = 106,								-- 活跃boss地图进入次数
	DAYCOUNT_ID_GUILD_SHANGXIANG_COINT = 107,							-- 家族铜币上香，每日一次
	DAYCOUNT_ID_GUILD_SHANGXIANG_COINT = 108,							-- 家族元宝上香，每日一次
	DAYCOUNT_ID_FB_DIAOYU = 109,										-- 钓鱼
	DAYCOUNT_ID_FB_WAKUANG = 110,										-- 挖矿
	DAYCOUNT_ID_MONEY_TREE_COUNT = 111,									-- 摇钱树转转转乐免费抽将次数
	DAYCOUNT_ID_DIMAI_FB_CHALLENGE_TIMES = 112,							-- 抢地脉挑战次数
	DAYCOUNT_ID_JINGLING_SKILL_COUNT = 113,                				-- 精灵技能免费刷新次数
	DAYCOUNT_ID_WORLD_CHANNEL_CHAT_FREE_TIMES = 114,					-- 世界聊天次数
	DAYCOUNT_ID_DAILY_TASK_QUICK_DONE = 115,							-- 快速完成日常任务
	DAYCOUNT_ID_EQUIP_TEAM_FB_JOIN_TIMES = 116,							-- 精英须臾幻境

	-------------------------------------------------------------------------------------------

	DAYCOUNT_ID_CAMP_NEIZHENG_BEG = 150,								
								
	DAYCOUNT_ID_CAMP_NEIZHENG_YUNBIAO = 151,							-- 国家内政-运镖次数	
	DAYCOUNT_ID_CAMP_NEIZHENG_BANZHUAN = 152,							-- 国家内政-搬砖次数	
	DAYCOUNT_ID_CAMP_NEIZHENG_OFFICER_WELFARE = 153,					-- 国家内政-官员福利			
	DAYCOUNT_ID_CAMP_NEIZHENG_GUOMIN_WELFARE = 154,						-- 国家内政-国民福利		
	DAYCOUNT_ID_CAMP_NEIZHENG_SET_NEIJIAN = 155,						-- 国家内政-设置内奸		
	DAYCOUNT_ID_CAMP_NEIZHENG_UNSET_NEIJIAN = 156,						-- 国家内政-取消内奸		
									
	DAYCOUNT_ID_CAMP_NEIZHENG_END = 169,								
									
	-------------------------------------------------------------------------------------------								
									
	DAYCOUNT_ID_CAMP_TASK_BEG = 170,								
									
	DAYCOUNT_ID_CAMP_TASK_CITAN_ACCEPT_TIMES = 171,						-- 国家任务-接受刺探任务次数		
	DAYCOUNT_ID_CAMP_TASK_CITAN_BUY_TIMES = 172,						-- 国家任务-刺探任务购买次数		
	DAYCOUNT_ID_CAMP_TASK_YINGJIU_ACCEPT_TIMES = 173,					-- 国家任务-接受营救任务次数			
	DAYCOUNT_ID_CAMP_TASK_YINGJIU_BUY_TIMES = 174,						-- 国家任务-营救任务购买次数		
	DAYCOUNT_ID_CAMP_TASK_BANZHUAN_ACCEPT_TIMES = 175,					-- 国家任务-接受搬砖任务次数			
	DAYCOUNT_ID_CAMP_TASK_BANZHUAN_BUY_TIMES = 176,						-- 国家任务-搬砖任务购买次数		
									
	DAYCOUNT_ID_CAMP_TASK_END = 199,								
}

MONSTER_TYPE = {
	MONSTER = 0,
	BOSS = 1,
}

GUAI_JI_TYPE = {
	NOT = 0,										-- 不挂机
	ROLE = 1,										-- 挂机打人
	MONSTER = 2,									-- 挂机打怪
}

SERVER_TYPE = {
	RECOMMEND = 1,
	ALL = 2,
}

--攻城战传送类型
CITY_COMBAT_MOVE_TYPE ={
	ATTACK_PLACE = 0,
	DEFENCE_PLACE = 1,
	ZHIYUAN_PLACE = 2,
}

-- 技能重置位置类型
SKILL_RESET_POS_TYPE = {
	SKILL_RESET_POS_TYPE_INVALID = 0,
	SKILL_RESET_POS_TYPE_CHONGFENG = 1,					-- 冲锋
	SKILL_RESET_POS_TYPE_JUMP = 2,						-- 跳跃
	SKILL_RESET_POS_TYPE_FOUNTAIN = 3,					-- 喷泉
	SKILL_RESET_POS_TYPE_CAPTURE = 4,					-- 捕抓
	SKILL_RESET_POS_TYPE_JITUI = 5,						-- 击退
	SKILL_RESET_POS_TYPE_TOWER_DEFEND_ZHENFA = 5,		-- 塔防阵法
	SKILL_RESET_POS_TYPE_SHUNYI = 6,					-- 瞬移
	SKILL_RESET_POS_TYPE_MAX = 7
}

ANIMATOR_PARAM = {
	STATUS = UnityEngine.Animator.StringToHash("status"),
	ATTACK1 = UnityEngine.Animator.StringToHash("attack1"),
	COMBO1_1 = UnityEngine.Animator.StringToHash("combo1_1"),
	COMBO1_2 = UnityEngine.Animator.StringToHash("combo1_2"),
	COMBO1_3 = UnityEngine.Animator.StringToHash("combo1_3"),
	HURT = UnityEngine.Animator.StringToHash("hurt"),
	REST = UnityEngine.Animator.StringToHash("rest"),
	REST1 = UnityEngine.Animator.StringToHash("rest1"),
	SHOW = UnityEngine.Animator.StringToHash("show"),
	FIGHT = UnityEngine.Animator.StringToHash("fight"),
}

BiPIN_RANK_TYPE = {
	PERSON_RANK_TYPE_UPGRADE_MOUNT = 69,						-- 坐骑进阶榜
	PERSON_RANK_TYPE_UPGRADE_WING = 70,							-- 羽翼进阶榜
	PERSON_RANK_TYPE_UPGRADE_HALO = 71,							-- 光环进阶榜
	PERSON_RANK_TYPE_UPGRADE_FIGHTMOUNT = 72,					-- 战骑进阶榜(法印)
	PERSON_RANK_TYPE_UPGRADE_JL_HALO = 73,						-- 精灵光环进阶榜(美人光环)
	PERSON_RANK_TYPE_UPGRADE_ZHIBAO = 74,						-- 至宝进阶榜(法宝)
	PERSON_RANK_TYPE_UPGRADE_SHENYI = 75,						-- 神翼进阶榜(披风)
	PERSON_RANK_TYPE_UPGRADE_SHENGONG = 76,						-- 神弓进阶榜(足迹)

	PERSON_RANK_TYPE_ICE_MASTER = 77,							-- 冰精通
	PERSON_RANK_TYPE_FIRE_MASTER = 78,							-- 火精通
	PERSON_RANK_TYPE_THUNDER_MASTER = 79,						-- 雷精通
	PERSON_RANK_TYPE_POISON_MASTER = 80,						-- 毒精通
	PERSON_RANK_TYPE_MINGZHONG = 81,							-- 命中
	PERSON_RANK_TYPE_SHANBI = 82,								-- 闪避
	PERSON_RANK_TYPE_BAOJI = 83,								-- 暴击
	PERSON_RANK_TYPE_JIANREN = 84,								-- 抗暴

	PERSON_RANK_TYPE_WULI = 85,									-- 武力
	PERSON_RANK_TYPE_ZHILI = 86,								-- 智力
	PERSON_RANK_TYPE_TONGSHUAI = 87,							-- 统帅

}

MAINUI_TIP_TYPE = {
	FRIEND = 1,
	GUILD = 2,
	TEAM_INVITE = 3,								-- 仙盟邀请
	TEAM_APPLY = 4,									-- 队伍申请与邀请
	TEAM = 5,										-- 队伍
	HU = 6,
	JIU = 7,
	YUAN = 8,
	WABAO = 9,
	JILIAN = 10,
	MAIL = 11, 										-- 充值返利邮件
	Trade = 14,										-- 交易
	FIELD1V1_FAIL = 15,								-- 斗法封神失败提醒
	BLESSWISH = 16,									-- 祝福邀请提醒
	WEDDING = 17,									-- 婚宴提醒
	REDENVELOPES = 18,								-- 红包提醒
	MI_JING = 19,									-- 仙盟秘境
	YUNSHI = 20,									-- 仙盟运势提醒图标
	REDNAME = 21,									-- 红名提示
	PRIVILEGE = 22,									-- 一折抢购提示
	TEAM_FB = 23,									-- 团队副本
	XIONGSHOU = 24,									-- 仙盟凶兽
	BONFIRE = 25,									-- 仙盟篝火
	SPACE_GIFT = 26,								-- 空间送礼
	SPACE_LIUYAN = 27,								-- 空间浏览
	CLEAR_BAG = 28,									-- 清理背包
	GONGGAO = 29,									-- 公告栏
	DAILYLOVE = 30, 								-- 每日一爱提示
}

TUMO_NOTIFY_REASON_TYPE = {
	TUMO_NOTIFY_REASON_DEFALUT = 0,					--屠魔默认通知类型
	TUMO_NOTIFY_REASON_ADD_TASK = 1,				--增加任务
	TUMO_NOTIFY_REASON_REMOVE_TASK = 2,				--移除任务
}

--属性丹类型
SHUXINGDAN_TYPE = {
	SHUXINGDAN_TYPE_INVALID = 0,
	SHUXINGDAN_TYPE_XIANNV = 1,						--精灵
	SHUXINGDAN_TYPE_MOUNT = 2,						--坐骑
	SHUXINGDAN_TYPE_XIULIAN = 3,					--修炼
	SHUXINGDAN_TYPE_WING = 4,						--羽翼
	SHUXINGDAN_TYPE_CHANGJIU = 5,					--成就
	SHUXINGDAN_TYPE_SHENGWANG = 6,					--声望

	SHUXINGDAN_TYPE_MAX = 6,
}

TUHAOJIN_REQ_TYPE = {
	TUHAOJIN_MAX_JINGHUA_COUNT = 7,							-- 土豪金精华最大数量
	TUHAOJIN_MAX_LEVEL = 50,								-- 土豪金最大等级
}

RA_CHONGZHI_MIJINGXUNBAO_CHOU_TYPE = {
		RA_CHONGZHI_MIJINGXUNBAO_CHOU_TYPE_1 = 0,			--淘宝一次
		RA_CHONGZHI_MIJINGXUNBAO_CHOU_TYPE_10 = 1,			--淘宝十次
		RA_CHONGZHI_MIJINGXUNBAO_CHOU_TYPE_50 = 2,			--淘宝五十次
		RA_CHONGZHI_MIJINGXUNBAO_CHOU_TYPE_MAX = 3,
}

RA_CHONGZHI_MIJINGXUNBAO_OPERA_TYPE = {
	RA_MIJINGXUNBAO_OPERA_TYPE_QUERY_INFO = 0,				-- 请求活动信息
	RA_MIJINGXUNBAO_OPERA_TYPE_TAO = 1,						-- 淘宝
	RA_MIJINGXUNBAO_OPERA_TYPE_MAX = 2,
}

SHENZHOU_WEAPON_REQ_TYPE = {
	SHENZHOU_WEAPON_REQ_TYPE_UPGRADE_WEAPON = 0,			-- 提升神器等级
	SHENZHOU_WEAPON_REQ_TYPE_UPGRADE_IDENTIFY = 1,			-- 提升鉴定等级
	SHENZHOU_WEAPON_REQ_TYPE_INDENTIFY = 2,					-- 鉴定物品 param1 背包物品下标
	SHENZHOU_WEAPON_REQ_TYPE_TAKE_OUT = 3,					-- 取出物品到背包 param1 背包物品下标
	SHENZHOU_WEAPON_REQ_TYPE_RECYCLE = 4,					-- 垃圾熔炼 param1 背包物品下标
	SHENZHOU_WEAPON_REQ_TYPE_ONE_KEY_RECYCLE = 5,			-- 一键垃圾熔炼
	SHENZHOU_WEAPON_REQ_TYPE_EXCHANGE_IDENTIFY_EXP = 6,		-- 兑换鉴定经验
}

XUNBAO_TYPE = {
	JINGLING_TYPE = 2      									-- 精灵类型寻宝展示
}

-- 活跃度类型
ACTIVEDEGREE_TYPE = {
	ADD_EXP = 0,									-- 帮派捐献
	SHENSHOU = 1,									-- 帮派神兽
	--MOUNT_UPGRADE = 2,							-- 坐骑进阶

	CHALLENGE_FB = 2,								-- 挑战副本
	EQUIP_FB = 3,									-- 装备副本
	EXP_FB = 4,										-- 经验副本
	TEAM_TOWERDEFEND = 5,							-- 塔防
	PHASE_FB = 6,									-- 阶段副本

	QUNXIANLUANDOU = 7,								-- 三界战场
	XIANMENGZHAN = 8,								-- 仙盟战
	GONGCHENGZHAN = 9,								-- 攻城战
	PVP = 10,										-- 排名竞技场
	ZHUXIE = 11,									-- 诛邪战场
	NATIONAL_BOSS = 12,								-- 全服Boss

	HUSONG_TASK = 13,								-- 运镖
	QUESTION = 14,									-- 答题
	TUMO_TASK = 15,									-- 日常任务
	GUILD_TASK = 16,								-- 仙盟任务

	ACTIVEDEGREE_TYPE_NUM = 17,
}

COMBINE_SERVER_ACTIVITY_SUB_TYPE = {
	CSA_SUB_TYPE_INVALID  =  0,
	CSA_SUB_TYPE_RANK_QIANGGOU = 1,	    	--  抢购
	CSA_SUB_TYPE_ROLL = 2,	     			--  转盘
	CSA_SUB_TYPE_GONGCHENGZHAN = 3,	   	 	--  攻城战
	CSA_SUB_TYPE_XIANMENGZHAN = 4,	    	--  仙盟战  -- 暂时无用
	CSA_SUB_TYPE_CHONGZHI_RANK = 5,	    	--  充值排行
	CSA_SUB_TYPE_CONSUME_RANK = 6,	    	--  消费排行
	CSA_SUB_TYPE_KILL_BOSS = 7,	   			--  击杀boss
	CSA_SUB_TYPE_SINGLE_CHARGE = 8,	      	--  单笔充值
	CSA_SUB_TYPE_LOGIN_Gift = 9,	     	--  登录奖励
	CSA_SUB_TYPE_PERSONAL_PANIC_BUY = 10,	--  个人抢购
	CSA_SUB_TYPE_SERVER_PANIC_BUY = 11,	    --  全服抢购
	CSA_SUB_TYPE_ZHANCHANG_FANBEI = 12,	   	--  战场翻倍
	CSA_SUB_TYPE_CHARGE_REWARD_DOUBLE = 13,	--  充值双倍返利
	CSA_SUB_TYPE_SANRIKUANGHUAN = 14, 		-- 	三日狂欢
	-- CSA_SUB_TYPE_BOSS = 14,		
	CAS_SUB_TYPE_TIANTIANFANLI = 15,    	--天天返利
	CAS_SUB_TYPE_PVP = 16,					-- 合服PVP
	CSA_SUB_TYPE_MAX = 17,
}

-- 活动类型
ACTIVITY_TYPE = {
	INVALID = -1,									-- 无效类型
	ZHUXIE = 1,										-- 攻城准备战
	QUESTION = 2,									-- 答题活动（旧版）
	HUSONG = 3,										-- 护送活动
	MONSTER_INVADE = 4,								-- 怪物入侵
	QUNXIANLUANDOU = 5,								-- 三界战场(元素战场)
	GONGCHENGZHAN = 6,								-- 一统天下
	XIANMENGZHAN = 7,								-- 仙盟战
	NATIONAL_BOSS = 8,								-- 神兽禁地(全民boss)
	CHAOSWAR = 9,							 		-- 一战到底
	MOSHEN = 10,							 		-- 魔神降临
	CAMPTASK = 11,							 		-- 阵营刺杀
	LUCKYGUAJI = 12,							 	-- 幸运挂机
	WUXINGGUAJI = 13,							 	-- 五行挂机
	SHUIJING = 14,									-- 水晶幻境
	HUANGCHENGHUIZHAN = 15,							-- 皇城会战
	CAMP_DEFEND1 = 16,								-- 守卫雕像1
	CAMP_DEFEND2 = 17,								-- 守卫雕像2
	CAMP_DEFEND3 = 18,								-- 守卫雕像3
	CLASH_TERRITORY = 19,							-- 领土战
	TIANJIANGCAIBAO = 20,							-- 天降财宝
	GUILDBATTLE = 21,								-- 成王败寇
	HAPPYTREE_GROW_EXCHANGE = 22,					-- 欢乐果树成长值兑换
	QUESTION_2 = 23,								-- 答题活动(新)
	GUILD_BOSS = 24,								-- 公会Boss
	BIG_RICH = 25,									-- 大富豪
	TOMB_EXPLORE = 26,								-- 皇陵探险
	GUILD_BONFIRE_OPEN = 27,						-- 行会篝火开启
	BANZHUAN = 28,									-- 搬砖双倍开启
	ACTIVITY_TYPE_MONSTER_SIEGE = 30,               -- 怪物攻城
	WEDDING_ACTIVITY = 31,							-- 婚宴

	ACTIVITY_TYPE_XINGZUOYIJI = 50,					-- 星座遗迹

	-- 客户端定义的活动类型
	PAIMINGJINGJICHANG = 101,						-- 排名竞技场(1V1)
	MarryFB = 100,									-- 情缘副本
	XIANMENGRENWU = 102,							-- 仙盟任务
	XIANMENGSHENSHOU = 103,							-- 仙盟神兽
	MIGONGXUNBAO = 104,								-- 迷宫寻宝
	TEAMFB = 105,									-- 多人副本
	WABAO = 106,									-- 挖宝(仙女掠夺)
	Alchemy = 108, 									-- 炼丹
	GuaJi = 109,									-- 挂机
	MANYTOWER = 110,								-- 多人塔防
	XIONGSHOU = 112,
	ZHUAGUI = 113,									-- 秘境降魔
	GONGCHENGZHAN_WORSHIP = 114, 					-- 攻城战膜拜
	GUILDBATTLE_WORSHIP = 115,						-- 公会争霸膜拜
	ROYAL_TOMB = 116,								-- 皇陵除恶
	
	--充值活动类型
	OPEN_SERVER = 1025,								-- 开服活动
	CLOSE_BETA = 1026,								-- 封测活动
	BANBEN_ACTIVITY = 1027,							-- 版本活动
	COMBINE_SERVER = 1028,							-- 合服活动
	Act_Roller = 2048,								-- 随机活动转盘

	--随机活动
	RAND_ACT = 2000,								-- 客户端用于泛指随机活动类型
	RAND_DAY_CHONGZHI_FANLI = 2049,					-- 单日充值返利
	RAND_DAY_CONSUME_GOLD = 2050,					-- 单日消费
	RAND_TOTAL_CONSUME_GOLD = 2051,					-- 累计消费
	RAND_DAY_ACTIVIE_DEGREE = 2052,					-- 单日活跃奖励
	RAND_CHONGZHI_RANK = 2053,						-- 充值排行
	RAND_CONSUME_GOLD_RANK = 2054,					-- 消费排行
	RAND_SERVER_PANIC_BUY = 2055,					-- 全服疯狂抢购
	RAND_PERSONAL_PANIC_BUY = 2056,					-- 个人疯狂抢购
	RAND_CONSUME_GOLD_FANLI = 2057,					-- 消费返利
	RAND_EQUIP_STRENGTHEN = 2058,					-- 装备强化
	RAND_CHESTSHOP = 2059,							-- 奇珍异宝
	RAND_STONE_UPLEVEL = 2060,						-- 宝石升级
	RAND_XN_CHANMIAN_UPLEVEL = 2061,				-- 仙女缠绵
	RAND_MOUNT_UPGRADE = 2062,						-- 坐骑进阶
	RAND_QIBING_UPGRADE = 2063,						-- 骑兵升级
	RAND_MENTALITY_TOTAL_LEVEL = 2064,				-- 根骨全身等级
	RAND_WING_UPGRADE = 2065,						-- 羽翼进化
	RAND_QUANMIN_QIFU = 2066,						-- 全民祈福
	RAND_SHOUYOU_YUXIANG = 2067,					-- 手有余香
	RAND_XIANMENG_JUEQI = 2068,						-- 仙盟崛起
	RAND_XIANMENG_BIPIN = 2069,						-- 仙盟比拼
	RAND_DAY_ONLINE_GIFT = 2070,					-- 每日在线好礼
	RAND_KILL_BOSS = 2071,							-- BOSS击杀
	RAND_DOUFA_KUANGHUAN = 2072,					-- 斗法狂欢
	RAND_ZHANCHANG_FANBEI = 2073,					-- 战场翻倍
	RAND_LOGIN_GIFT = 2074,							-- 登录奖励
	RAND_ACTIVITY_TYPE_SINGLE_CHONGZHI = 2178,		-- 单返豪礼
	RAND_ACTIVITY_TYPE_BP_CAPABILITY_WING = 2080,		-- 比拼羽翼战力
	RAND_ACTIVITY_TYPE_BP_CAPABILITY_MOUNT = 2079,		-- 比拼坐骑战力
	RAND_ACTIVITY_TYPE_BP_CAPABILITY_JINGLING = 2098,	-- 比拼精灵战力
	RAND_ACTIVITY_TYPE_BP_CAPABILITY_EQUIPSHEN = 2097,	-- 比拼神装战力
	RAND_ACTIVITY_TYPE_BP_CAPABILITY_EQUIP = 2076,		-- 比拼装备战力
	RAND_ACTIVITY_TYPE_BP_CAPABILITY_JINGLIAN = 2099,	-- 比拼精炼战力
	RAND_ACTIVITY_TYPE_BP_CAPABILITY_TOTAL = 2075,		-- 比拼综合战力
	RAND_CHARGE_REPALMENT = 2081,					-- 充值回馈
	RAND_SINGLE_CHARGE = 2082,						-- 单笔充值
	RAND_ACTIVITY_TYPE_CORNUCOPIA = 2083,			-- 聚宝盆
	RAND_CHONGZHI_DOUBLE = 2084,					-- 双倍充值
	RAND_TOTAL_CHARGE_DAY = 2086,					-- 随机活动每日累充
	RAND_TOMORROW_REWARD = 2087,					-- 次日福利活动
	RAND_SEVEN_DOUBLE = 2088,						-- 七日双倍活动
	RAND_DAILY_CHONGZHI_RANK = 2089,				-- 每日充值排行
	RAND_DAILY_CONSUME_RANK = 2090,					-- 每日消费排行
	RAND_TOTAL_CHONGZHI = 2091,						-- 活动累计充值
	RAND_DOUBLE_XUNBAO_JIFEN = 2092,				-- 双倍寻宝积分
	RAND_EQUIP_EXCHANGE = 2093,						-- 装备积分兑换
	RAND_SPRITE_EXCHANGE = 2094,					-- 精灵积分兑换
	RAND_JINYINTA = 2095,							-- 金银塔
	RAND_NIUEGG = 2096,								-- 充值扭蛋
	RAND_ACTIVITY_TREASURE_LOFT = 2100, 			-- 珍宝阁
	RAND_ACTIVITY_MIJINGXUNBAO = 2101,              -- 秘境淘宝
	RAND_ACTIVITY_TYPE_SINGLE_CHARGE_2 = 2102, 		-- 极速冲战
	RAND_LOTTERY_TREE = 2103,						-- 摇钱树
	RAND_DAILY_LOVE = 2104,							-- 每日一爱活动
	RAND_ACTIVITY_PLEASE_DRAW_CARD = 2105,			-- 陛下请翻牌
	RAND_ACTIVITY_SANJIANTAO = 2106, 				-- 三件套
	RAND_ACTIVITY_BEIZHENGDAREN = 2107,				-- 被整达人
	RAND_ACTIVITY_ZHENGGUZJ = 2108,					-- 整蛊专家
	RAND_ACTIVITY_ZONGYE = 2109,					-- 粽叶飘香
	RAND_ACTIVITY_NEW_THREE_SUIT = 2110,			-- 新三件套
	RAND_ACTIVITY_MINE = 2111,						-- 开心矿场
	RAND_ACTIVITY_DINGGUAGUA = 2112,				-- 刮刮乐
	RAND_ACTIVITY_LUCKYDRAW = 2113,				    -- 天命卜卦
	RAND_ACTIVITY_FANFANZHUAN = 2114,				-- 翻翻转活动
	RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI = 2115,	-- 连充特惠
	RAND_ACTIVITY_TYPE_CONTINUE_CONSUME = 2116,		-- 连续消费
	RAND_ACTIVITY_QIXI = 2118,						-- 七夕情缘
	RAND_ACTIVITY_TYPE_REPEAT_RECHARGE = 2119,		-- 循环充值
	RAND_ACTIVITY_SUPER_LUCKY_STAR = 2120,			-- 至尊幸运星
	RAND_ACTIVITY_LINGXUBAOZANG= 2121,				-- 灵虚宝藏
	RAND_ACTIVITY_BLESS_WATER = 2122,				-- 天泉祈福
	RAND_ACTIVITY_NATIONALDAY = 2123,				-- 国庆活动
	RAND_ACTIVITY_TREASURE_BUSINESSMAN = 2124,		-- 秘宝商人
	RAND_ACTIVITY_TYPE_DAY_DAY_UP = 2125,			-- 步步高升
	RAND_ACTIVITY_TYPE_BLACKMARKET_AUCTION = 2126,	-- 黑市拍卖
	RAND_ACTIVITY_TYPE_TREASURE_MALL = 2127, 		-- 珍宝商城
	RAND_CORNUCOPIA = 2156,							-- 新聚宝盆
	RAND_ACTIVITY_TYPE_ITEM_COLLECTION = 2157,		-- 集字活动   （统一的那个活动协议）
	MARRY_ME = 2158,								-- 我们结婚吧
	RAND_ACTIVITY_TYPE_HONG_BAO = 2159,				-- 开服红包
	RAND_ACTIVITY_TYPE_SUPPER_GIFT = 2160,			-- 礼包限购
	RAND_ACTIVITY_TYPE_EXP_REFINE = 2161,			-- 经验炼制
	RAND_ACTIVITY_TYPE_BOSS_XUANSHANG = 2162,		-- boss悬赏
	RAND_ACTIVITY_TYPE_GREATE_SOLDIER_DRAW = 2163,	-- 名将抽将
	RAND_ACTIVITY_TYPE_WAR_GOALS = 2164,			-- 战事目标
	RAND_ACTIVITY_TYPE_DAILY_NATION_WAR = 2165,		-- 每日国事
	RAND_ACTIVITY_TYPE_CHUJUN_GIFT = 2166,			-- 储君有礼
	RAND_ACTIVITY_TYPE_MARRY_GIFT = 2167,			-- 结婚礼金
	RAND_ACTIVITY_TYPE_XIANYUAN_TREAS = 2179, 		-- 聚划算
	RAND_ACTIVITY_TYPE_LUCKY_CHESS = 2125,			-- 幸运棋
	RAND_ACTIVITY_TYPE_LUCKY_TURNTABLE = 2170,		-- 幸运转盘
	RAND_ACTIVITY_TYPE_IMAGE_CHANGE_SHOP = 2171,    -- 形象兑换商城
	RAND_ACTIVITY_TYPE_DAY_TARGET = 2172,			-- 每日目标
	RAND_ACTIVITY_TYPE_HAPPY_LOTTERY = 2173,		-- 欢乐抽
	RAND_ACTIVITY_TYPE_MID_AUTUMN_LOTTERY = 2199,   -- 月饼大作战
	RAND_ACTIVITY_TYPE_REBATE_ACTIVITY = 2177,		-- 返利活动
	RAND_ACTIVITY_TYPE_SINGLE_CHARGE_REWARD = 2186, -- 单笔充值大奖
	RAND_ACTIVITY_TYPE_ADVENTURE_SHOP = 2084,		-- 奇遇商店
	RAND_ACTIVITY_TYPE_UPGRADE_MOUNT_RANK = 2143,						-- 坐骑进阶榜(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_WING_RANK = 2144,						-- 羽翼进阶榜(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_HALO_RANK = 2145,						-- 光环进阶榜(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_FIGHT_MOUNT_RANK = 2146,					-- 战骑进阶榜--法印(开服活动)
	RAND_ACTIVITY_TYPE_JL_GUANGHUAN_RANK = 2147,						-- 精灵光环--美人光环(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_ZHIBAO_RANK = 2148,						-- 法宝进阶榜--圣物(开服活动) 第六天
	RAND_ACTIVITY_TYPE_UPGRADE_SHENYI_RANK = 2149,						-- 神翼进阶榜--披风(开服活动)
	RAND_ACTIVITY_TYPE_DANBI_CHARGE = 2181,								-- 单笔大放送
	RAND_ACTIVITY_TYPE_ALONE_CHARGE_GIFT = 2182,						-- 单笔充值
	RAND_ACTIVITY_TYPE_MAP_HUNT = 2185,									-- 地图寻宝
	RAND_ACTIVITY_TYPE_MAGIC_SHOP = 2188,								-- 幻装商店
	RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU = 2174,		-- 连充特惠初(开服活动)
	RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO = 2175,		-- 连充特惠高(开服活动)
	RAND_ACTIVITY_TYPE_SUPER_DAILY_TOTAL_CHONGZHI = 2189,	-- 始皇武库
	RAND_ACTIVITY_TYPE_DAILY_TOTAL_CHONGZHI = 2187,			-- 每日累冲
	RAND_ACTIVITY_TYPE_RECHARGE_CAPACITY = 2184,			-- 单笔送好礼
	RAND_ACTIVITY_TYPE_RUSH_BUYING = 2180, 					-- 限时拍卖
	RAND_ACTIVITY_RMB_BUY_COUNT_SHOP = 2169,				-- RMB购买
	RAND_ACTIVITY_TYPE_GOD_DROP_GIFT = 2168,				-- 天降豪礼
	RAND_ACTIVITY_TYPE_QIXI_MARRIAGE = 2192,				-- 七夕婚宴
	RAND_ACTIVITY_TYPE_UEHUI_DAZUOZHAN = 2193,				-- 七夕活动
	RAND_ACTIVITY_TYPE_QIXI_SEND_FLOWER = 2194,				-- 七夕送花
	RAND_ACTIVITY_TYPE_APPRECIATION_REWARD = 2195,          -- 感恩回馈
	RAND_ACTIVITY_TYPE_MEIRI_ZHANBEI_GIFT = 2196,           -- 每日战备
	RAND_ACTIVITY_TYPE_LOTTERY = 2197,						-- 纸醉金迷
	RAND_ACTIVITY_TYPE_MIDAUTUMN = 2198,					-- 累计登陆
	RAND_ACTIVITY_TYPE_MIDAUTUMNMYYL = 2200,				-- 明月有礼
	RAND_ACTIVITY_TYPE_MIDAUTUMN_REWARD_TASK = 2201,		-- 中秋奖励任务
	RAND_ACTIVITY_TYPE_MIDAUTUMN_ITEM_EXCHANGE = 2202,		-- 中秋物品兑换
	RAND_ACTIVITY_TYPE_SUPER_CARGE_FEEDBACK = 2204,			-- 超级回馈
    RAND_ACTIVITY_TYPE_MIDAUTUMN_CUP_MOON = 2203,		    -- 中秋举杯望明月
    RAND_ACTIVITY_TYPE_MONEY_TREE_5 = 2214,				    -- 大射天下
    RAND_ACTIVITY_TYPE_MONEY_TREE_3 = 2212,				    -- 幸运宝箱 摇钱树3活动(转转乐2)

	RAND_ACTIVITY_FLAG = 2117,						        -- 军歌嘹亮
	RAND_ACTIVITY_TYPE_SHENGONG_UPGRADE_NEW = 2205,         -- 足迹进阶（w1足迹=神弓）
	RAND_ACTIVITY_TYPE_YAOSHI_UPGRADE = 2206,               -- 腰饰进阶
	RAND_ACTIVITY_TYPE_TOUSHI_UPGRADE = 2207,               -- 头饰进阶
	RAND_ACTIVITY_TYPE_QILINBI_UPGRADE = 2208,              -- 麒麟臂进阶  
	RAND_ACTIVITY_TYPE_MASK_UPGRADE = 2209,                 -- 面具进阶
	RAND_ACTIVITY_TYPE_XIANBAO_UPGRADE = 2210,              -- 仙宝进阶
	RAND_ACTIVITY_TYPE_LINGZHU_UPGRADE = 2211,              -- 灵珠进阶

	RAND_ACTIVITY_TYPE_MONEY_TREE_4 = 2213,				    -- 幸运扭蛋机

	KF_XIULUO_TOWER = 3073, 						-- 跨服修罗塔
	KF_ONEVONE = 3074, 								-- 跨服1V1
	KF_PVP = 3075, 									-- 跨服3V3
	KF_TEAMBATTLE = 3076,							-- 跨服天庭战
	KF_FARMHUNTING = 3077,							-- 牧场
	KF_BOSS = 3078,									-- 跨服boss
	KF_FB = 3079,									-- 跨服副本
	KF_HOT_SPRING = 3080,							-- 跨服温泉
	CROSS_SHUIJING = 3081,							-- 跨服水晶
	KF_MINING = 3082,								-- 跨服挖矿
	KF_FISHING = 3085,								-- 跨服钓鱼
	KF_GUILDBATTLE = 3086,							-- 跨服六界
	KF_BATTLE = 3089,								-- 跨服争霸

	KF_XYJD = 3087,									-- 咸阳据点
	KF_XY_CITY = 3088,								-- 咸阳城
	CROSS_RAND_ACTIVITY_TYPE_CHONGZHI_RANK  = 4000,	-- 跨服充值排行
	CROSS_FLOWER_RANK = 4001,						-- 跨服花榜
	CROSS_MI_BAO_RANK = 4002,						-- 真言秘宝

	--手动添加活动
	HUN_YAN = 10001, 								-- 婚宴
	SUOYAOTA = 10002,								-- 锁妖塔
	YAOSHOUPLAZA = 10003,							-- 妖兽广场
	GUILD_SHILIAN = 10004,							-- 仙盟试炼
	GUILD_BONFIRE = 27,								-- 仙盟篝火
	ACTIVITY_HALL = 10006,
}

MAIL_TYPE = {
	MAIL_TYPE_PERSONAL = 1,			-- 私人邮件
	MAIL_TYPE_SYSTEM = 2,			-- 系统邮件
	MAIL_TYPE_GUILD = 3,			-- 公会邮件
	MAIL_TYPE_CHONGZHI = 4,			-- 官方邮件

}

GUWU_TYPE = {
	GUWU_TYPE_GONGJI = 0,			-- 鼓舞攻击
	GUWU_TYPE_EXP = 1,				-- 鼓舞经验
}

MONTH_CARD_REWARD_TYPE = {
	MONTH_CARD_REWARD_TYPE_FIRST = 0,						-- 月卡第一次奖励
	MONTH_CARD_REWARD_TYPE_DAILY = 1,						-- 月卡每日奖励
}

TOUZI_JIHUA_TYPE = {										-- 投资类型
	TOUZI_JIHUA_TYPE_LEVEL = 0,								-- 等级投资				
	TOUZI_JIHUA_TYPE_LOGIN = 1,								-- 登录投资

	CHONGZHIDAHUIKUI_REQ_TYPE_ALL_INFO = 0,     		    -- 请求充值大回馈所有信息
	CHONGZHIDAHUIKUI_REQ_TYPE_FETCH_REWARD = 1, 			-- 请求领取充值大回馈奖励
}	

TOUZI_ACTIVE_TYPE = {										-- 投资激活类型
	NO_TOUZI = 0,											-- 没有投资
	TOUZI_LEVEL = 1,										-- 已投等级投资
	TOUZI_LOGIN = 2,										-- 已投登陆投资
	TOUZI_ALL = 3,											-- 已投所有投资
}

-- 大射天下
RA_CHONGZHI_MONEY_TREE_FIVE_OPERA_TYPE =
{
	RA_MONEY_TREE_OPERA_TYPE_QUERY_INFO = 0,				-- 请求活动信息
	RA_MONEY_TREE_OPERA_TYPE_CHOU = 1,						-- 抽奖
	RA_MONEY_TREE_OPERA_TYPE_FETCH_REWARD = 2,				-- 领取全服奖励
}				

-- 藏宝阁
RA_ZHENBAOGE_OPERA_TYPE = {
	RA_ZHENBAOGE_OPERA_TYPE_QUERY_INFO = 0,					-- 请求活动信息
	RA_ZHENBAOGE_OPERA_TYPE_BUY = 1,						-- 单个购买请求
	RA_ZHENBAOGE_OPEAR_TYPE_BUY_ALL = 2,					-- 全部购买请求
	RA_ZHENBAOGE_OPEAR_TYPE_FLUSH = 3,						-- 刷新请求
	RA_ZHENBAOGE_OPEAR_TYPE_RARE_FLUSH = 4,					-- 稀有刷新请求
	RA_ZHENBAOGE_OPERA_TYPE_FETCH_SERVER_GIFT = 5,			-- 领取全服礼包
	RA_ZHENBAOGE_OPERA_TYPE_MAX = 6,
}

RA_KING_DRAW_OPERA_TYPE = {
	RA_KING_DRAW_OPERA_TYPE_QUERY_INFO = 0,				-- 请求活动的信息
	RA_KING_DRAW_OPERA_TYPE_PLAY_ONCE = 1,				-- 只玩一次请求，发level和翻牌下标
	RA_KING_DRAW_OPERA_TYPE_PLAY_TIMES = 2,				-- 玩多次请求，发level和翻牌次数
	RA_KING_DRAW_OPERA_TYPE_REFRESH_CARD = 3,			-- 请求重置
	RA_KING_DRAW_OPERA_TYPE_FETCH_REWARD = 4,			-- 领取奖励
	RA_KING_DRAW_OPERA_TYPE_MAX = 5,
}

--限时兑换，形象幻化商城
RA_IMAGE_EXCHANGE_SHOP_OPERA_REQ = {
	RA_IMAGE_EXCHANGE_SHOP_OPERA_REQ_INFO = 0,			-- 请求兑换次数信息
	RA_IMAGE_EXCHANGE_SHOP_OPERA_REQ_EXCHANGE = 1,		-- 请求兑换
}

SIGN_GET_REWARD_STATUS = {
	ONE_SIGN = 1,			--领取签到一天奖励
	TOTAL_SIGN = 2, 		--领取累计签到奖励
}

NEQ_CARD_STATUS =  -- 卡牌状态
{
	DEFAULT = 1, 			--初始
	PREVIEW = 2, 			--预览
	SHUFFLE = 3, 			--洗牌
	COMPLETE_SHUFFLE = 4, 	--完成洗牌
	OPEN_ING = 5, 			--开启中
	OPEN = 6, 				--已开启
}

FU_BEN_TYPE = {
	FB_XIANNV = 1,									--仙女本
	FB_COIN = 2,									--铜币本
	FB_WING = 3,									--羽翼本
	FB_XIULIAN = 4,									--修练本
	FB_QIBING = 5,									--骑兵本
	FB_JUNXIAN = 23,								--军衔本
}

-- 活动状态
ACTIVITY_STATUS = {
	CLOSE = 0,										-- 活动关闭状态
	STANDY = 1,										-- 活动准备状态
	OPEN = 2,										-- 活动进行中
}

ACTIVITY_ROOM_STATUS = {
	CLOSE = 0,										-- 活动房间关闭
	OPEN = 1,										-- 活动房间开启
}

CHAT_TYPE = {
	CHANNEL = 1,									-- 频道聊天
	PRIVATE = 2,									-- 私聊
	GUILD = 3,										-- 帮会聊天
}

CHAT_CONTENT_TYPE = {
	TEXT = 0,										-- 文本
	AUDIO = 1,										-- 语音
}

SYS_MSG_TYPE = {
	SYS_MSG_ONLY_CHAT_WORLD = 1,					-- 添加到世界频道+主页面聊天窗口
	SYS_MSG_ONLY_CHAT_GUILD = 2,	 				-- 添加到综合频道+群聊家族+主页面聊天窗口
	SYS_MSG_ONLY_CHAT_CAMP = 3,						-- 添加到综合频道+群聊国家+主页面聊天窗口
	SYS_MSG_CENTER_AND_ROLL = 4,					-- 添加到系统频道+屏幕中央滚动+主页面聊天窗口
	SYS_MSG_CENTER_NOTICE = 5,						-- 添加到系统频道+屏幕中央弹出+主页面聊天窗口
	SYS_MSG_ACTIVE_NOTICE = 6, 						-- 屏幕中央弹出（活动公告，只在活动场景弹出）
	SYS_MSG_CENTER_PERSONAL_NOTICE = 7, 			-- 屏幕中央弹出（只对个人显示）
	SYS_MSG_ONLY_CHAT_GUILD_2 = 8,					-- 添加到左下角群聊图标弹出+家族面板弹出
	SYS_MSG_CENTER_ROLL_2 = 9,						-- 添加到系统频道+屏幕中央滚动
	SYS_MSG_CENTER_NOTICE_2 = 10,					-- 添加到系统频道+屏幕中央弹出
	SYS_MSG_ONLY_CHAT_GUILD_3 = 11,					-- 加到综合频道+群聊家族系统页面+主页面聊天窗口

	SYS_MSG_WORLD_QUEST = 100,						-- 传闻 世界答题
	SYS_MSG_GUILD_QUEST = 101,						-- 传闻 仙盟答题
}

ITEM_CHANGE_TYPE = {
	ITEM_CHANGE_TYPE_SNEAKY_IN = -4,				-- 偷偷的放入 不需要通知玩家获得 当脱下装备和宝石镶嵌惩罚时使用这个
	ITEM_CHANGE_TYPE_CHANGE = -3,	 				-- 发生改变
	ITEM_CHANGE_TYPE_OUT = -2,	 					-- 从背包进入外部
	ITEM_CHANGE_TYPE_IN = -1,	 					-- 从外部进入背包
	-- 0以上表示是从背包/仓库的其他格子里移动过来/去 值表示原来的下标
}

PRODUCT_ID_TRIGGER = {
	PRODUCT_ID_TRIGGER_SPECIAL_DICI = 1200,				-- 地刺
	PRODUCT_ID_TRIGGER_SPECIAL_BEILAO = 1201,			-- 焙烙
	PRODUCT_ID_TRIGGER_SPECIAL_BANMASUO = 1202,			-- 绊马索
	PRODUCT_ID_TRIGGER_SPECIAL_ICE_LANDMINE = 1203,		-- 冰霜地雷
	PRODUCT_ID_TRIGGER_SPECIAL_FIRE_LANDMINE = 1204,	-- 火焰地雷


	CLIENT_SHANDIANXIAN_LINE = 100001,					-- 闪电线
}

GUILD_SINGIN_REQ_TYPE = {
	GUILD_SINGIN_REQ_TYPE_SIGNIN = 0,               	-- 签到
	GUILD_SINGIN_REQ_TYPE_FETCH_REWARD = 1,             -- 拿奖励 p1 index
	GUILD_SINGIN_REQ_ALL_INFO = 2,                  	-- 请求所有信息
}

--红包类型
RED_PAPER_TYPE = {					
	RED_PAPER_TYPE_INVALID = 0,
	RED_PAPER_TYPE_COMMON = 1, 		--普通
	RED_PAPER_TYPE_RAND = 2,		--拼手气
	RED_PAPER_TYPE_GLOBAL = 3,		--全服
	RED_PAPER_TYPE_GUILD = 4,		--公会
	RED_PAPER_TYPE_COMMAND_SPEAKER = 5,		--口令
	RED_PAPER_TYPE_MAX,
}

--红包通知类型
RED_PAPER_NOTIFY_REASON = {				
	NOTIFY_REASON_FETCH_SUCC = 0,			--拿取红包成功
	NOTIFY_REASON_HAS_FETCH = 1,			--有红包拿
	NOTIFY_REASON_NO_FETCH_TIMES = 2,		--红包被抢完
	NOTIFY_REASON_FAIL = 3,					--红包失效

	NOTIFY_REASON_MAX,
}

CHAT_OPENLEVEL_LIMIT_TYPE = {
	WORLD = 0,
	CAMP = 1,
	SCENE = 2,
	TEAM = 3,
	GUILD = 4,
	SINGLE = 5,
	SEND_MAIL = 6,

	MAX = 7,
}

PUT_REASON_TYPE = {
	PUT_REASON_INVALID = 0,							-- 无效
	PUT_REASON_NO_NOTICE = 1,						-- 不通知
	PUT_REASON_GM = 2,								-- GM命令
	PUT_REASON_PICK = 3,							-- 捡取掉落
	PUT_REASON_GIFT = 4,							-- 礼包打开
	PUT_REASON_COMPOSE = 5,							-- 合成产生
	PUT_REASON_TASK_REWARD = 6,						-- 任务奖励
	PUT_REASON_MAIL_RECEIVE = 7,					-- 邮件
	PUT_REASON_CHEST_SHOP = 8,						-- 宝箱
	PUT_REASON_RANDOM_CAMP = 9,						-- 听天由命礼包
	PUT_REASON_SHOP_BUY = 10,						-- 商城购买
	PUT_REASON_WELFARE = 11,						-- 福利
	PUT_REASON_ACTIVE_DEGREE = 12,					-- 活跃度
	PUT_REASON_CONVERT_SHOP = 13,					-- 兑换商店
	PUT_REASON_ZHUXIE_ACTIVITY_REWARD = 14,			-- 诛邪战场奖励
	PUT_REASON_FB_TOWERDEFEND_TEAM = 15,			-- 多人塔防副本
	PUT_REASON_SEVEN_DAY_LOGIN_REWARD = 16,			-- 七天登录活动奖励
	PUT_REASON_YAOJIANG = 17,						-- 摇奖
	PUT_REASON_ACTIVITY_FIND = 18,					-- 活动找回
	PUT_REASON_NEQ_STAR_REWARD = 19,				-- 新装备本星星奖励
	PUT_REASON_NEQ_AUTO = 20,						-- 新装备本扫荡
	PUT_REASON_NEQ_ROLL = 21,						-- 新装备本翻牌
	PUT_REASON_MAZE = 22,							-- 迷宫寻宝
	PUT_REASON_EXP_FB = 23,							-- 经验副本
	PUT_REASON_CHALLENGE_FB = 24,					-- 挑战副本
	PUT_REASON_VIP_LEVEL_REWARD = 25,				-- VIP等级奖励
	PUT_REASON_QIFU_TIMES_REWARD = 26,				-- 祈福次数奖励
	PUT_REASON_GUILD_TASK_REWARD = 27,				-- 仙盟任务奖励
	PUT_REASON_CHONGZHI_ACTIVITY = 28,				-- 充值活动
	PUT_REASON_OPENGAME_ACTIVITY = 29,				-- 开服活动
	PUT_REASON_DISCOUNT_BUY = 30,					-- 一折抢购
	PUT_REASON_LUCKYROLL = 31,						-- 幸运转盘
	PUT_REASON_DAILY_TASK_REWARD = 33,				-- 每日任务奖励
	PUT_REASPN_PHASE_AUTO = 39,						-- 阶段本扫荡奖励

	PUT_REASON_LUCKYROLL_EXTRAL = 40,			 	-- 幸运转盘额外奖励
	PUT_REASON_LUCKYROLL_CS = 79,			 		-- 合服活动幸运转盘
	PUT_REASON_ZHUXIE_GATHER = 96,					-- 诛邪采集获得
	PUT_REASON_EXP_BOTTLE = 97,						-- 凝聚经验
	PUT_REASON_GCZ_DAILY_REWARD = 98,				-- 攻城战每日奖励
	PUT_REASON_LIFE_SKILL_MAKE= 99,					-- 生活技能制造
	PUT_REASON_PAOHUAN_ROLL = 100,					-- 跑环任务翻牌
	PUT_REASON_GUILD_STORE = 101,					-- 从公会仓库取出
	PUT_REASON_RA_LEVEL_LOTTERY = 105,				-- 金银塔活动奖励
	PUT_REASON_RA_MONEY_TREE_REWARD= 111,			-- 转转乐随机奖励
	PUT_REASON_LITTLE_PET_CHOUJIANG_ONE = 162,		--小宠物抽奖1连
	PUT_REASON_LITTLE_PET_CHOUJIANG_TEN = 163,		--小宠物抽奖10连
	PUT_REASON_GUILD_BOX_REWARD = 186,				-- 开启公会宝箱奖励
	PUT_REASON_SZLQ_OPEN_BOX_REWARD = 191,			-- 魂器打开宝藏
	PUT_REASON_ZODIAC_GGL_REWARD = 193,				-- 星座摇奖机
	PUT_REASON_WABAO = 32,							-- 挖宝
	PUT_REASON_ZHIXIAN_TASK_REWARD = 198,			-- 支线任务
	PUT_REASON_DAILY_TASK_DRAW = 210, 				-- 日常任务抽奖
	PUT_REASON_MAP_HUNT_BAST_REWARD = 260,			-- 地图寻宝最终奖励
	PUT_REASON_MAP_HUNT_BASE_REWARD = 261,			-- 地图寻宝基础奖励
	PUT_REASON_LUCKYCHESS_REWARD = 262,				-- 幸运棋
	PUT_REASON_LUCKY_TURNTABLE_REWARD = 270,		--幸运转盘
	PUT_REASON_RA_DAILY_XIANGOULIBAO = 286,			--每日限购
	PUT_REASON_ADVENTURE_SHOP_REWARD = 288,			-- 奇遇商店
}

--固定的错误码，直接在收到错误码时处理，简单粗暴
FIX_ERROR_CODE =
{
	EN_GET_ACCOUNT_GOLD_TOO_FAST = 100000,			--从账号提取元宝间隔时间不足
	EN_COIN_NOT_ENOUGH = 100001,					--铜币不足
	EN_GOLD_NOT_ENOUGH = 100002,					--您元宝不足，请前往充值！
	EN_BIND_GOLD_NOT_ENOUGH = 100003,				--绑定元宝不足
	EN_MONEY_IS_LOCK = 100004,						--金钱已经锁定
	EN_ROLE_ZHENQI_NOT_ENOUGH = 100005,				--仙魂不足
	EN_XIANNV_EXP_DAN_LIMIT = 100006,				--仙女经验丹不足
	EN_CONVERTSHOP_BATTLE_FIELD_HONOR_LESS = 100007, --战场荣誉不足
	EN_SHENGWANG_SHENGWANG_NOT_ENOUGH = 100010, 		--竞技场声望不足
}

--传闻链接类型
CHAT_LINK_TYPE = {
	GUILD_APPLY = 0,								-- 申请加入 仙盟申请
	EQUIP_QIANG_HUA = 3,							-- 我要强化 装备强化
	MOUNTJINJIE = 4,								-- 我要进阶 坐骑进阶
	HUSONG = 5,										-- 我要护送
	EQUIP_UP_STAR =6,								-- 我要升星 装备升星
	GUILD_JUANXIAN =7,								-- 我要捐献
	EQUIP_FULING = 8,								-- 我要附灵 装备附灵
	MOUNT_LIEHUN = 9,								-- 我要猎魂 坐骑猎魂
	JINGLING_UPLEVEL = 10,							-- 我要升级 精灵升级
	ACHIEVE_UP = 11,								-- 我要提升 成就提升
	EQUIP_JICHENG = 12,								-- 我要继承 装备继承
	XIANJIE_UP = 13,								-- 我要提升 仙阶提升
	PaTa = 14,										-- 我要挑战 爬塔
	GENGU = 15,										-- 我要提升根骨
	JINGMAI = 16,									-- 我要提升经脉
	SPRITE_FLY = 17,								-- 我要精灵进阶
	EQUIP_UPLEVEL =18,								-- 我要进阶 装备进阶
	FORGE_EQUIP_UPLEVEL =19,						-- 我要升级 神铸装备升级
	ROLE_BAOSHI = 20,								-- 我要镶嵌 宝石镶嵌
	SHEN_GRADE = 21,								-- 我要神装进阶
	ROLE_WINGUP =22,								-- 我要进阶 羽翼进阶
	HALO_UPGRADE = 23,								-- 我要进阶 光环进阶
	SHENGONG_UPGRADE = 24,							-- 我要进阶 神弓进阶
	VIP =25,										-- 成为vip
	SHENYI_UPGRADE = 26,							-- 我要进阶 神翼进阶
	FIGHT_MOUNT_UPGRADE = 27,						-- 我要进阶 战斗坐骑进阶
	KF_BOSS = 28,									-- 立即前往 kfboss
	BONFRIE = 29,									-- 立即前往 篝火
	BOSS_WORLD = 30,								-- 前往击杀 世界boss
	BOSS_JINGYING = 31,								-- 前往击杀 精英boss
	XUNBAO = 32,									-- 我要寻宝
	SPIRIT_XUNBAO = 33,								-- 精灵寻宝
	GUILD_WELLCOME = 34,							-- 公会入会欢迎语
	GUILD_MIJING = 36,								-- 公会试练
	MAGIC_WEAPON_VIEW = 37,							-- 魔器 前往夺宝
	ZHI_ZUN_YUE_KA = 38,							-- 变身至尊 至尊月卡
	SUI_JI_CHOU_JIANG = 39,							-- 我要抽奖 幸运转盘
	DA_FU_HAO = 40,									-- 立即前往 大富豪
	CAN_JIA_HUN_YAN = 41,							-- 我要参加 参加婚宴
	WO_QIUHUN = 42,									-- 我要求婚
	FAZHEN_UP = 43,									-- 我要进阶 法阵进阶
	GUILD_CALLIN = 44,								-- 公会邀请
	MOUNT_FLY = 45,									-- 我要飞升 坐骑飞升
	WO_CHONGZHI = 46,								-- 我要充值
	WO_HUNQI_DAMO = 47,								-- 我要铸魂
	DAY_DANBI = 48,									-- 查看活动 单笔充值
	ZHENBAOGE = 50,									-- 珍宝阁
	WO_LINGYU_FB = 51,								-- 灵玉副本 我要挑战
	MIJINGTAOBAO = 52,								-- 秘境淘宝
	WO_LOTTERYTREE = 53,							-- 摇一摇
	WO_KINGDRAW = 54,								-- 陛下请翻牌
	WO_LINGQI = 55,									-- 灵器
	WO_LIEQU = 56,                                  -- 黄金猎场
	DIVINATION = 57,                                -- 天命卜卦
	WO_FANFANZHUAN = 58,                            -- 翻翻转
	WO_FARM_HUNT = 59,                              -- 牧场抽奖
	WO_MULTIMOUNT = 60,								-- 双人坐骑进阶
	-- WO_QINGYUANFUBEN = 100, 						-- 接受情缘副本邀请
	WO_MAGIC_CARD = 61,                              -- 我要魔卡
	WO_JINGLING_HALO = 62,                          -- 精灵光环
	WO_TREASURE_BUSINESSMAN = 63,                   -- 仙宝商人
	WO_MOUNTJINGPO = 64,                  			-- 坐骑精魄
	CROSS_FB_TEAMMATE = 65,                  		-- 跨服组队招募队员
	TOMB_BOSS = 66,                  				-- 击杀皇陵探险BOSS
	SPIRIT_FAZHEN = 67,                  			-- 精灵法阵
	TIANSHEN_ZHUANGBEI = 68,                  		-- 天神装备
	MARRY_TUODAN = 69,                  			-- 我要脱单
	WO_COMPOSE = 70,                  				-- 我要合成
	WO_RUNE = 71,                  					-- 我要符文
	XING_ZUO_YI_JI = 74,                  			-- 星座遗迹 立即前往
	TOTAL_CHONG_ZHI = 76,                  			-- 累计充值
	WO_DAILY_RECHARGE = 77,                  		-- 每日累冲 前往查看
	SHEN_BING = 78,                  				-- 神兵 我要升级
	SHEN_GE_BLESS = 79,                  			-- 神格 祈福
	SHEN_GE_COMPOSE = 80,                  			-- 神格 合成
	SHENGXIAO_TU = 81,                  			-- 生肖 拼图
	WO_LEVEL_TOUZHI = 82,                  			-- 等级投资 我要投资
	WO_YUE_TOUZHI = 83,                  			-- 月卡投资 我要投资
	WO_ZERO_GIFT = 84,                  			-- 零元礼包 我要领取
	WO_FENG_SHEN = 85,                  			-- 封神之路 我要封神
	WO_DISCOUNT = 86,                  				-- 一折抢购 我要抢购
	WO_TEMP_GIFT = 87,                  			-- 限时礼包 我要抢购
	WO_SHEN_GE = 89,								-- 神格升级
	SHOUHUDCHEN = 90,								-- 守护大臣
	BAOHUQINGBAO = 91,								-- 保护情报
	BAOHUZHUANKUAI = 92,							-- 保护砖块
	SHOUHUGUOQI = 94,								-- 守护国旗	
	GODDESS_SHENGWU = 95,			 				-- 女神圣物，我要升级
	GODDESS_GONGMING = 96,							-- 女神法则，我要升级
	XUFUCILI = 97,									-- 徐福赐礼
	FAZHEN_GRADE = 98, 								-- 形象 法阵
	KF_MINING = 99,									-- 跨服挖矿
	YUNBIAOSUPPORT = 100, 							-- 运镖支援
	TIME_LIMIT = 105,								-- 限时秒杀
	WO_ZHANG_KONG = 106,							-- 神格掌控
	PROTECT_TOWER = 107,							-- 保护气运塔
	WO_XIULIAN = 110,								-- 我要修炼
	WO_ZHULING = 112,								-- 八卦注灵
	WO_XILIAN = 113,								-- 美人洗炼
	JINYINTA = 114,									-- 金银塔
	LUCKYCHESS = 115,								-- 幸运棋
	JUBAOPEN = 116,									-- 我要聚宝
	SERVER_FLAG = 117,								-- 阵营旗帜
	HAPPY_LOTTERY = 118,							-- 欢乐抽
	SERVER_JUDIAN = 119,							-- 据点抢夺
	LOTTETY_BET = 120, 								-- 纸醉金迷
	MIDAUTUMNLOTTERY = 121,                         -- 月饼大作战
	MUSEUM_CARD = 122,                       	 	-- 博物志卡牌
	HEAD_WEAR = 123,								-- 头饰
	MASK = 124,										-- 面饰
	WAIST = 125,									-- 腰饰
	KIRIN_ARM = 126,								-- 麒麟臂
	BEAD = 127,										-- 灵珠
	FA_BAO = 128,									-- 法宝
	LUCKY_BOX = 129,									-- 幸运宝箱

	LUCKY_TURN_EGG = 130,							-- 幸运扭蛋机
	DASHE_TIAN_XIA = 131,							--大射天下

	-- 1000开头客户端自己的传闻
	GODDESS_INFO = 1000,							-- 女神假传闻
}

FLYING_PROCESS_TYPE = {
	NONE_FLYING = 0,
	FLYING_UP = 1,
	FLYING_IN_MAX_HEIGHT = 2,
	FLYING_DOWN = 3,
}

MOVE_MODE = {
	MOVE_MODE_NORMAL = 0,										--正常
	MOVE_MODE_FLY = 1,											--飞行
	MOVE_MODE_JUMP = 2,											--跳跃
	MOVE_MODE_JUMP2 = 3,										--跳跃2
	MOVE_MODE_MAX = 4,
}

MOVE_MODE_FLY_PARAM = {
	MOVE_MODE_FLY_PARAM_INVALID = 0,
	MOVE_MODE_FLY_PARAM_DRAGON = 1,								--龙
	MOVE_MODE_FLY_PARAM_QILIN = 2,								--麒麟
}

SPECIAL_APPEARANCE_TYPE = {
	SPECIAL_APPEARANCE_TYPE_NORMAL = 0,
	SPECIAL_APPERANCE_TYPE_WORD_EVENT_YURENCARD = 1,            -- 世界事件愚人卡外观
	SPECIAL_APPERANCE_TYPE_GREATE_SOLDIER = 2,					-- 名将变身
	SPECIAL_APPERANCE_TYPE_HUASHENG = 3,						-- 化神外观
	SPECIAL_APPERANCE_TYPE_TERRITORYWAR = 4,					-- 领土战外观
	SPECIAL_APPERANCE_TYPE_CROSS_HOTSPRING = 5,					-- 跨服温泉外观
	SPECIAL_APPERANCE_TYPE_CROSS_MINING = 6,					-- 跨服挖矿外观
	SPECIAL_APPEARANCE_TYPE_CROSS_FISHING = 7,					-- 跨服钓鱼外观
	SPECIAL_APPEARANCE_TYPE_HUNYAN = 8,							-- 婚宴外观
	SPECIAL_APPEARANCE_TYPE_SHNEQI = 9, 						-- 神器变身外观
	SPECIAL_APPEARANCE_TYPE_BIANSHEN = 10,						-- 战场变身
	SPECIAL_APPEARANCE_TYPE_CAPTURE_CAPTIVE = 11,				-- 抓俘虏（咸阳城形象）

	SPECIAL_APPEARANCE_TYPE_ZHUQUE = 101,						--朱雀
	SPECIAL_APPEARANCE_TYPE_XUANWU = 102,
	SPECIAL_APPEARANCE_TYPE_QINGLONG = 103,
}

MONSTER_SPECIAL_PARAM = {
	MONSTER_SPECIAL_PARAM_INVALID = 0,
	MONSTER_SPECIAL_PARAM_MONSTER_SIEGE_ATTACK = 100,
	MONSTER_SPECIAL_PARAM_MONSTER_SIEGE_TOWER = 101,
	MONSTER_SPECIAL_PARAM_CAPTIVE_MALE = 110,					-- 咸阳城-男俘虏
	MONSTER_SPECIAL_PARAM_CAPTIVE_FEMALE = 111,					-- 咸阳城-女俘虏
	MONSTER_SPECIAL_PARAM_CAMP_TOTEM_PILLAR = 200,
	MONSTER_SPECIAL_PARAM_CAMP_TOTEM_PILLAR_END = 210,
}

HUNYAN_NOTIFY_REASON = {
	HUNYAN_NOTIFY_REASON_STATE_CHANGE = 0,				-- 状态改变
	HUNYAN_NOTIFY_REASON_ENTER_HUNYAN = 1,				-- 进入婚宴
	HUNYAN_NOTIFY_REASON_LOGIN = 2,						-- 上线
	HUNYAN_NOTIFY_REASON_INVITE_FRIEND = 3,				-- 邀请好友
	HUNYAN_NOTIFY_REASON_INVITE_GUILD = 4,				-- 邀请仙盟好友
	HUNYAN_NOTIFY_REASON_GATHER = 5,					-- 采集
	HUNYAN_NOTIFY_REASON_GIVE_HONGBAO = 6,				-- 发红包
}

TUODAN_OPERA_TYPE = {
	TUODAN_INSERT = 0,								--脱单信息插入(更新)
	TUODAN_DELETE = 1,								--脱单信息删除
}

SKILL_PERFOM_TYPE = {
	NONE = 0,											--不能释放
	AIM_TARGET = 1,										--瞄准目标
	DIRECT = 2,											--直接释放
}

SPEAKER_TYPE = {
	SPEAKER_TYPE_LOCAL = 0,								-- 本服喇叭
	SPEAKER_TYPE_CROSS = 1,								-- 跨服传音

	SPEAKER_TYPE_KOULING = 100,							-- 口令红包
	SSPEAKER_TYPE_MAX = 2,
}

LIEMING_HUNSHOU_OPERA_TYPE = {							-- 猎命操作类型
	INVALID = 0,
	CHOUHUN = 1,
	SUPER_CHOUHUN = 2,
	BATCH_HUNSHOU = 3,
	SPECIAL_BATCH_HUNSHOU = 4,
	PUT_BAG = 5,
	CONVERT_TO_EXP = 6,
	MERGE = 7,
	SINGLE_CONVERT_TO_EXP = 8,
	TAKEON = 9,
	TAKEOFF = 10,
	FUHUN_ADD_EXP = 11,
	PUT_BAG_ONE_KEY = 12,
	EXCHANGE = 13,										-- 把命魂池里面的命魂和命魂槽的交换

	OPERA_TYPE_MAX = 14,
}

JINGLING_OPER_TYPE = {						-- 精灵操作类型
	JINGLING_OPER_TAKEOFF = 0,				-- 取下
	JINGLING_OPER_CALLBACK = 1,				-- 召回
	JINGLING_OPER_FIGHTOUT = 2,				-- 出战
	JINGLING_OPER_UPLEVEL = 3,				-- 升级
	JINGLING_OPER_UPLEVELCARD = 4,			-- 升级卡牌
	JINGLING_OPER_RENAME = 5,				-- 精灵改名
	JINGLING_OPER_UPGRADE = 6,				-- 升阶
	JINGLING_OPER_STRENGTH = 7,				-- 强化装备
	JINGLING_OPER_USEIMAGE = 8,				-- 使用形象
	JINGLING_OPER_PHANTOM =	9,				-- 使用幻化形象
	JINGLING_OPER_UPPHANTOM = 10,			-- 幻化形象升级
	JINGLING_OPER_UPGRADESOUL = 11,         --聚灵升级
	JINGLING_OPER_UPGRADE_HALO = 12,		--精灵光环
	JINGLING_OPER_USE_HALO_IMG = 13,		--选择光环
	JINGLING_OPER_ONEKEY_RECYCL_BAG = 14,		-- 一键回收背包精灵
	JINGLING_OPER_UPLEVEL_WUXING = 15,		-- 升级悟性,param1 精灵索引,param2 是否使用保护符,param3 是否自动购买
	JINGLING_OPER_UPLEVEL_XIANZHEN = 16,	-- 升级仙阵
	JINGLING_OPER_UPLEVEL_HUNYU = 17,		-- 升级魂玉,param1 魂玉类型
	JINGLING_OPER_REMOVE_SKILL = 18,		-- 技能 遗忘,param1 精灵索引,param2 技能索引,param3 是否自动购买
	JINGLING_OPER_CHANGE_MOVE = 19,			-- 技能 变成可移动,param1 精灵索引,param2 技能索引,param3 是否自动购买
	JINGLING_OPER_PUT_ON_SKILL = 20,		-- 技能 穿戴,param1 精灵索引,param2 技能索引,param3 技能仓库索引
	JINGLING_OPER_TAKE_OFF_SKILL = 21,		-- 技能 脱下,param1 精灵索引,param2 技能索引,param3 技能仓库索引
	JINGLING_OPER_LEARN_SKILL = 22,			-- 技能 学习,param1 精灵索引,param2 技能索引,param3 物品索引
	JINGLING_OPER_REFRESH = 23,				-- 技能 刷新,param1 刷新索引,param2 是否10连刷
	JINGLING_OPER_GET = 24,					-- 技能 获取,param1 刷新索引,param2 技能索引
	JINGLING_OPER_REFRESH_ACTIVE = 25,		-- 技能 刷新激活,param1 刷新索引
}

--小宠物操作类型
LITTLE_PET_REQ_TYPE = {
	LITTLE_PET_REQ_INTENSIFY_SELF = 0,						-- 强化自己宠物 param1 宠物索引 param2 强化点索引 param3格子索引 (ug05弃用)
	LITTLE_PET_REQ_INTENSIFY_LOVER = 1,						-- 强化爱人宠物 param1 宠物索引 param2 强化点索引 param3格子索引 (ug05弃用)
	LITTLE_PET_REQ_CHOUJIANG = 2,							-- 抽奖	param1  1:10
	LITTLE_PET_REQ_RECYCLE = 3,								-- 回收	param1 物品id param2 物品数量 param3 是否绑定 1:0 默认绑定 (ug05弃用)
	LITTLE_PET_REQ_RELIVE = 4,								-- 放生	param1 宠物索引(ug05弃用)
    LITTLE_PET_REQ_FEED = 5 ,                               -- 喂养自己宠物 param1 宠物索引 , param2 自己：伴侣 1：0 param3:是否自动购买
	LITTLE_PET_REQ_PET_FRIEND_INFO = 6,						-- 宠友信息
	LITTLE_PET_REQ_INTERACT = 7,							-- 互动 param1 宠物索引 param2 目标role uid param3 自己:伴侣 1:0 (ug05弃用)
	LITTLE_PET_REQ_EXCHANGE = 8,							-- 兑换 param1 兑换物品索引 param2 数量
	LITTLE_PET_REQ_CHANGE_PET = 9,							-- 换宠 param1 宠物索引 param2 使用的物品id (ug05弃用)
	LITTLE_PET_REQ_USING_PET = 10,							-- 使用形象 param1 形象id (暂时无用)
	LITTLE_PET_REQ_FRIEND_PET_LIST = 11,					-- 好友小宠物列表 param1 朋友uid
	LITTLE_PET_REQ_INTERACT_LOG = 12,						-- 互动记录 (ug05弃用)
	LITTLE_PET_PUTON = 13,									-- 装备小宠物 param1:宠物下标 param2:背包宠物index
	LITTLE_PET_TAKEOFF = 14,								-- 卸下小宠物 param1:宠物下标
	LITTLE_PET_REQ_EQUIPMENT_PUTON = 15,					-- 小宠物穿戴装备 param1:宠物下标 param2:背包index
	LITTLE_PET_REQ_EQUIPMENT_TAKEOFF = 16,					-- 小宠物脱下装备 param1:宠物下标 param2:装备index
	LITTLE_PET_REQ_EQUIPMENT_UPLEVEL_SELF = 17,				-- 自己小宠物装备升级  param1 宠物下标 param2 装备下标(从0开始) param3 是否自动购买
	LITTLE_PET_REQ_EQUIPMENT_UPLEVEL_LOVER = 18,			-- 爱人小宠物装备升级  param1 宠物下标 param2 装备下标(从0开始) param3 是否自动购买
	LITTEL_PET_REQ_WALK = 19,								-- 溜宠物 param1 玩家是否idle动作 0不是 1是
}

--小宠物相关操作类型
LITTLE_PET_NOTIFY_INFO_TYPE = {
	LITTLE_PET_NOTIFY_INFO_SCORE = 0,											--param1 积分信息
	LITTLE_PET_NOTIFY_INFO_FREE_CHOU_TIMESTAMP = 1,								--param1 免费抽奖时间戳
	LITTLE_PET_NOTIFY_INFO_INTERACT_TIMES = 2,									--param1 玩家互动次数
	LITTLE_PET_NOTIFY_INFO_FEED_DEGREE = 3,										--param1 宠物索引, param2 饱食度, param3 自己:伴侣  1:0
	LITTLE_PET_NOTIFY_INFO_PET_INTERACT_TIMES = 4,					 			--param1 宠物互动次数
}
-- JINGLING_TALENT_TYPE = {
-- 	JL_TALENT_INVALID_TYPE = 0,
-- 	JL_TALENT_GONGJI = 1,
-- 	JL_TALENT_FANGYU = 2,
-- 	JL_TALENT_MAXHP = 3,
-- 	JL_TALENT_MINGZHONG = 4,
-- 	JL_TALENT_SHANGBI = 5,
-- 	JL_TALENT_BAOJI = 6,
-- 	JL_TALENT_JIANREN = 7,
-- 	JL_TALENT_JINGZHUN_PER = 8,
-- 	JL_TALENT_BAOJI_PER = 9,
-- 	JL_TALENT_POFANG_PER = 10,
-- 	JL_TALENT_MIANSHANG_PER = 11,
-- 	JL_TALENT_MAX_TYPE = 12,
-- }

SHENGXIAO_MIJI_TYPE = {
	[0] = "maxhp",
	[1] = "gongji",
	[2] = "fangyu",
	[3] = "baoji",
	[4] = "jianren",
	[5] = "mingzhong",
	[6] = "shanbi",
	[7] = "goddess_gongji",
	[8] = "constant_zengshang",
	[9] = "constant_mianshang",
}
SHENGXIAO_MIJI_ATTR_NAME = {
	maxhp = "气血",
	gongji = "攻击",
	fangyu = "防御",
	baoji = "暴击",
	jianren = "抗暴",
	mingzhong = "命中",
	shanbi = "闪避",
	goddess_gongji = "女神攻击",
	constant_zengshang = "固定增伤",
	constant_mianshang = "固定免伤",
}

JINGLING_TALENT_TYPE = {
	[1] = "gongji",
	[2] = "fangyu",
	[3] = "maxhp",
	[4] = "mingzhong",
	[5] = "shanbi",
	[6] = "baoji",
	[7] = "jianren",
	[8] = "per_jingzhun",
	[9] = "per_baoji",
	[10] = "per_pofang",
	[11] = "per_mianshang",
}

JINGLING_TALENT_ATTR_NAME = {
	gongji = "攻击",
	fangyu = "防御",
	maxhp = "生命",
	mingzhong = "命中",
	shanbi = "闪避",
	baoji = "暴击",
	jianren = "抗暴",
	per_jingzhun = "破甲",
	per_baoji = "暴伤",
	per_pofang = "增伤",
	per_mianshang = "免伤",
}

TEAM_ASSIGN_MODE = {
	TEAM_ASSIGN_MODE_KILL = 1,					-- 谁击杀谁得
	TEAM_ASSIGN_MODE_RANDOM = 2,				-- 随机分配模式
}

SHENGWANG_OPERA_TYPE = {						-- 声望操作类型
	SHENGWANG_OPERA_REQ_INFO = 0,				-- 请求声望相关信息
	SHENGWANG_OPERA_XIANJIE_UPLEVEL = 1,		-- 仙阶升级
	SHENGWANG_OPERA_XIANDAN_UPLEVEL = 2,		-- 仙丹升级
}

RA_HAPPY_DRAW2_OPERA_TYPE = {
	RA_HAPPY_DRAW2_OPERA_TYPE_RARE_RANK_INFO = 0,    -- 月饼大作战请求所有信息 
	RA_HAPPY_DRAW2_OPERA_TYPE_DRAW = 1,				 -- 十连抽 			
	RA_HAPPY_DRAW2_OPERA_TYPE_INFO = 2,				 -- 个人活动信息
}

CHENGJIU_OPER_TYPE = {
	CHENGJIU_REQ_INFO = 0,						-- 请求成就信息
	CHENGJIU_OPER_TITLE_UPLEVEL = 1,			-- 提升称号
	CHENGJIU_OPER_FETCH_REWARD = 2,				-- 领取奖励
	CHENGJIU_OPER_FUWEN_UPLEVEL = 3,	 		-- 提升符文
}

CHEST_SHOP_TYPE = {
	CHEST_SHOP_TYPE_EQUIP = 1,						-- 装备类型宝箱抽奖
	CHEST_SHOP_TYPE_JINGLING = 2,					-- 精灵类型宝箱抽奖
	CHEST_SHOP_TYPE_SUPER = 3,                      -- 至尊寻宝
}

REALIVE_TYPE = {
	REALIVE_TYPE_HERE_CAMP = 0,						-- 国家复活
	REALIVE_TYPE_HERE_STUFF = 1,					-- 复活石复活
	REALIVE_TYPE_HERE_BIND_GOLD = 2,				-- 使用绑元原地复活
	REALIVE_TYPE_HERE_GOLD = 3,						-- 使用元宝原地复活
	REALIVE_TYPE_BACK_HOME = 4,						-- 回城复活

}

--{第几次复活，所需铜币}
DAY_REVIVAL_TIMES = {
	{1, 200000},
	{6, 300000},
	{11, 400000},
	{16, 500000},
	{21, 600000},
	{26, 700000},
	{31, 800000},
	{36, 900000},
	{41, 1000000},
}

SCORE_TO_ITEM_TYPE = {
	INVALID = 0,
	GOUYU = 1,											-- 勾玉兑换
	NORMAL_ITEM = 2,									-- 道具兑换
	EQUIP = 3,											-- 装备兑换

	CS_EQUIP1 = 4,										-- 装备寻宝商店兑换1		 6仙品 幸运
	CS_EQUIP2 = 5,										-- 装备寻宝商店兑换2		 6仙品
	CS_EQUIP3 = 6,										-- 装备寻宝商店道具兑换3

	CS_JINGLING1 = 7,									-- 精灵寻宝商店兑换1
	CS_JINGLING2 = 8,									-- 精灵寻宝商店兑换2

	CS_MEDCHINE = 9,									-- 药店兑换购买

	CS_HUOLI = 10,										-- 活力

	MAX = 11,
}

TEAM_FB_OPERAT_TYPE = {
	REQ_ROOM_LIST = 1,			-- 请求房间列表
	CREATE_ROOM = 2,			-- 创建房间
	JOIN_ROOM = 3,				-- 加入指定房间
	START_ROOM = 4,				-- 开始
	EXIT_ROOM = 5,				-- 退出房间
	CHANGE_MODE = 6,			-- 改变模式
	KICK_OUT = 7,				-- T人
}

MIGONGXIANFU_LAYER_TYPE = {
	MGXF_LAYER_TYPE_NORMAL = 0,							-- 普通层
	MGXF_LAYER_TYPE_BOSS = 1,							-- Boss层
	MGXF_LAYER_TYPE_HIDE = 2,							-- 隐藏层
}

MIGONGXIANFU_STATUS_TYPE = {
	MGXF_DOOR_STATUS_NONE = 0,
	MGXF_DOOR_STATUS_TO_PRVE = 1,
	MGXF_DOOR_STATUS_TO_HERE = 2,
	MGXF_DOOR_STATUS_TO_NEXT = 3,
	MGXF_DOOR_STATUS_TO_HIDE = 4,
	MGXF_DOOR_STATUS_TO_BOSS = 5,
	MGXF_DOOR_STATUS_TO_FIRST = 6,
}

LIFE_SKILL_OPERAT_TYPE = {
	LIFE_SKILL_OPERAT_TYPE_REQ_INFO = 0,				-- 生活技能请求信息
	LIFE_SKILL_OPERAT_TYPE_UPLEVEL = 1,					-- 生活技能升级
	LIFE_SKILL_OPERAT_TYPE_MAKE = 2,					-- 生活技能制作物品
}

-- 公会骰子
GUILD_PAWN = {
	MAX_MEMBER_COUNT = 60,									-- 公会人数上限

}

-- 精灵配置天赋
JL_GAY_WAY = {
	LIBAO = 1
}

CHAT_WIN_REQ_TYPE = {
	PERSONALIZE_WINDOW_ALL_INFO = 0,				--个性化窗口信息
	PERSONALIZE_WINDOW_CONSUME_ITEM = 1,
	PERSONALIZE_WINDOW_USE_RIM = 2,
	PERSONALIZE_WINDOW_ACTIVE_BUBBLE_RIM_SUIT = 3,	-- 激活气泡框一个套装部位，参数1套装seq，参数2套装部位part
	PERSONALIZE_WINDOW_ACTIVE_BUBBLE_RIM = 4,		-- 激活气泡框，参数1气泡框seq
	PERSONALIZE_WINDOW_USE_BUBBLE_RIM = 5,			-- 使用气泡框，参数1气泡框seq
}

-- 卡牌操作
CARD_OPERATE_TYPE = {
	REQ = 0,				-- 请求信息
	INLAY = 1,			-- 镶嵌
	UPLEVEL = 2,			-- 升级
	KEY_UPLEVEL = 3,		-- 一键升级
}

-- 战斗力类型
CAPABILITY_TYPE = {
	CAPABILITY_TYPE_INVALID = 0,

	CAPABILITY_TYPE_BASE = 1,				-- 基础属性战斗力
	CAPABILITY_TYPE_MENTALITY = 2,			-- 元神属性战斗力
	CAPABILITY_TYPE_EQUIPMENT =3 ,			-- 装备属性战斗力
	CAPABILITY_TYPE_WING = 4,				-- 羽翼属性战斗力
	CAPABILITY_TYPE_MOUNT5 = 5,				-- 坐骑属性战斗力
	CAPABILITY_TYPE_TITLE = 6,				-- 称号属性战斗力
	CAPABILITY_TYPE_SKILL = 7,				-- 技能属性战斗力
	CAPABILITY_TYPE_XIANJIAN = 8,			-- 仙剑属性战斗力
	CAPABILITY_TYPE_XIANSHU = 9,			-- 仙盟仙术属性战斗力
	CAPABILITY_TYPE_GEM = 10,				-- 宝石战斗力
	CAPABILITY_TYPE_XIANNV = 11,			-- 仙女属性战斗力
	CAPABILITY_TYPE_FOOTPRINT = 12,			-- 足迹属性战斗力
	CAPABILITY_TYPE_QINGYUAN = 13,			-- 情缘属性战斗力
	CAPABILITY_TYPE_ZHANSHENDIAN = 14,		-- 战神殿属性战斗力
	CAPABILITY_TYPE_SHIZHUANG = 15,			-- 时装属性战斗力
	CAPABILITY_TYPE_ATTR_PER = 16,			-- 基础属性百分比加的战斗力
	CAPABILITY_TYPE_JINGLING = 17,			-- 精灵战力
	CAPABILITY_TYPE_VIPBUFF = 18,			-- vipbuff战力
	CAPABILITY_TYPE_SHENGWANG = 19,			-- 声望
	CAPABILITY_TYPE_CHENGJIU = 20,			-- 成就
	CAPABILITY_TYPE_WASH = 21,				-- 洗练
	CAPABILITY_TYPE_SHENZHUANG = 22,		-- 神装
	CAPABILITY_TYPE_TUHAOJIN = 23,			-- 土豪金战力
	CAPABILITY_TYPE_BIG_CHATFACE = 24,		-- 大表情战力
	CAPABILITY_TYPE_SHENZHOU_WEAPON = 25,	-- 神州六器战斗力
	CAPABILITY_TYPE_BABY = 26,				-- 宝宝属性战斗力
	CAPABILITY_TYPE_PET = 27,				-- 宠物战力
	CAPABILITY_TYPE_ACTIVITY = 28,			-- 活动相关提升的战力
	CAPABILITY_TYPE_MULTIMOUNT = 29,		-- 双人坐骑战力
	CAPABILITY_TYPE_PERSONALIZE_WINDOW = 30,--个性聊天框战力
	CAPABILITY_TYPE_XUNZHANG = 31,			-- 勋章战力
	CAPABILITY_TYPE_ZHIBAO = 32,			-- 至宝战力
	CAPABILITY_TYPE_HALO = 33,				-- 光环属性战斗力
	CAPABILITY_TYPE_SHENGONG = 34,			-- 神弓属性战斗力
	CAPABILITY_TYPE_SHENYI = 35,			-- 神翼属性战斗力
	CAPABILITY_TYPE_GUILD = 36,				-- 仙盟战斗力
	CAPABILITY_TYPE_TOTAL = 37,				-- 总战斗力

	CAPABILITY_TYPE_MAX = 50,
}

-- 仙盟仓库操作
GUILD_STORGE_OPERATE = {
	GUILD_STORGE_OPERATE_PUTON_ITEM = 1, -- 放进仓库
	GUILD_STORGE_OPERATE_TAKE_ITEM = 2,  -- 取出仓库
	GUILD_STORGE_OPERATE_REQ_INFO = 3,	 -- 请求仓库信息
}

-- 客户端操作请求类型
COMMON_OPERATE_TYPE = {
	COT_JINGHUA_HUSONG_COMMIT = 1,				-- 精华护送提交
	COT_JINGHUA_HUSONG_COMMIT_OPE = 2,			-- 精华护送提交次数请求
	COT_KEY_ADD_FRIEND = 3,						-- 一键踩好友空间
	COT_DAILY_TASK_DRAW = 5,					-- 日常抽奖任务
	COT_MASTER_COLLECT_ITEM_INFO = 6,			-- 精通收集信息param1为搜集索引
	COT_HOLD_BEAUTY = 7,						-- 请求抱/不抱美人，param1NPC ID   ID为0就不抱
	COT_REQ_WORLD_BOSS_DROP_RECORD = 8,			-- 获取世界boss掉落记录
	COT_REQ_RED_EQUIP_COLLECT_TAKEON = 9,		-- 红装收集，请求穿上，param1是红装seq，param2是红装槽index， param3是背包index
	COT_REQ_MONSTER_SIEGE_INFO = 10,			-- 请求怪物攻城信息
	COT_REQ_RED_EQUIP_COLLECT_FETCH_ATC_REWARD = 11, -- 红装收集，领取开服活动奖励，param1是奖励seq

	COT_ACT_BUY_EQUIPMENT_GIFT = 1000,			-- 活动 购买装备礼包
}

-- 服务器通知客户端信息类型
SC_COMMON_INFO_TYPE = {
	SCIT_JINGHUA_HUSONG_INFO = 1,				-- 同步精华护送信息
	SCIT_RAND_ACT_ZHUANFU_INFO = 2,				-- 随机活动专服信息
	SCIT_TODAY_FREE_RELIVE_NUM = 3,			    -- 复活信息
	SCIT_DAILY_TASK_DRAW = 4, 					-- 日常任务抽奖，param1是抽到的seq
	SCIT_CAMP_CHANGE_NAME_CD = 5,				-- 国家改名CD，param3是cd结束时间
}

JH_HUSONG_STATUS = {
	NONE = 0,
	FULL = 1,
	LOST = 2,
}

SHENZHUANG_OPERATE_TYPE = {
	REQ = 0,					-- 神装请求信息
	UPLEVEL = 1,				-- 神装升级
	SHENZHUANG_OPREATE_JINJIE = 2,			-- 新增 进阶
	SHENZHUANG_OPERATE_SHENZHU = 3,			-- 新增 神铸
}

MYSTERIOUSSHOP_OPERATE_TYPE = {
	MYSTERIOUSSHOP_OPERATE_TYPE_REQINFO = 0,		--请求神秘商店信息
	MYSTERIOUSSHOP_OPERATE_TYPE_BUY = 1,			--购买
}

CAMPEQUIP_OPERATE_TYPE = {
	CAMPEQUIP_OPERATE_TYPE_REQ_INFO = 0,		-- 请求信息
	CAMPEQUIP_OPERATE_TYPE_TAKEOFF = 1,			-- 脱下
	CAMPEQUIP_OPERATE_TYPE_HUNLIAN = 2,			-- 魂炼
	CAMPEQUIP_OPERATE_TYPE_RECYLE = 3,			-- 军团装备回收（新增）
}

--温泉是否同意添加伙伴
ADD_PARTNER_STATE = {
	ADDPARTNER_REJECT = 0,						-- 拒绝
	ADDPARTNER_AGREE = 1,						-- 同意
}

--温泉双修协议类型
SHUANGXIU_MSG_TYPE =
{
	SHUANGXIU_MSG_TYPE_ENTER_SCENE = 0,		-- 进入场景
	SHUANGXIU_MSG_TYPE_ADD = 1,					-- 双休对数增加
	SHUANGXIU_MSG_TYPE_DCE = 2,					-- 双休对数减少
}

CAMP_NORMALDUOBAO_OPERATE_TYPE = {
	ENTER = 0,		-- 请求进入军团普通夺宝
	EXIT = 1,			-- 请求退出军团普通夺宝
}

ROLE_SHADOW_TYPE = {
	ROLE_SHADOW_TYPE_CHALLENGE_FIELD = 0,		-- 竞技场
	ROLE_SHADOW_THPE_WORLD_EVENT = 1,			-- 世界事件
	ROLE_SHADOW_TYPE_ROLE_BOSS = 2,				-- 角色boss
	ROLE_SHADOW_TYPE_CAMPDEFEND = 3,			-- 守卫雕像
	ROLE_SHADOW_TYPE_KING_STATUES = 4,			-- 国王雕像
	ROLE_SHADOW_TYPE_EMPEROR_STATUES = 5,		-- 皇帝雕像
	ROLE_SHADOW_TYPE_MONSTER_SIEGE_KING = 6,	-- 怪物攻城国王
	ROLE_SHADOW_TYPE_DAKUAFU_BOSS_ROLE = 7, 	-- 大跨服玩家雕像
	ROLE_SHADOW_TYPE_QINGLOU_DANCER = 8,		-- 青楼跳舞的歌姬
}

RA_CHONGZHI_NIU_EGG_OPERA_TYPE = {
	RA_CHONGZHI_NIU_EGG_OPERA_TYPE_QUERY_INFO = 0,				-- 请求活动信息
	RA_CHONGZHI_NIU_EGG_OPERA_TYPE_CHOU = 1,					-- 抽奖
	RA_CHONGZHI_NIU_EGG_OPERA_TYPE_FETCH_REWARD = 2,			-- 领取全服奖励

	RA_CHONGZHI_NIU_EGG_OPERA_TYPE_MAX = 3,
}

RA_LJDL_REQ_TYPE = {
		RA_LJDL_REQ_TYPE_ALL_INFO = 0,							-- 请求信息
		RA_LJDL_REQ_TYPE_FETCH_DAILY_REWARD = 1,				-- 领取每日奖励
		RA_LJDL_REQ_TYPE_FETCH_REWARD = 2,						-- 领取奖励， param 传入领取第几个配置索引
}

CHONGZHI_REWARD_TYPE = {
	CHONGZHI_REWARD_TYPE_SPECIAL_FIRST = 0,										-- 特殊首充
	CHONGZHI_REWARD_TYPE_DAILY_FIRST = 1,										-- 日常首充
	CHONGZHI_REWARD_TYPE_DAILY_TOTAL = 2,										-- 日常累充
	CHONGZHI_REWARD_TYPE_DIFF_WEEKDAY_TOTAL = 3,	--新增						-- 每日累冲(星期几区分奖励配置)
	CHONGZHI_REWARD_TYPE_FIRST = 4,												-- 首充
	CHONGZHI_REWARD_TYPE_DAILY = 5,												-- 每日充值
	CHONGZHI_REWARD_TYPE_DAILY_TIMES = 6,										-- 每日充值累计天数奖励
	CHONGZHI_REWARD_TYPE_DAILY2 = 7,											-- 每日充值2
	CHONGZHI_REWARD_TYPE_DAHUIKUI = 8,											-- 充值大回馈（新增类型, param传拿取seq）
	CHONGZHI_REWARD_TYPE_DAILYWEEK = 9,											--每日累冲

	CHONGZHI_REWARD_TYPE_MAX,
}

SUPER_REWARD_TYPE = {
	REWARD_TYPE_PUTON_EQUIPMENT = 0,						-- 装备收集
	REWARD_TYPE_CAPABILITY = 1,								-- 战斗力冲刺
	REWARD_TYPE_ROLELEVEL = 2,								-- 人物等级冲刺
	REWARD_TYPE_SEVEN_DAY_TOTAL_CHONGZHI = 3,				-- 七天充值奖励  ---奖励类型发这个

	REWARD_TYPE_MAX,
}

LINGYU_FB_OPERA_TYPE = {
	REQINFO = 0,			-- 挑战副本请求信息
	BUYJOINTIMES = 1,		-- 挑战副本购买次数
	AUTO = 2,				-- 挑战副本扫荡
	RESETLEVEL = 3,			-- 挑战副本重置关卡
}

TAOZHUANG_TYPE =
{
	BAOSHI_TAOZHUANG = 0,
	STREGNGTHEN_TAOZHUANG =1,
	EQUIP_UP_STAR_TAPZHUANG = 2,
}

RA_CHONGZHI_MONEY_TREE_OPERA_TYPE =
{
	RA_MONEY_TREE_OPERA_TYPE_QUERY_INFO = 0,				-- 请求活动信息
	RA_MONEY_TREE_OPERA_TYPE_CHOU = 1,						-- 抽奖
	RA_MONEY_TREE_OPERA_TYPE_FETCH_REWARD = 2,				-- 领取全服奖励
}

-- 宝宝系统
BABY_REQ_TYPE = {
	BABY_REQ_TYPE_INFO = 0,								-- 请求单个宝宝信息  参数1 宝宝ID
	BABY_REQ_TYPE_ALL_INFO = 1,							-- 请求所有宝宝信息
	BABY_REQ_TYPE_UPLEVEL = 2,							-- 升级请求	参数1 宝宝ID
	BABY_REQ_TYPE_QIFU = 3,								-- 祈福请求 参数1 祈福类型
	BABY_REQ_TYPE_QIFU_RET = 4,							-- 祈福答应请求 参数1 祈福类型，参数2 是否接受
	BABY_REQ_TYPE_CHAOSHENG = 5,						-- 宝宝超生
	BABY_REQ_TYPE_SPIRIT_INFO = 6,						-- 请求单个宝宝的守护精灵的信息，发baby_index
	BABY_REQ_TYPE_TRAIN_SPIRIT = 7,						-- 培育精灵请求，发baby_index(param1)，spirit_id（param2, 从0开始，0-3）
	BABY_REQ_TYPE_REMOVE_BABY = 8,						-- 遗弃宝宝请求
	BABY_REQ_TYPE_DISPLAY_BABY = 9,						-- 宝宝展示或取消展示（param_0为1是使用，0取消，param_1为宝宝Index）
    BABY_REQ_TYPE_WASH_MASTER = 10,            			-- 宝宝洗练
}


PET_INFO_TYPE = {
	SC_CHOU_PET_MAX_TIMES = 10;							-- 宠物最大十连抽

	PET_MAX_COUNT_LIMIT = 12,							-- 宠物最大数量限制
	PET_MAX_STORE_COUNT = 48,							-- 宠物抽奖背包最大数量
	PET_MAX_LEVEL_LIMIT = 100,							-- 宠物最大等级限制
	PET_MAX_GRADE_LIMIT = 15,							-- 宠物最大阶数限制
	PET_EGG_MAX_COUNT_LIMIT = 15,						-- 宠物蛋最大数限制
	PET_REWARD_CFG_COUNT_LIMIT = 100,					-- 宠物奖品配置最大数量先知
	PET_SKILL_CFG_MAX_COUNT_LIMIT = 12,					-- 宠物技能配置最大个数
	INVALID_PET_ID = -1,								-- 无效的宠物ID
	PET_SKILL_MAX_LEVEL = 3,							--宠物技能最大等级
}

PET_REQ_TYPE = {
	PET_REQ_TYPE_INFO = 0,								-- 宠物基础信息请求
	PET_REQ_TYPE_BACKPACK_INFO = 1,						-- 宠物背包信息请求
	PET_REQ_TYPE_SELECT_PET = 2,						-- 宠物出战请求
	PET_REQ_TYPE_CHANGE_NAME = 3,						-- 宠物改名请求
	PET_REQ_TYPE_UP_LEVEL = 4,							-- 宠物升级请求
	PET_REQ_TYPE_UP_GRADE = 5,							-- 宠物升阶请求
	PET_REQ_TYPE_CHOU = 6,								-- 宠物抽取请求
	PET_REQ_TYPE_RECYCLE_EGG = 7,						-- 宠物蛋回收请求
	PET_REQ_TYPE_PUT_REWARD_TO_KNAPSACK = 8,			-- 宠物领取奖励请求
	PET_REQ_TYPE_ACTIVE = 9,							-- 激活请求
	PET_REQ_TYPE_LEARN_SKILL = 10,						-- 学习技能请求
	PET_REQ_TYPE_UPGRADE_SKILL = 11,					-- 升级技能请求
	PET_REQ_TYPE_FORGET_SKILL = 12,						-- 遗忘技能请求
	PET_REQ_TYPE_QINMI_PROMOTE = 13,					-- 提升亲密度，传食物的index [0, 3)
	PET_REQ_TYPE_QINMI_AUTO_PROMOTE = 14,				-- 一键升亲密等级，无参数
	PET_REQ_TYPE_FOOD_MARKET_CHOU_ONCE = 15,			-- 吃货市场一次抽奖
	PET_REQ_TYPE_FOOD_MARKET_CHOU_TIMES = 16,			-- 吃货市场多次抽奖
	PET_REQ_TYPE_UPLEVL_SPECIAL_IMG = 17,				--  灵器幻化升级
}

PET_SKILL_SLOT_TYPE = {
	PET_SKILL_SLOT_TYPE_ACTIVE = 0,						-- 主动技能槽
	PET_SKILL_SLOT_TYPE_PASSIVE_1 = 1,					-- 被动技能槽1
	PET_SKILL_SLOT_TYPE_PASSIVE_2 = 2,					-- 被动技能槽2
	PET_SKILL_SLOT_TYPE_COUNT = 3,						-- 技能槽总数量
}

RA_MINE_OPERA_TYPE = {
		RA_MINE_OPERA_TYPE_QUERY_INFO = 0,				-- 请求活动的信息
		RA_MINE_OPERA_REFRESH = 1,						-- 换矿请求，发一个参数，1使用元宝，0不使用
		RA_MINE_OPERA_GATHER = 2,						-- 挖矿请求，发一个参数，下标，[0, 3]
		RA_MINE_OPERA_FETCH_SERVER_REWARD = 3,			-- 领取全服奖励请求，发一个参数，下标
		RA_MINE_OPERA_EXCHANGE_REWARD = 4,				-- 兑换锦囊，发一个参数，下标

		RA_MINE_OPERA_TYPE_MAX,
	}

--开心矿场
RA_MINE_TYPES = {
	RA_MINE_TYPES_INVALID = 0,
	RA_MINE_TYPES_BEGIN = 10,
	RA_MINE_TYPES_END = 10 + GameEnum.RA_MINE_TYPE_MAX_COUNT - 1,
}

--顶刮刮
RA_GUAGUA_OPERA_TYPE = {
	RA_GUAGUA_OPERA_TYPE_QUERY_INFO = 0,					-- 请求活动的信息
	RA_GUAGUA_OPERA_TYPE_PLAY_TIMES =1,						-- 刮奖多次

	RA_GUAGUA_OPERA_TYPE_MAX =2,
}

RA_TIANMING_DIVINATION_OPERA_TYPE = {
	RA_TIANMING_DIVINATION_OPERA_TYPE_QUERY_INFO = 0, 			--请求天命卜卦活动信息
	RA_TIANMING_DIVINATION_OPERA_TYPE_ADD_LOT_TIMES = 1, 		--竹签加注
	RA_TIANMING_DIVINATION_OPERA_TYPE_RESET_ADD_LOT_TIMES = 2, 	--重置竹签加注倍数
	RA_TIANMING_DIVINATION_OPERA_TYPE_START_CHOU = 3, 			--开始卜卦
	RA_TIANMING_DIVINATION_OPERA_TYPE_MAX = 4,
}

-----化神
HUASHEN_REQ_TYPE = {
	HUASHEN_REQ_TYPE_ALL_INFO = 0,						-- 所有信息
	HUASHEN_REQ_TYPE_CHANGE_IMAGE = 1,					-- 切换形象
	HUASHEN_REQ_TYPE_UP_LEVEL = 2,						-- 升级
	HUASHEN_REQ_TYPE_SPIRIT_INFO = 3,		            -- 请求化神精灵信息
	HUASHEN_REQ_TYPE_UPGRADE_SPIRIT = 4,	            -- 化神精灵升级
	HUASHEN_REQ_TYPE_UP_GRADE = 5,						-- 化神形象升级
	HUASHEN_REQ_TYPE_MAX = 6,
}

QINGYUAN_COUPLE_HALO_REQ_TYPE = {
	QINGYUAN_COUPLE_REQ_TYPE_INFO = 0,					-- 请求信息
	QINGYUAN_COUPLE_REQ_TYPE_ACTIVITE_ICON = 1,			-- 激活图标
	QINGYUAN_COUPLE_REQ_TYPE_EQUIP = 2,					-- 装备光环
	QINGYUAN_COUPLE_REQ_TYPE_UPGRADE = 3,				-- 光环升级
	QINGYUAN_COUPLE_REQ_TYPE_MAX = 4,
}

RAND_ACTIVITY_OPEN_TYPE = {
	RAND_ACTIVITY_OPEN_TYPE_NORMAL = 0,                  --正常随机活动
	RAND_ACTIVITY_OPEN_TYPE_VERSION = 1,				--版本活动

}

--翻翻转
RA_FANFAN_OPERA_TYPE = {
	RA_FANFAN_OPERA_TYPE_QUERY_INFO = 0,		-- 请求活动信息
	RA_FANFAN_OPERA_TYPE_FAN_ONCE = 1,			-- 翻一次牌
	RA_FANFAN_OPERA_TYPE_FAN_ALL = 2,			-- 翻全部牌
	RA_FANFAN_OPERA_TYPE_REFRESH = 3,			-- 重置
	RA_FANFAN_OPERA_TYPE_WORD_EXCHANGE = 4,		-- 字组兑换

	RA_FANFAN_OPERA_TYPE_MAX = 5,
}

RA_FANFAN_CARD_TYPE = {
	RA_FANFAN_CARD_TYPE_BEGIN = 0,

	RA_FANFAN_CARD_TYPE_HIDDEN = 0,			-- 隐藏卡牌类型
	RA_FANFAN_CARD_TYPE_ITEM_BEGIN = 100,	-- 物品卡牌类型起始值
	RA_FANFAN_CARD_TYPE_WORD_BEGIN = 200,	-- 字组卡牌类型起始值

	RA_FANFAN_CARD_TYPE_MAX = 5,
}

-- 连充特惠
RA_CONTINUE_CHONGZHI_OPERA_TYPE = {
	RA_CONTINUE_CHONGZHI_OPERA_TYPE_QUERY_INFO = 0,			-- 请求活动信息
	RA_CONTINUE_CHONGZHI_OPEAR_TYPE_FETCH_REWARD = 1,		-- 获取奖励
	RA_CONTINUE_CHONGZHI_OPEAR_TYPE_FETCH_EXTRA_REWARD = 2,	-- 获取额外奖励

	RA_CONTINUE_CHONGZHI_OPERA_TYPE_MAX = 3,
}

-- 连消特惠
RA_CONTINUE_CONSUME_OPERA_TYPE = {
	RA_CONTINUME_CONSUME_OPERA_TYPE_QUERY_INFO = 0,						-- 请求活动信息
	RA_CONTINUE_CONSUME_OPEAR_TYPE_FETCH_REWARD = 1,					-- 获取奖励
	RA_CONTINUE_CONSUME_OPEAR_TYPE_FETCH_EXTRA_REWARD = 2,				-- 获取额外奖励
}

--军歌嘹亮枚举
RA_FLAG_TYPE = {
	RA_ARMY_DAY_ARMYINFO_NUM = 2,
	RA_ARMY_DAY_ARMY_SIDE_NUM = 3,
}

RA_PROMOTING_POSITION_CIRCLE_TYPE ={
	RA_PROMOTING_POSITION_CIRCLE_TYPE_OUTSIDE = 0,     --外圈
	RA_PROMOTING_POSITION_CIRCLE_TYPE_INSIDE = 1,       --内圈
}

-- 幸运棋
RA_PROMOTING_POSITION_OPERA_TYPE ={
	RA_PROMOTING_POSITION_OPERA_TYPE_ALL_INFO = 0,
	RA_PROMOTING_POSITION_OPERA_TYPE_PLAY = 1,
	RA_PROMOTING_POSITION_OPERA_TYPE_MAX = 2,
}

RA_FLAG_TYPE_CORPS_SIDE_TYPE = {
	BLUE_ARMY_SIDE = 0,
	RED_ARMY_SIDE = 1,
	YELLOW_ARMY_SIDE = 2,
}

RA_ARMY_DAY_OPERA_TYPE = {
	RA_ARMY_DAY_OPERA_TYPE_INFO = 0,						-- 请求活动信息
	RA_ARMY_DAY_OPERA_TYPE_EXCHANGE_FLAG = 1,				-- 兑换军旗
	RA_ARMY_DAY_OPERA_TYPE_EXCHANGE_ITEM = 2,				-- 兑换物品
}

MULTI_MOUNT_REQ_TYPE = {
		MULTI_MOUNT_REQ_TYPE_SELECT_MOUNT = 0,									-- 选择使用坐骑：param1 坐骑id
		MULTI_MOUNT_REQ_TYPE_UPGRADE = 1,										-- 坐骑进阶：param1 坐骑id, param2 重复次数，param3 是否自动购买
		MULTI_MOUNT_REQ_TYPE_RIDE = 2,											-- 上坐骑
		MULTI_MOUNT_REQ_TYPE_UNRIDE = 3,										-- 下坐骑
		MULTI_MOUNT_REQ_TYPE_INVITE_RIDE = 4,									-- 邀请骑乘：param1 玩家id
		MULTI_MOUNT_REQ_TYPE_INVITE_RIDE_ACK = 5,								-- 回应邀请骑乘：param1 玩家id，param2 是否同意
		MULTI_MOUNT_REQ_TYPE_USE_SPECIAL_IMG = 6,								-- 请求使用幻化形象：param1 特殊形象ID
		MULTI_MOUNT_REQ_TYPE_UPLEVEL_SPECIAL_IMG = 7,							-- 请求升级特殊形象：param1 特殊形象ID
		MULTI_MOUNT_REQ_TYPE_UPLEVEL = 8, 										-- 坐骑进阶：param1 物品id(激活卡进阶)
		MULTI_MOUNT_REQ_TYPE_CANCEL = 9, 										-- 取消使用双人坐骑
}

MULTI_MOUNT_CHANGE_NOTIFY_TYPE = {
		MULTI_MOUNT_CHANGE_NOTIFY_TYPE_SELECT_MOUNT = 0,						-- 当前使用中的坐骑改变, param1 坐骑id
		MULTI_MOUNT_CHANGE_NOTIFY_TYPE_UPGRADE = 1,								-- 进阶数据改变, param1 坐骑id，param2 阶数，param3 祝福值
		MULTI_MOUNT_CHANGE_NOTIFY_TYPE_INVITE_RIDE = 2,							-- 收到别人坐骑邀请, param1 玩家ID，param2 坐骑ID
		MULTI_MOUNT_CHANGE_NOTIFY_TYPE_ACTIVE_SPECIAL_IMG = 3,					-- 激活双人坐骑特殊形象 param1 特殊形象激活标记
		MULTI_MOUNT_CHANGE_NOTIFY_TYPE_USE_SPECIAL_IMG = 4,						-- 使用特殊形象	param1 特殊形象id，param2 特殊形象等级
		MULTI_MOUNT_CHANGE_NOTIFY_TYPE_UPGRADE_EQUIP = 5,						-- 升级装备	param1 装备类型， param2 装备等级
		MULTI_MOUNT_CHANGE_NOTIFY_TYPE_UPLEVEL_SPECIAL_IMG = 6,					-- 升级特殊形象	param1 特殊形象id， param2 特殊形象等级
		MULTI_MOUNT_CHANGE_NOTIFY_TYPE_UPLEVEL = 7, 							-- 升级数据改变, param1 坐骑id，param2 等级
}

PASTURESPIRIT_REQ_TYPE = {
	PASTURE_SPIRIT_REQ_TYPE_ALL_INFO = 0,							-- 请求所有信息
	PASTURE_SPIRIT_REQ_TYPE_UPGRADE = 1,							-- 请求升级
	PASTURE_SPIRIT_REQ_TYPE_PROMOTE_QUALITY = 2,					-- 请求提示品质
	PASTURE_SPIRIT_REQ_TYPE_AUTO_PROMOTE_QUALITY = 3,				-- 请求一键提示品质
	PASTURE_SPIRIT_REQ_TYPE_FREE_DRAW_ONCE = 4,						-- 请求免费抽一次
	PASTURE_SPIRIT_REQ_TYPE_LUCKY_DRAW_ONCE = 5,					-- 请求抽奖一次
	PASTURE_SPIRIT_REQ_TYPE_LUCKY_DRAW_TIMES = 6,					-- 请求抽奖多次

	PASTURESPIRIT_REQ_TYPE_MAX = 7,
}

--循环充值
RA_CIRCULATION_CHONGZHI_OPERA_TYPE = {
	RA_CIRCULATION_CHONGZHI_OPERA_TYPE_QUERY_INFO = 0,			-- 请求活动信息
	RA_CIRCULATION_CHONGZHI_OPEAR_TYPE_FETCH_REWARD = 1,		-- 获取奖励
	RA_CIRCULATION_CHONGZHI_OPEAR_TYPE_FETCH_EXTRA_REWARD = 2,	-- 获取额外奖励

	RA_CIRCULATION_CHONGZHI_OPERA_TYPE_MAX = 3,
}

CHANNEL_TYPE = {
	WORLD = 0,										-- 世界
	CAMP = 1,										-- 阵营
	SCENE = 2,										-- 场景
	TEAM = 3,										-- 队伍
	GUILD = 4,										-- 公会
	PRIVATE = 5,									-- 私聊
	SYSTEM = 6,										-- 系统
	SPEAKER = 8,									-- 喇叭
	CROSS = 9,										-- 跨服

	ALL = 100,										-- 全部
}

CHAT_WIN_REQ_TYPE = {
	PERSONALIZE_WINDOW_ALL_INFO = 0,				--个性化窗口信息
	PERSONALIZE_WINDOW_CONSUME_ITEM = 1,
	PERSONALIZE_WINDOW_USE_RIM = 2,
	PERSONALIZE_WINDOW_ACTIVE_BUBBLE_RIM_SUIT = 3,	-- 激活气泡框一个套装部位，参数1套装seq，参数2套装部位part
	PERSONALIZE_WINDOW_ACTIVE_BUBBLE_RIM = 4,		-- 激活气泡框，参数1气泡框seq
	PERSONALIZE_WINDOW_USE_BUBBLE_RIM = 5,			-- 使用气泡框，参数1气泡框seq
}

MAGIC_CARD_REQ_TYPE = {
	MAGIC_CARD_REQ_TYPE_ALL_INFO = 0,						-- 请求所有信息
	MAGIC_CARD_REQ_TYPE_CHOU_CARD = 1,						-- 抽奖，parm1 抽卡类型
	MAGIC_CARD_REQ_TYPE_USE_CARD = 2,						-- 使用魔卡，param1 魔卡id
	MAGIC_CARD_REQ_TYPE_UPGRADE_CARD = 3,					-- 升级魔卡，param1 颜色， param2 卡槽下标， param3 魔卡id
	MAGIC_CARD_REQ_TYPE_EXCHANGE = 4,						-- 魔卡兑换，param1 魔卡id
	MAGIC_CARD_REQ_TYPE_SKILL_ACTIVE = 5,					-- 激活技能
}

MAGIC_CARD = {
	MAGIC_CARD_SLOT_TYPE_LIMIT_COUNT = 4,				-- 魔卡位置最大种类限制
	MAGIC_CARD_MAX_LIMIT_COUNT = 27,					-- 魔卡最大卡牌数量
	MAGIC_CARD_CHOU_CARD_LIMIT_REWARD_COUNT = 16,		-- 魔卡抽卡奖品最大数量
	MAGIC_CARD_LIMIT_STRENGTH_LEVEL_MAX = 10,			-- 魔卡最大强化等级
}

MAGIC_CARD_COLOR_TYPE = {
	MAGIC_CARD_COLOR_TYPE_BLUE = 0,						-- 蓝色
	MAGIC_CARD_COLOR_TYPE_PURPLE = 1,					-- 紫色
	MAGIC_CARD_COLOR_TYPE_ORANGE = 2,					-- 橙色
	MAGIC_CARD_COLOR_TYPE_RED = 3,						-- 红色

	MAGIC_CARD_COLOR_TYPE_COLOR_COUNT = 4,
}

-- 星座星魂（名将根骨）
CS_TIAN_XIANG_TYPE = {
	CS_TIAN_XIANG_TYPE_ALL_INFO = 0,        -- 请求所有信息
	CS_TIAN_XIANG_TYPE_CHANGE_BEAD = 1,  	-- 请求改变珠子颜色，p1 = x , p2 = y， p3 = x, p4 = y, p5 = chapter
	CS_TIAN_XIANG_TYPE_XIE_BEAD = 2,  		-- 卸载珠，p1 = x , p2 = y, p3 = chapter
	CS_TIAN_XIANG_TYPE_GUNGUN_LE_REQ = 3,	-- 滚滚乐抽奖 p1： 0是抽1次，1是抽10次
	CS_UNLOCK_REQ = 4,						-- 星座解开锁
	CS_TIAN_XIANG_TYPE_PUT_MIJI = 5,		-- 放秘籍  P1 = 星座类型， p2 = 秘籍index
	CS_TIAN_XIANG_TYPE_CALC_CAPACITY = 6,	-- 放置秘籍成功，重新计算战力
	CS_TIAN_XIANG_TYPE_MIJI_COMPOUND = 7,	-- 秘籍合成 p1：index1
	CS_TIAN_XIANG_PUT_BEAD = 8,				-- 手动放珠子 p1:x, p2:y, p3:type, p4:章节
	CS_TIAN_XIANG_TYPE_XINGLING = 9,		-- 升级星灵
	CS_TIAN_XIANG_UPLEVEL_XINGHUN = 10,		-- 升级星魂 p1:生肖类型, p2:是否自动购买, p3:是否使用保护符
	CS_TIAN_XIANG_TYPE_XINGHUN_UNLOCK = 11,	-- 点击开锁星魂
}


-- 阵营枚举(国家枚举) ----------------------------------

-- 内政按钮类型
CAMP_AFFAIRS_TYPE = {
	YUNBIAO = 1,										-- 国家运镖
	BANZHUAN = 2,										-- 国家搬砖
	GUOMINFULI = 3,										-- 国民福利
	JINYANWANJIA = 4,									-- 禁言玩家
	NEIJIANBIAOJI = 5,									-- 标记内奸
	SHEMIANNEIJIAN = 6,									-- 赦免内奸
	GUANYUANFULI = 7,									-- 官员福利
	FUHUOFENPEI = 8,									-- 复活分配
}

-- 阵营类型
CAMP_TYPE = {
	CAMP_TYPE_INVALID = 0,
	CAMP_TYPE_FEIXING = 1,								-- 齐国
	CAMP_TYPE_ZHURI = 2,								-- 楚国
	CAMP_TYPE_ZHUIYUE = 3,								-- 秦国
	CAMP_TYPE_MAX = 4,
}
-- 阵营类型
NAME_TYPE_TO_CAMP = {
	["齐国"] = 1,
	["楚国"] = 2,
	["魏国"] = 3,
	["齐"] = 1,
	["楚"] = 2,
	["魏"] = 3,
}

-- 国家官职
CAMP_POST = {
	CAMP_POST_INVALID = 0,
	CAMP_POST_KING = 1,									-- 国王
	CAMP_POST_DASIMA = 2,								-- 大司马
	CAMP_POST_DAJIANGJUN = 3,							-- 大将军
	CAMP_POST_CHEJIJIANGJUN = 4,						-- 车骑将军
	CAMP_POST_YUSHIDAFU = 5,							-- 御史大夫
	CAMP_POST_JINGYINGGUOMIN = 6,						-- 精英国民
	CAMP_POST_GUOMIN = 7,								-- 国民

	CAMP_POST_MAX = 8,

	CAMP_POST_CHUJUN = 100,								-- 特殊的官职类型：储君
}

CAMP_RESULT_TYPE = {
	RESULT_TYPE_SEARCH_MEMBER = 0,						-- 返回查询成员结果，param1: role_id, param2第几页, param3排名方式
	RESULT_TYPE_NEIZHENG_YUNBIAO_OPEN = 1,				-- 运镖信息，param3是运镖活动结束时间(运镖活动，如果活动时间大于当前时间，那么运镖是双倍奖励的)
	RESULT_TYPE_NEIZHENG_BANZHUAN_OPEN = 2,				-- 搬砖信息，param3是活动结束时间
	RESULT_TYPE_ROB_USER_INFO = 3,						-- 要劫镖的玩家信息，param1和param2是坐标x,y，param4是场景ID	
	RESULT_TYPE_TASK_REWARD = 4,						-- 国家任务奖励，param1是任务类型，后面的参数根据类型不同而不同
	RESULT_TYPE_ADD_REBORN_DAN = 5,						-- 获取了复活丹，param1是获取数量
	RESULT_TYPE_DACHEN_DEFEND_SUCC = 6,					-- 大臣防御成功，param1是否有奖励
	RESULT_TYPE_FLAG_DEFEND_SUCC = 7,					-- 国旗防御成功，param1是否有奖励
}

CAMP_OPERA_TYPE = {
	OPERA_TYPE_APPOINT_OFFICER = 0,						-- 任命官员，param1: role_id, param2: post
	OPERA_TYPE_REMOVE_OFFICER = 1,						-- 解任官员，param1: role_id
	OPERA_TYPE_SEARCH_MEMBER = 2,						-- 查询成员，param4_name: 查询的玩家名字
	OPERA_TYPE_GET_REBORN_TIMES_LIST = 3,				-- 获取复活次数列表
	OPERA_TYPE_GET_CAMP_ROLE_INFO = 4,					-- 获取角色的国家信息
	OPERA_TYPE_SEARCH_USER = 5,							-- 搜索玩家，param1: 搜索类型，param4_name: 查询的玩家名字
	OPERA_TYPE_CHANGE_CAMP_NAME = 6,					-- 给国家改名，param4_name是要改的名字
	OPERA_TYPE_GET_CAMP_ALLIANCE_RANK_INFO = 7,			-- 获取国家同盟信息	
	OPERA_TYPE_GET_CAMP_SCORE_INFO = 8, 				-- 获取国家评分信息
	
	OPERA_TYPE_NEIZHENG_YUNBIAO = 100,					-- 内政-开启运镖
	OPERA_TYPE_NEIZHENG_OFFICER_WELFARE = 101,			-- 内政-官员福利
	OPERA_TYPE_NEIZHENG_GUOMIN_WELFARE = 102,			-- 内政-国民福利
	OPERA_TYPE_NEIZHENG_FORBID_TALK = 103,				-- 内政-禁言，param1：禁言玩家uid
	OPERA_TYPE_NEIZHENG_SET_NEIJIAN = 104,				-- 内政-设置或取消内奸，param1：要设置的玩家uid，param2：是否是设置（1设置，0取消）
	OPERA_TYPE_NEIZHENG_CALL = 105,						-- 内政-召集，param1：是否使用免费召集
	OPERA_TYPE_NEIZHENG_BANZHUAN = 106,					-- 内政-开启搬砖
	OPERA_TYPE_NEIZHENG_ACT_MONSTER_SIEGE = 107,		-- 申请开启怪物攻城活动
	OPERA_TYPE_NEIZHENG_MONSTER_SIEGE_BUILD_TOWER  = 108,--申请建立箭塔，param1：箭塔seq

	OPERA_TYPE_SALE_GET_ITEM_LIST = 200,				-- 拍卖-获取上架物品列表，param1：order_type，param2：page, param3：是否只显示我竞价的物品，param5：筛选物品ID
	OPERA_TYPE_SALE_ASK_PRICE = 201,					-- 拍卖-竞价，param1：sale_id，param2：page, param3：是否只显示我竞价的物品，param5：筛选物品ID
	OPERA_TYPE_SALE_BUY = 202,							-- 拍卖-一口价购买，param1：sale_id，param2：page, param3：是否只显示我竞价的物品，param5：筛选物品ID
	OPERA_TYPE_SALE_GET_RESULT_LIST = 203,				-- 拍卖-获取售卖结果列表

	OPERA_TYPE_CREATE_TOTEM_PILLAR = 300,				-- 创建图腾柱，param1是图腾柱类型
	OPERA_TYPE_QUERY_TOTEM_PILLAR_INFO = 301,			-- 请求本国图腾柱信息

	OPERA_TYPE_QIYUN_RANK_LOGIN_REWARD_ITEM = 400,		-- 国家同盟每日登陆奖励
	OPERA_TYPE_QIYUN_RANK_ZHANSHI_REWARD_ITEM = 401,	-- 国家同盟国家战事
}

CAMP_RANK_TYPE = {
	RANK_TYPE_CAPABILITY = 0,							-- 根据战力排名
	RANK_TYPE_KILL_NUM = 1,								-- 根据击杀数排名
}

-- 成员排名方式
CAMP_MEM_QUERY_ORDER_TYPE = {
	CMQOT_DEFAULT = 0,									-- 默认，官职，然后战力
	CMQOT_LEVEL = 1,									-- 等级
	CMQOT_CAPABILITY = 2,								-- 战力
	CMQOT_JUNGONG = 3,									-- 军功
	CMQOT_KILLNUM = 4,									-- 击杀数
}

-- 售卖结果类型
CAMP_SALE_RESULT_TYPE = {
	CAMP_SALE_RESULT_TYPE_INVALID = 0,
	CAMP_SALE_RESULT_TYPE_RECYCLE = 1,					-- 被回收
	CAMP_SALE_RESULT_TYPE_SOLD = 2,						-- 卖出
	CAMP_SALE_RESULT_TYPE_BUY = 3,						-- 被一口价购买
}

-- 排序规则
CAMP_SALE_ITEM_ORDER_TYPE = {
	CAMP_SALE_ITEM_ORDER_TYPE_DEFUALT = 0,				-- 默认按上架顺序排
	CAMP_SALE_ITEM_ORDER_TYPE_GOLD = 1,					-- 按照当前的价格，从小到大
	CAMP_SALE_ITEM_ORDER_TYPE_OTHER_1 = 2,				-- 已竞拍排未竞拍前面，快下架的排前面
	CAMP_SALE_ITEM_ORDER_TYPE_OTHER_2 = 3,				-- 已竞拍排未竞拍前面，价格低的排前面
}

-- 查询类型
SEARCH_TYPE = {
	SEARCH_TYPE_NAME = 0,								-- 按照名字查找
	SEARCH_TYPE_TALK = 1,								-- 按照聊天时间查找
	SEARCH_TYPE_SET_NEIJIAN = 2,						-- 设置内奸，按照战力，不显示官员
	SEARCH_TYPE_UNSET_NEIJIAN = 3,						-- 解除内奸，只显示内奸
}

SPECIAL_TYPE = {
	SPECIAL_TYPE_INVALID = 0,
	SPECIAL_TYPE_NEIJIAN = 1,							-- 内奸
	SPECIAL_TYPE_CITAN_COLOR = 2,						-- 刺探颜色
	SPECIAL_TYPE_BANZHUAN_COLOR = 3,					-- 搬砖颜色
	SPECIAL_TYPE_BEAUTY = 4,							-- 美人形象，param1是seq，param2是是否激活了神武
	SPECIAL_TYPE_BEAUTY_HUANHUA = 5,					-- 美人幻化形象，param1是seq，param2是是否激活了神武
	SPECIAL_TYPE_WING_HUANHUA = 6,						-- 羽翼幻化形象，param1是seq
	SPECIAL_TYPE_MOUNT_HUANHUA = 7,						-- 坐骑幻化形象，param1是seq
	SPECIAL_TYPE_HOLD_BEAUTY = 8,						-- 抱美人，param1是NPC ID
	SPECIAL_TYPE_JUNXIAN_LEVEL = 9,						-- 军衔等级，param1是军衔level
	SPECIAL_TYPE_BABY = 10,								-- 宝宝
}

CAMP_REPORT_TYPE = {
	REPORT_TYPE_INVALID = 0,
	REPORT_TYPE_KILL_DACHEN = 1,						-- 击杀大臣
	REPORT_TYPE_KILL_FLAG = 2,							-- 击杀国旗
	REPORT_TYPE_KILL_QIYUN_TOWER_SPEED_CHANGE = 3,		-- 摧毁气运塔，生产时间被改变
	REPORT_TYPE_KILL_QIYUN_TOWER_SPEED_REFRESH = 4, 	-- 摧毁气运塔，刷新生成加成时间
	REPORT_TYPE_DACHEN_DEFEND_SUCC = 5,					-- 成功保卫大臣
	REPORT_TYPE_FLAG_DEFEND_SUCC = 6,					-- 成功保卫国旗

}

CAMP_TASK_OPERA_TYPE = {
	OPERA_TYPE_ACCEPT_TASK = 0,							-- 接收任务，param1是任务类型
	OPERA_TYPE_COMMIT_TASK = 1,							-- 提交任务，param1是任务类型
	OPERA_TYPE_GET_TASK_STATUS = 2,						-- 获取任务状态，param1是任务类型，如果为0，表示获取所有任务状态

	OPERA_TYPE_CITAN_REFRESH_COLOR = 100,				-- 刺探任务-刷新颜色，param1是否一键最佳颜色
	OPERA_TYPE_CITAN_CONFIRM_COLOR = 101,				-- 刺探任务-确认颜色
	OPERA_TYPE_CITAN_BUY_TIMES = 102,					-- 刺探任务-购买次数
	OPERA_TYPE_CITAN_SHARE_COLOR = 103,					-- 刺探任务-分享

	OPERA_TYPE_YINGJIU_BUY_TIMES = 200,					-- 营救任务-购买次数

	OPERA_TYPE_BANZHUAN_BUY_TIMES = 300,				-- 搬砖任务-购买次数
	OPERA_TYPE_BANZHUAN_REFRESH_COLOR = 301,			-- 搬砖任务-刷新颜色，param1是否一键最佳颜色
	OPERA_TYPE_BANZHUAN_CONFIRM_COLOR = 302,			-- 搬砖任务-确认颜色
	OPERA_TYPE_BANZHUAN_SHARE_COLOR = 303,				-- 搬砖任务-分享
}

CAMP_TASK_TYPE = {
	CAMP_TASK_TYPE_INVALID = 0,
	CAMP_TASK_TYPE_YUNBIAO = 1,							-- 运镖（逻辑使用原来的护送，即HusongTask）
	CAMP_TASK_TYPE_CITAN = 2,							-- 刺探
	CAMP_TASK_TYPE_YINGJIU = 3,							-- 营救
	CAMP_TASK_TYPE_BANZHUAN = 4,						-- 搬砖

	CAMP_TASK_TYPE_MAX,
}

CAMP_WAR_OPERA_TYPE = {
	OPERA_TYPE_GET_YUNBIAO_USERS = 0,					-- 获取当前运镖玩家，param1是目标国家类型
	OPERA_TYPE_GET_ROB_YUNBIAO_USER = 1,				-- 获取抢劫当前运镖玩家信息，param1是目标玩家ID

	OPERA_TYPE_QUERY_QIYUN_STATUS = 100,				-- 请求气运塔状态
	OPERA_TYPE_QIYUN_REBORN_TOWER = 101,				-- 复活气运塔，param1：国家类型
	OPERA_TYPE_QUERY_QIYUN_REPORT = 102,				-- 请求气运战报
	OPERA_TYPE_QUERY_DACHEN_ACT_STATUS = 200,			-- 大臣活动状态
}

-------- 钓鱼枚举 --------------------------------------

-- 钓鱼类型
FISHING_OPERA_REQ_TYPE = {
	FISHING_OPERA_REQ_TYPE_START_FISHING = 0,			-- 开始钓鱼（进入钓鱼界面）
	FISHING_OPERA_REQ_TYPE_CASTING_RODS = 1,			-- 抛竿 param1是鱼饵类型
	FISHING_OPERA_REQ_TYPE_PULL_RODS = 2,				-- 收竿
	FISHING_OPERA_REQ_TYPE_CONFIRM_EVENT = 3,			-- 确认本次钓鱼事件
	FISHING_OPERA_REQ_TYPE_USE_GEAR = 4,				-- 使用法宝 param是法宝类型
	FISHING_OPERA_REQ_TYPE_BIG_FISH_HELP = 5,			-- 帮忙拉大鱼
	FISHING_OPERA_REQ_TYPE_STOP_FISHING = 6,			-- 停止钓鱼（离开钓鱼界面）
	FISHING_OPERA_REQ_TYPE_AUTO_FISHING = 7,			-- 自动钓鱼 param1:0取消状态1设置状态，param2状态类型
	FISHING_OPERA_REQ_TYPE_RAND_USER = 8,				-- 随机角色请求
	FISHING_OPERA_REQ_TYPE_BUY_STEAL_COUNT = 9,			-- 购买偷鱼次数
	FISHING_OPERA_REQ_TYPE_RANK_INFO = 10,				-- 请求钓鱼排行榜信息
	FISHING_OPERA_REQ_TYPE_STEAL_FISH = 11,				-- 偷鱼请求 param1 是被偷玩家rold_id
	FISHING_OPERA_REQ_TYPE_EXCHANGE = 12,				-- 兑换请求 param1：兑换组合下标
	FISHING_OPERA_REQ_TYPE_BUY_BAIT = 13,				-- 购买鱼饵 param1: 购买鱼饵类型 param2为购买数量
	FISHING_OPERA_REQ_TYPE_SCORE_REWARD = 14,			-- 领取积分奖励
}

-- 钓鱼日志类型
FISHING_NEWS_TYPE = {
	FISHING_NEWS_TYPE_INVALID = 0,
	FISHING_NEWS_TYPE_STEAL = 1,						-- 偷鱼日志
	FISHING_NEWS_TYPE_BE_STEAL = 2,						-- 被偷日志

	FISHING_NEWS_TYPE_MAX = 3
}

-- 钓鱼的状态
FISHING_STATUS = {
	FISHING_STATUS_IDLE = 0,							-- 未钓鱼，即不在钓鱼界面
	FISHING_STATUS_WAITING = 1,							-- 在钓鱼界面等待抛竿
	FISHING_STATUS_CAST = 2,							-- 已经抛竿，等待触发事件
	FISHING_STATUS_HOOKED = 3,							-- 已经触发事件，等待拉杆
	FISHING_STATUS_PULLED = 4,							-- 已经拉杆，等待玩家做选择
}

-- 特殊状态
SPECIAL_STATUS = {
	SPECIAL_STATUS_OIL = 0,								-- 使用香油中
	SPECIAL_STATUS_AUTO_FISHING = 1,					-- 自动钓鱼
	SPECIAL_STATUS_AUTO_FISHING_VIP = 2,				-- 自动钓鱼_vip
}

FISHING_EVENT_TYPE = {
	EVENT_TYPE_GET_FISH = 0,							-- 鱼类上钩 -- 事件类型为EVENT_TYPE_GET_FISH：param1为鱼的类型，param2为鱼的数量
	EVENT_TYPE_TREASURE = 1,							-- 破旧宝箱
	EVENT_TYPE_YUWANG = 2,								-- 渔网
	EVENT_TYPE_YUCHA = 3,								-- 渔叉
	EVENT_TYPE_OIL = 4,
	EVENT_TYPE_ROBBER = 5,								-- 盗贼偷鱼 -- 事件类型为EVENT_TYPE_ROBBER:param1为被偷的鱼类型， param2为被偷数量
	EVENT_TYPE_BIGFISH = 6,								-- 传说中的大鱼 -- 事件类型为EVENT_TYPE_BIGFISH: param1为的鱼类型， param2为数量

	EVENT_TYPE_COUNT = 7,
}

FISHING_GEAR = {
	FISHING_GEAR_NET = 0,								-- 渔网
	FISHING_GEAR_SPEAR = 1,								-- 鱼叉
	FISHING_GEAR_OIL = 2,								-- 香油

	FISHING_GEAR_COUNT = 3
}


--------- 随机活动 至尊幸运-----------------------------
RA_EXTREME_LUCKY_OPERA_TYPE = {
	RA_EXTREME_LUCKY_OPERA_TYPE_QUERY_INFO = 0,			-- 请求活动信息
	RA_EXTREME_LUCKY_OPERA_TYPE_FLUSH = 1,					-- 刷新
	RA_EXTREME_LUCKY_OPERA_TYPE_DRAW = 2,					-- 抽奖
	RA_EXTREME_LUCKY_OPERA_TYPE_NEXT_FLUSH = 3,				-- 本轮物品已经抽到9个，请求刷新
	RA_EXTREME_LUCKY_OPREA_TYPE_FETCH_REWARD = 4,			-- 领取返利奖励
	RA_EXTREME_LUCKY_OPERA_TYPE_MAX = 5,
}

WUSHANG_EQUIP_REQ_TYPE =
{
	WUSHANG_REQ_TYPE_ALL_INFO = 0,						-- 所有信息请求
	WUSHANG_REQ_TYPE_PUT_ON_EQUIP = 1,					-- 穿装备
	WUSHANG_REQ_TYPE_TAKE_OFF_EQUIP = 2,				-- 脱装备
	WUSHANG_REQ_TYPE_JIFEN_EXCHANGE = 3,				-- 积分兑换
	WUSHANG_REQ_TYPE_STRENGTHEN = 4,					-- 强化
	WUSHANG_REQ_TYPE_UP_STAR = 5,						-- 升星
	WUSHANG_REQ_TYPE_GLORY_EXCHANGE = 6,				-- 荣耀兑换
}

--跨服BOSS
SCCORSS_BOSS_PLAYER_INFO_REASON = {
	SCCORSS_BOSS_PLAYER_INFO_REASON_DEFAULT = 0,
	SCCORSS_BOSS_PLAYER_INFO_REASON_CROSS_REWARD_SYNC = 1,  -- 跨服奖励结算

	SCCORSS_BOSS_PLAYER_INFO_REASON_MAX = 2
}

--至尊寻宝
SUPER_XUNBAO_TIMES = {
	ONE_TIME = 1,
	TEN_TIME = 10,
}

--奖励列表类型
NOTICE_REWARD_TYPE = {
	NOTICE_TYPE_INVAILD = 0,					--无效类型
	NOTICE_TYPE_SHENZHOU_WEAPON = 1,			--魂器
	NOTICE_TYPE_SHENZHOU_WEAPON_OPEN_BOX = 2,
	NOTICE_TYPE_RANDGIFT = 3,
}


CHEST_SHOP_TYPE = {
	CHEST_SHOP_TYPE_EQUIP = 1,						-- 装备类型宝箱抽奖
	CHEST_SHOP_TYPE_JINGLING = 2,				-- 精灵类型宝箱抽奖
	CHEST_SHOP_TYPE_SUPER = 3,                   -- 至尊寻宝
}

-- 击杀大臣
GAME_ENUM_KO_REWARD_ITEM_COUNT = {
	REWARD_ITEM_COUNT = 3,						-- 击杀大臣
}

CHEST_SHOP_MODE = {									-- 宝箱商店
	CHEST_SHOP_MODE_1 = 1,							-- 装备抽X次
	CHEST_SHOP_MODE_10 = 2,							-- 装备抽X次
	CHEST_SHOP_MODE_50 = 3,							-- 装备抽X次
	CHEST_SHOP_JL_MODE_1 = 4,						-- 精灵抽X次
	CHEST_SHOP_JL_MODE_10 = 5,						-- 精灵抽X次
	CHEST_SHOP_JL_MODE_50 = 6,						-- 精灵抽X次
	CHEST_SHOP_MC_MODE_P_1 = 7,						-- 魔卡紫色抽奖1次
	CHEST_SHOP_MC_MODE_P_5 = 8,						-- 魔卡紫色抽奖5次
	CHEST_SHOP_MC_MODE_P_10 = 9,					-- 魔卡紫色抽奖10次
	CHEST_SHOP_MC_MODE_O_1 = 10,					-- 魔卡橙色抽奖1次
	CHEST_SHOP_MC_MODE_O_5 = 11,					-- 魔卡橙色抽奖5次
	CHEST_SHOP_MC_MODE_O_10 = 12,					-- 魔卡橙色抽奖10次
	CHEST_SHOP_MC_MODE_R_1 = 13,					-- 魔卡红色抽奖1次
	CHEST_SHOP_MC_MODE_R_5 = 14,					-- 魔卡红色抽奖5次
	CHEST_SHOP_MC_MODE_R_10 = 15,					-- 魔卡红色抽奖10次
	CHEST_PET_10 = 16,								-- 小宠物抽奖10次
	CHEST_SWORD_BIND_MODE_1 = 17,					-- 刀剑神域绑钻抽奖1次
	CHEST_SWORD_GOLD_MODE_1 = 18,					-- 刀剑神域钻石抽奖1次
	CHEST_SWORD_GOLD_MODE_10 = 19,					-- 刀剑神域钻石抽奖10次
	CHEST_RUNE_MODE_1 = 20,							-- 符文抽奖1次
	CHEST_RUNE_MODE_10 = 21,						-- 符文抽奖10次
	CHEST_RUNE_BAOXIANG_MODE = 22,					-- 符文宝箱
	CHEST_SHEN_GE_BLESS_MODE_1 = 23,				-- 神格祈福1次
	CHEST_SHEN_GE_BLESS_MODE_10 = 24,				-- 神格祈福10次
	CHEST_ERNIE_BLESS_MODE_1 = 25,					-- 摇奖机摇奖1次
	CHEST_ERNIE_BLESS_MODE_10 = 26,					-- 摇奖机摇奖10次
	CHEST_NORMAL_REWARD_MODE = 27,					-- 通用普通奖励(不需要再来一次的可以用这个类型)
	CHEST_BEAUTY_PRAY10 = 28,						-- 美人抽奖10次
	CHEST_BEAUTY_PRAY1 = 29,						-- 美人抽奖1次
	CHEST_GENERAL_MODE_1 = 30,						-- 名将抽x次
	CHEST_GENERAL_MODE_10 = 31,						-- 名将抽x次
	CHEST_GENERAL_MODE_50 = 32,						-- 名将抽x次
	CHEST_RANK_JINYIN_TA_MODE_1 = 33,			    -- 金银塔1次
	CHEST_RANK_JINYIN_TA_MODE_10 = 34,		        -- 金银塔10次
	CHEST_RANK_JINYIN_GET_REWARD = 35,				-- 领取累计奖励
	CHEST_RANK_ZHUANZHUANLE_MODE_10 = 36,           -- 转转乐10次
	CHEST_RANK_ZHUANZHUANLE_MODE_1 = 37,            -- 转转乐1次
	CHEST_RANK_ZHUANZHUANLE_GET_REWARD = 38,        --领取累积奖励
	CHEST_GUAJITA_REWARD = 39,						-- 符文塔扫荡
	CHEST_RANK_FANFANZHUANG_10 = 40,				-- 翻翻转10次
	CHEST_RANK_FANFANZHUANG_50 = 41,				-- 翻翻转50次
	CHEST_RANK_LUCK_CHESS_10 = 42,					-- 幸运棋10次
	CHEST_RANK_GIFT = 43,							-- 解礼包
	CHEST_RAN_LUCKY_TURNTABLE = 44,					-- 幸运转盘
	CHEST_RAND_HAPPY_LOTTERY_1 = 45,				-- 欢乐抽X次
	CHEST_RAND_HAPPY_LOTTERY_10 = 46,				-- 欢乐抽X次
	CHEST_RAN_ADVENTURE_SHOP = 47,					-- 奇遇商店
	CHEST_RAND_MID_AUTUMN_LOTTERY_1  = 48,          -- 月饼大作战X次
	CHEST_RAND_MID_AUTUMN_LOTTERY_10 = 49,			-- 月饼大作战X次
	CHEST_LITTLE_PET_MODE_1 = 50,					-- 小宠物商店1次
	CHEST_LITTLE_PET_MODE_10 = 51,					-- 小宠物商店10次
	CHEST_RANK_LUCKY_TURN_EGG_MODE_10 = 52,			-- 幸运扭蛋机10次
	CHEST_RANK_LUCKY_TURN_EGG_MODE_1 = 53,			-- 幸运扭蛋机1次
	CHEST_RANK_LUCKY_TURN_EGG_GET_REWARD = 54,		-- 幸运扭蛋机领取累积奖励
	CHEST_RANK_lUCKY_BOX_10 = 55,					-- 幸运宝箱10次
	CHEST_RANK_lUCKY_BOX_1 = 56,					-- 幸运宝箱1次
	CHEST_RANK_lUCKY_BOX_GET_REWARD = 57,			-- 幸运宝箱领取累积奖励
	CHEST_RANK_DASHE_TIAN_XIA_MODE_10 = 58,			-- 大射天下10次
	CHEST_RANK_DASHE_TIAN_XIA_MODE_1 = 59,			-- 大射天下1次

	CHEST_SYMBOL = 70, 								-- 五行之灵
	CHEST_SYMBOL_NIUDAN = 71, 						-- 五行之灵扭蛋
}

-- 御魂
MITAMA_REQ_TYPE = {
	MITAMA_REQ_TYPE_ALL_INFO = 0,						-- 请求所有信息
	MITAMA_REQ_TYPE_UPGRADE = 1,						-- 升级御魂
	MITAMA_REQ_TYPE_TASK_FIGHTING = 2,					-- 出征
	MITAMA_REQ_TYPE_TASK_AWARD = 3,						-- 领取出征奖励
	MITAMA_REQ_TYPE_EXCHANGE_ITEM = 4,					-- 兑换物品

	MITAMA_REQ_TYPE_MAX = 5,
}

-- 刀剑神域
CARDZU_REQ_TYPE = {
	CARDZU_REQ_TYPE_CHOU_CARD = 0,										-- 抽卡请求
	CARDZU_REQ_TYPE_HUALING = 1,										-- 化灵请求
	CARDZU_REQ_TYPE_LINGZHU = 2,										-- 灵铸请求
	CARDZU_REQ_TYPE_ACTIVE_ZUHE = 3,									-- 激活卡牌组合
	CARDZU_REQ_TYPE_UPGRADE_ZUHE = 4,									-- 升级卡牌组合
}

--黑市拍卖
RA_BLACK_MARKET_OPERA_TYPE =
{
	RA_BLACK_MARKET_OPERA_TYPE_ALL_INFO = 0, 		-- 请求所有信息
	RA_BLACK_MARKET_OPERA_TYPE_OFFER = 1,			-- 要价

	RA_BLACK_MARKET_OPERA_TYPE_MAX,
}

FAIRY_TREE_REQ_TYPE = {
	FAIRY_TREE_REQ_TYPE_ALL_INFO = 0,
	FAIRY_TREE_REQ_TYPE_FETCH_MONEY_REWARD = 1,			-- 领取在线金钱奖励
	FAIRY_TREE_REQ_TYPE_FETCH_GIFT_REWARD = 2,			-- 领取在线礼包奖励
	FAIRY_TREE_REQ_TYPE_UPLEVEL = 3,					-- 升级
	FAIRY_TREE_REQ_TYPE_UPGRADE = 4,					-- 进阶
	FAIRY_TREE_REQ_TYPE_DRAW_ONCE = 5,					-- 抽奖1次
	FAIRY_TREE_REQ_TYPE_DRAW_TEN_TIMES = 6,				-- 抽奖10次
	FAIRY_TREE_REQ_TYPE_GOLD = 7,						-- 元宝抽
}

MAGIC_EQUIPMENT_REQ_TYPE = {
	MAGIC_EQUIPMENT_REQ_TYPE_UPGRADE = 0,		--吞噬进阶：param1 魔器类型，param2 消耗数量
	MAGIC_EQUIPMENT_REQ_TYPE_STRENGTHEN = 1,	--锻造强化：param1 魔器类型，param2 是否自动强化， param3 是否自动购买
	MAGIC_EQUIPMENT_REQ_TYPE_EMBED = 2,		    --镶嵌魔石：param1 魔器类型，param2 镶嵌孔位，param3 魔石下标（配置里的）
	MAGIC_EQUIPMENT_REQ_TYPE_TAKE_OFF_STONE = 3,--卸下魔石： param1	魔器类型，param2 镶嵌孔位

	MAGIC_EQUIPMENT_REQ_TYPE_MAX = 4,
}

MAGIC_EQUIPMENT_CHANGE_NOTIFY_TYPE = {
	MAGIC_EQUIPMENT_CHANGE_NOTIFY_TYPE_QUALITY_LEVEL = 0,	   -- 品质等级改变：param1 魔器类型，param2 魔器品质等级， param3 吞噬进度
	MAGIC_EQUIPMENT_CHANGE_NOTIFY_TYPE_STRENGTHEN_LEVEL = 1,   -- 锻造等级改变：param1 魔器类型，param2 魔器锻造等级， param3 锻造值（祝福值）
	MAGIC_EQUIPMENT_CHANGE_NOTIFY_TYPE_EMBED = 2,			   -- 镶嵌魔石：param1 魔器类型，param2 魔石孔位， param3 魔石下标（配置里的）
	MAGIC_EQUIPMENT_CHANGE_NOTIFY_TYPE_TAKE_OFF = 3,		   -- 卸下魔石：param1 魔器类型，param2 魔石孔位， param3 魔石下标（配置里的）
}

RA_TREASURES_MALL_OPERA_TYPE = {
		RA_TREASURES_MALL_OPERA_TYPE_REQ_INFO = 0,	-- 珍宝商城所有信息
		RA_TREASURES_MALL_OPERA_TYPE_BUY = 1,		-- 珍宝商城购买
		RA_TREASURES_MALL_OPERA_TYPE_EXCHANGE = 2,	-- 珍宝商城兑换

		RA_TREASURES_MALL_OPERA_TYPE_MAX = 3,
}

--转生装备
ZHUANSHENG_REQ_TYPE =
{
	ZHUANSHENG_REQ_TYPE_ALL_INFO = 0,

	ZHUANSHENG_REQ_TYPE_OTHER_INFO = 2,
	ZHUANSHENG_REQ_TYPE_UPLEVEL = 3,						-- 升级请求
	ZHUANSHENG_REQ_TYPE_CHANGE_XIUWEI = 4,					-- 兑换修为请求
	ZHUANSHENG_REQ_TYPE_TAKE_OFF_EQUIP = 6,					-- 脱装备
}

-- 伤害的飘字类型
FIGHT_TEXT_TYPE =
{
	NORMAL = 0,			-- 普通
	BAOJU = 1,			-- 宝具
	NVSHEN = 2,			-- 女神

	SHENSHENG = 10,		-- 神圣
}

-- 变身类型
BIANSHEN_EFEECT_APPEARANCE =
{
	APPEARANCE_NORMAL = 0,									-- 正常外观
	APPEARANCE_DATI_XIAOTU = 1,								-- 答题变身卡-小兔
	APPEARANCE_DATI_XIAOZHU = 2,							-- 答题变身卡-小猪
	APPEARANCE_MOJIE_GUAIWU = 3,							-- 魔戒技能-怪物形象
	APPEARANCE_CROSS_XYCITY_CAPTIVE_BAG = 4,				-- 咸阳城-俘虏麻袋

	MINGJIANG = 99,											-- 名将变身
}

DISCONNECT_NOTICE_TYPE =
{
	INVALID = 0,
	LOGIN_OTHER_PLACE = 1,									-- 玩家在别处登录
	CLIENT_REQ = 2,											-- 客户端请求
}

--锻造
FORGE = {
	MAX_SUIT_EQUIP_PART = 10,
	EQUIPMENT_SUIT_OPERATE_TYPE =
	{
		EQUIPMENT_SUIT_OPERATE_TYPE_INFO_REQ = 1,			-- 信息请求
		EQUIPMENT_SUIT_OPERATE_TYPE_EQUIP_UP = 2,			-- 升级请求
	}
}

-- 坐骑
MOUNT_TYPE = {
	NORMAL_IMAGE = 0,										-- 使用普通形象
	TEMP_IMAGE = 1,											-- 使用临时形象
}

-- 引导副本类型
GUIDE_FB_TYPE = {
	HUSONG = 1,					-- 护送
	GONG_CHENG_ZHAN = 2,		-- 攻城战
	ROBERT_BOSS = 3,			-- 抢BOSS
	BE_ROBERTED_BOSS = 4,		-- 被抢boss
	SHUIJING = 5,				-- 水晶幻境
}

-- 黄金会员
GOLD_VIP_OPERA_TYPE = {
		OPERA_TYPE_ACTIVE = 0,               	-- 激活
		OPERA_TYPE_FETCH_RETURN_REWARD = 1,		-- 领取返还奖励
		OPERA_TYPE_CONVERT_SHOP = 2,            -- 兑换商店

		OPERA_TYPE_MAX = 3,
}

-- 经验炼制
RA_EXP_REFINE_OPERA_TYPE = {
	RA_EXP_REFINE_OPERA_TYPE_BUY_EXP = 0,					-- 炼制
	RA_EXP_REFINE_OPERA_TYPE_FETCH_REWARD_GOLD = 1,			-- 领取炼制红包
	RA_EXP_REFINE_OPERA_TYPE_GET_INFO = 2,					-- 获取信息
}

-- 目标系统
PERSONAL_GOAL_OPERA_TYPE = {
	PERSONAL_GOAL_INFO_REQ = 0,								-- 请求目标信息
	FETCH_PERSONAL_GOAL_REWARD_REQ = 1,						-- 领取个人目标奖励
	FETCH_BATTLE_FIELD_GOAL_REWARD_REQ = 2,					-- 领取集体目标奖励
	FINISH_GOLE_REQ = 3,									-- 完成目标
}

--符文系统操作参数
RUNE_SYSTEM_REQ_TYPE = {
	RUNE_SYSTEM_REQ_TYPE_ALL_INFO = 0,					-- 请求所有信息
	RUNE_SYSTEM_REQ_TYPE_BAG_ALL_INFO = 1,				-- 请求背包所有信息
	RUNE_SYSTEM_REQ_TYPE_RUNE_GRID_ALL_INFO = 2,		-- 请求符文槽所有信息
	RUNE_SYSTEM_REQ_TYPE_ONE_KEY_DISPOSE = 3,			-- 一键分解		p1 虚拟背包索引
	RUNE_SYSTEM_REQ_TYPE_COMPOSE = 4,					-- 合成			p1 p2 p3格子索引 如果是虚拟背包 加偏移值1000
	RUNE_SYSTEM_REQ_TYPE_SET_RUAN = 5,					-- 装备符文		p1 虚拟背包索引	p2 符文槽格子索引
	RUNE_SYSTEM_REQ_TYPE_XUNBAO_ONE = 6,				-- 寻宝一次
	RUNE_SYSTEM_REQ_TYPE_XUNBAO_TEN = 7,				-- 寻宝十次
	RUNE_SYSTEM_REQ_TYPE_UPLEVEL = 8,					-- 升级符文		p1 符文槽格子索引
	RUNE_SYSTEM_REQ_TYPE_CONVERT = 9,					-- 符文兑换
	RUNE_SYSTEM_REQ_TYPE_OTHER_INFO = 10,				-- 其他信息
	RUNE_SYSTEM_REQ_TYPE_AWAKEN = 11,					-- 符文格觉醒			p1 格子， p2觉醒类型
	RUNE_SYSTEM_REQ_TYPE_AWAKEN_CALC_REQ = 12,			-- 符文格觉醒重算战力
	RUNE_SYSTEM_REQ_TYPE_RAND_ZHILING_SLOT = 13,		-- 随机注灵槽（新增）
	RUNE_SYSTEM_REQ_TYPE_ZHULING = 14,					-- 注灵，参数1 符文格子inde
}

RUNE_SYSTEM_AWAKEN_TYPE = {
	RUEN_AWAKEN_TYPE_COMMON = 0,
	RUEN_AWAKEN_TYPE_DIAMOND = 1,
}

--符文系统列表参数
RUNE_SYSTEM_INFO_TYPE = {
	RUNE_SYSTEM_INFO_TYPE_INVAILD = 0,
	RUNE_SYSTEM_INFO_TYPE_ALL_BAG_INFO = 1,				-- 背包全部信息
	RUNE_SYSTEM_INFO_TYPE_RUNE_XUNBAO_INFO = 2,			-- 符文寻宝信息
	RUNE_SYSTEM_INFO_TYPE_OPEN_BOX_INFO = 3,			-- 打开符文宝箱
	RUNE_SYSTEM_INFO_TYPE_CONVERT_INFO = 4,				-- 符文兑换信息
}

--队员进入副本
TeamMemberState = {
	DEFAULT_STAE = 0,				-- 默认状态
	REJECT_STATE = 1,				-- 拒绝进入
	AGREE_STATE = 2,				-- 同意进入
}

FLOAT_VALUE_TYPE = {
	EFFECT_HPSTORE = 0,						-- EffectHpStore抵挡的伤害值
	EFFECT_UP_GRADE_SKILL = 1,				-- 进阶系统技能伤害
}

-- 飘雪附加技能特效
ATTATCH_SKILL_SPECIAL_EFFECT = {
	SPECIAL_EFFECT_NON = 0,
	SPECIAL_EFFECT_THUNDER = 1,				-- 雷电
	SPECIAL_EFFECT_STONE = 2,				-- 陨石
	SPECIAL_EFFECT_FIRE_TORNADO = 3,		-- 火龙卷
	SPECIAL_EFFECT_HAMMER = 4,				-- 雷神锤
	SPECIAL_EFFECT_WATER_TORNADO = 5,		-- 水龙卷
	SPECIAL_EFFECT_SWORD = 6,				-- 剑

	SPECIAL_EFFECT_MAX = 7,
}

ATTATCH_SKILL_SPECIAL_EFFECT_RES = {
	[1] = "juese_jinlei_t",
	[2] = "tongyong_yunsi",
	[3] = "Boss_lqf",
	[4] = "T_zjjn_shuilonjuan",
	[5] = "T_zjjn_jian",
	[6] = "tongyong_leishenchui",
}

-- 聚宝盆
RA_CORNUCOPIA_OPERA_TYPE = {
	RA_CORNUCOPIA_OPERA_TYPE_QUERY_INFO = 0,
	RA_CORNUCOPIA_OPERA_TYPE_FETCH_REWARD = 1,
	RA_CORNUCOPIA_OPERA_TYPE_FETCH_REWARD_INFO = 2,
}

WAR_REPORT_ENUM = {
	RANK_TYPE_CAPABILITY = 0,				
	RANK_TYPE_KILL_NUM = 1,					-- 本国杀敌排行

	BATTLE_REPORT_TYPE_INVALID = 0,         -- 无效
	BATTLE_REPORT_TYPE_KILL_OTHER = 1,      -- 击败敌人
	BATTLE_REPORT_TYPE_MULTI_KILL = 2,      -- 连续击杀
}

-- 国家建设日志类型
CAMP_BUILD_REPORT_ENUM = {
	TYPE_WIN_GUILE_BATTLE = 0,				-- 赢得抢皇帝
	TYPE_KILL_DACHEN = 1,					-- 击杀大臣
	TYPE_KILL_FLAG = 2,						-- 击杀国旗
	TYPE_KILL_QIYUN_TOWER = 3,				-- 击杀气运塔
	TYPE_ROB_HUSONG = 4,					-- 劫镖
}

MARKET_BUY_SORT_TYPE = {
	SORT_TYPE_INVALID = 0,											-- 不排序		
	SORT_TYPE_SINGLE = 1,											-- 单价排序
	SORT_TYPE_ALL = 2,												-- 总价排序
}

MARKET_BUY_RANK_TYPE = {
	RANK_TYPE_INVALID = 0,											
	RANK_TYPE_SMALL_TO_BIG = 1,										-- 排序方式从小到大
	RANK_TYPE_BIG_TO_SMALL = 2,										-- 排序方式从大到小
}

MASTER_COLLECT_TYPE = {
	MASTER_COLLECT_TYPE_INVALID = 0,
	MASTER_COLLECT_TYPE_MOUNT = 1,							-- 坐骑物品
	MASTER_COLLECT_TYPE_WING = 2,							-- 羽翼物品
	MASTER_COLLECT_TYPE_WEAPON = 3,							-- 武器物品
	MASTER_COLLECT_TYPE_DRESS = 4,							-- 衣服物品

	MASTER_COLLECT_TYPE_MAX = 5,

	MASTER_COLLECT_ITEM_COUNT = 200, 						-- 精通收集最大数量
}

-- 杀敌传闻
KILL_ROLE_CHUANWEN = {
	WAITING_TIME = 3, 					-- 传闻显示时间
	GAMER_ENTER_FB = 0, 				-- 玩家没有进入副本
	GAMER_LEAVE_FB = 1,					-- 玩家出入了副本
}

-- 国家复活类型
COUTRY_REVIVE_TYPE = {
	ROLE_REALIVE_COST_TYPE_CAMP  = 0,	-- 国家复活
	ROLE_REALIVE_COST_TYPE_RES   = 1,	-- 复活石复活
	ROLE_REALIVE_COST_TYPE_GOLD1 = 2,	-- 绑定宝复活
	ROLE_REALIVE_COST_TYPE_GOLD2 = 3,	-- 元宝复活
}

-- 搬砖任务砖块颜色
CAMP_TASK_BANZHUAN_COLOR = {
	CAMP_TASK_BANZHUAN_COLOR_INVALID = 0,	-- 无效颜色
	CAMP_TASK_BANZHUAN_COLOR_GREEN = 1,		-- 绿
	CAMP_TASK_BANZHUAN_COLOR_BLUE = 2,		-- 蓝
	CAMP_TASK_BANZHUAN_COLOR_PURPLE = 3,	-- 紫
	CAMP_TASK_BANZHUAN_COLOR_ORRANGE = 4,	-- 橙
	CAMP_TASK_BANZHUAN_COLOR_RED = 5,		-- 红

	CAMP_TASK_BANZHUAN_COLOR_MAX,
}

-- 任务阶段
CAMP_TASK_PHASE = 
{
	CAMP_TASK_PHASE_INVALID = 0,			-- 未接受
	CAMP_TASK_PHASE_ACCEPT = 1,				-- 接受，执行中
	CAMP_TASK_PHASE_COMPLETE = 2,			-- 接受，已完成
}

-- 营救任务目标
CAMP_TASK_YINGJIU_AIM = 
{
	CAMP_TASK_YINGJIU_AIM_INVALID = 0,						-- 无目标
	CAMP_TASK_YINGJIU_AIM_TOUCH_NPC = 1,					-- 同NPC对话
	CAMP_TASK_YINGJIU_AMI_GATHER = 2,						-- 采集物品
	CAMP_TASK_YINGJIU_AIM_KILL_MONSTER = 3,					-- 杀怪

	CAMP_TASK_YINGJIU_AIM_MAX = 4,
}

MINING_REQ_TYPE = {
	CROSS_MINING_REQ_TYPE_JOIN = 0,							-- 开始挖矿
	CROSS_MINING_REQ_TYPE_MINING = 1,						-- 请求挖矿 param_1：挖中的区域下标
	CROSS_MINING_REQ_TYPE_RANK_INFO = 2,					-- 排行榜信息
	CROSS_MINING_REQ_TYPE_AUTO_MINING = 3,					-- 自动挖矿
	CROSS_MINING_REQ_TYPE_CANCEL_AUTO_MINING = 4,			-- 取消自动挖矿
	CROSS_MINING_REQ_TYPE_EXCHANGE = 5,						-- 兑换 param_1:兑换seq
	CROSS_MINING_REQ_TYPE_STOP_GATHER = 6,					-- 停止采集
	CROSS_MINING_REQ_TYPE_OUT_MATCH = 7,					-- 请求退出活动
	CROSS_MINING_REQ_TYPE_FETCH_SCORE_REWARD = 8,			-- 领取积分奖励

	CROSS_MINING_REQ_TYPE_MAX,
}
	
--矿区区域类型
CROSS_MINING_AREA_TYPE = {
	CROSS_MINING_AREA_TYPE_BLACK = 0,						-- 黑色区域
	CROSS_MINING_AREA_TYPE_YELLOW = 1,						-- 黄色区域
	CROSS_MINING_AREA_TYPE_RED = 2,							-- 红色区域

	CROSS_MINING_AREA_TYPE_MAX,
}

--矿石类型
CROSS_MINING_MINE_TYPE = {
	CROSS_MINING_MINE_TYPE_BRASS = 0,						-- 黄铜
	CROSS_MINING_MINE_TYPE_SILVER = 1,						-- 银
	CROSS_MINING_MINE_TYPE_AMETHYST = 2,					-- 紫晶
	CROSS_MINING_MINE_TYPE_GOLD = 3,						-- 金
	CROSS_MINING_MINE_TYPE_PINK_GOLD = 4,					-- 赤金

	CROSS_MINING_MINE_TYPE_MAX
}

--状态类型
SPECIAL_CROSS_MINING_ROLE_STATUS = {
	SPECIAL_CROSS_MINING_ROLE_STATUS_NORMAL = 0,
	SPECIAL_CROSS_MINING_ROLE_STATUS_AUTO_MINING = 1,		-- 自动挖矿

	SPECIAL_CROSS_MINING_ROLE_STATUS_MAX
}

CROSS_MINING_EVENT_TYPE = {
	CROSS_MINING_EVENT_TYPE_INVALID = 0,
	CROSS_MINING_EVENT_TYPE_REWARD_MINE = 1,			-- 奖励矿石， 参数1为矿石类型， 参数2位矿石个数
	CROSS_MINING_EVENT_TYPE_REWARD_ITEM = 2,			-- 奖励物品  参数1为物品id  参数2为物品个数 参数3位是否绑定（大于0位绑定）
	CROSS_MINING_EVENT_TYPE_MONSTER = 3,				-- 遇到矿怪 （看客户端要显示什么， 参数1位怪物id）
	CROSS_MINING_EVENT_TYPE_ROBBER = 4,					-- 被打劫  （看看要怎么展示，可能新增协议）
	CROSS_MINING_EVENT_TYPE_ADD_CHANCE = 5,				-- 获得挖矿机会 参数1为增加挖矿次数
}

IS_ACK_REQ = {						-- 是否是自己请求的协议
	NO = 0,
	YES = 1,
}

BEAUTY_COMMON_REQ_TYPE = {
	BEAUTY_COMMON_REQ_TYPE_BASE_INFO = 0,			-- 所有信息请求
	BEAUTY_COMMON_REQ_TYPE_ACTIVE = 1,				-- 激活美人请求，param1是美人seq
	BEAUTY_COMMON_REQ_TYPE_EXCHANGE_ITEM = 2,		-- 兑换物品请求（缠绵），param1是美人seq
	BEAUTY_COMMON_REQ_TYPE_HETI = 3,				-- 合体请求,param1是美人seq
	BEAUTY_COMMON_REQ_TYPE_UPGRADE = 4,				-- 进阶请求，param1是美人seq
	BEAUTY_COMMON_REQ_TYPE_CALL = 5,				-- 出战请求，param1是美人seq
	BEAUTY_COMMON_REQ_TYPE_ACTIVE_SHENGWU = 6,		-- 激活圣物请求，param1是美人seq，param2是否是幻化
	BEAUTY_COMMON_REQ_TYPE_TASK_QUICK_COMPELTE = 7,	-- 快速完成美人心愿，param1是task_type，为0表示要全部完成
	BEAUTY_COMMON_REQ_TYPE_TASK_FETCH_REWARD = 8,	-- 美人心愿-缠绵（即领取任务奖励），param1是任务type，传0代表领取总奖励
	BEAUTY_COMMON_REQ_TYPE_XINJI_LEARN_SKILL = 9,	-- 美人心计-学习技能，param1是天地人大类型
	BEAUTY_COMMON_REQ_TYPE_XINJI_LOCK_SKILL = 10,	-- 美人心计-锁定技能，param1是天地人大类型，param2是slot, param3是否自动购买
	BEAUTY_COMMON_REQ_TYPE_XINJI_UPLEVEL_SKILL = 11,-- 美人心计-升级技能，param1是天地人大类型，param2是slot
	BEAUTY_COMMON_REQ_TYPE_DATING = 12,				-- 幽会，用于兑换幻化物品，param1是幻化索引
	BEAUTY_COMMON_REQ_TYPE_HUANHUA = 13,			-- 幻化，param1是幻化类型
	BEAUTY_COMMON_REQ_TYPE_USE_HUANHUA = 14,		-- 使用幻化形象
	BEAUTY_COMMON_REQ_TYPE_DRAW = 15,				-- 美人抽奖，1免费，2单抽，3十抽
	BEAUTY_COMMON_REQ_TYPE_DRQW_REWARD= 16,			-- 领取抽奖阶段奖励
	BEAUTY_COMMON_REQ_TYPE_CHANMIAN_UPGRADE = 17,	-- 缠绵进阶请求，param1是美人seq，param2是是否自动进阶，param3是自动进阶次数
}

BEAUTY_SKILL_TYPE = {
	BEAUTY_SKILL_TYPE_INVALID = 0,
	BEAUTY_SKILL_TYPE_RECOVER = 1,					-- 回复，每若干秒回复若干百分比的生命（当前最大生命上限）
	BEAUTY_SKILL_TYPE_JIANSHANG = 2,				-- 减伤，被怪物攻击，降低若干百分比伤害
	BEAUTY_SKILL_TYPE_POJIA = 3,					-- 破甲，对怪物攻击，增加若干百分比伤害
	BEAUTY_SKILL_TYPE_KUANGRE = 4,					-- 狂热，血量低于若干百分比，增加伤害若干百分比
	BEAUTY_SKILL_TYPE_BUQU = 5,						-- 不屈，血量低于若干百分比，降低受伤若干百分比
	BEAUTY_SKILL_TYPE_SHIXUE = 6,					-- 嗜血，击杀任意单位，攻击增加若干百分比，往上叠加最多N层，效果持续若干秒
	BEAUTY_SKILL_TYPE_HUDUN = 7,					-- 护盾，血量低于若干百分比，获得一个吸收伤害的护盾（可吸收自身生命上限若干百分比的伤害），效果持续若干秒

	BEAUTY_SKILL_TYPE_MAX,
}

-- 神器请求类型
SHENQI_OPERA_REQ_TYPE = 
{
	SHENQI_OPERA_REQ_TYPE_INFO = 0,							-- 请求所有信息
	SHENQI_OPERA_REQ_TYPE_DECOMPOSE = 1 ,					-- 分解 param_1:需要分解材料id	param_2:分解材料的个数
	SHENQI_OPERA_REQ_TYPE_SHENBING_INLAY = 2,				-- 神兵镶嵌请求 param_1:id  param_2:部位 param_3:品质
	SHENQI_OPERA_REQ_TYPE_SHENBING_UPLEVEL = 3,				-- 神兵升级请求 param_1:id  param_2:是否自动升级 param_3:一键发包数
	SHENQI_OPERA_REQ_TYPE_SHENBING_USE_IMAGE = 4,			-- 神兵更换使用形象 param_1:使用形象id(0取消使用)
	SHENQI_OPERA_REQ_TYPE_SHENBING_USE_TEXIAO = 5,			-- 神兵更换特效形象 param_1:使用特效id(0取消使用)
	SHENQI_OPERA_REQ_TYPE_BAOJIA_INLAY = 6,					-- 宝甲镶嵌请求 param_1:id  param_2:部位 param_3:品质
	SHENQI_OPERA_REQ_TYPE_BAOJIA_UPLEVEL = 7,				-- 宝甲升级请求 param_1:id  param_2:是否自动升级 param_3:一键发包数
	SHENQI_OPERA_REQ_TYPE_BAOJIA_USE_IMAGE = 8,				-- 宝甲更换使用形象 param_1:使用形象id(0取消使用)
	SHENQI_OPERA_REQ_TYPE_BAOJIA_USE_TEXIAO = 9,			-- 宝甲更换特效形象 param_1:使用特效id(0取消使用)

	SHENQI_OPERA_REQ_TYPE_MAX = 10,
}

SHENQI_SC_INFO_TYPE =										-- 神器下发信息类型
{
	SHENQI_SC_INFO_TYPE_SHENBING = 0,						-- 神兵
	SHENQI_SC_INFO_TYPE_BAOJIA = 1,							-- 宝甲
	SHENQI_SC_INFO_TYPE_MAX = 2,
}

-- 名将请求类型
GREATE_SOLDIER_REQ_TYPE = 
{
	GREATE_SOLDIER_REQ_TYPE_INFO = 0,						-- 请求所有信息
	GREATE_SOLDIER_REQ_TYPE_LEVEL_UP = 1,					-- 升级请求，param1是seq
	GREATE_SOLDIER_REQ_TYPE_BIANSHEN = 2,					-- 变身请求
	GREATE_SOLDIER_REQ_TYPE_WASH = 3,						-- 洗练请求，param1是seq
	GREATE_SOLDIER_REQ_TYPE_PUTON = 4,						-- 装上将位请求，param1是名将seq，param2是将位槽seq
	GREATE_SOLDIER_REQ_TYPE_PUTOFF = 5,						-- 卸下将位请求，param1是将位槽seq
	GREATE_SOLDIER_REQ_TYPE_SLOT_LEVEL_UP = 6,				-- 升级将位请求，param1是将位槽seq,param2是次数
	GREATE_SOLDIER_REQ_TYPE_DRAW = 7,						-- 抽奖请求，param1是抽奖类型 param2是否自动购买 是:否 1:0
	GRAETE_SOLDIER_REQ_TYPE_CONFIRM_WASH = 8,				-- 确认洗练结果，param1是seq
	GRAETE_SOLDIER_REQ_TYPE_WASH_ATTR = 9,					-- 洗练属性请求，param1是seq
	GRAETE_SOLDIER_REQ_TYPE_BIANSHEN_TRIAL = 10,			-- 变身体验请求，param1是seq

	GREATE_SOLDIER_REQ_TYPE_MAX,
}

-- 特殊技能类型
GREATE_SOLDIER_SPECIAL_SKILL_TYPE = 
{
	GREATE_SOLDIER_SPECIAL_SKILL_TYPE_INVALID = 0,

	GREATE_SOLDIER_SPECIAL_SKILL_TYPE_1 = 1,				-- 全队每秒回血5%
	GREATE_SOLDIER_SPECIAL_SKILL_TYPE_2 = 2,				-- 免疫控制技能
	GREATE_SOLDIER_SPECIAL_SKILL_TYPE_3 = 3,				-- 激活/结束时，晕眩周围对象2秒

	GREATE_SOLDIER_SPECIAL_SKILL_TYPE_MAX,
}

-- 潜能类型
GREATE_SOLDIER_POTENTIAL_TYPE = 
{
	GREATE_SOLDIER_POTENTIAL_TYPE_INVALID = 0,
	
	GREATE_SOLDIER_POTENTIAL_TYPE_GONGJI = 1,
	GREATE_SOLDIER_POTENTIAL_TYPE_FANGYU = 2,
	GREATE_SOLDIER_POTENTIAL_TYPE_HP = 3,

	GREATE_SOLDIER_POTENTIAL_TYPE_MAX
}

-- 抽奖类型
GREATE_SOLDIER_DRAW_TYPE = 
{
	GREATE_SOLDIER_DRAW_TYPE_INVALID = 0,

	GREATE_SOLDIER_DRAW_TYPE_1_DRAW = 1,
	GREATE_SOLDIER_DRAW_TYPE_10_DRAW = 2,
	GREATE_SOLDIER_DRAW_TYPE_50_DRAW = 3,

	GREATE_SOLDIER_DRAW_TYPE_SPECIAL_10_DRAW = 10,
	GREATE_SOLDIER_DRAW_TYPE_SPECIAL_50_DRAW = 11,

	GREATE_SOLDIER_DRAW_TYPE_MAX
}
-- Boss悬赏
RA_BOSS_XUANSHANG_REQ_TYPE = {
	RA_BOSS_XUANSHANG_REQ_TYPE_ALL_INFO = 0,				--请求信息
	RA_BOSS_XUANSHANG_REQ_TYP_FETCH_PHASE_REWARD = 1,		--拿取阶段任务奖励
	RA_BOSS_XUANSHANG_REQ_TYP_MAX = 2,
}

CHANNEL_CD = {												-- 聊天CD
	[CHANNEL_TYPE.WORLD] = 10,												-- 世界
	[CHANNEL_TYPE.CAMP] = 10,												-- 国家
	[CHANNEL_TYPE.GUILD] = 2,												-- 家族
	[CHANNEL_TYPE.TEAM] = 1,												-- 队伍
}

RED_PAPER_CURRENCY_TYPE = {
	RED_PAPER_CURRENCY_TYPE_INVALID = 0,									--	无效
	RED_PAPER_CURRENCY_TYPE_GOLD = 1,										--	元宝
	RED_PAPER_CURRENCY_TYPE_BIND_GOLD = 2,									--	绑元
	RED_PAPER_CURRENCY_TYPE_COIN = 3,										--	铜币

	RED_PAPER_MONEY_TYPE_MAX
}

--可以展示频道标签
CanShowChannel =
{
	[CHANNEL_TYPE.ALL] = true,
	[CHANNEL_TYPE.GUILD] = true,
	[CHANNEL_TYPE.WORLD] = true,
	[CHANNEL_TYPE.SYSTEM] = true,
	[CHANNEL_TYPE.TEAM] = true,
	[CHANNEL_TYPE.CAMP] = true,
	[CHANNEL_TYPE.SPEAKER] = true,
	[CHANNEL_TYPE.CROSS] = true,
}

-- 抽奖原因
DRAW_REASON = {
	DRAW_REASON_DEFAULT = 0,
	DRAW_REASON_BEAUTY = 1,			-- 美人抽奖
	DRAW_REASON_GREATE_SOLDIER = 2, -- 名将抽奖
	DRAW_REASON_HAPPY_DRAW = 3, 	-- 欢乐抽
	DRAW_REASON_HAPPY_DRAW2 = 4,    -- 月饼大作战
}

--监听种类
LISTEN_TYPE = {
	player_listener = 1,				--人物信息变更监听	
	item_listener	= 2,				--物品数目变更监听
}

-- Boss悬赏
RA_BOSS_XUANSHANG_REQ_TYPE = {
	RA_BOSS_XUANSHANG_REQ_TYPE_ALL_INFO = 0,				--请求信息
	RA_BOSS_XUANSHANG_REQ_TYP_FETCH_PHASE_REWARD = 1,		--拿取阶段任务奖励
	RA_BOSS_XUANSHANG_REQ_TYP_MAX = 2,
}

--每日国事
RA_DAILY_NATION_WAR_TYPE = {
	QXLD = 0,   											--元素战场
	GUILDBATTLE = 1, 										--抢国王
	GONGCHENGZHAN = 2, 										--抢皇帝
}

--领取奖励
RA_DAILY_NATION_WAR_REQ_TYPE = {
	INFO = 0,												--请求信息
	FETCH_REWARD = 1,										--拿取奖励, 参数1为拿取类型
}

-- 储君有礼
RA_CHUJUN_GIFT_REQ_TYPE = {
	RA_CHUJUN_GIFT_REQ_TYPE_INFO = 0,						-- 请求所有信息
	RA_CHUJUN_GIFT_REQ_TYPE_FETCHT_REWARD = 1,				-- 拿取奖励, param_1任务类型
	RA_CHUJUN_GIFT_REQ_TYPE_COMPETE = 2,					-- 请求竞争储君
	RA_CHUJUN_GIFT_REQ_TYPE_MUSTER = 3,						-- 召集请求

	RA_CHUJUN_GIFT_REQ_TYPE_MAX = 4
}

EQUIPMENT_TYPE = {
	EQUIPMENT_TYPE_GOUYU = 0,								--勾玉
	EQUIPMENT_TYPE_ZHIJIE = 1,								--戒指
	EQUIPMENT_TYPE_GUAZHUI = 2,								--挂坠

	EQUIPMENT_TYPE_MAX
}

-- 外观武器使用类型
APPEARANCE_USE_TYPE = {
	APPEARANCE_WUQI_USE_TYPE_INVALID = 0,					-- 不可用
	APPEARANCE_WUQI_USE_TYPE_SHIZHUANG = 1,
	APPEARANCE_WUQI_USE_TYPE_SHENQI = 2,
	APPEARANCE_USE_TYPE_MAX = 3,
}

-- 外观衣服使用类型
APPEARANCE_BODY_USE_TYPE = {
	APPEARANCE_BODY_USE_TYPE_INVALID = 0,
	APPEARANCE_BODY_USE_TYPE_SHIZHUANG = 1,
	APPEARANCE_BODY_USE_TYPE_SHENQI = 2,
	APPEARANCE_BODY_USE_TYPE_MAX = 3,
}

RONGLU_ADDEXP_TYPE = {
		RONGLU_ADDEXP_TYPE_ROLE_EXP = 0,	-- 人物经验
		RONGLU_ADDEXP_TYPE_RONGLU = 1,		-- 熔炼经验

		RONGLU_ADDEXP_TYPE_MAX = 2,
}

DECREE_SHOW_TYPE = {
	ACCEPT_TASK = 1,
	UPLEVEL = 2,
	GATHER_TASK = 3,			-- 采集物任务
}

--带战力道具
SHOW_POWER_PROP_TYPE = {
	TITLE_NAME = 1,
	GEMSTONE = 2,
	SHUXINGDAN = 3,
	BRACELET = 4,
	SHENQI = 5,
	JINJIEQUIP = 6,
	ZHUANSHENG = 7,
}

TUITU_FB_OPERA_REQ_TYPE = {
	TUITU_FB_OPERA_REQ_TYPE_ALL_INFO = 0,					-- 请求信息
	TUITU_FB_OPERA_REQ_TYPE_BUY_TIMES = 1,					-- 购买进入副本次数 param_1 购买副本类型 param_2, 购买次数
	TUITU_FB_OPERA_REQ_TYPE_FETCH_STAR_REWARD = 2,			-- 拿取星级奖励 param_1:章节  param_2:配置表seq
	TUITU_FB_OPERA_REQ_TYPE_SAODANG = 3 ,					-- 扫荡 param_1:副本类型 param_2:章节 param_3:关卡
	TUITU_FB_OPERA_REQ_TYPE_MAX = 4,
}

FAZHEN_OPERA_REQ_TYPE = {
	FAZHEN_OPERA_REQ_TYPE_INFO = 0,							-- 请求法阵信息
	FAZHEN_OPERA_REQ_TYPE_UPGRADE = 1,						-- 法阵进阶 param_1:是否自动进阶 param_2:进阶多少次
	FAZHEN_OPERA_REQ_TYPE_UPGRADE_IMG = 2,					-- 特殊形象进阶 param_1:特殊形象id
	FAZHEN_OPERA_REQ_TYPE_USE_IMG = 3,						-- 使用法阵形象 param_1:形象id
	FAZHEN_OPERA_REQ_TYPE_UNUSER_IMG = 4,					-- 取消使用形象
	FAZHEN_OPERA_REQ_TYPE_EQUIP_UPGRADE = 5,				-- 法阵装备进阶
}

FOOTPRINT_OPERATE_TYPE = {
	FOOTPRINT_OPERATE_TYPE_INFO_REQ = 0,			-- 请求信息
	FOOTPRINT_OPERATE_TYPE_UP_GRADE = 1,			-- 请求进阶 param_1=>repeat_times  param_2=>auto_buy
	FOOTPRINT_OPERATE_TYPE_USE_IMAGE = 2,			-- 请求使用形象 param_1=>image_id
	FOOTPRINT_OPERATE_TYPE_UP_LEVEL_EQUIP = 3,		-- 请求升级装备 param_1=>equip_idx
	FOOTPRINT_OPERATE_TYPE_UP_STAR = 4,				-- 请求升星 param_1=>stuff_index param_2=>is_auto_buy param_3=>loop_times
	FOOTPRINT_OPERATE_TYPE_UP_LEVEL_SKILL = 5,		-- 请求升级技能 param_1=>skill_idx param_2=>auto_buy
	FOOTPRINT_OPERATE_TYPE_UP_SPECIAL_IMAGE = 6,	-- 请求升特殊形象进阶 param_1=>special_image_id
}


-- 决斗
MiningChallengeType = {
	CHALLENGE_TYPE_NONE = 0,
	CHALLENGE_TYPE_MINING_ROB = 1,						-- 挖矿抢劫玩家，	param1 对手UID
	CHALLENGE_TYPE_MINING_ROB_ROBOT = 2,				-- 挖矿抢劫机器人，	param1 机器人index
	CHALLENGE_TYPE_MINING_REVENGE = 3,					-- 挖矿复仇，		param1 对手UID，param2 对应抢劫列表index
	CHALLENGE_TYPE_SAILING_ROB = 4,						-- 航海抢劫玩家，	param1 对手UID
	CHALLENGE_TYPE_SAILING_ROB_ROBOT = 5,				-- 航海抢劫机器人，	param1 机器人index
	CHALLENGE_TYPE_SAILING_REVENGE = 6,					-- 航海复仇，		param1 对手UID，param2 对应抢劫列表index
	CHALLENGE_TYPE_FIGHTING = 7,						-- 挑衅对战，		param1 对手下标
}

AdvanceUpdateEqu = {
	SKILL_TYPE_MOUNT = 0,   --坐骑
	SKILL_TYPE_WING = 1,  --羽翼
	SKILL_TYPE_HALO = 2,  --光环
	SKILL_TYPE_SHENGONG = 3,  --神弓/足迹
	SKILL_TYPE_SHENYI = 4,  --神翼/披风
	SKILL_TYPE_FAZHEN = 5,  --法阵/法印
	SKILL_TYPE_JINGLING_FAZHEN = 6,  --精灵法阵/圣物
	SKILL_TYPE_JINGLING_GUANGHUAN = 7,  --精灵光环/美人光环
	SKILL_TYPE_HEADWEAR = 8,   --头饰
	SKILL_TYPE_MASK = 9,   --面饰
	SKILL_TYPE_WAIST = 10,   --腰饰
	SKILL_TYPE_BEAD = 11,   --灵珠
	SKILL_TYPE_FABAO = 12,   --法宝
	SKILL_TYPE_KIRINARM = 13,   --麒麟臂
}

CLIENT_SETTING_TYPE = {
	CLIENT_SETTING_TYPE_REFUSE_SINGLE_CHAT = 0,			--拒绝私聊
	CLIENT_SETTING_TYPE_MAX = 1
}

TALENT_SYSTEM_REQ_TYPE = {
	TALENT_SYSTEM_REQ_TYPE_GET_INFO = 0,									--获取信息请求
	TALENT_SYSTEM_REQ_TYPE_RESET = 1,										--重置天赋页请求
	TALENT_SYSTEM_REQ_TYPE_EXCHANGE = 2,									--兑换天赋点情求
	TALENT_SYSTEM_REQ_TYPE_SAVE_INFO = 3,									--保存天赋页请求
	TALENT_SYSTEM_REQ_TYPE_ACTIVE_PAGE = 4,									--激活天赋页请求
}

GUILD_POST_TYPE = {
	GUILD_POST_INVALID = 0,

	GUILD_POST_CHENG_YUAN = 1,										-- 成员
	GUILD_POST_ZHANG_LAO = 2,										-- 长老
	GUILD_POST_FU_TUANGZHANG = 3,									-- 副团长
	GUILD_POST_TUANGZHANG = 4,										-- 团长
	GUILD_POST_JINGYING = 5,										-- 精英成员
	GUILD_POST_HUFA = 6,											-- 护法
}

TEAM_SKILL = {
	HIGH = 1,
	MEDIAN = 2,
	BASE = 4,
	TOTLE_NUM = 7,
}

TEAM_SKILL_SKILL_TYPE = {
	TEAM_SKILL_SKILL_TYPE_HIGH = 0,									--高级技能
	TEAM_SKILL_SKILL_TYPE_MEDIAN = 1,								--中级技能
	TEAM_SKILL_SKILL_TYPE_PRIMARY = 2,								--基础技能

	TEAM_SKILL_SKILL_TYPE_MAX = 3,	
}

TEAM_SKILL_OPERA_REQ_TYPE = {
	TEAM_SKILL_OPERA_REQ_TYPE_UPLEVEL_SKILL = 0,					-- 组队技能 技能升级(param_1:技能类型， param_2:技能下标， param_3:是否自动购买)
	TEAM_SKILL_OPERA_REQ_TYPE_AUTO_UPLEVEL_SKILL = 1,					-- 组队技能 自动升级(param_1:技能类型， param_2:技能下标， param_3:发包数)

	TEAM_SKILL_OPERA_REQ_TYPE_MAX = 2,
}

RA_TOTAL_CHARGE_OPERA_TYPE    = {							-- 金银塔活动请求类型
	RA_LEVEL_LOTTERY_OPERA_TYPE_QUERY_INFO          = 0,	-- 请求记录信息
	RA_LEVEL_LOTTERY_OPERA_TYPE_DO_LOTTERY          = 1,	-- 发起抽奖请求 param_1 次数
	RA_LEVEL_LOTTERY_OPERA_TYPE_FETCHE_TOTAL_REWARD = 2,	-- 领取累计抽奖次数奖励 param_1 次数
	RA_LEVEL_LOTTERY_OPERA_TYPE_ACTIVITY_INFO       = 3,	-- 请求活动信息
	RA_LEVEL_LOTTERY_OPERA_TYPE_MAX                 = 4,
}

CHARGE_OPERA = {
	CHOU_ONE = 1,
	CHOU_TEN = 10,
}

RA_DAY_ACTIVE_DEGREE_OPERA_TYPE = {
	RA_DAY_ACTIVE_DEGREE_OPERA_TYPE_QUERY_INFO = 0,		-- 查询信息
	RA_DAY_ACTIVE_DEGREE_OPERA_TYPE_FETCH_REWARD = 1,	-- 领取奖励 param1,reward_seq
}

-- 单笔充值2（单返豪礼）
RA_SINGLE_CHONGZHI_OPERA_TYPE =
{
	RA_SINGLE_CHONGZHI_OPERA_TYPE_INFO = 0,				-- 请求信息
	RA_SINGLE_CHONGZHI_OPERA_TYPE_FETCH_REWARD = 1,		-- 领取奖励

	RA_SINGLE_CHONGZHI_OPERA_TYPE_MAX = 2,
}
RA_CHONGZHI_MONEY_TREE_OPERA_TYPE ={
	RA_MONEY_TREE_OPERA_TYPE_QUERY_INFO = 0,			-- 请求活动信息
	RA_MONEY_TREE_OPERA_TYPE_CHOU = 1,						--抽奖：param_1 次数
	RA_MONEY_TREE_OPERA_TYPE_FETCH_REWARD = 2,				-- 领取全服奖励：param_1 seq
	RA_MONEY_TREE_OPERA_TYPE_MAX = 3,
}

--跨服帮派战请求(跨服六界)
CROSS_GUILDBATTLE_OPERATE = {
	CROSS_GUILDBATTLE_OPERATE_REQ_INFO = 0,
	CROSS_GUILDBATTLE_OPERATE_FETCH_REWARD = 1,
	CROSS_GUILDBATTLE_OPERATE_REQ_TASK_INFO = 2,
	CROSS_GUILDBATTLE_OPERATE_BOSS_INFO = 3,
}

CROSS_GUILDBATTLE = {
	CROSS_GUILDBATTLE_MAX_FLAG_IN_SCENE = 3,		-- 最大旗子数在场景中
	CROSS_GUILDBATTLE_MAX_SCENE_NUM = 6,			-- 帮派场景个数
	CROSS_GUILDBATTLE_MAX_GUILD_RANK_NUM = 5,		-- 跨服帮派战前5
	CROSS_GUILDBATTLE_MAX_TASK_NUM = 6,
}


--个人塔防buff类型
BUFF_FALLING_APPEARAN_TYPE = {
	NSTF_BUFF_1 = 1,
	NSTF_BUFF_2 = 2,
	NSTF_BUFF_3 = 3,
	NSTF_BUFF_4 = 4,
	YZDD_BUFF = 5,
	}

BUFF_FALLING_APPEARAN_TYPE_EFF = {
	[1] = "DLW_meirenzhifu",
	[2] = "DLW_meirenzhiqiang",
	[3] = "DLW_meirenzhinu",
	[4] = "DLW_meirenzhidun",
	[5] = "DLW_meirenzhinu",
}

--结婚操作
MARRY_REQ_TYPE = {
	MARRY_CHOSE_SHICI_REQ = 0,   		 --选誓词
	MARRY_PRESS_FINGER_REQ = 1,    	     --摁手指
 }

-- 结婚操作回馈
MARRY_RET_TYPE = {
	MARRY_AGGRE = 0,    				  -- 点击我愿意
	MARRY_CHOSE_SHICI = 1,  			  -- 选誓词
	MARRY_PRESS_FINGER = 2,      		  -- 摁手指
	MARRY_CANCEL = 3,						-- 对方拒绝了
  }

QINGYUAN_OPERA_TYPE = {
	QINGYUAN_OPERA_TYPE_WEDDING_YUYUE = 0,					-- 婚礼预约 param1 预约下标
	QINGYUAN_OPERA_TYPE_WEDDING_INVITE_GUEST = 1,			-- 邀请宾客 param1 宾客uid
	QINGYUAN_OPERA_TYPE_WEDDING_REMOVE_GUEST = 2,			-- 移除宾客 param1 宾客uid
	QINGYUAN_OPERA_TYPE_WEDDING_BUY_GUEST_NUM  = 3,			-- 购买宾客数量
	QINGYUAN_OPERA_TYPE_WEDDING_GET_YUYUE_INFO  = 4,		-- 获取预约信息
	QINGYUAN_OPERA_TYPE_WEDDING_GET_ROLE_INFO  = 5,			-- 获取玩家信息
	QINGYUAN_OPERA_TYPE_WEDDING_YUYUE_FLAG  = 6,			-- 获取婚礼预约标记
	QINGYUAN_OPERA_TYPE_WEDDING_YUYUE_RESULT  = 7,			-- 是否同意婚礼预约时间 param1 seq param2 是否同意
	QINGYUAN_OPERA_TYPE_LOVER_INFO_REQ  = 8,				-- 请求伴侣信息
	QINGYUAN_OPERA_TYPE_LOVER_TITLE_INFO  = 9,				-- 仙侣称号信息
	QINGYUAN_OPERA_TYPE_FETCH_LOVER_TITLE  = 10,			-- 领取仙侣称号 param1 index
	QINGYUAN_OPERA_TYPE_BUY_AND_PUTON_EQUIP  = 11,			-- 购买且穿戴装备 param1 index

	QINGYUAN_OPERA_TYPE_MAX,
}

QINGYUAN_INFO_TYPE = {
	QINGYUAN_INFO_TYPE_WEDDING_YUYUE = 0,					-- 婚礼预约
	QINGYUAN_INFO_TYPE_WEDDING_STANDBY = 1,					-- 婚礼准备
	QINGYUAN_INFO_TYPE_GET_BLESSING = 2,					-- 收到祝福 param_ch1 祝福类型 param2 参数
	QINGYUAN_INFO_TYPE_BAITANG_RET = 3,						-- 拜堂请求
	QINGYUAN_INFO_TYPE_BAITANG_EFFECT = 4,					-- 拜堂特效 param_ch1 是否已经拜堂
	QINGYUAN_INFO_TYPE_LIVENESS_ADD = 5,					-- 婚礼热度增加 param2 当前热度
	QINGYUAN_INFO_TYPE_HAVE_APPLICANT = 6,					-- 婚礼申请者 param2 申请者uid 
	QINGYUAN_INFO_TYPE_APPLY_RESULT = 7,					-- 申请结果 param2 1:同意 0:拒绝
	QINGYUAN_INFO_TYPE_ROLE_INFO = 8,						-- 玩家信息 param_ch1 婚姻类型 param_ch2 是否有婚礼次数 param_ch3 当前婚礼状态 param_ch4 婚礼预约seq
	QINGYUAN_INFO_TYPE_WEDDING_YUYUE_FLAG = 9,				-- 婚礼预约标记
	QINGYUAN_INFO_TYPE_YUYUE_RET = 10,						-- 婚礼预约请求 param_ch1 seq
	QINGYUAN_INFO_TYPE_YUYUE_POPUP = 11,					-- 婚礼预约弹窗
	QINGYUAN_OPERA_TYPE_BUY_QINGYUAN_FB_RET = 12,			-- 收到购买次数请求
	QINGYUAN_INFO_TYPE_YUYUE_SUCC = 13,						-- 婚礼预约成功
	QINGYUAN_INFO_TYPE_LOVER_INFO = 14,						-- 伴侣信息 param2 伴侣uid param_ch1 伴侣阵营 role_name 伴侣名字
	QINGYUAN_INFO_TYPE_LOVER_TITLE_INFO = 15,				-- 仙侣称号信息 param2 领取flag
	QINGYUAN_INFO_TYPE_REQ_LOVER_BUY_LOVE_BOX = 16,			-- 请求仙侣购买宝匣
	QINGYUAN_INFO_TYPE_WEDDING_BEGIN_NOTICE = 17,			-- 婚宴开启通知
}

--地脉操作请求类型
DIMAI_OPERA_TYPE = {
	DIMAI_OPERA_TYPE_ROLE_INFO = 0,					-- 请求玩家的地脉信息
	DIMAI_OPERA_TYPE_DIMAI_INFO = 1,				-- 查询某一层的所有地脉信息，param1是layer
	DIMAI_OPERA_TYPE_SINGLE_DIMAI_INFO = 2,			-- 查询单个地脉信息，param1是layer，param2是point
	DIMAI_OPERA_TYPE_BUY_TIMES = 3,					-- 购买进入次数
	DIMAI_OPERA_TYPE_FETCH_CHALLENGE_REWARD = 4,	-- 领取挑战奖励，param1是seq
}

CROSS_COMMON_OPERA_REQ = {
	CROSS_COMMON_OPERA_REQ_INVALID = 0,
	CROSS_COMMON_OPERA_REQ_CROSS_TEAM_ROOM_LIST_INFO = 1,       -- 跨服组队本 房间列表
	CROSS_COMMON_OPERA_REQ_CROSS_TEAM_ROOM_INFO = 2,            -- 跨服组队本 房间信息
	CROSS_COMMON_OPERA_REQ_CROSS_GUILDBATTLE_BOSS_INFO = 3,     -- 跨服组帮派战Boss信息

	CROSS_COMMON_OPERA_REQ_MAX
}

CAMP_BY_STR = {
	[0] = "WU",
	[1] = "QI",
	[2] = "CHU",
	[3] = "WEI",
}

RAND_ACTIVITY_PANEL_TYPE = {
	EXPENSE_PANEL = 1,
	ACTIVE_PANEL = 2,
}

--组队技能所有信息下发原因
TEAM_SKILL_INFO_SC_TYPE = {
	TEAM_SKILL_INFO_SC_TYPE_INIT = 0,      		 -- 初始化
	TEAM_SKILL_INFO_SC_TYPE_ADDEXP = 1,          -- 增加经验
	TEAM_SKILL_INFO_SC_TYPE_UPLEVEL = 2,         --	升级

	TEAM_SKILL_INFO_SC_TYPE_MAX = 3,
}

  --新累计充值
RA_NEW_TOTAL_CHARGE_OPERA_TYPE ={
	RA_NEW_TOTAL_CHARGE_OPERA_TYPE_QUERY_INFO = 0,
	RA_NEW_TOTAL_CHARGE_OPERA_TYPE_FETCH_REWARD = 1,

	RA_NEW_TOTAL_CHARGE_OPERA_TYPE_MAX = 2,
}

QINGYUAN_EQUIP_REQ_TYPE = {
	QINGYUAN_EQUIP_REQ_SELF_EQUIP_INFO = 0,				-- 请求自己装备信息
	QINGYUAN_EQUIP_REQ_ACTIVE_SUIT = 1,					-- 请求激活套装 param_1套装类型，param_2 套装槽, param_3背包索引
	QINGYUAN_EQUIP_REQ_OTHER_EQUIP_INFO = 2,			-- 请求伴侣装备信息
	QINGYUAN_EQUIP_REQ_TAKE_OFF = 3,					-- 请求脱装备, param_1 装备索引
}

--情缘圣地
QYSD_OPERA_TYPE =
{
	QYSD_OPERA_TYPE_FETCH_TASK_REWARD = 0,				-- 领取任务奖励，param -> 任务索引
	QYSD_OPERA_TYPE_FETCH_OTHER_REWARD = 1,				-- 领取额外奖励
	QYSD_OPERA_TYPE_QUICK_FINISH_TASK = 2,				-- 一键完成任务
}

-- 累计返利
RA_CHARGE_REPAYMENT_OPERA_TYPE ={
	RA_CHARGE_REPAYMENT_OPERA_TYPE_QUERY_INFO = 0,		--请求信息
	RA_CHARGE_REPAYMENT_OPERA_TYPE_FETCH_REWARD = 1,	--领取奖励
	RA_CHARGE_REPAYMENT_OPERA_TYPE_MAX = 2,
}

--八卦符文使用类型
RUNE_CELL_TYPE = {
	RUNE_BAG_BTN = 0,			--背包按钮
	RUNE_XIANGQIAN_BTN = 1,		--镶嵌
	RUNE_TIHUAN_BTN = 2,		--替换
}

SHENBING_ADDPER = {
	SHENBIN_TYPE = 0,			--神兵加成类型	
	BAOJIA_TYPE = 1, 			--宝甲加成类型
	QILING_TYPE = 2,			--器灵加成类型
}

--召集类型
CALL_TYPE = {
	CALL_TYPE_INVALID = 0,
	CALL_TYPE_GUILD = 1,					-- 家族召集
	CALL_TYPE_CAMP = 2,						-- 国家召集
	CALL_TYPE_CROSS = 3,
	CALL_TYPE_XYJD_DEFFENDER = 10,			-- 咸阳据点-召唤防御者
	CALL_TYPE_XYJD_ATTACKER = 11,			-- 咸阳据点-召唤进攻者
	CALL_TYPE_XYJD_PRGRESS_HALF = 12,    	-- 咸阳据点 - 据点进度至一半
    CALL_TYPE_XYCITY_MIDAO_DEFENDER = 20,   -- 咸阳城 - 密道开启通知防御方
    CALL_TYPE_XYCITY_MIDAO_ATTACKER = 21,   -- 咸阳城 - 密道开启通知进攻方
    CALL_TYPE_XYCITY_MIDAO_BOSS_HP = 22,    -- 咸阳城 - 密道BOSS HP改变召集防守方
}

--召集来源类型
CALL_FROM_TYPE = {
	CALL_TYPE_ROLE = 0,								-- 玩家召集
	CALL_TYPE_DACHEN_TO_ATTACKER = 1,				-- 大臣召集攻击者
	CALL_TYPE_DACHEN_TO_DEFENDER = 2,				-- 大臣召集防守者
	CALL_TYPE_FLAG_TO_ATTACKER = 3, 				-- 国旗召集攻击者
	CALL_TYPE_FLAG_TO_DEFENDER = 4,					-- 国旗召集防守者
	CALL_TYPE_QIYUN_TOWER = 5,						-- 气运塔召集
	CALL_TYPE_DESTORY_TASK = 6,						-- 击破任务发布
}

-- 副本通用奖励信息
COMMON_FB_GET_REWARD_TYPE = {
	COMMON_FB_GET_REWARD_TYPE_CROSS_FISHING = 0,
	COMMON_FB_GET_REWARD_TYPE_CROSS_MINING = 1,
	COMMON_FB_GET_REWARD_TYPE_MAX = 2,
}

ADVANCE_SKILL_TYPE = {
	MOUNT = 1,
	WING = 2,
	HALO = 3,
	FAZHEN = 4,
	BEAUTY_HALO = 5,
	HALIDOM = 6,
	FOOT = 7,
	MANTLE = 8,
	HEADWEAR = 9,
	MASK = 10,
	WAIST = 11,
	BEAD = 12,
	FABAO = 13,
	KIRINARM = 14,
}

ADVANCE_TAB_ACTIVE = {
	[1] = "mount_jinjie",
	[2] = "wing_jinjie",
	[3] = "halo_jinjie",
	[4] = "fight_mount",
	[5] = "meiren_guanghuan",
	[6] = "halidom_jinjie",
	[7] = "shengong_jinjie",
	[8] = "shenyi_jinjie",
}


RA_SUPER_DAILY_TOTAL_CHONGZHI_OPERA_TYPE = {
	RA_SUPER_DAILY_TOTAL_CHONGZHI_OPERA_TYPE_ALL_INFO = 0,						-- 请求信息
	RA_SUPER_DAILY_TOTAL_CHONGZHI_OPERA_TYPE_FETCH_REWARD = 1,					-- 拿取奖励 param_1 为seq

	RA_SUPER_DAILY_TOTAL_CHONGZHI_OPERA_TYPE_MAX = 2,
}

ADVANCE_EQUIP_TYPE = {
	MOUNT = 1,
	WING = 2,
	HALO = 3,
	FAZHEN = 4,
	BEAUTY_HALO = 5,
	HALIDOM = 6,
	FOOT = 7,
	MANTLE = 8,
	HEADWEAR = 9,
	MASK = 10,
	WAIST = 11,
	BEAD = 12,
	FABAO = 13,
	KIRINARM = 14,
}

CAMP_SALE_ITEM_LIST_TYPE = {
	GET_INFO = 0,
	BUY_SUCC = 1,
}

TEAM_INVITE_TYPE = {
	TEAM_INVITE_TYPE_USER = 0,
	TEAM_INVITE_TYPE_GUILD_MEMBER = 1,
	TEAM_INVITE_TYPE_CAMP_MEMBER = 2,

	TEAM_INVITE_TYPE_MAX = 3,
}

FETCH_ACTIVE_REWARD_OPERATE_TYEP = {
	FETCH_ACTIVE_DEGREE_REWARD = 0,
	FETCHE_TOTAL_ACTIVE_DEGREE_REWARD = 1,
	FETCH_ACTIVE_ONEKEY_COMPLETE = 2,
	TEAM_INVITE_TYPE_MAX = 3,
}



FENQIZHIZHUI_OPERA_REQ_TYPE = {
	FENQIZHIZHUI_OPERA_REQ_TYPE_INFO = 0,								--请求信息
	FENQIZHIZHUI_OPERA_REQ_TYPE_FETCH_REWARD = 1,						--拿取奖励  param_1  为系统类型
}

CameraType = {
	Free = 0,		-- 自由视角
	Fixed = 1,		-- 固定视角
}

SHENQI_TIP_TYPE = {
	SHENBING = 0,
	BAOJIA = 1,
}

SHOW_CHAT_TYPE = {
	CHAT = 0,
	SYS = 1,
	ANSWER = 2,
}

CHAT_POP_TYPE = {
	MAIN = 0,
	GUILD = 1,
}
TOUXIAN_OPERA_REQ_TYPE = {
	REQ_UPGRADE_TITLE = 0,				-- 请求进阶 param 是否自动购买
	REQ_TITLE_ALL_INFO = 1,				-- 请求进阶信息
}

HUGUOZHILI_OPERA_REQ_TYPE = {
	REQ_INFO = 0,					-- 请求信息
	REQ_ACTIVE_HUGUOZHILI = 1,		-- 请求激活护国之力
}

--神级技能
SHEN_JI_SKILL_TYPE = {
    REQ_INFO = 0,          -- 请求信息
    FETCH_REWARD = 1,       --请求领取神级奖励
}

RA_ONE_YUAN_DRAW_OPERA_TYPE =
{
	RA_ONE_YUAN_DRAW_TYPE_ALL_INFO = 0,				--请求信息
	RA_ONE_YUAN_DRAW_OPERA_TYPE_DRAW_REWARD = 1,		--抽奖
}

-- 每日目标
RA_CONSUME_AIM_OPERA_TYPE = {
	RA_CONSUME_AIM_OPERA_TYPE_ALL_INFO  = 0,		-- 请求所有信息
	RA_CONSUME_AIM_OPERA_TYPE_FETCH_REWARD = 1,		-- 请求获取奖励
}

RA_ADVENTURE_OPERA_TYPE = {
	ADVENTURE_SHOP_OPERA_TYPE = 0,
	ADVENTURE_SHOP_REQ_TYPE = 1,
}

RA_SUPER_CHARGE_FEEDBACK = {
	RA_SINGLE_CHARGE_PRIZE_OPERA_TYPE_ALL_INFO = 0,
	RA_SINGLE_CHARGE_PRIZE_OPERA_TYPE_FETCH_REWARD = 1,
}

RA_SINGLE_CHARGE_PRIZE_OPERA_TYPE =
{
	ALL_INFO = 0,			-- 请求所用信息
	FETCH_REWARD = 1,			-- 获取相应奖励
}

FIX_STUCK_STATUS = {
	BEGIN = 0,
	SUCC = 1,
	FAIL = 2,
}

EXCHANGE_SHOP_NUM = {
	TYPE = 19,
	INDEX = 11,
}

-- 服务器阵营
SERVER_GROUP_TYPE = {
	SERVER_GROUP_TYPE_1 = 0,
	SERVER_GROUP_TYPE_2 = 1,
	SERVER_GROUP_TYPE_MAX = 2,
}

CROSS_XYCITY_REQ_TYPE = {
	OP_HIT_CAPTIVE = 0,        		-- 击晕俘虏，param1是objid
	OP_CAPTURE_CAPTIVE = 1,      	-- 抓俘虏，param1是objid
	OP_ACCEPT_MIDAO_TASK = 2,  		-- 接受密道任务
	OP_BUY_BUFF = 3,     			-- 购买buff，param1是购买buff的类型，0听曲、1喝酒、2按摩
	OP_MIDAO_TRANSPORT = 4,			-- 密道传送
}

-- 跨服密道信息
CROSS_XYCITY_MIDAO_STATUS = {
	MIDAO_STATE_OPEN = 0,							-- 密道开启
	MIDAO_STATE_CD = 1,								-- 密道关闭(密道再次开启cd中)
	MIDAO_STATE_CAN_OPEN = 2,						-- 密道可以开启
	MIDAO_STATE_UNKNOWN = 3,						-- 其他情况
}

DAY_TARGET = {
	TASK_MAX_COUNT = 16,	
}

--七夕送花
SENDING_FLOWER = {
	INFO = 0,						--请求信息
	GETREWARD = 1,					--请求获取奖励
}

REBIRTH_REQ_TYPE = {
	ZHUANSHENGSYSTEM_REQ_TYPE_ALL_INFO = 0,							-- 请求所有信息
	ZHUANSHENGSYSTEM_REQ_TYPE_ZHUANSHENG_LEVEL = 1,					-- 请求转生等级升级
	ZHUANSHENGSYSTEM_REQ_TYPE_SLOT_ITEM_CONSUME = 2,				-- 套装装备消耗
	ZHUANSHENGSYSTEM_REQ_TYPE_SLOT_ITEM_UPGRADE = 3,				-- 升级请求
	ZHUANSHENGSYSTEM_REQ_TYPE_ATTR_REPLACE = 4,						-- 洗练属性替换请求
	ZHUANSHENGSYSTEM_REQ_TYPE_TO_LEVEL_FIVE = 5,					-- 属性置5请求
	ZHUANSHENGSYSTEM_REQ_TYPE_SAME_LEVEL = 6,						-- 属性取同请求
	ZHUANSHENGSYSTEM_REQ_TYPE_TO_NEED_PREFIX = 7,					-- 属性设为指定前缀请求
}

-- 感恩回馈
RA_APPRECIATION_REWARD_OPERA_TYPE = {
	RA_APPRECIATION_REWARD_OPERA_TYPE_ALL_INFO = 0,						-- 所有信息
	RA_APPRECIATION_REWARD_OPERA_TYPE_FETCH = 1,							-- 领取
}
RMB_BUY_TYPE = {
	RMB_BUY_TYPE_RA_XIANGOULIBAO = 5,    -- 限购礼包
	RMB_BUY_TYPE_MAX,
}

RA_DAILY_XIANGOULIBAO_OPERA_TYPE = {
	RA_DAILY_XIANGOULIBAO_OPERA_TYPE_ALL_INFO = 0,
	RA_DAILY_XIANGOULIBAO_OPERA_TYPE_FETCH_COIN = 1,
	RA_DAILY_XIANGOULIBAO_MAX_ITEM_COUNT = 6,
}

RARE_TREASURE = {
	RA_ZHEN_YAN_REQ_TYPE_INFO = 0,									-- 活动信息,无参
	RA_ZHEN_YAN_REQ_TYPE_CHANGE_WORD = 1,							-- 活动信息,参数信息:param1奖池编号,param2原始字编号（-1无效编号 第一次选编号用）,param3目标字编号
}

BABY_BOSS_OPERATE_TYPE = {
	TYPE_BOSS_INFO_REQ = 0,				-- 请求boss信息
	TYPE_ROLE_INFO_REQ = 1,				-- 请求人物相关信息
	TYPE_ENTER_REQ = 2,					-- 请求进入宝宝boss, param_0是场景id, param_1是boss_id
	TYPE_LEAVE_REQ = 3,					-- 请求离开宝宝boss
}

BABY_TYPE_LIMIT = {
	NORMAL = 0,
	MEDIUM = 1,
	HIGH = 2,
	FREE = 10000,
}

EXCHANGE_SHOP_NUM_MAX = {
	TYPE = 4,
	INDEX = 10,
}

-- 卡牌
RA_MUSEUM_CARD_OPERA_TYPE = {
	RA_MUSEUM_CARD_OPERA_TYPE_ALL_INFO = 0,							-- 卡牌所有信息
	RA_MUSEUM_CARD_OPERA_TYPE_ACTIVE = 1,							-- 卡牌激活(param1卡牌id)
	RA_MUSEUM_CARD_OPERA_TYPE_UPSTAR = 2,							-- 卡牌升星(param1卡牌id)
	RA_MUSEUM_CARD_OPERA_TYPE_FENJIE = 3,							-- 卡牌分解(param1物品id, param2物品数量)
}

DIE_MAIL = {
	SEND_KILLER_ITEM_COUNT = 6,
	CAMP_TYPE = 3,
}

MOON_GIFT = {
	QIANWANG_CHONGZHI = 1,
	LINGQU_JIANGLI = 2,
	GANXIE_CANYU = 3,
}

ACT_SPECIAL_REBATE_TYPE = {
	FOOT = 1,
	HEAD = 2,
	WAIST = 3,
	FACE = 4,
	ARM = 5,
	BEAD = 6, 			-- 灵宝
	TREASURE = 7, 		-- 仙宝
}

--形象进阶返利活动
RA_UPGRADE_NEW_OPERA_TYPE = {
    RA_UPGRADE_NEW_OPERA_TYPE_QUERY_INFO = 0,
    RA_UPGRADE_NEW_OPERA_TYPE_FETCH_REWARD = 1,
    RA_UPGRADE_NEW_OPERA_TYPE_MAX = 2,
}

-- 装扮进阶(upgrade system)请求类型
UGS_REQ = {
	REQ_TYPE_ALL_INFO = 0,		-- 请求神翼信息, 无参数
	REQ_TYPE_UP_GRADE = 1,			-- 请求进阶, param1 = repeat_times, param2 = auto_buy;
	REQ_TYPE_UP_GRADE_STAR = 2,		-- 升星级请求, param1 = stuff_index, param2 = is_auto_buy;
	REQ_TYPE_USE_IMG = 3,			-- 请求使用形象, param1 = image_id, param2 = reserve_sh;
	REQ_TYPE_UP_UNUSE_IMG = 4,		-- 请求取消使用形象, param1 = image_id, param2 = reserve_sh;
	REQ_TYPE_UP_GRADE_EQUIP = 5,	-- 升级装备请求, param1 = equip_idx, param2 = reserve;
	REQ_TYPE_UP_GRADE_SKILL = 6,	-- 技能升级请求, param1 = skill_idx, param2 = auto_buy;
	REQ_TYPE_UP_GRADE_IMG = 7,		-- 特殊形象进阶, param1 
	REQ_TYPE_UP_REUSE_IMG = 8,		-- 恢复上次使用形象
}

-- 五行之灵
ELEMENT_HEART_REQ_TYPE = {
	ACTIVE_GHOST = 0,							-- 激活五行之灵 param1 五行之灵id
	CHANGE_GHOST_WUXING_TYPE = 1,				-- 改变五行之灵五行 param1 五行之灵id
	FEED_ELEMENT = 2,							-- 喂养五行之灵	param1 五行之灵id param2 虚拟物品id param3 物品数量
	UPGRADE_GHOST = 3,							-- 五行之灵进阶	param1 五行之灵id param2 是否一键  param3 是否自动购买
	GET_PRODUCT = 4,							-- 五行之灵采集	param1 五行之灵id
	PRODUCT_UP_SEED = 5,						-- 五行之灵产出加速	param1 五行之灵id
	UPGRADE_CHARM = 6,							-- 元素之纹升级 para1 升级元素之纹下标 param2 消耗格子下标
	ALL_INFO = 7,								-- 请求所有信息
	CHOUJIANG = 8,								-- 五行之灵抽奖 param1 次数
	FEED_GHOST_ONE_KEY = 9,						-- 一键喂养五行之灵	param1 id
	SET_GHOST_WUXING_TYPE = 10,					-- 设置五行之灵类型	param1 id
	SHOP_REFRSH = 11,							-- 商店刷新 param 1是否使用积分刷新
	SHOP_BUY = 12,								-- 商城购买 param 1 商品seq
	XILIAN = 13,								-- 洗练 param1 元素id， param2 锁洗标志 param3洗练颜色、 param4 是否自动购买
	PUTON_EQUIP = 14,							-- 穿装备 param1元素id param2装备格子
	UPGRADE_EQUIP = 15,							-- 装备升级 Parma1 元素id param2 是否一键升级
	EQUIP_RECYCLE = 16,							-- 装备分解 param1 背包索引 param 2 消耗数量
}
