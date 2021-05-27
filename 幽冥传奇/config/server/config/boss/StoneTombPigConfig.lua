
--#include "..\..\language\LangCode.txt" once
StoneTombPigConfig =
{
	forExperience	= false,
	sceneId			=	130,
	fubenId			=   31,
	enterTimesLimit =	2,
	enterLevelLimit	=  {0,73},
	enterConsume 	=
	{
	},
	enterPos		=  {15,21},
	buyLimit 		= 10,
	buyHelper =
	{
		{
			consume = { {type = 3, id = 0, count = 200000, quality = 0, strong = 0, }, },
			helperMonId = 309,
			freeNum		= 4,
		},
		{
			consume = { {type = 5, id = 0, count = 1000, quality = 0, strong = 0, }, },
			helperMonId = 310,
			freeNum		= 0,
		},
	},
	autoHelperPos = {{15,23}, {15,25}, {15,27}, {16,29},  {18,30},  {20,29},  {22,27},  {22,25}, {22,23},  {20,21},	},
	freshTimeAfterEnter = 60,
	freshCd  = 1000,
	freshMon =
	{
		{
			311, 311, 311, 311, 311, 311, 311, 311, 311, 311, 311, 311, 311, 311, 311,
			311, 311, 311, 311, 311, 311, 311, 311, 311, 311, 311, 311, 311, 311, 311,
			312, 312, 312, 312, 312, 312, 312, 312, 312, 312,
			312, 312, 312, 312, 312, 312, 312, 312, 312, 312,
			313, 313, 313, 313, 313, 313, 313, 313, 313, 313,
			314, 314, 314, 314, 314, 314, 314, 314, 314, 314, 314, 314, 314, 314, 314,
			314, 314, 314, 314, 314, 314, 314, 314, 314, 314, 314, 314, 314, 314, 314,
			315, 315, 315, 315, 315, 315, 315, 315, 315, 315,
			315, 315, 315, 315, 315, 315, 315, 315, 315, 315,
			316, 316, 316, 316, 316, 316, 316, 316, 316, 316,
			317, 317, 317, 317, 317, 317, 317, 317, 317, 317, 317, 317, 317, 317, 317,
			317, 317, 317, 317, 317, 317, 317, 317, 317, 317, 317, 317, 317, 317, 317,
			318, 318, 318, 318, 318, 318, 318, 318, 318, 318,
			318, 318, 318, 318, 318, 318, 318, 318, 318, 318,
			319, 319, 319, 319, 319, 319, 319, 319, 319, 319,
			320, 320, 320, 320, 320, 320, 320, 320, 320, 320,
		},
		{
		},
	},
	mobMonster =
	{
		[311] = {monsterId = 311, sceneId =	130, num= 1, pos =	{12,17}, livetime = 24, expLibid = 3, expRate = 40, },
		[312] = {monsterId = 312, sceneId =	130, num= 1, pos =	{12,17}, livetime = 24, expLibid = 3, expRate = 60, },
		[313] = {monsterId = 313, sceneId =	130, num= 1, pos =	{12,17}, livetime = 24, expLibid = 3, expRate = 130, },
		[314] = {monsterId = 314, sceneId =	130, num= 1, pos =	{12,17}, livetime = 24, expLibid = 3, expRate = 50, },
		[315] = {monsterId = 315, sceneId =	130, num= 1, pos =	{12,17}, livetime = 24, expLibid = 3, expRate = 75, },
		[316] = {monsterId = 316, sceneId =	130, num= 1, pos =	{12,17}, livetime = 24, expLibid = 3, expRate = 140, },
		[317] = {monsterId = 317, sceneId =	130, num= 1, pos =	{12,17}, livetime = 24, expLibid = 3, expRate = 60, },
		[318] = {monsterId = 318, sceneId =	130, num= 1, pos =	{12,17}, livetime = 24, expLibid = 3, expRate = 80, },
		[319] = {monsterId = 319, sceneId =	130, num= 1, pos =	{12,17}, livetime = 24, expLibid = 3, expRate = 150, },
		[320] = {monsterId = 320, sceneId =	130, num= 1, pos =	{12,17}, livetime = 24, expLibid = 3, expRate = 200, },
	},
	getAward =
	{
		{
			rate 	= 1,
			isLost 	= true,
			consume = {},
		},
		{
			rate 	= 2,
			isLost 	= true,
			consume = { {type = 10, id = 0, count = 1000, quality = 0, strong = 0, }, },
		},
		{
			rate 	= 3,
			isLost 	= true,
			needVip = 1,
			orExpeVip = true,
			consume = { {type = 10, id = 0, count = 3000, quality = 0, strong = 0, }, },
		},
		{
			rate 	= 4,
			isLost 	= true,
			needVip = 2,
			consume = { {type = 10, id = 0, count = 6000, quality = 0, strong = 0, }, },
		},
		{
			rate 	= 5,
			isLost 	= false,
			needVip = 3,
			consume = { {type = 10, id = 0, count = 10000, quality = 0, strong = 0, }, },
		},
		{
			rate = 6,
			isLost 	= false,
			needVip = 4,
			consume = { {type = 10, id = 0, count = 15000, quality = 0, strong = 0, }, },
		},
	},
	miniExpLibRate = 1000,
}
StoneTombPigConfigForExp =
{
	forExperience	= true,
	sceneId			=	130,
	fubenId			=   31,
	enterPos		=  {15,21},
	buyLimit 		= 10,
	buyHelper =
	{
		{
			consume = { {type = 3, id = 0, count = 200000, quality = 0, strong = 0, }, },
			helperMonId = 309,
			freeNum		= 2,
		},
		{
			consume = { {type = 10, id = 0, count = 250, quality = 0, strong = 0, }, },
			helperMonId = 310,
			freeNum		= 8,
		},
	},
	autoHelperPos = {{15,23}, {15,25}, {15,27}, {16,29},  {18,30},  {20,29},  {22,27},  {22,25}, {22,23},  {20,21},	},
	freshTimeAfterEnter = 30,
	freshCd  = 3000,
	freshMon =
	{
		{
			509,510,509,510,509,510,509,510,509,510,509,510,509,510,509,510,509,510,509,510,
		},
		{
		},
	},
	mobMonster =
	{
		[509] = {monsterId = 509, sceneId =	130, num	= 1, pos =	{12,17}, livetime = 24, expLibid = 3, expRate = 50, },
		[510] = {monsterId = 510, sceneId =	130, num	= 1, pos =	{12,17}, livetime = 24, expLibid = 3, expRate = 50, },
	},
	getAward =
	{
		{
			rate 	= 1,
			isLost 	= true,
			consume = {},
		},
		{
			rate 	= 2,
			isLost 	= true,
			consume = { {type = 5, id = 0, count = 1000, quality = 0, strong = 0, }, },
		},
		{
			rate 	= 3,
			isLost 	= true,
			needVip = 1,
			orExpeVip = true,
			consume = { {type = 5, id = 0, count = 3000, quality = 0, strong = 0, }, },
		},
		{
			rate 	= 4,
			isLost 	= true,
			needVip = 2,
			consume = { {type = 5, id = 0, count = 6000, quality = 0, strong = 0, }, },
		},
		{
			rate 	= 5,
			isLost 	= false,
			needVip = 3,
			consume = { {type = 5, id = 0, count = 10000, quality = 0, strong = 0, }, },
		},
		{
			rate = 6,
			isLost 	= false,
			needVip = 4,
			consume = { {type = 5, id = 0, count = 15000, quality = 0, strong = 0, }, },
		},
	},
	quitCountDownTime = 10,
	miniExpLibRate = 1000,
}
