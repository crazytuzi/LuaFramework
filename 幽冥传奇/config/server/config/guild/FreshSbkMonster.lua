
SbkGuildMonsterConfig =
{
	monsters =
	{
		nMonsterID = 306,
		nSceenId = 4,
		posX = 96, posY =  100,
		nCount = 1,
		nLiveTime = 3600,
	},
	SbkBoxs =
	{
		{nMonsterID = 596, nSceenId = 9, posX1 = 16, posX2 = 16,  posY = 15, nCount = 1, nLiveTime = 600,},
	},
	nSceenId = 119,
	nSceenRange = {152,158,4,4},
	minLevel = 40,
	broadPerMin = 1 * 60,
	nonActivityTime = {19,22},
	needGuildCoin = 1000000,
	freeOpenTimes = 1,
	totalOpenTimes = 2,
	nDrafts = {itemId = 315,count = 2,},
	openNeedYb = 100,
	halfOpenYb = 50,
	fressBossTime = 5 * 60 * 1000,
	sbkTimeUp = 30 * 60,
	cityMonster =
	{
		{nMonsterID = 589, nSceenId = 119, posX1 = 98, posX2 = 143,  posY = 126, nCount = 1, nLiveTime = 1200,},
	},
	outSceenId = 9,
	outRange = {14,16,2,2},
	perTime = 30000,
	GiveExpOnTime =
	{
		{ type = 20, id = 1, count = 30, strong = 0, quality = 0, bind = 0 },
		{ type = 21, id = 0, count = 250, strong = 0, quality = 0, bind = 0 },
	},
	monsterRaid =
	{
		sceneid = 3,
		monsterMaxNum = {3,3,3,3},
		monsterRange = {307,313},
		createPos = {{96,122},{154,137},{150,91},{107,83}},
		posDeviation = {-5,5},
		nLiveTime = 1800,
	}
}
