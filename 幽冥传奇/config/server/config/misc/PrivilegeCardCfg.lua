
PrivilegeFlagsCfg ={
	isNot = 0,
	isNotHad =1,
	CanBuy =2,
	CanKeep =3,
	CanGet = 4,
	DropCrt_1 =5,
	isGetBonfireTime = 6,
	isAddDepotGrid = 7,
}
PrivilegeCardCfg =
{
	totalPros =3,
	showDay = 1,
	openDay = 1,
	needLevel = 1,
	needCircle = 0,
	Discount = 0.8,
	group = {144,115,   326,326},
	Pros =
	{
		[1] =
		{
			name = "贵族特权",
			addTimeSec = 604800,
			CostYB = {8,6,   30,30},
			TitleId = 47,
			BuffId = 332,
			addDepotGrid = 0,
			DropCrt = { 1, 0, 0, 0, 0, 0,},
			isOneKeyFinishCLFB = 0,
			privilegeBossTms = 1,
			dayAddWildBossTms = 0,
			multExpBonfireTime = 0,
			multExpBonfire = 0,
			oneHourAddExp = 0,
			offlineMaxTime = 43200,
			addExpIntervalTime = 10,
			award =
			{
				{type = 0,id = 266,count = 2,bind = 1,},
				{type = 0,id = 469,count = 10,bind = 1,},
			},
		},
		[2] =
		{
			name = "王者特权",
			addTimeSec = 1209600,
			CostYB = {38,28,   98,98},
			TitleId = 48,
			BuffId = 333,
			addDepotGrid = 10,
			DropCrt = { 0, 150, 50, 1000, 500, 0,},
			isOneKeyFinishCLFB = 1,
			privilegeBossTms = 1,
			dayAddWildBossTms = 0,
			multExpBonfireTime = 0,
			multExpBonfire = 2,
			oneHourAddExp = 0,
			offlineMaxTime = 43200,
			addExpIntervalTime = 10,
			award =
			{
				{type = 0,id = 266,count = 3,bind = 1,},
				{type = 0,id = 469,count = 18,bind = 1,},
				{type = 0,id = 2054,count = 5,bind = 1,},
			},
		},
		[3] =
		{
			name = "至尊特权",
			addTimeSec = 2592000,
			CostYB = {98,88,   198,198},
			TitleId = 49,
			BuffId = 334,
			addDepotGrid = 20,
			DropCrt = { 0, 150, 50, 4000, 1000, 0,},
			isOneKeyFinishCLFB = 1,
			privilegeBossTms = 1,
			dayAddWildBossTms = 0,
			multExpBonfireTime = 0,
			multExpBonfire = 2,
			oneHourAddExp = 0,
			offlineMaxTime = 43200,
			addExpIntervalTime = 10,
			award =
			{
				{type = 0,id = 266,count = 5,bind = 1,},
				{type = 0,id = 469,count = 25,bind = 1,},
				{type = 0,id = 2054,count = 8,bind = 1,},
			},
		},
	},
}