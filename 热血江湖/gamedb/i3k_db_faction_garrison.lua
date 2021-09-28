i3k_db_faction_garrison =
{
	openCondition = {
		needFactionLvl = 1,
		needActivity = 10000,
		donationItemID = 66723,
		donationItemCount = 800,
		needTime = 48,
		getPower = 100,
		dungeonId = 4002,
		enterLimitLvl = 45
	},
	pk = {
		defaultPKMode = 0,
		garrisonPKMode = 3
	},
	factionBoss = {
		openDay = { 1, 2, 3, 4, 5, 6, 0, },
		limitTime = 1,
		awardNeedLvl = 60,
		needTime = 48
	},
	bossOpenTimes = {
		[1] = { startTime = '16:00:00', openTime = 57600, lifeTime = 6900},
		[2] = { startTime = '21:00:00', openTime = 75600, lifeTime = 6900},
	},
};

i3k_db_faction_boss_donation =
{
	[1] = {showLvl = 65, donationCfg = {{itemID = 66719, limitCount = 10, getPower = 200, getSectMoney = 8}, {itemID = 66720, limitCount = 20, getPower = 35, getSectMoney = 4}, } , needPower = 50000, needRatio = 8000, consumeDiamond = 2, dropShow = {66728, 66724, 65819, 66153, } , showModelID = 4851, showBossName = '堕落城主' },
	[2] = {showLvl = 75, donationCfg = {{itemID = 66719, limitCount = 10, getPower = 100, getSectMoney = 10}, {itemID = 66721, limitCount = 20, getPower = 20, getSectMoney = 5}, } , needPower = 50000, needRatio = 8000, consumeDiamond = 5, dropShow = {66728, 66724, 66207, 66154, } , showModelID = 4852, showBossName = '虎威将军' },
	[3] = {showLvl = 85, donationCfg = {{itemID = 66719, limitCount = 10, getPower = 75, getSectMoney = 12}, {itemID = 66722, limitCount = 20, getPower = 15, getSectMoney = 6}, } , needPower = 50000, needRatio = 8000, consumeDiamond = 8, dropShow = {66728, 66724, 65657, 66161, } , showModelID = 4850, showBossName = '金钟武神' },
	[4] = {showLvl = 95, donationCfg = {{itemID = 66719, limitCount = 10, getPower = 50, getSectMoney = 14}, {itemID = 67291, limitCount = 20, getPower = 15, getSectMoney = 7}, } , needPower = 50000, needRatio = 8000, consumeDiamond = 10, dropShow = {66728, 66724, 66161, 67053, } , showModelID = 6911, showBossName = '魔女祝黑野' },
};

i3k_db_faction_garrsion_minimap =
{
	[4002] = { mapName = '帮派驻地', imageId = 4814, titleImgId = 4813, scaleX = 0.5, scaleY = 0.5, scale = 0.2, worldMapScale = 0.8, worldMapScaleX = 0.35, worldMapScaleY = 0.25 },
};

i3k_db_longyun_reward =
{
	[1] = { itemId1 = 66659, itemId2 = 65657, itemId3 = 66463, itemId4 = 65901 },
	[2] = { itemId1 = 66652, itemId2 = 66659, itemId3 = 65657, itemId4 = 66464 },
};

i3k_db_faction_dragon =
{
	dragonCfg = {
		dragonIDs = { 8050, 8051, 8052, 8053, 8054, },
		openDay = { 1, 2, 3, 4, 5, 6, 0, },
		addPoint = 100,
		spacing = 3,
		maxPoint = 1000,
		enterMaxNum = 30,
		factionMaxNum = 12,
		normalConsume = 2500,
		normalReward = 66694,
		superConsume = 3500,
		superReward = 66695,
		longyunTimes = 3,
		longyunLvl = 45,
		longyunApply = 48,
		longyunIcon = 4808
	},
	treasureOpenTime = {
		[1] = {startTime = '20:00:00', openTime = 72000, lifeTime = 2100},
	},
	dragonInfo = {
		[8050] = { action ='stand_jin', position = { x = 15.09183, y = 16.08383, z = 13.49876}, iconID =4895},
		[8051] = { action ='stand_mu', position = { x = 14.92505, y = 17.23064, z = 97.25977}, iconID =4896},
		[8052] = { action ='stand_shui', position = { x = -34.95977, y = 16.08383, z = 74.15284}, iconID =4897},
		[8053] = { action ='stand_huo', position = { x = -32.60651, y = 16.08383, z = 36.11781}, iconID =4898},
		[8054] = { action ='stand_tu', position = { x = 36.94038, y = 16.08383, z = 53.08035}, iconID =4899},
	},
	destiny = {
		minPercent = 3000
	},
};

i3k_db_faction_garrsion_boss =
{
	[1] = {  monsterId = 68701, position = { x = 15.4908543, y = 16.0838318, z = 52.563} },
	[2] = {  monsterId = 68702, position = { x = 15.4908543, y = 16.0838318, z = 52.563} },
	[3] = {  monsterId = 68703, position = { x = 15.4908543, y = 16.0838318, z = 52.563} },
	[4] = {  monsterId = 68704, position = { x = 15.4908543, y = 16.0838318, z = 52.563} },
};

i3k_db_faction_spirit =
{
	spiritCfg = {openlvl =45, openDay = { 1, 2, 3, 4, 5, 6, 0, }, startTime = '18:00:00', openTime = 64800, lifeTime = 1800, skillId = 91018, blessingLevel = 60, factionTime = 172800, blessingIcon = 7695, searchRange = 2000, monsterId = 170000, monsterCount = 240},
	blessingRewards = {
		[1] = { spiritCount = 20, expCount = 500, lifeTime = 3600, blessingText = 17466},
		[2] = { spiritCount = 50, expCount = 1000, lifeTime = 3600, blessingText = 17466},
		[3] = { spiritCount = 100, expCount = 1500, lifeTime = 3600, blessingText = 17466},
		[4] = { spiritCount = 150, expCount = 2000, lifeTime = 3600, blessingText = 17466},
		[5] = { spiritCount = 200, expCount = 2500, lifeTime = 3600, blessingText = 17466},
	},
}
