
--#include "..\..\language\LangCode.txt" once
CantTelToTeamFubenFromScenes =
{
	61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72,
}
TeamFubenConfig =
{
	{
		idx 		= 1,
		sceneId 	= 75,
		fubenId		= 3,
		fubenName 	= Lang.ScriptTips.TeamFubenName01,
		monsters 	=
		{
			{ monsterId=1180, sceneId=75, num=5, range={19,54,31,80}, livetime=600, isBoss=false },
			{ monsterId=1181, sceneId=75, num=5, range={19,54,31,80}, livetime=600, isBoss=false },
			{ monsterId=1182, sceneId=75, num=5, range={46,85,54,103}, livetime=600, isBoss=false },
			{ monsterId=1183, sceneId=75, num=5, range={46,85,54,103}, livetime=600, isBoss=false },
			{ monsterId=1169, sceneId=75, num=1, pos={23,64}, livetime=600, isBoss=true, },
			{ monsterId=1170, sceneId=75, num=1, pos={50,94}, livetime=600, isBoss=true, },
		},
		killBuff =
		{
		},
		createCD 		= 60,
		playerCountMax  = 5,
		dailyTimesMax	= 10,
		levelLimit		= {0,70},
		needPower		= 1500,
		enterPos		= {50,35},
		star  			= {600, 360, 180,},
		starAwards 		=
		{
			{
				{
					openServerDay = {1, 9999},
					awards =
					{
						{ libIdx=2, num=1, },
						{ libIdx=3, num=1, },
						{ libIdx=4, num=1, },
					},
				},
			},
			{
				{
					openServerDay = {1, 9999},
					awards =
					{
						{ libIdx=5, num=1, },
						{ libIdx=6, num=1, },
						{ libIdx=7, num=1, },
					},
				},
			},
			{
				{
					openServerDay = {1, 9999},
					awards =
					{
						{ libIdx=8, num=1, },
						{ libIdx=9, num=1, },
						{ libIdx=10, num=1, },
					},
				},
			},
		},
		showAwards =
		{   { type = 1, id = 0, count = 1, bind = 0, },
			{ type = 17, id = 0, count = 1, bind = 0, },
			{ type = 0, id = 179, count = 1, bind = 0, },
			{ type = 0, id = 189, count = 1, bind = 0, },
			{ type = 0, id = 189, count = 1, bind = 0, },
		},
	},
	{
		idx 		= 2,
		sceneId 	= 76,
		fubenId		= 4,
		fubenName 	= Lang.ScriptTips.TeamFubenName02,
		monsters 	=
		{
			{ monsterId=1184, sceneId=76, num=10, range={49,37,51,53}, livetime=600, isBoss=false, },
			{ monsterId=1185, sceneId=76, num=10, range={18,38,25,64}, livetime=600, isBoss=false, },
			{ monsterId=1186, sceneId=76, num=10, range={40,80,49,104}, livetime=600, isBoss=false, },
			{ monsterId=1171, sceneId=76, num=1, pos={49,45}, livetime=600, isBoss=true, },
			{ monsterId=1172, sceneId=76, num=1, pos={23,52}, livetime=600, isBoss=true, },
			{ monsterId=1173, sceneId=76, num=1, pos={45,93}, livetime=600, isBoss=true, },
		},
		killBuff =
		{
		},
		createCD = 60,
		playerCountMax  = 5,
		dailyTimesMax	= 10,
		levelLimit		= {0,100},
		needPower		= 6000,
		enterPos		= {51,42},
		star  = {600, 360, 180,},
		starAwards 		=
		{
			{
				{
					openServerDay = {1, 9999},
					awards =
					{
						{ libIdx=11, num=1, },
						{ libIdx=12, num=1, },
						{ libIdx=13, num=1, },
					},
				},
			},
			{
				{
					openServerDay = {1, 9999},
					awards =
					{
						{ libIdx=14, num=1, },
						{ libIdx=15, num=1, },
						{ libIdx=16, num=1, },
					},
				},
			},
			{
				{
					openServerDay = {1, 9999},
					awards =
					{
						{ libIdx=17, num=1, },
						{ libIdx=18, num=1, },
						{ libIdx=19, num=1, },
					},
				},
			},
		},
		showAwards =
		{
			{ type = 1, id = 0, count = 1, bind = 0, },
			{ type = 17, id = 0, count = 1, bind = 0, },
			{ type = 0, id = 359, count = 1, bind = 0, },
			{ type = 0, id = 369, count = 1, bind = 0, },
			{ type = 0, id = 379, count = 1, bind = 0, },
		},
	},
	{
		idx 		= 3,
		sceneId 	= 77,
		fubenId		= 5,
		fubenName 	= Lang.ScriptTips.TeamFubenName03,
		monsters =
		{
			{ monsterId=1187, sceneId=77, num=10, range={11,46,22,71},  livetime=600, isBoss=false, },
			{ monsterId=1188, sceneId=77, num=10, range={28,85,41,104},  livetime=600, isBoss=false, },
			{ monsterId=1189, sceneId=77, num=10, range={46,53,58,74},  livetime=600, isBoss=false, },
			{ monsterId=1174, sceneId=77, num=1, pos={16,61}, livetime=600, isBoss=true, },
			{ monsterId=1175, sceneId=77, num=1, pos={34,95}, livetime=600, isBoss=true, },
			{ monsterId=1176, sceneId=77, num=1, pos={53,63}, livetime=600, isBoss=true, },
		},
		killBuff =
		{
		},
		createCD = 60,
		playerCountMax  = 5,
		dailyTimesMax	= 10,
		levelLimit		= {0,130},
		needPower		= 15000,
		enterPos		= {34,29},
		star  = {600, 360, 180,},
		starAwards 		=
		{
			{
				{
					openServerDay = {1, 9999},
					awards =
					{
						{ libIdx=20, num=1, },
						{ libIdx=21, num=1, },
						{ libIdx=22, num=1, },
					},
				},
			},
			{
				{
					openServerDay = {1, 9999},
					awards =
					{
						{ libIdx=23, num=1, },
						{ libIdx=24, num=1, },
						{ libIdx=25, num=1, },
					},
				},
			},
			{
				{
					openServerDay = {1, 9999},
					awards =
					{
						{ libIdx=26, num=1, },
						{ libIdx=27, num=1, },
						{ libIdx=28, num=1, },
					},
				},
			},
		},
		showAwards =
		{
			{ type = 1, id = 0, count = 1, bind = 0, },
			{ type = 17, id = 0, count = 1, bind = 0, },
			{ type = 0, id = 539, count = 1, bind = 0, },
			{ type = 0, id = 549, count = 1, bind = 0, },
			{ type = 0, id = 559, count = 1, bind = 0, },
		},
	},
	{
		idx 		= 4,
		sceneId 	= 78,
		fubenId		= 6,
		fubenName 	= Lang.ScriptTips.TeamFubenName04,
		monsters =
		{
			{ monsterId=1190, sceneId=78, num=10, range={10,65,17,76},  livetime=600, isBoss=false, },
			{ monsterId=1191, sceneId=78, num=10, range={29,84,38,99},  livetime=600, isBoss=false, },
			{ monsterId=1192, sceneId=78, num=10, range={51,62,61,76},  livetime=600, isBoss=false, },
			{ monsterId=1177, sceneId=78, num=1, pos={15,71}, livetime=600, isBoss=true, },
			{ monsterId=1178, sceneId=78, num=1, pos={34,91}, livetime=600, isBoss=true, },
			{ monsterId=1179, sceneId=78, num=1, pos={56,69}, livetime=600, isBoss=true, },
		},
		killBuff =
		{
		},
		createCD = 60,
		playerCountMax  = 5,
		dailyTimesMax	= 10,
		levelLimit		= {0,160},
		needPower		= 30000,
		enterPos		= {32,43},
		star  = {600, 360, 180,},
		starAwards 		=
		{
			{
				{
					openServerDay = {1, 9999},
					awards =
					{
						{ libIdx=29, num=1, },
						{ libIdx=30, num=1, },
						{ libIdx=31, num=1, },
					},
				},
			},
			{
				{
					openServerDay = {1, 9999},
					awards =
					{
						{ libIdx=32, num=1, },
						{ libIdx=33, num=1, },
						{ libIdx=34, num=1, },
					},
				},
			},
			{
				{
					openServerDay = {1, 9999},
					awards =
					{
						{ libIdx=35, num=1, },
						{ libIdx=36, num=1, },
						{ libIdx=37, num=1, },
					},
				},
			},
		},
		showAwards =
		{
			{ type = 1, id = 0, count = 1, bind = 0, },
			{ type = 17, id = 0, count = 1, bind = 0, },
			{ type = 0, id = 719, count = 1, bind = 0, },
			{ type = 0, id = 729, count = 1, bind = 0, },
			{ type = 0, id = 739, count = 1, bind = 0, },
		},
	},
}
