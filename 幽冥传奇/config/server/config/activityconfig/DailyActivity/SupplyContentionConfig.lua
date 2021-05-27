
SupplyContentionConfig =
{
	level = {0, 70},
	Time = 1200,
	FinialRankShowNum = 20,
	rankLimit = 10,
	unionTeams =
	{
		{
			id = 1,
			name = Lang.ScriptTips.SupplyContention001,
			EnterPos = {205,5,9,3,3},
			npcId = 203,
		},
		{
			id = 2,
			name = Lang.ScriptTips.SupplyContention002,
			EnterPos = {205,60,15,3,3},
			npcId = 204,
		},
	},
	deadBuff =
	{
		{
			deadCount = 2,
			buffId = {1320,1325,1330,1335,1340,1345,1350,1355,1360,1365,1370},
		},
		{
			deadCount = 3,
			buffId = {1321,1326,1331,1336,1341,1346,1351,1356,1361,1366,1371},
		},
		{
			deadCount = 4,
			buffId = {1322,1327,1332,1337,1342,1347,1352,1357,1362,1367,1372},
		},
		{
			deadCount = 5,
			buffId = {1323,1328,1333,1338,1343,1348,1353,1358,1363,1368,1373},
		},
		{
			deadCount = 6,
			buffId = {1324,1329,1334,1339,1344,1349,1354,1359,1364,1369,1374},
		},
	},
	ExitPos = {4,50,70,3,3},
	killBossAddBuffList = {1317,1318,1319},
	boss = { monsterId = 1574, sceneId = 205, num = 1,  pos = {32,10}, livetime = 1800,},
	campWinScore = 8000,
	addScore = 300,
	addCampScore = 1,
	killScore =
	{
		{
			circle = 20,
			level = 80,
			addScore = 100,
		},
		{
			circle = 19,
			level = 80,
			addScore = 95,
		},
		{
			circle = 18,
			level = 80,
			addScore = 90,
		},
		{
			circle = 17,
			level = 80,
			addScore = 85,
		},
		{
			circle = 16,
			level = 80,
			addScore = 80,
		},
		{
			circle = 15,
			level = 80,
			addScore = 75,
		},
		{
			circle = 14,
			level = 80,
			addScore = 70,
		},
		{
			circle = 13,
			level = 80,
			addScore = 65,
		},
		{
			circle = 12,
			level = 80,
			addScore = 60,
		},
		{
			circle = 11,
			level = 80,
			addScore = 55,
		},
		{
			circle = 10,
			level = 80,
			addScore = 50,
		},
		{
			circle = 9,
			level = 80,
			addScore = 45,
		},
		{
			circle = 8,
			level = 80,
			addScore = 40,
		},
		{
			circle = 7,
			level = 80,
			addScore = 35,
		},
		{
			circle = 6,
			level = 80,
			addScore = 30,
		},
		{
			circle = 5,
			level = 80,
			addScore = 25,
		},
		{
			circle = 4,
			level = 80,
			addScore = 20,
		},
		{
			circle = 3,
			level = 80,
			addScore = 15,
		},
		{
			circle = 2,
			level = 80,
			addScore = 10,
		},
		{
			circle = 1,
			level = 80,
			addScore = 6,
		},
		{
			circle = 0,
			level = 70,
			addScore = 3,
		},
	},
	killScoreRate =
	{
		{
			rate = 10,
			addKillScoreRate = 20,
		},
		{
			rate = 100,
			addKillScoreRate = 15,
		},
		{
			rate = 1000,
			addKillScoreRate = 10,
		},
	},
	Awards =
	{
		{
			condition = {1000,999999},
			showicon = 4426,
			award =
			{
				{type = 0, id = 4091, count = 30, bind = 1 , strong = 0 ,quality = 0 ,},
				{type = 11, id = 1, count = 25000, bind = 1 , strong = 0 ,quality = 0 ,},
				{type = 0, id = 4047, count = 4, bind = 1 , strong = 0 ,quality = 0 ,},
				{type = 0, id = 4646, count = 1, bind = 1 , strong = 0 ,quality = 0 ,},
			},
		},
		{
			condition = {600,999},
			showicon = 4309,
			award =
			{
				{type = 0, id = 4091, count = 25, bind = 1 , strong = 0 ,quality = 0 ,},
				{type = 11, id = 1, count = 21000, bind = 1 , strong = 0 ,quality = 0 ,},
				{type = 0, id = 4047, count = 3, bind = 1 , strong = 0 ,quality = 0 ,},
			},
		},
		{
			condition = {300,599},
			showicon = 4425,
			award =
			{
				{type = 0, id = 4091, count = 20, bind = 1 , strong = 0 ,quality = 0 ,},
				{type = 11, id = 1, count = 19000, bind = 1 , strong = 0 ,quality = 0 ,},
				{type = 0, id = 4047, count = 2, bind = 1 , strong = 0 ,quality = 0 ,},
			},
		},
		{
			condition = {100,299},
			showicon = 4308,
			award =
			{
				{type = 0, id = 4091, count = 16, bind = 1 , strong = 0 ,quality = 0 ,},
				{type = 11, id = 1, count = 17000, bind = 1 , strong = 0 ,quality = 0 ,},
				{type = 0, id = 4047, count = 1, bind = 1 , strong = 0 ,quality = 0 ,},
			},
		},
		{
			condition = {10,99},
			showicon = 4307,
			award =
			{
				{type = 0, id = 4091, count = 13, bind = 1 , strong = 0 ,quality = 0 ,},
				{type = 11, id = 1, count = 15000, bind = 1 , strong = 0 ,quality = 0 ,},
				{type = 0, id = 4047, count = 1, bind = 1 , strong = 0 ,quality = 0 ,},
			},
		},
	},
	winnerAwards =
	{
		{type = 0, id = 4091, count = 10, bind = 1 , strong = 0 ,quality = 0 ,},
		{type = 0, id = 4059, count = 1, bind = 1 , strong = 0 ,quality = 0 ,},
	},
	winnerFirst =
	{
		{type = 0, id = 4091, count = 20, bind = 1 , strong = 0 ,quality = 0 ,},
		{type = 0, id = 4059, count = 3, bind = 1 , strong = 0 ,quality = 0 ,},
	},
	killBroadCast =
	{
		{
			killCount = 5,
			broadcast = Lang.ScriptTips.SupplyContention021,
		},
		{
			killCount = 15,
			broadcast = Lang.ScriptTips.SupplyContention022,
		},
		{
			killCount = 30,
			broadcast = Lang.ScriptTips.SupplyContention023,
		},
		{
			killCount = 50,
			broadcast = Lang.ScriptTips.SupplyContention024,
		},
	},
}
