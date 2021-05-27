
HorseRaceConfig =
{
	limitLevel = 40,
	actTime = 1800,
	readyTime = 180,
	countDown = 30,
	actScene = {115, 117},
	skill =
	{
		{id = 96, level = 1},
		{id = 97, level = 1},
		{id = 98, level = 1},
	},
	barrier = {sid = 115, mid = 389, pos = {{64,75}, {63,74}, {62,73}, {61,72},{61,71},{60,72},{59,73}, {60,71}, {59,70}, {58,71}, {59,72}, {60,73}, {61,74}, {72,75}, {62,76}, {63,77}, {64,76}, {63,75}, {62,74}, {61,73}, {60,70}, {59,71}}},
	readyScene =  {sid = 115, range = {67,65,3,3},},
	returnScene = {sid = 2, range = {218,236,3,3}},
	winBoss =
	{
		mid = 631,
		liveTime = 1800,
		range = {x1=69, y1=49, x2 = 75, y2 = 65},
	},
	rankAward =
	{
		{
			rankInterval = {1,1},
			awards=
			{
				{type = 20, id = 2, count = 3000,quality = 0, strong = 0, bind = 0},
				{type = 21, id = 0, count = 15000,quality = 0, strong = 0, bind = 0},
				{type = 0, id = 824, count = 1, quality = 0, strong = 0, bind = 1},
			},
		},
		{
			rankInterval = {2,2},
			awards=
			{
				{type = 20, id = 2, count = 2700,quality = 0, strong = 0, bind = 0},
				{type = 21, id = 0, count = 12750,quality = 0, strong = 0, bind = 0},
				{type = 0, id = 825, count = 1, quality = 0, strong = 0, bind = 1},
			},
		},
		{
			rankInterval = {3,3},
			awards=
			{
				{type = 20, id = 2, count = 2400,quality = 0, strong = 0, bind = 0},
				{type = 21, id = 0, count = 10838,quality = 0, strong = 0, bind = 0},
				{type = 0, id = 826, count = 1, quality = 0, strong = 0, bind = 1},
			},
		},
		{
			rankInterval = {4,10},
			awards=
			{
				{type = 20, id = 2, count = 2200,quality = 0, strong = 0, bind = 0},
				{type = 21, id = 0, count = 9212,quality = 0, strong = 0, bind = 0},
				{type = 0, id = 827, count = 1, quality = 0, strong = 0, bind = 1},
			},
		},
		{
			rankInterval = {11,20},
			awards=
			{
				{type = 20, id = 2, count = 2000,quality = 0, strong = 0, bind = 0},
				{type = 21, id = 0, count = 7830,quality = 0, strong = 0, bind = 0},
				{type = 0, id = 827, count = 1, quality = 0, strong = 0, bind = 1},
			},
		},
		{
			rankInterval = {21,50},
			awards=
			{
				{type = 20, id = 2, count = 1800,quality = 0, strong = 0, bind = 0},
				{type = 21, id = 0, count = 6656,quality = 0, strong = 0, bind = 0},
			},
		},
		{
			rankInterval = {51,10000},
			awards=
			{
				{type = 20, id = 2, count = 1600,quality = 0, strong = 0, bind = 0},
			},
		},
	},
}