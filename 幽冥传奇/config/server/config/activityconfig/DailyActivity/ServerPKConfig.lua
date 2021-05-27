
ServerPKConfig =
{
	level = {80,0},
	PrepareTime = 300,
	Time = 3300,
	RankCount = 10,
    RankLimit = 1,
	GameOverTime = 5,
	AutoPointTimer = 18,
	AutoPoint = 10,
	AutoExp = {{ type = 11, id = 1, count = 100, strong = 0, quality = 0, bind = 0 }},
	CirclePoint = {3,6,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100},
	KilledPointRate = 0.3,
	PreparePos =  {202,11,19,5,5},
	ActivityPos = {203,24,35,25,30},
	ExitPos = {5,71,65,5,5},
	SceneMsgTimer = 10,
	Awards  =
	{
		{
			condition = {1,1},
			awards =
			{
				{ type = 5, id = 0, count = 300 },
				{ type = 0, id = 4004, count = 5 },
                { type = 0, id = 4272, count = 2 },
			},
		},
		{
			condition = {2,5},
			awards =
			{
				{ type = 5, id = 0, count = 250 },
				{ type = 0, id = 4004, count = 4 },
			},
		},
		{
			condition = {6,20},
			awards =
			{
				{ type = 5, id = 0, count = 210 },
				{ type = 0, id = 4004, count = 3 },
			},
		},
		{
			condition = {21,50},
			awards =
			{
				{ type = 5, id = 0, count = 180 },
				{ type = 0, id = 4003, count = 25 },
			},
		},
		{
			condition = {51,200},
			awards =
			{
				{ type = 5, id = 0, count = 150 },
				{ type = 0, id = 4003, count = 20 },
			},
		},
	},
}