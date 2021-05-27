
--#include "..\..\language\LangCode.txt" once
BloodFightCfg =
{
	sceneId				=  120,
	fubenId				=  29,
	enterLevelLimit		=  {4,80},
	enterPos			=  {15,20},
	dailyFailTimesLimit	=  3,
	dailyPassTimesLimit =  30,
	reloginType			= 1,
	boss =
	{
		{ idx=1, bossId=998, pos={18,27}, livetime=0, quality = 1},
		{ idx=2, bossId=999, pos={18,27}, livetime=0, quality = 1},
		{ idx=3, bossId=1000, pos={18,27}, livetime=0, quality = 1},
		{ idx=4, bossId=1001, pos={18,27}, livetime=0, quality = 2},
		{ idx=5, bossId=1002, pos={18,27}, livetime=0, quality = 2},
		{ idx=6, bossId=1003, pos={18,27}, livetime=0, quality = 2},
		{ idx=7, bossId=1004, pos={18,27}, livetime=0, quality = 3},
		{ idx=8, bossId=1005, pos={18,27}, livetime=0, quality = 3},
		{ idx=9, bossId=1147, pos={18,27}, livetime=0, quality = 3},
		{ idx=10, bossId=1148, pos={18,27}, livetime=0, quality = 4},
		{ idx=11, bossId=1149, pos={18,27}, livetime=0, quality = 4},
		{ idx=12, bossId=1150, pos={18,27}, livetime=0, quality = 5},
		{ idx=13, bossId=1151, pos={18,27}, livetime=0, quality = 5},
	},
	freshRoomFee = { type=10, id=0, count=30, },
	inspireNeedPoint = { 1,1,1,1,1,1,1,1,1,1 },
	rooms	=
	{
		{
			passAddStar = 1,
			passAwards =
			{
				{ type = 11, id = 1, count = 500 },
				{ type = 17, id = 0, count = 1000000 },
				{ type = 25, id = 0, count = 4 },
			},
		},
		{
			passAddStar = 2,
			passAwards =
			{
				{ type = 11, id = 1, count = 750 },
				{ type = 17, id = 0, count = 1500000 },
				{ type = 25, id = 0, count = 7 },
			},
		},
		{
			passAddStar = 3,
			passAwards =
			{
				{ type = 11, id = 1, count = 1000 },
				{ type = 17, id = 0, count = 2000000 },
				{ type = 25, id = 0, count = 10 },
			},
		},
	},
	bossForFresh =
	{
--#include "BloodFightBoss\BloodFightBossRoom1.lua"
--#include "BloodFightBoss\BloodFightBossRoom2.lua"
--#include "BloodFightBoss\BloodFightBossRoom3.lua"
	},
	weekRank =
	{
		rankName  	= Lang.Rank.BloodFightWeekRank,
		rankNameHis = Lang.Rank.BloodFightLastWeekRank,
		notClearRank= false,
		rankLimit 	= 1,
		displayCount= 50,
		mailTitle  	= Lang.ScriptTips.BloodFightMailTitle01,
		mailContent	= Lang.ScriptTips.BloodFightMailContent01,
		mailLogId 	= 1295,
		mailLogStr 	= Lang.ScriptTips.BloodFightLog01,
		rankAwards 	=
		{
			{
				cond={1, 1},
				awards =
				{
					{
						openServerDay = {1, 14},
						award =
						{
							{ type = 0, id = 4053, count = 3, bind = 1, },
							{ type = 0, id = 4094, count = 2, bind = 1, },
						},
					},
					{
						openServerDay = {15, 60},
						award =
						{
							{ type = 0, id = 4053, count = 4, bind = 1, },
							{ type = 0, id = 4094, count = 3, bind = 1, },
						},
					},
					{
						openServerDay = {61, 120},
						award =
						{
							{ type = 0, id = 4053, count = 5, bind = 1, },
							{ type = 0, id = 4094, count = 4, bind = 1, },
						},
					},
					{
						openServerDay = {121, 99999},
						award =
						{
							{ type = 0, id = 4053, count = 6, bind = 1, },
							{ type = 0, id = 4094, count = 5, bind = 1, },
						},
					},
				},
			},
			{
				cond={2, 3},
				awards =
				{
					{
						openServerDay = {1, 14},
						award =
						{
							{ type = 0, id = 4052, count = 25, bind = 1, },
						},
					},
					{
						openServerDay = {15, 60},
						award =
						{
							{ type = 0, id = 4052, count = 30, bind = 1, },
						},
					},
					{
						openServerDay = {61, 120},
						award =
						{
							{ type = 0, id = 4052, count = 40, bind = 1, },
						},
					},
					{
						openServerDay = {121, 99999},
						award =
						{
							{ type = 0, id = 4052, count = 50, bind = 1, },
						},
					},
				},
			},
			{
				cond={4, 10},
				awards =
				{
					{
						openServerDay = {1, 14},
						award =
						{
							{ type = 0, id = 4052, count = 20, bind = 1, },
						},
					},
					{
						openServerDay = {15, 60},
						award =
						{
							{ type = 0, id = 4052, count = 25, bind = 1, },
						},
					},
					{
						openServerDay = {61, 120},
						award =
						{
							{ type = 0, id = 4052, count = 30, bind = 1, },
						},
					},
					{
						openServerDay = {121, 99999},
						award =
						{
							{ type = 0, id = 4052, count = 40, bind = 1, },
						},
					},
				},
			},
			{
				cond={11, 20},
				awards =
				{
					{
						openServerDay = {1, 14},
						award =
						{
							{ type = 0, id = 4052, count = 15, bind = 1, },
						},
					},
					{
						openServerDay = {15, 60},
						award =
						{
							{ type = 0, id = 4052, count = 20, bind = 1, },
						},
					},
					{
						openServerDay = {61, 120},
						award =
						{
							{ type = 0, id = 4052, count = 25, bind = 1, },
						},
					},
					{
						openServerDay = {121, 99999},
						award =
						{
							{ type = 0, id = 4052, count = 30, bind = 1, },
						},
					},
				},
			},
			{
				cond={21, 50},
				awards =
				{
					{
						openServerDay = {1, 14},
						award =
						{
							{ type = 0, id = 4052, count = 10, bind = 1, },
						},
					},
					{
						openServerDay = {15, 60},
						award =
						{
							{ type = 0, id = 4052, count = 15, bind = 1, },
						},
					},
					{
						openServerDay = {61, 120},
						award =
						{
							{ type = 0, id = 4052, count = 20, bind = 1, },
						},
					},
					{
						openServerDay = {121, 99999},
						award =
						{
							{ type = 0, id = 4052, count = 25, bind = 1, },
						},
					},
				},
			},
		},
	},
}
