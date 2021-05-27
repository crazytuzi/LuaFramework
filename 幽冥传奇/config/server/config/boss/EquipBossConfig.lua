
--#include "..\..\language\LangCode.txt" once
EquipBossCfg =
{
	DefaultOnlineScore = 3000,
	EverySecondOnlineScore = 1,
	EveryCalTime = 300,
	MaxOnlineScore = 30000,
	BossList =
	{
		{
			EquipBossName	= Lang.ScriptTips.EquipBossName001,
			sceneId 		= 105,
			fubenId			= 19,
			fubenTime		= 600,
			LevelLimit 		= {0,70},
			enterPos 		= {18,24},
			openServerDay   = 1,
			monsters =
			{
				{
					cond = {0, 1},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 928, sceneId = 105, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {2, 2},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 936, sceneId = 105, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {3, 5},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 944, sceneId = 105, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {6, 8},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 952, sceneId = 105, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {9, 11},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 960, sceneId = 105, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {12, 99},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 968, sceneId = 105, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
			},
			costOnlineScore = 600,
		},
		{
			EquipBossName	= Lang.ScriptTips.EquipBossName002,
			sceneId 		= 104,
			fubenId			= 18,
			fubenTime		= 600,
			LevelLimit 		= {0,62},
			enterPos 		= {18,24},
			openServerDay   = 1,
			monsters =
			{
			    {
					cond = {0, 1},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 929, sceneId = 104, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {2, 2},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 937, sceneId = 104, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {3, 4},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 945, sceneId = 104, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {5, 6},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 953, sceneId = 104, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {7, 8},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 961, sceneId = 104, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {9, 99},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 969, sceneId = 104, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
			},
			costOnlineScore = 600,
		},
		{
			EquipBossName	= Lang.ScriptTips.EquipBossName003,
			sceneId 		= 106,
			fubenId			= 20,
			fubenTime		= 600,
			LevelLimit 		= {0,65},
			enterPos 		= {18,24},
			openServerDay   = 1,
			monsters =
			{
				{
					cond = {0, 1},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 930, sceneId = 106, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {2, 2},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 938, sceneId = 106, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {3, 4},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 946, sceneId = 106, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {5, 6},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 954, sceneId = 106, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {7, 8},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 962, sceneId = 106, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {9, 99},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 970, sceneId = 106, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
			},
			costOnlineScore = 600,
		},
		{
			EquipBossName	= Lang.ScriptTips.EquipBossName004,
			sceneId 		= 100,
			fubenId			= 14,
			fubenTime		= 600,
			LevelLimit 		= {0,70},
			enterPos 		= {17,26},
			openServerDay   = 1,
			monsters =
			{
				{
					cond = {0, 1},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 931, sceneId = 100, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {2, 2},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 939, sceneId = 100, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {3, 4},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 947, sceneId = 100, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {5, 6},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 955, sceneId = 100, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {7, 8},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 963, sceneId = 100, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {9, 99},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 971, sceneId = 100, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
			},
			costOnlineScore = 600,
		},
		{
			EquipBossName	= Lang.ScriptTips.EquipBossName005,
			sceneId 		= 107,
			fubenId			= 21,
			fubenTime		= 600,
			LevelLimit 		= {0,65},
			enterPos 		= {18,24},
			openServerDay   = 1,
			monsters =
			{
				{
					cond = {0, 1},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 932, sceneId = 107, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {2, 2},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 940, sceneId = 107, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {3, 4},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 948, sceneId = 107, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {5, 6},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 956, sceneId = 107, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {7, 8},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 964, sceneId = 107, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {9, 99},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 972, sceneId = 107, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
			},
			costOnlineScore = 600,
		},
		{
			EquipBossName	= Lang.ScriptTips.EquipBossName006,
			sceneId 		= 103,
			fubenId			= 17,
			fubenTime		= 600,
			LevelLimit 		= {0,62},
			enterPos 		= {18,24},
			openServerDay   = 1,
			monsters =
			{
				{
					cond = {0, 1},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 933, sceneId = 103, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {2, 2},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 941, sceneId = 103, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {3, 4},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 949, sceneId = 103, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {5, 6},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 957, sceneId = 103, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {7, 8},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 965, sceneId = 103, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {9, 99},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 973, sceneId = 103, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
			},
			costOnlineScore = 600,
		},
		{
			EquipBossName	= Lang.ScriptTips.EquipBossName007,
			sceneId 		= 101,
			fubenId			= 15,
			fubenTime		= 600,
			LevelLimit 		= {0,75},
			enterPos 		= {18,24},
			openServerDay   = 1,
			monsters =
			{
				{
					cond = {0, 1},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 934, sceneId = 101, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {2, 2},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 942, sceneId = 101, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {3, 4},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 950, sceneId = 101, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {5, 6},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 958, sceneId = 101, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {7, 8},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 966, sceneId = 101, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {9, 99},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 974, sceneId = 101, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
			},
			costOnlineScore = 3000,
		},
		{
			EquipBossName	= Lang.ScriptTips.EquipBossName008,
			sceneId 		= 102,
			fubenId			= 16,
			fubenTime		= 600,
			LevelLimit 		= {0,80},
			enterPos 		= {18,24},
			openServerDay   = 1,
			monsters =
			{
				{
					cond = {0, 1},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 935, sceneId = 102, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {2, 2},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 943, sceneId = 102, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {3, 4},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 951, sceneId = 102, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {5, 6},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 959, sceneId = 102, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {7, 8},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 967, sceneId = 102, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
				{
					cond = {9, 99},
					monster =
					{
						{
							cond = {1, 255},
							boss = { monsterId = 975, sceneId = 102, num = 1,  pos = {22,32}, livetime = 600,},
						},
					},
				},
			},
			costOnlineScore = 3000,
		},
	},
}
