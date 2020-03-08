Require("CommonScript/Kin/KinDef.lua");
DomainBattle.DEFINE_CITY  	= 1;
DomainBattle.DEFINE_TOWN  	= 2;
DomainBattle.DEFINE_FIELD  	= 3;

DomainBattle.define =
{
	szOpenTimeFrame = "OpenDomainBattle", --开启时间轴
	nMinLevel = 20;
	tbDomainType =
	{
		nCity = 1,
		nTown = 2,
		nVillage = 3,
	},
	nNewsTimeLast = 3600 * 48; --活动结果的最新消息的持续时间
	tbNotifyBeginSet = {900, 300}, --宣战倒计时时间
	nKillPlayerAddScore = 50 * 4; -- 击杀一个玩家加的积分
	nKillFlagAddScore = 200 * 4; --击杀龙柱加分
	tbNpcId_Door = {
		[1] = 1723; --城市城门的npcid  BattleNpc
		[2] = 1777; --村镇的npcid  BattleNpc
	};
	tbDoorBuff = {1717, 1}; --城门，龙柱的buff id，level，加了以后就只能被有攻城buff的 打伤害很高
	tbFlagBuff = {1065, 5}; --龙柱 周围人越多抗性越强的buff
	tbAttackDoorBuff = {2, 1}; --攻城的buff id，level
	nDynamicObstacleNpcId = 104; --动态障碍墙 的npcid
	szDynamicObstacleCamp = "wall"; --营地一开始的动态障碍
	szTrapGotoAttack = "TrapToAttack"; --前往前线的trap 名
	nCallNpcMinDistance = 40;-- 此范围内的不能再招npc

	tbCanDeclareCareer = {  --能宣战的权限
			[Kin.Def.Career_Master] 	= 1,
			[Kin.Def.Career_ViceMaster] = 1,
		};
	tbCanKickRoleCareer = {  --能踢人的权限
		[Kin.Def.Career_Master] 	= 1,
		[Kin.Def.Career_ViceMaster] = 1,
		[Kin.Def.Career_Commander] = 1,
	};


	tbCanUseItemCareer =  --能用战争坊道具的权限
	{
		[Kin.Def.Career_Master] 	= 1,
		[Kin.Def.Career_ViceMaster] = 1,
		[Kin.Def.Career_Elder] = 1,
	};

	tbCanSpeakCareer = --能上麦的权限
	{
		[Kin.Def.Career_Master] 	= 1,
		[Kin.Def.Career_ViceMaster] = 1,
		[Kin.Def.Career_Elder] = 1,
		[Kin.Def.Career_Commander] = 1,
	};

	tbBattleApplyIds = {  -- 使用的战争坊道具id及 消耗的家族建设资金,  对应的效果函数，函数参数
		[2502] = {"UseItemCallDialogNpc", 1733, 16, true, "攻城车"};	--召唤的变身对话npcid和朝向,Class 需要是 DomainBattleChange, true是攻城车
		[2503] = {"UseItemCallDialogNpc", 1734, 16, false, "劲弩车"};	--劲弩车
		[2504] = {"UseItemCallDialogNpc", 1735, 16, false, "铁炮车"};	--铁炮车
		[2505] = {"UseItemCallAttackNpc", 1730, 16, "神射手", 150};	--，召唤的攻击NpcId ，最后参数是击杀对应积分
		[2506] = {"UseItemCallAttackNpc", 1731, 40, "鼓舞旗", 200};	--
	};

	tbBattleApplyLimit = { --填了的道具就每场只能取其上限, 不填的不限
		[2502] = 4 * 5;
		[2503] = 5 * 5;
		[2504] = 3 * 5;
		[2505] = 10;
		[2506] = 2 * 5;
	};


	tbBattleApplyIdOrder = { 2505, 2506, 2502, 2503, 2504 }; --上面的道具的显示顺序

	tbTimeFrameLevel = {  --npc，buff 强度时间轴
		{"OpenLevel59", 55},  --从低到高, 后面是npc强度等级，序号是buff等级
		{"OpenLevel69", 65},
		{"OpenLevel79", 75},
		{"OpenLevel89", 85},
		{"OpenLevel99", 95},
		{"OpenLevel109", 105},
		{"OpenLevel119", 115},
		{"OpenLevel129", 125},
		{"OpenLevel139", 135},
		{"OpenLevel149", 145},
		{"OpenLevel159", 155},
		{"OpenLevel169", 165},
		{"OpenLevel179", 175},
		{"OpenLevel189", 185},
	};

	tbFlagHpStateNotify = { --龙柱血变化百分比时的家族提示
		{0.4, 	"即将倒塌"},
		{0.7, 	"损毁严重"},
		{0.99, 	"正在被攻击"},
	};

	---------------奖励相关
	tbBaseAcutionAward = {{2168, 1, true}}; --没有随到拍卖奖励情况下给的保底拍卖奖励

	szMapMasterIndex = "LT_chengzhu";
	tbExchangeBoxHonor = { ----兑换宝箱
			{"OpenLevel59",  2524,  800}, --时间轴， 荣誉兑换的黄金宝箱id, 所需要的荣誉
			{"OpenLevel69",  2525, 800},
			{"OpenLevel79",  2526, 800},
			{"OpenLevel89",  3007, 800},
			{"OpenLevel99",  3496, 800},
			{"OpenLevel109",  3717, 800},
	};

	tbFlagScore = { --龙柱占领积分
		[1] = { --城市
			    [3] = {32000000 * 0.5 * 5 ,  50}, --大龙柱 积分，基准人数
			    [2] = {32000000 * 0.25 * 5, 25}, --小龙柱
			  },
		[2] = { --村镇
	    	    [3] = {16000000 * 0.5 * 5, 30},
			    [2] = {16000000 * 0.25 * 5, 15},
			  },
		[3] = { --野外
			    [3] = {8000000 * 5, 40},
			  },
	};

-------------------攻方奖励加成-----------------------
	tbFlagAddScore = { --龙柱占据加成
		[1] = { --城市
			    [3] = 3000000, --大龙柱 积分
			    [2] = 2000000, --小龙柱
			  },
		[2] = { --村镇
				[3] = 1500000,
				[2] = 1000000,
			  },
	};

	tbGateScore = { --城门伤害加成
		[DomainBattle.DEFINE_CITY]  = 1500000; --每一个门的积分
		[DomainBattle.DEFINE_TOWN] 	= 800000;
	};

-------------------攻方奖励加成-----------------------

	tbGuaranteeItemKey = {
		[4056] = "DomainBattle_4056"; --完颜洪烈同伴有保底
		[4053] = "DomainBattle_4053"; --魂石·完颜洪烈(真)有保底
		[7377] = "DomainBattle_7377"; --魂石·虞允文有保底
		[10626] = "LingtTuZhan_10626"; --跨服领土战魂石·本尘有保底
		[10627] = "LingtTuZhan_10627"; --跨服领土战魂石·段智兴有保底
		[3557] = "LingtTuZhan_3557"; --跨服领土战同伴·张三丰有保底
	};

	tbFlagAwardSetting = { -- 龙柱占领分决定的奖励分配
		{"OpenLevel59", { {2400, 3/4, 6000000}, {1394, 1/4, 500000}}}, --时间轴， 对应奖励道具，积分占比，对应奖励的消耗积分数
		{"OpenLevel69", { {2400, 1.5/4, 6000000}, {2696, 0.5/4, 1350000}, {4302, 0.75/4, 100000}, {1394, 0.5/4, 500000}, {1395, 0.75/4, 1000000}}},
		{"OpenLevel79", { {2400, 1/4, 6000000}, {2696, 0.25/4, 1350000}, {4302, 0.5/4, 100000}, {4303, 0/4, 200000}, {1395, 2/4, 1000000}, {7387, 0.25/4, 1600000}}},
		{"OpenDay99", 	{ {2400, 1/4, 6000000}, {2696, 0.25/4, 1350000}, {4302, 0.1/4, 100000}, {4303, 0.4/4, 200000}, {1395, 1.75/2, 1000000}, {7387, 0.5/4, 1600000}}},
		{"OpenLevel89",
			{
				nMapLevel1  = {{2400, 3/12, 6000000}, {2696, 1/12, 1350000}, {4302, 0.5/12, 100000}, {4303, 1.25/12, 200000}, {1396, 2/12, 3000000}, {1395, 3/12, 1000000}, {7388, 1.25/12, 2400000}},
				nMapLevel2  = {{2400, 3/12, 6000000}, {2696, 1/12, 1350000}, {4302, 0.5/12, 100000}, {4303, 1.25/12, 200000}, {1396, 2/12, 3000000}, {1395, 3/12, 1000000}, {7388, 1.25/12, 2400000}},
				nMapLevel3  = {{2400, 1/4, 6000000}, {2696, 0.25/4, 1350000}, {4302, 0.25/4, 100000}, {4303, 0.5/4, 200000}, {1395, 1/2, 1000000}},
			},
		},
		{"OpenLevel99",
			{
				nMapLevel1  = {{2400, 3/12, 6000000}, {2696, 0.75/12, 1350000}, {4303, 1/12, 200000}, {4304, 0/12, 400000}, {1396, 3/12, 3000000}, {1395, 2/12, 1000000}, {7389, 2.25/12, 3600000}},
				nMapLevel2  = {{2400, 3/12, 6000000}, {2696, 0.75/12, 1350000}, {4303, 1/12, 200000}, {4304, 0/12, 400000}, {1396, 3/12, 3000000}, {1395, 2/12, 1000000}, {7389, 2.25/12, 3600000}},
				nMapLevel3  = {{2400, 4/16, 6000000}, {2696, 1/16, 1350000}, {4303, 3/16, 200000}, {4304, 0/16, 400000}, {1395, 8/16, 1000000}},
			},
		},
		{"OpenDay224",
			{
				nMapLevel1  = {{2400, 3/12, 6000000}, {2696, 0.75/12, 1350000}, {4303, 0.5/12, 200000}, {4304, 1.25/12, 400000}, {1396, 3/12, 3000000}, {1395, 1.25/12, 1000000}, {7389, 2.25/12, 3600000}},
				nMapLevel2  = {{2400, 3/12, 6000000}, {2696, 0.75/12, 1350000}, {4303, 0.5/12, 200000}, {4304, 1.25/12, 400000}, {1396, 3/12, 3000000}, {1395, 1.25/12, 1000000}, {7389, 2.25/12, 3600000}},
				nMapLevel3  = {{2400, 4/16, 6000000}, {2696, 1/16, 1350000}, {4303, 1/16, 200000}, {4304, 2/16, 400000}, {1395, 8/16, 1000000}},
			},
		},
		{"OpenLevel109",
			{
				nMapLevel1  = {{2400, 2.5/12, 6000000}, {2696, 0.75/12, 1350000}, {4303, 0.5/12, 200000}, {4304, 1.25/12, 400000}, {1396, 3/12, 3000000}, {1395, 1/12, 1000000}, {7390, 3/12, 4800000}},
				nMapLevel2  = {{2400, 2.5/12, 6000000}, {2696, 0.75/12, 1350000}, {4303, 0.5/12, 200000}, {4304, 1.25/12, 400000}, {1396, 3/12, 3000000}, {1395, 1/12, 1000000}, {7390, 3/12, 4800000}},
				nMapLevel3  = {{2400, 4/16, 6000000}, {2696, 1/16, 1350000}, {4303, 1/16, 200000}, {4304, 2/16, 400000}, {1396, 2/16, 3000000}, {1395, 6/16, 1000000}},
			},
		},
		{"OpenDay279",
			{
				nMapLevel1  = {{2400, 1.25/12, 6000000}, {4053, 1.25/12, 4000000}, {4303, 0/12, 200000}, {4304, 0.5/12, 400000}, {7394, 0.75/12, 500000}, {1395, 0.25/12, 1000000}, {1396, 2.5/12, 3000000}, {4056, 2/12, 18000000}, {4057, 1/12, 10000000}, {7390, 2.5/12, 4800000}},
				nMapLevel2  = {{2400, 1.25/12, 6000000}, {4053, 1.25/12, 4000000}, {4303, 0/12, 200000}, {4304, 0.5/12, 400000}, {7394, 0.75/12, 500000}, {1395, 0.25/12, 1000000}, {1396, 2.5/12, 3000000}, {4056, 2/12, 18000000}, {4057, 1/12, 10000000}, {7390, 2.5/12, 4800000}},
				nMapLevel3  = {{2400, 1/4, 6000000}, {2696, 0.2/4, 1350000}, {4053, 0.25/4, 4000000}, {4303, 0.25/4, 200000}, {4304, 0.5/4, 400000}, {1395, 1/4, 1000000}, {1396, 0.5/4, 3000000}, {4056, 0.3/4, 18000000}},
			},
		},
		{"OpenLevel119",
			{
				nMapLevel1  = {{2400, 1.25/12, 6000000}, {4053, 1.25/12, 4000000}, {4303, 0/12, 200000}, {4304, 0.5/12, 400000}, {7394, 0.75/12, 500000}, {1395, 0.25/12, 1000000}, {1396, 2.5/12, 3000000}, {4056, 2/12, 18000000}, {4057, 1/12, 10000000}, {7391, 2.5/12, 6000000}},
				nMapLevel2  = {{2400, 1.25/12, 6000000}, {4053, 1.25/12, 4000000}, {4303, 0/12, 200000}, {4304, 0.5/12, 400000}, {7394, 0.75/12, 500000}, {1395, 0.25/12, 1000000}, {1396, 2.5/12, 3000000}, {4056, 2/12, 18000000}, {4057, 1/12, 10000000}, {7391, 2.5/12, 6000000}},
				nMapLevel3  = {{2400, 0.8/4, 6000000}, {2696, 0.2/4, 1350000}, {4053, 0.35/4, 4000000}, {4303, 0.2/4, 200000}, {4304, 0.55/4, 400000}, {1395, 1/4, 1000000}, {1396, 0.5/4, 3000000}, {4056, 0.4/4, 18000000}},
			},
		},
		{"OpenDay399",
			{
				nMapLevel1  = {{2400, 1.25/12, 6000000}, {4053, 1.25/12, 4000000}, {4304, 0/12, 400000}, {4305, 0.5/12, 800000}, {7394, 0.75/12, 500000}, {1395, 0.25/12, 1000000}, {1396, 2.5/12, 3000000}, {4056, 2/12, 18000000}, {4057, 1/12, 10000000}, {7391, 2.5/12, 6000000}},
				nMapLevel2  = {{2400, 1.25/12, 6000000}, {4053, 1.25/12, 4000000}, {4304, 0/12, 400000}, {4305, 0.5/12, 800000}, {7394, 0.75/12, 500000}, {1395, 0.25/12, 1000000}, {1396, 2.5/12, 3000000}, {4056, 2/12, 18000000}, {4057, 1/12, 10000000}, {7391, 2.5/12, 6000000}},
				nMapLevel3  = {{2400, 0.8/4, 6000000}, {2696, 0.2/4, 1350000}, {4053, 0.35/4, 4000000}, {4304, 0.25/4, 400000}, {4305, 0.5/4, 800000}, {1395, 1/4, 1000000}, {1396, 0.5/4, 3000000}, {4056, 0.4/4, 18000000}},
			},
		},
		{"OpenLevel129",
			{
				nMapLevel1  = {{2400, 0.5/12, 6000000}, {4053, 2.5/12, 4000000},{7377, 1/12, 4050000}, {7741, 1/12, 1350000},{4304, 0/12, 400000}, {4305, 0.25/12, 800000}, {7394, 0.5/12, 500000}, {1395, 0/12, 1000000}, {1396, 1.75/12, 3000000}, {4056, 3/12, 18000000}, {4057, 1.5/12, 10000000}, {7392, 0/12, 7200000}},
				nMapLevel2  = {{2400, 0.5/12, 6000000}, {4053, 2.5/12, 4000000},{7377, 1/12, 4050000}, {7741, 1/12, 1350000},{4304, 0/12, 400000}, {4305, 0.25/12, 800000}, {7394, 0.5/12, 500000}, {1395, 0/12, 1000000}, {1396, 1.75/12, 3000000}, {4056, 3/12, 18000000}, {4057, 1.5/12, 10000000}, {7392, 0/12, 7200000}},
				nMapLevel3  = {{2400, 0.8/4, 6000000}, {2696, 0.2/4, 1350000}, {4053, 0.35/4, 4000000}, {4304, 0.2/4, 400000}, {4305, 0.5/4, 800000}, {1395, 0.8/4, 1000000}, {1396, 0.75/4, 3000000}, {4056, 0.4/4, 18000000}},
			},
		},
		{"OpenLevel139",
			{
				nMapLevel1  = {{2400, 0.5/12, 6000000}, {4053, 2.5/12, 4000000},{7377, 1.75/12, 4050000}, {7741, 0.75/12, 1350000},{4304, 0/12, 400000}, {4305, 0.25/12, 800000}, {7394, 0.5/12, 500000}, {1395, 0/12, 1000000}, {1396, 1.75/12, 3000000}, {4056, 3/12, 18000000}, {4057, 1/12, 10000000}, {7393, 0/12, 8400000}},
				nMapLevel2  = {{2400, 0.5/12, 6000000}, {4053, 2.5/12, 4000000},{7377, 1.75/12, 4050000}, {7741, 0.75/12, 1350000},{4304, 0/12, 400000}, {4305, 0.25/12, 800000}, {7394, 0.5/12, 500000}, {1395, 0/12, 1000000}, {1396, 1.75/12, 3000000}, {4056, 3/12, 18000000}, {4057, 1/12, 10000000}, {7393, 0/12, 8400000}},
				nMapLevel3  = {{2400, 2/12, 6000000}, {2696, 1/12, 1350000}, {4053, 1/12, 4000000}, {4304, 0.5/12, 400000}, {4305, 1.25/12, 800000}, {7394, 1.25/12, 500000}, {1395, 1.5/12, 1000000}, {1396, 2/12, 3000000}, {4056, 1.5/12, 18000000}},
			},
		},
		{"OpenLevel149",
			{
				nMapLevel1  = {{2400, 0.5/12, 6000000}, {4053, 2.5/12, 4000000},{7377, 1.75/12, 4050000}, {7741, 0.75/12, 1350000},{4304, 0/12, 400000}, {4305, 0.25/12, 800000}, {7394, 0.5/12, 500000}, {1395, 0/12, 1000000}, {1396, 1.75/12, 3000000}, {4056, 3/12, 18000000}, {4057, 1/12, 10000000}, {7587, 0/12, 9000000}},
				nMapLevel2  = {{2400, 0.5/12, 6000000}, {4053, 2.5/12, 4000000},{7377, 1.75/12, 4050000}, {7741, 0.75/12, 1350000},{4304, 0/12, 400000}, {4305, 0.25/12, 800000}, {7394, 0.5/12, 500000}, {1395, 0/12, 1000000}, {1396, 1.75/12, 3000000}, {4056, 3/12, 18000000}, {4057, 1/12, 10000000}, {7587, 0/12, 9000000}},
				nMapLevel3  = {{2400, 2/12, 6000000}, {2696, 1/12, 1350000}, {4053, 1/12, 4000000}, {4304, 0.5/12, 400000}, {4305, 1.25/12, 800000}, {7394, 1.25/12, 500000}, {1395, 1.5/12, 1000000}, {1396, 2/12, 3000000}, {4056, 1.5/12, 18000000}},
			},
		},
		{"OpenLevel159",
			{
				nMapLevel1  = {{2400, 0.5/12, 6000000}, {4053, 2.5/12, 4000000},{7377, 1.75/12, 4050000}, {7741, 0.75/12, 1350000},{4304, 0/12, 400000}, {4305, 0.25/12, 800000}, {10977, 0.75/12, 1600000}, {7394, 0.5/12, 500000}, {1395, 0/12, 1000000}, {1396, 1/12, 3000000}, {4056, 3/12, 18000000}, {4057, 1/12, 10000000}, {7588, 0/12, 10000000}},
				nMapLevel2  = {{2400, 0.5/12, 6000000}, {4053, 2.5/12, 4000000},{7377, 1.75/12, 4050000}, {7741, 0.75/12, 1350000},{4304, 0/12, 400000}, {4305, 0.25/12, 800000}, {10977, 0.75/12, 1600000}, {7394, 0.5/12, 500000}, {1395, 0/12, 1000000}, {1396, 1/12, 3000000}, {4056, 3/12, 18000000}, {4057, 1/12, 10000000}, {7588, 0/12, 10000000}},
				nMapLevel3  = {{2400, 2/12, 6000000}, {2696, 1/12, 1350000}, {4053, 1/12, 4000000}, {4304, 0.25/12, 400000}, {4305, 0.75/12, 800000}, {10977, 0.75/12, 1600000}, {7394, 1.25/12, 500000}, {1395, 1.5/12, 1000000}, {1396, 2/12, 3000000}, {4056, 1.5/12, 18000000}},
			},
		},
	};

	--家族内的排名奖励
	tbMemberAwardSetting = {
		{nPos = 1,   Award = {{"DomainHonor", 3200 * 3}, {"BasicExp", 180 * 5},},},
		{nPos = 2,   Award = {{"DomainHonor", 3000 * 3}, {"BasicExp", 170 * 5},},},
		{nPos = 3,   Award = {{"DomainHonor", 2800 * 3}, {"BasicExp", 160 * 5},},},
		{fPos = 0.1, Award = {{"DomainHonor", 2600 * 3}, {"BasicExp", 150 * 5},},},
		{fPos = 0.2, Award = {{"DomainHonor", 2400 * 3}, {"BasicExp", 140 * 5},},},
		{fPos = 0.3, Award = {{"DomainHonor", 2200 * 3}, {"BasicExp", 130 * 5},},},
		{fPos = 0.5, Award = {{"DomainHonor", 2000 * 3}, {"BasicExp", 120 * 5},},},
		{fPos = 0.7, Award = {{"DomainHonor", 1800 * 3}, {"BasicExp", 110 * 5},},},
		{fPos = 0.9, Award = {{"DomainHonor", 1600 * 3}, {"BasicExp", 105 * 5},},},
		{fPos = 1, 	 Award = {{"DomainHonor", 1400 * 3}, {"BasicExp", 100 * 5},},},
	};

	--城主所在家族成员奖励 ,
	tbCityMasterKinMemberAward = {
		{
			{"item", 995140, 1}; --封印襄阳宝箱J
			--{"item", 998142, 1}; --潮流金蛋宝箱
			--{"item", 998141, 1}; --潮流银蛋宝箱
		}
	},

	--城主奖励 ,
	tbCityMasterAward = {
		{"OpenLevel39",
			{
				{"AddTimeTitle", 6000}; --襄阳城主称号 -发送时计算有效期
				{"item", 2507, 1}; --逐日 -发送时计算有效期
			}
		},
		{"OpenLevel79",
			{
				{"AddTimeTitle", 6000};
				{"item", 2508, 1};
			}
		},
		{"OpenLevel99",
			{
				{"AddTimeTitle", 6000};
				{"item", 3639, 1};
			}
		},
		{"OpenLevel119",
			{
				{"AddTimeTitle", 6000};
				{"item", 4583, 1};
			}
		},
		{"OpenLevel139",
			{
				{"AddTimeTitle", 6000};
				{"item", 8369, 1};
			}
		},
		{"OpenLevel159",
			{
				{"AddTimeTitle", 6000};
				{"item", 5359, 1};
			}
		},
	};

	--城主雕像
	tbMasterStatuePos =  {
		{10, 11636, 9113, 16}; --地图id，坐标，朝向
		--{15, 18041, 11277, 0}; --地图id，坐标，朝向   襄阳城的城主雕像暂时不在临安城出现，留给跨服城战城主
	};
	tbMasterStatueId = { --各门派对应的npcid 分别为男女
		[1]	 = {1841, 3282};--天王
		[2]	 = {1842, 1842};--峨嵋
		[3]	 = {1843, 1843};--桃花
		[4]	 = {1844, 3448};--逍遥
		[5]	 = {1845, 2911};--武当
		[6]	 = {3795, 1846};--天忍
		[7]	 = {1847, 1847};--少林
		[8]	 = {1848, 1848};--翠烟
		[9]	 = {2000, 2000};--唐门
		[10] = {2968, 2002};--昆仑
		[11] = {2215, 3726};--丐帮
		[12] = {2216, 2216};--五毒
		[13] = {2379, 2379};--藏剑山庄
		[14] = {2380, 2380};--长歌门
		[15] = {2655, 2656};--天山
		[16] = {2909, 2910};--霸刀
		[17] = {2966, 2967};--华山
		[18] = {3280, 3281};--明教
		[19] = {3446, 3447};--段氏
		[20] = {3724, 3725};--万花
		[21] = {3793, 3794};--杨门
	};

	--城战威望设置
	tbKinPrestigeSetting = {
		[1] = { nOwner = 1000, 	nHasFlag = 400 }; --城市
		[2] = { nOwner = 500, 	nHasFlag = 200 }; --村镇
		[3] = { nOwner = 200, 	nHasFlag = 0 }; --野外
	};
	nKinDecarlePrestige = 50; --没有获得占领威望的参与威望

	--结束篝火设置
	FireNpcTemplateId = 1817;--篝火的npc id
	nFireNpcTime = 180; --秒

	--占领拍卖商人奖励价值量设置
	tbActOwnerScoreSetting = {
		[1] = {8000000, 80};
		[2] = {4000000, 60};
		[3] = {2000000, 40};
	};
	--占领拍卖商人奖励道具设置
	tbActOwnerItemSetting = {
		{"OpenLevel59",  { {2168, 2/3, 450000, true}, {1394, 1/3, 500000, false}}}, --时间轴， 对应奖励道具，积分占比，对应奖励的消耗积分数, 是否随机箱子
		{"OpenLevel69",  { {2168, 3/8, 450000, true}, {2169, 2/8, 1350000, true}, {4312, 1/8, 100000, false}, {1395, 1.5/8, 1000000, false}, {2271, 0.5/8, 3000000, true} }},
		{"OpenLevel79",  { {2168, 2.5/8, 450000, true}, {2169, 2.5/8, 1350000, true}, {4312, 1/8, 100000, false}, {4313, 0/8, 200000, false}, {1395, 1.5/8, 1000000, false}, {2271, 0.5/8, 3000000, true} }},
		{"OpenDay99", 	 { {2168, 2.5/8, 450000, true}, {2169, 2.5/8, 1350000, true}, {4312, 0.33/8, 100000, false}, {4313, 0.67/8, 200000, false}, {1395, 1.5/8, 1000000, false}, {2271, 0.5/8, 3000000, true} }},
		{"OpenLevel89",  { {2168, 1.5/8, 450000, true}, {2169, 3.5/8, 1350000, true}, {4312, 0.33/8, 100000, false}, {4313, 0.67/8, 200000, false}, {1395, 1.5/8, 1000000, false}, {2271, 0.5/8, 3000000, true} }},
		{"OpenLevel99",  { {2168, 1/8, 450000, true}, {2169, 4/8, 1350000, true}, {4312, 0.25/8, 100000, false}, {4313, 0.75/8, 200000, false}, {1395, 1/8, 1000000, false}, {1396, 0.5/8, 3000000, false}, {2271, 0.5/8, 3000000, true} }},
		{"OpenDay224", 	 { {2168, 1/8, 450000, true}, {2169, 4/8, 1350000, true}, {4313, 0.33/8, 200000, false}, {4314, 0.67/8, 400000, false}, {1395, 1/8, 1000000, false}, {1396, 0.5/8, 3000000, false}, {2271, 0.5/8, 3000000, true} }},
		{"OpenLevel109", { {7394, 1.6/8, 500000,false},{6152, 1.6/8, 500000,false}, {2169, 2.6/8, 1350000, true}, {4313, 0.2/8, 200000, false}, {4314, 0.5/8, 400000, false}, {1395, 0/8, 1000000, false}, {1396, 1/8, 3000000, false}, {2271, 0.5/8, 3000000, true} }},
		{"OpenLevel119", { {7394, 1.6/8, 500000,false},{6152, 1.6/8, 500000,false}, {2169, 2.6/8, 1350000, true}, {4313, 0.2/8, 200000, false}, {4314, 0.5/8, 400000, false}, {1395, 0/8, 1000000, false}, {1396, 1/8, 3000000, false}, {2271, 0.5/8, 3000000, true} }},
		{"OpenDay399", 	 { {7394, 1.6/8, 500000,false},{6152, 1.6/8, 500000,false}, {2169, 2.6/8, 1350000, true}, {4314, 0.2/8, 400000, false}, {4315, 0.5/8, 800000, false}, {1395, 0/8, 1000000, false}, {1396, 1/8, 3000000, false}, {2271, 0.5/8, 3000000, true} }},
		{"OpenLevel129", { {7394, 1.6/8, 500000,false},{6152, 1.6/8, 500000,false}, {2169, 2.6/8, 1350000, true}, {4314, 0.2/8, 400000, false}, {4315, 0.5/8, 800000, false}, {1395, 0/8, 1000000, false}, {1396, 1/8, 3000000, false}, {2271, 0.5/8, 3000000, true} }},
		{"OpenLevel159", { {7394, 2/8, 500000,false},{6152, 2/8, 500000,false}, {2169, 1.5/8, 1350000, true}, {4314, 0/8, 400000, false}, {4315, 0.5/8, 800000, false},{10981, 0.5/8, 1600000, false}, {1395, 0/8, 1000000, false}, {1396, 1/8, 3000000, false}, {2271, 0.5/8, 3000000, true} }},
	};
}

--地图之间的关联 ，key是地图id ,同一级的目前就是按地图id大小顺序了, GotoDefend1就是对应id最小的地图了
local tbMapSetting =
{
	nMapTemplateId = 1400,
	tbChilds =
	{
		{
			nMapTemplateId = 1401,	--稻香村

			tbChilds =
			{
				{nMapTemplateId = 1405},	--洞庭湖畔
				{nMapTemplateId = 1406},	--苗岭
			},
		},
		{
			nMapTemplateId = 1402,	--巴陵县
			tbChilds =
			{
				{nMapTemplateId = 1407},	--点苍山
				{nMapTemplateId = 1408},	--响水洞
			},
		},
		{
			nMapTemplateId = 1403,	--江津村
			tbChilds =
			{
				{nMapTemplateId = 1409},	--见性峰
				{nMapTemplateId = 1410},	--剑门关
			},
		},
		{
			nMapTemplateId = 1404,	--永乐镇
			tbChilds =
			{
				{nMapTemplateId = 1411},	--荐菊洞
				{nMapTemplateId = 1412},	--伏牛山
			},
		},
	},
}

--地图的营地传送点设置
local tbMapPosSetting =
{
	[1400] = {
			tbAtackPos = {
			 --按顺序传入tbMapSetting下tbChilds序列的map
				--征战营地的出生点,传送子地图trap, 子地图名，传出营地trap名，传出营地点，进入营地trap名，传入营地点
				{5405, 12040, "TrapToDXC", "稻香村","TrapToFight4", {{6798, 12236},{6782, 11918},{6793, 11589},{6793, 11239},}, "TrapToPeace4", {{6329, 12206},{6326, 11894},{6316, 11600},{6292, 11287},} },
				{5246, 9386, "TrapToBLX", "巴陵县","TrapToFight3", {{6520, 9536},{6522, 9215},{6517, 8892},{6522, 8585},}, "TrapToPeace3", {{6064, 9573},{6059, 9273},{6059, 8966},{6024, 8627},} },
				{5184, 6856, "TrapToJJC", "江津村","TrapToFight2", {{6430, 7379},{6427, 7045},{6435, 6701},{6443, 6319},}, "TrapToPeace2", {{5939, 7302},{5955, 7008},{5947, 6704},{5953, 6367},} },
				{5449, 4149, "TrapToYLZ", "永乐镇","TrapToFight1", {{6727, 4779},{6802, 4157},{6770, 4468},{6858, 3771},}, "TrapToPeace1", {{6253, 4562},{6274, 4310},{6298, 4029},{6349, 3739},} },
			},

			tbDefendPos = {20874, 8188}, --防守营地进入点
			tbCampDynamicObstacle = {   -- 一开始的各个营地障碍npc的摆放 位置，朝向
				{6568, 11660, 32},
				{6568, 12052, 32},
				{6568, 11296, 32},
				{6286, 8971, 32},
				{6286, 9338, 32},
				{6286, 8580, 32},
				{6172, 6821, 32},
				{6172, 7200, 32},
				{6172, 6420, 32},
				{6533, 4186, 30},
				{6481, 4557, 30},
				{6593, 3790, 30},
			};

			tbStartPutNpcs = { 	--战斗开始后摆放的npc，可以是后营、前营地的传送阵,
				{73, 19677, 8303, 0}, --后营
				{73, 6440, 11730, 0},--征战营地1
				{73, 6170, 9124, 0},--征战营地2
				{73, 6057, 6864, 0},--征战营地3
				{73, 6415, 4142, 0},--征战营地4
			};

			TrapOutN = {{12749, 11220}, {12753, 11054}, {12760, 10837}}; --城门1 ,踩了以后传送到的点，多点随机
			TrapOutM = {{12758, 8498}, {12754, 8262}, {12760, 8029}};
			TrapOutS = {{12778, 5757}, {12770, 5594}, {12778, 5430}};

			--每个营地旁边的 trap TrapPeace，TrapFight 更改战斗状态
			--BackCampOut, BackCampIn  --后营进出的trap
			tbPosBackCampOut = {{19053, 8651}, {19057, 8489}, {19053, 8292}, {19041, 8112}, {19046, 7932}}; --踩到出后营trap 传送的点
			tbPosBackCampIn =  {{19899, 8253}}; --踩到进后营trap 传送的点

			Doors = {
				 {12857, 11027, 48, "gate_n", "DES_GateN", "TrapOutN", "北城门"},--城门的位置及朝向, 对应的动态障碍名（同时也是text_pos_info.txt显示已击破的 index）
				 {12854, 8273, 48, "gate_m", "DES_GateM", "TrapOutM", "中城门"},
				 {12856, 5611, 48, "gate_s", "DES_GateS", "TrapOutS", "南城门"},
			},

			tbFlogNpcPos = {         --龙柱id的class 需要是 BattleNpc
				{ 1724, 3, 15536, 8278, 48, "OCC_Longzhu_sun"}, --龙柱npcid，等级（3是大龙柱，2是小龙柱） 龙柱的位置 ,朝向， 越往下的龙柱等级越高
				{ 1725, 2, 15536, 11012, 48, "OCC_Longzhu_moon"}, --对应 text_pos_info.txt 龙柱显示占领的家族 是 Flag2
				{ 1726, 2, 15539, 5577, 48, "OCC_Longzhu_star"},
			};
		  },
	[1401] = {
			tbAtackPos = {
				{4719, 10048, "TrapToFlield_dthp", "洞庭湖畔", "TrapToFight2", {{5369, 9316},{5621, 9577},{5897, 9825},{6130, 10064},}, "TrapToPeace2", {{4941, 9649},{5124, 9869},{5570, 10227},{5755, 10430},} },
				{4328, 3979, "TrapToFlield_ml", "苗岭", "TrapToFight1", {{5449, 5189},{5615, 4709},{5876, 4262},{6082, 3974},}, "TrapToPeace1", {{4923, 4973},{4995, 4663},{5269, 4004},{5511, 3670},} },
			},

			tbDefendPos = {19490, 7343},
			tbCampDynamicObstacle = {   -- 一开始的各个营地障碍npc的摆放 位置，朝向
				{5869, 10179, 40},
				{5241, 9549, 40},
				{5554, 9857, 40},
				{5449, 4405, 27},
				{5668, 4014, 27},
				{5228, 4877, 27},
			};

			tbStartPutNpcs = { 	--战斗开始后摆放的npc，可以是后营的传送阵
				{73, 18634, 7286, 0}, --npcId, 位置，朝向
				{73, 5407, 9988, 0},
				{73, 5226, 4417, 0},
			};

			TrapOutN = {{11553, 9691}, {11467, 9595}, {11382, 9469}, {11242, 9318}}; --城门1 ,踩了以后传送到的点，多点随机
			TrapOutS = {{11434, 4875}, {11589, 4749}, {11306, 5012}, {11712, 4614}};

			tbPosBackCampOut = {{18046, 7611}, {18038, 7422}, {18038, 7266}, {18043, 7128}, {18051, 6953}}; --踩到出后营trap 传送的点
			tbPosBackCampIn =  {{18828, 7266}}; --踩到进后营trap 传送的点

			Doors = {
				 {11593, 9426, 23, "gate_n", "DES_GateN", "TrapOutN", "北城门"},--城门的位置及朝向, 对应的动态障碍名（同时也是text_pos_info.txt显示已击破的 index）
				 {11622, 5054, 39, "gate_s", "DES_GateS", "TrapOutS", "南城门"},
			},

			tbFlogNpcPos = {         --龙柱id的class 需要是 BattleNpc
				{ 1724, 3, 13159, 7279, 40, "OCC_Longzhu_sun"}, --龙柱npcid，等级（3是大龙柱，2是小龙柱） 龙柱的位置 ,朝向， 越往下的龙柱等级越高
				{ 1725, 2, 14861, 10191, 40, "OCC_Longzhu_moon"}, --对应 text_pos_info.txt 龙柱显示占领的家族 是 Flag2
				{ 1726, 2, 14863, 4967, 40, "OCC_Longzhu_star"},
			};
	  		},
	[1402] = {
			tbAtackPos = {
				{4719, 10048, "TrapToFlield_xsd", "点苍山", "TrapToFight2", {{5369, 9316},{5621, 9577},{5897, 9825},{6130, 10064},}, "TrapToPeace2", {{4941, 9649},{5124, 9869},{5570, 10227},{5755, 10430},} },
				{4328, 3979, "TrapToFlield_dcs", "响水洞", "TrapToFight1", {{5449, 5189},{5615, 4709},{5876, 4262},{6082, 3974},}, "TrapToPeace1", {{4923, 4973},{4995, 4663},{5269, 4004},{5511, 3670},} },
			},
			tbDefendPos = {19490, 7343},
			tbCampDynamicObstacle = {   -- 一开始的各个营地障碍npc的摆放 位置，朝向
				{5869, 10179, 40},
				{5241, 9549, 40},
				{5554, 9857, 40},
				{5449, 4405, 27},
				{5668, 4014, 27},
				{5228, 4877, 27},
			};

			tbStartPutNpcs = { 	--战斗开始后摆放的npc，可以是后营的传送阵
				{73, 18634, 7286, 0}, --npcId, 位置，朝向
				{73, 5407, 9988, 0},
				{73, 5226, 4417, 0},
			};

			TrapOutN = {{11553, 9691}, {11467, 9595}, {11382, 9469}, {11242, 9318}}; --城门1 ,踩了以后传送到的点，多点随机
			TrapOutS = {{11434, 4875}, {11589, 4749}, {11306, 5012}, {11712, 4614}};

			tbPosBackCampOut = {{18046, 7611}, {18038, 7422}, {18038, 7266}, {18043, 7128}, {18051, 6953}}; --踩到出后营trap 传送的点
			tbPosBackCampIn =  {{18828, 7266}}; --踩到进后营trap 传送的点

			Doors = {
				 {11593, 9426, 23, "gate_n", "DES_GateN", "TrapOutN", "北城门"},--城门的位置及朝向, 对应的动态障碍名（同时也是text_pos_info.txt显示已击破的 index）
				 {11622, 5054, 39, "gate_s", "DES_GateS", "TrapOutS", "南城门"},
			},

			tbFlogNpcPos = {         --龙柱id的class 需要是 BattleNpc
				{ 1724, 3, 13159, 7279, 40, "OCC_Longzhu_sun"}, --龙柱npcid，等级（3是大龙柱，2是小龙柱） 龙柱的位置 ,朝向， 越往下的龙柱等级越高
				{ 1725, 2, 14861, 10191, 40, "OCC_Longzhu_moon"}, --对应 text_pos_info.txt 龙柱显示占领的家族 是 Flag2
				{ 1726, 2, 14863, 4967, 40, "OCC_Longzhu_star"},
			};
	  		},
    [1403] = {
			tbAtackPos = {
				{4328, 3979, "TrapToFlield_jxf", "见性峰", "TrapToFight1", {{5449, 5189},{5615, 4709},{5876, 4262},{6082, 3974},}, "TrapToPeace1", {{4923, 4973},{4995, 4663},{5269, 4004},{5511, 3670},} },
				{4719, 10048, "TrapToFlield_jmg", "剑门关", "TrapToFight2", {{5369, 9316},{5621, 9577},{5897, 9825},{6130, 10064},}, "TrapToPeace2", {{4941, 9649},{5124, 9869},{5570, 10227},{5755, 10430},} },
				},
			tbDefendPos = {19490, 7343},
			tbCampDynamicObstacle = {   -- 一开始的各个营地障碍npc的摆放 位置，朝向
				{5869, 10179, 40},
				{5241, 9549, 40},
				{5554, 9857, 40},
				{5449, 4405, 27},
				{5668, 4014, 27},
				{5228, 4877, 27},
			};

			tbStartPutNpcs = { 	--战斗开始后摆放的npc，可以是后营的传送阵
				{73, 18634, 7286, 0}, --npcId, 位置，朝向
				{73, 5407, 9988, 0},
				{73, 5226, 4417, 0},
			};

			TrapOutN = {{11553, 9691}, {11467, 9595}, {11382, 9469}, {11242, 9318}}; --城门1 ,踩了以后传送到的点，多点随机
			TrapOutS = {{11434, 4875}, {11589, 4749}, {11306, 5012}, {11712, 4614}};

			tbPosBackCampOut = {{18046, 7611}, {18038, 7422}, {18038, 7266}, {18043, 7128}, {18051, 6953}}; --踩到出后营trap 传送的点
			tbPosBackCampIn =  {{18828, 7266}}; --踩到进后营trap 传送的点

			Doors = {
				 {11593, 9426, 23, "gate_n", "DES_GateN", "TrapOutN", "北城门"},--城门的位置及朝向, 对应的动态障碍名（同时也是text_pos_info.txt显示已击破的 index）
				 {11622, 5054, 39, "gate_s", "DES_GateS", "TrapOutS", "南城门"},
			},

			tbFlogNpcPos = {         --龙柱id的class 需要是 BattleNpc
				{ 1724, 3, 13159, 7279, 40, "OCC_Longzhu_sun"}, --龙柱npcid，等级（3是大龙柱，2是小龙柱） 龙柱的位置 ,朝向， 越往下的龙柱等级越高
				{ 1725, 2, 14861, 10191, 40, "OCC_Longzhu_moon"}, --对应 text_pos_info.txt 龙柱显示占领的家族 是 Flag2
				{ 1726, 2, 14863, 4967, 40, "OCC_Longzhu_star"},
			};
	  		},
	[1404] = {
			tbAtackPos = {
				{4328, 3979, "TrapToFlield_jjd", "荐菊洞", "TrapToFight1", {{5449, 5189},{5615, 4709},{5876, 4262},{6082, 3974},}, "TrapToPeace1", {{4923, 4973},{4995, 4663},{5269, 4004},{5511, 3670},} },
				{4719, 10048, "TrapToFlield_fns", "伏牛山", "TrapToFight2", {{5369, 9316},{5621, 9577},{5897, 9825},{6130, 10064},}, "TrapToPeace2", {{4941, 9649},{5124, 9869},{5570, 10227},{5755, 10430},} },
			},
			tbDefendPos = {19490, 7343},
			tbCampDynamicObstacle = {   -- 一开始的各个营地障碍npc的摆放 位置，朝向
				{5869, 10179, 40},
				{5241, 9549, 40},
				{5554, 9857, 40},
				{5449, 4405, 27},
				{5668, 4014, 27},
				{5228, 4877, 27},
			};

			tbStartPutNpcs = { 	--战斗开始后摆放的npc，可以是后营的传送阵
				{73, 18634, 7286, 0}, --npcId, 位置，朝向
				{73, 5407, 9988, 0},
				{73, 5226, 4417, 0},
			};

			TrapOutN = {{11553, 9691}, {11467, 9595}, {11382, 9469}, {11242, 9318}}; --城门1 ,踩了以后传送到的点，多点随机
			TrapOutS = {{11434, 4875}, {11589, 4749}, {11306, 5012}, {11712, 4614}};

			tbPosBackCampOut = {{18046, 7611}, {18038, 7422}, {18038, 7266}, {18043, 7128}, {18051, 6953}}; --踩到出后营trap 传送的点
			tbPosBackCampIn =  {{18828, 7266}}; --踩到进后营trap 传送的点

			Doors = {
				 {11593, 9426, 23, "gate_n", "DES_GateN", "TrapOutN", "北城门"},--城门的位置及朝向, 对应的动态障碍名（同时也是text_pos_info.txt显示已击破的 index）
				 {11622, 5054, 39, "gate_s", "DES_GateS", "TrapOutS", "南城门"},
			},

			tbFlogNpcPos = {         --龙柱id的class 需要是 BattleNpc
				{ 1724, 3, 13159, 7279, 40, "OCC_Longzhu_sun"}, --龙柱npcid，等级（3是大龙柱，2是小龙柱） 龙柱的位置 ,朝向， 越往下的龙柱等级越高
				{ 1725, 2, 14861, 10191, 40, "OCC_Longzhu_moon"}, --对应 text_pos_info.txt 龙柱显示占领的家族 是 Flag2
				{ 1726, 2, 14863, 4967, 40, "OCC_Longzhu_star"},
			};
	  		},
   [1405] = {
			tbAtackPos = {
				{13493, 12656, "", "天"},
				{6546, 11717, "", "地"},
				{5106, 8756, "", "人"},
			},
			tbDefendPos = {13680, 8144},
			tbPosBackCampOut = {{12915, 7545}}; --踩到出后营trap 传送的点
			tbPosBackCampIn = {{13680, 8144}}; --踩到进后营trap 传送的点
			tbCampDynamicObstacle = {   -- 一开始的各个营地障碍npc的摆放 位置，朝向
				{13159, 12044, 50},
				{13387, 11991, 50},
				{7009, 11322, 40},
				{6810, 11149, 40},
				{5675, 8784, 32},
				{5670, 8552, 32},
			};

			tbStartPutNpcs = { 	--战斗开始后摆放的npc，可以是后营的传送阵
				{73, 13247, 7842, 0}, --npcId, 位置，朝向
			};

			tbFlogNpcPos = {
				{ 1724, 3, 10593, 7625, 48, "OCC_Longzhu_sun"},
			};
		   },
   [1406] = {
			tbAtackPos = {
				{12774, 11847, "", "天"},
				{6516, 13097, "", "地"},
				{12898, 5967, "", "人"}
			},
			tbDefendPos = {4795, 8097},
			tbPosBackCampOut = {{5698, 8051}}; --踩到出后营trap 传送的点
			tbPosBackCampIn = {{4795, 8097}}; --踩到进后营trap 传送的点
			tbCampDynamicObstacle = {   -- 一开始的各个营地障碍npc的摆放 位置，朝向
				{12234, 11557, 56},
				{12392, 11373, 56},
				{6416, 12496, 48},
				{6665, 12496, 48},
				{12471, 6277, 8},
				{12689, 6473, 8},
			};

			tbStartPutNpcs = { 	--战斗开始后摆放的npc，可以是后营的传送阵
				{73, 5239, 8037, 0}, --npcId, 位置，朝向
			};

			tbFlogNpcPos = {
				{ 1724, 3, 8848, 8233, 48, "OCC_Longzhu_sun"},
			};
		   },
   [1407] = {
			tbAtackPos = {
				{4885, 12190, "", "天"},
				{3893, 3631, "", "地"},
				{12439, 3685, "", "人"}
			},
			tbDefendPos = {10189, 10810},
			tbPosBackCampOut = {{10164, 9967}}; --踩到出后营trap 传送的点
			tbPosBackCampIn = {{10189, 10810}}; --踩到进后营trap 传送的点
			tbCampDynamicObstacle = {   -- 一开始的各个营地障碍npc的摆放 位置，朝向
				{5038, 11628, 48},
				{4764, 11638, 48},
				{4251, 4096, 24},
				{4400, 3930, 24},
				{12141, 4208, 8},
				{11982, 4056, 8},
			};

			tbStartPutNpcs = { 	--战斗开始后摆放的npc，可以是后营的传送阵
				{73, 10140, 10421, 0}, --npcId, 位置，朝向
			};

			tbFlogNpcPos = {
				{ 1724, 3, 7994, 8191, 48, "OCC_Longzhu_sun"},
			};
		   },
   [1408] = {
			tbAtackPos = {
				{6662, 13040, "", "天" },
				{2138, 10041, "", "地" },
				{2502, 4151, "", "人"}
			},
			tbDefendPos = {10233, 5705},
			tbPosBackCampOut = {{10258, 6521}}; --踩到出后营trap 传送的点
			tbPosBackCampIn = {{10233, 5705}}; --踩到进后营trap 传送的点
			tbCampDynamicObstacle = {   -- 一开始的各个营地障碍npc的摆放 位置，朝向
				{6516, 12503, 48},
				{6783, 12509, 48},
				{2562, 10149, 32},
				{2556, 9886, 32},
				{3013, 4232, 32},
				{3005, 3970, 32},
			};

			tbStartPutNpcs = { 	--战斗开始后摆放的npc，可以是后营的传送阵
				{73, 10277, 6100, 0}, --npcId, 位置，朝向
			};

			tbFlogNpcPos = {
				{ 1724, 3, 6899, 7289, 48, "OCC_Longzhu_sun"},
			};
		   },
   [1409] = {
			tbAtackPos = {
				{9763, 10533, "", "天" },
				{3043, 9514, "", "地" },
				{11539, 5150, "", "人" }
			},
			tbDefendPos = {4127, 4166},
			tbPosBackCampOut = {{4824, 4824}}; --踩到出后营trap 传送的点
			tbPosBackCampIn = {{4127, 4166}}; --踩到进后营trap 传送的点
			tbCampDynamicObstacle = {   -- 一开始的各个营地障碍npc的摆放 位置，朝向
				{9622, 10032, 48},
				{9840, 10042, 48},
				{3570, 9646, 32},
				{3570, 9354, 32},
				{11019, 5303, 64},
				{10996, 5062, 64},
			};

			tbStartPutNpcs = { 	--战斗开始后摆放的npc，可以是后营的传送阵
				{73, 4425, 4456, 0}, --npcId, 位置，朝向
			};

			tbFlogNpcPos = {
				{ 1724, 3, 6552, 6364, 48, "OCC_Longzhu_sun"},
			};
		   },
   [1410] = {
			tbAtackPos = {
				{11607, 11286, "", "天" },
				{4662, 11625, "", "地" },
				{4633, 4282, "", "人" }
			},
			tbDefendPos = {11799, 6730},
			tbPosBackCampOut = {{10910, 6790}}; --踩到出后营trap 传送的点
			tbPosBackCampIn = {{11799, 6730}}; --踩到进后营trap 传送的点
			tbCampDynamicObstacle = {   -- 一开始的各个营地障碍npc的摆放 位置，朝向
				{11098, 11038, 56},
				{11257, 10834, 56},
				{4490, 11127, 48},
				{4775, 11124, 48},
				{5112, 4361, 32},
				{5108, 4108, 32},
			};

			tbStartPutNpcs = { 	--战斗开始后摆放的npc，可以是后营的传送阵
				{73, 11368, 6805, 0}, --npcId, 位置，朝向
			};

			tbFlogNpcPos = {
				{ 1724, 3, 7924, 7658, 48, "OCC_Longzhu_sun"},
			};
		   },
   [1411] = {
			tbAtackPos = {
				{4013, 11719, "", "天" },
				{4371, 4020, "", "地" },
				{12529, 4521, "", "人" }
			},
			tbDefendPos = {11325, 10686},
			tbPosBackCampOut = {{11227, 9879}}; --踩到出后营trap 传送的点
			tbPosBackCampIn = {{11325, 10686}}; --踩到进后营trap 传送的点
			tbCampDynamicObstacle = {   -- 一开始的各个营地障碍npc的摆放 位置，朝向
				{4297, 11213, 40},
				{4491, 11377, 40},
				{4678, 4484, 24},
				{4858, 4288, 24},
				{12093, 4847, 8},
				{12307, 5063, 8},
			};
			tbStartPutNpcs = { 	--战斗开始后摆放的npc，可以是后营的传送阵
				{73, 11258, 10321, 0}, --npcId, 位置，朝向
			};
			tbFlogNpcPos = {
				{ 1724, 3, 8429, 8322, 48, "OCC_Longzhu_sun"},
			};
		   },
   [1412] = {
			tbAtackPos = {
				{3049, 8651, "", "天" },
				{5108, 3913, "", "地" },
				{12963, 6173, "", "人" }
			},
			tbDefendPos = {8516, 12643},
			tbPosBackCampOut = {{8508, 11837}}; --踩到出后营trap 传送的点
			tbPosBackCampIn = {{8516, 12643}}; --踩到进后营trap 传送的点
			tbCampDynamicObstacle = {   -- 一开始的各个营地障碍npc的摆放 位置，朝向
				{3484, 8746, 32},
				{3489, 8480, 32},
				{5408, 4339, 24},
				{5590, 4138, 24},
				{12837, 6701, 16},
				{13126, 6701, 16},
			};
			tbStartPutNpcs = { 	--战斗开始后摆放的npc，可以是后营的传送阵
				{73, 8489, 12248, 0}, --npcId, 位置，朝向
			};
			tbFlogNpcPos = {
				{ 1724, 3, 8391, 8515, 48, "OCC_Longzhu_sun"},
			};
		   },
}

DomainBattle.STATE_TRANS =
{
	{nSeconds = 300,   	szFunc = "StartFight",  szDesc = "准备阶段"},
	{nSeconds = 60*25, 	szFunc = "StopFight",   szDesc = "战斗阶段"},
	{nSeconds = 10,   	szFunc = "CloseBattle", szDesc = "结算阶段"},
}

--在active 的指定帧数下执行的函数
DomainBattle.tbActiveCountFunc =
{
	[60 * 15] 	   = "SynGameTime",
	[60 * 20] 	   = "SynGameTime",
	[60 * 23] 	   = "SynGameTime",
	[60 * 24] 	   = "SynGameTime",
	[60 * 24 + 30]	   = "SynGameTime",
	[60 * 24 + 50] 	   = "SynGameTime",
}

DomainBattle.tbMapLevelDesc =
{
	[DomainBattle.DEFINE_CITY] = "主城",
	[DomainBattle.DEFINE_TOWN] = "村镇",
	[DomainBattle.DEFINE_FIELD] = "野外",
}




----------配置截止-----------------

DomainBattle.tbMapPosSetting = tbMapPosSetting

DomainBattle.tbMapSetting = tbMapSetting;

local fnSetMapLevel = function ()
	local tbMapLevel = {}
	tbMapLevel[tbMapSetting.nMapTemplateId] = {1}
	for i1, v1 in ipairs(tbMapSetting.tbChilds) do
		tbMapLevel[v1.nMapTemplateId] = { 2, i1 }
		for i2, v2 in ipairs(v1.tbChilds) do
			tbMapLevel[v2.nMapTemplateId] = {3, i1, i2}
		end
	end

	DomainBattle.tbMapLevel = tbMapLevel; -- [nMapTemplateId] = { nLevel, index1, index2}
end
fnSetMapLevel();

function DomainBattle:GetMapSetting(nMapTemplateId)
	return self.tbMapPosSetting[nMapTemplateId]
end


function DomainBattle:GetMapLevel(nMapTemplateId)
	local tb = self.tbMapLevel[nMapTemplateId]
	if tb then
		return tb[1]
	end
end

function DomainBattle:GetLevelMaps(nLevel)
	if nLevel == 1 then
		return { self.tbMapSetting.nMapTemplateId }
	elseif nLevel == 2 then
		local tbMaps = {}
		for i, v in ipairs(self.tbMapSetting.tbChilds) do
			table.insert(tbMaps, v.nMapTemplateId)
		end
		return tbMaps
	elseif nLevel == 3 then
		local tbMaps = {}
		for i, v in ipairs(self.tbMapSetting.tbChilds) do
			for i2,v2 in ipairs(v.tbChilds) do
				table.insert(tbMaps, v2.nMapTemplateId)
			end
		end
		return tbMaps
	end
end

function DomainBattle:GetFatherLinkMap(nMapTemplateId)
	local tbMapLevel = self.tbMapLevel[nMapTemplateId]
	if not tbMapLevel then
		return
	end
	local nLevel, index1, index2 = unpack(tbMapLevel)
	if index2 then
		return  self.tbMapSetting.tbChilds[index1].nMapTemplateId
	end
	if  index1 then
		return  self.tbMapSetting.nMapTemplateId
	end
end

function DomainBattle:GetChildLinkMap(nMapTemplateId)
	local tbMapLevel = self.tbMapLevel[nMapTemplateId]
	if not tbMapLevel then
		return
	end

	local nLevel, index1, index2 = unpack(tbMapLevel)
	if index2 then
		return;
	end

	if index1 then
		local tbChilds = {}
		for i, v in ipairs(self.tbMapSetting.tbChilds[index1].tbChilds) do
			table.insert(tbChilds, v.nMapTemplateId)
		end
		return tbChilds
	end

	local tbChilds = {}
	for i,v in ipairs(self.tbMapSetting.tbChilds) do
		table.insert(tbChilds, v.nMapTemplateId)
	end
	return tbChilds
end

--根据龙柱状态获取的胜利家族
function DomainBattle:GetWinKin(tbFlagState, nMapTemplateId)
	local tbFlogNpcPos = self.tbMapPosSetting[nMapTemplateId].tbFlogNpcPos
	local tbFlagVal = {}
	local nMaxVal = 0;
	local tbWinKin;
	for nIndex, v in ipairs(tbFlagState) do
		local dwKinId = v[1]
		if dwKinId ~= - 1 then
			tbFlagVal[dwKinId] = (tbFlagVal[dwKinId] or 0) + tbFlogNpcPos[nIndex][2];
			if tbFlagVal[dwKinId]  > nMaxVal then
				nMaxVal = tbFlagVal[dwKinId];
				tbWinKin = v;
			end
		end
	end
	return tbWinKin
end

function DomainBattle:CanKinSignUpMap(nMapTemplateId, nBattleVersion)
	if nBattleVersion == 0 then
		return false, "当前未开启宣战"
	end
	local nMapLevel = self:GetMapLevel(nMapTemplateId)
	if not nMapLevel then
		return false, "无效的宣战地图"
	end
	if nBattleVersion == 1 then
		if nMapLevel < 3 then
			return false, "当前领地暂未开放宣战"
		end
	elseif nBattleVersion == 2 then
		if nMapLevel < 2 then
			return false, "当前领地暂未开放宣战"
		end
	end
	return true
end

function DomainBattle:Honor2Box(dwRoleId, nGetHonor, tbAwardList)
	local nCurHonor = 0;
	local nBoxCount = 0;
	local nLeftHonor = 0;

	if not tbAwardList then
		return nCurHonor, nBoxCount, nLeftHonor;
	end

	local pAsync = KPlayer.GetAsyncData(dwRoleId);
	if  not pAsync then
		return nCurHonor, nBoxCount, nLeftHonor;
	end

	nCurHonor = pAsync.GetDomainHonor();

	nLeftHonor = nCurHonor + nGetHonor;

	local tbTimeFrameAward;
	for i, v in ipairs(self.define.tbExchangeBoxHonor) do
		if GetTimeFrameState(v[1]) ~= 1 then
			break;
		end
		tbTimeFrameAward = v;
	end
	if not tbTimeFrameAward then
		Log(debug.traceback())
		return
	end

	local nCanChangeNum = math.floor(nLeftHonor / tbTimeFrameAward[3])
	if nCanChangeNum > 0 then
		local nCostHonor = nCanChangeNum * tbTimeFrameAward[3]
		nLeftHonor = nLeftHonor - nCostHonor

		table.insert(tbAwardList, {"item", tbTimeFrameAward[2], nCanChangeNum })
		nBoxCount = nBoxCount + nCanChangeNum
	end

	return nCurHonor, nBoxCount, nLeftHonor;
end

function DomainBattle:GetBaseMapScore(nMapTemplateId)
	local tbFlagScore = self.define.tbFlagScore
	local nMapLevel = DomainBattle:GetMapLevel(nMapTemplateId)
	local tbMapPosSetting = DomainBattle.tbMapPosSetting[nMapTemplateId]
    local tbFlogNpcPos = tbMapPosSetting.tbFlogNpcPos
    local nTotalScore = 0
    for i,v in ipairs(tbFlogNpcPos) do
        local nFlagLevel = v[2]
        nTotalScore = nTotalScore + tbFlagScore[nMapLevel][nFlagLevel][1]
    end
    return nTotalScore
end

function DomainBattle:IsCanKickPlayer( pPlayer )
	local nMapTemplateId = pPlayer.nMapTemplateId
	if not DomainBattle.tbMapPosSetting[nMapTemplateId] then
		return
	end

	local nCareer;
	--todo 跨服如果是服务端怎么获取职位信息
	if not MODULE_GAMESERVER then
		local tbCareer = Kin:GetMemberCareer()
		if not tbCareer or not next(tbCareer) then
			Kin:UpdateMemberCareer();
			return
		end
		nCareer = tbCareer[pPlayer.dwID]
	else
		local tbMember = Kin:GetMemberData(pPlayer.dwID)
		if not tbMember then
			return
		end
		nCareer = tbMember:GetCareer()
	end
	if not nCareer then
		return
	end

	if not self.define.tbCanKickRoleCareer[nCareer]  then
		return;
	end
	return true
end

--TODO 配置格式检查

