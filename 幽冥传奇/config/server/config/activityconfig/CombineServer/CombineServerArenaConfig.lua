--#include "..\..\..\language\LangCode.txt"
CombineServerArenaCfg =
{
	arena =
	{
		fubenId	= 72,
		sceneId	= 190,
		enterPos	= { {11, 16}, {17, 25} },
		levelLimit  = {2,80},
		reliveTime	= 10,
		relivePos	= { {8, 18}, {11, 23},	{17, 17}, {18, 23}, {18, 15}, {22, 19} },
		playerNum	= 6,
		extraArenaNum=2,
		combineServerDay = {1,3},
		activeTime	= { {{16,0},{17,0}},{{20,0},{22,0}}},
		score =
		{
			killScoreToActor	= 1,
			killScoreToCamp		= 1,
			winScore	= 50,
			loseScore	= 0,
		},
		winAwards =
		{
			{ type=3, id=0, count=3000000, bind=1, },
			{ type=1, id=0, count=15000000, bind=1, },
		},
		loseAwards =
		{
			{ type=3, id=0, count=1000000, bind=1, },
			{ type=1, id=0, count=10000000, bind=1, },
		},
	scoreRank =
		{
			rankName 	= Lang.Rank.CombineArenaScoreRank,
			rankLimit	= 1,
			displayCount = 10,
			notClearRank = true,
			mailTitle 	= Lang.ScriptTips.CombineAreanMailTitle3,
			mailContent	= Lang.ScriptTips.CombineAreanMailCont3,
			mailLogId	= 146,
			mailLogStr	= Lang.ScriptTips.CombineServerAreanLog02,
			rankAwards =
			{
				{
					cond={1, 10},
					awards =
					{
						{
							openServerDay = {1, 9999},
							award =
							{
								{ type = 0, id = 4065, count = 1, bind = 1, },
								{ type = 0, id = 4053, count = 2, bind = 1, },
							},
						},
					},
				},
				{
					cond={10, 200},
					awards =
					{
						{
							openServerDay = {1, 9999},
							award =
							{
								{ type = 0, id = 4064, count = 2, bind = 1, },
								{ type = 0, id = 4052, count = 5, bind = 1, },
							},
						},
					},
				},
			},
		},
	},
	fight =
	{
		fubenId	= 73,
		sceneId	= 191,
		rankIdxLimit= 10,
		levelLimit  = {2,80},
		enterPosRand = { {14, 32}, {36, 46} },
		relivePos	 = { {20, 24}, {29, 27},	{21, 40}, {30, 37}, {27, 42}, {28, 50} },
		killAddScore = 20,
		combineServerDay = {1,3},
		activeTime	= { {{16,0},{16,45}},},
	scoreRank =
		{
			rankName 	= Lang.Rank.CombineBigFightScoreRank,
			displayLimit= 0,
			rankLimit	= 1,
			displayCount = 10,
			notClearRank = true,
			mailTitle 	= Lang.ScriptTips.CombineAreanMailTitle4,
			mailContent	= Lang.ScriptTips.CombineAreanMailCont4,
			mailLogId	= 146,
			mailLogStr	= Lang.ScriptTips.CombineServerAreanLog02,
			rankAwards =
			{
				{
					cond={1, 1},
					awards =
					{
						{
							openServerDay = {1, 9999},
							award =
							{
								{ type = 0, id = 4500, count = 1, bind = 1, },
								{ type = 0, id = 4094, count = 5, bind = 1, },
								{ type = 0, id = 4060, count = 1, bind = 1, },
							},
						},
					},
				},
				{
					cond={2, 10},
					awards =
					{
						{
							openServerDay = {1, 9999},
							award =
							{
								{ type = 0, id = 4094, count = 2, bind = 1, },
								{ type = 0, id = 4059, count = 2, bind = 1, },
								{ type = 0, id = 4019, count = 100, bind = 1, },
							},
						},
					},
				},
			},
		},
	},
}
