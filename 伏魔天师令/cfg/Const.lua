_G.Const =
{
    --/** AUTO_CODE_BEGIN_Const **************** don't touch this line ********************/
	--/** =============================== 自动生成的代码 =============================== **/

	--/** 开发版本号(日期时间) */
	DEVELOPMENT_VERSION                        = "2016-07-25 10",

	--------------------------------------------------------------------
	-- ( 版本 ) 
	--------------------------------------------------------------------
	-- [2]惊奇先生 -- 版本 
	CONST_VERSION_OBJ                          = 2,

	--------------------------------------------------------------------
	-- ( 系统 ) 
	--------------------------------------------------------------------
	-- [16]随身商店ID  -- 系统 
	CONST_CARRY_STORE_ID                       = 16,
	-- [30]最大连续错误心跳次数  -- 系统 
	CONST_BAD_HEART                            = 30,
	-- [60]时间同步协议频率（秒）  -- 系统 
	CONST_TSP_INTERVAL                         = 60,
	-- [60]玩家掉线进程存活时间(秒)  -- 系统 
	CONST_USER_OFFLINE_ALIVE                   = 60,
	-- [100]消息队列最大长度  -- 系统 
	CONST_MESSAGE_QUEUE_LEN_MAX                = 100,
	-- [300]Player数据存蓄间隔时间（秒）  -- 系统 
	CONST_DB_SAVE                              = 300,
	-- [3000]心跳间隔时间（毫秒）PS：300毫秒容错  -- 系统 
	CONST_INTERVAL_HEART                       = 3000,
	-- [86400]离线玩家数据ets保存多少时间(秒)  -- 系统 
	CONST_OFF_DATA_TIME                        = 86400,
	-- [172800]临时背包物品有效时间(秒)  -- 系统 
	CONST_BAG_TEMP_EXPIRY                      = 172800,

	-- [0]有效期-不失效  -- 系统 
	CONST_EXPIRY_PERPETUITY                    = 0,
	-- [1]有效期-秒  -- 系统 
	CONST_EXPIRY_ECOND                         = 1,
	-- [2]有效期-天  -- 系统 
	CONST_EXPIRY_DAY                           = 2,

	-- [10]协议，容错次数(次)  -- 系统 
	CONST_FAULT_PROTOCOL                       = 10,
	-- [600]登录，容错时间(秒)  -- 系统 
	CONST_FAULT_TOLERANT                       = 600,

	-- [20]游戏公告显示默认时长(秒)  -- 系统 
	CONST_NOTICE_SHOW_TIME                     = 20,
	-- [80]游戏公告显示最长时长(秒)  -- 系统 
	CONST_NOTICE_SHOW_TIME_MAX                 = 80,

	-- [5]在线获得体力值点数  -- 系统 
	CONST_SP_ONLINE_VALUE                      = 5,
	-- [1800]在线获得体力值时间间隔  -- 系统 
	CONST_SP_ONLINE_TIMES                      = 1800,

	-- [0]默认绑元  -- 系统 
	CONST_DEFAULT_RMB_BIND                     = 0,
	-- [0]默认地图id  -- 系统 
	CONST_DEFAULT_MAP                          = 0,
	-- [0]默认无配偶  -- 系统 
	CONST_DEFAULT_MATE                         = 0,
	-- [6]玩家/怪物初始化(方向)  -- 系统 
	CONST_DEFAULT_DIR                          = 6,
	-- [5000]默认银元  -- 系统 
	CONST_DEFAULT_GOLD                         = 5000,

	-- [1]玩家  -- 系统 
	CONST_PLAYER                               = 1,
	-- [2]伙伴  -- 系统 
	CONST_PARTNER                              = 2,
	-- [3]怪物  -- 系统 
	CONST_MONSTER                              = 3,
	-- [4]NPC  -- 系统 
	CONST_NPC                                  = 4,
	-- [5]宠物  -- 系统 
	CONST_PET                                  = 5,
	-- [6]传送点  -- 系统 
	CONST_TRANSPORT                            = 6,
	-- [7]离体攻击  -- 系统 
	CONST_VITRO                                = 7,
	-- [8]物品  -- 系统 
	CONST_GOODS                                = 8,
	-- [9]物品怪物  -- 系统 
	CONST_GOODS_MONSTER                        = 9,
	-- [10]雕像  -- 系统 
	CONST_DEFENSE                              = 10,
	-- [11]盒子怪兽  -- 系统 
	CONST_BOX_MONSTER                          = 11,
	-- [12]陷阱  -- 系统 
	CONST_HOOK                                 = 12,
	-- [13]滚动陷阱  -- 系统 
	CONST_TRAP                                 = 13,
	-- [14]组队雇佣 -- 系统 
	CONST_TEAM_HIRE                            = 14,

	-- [1]货币-铜钱  -- 系统 
	CONST_CURRENCY_GOLD                        = 1,
	-- [2]货币-元宝(人民币)  -- 系统 
	CONST_CURRENCY_RMB                         = 2,
	-- [3]货币-元宝(绑定元宝)  -- 系统 
	CONST_CURRENCY_RMB_BIND                    = 3,
	-- [4]货币-声望  -- 系统 
	CONST_CURRENCY_RENOWN                      = 4,
	-- [5]货币-精力  -- 系统 
	CONST_CURRENCY_ENERGY                      = 5,
	-- [6]货币-星魂  -- 系统 
	CONST_CURRENCY_SOUL_STAR                   = 6,
	-- [7]货币-战功  -- 系统 
	CONST_CURRENCY_ADV_SKILL                   = 7,
	-- [8]货币-紫色精魄  -- 系统 
	CONST_CURRENCY_SOUL_VIGOUR_PURPLE          = 8,
	-- [9]货币-金色精魄  -- 系统 
	CONST_CURRENCY_SOUL_VIGOUR_GOLD            = 9,
	-- [10]货币-橙色精魄  -- 系统 
	CONST_CURRENCY_SOUL_VIGOUR_ORANGE          = 10,
	-- [11]货币-红色精魄  -- 系统 
	CONST_CURRENCY_SOUL_VIGOUR_RED             = 11,
	-- [12]货币-战斗次数  -- 系统 
	CONST_CURRENCY_FIGHT_ALLOW                 = 12,
	-- [13]货币-经验  -- 系统 
	CONST_CURRENCY_EXP                         = 13,
	-- [14]货币-个人贡献  -- 系统 
	CONST_CURRENCY_DEVOTE                      = 14,
	-- [15]货币-神器碎片  -- 系统 
	CONST_CURRENCY_SYMBOL                      = 15,
	-- [16]货币-消费积分  -- 系统 
	CONST_CURRENCY_PAY_POINT                   = 16,
	-- [17]货币-体能  -- 系统 
	CONST_CURRENCY_TINENG                      = 17,
	-- [19]货币-竞技水晶  -- 系统 
	CONST_COMPETITIVE_PEBBLE                   = 19,
	-- [20]货币-斗魂  -- 系统 
	CONST_CURRENCY_DOUHUN                      = 20,
	-- [21]货币-至尊令  -- 系统 
	CONST_CURRENCY_YUXI                        = 21,
	-- [23]货币-元魂  -- 系统 
	CONST_CURRENCY_YUAN_HUN                    = 23,
	-- [24]货币-玄晶  -- 系统 
	CONST_CURRENCY_XUANJIN                     = 24,
	-- [25]货币-星石  -- 系统 
	CONST_CURRENCY_STONE                       = 25,
	-- [26]货币-荣誉 -- 系统 
	CONST_CURRENCY_HONE                        = 26,
	-- [27]货币-神源 -- 系统 
	CONST_CURRENCY_SHEN_YUAN                   = 27,
	-- [28]货币-红包 -- 系统 
	CONST_CURRENCY_HONGBAO                     = 28,
	-- [29]货币-属性点 -- 系统 
	CONST_CURRENCY_SHUXINGDIAN                 = 29,

	-- [46000]货币-铜钱 类型1 -- 系统 
	CONST_ZHUANHUAN_GOLD                       = 46000,
	-- [46100]货币-元宝(绑定元宝) 类型3 -- 系统 
	CONST_ZHUANHUAN_RMB_BIND                   = 46100,
	-- [46200]货币-声望 类型4 -- 系统 
	CONST_ZHUANHUAN_RENOWN                     = 46200,
	-- [46700]货币-经验 类型13 -- 系统 
	CONST_ZHUANHUAN_EXP                        = 46700,
	-- [46800]货币-元宝(人民币) 类型2 -- 系统 
	CONST_ZHUANHUAN_RMB                        = 46800,
	-- [46900]货币-个人贡献 类型14 -- 系统 
	CONST_ZHUANHUAN_DEVOTE                     = 46900,

	-- [0]职业-所有  -- 系统 
	CONST_PRO_NULL                             = 0,
	-- [1]职业-通臂白猿(棍)  -- 系统 
	CONST_PRO_ZHENGTAI                         = 1,
	-- [2]职业-千瓣莲女(环)  -- 系统 
	CONST_PRO_SUNMAN                           = 2,
	-- [3]职业-云游龙子(扇)  -- 系统 
	CONST_PRO_ICEGIRL                          = 3,
	-- [4]职业-飞天之舞(暂不开放)  -- 系统 
	CONST_PRO_BIGSISTER                        = 4,
	-- [5]职业-梦幻之星(暂不开放)  -- 系统 
	CONST_PRO_LOLI                             = 5,
	-- [6]职业-钢铁之躯(暂不开放)  -- 系统 
	CONST_PRO_MONSTER                          = 6,

	-- [0]性别-不限  -- 系统 
	CONST_SEX_NULL                             = 0,
	-- [1]性别-女生  -- 系统 
	CONST_SEX_MM                               = 1,
	-- [2]性别-男生  -- 系统 
	CONST_SEX_GG                               = 2,

	-- [0]阵营-无  -- 系统 
	CONST_COUNTRY_DEFAULT                      = 0,
	-- [1]阵营-魏  -- 系统 
	CONST_COUNTRY_ONE                          = 1,
	-- [2]阵营-蜀  -- 系统 
	CONST_COUNTRY_FAIRY                        = 2,
	-- [3]阵营-吴  -- 系统 
	CONST_COUNTRY_MAGIC                        = 3,

	-- [0]颜色-灰 -- 系统 
	CONST_COLOR_GREY                           = 0,
	-- [1]颜色-白 -- 系统 
	CONST_COLOR_WHITE                          = 1,
	-- [2]颜色-绿 -- 系统 
	CONST_COLOR_GREEN                          = 2,
	-- [3]颜色-蓝 -- 系统 
	CONST_COLOR_BLUE                           = 3,
	-- [4]颜色-紫 -- 系统 
	CONST_COLOR_VIOLET                         = 4,
	-- [5]颜色-金 -- 系统 
	CONST_COLOR_GOLD                           = 5,
	-- [6]颜色-橙 -- 系统 
	CONST_COLOR_ORANGE                         = 6,
	-- [7]颜色-红 -- 系统 
	CONST_COLOR_RED                            = 7,
	-- [8]颜色-青 -- 系统 
	CONST_COLOR_CYANBLUE                       = 8,
	-- [9]颜色-标签蓝 -- 系统 
	CONST_COLOR_LABELBLUE                      = 9,
	-- [10]颜色-棕色 -- 系统 
	CONST_COLOR_BROWN                          = 10,
	-- [11]颜色-中春绿 -- 系统 
	CONST_COLOR_SPRINGGREEN                    = 11,
	-- [12]颜色-中春黄 -- 系统 
	CONST_COLOR_BRIGHTYELLOW                   = 12,
	-- [13]颜色-暗紫 -- 系统 
	CONST_COLOR_DARKPURPLE                     = 13,
	-- [14]颜色-暗蓝 -- 系统 
	CONST_COLOR_DARKBLUE                       = 14,
	-- [15]颜色-暗金 -- 系统 
	CONST_COLOR_DARKGOLD                       = 15,
	-- [16]颜色-暗绿 -- 系统 
	CONST_COLOR_DARKGREEN                      = 16,
	-- [17]颜色-暗红 -- 系统 
	CONST_COLOR_DARKRED                        = 17,
	-- [18]颜色-暗白 -- 系统 
	CONST_COLOR_DARKWHITE                      = 18,
	-- [19]颜色-暗橙 -- 系统 
	CONST_COLOR_DARKORANGE                     = 19,
	-- [20]颜色-黄 -- 系统 
	CONST_COLOR_YELLOW                         = 20,
	-- [21]颜色-普蓝 -- 系统 
	CONST_COLOR_PBLUE                          = 21,
	-- [22]颜色-亮蓝 -- 系统 
	CONST_COLOR_LBLUE                          = 22,
	-- [23]颜色-普通描边 -- 系统 
	CONST_COLOR_PSTROKE                        = 23,
	-- [24]颜色-选中描边 -- 系统 
	CONST_COLOR_XSTROKE                        = 24,
	-- [25]颜色-橙红色 -- 系统 
	CONST_COLOR_ORED                           = 25,
	-- [26]颜色-橙色描边 -- 系统 
	CONST_COLOR_OSTROKE                        = 26,
	-- [27]颜色-灰蓝 -- 系统 
	CONST_COLOR_HBLUE                          = 27,
	-- [28]颜色-浅蓝 -- 系统 
	CONST_COLOR_LIGHTBLUE                      = 28,
	-- [29]颜色-天蓝 -- 系统 
	CONST_COLOR_SKYBLUE                        = 29,
	-- [30]颜色-土黄 -- 系统 
	CONST_COLOR_YELLOWISH                      = 30,
	-- [31]颜色-浅黄 -- 系统 
	CONST_COLOR_PALEGREEN                      = 31,
	-- [32]颜色-草绿 -- 系统 
	CONST_COLOR_GRASSGREEN                     = 32,

	-- [200]速度-角色  -- 系统 
	CONST_SPEED_PLAYER                         = 200,
	-- [260]速度-坐骑  -- 系统 
	CONST_SPEED_MOUNT                          = 260,
	-- [340]速度-怪物  -- 系统 
	CONST_SPEED_MONSTER                        = 340,

	-- [0]状态-正常(无状态)  -- 系统 
	CONST_PLAYER_FLAG_NORMAL                   = 0,
	-- [1]状态-战斗中  -- 系统 
	CONST_PLAYER_FLAG_WAR                      = 1,
	-- [2]状态-死亡  -- 系统 
	CONST_PLAYER_FLAG_DIE                      = 2,
	-- [3]状态-封神台  -- 系统 
	CONST_PLAYER_FLAG_ARENA                    = 3,
	-- [4]状态-洞府战  -- 系统 
	CONST_PLAYER_FLAG_CLANWAR                  = 4,
	-- [6]状态-挂机  -- 系统 
	CONST_PLAYER_FLAG_HOOK                     = 6,
	-- [9]状态-组队(是否是队长)  -- 系统 
	CONST_PLAYER_FLAG_TEAM_LEADER              = 9,
	-- [10]状态-红名  -- 系统 
	CONST_PLAYER_FLAG_RED                      = 10,

	-- [1]攻击类型-力量  -- 系统 
	CONST_ATTACK_DISTANCE_SHORT                = 1,
	-- [2]攻击类型-灵力  -- 系统 
	CONST_ATTACK_DISTANCE_LONG                 = 2,

	-- [1]名字蓝色  -- 系统 
	CONST_NAME_COLOR_BLUE                      = 1,
	-- [2]名字紫色  -- 系统 
	CONST_NAME_COLOR_VIOLET                    = 2,
	-- [3]名字金色  -- 系统 
	CONST_NAME_COLOR_GOLDEN                    = 3,

	-- [3]角色红色-杀戮值分界点，大于等于就红名  -- 系统 
	CONST_RED_NAME                             = 3,

	-- [10]等级1~10  -- 系统 
	CONST_GRADE_1_10                           = 10,
	-- [20]等级11~20  -- 系统 
	CONST_GRADE_11_20                          = 20,
	-- [30]等级21~30  -- 系统 
	CONST_GRADE_21_30                          = 30,
	-- [40]等级31~40  -- 系统 
	CONST_GRADE_31_40                          = 40,
	-- [50]等级41~50  -- 系统 
	CONST_GRADE_41_50                          = 50,
	-- [60]等级51~60  -- 系统 
	CONST_GRADE_51_60                          = 60,
	-- [70]等级61~70  -- 系统 
	CONST_GRADE_61_70                          = 70,
	-- [80]等级71~80  -- 系统 
	CONST_GRADE_71_80                          = 80,
	-- [90]等级81~90  -- 系统 
	CONST_GRADE_81_90                          = 90,
	-- [100]等级91~100  -- 系统 
	CONST_GRADE_91_100                         = 100,

	-- [1]怪物等阶-普通  -- 系统 
	CONST_MONSTER_RANK_NORMAL                  = 1,
	-- [2]怪物等阶-优秀  -- 系统 
	CONST_MONSTER_RANK_GOOD                    = 2,
	-- [3]怪物等阶-精英  -- 系统 
	CONST_MONSTER_RANK_ELITE                   = 3,
	-- [4]怪物等阶-精英boss  -- 系统 
	CONST_MONSTER_RANK_ELITE_LEADER            = 4,
	-- [5]怪物等阶-魔王boss  -- 系统 
	CONST_MONSTER_RANK_BOSS                    = 5,
	-- [6]怪物等阶-通关boss  -- 系统 
	CONST_MONSTER_RANK_BOSS_SUPER              = 6,
	-- [7]怪物等阶-世界boss  -- 系统 
	CONST_OVER_BOSS                            = 7,

	-- [1]怪物种族-普通怪:可移动可攻击的怪物  -- 系统 
	CONST_MONSTER_RACE_NORMAL                  = 1,
	-- [2]怪物种族-主角做怪物  -- 系统 
	CONST_MONSTER_RACE_PLAYER                  = 2,
	-- [5]怪物种族-采集怪:攻击此怪物不会进入战斗，只有采集进度条显示  -- 系统 
	CONST_MONSTER_RACE_COLLECT                 = 5,

	-- [1]怪物行为状态--站立  -- 系统 
	CONST_MONSTER_STATE_STAND                  = 1,
	-- [2]怪物行为状态--移动  -- 系统 
	CONST_MONSTER_STATE_MOVE                   = 2,
	-- [3]怪物出场方式--跳跃  -- 系统 
	CONST_MONSTER_JUMP                         = 3,
	-- [4]怪物出场方式--跑步  -- 系统 
	CONST_MONSTER_RUN                          = 4,
	-- [5]怪物出场方式--飞行 -- 系统 
	CONST_MONSTER_FLY                          = 5,
	-- [6]怪物出场方式--慢跑 -- 系统 
	CONST_MONSTER_SLRUN                        = 6,
	-- [7]怪物出场方式--爬出 -- 系统 
	CONST_MONSTER_CLIMB                        = 7,
	-- [8]怪物出场方式--落石 -- 系统 
	CONST_MONSTER_ROCKFALL                     = 8,
	-- [9]怪物出场方式--旋风 -- 系统 
	CONST_MONSTER_WHIRL                        = 9,
	-- [10]场景普通怪攻击半径  -- 系统 
	CONST_MONSTER_ATTACK_RADIUS                = 10,
	-- [11]怪物出场方式--爆炸 -- 系统 
	CONST_MONSTER_BOOM                         = 11,
	-- [12]怪物出场方式--播放技能 -- 系统 
	CONST_MONSTER_SKILL                        = 12,
	-- [13]怪物出场方式--残影  -- 系统 
	CONST_MONSTER_CANYING                      = 13,
	-- [14]怪物出场方式--爬出  -- 系统 
	CONST_MONSTER_PACHU                        = 14,
	-- [15]怪物出场方式--棺材 -- 系统 
	CONST_MONSTER_GUANCAI                      = 15,
	-- [16]怪物出场方式--爬跳 -- 系统 
	CONST_MONSTER_PATIAO                       = 16,
	-- [17]怪物出场方式--飓风 -- 系统 
	CONST_MONSTER_JUFENG                       = 17,
	-- [18]怪物出场方式--慢跑 -- 系统 
	CONST_MONSTER_MANPAO                       = 18,
	-- [19]怪物出场方式--快跑 -- 系统 
	CONST_MONSTER_KUAIPAO                      = 19,
	-- [20]怪物出场方式--小跳 -- 系统 
	CONST_MONSTER_XIAOTIAO                     = 20,
	-- [21]怪物出场方式--大跳 -- 系统 
	CONST_MONSTER_DATIAO                       = 21,
	-- [1001]怪物出场方式--罐子  -- 系统 
	CONST_MONSTER_POT                          = 1001,
	-- [1002]怪物出场方式--木箱  -- 系统 
	CONST_MONSTER_CASE                         = 1002,
	-- [1003]怪物出场方式--铁箱  -- 系统 
	CONST_MONSTER_IRON                         = 1003,
	-- [1004]怪物出场方式--木盒  -- 系统 
	CONST_MONSTER_BOX                          = 1004,
	-- [1005]怪物出场方式--木桶  -- 系统 
	CONST_MONSTER_VAT                          = 1005,
	-- [1006]怪物出场方式--弩车  -- 系统 
	CONST_MONSTER_NUCHE                        = 1006,

	-- [1]方向--西南  -- 系统 
	CONST_DIRECTION_SOUTHWEST                  = 1,
	-- [2]方向--南  -- 系统 
	CONST_DIRECTION_SOUTH                      = 2,
	-- [3]方向--东南  -- 系统 
	CONST_DIRECTION_SOUTHEAST                  = 3,
	-- [4]方向--西(右)  -- 系统 
	CONST_DIRECTION_WEST                       = 4,
	-- [5]方向--中心  -- 系统 
	CONST_DIRECTION_CENTER                     = 5,
	-- [6]方向--东(左)  -- 系统 
	CONST_DIRECTION_EAST                       = 6,
	-- [7]方向--西北  -- 系统 
	CONST_DIRECTION_NORTHWEST                  = 7,
	-- [8]方向--北  -- 系统 
	CONST_DIRECTION_NORTH                      = 8,
	-- [9]方向--东北  -- 系统 
	CONST_DIRECTION_NORTHEAST                  = 9,

	-- [1]系统开放类型-等级  -- 系统 
	CONST_SYS_LV                               = 1,
	-- [2]系统开放类型-任务  -- 系统 
	CONST_SYS_TASK                             = 2,

	-- [0]各种FALSE  -- 系统 
	CONST_FALSE                                = 0,
	-- [1]各种TRUE  -- 系统 
	CONST_TRUE                                 = 1,

	-- [100]百分比,转换速算数(如:5978 除以本速算数5978/100=59.78%) Ps:主要是前端用  -- 系统 
	CONST_PERCENT_FAST                         = 100,
	-- [10000]百分比分母(100为1% 10000为100%))  -- 系统 
	CONST_PERCENT                              = 10000,

	-- [10]客户端类型-网页  -- 系统 
	CONST_CLIENT_WEB                           = 10,
	-- [20]客户端类型-富媒体  -- 系统 
	CONST_CLIENT_AIR                           = 20,
	-- [30]客户端类型-微端  -- 系统 
	CONST_CLIENT_WIN                           = 30,
	-- [40]客户端类型-WinPhone  -- 系统 
	CONST_CLIENT_WP                            = 40,
	-- [80]客户端类型-iOS  -- 系统 
	CONST_CLIENT_IOS                           = 80,
	-- [120]客户端类型-Android  -- 系统 
	CONST_CLIENT_ANDROID                       = 120,

	-- [0]开放时间类型-永久开放  -- 系统 
	CONST_TYPE_TIME_ALWAYS                     = 0,
	-- [1]开放时间类型-按西元日期时间(开始结束)  -- 系统 
	CONST_TYPE_TIME_GREGORY                    = 1,
	-- [2]开放时间类型-按周开放  -- 系统 
	CONST_TYPE_TIME_WEEK                       = 2,
	-- [3]开放时间类型-按月开放  -- 系统 
	CONST_TYPE_TIME_MONTH                      = 3,

	-- [1]左对齐  -- 系统 
	CONST_ALIGN_LEFT                           = 1,
	-- [2]右对齐  -- 系统 
	CONST_ALIGN_RIGHT                          = 2,
	-- [3]上对齐  -- 系统 
	CONST_ALIGN_TOP                            = 3,
	-- [4]下对齐  -- 系统 
	CONST_ALIGN_DOWN                           = 4,
	-- [5]左上对齐  -- 系统 
	CONST_ALIGN_LEFTANDTOP                     = 5,
	-- [6]右上对齐  -- 系统 
	CONST_ALIGN_RIGHTANDTOP                    = 6,
	-- [7]左下对齐  -- 系统 
	CONST_ALIGN_LEFTANDDOWN                    = 7,
	-- [8]右下对齐  -- 系统 
	CONST_ALIGN_RIGHTANDDOWN                   = 8,

	-- [1]步兵  -- 系统 
	CONST_INFANTRY                             = 1,
	-- [2]弓箭手  -- 系统 
	CONST_ARCHER                               = 2,
	-- [3]骑兵  -- 系统 
	CONST_CAVALRY                              = 3,

	-- [3]心跳时间  -- 系统 
	CONST_HEART_TIME                           = 3,

	--------------------------------------------------------------------
	-- ( 物品 ) 
	--------------------------------------------------------------------
	-- [6]次数物品日志数量(鞭炮)  -- 物品 
	CONST_GOODS_TIMES_GOODS_LOGS               = 6,
	-- [13]装备栏容量  -- 物品 
	CONST_GOODS_ACTION_EQUIP                   = 13,

	-- [2033]物品ID-小喇叭  -- 物品 
	CONST_GOODS_ID_TRUM                        = 2033,
	-- [9504]物品ID-镇兽石  -- 物品 
	CONST_GOODS_ID_PROTECT                     = 9504,
	-- [47001]物品id-将星  -- 物品 
	CONST_GOODS_START                          = 47001,
	-- [57001]物品ID-汤圆  -- 物品 
	CONST_GOODS_ID_TANGYUAN                    = 57001,
	-- [57006]物品ID-乳猪  -- 物品 
	CONST_GOODS_ID_RUZHU                       = 57006,

	-- [1]背包  -- 物品 
	CONST_GOODS_CONTAINER_BAG                  = 1,
	-- [2]装备  -- 物品 
	CONST_GOODS_CONTAINER_EQUIP                = 2,
	-- [3]临时背包  -- 物品 
	CONST_GOODS_CONTAINER_DEPOT                = 3,
	-- [4]开宝箱仓库  -- 物品 
	CONST_GOODS_CONTAINER_CHEST_BAG            = 4,
	-- [5]战斗临时背包  -- 物品 
	CONST_GOODS_CONTAINER_TEMP_BAG             = 5,
	-- [6]购回背包 -- 物品 
	CONST_GOODS_CONTAINER_BUY_BACK             = 6,

	-- [1]类型-装备  -- 物品 
	CONST_GOODS_EQUIP                          = 1,
	-- [2]装备-武器  -- 物品 
	CONST_GOODS_WEAPON                         = 2,
	-- [3]类型-宝石  -- 物品 
	CONST_GOODS_STERS                          = 3,
	-- [4]类型-材料  -- 物品 
	CONST_GOODS_MATERIAL                       = 4,
	-- [5]类型-神器  -- 物品 
	CONST_GOODS_MAGIC                          = 5,
	-- [6]类型-普通  -- 物品 
	CONST_GOODS_ORD                            = 6,
	-- [7]类型-武将  -- 物品 
	CONST_GOODS_MOUNT                          = 7,
	-- [8]类型-卦象 -- 物品 
	CONST_GOODS_HOLIDAY                        = 8,
	-- [9]类型-被卖出  -- 物品 
	CONST_GOODS_SALE                           = 9,

	-- [11]装备-戒指  -- 物品 
	CONST_GOODS_EQUIP_HAT                      = 11,
	-- [12]装备-项链  -- 物品 
	CONST_GOODS_EQUIP_CLOAK                    = 12,
	-- [13]装备-鞋子  -- 物品 
	CONST_GOODS_EQUIP_SHOE                     = 13,
	-- [14]装备-头盔  -- 物品 
	CONST_GOODS_EQUIP_ARMOR                    = 14,
	-- [15]装备-衣服  -- 物品 
	CONST_GOODS_EQUIP_CLOTHES                  = 15,
	-- [16]装备-武器-鹭、弓箭  -- 物品 
	CONST_GOODS_EQUIP_WEAPON_STICK             = 16,
	-- [16]装备-武器-剑、长枪  -- 物品 
	CONST_GOODS_EQUIP_WEAPON_GUN               = 16,
	-- [16]装备-武器-斧、大刀  -- 物品 
	CONST_GOODS_EQUIP_WEAPON_BOW               = 16,
	-- [51]装备-神器-真元  -- 物品 
	CONST_GOODS_GOD_WINDS                      = 51,
	-- [52]装备-神器-时装  -- 物品 
	CONST_GOODS_GOD_TWO                        = 52,
	-- [53]装备-神器-洪荒  -- 物品 
	CONST_GOODS_GOD_THREE                      = 53,
	-- [54]装备-神器-秘典  -- 物品 
	CONST_GOODS_GOD_FOUR                       = 54,
	-- [55]装备-神器-奇谋  -- 物品 
	CONST_GOODS_GOD_FIVE                       = 55,
	-- [56]装备-神器-剑灵  -- 物品 
	CONST_GOODS_GOD_SIX                        = 56,
	-- [70]材料-宝石卷轴  -- 物品 
	CONST_GOODS_MATERIAL_MATERIAL              = 70,
	-- [71]材料-普通材料  -- 物品 
	CONST_GOODS_BLESS                          = 71,
	-- [73]材料-珍宝卷轴  -- 物品 
	CONST_GOODS_PROTECTION                     = 73,
	-- [75]材料-神器祝福油  -- 物品 
	CONST_GOODS_DEBRIS                         = 75,
	-- [76]神器材料-保护符  -- 物品 
	CONST_GOODS_PROTECT_OPERATOR               = 76,
	-- [77]神器材料-虎符  -- 物品 
	CONST_GOODS_DECORATION                     = 77,
	-- [78]神器材料-碎片  -- 物品 
	CONST_GOODS_FRAGMENT                       = 78,
	-- [79]神器材料-圣水  -- 物品 
	CONST_GOODS_HOLY_WATER                     = 79,
	-- [80]神羽-材料-翎毛 -- 物品 
	CONST_GOODS_FEATHER_UPGRADE                = 80,
	-- [81]神羽-材料-升阶丹 -- 物品 
	CONST_GOODS_FEATHER_UPSTEP                 = 81,
	-- [111]宝石-紫宝石（气血）  -- 物品 
	CONST_GOODS_STERS_HP                       = 111,
	-- [112]宝石-月光石（攻击）  -- 物品 
	CONST_GOODS_STERS_STRONG                   = 112,
	-- [113]宝石-水晶石（防御）  -- 物品 
	CONST_GOODS_STERS_STR_DEF                  = 113,
	-- [114]宝石-橙宝石（破甲）  -- 物品 
	CONST_GOODS_STERS_DEF_DOWN                 = 114,
	-- [115]宝石-伤害石（命中）  -- 物品 
	CONST_GOODS_STERS_HARM                     = 115,
	-- [116]宝石-青绿石（闪避）  -- 物品 
	CONST_GOODS_STERS_REDUCTION                = 116,
	-- [117]宝石-绿宝石（暴击）  -- 物品 
	CONST_GOODS_STERS_CRIT                     = 117,
	-- [118]宝石-黄宝石（抗暴）  -- 物品 
	CONST_GOODS_STERS_RES_CRIT                 = 118,
	-- [119]宝石-伤害石（伤害）  -- 物品 
	CONST_GOODS_STERS_SHANG                    = 119,
	-- [120]宝石-免伤石（免伤）  -- 物品 
	CONST_GOODS_STERS_MIAN                     = 120,
	-- [131]普通-礼包  -- 物品 
	CONST_GOODS_COMMON_GIFT                    = 131,
	-- [132]普通-宝盒  -- 物品 
	CONST_GOODS_COMMON_BOX                     = 132,
	-- [133]普通-钱袋  -- 物品 
	CONST_GOODS_COMMON_MONEY_BAG               = 133,
	-- [134]普通-附魔石 -- 物品 
	CONST_GOODS_COMMON_EXP                     = 134,
	-- [135]普通-装备进阶  -- 物品 
	CONST_GOODS_COMMON_PAR_EXP                 = 135,
	-- [136]普通-坐骑经验丹  -- 物品 
	CONST_GOODS_COMMON_MOUNT_EXP               = 136,
	-- [137]普通-虚拟货币  -- 物品 
	CONST_GOODS_IDEAL_GET                      = 137,
	-- [138]普通-伙伴卡  -- 物品 
	CONST_GOODS_COMMON_PARTNER_CARD            = 138,
	-- [139]普通-悬赏任务卡 -- 物品 
	CONST_GOODS_COMMON_RESET_SKILL             = 139,
	-- [140]普通-VIP体验  -- 物品 
	CONST_GOODS_VIP                            = 140,
	-- [141]普通-卦象宝盒类  -- 物品 
	CONST_GOODS_WHEEL_GOODS                    = 141,
	-- [142]普通-卦象升阶 -- 物品 
	CONST_GOODS_LV_GOODS                       = 142,
	-- [143]普通-美人类  -- 物品 
	CONST_GOODS_PET_CARD                       = 143,
	-- [144]普通-真元 -- 物品 
	CONST_GOODS_ZHENFA                         = 144,
	-- [145]普通-增益类  -- 物品 
	CONST_GOODS_BUFF                           = 145,
	-- [146]普通-话费类  -- 物品 
	CONST_GOODS_HUAFEI                         = 146,
	-- [147]普通-宝石碎片  -- 物品 
	CONST_GOODS_BAOSHISUIPIAN                  = 147,
	-- [148]普通-洗练石  -- 物品 
	CONST_GOODS_STONE_WASH                     = 148,
	-- [149]普通-更名卡  -- 物品 
	CONST_GOODS_GENGMINGKA                     = 149,
	-- [150]节日兑换物品  -- 物品 
	CONST_GOODS_HOLIDAY_GOOD                   = 150,
	-- [151]普通-增益类(主城使用)  -- 物品 
	CONST_GOODS_BUFF_CITY                      = 151,
	-- [152]普通-商店兑换  -- 物品 
	CONST_GOODS_STORE_EXCHANGE                 = 152,
	-- [153]普通-商店兑换  -- 物品 
	CONST_GOODS_STORE_EXCHANGES                = 153,
	-- [154]特殊-礼包优惠  -- 物品 
	CONST_GOODS_SPECIAL_LIBAO                  = 154,
	-- [155]特殊-充值优惠 -- 物品 
	CONST_GOODS_SPECIAL_CHONGZHI               = 155,
	-- [158]特殊-充值优惠 -- 物品 
	CONST_GOODS_LABA                           = 158,
	-- [160]灵妖碎片 -- 物品 
	CONST_GOODS_LINGYAOSUIPIAN                 = 160,

	-- [0]容器-全部取出  -- 物品 
	CONST_GOODS_ACTION_ALL                     = 0,
	-- [1]容器-部分取出  -- 物品 
	CONST_GOODS_ACTION_PART                    = 1,
	-- [3]容器-数量不足  -- 物品 
	CONST_GOODS_ACTION_LACK                    = 3,
	-- [4]容器-已满  -- 物品 
	CONST_GOODS_ACTION_FULL                    = 4,

	-- [500]背包开格数  -- 物品 
	CONST_GOODS_BAG_MAX                        = 500,
	-- [500]临时背包开格数  -- 物品 
	CONST_GOODS_TEMP_BAG                       = 500,

	-- [1]等级段常量-1-9级  -- 物品 
	CONST_GOODS_RANGE_LV_ONE                   = 1,
	-- [2]等级段常量,10-19级  -- 物品 
	CONST_GOODS_RANGE_LV_TWO                   = 2,
	-- [3]等级段常量 20-29级  -- 物品 
	CONST_GOODS_RANGE_LV_THREE                 = 3,
	-- [4]等级段常量-30-39级  -- 物品 
	CONST_GOODS_RANGE_LV_FOUR                  = 4,
	-- [5]等级段常量-40-49级  -- 物品 
	CONST_GOODS_RANGE_LV_FIVE                  = 5,
	-- [6]等级段常量-50-59级  -- 物品 
	CONST_GOODS_RANGE_LV_SIX                   = 6,
	-- [7]等级段常量-60-69级  -- 物品 
	CONST_GOODS_RANGE_LV_SEVEN                 = 7,
	-- [8]等级段常量-70-79级  -- 物品 
	CONST_GOODS_RANGE_LV_EIGHT                 = 8,
	-- [9]等级段常量-80-89级  -- 物品 
	CONST_GOODS_RANGE_LV_NIGHT                 = 9,
	-- [10]等级段常量-90-99级  -- 物品 
	CONST_GOODS_RANGE_LV_TEN                   = 10,
	-- [11]等级段常量-100-109级  -- 物品 
	CONST_GOODS_RANGE_LV_ELE                   = 11,
	-- [12]等级段常量-110-119级  -- 物品 
	CONST_GOODS_RANGE_LV_TWL                   = 12,

	-- [0]Tips位置-在其他位置，只能查看信息，无按钮  -- 物品 
	CONST_GOODS_SITE_OTHERROLE                 = 0,
	-- [1]Tips位置-在背包中  -- 物品 
	CONST_GOODS_SITE_BACKPACK                  = 1,
	-- [2]Tips位置-在人物身上打开 -- 物品 
	CONST_GOODS_SITE_PLAYER                    = 2,
	-- [3]Tips位置-在角色身上背包中  -- 物品 
	CONST_GOODS_SITE_ROLEBACKPACK              = 3,
	-- [4]Tips位置-在神器界面中  -- 物品 
	CONST_GOODS_SITE_ARTIFACT                  = 4,
	-- [5]Tips位置-在珍宝界面中 取出  -- 物品 
	CONST_GOODS_SITE_TREASUREUNLOAD            = 5,
	-- [6]Tips位置-在珍宝界面中 放入  -- 物品 
	CONST_GOODS_SITE_TREASURELOAD              = 6,
	-- [7]背包购回 -- 物品 
	CONST_GOODS_SITE_GOODSELL                  = 7,
	-- [8]Tips位置-在镶嵌界面打开  -- 物品 
	CONST_GOODS_SITE_INLAID                    = 8,
	-- [9]Tips位置-在镶嵌背包打开  -- 物品 
	CONST_GOODS_SITE_INLAIDBAG                 = 9,

	-- [56100]物品ID-三星S5  -- 物品 
	CONST_GOODS_ID_S5                          = 56100,
	-- [56105]物品ID-苹果5S  -- 物品 
	CONST_GOODS_ID_5S                          = 56105,

	-- [137]虚拟物品-子类  -- 物品 
	CONST_GOODS_VIRTUAL_GOODS_SUB              = 137,

	--------------------------------------------------------------------
	-- ( 装备 ) 
	--------------------------------------------------------------------
	-- [7]坐骑  -- 装备 
	CONST_EQUIP_MOUNT                          = 7,
	-- [11]戒指 -- 装备 
	CONST_EQUIP_RING                           = 11,
	-- [12]项链  -- 装备 
	CONST_EQUIP_NECKLACE                       = 12,
	-- [13]鞋子  -- 装备 
	CONST_EQUIP_SHOE                           = 13,
	-- [14]头盔 -- 装备 
	CONST_EQUIP_ARMOR                          = 14,
	-- [15]衣服 -- 装备 
	CONST_EQUIP_CLOAK                          = 15,
	-- [16]武器  -- 装备 
	CONST_EQUIP_WEAPON                         = 16,

	-- [8]特殊  -- 装备 
	CONST_EQUIP_PET                            = 8,

	-- [3]VIP开发等级  -- 装备 
	CONST_EQUIP_ENCHANT_VIP                    = 3,

	-- [2]附魔初次消耗元宝  -- 装备 
	CONST_EQUIP_ENCHANT_RMB                    = 2,
	-- [25]附魔按钮打开等级  -- 装备 
	CONST_EQUIP_ENCHANT_OPEN                   = 25,

	--------------------------------------------------------------------
	-- ( 场景 ) 
	--------------------------------------------------------------------
	-- [60]默认地图X  -- 场景 
	CONST_MAP_DEFAULT_POSX                     = 60,
	-- [105]战船地图ID  -- 场景 
	CONST_MAP_ZHANCHUAN                        = 105,
	-- [160]默认地图Y  -- 场景 
	CONST_MAP_DEFAULT_POSY                     = 160,
	-- [10100]默认地图ID  -- 场景 
	CONST_MAP_DEFAULT_MAP                      = 10100,
	-- [10200]桃园村地图ID  -- 场景 
	CONST_MAP_TAOYUANCUN                       = 10200,

	-- [0]场景坐标标识--不可行走  -- 场景 
	CONST_MAP_WALK_NO                          = 0,
	-- [0.5]地图检查时间间隔(单位秒)  -- 场景 
	CONST_MAP_INTERVAL_SECONDS                 = 0.5,
	-- [1]场景坐标标识--可行走  -- 场景 
	CONST_MAP_WALK_YES                         = 1,
	-- [2]场景坐标标识--可行走(半透明)  -- 场景 
	CONST_MAP_WALK_HALF                        = 2,
	-- [3]发送失败次数上限，列表删除  -- 场景 
	CONST_MAP_MAP_SEND_LOSE_MAX                = 3,
	-- [10]地图一个格子的像素  -- 场景 
	CONST_MAP_MAP_TILE_PIXEL                   = 10,
	-- [15]地图最大人数(世界boss)  -- 场景 
	CONST_MAP_BOSS_MAX_COUNT                   = 15,
	-- [25]地图最大人数(场景)  -- 场景 
	CONST_MAP_MAP_MAX_COUNT                    = 25,
	-- [50]地图坐标间隔距离(大于这个数，就会提示相距太远)  -- 场景 
	CONST_MAP_MAP_DISTANCE_MOVE                = 50,
	-- [100]地图时间间隔,清理一次,没人关闭进程(秒)  -- 场景 
	CONST_MAP_MAP_TIME_SLOT                    = 100,

	-- [1]进入-正常（新上线/换地图）  -- 场景 
	CONST_MAP_ENTER_NULL                       = 1,
	-- [2]进入-副本  -- 场景 
	CONST_MAP_ENTER_COPY                       = 2,
	-- [3]进入-瞬移  -- 场景 
	CONST_MAP_ENTER_TELEPORT                   = 3,
	-- [4]进入-校正(服务器拉)  -- 场景 
	CONST_MAP_ENTER_CHECK                      = 4,
	-- [5]进入-剧情  -- 场景 
	CONST_MAP_ENTER_DRAMA                      = 5,

	-- [1]传送门类型 - 进地图  -- 场景 
	CONST_MAP_DOOR_MAP                         = 1,
	-- [2]传送门类型 - 打开面板  -- 场景 
	CONST_MAP_DOOR_OPEN                        = 2,
	-- [3]传送门类型 - 进入下层副本  -- 场景 
	CONST_MAP_DOOR_NEXT_COPY                   = 3,
	-- [4]传送门类型 - 退出副本  -- 场景 
	CONST_MAP_DOOR_EXIT_COPY                   = 4,

	-- [1]离开-正常（下线/换地图）  -- 场景 
	CONST_MAP_OUT_NULL                         = 1,
	-- [2]离开-死亡  -- 场景 
	CONST_MAP_OUT_DIE                          = 2,
	-- [3]离开-瞬移  -- 场景 
	CONST_MAP_OUT_TELEPORT                     = 3,
	-- [4]离开-校正(服务器拉)  -- 场景 
	CONST_MAP_OUT_CHECK                        = 4,

	-- [1020]体力 -- 场景 
	CONST_MAP_ENARGY                           = 1020,
	-- [1030]邮件 -- 场景 
	CONST_MAP_MALL                             = 1030,
	-- [1040]聊天 -- 场景 
	CONST_MAP_CHATTING                         = 1040,
	-- [1050]排行榜 -- 场景 
	CONST_MAP_PAIHANG                          = 1050,
	-- [1060]攻略 -- 场景 
	CONST_MAP_STRATEGY                         = 1060,
	-- [1061]攻略-活动日历 -- 场景 
	CONST_MAP_STRATEGY_CALENDAR                = 1061,
	-- [1062]攻略-今日活跃 -- 场景 
	CONST_MAP_STRATEGY_ACTIVE                  = 1062,
	-- [1063]攻略-我要变强 -- 场景 
	CONST_MAP_STRATEGY_STRONG                  = 1063,
	-- [1070]设置 -- 场景 
	CONST_MAP_SETING                           = 1070,
	-- [1071]更新公告 -- 场景 
	CONST_MAP_SETING_UPDATE                    = 1071,
	-- [1072]联系GM -- 场景 
	CONST_MAP_SETING_CONTACT_GM                = 1072,
	-- [1073]提交BUG -- 场景 
	CONST_MAP_SETING_SUBMIT_BUG                = 1073,
	-- [1074]微信绑定 -- 场景 
	CONST_MAP_SETING_WEIXING                   = 1074,
	-- [2010]角色 -- 场景 
	CONST_MAP_ROLE                             = 2010,
	-- [2011]角色-属性 -- 场景 
	CONST_MAP_ROLE_ATTRIBUTE                   = 2011,
	-- [2012]角色-装备 -- 场景 
	CONST_MAP_ROLE_EQUIP                       = 2012,
	-- [2013]角色-技能 -- 场景 
	CONST_MAP_ROLE_SKILL                       = 2013,
	-- [2014]角色-金身 -- 场景 
	CONST_MAP_ROLE_GOLD                        = 2014,
	-- [2015]角色-称号 -- 场景 
	CONST_MAP_ROLE_TITLE                       = 2015,
	-- [2016]器灵 -- 场景 
	CONST_MAP_QILING                           = 2016,
	-- [2017]神羽 -- 场景 
	CONST_MAP_FEATHER                          = 2017,
	-- [2020]湛卢坊 -- 场景 
	CONST_MAP_SMITHY                           = 2020,
	-- [2021]湛卢坊-强化 -- 场景 
	CONST_MAP_SMITHY_STRENGTHEN                = 2021,
	-- [2022]湛卢坊-升品 -- 场景 
	CONST_MAP_SMITHY_QUALITY                   = 2022,
	-- [2023]湛卢坊-镶嵌 -- 场景 
	CONST_MAP_SMITHY_INLAY                     = 2023,
	-- [2024]湛卢坊-分解 -- 场景 
	CONST_MAP_SMITHY_RESOLVE                   = 2024,
	-- [2025]湛卢坊-附魔 -- 场景 
	CONST_MAP_SMITHY_ENCHANTS                  = 2025,
	-- [2030]神兵 -- 场景 
	CONST_MAP_ARTIFACT                         = 2030,
	-- [2031]神兵-装备 -- 场景 
	CONST_MAP_ARTIFACT_EQUIP                   = 2031,
	-- [2032]神兵-强化 -- 场景 
	CONST_MAP_ARTIFACT_STRENGTHEN              = 2032,
	-- [2033]神兵-升阶 -- 场景 
	CONST_MAP_ARTIFACT_QUALITY                 = 2033,
	-- [2034]神兵-洗练 -- 场景 
	CONST_MAP_ARTIFACT_WASH                    = 2034,
	-- [2040]坐骑 -- 场景 
	CONST_MAP_MOUNT                            = 2040,
	-- [2050]真元 -- 场景 
	CONST_MAP_WING                             = 2050,
	-- [2060]珍宝 -- 场景 
	CONST_MAP_JEWELLERY                        = 2060,
	-- [2070]背包 -- 场景 
	CONST_MAP_BAG                              = 2070,
	-- [2071]背包-道具 -- 场景 
	CONST_MAP_BAG_PROP                         = 2071,
	-- [2072]背包-宝石 -- 场景 
	CONST_MAP_BAG_GEM                          = 2072,
	-- [2073]背包-装备 -- 场景 
	CONST_MAP_BAG_EQUIP                        = 2073,
	-- [2074]背包-购回 -- 场景 
	CONST_MAP_BAG_REPURCHASE                   = 2074,
	-- [2075]背包-合成 -- 场景 
	CONST_MAP_BAG_COMPOSE                      = 2075,
	-- [2080]美人 -- 场景 
	CONST_MAP_BEAUTY                           = 2080,
	-- [2090]任务 -- 场景 
	CONST_MAP_TASK                             = 2090,
	-- [2091]任务-主线 -- 场景 
	CONST_MAP_TASK_THREAD                      = 2091,
	-- [2092]任务-支线 -- 场景 
	CONST_MAP_TASK_FEEDER                      = 2092,
	-- [2093]任务-悬赏 -- 场景 
	CONST_MAP_TASK_DAILY                       = 2093,
	-- [2100]卦象 -- 场景 
	CONST_MAP_SHEN                             = 2100,
	-- [2101]卦象-升级 -- 场景 
	CONST_MAP_SHEN_UP                          = 2101,
	-- [2102]卦象-升品 -- 场景 
	CONST_MAP_SHEN_QUALITY                     = 2102,
	-- [2110]守护 -- 场景 
	CONST_MAP_PARTNER                          = 2110,
	-- [2111]守护-属性 -- 场景 
	CONST_MAP_PARTNER_ATTRIBUTE                = 2111,
	-- [2112]守护-图鉴 -- 场景 
	CONST_MAP_PARTNER_ATLAS                    = 2112,
	-- [2113]守护-进阶 -- 场景 
	CONST_MAP_PARTNER_ADVANCED                 = 2113,
	-- [2114]守护-炼魂 -- 场景 
	CONST_MAP_PARTNER_SOUL                     = 2114,
	-- [2115]守护-助阵 -- 场景 
	CONST_MAP_PARTNER_CHEER                    = 2115,
	-- [2120]仙宠灵兽 -- 场景 
	CONST_MAP_DAEMON                           = 2120,
	-- [3010]洞府 -- 场景 
	CONST_MAP_GANGS                            = 3010,
	-- [3012]洞府活动-洞府守护神 -- 场景 
	CONST_MAP_GANGS_BOSS                       = 3012,
	-- [3013]洞府活动-保卫圣兽堂 -- 场景 
	CONST_MAP_GANGS_DEFEND                     = 3013,
	-- [3014]洞府活动-洞府大战 -- 场景 
	CONST_MAP_GANGS_WAR                        = 3014,
	-- [3015]洞府活动-占山为王 -- 场景 
	CONST_MAP_GANGS_KING                       = 3015,
	-- [3020]好友 -- 场景 
	CONST_MAP_FRIEND                           = 3020,
	-- [3021]好友-祝福 -- 场景 
	CONST_MAP_FRIEND_WISH                      = 3021,
	-- [3030]竞技场 -- 场景 
	CONST_MAP_ARENA                            = 3030,
	-- [3040]奴仆 -- 场景 
	CONST_MAP_MOIL                             = 3040,
	-- [3050]通天浮屠 -- 场景 
	CONST_MAP_TOWER                            = 3050,
	-- [3060]浮屠静修 -- 场景 
	CONST_MAP_JINGXIU                          = 3060,
	-- [3070]封神榜 -- 场景 
	CONST_MAP_MYTH                             = 3070,
	-- [3080]大闹天宫 -- 场景 
	CONST_MAP_WELKIN                           = 3080,
	-- [3081]大闹天宫-问鼎天宫 -- 场景 
	CONST_MAP_WELKIN_FIRST                     = 3081,
	-- [3082]大闹天宫-决战凌霄 -- 场景 
	CONST_MAP_WELKIN_BATTLE                    = 3082,
	-- [3083]大闹天宫-独尊三界 -- 场景 
	CONST_MAP_WELKIN_ONLY                      = 3083,
	-- [3090]三界争锋 -- 场景 
	CONST_MAP_STRIVE                           = 3090,
	-- [3100]副本 -- 场景 
	CONST_MAP_COPY                             = 3100,
	-- [3101]副本-剧情 -- 场景 
	CONST_MAP_COPY_COMMON                      = 3101,
	-- [3102]副本-噩梦 -- 场景 
	CONST_MAP_COPY_NIGHTMARE                   = 3102,
	-- [3103]副本-地狱 -- 场景 
	CONST_MAP_COPY_HELL                        = 3103,
	-- [3104]副本-珍宝 -- 场景 
	CONST_MAP_COPY_JEWELLERY                   = 3104,
	-- [3110]群仙诛邪 -- 场景 
	CONST_MAP_TEAM                             = 3110,
	-- [3120]无限心魔 -- 场景 
	CONST_MAP_DEMONS                           = 3120,
	-- [3130]三界妖王 -- 场景 
	CONST_MAP_BOSS                             = 3130,
	-- [3131]三界妖王-世界 -- 场景 
	CONST_MAP_BOSS_SHIJIE                      = 3131,
	-- [3132]三界妖王-城镇 -- 场景 
	CONST_MAP_BOSS_CHENGZHEN                   = 3132,
	-- [3140]降魔之路 -- 场景 
	CONST_MAP_SURRENDER                        = 3140,
	-- [3150]秘宝活动 -- 场景 
	CONST_MAP_BOX                              = 3150,
	-- [3160]灵妖竞技 -- 场景 
	CONST_MAP_LYJJ                             = 3160,
	-- [3170]道劫 -- 场景 
	CONST_MAP_DAOJIE                           = 3170,
	-- [4010]转盘抽奖 -- 场景 
	CONST_MAP_TURNTABLE                        = 4010,
	-- [4020]祈福 -- 场景 
	CONST_MAP_LUCKY                            = 4020,
	-- [4030]对对牌 -- 场景 
	CONST_MAP_CARDS                            = 4030,
	-- [4040]翻翻乐 -- 场景 
	CONST_MAP_GAMBLE                           = 4040,
	-- [4050]限时抢购 -- 场景 
	CONST_MAP_RUSH                             = 4050,
	-- [4060]拍卖活动 -- 场景 
	CONST_MAP_AUCTION                          = 4060,
	-- [4070]精彩返利 -- 场景 
	CONST_MAP_REBATE                           = 4070,
	-- [4080]节日活动 -- 场景 
	CONST_MAP_HOLIDAY                          = 4080,
	-- [4081]节日活动-节日转盘 -- 场景 
	CONST_MAP_HOLIDAY_TURNTABLE                = 4081,
	-- [4082]节日活动-一字千金 -- 场景 
	CONST_MAP_HOLIDAY_VALUELESS                = 4082,
	-- [4083]节日活动-登陆送礼 -- 场景 
	CONST_MAP_HOLIDAY_GIVE                     = 4083,
	-- [4090]福利 -- 场景 
	CONST_MAP_WELFARE                          = 4090,
	-- [4091]签到奖励 -- 场景 
	CONST_MAP_REWARD_SIGN                      = 4091,
	-- [4092]在线奖励 -- 场景 
	CONST_MAP_REWARD_ON_LINE                   = 4092,
	-- [4093]等级奖励 -- 场景 
	CONST_MAP_REWARD_LV                        = 4093,
	-- [4100]礼包码 -- 场景 
	CONST_MAP_NOVICE                           = 4100,
	-- [4110]科举 -- 场景 
	CONST_MAP_EXAMINATION                      = 4110,
	-- [4120]开服七日 -- 场景 
	CONST_MAP_SEVENDAY                         = 4120,
	-- [4130]充值 -- 场景 
	CONST_MAP_RECHARGE                         = 4130,
	-- [4131]充值-充值 -- 场景 
	CONST_MAP_RECHARGE_R                       = 4131,
	-- [4132]充值-vip特权 -- 场景 
	CONST_MAP_RECHARGE_VIP_PRIVILEGE           = 4132,
	-- [4133]充值-平民基金 -- 场景 
	CONST_MAP_RECHARGE_S_FUND                  = 4133,
	-- [4134]充值-土豪基金 -- 场景 
	CONST_MAP_RECHARGE_B_FUND                  = 4134,
	-- [4135]充值-至尊商城 -- 场景 
	CONST_MAP_RECHARGE_SUPREME                 = 4135,
	-- [4140]每日首充 -- 场景 
	CONST_MAP_EXAMINATION_DAILY                = 4140,
	-- [4150]商城 -- 场景 
	CONST_MAP_SHOP                             = 4150,
	-- [4170]抽奖 -- 场景 
	CONST_MAP_DRAW                             = 4170,
	-- [4180]成就 -- 场景 
	CONST_MAP_CHENGJIU                         = 4180,
	-- [5000]切磋攻略提醒 -- 场景 
	CONST_MAP_QIECHUO_GONGLUE                  = 5000,

	-- [1]地图类型-城镇  -- 场景 
	CONST_MAP_TYPE_CITY                        = 1,
	-- [2]地图类型-普通副本  -- 场景 
	CONST_MAP_TYPE_COPY_NORMAL                 = 2,
	-- [3]地图类型-精英副本  -- 场景 
	CONST_MAP_TYPE_COPY_HERO                   = 3,
	-- [4]地图类型-魔王副本  -- 场景 
	CONST_MAP_TYPE_COPY_FIEND                  = 4,
	-- [5]地图类型-世界BOSS  -- 场景 
	CONST_MAP_TYPE_BOSS                        = 5,
	-- [6]地图类型-竞技场  -- 场景 
	CONST_MAP_TYPE_CHALLENGEPANEL              = 6,
	-- [7]地图类型-多人PK  -- 场景 
	CONST_MAP_TYPE_INVITE_PK                   = 7,
	-- [8]地图类型-过关斩将  -- 场景 
	CONST_MAP_TYPE_COPY_FIGHTERS               = 8,
	-- [9]地图类型-天下第一  -- 场景 
	CONST_MAP_TYPE_KOF                         = 9,
	-- [10]地图类型-洞府Boss  -- 场景 
	CONST_MAP_TYPE_CLAN_BOSS                   = 10,
	-- [11]地图类型-洞府副本  -- 场景 
	CONST_MAP_TYPE_COPY_CLAN                   = 11,
	-- [12]地图类型-洞府守卫战  -- 场景 
	CONST_MAP_CLAN_DEFENSE                     = 12,
	-- [13]地图类型-洞府战  -- 场景 
	CONST_MAP_CLAN_WAR                         = 13,
	-- [14]地图类型-组队副本  -- 场景 
	CONST_MAP_TYPE_COPY_MULTIPLAYER            = 14,
	-- [15]地图类型-城市boss  -- 场景 
	CONST_MAP_TYPE_CITY_BOSS                   = 15,
	-- [16]地图类型-手动pk机器人  -- 场景 
	CONST_MAP_TYPE_PK_ROBOT                    = 16,
	-- [17]地图类型-一骑当千  -- 场景 
	CONST_MAP_TYPE_THOUSAND                    = 17,
	-- [18]地图类型-跨服天下第一  -- 场景 
	CONST_MAP_TYPE_TXDY_SUPER                  = 18,
	-- [19]地图类型-灵妖竞技 -- 场景 
	CONST_MAP_TYPE_PK_LY                       = 19,
	-- [20]地图类型-珍宝副本 -- 场景 
	CONST_MAP_TYPE_COPY_GEM                    = 20,
	-- [30]地图类型-降魔之路 -- 场景 
	CONST_MAP_TYPE_COPY_ROAD                   = 30,
	-- [40]地图类型-抢宝箱 -- 场景 
	CONST_MAP_TYPE_COPY_BOX                    = 40,
	-- [50]地图类型-铜钱副本 -- 场景 
	CONST_MAP_TYPE_COPY_MONEY                  = 50,
	-- [3016]洞府活动-祈福 -- 场景 
	CONST_MAP_GANGS_QIFU                       = 3016,

	-- [20]主动怪攻击触发距离  -- 场景 
	CONST_MAP_WAR_DISTANCE                     = 20,
	-- [3017]洞府技能 -- 场景 
	CONST_MAP_GANGS_SKILL                      = 3017,

	-- [1]触发-打怪  -- 场景 
	CONST_MAP_TOUCH_WAR                        = 1,
	-- [2]触发-采集  -- 场景 
	CONST_MAP_TOUCH_COLLECT                    = 2,

	-- [1]地图行走方式--移动  -- 场景 
	CONST_MAP_MOVE_MOVE                        = 1,
	-- [2]地图行走方式--跳跃  -- 场景 
	CONST_MAP_MOVE_JUMP                        = 2,
	-- [3]地图行走方式-停止行走  -- 场景 
	CONST_MAP_MOVE_STOP                        = 3,

	-- [100](优先级)人物  -- 场景 
	CONST_MAP_PRIORITY_PLAYER                  = 100,
	-- [200](优先级)主场景UI  -- 场景 
	CONST_MAP_PRIORITY_MAINUI                  = 200,
	-- [300](优先级)界面显示屏蔽  -- 场景 
	CONST_MAP_PRIORITY_LAYER                   = 300,
	-- [400](优先级)提示  -- 场景 
	CONST_MAP_PRIORITY_NOTIC                   = 400,
	-- [500](优先级)场景移动事件  -- 场景 
	CONST_MAP_PRIORITY_MOVE                    = 500,

	-- [200](层级)人物层  -- 场景 
	CONST_MAP_ZORDER_PLAYER                    = 200,
	-- [300](层级)主场景UI层  -- 场景 
	CONST_MAP_ZORDER_MAINUI                    = 300,
	-- [400](层级)控制层  -- 场景 
	CONST_MAP_ZORDER_CONTROL                   = 400,
	-- [500](层级)界面显示层  -- 场景 
	CONST_MAP_ZORDER_LAYER                     = 500,
	-- [1300](层级)提示层  -- 场景 
	CONST_MAP_ZORDER_NOTIC                     = 1300,
	-- [1400](层级)跑马灯层  -- 场景 
	CONST_MAP_ZORDER_MARQUEE                   = 1400,

	-- [10]刷新怪物倒计时  -- 场景 
	CONST_MAP_CLAN_DEF_TIME1                   = 10,
	-- [60]每一波怪物持续时间  -- 场景 
	CONST_MAP_CLAN_DEF_TIME2                   = 60,

	--------------------------------------------------------------------
	-- ( 任务 ) 
	--------------------------------------------------------------------
	-- [1]预先取得任务的等级  -- 任务 
	CONST_TASK_PRE_LV                          = 1,
	-- [15]任务分界等级  -- 任务 
	CONST_TASK_SPLIT_LV                        = 15,
	-- [100180]阵营任务ID  -- 任务 
	CONST_TASK_COUNTRY_ID                      = 100180,

	-- [2]接受条件类型--追加任务  -- 任务 
	CONST_TASK_ACCEPT_TYPE_ADD                 = 2,

	-- [1]任务目标其它 - 首次充值  -- 任务 
	CONST_TASK_TO_PAY_FIRST                    = 1,
	-- [2]任务目标其它 - 加入阵营  -- 任务 
	CONST_TASK_TO_COUNTRY                      = 2,
	-- [3]任务目标其它 - 加入洞府  -- 任务 
	CONST_TASK_TO_BUY                          = 3,
	-- [4]任务目标其它 - 饰品升品  -- 任务 
	CONST_TASK_TO_MAKE                         = 4,
	-- [5]任务目标其它 - 饰品强化  -- 任务 
	CONST_TASK_TO_STRENG                       = 5,
	-- [6]任务目标其它 - 装备洗练  -- 任务 
	CONST_TASK_TO_WASH                         = 6,
	-- [7]任务目标其它 - 通过关卡  -- 任务 
	CONST_TASK_TO_PASS_LV                      = 7,
	-- [8]任务目标其它 - 培养坐骑  -- 任务 
	CONST_TASK_TO_PET_FEED                     = 8,
	-- [9]任务目标其它 - 招财  -- 任务 
	CONST_TASK_TO_MONEY                        = 9,
	-- [10]任务目标其它 - 上香  -- 任务 
	CONST_TASK_TO_PRAY                         = 10,
	-- [11]任务目标其它 - 提升声望等级  -- 任务 
	CONST_TASK_TO_RENOWN_LV                    = 11,
	-- [12]任务目标其它 - 挑战某BOSS  -- 任务 
	CONST_TASK_TO_SANJIESHA                    = 12,
	-- [13]任务目标其它 - 打副本  -- 任务 
	CONST_TASK_TO_COPY                         = 13,
	-- [14]任务目标其它 - 特殊道具  -- 任务 
	CONST_TASK_TO_USE_GOODS                    = 14,
	-- [15]任务目标其它 - 道具使用  -- 任务 
	CONST_TASK_TO_GOODS                        = 15,
	-- [17]任务目标其它 - 封神台  -- 任务 
	CONST_TASK_TO_ARENA                        = 17,
	-- [18]任务目标其它 - 消费金元  -- 任务 
	CONST_TASK_TO_COST_RMB                     = 18,
	-- [19]任务目标其它 - 充值金元  -- 任务 
	CONST_TASK_TO_PAY_RMB                      = 19,
	-- [20]任务目标其它 - 招募武将  -- 任务 
	CONST_TASK_TO_PARTNER                      = 20,
	-- [21]任务目标其它 - 下载新资源  -- 任务 
	CONST_TASK_DOWN_NEWS                       = 21,
	-- [22]任务目标其它 - 卦象  -- 任务 
	CONST_TASK_TO_BAQI                         = 22,
	-- [23]任务目标其它 - 金身  -- 任务 
	CONST_TASK_TO_ZHENFA                       = 23,
	-- [24]任务目标其它 - 珍宝  -- 任务 
	CONST_TASK_TO_ZHENBAO                      = 24,
	-- [25]任务目标其它 - 神器  -- 任务 
	CONST_TASK_TO_SHENQI                       = 25,
	-- [26]任务目标其它 - 挑战迷宫  -- 任务 
	CONST_TASK_TO_TZMG                         = 26,
	-- [27]任务目标其它 - 皇陵探宝  -- 任务 
	CONST_TASK_TO_HLTB                         = 27,
	-- [28]任务目标其它 - 奴仆  -- 任务 
	CONST_TASK_TO_KUGONG                       = 28,
	-- [29]任务目标其它 - 护送美人  -- 任务 
	CONST_TASK_TO_HSMR                         = 29,
	-- [30]任务目标其它 - 全体装备强化到N级  -- 任务 
	CONST_TASK_EQUIP_TON                       = 30,
	-- [31]任务目标其它 - 坐骑达到N级  -- 任务 
	CONST_TASK_MOU_TON                         = 31,
	-- [32]任务目标其它 - 武将达到N级  -- 任务 
	CONST_TASK_PARTNER_TON                     = 32,
	-- [33]任务目标其它 - 技能达到N级  -- 任务 
	CONST_TASK_SKILL_TON                       = 33,
	-- [34]任务目标其它 - 宝石合成  -- 任务 
	CONST_TASK_BAOSHI_HECHENG                  = 34,
	-- [35]任务目标其它 - 武将装备  -- 任务 
	CONST_TASK_WUJIANG__ZHUANGBEI              = 35,
	-- [36]任务目标其它 - 激活称号  -- 任务 
	CONST_TASK_JIHUO_CHENGHAO                  = 36,
	-- [37]任务目标其它 - 翻翻乐  -- 任务 
	CONST_TASK_LOOK_THROUGH                    = 37,
	-- [38]任务目标其它 - 摇钱树  -- 任务 
	CONST_TASK_MONEY_TREE                      = 38,
	-- [39]任务目标其它 - 镶嵌宝石  -- 任务 
	CONST_TASK_INLIAD_GEMS                     = 39,
	-- [40]任务目标其它 - 领取奖励  -- 任务 
	CONST_TASK_RECEIVE_REWARD                  = 40,
	-- [41]任务目标其它 - 日常任务  -- 任务 
	CONST_TASK_DAILY_TASKS                     = 41,
	-- [42]任务目标其它 - 每日转盘  -- 任务 
	CONST_TASK_DAILY_TURNTABLE                 = 42,
	-- [43]任务目标其它 - 每日一箭  -- 任务 
	CONST_TASK_DAILY_ARROW                     = 43,
	-- [44]任务目标其它 - 全民寻宝  -- 任务 
	CONST_TASK_TO_XUNBAO                       = 44,
	-- [45]任务目标其它 - 组队副本  -- 任务 
	CONST_TASK_TO_TEAM                         = 45,
	-- [46]任务目标其它 - 侠客行  -- 任务 
	CONST_TASK_TO_XIAKE                        = 46,
	-- [47]任务目标其它 - 上坐骑  -- 任务 
	CONST_TASK_TO_HORSE                        = 47,
	-- [48]任务目标其它 - 技能装备  -- 任务 
	CONST_TASK_TO_SKILL                        = 48,
	-- [49]任务目标其它 - 无尽心魔达到N层 -- 任务 
	CONST_TASK_TO_WUJINXINMO                   = 49,
	-- [50]任务目标其它 - 锁妖塔达到N层 -- 任务 
	CONST_TASK_TO_FUTU                         = 50,
	-- [51]任务目标其它 - 挑战锁妖塔N次 -- 任务 
	CONST_TASK_TO_FUTU_FIGHT                   = 51,
	-- [52]任务目标其它 - 经脉修炼达到N级 -- 任务 
	CONST_TASK_GOLDBODY_TON                    = 52,
	-- [53]任务目标其它 - 装备一个卦象 -- 任务 
	CONST_TASK_ZHUANNGBEI_BAGUA                = 53,
	-- [54]任务目标其它 - 通过轮回试炼副本 -- 任务 
	CONST_TASK_XIANGMO_ZHILU                   = 54,
	-- [55]任务目标其它 - 竞技场挑战 -- 任务 
	CONST_TASK_ARENA                           = 55,
	-- [56]任务目标其它 - 灵妖竞技场 -- 任务 
	CONST_TASK_PARTNER_VS                      = 56,
	-- [57]任务目标其它 - 镇守妖塔界面 -- 任务 
	CONST_TASK_TO_FUTUJINGXIU                  = 57,
	-- [58]任务目标其它 - 饰品附魔 -- 任务 
	CONST_TASK_EQUIP_FUMO                      = 58,
	-- [59]任务目标其它 - 副本宝箱奖励 -- 任务 
	CONST_TASK_COPY_REWARD                     = 59,
	-- [60]任务目标其它 - 秘宝界面 -- 任务 
	CONST_TASK_MIBAO                           = 60,
	-- [61]任务目标其它 - 斗转星移说明 -- 任务 
	CONST_TASK_DZXY                            = 61,
	-- [62]任务目标其它 - 道劫挑战 -- 任务 
	CONST_TASK_DAOJIE                          = 62,

	-- [1]任务追踪弹出面板-剧情副本  -- 任务 
	CONST_TASK_POP_FB                          = 1,
	-- [2]任务追踪弹出面板-精英副本  -- 任务 
	CONST_TASK_POP_MS                          = 2,
	-- [3]任务追踪弹出面板-竞技场  -- 任务 
	CONST_TASK_POP_VS                          = 3,
	-- [4]任务追踪弹出面板-任务面板  -- 任务 
	CONST_TASK_POP_TASK                        = 4,
	-- [7]任务追踪弹出面板-福利面板  -- 任务 
	CONST_TASK_POP_WELFARE                     = 7,
	-- [8]任务追踪弹出面板-市场系统面板  -- 任务 
	CONST_TASK_POP_MARKET                      = 8,
	-- [9]任务追踪弹出面板-声望兑换面板  -- 任务 
	CONST_TASK_POP_RENOWN                      = 9,
	-- [12]任务追踪弹出面板-装备炼制系统  -- 任务 
	CONST_TASK_POP_EQUIP                       = 12,
	-- [13]任务追踪弹出面板-宠物面板(美女)  -- 任务 
	CONST_TASK_POP_PET                         = 13,
	-- [14]任务追踪弹出面板-洞府面板  -- 任务 
	CONST_TASK_POP_FAM                         = 14,
	-- [15]任务追踪弹出面板-商城  -- 任务 
	CONST_TASK_POP_MALL                        = 15,

	-- [5]日常任务免费刷星次数  -- 任务 
	CONST_TASK_DAILY_FREE_FRESH_TIMES          = 5,
	-- [10]一键满星所用的RMB  -- 任务 
	CONST_TASK_DAILY_ONE_FRESH                 = 10,
	-- [40]日常任务开放等级  -- 任务 
	CONST_TASK_DAILY_LV                        = 40,
	-- [308]日常任务NPC_ID  -- 任务 
	CONST_TASK_DAILY_NPC_ID                    = 308,
	-- [2078]日常任务刷星必需品ID  -- 任务 
	CONST_TASK_DAILY_FRESH_GOODS_ID            = 2078,

	-- [1]主线任务  -- 任务 
	CONST_TASK_TYPE_MAIN                       = 1,
	-- [2]支线任务  -- 任务 
	CONST_TASK_TYPE_BRANCH                     = 2,
	-- [10]日常任务  -- 任务 
	CONST_TASK_TYPE_EVERYDAY                   = 10,
	-- [20]家族任务  -- 任务 
	CONST_TASK_TYPE_CLAN                       = 20,
	-- [22]夫妻任务  -- 任务 
	CONST_TASK_TYPE_WIFE                       = 22,
	-- [60]活动任务  -- 任务 
	CONST_TASK_TYPE_ACTIVITY                   = 60,
	-- [99]其他任务  -- 任务 
	CONST_TASK_TYPE_OTHER                      = 99,

	-- [1]对话类  -- 任务 
	CONST_TASK_TARGET_TALK                     = 1,
	-- [2]收集类  -- 任务 
	CONST_TASK_TARGET_COLLECT                  = 2,
	-- [3]击杀怪物  -- 任务 
	CONST_TASK_TARGET_KILL                     = 3,
	-- [4]击杀玩家  -- 任务 
	CONST_TASK_TARGET_PK                       = 4,
	-- [5]问答题  -- 任务 
	CONST_TASK_TARGET_ASK                      = 5,
	-- [6]其它(充值,加入家族,商城购买,装备打造)  -- 任务 
	CONST_TASK_TARGET_OTHER                    = 6,
	-- [7]通关副本  -- 任务 
	CONST_TASK_TARGET_COPY                     = 7,
	-- [8]采集类  -- 任务 
	CONST_TASK_TARGET_GATHER                   = 8,

	-- [0]任务提交方式:被动提交,即:npc对话完成  -- 任务 
	CONST_TASK_SUBMIT_PASSIVE                  = 0,
	-- [1]任务提交方式-主动提交,直接完成  -- 任务 
	CONST_TASK_SUBMIT_ACTIVE                   = 1,

	-- [0]任务状态-未激活  -- 任务 
	CONST_TASK_STATE_INACTIVE                  = 0,
	-- [1]任务状态-已激活  -- 任务 
	CONST_TASK_STATE_ACTIVATE                  = 1,
	-- [2]任务状态-可接受  -- 任务 
	CONST_TASK_STATE_ACCEPTABLE                = 2,
	-- [3]任务状态-接受未完成  -- 任务 
	CONST_TASK_STATE_UNFINISHED                = 3,
	-- [4]任务状态-完成未提交  -- 任务 
	CONST_TASK_STATE_FINISHED                  = 4,
	-- [5]任务状态-已提交  -- 任务 
	CONST_TASK_STATE_SUBMIT                    = 5,

	-- [1]任务移除原因--完成任务  -- 任务 
	CONST_TASK_REMOVE_REASON_DOWN              = 1,
	-- [2]任务移除原因--放弃任务  -- 任务 
	CONST_TASK_REMOVE_REASON_CANCEL            = 2,

	-- [1]任务追踪--主线任务类  -- 任务 
	CONST_TASK_TRACE_MAIN_TASK                 = 1,
	-- [2]任务追踪--日常任务类  -- 任务 
	CONST_TASK_TRACE_DAILY_TASK                = 2,
	-- [3]任务追踪--材料掉落类  -- 任务 
	CONST_TASK_TRACE_MATERIAL                  = 3,

	-- [65]打开npc对话框的距离  -- 任务 
	CONST_TASK_TALK_DISTANCE                   = 65,

	-- [0]任务对话-ID（NPC） -- 任务 
	CONST_TASK_DIALOG_NPC                      = 0,
	-- [1]任务对话-ID（主角） -- 任务 
	CONST_TASK_DIALOG_PLAYER                   = 1,

	-- [0]任务对话-类型-显示下句话 -- 任务 
	CONST_TASK_DIALOG_TYPE0                    = 0,
	-- [1]任务对话-类型-接受或提交任务 -- 任务 
	CONST_TASK_DIALOG_TYPE1                    = 1,
	-- [45]跳转悬赏等级 -- 任务 
	CONST_TASK_TIAOZHUAN_XUANSHAN              = 45,

	--------------------------------------------------------------------
	-- ( 聊天频道 ) 
	--------------------------------------------------------------------
	-- [0]综合  -- 聊天频道 
	CONST_CHAT_ALL                             = 0,
	-- [1]世界  -- 聊天频道 
	CONST_CHAT_WORLD                           = 1,
	-- [2]洞府  -- 聊天频道 
	CONST_CHAT_CLAN                            = 2,
	-- [3]组队  -- 聊天频道 
	CONST_CHAT_TEAM                            = 3,
	-- [4]私聊  -- 聊天频道 
	CONST_CHAT_PM                              = 4,
	-- [5]系统  -- 聊天频道 
	CONST_CHAT_SYSTEM                          = 5,

	-- [1]物品类型  -- 聊天频道 
	CONST_CHAT_GOODS                           = 1,
	-- [2]组队类型  -- 聊天频道 
	CONST_CHAT_TEAM_ID                         = 2,

	-- [0]聊天消息  -- 聊天频道 
	CONST_CHAT_MSGTYPE_CHAT                    = 0,
	-- [1]游戏广播  -- 聊天频道 
	CONST_CHAT_MSGTYPE_BROADCAST               = 1,

	-- [1]错误提示-没有洞府  -- 聊天频道 
	CONST_CHAT_NO_CLAN                         = 1,
	-- [2]错误提示-没有队伍  -- 聊天频道 
	CONST_CHAT_NO_TEAM                         = 2,
	-- [3]错误提示-没有改玩家或不在线  -- 聊天频道 
	CONST_CHAT_NO_ONLINE                       = 3,

	-- [3]间隔多少秒  -- 聊天频道 
	CONST_CHAT_INTERVAL_SECONDS                = 3,
	-- [20]一小时内最多发多少邀请  -- 聊天频道 
	CONST_CHAT_TEAM_MAX                        = 20,
	-- [60]组队多久发一条邀请  -- 聊天频道 
	CONST_CHAT_TEAM_LIMIT                      = 60,
	-- [60]这段时间最多发多少条信息  -- 聊天频道 
	CONST_CHAT_LIMIT_TIMES                     = 60,
	-- [3600]多久轮回重新计数  -- 聊天频道 
	CONST_CHAT_TIME_AGAIN                      = 3600,
	-- [3600]洞府多久发一条邀请  -- 聊天频道 
	CONST_CHAT_CLAN_LIMIT                      = 3600,

	-- [15]聊天最低等级限制  -- 聊天频道 
	CONST_CHAT_LV_LIMIT                        = 15,
	-- [100]聊天信息最大限制  -- 聊天频道 
	CONST_CHAT_SIZE_LIMIT                      = 100,

	-- [1]类型-聊天(0或1都是聊天)  -- 聊天频道 
	CONST_CHAT_TYPE_CHAT                       = 1,
	-- [2]类型-组队  -- 聊天频道 
	CONST_CHAT_TYPE_TEAM                       = 2,
	-- [3]类型-洞府  -- 聊天频道 
	CONST_CHAT_TYPE_CLAN                       = 3,
	-- [4]类型-洞府公告  -- 聊天频道 
	CONST_CHAT_TYPE_CLAN_NOTICE                = 4,

	--------------------------------------------------------------------
	-- ( 好友系统 ) 
	--------------------------------------------------------------------
	-- [10]系统推荐好友数量  -- 好友系统 
	CONST_FRIEND_SYS_RECOMMEND                 = 10,
	-- [12]系统推荐好友-12级  -- 好友系统 
	CONST_FRIEND_TWENTY_FIVE                   = 12,
	-- [20]系统推荐好友-26级  -- 好友系统 
	CONST_FRIEND_THIRTY                        = 20,
	-- [25]系统推荐好友-29级  -- 好友系统 
	CONST_FRIEND_THIRTY_FIVE                   = 25,
	-- [100]好友上限  -- 好友系统 
	CONST_FRIEND_MAX                           = 100,

	-- [1]好友开放等级  -- 好友系统 
	CONST_FRIEND_FRIEND_LV                     = 1,
	-- [1]最近联系人保存时间( 天)  -- 好友系统 
	CONST_FRIEND_RECENT_TIME                   = 1,
	-- [5]最近联系人显示数量  -- 好友系统 
	CONST_FRIEND_RECENT_COUNT                  = 5,

	-- [1]类型-好友  -- 好友系统 
	CONST_FRIEND_FRIEND                        = 1,
	-- [2]类型-最近联系人  -- 好友系统 
	CONST_FRIEND_RECENT                        = 2,
	-- [3]类型-搜索玩家  -- 好友系统 
	CONST_FRIEND_SEARCH                        = 3,
	-- [4]类型-领取祝福  -- 好友系统 
	CONST_FRIEND_GET_BLESS                     = 4,
	-- [5]类型-黑名单  -- 好友系统 
	CONST_FRIEND_BLACKLIST                     = 5,
	-- [6]类型-附近的人  -- 好友系统 
	CONST_FRIEND_NEARBY                        = 6,

	-- [3]玩家推荐好友次数  -- 好友系统 
	CONST_FRIEND_RECOM_TIMES                   = 3,

	-- [5]最大被祝福次数  -- 好友系统 
	CONST_FRIEND_BLESSED_MAX                   = 5,
	-- [25]最大祝福次数  -- 好友系统 
	CONST_FRIEND_BLESS_MAX                     = 25,

	-- [2]祝福好友获得铜钱奖励  -- 好友系统 
	CONST_FRIEND_BLESS_GOLD                    = 2,
	-- [10]被祝福获得铜钱奖励  -- 好友系统 
	CONST_FRIEND_BLESSED_GOLD                  = 10,

	-- [0]一键祝福需要vip等级  -- 好友系统 
	CONST_FRIEND_VIP                           = 0,

	--------------------------------------------------------------------
	-- ( 邮件 ) 
	--------------------------------------------------------------------
	-- [7]邮件有效期(天数）  -- 邮件 
	CONST_MAIL_NET_TIME                        = 7,
	-- [40]邮件标题字数上限  -- 邮件 
	CONST_MAIL_ITLE_MAX                        = 40,
	-- [50]保存箱容量上限  -- 邮件 
	CONST_MAIL_VOLUME_MAX                      = 50,
	-- [900]邮件内容字数上限  -- 邮件 
	CONST_MAIL_CONTENT_LENGTH                  = 900,

	-- [0]读取状态 - 未读  -- 邮件 
	CONST_MAIL_STATE_UNREAD                    = 0,
	-- [1]读取状态 - 已读  -- 邮件 
	CONST_MAIL_STATE_READ                      = 1,

	-- [0]附件状态--无物品  -- 邮件 
	CONST_MAIL_ACCESSORY_NULL                  = 0,
	-- [1]附件状态--未提取  -- 邮件 
	CONST_MAIL_ACCESSORY_NO                    = 1,
	-- [2]附件状态--已提取  -- 邮件 
	CONST_MAIL_ACCESSORY_YES                   = 2,
	-- [6]附件数量  -- 邮件 
	CONST_MAIL_ATTACH                          = 6,

	-- [0]邮件类型--系统  -- 邮件 
	CONST_MAIL_TYPE_SYSTEM                     = 0,
	-- [1]邮件类型--洞府  -- 邮件 
	CONST_MAIL_TYPE_WAR                        = 1,
	-- [2]邮件类型--玩家  -- 邮件 
	CONST_MAIL_TYPE_PRIVATE                    = 2,

	-- [0]邮箱类型--收件箱  -- 邮件 
	CONST_MAIL_TYPE_GET                        = 0,
	-- [1]邮箱类型--发件箱  -- 邮件 
	CONST_MAIL_TYPE_SEND                       = 1,
	-- [2]邮箱类型--保存箱  -- 邮件 
	CONST_MAIL_TYPE_SAVE                       = 2,

	-- [6]邮件附件可发送箱子数  -- 邮件 
	CONST_MAIL_PICK_BOX                        = 6,

	--------------------------------------------------------------------
	-- ( 玩家属性 ) 
	--------------------------------------------------------------------
	-- [1]国家  -- 玩家属性 
	CONST_ATTR_COUNTRY                         = 1,
	-- [2]国家-职位  -- 玩家属性 
	CONST_ATTR_COUNTRY_POST                    = 2,
	-- [5]角色名颜色  -- 玩家属性 
	CONST_ATTR_NAME_COLOR                      = 5,
	-- [6]等级  -- 玩家属性 
	CONST_ATTR_LV                              = 6,
	-- [7]vip等级  -- 玩家属性 
	CONST_ATTR_VIP                             = 7,

	-- [10]精力  -- 玩家属性 
	CONST_ATTR_ENERGY                          = 10,
	-- [11]经验值  -- 玩家属性 
	CONST_ATTR_EXP                             = 11,
	-- [12]下级要多少经验  -- 玩家属性 
	CONST_ATTR_EXPN                            = 12,
	-- [13]总共集了多少 经验  -- 玩家属性 
	CONST_ATTR_EXPT                            = 13,
	-- [14]声望  -- 玩家属性 
	CONST_ATTR_RENOWN                          = 14,
	-- [15]杀戮值  -- 玩家属性 
	CONST_ATTR_SLAUGHTER                       = 15,
	-- [16]荣誉值  -- 玩家属性 
	CONST_ATTR_HONOR                           = 16,
	-- [17]战斗力  -- 玩家属性 
	CONST_ATTR_POWERFUL                        = 17,
	-- [18]名字  -- 玩家属性 
	CONST_ATTR_NAME                            = 18,
	-- [19]排名  -- 玩家属性 
	CONST_ATTR_RANK                            = 19,
	-- [20]元魂 -- 玩家属性 
	CONST_ATTR_SOUL                            = 20,

	-- [21]装备武器id（换装）  -- 玩家属性 
	CONST_ATTR_WEAPON                          = 21,
	-- [22]装备衣服id（换装）  -- 玩家属性 
	CONST_ATTR_ARMOR                           = 22,
	-- [23]装备时装id(换装)  -- 玩家属性 
	CONST_ATTR_FASHION                         = 23,
	-- [24]坐骑  -- 玩家属性 
	CONST_ATTR_MOUNT                           = 24,
	-- [25]坐骑特效 -- 玩家属性 
	CONST_ATTR_TEXIAO                          = 25,

	-- [37]血量(战斗中..)  -- 玩家属性 
	CONST_ATTR_S_HP                            = 37,

	-- [38]怒气恢复速度  -- 玩家属性 
	CONST_ATTR_SP_UP                           = 38,
	-- [39]初始灵气值  -- 玩家属性 
	CONST_ATTR_ANIMA                           = 39,
	-- [40]怒气(战斗中有用)  -- 玩家属性 
	CONST_ATTR_SP                              = 40,
	-- [41]血量  -- 玩家属性 
	CONST_ATTR_HP                              = 41,
	-- [42]攻击  -- 玩家属性 
	CONST_ATTR_STRONG_ATT                      = 42,
	-- [43]防御  -- 玩家属性 
	CONST_ATTR_STRONG_DEF                      = 43,
	-- [44]破甲  -- 玩家属性 
	CONST_ATTR_DEFEND_DOWN                     = 44,
	-- [45]命中  -- 玩家属性 
	CONST_ATTR_HIT                             = 45,
	-- [46]闪避  -- 玩家属性 
	CONST_ATTR_DODGE                           = 46,
	-- [47]暴击  -- 玩家属性 
	CONST_ATTR_CRIT                            = 47,
	-- [48]抗暴  -- 玩家属性 
	CONST_ATTR_RES_CRIT                        = 48,
	-- [49]伤害  -- 玩家属性 
	CONST_ATTR_BONUS                           = 49,
	-- [50]免伤  -- 玩家属性 
	CONST_ATTR_REDUCTION                       = 50,
	-- [60]光属性  -- 玩家属性 
	CONST_ATTR_LIGHT                           = 60,
	-- [61]光抗性  -- 玩家属性 
	CONST_ATTR_LIGHT_DEF                       = 61,
	-- [62]暗属性  -- 玩家属性 
	CONST_ATTR_DARK                            = 62,
	-- [63]暗抗性  -- 玩家属性 
	CONST_ATTR_DARK_DEF                        = 63,
	-- [64]灵属性  -- 玩家属性 
	CONST_ATTR_GOD                             = 64,
	-- [65]灵抗性  -- 玩家属性 
	CONST_ATTR_GOD_DEF                         = 65,
	-- [68]免疫眩晕  -- 玩家属性 
	CONST_ATTR_IMM_DIZZ                        = 68,
	-- [80]装备评分  -- 玩家属性 
	CONST_ATTR_SCORE_EQ                        = 80,
	-- [81]首饰评分  -- 玩家属性 
	CONST_ATTR_SCORE_JEW                       = 81,
	-- [82]神器评分  -- 玩家属性 
	CONST_ATTR_SCORE_MAG                       = 82,
	-- [84]宝石评分  -- 玩家属性 
	CONST_ATTR_SCORE_PEA                       = 84,

	-- [71]配偶：id  -- 玩家属性 
	CONST_ATTR_MATE                            = 71,
	-- [72]配偶：姓名[字符串]  -- 玩家属性 
	CONST_ATTR_MATE_NAME                       = 72,

	-- [81]称号-新加  -- 玩家属性 
	CONST_ATTR_TITLES_ADD                      = 81,
	-- [82]称号-移除(得到更高级的称号，低的要移除)  -- 玩家属性 
	CONST_ATTR_TITLES_DEL                      = 82,

	-- [91]洞府  -- 玩家属性 
	CONST_ATTR_CLAN                            = 91,
	-- [92]洞府：职位  -- 玩家属性 
	CONST_ATTR_CLAN_POST                       = 92,
	-- [93]洞府：名称[字符串]  -- 玩家属性 
	CONST_ATTR_CLAN_NAME                       = 93,

	-- [31]角色皮肤类型--装备  -- 玩家属性 
	CONST_ATTR_SKIN_TYPE_EQUIP                 = 31,
	-- [32]角色皮肤类型--时装  -- 玩家属性 
	CONST_ATTR_SKIN_TYPE_SHAPE                 = 32,
	-- [33]角色皮肤类型--坐骑  -- 玩家属性 
	CONST_ATTR_SKIN_TYPE_MOUNT                 = 33,
	-- [34]角色皮肤类型--任务(护送)  -- 玩家属性 
	CONST_ATTR_SKIN_TYPE_TASK_ESCORT           = 34,
	-- [35]角色皮肤类型--任务(变身)  -- 玩家属性 
	CONST_ATTR_SKIN_TYPE_TASK_SHAPE            = 35,

	-- [0]查看玩家属性类型  -- 玩家属性 
	CONST_ATTR_SHOW_TYPE                       = 0,

	-- [2]角色初始化颜色  -- 玩家属性 
	CONST_ATTR_INIT_NAME                       = 2,
	-- [50]主角换位置等级要求  -- 玩家属性 
	CONST_ATTR_CHANGE_LV                       = 50,

	-- [30]第二个出战伙伴等级限制  -- 玩家属性 
	CONST_ATTR_PARTNER_LV_TWO                  = 30,
	-- [50]第三个出战伙伴等级限制  -- 玩家属性 
	CONST_ATTR_PARTNER_LV_THREE                = 50,

	-- [100]人物总战斗力  -- 玩家属性 
	CONST_ATTR_ALLS_POWER                      = 100,

	-- [11150]创建人物时，小于这个值，发个物品  -- 玩家属性 
	CONST_ATTR_MAX_UUID                        = 11150,
	-- [41600]荣耀老兵礼包  -- 玩家属性 
	CONST_ATTR_HONOR_GOODS                     = 41600,

	-- [1]战力对比-总战力 -- 玩家属性 
	CONST_ATTR_POWERFUL_ALL                    = 1,
	-- [2]战力对比-基本战力 -- 玩家属性 
	CONST_ATTR_POWERFUL_LV                     = 2,
	-- [3]战力对比-装备战力 -- 玩家属性 
	CONST_ATTR_POWERFUL_EQUIP                  = 3,
	-- [4]战力对比-技能战力 -- 玩家属性 
	CONST_ATTR_POWERFUL_SKILL                  = 4,
	-- [5]战力对比-坐骑战力 -- 玩家属性 
	CONST_ATTR_POWERFUL_MOUNT                  = 5,
	-- [6]战力对比-守护战力 -- 玩家属性 
	CONST_ATTR_POWERFUL_INN                    = 6,
	-- [7]战力对比-金身战力 -- 玩家属性 
	CONST_ATTR_POWERFUL_GOLD                   = 7,
	-- [8]战力对比-洞府技能 -- 玩家属性 
	CONST_ATTR_POWERFUL_CLAN                   = 8,
	-- [9]战力对比-卦象战力 -- 玩家属性 
	CONST_ATTR_POWERFUL_DOUQI                  = 9,
	-- [10]战力对比-星宿战力 -- 玩家属性 
	CONST_ATTR_POWERFUL_WING                   = 10,
	-- [11]战力对比-神职战力（封神榜） -- 玩家属性 
	CONST_ATTR_POWERFUL_FSB                    = 11,
	-- [12]战力对比-装备战力（宝石） -- 玩家属性 
	CONST_ATTR_POWERFUL_EQUIP_GEM              = 12,
	-- [13]战力对比-装备战力（强化） -- 玩家属性 
	CONST_ATTR_POWERFUL_EQUIP_STR              = 13,
	-- [14]战力对比-装备战力（装备） -- 玩家属性 
	CONST_ATTR_POWERFUL_EQUIP_EQUIP            = 14,
	-- [15]战力对比-武器 -- 玩家属性 
	CONST_ATTR_POWERFUL_WUQI                   = 15,
	-- [16]战力对比-神羽 -- 玩家属性 
	CONST_ATTR_POWERFUL_FEATHER                = 16,
	-- [17]战力对比-灵妖 -- 玩家属性 
	CONST_ATTR_POWERFUL_LINGYAO                = 17,

	--------------------------------------------------------------------
	-- ( 组队 ) 
	--------------------------------------------------------------------
	-- [3]组队成员人数上限  -- 组队 
	CONST_TEAM_MAX                             = 3,
	-- [20]发布招募间隔时间（秒）  -- 组队 
	CONST_TEAM_RECRUIT_TIME                    = 20,

	-- [1]离队-被踢出队伍  -- 组队 
	CONST_TEAM_OUT_KICK                        = 1,
	-- [2]离队-自己主动退出  -- 组队 
	CONST_TEAM_OUT_EXIT                        = 2,

	-- [1]队伍成员加入  -- 组队 
	CONST_TEAM_MEMBER_UPDATE_IN                = 1,
	-- [2]队伍成员退出  -- 组队 
	CONST_TEAM_MEMBER_UPDATE_OUT               = 2,

	-- [1]队伍状态-组队中  -- 组队 
	CONST_TEAM_STATE_TEAMING                   = 1,
	-- [2]队伍状态-战斗中  -- 组队 
	CONST_TEAM_STATE_WARING                    = 2,

	-- [1]邀请类型--附近玩家  -- 组队 
	CONST_TEAM_INVITE_NEARBY                   = 1,
	-- [2]邀请类型--好友  -- 组队 
	CONST_TEAM_INVITE_FRIEND                   = 2,
	-- [3]邀请类型--社团人员  -- 组队 
	CONST_TEAM_INVITE_CLAN                     = 3,
	-- [4]邀请类型--雇佣 -- 组队 
	CONST_TEAM_INVITE_HIRE                     = 4,

	-- [1]雇佣玩家购买金钱系数 -- 组队 
	CONST_TEAM_HIRE_COEFFICIENT                = 1,
	-- [2]最大购买次数  -- 组队 
	CONST_TEAM_BUY_TIMES_MAX                   = 2,
	-- [70]每次购买次数元宝数  -- 组队 
	CONST_TEAM_BUY_TIMES_RMB                   = 70,

	--------------------------------------------------------------------
	-- ( 战斗 ) 
	--------------------------------------------------------------------
	-- [1]阵型 - 默认  -- 战斗 
	CONST_WAR_EMBATTLE_DEFAULT                 = 1,
	-- [5]战斗 最多5个玩家同时参战  -- 战斗 
	CONST_WAR_MAX_PLAYER                       = 5,
	-- [9]站位-左右每边总人数  -- 战斗 
	CONST_WAR_POSITION_MAX                     = 9,
	-- [20]boss命中增加士气值  -- 战斗 
	CONST_WAR_BOSS_SP                          = 20,
	-- [29]切磋最小等级  -- 战斗 
	CONST_WAR_MIN_PK2_LV                       = 29,
	-- [30]战斗最大回合数  -- 战斗 
	CONST_WAR_ROUNT_MAX                        = 30,
	-- [50]每次命中后增加士气  -- 战斗 
	CONST_WAR_UP_SP                            = 50,
	-- [100]技能触发所需士气  -- 战斗 
	CONST_WAR_USE_SP                           = 100,
	-- [2000]支援承受伤害  -- 战斗 
	CONST_WAR_RES_ASK                          = 2000,
	-- [3000]格挡承受30%伤害  -- 战斗 
	CONST_WAR_PARRY                            = 3000,
	-- [3000]战斗开始到结束最少时长（毫秒）  -- 战斗 
	CONST_WAR_TIME_MIN                         = 3000,
	-- [5000]两次战斗间隔-毫秒  -- 战斗 
	CONST_WAR_BATTLE_INTERVAL                  = 5000,

	-- [1]援助 - 容错值  -- 战斗 
	CONST_WAR_MERGE_FAULT_TOLERANT             = 1,
	-- [1]指命类型-普通攻击  -- 战斗 
	CONST_WAR_COM_NORMAL                       = 1,
	-- [2]指命类型-技能  -- 战斗 
	CONST_WAR_COM_SKILL                        = 2,
	-- [4]指命类型-星魂  -- 战斗 
	CONST_WAR_COM_TRIED                        = 4,
	-- [5]指命类型-buff获得类型  -- 战斗 
	CONST_WAR_COM_BUFF_TYPE                    = 5,
	-- [6]指命类型-buff释放  -- 战斗 
	CONST_WAR_COM_RE_BUFF                      = 6,
	-- [7]指命类型-炸弹  -- 战斗 
	CONST_WAR_COM_BOMB                         = 7,
	-- [13000]援助 - 普通攻击*130%  -- 战斗 
	CONST_WAR_MERGE_STRENGTHEN                 = 13000,

	-- [13000]反击 - 普通攻击*130%  -- 战斗 
	CONST_WAR_BACK_STRENGTHEN                  = 13000,
	-- [15000]暴击 - 普通攻击*150%  -- 战斗 
	CONST_WAR_CRIT_STRENGTHEN                  = 15000,

	-- [1]战斗参数 - 场景杀怪（包括副本）  -- 战斗 
	CONST_WAR_PARAS_1_NORMAL                   = 1,
	-- [2]战斗参数 - PK(默认)  -- 战斗 
	CONST_WAR_PARAS_1_PK                       = 2,
	-- [3]战斗参数 - 奴仆  -- 战斗 
	CONST_WAR_PARAS_1_MOIL                     = 3,
	-- [4]战斗参数 - 组队副本  -- 战斗 
	CONST_WAR_PARAS_1_TEAM                     = 4,
	-- [6]战斗参数 - 竟技场  -- 战斗 
	CONST_WAR_PARAS_1_JJC                      = 6,
	-- [9]战斗参数 - 洞府  -- 战斗 
	CONST_WAR_PARAS_1_CLAN                     = 9,
	-- [10]战斗参数 - 家族怪物  -- 战斗 
	CONST_WAR_PARAS_1_CLAN2                    = 10,
	-- [11]战斗参数 - 世界Boss  -- 战斗 
	CONST_WAR_PARAS_1_WORLD_BOSS               = 11,
	-- [13]战斗参数 - 保卫经书  -- 战斗 
	CONST_WAR_PARAS_1_DEFEND_BOOK              = 13,
	-- [14]战斗参数 - 天空之战  -- 战斗 
	CONST_WAR_PARAS_1_SKY_WAR                  = 14,
	-- [15]战斗参数 - 取经之路  -- 战斗 
	CONST_WAR_PARAS_1_PILROAD                  = 15,
	-- [16]战斗参数 - 塔防雕像  -- 战斗 
	CONST_WAR_CLAN_DEFENSE                     = 16,
	-- [17]战斗参数-洞府战类型  -- 战斗 
	CONST_WAR_WARFARE_WAR                      = 17,
	-- [18]战斗参数 - 城镇boss  -- 战斗 
	CONST_WAR_PARAS_1_CITY_BOSS                = 18,
	-- [19]战斗参数 - 跨服天下第一  -- 战斗 
	CONST_WAR_PARAS_1_TXDY_SUPER               = 19,
	-- [20]战斗参数 - 秘宝活动 -- 战斗 
	CONST_WAR_PARAS_MIBAO                      = 20,
	-- [500]战斗参数 - 身上/背包的装备有5%的爆出机率  -- 战斗 
	CONST_WAR_BLASTING_ODDS                    = 500,

	-- [1]PK - 击杀敌国，增加荣誉值  -- 战斗 
	CONST_WAR_PK_HONOR                         = 1,
	-- [1]PK - 同国杀死，增加杀戮值  -- 战斗 
	CONST_WAR_PK_SLAUGHTER                     = 1,

	-- [1]战斗广播标识--战斗开始  -- 战斗 
	CONST_WAR_BROADCAST_FLAG_START             = 1,
	-- [2]战斗广播标识--战斗结束  -- 战斗 
	CONST_WAR_BROADCAST_FLAG_OVER              = 2,

	-- [10]buff类型-加攻击  -- 战斗 
	CONST_WAR_PLUS_ATTACK                      = 10,
	-- [15]buff类型-减攻击  -- 战斗 
	CONST_WAR_MINUS_ATTACK                     = 15,
	-- [20]buff类型-加防御  -- 战斗 
	CONST_WAR_PLUS_DEFENSE                     = 20,
	-- [25]buff类型-减防御  -- 战斗 
	CONST_WAR_MINUS_DEFENSE                    = 25,
	-- [26]buff类型-加速度  -- 战斗 
	CONST_WAR_PLUS_SPEED                       = 26,
	-- [27]buff类型-降速度  -- 战斗 
	CONST_WAR_MINUS_SPEED                      = 27,
	-- [30]buff类型-加暴击  -- 战斗 
	CONST_WAR_PLUS_CRIT                        = 30,
	-- [35]buff类型-减暴击  -- 战斗 
	CONST_WAR_MINUS_CRIT                       = 35,
	-- [40]buff类型-加命中  -- 战斗 
	CONST_WAR_PLUS_HIT                         = 40,
	-- [45]buff类型-减命中  -- 战斗 
	CONST_WAR_MINUS_HIT                        = 45,
	-- [50]buff类型-加闪避  -- 战斗 
	CONST_WAR_PLUS_DODGE                       = 50,
	-- [55]buff类型-减闪避  -- 战斗 
	CONST_WAR_MINUS_DODGE                      = 55,
	-- [60]buff类型-加格挡  -- 战斗 
	CONST_WAR_PLUS_PARRY                       = 60,
	-- [65]buff类型-降格挡  -- 战斗 
	CONST_WAR_MINUS_PARRY                      = 65,
	-- [70]buff类型-加破击  -- 战斗 
	CONST_WAR_PLUS_WRECK                       = 70,
	-- [75]buff类型-减破击  -- 战斗 
	CONST_WAR_MINUS_WRECK                      = 75,
	-- [80]buff类型-每回合加血  -- 战斗 
	CONST_WAR_PLUS_REGAIN_HP                   = 80,
	-- [85]buff类型-中毒  -- 战斗 
	CONST_WAR_MINUS_POISON                     = 85,
	-- [90]buff类型-烧伤  -- 战斗 
	CONST_WAR_MINUS_BURN                       = 90,
	-- [100]buff类型-眩晕  -- 战斗 
	CONST_WAR_VERTIGO                          = 100,
	-- [110]buff类型-免疫眩晕  -- 战斗 
	CONST_WAR_PLUS_ANTI_IMM_VERTIGO            = 110,
	-- [115]buff类型-降低治疗效果  -- 战斗 
	CONST_WAR_PLUS_CURE                        = 115,
	-- [120]buff类型-每回合降士气  -- 战斗 
	CONST_WAR_MINUS_ROUND_SP                   = 120,
	-- [125]buff类型-加合击  -- 战斗 
	CONST_WAR_PLUS_MERGE                       = 125,
	-- [130]buff类型-加求援  -- 战斗 
	CONST_WAR_PLUS_RES_ASK                     = 130,
	-- [135]buff类型-换位置  -- 战斗 
	CONST_WAR_CHANGE                           = 135,
	-- [140]buff类型-武器加攻击  -- 战斗 
	CONST_WAR_PLUS_ATTACK_WEAPON               = 140,
	-- [145]buff类型-武器加防御  -- 战斗 
	CONST_WAR_PLUS_DEFENSE_WEAPN               = 145,
	-- [150]buff类型-加士气  -- 战斗 
	CONST_WAR_SP_ADD                           = 150,
	-- [155]buff类型-降低士气  -- 战斗 
	CONST_WAR_SP_DOWN                          = 155,

	-- [0]胜(败)层次-微胜(败)  -- 战斗 
	CONST_WAR_WIN_NONE                         = 0,
	-- [1]胜(败)层次-小胜(败)  -- 战斗 
	CONST_WAR_WIN_NOSE                         = 1,

	-- [1]战斗类型 - 普通(打怪)  -- 战斗 
	CONST_WAR_TYPE_NORMAL                      = 1,
	-- [2]战斗类型 - pk  -- 战斗 
	CONST_WAR_TYPE_PK                          = 2,
	-- [3]战斗类型- 切磋  -- 战斗 
	CONST_WAR_TYPE_PK2                         = 3,

	-- [0]战斗状态(被) - 死亡  -- 战斗 
	CONST_WAR_STATE_DIE                        = 0,
	-- [1]战斗状态(被) - 正常  -- 战斗 
	CONST_WAR_STATE_NORMAL                     = 1,

	-- [1]站位-左边  -- 战斗 
	CONST_WAR_POSITION_LEFT                    = 1,
	-- [2]站位-右边  -- 战斗 
	CONST_WAR_POSITION_RIGHT                   = 2,

	-- [1]目标-队友（已方）  -- 战斗 
	CONST_WAR_TARGET_OWN                       = 1,
	-- [2]目标-敌人（敌方）  -- 战斗 
	CONST_WAR_TARGET_FOE                       = 2,
	-- [3]目标-死亡个体(已方)  -- 战斗 
	CONST_WAR_TARGET_DIE                       = 3,
	-- [4]目标-全部(敌我)  -- 战斗 
	CONST_WAR_TARGET_ALL                       = 4,

	-- [100]指命集 - 正常  -- 战斗 
	CONST_WAR_COLL_NULL                        = 100,
	-- [101]指命集 - 连击  -- 战斗 
	CONST_WAR_COLL_DOUBLE_HIT                  = 101,
	-- [102]指命集 - 反击  -- 战斗 
	CONST_WAR_COLL_STRIKE_BACK                 = 102,
	-- [103]指命集 - 援助(合击)  -- 战斗 
	CONST_WAR_COLL_MERGE                       = 103,
	-- [104]指命集 - buff释放  -- 战斗 
	CONST_WAR_COLL_BUFF                        = 104,
	-- [105]指命集 - 中毒  -- 战斗 
	CONST_WAR_COLL_BRUISE                      = 105,

	-- [0]怪物生成-空  -- 战斗 
	CONST_WAR_MONSTER_MAKE_NULL                = 0,
	-- [1]怪物生成-本身  -- 战斗 
	CONST_WAR_MONSTER_MAKE_SELF                = 1,
	-- [2]怪物生成-随机(必生)  -- 战斗 
	CONST_WAR_MONSTER_MAKE_RANDOM              = 2,
	-- [100]怪物生成-随机(机率)  -- 战斗 
	CONST_WAR_MONSTER_MAKE_ODDS                = 100,

	-- [1]公式常量 - 伤害(最小)  -- 战斗 
	CONST_WAR_EXPRESSION_HARM_MIN              = 1,
	-- [500]公式常量 - 暴击几率%(最小)  -- 战斗 
	CONST_WAR_EXPRESSION_CRIT_MIN              = 500,
	-- [4500]公式常量 - 闪避几率%(最大)  -- 战斗 
	CONST_WAR_EXPRESSION_DODGE_MAX             = 4500,
	-- [5000]公式常量 - 暴击几率%(最大)  -- 战斗 
	CONST_WAR_EXPRESSION_CRIT_MAX              = 5000,

	-- [1]公式计算系数 - 攻击  -- 战斗 
	CONST_WAR_PARAMETER_ATTACK                 = 1,
	-- [1]公式计算系数 - 防御  -- 战斗 
	CONST_WAR_PARAMETER_DEFENSE                = 1,
	-- [200]公式计算系数 - 暴击  -- 战斗 
	CONST_WAR_PARAMETER_CRIT                   = 200,
	-- [200]公式计算系数 - 坚韧  -- 战斗 
	CONST_WAR_PARAMETER_TOUGH                  = 200,
	-- [200]公式计算系数 - 命中  -- 战斗 
	CONST_WAR_PARAMETER_HIT                    = 200,
	-- [200]公式计算系数 - 闪避  -- 战斗 
	CONST_WAR_PARAMETER_DODGE                  = 200,

	-- [2]战斗状态(被) - 中毒  -- 战斗 
	CONST_WAR_STATE_POISONING                  = 2,
	-- [3]战斗状态(被) - 隐身  -- 战斗 
	CONST_WAR_STATE_HIDING                     = 3,

	-- [50]表现状态 - 正常  -- 战斗 
	CONST_WAR_DISPLAY_NORMAL                   = 50,
	-- [51]表现状态 - 未命中  -- 战斗 
	CONST_WAR_DISPLAY_DODGE                    = 51,
	-- [52]表现状态 - 击暴  -- 战斗 
	CONST_WAR_DISPLAY_CRIT                     = 52,
	-- [53]表现状态 - 反射  -- 战斗 
	CONST_WAR_DISPLAY_REFLEX                   = 53,
	-- [54]表现状态 - 格挡  -- 战斗 
	CONST_WAR_DISPLAY_PARRY                    = 54,
	-- [55]表现状态 - 闪避  -- 战斗 
	CONST_WAR_DISPLAY_DOD                      = 55,
	-- [56]表现状态 - 求援  -- 战斗 
	CONST_WAR_DISPLAY_ASK                      = 56,

	-- [0.3]复活 - 原地,回复30%血  -- 战斗 
	CONST_WAR_REVIVE_LOCAL                     = 0.3,
	-- [1]复活 - 回城,回复1点血  -- 战斗 
	CONST_WAR_REVIVE_STWP                      = 1,

	-- [1]战斗结束选项-确定  -- 战斗 
	CONST_WAR_OVER_CONFIRM                     = 1,
	-- [2]战斗结束选项-复活-原地  -- 战斗 
	CONST_WAR_OVER_REVIVE_LOCAL                = 2,
	-- [3]战斗结束选项-复活-回城  -- 战斗 
	CONST_WAR_OVER_REVIVE_STWP                 = 3,

	-- [0]震屏效果-不震屏  -- 战斗 
	CONST_WAR_SHAKE_NONE                       = 0,
	-- [1]震屏效果-微震  -- 战斗 
	CONST_WAR_SHAKE_SLIGHT                     = 1,
	-- [2]震屏效果-小震  -- 战斗 
	CONST_WAR_SHAKE_SMALL                      = 2,
	-- [3]震屏效果-中震  -- 战斗 
	CONST_WAR_SHAKE_MIDDLE                     = 3,
	-- [4]震屏效果-大震  -- 战斗 
	CONST_WAR_SHAKE_BIG                        = 4,
	-- [5]震屏效果-惊天动地的震  -- 战斗 
	CONST_WAR_SHAKE_WORLD                      = 5,

	-- [1]攻击类型--力量  -- 战斗 
	CONST_WAR_STRONG                           = 1,
	-- [2]攻击类型--灵力  -- 战斗 
	CONST_WAR_MAGIC                            = 2,

	-- [1]buff释放显示类型-中毒  -- 战斗 
	CONST_WAR_BUFF_TYPE_POISON                 = 1,
	-- [2]buff释放显示类型-回血  -- 战斗 
	CONST_WAR_BUFF_TYPE_RECOVERY               = 2,

	-- [1]背景类型-封神台  -- 战斗 
	CONST_WAR_MAP_TYPE_ARENA                   = 1,
	-- [2]背景类型-三界杀  -- 战斗 
	CONST_WAR_MAP_TYPE_CIRCLE                  = 2,
	-- [3]背景类型-奴仆  -- 战斗 
	CONST_WAR_MAP_TYPE_MOIL                    = 3,

	-- [1.25]战斗计算倍数（1.25）  -- 战斗 
	CONST_WAR_CAL_MULTIPLE                     = 1.25,

	-- [15]角色击飞韧性  -- 战斗 
	CONST_WAR_TOUNGHNESS1                      = 15,
	-- [80]角色霸体韧性  -- 战斗 
	CONST_WAR_TOUNGHNESS2                      = 80,

	-- [0.5]血量飘动时间  -- 战斗 
	CONST_WAR_HP_TIME                          = 0.5,

	-- [20]邀请切磋最小等级  -- 战斗 
	CONST_WAR_PK_LV                            = 20,

	-- [1]集合-世界boss  -- 战斗 
	CONST_WAR_WORLD_BOSS                       = 1,
	-- [2]集合-洞府Boss  -- 战斗 
	CONST_WAR_CLAN_BOSS                        = 2,
	-- [3]集合-洞府TD  -- 战斗 
	CONST_WAR_CLAN_TD                          = 3,
	-- [4]集合-洞府战  -- 战斗 
	CONST_WAR_CLAN_WAR                         = 4,
	-- [5]集合-城镇boss  -- 战斗 
	CONST_WAR_CITY_BOSS                        = 5,
	-- [6]集合-秘宝活动 -- 战斗 
	CONST_WAR_BOX_MONSTER                      = 6,

	-- [0]战斗-重力衰减系数 -- 战斗 
	CONST_WAR_DECAY_COEFFICIENT                = 0,
	-- [350]战斗-衰减高度 -- 战斗 
	CONST_WAR_DECAY_HIGHT                      = 350,

	-- [2]自动战斗VIP等级 -- 战斗 
	CONST_WAR_ZIDONG_VIP                       = 2,
	-- [20]自动战斗人物等级 -- 战斗 
	CONST_WAR_ZIDONG_LV                        = 20,

	-- [800]武将距离主角距离 -- 战斗 
	CONST_WAR_PARTNER_DISTANCE                 = 800,

	-- [0.08]打击僵直时间 -- 战斗 
	CONST_WAR_RIGIDITY_TIME                    = 0.08,
	-- [15]翻滚耗蓝 -- 战斗 
	CONST_WAR_ROLL_MP                          = 15,
	-- [400]翻滚距离 -- 战斗 
	CONST_WAR_ROLL_X                           = 400,
	-- [1000]翻滚CD -- 战斗 
	CONST_WAR_ROLL_CD                          = 1000,
	-- [1300]翻滚速度 -- 战斗 
	CONST_WAR_ROLL_SPEED                       = 1300,

	-- [20]坐骑持续时间 -- 战斗 
	CONST_WAR_MOUNT_TIME                       = 20,
	-- [180]坐骑cd -- 战斗 
	CONST_WAR_MOUNT_CD                         = 180,

	--------------------------------------------------------------------
	-- ( 技能 ) 
	--------------------------------------------------------------------
	-- [0]伙伴技能  -- 技能 
	CONST_SKILL_PARTNER_SKILL                  = 0,
	-- [0]主角技能  -- 技能 
	CONST_SKILL_ROLE_SKILL                     = 0,
	-- [0.3]技能冷却后高亮时  -- 技能 
	CONST_SKILL_CD_SHINE                       = 0.3,
	-- [0.6]技能点击效果持续时间  -- 技能 
	CONST_SKILL_CLICK_SHINE                    = 0.6,
	-- [1]技能装备方案1  -- 技能 
	CONST_SKILL_ONE                            = 1,
	-- [2]技能装备方案2  -- 技能 
	CONST_SKILL_TWO                            = 2,
	-- [3]技能装备方案3  -- 技能 
	CONST_SKILL_THREE                          = 3,
	-- [20]开启大招人物等级  -- 技能 
	CONST_SKILL_BIGSKILL_LV                    = 20,
	-- [100]技能等级上限  -- 技能 
	CONST_SKILL_LV_MAX                         = 100,
	-- [101]星阵图初始化等级  -- 技能 
	CONST_SKILL_STAR_LV                        = 101,

	-- [0]正常施放  -- 技能 
	CONST_SKILL_ARG_OPEN                       = 0,
	-- [1]不能施放技能  -- 技能 
	CONST_SKILL_ARG_CLOSE                      = 1,

	-- [5]技能初始装备数量  -- 技能 
	CONST_SKILL_EQUIP_INIT_NUM                 = 5,
	-- [6]技能最大装备数量  -- 技能 
	CONST_SKILL_EQUIP_MAX                      = 6,

	-- [0]是否占回合数-不占用  -- 技能 
	CONST_SKILL_ROUND_HAVE_NOT                 = 0,
	-- [1]是否占回合数-占用  -- 技能 
	CONST_SKILL_ROUND_HAVE                     = 1,

	-- [1]类型-被动  -- 技能 
	CONST_SKILL_TYPE_PASSIVITY                 = 1,
	-- [2]类型-主动  -- 技能 
	CONST_SKILL_TYPE_INITIATIVE                = 2,
	-- [3]类型- 兵器技能  -- 技能 
	CONST_SKILL_TYPE_WEAPON                    = 3,

	-- [1]效果触发-自己行动前  -- 技能 
	CONST_SKILL_TOUCH_ACTION_PRE               = 1,
	-- [2]效果触发-自己动手时  -- 技能 
	CONST_SKILL_TOUCH_ACTION                   = 2,
	-- [3]效果触发-自己动手后  -- 技能 
	CONST_SKILL_TOUCH_ACTION_AFTER             = 3,
	-- [4]效果触发-战斗开始时  -- 技能 
	CONST_SKILL_TOUCH_BEGIN                    = 4,

	-- [0]范围参数-目标(默认)  -- 技能 
	CONST_SKILL_SINGLE                         = 0,
	-- [1]范围参数-己方前军  -- 技能 
	CONST_SKILL_OWN_FRONT                      = 1,
	-- [2]范围-己方中军  -- 技能 
	CONST_SKILL_OWN_MIDDLE                     = 2,
	-- [3]范围参数-己方后军  -- 技能 
	CONST_SKILL_OWN_BACK                       = 3,
	-- [4]范围参数-己方全军  -- 技能 
	CONST_SKILL_OWN_ALL                        = 4,
	-- [5]范围参数-只对己方前中军  -- 技能 
	CONST_SKILL_OWN_FM_ONLY                    = 5,
	-- [6]范围参数-己方前后军  -- 技能 
	CONST_SKILL_OWN_FB                         = 6,
	-- [7]范围-己方中后军  -- 技能 
	CONST_SKILL_OWN_MB                         = 7,
	-- [8]范围-自身  -- 技能 
	CONST_SKILL_SELF                           = 8,
	-- [9]范围-己方其它  -- 技能 
	CONST_SKILL_OWN_OTHER                      = 9,
	-- [10]范围-对方前军  -- 技能 
	CONST_SKILL_FOE_FRONT                      = 10,
	-- [11]范围-对方中军  -- 技能 
	CONST_SKILL_FOE_MIDD                       = 11,
	-- [12]范围-对方后军  -- 技能 
	CONST_SKILL_FOE_BACK                       = 12,
	-- [13]范围-对方全军  -- 技能 
	CONST_SKILL_FOE_ALL                        = 13,
	-- [14]范围-对方前中军  -- 技能 
	CONST_SKILL_FOE_FM                         = 14,
	-- [15]范围-对方前后军  -- 技能 
	CONST_SKILL_FOE_FB                         = 15,
	-- [16]范围-对方中后军  -- 技能 
	CONST_SKILL_FOE_MB                         = 16,
	-- [17]范围-只对己方中军  -- 技能 
	CONST_SKILL_OWN_MID_ONLY                   = 17,
	-- [18]范围-只对己方后军  -- 技能 
	CONST_SKILL_OWN_BAC_ONLY                   = 18,

	-- [110]效果-对目标造成伤害，技能威力系数arg1%  -- 技能 
	CONST_SKILL_MC_110                         = 110,
	-- [115]攻击对方目标单位，技能威力系数{mc_arg1}%，提升己方目标{mc_arg2}%速度，持续arg9回合，当前回合生效  -- 技能 
	CONST_SKILL_MC_115                         = 115,
	-- [120]攻击对方目标单位，技能威力系数{mc_arg1}%，降低对方目标{mc_arg2}%速度，持续arg9回合，当前回合生效  -- 技能 
	CONST_SKILL_MC_120                         = 120,
	-- [125]攻击对方目标单位，技能威力系数{mc_arg1}%，降低对方目标{mc_arg2}%攻击，持续arg3次，当前回合生效  -- 技能 
	CONST_SKILL_MC_125                         = 125,
	-- [130]攻击目标单位，技能系数arg1%，提升目标arg2%攻击，arg3%暴击和arg4%破击,持续arg5次 -- 技能 
	CONST_SKILL_MC_130                         = 130,
	-- [135]攻击目标单位，技能系数arg1%，提升目标arg2%攻击持续arg3次和arg4点士气，恢复自身arg5点士气  -- 技能 
	CONST_SKILL_MC_135                         = 135,
	-- [210]效果-对目标造成伤害，技能威力系数arg1%，动手时提升自身格挡arg2%，持续arg3次数，当前回合生效  -- 技能 
	CONST_SKILL_MC_210                         = 210,
	-- [220]效果-对目标造成伤害，技能威力系数arg1%，动手时提升自身力量攻击力arg2%和灵力攻击力arg3%，持续arg4次数  -- 技能 
	CONST_SKILL_MC_220                         = 220,
	-- [230]效果-对目标造成伤害，技能威力系数arg1%，动手时降低对方格挡arg2%，持续arg3次数，当前回合生效  -- 技能 
	CONST_SKILL_MC_230                         = 230,
	-- [240]效果-对目标造成伤害，技能威力系数arg1%，动手时提升自身暴击arg2%，持续arg3次数，当前回合生效  -- 技能 
	CONST_SKILL_MC_240                         = 240,
	-- [250]效果-对目标造成伤害，技能威力系数arg1%，动手时提升己方中军破击arg2%，持续arg9回合，当前回合生效  -- 技能 
	CONST_SKILL_MC_250                         = 250,
	-- [255]效果-对目标造成伤害，技能威力系数arg1%，动手时提升自身闪避arg2%，持续arg3次数，当前回合生效  -- 技能 
	CONST_SKILL_MC_255                         = 255,
	-- [260]效果-对目标造成伤害，技能威力系数arg1%，动手时提升己方中军力量攻击arg2%和灵力攻击arg3%,持续arg9回合，当前回合生效  -- 技能 
	CONST_SKILL_MC_260                         = 260,
	-- [320]效果-对目标造成伤害，技能威力系数arg1%，动手后提升己方中军arg2点士气，恢复自身arg3点士气  -- 技能 
	CONST_SKILL_MC_320                         = 320,
	-- [410]效果-对目标造成伤害，技能威力系数arg1%，动手后提升己方其它单位arg2点士气，恢复自身arg3点士气  -- 技能 
	CONST_SKILL_MC_410                         = 410,
	-- [420]效果-对目标造成伤害，技能威力系数arg1%，动手时降低对方闪避arg2%,持续arg3次数，当前回合生效  -- 技能 
	CONST_SKILL_MC_420                         = 420,
	-- [510]效果-对目标造成伤害，技能威力系数arg1%，动手后恢复自身arg2点士气  -- 技能 
	CONST_SKILL_MC_510                         = 510,
	-- [550]效果-对目标造成伤害，技能威力系数arg1%，动手时损失自身arg2%的当前血量并提升自身力量攻击arg3%和格挡arg4%，持续arg5次数，当前回合生效  -- 技能 
	CONST_SKILL_MC_550                         = 550,
	-- [610]效果-对目标造成伤害，技能威力系数arg1%，动手时提升自身力量防御arg2%和灵力防御arg3%，持续arg4次数，当前回合生效  -- 技能 
	CONST_SKILL_MC_610                         = 610,
	-- [620]效果-对目标造成伤害，技能威力系数arg1%，动手后有（arg2%+（自身等级-对方等级）的绝对值*arg3%）的机率令对方眩晕并降低对方arg4点士气，持续arg5次，当前回合生效  -- 技能 
	CONST_SKILL_MC_620                         = 620,
	-- [630]对目标造成伤害，技能威力系数arg1%，动手后有（arg2%+（自身等级-对方等级）的绝对值*arg3%）的机率令对方眩晕，持续arg9回合  -- 技能 
	CONST_SKILL_MC_630                         = 630,
	-- [735]效果-对目标造成伤害，技能威力系数arg1%，动手时驱散己方目标arg2的异常状态，动手时使己方目标免疫眩晕效果，持续arg9回合，当前回合生效  -- 技能 
	CONST_SKILL_MC_735                         = 735,
	-- [750]效果-对目标造成伤害，技能威力系数arg1%，动手时令对方中毒，中毒比例arg2%，持续arg9回合，下回合生效  -- 技能 
	CONST_SKILL_MC_750                         = 750,
	-- [810]效果-治疗己方目标，治疗技能系数arg1%  -- 技能 
	CONST_SKILL_MC_810                         = 810,
	-- [840]效果-治疗己方目标，技能威力系数arg1%，持续治疗arg9回合，持续治疗比例arg3%，下回合生效  -- 技能 
	CONST_SKILL_MC_840                         = 840,
	-- [850]效果-治疗己方目标，治疗技能系数arg1%，动手后恢复自身arg2点士气  -- 技能 
	CONST_SKILL_MC_850                         = 850,
	-- [901]效果-对目标造成伤害，技能威力系数arg1%，动手时降低对方力量防御arg2%和灵力防御arg3%，持续arg4次数，当前回合生效  -- 技能 
	CONST_SKILL_MC_901                         = 901,
	-- [902]效果-对目标造成伤害，技能威力系数arg1%，动手后有arg3机率眩晕对方，持续arg2次数，当前回合生效  -- 技能 
	CONST_SKILL_MC_902                         = 902,
	-- [903]效果-对目标造成伤害，技能威力系数arg1%，动手时使己方中军免疫眩晕效果，持续arg9回合，当前回合生效  -- 技能 
	CONST_SKILL_MC_903                         = 903,
	-- [904]效果-对目标造成伤害，技能威力系数arg1%，动手时降低对方治疗效果arg2%，持续arg3次数，当前回合生效  -- 技能 
	CONST_SKILL_MC_904                         = 904,
	-- [905]效果-对目标造成伤害，技能威力系数arg1%，动手时提升自身求援率arg2%，持续arg3次数，当前回合生效  -- 技能 
	CONST_SKILL_MC_905                         = 905,
	-- [906]效果-对目标造成伤害，技能威力系数arg1%，动手时提升自身合击率arg2%，持续arg3次数，下回合生效  -- 技能 
	CONST_SKILL_MC_906                         = 906,
	-- [907]效果-对目标造成伤害，技能威力系数arg1%，动手时将己方中军移动至后军位置，持续arg9回合，当前回合生效  -- 技能 
	CONST_SKILL_MC_907                         = 907,
	-- [911]攻击对方目标单位，技能威力系数{mc_arg1}%，动手时提升自身{mc_arg2}%格挡和{mc_arg3}%攻击，持续{mc_arg5}次数  -- 技能 
	CONST_SKILL_MC_911                         = 911,
	-- [912]攻击对方目标单位，技能威力系数{mc_arg1}%，动手时提升自身{mc_arg2}%闪避和{mc_arg3}%攻击，持续{mc_arg5}次数  -- 技能 
	CONST_SKILL_MC_912                         = 912,
	-- [913]攻击对方目标单位，技能威力系数{mc_arg1}%，动手时提升自身{mc_arg2}%防御和{mc_arg3}%攻击，持续{mc_arg5}次数 (  -- 技能 
	CONST_SKILL_MC_913                         = 913,
	-- [915]攻击对方目标单位，技能威力系数{mc_arg1}%，动手后造成伤害的{mc_arg2}%转化为自身气血 -- 技能 
	CONST_SKILL_MC_915                         = 915,
	-- [916]攻击对方目标单位，技能威力系数{mc_arg1}%，提升自身{mc_arg2}%攻击，持续{mc_arg4}次数，造成伤害的{mc_arg5}%转化为自身气血  -- 技能 
	CONST_SKILL_MC_916                         = 916,
	-- [921]攻击对方地坤单位，技能威力系数{mc_arg1}%，动手后恢复自身最大气血的{mc_arg2}%  -- 技能 
	CONST_SKILL_MC_921                         = 921,
	-- [922]攻击对方目标单位，技能威力系数{mc_arg1}%，提升自身{mc_arg2}%攻击，持续arg4次数，恢复自身最大气血的{mc_arg5}%  -- 技能 
	CONST_SKILL_MC_922                         = 922,
	-- [925]攻击对方目标单位，技能威力系数{mc_arg1}%，动手后降低对方{mc_arg2}点士气，并使我方人伐单位免疫眩晕{mc_arg9}回合  -- 技能 
	CONST_SKILL_MC_925                         = 925,
	-- [926]攻击对方目标单位，技能威力系数{mc_arg1}%，动手后提升所有单位{mc_arg2}点士气，使我方天泽单位免疫眩晕{mc_arg9}回合  -- 技能 
	CONST_SKILL_MC_926                         = 926,
	-- [981]效果-战斗开始时，额外增加自身arg1点士气  -- 技能 
	CONST_SKILL_MC_981                         = 981,
	-- [982]效果-动手后提升自身力量攻击力arg1%和灵力攻击力arg2%，持续arg3次数，下回合生效  -- 技能 
	CONST_SKILL_MC_982                         = 982,
	-- [983]效果-动手后回复自身最大气血的arg1%  -- 技能 
	CONST_SKILL_MC_983                         = 983,
	-- [984]效果-动手后降低对方arg1点士气  -- 技能 
	CONST_SKILL_MC_984                         = 984,
	-- [985]效果-动手后将造成伤害的arg1%转化为自身气血  -- 技能 
	CONST_SKILL_MC_985                         = 985,
	-- [986]效果-动手后提升自身力量防御力arg1%和灵力防御力arg2%，持续arg3次数，下回合生效  -- 技能 
	CONST_SKILL_MC_986                         = 986,
	-- [987]兵器技-动手时有arg1%概率打出双倍伤害  -- 技能 
	CONST_SKILL_MC_987                         = 987,

	-- [1]类型-召唤技能  -- 技能 
	CONST_SKILL_CALL_SKILL                     = 1,
	-- [2]类型-伤害技能  -- 技能 
	CONST_SKILL_HURT_SKILL                     = 2,
	-- [3]类型-扫地技能  -- 技能 
	CONST_SKILL_ARMOR_SKILL                    = 3,
	-- [4]类型-变身技能  -- 技能 
	CONST_SKILL_CHANGE_SKILL                   = 4,
	-- [5]类型-起身躲闪技能 -- 技能 
	CONST_SKILL_DODGE_SKILL                    = 5,
	-- [6]类型-打断技能 -- 技能 
	CONST_SKILL_INTERRUPT_SKILL                = 6,

	-- [616]星阵图结束点-1  -- 技能 
	CONST_SKILL_STAR_LAST_ONE                  = 616,
	-- [716]星阵图结束点-2  -- 技能 
	CONST_SKILL_STAR_LAST_TWO                  = 716,
	-- [816]星阵图结束点-3  -- 技能 
	CONST_SKILL_STAR_LAST_THREE                = 816,

	-- [1]离体攻击类型-直线 -- 技能 
	CONST_SKILL_VITRO_OLD                      = 1,
	-- [2]离体攻击类型-抛射 -- 技能 
	CONST_SKILL_VITRO_BOMB                     = 2,
	-- [3]离体攻击类型-定位 -- 技能 
	CONST_SKILL_VITRO_LOCATION                 = 3,

	--------------------------------------------------------------------
	-- ( 新手卡 ) 
	--------------------------------------------------------------------
	-- [3]首充礼包倍数  -- 新手卡 
	CONST_CARD_PAY_MULTIPLE                    = 3,
	-- [5000]充值最大返利金额  -- 新手卡 
	CONST_CARD_MAX_YUANBAO                     = 5000,

	--------------------------------------------------------------------
	-- ( 称号 ) 
	--------------------------------------------------------------------
	-- [5]称号类型-团队  -- 称号 
	CONST_TITLE_TEAM                           = 5,
	-- [7]称号字符限制  -- 称号 
	CONST_TITLE_NAME_WORDS_LIMIT               = 7,

	-- [0]删除称号  -- 称号 
	CONST_TITLE_FLAG_DELETE                    = 0,
	-- [1]增加称号  -- 称号 
	CONST_TITLE_FLAG_ADD                       = 1,

	-- [0]称号不使用  -- 称号 
	CONST_TITLE_STATE_UNUSE                    = 0,
	-- [1]使用称号  -- 称号 
	CONST_TITLE_STATE_USE                      = 1,

	-- [1]称号类型-系统  -- 称号 
	CONST_TITLE_SYSTEM                         = 1,
	-- [2]称号类型-成就  -- 称号 
	CONST_TITLE_ACHIEVE                        = 2,
	-- [3]称号类型-排行  -- 称号 
	CONST_TITLE_RANK                           = 3,
	-- [4]称号类型-家族  -- 称号 
	CONST_TITLE_CLAN                           = 4,

	-- [1101]称号ID-有点小钱 -- 称号 
	CONST_TITLE_CZ_BIREN                       = 1101,
	-- [1102]称号ID-有钱任性 -- 称号 
	CONST_TITLE_CZ_DIGUO                       = 1102,
	-- [1201]称号ID-独孤求败 -- 称号 
	CONST_TITLE_JJ_SHENGFO                     = 1201,
	-- [1202]称号ID-万夫莫敌 -- 称号 
	CONST_TITLE_JJ_DASHENG                     = 1202,
	-- [1203]称号ID-霸气外露 -- 称号 
	CONST_TITLE_JJ_SHENJIANG                   = 1203,
	-- [1204]称号ID-深藏不露 -- 称号 
	CONST_TITLE_JJ_XIANREN                     = 1204,
	-- [1301]称号ID-超级门派 -- 称号 
	CONST_TITLE_DF_SHENFU                      = 1301,
	-- [1302]称号ID-名门望族 -- 称号 
	CONST_TITLE_DF_FUDI                        = 1302,
	-- [1401]称号ID-锁妖第一 -- 称号 
	CONST_TITLE_TT_DASHENG                     = 1401,
	-- [1501]称号ID-三清天尊 -- 称号 
	CONST_TITLE_DZ_ZHIZUN                      = 1501,
	-- [1502]称号ID-万人之上 -- 称号 
	CONST_TITLE_DZ_ZHANSHEN                    = 1502,
	-- [1503]称号ID-叱咤沙场 -- 称号 
	CONST_TITLE_DZ_RENJIAN                     = 1503,
	-- [1601]称号ID-纵横无敌 -- 称号 
	CONST_TITLE_ZF_ZONGHENG                    = 1601,
	-- [1602]称号ID-无法无天 -- 称号 
	CONST_TITLE_ZF_HONGCHEN                    = 1602,
	-- [1701]称号ID-第一门派 -- 称号 
	CONST_TITLE_ZS_SHENGZHE                    = 1701,
	-- [1702]称号ID-横扫千军 -- 称号 
	CONST_TITLE_ZS_JINGANG                     = 1702,
	-- [1703]称号ID-十步一杀 -- 称号 
	CONST_TITLE_ZS_CHANGSHENG                  = 1703,
	-- [1704]称号ID-罕有敌手 -- 称号 
	CONST_TITLE_ZS_XIEMO                       = 1704,

	-- [1]称号类型-永久  -- 称号 
	CONST_TITLE_REPLACE_1                      = 1,
	-- [2]称号类型-定时  -- 称号 
	CONST_TITLE_REPLACE_2                      = 2,
	-- [3]称号类型-实时  -- 称号 
	CONST_TITLE_REPLACE_3                      = 3,

	-- [1]称号状态-已激活  -- 称号 
	CONST_TITLE_STATA_1                        = 1,
	-- [2]称号状态-不可激活  -- 称号 
	CONST_TITLE_STATA_2                        = 2,

	--------------------------------------------------------------------
	-- ( 防沉迷 ) 
	--------------------------------------------------------------------
	-- [0]防沉迷状态-正常(非沉迷状态)  -- 防沉迷 
	CONST_FCM_NORMAL                           = 0,
	-- [1]防沉迷状态-收益减半  -- 防沉迷 
	CONST_FCM_HALF                             = 1,
	-- [2]防沉迷状态-收益为0  -- 防沉迷 
	CONST_FCM_NOTHING                          = 2,

	-- [3]防沉迷-时间沉余(秒)  -- 防沉迷 
	CONST_FCM_ERROR_VALUE                      = 3,
	-- [900]防沉迷-超出5小时，每15分钟提示一次  -- 防沉迷 
	CONST_FCM_TIP_INTERVAL                     = 900,

	--------------------------------------------------------------------
	-- ( 反馈 ) 
	--------------------------------------------------------------------
	-- [0]反馈-失败  -- 反馈 
	CONST_FB_BAD                               = 0,
	-- [1]反馈-成功  -- 反馈 
	CONST_FB_OK                                = 1,

	-- [1]类型-bug  -- 反馈 
	CONST_FB_TYPE_BUG                          = 1,
	-- [2]类型-建议  -- 反馈 
	CONST_FB_TYPE_SUGGEST                      = 2,
	-- [3]类型-投诉  -- 反馈 
	CONST_FB_TYPE_COMPLAINT                    = 3,

	--------------------------------------------------------------------
	-- ( 素材 ) 
	--------------------------------------------------------------------
	-- [2]皮肤-机器人  -- 素材 
	CONST_MATERIAL_SKIN_ROBOT                  = 2,
	-- [3]皮肤-庞物  -- 素材 
	CONST_MATERIAL_SKIN_PET                    = 3,
	-- [4]皮肤-浮云(坐骑)  -- 素材 
	CONST_MATERIAL_SKIN_MOUNT                  = 4,
	-- [5]皮肤-武器  -- 素材 
	CONST_MATERIAL_SKIN_WEAPON                 = 5,
	-- [6]皮肤-衣服  -- 素材 
	CONST_MATERIAL_SKIN_ARMOR                  = 6,
	-- [7]时装  -- 素材 
	CONST_MATERIAL_FASHION                     = 7,

	-- [-2]图标-系统  -- 素材 
	CONST_MATERIAL_ICON_SYSTEM                 = -2,
	-- [-1]图标-技能  -- 素材 
	CONST_MATERIAL_ICON_SKILL                  = -1,
	-- [1]图标-装备  -- 素材 
	CONST_MATERIAL_ICON_EQUI                   = 1,
	-- [2]图标-武器  -- 素材 
	CONST_MATERIAL_ICON_WEAPON                 = 2,
	-- [3]图标-功能  -- 素材 
	CONST_MATERIAL_ICON_FUN                    = 3,
	-- [4]图标-普通  -- 素材 
	CONST_MATERIAL_ICON_NORMAL                 = 4,
	-- [5]图标-任务  -- 素材 
	CONST_MATERIAL_ICON_TASK                   = 5,

	--------------------------------------------------------------------
	-- ( 签到 ) 
	--------------------------------------------------------------------
	-- [0]玩家类型--普通  -- 签到 
	CONST_SIGN_TYPE_PLAIN                      = 0,
	-- [1]玩家类型--vip  -- 签到 
	CONST_SIGN_TYPE_VIP                        = 1,
	-- [102210]开启签到需完成的任务ID  -- 签到 
	CONST_SIGN_START                           = 102210,

	-- [3]连续签到的最大天数  -- 签到 
	CONST_SIGN_TIM_MAX                         = 3,
	-- [3]Vip玩家签到所需的VIP等级  -- 签到 
	CONST_SIGN_VIPLV                           = 3,

	-- [0]VIP玩家已签到  -- 签到 
	CONST_SIGN_SIGN_VIP_OK                     = 0,
	-- [1]VIP玩家未签到  -- 签到 
	CONST_SIGN_SIGN_VIP_NO                     = 1,

	-- [0]普通玩家未领取奖励  -- 签到 
	CONST_SIGN_NO                              = 0,
	-- [1]普通玩家已领取奖励  -- 签到 
	CONST_SIGN_OK                              = 1,

	--------------------------------------------------------------------
	-- ( NPC ) 
	--------------------------------------------------------------------
	-- [1]仓库  -- NPC 
	CONST_NPC_FUN_DEPOT                        = 1,
	-- [3]商店  -- NPC 
	CONST_NPC_FUN_SHOP                         = 3,
	-- [4]优惠商店  -- NPC 
	CONST_NPC_FUN_PREFEREN_SHOP                = 4,
	-- [8]进入副本（组队）  -- NPC 
	CONST_NPC_FUN_COPY_TEAM                    = 8,
	-- [15]灵珠镶嵌  -- NPC 
	CONST_NPC_FUN_GEM                          = 15,
	-- [16]打开商场  -- NPC 
	CONST_NPC_FUN_MALL                         = 16,
	-- [17]进入旅馆  -- NPC 
	CONST_NPC_FUN_TAVERN                       = 17,
	-- [18]打开年兽  -- NPC 
	CONST_NPC_FUN_NIANSHOU                     = 18,

	-- [148]仓库NPC的ID  -- NPC 
	CONST_NPC_WAREHOUSE_ID                     = 148,
	-- [40201]仓库NPC的场景ID  -- NPC 
	CONST_NPC_WAREHOUSE_SCENCE                 = 40201,

	--------------------------------------------------------------------
	-- ( 湛卢坊 ) 
	--------------------------------------------------------------------
	-- [0]强化下降固定等级(首饰)  -- 湛卢坊 
	CONST_MAKE_STREN_LOW_JEW                   = 0,
	-- [2]强化下降固定等级(法宝)  -- 湛卢坊 
	CONST_MAKE_STREN_LOW_MAGIC                 = 2,
	-- [4]强化下降固定等级(装备)  -- 湛卢坊 
	CONST_MAKE_STREN_LOW_WEA                   = 4,
	-- [6]附加最大条数  -- 湛卢坊 
	CONST_MAKE_BIPTIZE_COUNT_MAX               = 6,
	-- [10]双倍强化消耗金元  -- 湛卢坊 
	CONST_MAKE_STREN_DOU_COST                  = 10,
	-- [10]打折强化消耗金元  -- 湛卢坊 
	CONST_MAKE_STREN_DIS_COST                  = 10,
	-- [30]装备镶嵌等级  -- 湛卢坊 
	CONST_MAKE_LV_INLAX                        = 30,

	-- [1]法宝升阶需要vip等级  -- 湛卢坊 
	CONST_MAKE_MAGIC_UPGRADE_VIP               = 1,
	-- [1]法宝升阶强化等级降级  -- 湛卢坊 
	CONST_MAKE_MAGIC_UPGRADE_LOW               = 1,
	-- [3]法宝升阶需要最低等阶  -- 湛卢坊 
	CONST_MAKE_MAGIC_UPGRADE_CLASS             = 3,

	-- [1]洗练类型--普通  -- 湛卢坊 
	CONST_MAKE_WASH_TYPE_COMM                  = 1,
	-- [2]洗练类型--定向  -- 湛卢坊 
	CONST_MAKE_WASH_TYPE_FIXED                 = 2,
	-- [3]洗练类型--技能  -- 湛卢坊 
	CONST_MAKE_WASH_TYPE_SKILL                 = 3,
	-- [4]洗练类型--批量普通  -- 湛卢坊 
	CONST_MAKE_WASH_TYPE_MUL_COM               = 4,
	-- [5]洗练类型--批量定向  -- 湛卢坊 
	CONST_MAKE_WASH_TYPE_MUL_FIX               = 5,

	-- [5]批量洗练次数  -- 湛卢坊 
	CONST_MAKE_WASH_COUNT                      = 5,

	-- [1]灵珠合成类型--普通  -- 湛卢坊 
	CONST_MAKE_COMPOSE_COMM                    = 1,
	-- [2]灵珠合成类型--一键  -- 湛卢坊 
	CONST_MAKE_COMPOSE_ONEKEY                  = 2,

	-- [1]打造预览-未知  -- 湛卢坊 
	CONST_MAKE_MAKE_UNKNOW                     = 1,

	-- [2000]双倍强化-概率  -- 湛卢坊 
	CONST_MAKE_STREN_DOUBLE_ODDS               = 2000,

	-- [3]装备强化功能开启等级  -- 湛卢坊 
	CONST_MAKE_INTENSIFY_LV_OPEN               = 3,
	-- [15]装备镶嵌功能开启等级  -- 湛卢坊 
	CONST_MAKE_INLAY_LV_OPEN                   = 15,
	-- [30]装备附魔功能开启等级  -- 湛卢坊 
	CONST_MAKE_ENCHANTING_LV_OPEN              = 30,
	-- [40]装备升品功能开启等级  -- 湛卢坊 
	CONST_MAKE_QUALITY_LV_OPEN                 = 40,

	-- [1]单线打造  -- 湛卢坊 
	CONST_MAKE_ONE_ROAD                        = 1,
	-- [2]多线打造  -- 湛卢坊 
	CONST_MAKE_MANY_ROAD                       = 2,

	-- [3]批量洗练需要vip等级  -- 湛卢坊 
	CONST_MAKE_WASH_VIP                        = 3,

	-- [10]洗练消耗洗练石  -- 湛卢坊 
	CONST_MAKE_WASH_XLS                        = 10,
	-- [10]洗练消耗元宝  -- 湛卢坊 
	CONST_MAKE_WASH_RMB                        = 10,
	-- [20000]洗练消耗铜钱  -- 湛卢坊 
	CONST_MAKE_WASH_GOLD                       = 20000,
	-- [58000]洗练石id  -- 湛卢坊 
	CONST_MAKE_WASH_XLS_ID                     = 58000,

	-- [3]宝石镶嵌-1级宝石价格  -- 湛卢坊 
	CONST_MAKE_GEM_PRICE                       = 3,
	-- [7]宝石最高等级  -- 湛卢坊 
	CONST_MAKE_PEAR_LV                         = 7,

	--------------------------------------------------------------------
	-- ( 阵营 ) 
	--------------------------------------------------------------------
	-- [10101]人地图ID  -- 阵营 
	CONST_COUNTRY_WIND_MAP                     = 10101,
	-- [20101]仙地图ID  -- 阵营 
	CONST_COUNTRY_FIRE_MAP                     = 20101,
	-- [30101]魔地图ID  -- 阵营 
	CONST_COUNTRY_CLOUD_MAP                    = 30101,
	-- [100180]阵营任务ID  -- 阵营 
	CONST_COUNTRY_TASK_ID                      = 100180,

	-- [40071]听天由命礼包ID  -- 阵营 
	CONST_COUNTRY_RAND_GIFT                    = 40071,

	--------------------------------------------------------------------
	-- ( 商城 ) 
	--------------------------------------------------------------------
	-- [10]商城类型--普通商店  -- 商城 
	CONST_MALL_TYPE_ID_ORDINARY                = 10,
	-- [20]商城类型--限时商店  -- 商城 
	CONST_MALL_TYPE_ID_TIMEOUT                 = 20,
	-- [60]商城类型--神兵兑换  -- 商城 
	CONST_MALL_TYPE_ID_MAGIC                   = 60,
	-- [70]商城类型--至尊兑换 -- 商城 
	CONST_MALL_TYPE_ID_EXTREME                 = 70,
	-- [80]商城类型--积分兑换 -- 商城 
	CONST_MALL_TYPE_ID_INTEGRAL                = 80,
	-- [1010]商城子类型--火热 -- 商城 
	CONST_MALL_TYPE_SUB_HOT                    = 1010,
	-- [1020]商城子类型--宝石 -- 商城 
	CONST_MALL_TYPE_SUB_GEM                    = 1020,
	-- [1030]商城子类型--道具 -- 商城 
	CONST_MALL_TYPE_SUB_PROPS                  = 1030,
	-- [1040]商城子类型--礼包 -- 商城 
	CONST_MALL_TYPE_SUB_PACKAGE                = 1040,
	-- [1050]商城子类型--元宝 -- 商城 
	CONST_MALL_TYPE_SUB_INGOT                  = 1050,
	-- [2010]商城子类型--限时团购  -- 商城 
	CONST_MALL_TYPE_SUB_TIMEOUTS               = 2010,
	-- [5010]商城子类型--灵妖商城 -- 商城 
	CONST_MALL_TYPE_SUB_LY                     = 5010,
	-- [6010]商城子类型--神兵兑换 -- 商城 
	CONST_MALL_TYPE_SUB_MAGICS                 = 6010,
	-- [7010]商城子类型--至尊兑换 -- 商城 
	CONST_MALL_TYPE_SUB_EXTREMES               = 7010,

	-- [8010]商城子类型--积分兑换 -- 商城 
	CONST_MALL_TYPE_SUB_INTEGRAL               = 8010,
	-- [10000]消费积分兑换比率（万分比）  -- 商城 
	CONST_MALL_EXCHANGE_RATE                   = 10000,

	-- [1]商品属性-只能买一次(永久) -- 商城 
	CONST_MALL_TYPE_ONCE                       = 1,
	-- [6]VIP6商店优惠购买特权  -- 商城 
	CONST_MALL_VIP_EFFECT                      = 6,

	-- [10]商店按钮出现等级  -- 商城 
	CONST_MALL_SHOP_LV                         = 10,

	-- [1]附加属性类型-等级限制  -- 商城 
	CONST_MALL_TYPE_LV                         = 1,
	-- [2]附加属性类型-VIP限制  -- 商城 
	CONST_MALL_TYPE_VIP                        = 2,
	-- [3]附加属性类型--出现机率  -- 商城 
	CONST_MALL_TYPE_ODDS                       = 3,
	-- [19]限时团购开始小时  -- 商城 
	CONST_MALL_TUANGOU_BEGIN                   = 19,

	--------------------------------------------------------------------
	-- ( 福利 ) 
	--------------------------------------------------------------------
	-- [9](奖励领取类型)新手卡  -- 福利 
	CONST_WELFARE_NEWCARD                      = 9,
	-- [10](奖励领取类型)媒体卡  -- 福利 
	CONST_WELFARE_NEWCARD_MEDIA                = 10,

	-- [1](奖励领取类型)连续登陆  -- 福利 
	CONST_WELFARE_REWARD_LOGIN                 = 1,
	-- [2](奖励领取类型)日累计在线  -- 福利 
	CONST_WELFARE_REWARD_CUMUL_DAY             = 2,
	-- [3](奖励领取类型)周累计在线  -- 福利 
	CONST_WELFARE_REWARD_CUMUL_WEEK            = 3,
	-- [4](奖励领取类型)充值累计  -- 福利 
	CONST_WELFARE_REWARD_PAY_CUMUL             = 4,
	-- [5](奖励领取类型)充值额度  -- 福利 
	CONST_WELFARE_REWARD_PAY_LIMIT             = 5,
	-- [6](奖励领取类型)首次创建人物倒计时  -- 福利 
	CONST_WELFARE_REWARD_FIRST_CREATE          = 6,
	-- [7](奖励领取类型)登陆在线倒计时  -- 福利 
	CONST_WELFARE_REWARD_CUMUL_ONLINE          = 7,

	-- [1](请求数据)登陆  -- 福利 
	CONST_WELFARE_LIST_CONTINUE                = 1,
	-- [2](请求数据)在线  -- 福利 
	CONST_WELFARE_LIST_CUMUL                   = 2,
	-- [3](请求数据)充值  -- 福利 
	CONST_WELFARE_LIST_PAY                     = 3,
	-- [4](请求数据)经验  -- 福利 
	CONST_WELFARE_LIST_EXP                     = 4,
	-- [5](请求黄钻特权)每日面板  -- 福利 
	CONST_WELFARE_LIST_YELLOW_DAY              = 5,

	-- [8](奖励领取类型)经验找回  -- 福利 
	CONST_WELFARE_EXP_RECOVER                  = 8,

	--------------------------------------------------------------------
	-- ( 竞技场 ) 
	--------------------------------------------------------------------
	-- [0]广播类型-JJC信息  -- 竞技场 
	CONST_ARENA_HEARSAY                        = 0,
	-- [1]广播类型-排名第一传闻  -- 竞技场 
	CONST_ARENA_HEARSAY_ONE                    = 1,
	-- [1]事件--竞技场  -- 竞技场 
	CONST_ARENA_EVENT                          = 1,
	-- [3]挑战失败后的冷却时间（分钟）  -- 竞技场 
	CONST_ARENA_LOSE_TIME                      = 3,
	-- [5]jjc 显示人数  -- 竞技场 
	CONST_ARENA_SHOW_ROLE                      = 5,
	-- [10]取前10个挑战信息  -- 竞技场 
	CONST_ARENA_NUM                            = 10,
	-- [10]每天刷新剩余次数  -- 竞技场 
	CONST_ARENA_SURPLUS                        = 10,
	-- [15]进入竞技场需要等级  -- 竞技场 
	CONST_ARENA_YES_ARENA                      = 15,
	-- [180]竞技场战斗时间  -- 竞技场 
	CONST_ARENA_BATTLE_TIME                    = 180,

	-- [1]消除冷却时间所需的钻石（每分钟）  -- 竞技场 
	CONST_ARENA_FAST_RMB                       = 1,
	-- [5]购买挑战次数所需的元宝（首次）  -- 竞技场 
	CONST_ARENA_BUY_RMB                        = 5,
	-- [10]竞技场每天可购买次数  -- 竞技场 
	CONST_ARENA_BUY_MAX_TIMES                  = 10,

	-- [1]状态--挑战成功  -- 竞技场 
	CONST_ARENA_STATA_1                        = 1,
	-- [2]状态--挑战失败  -- 竞技场 
	CONST_ARENA_STATA_2                        = 2,
	-- [3]状态--挑站排名不变 赢  -- 竞技场 
	CONST_ARENA_STATA_3                        = 3,
	-- [4]挑站排名不变 输  -- 竞技场 
	CONST_ARENA_STATA_4                        = 4,

	-- [1]竞技场_产生霸体攻击次数  -- 竞技场 
	CONST_ARENA_BATI_NUM                       = 1,
	-- [309]竞技场_霸体BUFF  -- 竞技场 
	CONST_ARENA_BATI_BUFF                      = 309,

	-- [2]类型-领取  -- 竞技场 
	CONST_ARENA_SET_TYPE_2                     = 2,
	-- [3]类型- 购买挑战  -- 竞技场 
	CONST_ARENA_BUY                            = 3,

	-- [10]连胜-终结连胜-10场  -- 竞技场 
	CONST_ARENA_WIN_LINK_10                    = 10,
	-- [50]连胜-终结连胜-50场  -- 竞技场 
	CONST_ARENA_WIN_LINK_50                    = 50,
	-- [100]连胜-终结连胜-100场  -- 竞技场 
	CONST_ARENA_WIN_LINK_100                   = 100,
	-- [500]连胜-终结连胜-500场  -- 竞技场 
	CONST_ARENA_WIN_LINK_500                   = 500,
	-- [1000]连胜-终结连胜-1000场  -- 竞技场 
	CONST_ARENA_WIN_LINK_1000                  = 1000,

	-- [5000]世界平均等级经验加成  -- 竞技场 
	CONST_ARENA_WLV_EXP_ADD                    = 5000,

	-- [60110]竞技场场景ID  -- 竞技场 
	CONST_ARENA_THE_ARENA_ID                   = 60110,
	-- [60115]竞技场_奴仆场景ID  -- 竞技场 
	CONST_ARENA_JJC_MOIL_ID                    = 60115,
	-- [60116]竞技场_奴仆反抗场景ID  -- 竞技场 
	CONST_ARENA_JJC_MOIL2_ID                   = 60116,
	-- [60120]竞技场_押镖场景ID  -- 竞技场 
	CONST_ARENA_JJC_ESCORT_ID                  = 60120,
	-- [60140]竞技场_封神榜场景ID  -- 竞技场 
	CONST_ARENA_JJC_WARLORDS_ID                = 60140,
	-- [60155]竞技场_英雄塔场景ID  -- 竞技场 
	CONST_ARENA_JJC_HERO_TOWER_ID              = 60155,
	-- [60165]竞技场_灵妖竞技场景ID  -- 竞技场 
	CONST_ARENA_JJC_LY_ID                      = 60165,
	-- [60190]竞技场-跨服竞技场场景ID  -- 竞技场 
	CONST_ARENA__KFJJC_ID                      = 60190,

	-- [150]竞技场右"y"  -- 竞技场 
	CONST_ARENA_SENCE_RIGHT_Y                  = 150,
	-- [150]竞技场左"y"  -- 竞技场 
	CONST_ARENA_SENCE_LEFT_Y                   = 150,
	-- [200]竞技场左"x"  -- 竞技场 
	CONST_ARENA_SENCE_LEFT_X                   = 200,
	-- [900]竞技场右"x"  -- 竞技场 
	CONST_ARENA_RIGHT_X                        = 900,
	-- [900]竞技场_刷新按键出现名次 -- 竞技场 
	CONST_ARENA_JJC_SHUAXIN                    = 900,

	-- [1]机器人初始id  -- 竞技场 
	CONST_ARENA_JION_ROBERT                    = 1,
	-- [5]战斗时增加气血倍数  -- 竞技场 
	CONST_ARENA_ATTR_HP_TIMES                  = 5,
	-- [500]添加机器人数量  -- 竞技场 
	CONST_ARENA_ROBERT_NUM                     = 500,

	--------------------------------------------------------------------
	-- ( 广播 ) 
	--------------------------------------------------------------------
	-- [30]广播每次最大人数  -- 广播 
	CONST_BROAD_MAX_PLAYER                     = 30,
	-- [5000]竞技场第一名登陆延迟多少毫米广播  -- 广播 
	CONST_BROAD_ARENA_ONE_TIME                 = 5000,

	-- [1]广播字段类型--角色名字  -- 广播 
	CONST_BROAD_PLAYER_NAME                    = 1,
	-- [2]广播字段类型--家族名字  -- 广播 
	CONST_BROAD_CLAN_NAME                      = 2,
	-- [3]广播字段类型--团队名字  -- 广播 
	CONST_BROAD_GROUP_NAME                     = 3,
	-- [4]广播字段类型--副本Id  -- 广播 
	CONST_BROAD_COPY_ID                        = 4,
	-- [5]广播字段类型--角色名字（有职业）  -- 广播 
	CONST_BROAD_PLAYER_NAME_NEW                = 5,
	-- [50]广播字段类型--普通字符串  -- 广播 
	CONST_BROAD_STRING                         = 50,
	-- [51]广播字段类型--普通数字  -- 广播 
	CONST_BROAD_NUMBER                         = 51,
	-- [52]广播字段类型--地图ID  -- 广播 
	CONST_BROAD_MAPID                          = 52,
	-- [54]广播字段类型--物品ID  -- 广播 
	CONST_BROAD_GOODSID                        = 54,
	-- [55]广播字段类型--怪物ID  -- 广播 
	CONST_BROAD_MONSTERID                      = 55,
	-- [56]广播字段类型--三界杀卷名ID  -- 广播 
	CONST_BROAD_CIRCLE_CHAP                    = 56,
	-- [57]广播字段类型--奖励内容  -- 广播 
	CONST_BROAD_REWARD                         = 57,
	-- [59]广播字段类型--颜色  -- 广播 
	CONST_BROAD_NAME_COLOR                     = 59,
	-- [61]广播字段类型--伙伴ID  -- 广播 
	CONST_BROAD_PARTNER_ID                     = 61,
	-- [62]广播字段类型--卦象ID  -- 广播 
	CONST_BROAD_DOUQI_ID                       = 62,
	-- [63]广播字段类型--VIP等级  -- 广播 
	CONST_BROAD_VIP_LV                         = 63,
	-- [64]广播字段类型--坐骑ID  -- 广播 
	CONST_BROAD_MOUNT                          = 64,
	-- [65]广播字段类型--美人ID  -- 广播 
	CONST_BROAD_MEIREN                         = 65,
	-- [66]广播字段类型--称号名称  -- 广播 
	CONST_BROAD_TITLE                          = 66,
	-- [67]广播字段类型--排行榜  -- 广播 
	CONST_BROAD_TOP                            = 67,
	-- [68]广播字段类型--物品信息块  -- 广播 
	CONST_BROAD_GOODS_MSG                      = 68,
	-- [69]广播字段类型--城镇  -- 广播 
	CONST_BROAD_CITY_ID                        = 69,
	-- [70]广播字段类型--活动名称 -- 广播 
	CONST_BROAD_PLAYER_ID                      = 70,

	-- [1010]系统-停服  -- 广播 
	CONST_BROAD_ID_SERVER_CLOSE                = 1010,
	-- [1020]系统-开服  -- 广播 
	CONST_BROAD_ID_SERVER_OPEN                 = 1020,
	-- [1030]获得VIP5或以上  -- 广播 
	CONST_BROAD_VIP_5                          = 1030,
	-- [2010]打造神器—获得传说神器  -- 广播 
	CONST_BROAD_ID_TALISMAN                    = 2010,
	-- [2020]打造装备-打造橙色装备  -- 广播 
	CONST_BROAD_ORANGE                         = 2020,
	-- [2030]宝石合成-合成10级以上宝石  -- 广播 
	CONST_BROAD_JEWEL_10                       = 2030,
	-- [2040]坐骑-坐骑幻化成功  -- 广播 
	CONST_BROAD_MOUNT_HUANHUA                  = 2040,
	-- [2050]美人-获得美人  -- 广播 
	CONST_BROAD_MEIREN_GET                     = 2050,
	-- [2060]酒馆—招募武将  -- 广播 
	CONST_BROAD_INN_GET                        = 2060,
	-- [2070]神将招募-招募神将成功  -- 广播 
	CONST_BROAD_SHENJIAN_GET                   = 2070,
	-- [2080]领悟金色和橙色卦象  -- 广播 
	CONST_BROAD_DOUQI_ORANGE                   = 2080,
	-- [2090]更改名字  -- 广播 
	CONST_BROAD_CHANGE_NAME                    = 2090,
	-- [2091]开箱子  -- 广播 
	CONST_BROAD_OPEN_BOX                       = 2091,
	-- [2092]洞府-洞府更名  -- 广播 
	CONST_BROAD_CHANGE_CLAN_NAME               = 2092,
	-- [2093]摇钱树-10倍暴击  -- 广播 
	CONST_BROAD_WEAGOD                         = 2093,
	-- [3010]首冲礼包-获得首冲礼包  -- 广播 
	CONST_BROAD_FIRST_CHARGE                   = 3010,
	-- [3015]首充礼包-获得每日首充礼包  -- 广播 
	CONST_BROAD_DAILY_FIRST                    = 3015,
	-- [3020]签到抽奖-抽到100元宝  -- 广播 
	CONST_BROAD_SIGN_100                       = 3020,
	-- [3030]<1>充值了<51>元宝，已是富甲一方的土豪！  -- 广播 
	CONST_BROAD_TUHAO                          = 3030,
	-- [3040]充值转盘-抽到6级宝石  -- 广播 
	CONST_BROAD_WHELL_6_JEWEL                  = 3040,
	-- [3050]<1>在消费有礼中走了大运，获得了110元宝！  -- 广播 
	CONST_BROAD_CONSUME_LUCKY                  = 3050,
	-- [3060]<1>在抽奖中获得了5元话费，运气不错呀！  -- 广播 
	CONST_BROAD_CONSUME_5                      = 3060,
	-- [3070]<1>在抽奖中获得了10元话费，那运气真是杠杠的！  -- 广播 
	CONST_BROAD_CONSUME_10                     = 3070,
	-- [3080]<1>竟然在抽奖中获得了三星Galaxy S4，运气真是好到爆了你造吗？  -- 广播 
	CONST_BROAD_CONSUME_S4                     = 3080,
	-- [3090]<1>居然在抽奖中获得了苹果iphone5S，是财神爷保佑啊你造吗？  -- 广播 
	CONST_BROAD_CONSUME_5S                     = 3090,
	-- [3099]恭喜<1>获得了<1>的福泽天下礼包 -- 广播 
	CONST_BROAD_FZTX                           = 3099,
	-- [3100]消费有礼-提醒广播抽奖话费  -- 广播 
	CONST_BROAD_DRAW_HUAFEI                    = 3100,
	-- [3110]消费有礼-提醒广播抽奖S5  -- 广播 
	CONST_BROAD_DRAW_S5                        = 3110,
	-- [4010]竞技场—连胜10次以上  -- 广播 
	CONST_BROAD_ID_ARENA_10                    = 4010,
	-- [4020]竞技场—连胜20次以上  -- 广播 
	CONST_BROAD_ID_ARENA_20                    = 4020,
	-- [4030]竞技场—连胜30次以上  -- 广播 
	CONST_BROAD_ID_ARENA_30                    = 4030,
	-- [4040]竞技场—连胜50次以上  -- 广播 
	CONST_BROAD_ID_ARENA_50                    = 4040,
	-- [4050]竞技场—连胜100次以上  -- 广播 
	CONST_BROAD_ID_ARENA_100                   = 4050,
	-- [4060]竞技场—终结10次以上的连胜  -- 广播 
	CONST_BROAD_ID_ARENA_S_10                  = 4060,
	-- [4070]竞技场—第一名更换  -- 广播 
	CONST_BROAD_ID_ARENA_ONE                   = 4070,
	-- [4080]排行榜-各类排行版排名第一更换  -- 广播 
	CONST_BROAD_ONE_CHANGE                     = 4080,
	-- [4090]称号-获得称号  -- 广播 
	CONST_BROAD_TITLE_GET                      = 4090,
	-- [4100]宣传-第一名的玩家登录游戏  -- 广播 
	CONST_BROAD_AREAN_ONE                      = 4100,
	-- [4110]切磋-结果 -- 广播 
	CONST_BROAD_PK_RESULT                      = 4110,
	-- [5010]<1>愈战愈勇，终于击败了<4>！  -- 广播 
	CONST_BROAD_HERO_OVER                      = 5010,
	-- [5020]<1>以一敌百，终于击败了<4>！  -- 广播 
	CONST_BROAD_FIEND_OVER                     = 5020,
	-- [5030]天下第一-报名时间通告  -- 广播 
	CONST_BROAD_TXDY_SIGN                      = 5030,
	-- [5031]天下第一小组赛开启提前通告  -- 广播 
	CONST_BROAD_TXDY_YUSAI_5_MINUTE            = 5031,
	-- [5032]天下第一小组赛开启准备  -- 广播 
	CONST_BROAD_TXDY_YUSAI_1_MINUTE            = 5032,
	-- [5033]天下第一小组赛开启  -- 广播 
	CONST_BROAD_TXDY_YUSAI_START               = 5033,
	-- [5035]天下第一半区决赛开启提前通告  -- 广播 
	CONST_BROAD_TXDY_FINAL_5_MINUTE            = 5035,
	-- [5036]天下第一半区决赛开启准备  -- 广播 
	CONST_BROAD_TXDY_FINAL_1_MINUTE            = 5036,
	-- [5037]天下第一半区决赛开启  -- 广播 
	CONST_BROAD_TXDY_FINAL_START               = 5037,
	-- [5038]天下第一活动未能开启公告  -- 广播 
	CONST_BROAD_TXDY_CANCLE                    = 5038,
	-- [5040]天下第一-上下半区第一名  -- 广播 
	CONST_BROAD_TXDY_FIRST                     = 5040,
	-- [5050]天下第一-总决赛获胜  -- 广播 
	CONST_BROAD_TXDY_FINAL                     = 5050,
	-- [5051]天下第一活动取消 -- 广播 
	CONST_BROAD_TXDY_CANCEL                    = 5051,
	-- [5060]欢乐竞猜-开启活动通告  -- 广播 
	CONST_BROAD_TXDY_GUESS                     = 5060,
	-- [5070]封神榜-军衔升级到都督  -- 广播 
	CONST_BROAD_QUNXIONG_DUDU                  = 5070,
	-- [5080]封神榜-军衔升级到将军  -- 广播 
	CONST_BROAD_QUNXIONG_JIANGJUN              = 5080,
	-- [5090]过关斩将通过全部关卡  -- 广播 
	CONST_BROAD_FIGHTERS_ALL                   = 5090,
	-- [5100]三国群英-天地榜第一名更换  -- 广播 
	CONST_BROAD_TOP_TIANDI                     = 5100,
	-- [5110]巅峰之战-至尊榜第一名更换  -- 广播 
	CONST_BROAD_DIANFENG_ZHIZUN                = 5110,
	-- [5120]美人护送-经验双倍时间通告  -- 广播 
	CONST_BROAD_MEIREN_PROTECT                 = 5120,
	-- [5130]洞府战-最终获胜洞府  -- 广播 
	CONST_BROAD_CLAN_DEFEND                    = 5130,
	-- [5140]御前科举-排名第三（包括称号）  -- 广播 
	CONST_BROAD_KEJU_THERE                     = 5140,
	-- [5150]洞府boss-洞府成功击杀boss  -- 广播 
	CONST_BROAD_CLAN_BOSS_KILL                 = 5150,
	-- [5160]御前科举-排名第一  -- 广播 
	CONST_BROAD_KEJU_ONE                       = 5160,
	-- [5170]御前科举-排名第二  -- 广播 
	CONST_BROAD_KEJU_TWO                       = 5170,
	-- [5175]御前科举-准备开启公告 -- 广播 
	CONST_BROAD_KEJU_READY                     = 5175,
	-- [5180]御前科举-开启公告  -- 广播 
	CONST_BROAD_KEJU_START                     = 5180,
	-- [5210]独尊三界小组赛开启提前通告 -- 广播 
	CONST_BROAD_DZSJ_YUSAI_5_MINUTE            = 5210,
	-- [5211]独尊三界小组赛开启准备 -- 广播 
	CONST_BROAD_DZSJ_YUSAI_1_MINUTE            = 5211,
	-- [5212]独尊三界小组赛开启 -- 广播 
	CONST_BROAD_DZSJ_YUSAI_START               = 5212,
	-- [5213]独尊三界决赛开启提前通告 -- 广播 
	CONST_BROAD_DZSJ_FINAL_5_MINUTE            = 5213,
	-- [5214]独尊三界决赛开启准备 -- 广播 
	CONST_BROAD_DZSJ_FINAL_1_MINUTE            = 5214,
	-- [5215]独尊三界决赛开启 -- 广播 
	CONST_BROAD_DZSJ_FINAL_START               = 5215,
	-- [5216]独尊三界-巅峰对决 -- 广播 
	CONST_BROAD_DZSJ_FIRST                     = 5216,
	-- [5217]独尊三界-总决赛获胜 -- 广播 
	CONST_BROAD_DZSJ_FINAL                     = 5217,
	-- [5218]欢乐竞猜-开启活动通告 -- 广播 
	CONST_BROAD_DZSJ_GUESS                     = 5218,
	-- [5219]独尊三界-取消活动 -- 广播 
	CONST_BROAD_DZSJ_CANCEL                    = 5219,
	-- [5220]独尊三界-第一名更替 -- 广播 
	CONST_BROAD_DZSJ_CHANGE                    = 5220,
	-- [6010]世界BOSS—活动提前通告  -- 广播 
	CONST_BROAD_ID_WORLD_START                 = 6010,
	-- [6020]世界BOSS—活动开启准备  -- 广播 
	CONST_BROAD_ID_WORLD_REY                   = 6020,
	-- [6030]世界BOSS—BOSS出现  -- 广播 
	CONST_BROAD_ID_WORLD_SHOW                  = 6030,
	-- [6040]世界BOSS—BOSS被击杀  -- 广播 
	CONST_BROAD_ID_WORLD_DIE                   = 6040,
	-- [6050]世界BOSS—活动结束通告  -- 广播 
	CONST_BROAD_ID_WORLD_END                   = 6050,
	-- [6090]世界BOSS—购买BOSS通告  -- 广播 
	CONST_BROAD_ID_WORLD_BUY                   = 6090,
	-- [7010]精彩活动-活动开启通告  -- 广播 
	CONST_BROAD_JINGCAI_OPEN                   = 7010,
	-- [7020]节日活动-活动开启通告  -- 广播 
	CONST_BROAD_JIERI_OPEN                     = 7020,
	-- [7030]三国基金-购买土豪三国基金  -- 广播 
	CONST_BROAD_JIJIN_TUHAO                    = 7030,
	-- [7040]拍卖活动-活动开启通告  -- 广播 
	CONST_BROAD_AUCTION_OPEN                   = 7040,
	-- [7050]拍卖活动-玩家拍卖到某个物品  -- 广播 
	CONST_BROAD_AUCTION_GET                    = 7050,
	-- [7060]限时团购-活动开启通告  -- 广播 
	CONST_BROAD_TUANGOU_OPEN                   = 7060,
	-- [7070]每日一箭获得至尊大奖  -- 广播 
	CONST_BROAD_SHOOT_GREAT                    = 7070,
	-- [7080]每日转盘-抽到100个坐骑经验丹  -- 广播 
	CONST_BROAD_WHELL_100_EXP                  = 7080,
	-- [7090]签到抽奖-抽到200元宝  -- 广播 
	CONST_BROAD_SIGN_200                       = 7090,
	-- [7100]翻翻乐-抽到5张相同的牌  -- 广播 
	CONST_BROAD_FANFANLE_5                     = 7100,
	-- [7110]全民寻宝-获得5级宝石  -- 广播 
	CONST_BROAD_QUANMINXUBAO_5                 = 7110,
	-- [7120]节日转盘-获得珍贵物品  -- 广播 
	CONST_BROAD_TURNTABLE_THINGS               = 7120,
	-- [7130]活动即将结束 -- 广播 
	CONST_BROAD_WILL_OVER                      = 7130,
	-- [8010]洞府-加入洞府  -- 广播 
	CONST_BROAD_JOIN_CLAN                      = 8010,
	-- [8020]洞府-踢出洞府  -- 广播 
	CONST_BROAD_EXIT_CLAN                      = 8020,
	-- [8030]洞府-转让洞主  -- 广播 
	CONST_BROAD_TRANSFER_WANG                  = 8030,
	-- [8040]洞主-成为护法  -- 广播 
	CONST_BROAD_BECOME_DEPUTYWANG              = 8040,
	-- [8050]洞主-弹劾洞主  -- 广播 
	CONST_BROAD_IMPEACHMENT_WANG               = 8050,
	-- [8060]撤销护法  -- 广播 
	CONST_BROAD_UNDO_DEPUTYWANG                = 8060,
	-- [8070]洞府-主动退出洞府  -- 广播 
	CONST_BROAD_EXITCLAN_ONESELF               = 8070,
	-- [8100]洞府-洞府升级  -- 广播 
	CONST_BROAD_CLAN_LV_UP                     = 8100,
	-- [8110]洞府-招财-洗澡  -- 广播 
	CONST_BROAD_CLAN_MONEY_WASH                = 8110,
	-- [8120]洞府-招财-喂食  -- 广播 
	CONST_BROAD_CLAN_MONEY_FEEDING             = 8120,
	-- [8130]洞府-开启洞府boss  -- 广播 
	CONST_BROAD_OPEN_CLAN_BOSS                 = 8130,
	-- [8140]洞府-洞府boss出现  -- 广播 
	CONST_BROAD_APPEAR_CLAN_BOSS               = 8140,
	-- [8150]洞府-洞府boss死亡  -- 广播 
	CONST_BROAD_DEATH_CLAN_BOSS                = 8150,
	-- [8160]洞府-洞府boss被某某击杀  -- 广播 
	CONST_BROAD_KILL_BOSS                      = 8160,
	-- [8170]洞府-招募帮众  -- 广播 
	CONST_BROAD_RECRUITING                     = 8170,
	-- [8180]洞府大战-初赛开始前5分钟： -- 广播 
	CONST_BROAD_CLAN_FIRSTWAR_BEFORE           = 8180,
	-- [8190]洞府大战-初赛开始： -- 广播 
	CONST_BROAD_CLAN_SECONDWAR_BEFORE          = 8190,
	-- [8200]洞府大战-决赛开始前5分钟： -- 广播 
	CONST_BROAD_CLANWAR_START                  = 8200,
	-- [8210]洞府大战-决赛开始： -- 广播 
	CONST_BROAD_CLAN_FIRSTWAR_VICTORY          = 8210,
	-- [8220]洞府大战-决赛结束： -- 广播 
	CONST_BROAD_CLAN_SECONDWAR_VICTORY         = 8220,
	-- [8230]洞府大战-玩家完成10连杀： -- 广播 
	CONST_BROAD_CLAN_10KILL                    = 8230,
	-- [8240]洞府大战-玩家完成20连杀： -- 广播 
	CONST_BROAD_CLAN_20KILL                    = 8240,
	-- [8250]洞府大战-玩家完成50连杀： -- 广播 
	CONST_BROAD_CLAN_30KILL                    = 8250,
	-- [8260]洞府大战-洞主死亡： -- 广播 
	CONST_BROAD_CLAN_DEAD                      = 8260,
	-- [8270]洞府大战-战场总人数少于10人： -- 广播 
	CONST_BROAD_CLAN_LESS10                    = 8270,
	-- [8310]保卫圣兽堂-开始前5分钟 -- 广播 
	CONST_BROAD_DEFEND_5MIN                    = 8310,
	-- [8320]保卫圣兽堂-活动开始 -- 广播 
	CONST_BROAD_DEFEND_START                   = 8320,
	-- [8330]保卫圣兽堂-怪物10秒后到达 -- 广播 
	CONST_BROAD_DEFEND_10SED                   = 8330,
	-- [8340]保卫圣兽堂-怪物到达 -- 广播 
	CONST_BROAD_DEFEND_APPEAR                  = 8340,
	-- [8350]保卫圣兽堂-传送门出现 -- 广播 
	CONST_BROAD_DEFEND_PORTAL                  = 8350,
	-- [8360]洞府-更名成功 -- 广播 
	CONST_BROAD_NAME_CHANGE                    = 8360,
	-- [8410]占山为王-防守者被击杀 -- 广播 
	CONST_BROAD_KING_KILLED                    = 8410,
	-- [8420]占山为王-防守成功 -- 广播 
	CONST_BROAD_KING_S                         = 8420,
	-- [8430]占山为王-防守失败 -- 广播 
	CONST_BROAD_KING_D                         = 8430,
	-- [8440]占山为王-防守者连杀 -- 广播 
	CONST_BROAD_KING_KILL                      = 8440,
	-- [8450]洞府_新洞主 -- 广播 
	CONST_BROAD_NEW_DONGZHU                    = 8450,
	-- [10010]城镇boss出现前5分钟  -- 广播 
	CONST_BROAD_CITY_BOSS_BEFORE_5             = 10010,
	-- [10020]城镇boss出现  -- 广播 
	CONST_BROAD_CITY_BOSS_START                = 10020,
	-- [10030]城镇boss被打败  -- 广播 
	CONST_BROAD_CITY_BOSS_KILL                 = 10030,
	-- [10110]排行榜-锁妖塔第一 -- 广播 
	CONST_BROAD_RANK_SYT                       = 10110,
	-- [10120]排行榜-等级第一 -- 广播 
	CONST_BROAD_RANK_DJ                        = 10120,
	-- [10130]排行榜-战力第一 -- 广播 
	CONST_BROAD_RANK_ZL                        = 10130,
	-- [11010]跨服武道大会开始分组  -- 广播 
	CONST_BROAD_TXDY_SUPER_GROUP_10_MINUTE     = 11010,
	-- [11020]跨服武道大会1分钟  -- 广播 
	CONST_BROAD_TXDY_SUPER_GROUP_1_MINUTE      = 11020,
	-- [11030]跨服武道大会小组赛开始  -- 广播 
	CONST_BROAD_TXDY_SUPER_GROUP_START         = 11030,
	-- [11040]跨服武道大会小组赛结束，欢乐竞猜开启  -- 广播 
	CONST_BROAD_TXDY_SUPER_GROUP_OVER          = 11040,
	-- [11050]跨服武道大会决赛前10分钟提醒  -- 广播 
	CONST_BROAD_TXDY_SUPER_FINAL_10_MINUTE     = 11050,
	-- [11060]跨服武道大会开始前1分钟  -- 广播 
	CONST_BROAD_TXDY_SUPER_FINAL_1_MINUTE      = 11060,
	-- [11070]跨服武道大会开始  -- 广播 
	CONST_BROAD_TXDY_SUPER_FINAL_START         = 11070,
	-- [11080]跨服武道大会总决赛获胜  -- 广播 
	CONST_BROAD_TXDY_SUPER_FINAL_WIN           = 11080,
	-- [11081]跨服武道大会开始报名了！  -- 广播 
	CONST_BROAD_TXDY_SUPER_SIGN_START          = 11081,

	-- [1]区 - 综合频道  -- 广播 
	CONST_BROAD_AREA_MULTIPLE                  = 1,
	-- [2]区 - 世界频道  -- 广播 
	CONST_BROAD_AREA_WORLD                     = 2,
	-- [3]区 - 洞府频道  -- 广播 
	CONST_BROAD_AREA_CLAN                      = 3,
	-- [4]区 - 私聊频道  -- 广播 
	CONST_BROAD_AREA_PRIVATE                   = 4,
	-- [5]区 - 超级公告(跑马灯)  -- 广播 
	CONST_BROAD_AREA_SUPER                     = 5,
	-- [6]区 - 综合频道+超级公告  -- 广播 
	CONST_BROAD_AREA_SUPER_MULTIPLE            = 6,
	-- [7051]拍卖活动-即将要拍的物品 -- 广播 
	CONST_BROAD_AUCTION_NEW                    = 7051,

	--------------------------------------------------------------------
	-- ( 酒馆 ) 
	--------------------------------------------------------------------
	-- [1]请教经验值的百分比  -- 酒馆 
	CONST_INN_PERCENT                          = 1,

	-- [1]蓝色  -- 酒馆 
	CONST_INN_BLUE_KNIFE                       = 1,
	-- [2]紫色  -- 酒馆 
	CONST_INN_VIOLET_KNIFE                     = 2,
	-- [3]金色  -- 酒馆 
	CONST_INN_GOLDEN_KNIFE                     = 3,

	-- [11]蓝色宝箱  -- 酒馆 
	CONST_INN_BLUE_BOX                         = 11,
	-- [12]紫色宝箱  -- 酒馆 
	CONST_INN_VIOLET_BOX                       = 12,
	-- [13]金色宝箱  -- 酒馆 
	CONST_INN_GOLDEN_BOX                       = 13,

	-- [1]等级段-25-69  -- 酒馆 
	CONST_INN_LV_RANGE_FIRST                   = 1,
	-- [2]等级段-70-79  -- 酒馆 
	CONST_INN_LV_RANGE_MID                     = 2,
	-- [3]等级段-80-89  -- 酒馆 
	CONST_INN_LV_RANGE_AFTER                   = 3,

	-- [30]单次奉酒消耗金元  -- 酒馆 
	CONST_INN_WINE_COST                        = 30,
	-- [1500000]二狗头酒少于70级消耗-150万  -- 酒馆 
	CONST_INN_WINE_CASH                        = 1500000,
	-- [3000000]大于等于70级银元消耗-300万  -- 酒馆 
	CONST_INN_WINE_HIGHER_CASH                 = 3000000,

	-- [0]奉酒  -- 酒馆 
	CONST_INN_DRINK_TYPE                       = 0,
	-- [1]一键奉酒  -- 酒馆 
	CONST_INN_DRINK_TYPE2                      = 1,

	-- [0]伙伴状态-休息  -- 酒馆 
	CONST_INN_STATA0                           = 0,
	-- [1]伙伴状态-守护  -- 酒馆 
	CONST_INN_STATA1                           = 1,
	-- [2]伙伴状态-出战  -- 酒馆 
	CONST_INN_STATA2                           = 2,

	-- [70]酒留仙等级分界点-70级  -- 酒馆 
	CONST_INN_DRINK_LV_LINE                    = 70,

	-- [0]伙伴操作-离队  -- 酒馆 
	CONST_INN_OPERATION0                       = 0,
	-- [1]伙伴操作-归队  -- 酒馆 
	CONST_INN_OPERATION1                       = 1,
	-- [2]伙伴操作-出战  -- 酒馆 
	CONST_INN_OPERATION2                       = 2,
	-- [3]伙伴操作-休息  -- 酒馆 
	CONST_INN_OPERATION3                       = 3,
	-- [4]伙伴操作-招募  -- 酒馆 
	CONST_INN_OPERATION4                       = 4,
	-- [5]伙伴操作-培养  -- 酒馆 
	CONST_INN_OPERATION5                       = 5,

	-- [7]招募按钮可点击等级  -- 酒馆 
	CONST_INN_RECRUIT_LV                       = 7,

	-- [5]花费体力类型-体力  -- 酒馆 
	CONST_INN_TRAIN_TWO                        = 5,
	-- [25]获得培养值-体力  -- 酒馆 
	CONST_INN_LINESS_TWO                       = 25,
	-- [50]获得培养值-铜钱  -- 酒馆 
	CONST_INN_LINESS_ONE                       = 50,
	-- [5000]花费铜钱类型-铜钱  -- 酒馆 
	CONST_INN_TRAIN_ONE                        = 5000,

	-- [1]金币培养  -- 酒馆 
	CONST_INN_CULTURE_ONE                      = 1,
	-- [5]体力培养  -- 酒馆 
	CONST_INN_CULTURE_TWO                      = 5,

	-- [0]解锁定  -- 酒馆 
	CONST_INN_UNLOCK                           = 0,
	-- [1]锁定  -- 酒馆 
	CONST_INN_LOCK                             = 1,

	-- [50]伙伴最大数 -- 酒馆 
	CONST_INN_PARTNER_MAX                      = 50,
	-- [46600]获得的元魂 -- 酒馆 
	CONST_INN_YUAN_HUN                         = 46600,

	--------------------------------------------------------------------
	-- ( 日志 ) 
	--------------------------------------------------------------------
	-- [1]type常量--虚拟物品（金钱类::CURRENCY_XX）  -- 日志 
	CONST_LOGS_TYPE_CURRENCY                   = 1,
	-- [2]type常量--实体物品（装备类）  -- 日志 
	CONST_LOGS_TYPE_GOODS                      = 2,
	-- [3]type常量--属性改变::ATTR_XX  -- 日志 
	CONST_LOGS_TYPE_ATTR                       = 3,
	-- [4]type常量--BUFF改变::WAR_PLUS_XXX  -- 日志 
	CONST_LOGS_TYPE_BUFF                       = 4,
	-- [5]type常量--卦象物品  -- 日志 
	CONST_LOGS_TYPE_DOUQI                      = 5,

	-- [0]state状态--失去、减少、下降  -- 日志 
	CONST_LOGS_DEL                             = 0,
	-- [1]state状态--获得、增加、上升  -- 日志 
	CONST_LOGS_ADD                             = 1,

	-- [1001]恭喜你达到15级 赶紧去使用15级礼包吧  -- 日志 
	CONST_LOGS_1001                            = 1001,
	-- [1002]恭喜你达到20级 赶紧去使用20级礼包吧  -- 日志 
	CONST_LOGS_1002                            = 1002,
	-- [1003]恭喜你达到25级 赶紧去使用25级礼包吧  -- 日志 
	CONST_LOGS_1003                            = 1003,
	-- [1004]恭喜你达到30级 赶紧去使用30级礼包吧  -- 日志 
	CONST_LOGS_1004                            = 1004,
	-- [1005]恭喜你达到40级 赶紧去使用40级礼包吧  -- 日志 
	CONST_LOGS_1005                            = 1005,
	-- [1006]恭喜你达到50级 赶紧去使用50级礼包吧  -- 日志 
	CONST_LOGS_1006                            = 1006,
	-- [1101]每天12点、18点可额外获得50点体力，不要忘记领取咯！  -- 日志 
	CONST_LOGS_1101                            = 1101,
	-- [1106]接受精英副本任务 迎接更强挑战吧！  -- 日志 
	CONST_LOGS_1106                            = 1106,
	-- [1111]有伙伴加入社团，赶快去审核吧！  -- 日志 
	CONST_LOGS_1111                            = 1111,
	-- [1116]升级成功  -- 日志 
	CONST_LOGS_1116                            = 1116,
	-- [1117]你的活跃度达到了$等奖励，赶快领取吧！  -- 日志 
	CONST_LOGS_1117                            = 1117,
	-- [2009]新伙伴需要上阵才能帮助你战斗哦！  -- 日志 
	CONST_LOGS_2009                            = 2009,
	-- [2010]主人$心情好大赦天下，你终于自由了，赶紧谢恩吧！  -- 日志 
	CONST_LOGS_2010                            = 2010,
	-- [2012]你被$抓走了，你成为了TA的奴仆，命苦哇！  -- 日志 
	CONST_LOGS_2012                            = 2012,
	-- [2013]$不堪忍受你的折磨，想要反抗你，可惜他还是太嫩了！  -- 日志 
	CONST_LOGS_2013                            = 2013,
	-- [2014]$不堪忍受你的折磨，鼓起勇气反抗了你，现在TA自由了！  -- 日志 
	CONST_LOGS_2014                            = 2014,
	-- [2015]$不堪忍受你的折磨向大侠$求救，他那花拳绣腿怎是你的对手？  -- 日志 
	CONST_LOGS_2015                            = 2015,
	-- [2016]$不堪忍受你的折磨向大侠$求救，仗义出头那人本领高出你太多了，还是走为上计吧！  -- 日志 
	CONST_LOGS_2016                            = 2016,
	-- [2017]$与你许久未见也没忘了给你送去祝福哟，有友如此夫复何求，赶快感谢他吧！  -- 日志 
	CONST_LOGS_2017                            = 2017,
	-- [2019]恭喜，你的声望已提升到#级，快去看看自己增加了哪些新的属性吧！  -- 日志 
	CONST_LOGS_2019                            = 2019,
	-- [2020]你这些日子四处奔波劳累，精力已经不足了，赶紧先购买精力补充一下吧！  -- 日志 
	CONST_LOGS_2020                            = 2020,
	-- [2021]你的VIP体验已过期，成为VIP可享受更多特权！  -- 日志 
	CONST_LOGS_2021                            = 2021,
	-- [2024]你获得了新装备，立即使用可增强战斗力！  -- 日志 
	CONST_LOGS_2024                            = 2024,
	-- [2028]你现在实力大增，可以去打造等级更高的强力装备了！  -- 日志 
	CONST_LOGS_2028                            = 2028,
	-- [2029]你的境界大幅提升，可以去打造品质更好的法宝了！  -- 日志 
	CONST_LOGS_2029                            = 2029,
	-- [2031]识英雄重英雄，你威名远播，五湖四海的英雄豪杰都想与你结为好友！  -- 日志 
	CONST_LOGS_2031                            = 2031,
	-- [2032]不断增强你的战力，用实力说话，招募更为强大的伙伴与你并肩作战!  -- 日志 
	CONST_LOGS_2032                            = 2032,
	-- [2033]$开启了洞府Boss$，同帮的兄弟姐妹们齐心合力把它给消灭了吧  -- 日志 
	CONST_LOGS_2033                            = 2033,
	-- [2034]$在洞府Boss战役中奋力一击 #，成功击杀了BOSS $ ，成为咱帮的洞府英雄。  -- 日志 
	CONST_LOGS_CLAN_BOSS_KILLER                = 2034,
	-- [2035]你最近比较宅没参加什么活动，邮箱里都没有新鲜的邮件进来哦！  -- 日志 
	CONST_LOGS_NO_MAILS                        = 2035,
	-- [2036]不知是哪位豪杰巾帼需要加入本帮，赶快去处理TA们的申请吧！  -- 日志 
	CONST_LOGS_NEW_CLAN_MEMBER                 = 2036,
	-- [7000]失败乃兵家常事，赶快去增强自己的实力东山再起吧！  -- 日志 
	CONST_LOGS_7000                            = 7000,

	-- [8000]---------------------------------玩家离线需保存的日志--填写大于8000的常量值  -- 日志 
	CONST_LOGS_END_ID                          = 8000,

	-- [8001]$在竞技场挑战你失败 你的排名不变  -- 日志 
	CONST_LOGS_8001                            = 8001,
	-- [8002]$在竞技场挑战你成功 你的排名下降到第#名  -- 日志 
	CONST_LOGS_8002                            = 8002,
	-- [8004]你有新邮件，请注意查收！  -- 日志 
	CONST_LOGS_8004                            = 8004,
	-- [8005]恭喜，$社团已通过你的申请！  -- 日志 
	CONST_LOGS_8005                            = 8005,
	-- [8006]很遗憾，$洞府已拒绝你的申请！  -- 日志 
	CONST_LOGS_8006                            = 8006,
	-- [8007]奴仆被抢  -- 日志 
	CONST_LOGS_8007                            = 8007,

	--------------------------------------------------------------------
	-- ( 副本 ) 
	--------------------------------------------------------------------
	-- [1]副本类型-普通副本  -- 副本 
	CONST_COPY_TYPE_NORMAL                     = 1,
	-- [2]副本类型-英雄副本  -- 副本 
	CONST_COPY_TYPE_HERO                       = 2,
	-- [3]副本类型-魔王副本  -- 副本 
	CONST_COPY_TYPE_FIEND                      = 3,
	-- [4]副本类型-过关斩将  -- 副本 
	CONST_COPY_TYPE_FIGHTERS                   = 4,
	-- [5]副本类型-洞府副本  -- 副本 
	CONST_COPY_TYPE_CLAN                       = 5,
	-- [6]副本类型-组队副本  -- 副本 
	CONST_COPY_TYPE_TEAM                       = 6,
	-- [7]副本类型-一骑当千  -- 副本 
	CONST_COPY_TYPE_THOUSAND                   = 7,
	-- [20]副本类型-珍宝副本 -- 副本 
	CONST_COPY_TYPE_COPY_GEM                   = 20,
	-- [30]副本类型-降魔之路 -- 副本 
	CONST_COPY_TYPE_COPY_XMZL                  = 30,
	-- [50]副本类型-铜钱副本 -- 副本 
	CONST_COPY_TYPE_COPY_MONEY                 = 50,
	-- [60]副本类型-道劫副本 -- 副本 
	CONST_COPY_TYPE_COPY_HOOK                  = 60,
	-- [50400]副本传送门  -- 副本 
	CONST_COPY_DOOR_ID                         = 50400,

	-- [0.2]挂机一次的时间(秒)  -- 副本 
	CONST_COPY_UP_TIME                         = 0.2,
	-- [1]挂机加速每分钟消耗钻石  -- 副本 
	CONST_COPY_SPEED_RMB                       = 1,
	-- [1]副本状态--准备  -- 副本 
	CONST_COPY_STATE_READY                     = 1,
	-- [2]副本状态--进行中  -- 副本 
	CONST_COPY_STATE_PLAY                      = 2,
	-- [2]挂机奖励评价  -- 副本 
	CONST_COPY_UP_EVA                          = 2,
	-- [3]副本状态--暂停  -- 副本 
	CONST_COPY_STATE_PAUSE                     = 3,
	-- [4]副本状态--完成  -- 副本 
	CONST_COPY_STATE_OVER                      = 4,
	-- [5]副本状态--停止  -- 副本 
	CONST_COPY_STATE_STOP                      = 5,
	-- [6]副本状态--时间到  -- 副本 
	CONST_COPY_STATE_TIMEOUT                   = 6,
	-- [60]普通副本挂机冷却时间-60秒  -- 副本 
	CONST_COPY_NORMAL_CD                       = 60,
	-- [120]英雄副本挂机冷却时间-120秒  -- 副本 
	CONST_COPY_HERO_CD                         = 120,
	-- [180]魔王副本挂机冷却时间-180秒  -- 副本 
	CONST_COPY_FIEND_CD                        = 180,

	-- [1]副本通关类型--普通  -- 副本 
	CONST_COPY_PASS_NORMAL                     = 1,
	-- [2]副本通关类型--限时  -- 副本 
	CONST_COPY_PASS_TIME                       = 2,
	-- [3]副本通关类型--连击  -- 副本 
	CONST_COPY_PASS_COMBO                      = 3,
	-- [4]副本通关类型--生存  -- 副本 
	CONST_COPY_PASS_ALIVE                      = 4,
	-- [5]副本通关类型--击杀BOSS  -- 副本 
	CONST_COPY_PASS_BOSS                       = 5,
	-- [6]副本通关类型--伙伴存活 -- 副本 
	CONST_COPY_PASS_PARTNER                    = 6,

	-- [1]玩法-全部刷怪  -- 副本 
	CONST_COPY_WAY_WHOLE                       = 1,
	-- [2]玩法-部分刷怪  -- 副本 
	CONST_COPY_WAY_PART                        = 2,

	-- [1]英雄副本基数(可打次数等于已通关乘基数)  -- 副本 
	CONST_COPY_HERO_BASE                       = 1,
	-- [3]副本宝箱数量  -- 副本 
	CONST_COPY_CHEST_NUM                       = 3,
	-- [3]副本满星评价  -- 副本 
	CONST_COPY_EVA_WHOLE                       = 3,
	-- [3]魔王副本开启评价(相应的英雄副本的评价)  -- 副本 
	CONST_COPY_FIEND_OPEN_EVA                  = 3,

	-- [1]副本计时--开始  -- 副本 
	CONST_COPY_TIMING_START                    = 1,
	-- [2]副本计时--停止  -- 副本 
	CONST_COPY_TIMING_STOP                     = 2,

	-- [1]战斗最少回合数  -- 副本 
	CONST_COPY_WAR_ROUND_MIN                   = 1,
	-- [6]战斗最多回合数  -- 副本 
	CONST_COPY_WAR_ROUND_MAX                   = 6,

	-- [1]通关副本消耗精力  -- 副本 
	CONST_COPY_IN_COPY_ENERGY                  = 1,
	-- [1]挂机一轮消耗精力  -- 副本 
	CONST_COPY_UP_ENERGY                       = 1,

	-- [1]副本检查时间间隔(单位秒)  -- 副本 
	CONST_COPY_INTERVAL_SECONDS                = 1,
	-- [100]副本时间间隔,清理一次,没人关闭进程(秒)  -- 副本 
	CONST_COPY_TIME_SLOT                       = 100,

	-- [1]副本评价--C级  -- 副本 
	CONST_COPY_EVA_C                           = 1,
	-- [2]副本评价--B级  -- 副本 
	CONST_COPY_EVA_B                           = 2,
	-- [3]副本评价--A级  -- 副本 
	CONST_COPY_EVA_A                           = 3,

	-- [4]魔王副本免费次数  -- 副本 
	CONST_COPY_FIEND_MAX_FREE_TIMES            = 4,
	-- [10]魔王刷新rmb基数  -- 副本 
	CONST_COPY_JISHU_MOWANG                    = 10,
	-- [10]精英购买次数rmb基数  -- 副本 
	CONST_COPY_JISHU_HERO                      = 10,
	-- [20]英雄魔王最大刷新购买次数  -- 副本 
	CONST_COPY_MAX_FRESH_BUY_TIMES             = 20,

	-- [1]副本评分类型--无损  -- 副本 
	CONST_COPY_SCORE_HITS                      = 1,
	-- [2]副本评分类型--时间  -- 副本 
	CONST_COPY_SCORE_TIME                      = 2,
	-- [3]副本评分类型--连击  -- 副本 
	CONST_COPY_SCORE_CAROM                     = 3,
	-- [4]副本评分类型--杀敌  -- 副本 
	CONST_COPY_SCORE_KILL                      = 4,
	-- [5]副本评分类型--奖励  -- 副本 
	CONST_COPY_SCORE_REWARD                    = 5,

	-- [1]挂机完成类型--正常  -- 副本 
	CONST_COPY_UPTYPE_NORMAL                   = 1,
	-- [2]挂机完成类型--VIP  -- 副本 
	CONST_COPY_UPTYPE_VIP                      = 2,
	-- [3]挂机完成类型--加速  -- 副本 
	CONST_COPY_UPTYPE_SPEED                    = 3,
	-- [4]挂机完成类型--背包已满  -- 副本 
	CONST_COPY_UPTYPE_BAG_FULL                 = 4,

	-- [10]挂机功能开启  -- 副本 
	CONST_COPY_SWEEP_LV_OPEN                   = 10,
	-- [30]精英副本开放等级  -- 副本 
	CONST_COPY_HERO_LV_OPEN                    = 30,
	-- [41]魔王副本开放等级  -- 副本 
	CONST_COPY_FIEND_LV_OPEN                   = 41,

	-- [9999]初次进入游戏副本  -- 副本 
	CONST_COPY_FIRST_COPY                      = 9999,

	-- [105]新手场景的唯一副本ID  -- 副本 
	CONST_COPY_FIRST_SCENE_COPYID              = 105,
	-- [9999]新手场景  -- 副本 
	CONST_COPY_FIRST_SCENE                     = 9999,
	-- [10180]大招指引开启剧情 -- 副本 
	CONST_COPY_FIRST_BIGSKILL_PLOT             = 10180,
	-- [10181]大招指引开启副本 -- 副本 
	CONST_COPY_FIRST_BIGSKILL_COPY             = 10181,

	-- [3]副本通过后自行退出界面时间（秒）  -- 副本 
	CONST_COPY_AUTO_EXIT                       = 3,
	-- [25]翻牌时间（秒）(后端服务器)  -- 副本 
	CONST_COPY_DRAW_TIME_SERVER                = 25,
	-- [30]翻牌时间（秒）(前端) -- 副本 
	CONST_COPY_DRAW_TIME                       = 30,

	-- [1]1人怪物血量提升倍数  -- 副本 
	CONST_COPY_HP_UP_ONE                       = 1,
	-- [1.2]2人怪物血量提升倍数  -- 副本 
	CONST_COPY_HP_UP_TWO                       = 1.2,
	-- [1.4]3人怪物血量提升倍数  -- 副本 
	CONST_COPY_HP_UP_THREE                     = 1.4,

	-- [2]组队副本当天可打次数  -- 副本 
	CONST_COPY_TEAM_TIMES                      = 2,
	-- [4]魔王副本当天可打次数  -- 副本 
	CONST_COPY_MOWANG_TIMES                    = 4,
	-- [5]珍宝副本当天可打次数  -- 副本 
	CONST_COPY_GEM_TIMES                       = 5,
	-- [10]精英副本当天可打次数  -- 副本 
	CONST_COPY_HERO_TIMES                      = 10,

	-- [1]动物  -- 副本 
	CONST_COPY_MONSTER_ANIMAL                  = 1,
	-- [2]人  -- 副本 
	CONST_COPY_MONSTER_HUMAN                   = 2,
	-- [3]骑兵  -- 副本 
	CONST_COPY_MONSTER_CAVALRY                 = 3,
	-- [4]boss  -- 副本 
	CONST_COPY_MONSTER_BOSS                    = 4,

	-- [1]箱子击打次数  -- 副本 
	CONST_COPY_BOX_HIT                         = 1,
	-- [10]护栏击打次数  -- 副本 
	CONST_COPY_LAN_HIT                         = 10,

	-- [0]通关常量-不保护NPC  -- 副本 
	CONST_COPY_PASS_NPC0                       = 0,
	-- [1]通关常量-保护至少一个NPC -- 副本 
	CONST_COPY_PASS_NPC1                       = 1,
	-- [2]通关常量-保护所有NPC -- 副本 
	CONST_COPY_PASS_NPC2                       = 2,

	-- [1]通关常量-击杀所有怪物 -- 副本 
	CONST_COPY_PASS_TYPE1                      = 1,
	-- [2]通关常量-限时击杀所有怪物 -- 副本 
	CONST_COPY_PASS_TYPE2                      = 2,
	-- [3]通关常量-限时存活 -- 副本 
	CONST_COPY_PASS_TYPE3                      = 3,

	-- [5]购买增加挑战次数 -- 副本 
	CONST_COPY_TIMES_BUY_ADD                   = 5,

	--------------------------------------------------------------------
	-- ( 布阵 ) 
	--------------------------------------------------------------------
	-- [1]阵位-地坤（前军）  -- 布阵 
	CONST_ARRAY_POSITION_FRONT                 = 1,
	-- [2]阵位-人伐（中军）  -- 布阵 
	CONST_ARRAY_POSITION_MIDDLE                = 2,
	-- [3]阵位-天泽（后军）  -- 布阵 
	CONST_ARRAY_POSITION_BACK                  = 3,

	-- [1]伤害率加成  -- 布阵 
	CONST_ARRAY_ADDITION_ATTR_BONUS            = 1,
	-- [2]气血加成  -- 布阵 
	CONST_ARRAY_ADDITION_HP_MAX                = 2,
	-- [3]恢复气血加成  -- 布阵 
	CONST_ARRAY_ADDITION_RESUMEHP              = 3,
	-- [4]速度加成  -- 布阵 
	CONST_ARRAY_ADDITION_SPEED                 = 4,
	-- [5]免伤率加成  -- 布阵 
	CONST_ARRAY_ADDITION_REDUCTION             = 5,

	-- [6000]地坤伤害值(万分比)  -- 布阵 
	CONST_ARRAY_DOWN_HAEM                      = 6000,

	--------------------------------------------------------------------
	-- ( 坐骑 ) 
	--------------------------------------------------------------------
	-- [0]坐骑最低星级  -- 坐骑 
	CONST_MOUNT_MIN_STAR                       = 0,
	-- [10]坐骑系统要求等级  -- 坐骑 
	CONST_MOUNT_GET_LV                         = 10,
	-- [10]坐骑最高星级  -- 坐骑 
	CONST_MOUNT_MAX_STAR                       = 10,
	-- [50008]最高等阶坐骑ID  -- 坐骑 
	CONST_MOUNT_END_MOUNTID                    = 50008,

	-- [1]仙果增加属性-物攻，物防  -- 坐骑 
	CONST_MOUNT_PROP_STRONG                    = 1,
	-- [2]仙果增加属性-法攻，法防  -- 坐骑 
	CONST_MOUNT_PROP_MAGIC                     = 2,
	-- [3]仙果增加属性-速度  -- 坐骑 
	CONST_MOUNT_PROP_ATT_SPEED                 = 3,
	-- [4]仙果增加属性-气血  -- 坐骑 
	CONST_MOUNT_PROP_HP                        = 4,

	-- [1]培养方式-铜钱培养  -- 坐骑 
	CONST_MOUNT_MODE_GOLD                      = 1,
	-- [2]培养方式-道具培养  -- 坐骑 
	CONST_MOUNT_MODE_RMB                       = 2,
	-- [3]培养方式-元宝培养  -- 坐骑 
	CONST_MOUNT_MODE_ADVANCED                  = 3,

	-- [0]初始化-坐骑等级  -- 坐骑 
	CONST_MOUNT_BEGIN_LV                       = 0,
	-- [50001]初始化-坐骑ID  -- 坐骑 
	CONST_MOUNT_BEGIN_MOUNTID                  = 50001,
	-- [102610]开放坐骑任务ID  -- 坐骑 
	CONST_MOUNT_START_TASKID                   = 102610,

	-- [1]坐骑培养-消耗道具  -- 坐骑 
	CONST_MOUNT_PROP_NUMBER                    = 1,
	-- [5]培养坐骑-消耗金元  -- 坐骑 
	CONST_MOUNT_CULTURE_RMB                    = 5,
	-- [50]高级培养-一键进行多次  -- 坐骑 
	CONST_MOUNT_REPEATEDLY                     = 50,
	-- [45000]培养坐骑-道具物品ID  -- 坐骑 
	CONST_MOUNT_PROP_ID                        = 45000,
	-- [50000]培养坐骑-消耗银元  -- 坐骑 
	CONST_MOUNT_CULTRUE_GOLD                   = 50000,

	-- [0]幻化状态-使用中  -- 坐骑 
	CONST_MOUNT_STATUS_USING                   = 0,
	-- [1]幻化状态-已开启幻化过但使用  -- 坐骑 
	CONST_MOUNT_STATUS_LIUSION                 = 1,
	-- [2]幻化状态-开启但从未幻化过  -- 坐骑 
	CONST_MOUNT_STATUS_NOLIUSION               = 2,

	-- [1]坐骑培养结果-得到经验  -- 坐骑 
	CONST_MOUNT_RESULT_EXP                     = 1,
	-- [2]坐骑培养结果-突进  -- 坐骑 
	CONST_MOUNT_RESULT_DART                    = 2,
	-- [3]坐骑培养结果-突破  -- 坐骑 
	CONST_MOUNT_RESULT_BREACH                  = 3,

	--------------------------------------------------------------------
	-- ( 洞府 ) 
	--------------------------------------------------------------------
	-- [1]离开再进洞府时间限制(H)  -- 洞府 
	CONST_CLAN_TIME_OUTCLAN                    = 1,
	-- [3]护法数量  -- 洞府 
	CONST_CLAN_COUNT_SECOND                    = 3,
	-- [5]洞府列表单页显示数量  -- 洞府 
	CONST_CLAN_RANK_COUNT                      = 5,
	-- [5]同时申请加入洞府的上限数  -- 洞府 
	CONST_CLAN_JOIN_MAX_CALL                   = 5,
	-- [6]洞府名称最大字数  -- 洞府 
	CONST_CLAN_TITLE_MAX                       = 6,
	-- [10]最大日志数  -- 洞府 
	CONST_CLAN_EVENT_COUNT_MAX                 = 10,
	-- [10]创建洞府花费铜钱(万)  -- 洞府 
	CONST_CLAN_CREATE_COST                     = 10,
	-- [18]创建洞府等级限制  -- 洞府 
	CONST_CLAN_LV_LIMIT                        = 18,
	-- [30]申请信息忽略时间 -- 洞府 
	CONST_CLAN_TIME_SHENGQING                  = 30,
	-- [32]初始化洞府最大成员上限  -- 洞府 
	CONST_CLAN_NEW_CLAN_MAX                    = 32,
	-- [40]洞府接受申请信息上限  -- 洞府 
	CONST_CLAN_RECEIVE_MAX                     = 40,
	-- [50]洞府公告最大字数  -- 洞府 
	CONST_CLAN_NOTICE_MAX                      = 50,
	-- [60]洞府招收新人按钮(min)  -- 洞府 
	CONST_CLAN_TIME_NOOB_JOIN                  = 60,

	-- [0]职位-小钻风  -- 洞府 
	CONST_CLAN_POST_COMMON                     = 0,
	-- [1]职位-青龙使者  -- 洞府 
	CONST_CLAN_POST_QLSZ                       = 1,
	-- [2]职位-白虎使者  -- 洞府 
	CONST_CLAN_POST_BHSZ                       = 2,
	-- [3]职位-朱雀使者  -- 洞府 
	CONST_CLAN_POST_ZQSZ                       = 3,
	-- [4]职位-玄武使者  -- 洞府 
	CONST_CLAN_POST_XWSZ                       = 4,
	-- [5]职位-护法  -- 洞府 
	CONST_CLAN_POST_SECOND                     = 5,
	-- [6]职位-洞主  -- 洞府 
	CONST_CLAN_POST_MASTER                     = 6,
	-- [7]职位-踢出洞府  -- 洞府 
	CONST_CLAN_POST_OUT                        = 7,

	-- [1]日志类型- 欢迎$加入本洞府  -- 洞府 
	CONST_CLAN_EVENT_JOIN                      = 1,
	-- [2]日志类型- $退出本洞府  -- 洞府 
	CONST_CLAN_EVENT_OUT                       = 2,
	-- [3]日志类型- 洞主撤销了$的护法职位 -- 洞府 
	CONST_CLAN_EVENT_POST_DOWN                 = 3,
	-- [4]日志类型- $被洞主升为护法  -- 洞府 
	CONST_CLAN_EVENT_POST_UP                   = 4,
	-- [5]日志类型- $将洞主之位让贤给了$  -- 洞府 
	CONST_CLAN_EVENT_TRANS                     = 5,
	-- [6]日志类型- $被$踢出洞府  -- 洞府 
	CONST_CLAN_EVENT_KICK                      = 6,
	-- [7]日志类型- $修改了公告  -- 洞府 
	CONST_CLAN_EVENT_NOTICE                    = 7,
	-- [8]日志类型- $请求加入洞府  -- 洞府 
	CONST_CLAN_APPLY_JOIN                      = 8,
	-- [10]日志类型- $供奉守护神,为洞府增加#点贡献 -- 洞府 
	CONST_CLAN_EVENT_YQSJS                     = 10,
	-- [11]日志类型- $对洞主$进行了弹劾 -- 洞府 
	CONST_CLAN_EVENT_IMPEACH                   = 11,
	-- [12]日志类型- $祈祷了洞府获得xx奖励 -- 洞府 
	CONST_CLAN_EVENT_QIFU                      = 12,

	-- [1001]洞府活动--招财猫  -- 洞府 
	CONST_CLAN_ACTIVE_CAT                      = 1001,
	-- [1002]洞府活动--洞府BOSS  -- 洞府 
	CONST_CLAN_ACTIVE_CLANBOSS                 = 1002,
	-- [1003]洞府活动--洞府战  -- 洞府 
	CONST_CLAN_ACTIVE_COPY                     = 1003,
	-- [1004]洞府活动--洞府训练  -- 洞府 
	CONST_CLAN_ACTIVE_TRAIN                    = 1004,
	-- [1005]洞府活动--洞府守卫战  -- 洞府 
	CONST_CLAN_ACTIVE_TD                       = 1005,

	-- [1]开启等级--洞府BOSS  -- 洞府 
	CONST_CLAN_CLAN_BOSS_LIMIT_LV              = 1,
	-- [1]开启等级--招财猫  -- 洞府 
	CONST_CLAN_CLAN_LV_LIMIT                   = 1,
	-- [1]开启等级--洞府战  -- 洞府 
	CONST_CLAN_COPY_LV                         = 1,
	-- [2]开启等级--洞府守卫战  -- 洞府 
	CONST_CLAN_TD_LV                           = 2,

	-- [10]洞府boss复活所需元宝  -- 洞府 
	CONST_CLAN_BOSS_REPLAY_PRICE               = 10,
	-- [10]开启洞府BOSS的花费（钻）  -- 洞府 
	CONST_CLAN_CLAN_BOSS_SPEND                 = 10,
	-- [10]伤害排行榜玩家个数  -- 洞府 
	CONST_CLAN_BOSS_RANK_COUNT                 = 10,
	-- [60]洞府Boss准备时间  -- 洞府 
	CONST_CLAN_BOSS_REPLAY_TIME                = 60,
	-- [60]玩家死亡后复活等待时间（S）  -- 洞府 
	CONST_CLAN_RELIVE_TIME                     = 60,
	-- [1800]洞府Boss时长（s）  -- 洞府 
	CONST_CLAN_BOSS_TIME                       = 1800,
	-- [61160]洞府BOSS场景  -- 洞府 
	CONST_CLAN_BOSS_MAPID                      = 61160,

	-- [0]每日免费招财次数  -- 洞府 
	CONST_CLAN_CAT_TIMES                       = 0,

	-- [50060]守卫战场景  -- 洞府 
	CONST_CLAN_DEFENSE_SCENE                   = 50060,

	-- [41]洞府技能-位置1 -- 洞府 
	CONST_CLAN_SKILL_PLACE_1                   = 41,
	-- [42]洞府技能-位置2 -- 洞府 
	CONST_CLAN_SKILL_PLACE_2                   = 42,
	-- [43]洞府技能-位置3 -- 洞府 
	CONST_CLAN_SKILL_PLACE_3                   = 43,
	-- [44]洞府技能-位置4 -- 洞府 
	CONST_CLAN_SKILL_PLACE_4                   = 44,

	-- [1]获得的福值 -- 洞府 
	CONST_CLAN_QIFU_FZ                         = 1,
	-- [1]祈福次数 -- 洞府 
	CONST_CLAN_QIFU_CS                         = 1,
	-- [32]日志数量 -- 洞府 
	CONST_CLAN_QIFU_RZ                         = 32,
	-- [200]消耗的元宝 -- 洞府 
	CONST_CLAN_QIFU_XH                         = 200,

	-- [2]洞主离线N天可弹劾 -- 洞府 
	CONST_CLAN_TH_DAY                          = 2,
	-- [24]弹劾时间--小时 -- 洞府 
	CONST_CLAN_TH_HOUR                         = 24,

	--------------------------------------------------------------------
	-- ( 财神 ) 
	--------------------------------------------------------------------
	-- [0]招财免费次数  -- 财神 
	CONST_WEAGOD_FREE_TIMES                    = 0,
	-- [0]VIP0招财次数  -- 财神 
	CONST_WEAGOD_VIP0                          = 0,
	-- [6]开启自动招财VIP等级  -- 财神 
	CONST_WEAGOD_AUTO_VIP                      = 6,
	-- [10]批量招财次数  -- 财神 
	CONST_WEAGOD_PL_TIMES                      = 10,
	-- [12]开通等级  -- 财神 
	CONST_WEAGOD_OPEN_LV                       = 12,

	-- [1]单次招财成功返回类型  -- 财神 
	CONST_WEAGOD_SINGLE_TYPE                   = 1,
	-- [2]批量招财成功返回类型  -- 财神 
	CONST_WEAGOD_PL_TYPE                       = 2,
	-- [3]自动招财成功返回类型  -- 财神 
	CONST_WEAGOD_AUTO_TYPE                     = 3,

	-- [100]招财十倍权重  -- 财神 
	CONST_WEAGOD_WEIGHT_10                     = 100,
	-- [900]招财两倍权重  -- 财神 
	CONST_WEAGOD_WEIGHT_DOUBLE                 = 900,
	-- [9000]招财一倍权重  -- 财神 
	CONST_WEAGOD_WEIGHT_NORMAL                 = 9000,

	--------------------------------------------------------------------
	-- ( 声望 ) 
	--------------------------------------------------------------------
	-- [1]初始化等级  -- 声望 
	CONST_RENOWN_BEGIN_LV                      = 1,
	-- [22]不消耗每日声望等级  -- 声望 
	CONST_RENOWN_STEP_LV                       = 22,
	-- [37]最大声望等级  -- 声望 
	CONST_RENOWN_MAX_LV                        = 37,

	--------------------------------------------------------------------
	-- ( 精力 ) 
	--------------------------------------------------------------------
	-- [0]精力清0  -- 精力 
	CONST_ENERGY_ZERO                          = 0,
	-- [0]初始化精力类型  -- 精力 
	CONST_ENERGY_EXTRA                         = 0,
	-- [5]每半小时增加精力值  -- 精力 
	CONST_ENERGY_ADD                           = 5,
	-- [200]精力上限  -- 精力 
	CONST_ENERGY_MAX                           = 200,
	-- [200]初始化精力  -- 精力 
	CONST_ENERGY_BEGIN                         = 200,
	-- [1800]自动恢复精力时间  -- 精力 
	CONST_ENERGY_DELAY                         = 1800,

	-- [1]非VIP玩家可购买精力的次数  -- 精力 
	CONST_ENERGY_BUY_BASE                      = 1,
	-- [20]购买一次精力需花费金元数  -- 精力 
	CONST_ENERGY_BUY_RMB                       = 20,
	-- [40]购买成功增加精力数  -- 精力 
	CONST_ENERGY_BUY_NUM                       = 40,

	-- [0]购买精力类型--前端请求  -- 精力 
	CONST_ENERGY_REQUEST_TYPE                  = 0,
	-- [1]购买精力类型--后端触发  -- 精力 
	CONST_ENERGY_RETRUN_TYPE                   = 1,

	-- [46305]点击获得体力道具  -- 精力 
	CONST_ENERGY_GET_GOODS                     = 46305,

	--------------------------------------------------------------------
	-- ( 店铺 ) 
	--------------------------------------------------------------------
	-- [30]装配店铺等级  -- 店铺 
	CONST_SHOP_LV1                             = 30,
	-- [31]宝石店铺等级  -- 店铺 
	CONST_SHOP_LV2                             = 31,

	--------------------------------------------------------------------
	-- ( 抓奴仆 ) 
	--------------------------------------------------------------------
	-- [5]每日解救次数  -- 抓奴仆 
	CONST_MOIL_RESCUE_COUNT                    = 5,
	-- [5]每日求救次数  -- 抓奴仆 
	CONST_MOIL_CALLS_COUNT                     = 5,
	-- [5]每日反抗次数  -- 抓奴仆 
	CONST_MOIL_PROTEST_COUNT                   = 5,
	-- [5]每日互动次数  -- 抓奴仆 
	CONST_MOIL_ACTIVE_COUNT                    = 5,
	-- [10]每日抓捕次数  -- 抓奴仆 
	CONST_MOIL_CAPTRUE_COUNT                   = 10,
	-- [20373]抓奴仆指引任务id  -- 抓奴仆 
	CONST_MOIL_TASK_POINT                      = 20373,

	-- [1]抓奴仆  -- 抓奴仆 
	CONST_MOIL_FUNCTION_CATCH                  = 1,
	-- [2]解救奴仆  -- 抓奴仆 
	CONST_MOIL_FUNCTION_HELP                   = 2,
	-- [3]互动  -- 抓奴仆 
	CONST_MOIL_FUNCTION_INTER                  = 3,
	-- [4]压榨奴仆  -- 抓奴仆 
	CONST_MOIL_FUNCTION_DRAW                   = 4,
	-- [5]反抗  -- 抓奴仆 
	CONST_MOIL_FUNCTION_REVOLT                 = 5,
	-- [6]求救  -- 抓奴仆 
	CONST_MOIL_FUNCTION_ASKHELP                = 6,
	-- [7]夺扑之敌  -- 抓奴仆 
	CONST_MOIL_FUNCTION_SNATCH                 = 7,
	-- [8]释放  -- 抓奴仆 
	CONST_MOIL_FUNCTION_SHIFAN                 = 8,

	-- [1]身份-主人  -- 抓奴仆 
	CONST_MOIL_ID_HOST                         = 1,
	-- [2]身份-奴仆  -- 抓奴仆 
	CONST_MOIL_ID_MOIL                         = 2,
	-- [3]身份-酱油党  -- 抓奴仆 
	CONST_MOIL_ID_FREEMAN                      = 3,
	-- [4]身份-主人兼奴仆  -- 抓奴仆 
	CONST_MOIL_ID_H_M                          = 4,

	-- [1]压榨类型-压榨  -- 抓奴仆 
	CONST_MOIL_PRESS                           = 1,
	-- [2]压榨类型-提取  -- 抓奴仆 
	CONST_MOIL_PRESS_2                         = 2,
	-- [3]压榨类型-抽干  -- 抓奴仆 
	CONST_MOIL_PRESS_3                         = 3,

	-- [3]奴仆最大拥有数量  -- 抓奴仆 
	CONST_MOIL_MOIL_COUNT                      = 3,

	-- [10]购买抓捕次数上限  -- 抓奴仆 
	CONST_MOIL_CATCH_MAX                       = 10,
	-- [10]购买一次抓捕消耗金元  -- 抓奴仆 
	CONST_MOIL_CATCH_RMB_USE                   = 10,
	-- [10]压榨1小时消耗金元  -- 抓奴仆 
	CONST_MOIL_PRESS_RMB_USE                   = 10,
	-- [37]奴仆开放等级  -- 抓奴仆 
	CONST_MOIL_OPEN_LV                         = 37,

	--------------------------------------------------------------------
	-- ( 功能开放 ) 
	--------------------------------------------------------------------
	-- [10100]防沉迷 -- 功能开放 
	CONST_FUNC_OPEN_FCM                        = 10100,
	-- [10200]体力 -- 功能开放 
	CONST_FUNC_OPEN_ENARGY                     = 10200,
	-- [10300]邮件 -- 功能开放 
	CONST_FUNC_OPEN_MALL                       = 10300,
	-- [10400]聊天 -- 功能开放 
	CONST_FUNC_OPEN_CHATTING                   = 10400,
	-- [10500]排行榜 -- 功能开放 
	CONST_FUNC_OPEN_PAIHANG                    = 10500,
	-- [10600]攻略 -- 功能开放 
	CONST_FUNC_OPEN_STRATEGY                   = 10600,
	-- [10610]攻略-活动日历 -- 功能开放 
	CONST_FUNC_OPEN_STRATEGY_CALENDAR          = 10610,
	-- [10620]攻略-今日活跃 -- 功能开放 
	CONST_FUNC_OPEN_STRATEGY_ACTIVE            = 10620,
	-- [10630]攻略-我要变强 -- 功能开放 
	CONST_FUNC_OPEN_STRATEGY_STRONG            = 10630,
	-- [10700]设置 -- 功能开放 
	CONST_FUNC_OPEN_SETING                     = 10700,
	-- [10710]更新公告 -- 功能开放 
	CONST_FUNC_OPEN_SETING_UPDATE              = 10710,
	-- [10720]联系GM -- 功能开放 
	CONST_FUNC_OPEN_SETING_CONTACT_GM          = 10720,
	-- [10730]提交BUG -- 功能开放 
	CONST_FUNC_OPEN_SETING_SUBMIT_BUG          = 10730,
	-- [10740]微信绑定 -- 功能开放 
	CONST_FUNC_OPEN_SETING_WEIXING             = 10740,

	-- [20100]角色 -- 功能开放 
	CONST_FUNC_OPEN_ROLE                       = 20100,
	-- [20110]角色-属性 -- 功能开放 
	CONST_FUNC_OPEN_ROLE_ATTRIBUTE             = 20110,
	-- [20120]角色-装备 -- 功能开放 
	CONST_FUNC_OPEN_ROLE_EQUIP                 = 20120,
	-- [20130]角色-技能 -- 功能开放 
	CONST_FUNC_OPEN_ROLE_SKILL                 = 20130,
	-- [20140]角色-金身 -- 功能开放 
	CONST_FUNC_OPEN_ROLE_GOLD                  = 20140,
	-- [20150]角色-称号 -- 功能开放 
	CONST_FUNC_OPEN_ROLE_TITLE                 = 20150,
	-- [20160]器灵 -- 功能开放 
	CONST_FUNC_OPEN_QILING                     = 20160,
	-- [20170]神羽 -- 功能开放 
	CONST_FUNC_OPEN_FEATHER                    = 20170,
	-- [20200]湛卢坊 -- 功能开放 
	CONST_FUNC_OPEN_SMITHY                     = 20200,
	-- [20210]湛卢坊-强化 -- 功能开放 
	CONST_FUNC_OPEN_SMITHY_STRENGTHEN          = 20210,
	-- [20220]湛卢坊-升品 -- 功能开放 
	CONST_FUNC_OPEN_SMITHY_QUALITY             = 20220,
	-- [20230]湛卢坊-镶嵌 -- 功能开放 
	CONST_FUNC_OPEN_SMITHY_INLAY               = 20230,
	-- [20240]湛卢坊-分解 -- 功能开放 
	CONST_FUNC_OPEN_SMITHY_RESOLVE             = 20240,
	-- [20250]湛卢坊-附魔 -- 功能开放 
	CONST_FUNC_OPEN_SMITHY_ENCHANTS            = 20250,
	-- [20300]神兵 -- 功能开放 
	CONST_FUNC_OPEN_ARTIFACT                   = 20300,
	-- [20310]神兵-装备 -- 功能开放 
	CONST_FUNC_OPEN_ARTIFACT_EQUIP             = 20310,
	-- [20320]神兵-强化 -- 功能开放 
	CONST_FUNC_OPEN_ARTIFACT_STRENGTHEN        = 20320,
	-- [20330]神兵-升阶 -- 功能开放 
	CONST_FUNC_OPEN_ARTIFACT_QUALITY           = 20330,
	-- [20340]神兵-洗练 -- 功能开放 
	CONST_FUNC_OPEN_ARTIFACT_WASH              = 20340,
	-- [20400]坐骑 -- 功能开放 
	CONST_FUNC_OPEN_MOUNT                      = 20400,
	-- [20500]真元 -- 功能开放 
	CONST_FUNC_OPEN_WING                       = 20500,
	-- [20600]珍宝 -- 功能开放 
	CONST_FUNC_OPEN_JEWELLERY                  = 20600,
	-- [20700]背包 -- 功能开放 
	CONST_FUNC_OPEN_BAG                        = 20700,
	-- [20710]背包-道具 -- 功能开放 
	CONST_FUNC_OPEN_BAG_PROP                   = 20710,
	-- [20720]背包-宝石 -- 功能开放 
	CONST_FUNC_OPEN_BAG_GEM                    = 20720,
	-- [20730]背包-装备 -- 功能开放 
	CONST_FUNC_OPEN_BAG_EQUIP                  = 20730,
	-- [20740]背包-购回 -- 功能开放 
	CONST_FUNC_OPEN_BAG_REPURCHASE             = 20740,
	-- [20750]背包-合成 -- 功能开放 
	CONST_FUNC_OPEN_BAG_COMPOSE                = 20750,
	-- [20800]美人 -- 功能开放 
	CONST_FUNC_OPEN_BEAUTY                     = 20800,
	-- [20900]任务 -- 功能开放 
	CONST_FUNC_OPEN_TASK                       = 20900,
	-- [20910]任务-主线 -- 功能开放 
	CONST_FUNC_OPEN_TASK_THREAD                = 20910,
	-- [20920]任务-支线 -- 功能开放 
	CONST_FUNC_OPEN_TASK_FEEDER                = 20920,
	-- [20930]任务-悬赏 -- 功能开放 
	CONST_FUNC_OPEN_TASK_DAILY                 = 20930,
	-- [21000]卦象 -- 功能开放 
	CONST_FUNC_OPEN_SHEN                       = 21000,
	-- [21010]卦象-升级 -- 功能开放 
	CONST_FUNC_OPEN_SHEN_UP                    = 21010,
	-- [21020]卦象-升品 -- 功能开放 
	CONST_FUNC_OPEN_SHEN_QUALITY               = 21020,
	-- [21100]守护 -- 功能开放 
	CONST_FUNC_OPEN_PARTNER                    = 21100,
	-- [21110]守护-属性 -- 功能开放 
	CONST_FUNC_OPEN_PARTNER_ATTRIBUTE          = 21110,
	-- [21120]守护-图鉴 -- 功能开放 
	CONST_FUNC_OPEN_PARTNER_ATLAS              = 21120,
	-- [21130]守护-进阶 -- 功能开放 
	CONST_FUNC_OPEN_PARTNER_ADVANCED           = 21130,
	-- [21140]守护-炼魂 -- 功能开放 
	CONST_FUNC_OPEN_PARTNER_SOUL               = 21140,
	-- [21150]守护-助阵 -- 功能开放 
	CONST_FUNC_OPEN_PARTNER_CHEER              = 21150,
	-- [21200]仙宠灵兽 -- 功能开放 
	CONST_FUNC_OPEN_DAEMON                     = 21200,

	-- [3000]竞技 -- 功能开放 
	CONST_FUNC_OPEN_DUEL                       = 3000,
	-- [3100]挑战 -- 功能开放 
	CONST_FUNC_OPEN_DEKARON                    = 3100,
	-- [30100]洞府 -- 功能开放 
	CONST_FUNC_OPEN_GANGS                      = 30100,
	-- [30101]洞府-洞府列表 -- 功能开放 
	CONST_FUNC_OPEN_GANGS_LIST                 = 30101,
	-- [30102]洞府-洞府总览 -- 功能开放 
	CONST_FUNC_OPEN_GANGS_OVERVIEW             = 30102,
	-- [30103]洞府-洞府成员 -- 功能开放 
	CONST_FUNC_OPEN_GANGS_MEMBERS              = 30103,
	-- [30104]洞府-洞府活动 -- 功能开放 
	CONST_FUNC_OPEN_GANGS_ACTIVITY             = 30104,
	-- [30105]洞府-洞府技能 -- 功能开放 
	CONST_FUNC_OPEN_GANGS_SKILL                = 30105,
	-- [30110]创建洞府 -- 功能开放 
	CONST_FUNC_OPEN_GANGS_FOUND                = 30110,
	-- [30120]洞府活动-洞府守护神 -- 功能开放 
	CONST_FUNC_OPEN_GANGS_BOSS                 = 30120,
	-- [30130]洞府活动-保卫圣兽堂 -- 功能开放 
	CONST_FUNC_OPEN_GANGS_DEFEND               = 30130,
	-- [30140]洞府活动-洞府大战 -- 功能开放 
	CONST_FUNC_OPEN_GANGS_WAR                  = 30140,
	-- [30150]洞府活动-占山为王 -- 功能开放 
	CONST_FUNC_OPEN_GANGS_KING                 = 30150,
	-- [30160]洞府活动-祈福 -- 功能开放 
	CONST_FUNC_OPEN_GANGS_QIFU                 = 30160,
	-- [30200]好友 -- 功能开放 
	CONST_FUNC_OPEN_FRIEND                     = 30200,
	-- [30210]好友-祝福 -- 功能开放 
	CONST_FUNC_OPEN_FRIEND_WISH                = 30210,
	-- [30300]竞技场 -- 功能开放 
	CONST_FUNC_OPEN_ARENA                      = 30300,
	-- [30400]奴仆 -- 功能开放 
	CONST_FUNC_OPEN_MOIL                       = 30400,
	-- [30500]通天浮屠 -- 功能开放 
	CONST_FUNC_OPEN_TOWER                      = 30500,
	-- [30600]浮屠静修 -- 功能开放 
	CONST_FUNC_OPEN_JINGXIU                    = 30600,
	-- [30700]封神榜 -- 功能开放 
	CONST_FUNC_OPEN_MYTH                       = 30700,
	-- [30800]大闹天宫 -- 功能开放 
	CONST_FUNC_OPEN_WELKIN                     = 30800,
	-- [30810]大闹天宫-问鼎天宫 -- 功能开放 
	CONST_FUNC_OPEN_WELKIN_FIRST               = 30810,
	-- [30820]大闹天宫-决战凌霄 -- 功能开放 
	CONST_FUNC_OPEN_WELKIN_BATTLE              = 30820,
	-- [30830]大闹天宫-独尊三界 -- 功能开放 
	CONST_FUNC_OPEN_WELKIN_ONLY                = 30830,
	-- [30900]三界争锋 -- 功能开放 
	CONST_FUNC_OPEN_STRIVE                     = 30900,
	-- [31000]副本 -- 功能开放 
	CONST_FUNC_OPEN_COPY                       = 31000,
	-- [31010]副本-剧情 -- 功能开放 
	CONST_FUNC_OPEN_COPY_COMMON                = 31010,
	-- [31020]副本-噩梦 -- 功能开放 
	CONST_FUNC_OPEN_COPY_NIGHTMARE             = 31020,
	-- [31030]副本-地狱 -- 功能开放 
	CONST_FUNC_OPEN_COPY_HELL                  = 31030,
	-- [31040]副本-珍宝 -- 功能开放 
	CONST_FUNC_OPEN_COPY_JEWELLERY             = 31040,
	-- [31100]群仙诛邪 -- 功能开放 
	CONST_FUNC_OPEN_TEAM                       = 31100,
	-- [31200]无限心魔 -- 功能开放 
	CONST_FUNC_OPEN_DEMONS                     = 31200,
	-- [31300]三界妖王 -- 功能开放 
	CONST_FUNC_OPEN_BOSS                       = 31300,
	-- [31310]三界妖王-世界 -- 功能开放 
	CONST_FUNC_OPEN_BOSS_SHIJIE                = 31310,
	-- [31320]三界妖王-城镇 -- 功能开放 
	CONST_FUNC_OPEN_BOSS_CHENGZHEN             = 31320,
	-- [31400]降魔之路 -- 功能开放 
	CONST_FUNC_OPEN_SURRENDER                  = 31400,
	-- [31500]秘宝活动 -- 功能开放 
	CONST_FUNC_OPEN_BOX                        = 31500,
	-- [31600]灵妖竞技 -- 功能开放 
	CONST_FUNC_OPEN_LYJJ                       = 31600,
	-- [31700]道劫 -- 功能开放 
	CONST_FUNC_OPEN_DAOJIE                     = 31700,

	-- [4000]活动 -- 功能开放 
	CONST_FUNC_OPEN_ACTIVITY                   = 4000,
	-- [4100]时段活动 -- 功能开放 
	CONST_FUNC_OPEN_TIME                       = 4100,
	-- [40100]转盘抽奖 -- 功能开放 
	CONST_FUNC_OPEN_TURNTABLE                  = 40100,
	-- [40200]摇钱树 -- 功能开放 
	CONST_FUNC_OPEN_LUCKY                      = 40200,
	-- [40300]对对牌 -- 功能开放 
	CONST_FUNC_OPEN_CARDS                      = 40300,
	-- [40400]翻翻乐 -- 功能开放 
	CONST_FUNC_OPEN_GAMBLE                     = 40400,
	-- [40500]限时抢购 -- 功能开放 
	CONST_FUNC_OPEN_RUSH                       = 40500,
	-- [40600]拍卖活动 -- 功能开放 
	CONST_FUNC_OPEN_AUCTION                    = 40600,
	-- [40700]精彩返利 -- 功能开放 
	CONST_FUNC_OPEN_REBATE                     = 40700,
	-- [40800]节日活动 -- 功能开放 
	CONST_FUNC_OPEN_HOLIDAY                    = 40800,
	-- [40810]节日活动-节日转盘 -- 功能开放 
	CONST_FUNC_OPEN_HOLIDAY_TURNTABLE          = 40810,
	-- [40820]节日活动-一字千金 -- 功能开放 
	CONST_FUNC_OPEN_HOLIDAY_VALUELESS          = 40820,
	-- [40830]节日活动-登陆送礼 -- 功能开放 
	CONST_FUNC_OPEN_HOLIDAY_GIVE               = 40830,
	-- [40840]节日活动-铜钱副本 -- 功能开放 
	CONST_FUNC_OPEN_HOLIDAY_TONGQIAN           = 40840,
	-- [40900]福利 -- 功能开放 
	CONST_FUNC_OPEN_WELFARE                    = 40900,
	-- [40910]签到奖励 -- 功能开放 
	CONST_FUNC_OPEN_REWARD_SIGN                = 40910,
	-- [40920]在线奖励 -- 功能开放 
	CONST_FUNC_OPEN_REWARD_ON_LINE             = 40920,
	-- [40930]等级奖励 -- 功能开放 
	CONST_FUNC_OPEN_REWARD_LV                  = 40930,
	-- [41000]礼包码 -- 功能开放 
	CONST_FUNC_OPEN_NOVICE                     = 41000,
	-- [41100]科举 -- 功能开放 
	CONST_FUNC_OPEN_EXAMINATION                = 41100,
	-- [41200]开服七日 -- 功能开放 
	CONST_FUNC_OPEN_SEVENDAY                   = 41200,

	-- [41300]充值 -- 功能开放 
	CONST_FUNC_OPEN_RECHARGE                   = 41300,
	-- [41310]充值-充值 -- 功能开放 
	CONST_FUNC_OPEN_RECHARGE_R                 = 41310,
	-- [41320]充值-vip特权 -- 功能开放 
	CONST_FUNC_OPEN_RECHARGE_VIP_PRIVILEGE     = 41320,
	-- [41330]充值-平民基金 -- 功能开放 
	CONST_FUNC_OPEN_RECHARGE_S_FUND            = 41330,
	-- [41340]充值-土豪基金 -- 功能开放 
	CONST_FUNC_OPEN_RECHARGE_B_FUND            = 41340,
	-- [41350]充值-至尊商城 -- 功能开放 
	CONST_FUNC_OPEN_RECHARGE_SUPREME           = 41350,
	-- [41360]充值-月卡 -- 功能开放 
	CONST_FUNC_OPEN_RECHARGE_YUEKA             = 41360,
	-- [41370]充值-基金 -- 功能开放 
	CONST_FUNC_OPEN_RECHARGE_JIJIN             = 41370,
	-- [41380]充值-招财貔貅 -- 功能开放 
	CONST_FUNC_OPEN_WEAGOD_RMB                 = 41380,
	-- [41400]每日首充 -- 功能开放 
	CONST_FUNC_OPEN_EXAMINATION_DAILY          = 41400,
	-- [41500]商城 -- 功能开放 
	CONST_FUNC_OPEN_SHOP                       = 41500,
	-- [41510]商城-道具 -- 功能开放 
	CONST_FUNC_OPEN_SHOP_PROP                  = 41510,
	-- [41520]商城-宝石 -- 功能开放 
	CONST_FUNC_OPEN_SHOP_GEM                   = 41520,
	-- [41530]商城-热卖 -- 功能开放 
	CONST_FUNC_OPEN_SHOP_HOT                   = 41530,
	-- [41540]商城-礼包 -- 功能开放 
	CONST_FUNC_OPEN_SHOP_PACKAGE               = 41540,
	-- [41550]商城-元宝 -- 功能开放 
	CONST_FUNC_OPEN_SHOP_YUANBAO               = 41550,
	-- [41560]商城-神器 -- 功能开放 
	CONST_FUNC_OPEN_SHOP_SHENQI                = 41560,
	-- [41570]商城-灵妖 -- 功能开放 
	CONST_FUNC_OPEN_SHOP_LINGYAO               = 41570,
	-- [41700]抽奖 -- 功能开放 
	CONST_FUNC_OPEN_DRAW                       = 41700,
	-- [41800]三日首充 -- 功能开放 
	CONST_FUNC_OPEN_SRSC                       = 41800,
	-- [72250]独尊三界 -- 功能开放 
	CONST_FUNC_OPEN_DZSJ                       = 72250,

	-- [50000]切磋 -- 功能开放 
	CONST_FUNC_OPEN_QIECHUO_GONGLUE            = 50000,
	-- [50100]成就 -- 功能开放 
	CONST_FUNC_OPEN_CHENGJIU                   = 50100,

	--------------------------------------------------------------------
	-- ( 三界杀 ) 
	--------------------------------------------------------------------
	-- [3]消耗精力  -- 三界杀 
	CONST_CIRCLE_ENERGY                        = 3,
	-- [50]重置消耗金元  -- 三界杀 
	CONST_CIRCLE_RMB                           = 50,
	-- [30001]三界杀初始化武将  -- 三界杀 
	CONST_CIRCLE_INIT                          = 30001,

	--------------------------------------------------------------------
	-- ( VIP ) 
	--------------------------------------------------------------------
	-- [2]VIP2增加背包  -- VIP 
	CONST_VIP_BAG_ADD_TWO                      = 2,
	-- [5]VIP5增加背包  -- VIP 
	CONST_VIP_BAG_ADD_FIVE                     = 5,
	-- [7]VIP7增加背包  -- VIP 
	CONST_VIP_BAG_ADD_SEVNE                    = 7,
	-- [15]VIP最高等级  -- VIP 
	CONST_VIP_MOST_LV                          = 15,

	--------------------------------------------------------------------
	-- ( 剧情 ) 
	--------------------------------------------------------------------
	-- [1]剧情类型-人物出现  -- 剧情 
	CONST_DRAMA_ACT_APPEAR                     = 1,
	-- [2]剧情类型-人物对话  -- 剧情 
	CONST_DRAMA_ACT_DIALOGUE                   = 2,
	-- [3]剧情类型-人物移动  -- 剧情 
	CONST_DRAMA_ACT_MOVE                       = 3,
	-- [4]剧情类型-人物消失  -- 剧情 
	CONST_DRAMA_ACT_DISAPPEAR                  = 4,
	-- [5]剧情类型-人物离开  -- 剧情 
	CONST_DRAMA_ACT_LEAVE                      = 5,
	-- [6]剧情类型-剧情更换  -- 剧情 
	CONST_DRAMA_ACT_REPLACE                    = 6,
	-- [7]剧情类型-播放特效  -- 剧情 
	CONST_DRAMA_ACT_EFFECT                     = 7,
	-- [8]剧情类型-普通攻击特效  -- 剧情 
	CONST_DRAMA_ACT_NORMAL_ATTACK              = 8,
	-- [9]剧情类型-绝招攻击特效  -- 剧情 
	CONST_DRAMA_ACT_UNIQUE_SKILL               = 9,
	-- [10]剧情类型-人物死亡  -- 剧情 
	CONST_DRAMA_ACT_DEATH                      = 10,
	-- [11]剧情类型-人物打坐  -- 剧情 
	CONST_DRAMA_ACT_MEDITATION                 = 11,
	-- [12]剧情类型-人物正常状态  -- 剧情 
	CONST_DRAMA_ACT_NORMAL_STATE               = 12,
	-- [13]剧情类型-震屏  -- 剧情 
	CONST_DRAMA_ACT_SHOCK                      = 13,
	-- [14]剧情类型-摄像机平移  -- 剧情 
	CONST_DRAMA_ACT_CAMERA                     = 14,
	-- [15]剧情类型-对话(弹窗)  -- 剧情 
	CONST_DRAMA_ACT_ALERT                      = 15,
	-- [16]剧情类型-飘头像  -- 剧情 
	CONST_DRAMA_ACT_FULLTER                    = 16,
	-- [17]剧情类型-加属性  -- 剧情 
	CONST_DRAMA_ACT_ADDATTR                    = 17,
	-- [18]剧情类型-开启霸体  -- 剧情 
	CONST_DRAMA_ACT_ADDBUFF                    = 18,
	-- [19]剧情类型-开启大招  -- 剧情 
	CONST_DRAMA_ACT_ADDBIGSKILL                = 19,
	-- [21]剧情类型-移除尸体 -- 剧情 
	CONST_DRAMA_ACT_CLEANBODY                  = 21,

	-- [1]触发条件-进入场景  -- 剧情 
	CONST_DRAMA_GETINTO                        = 1,
	-- [2]触发条件-场景通关后  -- 剧情 
	CONST_DRAMA_FINISHE                        = 2,
	-- [3]触发条件-遇到指定BOSS  -- 剧情 
	CONST_DRAMA_ENCOUNTER                      = 3,
	-- [4]触发条件-任务触发  -- 剧情 
	CONST_DRAMA_TRIGGER                        = 4,
	-- [5]触发条件-打死指定BOSS  -- 剧情 
	CONST_DRAMA_DEFEAT                         = 5,

	-- [4]方向-西  -- 剧情 
	CONST_DRAMA_DIR_WEST                       = 4,
	-- [6]方向-东  -- 剧情 
	CONST_DRAMA_DIR_EAST                       = 6,

	--------------------------------------------------------------------
	-- ( 活动 ) 
	--------------------------------------------------------------------
	-- [0]通用活动状态--活动结束  -- 活动 
	CONST_ACTIVITY_STATE_OVER                  = 0,
	-- [1]通用活动状态--活动开始  -- 活动 
	CONST_ACTIVITY_STATE_START                 = 1,
	-- [2]通用活动状态--提前入场  -- 活动 
	CONST_ACTIVITY_STATE_ENTRANCE              = 2,
	-- [3]通用活动状态--提前通知  -- 活动 
	CONST_ACTIVITY_STATE_ADVANCE               = 3,
	-- [4]通用活动状态--提前报名  -- 活动 
	CONST_ACTIVITY_STATE_SIGN                  = 4,
	-- [5]通用活动状态--未开始  -- 活动 
	CONST_ACTIVITY_STATE_NOT_OPEN              = 5,
	-- [10]doloop检查时间  -- 活动 
	CONST_ACTIVITY_DOLOOP_TIME                 = 10,

	-- [0]活动类型--开服活动  -- 活动 
	CONST_ACTIVITY_TYPE_OPEN                   = 0,
	-- [1]活动类型--充值活动  -- 活动 
	CONST_ACTIVITY_TYPE_TIMES                  = 1,
	-- [2]活动类型--日常活动  -- 活动 
	CONST_ACTIVITY_TYPE_DAILY                  = 2,
	-- [4]活动类型--集体活动  -- 活动 
	CONST_ACTIVITY_TYPE_RANK                   = 4,

	-- [1001]活动ID--世界Boss1 -- 活动 
	CONST_ACTIVITY_WORLD_BOSS                  = 1001,
	-- [1002]活动ID--世界BOSS2  -- 活动 
	CONST_ACTIVITY_WORLD_BOSS_TWO              = 1002,
	-- [2001]活动ID--洞府守卫战  -- 活动 
	CONST_ACTIVITY_CLAN_DEFENSE                = 2001,
	-- [2002]活动ID--洞府战  -- 活动 
	CONST_ACTIVITY_ID_CLAN_WAR                 = 2002,
	-- [2003]活动ID--占山为王 -- 活动 
	CONST_ACTIVITY_CLAN_HILL                   = 2003,
	-- [3001]活动ID--格斗之王预赛  -- 活动 
	CONST_ACTIVITY_WRESTLE_YUSAI               = 3001,
	-- [3002]活动ID--格斗之王决赛  -- 活动 
	CONST_ACTIVITY_WRESTLE                     = 3002,
	-- [3006]活动ID--格斗之王竞猜（别删）  -- 活动 
	CONST_ACTIVITY_WRESTLE_GUESS               = 3006,
	-- [4001]活动ID--问鼎天宫 -- 活动 
	CONST_ACTIVITY_OPEN_10                     = 4001,
	-- [4002]活动ID--决战凌霄 -- 活动 
	CONST_ACTIVITY_OPEN_11                     = 4002,
	-- [4003]活动ID--独尊三界-初赛 -- 活动 
	CONST_ACTIVITY_OPEN_12                     = 4003,
	-- [4004]活动ID--独尊三界-决赛 -- 活动 
	CONST_ACTIVITY_OPEN_13                     = 4004,
	-- [5001]活动ID--限时团购  -- 活动 
	CONST_ACTIVITY_TUANGOU                     = 5001,
	-- [5002]活动ID--竞拍系统  -- 活动 
	CONST_ACTIVITY_AUCTION                     = 5002,
	-- [5003]活动ID--御前科举  -- 活动 
	CONST_ACTIVITY_KEJU                        = 5003,

	-- [101]悬赏任务 -- 活动 
	CONST_ACTIVITY_LINK_101                    = 101,
	-- [102]地狱副本 -- 活动 
	CONST_ACTIVITY_LINK_102                    = 102,
	-- [103]噩梦副本 -- 活动 
	CONST_ACTIVITY_LINK_103                    = 103,
	-- [104]三界妖王 -- 活动 
	CONST_ACTIVITY_LINK_104                    = 104,
	-- [105]封神榜 -- 活动 
	CONST_ACTIVITY_LINK_105                    = 105,
	-- [106]祈福 -- 活动 
	CONST_ACTIVITY_LINK_106                    = 106,
	-- [107]卦象 -- 活动 
	CONST_ACTIVITY_LINK_107                    = 107,
	-- [108]翻翻乐 -- 活动 
	CONST_ACTIVITY_LINK_108                    = 108,
	-- [109]群仙诛邪 -- 活动 
	CONST_ACTIVITY_LINK_109                    = 109,
	-- [110]通天浮屠 -- 活动 
	CONST_ACTIVITY_LINK_110                    = 110,
	-- [111]好友祝福 -- 活动 
	CONST_ACTIVITY_LINK_111                    = 111,
	-- [112]购买体力 -- 活动 
	CONST_ACTIVITY_LINK_112                    = 112,

	-- [1001]洞府守护神 -- 活动 
	CONST_ACTIVITY_MAIL_CLAN_BOSS              = 1001,
	-- [1002]世界BOSS -- 活动 
	CONST_ACTIVITY_MAIL_WOLD_BOSS              = 1002,
	-- [1003]世界BOSS击杀奖 -- 活动 
	CONST_ACTIVITY_MAIL_KILL_BOSS              = 1003,
	-- [1006]洞府守护神击杀奖 -- 活动 
	CONST_ACTIVITY_MAIL_CLAN_BOSS_KILL         = 1006,
	-- [1007]竞技场奖励 -- 活动 
	CONST_ACTIVITY_MAIL_ARENA                  = 1007,
	-- [1008]竞技场结算 -- 活动 
	CONST_ACTIVITY_MAIL_ARENA_SETTLEMENT       = 1008,
	-- [1011]占山为王奖励 -- 活动 
	CONST_ACTIVITY_MAIL_CAPTURE_S              = 1011,
	-- [1012]占山为王奖励 -- 活动 
	CONST_ACTIVITY_MAIL_CAPTURE_D              = 1012,
	-- [1013]占山为王奖励 -- 活动 
	CONST_ACTIVITY_MAIL_CAPTURE_S_HARM         = 1013,
	-- [1014]占山为王奖励 -- 活动 
	CONST_ACTIVITY_MAIL_CAPTURE_D_HARM         = 1014,
	-- [1015]退出洞府 -- 活动 
	CONST_ACTIVITY_MAIL_CLAN_QUIT              = 1015,
	-- [1016]洞府拒绝申请 -- 活动 
	CONST_ACTIVITY_MAIL_CLAN_REFUSE            = 1016,
	-- [1017]洞府大战初赛奖励 -- 活动 
	CONST_ACTIVITY_MAIL_CLAN_WAR_FIRST         = 1017,
	-- [1018]洞府大战决赛奖励 -- 活动 
	CONST_ACTIVITY_MAIL_CLAN_WAR_FIRST_WIN     = 1018,
	-- [1019]洞府大战决赛奖励 -- 活动 
	CONST_ACTIVITY_MAIL_CLAN_WAR_SECOND_WIN    = 1019,
	-- [1020]洞府大战击杀奖励 -- 活动 
	CONST_ACTIVITY_MAIL_CLAN_WAR_FIRST_KILL_REWARD = 1020,
	-- [1030]保卫圣兽堂奖励 -- 活动 
	CONST_ACTIVITY_MAIL_CLAN_SST_TOTAL         = 1030,
	-- [1031]保卫圣兽堂奖励 -- 活动 
	CONST_ACTIVITY_MAIL_CLAN_SST_PERSONAL      = 1031,
	-- [3001]竞拍系统 -- 活动 
	CONST_ACTIVITY_MAIL_JP_G                   = 3001,
	-- [3002]竞拍系统 -- 活动 
	CONST_ACTIVITY_MAIL_JP_F                   = 3002,
	-- [4001]封测大礼 -- 活动 
	CONST_ACTIVITY_MAIL_TEST                   = 4001,
	-- [5001]充值排行 -- 活动 
	CONST_ACTIVITY_MAIL_RECHARGE               = 5001,
	-- [5002]消费排行 -- 活动 
	CONST_ACTIVITY_MAIL_CONSUME                = 5002,
	-- [5003]竞技王者 -- 活动 
	CONST_ACTIVITY_MAIL_KING_JJ                = 5003,
	-- [5004]最强至尊 -- 活动 
	CONST_ACTIVITY_MAIL_KING_ZZ                = 5004,
	-- [6001]科举 -- 活动 
	CONST_ACTIVITY_MAIL_KEJU                   = 6001,
	-- [7001]浮屠静修奖励 -- 活动 
	CONST_ACTIVITY_HERO_TOWER_1                = 7001,
	-- [7002]浮屠静修抢占 -- 活动 
	CONST_ACTIVITY_HERO_TOWER_2                = 7002,
	-- [7003]浮屠静修 -- 活动 
	CONST_ACTIVITY_HERO_TOWER_3                = 7003,
	-- [7004]浮屠静修 -- 活动 
	CONST_ACTIVITY_HERO_TOWER_4                = 7004,
	-- [7005]浮屠静修被抢占 -- 活动 
	CONST_ACTIVITY_HERO_TOWER_5                = 7005,
	-- [7011]无尽心魔奖励 -- 活动 
	CONST_ACTIVITY_MAIL_TOWER                  = 7011,
	-- [7021]三界争锋 -- 活动 
	CONST_ACTIVITY_MAIL_STRIVE_APPLICANTS_S    = 7021,
	-- [7022]三界争锋 -- 活动 
	CONST_ACTIVITY_MAIL_STRIVE_APPLICANTS_D    = 7022,
	-- [7023]三界争锋奖励 -- 活动 
	CONST_ACTIVITY_MAIL_STRIVE_REWARD_P        = 7023,
	-- [7024]三界争锋奖励 -- 活动 
	CONST_ACTIVITY_MAIL_STRIVE_REWARD_F_D      = 7024,
	-- [7025]三界争锋奖励 -- 活动 
	CONST_ACTIVITY_MAIL_STRIVE_REWARD_F_V      = 7025,
	-- [7026]三界争锋 -- 活动 
	CONST_ACTIVITY_MAIL_STRIVE_REWARD_V        = 7026,
	-- [7027]三界争锋 -- 活动 
	CONST_ACTIVITY_MAIL_STRIVE_REWARD_D        = 7027,
	-- [7031]欢乐竞猜 -- 活动 
	CONST_ACTIVITY_MAIL_QUIZ_S                 = 7031,
	-- [7032]欢乐竞猜 -- 活动 
	CONST_ACTIVITY_MAIL_QUIZ_D                 = 7032,
	-- [7033]欢乐竞猜 -- 活动 
	CONST_ACTIVITY_MAIL_QUIZ_B                 = 7033,
	-- [7101]称号邮件 -- 活动 
	CONST_ACTIVITY_CH_YJ_1                     = 7101,
	-- [7102]称号邮件 -- 活动 
	CONST_ACTIVITY_CH_YJ_2                     = 7102,
	-- [7201]问鼎天宫 -- 活动 
	CONST_ACTIVITY_MAIL_WDTG_REWARD            = 7201,
	-- [7202]问鼎天宫 -- 活动 
	CONST_ACTIVITY_MAIL_WDTG_S                 = 7202,
	-- [7203]问鼎天宫 -- 活动 
	CONST_ACTIVITY_MAIL_WDTG_D                 = 7203,
	-- [7211]决战凌霄 -- 活动 
	CONST_ACTIVITY_MAIL_JZLX_REWARD            = 7211,
	-- [7212]决战凌霄 -- 活动 
	CONST_ACTIVITY_MAIL_JZLX_S                 = 7212,
	-- [7213]决战凌霄 -- 活动 
	CONST_ACTIVITY_MAIL_JZLX_D                 = 7213,
	-- [7222]独尊三界奖励 -- 活动 
	CONST_ACTIVITY_MAIL_DZSJ_D                 = 7222,
	-- [7223]独尊三界奖励 -- 活动 
	CONST_ACTIVITY_MAIL_DZSJ_PR_S              = 7223,
	-- [7224]独尊三界奖励 -- 活动 
	CONST_ACTIVITY_MAIL_DZSJ_FI_S              = 7224,
	-- [7225]独尊三界 -- 活动 
	CONST_ACTIVITY_MAIL_DZSJ_APPLICANTS_S      = 7225,
	-- [7226]独尊三界 -- 活动 
	CONST_ACTIVITY_MAIL_DZSJ_APPLICANTS_D      = 7226,
	-- [7227]欢乐竞猜 -- 活动 
	CONST_ACTIVITY_MAIL_DZSJ_QUIZ_S            = 7227,
	-- [7228]欢乐竞猜 -- 活动 
	CONST_ACTIVITY_MAIL_DZSJ_QUIZ_D            = 7228,
	-- [7232]欢乐竞猜 -- 活动 
	CONST_ACTIVITY_MAIL_DZSJ_QUIZ_B            = 7232,
	-- [7233]独尊三界-进入决赛 -- 活动 
	CONST_ACTIVITY_MAIL_DZSJ_INFIN             = 7233,
	-- [7411]奴仆抢夺 -- 活动 
	CONST_ACTIVITY_MOIL_QD                     = 7411,
	-- [7412]奴仆反抗 -- 活动 
	CONST_ACTIVITY_MOIL_FK                     = 7412,

	-- [0]新功能-点一次特效消失  -- 活动 
	CONST_ACTIVITY_NEW                         = 0,
	-- [1]无特效  -- 活动 
	CONST_ACTIVITY_ZHENGCHANG                  = 1,
	-- [2]活动期间存在特效  -- 活动 
	CONST_ACTIVITY_ACTIVITY                    = 2,
	-- [3]永久存在特效  -- 活动 
	CONST_ACTIVITY_YONGJIU                     = 3,
	-- [4]子类存在特效  -- 活动 
	CONST_ACTIVITY_ZILEI                       = 4,

	-- [1]主场景页面按钮打开方式-多个图标  -- 活动 
	CONST_ACTIVITY_OPEN_TYPE_A                 = 1,
	-- [2]主场景页面按钮打开方式-列表  -- 活动 
	CONST_ACTIVITY_OPEN_TYPE_B                 = 2,

	--------------------------------------------------------------------
	-- ( 目标任务 ) 
	--------------------------------------------------------------------
	-- [1]类型-完成主线任务(任务ID)  -- 目标任务 
	CONST_TARGET_TASK                          = 1,
	-- [2]类型-强化装备(到多少级)  -- 目标任务 
	CONST_TARGET_STRENG_EQUIP                  = 2,
	-- [3]类型-招财(次数)  -- 目标任务 
	CONST_TARGET_WEAGOD                        = 3,
	-- [4]类型-上香(次数)  -- 目标任务 
	CONST_TARGET_WEACEN                        = 4,
	-- [5]类型-提升声望等级(到多少级)  -- 目标任务 
	CONST_TARGET_RENOWN_LEVEL                  = 5,
	-- [6]类型-副本通关(副本ID)  -- 目标任务 
	CONST_TARGET_OVER_COPY                     = 6,
	-- [7]类型-培养坐骑(次数)  -- 目标任务 
	CONST_TARGET_CUL_MOUNT                     = 7,
	-- [8]类型-打造装备(次数)  -- 目标任务 
	CONST_TARGET_MAKE_EQUIP                    = 8,
	-- [9]类型-抓奴仆、获取经验  -- 目标任务 
	CONST_TARGET_MOIL_EXP                      = 9,
	-- [10]类型-去三界杀杀武将(武将ID)  -- 目标任务 
	CONST_TARGET_KILL_WUJIANG                  = 10,
	-- [11]类型-去封神台挑战(次数)  -- 目标任务 
	CONST_TARGET_WAR_ARENA                     = 11,

	-- [1]目标状态--未完成  -- 目标任务 
	CONST_TARGET_UNDONE                        = 1,
	-- [2]目标状态--已完成  -- 目标任务 
	CONST_TARGET_FINISH                        = 2,
	-- [3]目标状态--已领取  -- 目标任务 
	CONST_TARGET_REWARD                        = 3,

	-- [1]初始目标任务序号  -- 目标任务 
	CONST_TARGET_INIT_TASK                     = 1,
	-- [100010]目标任务开启-任务ID  -- 目标任务 
	CONST_TARGET_OPEN                          = 100010,

	--------------------------------------------------------------------
	-- ( 世界BOSS ) 
	--------------------------------------------------------------------
	-- [3]广播特效最大累计次数  -- 世界BOSS 
	CONST_BOSS_WAR_COUNT                       = 3,
	-- [300]提前入场时间  -- 世界BOSS 
	CONST_BOSS_REPLAY_TIME                     = 300,
	-- [1000]广播特效间隔毫秒  -- 世界BOSS 
	CONST_BOSS_WAR_LAST                        = 1000,
	-- [2000]广播dps时间间隔毫秒  -- 世界BOSS 
	CONST_BOSS_DPS_LAST                        = 2000,

	-- [12]公式常量-b  -- 世界BOSS 
	CONST_BOSS_FORMULA_B                       = 12,
	-- [20]公式常量-a  -- 世界BOSS 
	CONST_BOSS_FORMULA_A                       = 20,

	-- [30]世界BOSS复活次数  -- 世界BOSS 
	CONST_BOSS_TIMES_RELIVE                    = 30,

	-- [5000]暴击属性加成上限-50%  -- 世界BOSS 
	CONST_BOSS_CRIT_ADD_LIMIT                  = 5000,
	-- [10000]攻击属性加成上限-100%  -- 世界BOSS 
	CONST_BOSS_ATTACK_ADD_LIMIT                = 10000,

	-- [2020]三界BOSS皮肤  -- 世界BOSS 
	CONST_BOSS_SKIN                            = 2020,

	-- [0]安全区域X轴  -- 世界BOSS 
	CONST_BOSS_SECURITY_X                      = 0,

	-- [1001]洞府BOSS奖励邮件  -- 世界BOSS 
	CONST_BOSS_CLAN_BOSS_MAIL                  = 1001,
	-- [1002]世界BOSS奖励邮件  -- 世界BOSS 
	CONST_BOSS_WORLD_BOSS_MAIL                 = 1002,
	-- [1003]世界BOSS击杀邮件  -- 世界BOSS 
	CONST_BOSS_WORLD_BOSS_KILLED               = 1003,

	-- [10]世界boss复活消耗元宝  -- 世界BOSS 
	CONST_BOSS_RELIVE_PRICE                    = 10,
	-- [10]城镇boss复活消耗元宝  -- 世界BOSS 
	CONST_BOSS_CITY_RELIVE_PRICE               = 10,
	-- [20]世界boss复活时间  -- 世界BOSS 
	CONST_BOSS_RELIVE_TIME                     = 20,
	-- [30]城镇boss复活时间  -- 世界BOSS 
	CONST_BOSS_CITY_RELIVE_TIME                = 30,

	-- [5]鼓舞元宝数量  -- 世界BOSS 
	CONST_BOSS_EMBRAVE_MONEY                   = 5,

	-- [0.2]伤害奖励系数  -- 世界BOSS 
	CONST_BOSS_HARM_NUM                        = 0.2,
	-- [20]取竞技场平均等级-数量  -- 世界BOSS 
	CONST_BOSS_PJLV_NUM                        = 20,

	-- [61110]世界BOSS场景ID1  -- 世界BOSS 
	CONST_BOSS_MAP_ID1                         = 61110,
	-- [61120]世界BOSS场景ID2  -- 世界BOSS 
	CONST_BOSS_MAP_ID2                         = 61120,
	-- [61130]世界BOSS场景ID3  -- 世界BOSS 
	CONST_BOSS_MAP_ID3                         = 61130,

	-- [0]城镇BOSS未刷新  -- 世界BOSS 
	CONST_BOSS_CITY_STATE0                     = 0,
	-- [1]城镇BOSS已刷新  -- 世界BOSS 
	CONST_BOSS_CITY_STATE1                     = 1,
	-- [2]城镇BOSS已结束  -- 世界BOSS 
	CONST_BOSS_CITY_STATE2                     = 2,

	-- [6]dps显示数量 -- 世界BOSS 
	CONST_BOSS_DPS_COUNT                       = 6,

	-- [250]飙血数量 -- 世界BOSS 
	CONST_BOSS_BX_TIME                         = 250,

	-- [1]个人召唤次数 -- 世界BOSS 
	CONST_BOSS_P_CALL_TIMES                    = 1,
	-- [3]世界召唤次数 -- 世界BOSS 
	CONST_BOSS_W_CALL_TIMES                    = 3,
	-- [5]召唤需求（竞技场前n名） -- 世界BOSS 
	CONST_BOSS_CALL_DEMAND                     = 5,
	-- [300]花费钻石 -- 世界BOSS 
	CONST_BOSS_CALL_COST                       = 300,

	--------------------------------------------------------------------
	-- ( 取经之路 ) 
	--------------------------------------------------------------------
	-- [1]取经模式-单人  -- 取经之路 
	CONST_PILROAD_MODE_SINGAL                  = 1,
	-- [2]取经模式-多人  -- 取经之路 
	CONST_PILROAD_MODE_MULTI                   = 2,

	-- [3]组队要求至少玩家(个)  -- 取经之路 
	CONST_PILROAD_REQUIRE_PLAYERS              = 3,
	-- [3]组队奖励次数  -- 取经之路 
	CONST_PILROAD_REWARD_NUM                   = 3,

	-- [1]取经之路默认章节  -- 取经之路 
	CONST_PILROAD_DEFAULT_CHAP                 = 1,

	-- [1]采集结果类型-掉落物品  -- 取经之路 
	CONST_PILROAD_TYPE_COLLECT_FLOP            = 1,
	-- [2]采集结果类型-属性加成  -- 取经之路 
	CONST_PILROAD_TYPE_COLLECT_ATTR            = 2,
	-- [1500]采集怪属性加成上限  -- 取经之路 
	CONST_PILROAD_ATTR_LIMIT                   = 1500,
	-- [1500]物品属性加成上限  -- 取经之路 
	CONST_PILROAD_GOODS_ATTR_LIMIT             = 1500,

	-- [1]取经之路行为检查--文牒  -- 取经之路 
	CONST_PILROAD_CHECK_WAR                    = 1,
	-- [2]取经之路行为检查--剩余奖励次数  -- 取经之路 
	CONST_PILROAD_CHECK_REWARD                 = 2,

	-- [1]取经之路状态-进行中  -- 取经之路 
	CONST_PILROAD_STATE_PLAY                   = 1,
	-- [2]取经之路状态-杀完通关怪  -- 取经之路 
	CONST_PILROAD_STATE_KILL_BOSS              = 2,
	-- [3]取经之路状态-完成  -- 取经之路 
	CONST_PILROAD_STATE_OVER                   = 3,

	-- [1]黑店购买次数限制(买了不能再买)  -- 取经之路 
	CONST_PILROAD_BLACK_BUY_TIMES              = 1,
	-- [6]黑店刷新时间间隔(小时)  -- 取经之路 
	CONST_PILROAD_BLACK_REFRESH_TIME           = 6,
	-- [6]黑店显示物品种数  -- 取经之路 
	CONST_PILROAD_BLACK_NUM                    = 6,
	-- [10]黑店刷新消费元宝数量  -- 取经之路 
	CONST_PILROAD_BLACK_REFRESH_RMB            = 10,
	-- [20]黑店购买记录数量  -- 取经之路 
	CONST_PILROAD_BLACK_BUY_HISTORY            = 20,

	-- [5]买一个文牒所消耗的元宝数量  -- 取经之路 
	CONST_PILROAD_PLATE_RMB                    = 5,

	-- [1]物品增加物攻,法攻  -- 取经之路 
	CONST_PILROAD_GOOD_ATTR_ATTACK             = 1,
	-- [2]物品增加物防,法防  -- 取经之路 
	CONST_PILROAD_GOOD_ATTR_DEF                = 2,
	-- [3]物品增加速度  -- 取经之路 
	CONST_PILROAD_GOOD_ATTR_SPEED              = 3,
	-- [4]物品增加气血  -- 取经之路 
	CONST_PILROAD_GOOD_ATTR_HP                 = 4,
	-- [5]物品增加6种属性  -- 取经之路 
	CONST_PILROAD_GOOD_ATTR_SIX                = 5,

	--------------------------------------------------------------------
	-- ( 界面事件 ) 
	--------------------------------------------------------------------
	-- [1001]精力不足  -- 界面事件 
	CONST_SURFACE_ANENERGIA                    = 1001,
	-- [1006]破军技能  -- 界面事件 
	CONST_SURFACE_SKILL_DISRUPTING             = 1006,
	-- [1011]眩晕技能  -- 界面事件 
	CONST_SURFACE_SKILL_SWIM                   = 1011,
	-- [1016]镶嵌面板  -- 界面事件 
	CONST_SURFACE_INSET_PANEL                  = 1016,
	-- [1021]等级提升  -- 界面事件 
	CONST_SURFACE_LV_UP                        = 1021,
	-- [1026]星阵图  -- 界面事件 
	CONST_SURFACE_STAR                         = 1026,
	-- [1031]伙伴信息  -- 界面事件 
	CONST_SURFACE_PARTNER                      = 1031,
	-- [1036]声望提升  -- 界面事件 
	CONST_SURFACE_RENOWN                       = 1036,
	-- [1041]强化装备  -- 界面事件 
	CONST_SURFACE_EQUIP_STRENGTHEN             = 1041,
	-- [1046]招募伙伴  -- 界面事件 
	CONST_SURFACE_RECRUIT_PARTNER              = 1046,
	-- [1051]招财  -- 界面事件 
	CONST_SURFACE_WAVE_MONEY                   = 1051,

	--------------------------------------------------------------------
	-- ( 侠客行 ) 
	--------------------------------------------------------------------
	-- [0]立刻完成-vip开放等级  -- 侠客行 
	CONST_TASK_RAND_FINISHOPEN_VIP             = 0,
	-- [2]状态--已完成上一个任务  -- 侠客行 
	CONST_TASK_RAND_STATE                      = 2,
	-- [6]前进或后退最大步数  -- 侠客行 
	CONST_TASK_RAND_MAX_MOVE                   = 6,
	-- [10]快速完成花费金元  -- 侠客行 
	CONST_TASK_RAND_FAST_COST                  = 10,
	-- [10]一天最大掷骰子次数  -- 侠客行 
	CONST_TASK_RAND_MAX_ACCEPT                 = 10,

	-- [1]培养坐骑（次数）  -- 侠客行 
	CONST_TASK_RAND_MOUNT                      = 1,
	-- [2]强化装备（次数）  -- 侠客行 
	CONST_TASK_RAND_STRENG                     = 2,
	-- [3]洗练装备（次数）  -- 侠客行 
	CONST_TASK_RAND_WASH                       = 3,
	-- [4]竞技场（次数）  -- 侠客行 
	CONST_TASK_RAND_ARENA                      = 4,
	-- [5]完成副本（次数）  -- 侠客行 
	CONST_TASK_RAND_COPY                       = 5,
	-- [6]客栈斗法（次数）  -- 侠客行 
	CONST_TASK_RAND_INN_CONTEST                = 6,
	-- [7]招财（次数）  -- 侠客行 
	CONST_TASK_RAND_MONEY                      = 7,
	-- [8]帮好友上香（次数）  -- 侠客行 
	CONST_TASK_RAND_PRAY                       = 8,
	-- [9]移动  -- 侠客行 
	CONST_TASK_RAND_MOVE                       = 9,
	-- [10]战斗  -- 侠客行 
	CONST_TASK_RAND_WAR                        = 10,
	-- [11]礼物（直接获得奖励）  -- 侠客行 
	CONST_TASK_RAND_GIFT                       = 11,
	-- [12]随机事件  -- 侠客行 
	CONST_TASK_RAND_RANDOM                     = 12,
	-- [13]美人  -- 侠客行 
	CONST_TASK_RAND_MEIREN                     = 13,

	--------------------------------------------------------------------
	-- ( 活动-保卫经书 ) 
	--------------------------------------------------------------------
	-- [0]开始时间-分  -- 活动-保卫经书 
	CONST_DEFEND_BOOK_TIME_SI                  = 0,
	-- [0]开始时间-秒  -- 活动-保卫经书 
	CONST_DEFEND_BOOK_TIME_SS                  = 0,
	-- [21]开始时间-时  -- 活动-保卫经书 
	CONST_DEFEND_BOOK_TIME_SH                  = 21,

	-- [0]结束时间-秒  -- 活动-保卫经书 
	CONST_DEFEND_BOOK_TIME_ES                  = 0,
	-- [21]结束时间-时  -- 活动-保卫经书 
	CONST_DEFEND_BOOK_TIME_EH                  = 21,
	-- [30]可参于活动的玩家等级  -- 活动-保卫经书 
	CONST_DEFEND_BOOK_LIMITS_LV                = 30,
	-- [30]结束时间-分  -- 活动-保卫经书 
	CONST_DEFEND_BOOK_TIME_EI                  = 30,

	-- [10]排行榜上可显示的玩家数  -- 活动-保卫经书 
	CONST_DEFEND_BOOK_RANK_NUM                 = 10,
	-- [100]单个防守圈内玩家个数上限  -- 活动-保卫经书 
	CONST_DEFEND_BOOK_MAX_PLAYERS              = 100,
	-- [8050]目标活动地图ID  -- 活动-保卫经书 
	CONST_DEFEND_BOOK_MAPID                    = 8050,

	-- [0]击杀类型Type--未击杀  -- 活动-保卫经书 
	CONST_DEFEND_BOOK_KILL_TYPE_NO             = 0,
	-- [1]击杀类型Type--击杀  -- 活动-保卫经书 
	CONST_DEFEND_BOOK_KILL_TYPE                = 1,
	-- [2]击杀类型Type--击杀最后一只  -- 活动-保卫经书 
	CONST_DEFEND_BOOK_KILL_TYPE_END            = 2,

	-- [10]杀死最后一只怪物后等待下波怪刷新的时间  -- 活动-保卫经书 
	CONST_DEFEND_BOOK_BRUSH_MONSTER            = 10,
	-- [30]30次金元复活后每次复活消耗金元100个  -- 活动-保卫经书 
	CONST_DEFEND_BOOK_ADDRMB_RELIVE            = 30,
	-- [60]玩家死亡后等待复活的时间（S）  -- 活动-保卫经书 
	CONST_DEFEND_BOOK_RELIVE_TIME              = 60,

	-- [1]X_Y起始值  -- 活动-保卫经书 
	CONST_DEFEND_BOOK_X_Y                      = 1,
	-- [5]每波怪物数量| Y轴最大值  -- 活动-保卫经书 
	CONST_DEFEND_BOOK_MONSTERS_NUM             = 5,
	-- [45]最大格数--X轴  -- 活动-保卫经书 
	CONST_DEFEND_BOOK_X                        = 45,

	-- [1]怪物走一步所用时间（s）  -- 活动-保卫经书 
	CONST_DEFEND_BOOK_TIME_V                   = 1,
	-- [3]子弹冷却时间  -- 活动-保卫经书 
	CONST_DEFEND_BOOK_WAR_BREAK                = 3,
	-- [200]子弹移动的速度  -- 活动-保卫经书 
	CONST_DEFEND_BOOK_BULLET_SPEED             = 200,

	-- [60]物品掉落保留时间(S)  -- 活动-保卫经书 
	CONST_DEFEND_BOOK_SAVE_REWARDS             = 60,

	-- [50000]公式常量-a  -- 活动-保卫经书 
	CONST_DEFEND_BOOK_FORMULE_A                = 50000,

	-- [80]经验奖励常量  -- 活动-保卫经书 
	CONST_DEFEND_BOOK_EXP_REWORD               = 80,
	-- [400]铜钱奖励常量  -- 活动-保卫经书 
	CONST_DEFEND_BOOK_MONEY_REWORD             = 400,

	--------------------------------------------------------------------
	-- ( 促销活动 ) 
	--------------------------------------------------------------------
	-- [1]活动类型--首充礼包  -- 促销活动 
	CONST_SALES_TYPE_PAY_ONCE                  = 1,

	-- [101]活动ID--首充礼包  -- 促销活动 
	CONST_SALES_ID_PAY_ONCE                    = 101,
	-- [201]新手卡  -- 促销活动 
	CONST_SALES_ID_CDKEY                       = 201,
	-- [301]单笔充值  -- 促销活动 
	CONST_SALES_ID_PAY_SINGLE                  = 301,
	-- [401]充值排行  -- 促销活动 
	CONST_SALES_PAY_RANK                       = 401,
	-- [501]消费达人  -- 促销活动 
	CONST_SALES_CONSUMPTION_TOP                = 501,
	-- [502]消费达人2  -- 促销活动 
	CONST_SALES_COST_TWO                       = 502,
	-- [601]每日首充  -- 促销活动 
	CONST_SALES_DAY_ONCE                       = 601,
	-- [701]收集珍宝  -- 促销活动 
	CONST_SALES_COLLECT_TREASURES              = 701,
	-- [801]神器消费  -- 促销活动 
	CONST_SALES_GOD_EQUIP                      = 801,
	-- [802]宝石镶嵌  -- 促销活动 
	CONST_SALES_GEM_SET                        = 802,
	-- [803]坐骑消费  -- 促销活动 
	CONST_SALES_HORSE                          = 803,

	-- [24]充值排行结算时间(单位:小时)  -- 促销活动 
	CONST_SALES_PAY_RANK_TIME                  = 24,

	--------------------------------------------------------------------
	-- ( 人物BUFF ) 
	--------------------------------------------------------------------
	-- [1]洞府Buff ID  -- 人物BUFF 
	CONST_BUFF_CLAN                            = 1,
	-- [2]世界等级Buff ID  -- 人物BUFF 
	CONST_BUFF_WORLD_LV                        = 2,
	-- [3]天宫之战Buff ID  -- 人物BUFF 
	CONST_BUFF_SKY_WAR                         = 3,

	--------------------------------------------------------------------
	-- ( 天宫之战 ) 
	--------------------------------------------------------------------
	-- [9]攻城洞府数  -- 天宫之战 
	CONST_SKYWAR_ATTACK_COUNT                  = 9,
	-- [60]退出重进场景惩罚时间(秒)  -- 天宫之战 
	CONST_SKYWAR_PUNISH_SECOND                 = 60,
	-- [60]复活时间(秒)  -- 天宫之战 
	CONST_SKYWAR_REVIVE_TIME                   = 60,
	-- [5000]定时广播积分数据(毫秒)  -- 天宫之战 
	CONST_SKYWAR_SCORE_BROAD_TIME              = 5000,
	-- [8060]天宫之战地图  -- 天宫之战 
	CONST_SKYWAR_MAPID                         = 8060,
	-- [30000]杀死守城大将缓冲时间(毫秒)  -- 天宫之战 
	CONST_SKYWAR_KILL_BOSS_TIME                = 30000,

	-- [53001]外墙守城BOSS-起始ID  -- 天宫之战 
	CONST_SKYWAR_BOSS_ID_OUT_START             = 53001,
	-- [53100]外墙守城BOSS-结束ID  -- 天宫之战 
	CONST_SKYWAR_BOSS_ID_OUT_END               = 53100,

	-- [53501]内墙守城boss-开始ID  -- 天宫之战 
	CONST_SKYWAR_BOSS_ID_IN_START              = 53501,
	-- [53600]内墙守城boss-结束ID  -- 天宫之战 
	CONST_SKYWAR_BOSS_ID_IN_END                = 53600,

	-- [1]个人奖励-帮贡常量  -- 天宫之战 
	CONST_SKYWAR_REWORD_CONTRIBUTION           = 1,
	-- [4]失败积分常量  -- 天宫之战 
	CONST_SKYWAR_FAIL_INTEGRAL                 = 4,
	-- [7]BOSS积分常量  -- 天宫之战 
	CONST_SKYWAR_INTEGRAL_BOSS                 = 7,
	-- [10]胜利积分常量  -- 天宫之战 
	CONST_SKYWAR_INTEGRAL                      = 10,
	-- [1000]个人奖励-银元常量  -- 天宫之战 
	CONST_SKYWAR_REWORD_MONEY                  = 1000,
	-- [2000]个人奖励-经验常量  -- 天宫之战 
	CONST_SKYWAR_REWORD_EXP                    = 2000,
	-- [3000]炸弹伤害常量  -- 天宫之战 
	CONST_SKYWAR_BOMB_HARM                     = 3000,
	-- [10000]伤害常量  -- 天宫之战 
	CONST_SKYWAR_INTEGRAL_BURN                 = 10000,

	-- [1]阵营--攻城方  -- 天宫之战 
	CONST_SKYWAR_CAMP_ATTACK                   = 1,
	-- [2]阵营--守城方  -- 天宫之战 
	CONST_SKYWAR_CAMP_DEFEND                   = 2,

	-- [1]城墙--外墙  -- 天宫之战 
	CONST_SKYWAR_WALL_OUT                      = 1,
	-- [2]城墙--内墙  -- 天宫之战 
	CONST_SKYWAR_WALL_IN                       = 2,

	-- [5000]天宫之战守城经验奖励  -- 天宫之战 
	CONST_SKYWAR_HOLD_EXPREWARD                = 5000,
	-- [5000]天宫之战守城银元奖励  -- 天宫之战 
	CONST_SKYWAR_HOLD_MONEY                    = 5000,

	--------------------------------------------------------------------
	-- ( 挑战镜像(年兽) ) 
	--------------------------------------------------------------------
	-- [12000]怪物提升百分比-120%  -- 挑战镜像(年兽) 
	CONST_MIRROR_ATTR_UP_TWO                   = 12000,

	-- [11000]怪物提升百分比-110%  -- 挑战镜像(年兽) 
	CONST_MIRROR_ATTR_UP_ONE                   = 11000,

	-- [1]基础经验奖励  -- 挑战镜像(年兽) 
	CONST_MIRROR_BASE_EXP                      = 1,
	-- [100]基础战斗力  -- 挑战镜像(年兽) 
	CONST_MIRROR_BASE_POWER                    = 100,
	-- [200]基础银元奖励  -- 挑战镜像(年兽) 
	CONST_MIRROR_BASE_MONEY                    = 200,

	--------------------------------------------------------------------
	-- ( 活动-钓鱼达人 ) 
	--------------------------------------------------------------------
	-- [300]钓一条鱼需花费的时间  -- 活动-钓鱼达人 
	CONST_FISHING_FISH_TIME_ONE                = 300,
	-- [1800]每场钓鱼共需花费的时间（s）  -- 活动-钓鱼达人 
	CONST_FISHING_FISH_TIME_MAX                = 1800,

	-- [50]可参于活动的玩家等级  -- 活动-钓鱼达人 
	CONST_FISHING_LIMITS_LV                    = 50,
	-- [300]钓鱼需花费的银元数（万）  -- 活动-钓鱼达人 
	CONST_FISHING_CAST_GOLD                    = 300,

	-- [0]一键收取  -- 活动-钓鱼达人 
	CONST_FISHING_ALL_FISH                     = 0,
	-- [1]鱼品阶--绿  -- 活动-钓鱼达人 
	CONST_FISHING_GREEN_FISH                   = 1,
	-- [2]鱼品阶--蓝  -- 活动-钓鱼达人 
	CONST_FISHING_BLUE_FISH                    = 2,
	-- [3]鱼品阶--紫  -- 活动-钓鱼达人 
	CONST_FISHING_PURPLE_FISH                  = 3,
	-- [4]鱼品阶--金  -- 活动-钓鱼达人 
	CONST_FISHING_GOLD_FISH                    = 4,

	--------------------------------------------------------------------
	-- ( 活动-龙宫寻宝 ) 
	--------------------------------------------------------------------
	-- [2]寻宝VIP等级限制-一  -- 活动-龙宫寻宝 
	CONST_DRAGON_LIMITS_VIP_ONE                = 2,
	-- [5]寻宝VIP等级限制-二  -- 活动-龙宫寻宝 
	CONST_DRAGON_LIMITS_VIP_TWO                = 5,
	-- [8]寻宝VIP等级限制-三  -- 活动-龙宫寻宝 
	CONST_DRAGON_LIMITS_VIP_THREE              = 8,

	-- [1]一键寻宝次数限制-一  -- 活动-龙宫寻宝 
	CONST_DRAGON_TIMES_ONE                     = 1,
	-- [10]一键寻宝次数限制-二  -- 活动-龙宫寻宝 
	CONST_DRAGON_TIMES_TWO                     = 10,
	-- [50]一键寻宝次数限制-三  -- 活动-龙宫寻宝 
	CONST_DRAGON_TIMES_THREE                   = 50,
	-- [99]一键寻宝次数限制-最大次数  -- 活动-龙宫寻宝 
	CONST_DRAGON_TIMES_MAX                     = 99,

	-- [47006]寻宝令物品ID  -- 活动-龙宫寻宝 
	CONST_DRAGON_TREASURE_ID                   = 47006,

	-- [10]一次寻宝需花费的Rmb  -- 活动-龙宫寻宝 
	CONST_DRAGON_RMB                           = 10,

	-- [30]可参加活动的等级限制  -- 活动-龙宫寻宝 
	CONST_DRAGON_LIMITS_LV                     = 30,

	--------------------------------------------------------------------
	-- ( 问鼎天宫 ) 
	--------------------------------------------------------------------
	-- [9]自动报名VIP等级-9  -- 问鼎天宫 
	CONST_OVER_SERVER_AUTO_APPLY               = 9,
	-- [10]跨服战匹配人数--10  -- 问鼎天宫 
	CONST_OVER_SERVER_ROLE_SUM_18              = 10,
	-- [12]跨服战匹配人数-12  -- 问鼎天宫 
	CONST_OVER_SERVER_ROLE_SUM_12              = 12,
	-- [52]跨服战参加等级-65  -- 问鼎天宫 
	CONST_OVER_SERVER_JOIN_LV                  = 52,

	-- [10]跨服战战斗次数  -- 问鼎天宫 
	CONST_OVER_SERVER_BATTLE_TIMES             = 10,
	-- [12]跨服战增加战斗次数-10  -- 问鼎天宫 
	CONST_OVER_SERVER_ADD_TIMES                = 12,

	-- [10]决战凌霄挑战人数 -- 问鼎天宫 
	CONST_OVER_SERVER_FINAL_NUM                = 10,
	-- [10]决战凌霄增加战斗次数  -- 问鼎天宫 
	CONST_OVER_SERVER_FINAL_ADD_TIMES          = 10,
	-- [10]挑战购买价格-决战凌霄  -- 问鼎天宫 
	CONST_OVER_SERVER_BUY_PRICE2               = 10,
	-- [10]挑战购买价格-问鼎天宫  -- 问鼎天宫 
	CONST_OVER_SERVER_BUY_PRICE                = 10,
	-- [10]决战凌霄战斗次数  -- 问鼎天宫 
	CONST_OVER_SERVER_FINAL_TIMES              = 10,
	-- [200]购买越级挑战  -- 问鼎天宫 
	CONST_OVER_SERVER_BUY_YSTRIDE              = 200,

	-- [24]称号持续时间-24小时  -- 问鼎天宫 
	CONST_OVER_SERVER_TITLE_LAST               = 24,

	-- [1]跨服数据类型--挑战信息  -- 问鼎天宫 
	CONST_OVER_SERVER_STRIDE_TYPR_1            = 1,
	-- [2]跨服数据类型--问鼎天宫榜  -- 问鼎天宫 
	CONST_OVER_SERVER_STRIDE_TYPE_2            = 2,
	-- [3]跨服数据类型--决战凌霄榜  -- 问鼎天宫 
	CONST_OVER_SERVER_STRIDE_TYPE_3            = 3,
	-- [4]跨服数据类型--决战凌霄挑战信息  -- 问鼎天宫 
	CONST_OVER_SERVER_STRIDE_TYPE_4            = 4,
	-- [5]跨服数据类型--问鼎天宫挑战信息  -- 问鼎天宫 
	CONST_OVER_SERVER_STRIDE_TYPE_5            = 5,
	-- [6]跨服数据类型--越级挑战信息  -- 问鼎天宫 
	CONST_OVER_SERVER_STRIDE_TYPE_6            = 6,

	-- [1]跨服挑战类型--问鼎天宫常规挑战  -- 问鼎天宫 
	CONST_OVER_SERVER_WAR_1                    = 1,
	-- [2]跨服挑战类型--问鼎天宫越级挑战  -- 问鼎天宫 
	CONST_OVER_SERVER_WAR_2                    = 2,
	-- [3]跨服挑战类型--决战凌霄挑战  -- 问鼎天宫 
	CONST_OVER_SERVER_WAR_3                    = 3,

	-- [1]跨服分组--新手组  -- 问鼎天宫 
	CONST_OVER_SERVER_GROUP_1                  = 1,
	-- [2]跨服分组--青铜组  -- 问鼎天宫 
	CONST_OVER_SERVER_GROUP_2                  = 2,
	-- [3]跨服分组--白银组  -- 问鼎天宫 
	CONST_OVER_SERVER_GROUP_3                  = 3,
	-- [4]跨服分组--黄金组  -- 问鼎天宫 
	CONST_OVER_SERVER_GROUP_4                  = 4,
	-- [5]跨服分组--钻石组  -- 问鼎天宫 
	CONST_OVER_SERVER_GROUP_5                  = 5,
	-- [6]跨服分组--大师组  -- 问鼎天宫 
	CONST_OVER_SERVER_GROUP_6                  = 6,
	-- [7]跨服分组--宗师组  -- 问鼎天宫 
	CONST_OVER_SERVER_GROUP_7                  = 7,

	-- [1]跨服常规挑战层--1层  -- 问鼎天宫 
	CONST_OVER_SERVER_CENCI_1                  = 1,
	-- [2]跨服常规挑战层--2层  -- 问鼎天宫 
	CONST_OVER_SERVER_CENCI_2                  = 2,
	-- [3]跨服常规挑战层--3层  -- 问鼎天宫 
	CONST_OVER_SERVER_CENCI_3                  = 3,
	-- [4]跨服常规挑战层--4层  -- 问鼎天宫 
	CONST_OVER_SERVER_CENCI_4                  = 4,
	-- [5]跨服常规挑战层--5层  -- 问鼎天宫 
	CONST_OVER_SERVER_CENCI_5                  = 5,
	-- [6]跨服常规挑战层--6层  -- 问鼎天宫 
	CONST_OVER_SERVER_CENCI_6                  = 6,

	-- [1]跨服称号--黄金虎卫  -- 问鼎天宫 
	CONST_OVER_SERVER_TITLE_1                  = 1,
	-- [2]跨服称号--玄武圣骑  -- 问鼎天宫 
	CONST_OVER_SERVER_TITLE_2                  = 2,
	-- [3]跨服称号--朱雀圣骑  -- 问鼎天宫 
	CONST_OVER_SERVER_TITLE_3                  = 3,
	-- [4]跨服称号--青龙圣卫  -- 问鼎天宫 
	CONST_OVER_SERVER_TITLE_4                  = 4,

	-- [1]免费许愿次数  -- 问鼎天宫 
	CONST_OVER_SERVER_FREE_WISH                = 1,
	-- [5]许愿获得物品个数  -- 问鼎天宫 
	CONST_OVER_SERVER_GET_COUNT                = 5,
	-- [10]许愿消耗元宝  -- 问鼎天宫 
	CONST_OVER_SERVER_WISH_USE                 = 10,
	-- [50]天地榜显示人数  -- 问鼎天宫 
	CONST_OVER_SERVER_RANK_NUM                 = 50,
	-- [47001]许愿获得物品  -- 问鼎天宫 
	CONST_OVER_SERVER_WISH_GET                 = 47001,

	-- [1]数据刷新时间(小时) -- 问鼎天宫 
	CONST_OVER_SERVER_REFRESH                  = 1,

	-- [60145]决战凌霄场景ID -- 问鼎天宫 
	CONST_OVER_SERVER_QUNYING_ID               = 60145,
	-- [60150]问鼎天宫场景ID -- 问鼎天宫 
	CONST_OVER_SERVER_PEAK_ID                  = 60150,

	--------------------------------------------------------------------
	-- ( 御前科举 ) 
	--------------------------------------------------------------------
	-- [2]每周可参与次数 -- 御前科举 
	CONST_KEJU_WEEK_TIME                       = 2,
	-- [3]算卦剩余次数 -- 御前科举 
	CONST_KEJU_PUGUA_TIME                      = 3,
	-- [3]贿赂剩余次数 -- 御前科举 
	CONST_KEJU_HUILU_TIME                      = 3,
	-- [10]算卦消耗元宝 -- 御前科举 
	CONST_KEJU_PUGUA                           = 10,
	-- [15]排名显示人数 -- 御前科举 
	CONST_KEJU_PAIM                            = 15,
	-- [15]考试时间 -- 御前科举 
	CONST_KEJU_TEST_TIME                       = 15,
	-- [30]考试题目数量 -- 御前科举 
	CONST_KEJU_TEST_THING                      = 30,
	-- [50]贿赂消耗元宝 -- 御前科举 
	CONST_KEJU_HUILU                           = 50,

	--------------------------------------------------------------------
	-- ( 活动-阵营战 ) 
	--------------------------------------------------------------------
	-- [1]阵营类型--游龙图  -- 活动-阵营战 
	CONST_CAMPWAR_TYPE_HUMAN                   = 1,
	-- [2]阵营类型--御仙图  -- 活动-阵营战 
	CONST_CAMPWAR_TYPE_FAIRY                   = 2,
	-- [3]阵营类型--惊刹图  -- 活动-阵营战 
	CONST_CAMPWAR_TYPE_MAGIC                   = 3,

	-- [1]倒计时类型--提前入场倒计时  -- 活动-阵营战 
	CONST_CAMPWAR_TIMETYPE_BEFORE              = 1,
	-- [2]倒计时类型--战后整顿  -- 活动-阵营战 
	CONST_CAMPWAR_TIMETYPE_WAR_AFTER           = 2,
	-- [3]倒计时类型--匹配中  -- 活动-阵营战 
	CONST_CAMPWAR_TIMETYPE_MATCHING            = 3,

	-- [30]阵营战开放等级  -- 活动-阵营战 
	CONST_CAMPWAR_LIMITS_LV                    = 30,

	-- [10]计时器--战后整顿时间（s）  -- 活动-阵营战 
	CONST_CAMPWAR_TIME_BATTLE                  = 10,
	-- [30]计时器--匹配战斗时长（s)  -- 活动-阵营战 
	CONST_CAMPWAR_TIME_MATCHING                = 30,
	-- [1800]计时器--活动总时长(s)  -- 活动-阵营战 
	CONST_CAMPWAR_TIME_ALL                     = 1800,

	-- [3]连胜排行榜玩家数量  -- 活动-阵营战 
	CONST_CAMPWAR_WINS_COUNT                   = 3,

	-- [0]战报类型--匹配失败  -- 活动-阵营战 
	CONST_CAMPWAR_TYPE_NOWAR                   = 0,
	-- [1]战报类型--匹配成功  -- 活动-阵营战 
	CONST_CAMPWAR_TYPE_WAR                     = 1,

	-- [0]个人战报数据  -- 活动-阵营战 
	CONST_CAMPWAR_WARDATA_TYPE_SELF            = 0,
	-- [1]所有战报数据  -- 活动-阵营战 
	CONST_CAMPWAR_WARDATA_TYPE_ALL             = 1,

	-- [20]战报数量--个人战报  -- 活动-阵营战 
	CONST_CAMPWAR_MSG_SELF                     = 20,
	-- [30]战报数量--全体战报  -- 活动-阵营战 
	CONST_CAMPWAR_MSG_ALL                      = 30,

	--------------------------------------------------------------------
	-- ( 公共数据表KEY值 ) 
	--------------------------------------------------------------------
	-- [1001]活动-阵营战  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_CAMPWAR                   = 1001,
	-- [1002]活动-保卫经书  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_DEFENDBOOK                = 1002,
	-- [1003]活动-御前科举  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_YKEJU                     = 1003,

	-- [2001]功能-洞府  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_CLANLIST_PAGE             = 2001,
	-- [2002]功能-藏宝阁  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_TREASURE                  = 2002,
	-- [2003]功能-精力  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_ENERGY                    = 2003,
	-- [2004]功能-活动界面状态数据  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_ALL_ACTIVE                = 2004,
	-- [2005]功能-活动配置数据暂存  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_ACTIVE_CONFIG             = 2005,
	-- [2006]功能-每日一箭  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_KEY_SHOOT                 = 2006,
	-- [2007]功能-功能开放控制  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_FUNS_STATE                = 2007,
	-- [2008]功能-称号数据  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_TITLE                     = 2008,
	-- [2009]功能-系统竞拍  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_AUCTION                   = 2009,
	-- [2010]功能-每日转盘  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_WHEEL                     = 2010,
	-- [2011]功能-全民寻宝  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_ALLFIND                   = 2011,
	-- [2012]功能-封神榜  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_EXPEDIT                   = 2012,
	-- [2013]功能-签到抽奖  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_SIGN                      = 2013,
	-- [2014]功能-洞府守卫战  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_CLAN_DEFENSE              = 2014,

	-- [3001]商店-打折商店  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_MALL                      = 3001,
	-- [5001]限时团购1  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_TIME_MALL                 = 5001,
	-- [5002]限时团购2  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_TIME_MALL2                = 5002,

	-- [4001]天下第一-上半区  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_SHANGBANQU                = 4001,
	-- [4002]天下第一-下半区  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_XIABANQU                  = 4002,
	-- [4003]天下第一-所有对战UID  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_TXDY_UIDS                 = 4003,
	-- [4005]天下第一-活动状态控制  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_TXDY_ACTIVE               = 4005,
	-- [4006]天下第一-欢乐竞猜奖池  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_TXDY_ALL_PEBBLE           = 4006,
	-- [4007]天下第一-王者争霸状态  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_TXDY_KING_STATE           = 4007,

	-- [6001]开服七日次数  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_OPEN                      = 6001,
	-- [6002]七天抽奖  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_SEVEN_SIGN                = 6002,
	-- [6003]基金时间  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_PRIVILEGE                 = 6003,
	-- [6004]节日转盘  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_GALATURN                  = 6004,

	-- [7001]跨服天下第一-时间  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_TXDY_SUPER_TIME           = 7001,
	-- [7002]跨服天下第一-所以对战Uid  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_TXDY_SUPER_UID            = 7002,
	-- [7003]跨服天下第一-王者争霸状态  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_TXDY_SUPER_KING           = 7003,
	-- [7004]跨服天下第一-欢乐竞猜总金额  -- 公共数据表KEY值 
	CONST_PUBLIC_KEY_TXDY_SUPER_ALL_PEBBLE     = 7004,

	--------------------------------------------------------------------
	-- ( 战斗相关 ) 
	--------------------------------------------------------------------
	-- [1]站立  -- 战斗相关 
	CONST_BATTLE_STATUS_IDLE                   = 1,
	-- [2]移动  -- 战斗相关 
	CONST_BATTLE_STATUS_MOVE                   = 2,
	-- [3]受击  -- 战斗相关 
	CONST_BATTLE_STATUS_HURT                   = 3,
	-- [4]倒地  -- 战斗相关 
	CONST_BATTLE_STATUS_FALL                   = 4,
	-- [5]击飞  -- 战斗相关 
	CONST_BATTLE_STATUS_CRASH                  = 5,
	-- [6]跳跃  -- 战斗相关 
	CONST_BATTLE_STATUS_JUMP                   = 6,
	-- [7]跳跃普通攻击  -- 战斗相关 
	CONST_BATTLE_STATUS_JUMPATTACK             = 7,
	-- [8]死亡  -- 战斗相关 
	CONST_BATTLE_STATUS_DEAD                   = 8,
	-- [9]使用技能力  -- 战斗相关 
	CONST_BATTLE_STATUS_USESKILL               = 9,
	-- [10]受击2  -- 战斗相关 
	CONST_BATTLE_STATUS_HURTED                 = 10,
	-- [11]技能预备动作 -- 战斗相关 
	CONST_BATTLE_STATUS_PREUSESKILL            = 11,

	-- [1]自身推力  -- 战斗相关 
	CONST_BATTLE_BUFF_THRUST                   = 1,
	-- [1.8]人物死亡动画时间  -- 战斗相关 
	CONST_BATTLE_DIE                           = 1.8,
	-- [2]沉默  -- 战斗相关 
	CONST_BATTLE_BUFF_BEATBACK                 = 2,
	-- [3]霸体  -- 战斗相关 
	CONST_BATTLE_BUFF_ENDUCE                   = 3,
	-- [4]无敌  -- 战斗相关 
	CONST_BATTLE_BUFF_INVINCIBLE               = 4,
	-- [5]锁定X  -- 战斗相关 
	CONST_BATTLE_BUFF_LOCKX                    = 5,
	-- [6]锁定Y  -- 战斗相关 
	CONST_BATTLE_BUFF_LOCKY                    = 6,
	-- [7]锁定Z  -- 战斗相关 
	CONST_BATTLE_BUFF_LOCKZ                    = 7,
	-- [8]使目标僵值,受击  -- 战斗相关 
	CONST_BATTLE_BUFF_RIGIDITY                 = 8,
	-- [9]使目标击飞  -- 战斗相关 
	CONST_BATTLE_BUFF_CRASH                    = 9,
	-- [10]自身速度加成  -- 战斗相关 
	CONST_BATTLE_BUFF_SPEEDADD                 = 10,
	-- [11]倒地掉落  -- 战斗相关 
	CONST_BATTLE_BUFF_FALL                     = 11,
	-- [12]冲刺 只作标识用  -- 战斗相关 
	CONST_BATTLE_BUFF_SPRINT                   = 12,
	-- [13]震动屏幕  -- 战斗相关 
	CONST_BATTLE_BUFF_VIBRATE                  = 13,
	-- [14]永久霸体  -- 战斗相关 
	CONST_BATTLE_BUFF_ENDUCE_FOREVER           = 14,
	-- [15]悬空  -- 战斗相关 
	CONST_BATTLE_BUFF_HANGIN                   = 15,
	-- [16]冰冻  -- 战斗相关 
	CONST_BATTLE_BUFF_FROZEN                   = 16,
	-- [17]中毒  -- 战斗相关 
	CONST_BATTLE_BUFF_POISON                   = 17,
	-- [18]眩晕  -- 战斗相关 
	CONST_BATTLE_BUFF_DIZZY                    = 18,
	-- [19]烧伤  -- 战斗相关 
	CONST_BATTLE_BUFF_BURN                     = 19,
	-- [20]流血状态  -- 战斗相关 
	CONST_BATTLE_BUFF_BLEED                    = 20,
	-- [21]聚怪  -- 战斗相关 
	CONST_BATTLE_BUFF_GATHER                   = 21,
	-- [22]闪屏屏幕  -- 战斗相关 
	CONST_BATTLE_BUFF_SPLASH                   = 22,
	-- [23]加属性 -- 战斗相关 
	CONST_BATTLE_BUFF_ADD                      = 23,
	-- [24]加减速 -- 战斗相关 
	CONST_BATTLE_BUFF_SPEED                    = 24,
	-- [25]变大小 -- 战斗相关 
	CONST_BATTLE_BUFF_VARY                     = 25,
	-- [26]加减速 -- 战斗相关 
	CONST_BATTLE_BUFF_DISPEL                   = 26,
	-- [27]减属性 -- 战斗相关 
	CONST_BATTLE_BUFF_MINUS                    = 27,
	-- [28]回血 -- 战斗相关 
	CONST_BATTLE_BUFF_RENEW                    = 28,
	-- [29]隐身 -- 战斗相关 
	CONST_BATTLE_BUFF_STEALTH                  = 29,
	-- [30]分身 -- 战斗相关 
	CONST_BATTLE_BUFF_CLONE                    = 30,
	-- [31]黑屏 -- 战斗相关 
	CONST_BATTLE_BUFF_BLACK                    = 31,
	-- [32]慢动作 -- 战斗相关 
	CONST_BATTLE_BUFF_SLOW                     = 32,
	-- [33]动作暂停 -- 战斗相关 
	CONST_BATTLE_BUFF_STOP                     = 33,
	-- [34]命令 -- 战斗相关 
	CONST_BATTLE_BUFF_COMMAND                  = 34,
	-- [35]护盾（集合buff） -- 战斗相关 
	CONST_BATTLE_BUFF_SHIELD                   = 35,
	-- [36]不死 -- 战斗相关 
	CONST_BATTLE_BUFF_UNDEAD                   = 36,
	-- [37]显示特效 -- 战斗相关 
	CONST_BATTLE_BUFF_EFFECT_DISPLAY           = 37,
	-- [38]隐藏特效 -- 战斗相关 
	CONST_BATTLE_BUFF_EFFECT_HIDDEN            = 38,
	-- [39]技能移动 -- 战斗相关 
	CONST_BATTLE_BUFF_SKILL_MOVE               = 39,
	-- [40]暂停动作 -- 战斗相关 
	CONST_BATTLE_BUFF_STOP_ACTION              = 40,
	-- [41]闪避无敌 -- 战斗相关 
	CONST_BATTLE_BUFF_DODGE                    = 41,

	-- [1000]跳跃推力  -- 战斗相关 
	CONST_BATTLE_JUMP_THRUST                   = 1000,
	-- [2500]跳跃加速度  -- 战斗相关 
	CONST_BATTLE_JUMP_ACCELERATION             = 2500,

	-- [0.1]战斗公式常量-E  -- 战斗相关 
	CONST_BATTLE_FORMULA_E                     = 0.1,
	-- [0.1]战斗公式常量-F  -- 战斗相关 
	CONST_BATTLE_FORMULA_F                     = 0.1,
	-- [1]战斗公式常量-b  -- 战斗相关 
	CONST_BATTLE_FORMULA_B                     = 1,
	-- [1]战斗公式常量-a  -- 战斗相关 
	CONST_BATTLE_FORMULA_A                     = 1,
	-- [1.5]战斗公式常量-C  -- 战斗相关 
	CONST_BATTLE_FORMULA_C                     = 1.5,
	-- [1.5]战斗公式常量-D  -- 战斗相关 
	CONST_BATTLE_FORMULA_D                     = 1.5,

	-- [3]有效连击时间(秒)  -- 战斗相关 
	CONST_BATTLE_COMBO_TIME                    = 3,

	-- [1]攻击命中回怒气数  -- 战斗相关 
	CONST_BATTLE_HIT_ADD_MP                    = 1,
	-- [1]被攻击命中回怒气数  -- 战斗相关 
	CONST_BATTLE_HURT_ADD_MP                   = 1,
	-- [5]每秒回蓝点数  -- 战斗相关 
	CONST_BATTLE_ADD_SP_SPEED                  = 5,
	-- [100]初始怒气数  -- 战斗相关 
	CONST_BATTLE_START_MP                      = 100,
	-- [100]最大怒气数  -- 战斗相关 
	CONST_BATTLE_MAX_MP                        = 100,

	-- [-110]飞起时弹起角度  -- 战斗相关 
	CONST_BATTLE_FLY_ANGLE                     = -110,
	-- [-110]站立死亡时弹起角度  -- 战斗相关 
	CONST_BATTLE_DEAD_ANGLE                    = -110,
	-- [550]飞起时弹起速度  -- 战斗相关 
	CONST_BATTLE_FLY_SPEED                     = 550,
	-- [713]站立死亡时弹起速度  -- 战斗相关 
	CONST_BATTLE_DEAD_SPEED                    = 713,
	-- [2800]飞起时弹起的加速度  -- 战斗相关 
	CONST_BATTLE_FLY_ACCELERATION              = 2800,
	-- [2800]站立死亡时弹起的加速度  -- 战斗相关 
	CONST_BATTLE_DEAD_ACCELERATION             = 2800,

	-- [1]飞行物穿透碰撞  -- 战斗相关 
	CONST_BATTLE_FLYCOLLIDER_1                 = 1,
	-- [2]飞行物单次碰撞  -- 战斗相关 
	CONST_BATTLE_FLYCOLLIDER_2                 = 2,

	-- [1]怪物随机-原地不动  -- 战斗相关 
	CONST_BATTLE_RAND_TYPE_1                   = 1,
	-- [2]怪物随机-左右移动  -- 战斗相关 
	CONST_BATTLE_RAND_TYPE_2                   = 2,
	-- [3]怪物随机-上下移动  -- 战斗相关 
	CONST_BATTLE_RAND_TYPE_3                   = 3,
	-- [4]怪物移动-范围移动  -- 战斗相关 
	CONST_BATTLE_RAND_TYPE_4                   = 4,

	-- [0.33]击杀boss慢镜头放慢倍数  -- 战斗相关 
	CONST_BATTLE_END_SHOWDOWN                  = 0.33,
	-- [1.2]击杀boss慢镜头放慢时间  -- 战斗相关 
	CONST_BATTLE_END_SHOWTIME                  = 1.2,

	-- [2]秘宝活动人物增加血量倍数  -- 战斗相关 
	CONST_BATTLE_MIBAO_BOSS_HP                 = 2,
	-- [6]城镇boss人物增加血量倍数  -- 战斗相关 
	CONST_BATTLE_CITY_BOSS_HP                  = 6,

	-- [4]普攻次数 -- 战斗相关 
	CONST_BATTLE_SKILL_NONE_NUM                = 4,

	--------------------------------------------------------------------
	-- ( 前端人物初始化相关 ) 
	--------------------------------------------------------------------
	-- [0.5]移动回调时间-发送服务端  -- 前端人物初始化相关 
	CONST_INIT_MOVE_CALL_BACK_TIME             = 0.5,
	-- [1]初始人物碰撞ID  -- 前端人物初始化相关 
	CONST_INIT_COLLIDER_ID                     = 1,

	-- [60]Y速度小夹角  -- 前端人物初始化相关 
	CONST_INIT_Y_ANGLE_MIN                     = 60,
	-- [120]Y速度大夹角  -- 前端人物初始化相关 
	CONST_INIT_Y_ANGLE_MAX                     = 120,
	-- [200]Y基础速度  -- 前端人物初始化相关 
	CONST_INIT_MOVE_Y_SPEED                    = 200,
	-- [500]X基础速度  -- 前端人物初始化相关 
	CONST_INIT_MOVE_X_SPEED                    = 500,

	--------------------------------------------------------------------
	-- ( 提示界面 ) 
	--------------------------------------------------------------------
	-- [1]批量招财  -- 提示界面 
	CONST_CUE_CHANGE                           = 1,
	-- [2]钻石领悟  -- 提示界面 
	CONST_CUE_FIGHTGAS                         = 2,

	--------------------------------------------------------------------
	-- ( 珍宝系统 ) 
	--------------------------------------------------------------------
	-- [100]珍宝阁  -- 珍宝系统 
	CONST_TREASURE_DIFFERENCE                  = 100,
	-- [3600]倒计时为0  -- 珍宝系统 
	CONST_TREASURE_ZERO                        = 3600,
	-- [3600]商店定时刷新时间  -- 珍宝系统 
	CONST_TREASURE_STORE_TREASURE_TIME         = 3600,
	-- [80000]商店刷新铜钱  -- 珍宝系统 
	CONST_TREASURE_STORE_REFRESH_RMB           = 80000,

	-- [0]VIP6增加一键制作功能  -- 珍宝系统 
	CONST_TREASURE_ONCE_MAKE_VIP               = 0,

	-- [50]珍宝第二层开放等级  -- 珍宝系统 
	CONST_TREASURE_OPEN_SECOND                 = 50,
	-- [70]珍宝第三层开放等级  -- 珍宝系统 
	CONST_TREASURE_OPEN_THIRD                  = 70,
	-- [80]珍宝第七层开放等级  -- 珍宝系统 
	CONST_TREASURE_OPEN_SEVEN                  = 80,
	-- [85]珍宝第八层开放等级  -- 珍宝系统 
	CONST_TREASURE_OPEN_EIGHT                  = 85,
	-- [90]珍宝第九层开放等级  -- 珍宝系统 
	CONST_TREASURE_OPEN_NIGHT                  = 90,
	-- [90]珍宝第四层开放等级  -- 珍宝系统 
	CONST_TREASURE_OPEN_FOUR                   = 90,
	-- [95]珍宝第十层开放等级  -- 珍宝系统 
	CONST_TREASURE_OPEN_TEN                    = 95,
	-- [110]珍宝第五层开放等级  -- 珍宝系统 
	CONST_TREASURE_OPEN_FIVE                   = 110,
	-- [130]珍宝第六层开放等级  -- 珍宝系统 
	CONST_TREASURE_OPEN_SIX                    = 130,

	-- [6]珍宝开放最高层数  -- 珍宝系统 
	CONST_TREASURE_OPEN_MAX_LEVEL              = 6,

	--------------------------------------------------------------------
	-- ( 八卦系统 ) 
	--------------------------------------------------------------------
	-- [0]一键领悟所需的vip等级  -- 八卦系统 
	CONST_DOUQI_ONEKEY_VIP                     = 0,
	-- [0]每日免费领悟次数  -- 八卦系统 
	CONST_DOUQI_FREE_TIMES                     = 0,
	-- [1]开启金元领悟需要的VIP等级  -- 八卦系统 
	CONST_DOUQI_VIP_LIMIT                      = 1,
	-- [4]可分解的卦象颜色等级限制  -- 八卦系统 
	CONST_DOUQI_SPLIT_COLOR                    = 4,
	-- [101]铜钱最小领悟等级  -- 八卦系统 
	CONST_DOUQI_MIN_GRASP_LV                   = 101,
	-- [105]铜钱最大领悟等级  -- 八卦系统 
	CONST_DOUQI_MAX_GRASP_LV                   = 105,
	-- [106]钻石领悟等级  -- 八卦系统 
	CONST_DOUQI_RMB_GRASP_LV                   = 106,

	-- [0]领悟仓库类型 0  -- 八卦系统 
	CONST_DOUQI_TYPE_STORAGE                   = 0,
	-- [1]装备仓库类型 1  -- 八卦系统 
	CONST_DOUQI_TYPE_BAG                       = 1,
	-- [10]装备栏个数  -- 八卦系统 
	CONST_DOUQI_DQLAN_NUM                      = 10,
	-- [16]领悟仓格子数  -- 八卦系统 
	CONST_DOUQI_STORAGE_NUM                    = 16,
	-- [16]装备仓格子数  -- 八卦系统 
	CONST_DOUQI_BAG                            = 16,

	-- [1]卦象装备栏编号--开始  -- 八卦系统 
	CONST_DOUQI_LAN_START                      = 1,
	-- [8]卦象装备栏编号--结束  -- 八卦系统 
	CONST_DOUQI_LAN_END                        = 8,
	-- [9]装备仓格子编号--开始  -- 八卦系统 
	CONST_DOUQI_BAG_START                      = 9,
	-- [25]装备仓格子编号--结束  -- 八卦系统 
	CONST_DOUQI_BAG_END                        = 25,
	-- [26]领悟仓格子编号--开始  -- 八卦系统 
	CONST_DOUQI_STORAGE_START                  = 26,
	-- [42]领悟仓格子编号--结束  -- 八卦系统 
	CONST_DOUQI_STORAGE_END                    = 42,
	-- [60]神卦象装备栏编号--开始  -- 八卦系统 
	CONST_DOUQI_GOD_START                      = 60,
	-- [61]神卦象装备栏编号--结束  -- 八卦系统 
	CONST_DOUQI_GOD_END                        = 61,

	-- [0]仓库类型--领悟仓  -- 八卦系统 
	CONST_DOUQI_STORAGE_TYPE_TEMP              = 0,
	-- [1]仓库类型--装备仓  -- 八卦系统 
	CONST_DOUQI_STORAGE_TYPE_EQUIP             = 1,
	-- [2]仓库类型--人物仓  -- 八卦系统 
	CONST_DOUQI_STORAGE_TYPE_ROLE              = 2,

	-- [0]领悟方式--钻石领悟  -- 八卦系统 
	CONST_DOUQI_GRASP_TYPE_RMB                 = 0,
	-- [1]领悟方式--铜钱领悟  -- 八卦系统 
	CONST_DOUQI_GRASP_TYPE_GOLD                = 1,
	-- [2]领悟方式--铜钱一键领悟  -- 八卦系统 
	CONST_DOUQI_GRASP_TYPE_MORE                = 2,

	--------------------------------------------------------------------
	-- ( 充值类活动 ) 
	--------------------------------------------------------------------
	-- [101]首充活动ID  -- 充值类活动 
	CONST_RECHARGE_SALES_FIRST_PREPAID         = 101,

	--------------------------------------------------------------------
	-- ( 日常任务 ) 
	--------------------------------------------------------------------
	-- [0]这一轮任务为0  -- 日常任务 
	CONST_TASK_DAILY_SETZERO                   = 0,
	-- [0]任务初始值  -- 日常任务 
	CONST_TASK_DAILY_INITVALUE                 = 0,
	-- [0]日常任务清零  -- 日常任务 
	CONST_TASK_DAILY_ZERO                      = 0,
	-- [0]任务刷新次数清零  -- 日常任务 
	CONST_TASK_DAILY_VIPZERO                   = 0,
	-- [1]强化装备  -- 日常任务 
	CONST_TASK_DAILY_STRENGTH_EQUIP            = 1,
	-- [2]刷副本  -- 日常任务 
	CONST_TASK_DAILY_REFRESH_COPY              = 2,
	-- [3]领悟卦象  -- 日常任务 
	CONST_TASK_DAILY_DOUQI                     = 3,
	-- [4]连击副本  -- 日常任务 
	CONST_TASK_DAILY_LINK_COPYS                = 4,
	-- [5]浮屠静修 -- 日常任务 
	CONST_TASK_DAILY_FUTU                      = 5,
	-- [6]竞技场 -- 日常任务 
	CONST_TASK_DAILY_ARENA                     = 6,
	-- [7]摇钱 -- 日常任务 
	CONST_TASK_DAILY_YAOQ                      = 7,
	-- [8]培养坐骑  -- 日常任务 
	CONST_TASK_DAILY_PEIYANGZUOQI              = 8,
	-- [9]培养守护  -- 日常任务 
	CONST_TASK_DAILY_PARTNER                   = 9,
	-- [10]日常任务次数  -- 日常任务 
	CONST_TASK_DAILY_ALL                       = 10,

	-- [54001]日常任务一轮奖励-物品ID  -- 日常任务 
	CONST_TASK_DAILY_REWARD_GOOD               = 54001,

	-- [100]刷新一轮消耗钻石数目  -- 日常任务 
	CONST_TASK_DAILY_REFALSH_RMB_USE           = 100,

	-- [0]未完成  -- 日常任务 
	CONST_TASK_DAILY_UNFINISH                  = 0,
	-- [1]当前任务完成  -- 日常任务 
	CONST_TASK_DAILY_FINISH                    = 1,
	-- [2]这一轮任务已经完成  -- 日常任务 
	CONST_TASK_DAILY_ALLFINISH                 = 2,
	-- [26]日常任务进入等级  -- 日常任务 
	CONST_TASK_DAILY_ENTER_LV                  = 26,

	-- [1]第一轮奖励  -- 日常任务 
	CONST_TASK_DAILY_FIRST_COUNT               = 1,
	-- [1.5]第二轮奖励  -- 日常任务 
	CONST_TASK_DAILY_SECOND_COUNT              = 1.5,
	-- [2]第三轮奖励  -- 日常任务 
	CONST_TASK_DAILY_THIRD_COUNT               = 2,

	-- [0]一键完成日常任务按钮开启  -- 日常任务 
	CONST_TASK_DAILY_FINISH_OPEN               = 0,
	-- [5]日常任务一键完成消耗钻石  -- 日常任务 
	CONST_TASK_DAILY_ONE_FINISH                = 5,

	--------------------------------------------------------------------
	-- ( 风林山火 ) 
	--------------------------------------------------------------------
	-- [5]牌语数量--玩家拥有  -- 风林山火 
	CONST_FLSH_PLAYER_COUNT                    = 5,
	-- [6]牌语数量--所有  -- 风林山火 
	CONST_FLSH_PAI_COUNT                       = 6,

	-- [2]每局免费换牌次数  -- 风林山火 
	CONST_FLSH_FREE_SWITCH_TIMES               = 2,
	-- [4]最低顺子  -- 风林山火 
	CONST_FLSH_MIN_SZ                          = 4,
	-- [5]玩的次数--每天  -- 风林山火 
	CONST_FLSH_GAME_TIMES                      = 5,

	-- [2]换牌消耗钻石基数  -- 风林山火 
	CONST_FLSH_CHANGE_RMB_USE                  = 2,

	--------------------------------------------------------------------
	-- ( 每日一箭 ) 
	--------------------------------------------------------------------
	-- [8]该区玩家获得的大奖信息保存总数  -- 每日一箭 
	CONST_ARROW_DAILY_HISTORY                  = 8,
	-- [10000]点击头像消耗美刀数  -- 每日一箭 
	CONST_ARROW_DAILY_MONEY_UES                = 10000,
	-- [3000000]奖池最低奖励  -- 每日一箭 
	CONST_ARROW_DAILY_MIN_REWARD               = 3000000,

	-- [1]免费射箭次数  -- 每日一箭 
	CONST_ARROW_DAILY_FREE_TIMES               = 1,
	-- [5]增加每日一箭消耗钻石基数  -- 每日一箭 
	CONST_ARROW_DAILY_ADD_RMB_USE              = 5,

	-- [4]免费抽取or美刀抽取  -- 每日一箭 
	CONST_ARROW_DAILY_TYPE_GOLD                = 4,
	-- [5]钻石抽取  -- 每日一箭 
	CONST_ARROW_DAILY_TYPE_RMB                 = 5,

	-- [100]至尊大奖ID  -- 每日一箭 
	CONST_ARROW_DAILY_SUPREME_REWARD           = 100,

	--------------------------------------------------------------------
	-- ( 神器 ) 
	--------------------------------------------------------------------
	-- [3]神器升阶降低等级  -- 神器 
	CONST_MAGIC_EQUIP_LV_DOWN                  = 3,
	-- [6]神器升阶最高级别 -- 神器 
	CONST_MAGIC_EQUIP_CLASS_MAX                = 6,
	-- [9]神器升阶需要强化等级  -- 神器 
	CONST_MAGIC_EQUIP_STRENGTHEN_LV            = 9,
	-- [15]最高可以强化到的级别  -- 神器 
	CONST_MAGIC_EQUIP_STRENGTHEN_MAX           = 15,
	-- [36021]传说祝福石id  -- 神器 
	CONST_MAGIC_EQUIP_STORY_STONE_ID           = 36021,

	-- [1]神器阶层1  -- 神器 
	CONST_MAGIC_EQUIP_CLASS_STEP1              = 1,
	-- [2]神器阶层2  -- 神器 
	CONST_MAGIC_EQUIP_CLASS_STEP2              = 2,
	-- [3]神器阶层3  -- 神器 
	CONST_MAGIC_EQUIP_CLASS_STEP3              = 3,
	-- [4]神器阶层4  -- 神器 
	CONST_MAGIC_EQUIP_CLASS_STEP4              = 4,
	-- [5]神器阶层5  -- 神器 
	CONST_MAGIC_EQUIP_CLASS_STEP5              = 5,

	-- [1500]初级祝福石机率  -- 神器 
	CONST_MAGIC_EQUIP_PRIMARY_STONE            = 1500,
	-- [1500]中级祝福石机率  -- 神器 
	CONST_MAGIC_EQUIP_MIDDLE_STONE             = 1500,
	-- [1500]高级祝福石机率  -- 神器 
	CONST_MAGIC_EQUIP_SENIOR_STONE             = 1500,
	-- [2000]史诗祝福石机率  -- 神器 
	CONST_MAGIC_EQUIP_EPIC_STONE               = 2000,
	-- [2500]传说祝福石机率  -- 神器 
	CONST_MAGIC_EQUIP_STORY_STONE              = 2500,

	-- [37501]初级保护石id  -- 神器 
	CONST_MAGIC_EQUIP_PRIMARY_PROTECT          = 37501,
	-- [37506]中级保护石id  -- 神器 
	CONST_MAGIC_EQUIP_MIDDLE_PROTECT           = 37506,
	-- [37511]高级保护石id  -- 神器 
	CONST_MAGIC_EQUIP_SENTOR_PROTECT           = 37511,
	-- [37516]史诗保护石id  -- 神器 
	CONST_MAGIC_EQUIP_EPIC_PROTECT             = 37516,
	-- [37521]传说保护石id  -- 神器 
	CONST_MAGIC_EQUIP_STORY_PROTECT            = 37521,
	-- [38000]初级强化石 -- 神器 
	CONST_MAGIC_EQUIP_QIANGH_C                 = 38000,
	-- [38005]中级强化石 -- 神器 
	CONST_MAGIC_EQUIP_QIANGH_Z                 = 38005,
	-- [38010]高级强化石 -- 神器 
	CONST_MAGIC_EQUIP_QIANGH_G                 = 38010,
	-- [38015]史诗强化石 -- 神器 
	CONST_MAGIC_EQUIP_QIANGH_S                 = 38015,
	-- [38020]传说强化石 -- 神器 
	CONST_MAGIC_EQUIP_QIANGH_A                 = 38020,
	-- [39000]初级玄铁晶 -- 神器 
	CONST_MAGIC_EQUIP_JINJ_C                   = 39000,
	-- [39005]中级玄铁晶 -- 神器 
	CONST_MAGIC_EQUIP_JINJ_Z                   = 39005,
	-- [39010]高级玄铁晶 -- 神器 
	CONST_MAGIC_EQUIP_JINJ_G                   = 39010,
	-- [39015]史诗玄铁晶 -- 神器 
	CONST_MAGIC_EQUIP_JINJ_S                   = 39015,

	-- [43]神器阶层1商品id  -- 神器 
	CONST_MAGIC_EQUIP_STEP1_MALL_ID            = 43,
	-- [44]神器阶层2商品id  -- 神器 
	CONST_MAGIC_EQUIP_STEP2_MALL_ID            = 44,
	-- [45]神器阶层3商品id  -- 神器 
	CONST_MAGIC_EQUIP_STEP3_MALL_ID            = 45,
	-- [46]神器阶层4商品id  -- 神器 
	CONST_MAGIC_EQUIP_STEP4_MALL_ID            = 46,
	-- [47]神器阶层5商品id  -- 神器 
	CONST_MAGIC_EQUIP_STEP5_MALL_ID            = 47,

	-- [33]神器按钮可按等级  -- 神器 
	CONST_MAGIC_EQUIP_GOD_OPENLV               = 33,

	-- [1030]神器商店-碎片兑换  -- 神器 
	CONST_MAGIC_EQUIP_EXCHANGE_MAT             = 1030,
	-- [1040]神器商店-钻石兑换  -- 神器 
	CONST_MAGIC_EQUIP_EXCHANGE_DIAMOND         = 1040,

	-- [0]一键强化vip等级  -- 神器 
	CONST_MAGIC_EQUIP_ONEKEY_VIPLV             = 0,
	-- [38501]神器碎片id  -- 神器 
	CONST_MAGIC_EQUIP_EXCH_ID                  = 38501,

	-- [1]时装  -- 神器 
	CONST_MAGIC_EQUIP_SHIZHUANG                = 1,
	-- [2]真元  -- 神器 
	CONST_MAGIC_EQUIP_CHIBANG                  = 2,

	--------------------------------------------------------------------
	-- ( 三界争锋 ) 
	--------------------------------------------------------------------
	-- [0]报名失败  -- 三界争锋 
	CONST_WRESTLE_FAIL                         = 0,
	-- [1]报名成功  -- 三界争锋 
	CONST_WRESTLE_SUCCESS                      = 1,
	-- [2]拳皇争霸  -- 三界争锋 
	CONST_WRESTLE_ZHENGBA                      = 2,
	-- [2]默认分组数量  -- 三界争锋 
	CONST_WRESTLE_GROUNP_COUNT                 = 2,
	-- [32]进入决赛的人数  -- 三界争锋 
	CONST_WRESTLE_FINAL_COUNT                  = 32,
	-- [50]天下第一限制等级  -- 三界争锋 
	CONST_WRESTLE_LV                           = 50,
	-- [64]参加比赛玩家人数  -- 三界争锋 
	CONST_WRESTLE_COUNT                        = 64,

	-- [0]失败一方获得分数  -- 三界争锋 
	CONST_WRESTLE_FAIL_SCORE                   = 0,
	-- [1]胜利一方获得分数  -- 三界争锋 
	CONST_WRESTLE_SUCCESS_SCORE                = 1,

	-- [0]轮空uid的值  -- 三界争锋 
	CONST_WRESTLE_NO_MATCH_UID                 = 0,

	-- [1]活动离下场战斗开始倒计时type  -- 三界争锋 
	CONST_WRESTLE_DAJISHI_START                = 1,
	-- [2]活动竞猜开始倒计时type  -- 三界争锋 
	CONST_WRESTLE_DAOJISHI_GUESS               = 2,
	-- [3]活动战斗进行时type  -- 三界争锋 
	CONST_WRESTLE_DAOSHI_START_ING             = 3,
	-- [60]活动首轮战斗开始倒计时  -- 三界争锋 
	CONST_WRESTLE_BEFORE_TIME                  = 60,
	-- [180]回合战斗时间  -- 三界争锋 
	CONST_WRESTLE_ACTIVE_TIME                  = 180,
	-- [240]活动离下场战斗开始倒计时（轮空）  -- 三界争锋 
	CONST_WRESTLE_ROUND_TIME                   = 240,

	-- [0]竞猜失败  -- 三界争锋 
	CONST_WRESTLE_GUESS_FAIL                   = 0,
	-- [1]竞猜成功  -- 三界争锋 
	CONST_WRESTLE_GUESS_SUCCESS                = 1,
	-- [2]没有参加竞猜  -- 三界争锋 
	CONST_WRESTLE_GUESS_NOT                    = 2,

	-- [0]可报名  -- 三界争锋 
	CONST_WRESTLE_STATE_BOOK                   = 0,
	-- [1]未开始  -- 三界争锋 
	CONST_WRESTLE_STATE_NOT_START              = 1,
	-- [2]小组赛进行中  -- 三界争锋 
	CONST_WRESTLE_STATE_GROUP_ING              = 2,
	-- [3]小组赛已结束  -- 三界争锋 
	CONST_WRESTLE_STATE_GROUP_OVER             = 3,
	-- [4]决赛进行中  -- 三界争锋 
	CONST_WRESTLE_STATE_FINAL_ING              = 4,
	-- [5]决赛已结束  -- 三界争锋 
	CONST_WRESTLE_STATE_FINAL_OVER             = 5,
	-- [6]王者争霸  -- 三界争锋 
	CONST_WRESTLE_STATE_KING                   = 6,
	-- [7]全部结束  -- 三界争锋 
	CONST_WRESTLE_STATE_ALL_OVER               = 7,
	-- [8]被淘汰  -- 三界争锋 
	CONST_WRESTLE_STATE_BE_OVER                = 8,
	-- [9]没参加  -- 三界争锋 
	CONST_WRESTLE_STATE_NO_JOIN                = 9,

	-- [100]单次下注元宝数 -- 三界争锋 
	CONST_WRESTLE_PEBBLE_MAX                   = 100,
	-- [5000]竞技水晶数量  -- 三界争锋 
	CONST_WRESTLE_PEBBLE                       = 5000,
	-- [60130]三界争锋场景常量  -- 三界争锋 
	CONST_WRESTLE_KOF_SENCE                    = 60130,

	-- [0]上半区  -- 三界争锋 
	CONST_WRESTLE_SHANGBANQU                   = 0,
	-- [1]下半区  -- 三界争锋 
	CONST_WRESTLE_XIABANQU                     = 1,

	-- [2]猜中1人奖励倍数 -- 三界争锋 
	CONST_WRESTLE_REWARD_ONE                   = 2,
	-- [4]猜中2人奖励倍数 -- 三界争锋 
	CONST_WRESTLE_REWARD_TWO                   = 4,
	-- [10]等待时间  -- 三界争锋 
	CONST_WRESTLE_TIME_WAIT                    = 10,
	-- [10]战斗倒计时  -- 三界争锋 
	CONST_WRESTLE_DAOJISHI                     = 10,
	-- [10]缓冲时间  -- 三界争锋 
	CONST_WRESTLE_TIME_BUFFER                  = 10,
	-- [120]战斗时间（使用） -- 三界争锋 
	CONST_WRESTLE_TIME_WAR                     = 120,
	-- [2000]最大奖励 -- 三界争锋 
	CONST_WRESTLE_MAX_REWARD                   = 2000,

	--------------------------------------------------------------------
	-- ( 邀请PK ) 
	--------------------------------------------------------------------
	-- [60125]邀请PK场景  -- 邀请PK 
	CONST_INVITE_PK_SENCE                      = 60125,

	-- [1]进入坐标-左  -- 邀请PK 
	CONST_INVITE_PK_LEFT                       = 1,
	-- [2]进入坐标-右  -- 邀请PK 
	CONST_INVITE_PK_RIGHT                      = 2,

	--------------------------------------------------------------------
	-- ( 拳皇生涯 ) 
	--------------------------------------------------------------------
	-- [1]挂机一个副本的时间(s)  -- 拳皇生涯 
	CONST_FIGHTERS_UP_COPY_TIME                = 1,
	-- [10]每天总共挑战次数  -- 拳皇生涯 
	CONST_FIGHTERS_CHALLENGE_TIMES             = 10,

	-- [1]挂机状态-没有挂机  -- 拳皇生涯 
	CONST_FIGHTERS_UPNO                        = 1,
	-- [2]挂机状态-挂机中  -- 拳皇生涯 
	CONST_FIGHTERS_UPING                       = 2,
	-- [3]挂机状态-挂机完成  -- 拳皇生涯 
	CONST_FIGHTERS_UPOVER                      = 3,

	-- [2]购买挑战次数递增元宝数  -- 拳皇生涯 
	CONST_FIGHTERS_BUY_DIZENG                  = 2,
	-- [10]挑战次数购买上限  -- 拳皇生涯 
	CONST_FIGHTERS_TIMES_BUY_LIMIT             = 10,
	-- [10]购买挑战次数所需的钻石基数  -- 拳皇生涯 
	CONST_FIGHTERS_TIMES_BUY_BASE              = 10,

	-- [0.5]副本传送门出现延迟秒数  -- 拳皇生涯 
	CONST_FIGHTERS_DOOR_DELAY_TIME             = 0.5,
	-- [900]距离刷新前多久关闭入口(单位:秒) -- 拳皇生涯 
	CONST_FIGHTERS_CLOSE_TIME                  = 900,

	-- [1]免费重置次数  -- 拳皇生涯 
	CONST_FIGHTERS_FREE_FRESH                  = 1,

	-- [1]占领领地  -- 拳皇生涯 
	CONST_FIGHTERS_HERO_TYPE1                  = 1,
	-- [2]其他玩家抢占你的领地  -- 拳皇生涯 
	CONST_FIGHTERS_HERO_TYPE2                  = 2,
	-- [3]离开领地  -- 拳皇生涯 
	CONST_FIGHTERS_HERO_TYPE3                  = 3,
	-- [4]满十二个小时离开(有奖励)  -- 拳皇生涯 
	CONST_FIGHTERS_HERO_TYPE4                  = 4,
	-- [5]满十二个小时离开(没有奖励)  -- 拳皇生涯 
	CONST_FIGHTERS_HERO_TYPE5                  = 5,
	-- [6]零点重置离开  -- 拳皇生涯 
	CONST_FIGHTERS_HERO_TYPE6                  = 6,
	-- [7]抢夺别人关卡失败 -- 拳皇生涯 
	CONST_FIGHTERS_HERO_TYPE7                  = 7,
	-- [8]成功击退别的玩家 -- 拳皇生涯 
	CONST_FIGHTERS_HERO_TYPE8                  = 8,

	-- [0]挑战失败  -- 拳皇生涯 
	CONST_FIGHTERS_HERO_RES_0                  = 0,
	-- [1]挑战成功  -- 拳皇生涯 
	CONST_FIGHTERS_HERO_RES_1                  = 1,
	-- [2]直接占领成功(不用挑战)  -- 拳皇生涯 
	CONST_FIGHTERS_HERO_RES_2                  = 2,

	-- [1800]英雄塔-奖励结算间隔时间(秒数)  -- 拳皇生涯 
	CONST_FIGHTERS_HERO_CLEAR_TIME             = 1800,
	-- [43200]英雄塔-每次最多可占领 12 小时  -- 拳皇生涯 
	CONST_FIGHTERS_MAX_TIME                    = 43200,

	-- [10]英雄塔-购买挑战次数的价格  -- 拳皇生涯 
	CONST_FIGHTERS_HERO_BUY_BASE               = 10,

	-- [10]英雄塔抢占获得比例 -- 拳皇生涯 
	CONST_FIGHTERS_HERO_SCALE                  = 10,
	-- [10]英雄塔免费占领次数  -- 拳皇生涯 
	CONST_FIGHTERS_HERO_FREE_TIME              = 10,
	-- [10]英雄塔购买占领次数  -- 拳皇生涯 
	CONST_FIGHTERS_HERO_BUY_TIMES              = 10,

	--------------------------------------------------------------------
	-- ( 排行榜 ) 
	--------------------------------------------------------------------
	-- [1]排行版类型-等级  -- 排行榜 
	CONST_TOP_TYPE_LV                          = 1,
	-- [2]排行版类型-洞府  -- 排行榜 
	CONST_TOP_TYPE_CLAN                        = 2,
	-- [3]排行版类型-战斗力  -- 排行榜 
	CONST_TOP_TYPE_POWER                       = 3,
	-- [4]排行版类型-金身  -- 排行榜 
	CONST_TOP_TYPE_MATRIX                      = 4,
	-- [5]排行版类型-装备  -- 排行榜 
	CONST_TOP_TYPE_EQUIP                       = 5,
	-- [6]排行版类型-神兵  -- 排行榜 
	CONST_TOP_TYPE_MAGIC                       = 6,
	-- [7]排行版类型-坐骑  -- 排行榜 
	CONST_TOP_TYPE_MOUNT                       = 7,
	-- [8]排行榜类型-竞技场  -- 排行榜 
	CONST_TOP_TYPE_ARENA                       = 8,
	-- [9]排行榜类型-充值  -- 排行榜 
	CONST_TOP_TYPE_RMB                         = 9,
	-- [10]排行榜类型-经验值  -- 排行榜 
	CONST_TOP_TYPE_EXP                         = 10,
	-- [11]排行榜类型-通天浮屠  -- 排行榜 
	CONST_TOP_TYPE_FIGHTERS                    = 11,
	-- [12]排行榜类型-卦象  -- 排行榜 
	CONST_TOP_TYPE_BAQI                        = 12,
	-- [13]排行榜类型-仙侣 -- 排行榜 
	CONST_TOP_TYPE_MEIREN                      = 13,
	-- [14]排行榜类型-无尽心魔  -- 排行榜 
	CONST_TOP_TYPE_ENDLESS                     = 14,
	-- [15]排行榜类型-真元 -- 排行榜 
	CONST_TOP_TYPE_WING                        = 15,
	-- [16]排行榜类型-总充值 -- 排行榜 
	CONST_TOP_TYPE_RMB_TOTAL                   = 16,
	-- [17]排行榜类型-星石 -- 排行榜 
	CONST_TOP_TYPE_STAR                        = 17,
	-- [18]排行榜类型-守护 -- 排行榜 
	CONST_TOP_TYPE_PARTNER                     = 18,
	-- [19]排行榜类型-装备宝石 -- 排行榜 
	CONST_TOP_TYPE_EQUIP_GEM                   = 19,
	-- [20]排行榜类型-装备升级 -- 排行榜 
	CONST_TOP_TYPE_EQUIP_STRENG                = 20,
	-- [21]排行榜类型-装备装备 -- 排行榜 
	CONST_TOP_TYPE_EQUIP_EQUIP                 = 21,
	-- [22]排行榜类型-武器 -- 排行榜 
	CONST_TOP_TYPE_WUQI                        = 22,
	-- [23]排行榜类型-神羽 -- 排行榜 
	CONST_TOP_TYPE_FEATHER                     = 23,
	-- [24]排行榜类型-灵妖 -- 排行榜 
	CONST_TOP_TYPE_LINGYAO                     = 24,

	-- [20]各排行前20数据  -- 排行榜 
	CONST_TOP_RANK_20                          = 20,

	--------------------------------------------------------------------
	-- ( 式神（宠物） ) 
	--------------------------------------------------------------------
	-- [10]高级修炼钻石基数  -- 式神（宠物） 
	CONST_PET_RMB                              = 10,
	-- [35]魔宠模块开通等级  -- 式神（宠物） 
	CONST_PET_OPEN_LV                          = 35,
	-- [50]高级修炼次数  -- 式神（宠物） 
	CONST_PET_SENIOR_TIMES                     = 50,
	-- [100]宠物最高等级  -- 式神（宠物） 
	CONST_PET_MAX_LV                           = 100,
	-- [54001]魔宠修炼道具id  -- 式神（宠物） 
	CONST_PET_GOODS_ID                         = 54001,

	-- [0]式神状态-可获得  -- 式神（宠物） 
	CONST_PET_STATE_0                          = 0,
	-- [1]式神状态-已获得  -- 式神（宠物） 
	CONST_PET_STATE_1                          = 1,
	-- [2]式神状态-可召唤  -- 式神（宠物） 
	CONST_PET_STATE_2                          = 2,
	-- [3]式神状态-已召唤  -- 式神（宠物） 
	CONST_PET_STATE_3                          = 3,

	--------------------------------------------------------------------
	-- ( 系统设置 ) 
	--------------------------------------------------------------------
	-- [101]设置背景音乐  -- 系统设置 
	CONST_SYS_SET_MUSIC_BG                     = 101,
	-- [102]游戏音效  -- 系统设置 
	CONST_SYS_SET_MUSIC                        = 102,
	-- [103]屏蔽其他玩家  -- 系统设置 
	CONST_SYS_SET_SHOW_ROLE                    = 103,
	-- [104]查看他人信息  -- 系统设置 
	CONST_SYS_SET_ROLE_DATA                    = 104,
	-- [105]允许切磋  -- 系统设置 
	CONST_SYS_SET_PK                           = 105,
	-- [106]允许接收组队  -- 系统设置 
	CONST_SYS_SET_TEAM                         = 106,
	-- [107]设置手机系统消息是否弹出  -- 系统设置 
	CONST_SYS_SET_MOBILE                       = 107,
	-- [108]满体力提示  -- 系统设置 
	CONST_SYS_SET_ENERGY                       = 108,
	-- [109]是否跳过新手指引  -- 系统设置 
	CONST_SYS_SET_GUIDE                        = 109,

	--------------------------------------------------------------------
	-- ( 新手指引 ) 
	--------------------------------------------------------------------
	-- [1]接受任务  -- 新手指引 
	CONST_NEW_GUIDE_ACCEPT_TASK                = 1,
	-- [2]完成任务  -- 新手指引 
	CONST_NEW_GUIDE_COMPLETE_TASK              = 2,
	-- [3]初次进入游戏  -- 新手指引 
	CONST_NEW_GUIDE_NEW                        = 3,
	-- [4]新功能开放  -- 新手指引 
	CONST_NEW_GUIDE_FUN_OPEN                   = 4,
	-- [5]完成指引  -- 新手指引 
	CONST_NEW_GUIDE_COMPLETE_GUIDE             = 5,

	-- [8]等级限制-装备穿戴指引 -- 新手指引 
	CONST_NEW_GUIDE_LV_EQUIP                   = 8,
	-- [30]等级限制-任务指引 -- 新手指引 
	CONST_NEW_GUIDE_LV_TASK                    = 30,

	-- [1]方向-上  -- 新手指引 
	CONST_NEW_GUIDE_UP                         = 1,
	-- [2]方向-下  -- 新手指引 
	CONST_NEW_GUIDE_DOWN                       = 2,
	-- [3]方向-左  -- 新手指引 
	CONST_NEW_GUIDE_LEFT                       = 3,
	-- [4]方向-右  -- 新手指引 
	CONST_NEW_GUIDE_RIGHT                      = 4,

	-- [101]系统指引-技能装备1 -- 新手指引 
	CONST_NEW_GUIDE_SYS_SKILL1                 = 101,
	-- [102]系统指引-技能装备2 -- 新手指引 
	CONST_NEW_GUIDE_SYS_SKILL2                 = 102,
	-- [103]系统指引-技能升级 -- 新手指引 
	CONST_NEW_GUIDE_SYS_SKILL3                 = 103,
	-- [111]系统指引-坐骑 -- 新手指引 
	CONST_NEW_GUIDE_SYS_MOUNT                  = 111,
	-- [121]系统指引-签到领奖 -- 新手指引 
	CONST_NEW_GUIDE_SYS_SIGN                   = 121,
	-- [131]系统指引-守护上阵 -- 新手指引 
	CONST_NEW_GUIDE_SYS_PARTNER_UP             = 131,
	-- [132]系统指引-守护升级 -- 新手指引 
	CONST_NEW_GUIDE_SYS_PARTNER_LEVEL          = 132,
	-- [141]系统指引-仙宠灵兽 -- 新手指引 
	CONST_NEW_GUIDE_SYS_CHEER                  = 141,
	-- [151]系统指引-金身 -- 新手指引 
	CONST_NEW_GUIDE_SYS_GOLD                   = 151,
	-- [161]系统指引-竞技场 -- 新手指引 
	CONST_NEW_GUIDE_SYS_ARENA                  = 161,
	-- [171]系统指引-装备强化 -- 新手指引 
	CONST_NEW_GUIDE_SYS_EQUIP                  = 171,
	-- [181]系统指引-守护升级2 -- 新手指引 
	CONST_NEW_GUIDE_SYS_PARTNER_LEVEL2         = 181,
	-- [191]系统指引-坐骑培养 -- 新手指引 
	CONST_NEW_GUIDE_SYS_MOUNT_LEVEL            = 191,
	-- [201]系统指引-技能升级2 -- 新手指引 
	CONST_NEW_GUIDE_SYS_SKILL4                 = 201,
	-- [211]系统指引-竞技场2 -- 新手指引 
	CONST_NEW_GUIDE_SYS_ARENA2                 = 211,
	-- [221]系统指引-摇钱树 -- 新手指引 
	CONST_NEW_GUIDE_SYS_MONEYTREE              = 221,
	-- [231]系统指引-金身2 -- 新手指引 
	CONST_NEW_GUIDE_SYS_GOLD2                  = 231,
	-- [241]系统指引-悬赏任务 -- 新手指引 
	CONST_NEW_GUIDE_SYS_DAILYTASK              = 241,
	-- [251]系统指引-宝石镶嵌 -- 新手指引 
	CONST_NEW_GUIDE_SYS_GEM                    = 251,
	-- [261]系统指引-加入洞府 -- 新手指引 
	CONST_NEW_GUIDE_SYS_CLAN                   = 261,
	-- [271]系统指引-扫荡副本 -- 新手指引 
	CONST_NEW_GUIDE_SYS_COPY                   = 271,
	-- [281]系统指引-通天浮屠 -- 新手指引 
	CONST_NEW_GUIDE_SYS_TOWER                  = 281,
	-- [291]系统指引-群仙诛邪 -- 新手指引 
	CONST_NEW_GUIDE_SYS_TEAM                   = 291,
	-- [301]系统指引-摇一摇 -- 新手指引 
	CONST_NEW_GUIDE_SYS_DICE                   = 301,
	-- [311]系统指引-卦象 -- 新手指引 
	CONST_NEW_GUIDE_SYS_BAGUA                  = 311,
	-- [321]系统指引-噩梦副本 -- 新手指引 
	CONST_NEW_GUIDE_SYS_BADDERAM               = 321,
	-- [331]系统指引-降魔之路 -- 新手指引 
	CONST_NEW_GUIDE_SYS_SURRENDER              = 331,
	-- [341]系统指引-饰品升品 -- 新手指引 
	CONST_NEW_GUIDE_SYS_EQUIP_RISE             = 341,
	-- [351]系统指引-灵妖竞技 -- 新手指引 
	CONST_NEW_GUIDE_SYS_LYJJ                   = 351,
	-- [361]系统指引-镇守妖塔 -- 新手指引 
	CONST_NEW_GUIDE_SYS_ZSYT                   = 361,
	-- [371]系统指引-困难副本 -- 新手指引 
	CONST_NEW_GUIDE_SYS_COPY_KUNNAN            = 371,
	-- [381]系统指引-饰品附魔 -- 新手指引 
	CONST_NEW_GUIDE_SYS_EQUIP_FUMO             = 381,
	-- [391]系统指引-普通副本 -- 新手指引 
	CONST_NEW_GUIDE_SYS_COPY_FIRST             = 391,
	-- [401]系统指引-章节一奖励 -- 新手指引 
	CONST_NEW_GUIDE_SYS_COPY_REWARD1           = 401,
	-- [411]系统指引-章节二奖励 -- 新手指引 
	CONST_NEW_GUIDE_SYS_COPY_REWARD2           = 411,
	-- [421]系统指引-章节三奖励 -- 新手指引 
	CONST_NEW_GUIDE_SYS_COPY_REWARD3           = 421,
	-- [431]系统指引-章节四奖励 -- 新手指引 
	CONST_NEW_GUIDE_SYS_COPY_REWARD4           = 431,
	-- [441]系统指引-章节五奖励 -- 新手指引 
	CONST_NEW_GUIDE_SYS_COPY_REWARD5           = 441,
	-- [451]系统指引-章节六奖励 -- 新手指引 
	CONST_NEW_GUIDE_SYS_COPY_REWARD6           = 451,
	-- [461]系统指引-秘境宝藏 -- 新手指引 
	CONST_NEW_GUIDE_SYS_MIBAO                  = 461,
	-- [471]系统指引-斗转星移 -- 新手指引 
	CONST_NEW_GUIDE_SYS_DZXY                   = 471,
	-- [481]系统指引-道劫 -- 新手指引 
	CONST_NEW_GUIDE_SYS_DAOJIE                 = 481,

	--------------------------------------------------------------------
	-- ( 三国基金 ) 
	--------------------------------------------------------------------
	-- [1]初级投资计划  -- 三国基金 
	CONST_PRIVILEGE_TYEP_1                     = 1,
	-- [2]中级投资计划  -- 三国基金 
	CONST_PRIVILEGE_TYPE_2                     = 2,
	-- [3]高级投资计划  -- 三国基金 
	CONST_PRIVILEGE_TYPE_3                     = 3,
	-- [4]超级投资计划  -- 三国基金 
	CONST_PRIVILEGE_TYPE_4                     = 4,

	-- [0]状态0（未领取or未开通）  -- 三国基金 
	CONST_PRIVILEGE_STATA0                     = 0,
	-- [1]状态1（已领取or已开通）  -- 三国基金 
	CONST_PRIVILEGE_STATA1                     = 1,

	-- [7]活动开服七天  -- 三国基金 
	CONST_PRIVILEGE_DATE                       = 7,

	--------------------------------------------------------------------
	-- ( 美人系统 ) 
	--------------------------------------------------------------------
	-- [0]已经获得美人  -- 美人系统 
	CONST_MEIREN_GET_GOT                       = 0,
	-- [1]美人卡条件  -- 美人系统 
	CONST_MEIREN_GET_CARD                      = 1,
	-- [1]签到条件  -- 美人系统 
	CONST_MEIREN_GET_SIGN                      = 1,
	-- [2]首充条件  -- 美人系统 
	CONST_MEIREN_GET_FIRST_CHARGE              = 2,
	-- [3]坐骑条件  -- 美人系统 
	CONST_MEIREN_GET_MOUNT                     = 3,
	-- [5]活动条件  -- 美人系统 
	CONST_MEIREN_GET_HUODONG                   = 5,

	-- [1]美人缠绵物品个数  -- 美人系统 
	CONST_MEIREN_GOODS_NUM                     = 1,
	-- [53005]相思红豆  -- 美人系统 
	CONST_MEIREN_GOODS_HONGDOU                 = 53005,
	-- [53006]香囊  -- 美人系统 
	CONST_MEIREN_GOODS_XIANGNANG               = 53006,
	-- [53010]胭脂  -- 美人系统 
	CONST_MEIREN_GOODS_YANZHI                  = 53010,

	-- [10]免费缠绵次数  -- 美人系统 
	CONST_MEIREN_FREE_TIMES                    = 10,

	-- [0]祝福值低于这个机率，必定失败  -- 美人系统 
	CONST_MEIREN_BLESS                         = 0,

	-- [1]美人进阶时等级加一  -- 美人系统 
	CONST_MEIREN_LV_UP                         = 1,
	-- [10]等阶满级  -- 美人系统 
	CONST_MEIREN_CLASS_MAX                     = 10,
	-- [10]品质满级  -- 美人系统 
	CONST_MEIREN_QUALITY_MAX                   = 10,

	-- [200]传承消耗元宝数  -- 美人系统 
	CONST_MEIREN_INHERTED_RMB                  = 200,

	--------------------------------------------------------------------
	-- ( 押镖 ) 
	--------------------------------------------------------------------
	-- [2]每趟镖的最大截取次数  -- 押镖 
	CONST_ESCORT_SURPLUS                       = 2,
	-- [2]免费刷新次数  -- 押镖 
	CONST_ESCORT_FREE_NUM                      = 2,
	-- [2]护送次数  -- 押镖 
	CONST_ESCORT_ESC_NUM                       = 2,
	-- [10]打劫次数  -- 押镖 
	CONST_ESCORT_ROB_NUM                       = 10,
	-- [1200]押镖时间 秒  -- 押镖 
	CONST_ESCORT_TIME                          = 1200,

	-- [0.1]被邀请好友扣除比例  -- 押镖 
	CONST_ESCORT_FRIEND_SCALE                  = 0.1,
	-- [0.1]被打劫扣除比例  -- 押镖 
	CONST_ESCORT_LOST_SCALE                    = 0.1,
	-- [1]邀请好友类型--好友  -- 押镖 
	CONST_ESCORT_FRIEND                        = 1,
	-- [2]邀请好友类型--洞府  -- 押镖 
	CONST_ESCORT_CLAN                          = 2,

	-- [1]个人战报类型--抢  -- 押镖 
	CONST_ESCORT_ONE                           = 1,
	-- [2]个人战报类型--被抢  -- 押镖 
	CONST_ESCORT_TWO                           = 2,
	-- [3]个人战报类型--已到  -- 押镖 
	CONST_ESCORT_THREE                         = 3,
	-- [10]要显示的个人战报数量  -- 押镖 
	CONST_ESCORT_OWN_NUM                       = 10,
	-- [20]要显示的所有战报数量  -- 押镖 
	CONST_ESCORT_ALL_NUM                       = 20,

	-- [0]直接召唤vip等级要求  -- 押镖 
	CONST_ESCORT_VIP                           = 0,
	-- [5]刷新消耗  -- 押镖 
	CONST_ESCORT_REFLASH_USE                   = 5,
	-- [20]快速护送最大消耗  -- 押镖 
	CONST_ESCORT_MAX_USE                       = 20,
	-- [50]直接召唤花费  -- 押镖 
	CONST_ESCORT_ZHAO_USE                      = 50,
	-- [6000]刷新成功机率万分比  -- 押镖 
	CONST_ESCORT_REFLASH_TRUE                  = 6000,

	--------------------------------------------------------------------
	-- ( 金身系统 ) 
	--------------------------------------------------------------------
	-- [8]每阶最高等级  -- 金身系统 
	CONST_MATIAX_MAXLV                         = 8,
	-- [10]金身升阶祝福值  -- 金身系统 
	CONST_MATIAX_ZHUFUZHI                      = 10,
	-- [15]金身开放等级  -- 金身系统 
	CONST_MATIAX_OPEN                          = 15,
	-- [18]最高阶  -- 金身系统 
	CONST_MATIAX_MAXSTAGE                      = 18,

	--------------------------------------------------------------------
	-- ( 挑战迷宫 ) 
	--------------------------------------------------------------------
	-- [20]最后的节点  -- 挑战迷宫 
	CONST_MAZE_LAST_NODE                       = 20,
	-- [57011]兑换物道具id  -- 挑战迷宫 
	CONST_MAZE_EXC_ID                          = 57011,

	-- [5]免费次数  -- 挑战迷宫 
	CONST_MAZE_FREE_NUM                        = 5,
	-- [10]每次使用的元宝  -- 挑战迷宫 
	CONST_MAZE_USE_RMB                         = 10,

	-- [1]探险类型--一次  -- 挑战迷宫 
	CONST_MAZE_TYPE_LOW                        = 1,
	-- [10]探险类型--十次  -- 挑战迷宫 
	CONST_MAZE_TYPE_MEDIUM                     = 10,
	-- [50]探险类型--五十次  -- 挑战迷宫 
	CONST_MAZE_TYPE_HIGHER                     = 50,

	-- [12]地图块个数  -- 挑战迷宫 
	CONST_MAZE_MAP_NUM                         = 12,
	-- [888888]地图ID  -- 挑战迷宫 
	CONST_MAZE_MAP_ID                          = 888888,

	-- [20]格子数量  -- 挑战迷宫 
	CONST_MAZE_LATTICE_NUM                     = 20,

	-- [10]探险一次花费  -- 挑战迷宫 
	CONST_MAZE_ONCE_USE                        = 10,
	-- [90]探险十次花费  -- 挑战迷宫 
	CONST_MAZE_MORE_USE                        = 90,
	-- [400]探险五十次花费  -- 挑战迷宫 
	CONST_MAZE_MAX_USE                         = 400,

	--------------------------------------------------------------------
	-- ( 每日转盘 ) 
	--------------------------------------------------------------------
	-- [4]免费转盘次数  -- 每日转盘 
	CONST_WHEEL_FREETIMES                      = 4,
	-- [10]元宝抽奖消耗值  -- 每日转盘 
	CONST_WHEEL_USE_RMB                        = 10,

	--------------------------------------------------------------------
	-- ( 拍卖系统 ) 
	--------------------------------------------------------------------
	-- [1]竞拍后冷却时间 -- 拍卖系统 
	CONST_AUCTION_TIME_LQCD                    = 1,
	-- [1]物品没有被拍卖 -- 拍卖系统 
	CONST_AUCTION_GOODS_NO                     = 1,
	-- [2]物品正在被拍卖 -- 拍卖系统 
	CONST_AUCTION_GOODS_NOW                    = 2,
	-- [3]物品已经被拍卖 -- 拍卖系统 
	CONST_AUCTION_GOODS_OLD                    = 3,
	-- [5]一次拍卖个数  -- 拍卖系统 
	CONST_AUCTION_NUM                          = 5,
	-- [120]拍下后倒计时 -- 拍卖系统 
	CONST_AUCTION_TIME_DJSCD                   = 120,
	-- [600]拍卖没人拍倒计时 -- 拍卖系统 
	CONST_AUCTION_TIME_CD                      = 600,

	--------------------------------------------------------------------
	-- ( 全民寻宝 ) 
	--------------------------------------------------------------------
	-- [1]寻宝方式：一  -- 全民寻宝 
	CONST_ALLFIND_ONE                          = 1,
	-- [10]寻宝方式：十  -- 全民寻宝 
	CONST_ALLFIND_TEN                          = 10,

	-- [10]获得积分类型一  -- 全民寻宝 
	CONST_ALLFIND_FINDPOINT_ONE                = 10,
	-- [100]获得积分类型十  -- 全民寻宝 
	CONST_ALLFIND_FINDPOINT_TEN                = 100,

	-- [1]全民寻宝免费次数  -- 全民寻宝 
	CONST_ALLFIND_FREETIMES                    = 1,
	-- [10]寻宝一次消耗元宝  -- 全民寻宝 
	CONST_ALLFIND_NEEDRMB_ONE                  = 10,
	-- [500]付费次数  -- 全民寻宝 
	CONST_ALLFIND_COSTTIMES                    = 500,

	-- [1]坐骑  -- 全民寻宝 
	CONST_ALLFIND_HORSE                        = 1,
	-- [2]宝石  -- 全民寻宝 
	CONST_ALLFIND_JEWEL                        = 2,
	-- [3]神器  -- 全民寻宝 
	CONST_ALLFIND_GODSIX                       = 3,
	-- [4]美人  -- 全民寻宝 
	CONST_ALLFIND_BEAUTY                       = 4,

	-- [12]宝石开放等级  -- 全民寻宝 
	CONST_ALLFIND_OPEN_JEWEL                   = 12,
	-- [33]神器开放等级  -- 全民寻宝 
	CONST_ALLFIND_OPEN_GODSIX                  = 33,
	-- [43]美人开放等级  -- 全民寻宝 
	CONST_ALLFIND_OPEN_BEAUTY                  = 43,

	-- [10]倍数  -- 全民寻宝 
	CONST_ALLFIND_MULTIPLE                     = 10,

	--------------------------------------------------------------------
	-- ( 地下皇陵 ) 
	--------------------------------------------------------------------
	-- [2]免费次数  -- 地下皇陵 
	CONST_TOMB_FREETIMES                       = 2,
	-- [20]挖一次宝消耗元宝  -- 地下皇陵 
	CONST_TOMB_NEEDRMB_ONE                     = 20,
	-- [100]挖五次宝消耗元宝  -- 地下皇陵 
	CONST_TOMB_NEEDRMB_FIVE                    = 100,
	-- [198]付费次数  -- 地下皇陵 
	CONST_TOMB_TIMES                           = 198,

	-- [5]挖五次宝最小次数  -- 地下皇陵 
	CONST_TOMB_SMALLTIMES                      = 5,

	-- [1]挖宝次数-一  -- 地下皇陵 
	CONST_TOMB_USE_TIMES_ONE                   = 1,
	-- [5]挖宝次数-五  -- 地下皇陵 
	CONST_TOMB_USE_TIMES_FIVE                  = 5,

	-- [1]挖宝方式-一  -- 地下皇陵 
	CONST_TOMB_ONE                             = 1,
	-- [5]挖宝方式-五  -- 地下皇陵 
	CONST_TOMB_FIVE                            = 5,

	--------------------------------------------------------------------
	-- ( 奖励 ) 
	--------------------------------------------------------------------
	-- [1]在线领奖面板  -- 奖励 
	CONST_REWARD_TYPE_ONLINE                   = 1,
	-- [2]每日奖励面板  -- 奖励 
	CONST_REWARD_TYPE_DAILY                    = 2,
	-- [3]等级奖励面板  -- 奖励 
	CONST_REWARD_TYPE_LV                       = 3,
	-- [4]vip奖励面板  -- 奖励 
	CONST_REWARD_TYPE_VIP                      = 4,
	-- [30]封测奖励基数  -- 奖励 
	CONST_REWARD_FENGCE_JIANGLI                = 30,

	-- [4]在线最大奖励领取  -- 奖励 
	CONST_REWARD_MAX_ONLINE                    = 4,

	-- [8]每日最大奖励领取  -- 奖励 
	CONST_REWARD_MAX_DAILY                     = 8,

	--------------------------------------------------------------------
	-- ( 封神榜 ) 
	--------------------------------------------------------------------
	-- [5]初始可购买次数 -- 封神榜 
	CONST_EXPEDIT_TIMES                        = 5,
	-- [10]花费初始值  -- 封神榜 
	CONST_EXPEDIT_COST                         = 10,
	-- [10]战报数量 -- 封神榜 
	CONST_EXPEDIT_NUM                          = 10,
	-- [50]失败荣誉  -- 封神榜 
	CONST_EXPEDIT_FAIL                         = 50,
	-- [100]胜利荣誉  -- 封神榜 
	CONST_EXPEDIT_WIN                          = 100,

	-- [5]初始匹配次数(每日) -- 封神榜 
	CONST_EXPEDIT_PP_NUM                       = 5,
	-- [41]一阶佛皇 -- 封神榜 
	CONST_EXPEDIT_FOWANG_1                     = 41,
	-- [50]十阶佛皇 -- 封神榜 
	CONST_EXPEDIT_FOWANG_2                     = 50,

	--------------------------------------------------------------------
	-- ( 成就系统 ) 
	--------------------------------------------------------------------
	-- [101]装备等级  -- 成就系统 
	CONST_ACHIEVE_EQUIP_LV                     = 101,
	-- [102]装备品质  -- 成就系统 
	CONST_ACHIEVE_EQUIP_QUALITY                = 102,
	-- [103]战力数值  -- 成就系统 
	CONST_ACHIEVE_POWERFUL                     = 103,
	-- [104]金身级别  -- 成就系统 
	CONST_ACHIEVE_ZHENFA                       = 104,
	-- [105]坐骑品质  -- 成就系统 
	CONST_ACHIEVE_MOUNT                        = 105,
	-- [106]魔王副本  -- 成就系统 
	CONST_ACHIEVE_FIEND                        = 106,
	-- [107]武将数量  -- 成就系统 
	CONST_ACHIEVE_INN_NUM                      = 107,
	-- [108]武将等级  -- 成就系统 
	CONST_ACHIEVE_INN_LV                       = 108,
	-- [109]珍宝层数  -- 成就系统 
	CONST_ACHIEVE_TREASURE                     = 109,
	-- [110]神器数量  -- 成就系统 
	CONST_ACHIEVE_MAGIC_NUM                    = 110,
	-- [111]神器品质  -- 成就系统 
	CONST_ACHIEVE_MAGIC_QUALITY                = 111,
	-- [112]美人数量  -- 成就系统 
	CONST_ACHIEVE_MEIREN_NUM                   = 112,
	-- [113]美人品质  -- 成就系统 
	CONST_ACHIEVE_MEIREN_QUALITY               = 113,
	-- [114]竞技场排名  -- 成就系统 
	CONST_ACHIEVE_AREAN                        = 114,
	-- [115]洞府等级  -- 成就系统 
	CONST_ACHIEVE_CLAN_LV                      = 115,
	-- [116]技能等级  -- 成就系统 
	CONST_ACHIEVE_SKILL_LV                     = 116,
	-- [117]卦象品质  -- 成就系统 
	CONST_ACHIEVE_BAQI_QUALITY                 = 117,

	-- [0]未完成状态  -- 成就系统 
	CONST_ACHIEVE_STATE_0                      = 0,
	-- [1]可领取状态  -- 成就系统 
	CONST_ACHIEVE_STATE_1                      = 1,
	-- [2]已完成状态  -- 成就系统 
	CONST_ACHIEVE_STATE_2                      = 2,

	--------------------------------------------------------------------
	-- ( 开服七天 ) 
	--------------------------------------------------------------------
	-- [1]冲级  -- 开服七天 
	CONST_OPEN_LV                              = 1,
	-- [2]坐骑升星  -- 开服七天 
	CONST_OPEN_MOUNTS                          = 2,
	-- [3]过关斩将  -- 开服七天 
	CONST_OPEN_KILL                            = 3,
	-- [4]战斗力  -- 开服七天 
	CONST_OPEN_POWERFUL                        = 4,
	-- [5]竞技  -- 开服七天 
	CONST_OPEN_ARENA                           = 5,
	-- [6]连续上线  -- 开服七天 
	CONST_OPEN_ONLINE                          = 6,
	-- [7]boss  -- 开服七天 
	CONST_OPEN_BOSS                            = 7,

	-- [1]竞技-第一  -- 开服七天 
	CONST_OPEN_ARENA_ONE                       = 1,
	-- [5]竞技-第五  -- 开服七天 
	CONST_OPEN_ARENA_FIVE                      = 5,
	-- [10]竞技-第十  -- 开服七天 
	CONST_OPEN_ARENA_TEN                       = 10,
	-- [20]竞技-二十  -- 开服七天 
	CONST_OPEN_ARENA_TWENTY                    = 20,
	-- [50]竞技-五十  -- 开服七天 
	CONST_OPEN_ARENA_FIFTY                     = 50,
	-- [499]竞技-五百  -- 开服七天 
	CONST_OPEN_FIVE_HUNDRED                    = 499,

	-- [1]上线-1  -- 开服七天 
	CONST_OPEN_ONLINE_ONE                      = 1,
	-- [2]上线-2  -- 开服七天 
	CONST_OPEN_ONLINE_TWO                      = 2,
	-- [3]上线-3  -- 开服七天 
	CONST_OPEN_ONLINE_THREE                    = 3,
	-- [4]上线-4  -- 开服七天 
	CONST_OPEN_ONLINE_FOUR                     = 4,
	-- [5]上线-5  -- 开服七天 
	CONST_OPEN_ONLINE_FIVE                     = 5,
	-- [6]上线-6  -- 开服七天 
	CONST_OPEN_ONLINE_SIX                      = 6,

	-- [1]boss类型-参与洞府击杀  -- 开服七天 
	CONST_OPEN_BOSS_ONE                        = 1,
	-- [2]boss类型-参与世界击杀  -- 开服七天 
	CONST_OPEN_BOSS_TWO                        = 2,
	-- [3]boss类型-洞府最后一击  -- 开服七天 
	CONST_OPEN_BOSS_THREE                      = 3,
	-- [4]boss类型-世界最后一击  -- 开服七天 
	CONST_OPEN_BOSS_FOUR                       = 4,
	-- [10701]bossID-参与洞府击杀  -- 开服七天 
	CONST_OPEN_BOSS_IDA                        = 10701,
	-- [10702]bossID-参与世界击杀  -- 开服七天 
	CONST_OPEN_BOSS_IDB                        = 10702,
	-- [10703]bossID-洞府最后一击  -- 开服七天 
	CONST_OPEN_BOSS_IDC                        = 10703,
	-- [10704]bossID-世界最后一击  -- 开服七天 
	CONST_OPEN_BOSS_IDD                        = 10704,
	-- [10705]bossID-魔王副本  -- 开服七天 
	CONST_OPEN_BOSS_IDE                        = 10705,

	-- [1]领取状态-不可领取  -- 开服七天 
	CONST_OPEN_STATE_ONE                       = 1,
	-- [2]领取状态-可领取  -- 开服七天 
	CONST_OPEN_STATE_TWO                       = 2,
	-- [3]领取状态-已领取  -- 开服七天 
	CONST_OPEN_STATE_THREE                     = 3,

	--------------------------------------------------------------------
	-- ( 每日抽奖 ) 
	--------------------------------------------------------------------
	-- [50]每次消耗元宝数  -- 每日抽奖 
	CONST_DRAW_RMB                             = 50,

	-- [7]连续登陆最大天数  -- 每日抽奖 
	CONST_DRAW_DAY_MAX                         = 7,

	--------------------------------------------------------------------
	-- ( 洞府守卫战 ) 
	--------------------------------------------------------------------
	-- [1]雕像类型--青龙  -- 洞府守卫战 
	CONST_DEFENSE_TYPE_1                       = 1,
	-- [2]雕像类型--白虎  -- 洞府守卫战 
	CONST_DEFENSE_TYPE_2                       = 2,
	-- [3]雕像类型--朱雀  -- 洞府守卫战 
	CONST_DEFENSE_TYPE_3                       = 3,
	-- [4]雕像类型--玄武  -- 洞府守卫战 
	CONST_DEFENSE_TYPE_4                       = 4,

	-- [4]分配开始--周四  -- 洞府守卫战 
	CONST_DEFENSE_WEEK_3                       = 4,
	-- [5]分配结束--周五  -- 洞府守卫战 
	CONST_DEFENSE_WEEK_4                       = 5,

	-- [5]塔--每分钟的伤害系数  -- 洞府守卫战 
	CONST_DEFENSE_ATT_NUM                      = 5,
	-- [7000]奖励系数2  -- 洞府守卫战 
	CONST_DEFENSE_REWARD_NUM_SEC               = 7000,
	-- [42000]奖励系数  -- 洞府守卫战 
	CONST_DEFENSE_REWARD_NUM                   = 42000,

	-- [-2]简单模式怪物等级  -- 洞府守卫战 
	CONST_DEFENSE_EASY_LV                      = -2,
	-- [-1]普通模式怪物等级  -- 洞府守卫战 
	CONST_DEFENSE_COMMON_LV                    = -1,
	-- [1]超难模式怪物等级  -- 洞府守卫战 
	CONST_DEFENSE_HARD_LV                      = 1,

	-- [20]复活时间  -- 洞府守卫战 
	CONST_DEFENSE_RE_TIME                      = 20,

	-- [10]复活花费元宝 -- 洞府守卫战 
	CONST_DEFENSE_RE_MONEY                     = 10,
	-- [10000]个人击杀奖励  -- 洞府守卫战 
	CONST_DEFENSE_ONE_REWARD                   = 10000,

	-- [250]每5秒钟塔受的伤害 -- 洞府守卫战 
	CONST_DEFENSE_5_SEC_HURT                   = 250,

	--------------------------------------------------------------------
	-- ( 洞府战 ) 
	--------------------------------------------------------------------
	-- [0]死亡类型-死亡  -- 洞府战 
	CONST_GANG_WARFARE_TYPE0                   = 0,
	-- [1]死亡类型-复活  -- 洞府战 
	CONST_GANG_WARFARE_TYPE1                   = 1,
	-- [1]赛程-初赛  -- 洞府战 
	CONST_GANG_WARFARE_CENG1                   = 1,
	-- [2]赛程-决赛  -- 洞府战 
	CONST_GANG_WARFARE_CENG2                   = 2,
	-- [5]前5分钟入场  -- 洞府战 
	CONST_GANG_WARFARE_ADVANCE                 = 5,
	-- [10]复活时间秒数  -- 洞府战 
	CONST_GANG_WARFARE_DIE_REC                 = 10,
	-- [10]复活次数  -- 洞府战 
	CONST_GANG_WARFARE_RESURRECTION_TIMES      = 10,
	-- [10]传送限定时间  -- 洞府战 
	CONST_GANG_WARFARE_TRANSFER_TIME           = 10,
	-- [20]活动时间  -- 洞府战 
	CONST_GANG_WARFARE_STARTING                = 20,
	-- [10000]击杀一个人奖励铜币  -- 洞府战 
	CONST_GANG_WARFARE_KILL_REWARD             = 10000,

	-- [61140]帮战地图1-ID  -- 洞府战 
	CONST_GANG_WARFARE_MAP1_ID                 = 61140,
	-- [61141]帮战地图2-ID  -- 洞府战 
	CONST_GANG_WARFARE_MAP2_ID                 = 61141,
	-- [61142]帮战地图3-ID  -- 洞府战 
	CONST_GANG_WARFARE_MAP3_ID                 = 61142,

	-- [60101]关闭传送门1  -- 洞府战 
	CONST_GANG_WARFARE_CLOSE_DOOR1             = 60101,
	-- [60106]关闭传送门2  -- 洞府战 
	CONST_GANG_WARFARE_CLOSE_DOOR2             = 60106,

	-- [2]洞府战人物增加血量  -- 洞府战 
	CONST_GANG_WARFARE_HP_ADD                  = 2,

	--------------------------------------------------------------------
	-- ( 占山为王 ) 
	--------------------------------------------------------------------
	-- [7]防守方血量加成 -- 占山为王 
	CONST_MOUNTAIN_KING_ADDITION_HP            = 7,
	-- [1000]攻击方免伤加成 -- 占山为王 
	CONST_MOUNTAIN_KING_ADDITION_REDUCTION     = 1000,
	-- [2000]攻击方伤害加成 -- 占山为王 
	CONST_MOUNTAIN_KING_ADDITION_DAMAGE        = 2000,

	-- [100]消除cd的花费 -- 占山为王 
	CONST_MOUNTAIN_KING_USE                    = 100,
	-- [300]战斗时间 -- 占山为王 
	CONST_MOUNTAIN_KING_FIGHT_TIME             = 300,
	-- [10800]CD时间 -- 占山为王 
	CONST_MOUNTAIN_KING_CD                     = 10800,

	-- [60170]战斗地图 -- 占山为王 
	CONST_MOUNTAIN_KING_MAP                    = 60170,

	--------------------------------------------------------------------
	-- ( 节日活动 ) 
	--------------------------------------------------------------------
	-- [101]中秋  -- 节日活动 
	CONST_HOLIDAY_MID_AUTUMN                   = 101,
	-- [102]国庆  -- 节日活动 
	CONST_HOLIDAY_NATIONAL_DAY                 = 102,
	-- [103]元旦  -- 节日活动 
	CONST_HOLIDAY_NEW_YEAR                     = 103,
	-- [104]寒假  -- 节日活动 
	CONST_HOLIDAY_WINTER_VACATION              = 104,
	-- [105]春节  -- 节日活动 
	CONST_HOLIDAY_SPRING_FESTIVAL              = 105,
	-- [106]劳动节  -- 节日活动 
	CONST_HOLIDAY_LABOR_DAY                    = 106,
	-- [107]暑假  -- 节日活动 
	CONST_HOLIDAY_SUMMER_VACATION              = 107,
	-- [108]七夕  -- 节日活动 
	CONST_HOLIDAY_JULY                         = 108,

	-- [110]节日-转盘活动  -- 节日活动 
	CONST_HOLIDAY_HOLIDAY_TABLE                = 110,

	-- [3]节日-转盘活动-免费次数  -- 节日活动 
	CONST_HOLIDAY_TABLE_TIMES                  = 3,
	-- [10]节日-转盘活动-花费元宝  -- 节日活动 
	CONST_HOLIDAY_TABLE_COST                   = 10,
	-- [10]节日-转盘活动-活动积分  -- 节日活动 
	CONST_HOLIDAY_TABLE_INTEGRAL               = 10,
	-- [12]节日转盘-珍贵产品  -- 节日活动 
	CONST_HOLIDAY_VALUABLE                     = 12,
	-- [52100]节日-铜钱 -- 节日活动 
	CONST_HOLIDAY_TONGQIAN                     = 52100,

	--------------------------------------------------------------------
	-- ( 一骑当千 ) 
	--------------------------------------------------------------------
	-- [2]每天免费挑战次数  -- 一骑当千 
	CONST_THOUSAND_FREE_TIMES                  = 2,
	-- [3]每天可买次数  -- 一骑当千 
	CONST_THOUSAND_BUY_TIMES                   = 3,
	-- [50]购买次数所需元宝数  -- 一骑当千 
	CONST_THOUSAND_BUY_RMB                     = 50,

	-- [20]排行榜最多显示人数  -- 一骑当千 
	CONST_THOUSAND_MAX_TOP                     = 20,

	-- [21]技能等级  -- 一骑当千 
	CONST_THOUSAND_SKILL_LV                    = 21,

	-- [60001]战斗场景 -- 一骑当千 
	CONST_THOUSAND_MAP                         = 60001,

	--------------------------------------------------------------------
	-- ( 跨服竞技场 ) 
	--------------------------------------------------------------------
	-- [50]加入等级  -- 跨服竞技场 
	CONST_CROSS_JION_LV                        = 50,

	--------------------------------------------------------------------
	-- ( 独尊三界 ) 
	--------------------------------------------------------------------
	-- [0]没参加  -- 独尊三界 
	CONST_TXDY_SUPER_STATE_NO_JOIN             = 0,
	-- [1]小组赛进行中  -- 独尊三界 
	CONST_TXDY_SUPER_STATE_GROUP               = 1,
	-- [2]小组赛结束 -- 独尊三界 
	CONST_TXDY_SUPER_STATE_GROUP_OVER          = 2,
	-- [3]决赛进行中  -- 独尊三界 
	CONST_TXDY_SUPER_STATE_FINAL               = 3,
	-- [4]王者争霸  -- 独尊三界 
	CONST_TXDY_SUPER_STATE_KING                = 4,
	-- [5]全部结束 -- 独尊三界 
	CONST_TXDY_SUPER_STATE_OVER                = 5,
	-- [6]被淘汰 -- 独尊三界 
	CONST_TXDY_SUPER_STATE_OUT                 = 6,
	-- [7]活动入口关闭  -- 独尊三界 
	CONST_TXDY_SUPER_STATE_CLOSE               = 7,

	-- [2000]最大奖励 -- 独尊三界 
	CONST_TXDY_SUPER_MAX_REWARD                = 2000,
	-- [60160]独尊三界场景ID  -- 独尊三界 
	CONST_TXDY_SUPER_MAP_ID                    = 60160,

	-- [10]缓冲时间  -- 独尊三界 
	CONST_TXDY_SUPER_TIME_BUFFER               = 10,
	-- [10]战斗倒计时  -- 独尊三界 
	CONST_TXDY_SUPER_TIME_DAOJISHI             = 10,
	-- [10]等待时间 -- 独尊三界 
	CONST_TXDY_SUPER_TIME_WAIT                 = 10,
	-- [120]战斗时间  -- 独尊三界 
	CONST_TXDY_SUPER_TIME_WAR                  = 120,

	-- [50]报名等级限制  -- 独尊三界 
	CONST_TXDY_SUPER_JOIN_LV                   = 50,

	-- [100]每注元宝数 -- 独尊三界 
	CONST_TXDY_SUPER_PEBBLE_ONCE               = 100,
	-- [5000]初始奖池 -- 独尊三界 
	CONST_TXDY_SUPER_PEBBLE_ALL                = 5000,

	-- [2]猜中1人奖励倍数 -- 独尊三界 
	CONST_TXDY_SUPER_REWARD_ONE                = 2,
	-- [4]猜中2人奖励倍数 -- 独尊三界 
	CONST_TXDY_SUPER_REWARD_TWO                = 4,

	--------------------------------------------------------------------
	-- ( 悬赏任务 ) 
	--------------------------------------------------------------------
	-- [0]任务未接受 -- 悬赏任务 
	CONST_TASK_REWARD_STATE_F                  = 0,
	-- [1]刷新花费  -- 悬赏任务 
	CONST_TASK_REWARD_REF_USE                  = 1,
	-- [1]任务接受未完成 -- 悬赏任务 
	CONST_TASK_REWARD_STATE_S                  = 1,
	-- [2]任务已完成 -- 悬赏任务 
	CONST_TASK_REWARD_STATE_T                  = 2,
	-- [10]每日可完成次数 -- 悬赏任务 
	CONST_TASK_REWARD_MAX_NUM                  = 10,
	-- [20]立刻完成消耗 -- 悬赏任务 
	CONST_TASK_REWARD_FINISH_USE               = 20,
	-- [48000]悬赏令id -- 悬赏任务 
	CONST_TASK_REWARD_REF_GID                  = 48000,

	-- [1.05]奖励基数 -- 悬赏任务 
	CONST_TASK_REWARD_REWARD_JS                = 1.05,
	-- [30]接受最低等级 -- 悬赏任务 
	CONST_TASK_REWARD_ACC_LV                   = 30,

	--------------------------------------------------------------------
	-- ( 对牌 ) 
	--------------------------------------------------------------------
	-- [1]可使用次数 -- 对牌 
	CONST_MATCH_CARD_TIMES_USE                 = 1,
	-- [2]翻一张可使用次数 -- 对牌 
	CONST_MATCH_CARD_TIMES_ONE                 = 2,
	-- [3]翻一对可使用次数 -- 对牌 
	CONST_MATCH_CARD_TIMES_TWO                 = 3,

	-- [10]翻一张消耗 -- 对牌 
	CONST_MATCH_CARD_TIMES_ONE_COST            = 10,
	-- [50]翻一对消耗 -- 对牌 
	CONST_MATCH_CARD_TIMES_TWO_COST            = 50,

	--------------------------------------------------------------------
	-- ( 真元 ) 
	--------------------------------------------------------------------
	-- [1]铜钱加成 -- 真元 
	CONST_WING_TONGQIAN_JIACHENG               = 1,
	-- [2]复活武将 -- 真元 
	CONST_WING_FUHUO_WUJIANG                   = 2,
	-- [3]爆伤加成 -- 真元 
	CONST_WING_BAOSHANG_JIACHENG               = 3,
	-- [4]移动速度 -- 真元 
	CONST_WING_YIDONG_SUDU                     = 4,
	-- [5]蓝条回复 -- 真元 
	CONST_WING_LANTIAO_HUIFU                   = 5,
	-- [6]经验加成 -- 真元 
	CONST_WING_JINGYAN_JIACHENG                = 6,
	-- [7]血量恢复 -- 真元 
	CONST_WING_XUELIANG_HUIFU                  = 7,
	-- [8]复活主角 -- 真元 
	CONST_WING_FUHUO_ZHUJUE                    = 8,
	-- [10]强化最高星级 -- 真元 
	CONST_WING_MAX_STAR                        = 10,
	-- [54000]强化真元消耗 -- 真元 
	CONST_WING_COST_GOODS                      = 54000,

	--------------------------------------------------------------------
	-- ( 人物升级奖励 ) 
	--------------------------------------------------------------------
	-- [1]初始化最少等级要求 -- 人物升级奖励 
	CONST_LV_REWARD_INIT_LV                    = 1,

	-- [0]非自动 -- 人物升级奖励 
	CONST_LV_REWARD_UN_AUTO                    = 0,
	-- [1]自动 -- 人物升级奖励 
	CONST_LV_REWARD_AUTO                       = 1,

	-- [1]不可领取 -- 人物升级奖励 
	CONST_LV_REWARD_STATE1                     = 1,
	-- [2]可领取 -- 人物升级奖励 
	CONST_LV_REWARD_STATE2                     = 2,

	--------------------------------------------------------------------
	-- ( 月卡 ) 
	--------------------------------------------------------------------
	-- [1]充值30购买月卡 -- 月卡 
	CONST_MONTH_CARD_TYPE1                     = 1,
	-- [2]充值188购买终身卡 -- 月卡 
	CONST_MONTH_CARD_TYPE2                     = 2,

	-- [0]不可领取 -- 月卡 
	CONST_MONTH_CARD_STATE2                    = 0,
	-- [1]可领取 -- 月卡 
	CONST_MONTH_CARD_STATE1                    = 1,

	-- [250]月卡价格(仙玉) -- 月卡 
	CONST_MONTH_CARD_MONEY1                    = 250,
	-- [1280]终身卡价格(仙玉) -- 月卡 
	CONST_MONTH_CARD_MONEY2                    = 1280,

	--------------------------------------------------------------------
	-- ( 红包 ) 
	--------------------------------------------------------------------
	-- [5]积分乘的倍数 -- 红包 
	CONST_HONG_BAO_MULTIPLE                    = 5,
	-- [999]每天最大可抢次数 -- 红包 
	CONST_HONG_BAO_MAX                         = 999,
	-- [10000]红包逗留时间(毫秒) -- 红包 
	CONST_HONG_BAO_TIME_MAX                    = 10000,

	--------------------------------------------------------------------
	-- ( 精彩活动转盘 ) 
	--------------------------------------------------------------------
	-- [1]放回式转盘物品消耗数量 -- 精彩活动转盘 
	CONST_ART_ZHUANPAN_UNLIMIT_COST            = 1,
	-- [1]不放回式转盘物品消耗数量 -- 精彩活动转盘 
	CONST_ART_ZHUANPAN_LIMIT_COST              = 1,
	-- [10]放回式转盘抽奖物品数量 -- 精彩活动转盘 
	CONST_ART_ZHUANPAN_UNLIMIT_NUM             = 10,
	-- [12]不放回式转盘抽奖物品数量 -- 精彩活动转盘 
	CONST_ART_ZHUANPAN_LIMIT_NUM               = 12,

	--------------------------------------------------------------------
	-- ( 降魔之路 ) 
	--------------------------------------------------------------------
	-- [2]战斗时间（分） -- 降魔之路 
	CONST_SURRENDER_TIME                       = 2,
	-- [10]属性加成百分比 -- 降魔之路 
	CONST_SURRENDER_PLUS_PERCENT               = 10,

	--------------------------------------------------------------------
	-- ( 神羽 ) 
	--------------------------------------------------------------------
	-- [44000]神羽升级物品ID -- 神羽 
	CONST_FEATHER_GOODS_ID_LV_UP               = 44000,
	-- [44005]神羽升阶物品ID -- 神羽 
	CONST_FEATHER_GOODS_ID_SJ_UP               = 44005,

	--------------------------------------------------------------------
	-- ( 秘宝 ) 
	--------------------------------------------------------------------
	-- [20]秘宝活动人物复活时间 -- 秘宝 
	CONST_MIBAO_REVIVE_TIME                    = 20,
	-- [20]秘宝活动复活元宝数 -- 秘宝 
	CONST_MIBAO_REVIVE_RMB                     = 20,

	-- [30]物品拥有者刷新时间 -- 秘宝 
	CONST_MIBAO_GOODS_REFRESH_TIME             = 30,
	-- [30]箱子拥有者刷新时间 -- 秘宝 
	CONST_MIBAO_BOX_REFRESH_TIME               = 30,
	-- [30]怪物拥有者刷新时间 -- 秘宝 
	CONST_MIBAO_MONSTER_REFRESH_TIME           = 30,

	-- [27]活动开放等级 -- 秘宝 
	CONST_MIBAO_LV                             = 27,

	--------------------------------------------------------------------
	-- ( 铜钱副本 ) 
	--------------------------------------------------------------------
	-- [30]活动开放等级 -- 铜钱副本 
	CONST_MONEY_LV                             = 30,

	--------------------------------------------------------------------
	-- ( 灵妖岛 ) 
	--------------------------------------------------------------------
	-- [1]灵 -- 灵妖岛 
	CONST_PAR_ARENA_LING                       = 1,
	-- [2]生 -- 灵妖岛 
	CONST_PAR_ARENA_SHENG                      = 2,
	-- [3]暗 -- 灵妖岛 
	CONST_PAR_ARENA_AN                         = 3,
	-- [4]幻 -- 灵妖岛 
	CONST_PAR_ARENA_HUAN                       = 4,
	-- [5]每次购买增加金额 -- 灵妖岛 
	CONST_PAR_ARENA_TIMES_GOLD                 = 5,
	-- [10]最多购买次数 -- 灵妖岛 
	CONST_PAR_ARENA_MAX_TIMES                  = 10,
	-- [10]克制 -- 灵妖岛 
	CONST_PAR_ARENA_KEZHI                      = 10,
	-- [120]战斗时间 -- 灵妖岛 
	CONST_PAR_ARENA_BATTLE_TIME                = 120,

	--------------------------------------------------------------------
	-- ( 道劫 ) 
	--------------------------------------------------------------------
	-- [1]等级 -- 道劫 
	CONST_DAOJIE_DENGJI                        = 1,
	-- [2]饰品 -- 道劫 
	CONST_DAOJIE_SHIPIN                        = 2,
	-- [3]元魄 -- 道劫 
	CONST_DAOJIE_YUANPO                        = 3,
	-- [4]八卦 -- 道劫 
	CONST_DAOJIE_BAGUA                         = 4,
	-- [4]扫荡次数 -- 道劫 
	CONST_DAOJIE_SAODANG                       = 4,
	-- [5]灵妖 -- 道劫 
	CONST_DAOJIE_LINGYAO                       = 5,
	-- [6]坐骑 -- 道劫 
	CONST_DAOJIE_ZUOQI                         = 6,
	-- [7]宠物 -- 道劫 
	CONST_DAOJIE_CHONGWU                       = 7,
	-- [8]神器 -- 道劫 
	CONST_DAOJIE_SHENQI                        = 8,
	-- [9]翅膀 -- 道劫 
	CONST_DAOJIE_CHIBANG                       = 9,
	-- [10]武器 -- 道劫 
	CONST_DAOJIE_WUQI                          = 10,
	-- [11]战力 -- 道劫 
	CONST_DAOJIE_ZHANLI                        = 11,
	-- [12]五行 -- 道劫 
	CONST_DAOJIE_WUXING                        = 12,
	-- [13]宝石 -- 道劫 
	CONST_DAOJIE_BAOSHI                        = 13,

	--------------------------------------------------------------------
	-- ( 成就 ) 
	--------------------------------------------------------------------
	-- [1]角色成就-角色等级 -- 成就 
	CONST_CHENGJIU_JUESE                       = 1,
	-- [2]技能成就-技能总等级 -- 成就 
	CONST_CHENGJIU_JINENG                      = 2,
	-- [3]经脉成就-经脉等阶 -- 成就 
	CONST_CHENGJIU_JINGMAI                     = 3,
	-- [4]团队成就-合战群魔挑战次数 -- 成就 
	CONST_CHENGJIU_TUANDUI                     = 4,
	-- [5]道劫成就-道劫层数 -- 成就 
	CONST_CHENGJIU_DAOJIE                      = 5,
	-- [6]妖塔成就-锁妖塔层数 -- 成就 
	CONST_CHENGJIU_YAOTA                       = 6,
	-- [7]试炼成就-轮回试炼通关次数 -- 成就 
	CONST_CHENGJIU_SHILIAN                     = 7,
	-- [8]伤害成就-斗转星移最高伤害 -- 成就 
	CONST_CHENGJIU_SHANGHAI                    = 8,
	-- [9]世界成就-勾魂使者参加次数 -- 成就 
	CONST_CHENGJIU_SHIJIE                      = 9,
	-- [10]妖兽成就-讨伐妖兽参加次数 -- 成就 
	CONST_CHENGJIU_YAOSHOU                     = 10,
	-- [11]第一门派-第一门派挑战次数 -- 成就 
	CONST_CHENGJIU_DIYI                        = 11,
	-- [12]门派大战-门派参加次数 -- 成就 
	CONST_CHENGJIU_MENPAI                      = 12,
	-- [13]贡献成就-门派总贡献 -- 成就 
	CONST_CHENGJIU_GONGXIAN                    = 13,
	--/** =============================== 自动生成的代码 =============================== **/
	--/*************************** don't touch this line *********** AUTO_CODE_END_Const **/
    
    
    
}