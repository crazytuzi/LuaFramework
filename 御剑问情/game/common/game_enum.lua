-----------------------------------------------------
-- 游戏中的枚举
-----------------------------------------------------
GameEnum =
{
	BASE_SPEED = 1800,
	SHENQI_SUIT_NUM_MAX = 64,
	SHENQI_PART_TYPE_MAX = 4,
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

	SHRINK_BTN_INTERABLE_LEVEL = 60,				--主界面右上角收起按钮开启等级

	ACT_HALL_ICON_LEVEL = 130,						--随机活动卷轴按钮开启等级

	NOVICE_LEVEL = 160, 							--新手最大等级
	POPUP_EXP = 130,                                --弹出获取经验最低等级
	AVTAR_REMINDER_LEVEL = 140, 					--头像红点提示等级

	MINGREN_REMINDER_LEVEL = 150, 					--名人红点提示等级

	-- 转盘基本信息
	TURNTABLE_TYPE_MAX_COUNT = 16,
	TURNTABLE_OPERA_TYPE = 0,

   --疯狂礼包
    RA_CRAZY_GIFT_CFG_COUNT_MAX  = 8,               --每种礼包配置个数
    RA_CRAZY_GIFT_GIFT_TYPE_MAX = 8,                --礼包种类个数
    RA_CRAZY_GIFT_REQ_TYPE_INFO = 0,                --操作类型,请求所有信息
    RA_CRAZY_GIFT_REQ_TYPE_BUY = 1,                 --操作类型,请求购买

	--婚宴操作
	HUNYAN_OPERA_TYPE_INVITE = 1,					-- 婚宴邀请
	HUNYAN_OPERA_TYPE_HONGBAO = 2,					-- 婚宴发红包
	HUNYAN_OPERA_TYPE_HUAYU = 3,					-- 浪漫花雨
	HUNYAN_OPERA_TYPE_YANHUA = 4,					-- 婚宴燃放烟花
	HUNYAN_OPERA_TYPE_PAOHUAQIU = 5,				-- 婚宴放置烟花
	HUNYAN_OPERA_TYPE_SAXIANHUA = 6,				-- 婚宴撒鲜花
	HUNYAN_OPERA_TYPE_INVITE_INFO = 7, 				-- 婚宴信息
	-- HUNYAN_OPERA_TYPE_RED_BAG = 8,					-- 婚宴送红包  param1  目标uid  param2  seq
	-- HUNYAN_OPERA_TYPE_FOLWER = 9,					-- 婚宴送花  param1  目标uid  param2  seq
	HUNYAN_OPERA_TYPE_BAITANG_REQ = 8,				-- 请求拜堂
	HUNUAN_OPERA_TYPE_BAITANG_RET = 9,				-- 收到拜堂  param1  1:同意  0:拒绝
	HUNYAN_OPERA_TYPE_APPLY = 10,					-- 申请参加婚礼
	HUNYAN_OPERA_TYPE_IS_AGREE_APPLY = 11,			-- 是否同意请求  param1  目标uid  param2  1:同意  0:拒绝
	HUNYAN_GET_BLESS_RECORD_INFO = 12,				-- 获取祝福历史
	HUNYAN_GET_APPLICANT_INFO = 13,					-- 获取申请者信息
	HUNYAN_GET_WEDDING_INFO = 14,					-- 获取婚礼信息
	HUNYAN_GET_WEDDING_ROLE_INFO = 15,				-- 获取婚礼个人信息
	HUNYAN_OPERA_APPLICANT_OPERA = 16,				-- 申请者操作  param1  目标uid  param2  1:同意  0:拒绝
	HUNYAN_OPERA_ANSWER_QUESTION = 17,				-- 答题操作 param1 答案id
	HUNYAN_OPERA_GUEST_BLESS = 18,					-- 宾客祝福

	--婚宴邀请类型
	HUNYAN_INVITE_TYPE_ALL_FRIEND = 0,				--邀请所有好友
	HUNYAN_INVITE_TYPE_ONE_FRIEND = 1,				--邀请单个好友
	HUNYAN_INVITE_TYPE_ALL_GUILD_MEMBER = 2,		--邀请所有公会成员
	HUNYAN_INVITE_TYPE_ONE_GUILD_MEMBER = 3,		--邀请单个公会成员

	ITEM_OPEN_TITLE = 3,							--背包打开称号面板

	--货币
	CURRENCY_COIN = 206003,								--金币（铜币）
	CURRENCY_BIND_COIN = 206004,						--绑定金币(绑定铜币)
	CURRENCY_BIND_GOLD = 206002,						--绑定钻石（绑定元宝）
	CURRENCY_GOLD = 206001,								--钻石（元宝）
	CURRENCY_NV_WA_SHI = 206005,						--水晶（女娲石）
	CURRENCY_KUA_FU = 206006,							--跨服
	CURRENCY_LING_JING = 206010,						--灵精
	PILAO_CARD = 23232,									--疲劳增值卡

	NOVICE_WARM_TIP = 40,								--新手温馨提示

	--职业
	ROLE_PROF_1 = 1, 								--魔剑士
	ROLE_PROF_2 = 2, 								--元素使
	ROLE_PROF_3 = 3, 								--猎魔人
	ROLE_PROF_4 = 4, 								--法师
	ROLE_PROF_11 = 11,								--狱血魔神
	ROLE_PROF_12 = 12,								--灵魂猎手
	ROLE_PROF_13 = 13,								--妙笔生花
	ROLE_PROF_14 = 14,								--寒冰尊者

	--性别
	FEMALE = 0,										--女性
	MALE = 1,										--男性

	--阵营
	ROLE_CAMP_0 = 0, 								--无
	ROLE_CAMP_1 = 1,								--昆仑
	ROLE_CAMP_2 = 2, 								--蓬莱
	ROLE_CAMP_3 = 3, 								--苍穹

	--物品颜色
	ITEM_COLOR_WHITE = 0,							-- 白
	ITEM_COLOR_GREEN = 1,							-- 绿
	ITEM_COLOR_BLUE = 2,							-- 蓝
	ITEM_COLOR_PURPLE = 3,							-- 紫
	ITEM_COLOR_ORANGE = 4,							-- 橙
	ITEM_COLOR_RED = 5,								-- 红
	ITEM_COLOR_GLOD = 6,							-- 分红
	ITEM_COLOR_JINGSE = 7,							-- 金色
	ITEM_COLOR_CAI = 8,								-- 彩色

	--装备品质颜色
	EQUIP_COLOR_GREEN = 0,							-- 绿
	EQUIP_COLOR_BLUE = 1,							-- 蓝
	EQUIP_COLOR_PURPLE = 2,							-- 紫
	EQUIP_COLOR_ORANGE = 3,							-- 橙
	EQUIP_COLOR_RED = 4,							-- 红
	EQUIP_COLOR_TEMP = 5,							-- 金
	EQUIP_COLOR_PINK = 6,							-- 粉装

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
    EQUIP_TYPE_GOUYU_LEFT = 109,                    --左勾玉
    EQUIP_TYPE_GOUYU_RIGHT = 110,                   --右勾玉

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
	BABY_MAX_COUNT = 10,							-- 最大可拥有的宝宝数量限制
	BABY_MAX_LEVEL = 10,							-- 宝宝最大等级
	BABY_MAX_GRADE = 10, 							-- 宝宝最大阶级
	BABY_SPIRIT_COUNT = 4,							-- 最大守护精灵数量
	MAX_SHENG_BABY_COUNT = 5,						-- 不超生最多生宝宝数量
	CAN_SHENG_BABY_LEVEL = 4,						-- 不超生最多生宝宝数量
	USE_TYPE_LITTLE_PET = 57,						-- 小宠物（Item使用类型）
	USE_TYPE_LITTLE_PET_FEED = 706,					-- 小宠物喂养道具

    --神州六器
    SHENZHOU_WEAPON_TYPE = 41,						 	--神州六器
    SHENZHOU_WEAPON_SLOT_COUNT = 6,						--神州六器槽数量
	SHENZHOU_WEAPON_BACKPACK_COUNT = 30,				--神州六器背包数量
	EQUIP_MAX_LEVEL = 50,								--神州六器最大等级
	MELT_MAX_LEVEL = 100,								--神州六器熔炼最大等级
	IDENTIFY_MAX_LEVEL = 10,							--神州六器鉴定最大等级
	IDENTIFY_STAR_MAX_LEVEL = 10,						--神州六器鉴定最大星级

	SEND_REASON_DEFAULT = 0,						-- 单个装备信息返回,默认
	SEND_REASON_COMPOUND = 1,						-- 单个装备信息返回,合成

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
	EQUIP_INDEX_GOUYU_1 = 10,						--勾玉1
	EQUIP_INDEX_GOUYU_2 = 11,						--勾玉2

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

	MARRY_EQUIP_SEARCH = 108, 						-- 结婚情饰的搜索类型

	-- 宝石类型
	STONE_FANGYU = 1,								-- 防御类型宝石
	STONE_GONGJI = 2,								-- 攻击类型宝石
	STONE_HP = 3,									-- 血气类型的宝石

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
	FIGHT_CHARINTATTR_TYPE_PER_JINGZHUN = 15,		--精准（破甲率）
	FIGHT_CHARINTATTR_TYPE_PER_BAOJI = 16,			--暴击（废弃）
	FIGHT_CHARINTATTR_TYPE_PER_KANGBAO = 17,		--抗暴（抵抗幸运一击）
	FIGHT_CHARINTATTR_TYPE_PER_POFANG = 18,			--破防百分比（增伤率）
	FIGHT_CHARINTATTR_TYPE_PER_MIANSHANG = 19,		--免伤百分比（免伤率）

	JUMP_ROLE_LEVEL = 10,							--跳跃的最小角色等级
	JUMP_MAX_COUNT = 4,								--最大跳跃次数
	JUMP_RECOVER_TIME = 5,							--跳跃恢复时间
	JUMP_RANGE = 17,								--跳跃的距离

	BASE_CHARINTATTR_TYPE_MAXHP = 33,				--基础最大血量
	BASE_CHARINTATTR_TYPE_MAXMP = 34,				--基础最大魔法
	BASE_CHARINTATTR_TYPE_GONGJI = 35,				--基础攻击
	BASE_CHARINTATTR_TYPE_FANGYU = 36,				--基础防御
	BASE_CHARINTATTR_TYPE_MINGZHONG = 37,			--基础命中
	BASE_CHARINTATTR_TYPE_SHANBI = 38,				--基础闪避
	BASE_CHARINTATTR_TYPE_BAOJI = 39,				--基础暴击
	BASE_CHARINTATTR_TYPE_JIANREN = 40,				--基础坚韧（抗暴）
	BASE_CHARINTATTR_TYPE_MOVE_SPEED = 41,			--基础移动速度
	BASE_CHARINTATTR_TYPE_FUJIA_SHANGHAI = 42,		--附加伤害（女神攻击）
	BASE_CHARINTATTR_TYPE_DIKANG_SHANGHAI = 43,		--抵抗伤害（废弃）
	BASE_CHARINTATTR_TYPE_PER_JINGZHUN = 44,		--精准（破甲率）
	BASE_CHARINTATTR_TYPE_PER_BAOJI = 45,			--暴击（暴击伤害率）
	BASE_CHARINTATTR_TYPE_PER_KANGBAO = 46,			--抗暴（废弃）
	BASE_CHARINTATTR_TYPE_PER_POFANG = 47,			--破防百分比（增伤率）
	BASE_CHARINTATTR_TYPE_PER_MIANSHANG = 48,		--免伤百分比（免伤率）

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
	ATTACK_MODE_TEAM = 1,							-- 组队模式
	ATTACK_MODE_GUILD = 2,							-- 战盟模式
	ATTACK_MODE_ALL = 3,							-- 全体模式
	ATTACK_MODE_NAMECOLOR = 4,						-- 善恶模式
	ATTACK_MODE_CAMP = 5,							-- 阵营模式
	ATTACK_MODE_MAX = 6,

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

	MO_LONG_GATHER = 5,                             -- 魔龙宝箱每波采集次数

	FB_CHECK_TYPE = {
		FBCT_DAILY_FB = 1,							-- 日常副本
		FBCT_STORY_FB = 2,							-- 剧情副本
		FBCT_CHALLENGE = 3,							-- 挑战副本
		FBCT_PHASE = 4,								-- 阶段副本
		FBCT_FUN_MOUNT_FB = 5,						-- 功能开启副本坐骑
		FBCT_TOWERDEFEND_PERSONAL  = 6,				-- 单人塔防
		FBCT_YAOSHOUJITANG_TEAM = 8,				-- 妖兽祭坛组队本
		FBCT_QINGYUAN = 9,							-- 情缘副本
		FBCT_ZHANSHENDIAN = 10,						-- 战神殿副本
		FBCT_HUNYAN = 11,							-- 婚宴副本
		FBCT_TOWERDEFEND_TEAM = 12,					-- 组队塔防
		FBCT_ZHUANZHI_PERSONAL = 13,				-- 个人转职副本
		FBCT_MIGONGXIANFU_TEAM = 14,				-- 迷宫仙府副本
		FBCT_WUSHUANG = 15,							-- 无双副本
		FBCT_PATAFB = 16,							-- 爬塔副本
		FBCT_CAMPGAOJIDUOBAO = 17,					-- 师门高级夺宝
		FBCT_VIPFB = 18,							-- VIP副本
		FBCT_GUIDE = 21,							-- 引导副本
		FBCT_GUAJI_TA = 22,							-- 挂机塔
		FBCT_TEAM_EQUIP_FB = 23,					-- 组队装备副本
		FBCT_DAILY_TASK_FB = 24,					-- 支线副本
		FBCT_TUITU_NORMAL_FB = 25,					-- 推图副本
		FBCT_SHENGDI_FB = 26,						-- 圣地副本
		FBCT_SUOYAOTOWER_FB = 28,					-- 锁妖塔
		FBCT_GOD_TEMPLE = 29,						-- 封神殿
	},

	FIELD_GOAL_SKILL_TYPE_MAX = 8,					-- 技能数量

	FIELD_GOAL_SKILL_TYPE = {
		FIELD_GOAL_INVALID_SKILL_TYPE = 0,			--
		FIELD_GOAL_HURT_MONSTER_ADD = 1, 			-- 压制
		FIELD_GOAL_KILL_MONSTER_EXP_ADD = 2,		-- 盛宴
		FIELD_GOAL_ABSORB_BLOOD = 3,				-- 血祭
		FIELD_GOAL_MAX_SKILL_TYPE = 4,
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
	ROLE_BAG_SLOT_NUM = 160, 						--背包格子个数

	WORLD_EVENT_TYPE_MAX = 7, 						--世界事件类型数


	CARD_MAX = 12, 									--卡牌数
	NEW_BOSS_COUNT = 3, 							--镜像boss数

	MENTALITY_SHUXINGDAN_MAX_TYPE = 3, 				--属性丹种类

	--随机活动的常量
	RAND_ACTIVITY_SERVER_PANIC_BUY_ITEM_MAX_COUNT = 16, 	--全民疯抢
	RAND_ACTIVITY_PERSONAL_PANIC_BUY_ITEM_MAX_COUNT = 16,	--个人疯抢

	HONGBAO_SEND = 0,							--发送红包
	HONGBAO_GET = 1,							--领取红包

	WUXINGGUAJI_STUFF_MAX = 5,						-- 材料个数
	WUXINGGUAJI_TARGET_MAX = 5,						-- 目标个数
	WUXINGGUAJI_BOSS_NUM = 1,						-- BOSS的最大数量

	WEEKEND_BOSS_MAX_BOSS_NUM = 5,                  --周末BOSS最大数量

	MENTALITY_WUXING_MAX_COUNT = 35,				-- 五行个数

	NOTIFY_REASON_GET = 0,							--仙盟运势 所有人
	NOTIFY_REASON_CHANGE = 1,						--仙盟运势 改变的人

	--------------------符文系统------------------------------
	RUNE_SYSTEM_BAG_MAX_GRIDS = 400,				--背包最大格子数量不可变 数据库
	RUNE_SYSTEM_SLOT_MAX_NUM = 10,					--符文槽最大数
	RUNE_SYSTEM_XUNBAO_RUNE_MAX_COUNT = 10,			--寻宝得符文最大数量
	RUNE_JINGHUA_TYPE = 19,							--符文精华类型
	RUNE_MAX_LEVEL = 200,							--符文最大等级

	--符文物品颜色
	RUNE_COLOR_WHITE = 0,							-- 白
	RUNE_COLOR_BLUE = 1,							-- 蓝
	RUNE_COLOR_PURPLE = 2,							-- 紫
	RUNE_COLOR_ORANGE = 3,							-- 橙
	RUNE_COLOR_RED = 4,								-- 红
	RUNE_COLOR_PINK = 5,							-- 粉
	------------------------------------------------------------

	-----------------------小宠物相关-------------------------------
	LITTLEPET_QIANGHUAGRID_MAX_NUM = 5,
	LITTLE_PET_COUPLE_MAX_SHARE_NUM = 10, 				--夫妻共享宠物最大数量
	LITTLE_PET_MAX_CHOU_COUNT = 10, 					--抽奖次数最大值
	LITTLE_PET_SHARE_MAX_LOG_NUM = 20,
	MAX_FRIEND_NUM = 100, 								--最大好友数量
	LITTLEPET_QIANGHUAPOINT_CURRENT_NUM = 8, 			--当前强化点数量
	LITTLEPET_EQUIP_INDEX_MAX_NUM = 4, 					--小宠物玩具装备下标数
	LITTLE_PET_SPECIAL_INDEX = 6,						--特殊小宠物位置
	--------------------------------------------------------------

	ELEMENT_HEART_WUXING_TYPE_MAX = 5,					-- 五行之灵五行最大数量
	ELEMENT_HEART_MAX_COUNT = 5,						-- 五行之灵槽最大数量
	ELEMENT_HEART_MAX_XILIAN_SLOT = 10,					-- 五行之灵洗练最大数量
	ELEMENT_HEART_MAX_GRID_COUNT = 100, 				-- 元素之涌背包格子数
	ELEMENT_SHOP_ITEM_COUNT = 10,						-- 商店当前刷新出来的物品数量
	ELEMENT_MAX_EQUIP_SLOT = 6,							-- 五行之灵最大装备格子数量

	TEAM_MAX_COUNT = 3,								--组队最大人数

	MOUNT_EQUIP_COUNT = 4,							--坐骑装备数量
	EQUIP_UPGRADE_PERCENT = 0.00006,				-- 装备升级乘以的百分比
	MOUNT_EQUIP_ATTR_COUNT = 3,						--坐骑装备属性数量
	MOUNT_EQUIP_MAX_LEVEL = 200,					--坐骑装备最大等级
	MAX_MOUNT_LEVEL = 100,							--坐骑最大等级
	MAX_MOUNT_GRADE = 30,							--坐骑最大阶数
	MAX_MOUNT_SPECIAL_IMAGE_ID = 63,				--可进阶坐骑特殊形象ID
	MAX_SPRITE_SPECIAL_IMAGE_ID = 31,				--可进阶精灵特殊形象ID
	MAX_UPGRADE_LIMIT = 10,							--坐骑特殊形象进阶最大等级
	MOUNT_SKILL_COUNT = 4,							--坐骑技能数量
	MOUNT_SKILL_MAX_LEVEL = 100,					--坐骑技能最大等级
	MOUNT_SPECIAL_IMA_ID = 1000,					--坐骑特殊形象ID换算
	MAX_MOUNT_SPECIAL_IMAGE_COUNT = 16,				--坐骑特殊形象数量

	MAX_WAIST_SPECIAL_IMAGE_COUNT = 64,				--腰饰特殊形象数量
	MAX_TOUSHI_SPECIAL_IMAGE_COUNT = 64,			--头饰特殊形象数量
	MAX_QILINBI_SPECIAL_IMAGE_COUNT = 64,			--麒麟臂特殊形象数量
	MAX_MASK_SPECIAL_IMAGE_COUNT = 64,				--面饰特殊形象数量
	MAX_LINGZHU_SPECIAL_IMAGE_COUNT = 64,			--灵珠特殊形象数量
	MAX_XIANBAO_SPECIAL_IMAGE_COUNT = 64,			--仙宝特殊形象数量
	MAX_LINGCHONG_SPECIAL_IMAGE_COUNT = 64,			--灵宠特殊形象数量
	MAX_LINGGONG_SPECIAL_IMAGE_COUNT = 64,			--灵弓特殊形象数量
	MAX_LINGQI_SPECIAL_IMAGE_COUNT = 64,			--灵骑特殊形象数量
	MAX_WEIYAN_SPECIAL_IMAGE_COUNT = 64,			--尾焰特殊形象数量

	MAX_XIANJIAN_COUNT = 8,							--仙剑把数（原先是8）
	JIANXIN_SLOT_PER_XIANJIAN = 7,					--每把剑的剑心孔数

	CSA_RANK_TYPE_MAX = 4,									--合服活动-排行榜MAX
	COMBINE_SERVER_ACTIVITY_RANK_REWARD_ROLE_NUM = 3,		--合服排行前几
	COMBINE_SERVER_RANK_QIANGOU_ITEM_MAX_TYPE = 3,			--合服抢购第一
	COMBINE_SERVER_SERVER_PANIC_BUY_ITEM_MAX_COUNT = 16,	--合服疯狂抢购全服物品数量
	COMBINE_SERVER_PERSONAL_PANIC_BUY_ITEM_MAX_COUNT = 8,	--合服疯狂抢购个人物品数量
	COMBINE_SERVER_MAX_FOUNDATION_TYPE = 10, 				--合服基金

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
	--lpl
	CHINESE_ZODIAC_MAX_EQUIP_LEVEL = 80,					-- 装备最高等级
	TIAN_XIANG_COMBINE_MEX_BEAD_NUM = 15, 					-- 每个组合最多的珠子数


	TIAN_XIANG_TABEL_ROW_COUNT = 7,			-- 行
	TIAN_XIANG_TABEL_MIDDLE_GRIDS = 7,		-- 列
	TIAN_XIANG_ALL_CHAPTER_COMBINE = 3,		-- 每个章节的组合数
	TIAN_XIANG_CHAPTER_NUM = 10,			-- 章节最大数
	TIAN_XIANG_SPIRIT_CHAPTER_NUM = 5,		-- 星灵章节最大数

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
	JINGLING_PTHANTOM_MAX_TYPE_NEW_2 = 32,      -- 新增精灵幻化升级等级
	JINGLING_EQUIP_MAX_PART = 8,
	JINGLING_CARD_MAX_TYPE = 16,

	JING_LING_SKILL_COUNT_MAX = 12,				-- 精灵技能最大数量
	JING_LING_SKILL_REFRESH_ITEM_MAX = 4,		-- 技能刷新最大格子数
	JING_LING_SKILL_REFRESH_SKILL_MAX = 11,		-- 技能刷新最大技能数量

	LIEMING_FUHUN_SLOT_COUNT = 10,				-- 精灵命魂曹数量		-- 服务器值为0~9, 0~6为普通命魂槽位, 7~8为彩色命魂槽位, 9不可穿戴任何命魂
	LIEMING_LIEHUN_POOL_MAX_COUNT = 18,			-- 精灵命魂猎取池
	LIEMING_HUNSHOU_BAG_GRID_MAX_COUNT = 36,	-- 精灵命魂背包最大格子数量
	RAND_ACTIVITY_ZHENBAOGE_ITEM_COUNT = 9,				--珍宝阁格子数量
	RAND_ACTIVITY_TREASURE_BUSINESSMAN_REWARD_COUNT = 6, --秘宝商人奖励物品数量
	BIG_CHATFACE_GRID_COUNT = 9,						--表情拼图数目
	SC_RA_MONEYTREE_CHOU_MAX_COUNT_LIMIT = 10,			-- 摇钱树奖励最大数量
	RA_KING_DRAW_LEVEL_COUNT = 3,						--陛下请翻牌最大牌组数
	RA_KING_DRAW_MAX_SHOWED_COUNT = 9,					-- 陛下请翻牌最大牌数

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

	BOSS_HANDBOOK_SLOT_PER_CARD = 4,					--Boss图鉴每张卡牌的四个部分
	BOSS_HANDBOOK_CARD_MAX_COUNT = 32, 					--Boss图鉴卡牌最大数量

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

	GOLDEN_PIG_SUMMON_TYPE_MAX = 3,						--金猪召唤boss类型
	GUAJI_SCENE_COUNT = 3,								--野外挂机场景数量
	GUAJI_BOSS_NEED_COUNT = 1,							--任务挂机boss需击杀的数量

	SHENGE_SYSTEM_SHENGESHENQU_MAX_NUM = 10,
	SHENGE_SYSTEM_SHENGESHENQU_ATTR_MAX_NUM = 7,
	SHENGE_SYSTEM_SHENGESHENQU_XILIAN_SLOT_MAX_NUM = 3,

	TALENT_CHOUJIANG_GRID_MAX_NUM = 9,	                --天赋抽奖最大格子数量

	PASTURE_SPIRIT_MAX_IMPRINT_ATTR_COUNT = 5,			-- 印记附加属性最大条数
	SHEN_YIN_PASTURE_SPIRIT_MAX_SHOP_ITEM_COUNT = 14,	-- 商店格子数
	SHEN_YIN_PASTURE_SPIRIT_MAX_GRID_COUNT = 100,		-- 背包格子数
	SHEN_YIN_LIEHUN_POOL_MAX_COUNT = 18,				-- 猎魂池容量最大数

	BABY_BOSS_KILLER_MAX_COUNT = 5,			--宝宝boss击杀信息最大条数

    ---------------------装备副本-------------------------
	FB_EQUIP_MAX_MYSTERYLAYER_NUM = 16,																	--神秘层数量
	FB_EQUIP_MAX_GOODS_NUM_PER_MYSTERYLAYER  = 6,														--每层神秘宝藏数量
	FB_EQUIP_MAX_LAYER_ID = 71,																			--最大层号
	FB_EQUIP_MAX_GOODS_SEQ = 16 * 6,																	--最大神秘层商品编号
	-------------------------------------------------------

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
	WEI_ZHUZHAN_XIANNV_SHANGHAI_PRECENT = 1,		--未出战仙女伤害百分比
	ACTIVE_ITEM_NUM	= 1,							--激活仙女需要物品数量

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

	XING_MAI_SLIDER_TIME = 3,				-- x星脉冷却条充满时间
	MAX_CROSS_BOSS_PER_SCENE = 20,			-- 场景内最大boss数量

	MAX_NOTICE_COUNT = 30,					-- 爱情契约聊天最大数

	PERSONAL_GOAL_COND_MAX = 3,				-- 个人目标条件

	XIAN_ZHEN_HUN_YU_TYPE_MAX = 3, 			-- 仙镇魂玉类型

	SHENSHOU_MAX_BACKPACK_COUNT = 200,					-- 神兽背包容量个数
	SHENSHOU_MAX_EQUIP_SLOT_INDEX = 4, 					-- 神兽装备最大部位index
	SHENSHOU_MAX_ID = 32,								-- 神兽最大ID
	SHENSHOU_MAX_EQUIP_ATTR_COUNT = 3,					-- 神兽装备最大随机属性个数
	SHENSHOU_EQ_MAX_LV = 500,							-- 神兽装备最大等级

	-------------------福利---------------------------
	MAX_GROWTH_VALUE_GET_TYPE = 4,				--欢乐果树成长值最大数量
	MAX_CHONGJIHAOLI_RECORD_COUNT = 30,			--冲级豪礼最大数量

	SALE_TYPE_COUNT_MAX = 100,				-- 拍卖种类
	Lock_Time = 120,							-- 自动锁屏时间

	JING_LING_HOME_REWARD_ITEM_MAX = 40, 	-- 精灵家园列表长度
	JINGLING_MAX_TAKEON_NUM = 4, 			-- 放养精灵最大数目

	GUILD_BATTLE_NEW_POINT_NUM = 5,			-- 公会争霸据点数量
	FIGHTING_CHALLENGE_OPPONENT_COUNT = 4,	-- 挖矿挑战角色人数
	MAX_CAMERA_MODE = 2,					-- 摄像机模式
	JING_LING_EXPLORE_LEVEL_COUNT = 6, 		-- 精灵探险关卡数量

	FISHING_FISH_TYPE_MAX_COUNT = 8,		-- 鱼的种类数
	FISHING_GEAR_MAX_COUNT = 3,				-- 法宝种类数
	FISHING_BE_STEAL_NEWS_MAX = 5,			-- 钓鱼被偷日志数量
	FISHING_SCORE_MAX_RANK = 10,			-- 钓鱼积分排行榜最大数量

	RA_MARRY_SHOW_COUPLE_COUNT_MAX = 10,	-- 我们结婚吧最多显示对数
	MAX_ZHIBAO_HUANHUA = 30,				-- 至宝幻化最大数量

	SHEN_EQUIP_NUM = 10,					-- 神装部位数量
	SHENSHOU_MAX_RERFESH_ITEM_COUNT = 14,	-- 唤灵物品显示数量
	SPIRIT_MEET_SCENE_COUNT = 9,            -- 精灵奇遇场景数

	IMG_FULING_JINGJIE_TYPE_MAX = 7,		-- 赋灵种类最大数量
	IMG_FULING_SLOT_COUNT = 7,				-- 赋灵格子数

	COMBINE_SERVER_BOSS_MAX_COUNT = 10,  	-- 合服boss最大数量
	COMBINE_SERVER_BOSS_RANK_NUM = 10,		-- 合服boss排行榜显示最大数量

	TALENT_TYPE_MAX = 7,					--天赋种类数量
	TALENT_SKILL_GRID_MAX_NUM = 13,			--天赋技能最大格子数量

	SEASONS_MIN = 8,
	SEASONS_MAX = 11,
	TIAN_XIANG_COMBLE_NUM = 14,				-- 天象组合最大值
	BOLL_GROUP_MAX_NUM = 14,				-- 天象组合需要最多珠子数量

	GREATE_SOLDIER_SPEICAL_IMG_COUNT_MAX = 32,				--名将幻化最大数量

	-- 属性顺序枚举
	AttrList = {
		[1] = "maxhp",
		[2] = "gongji",
		[3] = "fangyu",
	},

	BIPIN_POWER_COND = 10000,				--比拼活动战力条件
	ZIJI_INTERVAL_TIME = 7200,				--集字活动提醒间隔
	BIPIN_LEVEL_COND = 30, 					--比拼活动阶级条件
	MAKEMOON_INTERVAL_TIME = 7200,			--月饼活动提醒间隔

	TIANSHENHUTI_EQUIP_MAX_COUNT = 8,             -- 装备部位数量
	TIANSHENHUTI_BACKPACK_MAX_COUNT = 100,        -- 背包格子数量
	TIANSHENHUTI_BATCH_ROLL_TIMES = 5,
}

ROLE_PROF = {
	PROF_1 = 1,				--破军
	PROF_2 = 2,				--望舒
	PROF_3 = 3,				--逍遥
	PROF_4 = 4,				--天音
}

--=============================功能开启相关==============================
OPEN_FUN_TRIGGER_TYPE =
{
	ACHIEVE_TASK = 1,		--接受任务后
	SUBMIT_TASK = 2,		--提交任务后
	UPGRADE = 3,			--升级后
	PERSON_CHAPTER = 5,		-- 个人目标章节
	SERVER_DAY = 6,			-- 开服天数配合功能预告
	DEPEND_ON_SERVER_DAY = 7	-- 开服天数
}

OPEN_FLY_DICT_TYPE =
{
	UP = 1,					--上
	BOTTOM = 2,				--下
	OTHER = 3,				--其他
}
--=============================功能开启相关END==============================

--============================功能预告相关=================================
ADVANCE_NOTICE_OPERATE_TYPE = {
  ADVANCE_NOTICE_GET_INFO = 0,					--等级功能预告奖励信息
  ADVANCE_NOTICE_FETCH_REWARD = 1,				--等级功能预告领取奖励
  ADVANCE_NOTICE_DAY_GET_INFO = 2,				--天数功能预告奖励信息
  ADVANCE_NOTICE_DAY_FETCH_REWARD = 3,			--天数功能预告领取奖励
}

ADVANCE_NOTICE_TYPE = {
	ADVANCE_NOTICE_TYPE_LEVEL = 0,				--等级功能预告
	ADVANCE_NOTICE_TYPE_DAY = 1,				--天数功能预告
}
--=============================功能预告相关END==============================

--资质丹类型
ZIZHI_TYPE = {
	MOUNT = 5,					--坐骑
	WING = 6,					--羽翼
	HALO = 7,					--光环
	SHENGONG = 8,				--神弓
	SHENYI = 9,					--神翼
	FIGHTMOUNT = 10,			--战斗坐骑
	SHENBING = 11,				--神兵
	FOOT = 12,					--足迹
	CLOAK = 13,					--披风
	WAIST = 16,					--腰饰
	TOUSHI = 17,				--头饰
	QILINBI = 18,				--麒麟臂
	MASK = 19,					--面饰
	XIANBAO = 20,				--仙宝
	LINGZHU = 21,				--灵珠
	LINGCHONG = 22,				--灵宠
	LINGGONG = 23,				--灵弓
	LINGQI = 24,				--灵骑
	WEIYAN = 25,				--尾焰
}

LIEMING_BAG_NOTIFY_REASON = {
	LIEMING_BAG_NOTIFY_REASON_INVALID = 0,
	LIEMING_BAG_NOTIFY_REASON_BAG_MERGE = 1,
	LIEMING_BAG_NOTIFY_REASON_MAX = 2,
}

-- 每日次数
DAY_COUNT = {
	DAYCOUNT_ID_FB_START = 0,						--  副本开始
	DAYCOUNT_ID_FB_XIANNV = 1,						-- 仙女
	DAYCOUNT_ID_FB_COIN = 2, 						-- 铜币
	DAYCOUNT_ID_FB_WING = 3,						-- 羽翼
	DAYCOUNT_ID_FB_XIULIAN = 4,						-- 修炼
	DAYCOUNT_ID_FB_QIBING = 5,						-- 骑兵

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
	DAYCOUNT_ID_JINGLING_SKILL_COUNT = 107,								-- 精灵技能免费刷新次数
	DAYCOUNT_ID_BUY_MIKU_WERARY = 108,
	DAYCOUNT_ID_MONEY_TREE_COUNT = 109,									-- 摇钱树转转转乐免费抽将次数
	DAYCOUNT_ID_JING_LING_HOME_ROB_COUNT = 110, 						-- 精灵家园掠夺次数								-- 夺宝购买次数
	DAYCOUNT_ID_JING_LING_EXPLORE = 111, 								-- 精灵探险次数
	DAYCOUNT_ID_JING_LING_EXPLORE_RESET = 112, 							-- 精灵探险重置次数
	DAYCOUNT_ID_XIANJIE_BOSS = 114, 									-- 仙戒boss参与次数
	DAYCOUNT_ID_TEAM_FB_ASSIST_TIMES = 115,								-- 组队副本协助次数
	DAYCOUNT_ID_EQUIP_TEAM_FB_JOIN_TIMES = 116,							-- 精英须臾幻境
	DAYCOUNT_ID_GUAJI_BOSS_KILL_COUNT = 117,							-- 挂机boss击杀次数
	DAYCOUNT_ID_ENCOUNTER_BOSS_ENTER_COUNT = 118,						-- 奇遇boss获取奖励次数
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

BOSS_STATUS = {
	NOT_EXISTENT = 0,								--不存在
	EXISTENT = 1,									--存在
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

--属性丹类型(已无用)
-- SHUXINGDAN_TYPE = {
-- 	SHUXINGDAN_TYPE_INVALID = 0,
-- 	SHUXINGDAN_TYPE_XIANNV = 1,						--精灵
-- 	SHUXINGDAN_TYPE_MOUNT = 2,						--坐骑
-- 	SHUXINGDAN_TYPE_XIULIAN = 3,					--修炼
-- 	SHUXINGDAN_TYPE_WING = 4,						--羽翼
-- 	SHUXINGDAN_TYPE_CHANGJIU = 5,					--成就
-- 	SHUXINGDAN_TYPE_SHENGWANG = 6,					--声望

-- 	SHUXINGDAN_TYPE_MAX = 6,
-- }

-- 衣橱操作请求
DRESSING_ROOM_OPEAR_TYPE = {
	DRESSING_ROOM_OPEAR_TYPE_INFO = 0,						-- 请求信息
}

-- 衣橱套装部位类型
SPECIAL_IMG_TYPE = {
	SPECIAL_IMG_TYPE_CLOAK = 0,							-- 披风
	SPECIAL_IMG_TYPE_FIGHT_MOUNT = 1,					-- 战斗坐骑
	SPECIAL_IMG_TYPE_FOOTPRINT = 2,						-- 足迹
	SPECIAL_IMG_TYPE_HALO = 3,							-- 光环
	SPECIAL_IMG_TYPE_LINGZHU = 4,						-- 灵珠
	SPECIAL_IMG_TYPE_MASK = 5,							-- 面饰
	SPECIAL_IMG_TYPE_MOUNT = 6,							-- 坐骑
	SPECIAL_IMG_TYPE_QILINBI = 7,						-- 麒麟臂
	SPECIAL_IMG_TYPE_SHENGONG = 8,						-- 神弓
	SPECIAL_IMG_TYPE_SHENYI = 9,						-- 神翼
	SPECIAL_IMG_TYPE_TOUSHI = 10,						-- 头饰
	SPECIAL_IMG_TYPE_WING = 11,							-- 羽翼
	SPECIAL_IMG_TYPE_XIANBAO = 12,						-- 仙宝
	SPECIAL_IMG_TYPE_YAOSHI = 13,						-- 腰饰
	SPECIAL_IMG_TYPE_JINGLING = 14,						-- 精灵
	SPECIAL_IMG_TYPE_XIANNV = 15,						-- 仙女
	SPECIAL_IMG_TYPE_SHIZHUANG_PART_0 = 16,				-- 时装-部位(武器)
	SPECIAL_IMG_TYPE_SHIZHUANG_PART_1 = 17,				-- 时装-部位(衣服)
	SPECIAL_IMG_TYPE_MULIT_MOUNT = 18,					-- 双骑
	SPECIAL_IMG_TYPE_LINGGONG = 19,						-- 灵弓
	SPECIAL_IMG_TYPE_LINGQI = 20,						-- 灵骑
	SPECIAL_IMG_TYPE_LINGCHONG = 21,					-- 灵宠
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
	LITTEL_PET_BUY_SPECIAL_PET = 20,						-- 购买特殊宠物
	LITTEL_PET_RECEIVED_PET = 21,            				-- 领取特殊宠物
	LITTLE_PET_BUY_OR_RECEIVED_LITTLE_TARGET = 22,			-- 购买或领取小目标奖励
}

--小宠物相关操作类型
LITTLE_PET_NOTIFY_INFO_TYPE ={
	LITTLE_PET_NOTIFY_INFO_SCORE = 0,											--param1 积分信息
	LITTLE_PET_NOTIFY_INFO_FREE_CHOU_TIMESTAMP = 1,								--param1 免费抽奖时间戳
	LITTLE_PET_NOTIFY_INFO_INTERACT_TIMES = 2,									--param1 玩家互动次数
	LITTLE_PET_NOTIFY_INFO_FEED_DEGREE = 3,										--param1 宠物索引, param2 饱食度, param3 自己:伴侣  1:0
	LITTLE_PET_NOTIFY_INFO_PET_INTERACT_TIMES = 4,					 			--param1 宠物互动次数
}

--神印操作类型
CS_SHEN_YIN_TYPE = {
    ALL_INFO                 = 0,	-- 请求所有信息
    CHANGE_BEAD_TYPE         = 1,	-- 请求改变珠子颜色，p1 = x , p2 = y， p3 = 要改的颜色
    CHANGE_BEAD              = 2,	-- 请求改变位置，p1 = x , p2 = y， p3 = 目标格子的x, p4 = 目标格子的y
    IMPRINT_UP_START         = 3,	-- 印位升星 p1 印位类型 p2 是否使用保护符
    IMPRINT_UP_LEVEL         = 4,	-- 印位突破
    IMPRINT_EQUIT            = 5,	-- 装备印记 p1 虚拟背包索引， p2 印位类型
    IMPRINT_TAKE_OFF         = 6,	-- 卸下印记 p1 印位类型
    IMPRINT_ADD_ATTR_COUNT   = 7,	-- 增加属性条数 p1 印位类型
    IMPRINT_FLUSH_ATTR_TYPE  = 8,	-- 印位洗练属性类型 p1 印位类型
    IMPRINT_FLUSH_ATTR_VALUE = 9,	-- 印位洗练属性值 p1 印位类型
    IMPRINT_APLY_FLUSH       = 10,	-- 应用洗练 p1 类型 0 属性类：1 属性值
    IMPRINT_RECYCLE          = 11,	-- 印记回收 p1 虚拟背包索引， p2 数量
    IMPRINT_EXCHANGE         = 12,	-- 印记兑换 p1 商店索引
    SORT                     = 13,	-- 背包整理
    CHOUHUN                  = 14,	-- 抽取 p1 是否使用积分
    SUPER_CHOUHUN            = 15,	-- 逆天改运
    BATCH_HUNSHOU            = 16,	-- 连抽（一键猎魂）
    PUT_BAG                  = 17,	-- 放入背包 p1 格子id
    CONVERT_TO_EXP           = 18,	-- 一键出售
    SINGLE_CONVERT_TO_EXP    = 19,	-- 出售 p1 格子id
    PUT_BAG_ONE_KEY          = 20,	-- 一键放入背包
}

SHUXINGDAN_TYPE = {
	SHUXINGDAN_TYPE_INVALID = 0,
	SHUXINGDAN_TYPE_XIANNV = 1,						--精灵
	SHUXINGDAN_TYPE_MOUNT = 2,						--坐骑
	SHUXINGDAN_TYPE_XIULIAN = 3,					--修炼
	SHUXINGDAN_TYPE_WING = 4,						--羽翼
	SHUXINGDAN_TYPE_CHANGJIU = 5,					--成就
	SHUXINGDAN_TYPE_SHENGWANG = 6,					--声望
	SHUXINGDAN_TYPE_GUANGHUAN = 7,					--光环
	SHUXINGDAN_TYPE_SHENGGONG = 8,					--神弓
	SHUXINGDAN_TYPE_SHENGYI = 9,					--神翼
	SHUXINGDAN_TYPE_FIGHTMOUNT = 10,				--战骑
	SHUXINGDAN_TYPE_SHENGBING = 11,					--神兵
	SHUXINGDAN_TYPE_FOOT = 12,						--足迹
	SHUXINGDAN_TYPE_PIFENG = 13,					--披风
	SHUXINGDAN_TYPE_GUANGWU = 14,                   --光武
	SHUXINGDAN_TYPE_FAZHEN = 15,					--法阵
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

-- 欢乐摇奖
RA_HAPPYERNIE_OPERA_TYPE = {
		RA_HAPPYERNIE_OPERA_TYPE_QUERY_INFO = 0,				-- 请求活动信息
		RA_HAPPYERNIE_OPERA_TYPE_TAO = 1,						-- 淘宝
		RA_HAPPYERNIE_OPERA_TYPE_FETCH_REWARD = 2,				-- 领取个人累抽奖励 param_1 = 领取奖励的索引（0开始）
		RA_HAPPYERNIE_OPERA_TYPE_MAX = 3,
}

-- 欢乐摇奖
RA_HAPPYERNIE_CHOU_TYPE = {
		RA_HAPPYERNIE_CHOU_TYPE_1 = 0,				-- 淘宝一次
		RA_HAPPYERNIE_CHOU_TYPE_10 = 1,				-- 淘宝十次
		RA_HAPPYERNIE_CHOU_TYPE_30 = 2,				-- 淘宝三十次
		RA_HAPPYERNIE_CHOU_TYPE_MAX = 3,
}

-- 中秋欢乐摇奖
RA_ZHONGQIUHAPPYERNIE_CHOU_TYPE = {
		RA_ZHONGQIUHAPPYERNIE_CHOU_TYPE_1 = 0,				-- 淘宝一次
		RA_ZHONGQIUHAPPYERNIE_CHOU_TYPE_10 = 1,				-- 淘宝十次
		RA_ZHONGQIUHAPPYERNIE_CHOU_TYPE_30 = 2,				-- 淘宝三十次
		RA_ZHONGQIUHAPPYERNIE_CHOU_TYPE_MAX = 3,
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

--特殊伙伴类型
SPECIAL_GODDESS_OPER_TYPE = {
	OPERA_TYPE_GET_ACTIVATE_CARD = 0,				-- 领取激活卡
	OPERA_TYPE_UP_LEVEL = 1,						-- 升级
	OPERA_TYPE_BUY_ACTIVATE_CARD = 2,				-- 购买激活卡
	OPERA_TYPE_MAX = 3,
}

--伙伴称号操作类型
SPECIAL_TITLE_OPER_TYPE = {
	OPERA_TYPE_GET_SMALL_TARGET_TITLE_CARD = 0,				-- 领取伙伴小目标称号卡（达到条件）
	OPERA_TYPE_BUY_SMALL_TARGET_TITLE_CARD = 1,				-- 购买伙伴小目标称号卡
	OPERA_TYPE_MAX = 2,
}

-- 活动类型
ACTIVITY_TYPE = {
	INVALID = -1,									-- 无效类型
	ZHUXIE = 1,										-- 攻城准备战
	QUESTION = 2,									-- 答题活动（旧版）
	HUSONG = 3,										-- 护送活动
	MONSTER_INVADE = 4,								-- 怪物入侵
	QUNXIANLUANDOU = 5,								-- 三界战场
	GONGCHENGZHAN = 6,								-- 攻城战
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
	GUILDBATTLE = 21,								-- 公会争霸
	HAPPYTREE_GROW_EXCHANGE = 22,					-- 欢乐果树成长值兑换
	QUESTION_2 = 23,								-- 答题活动(新)
	GUILD_BOSS = 24,								-- 公会Boss
	BIG_RICH = 25,									-- 大富豪
	TOMB_EXPLORE = 26,								-- 皇陵探险
	GUILD_BONFIRE_OPEN = 27,						-- 行会篝火开启
	ACTIVITY_TYPE_XINGZUOYIJI = 28,					-- 星座遗迹
	ACTIVITY_TYPE_TRIPLE_GUAJI = 29,				-- 三倍挂机
	GONGCHENG_WORSHIP = 30,							-- 膜拜城主
	JINGHUA_HUSONG = 31, 							-- 精华护送
	ACTIVITY_TYPE_WEDDING = 32,						-- 结婚婚宴
	GUILD_MONEYTREE = 33,							-- 仙盟摇钱树
	WEEKBOSS = 34,									-- 周末boss
	Triple_LiuJie = 35,								-- 三倍六界
	KF_TUANZHAN = 36,								-- 天庭之战

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

	--充值活动类型
	OPEN_SERVER = 1025,								-- 开服活动
	COMBINE_SERVER = 1028,							-- 合服活动
	CLOSE_BETA = 1026,								-- 封测活动
	BANBEN_ACTIVITY = 1027,							-- 版本活动
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

	--循环进阶活动
	RAND_ACTIVITY_TYPE_MOUNT_UPGRADE  = 2062,		-- 坐骑进阶
	RAND_ACTIVITY_TYPE_WING_UPGRADE = 2065,			--羽翼进化
	RAND_ACTIVITY_TYPE_HALO_UPGRADE_NEW = 2191,		-- 光环进阶(与2062同一类)
	RAND_ACTIVITY_TYPE_FOOTPRINT_UPGRADE_NEW = 2192,--足迹进阶
	RAND_ACTIVITY_TYPE_FIGHTMOUNT_UPGRADE_NEW = 2193,--战斗坐骑进阶
	RAND_ACTIVITY_TYPE_SHENGONG_UPGRADE_NEW = 2194,	--光环进阶
	RAND_ACTIVITY_TYPE_SHENYI_UPGRADE_NEW = 2195,	-- 法阵进阶
	RAND_ACTIVITY_TYPE_YAOSHI_UPGRADE = 2202,       --腰饰进阶
  	RAND_ACTIVITY_TYPE_TOUSHI_UPGRADE = 2203,       --头饰进阶
  	RAND_ACTIVITY_TYPE_QILINBI_UPGRADE = 2204,      --麒麟臂进阶
  	RAND_ACTIVITY_TYPE_MASK_UPGRADE = 2205,			--面具进阶
	RAND_ACTIVITY_TYPE_XIANBAO_UPGRADE = 2206,		--仙宝进阶
	RAND_ACTIVITY_TYPE_LINGZHU_UPGRADE = 2207,		--灵珠进阶
	RAND_ACTIVITY_TYPE_LINGCHONG_UPGRADE  = 2222,	--灵宠进阶
	RAND_ACTIVITY_TYPE_LINGGONG_UPGRADE  = 2223,	--灵弓进阶
	RAND_ACTIVITY_TYPE_LINGQI_UPGRADE  = 2224,		--灵骑进阶
	RAND_ACTIVITY_TYPE_WEIYAN_UPGRADE  = 2236,		--尾焰进阶
	----
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
	RAND_HAPPY_RECHARGE = 2096,						-- 充值乐翻天

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
	RAND_DAY_DANBI_CHONGZHI = 2085, 				-- 单笔充值
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
	-- RAND_NIUEGG = 2096,								--充值扭蛋
	RAND_ACTIVITY_TREASURE_LOFT = 2100, 			-- 珍宝阁
	RAND_ACTIVITY_MIJINGXUNBAO = 2101,              -- 秘境淘宝
	RAND_ACTIVITY_TYPE_SINGLE_CHARGE_2 = 2102, 		-- 极速冲战
	RAND_LOTTERY_TREE = 2103,						-- 摇钱树
	RAND_DAILY_LOVE = 2104,							-- 每日一爱活动
	RAND_ACTIVITY_FANFANZHUAN = 2105,				-- 翻翻转
	RAND_ACTIVITY_SANJIANTAO = 2106, 				-- 三件套
	RAND_ACTIVITY_BIANSHENBANG = 2108,				-- 变身榜
	RAND_ACTIVITY_BEIBIANSHENBANG = 2107,			-- 被变身榜
	RAND_ACTIVITY_ZONGYE = 2109,					-- 粽叶飘香
	RAND_ACTIVITY_NEW_THREE_SUIT = 2110,			-- 新三件套
	RAND_ACTIVITY_MINE = 2111,						-- 开心矿场
	RAND_ACTIVITY_DINGGUAGUA = 2112,				-- 刮刮乐
	RAND_ACTIVITY_LUCKYDRAW = 2113,				    -- 神隐占卜屋
	-- RAND_ACTIVITY_FANFANZHUAN = 2114,				-- 翻翻转活动
	RAND_ACTIVITY_TYPE_FANFAN = 2114,				-- 寻字壕礼
	RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI = 2115,	-- 连充特惠
	RAND_ACTIVITY_TYPE_CONTINUE_CONSUME = 2116,		-- 连续消费
	RAND_ACTIVITY_QIXI = 2118,						-- 七夕情缘
	RAND_ACTIVITY_TYPE_REPEAT_RECHARGE = 2119,		 -- 循环充值
	RAND_ACTIVITY_SUPER_LUCKY_STAR = 2120,			-- 至尊幸运星
	RAND_ACTIVITY_LINGXUBAOZANG= 2121,				-- 灵虚宝藏
	RAND_ACTIVITY_BLESS_WATER = 2122,				-- 天泉祈福
	RAND_ACTIVITY_NATIONALDAY = 2123,				-- 国庆活动
	RAND_ACTIVITY_TREASURE_BUSINESSMAN = 2124,		-- 秘宝商人
	RAND_ACTIVITY_TYPE_DAY_DAY_UP = 2125,			-- 步步高升
	RAND_ACTIVITY_TYPE_BLACKMARKET_AUCTION = 2126,	-- 黑市拍卖
	RAND_ACTIVITY_TYPE_TREASURE_MALL = 2127, 		-- 珍宝商城
	RAND_ACTIVITY_TYPE_CHONGZHI_CRAZY_REBATE = 2209,	-- 狂返元宝
	RAND_CORNUCOPIA = 2167,							-- 聚宝盆
	RAND_ACTIVITY_TYPE_GOLDEN_PIG =	2173,			-- 金猪召唤(龙神夺宝)
	RAND_ACTIVITY_TYPE_ITEM_COLLECTION = 2168,		-- 集字活动   （统一的那个活动协议）
	RAND_ACTIVITY_TYPE_ITEM_COLLECTION_2 = 2216,    -- 匠心月饼
	RAND_ACTIVITY_TYPE_VERSIONS_GRAND_TOTAL_CHARGE = 2218,	-- 版本累计充值
	RAND_ACTIVITY_TYPE_TOTAL_CHARGE_FIVE = 2220,			-- 吉祥三宝
	RAND_ACTIVITY_TYPE_EXPENSE_NICE_GIFT = 2217,				-- 消费好礼

	RAND_ACTIVITY_TYPE_VERSIONS_GRAND_TOTAL_CHARGE = 2218,	-- 版本累计充值
	RAND_ACTIVITY_TYPE_TOTAL_CHARGE_FIVE = 2220,			-- 吉祥三宝
	MARRY_ME = 2169,		-- 我们结婚吧
	RAND_ACTIVITY_TYPE_HONG_BAO = 2170,				-- 开服红包(红包好礼)
	RAND_ACTIVITY_TYPE_EXP_REFINE = 2172,			-- 经验炼制
	RAND_ACTIVITY_TYPE_SINGLE_CHONGZHI = 2178,		-- 单返豪礼
	RAND_ACTIVITY_TYPE_LOOP_CHARGE_2 = 2196,		-- 送装备
	RAND_ACTIVITY_TYPE_SHAKE_MONEY = 2197,  		-- 疯狂摇钱树
	RAND_ACTIVITY_TYPE_HUANLE_ZADAN = 2213,         -- 欢乐砸蛋
	RAND_ACTIVITY_TYPE_HAPPY_ERNIE = 2214,			-- 欢乐摇奖

	-- RAND_ACTIVITY_TYPE_TIME_LIMIT_BIG_GIFT = 2199, 		    -- 限时豪礼
	RAND_ACTIVITY_TYPE_CONSUME_GOLD_FANLI = 2208,   --消费返礼
	RAND_ACTIVITY_TYPE_CONSUME_FOR_GIFT = 2211,     --消费有礼
	RAND_ACTIVITY_TYPE_TIME_LIMIT_BIG_GIFT = 2199, 	-- 限时豪礼
	RAND_ACTIVITY_TYPE_BUYONE_GETONE = 2210,        -- 买一送一

	RAND_ACTIVITY_TYPE_UPGRADE_MOUNT_RANK = 2143,			-- 坐骑进阶榜(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_HALO_RANK = 2150,			-- 光环进阶榜(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_WING_RANK = 2145,			-- 羽翼进阶榜(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_SHENGONG_RANK = 2146,		-- 神弓进阶榜(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_SHENYI_RANK = 2147,			-- 神翼进阶榜(开服活动)
	RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN = 2148,				-- 装备强化(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE = 2149,				-- 宝石升级(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_FOOT_RANK = 2144,			-- 足迹进阶榜(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE_RANK = 2151,		-- 宝石等级冲榜(开服活动)


	RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU = 2174,		-- 连充特惠初(开服活动)
	RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO = 2175,		-- 连充特惠高(开服活动)
	RAND_ACTIVITY_TYPE_KAIFU_INVEST = 2176,                 -- 开服投资
	RAND_ACTIVITY_TYPE_XIANYUAN_TREAS = 2179, 				-- 聚划算
	RAND_ACTIVITY_TYPE_SINGLE_CHARGE_2 = 2181,				-- 极速冲战
	RAND_ACTIVITY_TYPE_SINGLE_CHARGE_3 = 2183,				-- 冲战高手
	RAND_ACTIVITY_TYPE_RUSH_BUYING = 2180, 					-- 限时拍卖
	RAND_ACTIVITY_TYPE_RECHARGE_CAPACITY = 2184,			-- 单充送好礼
	RAND_ACTIVITY_TYPE_INCREASE_CAPABILITY = 2182,			-- 冲战达人
	RAND_ACTIVITY_TYPE_MAP_HUNT = 2185,                     -- 地图寻宝
	-- RAND_ACTIVITY_TYPE_LIGHT_TOWER_EXPLORE = 2186,          -- 极品宝塔
	RAND_ACTIVITY_TYPE_MAGIC_SHOP = 2188,                   -- 你充我送(幻装商店)
	RAND_ACTIVITY_TYPE_LIMITTIME_REBATE = 2189,		        -- 限时大回馈
	RAND_ACTIVITY_TYPE_TIME_LIMIT_GIFT = 2190, 		        -- 限时礼包
	RAND_ACTIVITY_TYPE_LOOP_CHARGE = 2191,					-- 循环充值
	RAND_ACTIVITY_TYPE_MIJINGXUNBAO3 = 2212,				-- 秘境寻宝
	RAND_ACTIVITY_TYPE_SINGLE_REBATE = 2198, 				-- 单笔返利
	RAND_ACTIVITY_RMB_BUY_COUNT_SHOP = 2201,				-- 臻品城/神秘商店
    RAND_ACTIVITY_TYPE_VERSIONS_CONTINUE_CHARGE = 2219,      -- 版本连续充值
    RAND_ACTIVITY_TYPE_HUANLE_YAOJIANG2 = 2221,             --中秋祈福
    RAND_ACTIVITY_TYPE_CHONGZHI_RANK = 2237,            	--版本充值排行2
    RAND_ACTIVITY_TYPE_XIAOFEI_RANK = 2238,            		--版本消费排行2

    RAND_ACTIVITY_TYPE_LANDINGF_REWARD = 2239,               --登陆奖励

	ACTIVITY_TYPE_WEEKEND_BOSS = 34,                     	--周末boss

	RAND_ACTIVITY_REST_DOUBLE_CHONGZHI = 2200,				-- 普天同庆

	ACTIVITY_TYPE_EQUIPMENT = 2215, 							-- 节日套装

	--线上活动
	--单笔充值
	RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_0 = 2225,
	RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_1 = 2226,
	RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_2 = 2227,

	--累计充值
	RAND_ACTIVITY_TYPE_OFFLINE_TOTAL_CHARGE_0 = 2228,
	RAND_ACTIVITY_TYPE_OFFLINE_TOTAL_CHARGE_1 = 2229,
	RAND_ACTIVITY_TYPE_OFFLINE_TOTAL_CHARGE_2 = 2230,

	-- 登录奖励
	RAND_ACTIVITY_TYPE_LOGIN_GIFT_0 = 2231,
  	RAND_ACTIVITY_TYPE_LOGIN_GIFT_1 = 2232,
  	RAND_ACTIVITY_TYPE_LOGIN_GIFT_2 = 2233,

  	--国庆种树
  	RAND_ACTIVITY_TYPE_PRINT_TREE = 2234,
  	RAND_ACTIVITY_TYPE_FANGFEI_QIQIU = 2235,
  	RAND_ACTIVITY_TYPE_EXPENSE_NICE_GIFT_2 = 2236,			-- 消费好礼2

	--手动开启的活动功能
	FUNC_TYPE_LONGXING = 100001,							-- 活动卷轴中的功能 龙行天下

	RAND_ACTIVITY_FLAG = 2117,						-- 军歌嘹亮
	KF_XIULUO_TOWER = 3073, 						-- 跨服修罗塔
	KF_ONEVONE = 3074, 								-- 跨服1V1
	KF_PVP = 3075, 									-- 跨服3V3
	KF_TEAMBATTLE = 3076,							-- 跨服天庭战
	KF_FARMHUNTING = 3077,							-- 牧场
	KF_BOSS = 3078,									-- 跨服boss
	KF_FB = 3079,									-- 跨服副本
	KF_HOT_SPRING = 3080,							-- 跨服温泉
	CROSS_SHUIJING = 3081,							-- 跨服水晶(更换为天神塚)
	KF_GUILDBATTLE = 3082,							-- 跨服六界
	KF_TIANJIANG_BOSS = 3083,						-- 跨服天将boss
	KF_SHENWU_BOSS = 3084,							-- 跨服神武boss
	KF_KUAFUCHONGZHI = 4000,						-- 跨服充值排行榜
	KF_COMMON_BOSS = 3085, 							-- 跨服vipboss等
	KF_MINING = 3086,								-- 跨服挖矿
	KF_FISHING = 3087, 								-- 跨服钓鱼
	-- KF_KUAFUCHONGZHI = 4000,						-- 跨服充值排行榜
	KF_ONEYUANSNATCH = 4001,						-- 跨服一元夺宝

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
	RA_KING_DRAW_OPERA_TYPE_FETCH_REWARD = 4,
	RA_KING_DRAW_OPERA_TYPE_MAX = 5,
}

RA_MIJINGXUNBAO3_OPERA_TYPE = {								-- 秘境寻宝
	RA_MIJINGXUNBAO3_OPERA_TYPE_QUERY_INFO = 0,				-- 请求活动信息
	RA_MIJINGXUNBAO3_OPERA_TYPE_TAO = 1,					-- 寻宝
	RA_MIJINGXUNBAO3_OPERA_TYPE_FETCH_REWARD = 2,			-- 领取个人累抽奖励 param_1 = 领取奖励的索引（0开始）
	RA_MIJINGXUNBAO3_OPERA_TYPE_MAX = 3,
}

RA_MIJINGXUNBAO3_CHOU_TYPE = {						-- 秘境寻宝
	RA_MIJINGXUNBAO3_CHOU_TYPE_1 = 0,				-- 寻宝一次
	RA_MIJINGXUNBAO3_CHOU_TYPE_10 = 1,				-- 寻宝十次
	RA_MIJINGXUNBAO3_CHOU_TYPE_30 = 2,				-- 寻宝三十次
	RA_MIJINGXUNBAO3_CHOU_TYPE_MAX = 3,
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

RED_PAPER_TYPE = {					--红包类型
	RED_PAPER_TYPE_INVALID = 0,
	RED_PAPER_TYPE_COMMON = 1, 		--普通
	RED_PAPER_TYPE_RAND = 2,		--拼手气
	RED_PAPER_TYPE_GLOBAL = 3,		--全服
	RED_PAPER_TYPE_GUILD = 4,		--公会
	RED_PAPER_TYPE_COMMAND_SPEAKER = 5,		--口令

	RED_PAPER_TYPE_MAX,
}
CHALLENGE_FB_OPERATE_TYPE = {
	CHALLENGE_FB_OPERATE_TYPE_AUTO_FB = 0,								-- 扫荡
	CHALLENGE_FB_OPERATE_TYPE_RESET_FB = 1,								-- 重置
	CHALLENGE_FB_OPERATE_TYPE_SEND_INFO_REQ = 2,						-- 请求发送协议
	CHALLENGE_FB_OPERATE_TYPE_BUY_TIMES = 3, 						-- 重置并扫荡
}

TUITU_FB_OPERA_REQ_TYPE = {
	TUITU_FB_OPERA_REQ_TYPE_ALL_INFO = 0,					-- 请求信息
	TUITU_FB_OPERA_REQ_TYPE_BUY_TIMES = 1,					-- 购买进入副本次数 param_1 购买副本类型 param_2, 购买次数
	TUITU_FB_OPERA_REQ_TYPE_FETCH_STAR_REWARD = 2,			-- 拿取星级奖励 param_1:章节  param_2:配置表seq
	TUITU_FB_OPERA_REQ_TYPE_SAODANG = 3 ,					-- 扫荡 param_1:副本类型 param_2:章节 param_3:关卡
	TUITU_FB_OPERA_REQ_TYPE_GETNAME = 4,					-- 请求第一名的信息
	TUITU_FB_OPERA_REQ_TYPE_MAX = 5,
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
	CHOU_THIRTY = 30,
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
	PUT_REASON_LUCKYROLL = 39,						-- 幸运转盘

	PUT_REASON_LUCKYROLL_EXTRAL = 40,			 	-- 幸运转盘额外奖励
	PUT_REASON_LUCKYROLL_CS = 79,			 		-- 合服活动幸运转盘
	PUT_REASON_ZHUXIE_GATHER = 96,					-- 诛邪采集获得
	PUT_REASON_EXP_BOTTLE = 97,						-- 凝聚经验
	PUT_REASON_GCZ_DAILY_REWARD = 98,				-- 攻城战每日奖励
	PUT_REASON_LIFE_SKILL_MAKE= 99,					-- 生活技能制造
	PUT_REASON_PAOHUAN_ROLL = 100,					-- 跑环任务翻牌
	PUT_REASON_GUILD_STORE = 101,					-- 从公会仓库取出
	PUT_REASON_RA_LEVEL_LOTTERY = 105,				-- 金银塔活动奖励
	PUT_REASON_ONLINE_REWARD = 139,					-- 在线奖励
	PUT_REASON_MOVE_CHESS = 150,					-- 走棋子奖励
	PUT_REASON_LITTLE_PET_CHOUJIANG_ONE = 162,		--小宠物抽奖1连
	PUT_REASON_LITTLE_PET_CHOUJIANG_TEN = 163,		--小宠物抽奖10连
	PUT_REASON_GUILD_BOX_REWARD = 186,				-- 开启公会宝箱奖励
	PUT_REASON_SZLQ_OPEN_BOX_REWARD = 191,			-- 魂器打开宝藏
	PUT_REASON_ZODIAC_GGL_REWARD = 193,				-- 星座摇奖机
	PUT_REASON_WABAO = 32,							-- 挖宝
	PUT_REASON_ZHIXIAN_TASK_REWARD = 198,			-- 支线任务
	PUT_REASON_GOLDEN_PIG_RANDOM_REWARD = 216,		-- 金猪召唤随机奖励
	PUT_REASON_RA_MONEY_TREE_REWARD= 111,			-- 转转乐随机奖励
	PUT_REASON_YUANBAO_ZHUANPAN = 205,				-- 转盘奖励
	PUT_REASON_MAP_HUNT_BAST_REWARD = 225,			-- 地图寻宝最终奖励
	PUT_REASON_MAP_HUNT_BASE_REWARD = 226,			-- 地图寻宝基础奖励
	PUT_REASON_SHENSHOU_HUANLING_REWARD = 234,  	-- 神兽唤灵抽奖
	PUT_REASON_COLOR_EQUIPMENT_COMPOSE = 246,  		-- 彩装合成
	PUT_REASON_RED_COLOR_EQUIPMENT_COMPOSE = 301,	-- 红装合成
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
	WO_WAKUANG = 56,                                -- 开心矿场
	DIVINATION = 57,                                -- 天命卜卦
	WO_FANFANZHUAN = 58,                            -- 翻翻转
	WO_FARM_HUNT = 59,                              -- 牧场抽奖
	WO_MULTIMOUNT = 60,								-- 双人坐骑进阶
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
	LEIJI_RECHARGE = 76,							-- 累计充值
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
	WO_SELF_BUY = 88,                  				-- 个人抢购 我要特价
	WO_SHENGE_INLAY = 89,                  			-- 神格镶嵌 我要升级
	WO_SPIRIT_UPGRADE = 90,							-- 精灵悟性 我要提升
	SHENMI_SHOP = 91,								--神秘商店
	ADD_FRIEND = 92,								-- 加好友
	RED_EQUIP_JINJIE = 93,							-- 我要进阶 锻造红装进阶
	ARENA_SHENGLI = 94,								-- 竞技场胜利
	ZHANGKONG_SHENGJI = 95,							-- 点击打开掌控
	JUBAOPEN = 96,									-- 聚宝盆
	FORTE_ENTERNITY = 97,							-- 永恒装备
	GOLDEN_PIG_ACTIVITY = 100,						-- 金猪召唤（龙神夺宝），立即前往金猪召唤boss处
	GODDESS_SHENGWU = 98,			 				-- 女神圣物，我要升级
	GODDESS_GONGMING = 99,							-- 女神法则，我要升级

	KAIFU_INVEST = 101,                             -- 开服投资，我要投资
	DUIHUAN_SHOP = 102,								-- 兑换商店
	FOOTPRINT_UPGRADE = 103,						-- 足迹进阶
	MAP_FIND = 104,                                 -- 地图寻宝
	XianShi_MiaoSha = 105,							-- 限时秒杀
	PIFENG_UPLEVEL = 106,							-- 披风提升
	SPIRIT_MEET = 107,							    -- 精灵奇遇
	MO_SHEN = 108,							   		-- 魔神
	IMG_FULING = 111,								-- 形象赋灵
	RUNE_ZHULING = 112,								-- 符文注灵
	SHENGE_GODBODY = 110,							-- 我要修炼
	HUNQI_XILIAN = 113,								-- 魂器洗练
	TEAM_SPECIAL_FB = 114,							-- 组队副本(须臾幻境)
	SPRITE_GROW_UP = 115,							-- 精灵成长进阶
	SPRITE_POWER_UP = 116,							-- 精灵悟性进阶
	SHENGE_ADVANCE = 117,							-- 神格淬炼
	LIANHUN = 118,									-- 炼魂(附魔)
	KF_MINING = 119,								-- 跨服挖矿
	YAOSHI = 120,									-- 腰饰
	TOUSHI = 121,									-- 头饰
	QILINBI = 122,									-- 麒麟臂
	MASK = 123,										-- 面饰
	LINGZHU = 124,									-- 灵珠
	XIANBAO = 125,									-- 仙宝
	TSHT_COMBINE = 126,								-- 天神护体-合成
	SECRET_TREASURE_HUNTING = 127,					-- 秘境寻宝
	HAPPY_HIT_EGG = 128,							-- 欢乐砸蛋
	HAPPY_ERNIE = 129,								-- 欢乐摇奖
	LING_CHONG = 130,								-- 灵宠
	LING_GONG = 131,								-- 灵弓
	LING_QI = 132,									-- 灵骑
    ZHONGQIU_QIFU = 133,                            -- 中秋祈福
    VES_LEICHONG = 134,								-- 累计充值
    RED_EQUIP_EXCHANGE = 135,						-- 红装兑换
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
	SPECIAL_APPEARANCE_TYP_BIANSHEN = 2,						-- 被施加变身effect
	SPECIAL_APPERANCE_TYPE_HUASHENG = 3,						-- 化神外观
	SPECIAL_APPERANCE_TYPE_TERRITORYWAR = 4,					-- 领土战外观
	SPECIAL_APPERANCE_TYPE_CROSS_HOTSPRING = 5,					-- 跨服温泉外观
	SPECIAL_APPERANCE_TYPE_CROSS_MINING = 6,					-- 跨服挖矿外观
	SPECIAL_APPEARANCE_TYPE_CROSS_FISHING = 105,					-- 跨服钓鱼外观
	SPECIAL_APPERANCE_TYPE_GREATE_SOLDIER = 10,					-- 天将变身

	SPECIAL_APPEARANCE_TYPE_SHNEQI = 9, 						-- 神器变身外观

	SPECIAL_APPEARANCE_TYPE_ZHUQUE = 101,						--朱雀
	SPECIAL_APPEARANCE_TYPE_XUANWU = 102,
	SPECIAL_APPEARANCE_TYPE_QINGLONG = 103,
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
	JINGLING_OPER_ONEKEY_RECYCL_BAG = 14,	-- 一键回收背包精灵
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
	JINGLING_OPER_CZ_UPGRADE = 26,			-- 成长升阶
	JINGLING_OPER_WX_UPGRADE = 27,			-- 悟性升级
	JINGLING_OPER_SPECIAL_JINGLING_INFO = 28, --特殊精灵信息-新加的
	JINGLING_OPER_SPECIAL_JINGLING_BUY = 29,  --购买特殊精灵
	JINGLING_OPER_SPECIAL_JINGLING_FETCH = 30,-- 领取特殊精灵 p1 = 精灵索引

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
 --}

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
	REALIVE_TYPE_BACK_HOME = 0,						-- 回城复活
	REALIVE_TYPE_HERE_ICON = 1,						-- 使用铜钱原地复活
	REALIVE_TYPE_HERE_GOLD = 2,						-- 使用钻石原地复活
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

COUPLE_RANK_TYPE =
{
	COUPLE_RANK_TYPE_MIN = 0,
	COUPLE_RANK_TYPE_QINGYUAN_CAP = 0,					-- 夫妻情缘战力榜
	COUPLE_RANK_TYPE_BABY_CAP = 1,						-- 夫妻宝宝战力榜
	COUPLE_RANL_TYPE_LITTLE_PET = 2,					-- 夫妻宠物战力榜

	COUPLE_RANK_TYPE_MAX = 2
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

--跨服帮派战请求
CROSS_GUILDBATTLE_OPERATE = {
	CROSS_GUILDBATTLE_OPERATE_REQ_INFO = 0,
	CROSS_GUILDBATTLE_OPERATE_FETCH_REWARD = 1,
	CROSS_GUILDBATTLE_OPERATE_REQ_TASK_INFO = 2,
	CROSS_GUILDBATTLE_OPERATE_BOSS_INFO = 3,
	CROSS_GUILDBATTLE_OPERATE_SCENE_RANK_INFO = 4,
	CROSS_GUILDBATTLE_OPERATE_GOTO_SCENE = 5,		--飞到对应场景的随机复活点
}

CROSS_GUILDBATTLE = {
	CROSS_GUILDBATTLE_MAX_FLAG_IN_SCENE = 3,		-- 最大旗子数在场景中
	CROSS_GUILDBATTLE_MAX_SCENE_NUM = 6,			-- 帮派场景个数
	CROSS_GUILDBATTLE_MAX_GUILD_RANK_NUM = 5,		-- 跨服帮派战前5
	CROSS_GUILDBATTLE_MAX_TASK_NUM = 6,
}

-- 战斗力类型
-- ranktag
CAPABILITY_TYPE = {
	CAPABILITY_TYPE_INVALID = 0,
	CAPABILITY_TYPE_BASE = 1,				-- 基础属性战斗力
	CAPABILITY_TYPE_MENTALITY = 2,			-- 元神属性战斗力
	CAPABILITY_TYPE_EQUIPMENT = 3,			-- 装备属性战斗力
	CAPABILITY_TYPE_WING = 4,				-- 羽翼属性战斗力
	CAPABILITY_TYPE_MOUNT = 5,				-- 坐骑属性战斗力
	CAPABILITY_TYPE_TITLE = 6,				-- 称号属性战斗力
	CAPABILITY_TYPE_SKILL = 7,				-- 技能属性战斗力
	CAPABILITY_TYPE_XIANJIAN = 8,			-- 仙剑属性战斗力
	CAPABILITY_TYPE_XIANSHU = 9,			-- 仙盟仙术属性战斗力
	CAPABILITY_TYPE_GEM = 10,				-- 宝石战斗力
	CAPABILITY_TYPE_XIANNV = 11,				-- 仙女属性战斗力
	CAPABILITY_TYPE_FOOTPRINT = 12,			-- 足迹属性战斗力
	CAPABILITY_TYPE_QINGYUAN = 13,			-- 情缘属性战斗力
	CAPABILITY_TYPE_ZHANSHENDIAN = 14,		-- 战神殿属性战斗力
	CAPABILITY_TYPE_SHIZHUANG = 15,			-- 时装属性战斗力
	CAPABILITY_TYPE_ATTR_PER = 16,			-- 基础属性百分比加的战斗力
	CAPABILITY_TYPE_LIEMING = 17,			-- 猎命装备战力
	CAPABILITY_TYPE_JINGLING = 18,			-- 精灵战力
	CAPABILITY_TYPE_VIPBUFF = 19,			-- vipbuff战力
	CAPABILITY_TYPE_SHENGWANG = 20,			-- 声望
	CAPABILITY_TYPE_CHENGJIU = 21,			-- 成就
	CAPABILITY_TYPE_WASH = 22,				-- 洗练
	CAPABILITY_TYPE_SHENZHUANG = 23,			-- 神装
	CAPABILITY_TYPE_TUHAOJIN = 24,			-- 土豪金战力
	CAPABILITY_TYPE_BIG_CHATFACE = 25,		-- 大表情战力
	CAPABILITY_TYPE_SHENZHOU_WEAPON = 26,	-- 神州六器战斗力
	CAPABILITY_TYPE_BABY = 27,				-- 宝宝属性战斗力
	CAPABILITY_TYPE_PET = 28,				-- 宠物战力
	CAPABILITY_TYPE_ACTIVITY = 29,			-- 活动相关提升的战力
	CAPABILITY_TYPE_HUASHEN = 30,			-- 化神战力
	CAPABILITY_TYPE_MULTIMOUNT = 31, 			-- 双人坐骑战力
	CAPABILITY_TYPE_PERSONALIZE_WINDOW = 32,	--个性聊天框战力
	CAPABILITY_TYPE_MAGIC_CARD = 33,			-- 魔卡战斗力
	CAPABILITY_TYPE_MITAMA = 34,				-- 御魂战力
	CAPABILITY_TYPE_XUNZHANG = 35,			-- 勋章战力
	CAPABILITY_TYPE_ZHIBAO = 36,				-- 至宝战力
	CAPABILITY_TYPE_HALO = 37,				-- 光环属性战斗力
	CAPABILITY_TYPE_SHENGONG = 38,			-- 神弓属性战斗力
	CAPABILITY_TYPE_SHENYI = 39,				-- 神翼属性战斗力
	CAPABILITY_TYPE_GUILD = 40,				-- 仙盟战斗力
	CAPABILITY_TYPE_CHINESE_ZODIAC = 41,		-- 星座系统战斗力
	CAPABILITY_TYPE_XIANNV_SHOUHU = 42,		-- 仙女守护战斗力
	CAPABILITY_TYPE_JINGLING_GUANGHUAN = 43,	-- 精灵光环战斗力
	CAPABILITY_TYPE_JINGLING_FAZHEN = 44,	-- 精灵法阵战斗力
	CAPABILITY_TYPE_CARDZU = 45,				-- 卡牌组合战力
	CAPABILITY_TYPE_ZHUANSHENGEQUIP = 46,    -- 转生属性战斗力
	CAPABILITY_TYPE_LITTLE_PET = 47,			-- 小宠物战力
	CAPABILITY_TYPE_ZHUANSHEN_RAND_ATTR = 48,-- 转生装备随机属性
	CAPABILITY_TYPE_FIGHT_MOUNT = 49,		-- 战斗坐骑战斗力
	CAPABILITY_TYPE_MOJIE = 50,				-- 魔戒
	CAPABILITY_TYPE_LOVE_TREE = 51,			-- 相思树
	CAPABILITY_TYPE_EQUIPSUIT = 52,			-- 锻造套装战斗力
	CAPABILITY_TYPE_RUNE_SYSTEM = 53,		-- 符文系统
	CAPABILITY_TYPE_SHENGE_SYSTEM = 54,		-- 神格系统
	CAPABILITY_TYPE_SHENBING = 55,			-- 神兵系统

    CAPABILITY_TYPE_ROLE_GOAL  =  56,     	 -- 角色目标
    CAPABILITY_TYPE_CLOAK = 57,        			-- 披风属性战斗力
    CAPABILITY_TYPE_SHENSHOU = 58,      			-- 神兽战斗力
    CAPABILITY_TYPE_IMG_FULING = 59,      			-- 形象赋灵
    CAPABILITY_TYPE_CSA_EQUIP = 60,      			-- 合服装备
    CAPABILITY_TYPE_MOLONG = 61,        			-- 魔龙头衔
    CAPABILITY_TYPE_CARD = 62,        				-- 卡牌
    CAPABILITY_TYPE_JINGJIE = 63,     				-- 境界战力
    CAPABILITY_TYPE_CF_BEST_RANK_BREAK = 64,  		-- 竞技场历史最高排名突破
    CAPABILITY_TYPE_GREATE_SOLDIER = 65,    		-- 名将
    CAPABILITY_TYPE_TALENT = 66,        			-- 天赋进阶战力
    CAPABILITY_TYPE_SHENQI = 67,        			-- 神器系统
    CAPABILITY_TYPE_BOSS_HANDBOOK = 68,    		-- BOSS图鉴
    CAPABILITY_TYPE_YAOSHI = 69,        			-- 腰饰战力
    CAPABILITY_TYPE_TOUSHI = 70,       			-- 头饰战力
    CAPABILITY_TYPE_QILINBI = 71,      			-- 麒麟臂战力
    CAPABILITY_TYPE_MASK = 72,					-- 面具战力
    CAPABILITY_TYPE_XIANBAO = 73,				-- 仙宝战力
    CAPABILITY_TYPE_LINGZHU = 74,				-- 灵珠战力
    CAPABILITY_TYPE_TIANSHENHUTI= 75,			-- 周末装备战力
    CAPABILITY_TYPE_LINGCHONG = 76,				-- 灵宠战力
    CAPABILITY_TYPE_LINGGONG = 77,     			-- 灵弓战力
    CAPABILITY_TYPE_LINGQI = 78,				-- 灵骑战力
    CAPABILITY_TYPE_TOTAL = 79,        			-- 总战斗力，(战斗力计算方式改为所有属性算好后再套公式计算，取消各个模块分别计算再加起来的方式）
    CAPABILITY_TYPE_MAX = 80,
}

-- 仙盟仓库操作
GUILD_STORGE_OPERATE = {
	GUILD_STORGE_OPERATE_PUTON_ITEM = 1, -- 放进仓库
	GUILD_STORGE_OPERATE_TAKE_ITEM = 2,  -- 取出仓库
	GUILD_STORGE_OPERATE_REQ_INFO = 3,	 -- 请求仓库信息
}

-- 红包
GUILD_RED_POCKET_OPERATE_TYPE = {
	GUILD_RED_POCKET_OPERATE_INFO_LIST = 0,                 -- 仙盟红包 请求红包列表信息
	GUILD_RED_POCKET_OPERATE_DISTRIBUTE	= 1,				-- 仙盟红包 请求分发红包
	GUILD_RED_POCKET_OPERATE_GET_POCKET	= 2,				-- 仙盟红包 请求获取红包
	GUILD_RED_POCKET_OPERATE_DISTRIBUTE_INFO = 3,			-- 仙盟红包 请求分发详情
}

-- 红包领取状态
GUILD_RED_POCKET_STATUS = {
	UN_DISTRIBUTED = 1,										-- 未发放
	DISTRIBUTED = 2,										-- 已发放
	DISTRIBUTE_OUT = 3,                                     -- 已抢的红包
}
NOTICE_REASON = {
	HAS_CAN_CREATE_RED_PAPER = 0,							-- 有可发
	HAS_CAN_FETCH_RED_PAPER = 1,							-- 有可领
}

-- 公会骰子
GUILD_PAWN = {
	MAX_MEMBER_COUNT = 60,									-- 公会人数上限

}

-- 客户端操作请求类型
COMMON_OPERATE_TYPE = {
	COT_JINGHUA_HUSONG_COMMIT = 1,				-- 精华护送提交
	COT_JINGHUA_HUSONG_COMMIT_OPE = 2,			-- 精华护送提交次数请求
	COT_KEY_ADD_FRIEND = 3,						-- 一键踩好友空间
	COT_JINGHUA_HUSONG_BUY_GATHER_TIMES = 4,	-- 精华护送购买采集次数
	COT_REQ_RED_EQUIP_COLLECT_FETCH_TITEL_REWARD = 7,	-- 红装收集领取称号奖励, param1是奖励seq
	COT_ACT_BUY_EQUIPMENT_GIFT = 1000,			-- 活动 购买装备礼包
	COT_REQ_RED_EQUIP_COLLECT_TAKEON = 5,		-- 红装收集，请求穿上，param1是红装seq，param2是红装槽index， param3是背包index
	COT_REQ_RED_EQUIP_COLLECT_FETCH_ATC_REWARD = 6, -- 红装收集，领取开服活动奖励，param1是奖励seq
	COT_REQ_ORANGE_EQUIP_COLLECT_TAKEON = 8,	-- 红装收集，请求穿上，param1是红装seq，param2是红装槽index， param3是背包index
}

-- 服务器通知客户端信息类型
SC_COMMON_INFO_TYPE = {
	SCIT_JINGHUA_HUSONG_INFO = 1,				-- 同步精华护送信息
	SCIT_RAND_ACT_ZHUANFU_INFO = 2,	            -- 随机活动专服信息
	SCIT_TODAY_FREE_RELIVE_NUM = 3,			    -- 复活信息
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
	ROLE_SHADOW_TYPE_CLONE_ROLE = 6,			-- 玩家分身
}

RA_CHONGZHI_NIU_EGG_OPERA_TYPE = {
	RA_CHONGZHI_NIU_EGG_OPERA_TYPE_QUERY_INFO = 0,				-- 请求活动信息
	RA_CHONGZHI_NIU_EGG_OPERA_TYPE_CHOU = 1,					-- 抽奖
	RA_CHONGZHI_NIU_EGG_OPERA_TYPE_FETCH_REWARD = 2,			-- 领取全服奖励

	RA_CHONGZHI_NIU_EGG_OPERA_TYPE_MAX = 3,
}


CHONGZHI_REWARD_TYPE = {
		CHONGZHI_REWARD_TYPE_SPECIAL_FIRST = 0,										-- 特殊首充
		CHONGZHI_REWARD_TYPE_DAILY_FIRST = 1,										-- 日常首充
		CHONGZHI_REWARD_TYPE_DAILY_TOTAL = 2,										-- 日常累充
		CHONGZHI_REWARD_TYPE_DIFF_WEEKDAY_TOTAL = 3,	--新增						-- 每日累冲(星期几区分奖励配置)

		CHONGZHI_REWARD_TYPE_MAX,
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
	BABY_REQ_TYPE_SUP_BABY_QIFU = 9,					-- 超级宝宝购买
	BABY_REQ_TYPE_SUP_BABY_REMOVE_BABY = 10,			-- 超级宝宝遗弃
	BABY_REQ_TYPE_SUP_BABY_UPGRADE = 11,				-- 超级宝宝升阶请求
	BABY_REQ_TYPE_SUP_BABY_AWARD = 12,					-- 超级宝宝领奖
	BABY_REQ_TYPE_SUP_BABY_VIEW = 13,					-- 超级宝宝出战 1 出战 0 收回
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
	RA_GUAGUA_OPERA_TYPE_PLAY_TIMES = 1,						-- 刮奖多次
    RA_GUAGUA_OPREA_TYPE_FETCH_REWARD = 2,
	RA_GUAGUA_OPERA_TYPE_MAX = 3,
}

--中秋连续充值
RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE = {
    RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE_QUERY_INFO = 0,    -- 请求活动信息
    RA_VERSION_CONTINUE_CHONGZHI_OPEAR_TYPE_FETCH_REWARD = 1,    -- 获取奖励

    RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE_MAX = 2
}

--
RA_HUANLE_YAOJIANG_2_OPERA_TYPE = {
    RA_HUANLEYAOJIANG_OPERA_2_TYPE_QUERY_INFO = 0,      -- 请求活动信息
    RA_HUANLEYAOJIANG_OPERA_2_TYPE_TAO = 1,            -- 淘宝
    RA_HUANLEYAOJIANG_OPERA_2_TYPE_FETCH_REWARD = 2,       -- 领取个人累抽奖励 param_1 = 领取奖励的索引（0开始）

    RA_HUANLEYAOJIANG_OPERA_2_TYPE_MAX = 3,
  }

RA_GUAGUA_PLAY_MULTI_TYPES =               --刮奖多次的类型
{
  RA_GUAGUA_PLAY_ONE_TIME = 0,                    -- 刮奖1次
  RA_GUAGUA_PLAY_TEN_TIMES = 1,                    -- 刮奖10次
  RA_GUAGUA_PLAY_THIRTY_TIMES = 2,                    -- 刮奖30次
}

--神秘占卜屋
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
	RA_FANFAN_OPERA_TYPE_LEICHOU_EXCHANGE = 5,  --类抽兑换

	RA_FANFAN_OPERA_TYPE_MAX = 6,
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

-- 公会排行
GUILD_RANK_TYPE = {
	GUILD_RANK_TYPE_LEVEL = 0,									-- 军团等级榜
	GUILD_RANK_TYPE_XIANMENGZHAN,								-- 仙盟战排行
	GUILD_RANK_TYPE_KILL_WORLD_BOSS,							-- 击杀世界boss数量
	GUILD_RANK_TYPE_XIANMENG_BIPIN_KILL_WORLD_BOSS,				-- 仙盟比拼期间击杀世界boss数量
	GUILD_RANK_TYPE_DAY_INCREASE_CAPABILITY,					-- 仙盟每日增加战力
	GUILD_RANK_TYPE_CAPABILITY,									-- 仙盟战力榜
	GUILD_RANK_TYPE_GUILDBATTLE = 6,							-- 公会争霸排行榜
	GUILD_RANK_TYPE_TERRITORYWAR,								-- 领土战排行榜
	GUILD_RANK_TYPE_MAX,
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
	MULTI_MOUNT_REQ_TYPE_SELECT_MOUNT = 0,			-- 选择使用坐骑：param1 坐骑id
	MULTI_MOUNT_REQ_TYPE_UPGRADE = 1,				-- 坐骑进阶：param1 坐骑id
	MULTI_MOUNT_REQ_TYPE_RIDE = 2,					-- 上坐骑
	MULTI_MOUNT_REQ_TYPE_UNRIDE = 3,				-- 下坐骑
	MULTI_MOUNT_REQ_TYPE_INVITE_RIDE = 4,			-- 邀请骑乘：param1 玩家id
	MULTI_MOUNT_REQ_TYPE_INVITE_RIDE_ACK = 5,		-- 回应邀请骑乘：param1 玩家id，param2 是否同意
	MULTI_MOUNT_REQ_TYPE_USE_SPECIAL_IMG = 6,		-- 请求使用幻化形象：param1特殊形象ID
	MULTI_MOUNT_REQ_TYPE_UPGRADE_EQUIP = 7,			-- 请求升级坐骑装备：param1 装备类型（下标）
}

MULTI_MOUNT_CHANGE_NOTIFY_TYPE = {
	MULTI_MOUNT_CHANGE_NOTIFY_TYPE_SELECT_MOUNT = 0,					-- 当前使用中的坐骑改变, param1 坐骑id
	MULTI_MOUNT_CHANGE_NOTIFY_TYPE_UPGRADE = 1,							-- 进阶数据改变, param1 坐骑id，param2 阶数，param3 祝福值
	MULTI_MOUNT_CHANGE_NOTIFY_TYPE_INVITE_RIDE = 2,						-- 收到别人坐骑邀请, param1 玩家ID，param2 坐骑ID
	MULTI_MOUNT_CHANGE_NOTIFY_TYPE_ACTIVE_SPECIAL_IMG = 3,				-- 激活双人坐骑特殊形象 param1特殊形象激活标记
	MULTI_MOUNT_CHANGE_NOTIFY_TYPE_USE_SPECIAL_IMG = 4,					-- 使用特殊形象 param1特殊形象id
	MULTI_MOUNT_CHANGR_NOTIFY_TYPE_UPGRADE_EQUIP = 5,					-- 坐骑装备数据改变
	MULTI_MOUNT_CHANGE_NOTIFY_TYPE_UPLEVEL_SPECIAL_IMG = 6,          	-- 升级特殊形象  param1 特殊形象id， param2 特殊形象等级（新增类型）
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

--特殊聊天id
SPECIAL_CHAT_ID = {
	GUILD = 1,
	TEAM = 2,
	ALL = 100,										--100之后的都默认为私聊id
}

CHANNEL_TYPE = {
	WORLD = 0,										-- 世界
	CAMP = 1,										-- 阵营
	SCENE = 2,										-- 场景
	TEAM = 3,										-- 队伍
	GUILD = 4,										-- 公会
	WORLD_QUESTION = 5,								-- 世界答题
	GUILD_QUESTION = 6,								-- 公会答题

	PRIVATE = 94,									-- 私聊
	SYSTEM = 95,									-- 系统
	GUILD_SYSTEM = 96,								-- 公会系统
	SPEAKER = 97,									-- 喇叭
	CROSS = 98,										-- 跨服
	MAINUI = 99,									-- 主界面
	ALL = 100,										-- 全部
}

SYS_MSG_TYPE = {
	SYS_MSG_ONLY_CHAT_WORLD = 0,					-- 只添加到聊天世界频道
	SYS_MSG_ONLY_CHAT_GUILD = 1,	 				-- 只添加到聊天仙盟频道
	SYS_MSG_CENTER_AND_ROLL = 2,					-- 屏幕中央滚动消息
	SYS_MSG_CENTER_NOTICE_NOT_CHAT = 3, 			-- 屏幕中央弹出消息, 不添加到主界面聊天列表中
	SYS_MSG_ACTIVE_NOTICE = 4, 						-- 活动公告
	SYS_MSG_CENTER_PERSONAL_NOTICE = 5, 			-- 个人消息弹出
	SYS_MSG_CENTER_NOTICE = 6,						-- 屏幕中央弹出消息
	SYS_MSG_ONLY_WORLD_QUESTION = 7,				-- 只添加到世界答题
	SYS_MSG_ONLY_GUILD_QUESTION = 8,				-- 只添加到公会答题
	SYS_MSG_EVENT_TYPE_COMMON_NOTICE = 11,
	SYS_MSG_EVENT_TYPE_SPECIAL_NOTICE = 12
}

--循环进阶活动请求类型
RA_UPGRADE_NEW_OPERA_TYPE = {
	RA_UPGRADE_NEW_OPERA_TYPE_QUERY_INFO = 0,       -- 请求所有信息
	RA_UPGRADE_NEW_OPERA_TYPE_FETCH_REWARD = 1,		-- 请求领奖信息

	RA_UPGRADE_NEW_OPERA_TYPE_MAX = 2,
}

--不添加到主界面聊天的频道
NOT_ADD_MAIN_CHANNEL_TYPE = {
	[CHANNEL_TYPE.TEAM] = true,
	[CHANNEL_TYPE.GUILD] = true,
	[CHANNEL_TYPE.GUILD_SYSTEM] = true,
	[CHANNEL_TYPE.WORLD_QUESTION] = true,
	[CHANNEL_TYPE.GUILD_QUESTION] = true,
}

--不添加到主界面聊天的消息类型
NOT_ADD_MAIN_SYS_MSG_TYPE = {
	[SYS_MSG_TYPE.SYS_MSG_ONLY_CHAT_GUILD] = true,
	[SYS_MSG_TYPE.SYS_MSG_CENTER_NOTICE_NOT_CHAT] = true,
	[SYS_MSG_TYPE.SYS_MSG_ONLY_WORLD_QUESTION] = true,
	[SYS_MSG_TYPE.SYS_MSG_ONLY_GUILD_QUESTION] = true,
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

--------- 随机活动 至尊幸运-----------------------------
RA_EXTREME_LUCKY_OPERA_TYPE = {
	RA_EXTREME_LUCKY_OPERA_TYPE_QUERY_INFO = 0,			-- 请求活动信息
	RA_EXTREME_LUCKY_OPERA_TYPE_FLUSH = 1,					-- 刷新
	RA_EXTREME_LUCKY_OPERA_TYPE_DRAW = 2,					-- 抽奖
	RA_EXTREME_LUCKY_OPERA_TYPE_NEXT_FLUSH = 3,             -- 本轮物品已经抽到9个，请求刷新
	RA_EXTREME_LUCKY_OPERA_TYPE_MAX = 5,
    RA_EXTREME_LUCKY_OPREA_TYPE_FETCH_REWARD = 4,           -- 领取返利奖励
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
}


CHEST_SHOP_TYPE = {
	CHEST_SHOP_TYPE_EQUIP = 1,						-- 装备类型宝箱抽奖
	CHEST_SHOP_TYPE_JINGLING = 2,				-- 精灵类型宝箱抽奖
	CHEST_SHOP_TYPE_SUPER = 3,                   -- 至尊寻宝
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
	CHEST_RANK_JINYIN_TA_MODE_1 = 28,			    -- 金银塔1次
	CHEST_RANK_JINYIN_TA_MODE_10 = 29,		        -- 金银塔10次
	CHEST_RANK_JINYIN_GET_REWARD = 30,				-- 领取累计奖励
	CHEST_RANK_JINYIN_QUICK_REWARD = 31,			-- 精灵家园加速奖励
	CHEST_GUAJITA_REWARD = 32,						-- 符文塔扫荡
	CHEST_RANK_ZHUANZHUANLE_MODE_10 = 33,           --转转乐10次
	CHEST_RANK_ZHUANZHUANLE_MODE_1 = 34,            --转转乐1次
	CHEST_RANK_ZHUANZHUANLE_GET_REWARD = 35,        --领取累积奖励
	CHEST_PUSH_FB_STAR_REWARD = 36,					-- 推图本星星奖励
	CHEST_RANK_FANFANZHUANG_10 = 37,				-- 翻翻转10次
	CHEST_RANK_FANFANZHUANG_50 = 38,				-- 翻翻转10次
	CHEST_RANK_LUCK_CHESS_10 = 39,					-- 幸运棋10次
	HAPPY_RECHARGE_1 = 40,							-- 充值大乐透1次
	HAPPY_RECHARGE_10 = 41,							-- 充值大乐透10次
	LUCKLY_TURNTABLE_GET_REWARD = 42,				-- 转盘抽奖
	CHEST_HUNQI_BAOZANG_10 = 43, 					--魂器宝藏开启十次
	CHEST_WABAO_QUICKL = 44,
	CHEST_HUNQI_BAOZANG_1 = 45,						--魂器宝藏开启一次
	CHEST_HAPPYHITEGG_MODE_1 = 55,					--欢乐砸蛋1次
	CHEST_HAPPYHITEGG_MODE_10 = 56,				    --欢乐砸蛋10次
	CHEST_HAPPYHITEGG_MODE_30 = 57,				    --欢乐砸蛋30次
	CHEST_ZHONGQIU_HAPPY_ERNIE_MODE_1 = 60,				    --中秋欢乐砸蛋10次
	CHEST_ZHONGQIU_HAPPY_ERNIE_MODE_10 = 61,				    --中秋欢乐砸蛋20次
	CHEST_ZHONGQIU_HAPPY_ERNIE_MODE_30 = 62,				    --中秋欢乐砸蛋30次

	CHEST_GuaGuaLe_MODE_1 = 46,
	CHEST_GuaGuaLe_MODE_10 = 47,
	CHEST_GuaGuaLe_MODE_50 = 48,
	CHEST_MIJINGXUNBAO3_MODE_1 = 49,				--秘境寻宝抽一次
	CHEST_MIJINGXUNBAO3_MODE_10 = 50,				--秘境寻宝抽十次
	CHEST_MIJINGXUNBAO3_MODE_30 = 51,				--秘境寻宝抽三十次
	CHEST_HAPPY_ERNIE_MODE_1 = 52,						-- 欢乐摇奖一次
	CHEST_HAPPY_ERNIE_MODE_10 = 53,						-- 欢乐摇奖十次
	CHEST_HAPPY_ERNIE_MODE_30 = 54,						-- 欢乐摇奖三十次
	CHEST_LITTLE_PET_MODE_1 = 58,					-- 小宠物商店1次
	CHEST_LITTLE_PET_MODE_10 = 59,					-- 小宠物商店10次
	LOCKY_DRAW_10 = 60,								-- 占卜十次
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
	NVSHEN_FAN = 3,  	-- 女神反伤
	NVSHEN_SHA = 4,		-- 女神杀戮

	SHENSHENG = 10,		-- 神圣
	YAZHI = 11,			-- 压制
	BAOJI = 12,			-- 暴击
}

--买一送一活动请求
RA_BUY_ONE_GET_ONE_FREE_OPERA_TYPE = {
	RA_BUY_ONE_GET_ONE_FREE_OPERA_TYPE_INFO = 0,			--请求物品的信息
	RA_BUY_ONE_GET_ONE_FREE_OPERA_TYPE_BUY = 1,				--请求购买物品的索引
	RA_BUY_ONE_GET_ONE_FREE_OPERA_TYPE_FETCH_REWARD = 2,	--请求领取物品的索引
}

--版本累计充值请求
RA_VERSION_TOTAL_CHARGE_OPERA_TYPE = {
    RA_VERSION_TOTAL_CHARGE_OPERA_TYPE_QUERY_INFO = 0,
    RA_VERSION_TOTAL_CHARGE_OPERA_TYPE_FETCH_REWARD = 1,

    RA_VERSION_TOTAL_CHARGE_OPERA_TYPE_MAX = 2,
}

--消费有礼类型
RA_CONSUME_FOR_GIFT_OPERA_TYPE = {
	RA_CONSUME_FOR_GIFT_OPERA_TYPE_ALL_INFO = 0,			--请求所有信息
	RA_CONSUME_FOR_GIFT_OPERA_TYPE_EXCHANGE_ITEM = 1,	--兑换物品

	RA_CONSUME_FOR_GIFT_OPERA_TYPE_MAX = 2,
}
-- 变身类型
BIANSHEN_EFEECT_APPEARANCE =
{
	APPEARANCE_NORMAL = 0,									-- 正常外观
	APPEARANCE_DATI_XIAOTU = 1,								-- 答题变身卡-小兔
	APPEARANCE_DATI_XIAOZHU = 2,							-- 答题变身卡-小猪
	APPEARANCE_MOJIE_GUAIWU = 3,							-- 魔戒技能-怪物形象
	APPEARANCE_YIZHANDAODI = 4,								-- 一站到底-树人
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
	UPLEVEL_SKILL = 4,										-- 升级技能
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
	[1] = "DLW_nvshenzhufu",
	[2] = "DLW_nvshenzhiqiang",
	[3] = "DLW_nvshenzhinu",
	[4] = "DLW_nvshenzhidun",
	[5] = "DLW_nvshenzhinu",
}

--符文系统操作参数
RUNE_SYSTEM_REQ_TYPE = {
	RUNE_SYSTEM_REQ_TYPE_ALL_INFO = 0,								-- 请求所有信息
	RUNE_SYSTEM_REQ_TYPE_BAG_ALL_INFO = 1,							-- 请求背包所有信息
	RUNE_SYSTEM_REQ_TYPE_RUNE_GRID_ALL_INFO = 2,					-- 请求符文槽所有信息
	RUNE_SYSTEM_REQ_TYPE_ONE_KEY_DISPOSE = 3,						-- 一键分解		p1 虚拟背包索引
	RUNE_SYSTEM_REQ_TYPE_COMPOSE = 4,								-- 合成			p1 索引1 p2 非零（索引1是背包索引);零（索引1是格子索引）p3 索引2 p4 非零（索引2是背包索引);零（索引2是格子索引）
	RUNE_SYSTEM_REQ_TYPE_SET_RUAN = 5,								-- 装备符文		p1 虚拟背包索引	p2 符文槽格子索引
	RUNE_SYSTEM_REQ_TYPE_XUNBAO_ONE = 6,							-- 寻宝一次
	RUNE_SYSTEM_REQ_TYPE_XUNBAO_TEN = 7,							-- 寻宝十次
	RUNE_SYSTEM_REQ_TYPE_UPLEVEL = 8,								-- 升级符文		p1 符文槽格子索引
	RUNE_SYSTEM_REQ_TYPE_CONVERT = 9,								-- 符文兑换
	RUNE_SYSTEM_REQ_TYPE_OTHER_INFO = 10,							-- 其他信息
	RUNE_SYSTEM_REQ_TYPE_AWAKEN = 11,								-- 符文格觉醒			p1 格子， p2觉醒类型
	RUNE_SYSTEM_REQ_TYPE_AWAKEN_CALC_REQ = 12,						-- 符文格觉醒重算战力
	RUNE_SYSTEM_REQ_TYPE_RAND_ZHILING_SLOT = 13,					-- 随机注灵槽（新增）
	RUNE_SYSTEM_REQ_TYPE_ZHULING = 14,								-- 注灵，参数1 符文格子index
	RUNE_SYSTEM_REQ_TYPE_ACTIVATE_BEST_RUNE = 15,					-- 激活终极符文
	RUNE_SYSTEM_REQ_TYPE_BUY_BEST_RUNE_ACTIVATE_CARD = 16,			-- 购买终极符文
	RUNE_SYSTEM_REQ_TYPE_GET_BEST_RUNE_ACTIVATE_CARD = 17,			-- 领取终极符文
	RUNE_SYSTEM_REQ_TYPE_BUY_RUNE_SMALL_TARGET_TITLE_CARD = 18,		-- 购买符文小目标称号卡
	RUNE_SYSTEM_REQ_TYPE_GET_RUNE_SMALL_TARGET_TITLE_CARD = 19,		-- 免费领取符文小目标称号卡（达到条件）
}

RUNE_SYSTEM_AWAKEN_TYPE = {
	RUEN_AWAKEN_TYPE_COMMON = 0,
	RUEN_AWAKEN_TYPE_DIAMOND = 1,
	RUNE_AWAKEN_TYPE_NOT_TEN = 0,
	RUNE_AWAKEN_TYPE_IS_TEN = 1,
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
	EFFECT_REBOUNDHURT = 2, 				-- 反弹伤害
	EFFECT_RESTORE_HP = 3, 					-- 回血飘字
	EFFECT_NORMAL_HURT = 4, 				-- 通用伤害飘字
	EFFECT_JUST_SPECIAL_EFFECT = 5, 		-- 仅仅播放特效，不需要飘字
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

	SPECIAL_EFFECT_REBOUNDHURT = 7, 			-- 反弹伤害
	SPECIAL_EFFECT_XIANNV_SHENGWU_RESTORE_HP = 8, -- 仙女圣物回血技能
	SPECIAL_EFFECT_XIANNV_SHENGWU_HURT = 9, 	-- 仙女圣物直接伤害技能
	SPECIAL_EFFECT_JINGLING_REBOUNDHURT = 10,	-- 精灵反弹伤害

	SPECIAL_EFFECT_MAX = 11,
}

-- 这里面key与上面的类型对应
ATTATCH_SKILL_SPECIAL_EFFECT_RES = {
	[1] = "Boss_jinlei_T",
	[2] = "tongyong_yunsi",
	[3] = "Boss_lqf",
	[4] = "T_zjjn_shuilonjuan",
	[5] = "T_zjjn_jian",
	[6] = "tongyong_leishenchui",
	[7] = "Effect_fantan",
	[8] = "Buff_nvshenzhufu",
	[9] = "Effect_daji",
	[10] = "10042",--Effect_fantanhudun
	[60] = "BDJN_01",
	[61] = "BDJN_02",
	[62] = "BDJN_03",
	[63] = "BDJN_04",
	[64] = "BDJN_05",
	[65] = "BDJN_06",
}

-- 聚宝盆
RA_CORNUCOPIA_OPERA_TYPE = {
	RA_CORNUCOPIA_OPERA_TYPE_QUERY_INFO = 0,
	RA_CORNUCOPIA_OPERA_TYPE_FETCH_REWARD = 1,
	RA_CORNUCOPIA_OPERA_TYPE_FETCH_REWARD_INFO = 2,
}

-- 温泉技能类型
HOTSPRING_SKILL_TYPE = {
	HOTSPRING_SKILL_MASSAGE = 1,			-- 搓背 (喝酒)
	HOTSPRING_SKILL_THROW_SNOWBALL = 2,		-- 扔雪球
}


-- 虚拟技能
VIRTUAL_SKILL_TYPE = {
	THROW_SNOW_BALL = 10001,				-- 温泉扔雪球
}

--好友祝贺消息类型
SC_FRIEND_HELI_REQ_YTPE = {
	SC_FRIEND_HELI_UPLEVEL_REQ = 0,					-- 升级贺礼          p1 = level
	SC_FRIEND_HELI_SKILL_BOSS_FETCH_EQUI_REQ = 1,	-- 杀boss获得好装备，p1 = bossid , p2 = 装备id
}

--好友祝贺送礼类型
CONGRATULATION_TYPE = {
	EGG = 1,
	FLOWER = 2,
}

-- 婚礼祝福
MARRY_ZHUHE_TYPE = {
	MARRY_ZHUHE_TYPE0 = 0,						-- 祝福
	MARRY_ZHUHE_TYPE1 = 1,						-- 送花
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


--仙阵魂玉类型
HUNYU_TYPE = {
	LIFE_HUNYU = 0,
	ATTACK_HUNYU = 1,
	DEFENSE_HUNYU = 2
}

--仙阵提升界面选择
SPIRITPROMOTETAB_TYPE = {
	TABXIANZHEN = 1,
	TABHUNYU = 2
}

-- 温泉动作
HOTSPRING_ACTION_TYPE = {
	SHUANG_XIU = 1,						-- 双修
	MASSAGE = 2,						-- 按摩
}

--进阶奖励类型
JINJIE_TYPE =
{
	JINJIE_TYPE_CLOAK = 0,							-- 披风
	JINJIE_TYPE_FIGHT_MOUNT = 1,					-- 战斗坐骑
	JINJIE_TYPE_FOOTPRINT = 2,						-- 足迹
	JINJIE_TYPE_HALO = 3,							-- 光环
	JINJIE_TYPE_LINGZHU = 4,						-- 灵珠
	JINJIE_TYPE_MASK = 5,							-- 面饰
	JINJIE_TYPE_MOUNT = 6,							-- 坐骑
	JINJIE_TYPE_QILINBI = 7,						-- 麒麟臂
	JINJIE_TYPE_SHENGONG = 8,						-- 神弓
	JINJIE_TYPE_SHENYI = 9,							-- 神翼
	JINJIE_TYPE_TOUSHI = 10,						-- 头饰
	JINJIE_TYPE_WING = 11,							-- 羽翼
	JINJIE_TYPE_XIANBAO = 12,						-- 仙宝
	JINJIE_TYPE_YAOSHI = 13,						-- 腰饰
	JINJIE_TYPE_LINGGONG = 14,						-- 灵弓
	JINJIE_TYPE_LINGQI = 15,						-- 灵骑
	JINJIE_TYPE_LINGCHONG = 16,						-- 灵宠
	JINJIE_TYPE_WEIYAN = 17,						-- 尾焰

	JINJIE_TYPE_MAX = 18,

}

--进阶奖励操作类型
JINJIESYS_REWARD_OPEAR_TYPE = {
	JINJIESYS_REWARD_OPEAR_TYPE_INFO = 0,			-- 获取信息
	JINJIESYS_REWARD_OPEAR_TYPE_BUY = 1,			-- 购买, param_1 = 进阶系统类型
	JINJIESYS_REWARD_OPEAR_TYPE_FETCH = 2,			-- 领取进阶奖励, param_1 = 进阶系统类型
}

--元宝转盘
Yuan_Bao_Zhuanpan_OPERATE_TYPE = {
	SET_JC_ZhUANSHI_NUM = 0,		--SC请求CS发送奖池砖石数量
	CHOU_JIANG = 1,					--SC抽奖时发的协议
}

GUILD_MAZE_OPERATE_TYPE = {
	GUILD_MAZE_OPERATE_TYPE_GET_INFO = 0,		-- 请求信息
	GUILD_MAZE_OPERATE_TYPE_SELECT = 1,      	-- 选门
}

MYSTERIOUSSHOP_IN_MALL_OPERATE_TYPE = {
	OPERATE_TYPE_MONEY = 0,
	OPERATE_REQ = 2,
	OPERATE_TYPE_REFRESH = 1,
}

-- 公会迷宫通知原因
GUILD_MAZE_INFO_REASON = {
	GUILD_MAZE_INFO_REASON_DEF = 0,
	GUILD_MAZE_INFO_REASON_FIRST_SUCC = 1,
	GUILD_MAZE_INFO_REASON_SUCC = 2,
	GUILD_MAZE_INFO_REASON_FAIL = 3,
}

--连充特惠
RA_CONTINUE_CHONGZHI_OPERA_TYPE = {

		RA_CONTINUE_CHONGZHI_OPERA_TYPE_QUERY_INFO = 0,		-- 请求活动信息
		RA_CONTINUE_CHONGZHI_OPEAR_TYPE_FETCH_REWARD = 1,		-- 获取奖励

		RA_CONTINUE_CHONGZHI_OPERA_TYPE_MAX = 2,
}

--金猪召唤
GOLDEN_PIG_OPERATE_TYPE = {
	GOLDEN_PIG_OPERATE_TYPE_REQ_INFO = 0,				--请求信息
	GOLDEN_PIG_OPERATE_TYPE_SUMMON = 1,					--召唤
}

GOLDEN_PIG_SUMMON_TYPE = {
	GOLDEN_PIG_SUMMON_TYPE_JUNIOR = 0,					-- 初级召唤
	GOLDEN_PIG_SUMMON_TYPE_MEDIUM = 1,					-- 中级召唤
	GOLDEN_PIG_SUMMON_TYPE_SENIOR = 2,					-- 高级召唤
}

IMP_GUARD_TYPE = {
	TIANSHI = 1,
	EMO = 2,
}

IMP_GUARD_REQ_TYPE = {
	IMP_GUARD_REQ_TYPE_RENEW_PUTON = 0,					-- 续费 穿在身上的恶魔天使 （param1：恶魔还是天使，param2 : 是否使用绑元）
	IMP_GUARD_REQ_TYPE_RENEW_KNAPSACK = 1,				-- 续费 背包中的恶魔天使   （param1：背包index，   param2 ：是否使用绑元）
	IMP_GUARD_REQ_TYPE_TAKEOFF = 2,						-- 脱下 恶魔天使		   （param1：恶魔还是天使）
	IMP_GUARD_REQ_TYPE_ALL_INFO = 3,					-- 请求信息
}

JING_LING_HOME_OPER_TYPE = {
	JING_LING_HOME_OPER_TYPE_GET_INFO = 0,		-- 查询信息, 参数1 人物ID
	JING_LING_HOME_OPER_TYPE_PUT_HOME = 1,		-- 放入家园 param1 精灵索引，param2 家园索引
	JING_LING_HOME_OPER_TYPE_QUICK = 2,			-- 加快速度 param1 家园索引
	JING_LING_HOME_OPER_TYPE_GET_REWARD = 3,		-- 领取奖励 param1 家园索引
	JING_LING_HOME_OPER_TYPE_ROB = 4,			-- 掠夺 param1 精灵索引，param2 家园索引
	JING_LING_HOME_OPER_TYPE_OUT = 5, 			-- 取出, param1 家园索引
	JING_LING_HOME_OPER_TYPE_REFRESH_LIST = 6, 				-- 刷新列表
	JING_LING_HOME_OPER_TYPE_READ_ROB_RECORD = 7, -- 阅读被掠夺记录
}

JING_LING_HOME_REASON = {
	JING_LING_HOME_REASON_DEF = 0,
	JING_LING_HOME_REASON_PUT = 1,
	JING_LING_HOME_REASON_QUICK = 2,
	JING_LING_HOME_REASON_GET_REWARD = 3,
	JING_LING_HOME_REASON_ROB_WIN = 4,
	JING_LING_HOME_REASON_ROB_LOST = 5,
}

SKIP_TYPE = {
	SKIP_TYPE_CHALLENGE = 0,						--决斗场，附近的人
	SKIP_TYPE_SAILING = 1,							--决斗场，航海
	SKIP_TYPE_MINE = 2,								--决斗场，挖矿
	SKIP_TYPE_FISH = 3,								--捕鱼
	SKIP_TYPE_JINGLING_ADVANTAGE = 4,				--精灵奇遇
	SKIP_TYPE_SHENZHOU_WEAPON = 5,					--上古遗迹
	SKIP_TYPE_XINGZUOYIJI = 6,						--星座遗迹
	SKIP_TYPE_QYSD = 7,								--情缘圣地
	SKIP_TYPE_PRECIOUS_BOSS = 8,					--秘藏boss
	SKIP_TYPE_PAOHUAN_TASK = 9,						--跑环任务
	SKIP_TYPE_CROSS_GUIDE = 10,						--跨服争霸
}

JING_LING_HOME_STATE = {
	MY = 0,
	OTHER = 1,
	MY_IN_OTHER = 2,
}

JING_LING_HOME_SEND_STATE = {
	SEND = 0,
	REPLACE = 1,
	TAKE_BACK = 2,
}

JL_EXPLORE_OPER_TYPE = {
	JL_EXPLORE_OPER_TYPE_SELECT_MODE = 0,		-- 选择模式, param1 模式 0简单 1普通 2困难
	JL_EXPLORE_OPER_TYPE_EXPLORE = 1,			-- 挑战
	JL_EXPLORE_OPER_TYPE_FETCH = 2,				-- 领取奖励, param1 关卡 0~5
	JL_EXPLORE_OPER_TYPE_RESET = 3,				-- 重置挑战
	JL_EXPLORE_OPER_TYPE_BUY_BUFF = 4, 			-- 购买BUFF
}

JL_EXPLORE_INFO_REASON = {
	JL_EXPLORE_INFO_REASON_DEF = 0,
	JL_EXPLORE_INFO_REASON_SELECT = 1,
	JL_EXPLORE_INFO_REASON_CHALLENGE_SUCC = 2,
	JL_EXPLORE_INFO_REASON_CHALLENGE_FAIL = 3,
	JL_EXPLORE_INFO_REASON_FETCH = 4,
	JL_EXPLORE_INFO_REASON_RESET = 5,
	JL_EXPLORE_INFO_REASON_BUY_BUFF = 6,
}

RA_CHONGZHI_MONEY_TREE_OPERA_TYPE ={
	RA_MONEY_TREE_OPERA_TYPE_QUERY_INFO = 0,			-- 请求活动信息
	RA_MONEY_TREE_OPERA_TYPE_CHOU = 1,						--抽奖：param_1 次数
	RA_MONEY_TREE_OPERA_TYPE_FETCH_REWARD = 2,				-- 领取全服奖励：param_1 seq
	RA_MONEY_TREE_OPERA_TYPE_MAX = 3,
}

--消费返利
 RA_CONSUME_GOLD_REWARD_OPERATE_TYPE = {
	RA_CONSUME_GOLD_REWARD_OPERATE_TYPE_INFO = 0,		-- 请求活动信息
	RA_CONSUME_GOLD_REWARD_OPERATE_TYPE_FETCH = 1,		-- 请求领取奖励
}


SPIRIT_FIGHT_TYPE = {
	HOME = 0,
	EXPLORE = 1,
}

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

FUBEN_SCENE_ID ={
	SHUIJING = 1500,   --水晶
}

CHAT_OPENLEVEL_LIMIT_TYPE = {
    WORLD = 0,
    CAMP = 1,
    SCENE = 2,
    TEAM = 3,
    GUILD = 4,
    SINGLE = 5,
    SEND_MAIL = 6,
    SPEAKER = 7,
    MAX = 8,
}

ANIMATOR_PARAM = {
	STATUS = UnityEngine.Animator.StringToHash("status"),
	ATTACK1 = UnityEngine.Animator.StringToHash("attack1"),
	ATTACK2 = UnityEngine.Animator.StringToHash("attack2"),
	COMBO1_1 = UnityEngine.Animator.StringToHash("combo1_1"),
	COMBO1_2 = UnityEngine.Animator.StringToHash("combo1_2"),
	COMBO1_3 = UnityEngine.Animator.StringToHash("combo1_3"),
	HURT = UnityEngine.Animator.StringToHash("hurt"),
	REST = UnityEngine.Animator.StringToHash("rest"),
	REST1 = UnityEngine.Animator.StringToHash("rest1"),
	SHOW = UnityEngine.Animator.StringToHash("show"),
	FIGHT = UnityEngine.Animator.StringToHash("fight"),
	COMBO1_1_BACK = UnityEngine.Animator.StringToHash("combo1_1_back"),
	COMBO1_2_BACK = UnityEngine.Animator.StringToHash("combo1_2_back"),
	COMBO1_3_BACK = UnityEngine.Animator.StringToHash("combo1_3_back"),
	BASE_LAYER = 0,
	FLY_LAYER = 1,
	MOUNT_LAYER = 2,
	FIGHTMOUNT_LAYER = 3,
	CHONGCI_LAYER = 4,
	ACTION_LAYER = 5,
	DEATH_LAYER = 6,
	HUG_LAYER = 7,
	FISH_LAYER = 8,
	CROSS_MINING_LAYER = 9,
	MOUNT_LAYER2 = 10,
	DANCE1_LAYER = 11,
	DANCE2_LAYER = 12,
	DANCE3_LAYER = 13,
}

LINGCHONG_ANIMATOR_PARAM = {
	REST = UnityEngine.Animator.StringToHash("rest"),
	STATUS = UnityEngine.Animator.StringToHash("status"),
	FIGHT = UnityEngine.Animator.StringToHash("fight"),

	BASE_LAYER = 0,
	MOUNT_LAYER = 1,
}

CLOAK_OPERATE_TYPE = {
	CLOAK_OPERATE_TYPE_INFO_REQ = 0,				-- 请求信息
	CLOAK_OPERATE_TYPE_UP_LEVEL = 1,				-- 请求升级 param_1=>stuff_index param_2=>is_auto_buy param_3=>loop_times
	CLOAK_OPERATE_TYPE_USE_IMAGE = 2,				-- 请求使用形象 param_1=>image_id
	CLOAK_OPERATE_TYPE_UP_SPECIAL_IMAGE = 3,		-- 请求升特殊形象进阶 param_1=>special_image_id
	CLOAK_OPERATE_TYPE_UP_LEVEL_EQUIP = 4,			-- 请求升级装备 param_1=>equip_idx
	CLOAK_OPERATE_TYPE_UP_LEVEL_SKILL = 5,			-- 请求升级技能 param_1=>skill_idx param_2=>auto_buy
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

-- 神兽
SHENSHOU_REQ_TYPE ={
	SHENSHOU_REQ_TYPE_ALL_INFO = 0,					-- 请求所有信息
	SHENSHOU_REQ_TYPE_PUT_ON = 1,					-- 装备， param1 背包格子index，param2 神兽ID, param3 装备槽格子index
	SHENSHOU_REQ_TYPE_TAKE_OFF = 2,					-- 卸下， param1 神兽ID, param2 装备槽index
	SHENSHOU_REQ_TYPE_ZHUZHAN = 3,					-- 助战， param1 神兽ID，
	SHENSHOU_REQ_TYPE_ADD_ZHUZHAN = 4,				-- 扩展神兽助战位
	SHENSHOU_REQ_TYPE_COMPOSE = 5,					-- 合成， param_1 物品id ，param_2 背包格子index1 ，param_3 背包格子index2，param_4 背包格子index3

	SHENSHOU_REQ_TYPE_HUANLING_INFO = 6,			-- 请求唤灵信息,服务器发送2565
	SHENSHOU_REQ_TYPE_HUANLING_REFRESH = 7,			-- 唤灵刷新
	SHENSHOU_REQ_TYPE_HUANLING_DRAW = 8,			-- 唤灵抽奖
}

-- 单笔充值2（单返豪礼）
RA_SINGLE_CHONGZHI_OPERA_TYPE =
{
	RA_SINGLE_CHONGZHI_OPERA_TYPE_INFO = 0,				-- 请求信息
	RA_SINGLE_CHONGZHI_OPERA_TYPE_FETCH_REWARD = 1,		-- 领取奖励

	RA_SINGLE_CHONGZHI_OPERA_TYPE_MAX = 2,
}

RA_DAY_ACTIVE_DEGREE_OPERA_TYPE = {
	RA_DAY_ACTIVE_DEGREE_OPERA_TYPE_QUERY_INFO = 0,		-- 查询信息
	RA_DAY_ACTIVE_DEGREE_OPERA_TYPE_FETCH_REWARD = 1,	-- 领取奖励 param1,reward_seq
}

RA_CHARGE_REPAYMENT_OPERA_TYPE ={
	RA_CHARGE_REPAYMENT_OPERA_TYPE_QUERY_INFO = 0,		--请求信息
	RA_CHARGE_REPAYMENT_OPERA_TYPE_FETCH_REWARD = 1,	--领取奖励
	RA_CHARGE_REPAYMENT_OPERA_TYPE_MAX = 2,
}

RA_SERVER_PANIC_BUY_OPERA_TYPE = {
	RA_SERVER_PANIC_BUY_OPERA_TYPE_QUERY_INFO = 0,
	RA_SERVER_PANIC_BUY_OPERA_TYPE_BUY_ITEM = 1,

	RA_SERVER_PANIC_BUY_OPERA_TYPE_MAX = 2,
}

IMG_FULING_JINGJIE_TYPE = {
	IMG_FULING_JINGJIE_TYPE_MOUNT  =  0,			--坐骑
	IMG_FULING_JINGJIE_TYPE_WING  =  1,				--羽翼
	IMG_FULING_JINGJIE_TYPE_HALO  =  2,				--光环
	IMG_FULING_JINGJIE_TYPE_FIGHT_MOUNT  =  3,		--魔骑
	IMG_FULING_JINGJIE_TYPE_SHENGONG  =  4,			--神弓
	IMG_FULING_JINGJIE_TYPE_SHENYI  =  5,			--神翼
	IMG_FULING_JINGJIE_TYPE_FOOT_PRINT  =  6,		--足迹
}

--  操作类型
IMG_FULING_OPERATE_TYPE = {
	IMG_FULING_OPERATE_TYPE_INFO_REQ  =  0,			--  请求信息
	IMG_FULING_OPERATE_TYPE_LEVEL_UP = 1,			--  请求升级  param_1=>进阶系统类型    param_2=>花费物品索引
}

CSA_ROLL_OPERA = {
    CSA_ROLL_OPERA_ROLL = 0,       -- 抽奖
    CSA_ROLL_OPERA_BROADCAST = 1,  -- 传闻
 }

GUILD_SINGIN_REQ_TYPE = {
    GUILD_SINGIN_REQ_TYPE_SIGNIN = 0,               	-- 签到
    GUILD_SINGIN_REQ_TYPE_FETCH_REWARD = 1,             -- 拿奖励 p1 index
    GUILD_SINGIN_REQ_ALL_INFO = 2,                  	-- 请求所有信息
}

--新累计充值
RA_NEW_TOTAL_CHARGE_OPERA_TYPE ={
	RA_NEW_TOTAL_CHARGE_OPERA_TYPE_QUERY_INFO = 0,
	RA_NEW_TOTAL_CHARGE_OPERA_TYPE_FETCH_REWARD = 1,

	RA_NEW_TOTAL_CHARGE_OPERA_TYPE_MAX = 2,
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
	CROSS_MINING_REQ_TYPE_USE_SKILL = 9,	   				-- 使用技能
	CROSS_MINING_REQ_TYPE_BUY_BUFF = 10, 					-- 购买buff

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
--情缘圣地
QYSD_OPERA_TYPE =
{
	QYSD_OPERA_TYPE_FETCH_TASK_REWARD = 0,				-- 领取任务奖励，param -> 任务索引
	QYSD_OPERA_TYPE_FETCH_OTHER_REWARD = 1,				-- 领取额外奖励
}
--欢乐砸蛋
RA_HUANLEZADAN_CHOU_TYPE =                            -- 淘宝类型
{
  RA_HUANLEZADAN_CHOU_TYPE_1 = 0,                     -- 淘宝一次
  RA_HUANLEZADAN_CHOU_TYPE_10 = 1,                    -- 淘宝十次
  RA_HUANLEZADAN_CHOU_TYPE_30 = 2,                    -- 淘宝三十次
  RA_HUANLEZADAN_CHOU_TYPE_MAX = 3,
}

--欢乐砸蛋
RA_HUANLEZADAN_OPERA_TYPE =
 {
   RA_HUANLEZADAN_OPERA_TYPE_QUERY_INFO = 0,                -- 请求活动信息
   RA_HUANLEZADAN_OPERA_TYPE_TAO = 1,                       -- 淘宝
   RA_HUANLEZADAN_OPERA_TYPE_FETCH_REWARD = 2,              -- 领取个人累抽奖励 param_1 = 领取奖励的索引（0开始）
   RA_HUANLEZADAN_OPERA_TYPE_MAX = 3,
 }

--合服活动
COMBINE_SERVER_ACTIVITY_SUB_TYPE = {
	CSA_SUB_TYPE_INVALID  =  0,
	CSA_SUB_TYPE_RANK_QIANGGOU = 1,	    --  抢购
	CSA_SUB_TYPE_ROLL = 2,	     		--  转盘
	CSA_SUB_TYPE_GONGCHENGZHAN = 3,	    --  攻城战
	CSA_SUB_TYPE_XIANMENGZHAN = 4,	    --  仙盟战  -- 暂时无用
	CSA_SUB_TYPE_CHONGZHI_RANK = 5,	    --  充值排行
	CSA_SUB_TYPE_CONSUME_RANK = 6,	    --  消费排行
	CSA_SUB_TYPE_KILL_BOSS = 7,	   		--  击杀boss
	CSA_SUB_TYPE_SINGLE_CHARGE = 8,	      --  单笔充值
	CSA_SUB_TYPE_LOGIN_Gift = 9,	      --  登录奖励
	CSA_SUB_TYPE_PERSONAL_PANIC_BUY = 10,	      --  个人抢购
	CSA_SUB_TYPE_SERVER_PANIC_BUY = 11,	      --  全服抢购
	CSA_SUB_TYPE_ZHANCHANG_FANBEI = 12,	      --  战场翻倍
	CSA_SUB_TYPE_CHARGE_REWARD_DOUBLE = 13,	      --  充值双倍返利
	CSA_SUB_TYPE_BOSS = 14,					-- 合服boss
	-- CSA_SUB_TYPE_MINGZHUZHENBA = 15,		-- 盟主争霸
	CSA_SUB_TYPE_TOUZI = 15, 				--合服投资
	CSA_SUB_TYPE_JIJIN = 16, 				--和服基金
	CSA_SUB_TYPE_MAX = 17,
}

CHANGE_MODE_TASK_TYPE = {
    INVALID = 0,
    GATHER = 1,            					--采集物
    TALK_TO_NPC = 2,            			-- NPC
  }


CSA_BOSS_OPERA_TYPE = {
	CSA_BOSS_OPERA_TYPE_ENTER  =  0,	--进入boss场景
	CSA_BOSS_OPERA_TYPE_INFO_REQ  =  1,	--请求boss信息
	CSA_BOSS_OPERA_TYPE_RANK_REQ  =  2,	--请求排行榜信息
	CSA_BOSS_OPERA_TYPE_ROLE_INFO_REQ = 3, --请求个人信息
}

SHENGXINGZHULI_SYSTEM_TYPE = {
  SHENGXINGZHULI_SYSTEM_TYPE_MOUNT = 0,      -- 坐骑系统
  SHENGXINGZHULI_SYSTEM_TYPE_WING = 1,      -- 翅膀
  SHENGXINGZHULI_SYSTEM_TYPE_FOOT_PRINT = 6,    -- 足迹
  SHENGXINGZHULI_SYSTEM_TYPE_HALO = 3,      -- 光环
  SHENGXINGZHULI_SYSTEM_TYPE_FIGHT_MOUNT = 5,    -- 战骑
  SHENGXINGZHULI_SYSTEM_TYPE_SHENGONG = 2,    -- 神弓
  SHENGXINGZHULI_SYSTEM_TYPE_PIFENG = 4,      -- 披风(神翼进阶)

  SHENGXINGZHULI_SYSTEM_TYPE_COUNT = 7,
}

CSA_LOGIN_GIFT_OPERA = {
	CSA_LOGIN_GIFT_OPERA_FETCH_COMMON_REWARD = 0,				-- 普通奖励
	CSA_LOGIN_GIFT_OPERA_FETCH_VIP_REWARD = 1,					-- vip奖励
	CSA_LOGIN_GIFT_OPERA_FETCH_ACCUMULATE_REWARD = 2,			-- 累计登录奖励

	CSA_LOGIN_GIFT_OPERA_MAX,
}

NOTIFY_REASON_TYPE =
    {
      JINGJIE_LEVEL_CHANGE = 0,       					-- 头衔境界等级改变
    }

MODEL_TYPE = {
	[1] = "Weapon",
	[2] = "Wing",
	[3] = "Mount",
}

LogActTypeCustom = {
	SendProtocol = "False",
	DecodeProtocol = "False"
}

CameraType = {
	Free = 0,		-- 自由视角
	Fixed = 1,		-- 固定视角
}

-- 创建角色返回
RET_TYPE = {
	RESULT_TYPE_SUCC = 0,          -- 成功
	RESULT_TYPE_NO_SPACE = -1,        -- 拥有角色太多，没有空间再创角色
	RESULT_TYPE_EXIST_NAME = -2,      -- 重名
	RESULT_TYPE_NAME_INVALID = -3,      -- 名字不合法
	RESULT_TYPE_SERVER_LIMIT = -4,      -- 服务器禁止创建角色
	RESULT_TYPE_SERVER_TIMELIMIT = -5,    -- 服务器超时了 创建角色
}

--组队塔防
TEAM_TOWERDEFEND_ATTRTYPE = {
	TEAM_TOWERDEFEND_ATTRTYPE_INVALID = 0,
	TEAM_TOWERDEFEND_ATTRTYPE_GONGJI = 1,									-- 加攻 朱雀
	TEAM_TOWERDEFEND_ATTRTYPE_FANGYU = 2,									-- 加防 玄武
	TEAM_TOWERDEFEND_ATTRTYPE_ASSIST = 3,									-- 辅助 青龙
	TEAM_TOWERDEFEND_ATTRTYPE_MAX = 4,
}

TIP_COLOR_IMAGE = {
	[0] = 0,
	[1] = 1,
	[2] = 1,
	[5] = 2,
	[13] = 6,
	[12] = 7,
	[9] = 0,
	[11] = 11,
	[14] = 1,
}

TIP_COLOR_TITLE = {
	[0] = 0,
	[1] = 1,
	[2] = 1,
	[5] = 2,
	[13] = 6,
	[12] = 7,
	[9] = 5,
	[11] = 11,
	[14] = 14,
}

--职业对应预制体模型下标
PROF_ROLE = {
	[1] = 1,
	[2] = 1,
	[3] = 2,
	[4] = 2,
}

--限时礼包活动
RA_TIMELIMIT_GIFT_OPERA_TYPE = {
    RA_TIMELIMIT_GIFT_OPERA_TYPE_QUERY_INFO = 0,			--请求物品的信息
    RA_TIMELIMIT_GIFT_OPERA_TYPE_FETCH_REWARD = 1,			--请求领取物品的索引
    RA_TIMELIMIT_GIFT_OPERA_TYPE_MAX = 2,
 }

 --限时礼包领取操作
RA_TIMELIMIT_GIFT_FETCH_TYPE = {
	RA_TIMELIMIT_GIFT_FETCH_FIRST = 0,			--第一份奖励领取操作
	RA_TIMELIMIT_GIFT_FETCH_SECOND = 1,			--第二份奖励领取操作
 }

 --限时豪礼活动
RA_TIMELIMIT_BIG_GIFT_OPERA_TYPE = {
    RA_TIMELIMIT_BIG_GIFT_OPERA_TYPE_QUERY_INFO = 0,			--请求物品的信息
    RA_TIMELIMIT_BIG_GIFT_OPERA_TYPE_QUERY_BUY = 1,			    --请求购买的信息
 }

  --普天同庆活动
RA_REST_DOUBLE_CHATGE_OPERA_TYPE = {
    RA_RESET_DOUBLE_CHONGZHI_OPERA_TYPE_INFO = 0,			--请求物品的信息
    RA_RESET_DOUBLE_CHONGZHI_OPERA_TYPE_RESET = 1,			    --请求购买的信息
 }


-- 呆萌渠道聊天类型
DM_CHANNEL_TYPE = {
	[CHANNEL_TYPE.WORLD] = 1,
	[CHANNEL_TYPE.CAMP] = 2,
	[CHANNEL_TYPE.GUILD] = 3,
	[CHANNEL_TYPE.TEAM] = 4,
	[CHANNEL_TYPE.PRIVATE] = 5,
}

 --限时大反馈活动请求
RA_LIMIT_TIME_REBATE_OPERA_TYPE = {
    RA_LIMIT_TIME_REBATE_OPERA_TYPE_INFO = 0,     			--请求信息
    RA_LIMIT_TIME_REBATE_OPERA_TYPE_FETCH_REWARD = 1,		--请求领取信息
}

TIME_FORMAT_TYPE = {
	DAY_HOUR_MIN_HOLD_TWO = 1,								--天时分保留两位
	DAY_HOUR_HOLD_TWO = 2,									--天时保留两位
	DAY_HOLD_TWO_HOUR = 3,									--天保留两位时
	DAY_HOUR = 4,											--天时
	DAY_HOLD_TWO_HOUR_MIN = 5,								--天保留两位时分
	HOUR_MIN = 6,											--时分
}

CIRCULATION_CHONGZHI_OPERA_TYPE =
{
    CIRCULATION_CHONGZHI_OPERA_TYPE_QUERY_INFO = 0, -- 请求活动信息
    CIRCULATION_CHONGZHI_OPEAR_TYPE_FETCH_REWARD = 1, -- 获取奖励

    CIRCULATION_CHONGZHI_OPERA_TYPE_MAX = 2
}

ATTACK_MODE = {
	FREE = 0,			-- 自由
	PEACE = 1,			-- 和平
	TEAM = 2,			-- 组队
	GUILD = 3,			-- 仙盟
	ALL = 4,			-- 全体
}

-- 名将请求类型 天神
GREATE_SOLDIER_REQ_TYPE =
{
	GREATE_SOLDIER_REQ_TYPE_INFO = 0,						-- 请求所有信息
	GREATE_SOLDIER_REQ_TYPE_LEVEL_UP = 1,					-- 升阶请求，param1是seq
	GREATE_SOLDIER_REQ_TYPE_BIANSHEN = 2,					-- 变身请求
	GREATE_SOLDIER_REQ_TYPE_WASH = 3,						-- 洗练请求，param1是seq
	GREATE_SOLDIER_REQ_TYPE_PUTON = 4,						-- 装上将位请求，param1是名将seq，param2是将位槽seq
	GREATE_SOLDIER_REQ_TYPE_PUTOFF = 5,						-- 卸下将位请求，param1是将位槽seq
	GREATE_SOLDIER_REQ_TYPE_SLOT_LEVEL_UP = 6,				-- 升级将位请求，param1是将位槽seq,param2是次数
	GREATE_SOLDIER_REQ_TYPE_DRAW = 7,						-- 抽奖请求，param1是抽奖类型 param2是否自动购买 是:否 1:0
	GRAETE_SOLDIER_REQ_TYPE_CONFIRM_WASH = 8,				-- 确认洗练结果，param1是seq
	GRAETE_SOLDIER_REQ_TYPE_WASH_ATTR = 9,					-- 洗练属性请求，param1是seq
	GRAETE_SOLDIER_REQ_TYPE_BIANSHEN_TRIAL = 10,			-- 变身体验请求，param1是seq
	GRAETE_SOLDIER_REQ_TYPE_POTENTIAL_LEVEL_UP = 11,	    -- 潜能升级请求
	GREATE_SOLDIER_REQ_TYPE_MAIN_SLOT = 12,                 -- 设置出战名将，param1是seq
    GREATE_SOLDIER_REQ_TYPE_GUANGWU_LEVEL_UP = 13,          -- 光武升级请求，param1是seq
    GREATE_SOLDIER_REQ_TYPE_SHENWU_LEVEL_UP = 14,			-- 法阵升级请求

	GREATE_SOLDIER_REQ_TYPE_FETCH_SPCEIAL_IMG_REWARD = 15, 	-- 拿取特殊形象奖励 param_1是领取 特殊形象id
	GREATE_SOLDIER_REQ_TYPE_BUY_SPECIAL_SOLDIER = 16, 		-- 购买特殊名将 param_1是购买 特殊形象id
	GREATE_SOLDIER_REQ_TYPE_ACTIVE_SPECIAL_IMG = 17,		-- 激活特殊形象 param_1是激活 特殊形象id
	GREATE_SOLDIER_REQ_TYPE_UPLEVEL_SPECIAL_IMG = 18,		-- 特殊形象 param_1是特殊形象id
	GREATE_SOLDIER_REQ_TYPE_USE_SPECIAL_IMG = 19,			-- 使用/取消特殊形象 param_1 0为取消, 否则发送 特殊形象id
	GREATE_SOLDIER_REQ_TYPE_SMALL_GOAL_BUY = 26,			-- 购买小目标
	GREATE_SOLDIER_REQ_TYPE_SMALL_GOAL_FETCH = 27,			-- 拿取小目标奖励

	GREATE_SOLDIER_REQ_TYPE_EQUIP_SLOT_LEVEL_UP = 21,		-- 装备格子升级请求，param_1 = 名将索引，param2 = 装备索引
	GREATE_SOLDIER_REQ_TYPE_EQUIP_SLOT_PUT_ON = 22,			-- 穿上/替换装备请求，param_1 = 名将索引，param2 =  背包索引
	GREATE_SOLDIER_REQ_TYPE_EQUIP_SLOT_TAKE_OFF = 23,		-- 脱下装备请求，param_1 = 名将索引，param2 = 装备索引
	GREATE_SOLDIER_REQ_TYPE_DECOMPOSE_EQUIP = 24,			-- 分解装备请求，param_1 = 背包格子索引
	GREATE_SOLDIER_REQ_TYPE_SORT_VIRTUAL_BAG = 25,			-- 整理装备虚拟背包请求

	GREATE_SOLDIER_REQ_TYPE_MAX,
}

SHENQI_SC_INFO_TYPE =										-- 神器下发信息类型
{
	SHENQI_SC_INFO_TYPE_SHENBING = 0,						-- 神兵
	SHENQI_SC_INFO_TYPE_BAOJIA = 1,							-- 宝甲
	SHENQI_SC_INFO_TYPE_MAX = 2,
}

TALENT_OPERATE_TYPE = {
	TALENT_OPERATE_TYPE_INFO = 0,
	TALENT_OPERATE_TYPE_CHOUJIANG_INFO = 1,
	TALENT_OPERATE_TYPE_CHOUJIANG_REFRESH = 2,				-- param1:0刷新一次/1刷新全部
	TALENT_OPERATE_TYPE_AWAKE = 3,							-- param1:抽奖格子索引
	TALENT_OPERATE_TYPE_PUTON = 4,							-- param1:天赋类型, param2:天赋格子序号, param3:背包格子索引
	TALENT_OPERATE_TYPE_PUTOFF = 5,							-- param1:天赋类型, param2:天赋格子序号
	TALENT_OPERATE_TYPE_SKILL_UPLEVEL = 6,					-- param1:天赋类型, param2:天赋格子序号
	TALENT_OPERATE_TYPE_SKILL_FOCUS = 7,					-- param1:技能id
	TALENT_OPERATE_TYPE_SKILL_CANCLE_FOCUS = 8,				-- param1:技能id
}

TALENT_SKILL_TYPE = {
  TALENT_SKILL_TYPE_0 = 0,  	--气血
  TALENT_SKILL_TYPE_1 = 1,      --攻击
  TALENT_SKILL_TYPE_2 = 2,      --防御
  TALENT_SKILL_TYPE_3 = 3,      --命中
  TALENT_SKILL_TYPE_4 = 4,      --闪避
  TALENT_SKILL_TYPE_5 = 5,      --暴击
  TALENT_SKILL_TYPE_6 = 6,      --抗暴
  TALENT_SKILL_TYPE_7 = 7,      --固定增伤
  TALENT_SKILL_TYPE_8 = 8,      --固定免伤
  TALENT_SKILL_TYPE_9 = 9,      --对应系统进阶属性百分比
  TALENT_SKILL_TYPE_10 = 10,      --本天赋页气血百分比+固定值
  TALENT_SKILL_TYPE_11 = 11,      --本天赋页攻击百分比+固定值
  TALENT_SKILL_TYPE_12 = 12,      --本天赋页防御百分比+固定值
  TALENT_SKILL_TYPE_13 = 13,      --本天赋页命中百分比+固定值
  TALENT_SKILL_TYPE_14 = 14,      --本天赋页闪避百分比+固定值
  TALENT_SKILL_TYPE_15 = 15,      --本天赋页暴击百分比+固定值
  TALENT_SKILL_TYPE_16 = 16,      --本天赋页抗暴百分比+固定值
  TALENT_SKILL_TYPE_17 = 17,      --本天赋页固定增伤百分比+固定值
  TALENT_SKILL_TYPE_18 = 18,      --本天赋页固定免伤百分比+固定值
  TALENT_SKILL_TYPE_19 = 19,      --坐骑终极技能
  TALENT_SKILL_TYPE_20 = 20,      --羽翼终极技能
  TALENT_SKILL_TYPE_21 = 21,      --光环终极技能
  TALENT_SKILL_TYPE_22 = 22,      --魔骑终极技能
  TALENT_SKILL_TYPE_23 = 23,      --神弓终极技能
  TALENT_SKILL_TYPE_24 = 24,      --神翼终极技能
  TALENT_SKILL_TYPE_25 = 25,      --足记终极技能
}

TALENT_TYPE = {
	TALENT_MOUNT = 0,			--坐骑
	TALENT_WING = 1,			--羽翼
	TALENT_HALO = 2,			--光环
	TALENT_FIGHTMOUNT = 3,		--魔骑
	TALENT_SHENGGONG = 4,		--神弓
	TALENT_SHENYI = 5,			--神翼
	TALENT_FOOTPRINT = 6,		--足记
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
	SHENQI_OPERA_REQ_TYPE_SHENGBING_TEXIAO_ACTIVE = 10,		-- 激活神兵特效 param_1 神兵id
	SHENQI_OPERA_REQ_TYPE_BaoJia_TEXIAO_ACTIVE = 11,		-- 激活宝甲特效 param_1 宝甲id


	SHENQI_OPERA_REQ_TYPE_MAX = 12,
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
	QINGYAN_OPREA_TYPE_BUY_TIME_LIMIT_GIFT = 12,			-- 购买限时礼包

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

-- 跨服修罗塔日志
CROSS_XIULUO_TOWER_DROP_LOG_TYPE = {
  CROSS_XIULUO_TOWER_DROP_LOG_TYPE_MONSTER = 1,    			-- 怪物掉落
  CROSS_XIULUO_TOWER_DROP_LOG_TYPE_GOLD_BOX = 2,   			-- 金箱子掉落

  CROSS_XIULUO_TOWER_DROP_LOG_TYPE_MAX = 3,
}

RoleStatus = {
	ROLE_STATUS_GATHER = 1,                      -- 采集状态
	ROLE_STATUS_REST = 2,                      -- 打坐休息状态
}

GUILD_WAR_TYPE = {
	TYPE_INFO_REQ = 0,						-- 请求公会争霸奖励信息
	TYPE_FETCH_REQ = 1,						-- 领取奖励
}

GUILD_SOS_TYPE = {
  GUILD_SOS_TYPE_DEFAULT = 0,                    	-- 默认求救
  GUILD_SOS_TYPE_HUSONG = 1,                    	-- 护送求救
  GUILD_SOS_TYPE_HUSONG_BE_ATTACK = 2,             	-- 护送求救 - 被攻击
  GUILD_SOS_TYPE_GUILD_BATTLE = 3,                	-- 公会争霸
  GUILD_SOS_TYPE_GONGCHENGZHAN = 4,                	-- 攻城战
}

CROSS_TIANJIANG_BOSS_OPER_TYPE = {
	CROSS_TIANJIANG_BOSS_OPER_TYPE_INFO = 0,			-- 请求天将boss个人信息
	CROSS_TIANJIANG_BOSS_OPER_TYPE_BUY_ENTER_COUNT = 1,	-- 请求购买天将boss进入次数
	CROSS_TIANJIANG_BOSS_OPER_TYPE_BOSS_INFO = 2,		-- 请求boss信息

	CROSS_TIANJIANG_BOSS_OPER_TYPE_MAX = 3,
}

CROSS_SHENWU_BOSS_OPER_TYPE = {
	CROSS_SHENWU_BOSS_OPER_TYPE_INFO  = 0,				-- 请求神武boss个人信息
	CROSS_SHENWU_BOSS_OPER_TYPE_BUY_WEARY_LIMIT = 1,	-- 请求购买神武boss进入次数
	CROSS_SHENWU_BOSS_OPER_TYPE_BOSS_INFO = 2,			-- 请求boss信息

	CROSS_TIANJIANG_BOSS_OPER_TYPE_MAX = 3,
}

BABY_BOSS_OPERATE_TYPE = {
	BABY_BOSS_INFO_REQ = 0,							-- 请求宝宝boss信息
	BABY_BOSS_ROLE_INFO_REQ = 1,					-- 请求人物相关信息
	BABY_BOSS_SCENE_ENTER_REQ = 2,					-- 请求进入宝宝boss
	BABY_BOSS_SCENE_LEAVE_REQ = 3,					-- 请求离开宝宝boss副本
}

NEW_TOUZIJIHUA_OPERATE_TYPE = {
	NEW_TOUZIJIHUA_OPERATE_BUY = 0,					--购买月卡投资
	NEW_TOUZIJIHUA_OPERATE_FETCH = 1,				--获取月卡奖励
	NEW_TOUZIJIHUA_OPERATE_FIRST = 2,				--获取月卡立返
	NEW_TOUZIJIHUA_OPERATE_VIP_FETCH = 3,
	NEW_TOUZIJIHUA_OPERATE_FOUNDATION_FETCH = 4,	--领取成长基金
}

DISPLAY_TYPE = {ALL_TITLE = 0,XIAN_NV = 1, MOUNT = 2, WING = 3, FASHION = 4, HALO = 5, SPIRIT = 6, FIGHT_MOUNT = 7, SHENGONG = 8, SHENYI = 9,
				SPIRIT_HALO = 10, SPIRIT_FAZHEN = 11, NPC = 12, BUBBLE = 13, ZHIBAO = 14, MONSTER = 15, ROLE = 16, DAILY_CHARGE = 17,
				TITLE = 18, XUN_ZHANG = 19, ROLE_WING = 20, WEAPON = 21, SHENGONG_WEAPON = 22, FORGE = 23, GATHER = 24, STONE = 25,
				SHEN_BING = 26, BOX = 27, HUNQI = 28, ZEROGIFT = 29, FOOTPRINT = 30, TASKDIALOG = 31, CLOAK = 32, COUPLE_HALO = 33, GENERAL = 34,
				HEAD_FRAME = 35, MULTI_MOUNT = 36, TOU_SHI = 37, YAO_SHI = 38, MIAN_SHI = 39, QIN_LIN_BI = 40, SUPER_BABY = 41}
--疯狂摇钱树
RA_SHAKEMONEY_OPERA_TYPE = {
	RA_SHAKEMONEY_OPERA_TYPE_QUERY_INFO = 0,				-- 请求信息
	RA_SHAKEMONEY_OPERA_TYPE_FETCH_GOLD = 1,				-- 领取元宝
	RA_SHAKEMONEY_OPERA_TYPE_MAX = 2,
}

SUOYAOTA_FB_OPERA_REQ_TYPE =
{
	SUOYAOTA_FB_OPERA_REQ_TYPE_ALL_INFO = 0,				--请求信息
	SUOYAOTA_FB_OPERA_REQ_TYPE_BUY_POWER = 1,					--购买进体力 param_1 购买次数
	SUOYAOTA_FB_OPERA_REQ_TYPE_FETCH_STAR_REWARD = 2,			--拿取星级奖励 param_1:副本类型  param_2:配置表seq
	SUOYAOTA_FB_OPERA_REQ_TYPE_SAODANG = 3,						--扫荡 param_1:副本类型 param_2:层 param_3:关卡
	SUOYAOTA_FB_OPERA_REQ_TYPE_TITLE = 4,						--称号

	SUOYAOTA_FB_OPERA_REQ_TYPE_MAX
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

CSA_FOUNDATION_OPERA = {
	CSA_FOUNDATION_INFO_REQ = 0,	-- 请求信息
	CSA_FOUNDATION_FETCH_REQ = 1,	-- 领取奖励，param_2填奖励索引
}

CSA_SUB_GONGCHENGZHAN = {
	CSA_SUB_TYPE_FOUNDATION = 3,    --攻城战子活动号
}


RA_CLOUDPURCHASE_OPERA_TYPE = {
	RA_CLOUDPURCHASE_OPERA_TYPE_INFO = 0,      --请求所有信息（所有物品购买次数、是否开奖）
    RA_CLOUDPURCHASE_OPERA_TYPE_BUY = 1,        --购买请求， param1:购买seq param2:购买次数
    RA_CLOUDPURCHASE_OPERA_TYPE_BUY_RECORD = 2,      --购买记录
    RA_CLOUDPURCHASE_OPERA_TYPE_CONVERT = 3,      --兑换请求(param1: seq, param2: 兑换次数)
    RA_CLOUDPURCHASE_OPERA_TYPE_CONVERT_INFO = 4,    --兑换信息（积分、兑换相关的信息）
    RA_CLOUDPURCHASE_OPERA_TYPE_SERVER_RECORD_INFO = 5,  --全服记录（中奖信息）

}


GUILD_FIRE_ADD_TYPE = {									--仙盟篝火请求
	 GUILD_FIRE_ADD_TYPE_MUCAI = 0,
	 GUILD_FIRE_ADD_TYPE_FAKER_GATHER = 1,
}

TIPSEVENTTYPES = {
	SPECIAL = 0,
	COMMON = 1
}

AUTHORITY_TYPE = {
	INVALID = 0, 									-- 无任何权限
	GUIDER = 1, 									-- 新手指导员
	GM = 2, 										-- GM
	TEST = 3, 										-- 测试账号（内部号）
}

--这里面存放对应的版本活动ID号
FESTIVAL_ACTIVITY_ID = {
	--格式 	ACTIVITY_TYPE.KF_FISHING = 3087
	ACTIVITY_TYPE_BEIBIANSHEN = 2107,
	ACTIVITY_TYPE_BIANSHEN = 2108,
	ACTIVITY_TYPE_EQUIPMENT = 2215,
	RAND_ACTIVITY_TYPE_VERSIONS_CONTINUE_CHARGE = 2219,
	RAND_ACTIVITY_TYPE_HUANLE_YAOJIANG2 = 2221,
	RAND_ACTIVITY_TYPE_ITEM_COLLECTION_2 = 2216,

	RAND_ACTIVITY_TYPE_VERSIONS_GRAND_TOTAL_CHARGE = 2218,	-- 版本累计充值
	RAND_ACTIVITY_TYPE_TOTAL_CHARGE_FIVE = 2220,			-- 吉祥三宝
	RAND_ACTIVITY_TYPE_EXPENSE_NICE_GIFT = 2217,				-- 消费好礼

	--国庆种树
	RAND_ACTIVITY_TYPE_PRINT_TREE = 2234,
	RAND_ACTIVITY_TYPE_FANGFEI_QIQIU = 2235,

	--充值、消费排行
	RAND_ACTIVITY_TYPE_CHONGZHI_RANK = 2237,
	RAND_ACTIVITY_TYPE_XIAOFEI_RANK = 2238,

	RAND_ACTIVITY_TYPE_LANDINGF_REWARD = 2239,               --登陆奖励
	RAND_ACTIVITY_TYPE_CRAZY_GIFT = 2240,                   -- 疯狂礼包

}

RAND_ACTIVITY_TYPE_UPGRADE = {
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MOUNT_UPGRADE] = 1,             --坐骑
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WING_UPGRADE] = 2,			  --羽翼
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HALO_UPGRADE_NEW] = 3,		  --光环
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FOOTPRINT_UPGRADE_NEW] = 4,     --足迹
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIGHTMOUNT_UPGRADE_NEW] = 5,	  --战骑
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENGONG_UPGRADE_NEW] = 6,	  --神弓
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENYI_UPGRADE_NEW] = 7,	      --神翼
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_YAOSHI_UPGRADE] = 8,			  --腰饰
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOUSHI_UPGRADE] = 9,			  --头饰
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QILINBI_UPGRADE] = 10,			  --麒麟臂
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MASK_UPGRADE] = 11,			  --面饰
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIANBAO_UPGRADE] = 12,			  --仙宝
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGZHU_UPGRADE] = 13,			  --灵珠
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGCHONG_UPGRADE] = 14,			  --灵珠
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGGONG_UPGRADE] = 15,			  --灵珠
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGQI_UPGRADE] = 16,			  --灵珠
}

RA_EXPENSE_NICE_GIFT_OPERA_TYPE = {
	RA_EXPENSE_NICE_GIFT_OPERA_TYPE_QUERY_INFO = 0,    -- 请求活动信息
    RA_EXPENSE_NICE_GIFT_OPERA_TYPE_YAO = 1,        -- 摇奖
    RA_EXPENSE_NICE_GIFT_OPERA_TYPE_FETCH_TOTAL_REWARD = 2,	-- 领取累计消费奖励
    RA_EXPENSE_NICE_GIFT_OPERA_TYPE_FEICH_REWARD = 3,
}

TIME_LIMIT_TITLE_PANEL = {
	GENERAL = "general",
	BABY = "baby",
	LITTLEPET = "littlepet",
	RUNE = "rune",
	SPECIALSPIRIT = "specialspirit",
	Goddess = "goddess",
}

TIME_LIMIT_TITLE_CALL_TYPE = {
	BUY = 1,					--直接购买
	FETCH = 2,					--领取
}

ONLINE_ACTIVITY_ID = {
    --单笔充值
	RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_0 = 2225,
	RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_1 = 2226,
	RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_2 = 2227,

	--累计充值
	RAND_ACTIVITY_TYPE_OFFLINE_TOTAL_CHARGE_0 = 2228,
	RAND_ACTIVITY_TYPE_OFFLINE_TOTAL_CHARGE_1 = 2229,
	RAND_ACTIVITY_TYPE_OFFLINE_TOTAL_CHARGE_2 = 2230,

	-- 登录奖励
	RAND_ACTIVITY_TYPE_LOGIN_GIFT_0 = 2231,
  	RAND_ACTIVITY_TYPE_LOGIN_GIFT_1 = 2232,
  	RAND_ACTIVITY_TYPE_LOGIN_GIFT_2 = 2233,
}

RA_LOGIN_GIFT_OPERA_TYPE = {
    RA_LOGIN_GIFT_OPERA_TYPE_INFO = 0,                                	-- 获取信息
    RA_LOGIN_GIFT_OPERA_TYPE_FETCH_COMMON_REWARD = 1,                	-- 获取普通奖励
    RA_LOGIN_GIFT_OPERA_TYPE_FETCH_VIP_REWARD = 2,                   	-- 获取VIP奖励
    RA_LOGIN_GIFT_OPERA_TYPE_FETCH_ACCUMULATE_REWARD = 3,          		-- 获取累计奖励
}

RA_PLANTING_TREE_OPERA_TYPE = {
	RA_PLANTING_TREE_OPERA_TYPE_RANK_INFO = 0,				-- 请求排行榜信息	param_1 排行榜类型，见下面的枚举
	RA_PLANTING_TREE_OPERA_TYPE_TREE_INFO = 1,				-- 请求一颗树的信息 param_1 场景id，param_2 obj_id
	RA_PLANTING_TREE_OPERA_MINI_TYPE_MAP_INFO = 2,			-- 请求小地图树的信息	param_1 场景id
}

--一个活动号对应两个活动
ONE_ID_DOUBLE_ACTIVITY = {
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PRINT_TREE] = 2235,
}

RA_PLANTING_TREE_RANK_TYPE = {
	PERSON_RANK_TYPE_PLANTING_TREE_PLANTING = 69, -- 打气球
	PERSON_RANK_TYPE_PLANTING_TREE_WATERING = 70, -- 吹气球
}

RA_EXPENSE_NICE_GIFT2_OPERA_TYPE = {
	RA_EXPENSE_NICE_GIFT2_OPERA_TYPE_QUERY_INFO = 0,		-- 请求活动信息
	RA_EXPENSE_NICE_GIFT2_OPERA_TYPE_YAO = 1,					-- 摇奖
	RA_EXPENSE_NICE_GIFT2_OPERA_TYPE_FETCH_TOTAL_REWARD = 2,	-- 领取累计消费奖励
	RA_EXPENSE_NICE_GIFT2_OPERA_TYPE_FETCH_REWARD = 3,			-- 发放奖励

	RA_EXPENSE_NICE_GIFT2_OPERA_TYPE_MAX = 4,
}

--登录活跃有礼
RA_LOGIN_ACTIVE_GIFT_REQ_TYPE = {
	RA_LOGIN_ACTIVE_GIFT_REQ_TYPE_INFO = 0,			--请求所有信息
	RA_LOGIN_ACTIVE_GIFT_REQ_TYPE_FETCH = 1,			--请求拿取奖励 参数1：礼包类型 参数2：礼包seq

	RA_LOGIN_ACTIVE_GIFT_REQ_TYPE_MAX = 2 ,
}