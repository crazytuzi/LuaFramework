local CrossPVPConst =
{
	-- 比赛赛程
	COURSE_NONE			= 0, -- 没有比赛
	COURSE_APPLY		= 1, -- 报名
	COURSE_PROMOTE_1024	= 2, -- 海选（1024强晋级赛）
	COURSE_PROMOTE_256	= 3, -- 复赛（256强晋级赛）
	COURSE_PROMOTE_64	= 4, -- 64强晋级赛
	COURSE_PROMOTE_16	= 5, -- 16强晋级赛
	COURSE_PROMOTE_4 	= 6, -- 4强晋级赛
	COURSE_FINAL		= 7, -- 决赛
	COURSE_EXTRA		= 8, -- 多出来的一轮，只是为了回顾决赛的战况

	-- 一个赛程中的阶段
	STAGE_NONE			= 0, -- 没有开赛
	STAGE_REVIEW		= 1, -- 回顾上轮战果
	STAGE_BET			= 2, -- 投注（鲜花鸡蛋）
	STAGE_ENCOURAGE		= 3, -- 鼓舞
	STAGE_FIGHT			= 4, -- 战斗/观战
	STAGE_END 			= 5, -- 多出来的一个阶段，某些特殊情况下用到

	-- 投注类型
	BET_FLOWER			= 1, -- 鲜花
	BET_EGG				= 2, -- 鸡蛋

	-- 鼓舞类型
	ENCOURAGE_DAMAGE_UP	= 1, -- 伤害加成
	ENCOURAGE_HURT_DOWN	= 2, -- 伤害减免

	-- 部分协议需要延迟请求的时间
	REQUEST_DELAY 		= 3, -- 秒

	-- 事件类型
	EVENT_STAGE_CHANGED	= "event_cross_pvp_stage_changed",	-- 比赛阶段或者赛程改变

	-- 战斗部分
	STAGE_FLAG = {
		GREEN   = 1, -- 绿旗
		BLUE    = 2, -- 蓝旗
		PURPLE  = 3, -- 紫旗
		ORANGE  = 4, -- 橙旗
		RED 	= 5, -- 红旗
		GOLD 	= 6, -- 金旗
	},

	INVINCIBLE_TIME = 10, -- 10秒的无敌时间

	MAX_ENGAGED_TIME = 60, -- 据点最长被占领时间，超时占领者将被自动T下

	EAGAGED_STATE = {
		NO  = 0,		-- 据点还未被占领
		YES = 1,		-- 据点已经被占领
	},

	-- 战场类型
	BATTLE_FIELD_TYPE = {
		PRIMARY  = 1,   -- 初级战场
		MIDDLE   = 2,    -- 中级战场
		ADVANCED = 3,  -- 高级战场
		EXTREME  = 4,   -- 至尊战场
	},


	BATTLE_FIELD_NUM = 4, -- 战场类型数

	INSPIRE_TYPE = {
		HARM_ADD = 1,	  -- 伤害加成
		HARM_REDUCE = 2,  -- 伤害减免
	},

	RANK_TYPE = {
		GLOBAL = 1,	-- 全局的一个排行榜
		ROOM = 2,   -- 战斗房间的一个排行榜
	},

	FLAG_IMG = { "ui/crosspvp/bg_chujizhanchang.png",
				 "ui/crosspvp/bg_zhongjizhanchang.png",
				 "ui/crosspvp/bg_gaojizhanchang.png",
				 "ui/crosspvp/bg_zhizunzhanchang.png" },

	FIELD_NAME = { "kfds-chujizhanchang.png",
				   "kfds-zhongjizhanchang.png",
				   "kfds-gaojizhanchang.png",
				   "kfds-zhizunzhanchang.png"},

	TEXT_TYPE = {
		NORMAL = 1,
		HEIGHT_LIGHT = 2,
	},

}

return CrossPVPConst