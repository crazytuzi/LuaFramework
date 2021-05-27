
WeiZhiAnDianCfg =
{
	openSvrDays = 1,
	openLevel = 70,
	daysMaxTimes = 0,
	freeTimes = 3,
	Money = {{type = 7, id = 0, count = 500},},
	npcId = 84,
	SceneId = 217,
	posX = 60,
	posY = 7,
	buyMultExp =
	{
		{mult = 2, times = 600, consumes = {{type = 15, id = 0, count = 288,},},},
		{mult = 2, times = 1800, consumes = {{type = 15, id = 0, count = 688,},},},
	},
	FireId = {[365] = 365, [366] = 366, [367] = 367}, -- 注意,修改ID需要修改对应的圆圈资料的命名.圆圈命名前缀"bonfire_range_"
	bonfireCfg =
	{
		typeId = 1,
		effectTypes =
		{
			-- 圆圈资料位置client\runtime\assets\res\xui\painting,圆圈命名前缀"bonfire_range_"
			{monId = 588, rate = 1000, radius = 3, times = 60, exp = 30000, interval = 1, modelId = 365, actorNum = 0, isnotice = 0,},
			{monId = 589, rate = 1000, radius = 3, times = 60, exp = 30000, interval = 1, modelId = 365, actorNum = 0, isnotice = 0,},
			{monId = 590, rate = 1000, radius = 3, times = 60, exp = 30000, interval = 1, modelId = 365, actorNum = 0, isnotice = 0,},
			{monId = 591, rate = 1000, radius = 3, times = 60, exp = 30000, interval = 1, modelId = 365, actorNum = 0, isnotice = 0,},
			{monId = 592, rate = 1000, radius = 3, times = 60, exp = 30000, interval = 1, modelId = 365, actorNum = 0, isnotice = 0,},
			{monId = 593, rate = 1000, radius = 3, times = 60, exp = 30000, interval = 1, modelId = 365, actorNum = 0, isnotice = 0,},
			{monId = 594, rate = 1000, radius = 3, times = 60, exp = 30000, interval = 1, modelId = 365, actorNum = 0, isnotice = 0,},
			{monId = 595, rate = 1000, radius = 3, times = 60, exp = 30000, interval = 1, modelId = 365, actorNum = 0, isnotice = 0,},
			{monId = 580, rate = 10000, radius = 3, times = 120, exp = 50000, interval = 1, modelId = 366, actorNum = 0, isnotice = 0,},
			{monId = 581, rate = 10000, radius = 3, times = 120, exp = 50000, interval = 1, modelId = 366, actorNum = 0, isnotice = 0,},
			{monId = 582, rate = 10000, radius = 3, times = 120, exp = 50000, interval = 1, modelId = 366, actorNum = 0, isnotice = 0,},
			{monId = 583, rate = 10000, radius = 3, times = 120, exp = 50000, interval = 1, modelId = 366, actorNum = 0, isnotice = 0,},
			{monId = 584, rate = 10000, radius = 3, times = 120, exp = 50000, interval = 1, modelId = 366, actorNum = 0, isnotice = 0,},
			{monId = 585, rate = 10000, radius = 3, times = 120, exp = 50000, interval = 1, modelId = 366, actorNum = 0, isnotice = 0,},
			{monId = 586, rate = 10000, radius = 4, times = 180, exp = 100000, interval = 1, modelId = 367, actorNum = 10, isnotice = 1,},
			{monId = 587, rate = 10000, radius = 4, times = 180, exp = 100000, interval = 1, modelId = 367, actorNum = 10, isnotice = 1,},
		},
	},
	RwData = {"未知暗殿", "龙魂城", "{viewLink;UnknownDarkHouse;[我也要进入]}"},
}