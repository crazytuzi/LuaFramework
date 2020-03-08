
-- 同伴经验丹   类名 PartnerExpItem  附加参数 1 为使用后增加的经验
-- 同伴技能经验丹  类名 PartnerSkillExpItem 附加参数 1 为使用后增加的技能经验

local preEnv;
-- 两种模式下通用定义
if Partner then --调试需要
	preEnv = _G;	--保存旧的环境
	setfenv(1, Partner)
end

szOpenAwarenessTimeFrame = "OpenDay159";
nPartnerAwarenessCostItem = 1969;

TLOG_DEF_PARTNER_DELETE              = 1
TLOG_DEF_PARTNER_USE_SKILL_BOOK      = 2
TLOG_DEF_PARTNER_ADD_PARTNER         = 3
TLOG_DEF_PARTNER_USE_PROTENTIAL_ITEM = 4
TLOG_DEF_PARTNER_REINIT              = 5
TLOG_DEF_PARTNER_USE_WEAPON          = 6
TLOG_DEF_PARTNER_AWARENESS           = 7


INT_VALUE_SKILL_ORG_VALUE = 1;	-- 初始价值量
INT_VALUE_USE_SKILL_BOOK = 2;	-- 使用技能书价值量

PARTNER_HAS_GROUP = 101;
PARTNER_HAS_MAX_ID = 255;

POTENTIAL_TYPE_VITALITY		= 1;
POTENTIAL_TYPE_DEXTERITY	= 2;
POTENTIAL_TYPE_STRENGTH		= 3;
POTENTIAL_TYPE_ENERGY		= 4;

tbAllProtentialType = {
	[POTENTIAL_TYPE_VITALITY] = "Vitality",
	[POTENTIAL_TYPE_DEXTERITY] = "Dexterity",
	[POTENTIAL_TYPE_STRENGTH] = "Strength",
	[POTENTIAL_TYPE_ENERGY] = "Energy",
};

tbAllProtentialTypeStr2Id = {};
for k, v in preEnv.pairs(tbAllProtentialType) do
	tbAllProtentialTypeStr2Id[v] = k;
end

MAX_LEVEL = 139;  --同伴等级上限

tbProtentialName = {
	[POTENTIAL_TYPE_VITALITY] = "体质",
	[POTENTIAL_TYPE_DEXTERITY] = "敏捷",
	[POTENTIAL_TYPE_STRENGTH] = "力量",
	[POTENTIAL_TYPE_ENERGY] = "灵巧",
}

MAX_PARTNER_COUNT = 200;
MAX_PARTNER_POS_COUNT = 4;

MAX_PARTNER_SKILL_COUNT = 5;

MIN_PARTNER_QUALITY_LEVEL = 6;

MAX_PROTENTIAL_LIMITE_LEVEL = 5;
PARTNER_PROTECT_SKILL_IDX = 2; 		 -- 脚本中护主技能所在索引
tbPartnerLimitLevelDesc = {
	[1] = "[848484]（普通）[-]",
	[2] = "[64db00]（良好）[-]",
	[3] = "[11adf6]（优秀）[-]",
	[4] = "[aa62fc]（卓越）[-]",
	[5] = "[ff8f06]（完美）[-]",
}

nBYLimitStartRandomLevel = 4;		-- 奇才同伴随机资质上限，起始等级
nGoodLimitStartRandomLevel = 3;		-- 保底同伴随机资质上线，起始等级

PARTNER_TYPE_NORMAL = 1;		-- 随机普通同伴类型
PARTNER_TYPE_GOOD = 2;			-- 随机保底同伴类型
PARTNER_TYPE_BY = 3;			-- 随机奇才同伴类型
PARTNER_TYPE_DEBT = 4;			-- 欠款状态随机类型

-- 升级增加潜能数值
tbLevelupGrowthValue = {
	[1] = 40,
	[2] = 30,
	[3] = 24,
	[4] = 20,
	[5] = 16,
	[6] = 12,
}

-- 同伴变异为奇才的概率
nPartnerBYRate = 0.08;

-- 同伴最大随机奇才次数，达到这个数量一定会出一次奇才
nMaxRandomBYCount = 10;
-- 同伴保底随机次数
nMaxRandomGoodCount = 3;

-- 一点价值量对应基准经验
nValueToBaseExp = 0.01;

-- 1点价值量对应的战斗力
nValueToFightPower = 0.0005;

nWeaponValue2RealValue = 2;

-- 遣散后给的同伴经验道具Id
nPartnerExpItemId = 1342;
nPartnerSubExpItemId = 1016;

-- 同伴洗髓丹道具Id
nSeveranceItemId = 1968;

-- 同伴资质突破
tbGradeLevelProtentialLimit = {
	{120, 115},
	{118, 114},
	{116, 113},
	{114, 112},
	{112, 111},
	{110, 110},
	{108, 109},
	{106, 108},
	{104, 107},
	{102, 106},
	{100, 105},
	{98, 104},
	{96, 103},
	{94, 102},
	{92, 101},
	{90, 100},
	{88, 98},
	{86, 96},
	{84, 94},
	{82, 92},
	{80, 90},
	{78, 88},
	{76, 86},
	{74, 84},
	{72, 82},
	{70, 80},
	{68, 78},
	{66, 76},
	{64, 74},
	{62, 72},
	{60, 70},
	{50, 60},
	{40, 50},
	{30, 40},
	{20, 30},
	{10, 20},
	{0, 10},
}

-- 不同品质同伴洗髓消耗洗髓丹数量
ServeranceCost = {
	[1] = 120,			--SSS
	[2] = 48,			--SS
	[3] = 12,			--S
	[4] = 4,			--A
	[5] = 2,			--B
	[6] = 1,			--C
}

-- 每个等级技能价值量
tbOneSkillValueByQuality = {
	[1] = 50000,
	[2] = 150000,
	[3] = 500000,
	[4] = 1500000,
	[5] = 5000000,
	[6] = 15000000,
}

-- 用来预估同伴护主技能等级上限，不同品质同伴对应5本同伴技能的价值量
tbSkillAvaMaxValue = {
	[1] = 75000000,		--SSS
	[2] = 25000000,		--SS
	[3] = 7500000,		--S
	[4] = 2500000,		--A
	[5] = 750000,		--B
	[6] = 250000,		--C
}

--同伴随机的初始战力达到以下数值,则非奇才也显示为奇才
tbMinBYFightPower = {
	[1] = 30000,	--SSS
	[2] = 9000,		--SS
	[3] = 2250,		--S
	[4] = 750,		--A
	[5] = 300,		--B
	[6] = 75,		--C
};

-- 招募同伴所需洗髓丹
tbCallPartnerCost =
{
	[1] = 300,			-- SSS
	[2] = 125,			-- SS
	[3] = 30,			-- S
	[4] = 10,			-- A
	[5] = 5,			-- B
	[6] = 2,			-- C
}

-- 洗髓折算概率
tbReinitRate = {
	Protential = {1, 1},
	Skill = {0.75, 0.85},
}

-- 分解折算概率
tbDecomposeRate = {
	Protential = {0.4, 0.6},
	Skill = {0.4, 0.6},
	Exp = {0.4, 0.6},
}

-- 同伴资质丹道具Id
nPartnerProtentialItem = 1969;

-- 出战位开启所需等级
tbPosNeedLevel = {
	[1] = 5,
	[2] = 10,
	[3] = 20,
	[4] = 30,
};

tbQualityLevelDes_Old = {
	[1] = "SSS",
	[2] = "SS",
	[3] = "S",
	[4] = "A",
	[5] = "B",
	[6] = "C",
}

if preEnv.version_tx then
	tbQualityLevelDes = {
		[1] = "天",
		[2] = "地",
		[3] = "甲",
		[4] = "乙",
		[5] = "丙",
		[6] = "丁",
	};
else
	tbQualityLevelDes = {
		[1] = "SSS",
		[2] = "SS",
		[3] = "S",
		[4] = "A",
		[5] = "B",
		[6] = "C",
	};
end

tbDes2QualityLevel = {
	SSS = 1,
	SS  = 2,
	S   = 3,
	A   = 4,
	B   = 5,
	C   = 6,
};

-- 战力对应星级，一个数字代表半个星
tbStarDef = {
	[1] = 5,
	[2] = 250,
	[3] = 500,
	[4] = 750,
	[5] = 1000,
	[6] = 1500,
	[7] = 2000,
	[8] = 2500,
	[9] = 3750,
	[10] = 5000,
	[11] = 6250,
	[12] = 7500,
	[13] = 10000,
	[14] = 15000,
	[15] = 20000,
	[16] = 25000,
	[17] = 37500,
	[18] = 50000,
	[19] = 62500,
	[20] = 75000,
	[21] = 87500,
	[22] = 100000,
	[23] = 112500,
	[24] = 125000,
	[25] = 137500,
	[26] = 150000,
	[27] = 162500,
	[28] = 175000,
	[29] = 187500,
	[30] = 200000,
}

tbQualityLevelToSpr =
{
	[1] = "CompanionSSS";
	[2] = "CompanionSS";
	[3] = "CompanionS";
	[4] = "CompanionA";
	[5] = "CompanionB";
	[6] = "CompanionC";
}

-- 护主技能，对应星级
tbFightPowerToSkillLevel = {
	[1]  = 1,
	[2]  = 2,
	[3]  = 3,
	[4]  = 4,
	[5]  = 5,
	[6]  = 6,
	[7]  = 7,
	[8]  = 8,
	[9]  = 9,
	[10] = 10,
	[11] = 11,
	[12] = 12,
	[13] = 13,
	[14] = 14,
	[15] = 15,
	[16] = 16,
	[17] = 17,
	[18] = 18,
	[19] = 19,
	[20] = 20,
	[21] = 21,
	[22] = 22,
	[23] = 23,
	[24] = 24,
	[25] = 25,
	[26] = 26,
	[27] = 27,
	[28] = 28,
	[29] = 29,
	[30] = 30,
}

szEffectPrefabPath = "UI/Atlas/ItemGrid/ItemGrid.prefab";
-- 星级对应的背景&边框颜色
-- 改同伴进化边框颜色时，注意需要同时改 tbFightPowerToTxtColor
tbFightPowerLevelToSpr =
{
	[1] = {"CompanionHeadBg_White",		"CompanionQuality_White"};
	[2] = {"CompanionHeadBg_Green",		"CompanionQuality_Green+",		};
	[3] = {"CompanionHeadBg_Green",		"CompanionQuality_Green+",		};
	[4] = {"CompanionHeadBg_Green",		"CompanionQuality_Green+",		"head1_"};
	[5] = {"CompanionHeadBg_Green",		"CompanionQuality_Green+",		"head1_"};
	[6] = {"CompanionHeadBg_Blue",		"CompanionQuality_Blue+",		};
	[7] = {"CompanionHeadBg_Blue",		"CompanionQuality_Blue+",		};
	[8] = {"CompanionHeadBg_Blue",		"CompanionQuality_Blue+",		"head2_"};
	[9] = {"CompanionHeadBg_Blue",		"CompanionQuality_Blue+",		"head2_"};
	[10] = {"CompanionHeadBg_Purple",	"CompanionQuality_Purple+",		};
	[11] = {"CompanionHeadBg_Purple",	"CompanionQuality_Purple+",		};
	[12] = {"CompanionHeadBg_Purple",	"CompanionQuality_Purple+",		"head3_"};
	[13] = {"CompanionHeadBg_Purple",	"CompanionQuality_Purple+",		"head3_"};
	[14] = {"CompanionHeadBg_Orange",	"CompanionQuality_Orange+",		};
	[15] = {"CompanionHeadBg_Orange",	"CompanionQuality_Orange+",		};
	[16] = {"CompanionHeadBg_Orange",	"CompanionQuality_Orange+",		"head5_"};
	[17] = {"CompanionHeadBg_Orange",	"CompanionQuality_Orange+",		"head5_"};
	[18] = {"CompanionHeadBg_Gold",		"CompanionQuality_Gold+"};
	[19] = {"CompanionHeadBg_Gold",		"CompanionQuality_Gold+"};
	[20] = {"CompanionHeadBg_Gold",		"CompanionQuality_Gold+",		"head6_"};
	[21] = {"CompanionHeadBg_Gold",		"CompanionQuality_Gold+",		"head6_"};
	[22] = {"CompanionHeadBg_Gold",		"CompanionQuality_Gold+",		"head6_"};
	[23] = {"CompanionHeadBg_Gold",		"CompanionQuality_Gold+",		"head6_"};
	[24] = {"CompanionHeadBg_Gold",		"CompanionQuality_Gold+",		"head6_"};
	[25] = {"CompanionHeadBg_Gold",		"CompanionQuality_Gold+",		"head6_"};
	[26] = {"CompanionHeadBg_Gold",		"CompanionQuality_Gold+",		"head6_"};
	[27] = {"CompanionHeadBg_Gold",		"CompanionQuality_Gold+",		"head6_"};
	[28] = {"CompanionHeadBg_Gold",		"CompanionQuality_Gold+",		"head6_"};
	[29] = {"CompanionHeadBg_Gold",		"CompanionQuality_Gold+",		"head6_"};
	[30] = {"CompanionHeadBg_Gold",		"CompanionQuality_Gold+",		"head6_"};
};

tbFightPowerToTxtColor =
{
	[1] = "848484";  --白
	[2] = "64db00";  --绿
	[3] = "64db00";
	[4] = "64db00";
	[5] = "64db00";
	[6] = "11adf6";  --蓝
	[7] = "11adf6";
	[8] = "11adf6";
	[9] = "11adf6";
	[10] = "aa62fc";  --紫
	[11] = "aa62fc";
	[12] = "aa62fc";
	[13] = "aa62fc";
	[14] = "ff8f06";  --橙
	[15] = "ff8f06";
	[16] = "ff8f06";
	[17] = "ff8f06";
	[18] = "e6d012";  --金
	[19] = "e6d012";
	[20] = "e6d012";
	[21] = "e6d012";
	[22] = "e6d012";
	[23] = "e6d012";
	[24] = "e6d012";
	[25] = "e6d012";
	[26] = "e6d012";
	[27] = "e6d012";
	[28] = "e6d012";
	[29] = "e6d012";
	[30] = "e6d012";
}

--技能边框颜色
tbSkillColor = {
	[1] = "itemframe",
	[2] = "itemframeGreen",
	[3] = "itemframeBlue",
	[4] = "itemframePurple",
	[5] = "itemframeOrange",
	[6] = "itemframeGold",
}

nSavePKFightGroup = 111;
nSavePKFightID    = 1;


if preEnv then
	preEnv.setfenv(1, preEnv); --恢复全局环境
end
