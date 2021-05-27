
WorshipConfig =
{
	limitLevel = 35,
	multiExp =
	{
		{
			times = {100, 199},
			buff = {buffType = 64, groupId = 94, value = 1.5, times = 1, interval = 3600, buffName = Lang.Activity.a00126, timeOverlay = false},
		},
		{
			times = {200, 299},
			buff = {buffType = 64, groupId = 94, value = 1.8, times = 1, interval = 3600, buffName = Lang.Activity.a00126, timeOverlay = false},
		},
		{
			times = {300, 399},
			buff = {buffType = 64, groupId = 94, value = 2, times = 1, interval = 3600, buffName = Lang.Activity.a00126, timeOverlay = false},
		},
		{
			times = {400, 499},
			buff = {buffType = 64, groupId = 94, value = 2.5, times = 1, interval = 3600, buffName = Lang.Activity.a00126, timeOverlay = false},
		},
		{
			times = {500, 100000000},
			buff = {buffType = 64, groupId = 94, value = 3, times = 1, interval = 3600, buffName = Lang.Activity.a00126, timeOverlay = false},
		},
	},
	worshipsLimitTimes =
	{
		goldTimes = 50,
		ybTimes = 100,
	},
	worships =
	{
		{
			times = 1,
			inc = 0.25,
			consumes =
			{
				{type = 6, id = 0, count = 5000},
			},
			awards =
			{
				{type = 20, id = 3, count = 50, quality = 0},
			},
		},
		{
			times = 2,
			consumes =
			{
				{type = 15, id = 0, count = 10},
			},
			awards =
			{
				{type = 20, id = 3, count = 150, quality = 0},
			},
		},
		{
			times = 1,
			inc = 0.25,
			consumes =
			{
				{type = 6, id = 0, count = 5000},
			},
			awards =
			{
				{type = 20, id = 3, count = 50, quality = 0},
			},
		},
		{
			times = 2,
			consumes =
			{
				{type = 15, id = 0, count = 10},
			},
			awards =
			{
				{type = 20, id = 3, count = 150, quality = 0},
			},
		},
	},
	castellanAward =
	{
		limitTimes = 200,
		maxLimit = 5,
		awards =
		{
			{type = 20, id = 3, count = 5000, quality = 0},
		},
	},
	rewardWorship =
	{
		chgRate = 2,
		consumes =
		{
			{type = 15, id = 0, count = 100},
			{type = 15, id = 0, count = 200},
			{type = 15, id = 0, count = 300},
			{type = 15, id = 0, count = 500},
			{type = 15, id = 0, count = 1000},
		},
		rewards =
		{
			{type = 7, id = 0, count = 10},
		}
	}
}