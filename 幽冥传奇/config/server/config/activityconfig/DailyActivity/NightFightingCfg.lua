
NightFightingCfg =
{
	level = {70,0},
	Time = 1800,
	OneTime = 300,
	SpaceTime = 10,
	count = 5,
	FinialRankShowNum = 3,
	GapLevel = 80,
	nKillScore = 50,
	nMinScore = 150,
	nMinAddScore = 50,
	RankCount = 10,
	rankLimit = 150,
	EnterPos =
	{
		{182,29,41,1,1},			{182,25,49,1,1},			{182,40,31,1,1},
		{182,37,30,1,1},			{182,21,36,1,1},			{182,25,32,1,1},
		{182,28,28,1,1},			{182,32,24,1,1},		{182,35,54,1,1},
		{182,38,51,1,1},			{182,41,46,1,1},			{182,44,40,1,1},
	},
	ExitPos = {4,49,71,3,3},
	timeSpace = 18,
	timeCount = 100,
	awardMultiple =
	{
		1800,
	},
	timeAward =
	{
		{
			{type = 11, id = 1, count = 100, quality = 0, strong = 0, bind = 1},
			{type = 32, id = 0, count = 100, quality = 0, strong = 0, bind = 1},
		},
	},
	Awards =
	{
		{
			condition = {1,1},
			award =
			{
				{type = 0, id = 4075, count = 30, bind = 1 , strong = 0 ,quality = 0 ,},
				{type = 11, id = 1, count = 20000, bind = 1 , strong = 0 ,quality = 0 ,},
			},
		},
		{
			condition = {2,5},
			award =
			{
				{type = 0, id = 4075, count = 25, bind = 1 , strong = 0 ,quality = 0 ,},
				{type = 11, id = 1, count = 18000, bind = 1 , strong = 0 ,quality = 0 ,},
			},
		},
		{
			condition = {6,20},
			award =
			{
				{type = 0, id = 4075, count = 21, bind = 1 , strong = 0 ,quality = 0 ,},
				{type = 11, id = 1, count = 15000, bind = 1 , strong = 0 ,quality = 0 ,},
			},
		},
		{
			condition = {21,50},
			award =
			{
				{type = 0, id = 4075, count = 18, bind = 1 , strong = 0 ,quality = 0 ,},
				{type = 11, id = 1, count = 12000, bind = 1 , strong = 0 ,quality = 0 ,},
			},
		},
		{
			condition = {51,200},
			award =
			{
				{type = 0, id = 4075, count = 15, bind = 1 , strong = 0 ,quality = 0 ,},
				{type = 11, id = 1, count = 10000, bind = 1 , strong = 0 ,quality = 0 ,},
			},
		},
	},
}
