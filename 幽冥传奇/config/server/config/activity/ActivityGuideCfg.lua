--#include "..\..\language\LangCode.txt" once
ACTIVITY_DEFINE_SIEGE 				= 1
ACTIVITY_DEFINE_WORSHIP			 	= 2
ACTIVITY_DEFINE_ENTRUST_QUEST	 	= 3
ACTIVITY_DEFINE_BOSS_HOME			= 4
ACTIVITY_DEFINE_ALLDAY				= 5
ACTIVITY_DEFINE_STONE_TOMB			= 6
ACTIVITY_DEFINE_BAOZANG 			= 7
ACTIVITY_DEFINE_DOUBLE_EXP 			= 8
ACTIVITY_DEFINE_TWELVE_PALACES		= 9
ACTIVITY_DEFINE_WILD_BOSS			= 10
ACTIVITY_DEFINE_PERSON_BOSS			= 11
ACTIVITY_DEFINE_MAYA_PALACE 		= 12
ACTIVITY_DEFINE_LOCK_BOSS			= 13
ACTIVITY_DEFINE_MATERIAL			= 14
ACTIVITY_DEFINE_BOSS_ATTACK	  		= 15
ACTIVITY_DEFINE_EACORT 				= 17
ACTIVITY_DEFINE_GUILD_BOSS 			= 18
ACTIVITY_DEFINE_NIFHTFIFHTING		= 19
ACTIVITY_DEFINE_SECRETTREASURE		= 20
ACTIVITY_DEFINE_TREASURE_MAP  		= 21
ACTIVITY_DEFINE_DREAMLANDBOSS		= 22
ACTIVITY_DEFINE_TIANHUANG			= 23
ACTIVITY_DEFINE_MAGICCITY			= 24
ACTIVITY_DEFINE_MOZUN				= 25
ACTIVITY_DEFINE_SPACETRIAL			= 26
ACTIVITY_DEFINE_EQUIPBOSS			= 27
ACTIVITY_DEFINE_BOSSBATTLEFIELD		= 28
ACTIVITY_DEFINE_VIPSCENE			= 29
ACTIVITY_DEFINE_MULPHAADVENTURE		= 30
ACTIVITY_DEFINE_BLOODFIGHT			= 31
ACTIVITY_DEFINE_DART				= 32
ACTIVITY_DEFINE_ARENABOSS			= 33
ACTIVITY_DEFINE_SCENEANSWER			= 34
ACTIVITY_DEFINE_WanShouMoPu			= 35
ACTIVITY_DEFINE_TUCITY_FIGHT		= 36
ACTIVITY_DEFINE_PERSON_ANSWER		= 37
ACTIVITY_DEFINE_SKYTOWER			= 38
ACTIVITY_DEFINE_HUNT_BOSSTREASURE	= 39
ACTIVITY_DEFINE_CROSS_BOSS_ATTACK	= 40
ACTIVITY_DEFINE_CROSS_UNION_WAR		= 41
ACTIVITY_DEFINE_EQUIP_RECOVER		= 42
ACTIVITY_DEFINE_SERVERPK		    = 43
ACTIVITY_DEFINE_SUPPLY_CONTENTION	= 44
ACTIVITY_DEFINE_DARK_BOX 			= 45
ACTIVITY_DEFINE_WORLD_BOSS			= 46
ACTIVITY_DEFINE_FIRE_DRAGON			= 47
ACTIVITY_DEFINE_CROSS_LEAGUE		= 48
ACTIVITY_DEFINE_CROSS_CRYSTAL		= 49
ACTIVITY_DEFINE_CROSS_EATCHICKEN	= 50
ACT_TYPE_CNT = 2
ActivityGuideCfg =
{
	{
		groupName 	= Lang.ScriptTips.ActivityGuildGroupName01,
		activities 	=
		{
			{
			    ActivityType        = 1,
				id 			= ACTIVITY_DEFINE_CROSS_BOSS_ATTACK,
				name 		= Lang.ScriptTips.ActivityGuildName0406,
				icon 		= 13,
				condDesc	= Lang.ScriptTips.ActivityGuildCond0406,
				timeDesc	= Lang.ScriptTips.ActivityGuildTime0406,
				ruleDesc	= Lang.ScriptTips.ActivityGuildRule0406,
				showAwards 	=
				{
				},
				openTimes=
				{
					{	openserverdays 	= {3},
					    validTime 			= {{14,00},{23,30}},
					},
					{
						notopenserverdays 	= {1,2},
					    validTime 			= {{14,00},{23,30}},
					},
				},
				teleId = 227,
				levelLimit = {2,80},
				isNotify = true,
				rank = 5,
				isEffect = true,
				isSimpleTip = true,
			},
			{
			    ActivityType        = 1,
				id 			= ACTIVITY_DEFINE_CROSS_LEAGUE,
				name 		= Lang.ScriptTips.ActivityGuildName0426,
				icon 		= 34,
				condDesc	= Lang.ScriptTips.ActivityGuildCond0426,
				timeDesc	= Lang.ScriptTips.ActivityGuildTime0426,
				ruleDesc	= Lang.ScriptTips.ActivityGuildRule0426,
				showAwards 	=
				{
				},
				openTimes=
				{
					{	openserverdays 	= {3},
					    validTime 			= {{20,30},{22,50}},
					},
					{
						notopenserverdays 	= {1,2},
					    validTime 			= {{20,30},{22,50}},
					},
				},
				teleId = 227,
				levelLimit = {2,80},
				isNotify = true,
				rank = 5,
				isEffect = true,
				isSimpleTip = true,
			},
			{
			    ActivityType        = 1,
				id 			= ACTIVITY_DEFINE_CROSS_EATCHICKEN,
				name 		= Lang.ScriptTips.ActivityGuildName0427,
				icon 		= 35,
				condDesc	= Lang.ScriptTips.ActivityGuildCond0427,
				timeDesc	= Lang.ScriptTips.ActivityGuildTime0427,
				ruleDesc	= Lang.ScriptTips.ActivityGuildRule0427,
				showAwards 	=
				{
				},
				openTimes=
				{
					{	openserverdays 	= {3},
					    validTime 			= {{18,01},{20,30}},
					},
					{
						notopenserverdays 	= {1,2},
					    validTime 			= {{20,30},{22,50}},
					},
				},
				teleId = 227,
				levelLimit = {2,80},
				isNotify = true,
				rank = 5,
				isEffect = true,
				isSimpleTip = true,
			},
			{
			    ActivityType        = 1,
				id 			= ACTIVITY_DEFINE_CROSS_CRYSTAL,
				name 		= Lang.ScriptTips.ActivityGuildName0428,
				icon 		= 36,
				condDesc	= Lang.ScriptTips.ActivityGuildCond0428,
				timeDesc	= Lang.ScriptTips.ActivityGuildTime0428,
				ruleDesc	= Lang.ScriptTips.ActivityGuildRule0428,
				showAwards 	=
				{
				},
				openTimes=
				{
					{	openserverdays 	= {3},
					    validTime 			= {{20,35},{22,30}},
					},
					{
						notopenserverdays 	= {1,2},
					    validTime 			= {{20,30},{22,50}},
					},
				},
				teleId = 227,
				levelLimit = {2,80},
				isNotify = true,
				rank = 5,
				isEffect = true,
				isSimpleTip = true,
			},
			{
			    ActivityType        = 2,
			    achieveId = 312,
				id 			= ACTIVITY_DEFINE_ENTRUST_QUEST,
				name 		= Lang.ScriptTips.ActivityGuildName0101,
				icon 		= 4,
				condDesc	= Lang.ScriptTips.ActivityGuildCond0101,
				timeDesc	= Lang.ScriptTips.ActivityGuildTime0101,
				ruleDesc	= Lang.ScriptTips.ActivityGuildRule0101,
				showAwards 	=
				{
					{ type = 1, id = 0, count = 1 },
					{ type = 29, id = 0, count = 1 },
				},
				openTimes=
				{
					{
						validTime 		= {{0,0},{23,59}},
					},
				},
				teleId = 150,
				levelLimit = {0,69},
				isNotify = true,
				rank = 5,
				sorting = 5,
			},
			{
				ActivityType        = 2,
				achieveId = 310,
				id 			= ACTIVITY_DEFINE_STONE_TOMB,
				name 		= Lang.ScriptTips.ActivityGuildName0102,
				icon 		= 4,
				condDesc	= Lang.ScriptTips.ActivityGuildCond0102,
				timeDesc	= Lang.ScriptTips.ActivityGuildTime0102,
				ruleDesc	= Lang.ScriptTips.ActivityGuildRule0102,
				showAwards 	=
				{
					{ type = 1, id = 0, count = 1 },
				},
				openTimes=
				{
					{
						validTime 		= {{0,0},{23,59}},
					},
				},
				teleId = 108,
				levelLimit = {0,73},
				isNotify = true,
				rank = 5,
				sorting = 6,
			},
			{
			    ActivityType        = 1,
			    achieveId = 313,
				id 			= ACTIVITY_DEFINE_DOUBLE_EXP,
				name 		= Lang.ScriptTips.ActivityGuildName0103,
				icon 		= 4,
				condDesc	= Lang.ScriptTips.ActivityGuildCond0103,
				timeDesc	= Lang.ScriptTips.ActivityGuildTime0103,
				ruleDesc	= Lang.ScriptTips.ActivityGuildRule0103,
				showAwards 	=
				{
					{ type = 1, id = 0, count = 1 },
				},
				openTimes=
				{
					{
						validTime 		= {{15,0},{17,0}},
					},
					{
						validTime 		= {{22,0},{23,59}},
					},
				},
				teleId = 109,
				levelLimit = {0,1},
				isNotify = false,
				rank = 2,
			},
			{
			    ActivityType        = 2,
			    achieveId = 305,
				id 			= ACTIVITY_DEFINE_TWELVE_PALACES,
				name 		= Lang.ScriptTips.ActivityGuildName0104,
				icon 		= 1,
				condDesc	= Lang.ScriptTips.ActivityGuildCond0104,
				timeDesc	= Lang.ScriptTips.ActivityGuildTime0104,
				ruleDesc	= Lang.ScriptTips.ActivityGuildRule0104,
				showAwards 	=
				{
					{ type = 1, id = 0, count = 1 },
					{ type = 0, id = 4458, count = 1 },
					{ type = 0, id = 4023, count = 1 },
				},
				openTimes=
				{
					{
						validTime 		= {{0,0},{23,59}},
					},
				},
				teleId = 134,
				levelLimit = {0,70},
				isNotify = true,
				rank = 5,
				isEffect = false,
			},
			{
			    ActivityType        = 1,
			    achieveId = 315,
				id 			= ACTIVITY_DEFINE_WORSHIP,
				name 		= Lang.ScriptTips.ActivityGuildName0105,
				icon 		= 7,
				condDesc	= Lang.ScriptTips.ActivityGuildCond0105,
				timeDesc	= Lang.ScriptTips.ActivityGuildTime0105,
				ruleDesc	= Lang.ScriptTips.ActivityGuildRule0105,
				showAwards 	=
				{
					{ type = 1, id = 0, count = 1 },
				},
				openTimes=
				{
					{
						validTime 		= {{12,0},{12,15}},
					},
					{
						validTime 		= {{18,0},{18,15}},
					},
				},
				teleId = 110,
				levelLimit = {0,50},
				isNotify = true,
				rank = 5,
				isEffect = true,
			},
			{
			    ActivityType        = 1,
			    achieveId = 513,
				id 			= ACTIVITY_DEFINE_SUPPLY_CONTENTION,
				name 		= Lang.ScriptTips.ActivityGuildName0421,
				icon 		= 31,
				condDesc	= Lang.ScriptTips.ActivityGuildCond0421,
				timeDesc	= Lang.ScriptTips.ActivityGuildTime0421,
				ruleDesc	= Lang.ScriptTips.ActivityGuildRule0421,
				showAwards 	=
				{
					{ type = 1, id = 0, count = 1 },
					{ type = 0, id = 4091, count = 1 },
				},
				openTimes=
				{
					{
						validTime 		= {{14,00},{14,20}},
					},
				},
				teleId = 252,
				levelLimit = {0,70},
				isNotify = true,
				rank = 5,
				isEffect = true,
			},
			{
			    ActivityType        = 1,
			    achieveId = 427,
				id 		= ACTIVITY_DEFINE_DARK_BOX,
				name 		= Lang.ScriptTips.ActivityGuildName0107,
				icon 		= 3,
				condDesc	= Lang.ScriptTips.ActivityGuildCond0107,
				timeDesc	= Lang.ScriptTips.ActivityGuildTime0107,
				ruleDesc	= Lang.ScriptTips.ActivityGuildRule0107,
				showAwards 	=
				{
					{ type = 1, id = 0, count = 1 },
					{ type = 0, id = 4094, count = 1 },
				},
				openTimes=
				{
					{
						validTime 		= {{19,00},{19,30}},
					},
				},
				teleId = 219,
				levelLimit = {0,70},
				isNotify = true,
				rank = 4,
				isEffect = true,
			},
		},
	},
	{
		groupName 	= Lang.ScriptTips.ActivityGuildGroupName02,
		activities 	=
		{
			{
			    ActivityType        = 2,
			    achieveId = 311,
				id 			= ACTIVITY_DEFINE_LOCK_BOSS,
				name 		= Lang.ScriptTips.ActivityGuildName0206,
				icon 		= 12,
				condDesc	= Lang.ScriptTips.ActivityGuildCond0206,
				timeDesc	= Lang.ScriptTips.ActivityGuildTime0206,
				ruleDesc	= Lang.ScriptTips.ActivityGuildRule0206,
				showAwards 	=
				{
						{ type = 0, id = 3161, count = 1 },
						{ type = 0, id = 3261, count = 1 },
						{ type = 0, id = 3361, count = 1 },
						{ type = 0, id = 3221, count = 1 },
				},
				openTimes=
				{
					{
						validTime 		= {{0,0},{23,59}},
					},
				},
				teleId = 203,
				levelLimit = {1,80},
				isNotify = false,
				rank = 5,
			},
		},
	},
	{
		groupName 	= Lang.ScriptTips.ActivityGuildGroupName03,
		activities 	=
		{
			{
			    ActivityType        = 2,
			    achieveId = 298,
				id 			= ACTIVITY_DEFINE_ALLDAY,
				name 		= Lang.ScriptTips.ActivityGuildName0302,
				icon 		= 10,
				condDesc	= Lang.ScriptTips.ActivityGuildCond0302,
				timeDesc	= Lang.ScriptTips.ActivityGuildTime0302,
				ruleDesc	= Lang.ScriptTips.ActivityGuildRule0302,
				showAwards 	=
				{
					{ type = 0, id = 4001, count = 1 },
					{ type = 0, id = 4028, count = 1 },
					{ type = 0, id = 4023, count = 1 },
					{ type = 0, id = 4002, count = 1 },
					{ type = 0, id = 4038, count = 1 },
					{ type = 0, id = 4047, count = 1 },
				},
				openTimes=
				{
					{
						validTime 		= {{0,0},{23,59}},
					},
				},
				teleId = 107,
				levelLimit = {0,50},
				isNotify = false,
				rank = 9,
				sorting = 9,
			},
			{
			    ActivityType        = 1,
			    achieveId = 316,
				id 			= ACTIVITY_DEFINE_BAOZANG,
				name 		= Lang.ScriptTips.ActivityGuildName0304,
				icon 		= 5,
				condDesc	= Lang.ScriptTips.ActivityGuildCond0304,
				timeDesc	= Lang.ScriptTips.ActivityGuildTime0304,
				ruleDesc	= Lang.ScriptTips.ActivityGuildRule0304,
				showAwards 	=
				{
					{ type = 0, id = 4081, count = 1 },
					{ type = 0, id = 4020, count = 1 },
					{ type = 0, id = 4015, count = 1 },
				},
				openTimes=
				{
					{
						validTime 		= {{10,30},{11,30}},
					},
					{
						validTime 		= {{16,45},{17,45}},
					},
				},
				teleId = 111,
				levelLimit = {0,50},
				isNotify = true,
				rank = 3,
				isEffect = true,
			},
			{
			    ActivityType        = 1,
			    achieveId = 304,
				id 			= ACTIVITY_DEFINE_EACORT ,
				name 		= Lang.ScriptTips.ActivityGuildName0407,
				icon 		= 22,
				condDesc	= Lang.ScriptTips.ActivityGuildCond0407,
				timeDesc	= Lang.ScriptTips.ActivityGuildTime0407,
				ruleDesc	= Lang.ScriptTips.ActivityGuildRule0407,
				showAwards 	=
				{
				    { type = 1, id = 0, count = 1 },
				    { type = 5, id = 0, count = 1 },
				},
				openTimes=
				{
					{
						validTime 		= {{15,0},{16,0}},
					},
					{
						validTime 		= {{21,30},{22,30}},
					},
				},
				teleId = 126,
				levelLimit = {0,70},
				isNotify = true,
				rank = 3,
				isEffect = true,
			},
			{
			    ActivityType        = 2,
			    achieveId = 299,
				id 			= ACTIVITY_DEFINE_WanShouMoPu,
				name 		= Lang.ScriptTips.ActivityGuildName0408,
				icon 		= 4,
				condDesc	= Lang.ScriptTips.ActivityGuildCond0408,
				timeDesc	= Lang.ScriptTips.ActivityGuildTime0408,
				ruleDesc	= Lang.ScriptTips.ActivityGuildRule0408,
				showAwards 	=
				{
                    { type = 1, id = 0, count = 1 },
					{ type = 0, id = 4092, count = 1 },
				},
				openTimes=
				{
					{
						validTime 		= {{0,0},{23,59}},
					},
				},
				teleId = 124,
				levelLimit = {0,76},
				isNotify = false,
				rank = 5,
				sorting = 8,
			},
			{
			    ActivityType        = 1,
			    achieveId = 406,
				id 			= ACTIVITY_DEFINE_SECRETTREASURE,
				name 		= Lang.ScriptTips.ActivityGuildName0204,
				icon 		= 25,
				condDesc	= Lang.ScriptTips.ActivityGuildCond0204,
				timeDesc	= Lang.ScriptTips.ActivityGuildTime0204,
				ruleDesc	= Lang.ScriptTips.ActivityGuildRule0204,
				showAwards 	=
				{
					{ type = 0, id = 4094, count = 1 },
					{ type = 0, id = 4096, count = 1 },
					{ type = 0, id = 772, count = 1 },
					{ type = 0, id = 782, count = 1 },
					{ type = 0, id = 792, count = 1 },
				},
				openTimes=
				{
					{
						validTime 		= {{12,15},{12,45}},
					},
				},
				teleId = 106,
				levelLimit = {0,70},
				isNotify = true,
				rank = 3,
				sorting = 12,
			},
			{
			    ActivityType        = 1,
			    achieveId = 407,
				id 			= ACTIVITY_DEFINE_BOSSBATTLEFIELD,
				name 		= Lang.ScriptTips.ActivityGuildName0405,
				icon 		= 27,
				condDesc	= Lang.ScriptTips.ActivityGuildCond0405,
				timeDesc	= Lang.ScriptTips.ActivityGuildTime0405,
				ruleDesc	= Lang.ScriptTips.ActivityGuildRule0405,
				showAwards 	=
				{
					{ type = 1, id = 0, count = 1 },
					{ type = 0, id = 4074, count = 1 },
					{ type = 0, id = 771, count = 1 },
					{ type = 0, id = 781, count = 1 },
					{ type = 0, id = 791, count = 1 },
				},
				openTimes=
				{
					{
					notopenserverdays 	= {1,2,3,4,5,},
						validTime 		= {{11,30},{11,45}},
					},
					{
					notopenserverdays 	= {1,2,3,4,5,},
						validTime 		= {{14,45},{15,00}},
					},
				},
				teleId = 225,
				levelLimit = {0,75},
				isNotify = true,
				rank = 3,
				sorting = 13,
			},
			{
			    ActivityType        = 2,
			    achieveId = 307,
				id 			= ACTIVITY_DEFINE_ARENABOSS,
				name 		= Lang.ScriptTips.ActivityGuildName0411,
				icon 		= 15,
				condDesc	= Lang.ScriptTips.ActivityGuildCond0411,
				timeDesc	= Lang.ScriptTips.ActivityGuildTime0411,
				ruleDesc	= Lang.ScriptTips.ActivityGuildRule0411,
				showAwards 	=
				{
					{ type = 0, id = 411, count = 1 },
					{ type = 0, id = 412, count = 1 },
					{ type = 0, id = 421, count = 1 },
					{ type = 1, id = 0, count = 1 },
					{ type = 17, id = 0, count = 1 },
					{ type = 3, id = 0, count = 1 },
				},
				openTimes=
				{
					{
						validTime 		= {{0,0},{23,59}},
					},
				},
				teleId = 127,
				levelLimit = {0,65},
				isNotify = false,
				rank = 3,
				sorting = 7,
			},
			{
			    ActivityType        = 1,
			    achieveId = 408,
				id 			= ACTIVITY_DEFINE_NIFHTFIFHTING,
				name 		= Lang.ScriptTips.ActivityGuildName0401,
				icon 		= 28,
				condDesc	= Lang.ScriptTips.ActivityGuildCond0401,
				timeDesc	= Lang.ScriptTips.ActivityGuildTime0401,
				ruleDesc	= Lang.ScriptTips.ActivityGuildRule0401,
				showAwards 	=
				{
					{ type = 1, id = 0, count = 1 },
					{ type = 0, id = 4075, count = 1 },
				},
				openTimes=
				{
					{
						validTime 			= {{18,15},{18,45}},
					},
				},
				teleId = 105,
				levelLimit = {0,70},
				isNotify = true,
				rank = 3,
				sorting = 14,
			},
			{
			    ActivityType        = 1,
			    achieveId = 410,
				id 			= ACTIVITY_DEFINE_TIANHUANG,
				name 		= Lang.ScriptTips.ActivityGuildName0306,
				icon 		= 30,
				condDesc	= Lang.ScriptTips.ActivityGuildCond0306,
				timeDesc	= Lang.ScriptTips.ActivityGuildTime0306,
				ruleDesc	= Lang.ScriptTips.ActivityGuildRule0306,
				showAwards 	=
				{
					{ type = 1, id = 0, count = 1 },
					{ type = 0, id = 4043, count = 1 },
					{ type = 0, id = 3423, count = 1 },
					{ type = 0, id = 771, count = 1 },
					{ type = 0, id = 781, count = 1 },
					{ type = 0, id = 791, count = 1 },
				},
				openTimes=
				{
					{
					    notopenserverdays 	= {1,2,3,4,},
						validTime 		= {{21,15},{22,15}},
					},
					{
					notopenserverdays 	= {1,2,3,4,},
						validTime 		= {{21,15},{22,15}},
					},
				},
				teleId = 220,
				levelLimit = {4,80},
				isNotify = true,
				rank = 3,
				sorting = 16,
			},
			{
			    ActivityType        = 1,
			    achieveId = 405,
				id 			= ACTIVITY_DEFINE_BOSS_ATTACK,
				name 		= Lang.ScriptTips.ActivityGuildName0305,
				icon 		= 26,
				condDesc	= Lang.ScriptTips.ActivityGuildCond0305,
				timeDesc	= Lang.ScriptTips.ActivityGuildTime0305,
				ruleDesc	= Lang.ScriptTips.ActivityGuildRule0305,
				showAwards 	=
				{
					{ type = 1, id = 0, count = 1 },
					{ type = 0, id = 771, count = 1 },
					{ type = 0, id = 781, count = 1 },
					{ type = 0, id = 791, count = 1 },
				},
				openTimes=
				{
					{
						openserverdays 	= {1,2,3},
						validTime 		= {{20,0},{21,0}},
					},
					{
						notopenserverdays 	= {4,5},
						notcombineserverdays = {4,5},
						weeks 				= {0,0,0,0,0,0,1},
						validTime 			= {{20,0},{21,0}},
					},
				},
				teleId = 122,
				levelLimit = {0,50},
				isNotify = true,
				rank = 17,
				sorting = 17,
			},
			{
			    ActivityType        = 2,
			    achieveId = 309,
				id 			= ACTIVITY_DEFINE_ARENABOSS,
				name 		= Lang.ScriptTips.ActivityGuildName0414,
				icon 		= 24,
				condDesc	= Lang.ScriptTips.ActivityGuildCond0414,
				timeDesc	= Lang.ScriptTips.ActivityGuildTime0414,
				ruleDesc	= Lang.ScriptTips.ActivityGuildRule0414,
				showAwards 	=
				{
					{ type = 0, id = 538, count = 1 },
					{ type = 0, id = 539, count = 1 },
					{ type = 0, id = 548, count = 1 },
					{ type = 0, id = 549, count = 1 },
					{ type = 0, id = 558, count = 1 },
					{ type = 0, id = 559, count = 1 },
				},
				openTimes=
				{
					{
						validTime 		= {{0,0},{23,59}},
					},
				},
				teleId = 131,
				levelLimit = {0,50},
				isNotify = false,
				rank = 3,
				sorting = 2,
			},
			{
			    ActivityType        = 2,
			    achieveId = 412,
				id 			= ACTIVITY_DEFINE_EQUIP_RECOVER,
				name 		= Lang.ScriptTips.ActivityGuildName0420,
				icon 		= 4,
				condDesc	= Lang.ScriptTips.ActivityGuildCond0420,
				timeDesc	= Lang.ScriptTips.ActivityGuildTime0420,
				ruleDesc	= Lang.ScriptTips.ActivityGuildRule0420,
				showAwards 	=
				{
					{ type = 1, id = 0, count = 1 },
					{ type = 22, id = 0, count = 1 },
				},
				openTimes=
				{
					{
						validTime 		= {{0,0},{23,59}},
					},
				},
				teleId = 117,
				levelLimit = {0,55},
				isNotify = false,
				rank = 3,
				sorting = 8,
			},
			{
			    ActivityType        = 1,
				id 			= ACTIVITY_DEFINE_SERVERPK,
				achieveId = 322,
				name 		= Lang.ScriptTips.ActivityGuildName0413,
				icon 		= 23,
				condDesc	= Lang.ScriptTips.ActivityGuildCond0413,
				timeDesc	= Lang.ScriptTips.ActivityGuildTime0413,
				ruleDesc	= Lang.ScriptTips.ActivityGuildRule0413,
				showAwards 	=
				{
					{ type = 0, id = 4272, count = 1 },
					{ type = 5, id = 0, count = 1 },
					{ type = 0, id = 4003, count = 1 },
				},
				openTimes=
				{
					{
						notopenserverdays 	= {1,2,3,4,},
						notcombineserverdays = {1,2,3,4,},
						weeks 				= {0,1,0,1,0,1,0},
						validTime 			= {{20,0},{21,0}},
					},
				},
				teleId = 129,
				levelLimit = {0,70},
				isNotify = true,
				rank = 5,
				isEffect = true,
			},
			{
			    ActivityType        = 1,
				id 			= ACTIVITY_DEFINE_SIEGE,
				achieveId = 411,
				name 		= Lang.ScriptTips.ActivityGuildName0402,
				icon 		= 9,
				condDesc	= Lang.ScriptTips.ActivityGuildCond0402,
				timeDesc	= Lang.ScriptTips.ActivityGuildTime0402,
				ruleDesc	= Lang.ScriptTips.ActivityGuildRule0402,
				showAwards 	=
				{
					{ type = 0, id = 4326, count = 1 },
					{ type = 0, id = 4328, count = 1 },
					{ type = 0, id = 4330, count = 1 },
					{ type = 0, id = 4331, count = 1 },
				},
				openTimes=
				{
					{
						openserverdays 	= {4},
						validTime 		= {{20,0},{21,0}},
					},
					{
						combineserverdays = {4},
						validTime 		= {{20,0},{21,0}},
					},
					{
						notopenserverdays 	= {1,2,3,5},
						notcombineserverdays = {1,2,3,5},
						weeks 				= {1,0,1,0,1,0,0},
						validTime 			= {{20,0},{21,0}},
					},
				},
				teleId = 112,
				levelLimit = {0,70},
				isNotify = true,
				rank = 5,
				isEffect = true,
			},
			{
			    ActivityType        = 2,
			    achieveId = 324,
				id 			= ACTIVITY_DEFINE_SPACETRIAL,
				name 		= Lang.ScriptTips.ActivityGuildName0418,
				icon 		= 10,
				condDesc	= Lang.ScriptTips.ActivityGuildCond0418,
				timeDesc	= Lang.ScriptTips.ActivityGuildTime0418,
				ruleDesc	= Lang.ScriptTips.ActivityGuildRule0418,
				showAwards 	=
				{
					{ type = 1, id = 0, count = 1 },
					{ type = 35, id = 0, count = 1 },
					{ type = 0, id = 4518, count = 1 },
				},
				openTimes=
				{
					{
						validTime 		= {{0,0},{23,59}},
					},
				},
				teleId = 234,
				levelLimit = {5,80},
				isNotify = true,
				rank = 3,
				sorting = 4,
			},
			{
			    ActivityType        = 1,
			    achieveId = 514,
				id 			= ACTIVITY_DEFINE_WORLD_BOSS ,
				name 		= Lang.ScriptTips.ActivityGuildName0422,
				icon 		= 32,
				condDesc	= Lang.ScriptTips.ActivityGuildCond0422,
				timeDesc	= Lang.ScriptTips.ActivityGuildTime0422,
				ruleDesc	= Lang.ScriptTips.ActivityGuildRule0422,
				showAwards 	=
				{
					{ type = 0, id = 411, count = 1 },
					{ type = 0, id = 421, count = 1 },
					{ type = 0, id = 431, count = 1 },
					{ type = 0, id = 771, count = 1 },
					{ type = 0, id = 781, count = 1 },
					{ type = 0, id = 4647, count = 1 },
				},
				openTimes=
				{
					{
						validTime 		= {{13,00},{13,30}},
					},
				},
				teleId = 253,
				levelLimit = {0,70},
				isNotify = true,
				rank = 5,
				isEffect = true,
			},
			{
			    ActivityType        = 1,
			    achieveId = 429,
				id 			= ACTIVITY_DEFINE_FIRE_DRAGON,
				name 		= Lang.ScriptTips.ActivityGuildName0423,
				icon 		= 33,
				condDesc	= Lang.ScriptTips.ActivityGuildCond0423,
				timeDesc	= Lang.ScriptTips.ActivityGuildTime0423,
				ruleDesc	= Lang.ScriptTips.ActivityGuildRule0423,
				showAwards 	=
				{
					{ type = 0, id = 411, count = 1 },
					{ type = 0, id = 421, count = 1 },
					{ type = 0, id = 431, count = 1 },
					{ type = 0, id = 771, count = 1 },
					{ type = 0, id = 781, count = 1 },
					{ type = 0, id = 791, count = 1 },
				},
				openTimes=
				{
					{
						validTime 		= {{16,00},{16,30}},
					},
				},
				teleId = 251,
				levelLimit = {1,80},
				isNotify = true,
				rank = 5,
				isEffect = true,
			},
		},
	},
	{
		groupName 	= Lang.ScriptTips.ActivityGuildGroupName04,
		activities 	=
		{
		},
	},
dailyActivityAwards =
    {
        {
            ActivityNum = 50,
            awards =
            {
                {
                    cond = {1, 7},
                    dailyAwards = {{ type = 0, id = 1541, count = 1, bind = 1,},},
                },
                {
                    cond = {8, 20},
                    dailyAwards = {{ type = 0, id = 1546, count = 1,bind = 1, },},
                },
                {
                    cond = {21, 50},
                    dailyAwards = {{ type = 0, id = 1551, count = 1,bind = 1, },},
                },
                {
                    cond = {51, 90},
                    dailyAwards = {{ type = 0, id = 1556, count = 1,bind = 1, },},
                },
                {
                    cond = {91, 150},
                    dailyAwards = {{ type = 0, id = 1561, count = 1,bind = 1, },},
                },
                {
                    cond = {151, 9999},
                    dailyAwards = {{ type = 0, id = 1566, count = 1,bind = 1, },},
                },
            },
        },
        {
            ActivityNum = 100,
            awards =
            {
                 {
                    cond = {1, 7},
                    dailyAwards = {{ type = 0, id = 1542, count = 1, bind = 1,},},
                },
                {
                    cond = {8, 20},
                    dailyAwards = {{ type = 0, id = 1547, count = 1,bind = 1, },},
                },
                {
                    cond = {21, 50},
                    dailyAwards = {{ type = 0, id = 1552, count = 1,bind = 1, },},
                },
                {
                    cond = {51, 90},
                    dailyAwards = {{ type = 0, id = 1557, count = 1,bind = 1, },},
                },
                {
                    cond = {91, 150},
                    dailyAwards = {{ type = 0, id = 1562, count = 1,bind = 1, },},
                },
                {
                    cond = {151, 9999},
                    dailyAwards = {{ type = 0, id = 1567, count = 1,bind = 1, },},
                },
            },
        },
        {
            ActivityNum = 150,
            awards =
            {
                {
                    cond = {1, 7},
                    dailyAwards = {{ type = 0, id = 1543, count = 1, bind = 1,},},
                },
                {
                    cond = {8, 20},
                    dailyAwards = {{ type = 0, id = 1548, count = 1,bind = 1, },},
                },
                {
                    cond = {21, 50},
                    dailyAwards = {{ type = 0, id = 1553, count = 1,bind = 1, },},
                },
                {
                    cond = {51, 90},
                    dailyAwards = {{ type = 0, id = 1558, count = 1,bind = 1, },},
                },
                {
                    cond = {91, 150},
                    dailyAwards = {{ type = 0, id = 1563, count = 1,bind = 1, },},
                },
                {
                    cond = {151, 9999},
                    dailyAwards = {{ type = 0, id = 1568, count = 1,bind = 1, },},
                },
            },
        },
        {
            ActivityNum = 200,
            awards =
            {
                {
                    cond = {1, 7},
                    dailyAwards = {{ type = 0, id = 1544, count = 1, bind = 1,},},
                },
                {
                    cond = {8, 20},
                    dailyAwards = {{ type = 0, id = 1549, count = 1,bind = 1, },},
                },
                {
                    cond = {21, 50},
                    dailyAwards = {{ type = 0, id = 1554, count = 1,bind = 1, },},
                },
                {
                    cond = {51, 90},
                    dailyAwards = {{ type = 0, id = 1559, count = 1,bind = 1, },},
                },
                {
                    cond = {91, 150},
                    dailyAwards = {{ type = 0, id = 1564, count = 1,bind = 1, },},
                },
                {
                    cond = {151, 9999},
                    dailyAwards = {{ type = 0, id = 1569, count = 1,bind = 1, },},
                },
            },
        },
        {
            ActivityNum = 250,
            awards =
            {
                {
                    cond = {1, 7},
                    dailyAwards = {{ type = 0, id = 1545, count = 1, bind = 1,},},
                },
                {
                    cond = {8, 20},
                    dailyAwards = {{ type = 0, id = 1550, count = 1,bind = 1, },},
                },
                {
                    cond = {21, 50},
                    dailyAwards = {{ type = 0, id = 1555, count = 1,bind = 1, },},
                },
                {
                    cond = {51, 90},
                    dailyAwards = {{ type = 0, id = 1560, count = 1,bind = 1, },},
                },
                {
                    cond = {91, 150},
                    dailyAwards = {{ type = 0, id = 1565, count = 1,bind = 1, },},
                },
                {
                    cond = {151, 9999},
                    dailyAwards = {{ type = 0, id = 1570, count = 1,bind = 1, },},
                },
            },
        },
    },
}
