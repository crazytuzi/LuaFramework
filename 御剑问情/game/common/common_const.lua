----------------------------------------------------
-- 常量定义
----------------------------------------------------
COMMON_CONSTS =
{
	INVALID_OBJID = -1,								-- 无效场景对象ID

	PET_NUMBER = 7,									-- 宠物个数

	SCENE_LOADING_MIN_TIME = 1.5, 					-- 场景进度条加载最短时间
	SCENE_LOADING_MAX_TIME = 8,						-- 场景进度条加载最长时间

	XIN_SHOU_LEVEL = 144,							-- 新手保护等级
	CHAT_LEVEL_LIMIT = 140,							-- 聊天等级限制
	PRIVATE_CHAT_LEVEL_LIMIT = 140,					-- 私聊等级限制
	SHUIJING_LEVEL_LIMIT = 150,						-- 进入水晶幻境等级限制

	MAX_PRIVITE_OBJ_NUM = 20,						-- 最大私聊对象数量

	MAX_CHANNEL_MSG_NUM	= 50,						-- 频道消息最大数量
	MAX_PRESERVE_MSG_NUM = 50,						-- 私聊消息最大数量
	MAX_TRANSMIT_MSG_NUM = 10,						-- 喇叭消息最大数量

	MAX_BAG_COUNT = 400,							-- 背包、仓库最大格子数量
	WARE_HOUSE_START_INDEX = 400,					-- 背包仓库初始位置index
	MAX_BUY_COUNT = 99,								-- 背包、仓库购买（堆叠）最大格子数量
	OpenBagItemId = 26914,							-- 拓展背包物品
	OpenStorgeItemId = 26915,						-- 拓展仓库物品
	GuildTanheItemId = 26911,						-- 仙盟弹令
	GUILD_NAME_MAX = 6,								-- 公会名字最大长度
	GUILD_CHANGE_NAME = 26922,								-- 公会改名卡
	GUILD_ICON_CHANGE_LV = 200,						--修改公会头像等级

	MAX_EQUIPMENT_GRID_NUM = 12,					-- 最大装备格子数量
	MAX_NEW_EQUIPMENT_GRID_NUM = 8,					-- 最大觉醒装备格子数量
	MAX_CAN_FORGE_EQUIP_NUM = 10,					-- 最大可锻造装备数量

	MAX_STONE_COUNT = 7,							-- 每个装备中宝石的最大数量

	MAX_STONE_EQUIP_PART = 10,						-- 宝石的位置

	FONT = "res/fonts/MNJCY.ttf",					-- 默认字体

	ACT_ICON_OPEN_LEVEL = 21,						-- 活动图标开放等级

	SHENZHUADDPERCENT = 120,						-- 神铸等级为1时的属性加成百分数

	MAX_ROLE_CHEST_GRID = 500,						-- 宝物仓库最大的格子数

	EQUIP_SHENZHU_RATE = 15,						-- 装备神铸比率

	FIGHT_STATE_TIME = 5,							-- 战斗状态持续时间
	FIGHT_WING_APPEAR_TIME = 3,						-- 战斗状态持续时间
	SKILL_GLOBAL_CD = 0.6,							-- 技能全局CD
	SELECT_OBJ_DISTANCE = 60 * 60,					-- 选择目标范围
	SELECT_OBJ_DISTANCE_IN_BOSS_SCENE = 60 * 60,	-- Boss场景选择目标范围
	REALIVE_TIME = 60,								-- 复活倒计时
	FOOTPRINT_CREATE_GAP_TIME = 0.3,				-- 足迹生成间隔时间
	MAIN_ROLE_BEHIT_SOUND_DELAY = 3,				-- 主角攻击后n秒内不播受击
	STAND_XIANJIAN_MOVE_DELAY_TIME = 5,				-- 站立5秒后仙剑开始移动的时间

	FLYING_UP_USE_TIME = 1,							-- 飞行上升使用时间
	FLYING_DOWN_USE_TIME = 1,						-- 飞行下降使用时间
	FLYING_MAX_HEIGHT = 250,						-- 飞行最高高度
	FLYING_SHADOW_MAX_SCALE = 3, 					-- 飞行时影子最大缩放
	FLYING_SHADOW_MIN_OPACITY = 100, 				-- 飞行时影子最小透明度
	FLYING_CAMCERA_SCALE = 0.7,						-- 飞行时镜头缩放系数

	NPC_TRIIGER_RANGE = 3, 							-- 触发NPC响应距离
	GATHER_TRIIGER_RANGE = 2,						-- 采集距离

	MAX_DUAN_ATK = 3,								-- 最大段数攻击
	DUAN_SKILL_RESET_TIME = 3,						-- 段技能重置时间
	NUQI_SKILL_LEVEL = 45,							-- 怒气技能可用等级
	NUQI_FULL = 200.0,								-- 怒气满值
	FUZZY_SEARCH_ITEM_TYPE_COUNT = 24,				-- 市场模糊查询的最大的查询组
	FUZZY_SEARCH_ITEM_ID_COUNT = 256,				-- 市场模糊查询每个组最大的查询数

	EXP_MAX_STAR = 3,								-- 每一关卡最多星数
	EXP_DUNGEON_ALLSTAR = 12,						-- 经验副本总星星数

	JINGLING_CARD_MAX_LEVEL = 20,					-- 精灵卡牌最大等级

	NEQFB_MAX_STAR = 3,								-- 每一关卡最多星数
	NEQFB_ROLLPOOL_0_COUNT = 7,
	NEQFB_ROLLPOOL_1_COUNT = 2,
	NEQFB_ROLLPOOL_2_COUNT = 1,
	NEQFB_ROLLPOOL_TOTAL_COUNT = 8,
	LEVEL_MAX_COUNT = 6,

	TOWER_MAX_PAGE = 2,
	TOWER_MAX_PER_PAGE = 6,
	TOWER_TOTAL = 8,

	PUBLICSALE_MAX_ITEM_COUNT = 20,					-- 每个人最多能寄售的物品个数

	ACTIVITY_ROOM_MAX = 8,							-- 开房间的活动 统一为8个
	ZHUXIE_TASK_MAX = 4,							-- 诛邪战场任务最大个数
	ZHUXIE_BOSS_NUM = 1,							-- 诛邪战场BOSS数量

	ROLE_MOVE_SPEED = 1000,							-- 主角移动速度

	FLY_CROSS_MAP_VIP_LEVEL = 4,					-- 跨地图传送时Vip等级要求
	FLY_CROSS_MAP_ROLE_LEVEL = 25,					-- 跨地图传送时人物等级要求

	MAX_CHAT_MSG_LEN = 1024,						-- 聊天消息最大长度
	HusongTaskTotalTime = 900,						-- 护送总时间（过后失效）
	POINT = "·",									-- 点号分隔符

	TASK_GUILD_DAY_MAX_COUNT = 10,					--一天完成仙盟任务最大数量
	TASK_DAILY_DAY_MAX_COUNT = 10,					--一天完成日常任务最大数量
	TASK_CAMP_DAY_MAX_COUNT = 3,					--一天完成阵营任务最大数量
	TEAM_TOWERDEFEND_JOIN_TIMES = 1,				--组队塔防最大数量

	TASK_GUILD_PRVE_TASK = 290,						--仙盟任务的前置任务id
	MOUNT_QIBING_PRVE_TASK = 430,					--坐骑的前置任务id
	CAMP_GATHER_TASK = 1210,						--阵营采集任务（链接时需区分不同阵营）

	MAX_TILI = 200,									--体力最大值

	NPC_HUSONG_RECEIVE_ID = 400,					--护送接收任务npcId
	NPC_HUSONG_DONE_ID = 401,						--护送完成任务npcId
	NPC_CAMP_ID = 201,								--阵营npcId
	NPC_STORAGE_ID = 185,							--仓库npcId
	NPC_DRUGSTORE_ID = 186,							--药店npcId
	NPC_MARRY_ID = 2000,							--月老npcId

	FLOWER_START_ID = 26903,						--花的起始id

	VIRTUAL_ITEM_NVWASHI = 90125,					--虚拟物品 女娲石
	VIRTUAL_ITEM_EXP = 90050,						--虚拟物品 经验
	VIRTUAL_ITEM_BIND_COIN = 65535,					--虚拟物品 绑定铜币
	VIRTUAL_ITEM_COIN = 65536,						--虚拟物品 非绑铜币
	VIRTUAL_ITEM_XIANHUN = 90070,					--虚拟物品 仙魂
	VIRTUAL_ITEM_BINDGOL = 90054,					--虚拟物品 绑定元宝
	VIRTUAL_ITEM_HORNOR = 90071,					--虚拟物品 荣誉
	VIRTUAL_ITEM_GONGXIAN = 90074,					--虚拟物品 仙盟贡献
	VIRTUAL_ITEM_GOLD = 65534,						--虚拟物品 元宝
	VIRTUAL_ITEM_PERCENT_GOLD = 65537,				--虚拟物品 钻石百分比堆
	VIRTUAL_ITEM_FUWEN_EXP = 23379,					--虚拟物品 符文经验
	SPIRIT_ID = 27589,								--星灵石
	VIRTUAL_ITEM_YUANLI = 90072, 					--精华
	VIRTUAL_ITEM_SHENGWANG = 90086,					--声望
	VIRTUAL_ITEM_GONGXUN = 90341,					--功勋

	EVIL_TITLE_1 = 2011,							--恶名称号1
	EVIL_TITLE_2 = 2012,							--恶名称号2

	FLY_HUSONG_RANDOM_RANGE = 3,					--飞行到护送随机距离
	FLY_CAMP_RANDOM_RANGE = 3,						--飞行到阵营刺杀随机距离
	FLY_BOSS_RANDOM_RANGE = 10,						--飞行到BOSS的随机距离
	FLY_MOSHEN_RANDOM_RANGE = 25,					--飞行到魔神的随机距离

	SCENE_CAMERA_OFFSET_Y = 70,						--场景相机偏移Y

	MAX_LOOPS = 999999999,							--无限循环

	XIANPIN_MAX_NUM = 6,							--仙品最大数量

	MIN_SUIT_ROCK = 27678,							-- 套装id最小值

	WORLD_LEVEL_OPEN = 150,							--世界等级开放等级
	WORLD_LEVEL_EXP_PERCENT = 3,					--世界等级经验加成
	WORLD_LEVEL_EXP_MAX_PERCENT = 200,				--世界等级最大经验加成
	WORLD_LEVEL_LIMIT = 40,							--世界等级限制
	BIGCHATFACE_ID_FIRST = 50,						--大表情起始ID
	SPECIALFACE_ID_FIRST = 200,						--特殊表情起始ID

	ACTIVEDEGREE_REWARD_ITEM_MAX_NUM = 8,			--活跃度最大奖励数
	ACTIVEDEGREE_MAX_TYPE = 64,						--活跃度最大类型

	CG_NVSHEN_NPC_ID = 300, 							--cg里的女神npcid

	UI_QUALITY_OVER_LEVEL = 0, 						--ui界面上品质

	MAGICAL_PRECIOUS_CHAPTER_COUNT = 32,			--魔龙秘宝章节数
	MAGICAL_PRECIOUS_CHAPTER_FLAG_COUNT = 5,		--魔龙秘宝章数

	COMPARE_MIN_POWER = 20,							 -- 战力对比误差

	CHONGCI_MIN_DISTANCE = 3 * 3,						-- 冲刺最短距离
	CHONGCI_MAX_DISTANCE = 20 * 20,						-- 冲刺最长距离
	CHONGCI_SPEED = 50,									-- 冲刺速度

	WATER_HEIGHT = 1.2,						-- 水深

	TIME_SCALE = 0.07,						-- 时间拉伸系数
	TIME_SCALE_DURATION = 3.5,				-- 时间拉伸持续的时间
	TIME_SCALE_FREEZE = 0.1,				-- 时间静止系数(策划说有可能不为0)
	TIME_SCALE_FREEZE_DURATION = 2,			-- 时间停止持续的时间

	NPC_WALK_SPEED = 2,						-- NPC走路速度

	GREATE_SOLDIER_SLOT_MAX_COUNT = 5,

	AVATAR_WINDOW_MAX_TYPE = 50,

	MAX_BOSS_PERSONAL_DPS_COUNT = 5,
	MAX_BOSS_GUILD_DPS_COUNT = 5,
	SHUIJING_LIST_MAX_NUM = 50,
	MAX_RED_EQUIP_CONVERT_COUNT = 500,			--红装兑换最大装备数量
	GREATE_SOLDIER_MAX_COUNT = 32,
	GREATE_SOLDIER_EQUIP_PART_COUNT = 10,
	GREATE_SOLDIER_EQUIP_VIRTUAL_BAG_NUM = 160,
}
