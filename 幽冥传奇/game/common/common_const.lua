----------------------------------------------------
-- 常量定义
----------------------------------------------------
COMMON_CONSTS = 
{
	RIGHT_MENU_BAR = -1,							-- 右侧菜单栏 比正常界面低一个层级
	INVALID_OBJID = 0,								-- 无效场景对象ID

	SERVER_TIME_OFFSET = 1451577600,				-- 2016-1-1 0:0:0 时间戳

	CHAT_LEVEL_LIMIT = 40,							-- 语音聊天等级限制
	-- PRIVATE_CHAT_LEVEL_LIMIT = 60,					-- 私聊等级限制

	MAX_BAG_COUNT = 75,								-- 背包、仓库最大格子数量
	MAX_BUY_COUNT = 99,								-- 背包、仓库购买（堆叠）最大格子数量
	OpenBagItemId = 26914,							-- 拓展背包物品
	OpenStorgeItemId = 26915,						-- 拓展仓库物品
	GuildTanheItemId = 26911,						-- 仙盟弹令

	MAX_STRENGTHEN_EQUIP_PART = 14,					-- 最大装备强化数量
	MAX_NORMAL_EQUIP_PART = 18,						-- 最大普通装备数量
	EQUIP_FLUSH_ATTR_BASE_NUM = 5,					-- 装备洗练刷新属性最大数量

	FONT = "res/fonts/MNJCY.ttf",						-- 默认字体

	FIGHT_STATE_TIME = 5,							-- 战斗状态持续时间
	SKILL_GLOBAL_CD = 0.6,							-- 技能全局CD
	SELECT_OBJ_DISTANCE = 20 * 20,					-- 选择目标范围(平方)
	REALIVE_TIME = 60,								-- 复活倒计时
	FOOTPRINT_CREATE_GAP_TIME = 0.3,				-- 足迹生成间隔时间
	MAIN_ROLE_BEHIT_SOUND_DELAY = 3,				-- 主角攻击后n秒内不播受击

	FLYING_UP_USE_TIME = 1,							-- 飞行上升使用时间
	FLYING_DOWN_USE_TIME = 1,						-- 飞行下降使用时间
	FLYING_MAX_HEIGHT = 250,						-- 飞行最高高度
	FLYING_SHADOW_MAX_SCALE = 3, 					-- 飞行时影子最大缩放
	FLYING_SHADOW_MIN_OPACITY = 100, 				-- 飞行时影子最小透明度
	FLYING_CAMCERA_SCALE = 0.7,						-- 飞行时镜头缩放系数

	SCENE_FALLITEM_AUTO_PICK_RANGE = 4,				-- 场景掉落物自动捡取距离

	XIN_SHOU_LEVEL = 60,							-- 新手保护等级

	ZORDER_RECHARGE_PANEL = 900000,					-- 充值相关界面层ZOrder
	SELECT_ITEM_TIPS = 900001,						-- itemtips ZOrder
	ZORDER_ITEM_TIPS = 900002,						-- itemtips ZOrder
	ALERT_TIPS = 900003,							-- alert ZOrder
	PANEL_MAX_ZORDER = 1000000,						-- panel 最高层
	ZORDER_CURTAIN = 1000001,						-- 新手幕布
	ZORDER_GUIDE = 1000002,							-- 新手引导相关界面ZOrder
	ZORDER_BETTER_EQUIP = 1000004,					-- 更好装备提醒层
	ZORDER_FB_PANEL = -3,						-- 副本结算界面层ZOrder
	ZORDER_RECEIVE_BISHA = 100008,					-- 获取必杀技能
	ZORDER_SYSTEM_EFFECT = 1000010,					-- 特效层
	ZORDER_FUHUO = 1000013,							-- 复活界面层
	ZORDER_LOGIN = 1000015,							-- 登录界面ZOrder
	ZORDER_AGENT_LOGIN = 1000016,					-- 登录渠道界面ZOrder
	ZORDER_SYSTEM_HINT = 1000020,					-- 系统飘字ZOrder
	ZORDER_CHANGE_SCENE = 1000030,					-- 切场景界面ZOrder
	ZORDER_ENDGAME = 1000040,						-- 退出游戏界面ZOrder
	ZORDER_ONFUBEN = 1000050, 						-- 进入副本动画层
	ZORDER_MAX = 2000000,							-- 最大ZOrder
	ZORDER_ERROR = 3000000,							-- 报错层


	FLY_CROSS_MAP_VIP_LEVEL = 4,					-- 跨地图传送时Vip等级要求
	FLY_CROSS_MAP_ROLE_LEVEL = 25,					-- 跨地图传送时人物等级要求

	MAX_CHAT_MSG_LEN = 1024,						-- 聊天消息最大长度

	VIRTUAL_ITEM_EXP = 836,							--虚拟物品 经验
	VIRTUAL_ITEM_BIND_COIN = 842,					--虚拟物品 绑定铜币
	VIRTUAL_ITEM_COIN = 842,						--虚拟物品 铜币
	VIRTUAL_ITEM_BIND_GOLD = 843,					--虚拟物品 绑定元宝
	VIRTUAL_ITEM_GOLD = 844,						--虚拟物品 元宝

	EVIL_TITLE_1 = 2011,							--恶名称号1
	EVIL_TITLE_2 = 2013,							--恶名称号2
	EVIL_TITLE_3 = 2012,							--恶名称号3

	FLY_HUSONG_RANDOM_RANGE = 3,					--飞行到护送随机距离
	FLY_CAMP_RANDOM_RANGE = 3,						--飞行到阵营刺杀随机距离
	FLY_BOSS_RANDOM_RANGE = 10,						--飞行到BOSS的随机距离
	FLY_MOSHEN_RANDOM_RANGE = 25,					--飞行到魔神的随机距离

	SCENE_CAMERA_OFFSET_Y = 70,						--场景相机偏移Y

	MAX_LOOPS = 0x7fffffff,							--无限循环

	BIGCHATFACE_ID_FIRST = 100,						--大表情起始ID
	BIGCHATFACE_ID_LAST = 132,						--大表情结束ID

	ROLE_HEIGHT = 124,
	MONSTER_HEIGHT = 62,
}

--gamesecne.h 定义 lua全局表同名
--[[
	//注意，以下在GRQ_UI层及以上的都会受m_camera_scale的影响
	GRQ_UNKNOW = 0,
	GRQ_TERRAIN = 10,														// 地形层
	GRQ_BLOCK = 20,															// 阻挡层
	GRQ_SHADOW = 30,														// 阴影层
	GRQ_SCENE_OBJ = 40,														// 场景对象
	GRQ_DEFAULT_PS = 50,													// 默认粒子系统
	GRQ_UI = 60,															// UI
	GRQ_UI_UP = 70,															// UI之上的绘制物体
]]