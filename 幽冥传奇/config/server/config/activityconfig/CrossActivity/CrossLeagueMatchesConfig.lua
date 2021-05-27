--#include "..\..\..\language\LangCode.txt"
CrossLeagueMatchesCfg =
{
	resetHighCount = {2, 1},
	resetLowCount = {2, 2},
	SignFailWhenEnterScenes = {142,},
	deadOutCount = 10,
	MinRankScore = 100,
	RankNum = 100,
	ChoiceRankRange = {6,12,18,24,30,42,54,66,78,90,102,126,150,10000},
	activeTime 	= {{{20,30},{21,50}},{{21,50},{22,30}}},
	fubenId 	= 75,
	sceneId 	= 198,
	enterPos 	= { {14, 33}, {20, 33} },
	levelLimit  = {2,80},
	reliveTime	= 5,
	relivePos	= { {17, 40}, {17, 27},	{14, 30}, {20, 37}, {19, 30}, {15, 37} },
	AddScore =
	{
		{
			winScore 	= 100,
			winAward = {{type = 0, id = 4495, count = 1, bind = 1 , strong = 0 ,quality = 0 ,},},
			loseScore 	= 30,
			loseAward = {{type = 0, id = 4494, count = 2, bind = 1 , strong = 0 ,quality = 0 ,},},
			drawScore 	= 50,
			drawAward = {{type = 0, id = 4494, count = 5, bind = 1 , strong = 0 ,quality = 0 ,},},
			passScore   = 50,
			passAward = {{type = 0, id = 4494, count = 5, bind = 1 , strong = 0 ,quality = 0 ,},},
		},
		{
			winScore 	= 10,
			winAward = {{type = 0, id = 4494, count = 3, bind = 1 , strong = 0 ,quality = 0 ,},},
			loseScore 	= 0,
			drawScore 	= 3,
			drawAward = {{type = 0, id = 4494, count = 1, bind = 1 , strong = 0 ,quality = 0 ,},},
			passScore   = 5,
			passAward = {{type = 0, id = 4494, count = 1, bind = 1 , strong = 0 ,quality = 0 ,},},
		},
	},
	rankAwards =
	{
		{
			cond={1, 1},
			awards =
			{
		   		{ type = 0, id = 4613, count = 1, bind = 1, },
			},
		},
		{
			cond={2, 5},
			awards =
			{
				{ type = 0, id = 4614, count = 1, bind = 1, },
			},
		},
		{
			cond={6, 20},
			awards =
			{
				{ type = 0, id = 4615, count = 1, bind = 1, },
			},
		},
		{
			cond={21, 50},
			awards =
			{
				{ type = 0, id = 4616, count = 1, bind = 1, },
			},
		},
		{
			cond={51, 100},
			awards =
			{
				{ type = 0, id = 4617, count = 1, bind = 1, },
			},
		},
	},
}
