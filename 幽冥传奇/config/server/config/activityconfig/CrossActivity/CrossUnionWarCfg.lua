
CrossUnionWarCfg =
{
	level = {0, 70},
	Time = 1800,
	FinialRankShowNum = 10,
	rankLimit = 100,
	unionTeams =
	{
		{
			id = 1,
			name = Lang.ScriptTips.CrossUnionWar001,
			EnterPos = {183,22,72,3,3},
			npcId = 155,
		},
		{
			id = 2,
			name = Lang.ScriptTips.CrossUnionWar002,
			EnterPos = {183,69,57,3,3},
			npcId = 156,
		},
	},
	deadBuff =
	{
		{
			deadCount = 1,
			buffId = { 808,  },
		},
		{
			deadCount = 2,
			buffId = { 809,  },
		},
		{
			deadCount = 3,
			buffId = { 810, },
		},
	},
	ExitPos = {5,76,67,3,3},
	ExchangeItems =
	{
		{
			id = 4296,
			consume = {{ type = 0, id = 4296, count = 1, },},
			score = 20,
		},
		{
			id = 4297,
			consume = {{ type = 0, id = 4297, count = 1, },},
			score = 100,
		},
		{
			id = 4298,
			consume = {{ type = 0, id = 4298, count = 1, },},
			score = 500,
		},
		{
			id = 4299,
			consume = {{ type = 0, id = 4299, count = 1, },},
			score = 2500,
		},
		{
			id = 4300,
			consume = {{ type = 0, id = 4300, count = 1, },},
			score = 10000,
		},
	},
	ShowTitleItemId = 4298,
	killScore =
	{
		{
			circle = 12,
			level = 80,
			addScore = 2000,
		},
		{
			circle = 11,
			level = 80,
			addScore = 1800,
		},
		{
			circle = 10,
			level = 80,
			addScore = 1600,
		},
		{
			circle = 9,
			level = 80,
			addScore = 1400,
		},
		{
			circle = 8,
			level = 80,
			addScore = 1200,
		},
		{
			circle = 7,
			level = 80,
			addScore = 1000,
		},
		{
			circle = 6,
			level = 80,
			addScore = 800,
		},
		{
			circle = 5,
			level = 80,
			addScore = 600,
		},
		{
			circle = 4,
			level = 80,
			addScore = 400,
		},
		{
			circle = 3,
			level = 80,
			addScore = 300,
		},
		{
			circle = 2,
			level = 80,
			addScore = 200,
		},
		{
			circle = 1,
			level = 80,
			addScore = 100,
		},
		{
			circle = 0,
			level = 70,
			addScore = 30,
		},
	},
	Awards =
	{
		{
			condition = {1,1},
			award =
			{
				{type = 0, id = 4073, count = 30, bind = 1 , strong = 0 ,quality = 0 ,},
				{type = 0, id = 4072, count = 30, bind = 1 , strong = 0 ,quality = 0 ,},
			},
		},
		{
			condition = {2,5},
			award =
			{
				{type = 0, id = 4073, count = 25, bind = 1 , strong = 0 ,quality = 0 ,},
				{type = 0, id = 4072, count = 25, bind = 1 , strong = 0 ,quality = 0 ,},
			},
		},
		{
			condition = {6,20},
			award =
			{
				{type = 0, id = 4073, count = 21, bind = 1 , strong = 0 ,quality = 0 ,},
				{type = 0, id = 4072, count = 21, bind = 1 , strong = 0 ,quality = 0 ,},
			},
		},
		{
			condition = {21,50},
			award =
			{
				{type = 0, id = 4073, count = 18, bind = 1 , strong = 0 ,quality = 0 ,},
				{type = 0, id = 4072, count = 18, bind = 1 , strong = 0 ,quality = 0 ,},
			},
		},
		{
			condition = {51,100},
			award =
			{
				{type = 0, id = 4073, count = 15, bind = 1 , strong = 0 ,quality = 0 ,},
				{type = 0, id = 4072, count = 15, bind = 1 , strong = 0 ,quality = 0 ,},
			},
		},
	},
	winnerAwards =
	{
		{type = 0, id = 4034, count = 1, bind = 1 , strong = 0 ,quality = 0 ,},
		{type = 0, id = 4039, count = 1, bind = 1 , strong = 0 ,quality = 0 ,},
		{type = 0, id = 4018, count = 1, bind = 1 , strong = 0 ,quality = 0 ,},
	},
}
