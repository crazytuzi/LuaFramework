--#include "..\..\language\LangCode.txt"
MaterialFubenCfg =
{
	{
		fubenName 		= Lang.ScriptTips.MaterialFBName004,
		fubenTime		= 600,
		fubenIdx		= 1,
		fubenId 		= 24,
		sceneId 		= 115,
		enterPos 		= {18,26},
		dailyEnterTimes = 2,
		levelLimit		= {0, 55},
		monsters =
		{
            { monsterId=331, sceneId=115, num=1, pos={18,27,24,35}, livetime=600,},
			{ monsterId=336, sceneId=115, num=5, pos={18,27,24,35}, livetime=600,},
		},
		enterConsume =
		{
			{
				{type = 0, id = 4261, count = 10, quality = 0, strong = 0, },
			},
			{
				{type = 0, id = 4261, count = 10, quality = 0, strong = 0, },
			},
		},
		getAwardConsume =
		{
			{
			},
			{
				{type = 10, id = 0, count = 15, quality = 0, strong = 0, },
			},
		},
		doubleAwardButtonParam = 14,
		fubenAwards =
		{
			{
				{
					cond = {0, 4},
					awards =
					{
						{type = 1, id = 0, count = 1000000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4447, count = 3,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {5, 10},
					awards =
					{
						{type = 1, id = 0, count = 1100000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4447, count = 4,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {11, 20},
					awards =
					{
						{type = 1, id = 0, count = 1300000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4447, count = 5,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {21, 35},
					awards =
					{
						{type = 1, id = 0, count = 1500000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4447, count = 6,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {36, 55},
					awards =
					{
						{type = 1, id = 0, count = 1750000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4447, count = 7,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {56, 80},
					awards =
					{
						{type = 1, id = 0, count = 2000000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4447, count = 8,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {81, 110},
					awards =
					{
						{type = 1, id = 0, count = 2250000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4447, count = 9,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {111, 36500},
					awards =
					{
						{type = 1, id = 0, count = 2500000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4447, count = 10,  quality = 0, strong = 0, bind = 1 },
					},
				},
			},
			{
				{
					cond = {0, 4},
					awards =
					{
						{type = 1, id = 0, count = 2000000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4447, count = 6,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {5, 10},
					awards =
					{
						{type = 1, id = 0, count = 2200000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4447, count = 8,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {11, 20},
					awards =
					{
						{type = 1, id = 0, count = 2600000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4447, count = 10,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {21, 35},
					awards =
					{
						{type = 1, id = 0, count = 3000000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4447, count = 12,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {36, 55},
					awards =
					{
						{type = 1, id = 0, count = 3500000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4447, count = 14,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {56, 80},
					awards =
					{
						{type = 1, id = 0, count = 4000000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4447, count = 16,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {81, 110},
					awards =
					{
						{type = 1, id = 0, count = 4500000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4447, count = 18,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {111, 36500},
					awards =
					{
						{type = 1, id = 0, count = 5000000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4447, count = 20,  quality = 0, strong = 0, bind = 1 },
					},
				},
			},
		},
		sweepConsume =
		{
			{
				{
					{type = 22, id = 0, count = 5, quality = 0, strong = 0, bind = 1 },
				},
				{
					{type = 22, id = 0, count = 5, quality = 0, strong = 0, bind = 1 },
					{type = 10, id = 0, count = 188, quality = 0, strong = 0, bind = 1 },
				},
				{
					{type = 22, id = 0, count = 5, quality = 0, strong = 0, bind = 1 },
					{type = 10, id = 0, count = 488, quality = 0, strong = 0, bind = 1 },
				},
			},
			{
				{
					{type = 22, id = 0, count = 10, quality = 0, strong = 0, bind = 1 },
				},
				{
					{type = 22, id = 0, count = 10, quality = 0, strong = 0, bind = 1 },
					{type = 10, id = 0, count = 188, quality = 0, strong = 0, bind = 1 },
				},
				{
					{type = 22, id = 0, count = 10, quality = 0, strong = 0, bind = 1 },
					{type = 10, id = 0, count = 488, quality = 0, strong = 0, bind = 1 },
				},
			},
		},
	},
	{
		fubenName 		= Lang.ScriptTips.MaterialFBName005,
		fubenTime		= 600,
		fubenIdx		= 2,
		fubenId 		= 23,
		sceneId 		= 114,
		enterPos 		= {18,26},
		dailyEnterTimes = 2,
		levelLimit		= {0, 62},
		monsters =
		{
            { monsterId=332, sceneId=114, num=1, pos={18,27,24,35}, livetime=600,},
			{ monsterId=337, sceneId=114, num=5, pos={18,27,24,35}, livetime=600,},
		},
		enterConsume =
		{
			{
				{type = 0, id = 4261, count = 10, quality = 0, strong = 0, },
			},
			{
				{type = 0, id = 4261, count = 10, quality = 0, strong = 0, },
			},
		},
		getAwardConsume =
		{
			{
			},
			{
				{type = 10, id = 0, count = 15, quality = 0, strong = 0, },
			},
		},
		doubleAwardButtonParam = 15,
		fubenAwards =
		{
			{
				{
					cond = {0, 3},
					awards =
					{
						{type = 1, id = 0, count = 1000000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4013, count = 3,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {4, 15},
					awards =
					{
						{type = 1, id = 0, count = 1100000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4013, count = 4,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {16, 30},
					awards =
					{
						{type = 1, id = 0, count = 1300000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4013, count = 5,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {31, 60},
					awards =
					{
						{type = 1, id = 0, count = 1500000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4013, count = 6,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {61, 90},
					awards =
					{
						{type = 1, id = 0, count = 1750000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4013, count = 7,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {91, 120},
					awards =
					{
						{type = 1, id = 0, count = 2000000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4013, count = 8,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {121, 150},
					awards =
					{
						{type = 1, id = 0, count = 2250000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4013, count = 9,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {151, 36500},
					awards =
					{
						{type = 1, id = 0, count = 2500000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4013, count = 10,  quality = 0, strong = 0, bind = 1 },
					},
				},
			},
			{
				{
					cond = {0, 3},
					awards =
					{
						{type = 1, id = 0, count = 2000000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4013, count = 6,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {4, 15},
					awards =
					{
						{type = 1, id = 0, count = 2200000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4013, count = 8,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {16, 30},
					awards =
					{
						{type = 1, id = 0, count = 2600000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4013, count = 10,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {31, 60},
					awards =
					{
						{type = 1, id = 0, count = 3000000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4013, count = 12,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {61, 90},
					awards =
					{
						{type = 1, id = 0, count = 3500000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4013, count = 14,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {91, 120},
					awards =
					{
						{type = 1, id = 0, count = 4000000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4013, count = 16,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {121, 150},
					awards =
					{
						{type = 1, id = 0, count = 4500000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4013, count = 18,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {151, 36500},
					awards =
					{
						{type = 1, id = 0, count = 5000000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4013, count = 20,  quality = 0, strong = 0, bind = 1 },
					},
				},
			},
		},
		sweepConsume =
		{
			{
				{
					{type = 22, id = 0, count = 5, quality = 0, strong = 0, bind = 1 },
				},
				{
					{type = 22, id = 0, count = 5, quality = 0, strong = 0, bind = 1 },
					{type = 10, id = 0, count = 188, quality = 0, strong = 0, bind = 1 },
				},
				{
					{type = 22, id = 0, count = 5, quality = 0, strong = 0, bind = 1 },
					{type = 10, id = 0, count = 488, quality = 0, strong = 0, bind = 1 },
				},
			},
			{
				{
					{type = 22, id = 0, count = 10, quality = 0, strong = 0, bind = 1 },
				},
				{
					{type = 22, id = 0, count = 10, quality = 0, strong = 0, bind = 1 },
					{type = 10, id = 0, count = 188, quality = 0, strong = 0, bind = 1 },
				},
				{
					{type = 22, id = 0, count = 10, quality = 0, strong = 0, bind = 1 },
					{type = 10, id = 0, count = 488, quality = 0, strong = 0, bind = 1 },
				},
			},
		},
	},
	{
		fubenName 		= Lang.ScriptTips.MaterialFBName001,
		fubenTime		= 600,
		fubenIdx		= 3,
		fubenId 		= 22,
		sceneId 		= 113,
		enterPos 		= {18,26},
		dailyEnterTimes = 2,
		levelLimit		= {0, 65},
		monsters =
		{
            { monsterId=328, sceneId=113, num=1, pos={18,27,24,35}, livetime=600,},
			{ monsterId=333, sceneId=113, num=5, pos={18,27,24,35}, livetime=600,},
		},
		enterConsume =
		{
			{
				{type = 0, id = 4261, count = 10, quality = 0, strong = 0, },
			},
			{
				{type = 0, id = 4261, count = 10, quality = 0, strong = 0, },
			},
		},
		getAwardConsume =
		{
			{
			},
			{
				{type = 10, id = 0, count = 15, quality = 0, strong = 0, },
			},
		},
		doubleAwardButtonParam = 11,
		fubenAwards =
		{
			{
				{
					cond = {0, 3},
					awards =
					{
						{type = 1, id = 0, count = 1000000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4091, count = 3,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {4, 15},
					awards =
					{
						{type = 1, id = 0, count = 1100000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4091, count = 4,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {16, 30},
					awards =
					{
						{type = 1, id = 0, count = 1300000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4091, count = 5,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {31, 60},
					awards =
					{
						{type = 1, id = 0, count = 1500000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4091, count = 6,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {61, 90},
					awards =
					{
						{type = 1, id = 0, count = 1750000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4091, count = 7,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {91, 120},
					awards =
					{
						{type = 1, id = 0, count = 2000000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4091, count = 8,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {121, 150},
					awards =
					{
						{type = 1, id = 0, count = 2250000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4091, count = 9,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {151, 36500},
					awards =
					{
						{type = 1, id = 0, count = 2500000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4091, count = 10,  quality = 0, strong = 0, bind = 1 },
					},
				},
			},
			{
				{
					cond = {0, 3},
					awards =
					{
						{type = 1, id = 0, count = 2000000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4091, count = 6,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {4, 15},
					awards =
					{
						{type = 1, id = 0, count = 2200000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4091, count = 8,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {16, 30},
					awards =
					{
						{type = 1, id = 0, count = 2600000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4091, count = 10,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {31, 60},
					awards =
					{
						{type = 1, id = 0, count = 3000000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4091, count = 12,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {61, 90},
					awards =
					{
						{type = 1, id = 0, count = 3500000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4091, count = 14,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {91, 120},
					awards =
					{
						{type = 1, id = 0, count = 4000000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4091, count = 16,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {121, 150},
					awards =
					{
						{type = 1, id = 0, count = 4500000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4091, count = 18,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {151, 36500},
					awards =
					{
						{type = 1, id = 0, count = 5000000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4091, count = 20,  quality = 0, strong = 0, bind = 1 },
					},
				},
			},
		},
		sweepConsume =
		{
			{
				{
					{type = 22, id = 0, count = 5, quality = 0, strong = 0, bind = 1  },
				},
				{
					{type = 22, id = 0, count = 5, quality = 0, strong = 0, bind = 1  },
					{type = 10, id = 0, count = 188, quality = 0, strong = 0, bind = 1  },
				},
				{
					{type = 22, id = 0, count = 5, quality = 0, strong = 0, bind = 1  },
					{type = 10, id = 0, count = 488, quality = 0, strong = 0, bind = 1  },
				},
			},
			{
				{
					{type = 22, id = 0, count = 10, quality = 0, strong = 0, bind = 1  },
				},
				{
					{type = 22, id = 0, count = 10, quality = 0, strong = 0, bind = 1  },
					{type = 10, id = 0, count = 188, quality = 0, strong = 0, bind = 1  },
				},
				{
					{type = 22, id = 0, count = 10, quality = 0, strong = 0, bind = 1  },
					{type = 10, id = 0, count = 488, quality = 0, strong = 0, bind = 1  },
				},
			},
		},
	},
	{
		fubenName 		= Lang.ScriptTips.MaterialFBName002,
		fubenTime		= 600,
		fubenIdx		= 4,
		fubenId 		= 26,
		sceneId 		= 117,
		enterPos 		= {18,26},
		dailyEnterTimes = 2,
		levelLimit		= {0, 75},
		monsters =
		{
            { monsterId=329, sceneId=117, num=1, pos={18,27,24,35}, livetime=600,},
			{ monsterId=334, sceneId=117, num=5, pos={18,27,24,35}, livetime=600,},
		},
		enterConsume =
		{
			{
				{type = 0, id = 4261, count = 10, quality = 0, strong = 0, },
			},
			{
				{type = 0, id = 4261, count = 10, quality = 0, strong = 0, },
			},
		},
		getAwardConsume =
		{
			{
			},
			{
				{type = 10, id = 0, count = 15, quality = 0, strong = 0, },
			},
		},
		doubleAwardButtonParam = 14,
		fubenAwards =
		{
			{
				{
					cond = {0, 4},
					awards =
					{
						{type = 1, id = 0, count = 1000000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4074, count = 3,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {5, 10},
					awards =
					{
						{type = 1, id = 0, count = 1100000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4074, count = 4,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {11, 20},
					awards =
					{
						{type = 1, id = 0, count = 1300000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4074, count = 5,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {21, 35},
					awards =
					{
						{type = 1, id = 0, count = 1500000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4074, count = 6,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {36, 55},
					awards =
					{
						{type = 1, id = 0, count = 1750000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4074, count = 7,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {56, 80},
					awards =
					{
						{type = 1, id = 0, count = 2000000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4074, count = 8,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {81, 110},
					awards =
					{
						{type = 1, id = 0, count = 2250000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4074, count = 9,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {111, 36500},
					awards =
					{
						{type = 1, id = 0, count = 2500000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4074, count = 10,  quality = 0, strong = 0, bind = 1 },
					},
				},
			},
			{
				{
					cond = {0, 4},
					awards =
					{
						{type = 1, id = 0, count = 2000000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4074, count = 6,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {5, 10},
					awards =
					{
						{type = 1, id = 0, count = 2200000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4074, count = 8,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {11, 20},
					awards =
					{
						{type = 1, id = 0, count = 2600000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4074, count = 10,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {21, 35},
					awards =
					{
						{type = 1, id = 0, count = 3000000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4074, count = 12,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {36, 55},
					awards =
					{
						{type = 1, id = 0, count = 3500000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4074, count = 14,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {56, 80},
					awards =
					{
						{type = 1, id = 0, count = 4000000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4074, count = 16,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {81, 110},
					awards =
					{
						{type = 1, id = 0, count = 4500000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4074, count = 18,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {111, 36500},
					awards =
					{
						{type = 1, id = 0, count = 5000000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4074, count = 20,  quality = 0, strong = 0, bind = 1 },
					},
				},
			},
		},
		sweepConsume =
		{
			{
				{
					{type = 22, id = 0, count = 5, quality = 0, strong = 0, bind = 1 },
				},
				{
					{type = 22, id = 0, count = 5, quality = 0, strong = 0, bind = 1 },
					{type = 10, id = 0, count = 188, quality = 0, strong = 0, bind = 1 },
				},
				{
					{type = 22, id = 0, count = 5, quality = 0, strong = 0, bind = 1 },
					{type = 10, id = 0, count = 488, quality = 0, strong = 0, bind = 1 },
				},
			},
			{
				{
					{type = 22, id = 0, count = 10, quality = 0, strong = 0, bind = 1 },
				},
				{
					{type = 22, id = 0, count = 10, quality = 0, strong = 0, bind = 1 },
					{type = 10, id = 0, count = 188, quality = 0, strong = 0, bind = 1 },
				},
				{
					{type = 22, id = 0, count = 10, quality = 0, strong = 0, bind = 1 },
					{type = 10, id = 0, count = 488, quality = 0, strong = 0, bind = 1 },
				},
			},
		},
	},
	{
		fubenName 		= Lang.ScriptTips.MaterialFBName003,
		fubenTime		= 600,
		fubenIdx		= 5,
		fubenId 		= 25,
		sceneId 		= 116,
		enterPos 		= {18,26},
		dailyEnterTimes = 2,
		levelLimit		= {0, 75},
		monsters =
		{
            { monsterId=330, sceneId=116, num=1, pos={18,27,24,35}, livetime=600,},
			{ monsterId=335, sceneId=116, num=5, pos={18,27,24,35}, livetime=600,},
		},
		enterConsume =
		{
			{
				{type = 0, id = 4261, count = 10, quality = 0, strong = 0, },
			},
			{
				{type = 0, id = 4261, count = 10, quality = 0, strong = 0, },
			},
		},
		getAwardConsume =
		{
			{
			},
			{
				{type = 10, id = 0, count = 15, quality = 0, strong = 0, },
			},
		},
		doubleAwardButtonParam = 14,
		fubenAwards =
		{
			{
				{
					cond = {0, 4},
					awards =
					{
						{type = 1, id = 0, count = 1000000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4075, count = 3,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {5, 10},
					awards =
					{
						{type = 1, id = 0, count = 1100000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4075, count = 4,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {11, 20},
					awards =
					{
						{type = 1, id = 0, count = 1300000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4075, count = 5,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {21, 35},
					awards =
					{
						{type = 1, id = 0, count = 1500000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4075, count = 6,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {36, 55},
					awards =
					{
						{type = 1, id = 0, count = 1750000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4075, count = 7,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {56, 80},
					awards =
					{
						{type = 1, id = 0, count = 2000000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4075, count = 8,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {81, 110},
					awards =
					{
						{type = 1, id = 0, count = 2250000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4075, count = 9,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {111, 36500},
					awards =
					{
						{type = 1, id = 0, count = 2500000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4075, count = 10,  quality = 0, strong = 0, bind = 1 },
					},
				},
			},
			{
				{
					cond = {0, 4},
					awards =
					{
						{type = 1, id = 0, count = 2000000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4075, count = 6,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {5, 10},
					awards =
					{
						{type = 1, id = 0, count = 2200000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4075, count = 8,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {11, 20},
					awards =
					{
						{type = 1, id = 0, count = 2600000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4075, count = 10,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {21, 35},
					awards =
					{
						{type = 1, id = 0, count = 3000000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4075, count = 12,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {36, 55},
					awards =
					{
						{type = 1, id = 0, count = 3500000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4075, count = 14,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {56, 80},
					awards =
					{
						{type = 1, id = 0, count = 4000000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4075, count = 16,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {81, 110},
					awards =
					{
						{type = 1, id = 0, count = 4500000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4075, count = 18,  quality = 0, strong = 0, bind = 1 },
					},
				},
				{
					cond = {111, 36500},
					awards =
					{
						{type = 1, id = 0, count = 5000000, quality = 0, strong = 0, bind = 1 },
						{type = 0, id = 4075, count = 20,  quality = 0, strong = 0, bind = 1 },
					},
				},
			},
		},
		sweepConsume =
		{
			{
				{
					{type = 22, id = 0, count = 5, quality = 0, strong = 0, bind = 1 },
				},
				{
					{type = 22, id = 0, count = 5, quality = 0, strong = 0, bind = 1 },
					{type = 10, id = 0, count = 188, quality = 0, strong = 0, bind = 1 },
				},
				{
					{type = 22, id = 0, count = 5, quality = 0, strong = 0, bind = 1 },
					{type = 10, id = 0, count = 488, quality = 0, strong = 0, bind = 1 },
				},
			},
			{
				{
					{type = 22, id = 0, count = 10, quality = 0, strong = 0, bind = 1 },
				},
				{
					{type = 22, id = 0, count = 10, quality = 0, strong = 0, bind = 1 },
					{type = 10, id = 0, count = 188, quality = 0, strong = 0, bind = 1 },
				},
				{
					{type = 22, id = 0, count = 10, quality = 0, strong = 0, bind = 1 },
					{type = 10, id = 0, count = 488, quality = 0, strong = 0, bind = 1 },
				},
			},
		},
	},
}
