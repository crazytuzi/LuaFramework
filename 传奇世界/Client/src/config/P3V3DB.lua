--P3V3DB.lua

local Item = {
	mapId = 6018,
	posLiveA = {x = 3, y = 53},		--复活点
	posLiveB = {x = 59, y = 9},		--复活点
	posTowerA = {x = 22, y = 38},	--塔点
	posTowerB = {x = 40, y = 24},	--塔点
	posCampA = {x = 7, y = 48},		--大营点
	posCampB = {x = 55, y = 12},	--大营点

	matchTime = 120,				--每次匹配时间
	battleTime = 300,				--战斗时间
	memberCnt = 3,					--成员个数
	matchCnt = 3,					--每天的次数

	campIdA = 653,					--大营ID
	campIdB = 654,					--大营ID
	towerIdA = 652,					--塔ID
	towerIdB = 655,					--塔ID
	rewardWinner = 2308,			--胜者奖励
	rewardLoser = 2309,				--败者奖励
	rewardNowin = 2309,				--平局奖励	

	posFlag = {						--符文刷新点
		[1] = {x = 32, y = 32},
		[2] = {x = 29, y = 38},	
		[3] = {x = 24, y = 34},	
		[4] = {x = 38, y = 30},
		[5] = {x = 34, y = 26},
		[6] = {x = 36, y = 36},
		[7] = {x = 27, y = 28},

	
		
		},
		rankReward =					--累胜奖励
		{
			[3] = 2298,
			[9] = 2299,
			[15] = 2300,
			[21] = 2301,
			[27] = 2302,
			[33] = 2303,
			[39] = 2304,
			[45] = 2305,
			[51] = 2306,
			[60] = 2307,
		},
		flagRefesh =					--符文刷新时间
		{
                        [25] = 0,
			[30] = 1,
			[60] = 2,
			[120] = 2,
			[180] = 2,
			[240] = 2,

	},
	reliveTime =					--复活时间
	{
			20, 25, 30
	},
}

return Item

