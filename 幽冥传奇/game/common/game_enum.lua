-----------------------------------------------------
-- 游戏中的枚举
-----------------------------------------------------
GameEnum =
{
	--职业
	ROLE_PROF_1 = 1, 								--战士
	ROLE_PROF_2 = 2, 								--法师
	ROLE_PROF_3 = 3, 								--道士

	--性别
	MALE = 0,										--男性
	FEMALE = 1,										--女性

	--阵营
	ROLE_CAMP_0 = 0, 								--无
	ROLE_CAMP_1 = 1,								--昆仑	女娲
	ROLE_CAMP_2 = 2, 								--蓬莱	伏羲
	ROLE_CAMP_3 = 3, 								--苍穹	蚩尤

	--物品颜色
	ITEM_COLOR_WHITE = 0,							-- 白
	ITEM_COLOR_GREEN = 1,							-- 绿
	ITEM_COLOR_BLUE = 2,							-- 蓝
	ITEM_COLOR_PURPLE = 3,							-- 紫
	ITEM_COLOR_ORANGE = 4,							-- 橙
	ITEM_COLOR_RED = 5,								-- 红
	ITEM_COLOR_GLOD = 6,							-- 金

	--装备品质颜色
	EQUIP_COLOR_GREEN = 0,							-- 绿
	EQUIP_COLOR_BLUE = 1,							-- 蓝
	EQUIP_COLOR_PURPLE = 2,							-- 紫
	EQUIP_COLOR_ORANGE = 3,							-- 橙
	EQUIP_COLOR_RED = 4,							-- 红
	EQUIP_COLOR_TEMP = 5,							-- 金

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

	--装备类型
	EQUIP_TYPE_TOUKUI = 100,						--头盔
	EQUIP_TYPE_YIFU = 101,							--衣服
	EQUIP_TYPE_YAODAI = 102,						--腰带
	EQUIP_TYPE_HUTUI = 103,							--护腿
	EQUIP_TYPE_XIEZI = 104,							--鞋子
	EQUIP_TYPE_HUSHOU = 105,						--护手
	EQUIP_TYPE_XIANGLIAN = 106,						--项链
	EQUIP_TYPE_HUFU = 107,							--护符
	EQUIP_TYPE_WUQI = 108,							--武器 剑 刺 笔 杖
	EQUIP_TYPE_JIEZHI = 109,						--戒指

	EQUIP_TYPE_JINGLING = 201,						-- 精灵
	EQUIP_TYPE_HUNJIE = 202,						-- 婚戒

	JINJIE_TYPE_MIN = 400,							-- 进阶装备最小值

	E_TYPE_MOUNT_TOUKUI = 400,						-- 坐骑头盔
	E_TYPE_MOUNT_YIFU = 401,						-- 坐骑衣服
	E_TYPE_MOUNT_HUTUI = 402,						-- 坐骑护腿
	E_TYPE_MOUNT_XIEZI = 403,						-- 坐骑鞋子

	E_TYPE_FLYUP_TOUKUI = 450,						-- 飞升头盔
	E_TYPE_FLYUP_YIFU = 451,						-- 飞升衣服
	E_TYPE_FLYUP_HUTUI = 452,						-- 飞升护腿
	E_TYPE_FLYUP_XIEZI = 453,						-- 飞升鞋子

	E_TYPE_WING_TOUKUI = 500,						-- 羽翼头盔
	E_TYPE_WING_YIFU = 501,							-- 羽翼衣服
	E_TYPE_WING_HUTUI = 502,						-- 羽翼护腿
	E_TYPE_WING_XIEZI = 503,						-- 羽翼鞋子

	E_TYPE_SHENBING_TOUKUI = 550,					-- 神兵头盔
	E_TYPE_SHENBING_YIFU = 551,						-- 神兵衣服
	E_TYPE_SHENBING_HUTUI = 552,					-- 神兵护腿
	E_TYPE_SHENBING_XIEZI = 553,					-- 神兵鞋子

	E_TYPE_FAZHEN_TOUKUI = 600,						-- 法阵头盔
	E_TYPE_FAZHEN_YIFU = 601,						-- 法阵衣服
	E_TYPE_FAZHEN_HUTUI = 602,						-- 法阵护腿
	E_TYPE_FAZHEN_XIEZI = 603,						-- 法阵鞋子

	E_TYPE_FOOTPRINT_TOUKUI = 650,					-- 足迹头盔
	E_TYPE_FOOTPRINT_YIFU = 651,					-- 足迹衣服
	E_TYPE_FOOTPRINT_HUTUI = 652,					-- 足迹护腿
	E_TYPE_FOOTPRINT_XIEZI = 653,					-- 足迹鞋子

	E_TYPE_FASHION_TOUKUI = 700,					-- 时装头盔
	E_TYPE_FASHION_YIFU = 701,						-- 时装衣服
	E_TYPE_FASHION_HUTUI = 702,						-- 时装护腿
	E_TYPE_FASHION_XIEZI = 707,						-- 时装鞋子

	E_TYPE_FABAO_TOUKUI = 750,						-- 法宝头盔
	E_TYPE_FABAO_YIFU = 751,						-- 法宝衣服
	E_TYPE_FABAO_HUTUI = 752,						-- 法宝护腿
	E_TYPE_FABAO_XIEZI = 753,						-- 法宝鞋子

	E_TYPE_PET_TOUKUI = 800,						-- 宠物头盔
	E_TYPE_PET_YIFU = 801,							-- 宠物衣服
	E_TYPE_PET_HUTUI = 802,							-- 宠物护腿
	E_TYPE_PET_XIEZI = 803,							-- 宠物鞋子

	JINJIE_TYPE_MAX = 899,							-- 进阶装备最大值

	--装备位置索引
	EQUIP_INDEX_TOUKUI = 0,							--头盔
	EQUIP_INDEX_YIFU = 1,							--衣服
	EQUIP_INDEX_YAODAI = 2,							--腰带
	EQUIP_INDEX_HUTUI = 3, 	  						--护腿
	EQUIP_INDEX_XIEZI = 4,  						--鞋子
	EQUIP_INDEX_HUSHOU = 5,							--护手
	EQUIP_INDEX_XIANGLIAN = 6,						--项链
	EQUIP_INDEX_HUFU1 = 7,							--护符1
	EQUIP_INDEX_HUFU2 = 8,							--护符2
	EQUIP_INDEX_WUQI = 9,							--武器
	EQUIP_INDEX_JIEZHI_1 = 10,						--戒指1
	EQUIP_INDEX_JIEZHI_2 = 11,						--戒指2
	EQUIP_INDEX_XUEFU = 12,							--血符
	EQUIP_INDEX_ZHANHUN = 13,						--战魂
	EQUIP_FABAO = 14,								--法宝

	EQUIP_INDEX_JINGLING = 21,						--精灵
	EQUIP_INDEX_HUNJIE = 22,						--婚戒

	-- 宝石类型
	STONE_FANGYU = 1,								-- 防御类型宝石
	STONE_GONGJI = 2,								-- 攻击类型宝石
	STONE_MAXHP = 3,								-- 血气类型的宝石
	STONE_FUJIASHANGHAI = 4,						-- 附加伤害的宝石

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
	FIGHT_CHARINTATTR_TYPE_JIANREN = 11,			--坚韧
	FIGHT_CHARINTATTR_TYPE_MOVE_SPEED = 12,			--移动速度
	FIGHT_CHARINTATTR_TYPE_FUJIA_SHANGHAI = 13,		--附加伤害
	FIGHT_CHARINTATTR_TYPE_DIKANG_SHANGHAI = 14,	--抵抗伤害

	BASE_CHARINTATTR_TYPE_MAXHP = 33,				--基础最大血量
	BASE_CHARINTATTR_TYPE_MAXMP = 34,				--基础最大魔法
	BASE_CHARINTATTR_TYPE_GONGJI = 35,				--基础攻击
	BASE_CHARINTATTR_TYPE_FANGYU = 36,				--基础防御
	BASE_CHARINTATTR_TYPE_MINGZHONG = 37,			--基础命中
	BASE_CHARINTATTR_TYPE_SHANBI = 38,				--基础闪避
	BASE_CHARINTATTR_TYPE_BAOJI = 39,				--基础暴击
	BASE_CHARINTATTR_TYPE_JIANREN = 40,				--基础坚韧
	BASE_CHARINTATTR_TYPE_MOVE_SPEED = 41,			--基础移动速度
	BASE_CHARINTATTR_TYPE_FUJIA_SHANGHAI = 42,		--附加伤害
	BASE_CHARINTATTR_TYPE_DIKANG_SHANGHAI = 43,		--抵抗伤害

	--攻击模式
	ATTACK_MODE_PEACE = 0,							-- 和平模式
	ATTACK_MODE_TEAM = 1,							-- 组队模式
	ATTACK_MODE_GUILD = 2,							-- 帮派模式
	ATTACK_MODE_NAMECOLOR = 3,						-- 善恶模式
	ATTACK_MODE_ALL = 4,							-- 全体模式
	ATTACK_MODE_UNION = 5,							-- 联盟模式
	ATTACK_MODE_CAMP = 6,							-- 阵营模式
	ATTACK_MODE_MAX = 7,

	--名字颜色
	NAME_COLOR_WHITE = 0,							-- 白名
	NAME_COLOR_RED_1 = 1,							-- 红名
	NAME_COLOR_RED_2 = 2,							-- 红名
	NAME_COLOR_RED_3 = 3,							-- 红名
	NAME_COLOR_MAX = 0,

	--NPC任务状态
	TASK_STATUS_NONE = 0,							-- 无
	TASK_STATUS_CAN_ACCEPT = 1,						-- 有可接任务
	TASK_STATUS_COMMIT = 2,							-- 有可提交任务
	TASK_STATUS_ACCEPT_PROCESS = 3,					-- 有未完成的任务

	--数据列表单项改变原因
	DATALIST_CHANGE_REASON_UPDATE = 0,  			-- 更新
	DATALIST_CHANGE_REASON_ADD = 1,					-- 添加
	DATALIST_CHANGE_REASON_REMOVE = 2, 				-- 移除

	MAX_FB_NUM = 60,								-- 副本数量

	-- 购买类型
	CONSUME_TYPE_BIND = 1,							-- 绑定元宝
	CONSUME_TYPE_NOTBIND = 2,						-- 元宝

	-- 商店类型
	SHOP = 1,										-- 商城
	SECRET_SHOP = 2,								-- 神秘商店

	-- 存储类型
	STORAGER_TYPE_BAG = 0,							-- 背包
	STORAGER_TYPE_STORAGER = 1,						-- 仓库
}

MONSTER_TYPE = {
	COMMON = 1,										-- 普通怪
	ELITE = 2,										-- 精英怪
	TOUMU = 3,										-- 头目
	BOSS = 4,										-- boss
	Guarder = 5,									-- 护卫
}

SERVER_TYPE = {
	RECOMMEND = 1,
	ALL = 2,
}

TUMO_NOTIFY_REASON_TYPE = {
	TUMO_NOTIFY_REASON_DEFALUT = 0,					--屠魔默认通知类型
	TUMO_NOTIFY_REASON_ADD_TASK = 1,				--增加任务
	TUMO_NOTIFY_REASON_REMOVE_TASK = 2,				--移除任务
}

--属性丹类型
SHUXINGDAN_TYPE = {
	SHUXINGDAN_TYPE_INVALID = 0,
	SHUXINGDAN_TYPE_SPRITE = 1,						--精灵
	SHUXINGDAN_TYPE_MOUNT = 2,						--坐骑
	SHUXINGDAN_TYPE_XIULIAN = 3,					--修炼
	SHUXINGDAN_TYPE_WING = 4,						--羽翼
	SHUXINGDAN_TYPE_CHANGJIU = 5,					--成就
	SHUXINGDAN_TYPE_SHENGWANG = 6,					--声望
	SHUXINGDAN_TYPE_FLYUP = 7,						--飞升
	SHUXINGDAN_TYPE_SHENBING = 8,					--神兵
	SHUXINGDAN_TYPE_FAZHEN = 9,						--法阵
	SHUXINGDAN_TYPE_FOOTPRINT = 10,					--足迹
	SHUXINGDAN_TYPE_FABAO = 11,						--法宝
	SHUXINGDAN_TYPE_FASHION = 12,					--时装
	SHUXINGDAN_TYPE_XIANNV = 13,					--仙女
	

	SHUXINGDAN_TYPE_MAX = 6,
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

--日常活动类型ID
DAILY_ACTIVITY_TYPE = {
	BI_GUAN = 1, 					-- 闭关修炼
	DUO_BAO_QI_BING = 2, 			-- 夺宝奇兵
	HANG_HUI = 3,					-- 行会闯关
	GONG_CHENG = 4, 				-- 攻城战
	MO_BAI = 5, 					-- 膜拜城主
	WULIN_ZHENG_BA = 6, 			-- 武林争霸
	YUAN_BAO = 7, 					-- 元宝嘉年华
	YA_SONG = 8,					-- 多倍押送
	HANG_HUI_BOSS = 9,				-- 行会BOSS
	ZHEN_YING = 10,					-- 阵营战
	SHI_JIE_BOSS = 11,				-- 世界BOSS

	-- SHUANG_BEI = 3, 				-- 全服双倍
	-- FU_GUI_SHOU = 14, 				-- 富贵兽
	-- ZHEN_YING = 11, 					-- 阵营战
	-- WANG_CHENG = 12, 				-- 王城危机
	-- JU_MO = 13, 						-- 巨魔之巢
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
	SYS_MSG_PUBLIC_NOTICE = 0,						--系统公告，滚屏播放
	SYS_MSG_PERSONAL = 1,	 						--个人系统消息
	SYS_MSG_CENTER = 2,	 							--屏幕中央信息，如击杀、任命等
	SYS_MSG_ROLL = 3,	 							--滚动公告，用于播放重要的游戏内信息，如国战结果等
	SYS_MSG_ONLY_CHAT_WORLD = 4,					--只添加到聊天世界频道
	SYS_MSG_ONLY_CHAT_GUILD = 5,	 				--只添加到聊天仙盟频道
	SYS_MSG_CENTER_AND_ROLL = 6,					--中央显示和滚动同时显示
	SYS_MSG_SPECIAL_SCENE_CENTER_AND_ROLL = 7,		--战场专用滚动和聊天框传闻
};

-- ITEM_CHANGE_TYPE = {
-- 	ITEM_CHANGE_TYPE_SNEAKY_IN = -4,				-- 偷偷的放入 不需要通知玩家获得 当脱下装备和宝石镶嵌惩罚时使用这个
-- 	ITEM_CHANGE_TYPE_CHANGE = -3,	 				-- 发生改变
-- 	ITEM_CHANGE_TYPE_OUT = -2,	 					-- 从背包进入外部
-- 	ITEM_CHANGE_TYPE_IN = -1,	 					-- 从外部进入背包
-- 	-- 0以上表示是从背包/仓库的其他格子里移动过来/去 值表示原来的下标
-- }

RED_PAPER_TYPE = {					--红包类型
	RED_PAPER_TYPE_INVALID = 0,
	RED_PAPER_TYPE_COMMON = 1, 		--普通
	RED_PAPER_TYPE_RAND = 2,		--拼手气
	RED_PAPER_TYPE_GLOBAL = 3,		--全服

	RED_PAPER_TYPE_MAX,
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
	PUT_REASPN_PHASE_AUTO = 31,						-- 阶段本扫荡奖励

	PUT_REASON_LUCKYROLL = 39,						-- 幸运转盘
	PUT_REASON_LUCKYROLL_EXTRAL = 40,			 	-- 幸运转盘额外奖励
	PUT_REASON_LUCKYROLL_CS = 79,			 		-- 合服活动幸运转盘
	PUT_REASON_ZHUXIE_GATHER = 96,					-- 诛邪采集获得
	PUT_REASON_EXP_BOTTLE = 97,						-- 凝聚经验
	PUT_REASON_GCZ_DAILY_REWARD = 98,				-- 攻城战每日奖励
	PUT_REASON_LIFE_SKILL_MAKE= 99,					-- 生活技能制造
	PUT_REASON_PAOHUAN_ROLL = 100,					-- 跑环任务翻牌

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

FLYING_PROCESS_TYPE = {	
	NONE_FLYING = 0,
	FLYING_UP = 1,
	FLYING_IN_MAX_HEIGHT = 2,
	FLYING_DOWN = 3,
}

MOVE_MODE = {
	MOVE_MODE_NORMAL = 0,										--正常
	MOVE_MODE_FLY = 1,											--飞行
	MOVE_MODE_LONGJUMP_UP = 2,									--长跳加速
	MOVE_MODE_LONGJUMP_DOWN = 3,								--长跳减速
	MOVE_MODE_JUMP1 = 4,										--跳跃1
	MOVE_MODE_JUMP2 = 5,										--跳跃2
	MOVE_MODE_MAX = 6
}

MOVE_MODE_FLY_PARAM = {
	MOVE_MODE_FLY_PARAM_INVALID = 0,
	MOVE_MODE_FLY_PARAM_DRAGON = 1,								--龙
	MOVE_MODE_FLY_PARAM_QILIN = 2,								--麒麟
}

SPEAKER_TYPE = {
	SPEAKER_TYPE_LOCAL = 0,								-- 本服喇叭
	SPEAKER_TYPE_CROSS = 1,								-- 跨服传音

	SSPEAKER_TYPE_MAX = 2,
}

CHEST_SHOP_TYPE = {
	CHEST_SHOP_TYPE_EQUIP = 1,						-- 装备类型宝箱抽奖
	CHEST_SHOP_TYPE_JINGLING = 2,					-- 精灵类型宝箱抽奖
}

--(0复活石, 1元宝复活, 2安全复活, 4原地复活)
REALIVE_TYPE = {
	REALIVE_TYPE_FUHUOSHI = 0,						-- 0复活石
	REALIVE_TYPE_HERE_GOLD = 1,						-- 1元宝复活
	REALIVE_TYPE_BACK_HOME = 2,						-- 2安全复活
	REALIVE_TYPE_HERE = 4,							-- 4原地复活
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

-- 卡牌操作
CARD_OPERATE_TYPE = {
	REQ = 0,				-- 请求信息
	INLAY = 1,				-- 镶嵌
	UPLEVEL = 2,			-- 升级
	KEY_UPLEVEL = 3,		-- 一键升级
}

TAOZHUANG_TYPE =
{
	BAOSHI_TAOZHUANG = 0,
	STREGNGTHEN_TAOZHUANG =1
}

TAG_ITEM_LOOT_STYPE_TYPE ={
	ITEM_OWNER_ALL_MEMBER = 0,                     		--所有人都能够拾取
	ITEM_OWNER_SPECIAL_ACTOR = 1,          				--特定一个玩家,已经确定了所有者了
	ITEM_OWNER_WAIT_ROLL = 2,   						--物品等等待Roll，还没Roll
	ITEM_OWNER_IS_WATING_CAPTIN = 3,    				--正在等待队长分配
	ITEM_OWNER_UNDER_ROLLING = 4,        				--物品正当Roll，等待Roll的结果
	ITEM_OWNER_INVALID = 5,     						--出现了错误
}

-- 离线消息类型
-- 由于保存消息的内容是使用二进制，所以每一种消息类型，是有单独的数据格式，系统需要对每一种消息进行组装和解包
MSG_TYPE = 
{
	NO_TYPE = 0,	--无意义的消息
	TXT_MSG = 1,	--普通的文字通知,通常是比较重要的文字通知才需要用到
	UNMARRY = 2,		--离婚
	CHANGE_MONEY = 3,	--改变玩家的金钱，包括银两和元宝，绑定和非绑定
	JOIN_GUILD = 4,	--加入帮派
	LEAVE_GUILD = 5,	--离开帮派
	ADD_INDEX_ITEM = 6, --获得物品(present等)				
	GM_TXT_MSG = 7,	-- GM 系统消息，只有文字内容，因为显示界面和TxtMsg不一样，所以单独一种类型
	SEVER_MASTER = 8,		--与师傅绝关系
	EXPEL_PUPIL  = 9,		--逐出师门
	PUPIL_BONUS	= 10,	--徒弟消费给师傅的红利
	MASTER_GIFT	= 11,	--出师师傅领取礼包奖励
	PUPIL_GIFT		= 12,	--徒弟升级给师徒领取奖励
	DELETE_GUILD   = 13,	--帮派解散
	RETURN_SUGGEST_MSG = 14,	--Gm给玩家直接发送离线消息
	GUILD_DEPOT_MSG = 15,		--从仓库取出物品的离线消息
	AUCTION_ITEM = 16,		--领取竞拍物品
	GIVE_STORE_ITEM = 17,	--有人赠送了商城物品
	PATA_MASTER_AWARD = 18,	--爬塔奖励消息
	CORPS_BATTLE_AWARD = 19,		--战队竞技给奖励
	COMBAT_RANK_AWARD = 20,			--战力竞技奖励
	WHOLE_ACTIVITY_AWARD = 21,		--全民活动奖励
	GIVE_FIRST_SBK_GUILD_AWARD = 22,	--给予首个占领sbk的行会首领奖励
	DEFEND_SBK_THREE_TIMES = 23,		--给予首次守沙成功三次行会首领成功
	DEFEND_SBK_SEC_AWARDS = 24,		--给予首次守沙成功三次行会的副首领奖励
	GIVE_FIRST_COMBINE_SBK_AWARD = 25,		--给予首个合服占领沙巴克的行会首领奖励
	GIVE_FIRST_COMBINE_SEC_SBK_AWARD = 26,		--给予首个合服占领沙巴克的服首领奖励
	GIVE_COMBINE_DEFEND_SBK_AWARD = 27,		--给予首个合服守沙三次的行会首领奖励
	GIVE_COMBINE_DEFEND_SBK_SEC_AWARD = 28,		--给予首个合服守沙三次的行会副首领奖励
	GIVE_COMBINE_ACTIVITY_AWARD = 29,			--合服活动奖励
	HUNDRED_YESTODAY_CONSUME_RANK = 30,			--百服活动昨天消费排名奖励
	SURPRISE_RET = 31,							--惊喜回馈
	SEND_RED_PACKET = 32,						--赠送红包
	SEND_FIRE = 33,							--赠送鞭炮
	LUCK_AWARD = 34,							--春节幸运大抽奖
	FIRE_TOP1 = 35,							--魅力第一
	FESTIVAL_WITH_DRAW = 36,						--提取反馈
	OLD_PLAYER_BACK = 37,						--老友回归
	NOT_ENOUGH_GUILD_COIN = 38,					--行会资金提示
	NEW_SERVER_EIGHT_DAY_ACTIVITY = 39,			--新区八天奖励
	COMBINE_SERVER_CUMULATIVE = 40,				--合区充值累积礼包
	GUILD_RETUEN_RED_PACKET = 41,				--行会红包返回元宝
	SCRIPT_OFFLINE_MSG = 42,					--脚本离线消息
	GIVE_GIFT_TO_PLAYER = 43,					-- 赠送礼物给玩家
}

tagAwardType = {
	qatEquipment=0,             -- 物品或者装备 id:物品ID count:物品数量 quality:物品品质 strong:强化等级 bind:绑定状态 param:物品指针 
	qatXiuwei = 1,	            -- 修为	count:修为值
	qatExp = 2,                	-- 角色经验值 count:经验值 param:如果是任务，这个就填写任务的ID，其他的话填关键的有意义的参数，如果没有就填写0
	qatGuildContribution = 3,	-- 帮派贡献值 count:帮派贡献值
	qatZYContribution = 4,		-- 阵营贡献 count:阵营贡献值
	qatBindMoney = 5,           -- 绑定银两 count:绑定银两值(绑金)
	qatMoney = 6,	            -- 银两	count:银两
	qatBindYb = 7,	            -- 绑定元宝 count:绑定元宝
	qatTitle = 8,	            -- 称谓 count:称谓ID
	qatSkill = 9,	            -- 技能 count:技能ID param:技能等级
	qatZhanhun = 10,	        -- 战魂 count:战魂值
	qatAchievePoint =11,        -- 成就点 count:成就点
	qatRenown=12,                -- 声望  count:声望值
	qatPet =13,                  -- 奖励宠物 
	qatActivity = 14,			-- 奖励活跃度 count:奖励活跃度
	qatYuanbao =15,              -- 元宝 count:元宝
	qatGuildFr = 16,			-- 繁荣度 count:奖励繁荣度值
	qatGuildYs = 17,			-- 玥石 count:帮派玥石值
	qatXPVal=18,				--  XP值	 count:XP值
	qatCombatScore = 19,		-- 竞技积分 count:竞技积分值
	qatAddExp = 20,				-- 按经验配置表加经验 id:奖励库ID count:普通加成率 quality:vip加成率 加成率使用以1000为基数的整形 即n/1000
	qatHonor = 21,				-- 荣誉  (暂时不用)
	qatCircleSoul = 22,			-- 转生灵魄  转生修为
	qatAnger = 23,				-- 怒气
	qatBoss =24,                -- boss
	qatUpgrade = 25,			-- 玩家升级
	qatPetUpgrade = 26,			-- 宝宝升级
	qatGuildCoin = 27,			-- 行会资金
	qatIntimacy = 28,			-- 师徒亲密度
	qatAwardCharm = 29,			--  魅力/帅气
	qatAwardHeroExp= 30,		-- 增加英雄的经验
	qatHeroUpgrade = 31,		-- 增加出战英雄等级
	qatRideStarIndex = 32,		-- 增加坐骑星级
	qatCsKillDevilToken  = 33,	-- //跨服灭魔令数量
	qatMagicPower = 34,			-- 灵力
	qatZhanXun = 35,			-- 战勋
	qatEnergy = 36,				-- 能量
	qatCrystal = 37,			-- 魔晶值 (可用)
	qatSpiritValue = 38,		-- 战功值
	qatGuildScore = 39,			-- 帮派积分值
	qatWardrobeExp = 40,		-- 衣橱经验
	qatHonorVaule = 41,			-- 荣誉值 功勋
	qatMeritVaule = 42,			-- 圣珠结晶
	qatBravePoint = 44,			-- 勇者积分
	qatSpiritShield = 45,		-- 神灵精魄-封神
	qatFuSoulValue = 46,		-- 玉佩碎片
	qatDiamond = 47,			-- 钻晶 宝石结晶
	qatRingCrystal = 48,		-- 特戒结晶
	qatLunHuiValue = 49,		-- 轮回修为
	qatKingKongStone = 50,		-- 金刚石 (可用)
	qatRedDiamonds = 51,		-- 红钻
	qatItemSex = 52,			-- 跟据性别奖励物品 {男,女}
	qatItemJob = 53,			-- 跟据职业奖励物品 {战士, 法师, 道士}
	qatItemSexJob = 54,			-- 跟据性别和职业奖励物品 { 男:{战士, 法师, 道士}, 女:{战士, 法师, 道士}}
	qatZodiacAura = 56,			-- 战将灵力(改为斗笠结晶)
	qatLueiGongExp = 57,		-- 内功经验
	qatStrongStone = 58,		-- 化石	(前端占位)
	qatBossScore = 59,			-- boss积分	(前端占位)
	qatFBTeleportBook = 60,		-- 副本传送卷(前端占位)
	qatRose = 61,				-- (前端占位)
	qatGoldDebris = 62,			-- 碎金		(前端占位)
	qatMaterial = 63,			-- 各种材料	(前端占位)
	qatAllEquip = 64,			-- 各类装备	(前端占位)
	qatXiaoFeiXie = 65,			-- 小飞鞋	(前端占位)
	qatWuLinZhenBaTitle = 66,	-- 武林争霸称号	(前端占位)
	qatRuneEssence = 67,		-- 符文碎片
	qatSecretAreaScore = 68,	-- 秘境积分
	qatReliveTimeCD = 69,		-- 复活倒计时
	qatPkValue =70,				-- pk值
	qatSecretBuyCount =71,		-- 秘境购买次数
	qatCrossReturnItem = 72,	-- 跨服返回物品
	qatTurnCards_1 = 73,		-- 牌面1
	qatTurnCards_2 = 74,		-- 牌面2
	qatTurnCards_3 = 75,		-- 牌面3
	qatPrestigeScore = 76,		-- 威望
	qatPokedexExp = 77,			-- 图鉴经验
	qatColorStone = 79,			-- 七彩石值
	qatDragonSpitit = 80,		-- 龙魄值



	qatCustomize = 127,		    -- 自定义奖励
}

-- 虚拟物品对应的物品id
tagAwardItemIdDef = {
	[tagAwardType.qatExp] = 491, --经验
	[tagAwardType.qatBindMoney] = 493, --绑元
	[tagAwardType.qatMoney] = 493, --金币
	[tagAwardType.qatBindYb] = 495, --绑钻
	[tagAwardType.qatYuanbao] = 495, --钻石
	[tagAwardType.qatRedDiamonds] = 494,-- 红钻
	--[tagAwardType.qatLueiGongExp] = 3583, --内功经验
	--[tagAwardType.qatAchievePoint] = 838, --成就点
	-- [tagAwardType.qatRealDollars] = 839, 
	--[tagAwardType.qatZodiacAura] = 839, --战将灵力(改为斗笠结晶)
	[tagAwardType.qatGuildContribution] = 2874, --帮派贡献值
	--[tagAwardType.qatZYContribution] = 840, -- 阵营贡献
	[tagAwardType.qatMaterial] = 500, -- 各种材料
	[tagAwardType.qatAllEquip] = 499, --各类装备
	[tagAwardType.qatFuSoulValue] = 272, -- 玉佩碎片
	[tagAwardType.qatSpiritShield] = 2055, -- 神灵精魄-封神
	--[tagAwardType.qatHonorVaule] = 841, -- 荣誉值 功勋
	--[tagAwardType.qatDiamond] = 859, -- 钻晶 宝石结晶
	[tagAwardType.qatMeritVaule] = 2262, -- 圣珠结晶
	--[tagAwardType.qatRingCrystal] = 856, -- 特戒结晶
	--[tagAwardType.qatColorStone] = 3898, -- 七彩石
	[tagAwardType.qatPokedexExp] = 478, --图鉴经验
	[tagAwardType.qatBravePoint] = 2096,-- 勇者积分
	[tagAwardType.qatCsKillDevilToken] = 2844,-- 跨服屠魔令
	[tagAwardType.qatGuildCoin] = 2873,-- 行会资金
}

-- 虚拟物品对应的人物属性
tagAwardAttrDef = {
	[tagAwardType.qatBindMoney] = 55, --绑元
	[tagAwardType.qatMoney] = 56, --金币
	[tagAwardType.qatBindYb] = 57, --绑钻
	[tagAwardType.qatYuanbao] = 58, --钻石
}

--脚本离线消息id
OFFLINE_MSG_IDS = {
	YB_CONSUME_RANKING_1 = 1, 			-- 月度活动 元宝消耗排行榜第 1 名奖励
	YB_CONSUME_RANKING_2 = 2, 			-- 月度活动 元宝消耗排行榜第 2 ~ 5 名奖励
	YB_CONSUME_RANKING_3 = 3, 			-- 月度活动 元宝消耗排行榜第 6 ~ 20 名奖励
	TX_INVITATION_SUCCESS = 4,			-- 腾讯好友邀请
	TX_INVITATION_LEVEL_UP = 5,			-- 腾讯邀请的好友升级
	GET_TX_RECHARGE_AWARD = 6,			-- 腾讯充值礼包
	GET_TX_YELLOW_VIP_AWARD = 7,		-- 腾讯开通黄钻礼包
	ACTOR_GIVING_GIFT = 8,				-- 角色赠送的礼物
}

-- 物品操作类型定义
ENHANCE_OPT_TYPE = {
	EQUIP_UPGRADE,						--1装备升级
	EQUIP_STRONG,						--2装备强化
	NEW_EQUIP_AUTHENTICATE,				--3装备鉴定
	EQUIP_WASHAUTH,						--4鉴定清洗
	ON_WING_COMPOSITE,					--5翅膀合成
	ON_CIRCLE_FORGE,					--6转生装备锻造
	ON_EQUIP_BREAK,						--7装备分解
	ON_ITEM_COMPOSITE,					--8道具合成
	ON_DIAMOND_COMPOSITE,				--9宝石合成
	ON_DIAMOND_CHG,						--10宝石转换
	ON_MOVE_INIT_ATTR,					--11极品属性转移
	ON_CLEAR_INIT_ATTR,					--12清洗极品属性
	ON_WEAPON_EXTEND_CHG,				--13武器扩展 幻武转移
	ON_MAGIC_ITEM_COMPOSITE,			--14法宝合成
	ON_MAGIC_ITEM_CHG,					--15法宝幻化
	CIRCLE_EQUIP_UPGRADE,				--16转生后装备升级
	EQUIP_RESET_STRONG, 				--17重置装备强化属性
	MOVE_EQUIP_ATTR, 					--18转移装备属性
	EQUIP_BUY_STRONG_COUNT, 			--19购买强化次数
	EQUIP_BLOOD_REFINING,				--20装备血炼
	EQUIP_BLOOD_DECOM,					--21血炼分解
	EQUIP_NECKLACE_LUCK,     			--22项链幸运
	EQUIP_NECKLACE_LUCK_TRANS, 			--23幸运转移
	EQUIP_FORGING_SUPER_ATTR,			--24极品属性
	GOD_EQUIP,							--25神装系统
	RESOLVIng_GodEquip,					--26神装拆解
}

-- KP模式
FREEPKMODE = 
{
	PEACEFUL = 0,		--和平模式
	TEAM = 1,			--团队模式
	GUILD = 2,		--帮派模式
	EVIL = 3,			--善恶模式	
	PK = 4,			--杀戮模式	
	UNION = 5,		--联盟模式	
	ZY = 6,			--阵营模式
	COUNT = 7,
}

--每日活跃度活动
S2C_LIVENESSMSGID = {
	GETLIVENESSINFO = 1,        --获取活跃度活动信息
	GETLIVENESSAWARDRESULT = 2, --下发领取活跃度奖励结果
	ICONSTATUS = 3,             --下发图标状态
	SENDGUILDLIVENESS = 4,      --下发行会活跃度(行会界面要显示行会活跃度,所以这里单独下发这个值)
}

--活跃度目标类型
LIVENESSTARGET = {
	[0] = "降妖除魔完成次数",
	[1] = "采集珍珠完成次数",
	[2] = "护送皇杠/钾镖完成次数",
	[3] = "屠魔圣殿完成次数",
	[4] = "激情PK完成次数",
	[5] = "行会捐献完成次数",
	[6] = "每日充值1000元宝次数"
}

-- 昨天任务消息id
S2C_HISTORYTASKMSGID = {
	GETINFOMSGID = 1, 		--获得昨天的任务信息
	FINISHRESULT = 2, 		--下发完成昨天的任务结果
}

--npc对话框类型
NPC_DIALOG_TYPE = 
{
	GENERAL_NPCDLG = 1,						-- 普通NPC
	XXGJ_NPCDLG = 2,						-- 休闲挂机
	WZAD_NPCDLG = 3,						-- 未知暗殿
	BOSSZJ_NPCDLG = 4,						-- boss之家
	ZSSD_NPCDLG = 5,						-- 转生神殿
	MYSD_NPCDLG = 6,						-- 玛雅神殿
	FYSD_NPCDLG = 7,						-- 婚姻神殿
	XYCM_NPCDLG = 8,						-- 降妖除魔
	CLFB_NPCDLG = 9,						-- 材料副本
	TFFM_NPCDLG = 10,						-- 塔防封魔
	ZBT_NPCDLG = 11,						-- 总镖头
	TFF_MNPCAWARDDLG = 12,					-- 塔防风魔奖励面板
	BGXL_NPCDLG = 13,						-- 闭关修炼
	TiShuTaskNpcDlg = 14, 				    --天书任务
	SBHD_NPCDLG = 15,						-- 双倍活动
	WLZB_NPCDLG = 16,						-- 武林争霸
	YBJNH_NPCDLG = 17,						-- 元宝嘉年华
	ZYZ_NPCDLG = 18,						-- 阵营战
	GCZ_NPCDLG = 19,						-- 攻城战
	WCWJ_NPCDLG = 20,						-- 王城危机
	HHCG_NPCDLG = 21,						-- 行会闯关
	DBQB_NPCDLG = 22,						-- 夺宝奇兵
	CHIYOU_NPCDLG = 30, 					-- 蚩尤结界
	DRFB_NPCDLG = 31,						-- 多人副本
	HHJD_NPCDLG = 32,						-- 行会禁地
	SSG_NPCDLG = 33,						-- 圣兽宫
	PrestigeTaskNpcDla = 35,				-- 威望任务
	WorshiNpcDlg = 36,						-- 膜拜城主
	GUILDBOSSDlg = 37,						-- 行会BOSS
	WorldBossNpcDlg = 38,					-- 世界BOSS
	WingEquipMapNpcDlg = 39,					-- 护送镖车
	
	KuangDongNpcDlg = 40,				--封神地图
	KuangDongNpcDlg = 41,				--矿洞
	WingEquipMapNpcDlg  = 42,				--翅膀地图
	XingKongShenDianDlg  = 43,			--星空神殿
	StoneTombNpcDlg = 44,				--石墓阵
	ZumaTempleNpcDlg = 45,			--祖玛寺庙
	BullHallNpcDlg = 46,				--牛魔大厅
	BoneMagicNpcDlg = 47,				--骨魔洞
	RedMoonNpcDlg = 48,				--赤月峡谷
	MagicDragonNpcDlg = 49,			--魔龙岭
	SnowyNpcDlg = 50,					--雪域
	LeiyanCaveNpcDlg = 51,			--雷炎洞穴
	GhostSunkenNpcDlg = 52,			--幽灵沉船
	CrystalPalaceNpcDlg = 53,			--水晶宫
	TieXueZorkNpcDlg = 54,			--铁血魔域
	UndergroundTombNpcDlg = 55,		--地下王陵
	TibetanRuinsNpcDlg = 56,			--地藏遗址
	LavaHellNpcDlg = 57,				--熔岩地狱
	SubmarineMazeNpcDlg = 58,			--海底迷宫
	ShuraTempleNpcDlg = 59,			--修罗天宫
	WolongVillaNpcDlg = 60,			--卧龙山庄
	BingLongCityNpcDlg = 61,			--冰龙皇城
	ChuanShiCityNpcDlg = 62,			--传世皇宫

}

-- 需要材料不足弹窗的NPC
NPC_POPUPTIPS = {
	[NPC_DIALOG_TYPE.XingKongShenDianDlg] = XingKongShenDianCfg,
}

--金钱的类型的定义
EMONEYTYPE = {
	MTBINDCOIN =0,        --不可交易的金钱，比如系统奖励的一些金钱 
	MTCOIN=1,			  --可交易的金钱，如任务等发送的金钱
	MTBINDYUANBAO =2,     --不可交易的元宝，一般是系统奖励的 
	MTYUANBAO=3,		  --可交易的元宝，玩家充值兑换的
	MTSTOREPOINT = 4,	  --商城积分，消费元宝时产出
	MTHONOUR = 5,		  --荣誉

	MTZHANXUN = 6,			--战勋
	MTENERGY = 7,			--能量点
	MTMONEYTYPECOUNT,
	MTMONEYTYPESTART = mtBindCoin,
}

--排行榜
RANKING_TYPE =
{
	RANKING_TYPE_LEVEL = 0,		-- 等级榜(值会降低)
	RANKING_TYPE_BATTLE_POWER,	-- 战力榜(值会降低)
	RANKING_TYPE_OFFICE,		-- 官职榜
	RANKING_TYPE_SWING,			-- 翅膀榜
	RANKING_TYPE_CHARM,			-- 魅力榜(值会降低)
	RANKING_TYPE_HERO,			-- 英雄榜

	_RANKING_TYPE_SUM,
}

-- 服务端弹窗类型定义
SERVER_ALERT_TYPE = {
	RECHARGE_GOLD = 1,				-- 充值元宝
	COMMON_DESC = 2,				-- 通用描述
	BUY_WINDOW = 3,					-- 购买窗口
	USE_ITEM = 4,					-- 使用物品
	MULTI_BUTTON = 5,				-- 多按钮弹窗
}

-- 默认地图区域参数
MAP_AREA_DEFAULT_PARAM = {
	[1] = {x=10, y=10},
	[2] = {x=20, y=20},
	[3] = {x=60, y=50},
}

--tolua_begin
--地图区域属性的定义
--完全搬战将的过来，有些未必用得到,先定义
--注意：在配置文件中，attri字段里的type对应下面的值，如aaSaft，而value根据type的值不同，会需要配置不同的值，有些是配一个整数，有些是整数列表（多个整数），有些
--有时不需要配置value
MapAreaAttribute = {
  aaNoAttri = 0,  --无意义
  aaSaft = 1,   --"世界安全区"，无参数
  aaAddBuff = 2,  --进入自动增加buff,离开后会自动删除buff,参数：[buff的个数]+N*{[buff类型][groupid][周期（秒）][次数][buff值]},
  --注：应该给区域属性的buff分配个固定的id，另外由于这里参数都是填整数类型的，buff值如果是浮点数类型的，比如0.01，就写100，即0.01的10000倍,
  --为保险起见，加的buff需要限定次数，以避免buff没正常删除的情况
  aaWar = 3,    --"战斗"，战斗专门区域，打死人是不用负责任滴，无参数,注：暂未实现
  aaGuildWar = 4, --"帮派战斗"，帮派战的合理区域，，无参数,注：暂未实现
  aaChat = 5,   --"禁言"，无参数,注：暂未实现
  aaReloadMap = 6,--"重配地图",如果玩家在这个区域挂掉或重新上线，会转移到之前的非重配地图区域，无参数
  aaExpDouble = 7,  --"经验倍数"，，无参数，注：可能取消
  aaPKAddLevel = 8, --"PK胜利加等级"，[等级增加的数量],注：暂未实现
  aaPkAddExp = 9,   --"PK胜利加经验"  [增加经验的数量],注：暂未实现
  aaPkSubLevel = 10,  --"PK失败减等级" [等级减少的数量],注：暂未实现
  aaPkSubExp = 11,  --"PK失败减经验" [减少的经验],注：暂未实现
  aaAutoSubHP = 12, --"自动减HP"   [减少的HP]，注：执行的周期是1秒
  aaAutoAddHP = 13, --"自动加HP"   [增加的HP]，注：执行的周期是1秒
  aaXiuweiRate = 14,  --"修为加成"  [加成值，整数,每20秒增加一次]
  aaAutoSubBindYuanbao = 15,  --"自动减游戏点"  [数量],注：暂未实现
  aaAutoAddYuanbao = 16,  --"自动加游戏币"    [数量],注：暂未实现
  aaAUtoAddBindYuanbao = 17,  --"自动加游戏点"  [数量],注：暂未实现
  aaCrossMan = 18,    --"穿人"  ，无参数,  
  aaCrossMonster = 19,    --"穿怪"，无参数, 
  aaNotCrossMan = 20,   --"禁止穿人"，无参数
  aaNotCrossMonster = 21,   --"禁止穿怪"，无参数
  aaNotSubDura = 22,    --死亡不减武器的耐久度
  aaNotGuildTran = 23,    --"禁止使用行会拉传"，参数：【召唤1，行会集结令2，行会回城卷3,队伍集结4】
  aaNotMarryTran = 24,    --"禁止使用夫妻传送"，无参数,注：可能取消
  aaNotMasterTran = 25,   --"禁止使用师徒传送"，无参数,注：暂未实现
  aaRandTran = 26,    --"禁止随机传送"，无参数,注：暂未实现
  aaNoDrug = 27,      --"禁止使用药品"，无参数,注：暂未实现
  aaZyProtect = 28,     --"阵营保护区域",【被保护的阵营id】，如果有2个阵营被保护，则2个参数。
  aaNotTransfer = 29,   --"禁止定点传送"，无参数
  aaNotBeTran = 30,   --"禁止被行会拉传"，参数：【召唤1，行会集结令2，行会回城卷3,队伍集结4】
  aaTriggerGuid = 31,   --"图为引导"，[图文id]
  aaNotBeMasterTran = 32,   --"禁止被师徒传送"，无参数,注：暂未实现
  aaNotSkillId = 33,    --"限制技能使用"，[技能1，技能2，技能3...],技能id
  aaNotItemId = 34,   --"限制物品使用"[物品1，物品2，物品3...]，都是指物品id
  aaNotAttri = 35,    --"限制特殊属性",注：暂未实现
  aaSceneLevel = 36,    --"进地图等级"，[等级],注：暂未实现
  aaSceneFlag = 37,   --"进地图标志" ,注：暂未实现
  aaRunNpc = 38,      --"进入触发NPC脚本",注：
  aaCity = 39,      --"城镇"，无参数,表示回城卷或者回城复活，就会回到这里
  aaNotLevelProtect = 40,     --"关闭新手保护"，无参数，现低于40级（以下）是保护状态，免受攻击，进入该区域后，这个规则失效
  aaAutoAddExp = 41,    --"自动加经验"，[经验的数量]，注：执行的周期是1秒
  aaAutoSubExp = 42,    --"自动减经验"，[经验的数量]，注：
  aaNotMount = 43,    --"限制骑乘宝物"  ，无参数，骑乘宝物,注：
  aaNotHereRelive = 44,   --"禁止原地复活"，无参数,注：暂未实现
  aaNotCallMount = 45,    --"禁止骑马"，无参数,注：
  aaSaftRelive = 46,    --"安全复活区"，即复活点，无参数,   如果是表示沙巴克战是复活，第五个参数表示复活的地图id
  aaSubHPByPercent = 47,    --"按千分比减少HP"[每次减少的千分比]，注：可能取消
  aaAddHPByPercent = 48,    --"按千分比增加HP"[每次增加的千分比]，注：可能取消
  aaEndPkCanHereRelive = 49,  --"PK死亡允许原地复活"，无参数,注：暂未实现
  aaForcePkMode = 50,   --"强制攻击模式",[PK模式]，注意：只接受一个参数。0和平模式，1团队模式，2帮派模式，3阵营模式，4杀戮模式，5联盟模式
  aaNotSkillAttri = 51,   --"禁止使用任何技能属性"，无参数,注：暂未实现
  aaNotTeam = 52,     --"禁止组队"，无参数,注：暂未实现
  aaLeftTeam = 53,    --"强制离开队伍"，无参数
  aaNotAutoAddHpDrug = 54,    --"自动恢复体力类物品无效"，无参数,注：暂未实现
  aaNotAutoAddMpDrug = 55,  --"自动恢复灵力类物品无效"，无参数,注：暂未实现
  aaNotDeal = 56,     --"禁止交易"，无参数,注：暂未实现
  aaNotMeditation = 57,   --"禁止打坐"，无参数
  aaEndPkNotHereRelive = 58,  --"PK死亡后禁止原地复活"，无参数,注：暂未实现
  aaNotProtect = 59,    --"关闭保护"，无参数
  aaNotAutoBattle = 60,   --禁止自动战斗，无参数,注：暂未实现
  aaNotMatch = 61,    --禁止切磋，无参数
  aaNotJump = 62,     --禁止跳跃，无参数
  aaNotJumpTarget = 63, --禁止以这个为跳跃目的点，无参数
  aaJumpNotQg = 64,     --跳跃不消耗轻功，无参数
  aaNotAddZhanHun = 65,   --禁止PK获得战魂
  aaAddZhanHunByPercent = 66, --"PK胜利按千分比增加战魂"[每次增加的千分比]
  aaNotSubZhanHun = 67,   --禁止PK掉落战魂
  aaSubZhanHunByPercent = 68, --"PK失败按千分比减少战魂"[每次减少的千分比]
  aaPkNotAddExp = 69,     --禁止PK获得经验
  aaPkAddExpByPercent = 70,   --"PK胜利按千分比增加经验"[每次增加的千分比]
  aaPkNotSubExp = 71,   --禁止PK掉落经验
  aaPkSubExpByPercent = 72, --"PK失败按千分比减少经验"[每次减少的千分比]
  aaCannotViewOther=73,   -- "无法查看其他玩家信息"
  aaCannotShutUp=74,      -- "无法聊天频道发言"
  aaCannotSeeName=75,     -- "无法看到周围玩家名字"
  aaLeaveDelBuf=76,     -- 删除场景的时候删除buff[bufftype,buffid,bufftype,buffid]
  aaSceneMaxLevel = 77,   --进入地图的最高等级
  asStallArea = 78,     --摆摊区域
  asSceneAreaMode = 79,   --区域玩家属性 参数： 1 进入沙巴克区域 
  asNoDropEquip = 80,     --所在场景不爆装备
  aaDigArea=81,               --挖矿区域
  aaCitydoorArea=82,           --城门区域,如沙巴克城门
  aaNoFire = 83,        --禁止使用火墙术
  aaHorseRace = 84,     --赛马区域
  aaNotCallHero = 85,     --禁止召唤英雄与道士宝宝
  aaSwimArea = 86,      --游泳地图
  aaNewPlayerProtect = 87,  --新手保护有效，有此地图属性的区域，新手保护BUFF将产生效果，在此区域内，玩家不会被他人攻击，也不可攻击他人
  aaChangeModel = 88,     --切换模型[男模ID,女模ID]
  aaNoDropItem = 89,      --不能丢弃物品
  aaBigFire = 90,     --大篝火区域
  aaNotItemTran = 91,     --禁止使用物品类速传
  aaAnswerArea = 92,      --答题区域
  aaSunlight = 93,      --沐光区域
  aaGerser = 94,              --喷泉区域
  aaGlory = 95,               --佛光普照区域
  aaNotPutGuildFlag = 96,   --禁止放行会会棋
  aaPaoDianAddExpArea = 97, --泡点加经验区域
  aaNotCallZhanJiang = 98,	--禁止召唤战将

  aaAttriCount = 99,     --属性类型的数量
}

NPC_ID = {
	GCZ = 103,
	HHCG = 104,
	CHENGZHU = 94,
	MINGREN1 = 183,
	MINGREN2 = 184,
	MINGREN3 = 185,
}
