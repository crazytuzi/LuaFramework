local preEnv;
-- 两种模式下通用定义
if ImperialTomb then --调试需要
	preEnv = _G;	--保存旧的环境
	setfenv(1, ImperialTomb)
end

OPEN_TIME_FRAME = "OpenDay89"
FEMALE_EMPEROR_TIME_FRAME = "OpenLevel129Add10"

EMPEROR_NEED_ITEM = 2840; --参加活动门票
EMPEROR_ADD_TIME = 995121; --增加活动时间
EVERY_DAY_STAY_TIME_ADD = 60 * 60; --额外增加时间

EMPEROR_TICKET_COUNT =
{
	[false] = 1, --秦始皇
	[true] = 2, --武则天
}
MIN_LEVEL = 60; -- 参加等级下限
FEMALE_EMPEROR_MIN_LEVEL = 80; -- 参加等级下限
EMPEROR_COUNT = 3; --秦始皇数量
BOSS_COUNT = 9; --首领数量
FEMALE_EMPEROR_BOSS_COUNT = 6; --首领数量
EMPEROR_INVITE_TIME = 35 * 60 --秦始皇通知持续时间
SECRET_INVITE_TIME = 1 * 60 --密室通知持续时间
EMPEROR_EXSIT_TIME = 35 * 60 --秦始皇房间存在时间（秒）
BOSS_EXSIT_TIME = 30 * 60 --1、2、3层首领存在时间（秒）
EMPEROR_END_DELAY_TIME = 30 --秦始皇结束传送时间（秒）
UPDATE_SYNC_DMG_INTERVAL = 30 --更新实时伤害排行间隔
BOSS_SYNC_DMG_COUNT = 5 --首领实时伤害排行显示数量
EMPEROR_SYNC_DMG_COUNT = 20 --秦始皇实时伤害排行显示数量
EMPEROR_AWARD_RANK_COUNT = 20 --秦始皇排行奖励最大的名次
BOSS_AWARD_RANK_COUNT = 5 --首领排行奖励最大的名次
EMPEROR_AWARD_ID = 1 --秦始皇排行奖励ID
FEMALE_EMPEROR_AWARD_ID = 5 --武则天排行奖励ID
EMPEROR_DEFAULT_AWARD_ITEM = --秦始皇保底奖励道具
{
	["OpenDay1"] = {{nItemTemplateId = 2804, nRate = 1}},
	["OpenDay204"] = {
		{nItemTemplateId = 2804, nRate = 0.83},--和氏璧
		{nItemTemplateId = 3554, nRate = 0.15, szGuaranteeKey = "Imperial_Emperor_3554_Default"},--同伴·秦始皇
		{nItemTemplateId = 1396, nRate = 0.01},--帝皇令
		{nItemTemplateId = 1397, nRate = 0.01},--传说令
	},
}

FEMALE_EMPEROR_DEFAULT_AWARD_ITEM = --武则天保底奖励道具
{
	["OpenDay1"] = {{nItemTemplateId = 2804, nRate = 1}},
	["OpenLevel129"] = {
		{nItemTemplateId = 2804, nRate = 0.83},--和氏璧
		{nItemTemplateId = 3555, nRate = 0.15, szGuaranteeKey = "Imperial_Emperor_3555_Default"},--同伴·武则天
		{nItemTemplateId = 1396, nRate = 0.01},--帝皇令
		{nItemTemplateId = 1397, nRate = 0.01},--传说令
	},
}

EMPEROR_AWARD_PARAM = 10
EMPEROR_DEFAULT_AWARD_ITEM_VALUE =
{
	[false] = 84000 * EMPEROR_AWARD_PARAM, --秦始皇保底奖励道具价值
	[true] = 84000 * EMPEROR_AWARD_PARAM, --武则天保底奖励道具价值
}
EMPEROR_MAX_PLAYER_VALUE =
{
	[false] = 250000 * EMPEROR_AWARD_PARAM, --秦始皇单人最高价值
	[true] = 250000 * EMPEROR_AWARD_PARAM, --武则天单人最高价值
}

BOSS_MAX_PLAYER_VALUE =
{
	[false] = 250000 * EMPEROR_AWARD_PARAM, --秦始皇首领单人最高价值
	[true] = 250000 * EMPEROR_AWARD_PARAM, --武则天首领单人最高价值
}

--传送技能
EMPEROR_MIRROR_WARNING_SKILL =
{
	[false] = 3083,
	[true] = 4858,
}

--传送后无敌
EMPEROR_MIRROR_SKILL =
{
	[false] = 3069,
	[true] = 3069,
}

--秒杀技能特效
EMPEROR_SWEEP_EFFECT_SKILL = 
{
	[false] = 3082,
	[true] = 4859,
}

--秒杀技能
EMPEROR_SWEEP_SKILL = 
{
	[false] = 3076,
	[true] = 4856,
}

FIRST_LAST_DMG_BONUS = 3; --秦始皇首摸和最后一击额外血量百分比
DMG_PERCENT_FACTOR = 1 / 1.18; -- 秦始皇血量的百分比参数
MIN_DMG_PERCENT = 1; --最少血量百分比

BOSS_FIRST_LAST_DMG_BONUS = 10; --首领首摸和最后一击额外血量百分比
BOSS_DMG_PERCENT_FACTOR = 1 / 1.2; -- 首领血量的百分比参数

ALLOW_ENTER_TIME = {"10:00", "23:59"}; --每天允许进入皇陵的时间

EVERY_DAY_STAY_TIME = 60 * 60; --每天累计进入时间(单位:秒)
MAX_STAY_TIME = 7 * 30 * 60; --最多累计时间(单位:秒)
EVERY_DAY_REFRESH_TIME = "4:00"; --每天更新累计时间

SAVE_GROUP = 49
LAST_REFRESH_TIME_KEY = 10
TOTAL_STAY_TIME_KEY = 11
LAST_ENTER_SECRET_TIME = 12
ENTER_SECRET_DAILY_COUNT = 13

SECRET_ROOM_SPAWN_INTERVAL = 3 * 60; --密室刷新间隔(单位:秒)
SECRET_ROOM_INVITE_RATE = 12000; --密室概率12%
PROTECT_TIME = 3 * 60; --PK保护时间(单位:秒)
SECRET_ROOM_STAY_TIME = 10 * 60; --密室停留时间(单位:秒)
SECRET_ROOM_MAX_PLAYER = 24; --密室里最大的玩家人数
SECRET_ROOM_INVITE_TIME_OUT = 60; --密室邀请过期时间(单位:秒)
SECRET_ROOM_COUNT_LIMIT = 3; --密室进入周期进入次数
SECRET_ROOM_COUNT_TIME_LIMIT = 15 * 60; --密室进入时间重置周期

CHECK_STAY_INTERVAL = 60; --检查时间是否用完的时间间隔(单位:秒)

PICK_BOX_TIME = 45; --密室宝箱拾取时间（单位：秒）
BOX_AWARD_ID = 2843; --密室宝箱ID

STAY_TIME_BUFF = 2311; --查看皇陵停留时间BUFF
PROTECT_TIME_BUFF = 2312; --查看密室保护时间BUFF

AUTO_FIGHT_RADIUS = 600 --皇陵中自动战斗搜索范围

MIRROR_DMG_SYNC_INTERVAL = 5 --秦始皇分身伤害同步间隔
MIRROR_MAP_EXIST_TIME = 5 * 60 --秦始皇分身地图存在时间
MIRROR_TRANS_INTERVAL = 1 * 30 --分身阶段传送时间间隔
MIRROR_SKILL_INTERVAL = 9 --分身阶段技能时间间隔
MIRROR_MAP_MAX_PLAYER = 8
MIRROR_DEATH_WAIT_TIME = 10 --死亡复活时间

--进入密室成就
ENTER_SECRET_DAILY_ACHIV =
{
	{"ImperialTomb_Hole_1", 1},
	{"ImperialTomb_Hole_2", 3},
	{"ImperialTomb_Hole_3", 5},
	{"ImperialTomb_Hole_4", 10},
	{"ImperialTomb_Hole_5", 20},
}

MAP_TYPE = 
{
	FIRST_FLOOR = 1,
	SECOND_FLOOR = 2,
	THIRD_FLOOR = 3,
	SECRET_ROOM_FIRST_FLOOR = 4,
	SECRET_ROOM_SECOND_FLOOR = 5,
	SECRET_ROOM_THIRD_FLOOR = 6,
	BOSS_ROOM = 7,
	EMPEROR_ROOM= 8,
	EMPEROR_MIRROR_ROOM= 9,
	FEMALE_EMPEROR_FLOOR = 10,
	FEMALE_EMPEROR_BOSS_ROOM = 11,
	FEMALE_EMPEROR_ROOM= 12,
	FEMALE_EMPEROR_MIRROR_ROOM= 13,
}

MAP_TEMPLATE_ID = 
{
	[MAP_TYPE.FIRST_FLOOR] = 1100,
	[MAP_TYPE.SECOND_FLOOR] = 1101,
	[MAP_TYPE.THIRD_FLOOR] = 1102,
	[MAP_TYPE.SECRET_ROOM_FIRST_FLOOR] = 1103,
	[MAP_TYPE.SECRET_ROOM_SECOND_FLOOR] = 1104,
	[MAP_TYPE.SECRET_ROOM_THIRD_FLOOR] = 1105,
	[MAP_TYPE.BOSS_ROOM] = 1107,
	[MAP_TYPE.EMPEROR_ROOM] = 1106,
	[MAP_TYPE.EMPEROR_MIRROR_ROOM] = 1108,
	[MAP_TYPE.FEMALE_EMPEROR_FLOOR] = 1110,
	[MAP_TYPE.FEMALE_EMPEROR_BOSS_ROOM] = 1111,
	[MAP_TYPE.FEMALE_EMPEROR_ROOM] = 1112,
	[MAP_TYPE.FEMALE_EMPEROR_MIRROR_ROOM] = 1113,
}

NORMAL_FLOOR_2_SECRET_ROOM = 
{
	[MAP_TYPE.FIRST_FLOOR] = MAP_TYPE.SECRET_ROOM_FIRST_FLOOR,
	[MAP_TYPE.SECOND_FLOOR] = MAP_TYPE.SECRET_ROOM_SECOND_FLOOR,
	[MAP_TYPE.THIRD_FLOOR] = MAP_TYPE.SECRET_ROOM_THIRD_FLOOR,
}

SECRET_ROOM_2_NORMAL_FLOOR = 
{
	[MAP_TYPE.SECRET_ROOM_FIRST_FLOOR] = MAP_TYPE.FIRST_FLOOR,
	[MAP_TYPE.SECRET_ROOM_SECOND_FLOOR] = MAP_TYPE.SECOND_FLOOR,
	[MAP_TYPE.SECRET_ROOM_THIRD_FLOOR] = MAP_TYPE.THIRD_FLOOR,
}

FEMALE_EMPEROR_FLOOR_ENTER_POS = 
{
	{3500, 13700},
	{17000, 4800},
	{3500, 6000},
	{14000, 16000},
}

BOSS_INFO = 
{
	{nTemplate = 1875, nX = 4800, nY = 3500, nTitleId = 500},
	{nTemplate = 1876, nX = 4800, nY = 3500, nTitleId = 501},
	{nTemplate = 1877, nX = 4800, nY = 3500, nTitleId = 502},
	{nTemplate = 1875, nX = 4800, nY = 3500, nTitleId = 500},
	{nTemplate = 1876, nX = 4800, nY = 3500, nTitleId = 501},
	{nTemplate = 1877, nX = 4800, nY = 3500, nTitleId = 502},
	{nTemplate = 1875, nX = 4800, nY = 3500, nTitleId = 500},
	{nTemplate = 1876, nX = 4800, nY = 3500, nTitleId = 501},
	{nTemplate = 1877, nX = 4800, nY = 3500, nTitleId = 502},
}

FEMALE_EMPEROR_BOSS_INFO = 
{
	{nTemplate = 2510, nX = 5000, nY = 3500, nTitleId = 505},
	{nTemplate = 2511, nX = 5000, nY = 3500, nTitleId = 506},
	{nTemplate = 2512, nX = 5000, nY = 3500, nTitleId = 507},
	{nTemplate = 2510, nX = 5000, nY = 3500, nTitleId = 505},
	{nTemplate = 2511, nX = 5000, nY = 3500, nTitleId = 506},
	{nTemplate = 2512, nX = 5000, nY = 3500, nTitleId = 507},
	{nTemplate = 2510, nX = 5000, nY = 3500, nTitleId = 505},
	{nTemplate = 2511, nX = 5000, nY = 3500, nTitleId = 506},
	{nTemplate = 2512, nX = 5000, nY = 3500, nTitleId = 507},
}

--首领排行奖励ID
BOSS_AWARD_ID = 
{
	[1875] = 2,
	[1876] = 3,
	[1877] = 4,

	[2510] = 6,
	[2511] = 7,
	[2512] = 8,
}

--密室首领排行奖励ID
NORMAL_BOSS_AWARD_ID = 
{
	[1835] = 1,
	[1836] = 2,
	[1837] = 3,
}

EMPEROR_INFO= {nTemplate = 1838, nX = 6350, nY = 4070, nTitleId = 503}
EMPEROR_MIRROR_INFO= {nTemplate = 1955, nX = 4800, nY = 3500, nTitleId = 504}
EMPEROR_SWEEP_INFO= {nTemplate = 1956, nX = 5000, nY = 4050}


FEMALE_EMPEROR_INFO= {nTemplate = 2509, nX = 10500, nY = 7000, nTitleId = 508}
FEMALE_EMPEROR_MIRROR_INFO= {nTemplate = 2513, nX = 5500, nY = 3400, nTitleId = 509}
FEMALE_EMPEROR_SWEEP_INFO= {nTemplate = 2530, nX = 10980, nY = 6980}

NPC_TIME_FRAME_LEVEL = 
{
	["OpenLevel39"] = 55, 
	["OpenLevel59"] = 55, 
	["OpenLevel69"] = 65, 
	["OpenLevel79"] = 75, 
	["OpenLevel89"] = 85, 
	["OpenLevel99"] = 95, 
	["OpenLevel109"] = 105,
	["OpenLevel119"] = 115,
	["OpenLevel129"] = 125,
	["OpenLevel139"] = 135, 
	["OpenLevel149"] = 145, 
	["OpenLevel159"] = 155,    
};

NOMAL_FLOOR_DEFAULT_POS = 
{
	[MAP_TYPE.FIRST_FLOOR] = {nX = 8000, nY = 5750},
	[MAP_TYPE.SECOND_FLOOR] = {nX = 6000, nY = 5650},
	[MAP_TYPE.THIRD_FLOOR] = {nX = 5100, nY = 6150},
	[MAP_TYPE.FEMALE_EMPEROR_FLOOR] = {nX = 3500, nY = 13700},
}

EMPEROR_ROOM_TRAP_POS = 
{
	{8600, 6640},
	{9000, 2300},
	{2150, 8450},
}

BOSS_ROOM_TRAP_POS = 
{
	[MAP_TYPE.FIRST_FLOOR] = 
	{
		{8860, 12010},
		{3850, 6360},
		{11880, 3760},
	},

	[MAP_TYPE.SECOND_FLOOR] = 
	{
		{9660, 3650},
		{400, 2310},
		{10060, 8660},
	},

	[MAP_TYPE.THIRD_FLOOR] = 
	{
		{1500, 3270},
		{6090, 1570},
		{6400, 4920},
	},
}


FEMALE_EMPEROR_BOSS_ROOM_TRAP_POS = 
{
	{
		{9570, 15308, 1},
		{12530, 13360, 2},
		{16547, 12784, 3},
	},

	{
		{7288, 4492, 4},
		{7207, 6823, 5},
		{4683, 9561, 6},
	},

	{
		{5468, 11333, 7},
		{6747, 12420, 8},
		{8135, 16087, 9},
	},

	{
		{16600, 9400, 10},
		{13800, 5800, 11},
		{11775, 5401, 12},
	},
}

FEMALE_EMPEROR_ROOM_TRAP_POS = 
{
	{8265, 12578},
	{13760, 8988},
	{9169, 9502},
	{11795, 11008},
}

SECRET_ROOM_POS_TYPE = 
{
	MINION = 1,
	LEADER = 2,
	BOX = 3,
}

SECRET_ROOM_NPC = 
{
	--盗墓贼*1
	{
		nRate = 23000,
		nPosType = SECRET_ROOM_POS_TYPE.MINION,
		nTemplate = 1878,
		nCount = 1,
	},
	--盗墓贼*2
	{
		nRate = 23000,
		nPosType = SECRET_ROOM_POS_TYPE.MINION,
		nTemplate = 1878,
		nCount = 2,
	},
	--盗墓贼*3
	{
		nRate = 15000,
		nPosType = SECRET_ROOM_POS_TYPE.MINION,
		nTemplate = 1878,
		nCount = 3,
	},
	--盗墓贼*5
	{
		nRate = 6000,
		nPosType = SECRET_ROOM_POS_TYPE.MINION,
		nTemplate = 1878,
		nCount = 5,
	},
	--盗墓贼头领
	{
		nRate = 10000,
		nPosType = SECRET_ROOM_POS_TYPE.MINION,
		nTemplate = 1874,
		nCount = 1,
	},
	--地宫首领
	{
		nRate = 4000,
		nPosType = SECRET_ROOM_POS_TYPE.LEADER,
		nTemplate = 
		{
			[MAP_TYPE.SECRET_ROOM_FIRST_FLOOR] = 1835,
			[MAP_TYPE.SECRET_ROOM_SECOND_FLOOR] = 1836,
			[MAP_TYPE.SECRET_ROOM_THIRD_FLOOR] = 1837,
		},
		nCount = 1,
	},
	--宝箱
	{
		nRate = 19000,
		nPosType = SECRET_ROOM_POS_TYPE.BOX,
		nTemplate = 1879,
		nCount = 1,
	},
}

SECRET_ROOM_POS = 
{
	--盗墓贼,盗墓贼头领
	[SECRET_ROOM_POS_TYPE.MINION] = 
	{
		{{3550,4620}, {5200,4400}},
		{{3500,2780}, {5060,2530}},
	},
	--地宫首领
	[SECRET_ROOM_POS_TYPE.LEADER] = 
	{
		{{4300,3930}, {5110,3170}},
	},
	--宝箱
	[SECRET_ROOM_POS_TYPE.BOX] = 
	{
		{{3570,3930}, {4040,3170}},
	},
}

BOSS_STATUS = 
{
	NONE = 0,
	EXSIT = 1,
	DEAD = 2,
}

--全屏秒杀技能释放血量
EMPEROR_SWEEP_HP = 
{
	96,
	93,
	52,
	48,
	5,
}

--镜像房间进入血量
EMPEROR_MIRROR_HP = 
{
	{90,55},
	{45,10},
}

--满概率
EMPEROR_SWEEP_RATE = 
{
	100000,
	50000,
	35000,
	20000,
	20000,
	20000,
	20000,
	20000,
	20000,
	20000,		--10
	20000,
	20000,
	20000,
	20000,
	20000,		--15
	20000,
	20000,
	20000,
	20000,
	20000,		--20
	}

--女帝疑冢安全区名字(对应4个武则天 Trap点id)
FEMALE_EMPEROR_SAFE_ZONE_NAME = 
{
	"西·白虎",
	"东·青龙",
	"南·朱雀",
	"北·玄武",
}

--女帝疑冢安全区名字(对应12个Boss Trap点id)
FEMALE_EMPEROR_BOSS_SAFE_ZONE_NAME = 
{
	FEMALE_EMPEROR_SAFE_ZONE_NAME[4],
	FEMALE_EMPEROR_SAFE_ZONE_NAME[4],
	FEMALE_EMPEROR_SAFE_ZONE_NAME[4],

	FEMALE_EMPEROR_SAFE_ZONE_NAME[3],
	FEMALE_EMPEROR_SAFE_ZONE_NAME[3],
	FEMALE_EMPEROR_SAFE_ZONE_NAME[3],

	FEMALE_EMPEROR_SAFE_ZONE_NAME[1],
	FEMALE_EMPEROR_SAFE_ZONE_NAME[1],
	FEMALE_EMPEROR_SAFE_ZONE_NAME[1],

	FEMALE_EMPEROR_SAFE_ZONE_NAME[2],
	FEMALE_EMPEROR_SAFE_ZONE_NAME[2],
	FEMALE_EMPEROR_SAFE_ZONE_NAME[2],
}

FEMALE_EMPEROR_BOSS_TRAP_2_ENTER_INDEX = 
{
	4,4,4,
	3,3,3,
	1,1,1,
	2,2,2,
}

EMPEROR_PREPARE_MSG = 
{
	[false] = {
		szTitle="秦始皇",
		szContent = "诸位侠士，通往秦始皇陵深处的通道已被发现，诸位可火速前往，占得先机。",
		},
	[true] = {
		szTitle="女帝复苏",
		szContent = "诸位侠士，通往女帝疑冢深处的通道已被发现，诸位可火速前往，占得先机。",
		},
}


EMPEROR_ROOM_RECORD_MSG = 
{
	[false] = "秦始皇在你身上施加了印记，你无法进入其他[FFFE0D]【永生台】[-]！",
	[true] =  "玄武门竟忽然闭合，侠士本次女帝疑冢之旅，无法再前往其他[FFFE0D]【天后神都】[-]！",
}

EMPEROR_TICKET_MSG = 
{
	[false] = "秦始皇重现于世，墓中毒雾更甚，不可视物，请先寻找[FFFE0D]%s颗夜明珠[-]",
	[true] =  "女帝复苏，疑冢阴云密布，不可视物，难觅其踪，需备[FFFE0D]%s颗夜明珠[-]",
}

EMPEROR_BOSS_CALL_MSG = 
{
	[false] = "诸位侠士，秦始皇陵三层均出现暴动，秦之栋梁重生，可速速寻找入口，将之剿灭",
	[true] =  "诸位侠士，疑冢中有若干路口已然开启，幽暗隐秘，不知通往何处，可速速前去一探",
}

EMPEROR_CALL_MSG = 
{
	[false] = "如今天时已到，始皇已然苏醒，在皇陵最深处等待诸位觐见，还请诸位侠士通过三层入口前往永生台",
	[true] =  "如今天时已到，女帝已然复苏，降临于世，还请诸位找到真正的行宫入口，使之安息",
}


EMPEROR_WRONG_ENTRY_MSG = 
{
	[false] = "只能前往本场始皇降世首次进入的[FFFE0D]【永生台】[-]",
	[true] =  "玄武门已关闭，只能前往本场女帝复苏首次进入的[FFFE0D]【天后神都】[-]",
}

EMPEROR_SWEEP_MSG = 
{
	[false] = "尔等鼠辈竟以下犯上，区区蝼蚁，准备承受寡人的怒火吧！",
	[true] =  "朕玩腻了！不容尔等贱民在朕的行宫放肆！瀚海！驱逐他们！",
}

EMPEROR_TRANS_MSG = 
{
	[false] = "兵不厌诈，尔等入侵者，都到寡人精心设计的房间中化为灰烬吧！",
	[true] =  "有趣，许久未出现这样的情绪了，朕带你们去个更有趣的地方吧！",
}

EMPEROR_MIRROR_IN_MSG = 
{
	[false] = "皇陵中竟设有疑冢，伪帝同样身怀重宝，尽可能击败他寻找出路！",
	[true] =  "无即是有，有即是无，虚幻真假，天象难测！尔等岂能窥破天机？",
}

EMPEROR_MIRROR_OUT_MSG = 
{
	[false] = "诸位侠士成功破解疑冢，始皇遭受重创，可乘机乘胜追击！",
	[true] =  "诸位侠士成功从[FFFE0D]赝雀宫[-]脱身，需乘胜追击，不让女帝有喘息之机",
}

BOSS_RANK_TIPS = preEnv.XT([[奖励规则：
·输出排名进入前5的家族，可获得奖励
·奖励获得的多少，与输出的占比相关
·玄天武机、白起、李斯每只独立计算输出
·首次攻击以及最后一击有额外的奖励加成]])

FEMALE_BOSS_RANK_TIPS = preEnv.XT([[奖励规则：
·输出排名进入前5的家族，可获得奖励
·奖励获得的多少，与输出的占比相关
·无字碑、元芳、狄仁杰每只独立计算输出
·首次攻击以及最后一击有额外的奖励加成]])


EMPEROR_RANK_TIPS = preEnv.XT([[奖励规则：
·输出排名进入前20的家族，可获得奖励
·奖励获得的多少，与总输出的占比相关
·三位秦始皇均被击败后将合并计算总输出
·首次攻击以及最后一击有额外的奖励加成]])

FEMALE_EMPEROR_RANK_TIPS = preEnv.XT([[奖励规则：
·输出排名进入前20的家族，可获得奖励
·奖励获得的多少，与总输出的占比相关
·三位武则天均被击败后将合并计算总输出
·首次攻击以及最后一击有额外的奖励加成]])

if preEnv then
	preEnv.setfenv(1, preEnv); --恢复全局环境
end
