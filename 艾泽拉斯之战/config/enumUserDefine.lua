
enum.SKILL_CALLBACK_TYPE = {
	SCT_INVALID = -1, -- null
	SCT_SKILL_COMMON = 0, -- skill common
	SCT_MAGIC_COMMON = 1, -- magic common
	SCT_SKIILL_CONSECUTIVE = 2, -- skill consecutive
}

--globalenumdef 客户端枚举，比服务器+1
enum.Adventure_TYPE = {

	NORMAL = 1,
	ELITE = 2,
}

enum.SEC_PER_DAY = 24*60*60;
enum.SEC_PER_HOUR = 60*60;
enum.SEC_PER_MIN = 60;

enum.TIME_UNIT = 100000;

enum.unitMoveTypeMap = {
	[0] = "(陆地)",
	[1] = "(飞行)",
	[2] = "(闪烁)",
};

enum.unitMoveTypeImageMap = {
	[0] = "set:type.xml image:walk",
	[1] = "set:type.xml image:fly",
	[2] = "set:type.xml image:walk",
};

enum.unitDamageTypeMap = {
	[0] = "(普通)",
	[1] = "(穿刺)",
	[2] = "(法术)",
	[255] = "(真实伤害)", 
};

enum.unitDamageTypeImageMap = {
	[0] = "set:type.xml image:narmal",
	[1] = "set:type.xml image:pierce",
	[2] = "set:type.xml image:magic",
	[255] = "set:type.xml image:narmal", 
};

enum.unitIsRangeMap = {
	[0] = "(近战)",
	[1] = "(远程)",
};

enum.unitIsRangeImageMap = {
	[0] = "set:type.xml image:melee",
	[1] = "set:type.xml image:missile",
};

enum.BUILD_TYPE_TEXT = {
	[0] = "城堡",
	[1] = "金矿",
	[2] = "伐木场",
	[3] = "法师塔",
}

enum.BUY_RESOURCE_TYPE = {};
enum.BUY_RESOURCE_TYPE.GOLD = 0;
enum.BUY_RESOURCE_TYPE.WOOD = 1;
enum.BUY_RESOURCE_TYPE.VIGOR = 2;
enum.BUY_RESOURCE_TYPE.RESET_COPY = 3;
enum.BUY_RESOURCE_TYPE.EXP = 4;
enum.BUY_RESOURCE_TYPE.MAGIC = 5;
enum.BUY_RESOURCE_TYPE.PLUNDER_TIMES = 6;
enum.BUY_RESOURCE_TYPE.PROTECT_TIME = 7;
enum.BUY_RESOURCE_TYPE.GUILD_WAR_INSPIRE_ATTACK = 8;
enum.BUY_RESOURCE_TYPE.GUILD_WAR_INSPIRE_DEFENCE = 9;
enum.BUY_RESOURCE_TYPE.GUILD_WAR_BATTLE = 10;

enum.MESSAGE_BOX_TYPE = {
	ERROR = -1,
	COMMON = 0,
	CANCEL_LEVEL_UP_BUILDING = 1,
	LACK_OF_DIMOND = 2,
	--BUILD_LEVEL_UP_IMMEDIATE = 3,
	--LACK_OF_SWEEP_TICKET = 4,
};

enum.MESSAGE_DIAMOND_TYPE = {};
enum.MESSAGE_DIAMOND_TYPE.BUILD_LEVEL_UP_IMMEDIATE = 0;
enum.MESSAGE_DIAMOND_TYPE.LACK_OF_SWEEP_TICKET = 1;
enum.MESSAGE_DIAMOND_TYPE.REFRESH_SHOP = 2;
enum.MESSAGE_DIAMOND_TYPE.CLEAN_CD = 3;
enum.MESSAGE_DIAMOND_TYPE.RESET_NUM = 4;
enum.MESSAGE_DIAMOND_TYPE.CHANGENAME = 5;


enum.EQUIP_ATTR_ICON = 
{
	[0] = "set:common.xml image:shuxing7", -- 攻击等级
	[1] = "set:common.xml image:shuxing8", -- 防御等级
	[2] = "set:common.xml image:shuxing4", -- 暴击等级
	[3] = "set:common.xml image:shuxing2", -- 韧性等级
};

enum.EQUIP_ATTR_TEXT = 
{
	[0] = "攻击等级", -- 攻击等级
	[1] = "防御等级", -- 防御等级
	[2] = "暴击等级", -- 暴击等级
	[3] = "韧性等级", -- 韧性等级
};

-- 金钱对应的图标
enum.EXP_ICON_STRING = "set:common.xml image:huobi2";

enum.MONEY_ICON_STRING = {};
enum.MONEY_ICON_STRING[enum.MONEY_TYPE.MONEY_TYPE_GOLD] = "set:common.xml image:wuzi2";
enum.MONEY_ICON_STRING[enum.MONEY_TYPE.MONEY_TYPE_LUMBER] = "set:common.xml image:wuzi3";
enum.MONEY_ICON_STRING[enum.MONEY_TYPE.MONEY_TYPE_DIAMOND] = "set:common.xml image:wuzi1";
enum.MONEY_ICON_STRING[enum.MONEY_TYPE.MONEY_TYPE_VIGOR] = "set:common.xml image:wuzi4";

enum.MONEY_ICON_STRING[enum.MONEY_TYPE.MONEY_TYPE_HONOR] = "set:common.xml image:wuzi5";
enum.MONEY_ICON_STRING[enum.MONEY_TYPE.MONEY_TYPE_CONQUEST] = "set:common.xml image:wuzi6";
enum.MONEY_ICON_STRING[enum.MONEY_TYPE.MONEY_TYPE_MAGICEXP] = "set:jianzhu5.xml image:magic";
 

enum.MONEY_NAME_STRING = {};
enum.MONEY_NAME_STRING[enum.MONEY_TYPE.MONEY_TYPE_GOLD] = "金币";
enum.MONEY_NAME_STRING[enum.MONEY_TYPE.MONEY_TYPE_LUMBER] = "木材";
enum.MONEY_NAME_STRING[enum.MONEY_TYPE.MONEY_TYPE_DIAMOND] = "钻石";
enum.MONEY_NAME_STRING[enum.MONEY_TYPE.MONEY_TYPE_VIGOR] = "体力";
enum.MONEY_NAME_STRING[enum.MONEY_TYPE.MONEY_TYPE_HONOR] = "荣誉";
enum.MONEY_NAME_STRING[enum.MONEY_TYPE.MONEY_TYPE_CONQUEST] = "徽章";
enum.MONEY_NAME_STRING[enum.MONEY_TYPE.MONEY_TYPE_MAGICEXP] = "魔法碎片";


-- 特殊技能表现枚举定义
enum.SKILL_TABLE_ID = {};
--class skillEjection
enum.SKILL_TABLE_ID.TanShe = 21;
enum.SKILL_TABLE_ID.ZhiLiaoBo = 82;
enum.SKILL_TABLE_ID.ShanDianLian = 83;

--class skillAnSha
enum.SKILL_TABLE_ID.AnSha = 66;
enum.SKILL_TABLE_ID.AnSha2 = 251;

--class skillJianYu
enum.SKILL_TABLE_ID.AoShuFeiDan = 79;
enum.SKILL_TABLE_ID.JianYu = 80;
--class skillChuanCi
enum.SKILL_TABLE_ID.ChuanCi = 169;
--skill ji tui
enum.SKILL_TABLE_ID.Repel = 120;
enum.SKILL_TABLE_ID.Repel2 = 242;

enum.SKILL_TABLE_ID.YongHengShiXiang = 103;

-- 特殊魔法表现
enum.MAGIC_TABEL_ID = {};
enum.MAGIC_TABEL_ID.LianSuoShanDian = 2;
enum.MAGIC_TABEL_ID.ZhiLiaoBo = 13;
enum.MAGIC_TABEL_ID.QianLiLianSuoShanDian = 80;
enum.MAGIC_TABEL_ID.ShanDianLian = 122;
enum.MAGIC_TABEL_ID.ZengQiangShanDianLian = 134;

--other
enum.SKILL_TABLE_ID.RouGou = 107;
enum.SKILL_TABLE_ID.RouGou2 = 216;
enum.SKILL_TABLE_ID.GeLie = 50;
enum.SKILL_TABLE_ID.TianShenXiaFan = 162;
enum.SKILL_TABLE_ID.HuoJianJiZhong = 223;
enum.SKILL_TABLE_ID.GeLie2 = 192
enum.SKILL_TABLE_ID.DeadSummon = 94

-- 特殊状态buff表现
enum.BUFF_TABLE_ID = {};
enum.BUFF_TABLE_ID.ChaoFeng = 25;
enum.BUFF_TABLE_ID.YANG = 40;
enum.BUFF_TABLE_ID.YongHengShiXiang = 16;
enum.BUFF_TABLE_ID.TianShenXiaFan = 77;
enum.BUFF_TABLE_ID.Frozen = 69;
enum.BUFF_TABLE_ID.HuoJianYinDao = 111;
enum.BUFF_TABLE_ID.WeiMingZhong = 120;

-- 军团穿刺状态
enum.UNIT_CHUANCI_STATE = {};
enum.UNIT_CHUANCI_STATE.NONE = 0;
enum.UNIT_CHUANCI_STATE.UPDOWN = 1;
enum.UNIT_CHUANCI_STATE.OVER = 3;

-- 穿刺状态
enum.CHUANCI_STATE = {};
enum.CHUANCI_STATE.BEFORE_CAST = 0;
enum.CHUANCI_STATE.CAST = 1;


-- 家园建筑索引
enum.HOMELAND_BUILD_TYPE = {};
enum.HOMELAND_BUILD_TYPE.GOLD = 1;
enum.HOMELAND_BUILD_TYPE.WOOD = 2;
enum.HOMELAND_BUILD_TYPE.BASE = 3;
enum.HOMELAND_BUILD_TYPE.SHOP = 4;
enum.HOMELAND_BUILD_TYPE.MAGIC = 5;
enum.HOMELAND_BUILD_TYPE.ARENA = 6;
enum.HOMELAND_BUILD_TYPE.SHIP = 7;
enum.HOMELAND_BUILD_TYPE.EQUIP = 8;
enum.HOMELAND_BUILD_TYPE.CARD = 9;
enum.HOMELAND_BUILD_TYPE.INSTANCE = 10;
enum.HOMELAND_BUILD_TYPE.GONGHUI = 11;
enum.HOMELAND_BUILD_TYPE.CARD2 = 12;

enum.HOMELAND_BUILD_NAME = {};
enum.HOMELAND_BUILD_NAME[enum.HOMELAND_BUILD_TYPE.GOLD] = "金矿";
enum.HOMELAND_BUILD_NAME[enum.HOMELAND_BUILD_TYPE.WOOD] = "伐木场";
enum.HOMELAND_BUILD_NAME[enum.HOMELAND_BUILD_TYPE.BASE] = "城堡";
enum.HOMELAND_BUILD_NAME[enum.HOMELAND_BUILD_TYPE.SHOP] = "神秘商店";
enum.HOMELAND_BUILD_NAME[enum.HOMELAND_BUILD_TYPE.MAGIC] = "法师塔";
enum.HOMELAND_BUILD_NAME[enum.HOMELAND_BUILD_TYPE.ARENA] = "竞技场";
enum.HOMELAND_BUILD_NAME[enum.HOMELAND_BUILD_TYPE.SHIP] = "试炼场";
enum.HOMELAND_BUILD_NAME[enum.HOMELAND_BUILD_TYPE.EQUIP] = "奇迹";
enum.HOMELAND_BUILD_NAME[enum.HOMELAND_BUILD_TYPE.CARD] = "召唤阵";
enum.HOMELAND_BUILD_NAME[enum.HOMELAND_BUILD_TYPE.INSTANCE] = "冒险";
enum.HOMELAND_BUILD_NAME[enum.HOMELAND_BUILD_TYPE.GONGHUI] = "神像";


-- 领地事件条件相关显示文本
enum.INCIDENT_CONDITION_TEXT = {};
enum.INCIDENT_CONDITION_TEXT[enum.INCIDENT_CONDITION.INCIDENT_CONDITION_HUMS] = "上阵人族军团数量";
enum.INCIDENT_CONDITION_TEXT[enum.INCIDENT_CONDITION.INCIDENT_CONDITION_ORGS] = "上阵兽族军团数量";
enum.INCIDENT_CONDITION_TEXT[enum.INCIDENT_CONDITION.INCIDENT_CONDITION_NES] = "上阵暗夜军团数量";
enum.INCIDENT_CONDITION_TEXT[enum.INCIDENT_CONDITION.INCIDENT_CONDITION_UDS] = "上阵不死军团数量";
enum.INCIDENT_CONDITION_TEXT[enum.INCIDENT_CONDITION.INCIDENT_CONDITION_REMOTES] = "远程军团数量";
enum.INCIDENT_CONDITION_TEXT[enum.INCIDENT_CONDITION.INCIDENT_CONDITION_CLOSE_COMBATS] = "近战军团数量";
enum.INCIDENT_CONDITION_TEXT[enum.INCIDENT_CONDITION.INCIDENT_CONDITION_FLYINGS] = "飞行军团数量";
enum.INCIDENT_CONDITION_TEXT[enum.INCIDENT_CONDITION.INCIDENT_CONDITION_KING_MP] = "国王剩余魔法值";
enum.INCIDENT_CONDITION_TEXT[enum.INCIDENT_CONDITION.INCIDENT_CONDITION_FEMALE] = "女性角色";
enum.INCIDENT_CONDITION_TEXT[enum.INCIDENT_CONDITION.INCIDENT_CONDITION_KILLED] = "死亡军团";
enum.INCIDENT_CONDITION_TEXT[enum.INCIDENT_CONDITION.INCIDENT_CONDITION_ROUND] = "行动数";
enum.INCIDENT_CONDITION_TEXT[enum.INCIDENT_CONDITION.INCIDENT_CONDITION_MAGICIAN] = "上阵法术伤害军团数量";
enum.INCIDENT_CONDITION_TEXT[enum.INCIDENT_CONDITION.INCIDENT_CONDITION_PHYSICS] = "上阵物理伤害军团数量";

enum.INCIDENT_COMPARE_TEXT = {};
enum.INCIDENT_COMPARE_TEXT[enum.INCIDENT_COMPARE.INCIDENT_COMPARE_LARGE] = "大于";
enum.INCIDENT_COMPARE_TEXT[enum.INCIDENT_COMPARE.INCIDENT_COMPARE_LARGEEQUAL] = "大于等于";
enum.INCIDENT_COMPARE_TEXT[enum.INCIDENT_COMPARE.INCIDENT_COMPARE_LESS] = "小于";
enum.INCIDENT_COMPARE_TEXT[enum.INCIDENT_COMPARE.INCIDENT_COMPARE_LESSEQUAL] = "小于等于";
enum.INCIDENT_COMPARE_TEXT[enum.INCIDENT_COMPARE.INCIDENT_COMPARE_EQUAL] = "等于";
enum.INCIDENT_COMPARE_TEXT[enum.INCIDENT_COMPARE.INCIDENT_COMPARE_NOTEQUAL] = "不等于";

--系统消息的枚举定义
enum.CHAT_TYPE.CHAT_TYPE_NOTIFY = 99999;

enum.ENEMYBACK = "set:battle.xml image:dueili2";
enum.SELFBACK = "set:battle.xml image:dueili1";

enum.ATTACK_KING_ICON = "hero1.png";
enum.GUARD_KING_ICON = "hero2.png";

--服务器状态枚举

enum.SERVER_STATE = {};
enum.SERVER_STATE.FULL = 0;
enum.SERVER_STATE.HOT = 1;
enum.SERVER_STATE.NEW = 2;

enum.SERVER_STATE_TEXT = {};
enum.SERVER_STATE_TEXT[enum.SERVER_STATE.FULL] = "火爆";
enum.SERVER_STATE_TEXT[enum.SERVER_STATE.HOT] = "热门";
enum.SERVER_STATE_TEXT[enum.SERVER_STATE.NEW] = "新服";

enum.SERVER_STATE_IMAGE = {};
enum.SERVER_STATE_IMAGE[enum.SERVER_STATE.FULL] = "set:login.xml image:type1";
enum.SERVER_STATE_IMAGE[enum.SERVER_STATE.HOT] = "set:login.xml image:type2";
enum.SERVER_STATE_IMAGE[enum.SERVER_STATE.NEW] = "set:login.xml image:type3";

enum.DEFAULT_PLAYER_NAME = "守护者";

enum.BATTLE_PVP_SCENE_ID = 17;

enum.RANK_LIST_TYPE = {};
enum.RANK_LIST_TYPE.PVP_RANK = 1;
enum.RANK_LIST_TYPE.DAMAGE_RANK = 2;
enum.RANK_LIST_TYPE.SPEED_RANK = 3;
enum.RANK_LIST_TYPE.GUILD_RANK = 4;

enum.RANK_LIST_NAME = {};
enum.RANK_LIST_NAME[enum.RANK_LIST_TYPE.PVP_RANK] = "竞技场";
enum.RANK_LIST_NAME[enum.RANK_LIST_TYPE.DAMAGE_RANK] = "伤害排行榜";
enum.RANK_LIST_NAME[enum.RANK_LIST_TYPE.SPEED_RANK] = "极速挑战";
enum.RANK_LIST_NAME[enum.RANK_LIST_TYPE.GUILD_RANK] = "公会战";

enum.RACE_TEXT = {};
enum.RACE_TEXT[enum.RACE.RACE_HUMAN] = "人族";
enum.RACE_TEXT[enum.RACE.RACE_ORCS] = "兽族";
enum.RACE_TEXT[enum.RACE.RACE_DARK_NIGHT] = "暗夜";
enum.RACE_TEXT[enum.RACE.RACE_UNDEAD] = "不死";
