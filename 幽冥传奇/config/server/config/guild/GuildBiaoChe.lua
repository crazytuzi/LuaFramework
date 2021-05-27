
GuildDartConst =
{
	OpenTimes = 1,
	SbkOwnOpenTimes = 2,
	OpenInterval = 3600,
	needGuildCoin = 500000,
	returnCoinRate = 20,
	dartTime = {19,22},
	protectItemId = 743,
	Dest =
	{
		nSceneid = 8, x = 113, y = 45, destnpcname = Lang.EntityName.n00090,
	},
	Src =
	{
		nSceneid = 8, x = 92, y = 42, snpcname = Lang.EntityName.n00090,
	},
	  GuildDartHorse =
	  {
		id = 308,
		livetime = 3600,
		monName = Lang.EntityName.m00355,
		x = 103,
		y = 181,
	  },
	beLootDart =
	{
		id = 309,
		modleId = 272,
		livetime = 3600,
		monName = Lang.EntityName.m00355,
	},
         successAwards =
	 {
		{type = 20, id = 1, count = 1000, quality = -1, strong = -1, bind = 1, param = 0},
	 },
	actorNumAward =
	{
		{1,1},
		{2,1.25},
		{4,1.5},
		{6,1.75},
		{8,2},
		{10,2.5},
		{12,3},
		{14,3.5},
		{16,4},
		{20,6},
		{25,8},
		{30,11},
		{40,15},
		{50,20},
	},
	awardJieBiaoRate = 1,
	 AwardGuildCoin = 500000,
	 beLootAwards =
	 {
		{type = 20, id = 1, count = 1000, quality = -1, strong = -1, bind = 1, param = 0},
	 },
	 onLootAwards =
	 {
		{type = 20, id = 1, count = 300, quality = -1, strong = -1, bind = 1, param = 0},
	 },
	  DartSetup =
	  {
		succFollowDist = 30,
		actionTime = 3600,
		CampDartStatusIdle = 0,
		CampDartStatusAccept = 1,
		CampDartStatusFinished = 2,
		CampDartStatusGotAward = 3,
		CampDartFailUnknown = 0,
		CampDartFailExpired = 1,
		CampDartFailOverMaxDist = 2,
		CampDartFailObjDie=3,
		CampDartFailActorGiveUp=4,
		CampDartFailActorLogout=5,
		CampDartFailBeLoot = 6,
	},
}
