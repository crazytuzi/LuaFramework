i3k_db_defenceWar_cfg = {
	factionLvl = 8, 
	playerLvl = 50, 
	bidTotalTime = 4, 
	backRatio = 8000, 
	joinCnt = 30, 
	reviveCooling = 10, 
	score = {outGateScore = 10, inGateScore = 10, towerScore = 10, bossScore = 50, guardScore = 20, oneKillScore = 200, addScoreSecond = 180, addScoreNum = 45}, 
	bless = {blessOpenTime = 1, blessSecond = 3600}, 
	car = {carCost = 200, carCooling = 600}, 
	tower = {towerGoodModel = 2169, towerBadModel = 2169, towerCost = 100, towerCooling = 300}, 
	fightTotalTime = 1800, 
	needJoinSectTime = 86400, 
	rewardJoinSectTime = 86400, 
	listNums = 10, 
	fightText = 'fight', 
	towerFactionSkillID = 13, 
	carFactionSkillID = 12, 
	group = {
		[1] = {
			menDecentModel = { 2037, 2038, 2039, 2040, 2041, 2267, 2443, 4862, }, 
			womenDecentModel = { 2047, 2048, 2049, 2050, 2051, 2269, 2445, 4864, }, 
			carChangeID = 413, 
			factionFlagModelID = 440
		},
		[2] = {
			menDecentModel = { 2032, 2033, 2034, 2035, 2036, 2266, 2442, 4861, }, 
			womenDecentModel = { 2042, 2043, 2044, 2045, 2046, 2268, 2444, 4863, }, 
			carChangeID = 415, 
			factionFlagModelID = 439
		},
		[3] = {
			menDecentModel = { 2674, 2676, 2678, 2680, 2682, 2684, 2686, 4865, }, 
			womenDecentModel = { 2675, 2677, 2679, 2681, 2683, 2685, 2687, 4866, }, 
			carChangeID = 417, 
			factionFlagModelID = 2689
		},
	},
	transformBaseHp = 500000,
	delayTime = {3600, 7200, 10800, 14400, },
};

i3k_db_defenceWar_time = {
	[1] = {name = '城战第1期', startTime = 1532743200, endTime = 1533135600, signEndTime = 1532771700, captureStartTime = 1532771760, bidStartTime = 1532772720, bidEndTime = 1532772900, grabStartTime = 1532773080},
	[2] = {name = '城战第2期', startTime = 1534125600, endTime = 1536505200, signEndTime = 1534591800, captureStartTime = 1534593600, bidStartTime = 1535335200, bidEndTime = 1535801400, grabStartTime = 1535803200},
	[3] = {name = '城战第3期', startTime = 1537754400, endTime = 1540134000, signEndTime = 1538220600, captureStartTime = 1538222400, bidStartTime = 1538964000, bidEndTime = 1539430200, grabStartTime = 1539432000},
	[4] = {name = '城战第4期', startTime = 1540173600, endTime = 1542553200, signEndTime = 1540639800, captureStartTime = 1540641600, bidStartTime = 1541383200, bidEndTime = 1541849400, grabStartTime = 1541851200},
	[5] = {name = '城战第5期', startTime = 1542592800, endTime = 1544972400, signEndTime = 1543059000, captureStartTime = 1543060800, bidStartTime = 1543802400, bidEndTime = 1544268600, grabStartTime = 1544270400},
	[6] = {name = '城战第6期', startTime = 1545012000, endTime = 1547391600, signEndTime = 1545478200, captureStartTime = 1545480000, bidStartTime = 1546221600, bidEndTime = 1546687800, grabStartTime = 1546689600},
	[7] = {name = '城战第7期', startTime = 1547431200, endTime = 1549810800, signEndTime = 1547897400, captureStartTime = 1547899200, bidStartTime = 1548640800, bidEndTime = 1549107000, grabStartTime = 1549108800},
	[8] = {name = '城战第8期', startTime = 1549850400, endTime = 1552230000, signEndTime = 1550316600, captureStartTime = 1550318400, bidStartTime = 1551060000, bidEndTime = 1551526200, grabStartTime = 1551528000},
	[9] = {name = '城战第9期', startTime = 1552269600, endTime = 1554649200, signEndTime = 1552735800, captureStartTime = 1552737600, bidStartTime = 1553479200, bidEndTime = 1553945400, grabStartTime = 1553947200},
	[10] = {name = '城战第10期', startTime = 1554688800, endTime = 1557068400, signEndTime = 1555155000, captureStartTime = 1555156800, bidStartTime = 1555898400, bidEndTime = 1556364600, grabStartTime = 1556366400},
	[11] = {name = '城战第11期', startTime = 1557108000, endTime = 1559487600, signEndTime = 1557574200, captureStartTime = 1557576000, bidStartTime = 1558317600, bidEndTime = 1558783800, grabStartTime = 1558785600},
	[12] = {name = '城战第12期', startTime = 1561341600, endTime = 1563721200, signEndTime = 1561807800, captureStartTime = 1561809600, bidStartTime = 1562551200, bidEndTime = 1563017400, grabStartTime = 1563019200},
	[13] = {name = '城战第13期', startTime = 1563760800, endTime = 1566140400, signEndTime = 1564227000, captureStartTime = 1564228800, bidStartTime = 1564970400, bidEndTime = 1565436600, grabStartTime = 1565438400},
	[14] = {name = '城战第14期', startTime = 1566180000, endTime = 1568559600, signEndTime = 1566646200, captureStartTime = 1566648000, bidStartTime = 1567389600, bidEndTime = 1567855800, grabStartTime = 1567857600},
	[15] = {name = '城战第15期', startTime = 1568599200, endTime = 1570978800, signEndTime = 1569065400, captureStartTime = 1569067200, bidStartTime = 1569808800, bidEndTime = 1570275000, grabStartTime = 1570276800},
	[16] = {name = '城战第16期', startTime = 1571018400, endTime = 1573333200, signEndTime = 1571484600, captureStartTime = 1571486400, bidStartTime = 1572228000, bidEndTime = 1572694200, grabStartTime = 1572696000},
	[17] = {name = '城战第17期', startTime = 1573437600, endTime = 1575752400, signEndTime = 1573903800, captureStartTime = 1573905600, bidStartTime = 1574647200, bidEndTime = 1575113400, grabStartTime = 1575115200},
	[18] = {name = '城战第18期', startTime = 1575856800, endTime = 1578236400, signEndTime = 1576323000, captureStartTime = 1576324800, bidStartTime = 1577066400, bidEndTime = 1577532600, grabStartTime = 1577534400},
	[19] = {name = '城战第19期', startTime = 1578276000, endTime = 1580655600, signEndTime = 1578742200, captureStartTime = 1578744000, bidStartTime = 1579485600, bidEndTime = 1579951800, grabStartTime = 1579953600},
	[20] = {name = '城战第20期', startTime = 1580695200, endTime = 1583074800, signEndTime = 1581161400, captureStartTime = 1581163200, bidStartTime = 1581904800, bidEndTime = 1582371000, grabStartTime = 1582372800},
	[21] = {name = '城战第21期', startTime = 1583114400, endTime = 1585494000, signEndTime = 1583580600, captureStartTime = 1583582400, bidStartTime = 1584324000, bidEndTime = 1584790200, grabStartTime = 1584792000},

};

i3k_db_defenceWar_reward = {
	captureStageReward = {
		[1] = {score = 3000, rewards = {{id = 67498, count = 2}, {id = 67497, count = 5}, {id = 3, count = 1000}, {id = 67498, count = 2}, {id = 67497, count = 5}, {id = 3, count = 1000}, }, },
		[2] = {score = 6000, rewards = {{id = 67498, count = 3}, {id = 67497, count = 25}, {id = 3, count = 2000}, {id = 67498, count = 3}, {id = 67497, count = 25}, {id = 3, count = 2000}, }, },
		[3] = {score = 9000, rewards = {{id = 67498, count = 4}, {id = 67497, count = 25}, {id = 3, count = 3000}, {id = 67498, count = 4}, {id = 67497, count = 25}, {id = 3, count = 3000}, }, },
		[4] = {score = 12000, rewards = {{id = 67498, count = 5}, {id = 67497, count = 35}, {id = 3, count = 4000}, {id = 67498, count = 5}, {id = 67497, count = 35}, {id = 3, count = 4000}, }, },
		[5] = {score = 15000, rewards = {{id = 67498, count = 6}, {id = 67497, count = 45}, {id = 3, count = 5000}, {id = 67498, count = 6}, {id = 67497, count = 45}, {id = 3, count = 5000}, }, },
	},
};

i3k_db_defenceWar_city = {
	[1] = {name = '真武城', cityModel = 2169, signCost = 500, bidLowerPrice = 1000, blessAddition = 2000, storeDiscount = 8000, captureReward = {{id = 67498, count = 9}, {id = 67497, count = 65}, {id = 67495, count = 30}, }, icon = 982, grade = 2, fuli = '1:幫派商店商品打%s折。\n2:每天可以開啟%s小時城主之光', mapID = 4003, iconSign = 7059, iconBattle = 7064, difOpenCost = 10000},
	[2] = {name = '拜月城', cityModel = 2169, signCost = 500, bidLowerPrice = 1000, blessAddition = 2000, storeDiscount = 8000, captureReward = {{id = 67498, count = 9}, {id = 67497, count = 65}, {id = 67495, count = 30}, }, icon = 982, grade = 2, fuli = '1:幫派商店商品打%s折。\n2:每天可以開啟%s小時城主之光', mapID = 4004, iconSign = 7060, iconBattle = 7065, difOpenCost = 10000},
	[3] = {name = '帝王都', cityModel = 2169, signCost = 500, bidLowerPrice = 3000, blessAddition = 3000, storeDiscount = 7000, captureReward = {{id = 67498, count = 12}, {id = 67497, count = 80}, {id = 67494, count = 30}, }, icon = 982, grade = 1, fuli = '1:幫派商店商品打%s折。\n2:每天可以開啟%s小時城主之光', mapID = 4005, iconSign = 7063, iconBattle = 7068, difOpenCost = 10000},
	[4] = {name = '無憂城', cityModel = 2169, signCost = 500, bidLowerPrice = 1000, blessAddition = 2000, storeDiscount = 8000, captureReward = {{id = 67498, count = 9}, {id = 67497, count = 65}, {id = 67495, count = 30}, }, icon = 982, grade = 2, fuli = '1:幫派商店商品打%s折。\n2:每天可以開啟%s小時城主之光', mapID = 4006, iconSign = 7062, iconBattle = 7067, difOpenCost = 10000},
	[5] = {name = '東洲城', cityModel = 2169, signCost = 500, bidLowerPrice = 1000, blessAddition = 2000, storeDiscount = 8000, captureReward = {{id = 67498, count = 9}, {id = 67497, count = 65}, {id = 67495, count = 30}, }, icon = 982, grade = 2, fuli = '1:幫派商店商品打%s折。\n2:每天可以開啟%s小時城主之光', mapID = 4007, iconSign = 7061, iconBattle = 7066, difOpenCost = 10000},
	[6] = {name = '墨武鎮', cityModel = 2169, signCost = 500, bidLowerPrice = 600, blessAddition = 1000, storeDiscount = 9000, captureReward = {{id = 67498, count = 6}, {id = 67497, count = 50}, {id = 3, count = 5000}, }, icon = 982, grade = 3, fuli = '1:幫派商店商品打%s折。\n2:每天可以開啟%s小時城主之光', mapID = 4013, iconSign = 7376, iconBattle = 7377, difOpenCost = 10000},
	[7] = {name = '皓月鎮', cityModel = 2169, signCost = 500, bidLowerPrice = 600, blessAddition = 1000, storeDiscount = 9000, captureReward = {{id = 67498, count = 6}, {id = 67497, count = 50}, {id = 3, count = 5000}, }, icon = 982, grade = 3, fuli = '1:幫派商店商品打%s折。\n2:每天可以開啟%s小時城主之光', mapID = 4014, iconSign = 7376, iconBattle = 7377, difOpenCost = 10000},
	[8] = {name = '羅明鎮', cityModel = 2169, signCost = 500, bidLowerPrice = 600, blessAddition = 1000, storeDiscount = 9000, captureReward = {{id = 67498, count = 6}, {id = 67497, count = 50}, {id = 3, count = 5000}, }, icon = 982, grade = 3, fuli = '1:幫派商店商品打%s折。\n2:每天可以開啟%s小時城主之光', mapID = 4015, iconSign = 7376, iconBattle = 7377, difOpenCost = 10000},
	[9] = {name = '齊樂鎮', cityModel = 2169, signCost = 500, bidLowerPrice = 600, blessAddition = 1000, storeDiscount = 9000, captureReward = {{id = 67498, count = 6}, {id = 67497, count = 50}, {id = 3, count = 5000}, }, icon = 982, grade = 3, fuli = '1:幫派商店商品打%s折。\n2:每天可以開啟%s小時城主之光', mapID = 4016, iconSign = 7376, iconBattle = 7377, difOpenCost = 10000},
	[10] = {name = '偏洲鎮', cityModel = 2169, signCost = 500, bidLowerPrice = 600, blessAddition = 1000, storeDiscount = 9000, captureReward = {{id = 67498, count = 6}, {id = 67497, count = 50}, {id = 3, count = 5000}, }, icon = 982, grade = 3, fuli = '1:幫派商店商品打%s折。\n2:每天可以開啟%s小時城主之光', mapID = 4017, iconSign = 7376, iconBattle = 7377, difOpenCost = 10000},
};

i3k_db_defenceWar_trans = 
{
	[1] = {line = 1, monster = 0, name = '城池外城'},
	[2] = {line = 1, monster = 0, name = '城池內城'},
	[3] = {line = 2, monster = 0, name = '營地復活點'},
	[4] = {line = 2, monster = 95402, name = ''},
	[5] = {line = 2, monster = 95403, name = ''},
	[6] = {line = 3, monster = 0, name = '營地復活點'},
	[7] = {line = 3, monster = 95408, name = ''},
	[8] = {line = 3, monster = 95409, name = ''},
};

i3k_db_defenceWar_architectureskills = 
{
	[1] = {baseBlood = 0, towerExplain = 0, carExplain = 0},
	[2] = {baseBlood = 0, towerExplain = 500, carExplain = 0},
	[3] = {baseBlood = 0, towerExplain = 1000, carExplain = 0},
	[4] = {baseBlood = 0, towerExplain = 1500, carExplain = 0},
	[5] = {baseBlood = 0, towerExplain = 2000, carExplain = 0},
	[6] = {baseBlood = 0, towerExplain = 2500, carExplain = 0},
	[7] = {baseBlood = 0, towerExplain = 3000, carExplain = 0},
	[8] = {baseBlood = 0, towerExplain = 3500, carExplain = 0},
	[9] = {baseBlood = 0, towerExplain = 4000, carExplain = 0},
	[10] = {baseBlood = 0, towerExplain = 4500, carExplain = 0},
	[11] = {baseBlood = 0, towerExplain = 5000, carExplain = 0},
	[12] = {baseBlood = 0, towerExplain = 5500, carExplain = 0},
	[13] = {baseBlood = 0, towerExplain = 6000, carExplain = 0},
	[14] = {baseBlood = 0, towerExplain = 6500, carExplain = 0},
	[15] = {baseBlood = 0, towerExplain = 7000, carExplain = 0},
	[16] = {baseBlood = 0, towerExplain = 7500, carExplain = 0},
	[17] = {baseBlood = 0, towerExplain = 8000, carExplain = 0},
	[18] = {baseBlood = 0, towerExplain = 8500, carExplain = 0},
	[19] = {baseBlood = 0, towerExplain = 9000, carExplain = 0},
	[20] = {baseBlood = 0, towerExplain = 9500, carExplain = 0},
	[21] = {baseBlood = 0, towerExplain = 10000, carExplain = 0},
	[22] = {baseBlood = 500000, towerExplain = 0, carExplain = 0},
	[23] = {baseBlood = 600000, towerExplain = 0, carExplain = 500},
	[24] = {baseBlood = 700000, towerExplain = 0, carExplain = 1000},
	[25] = {baseBlood = 800000, towerExplain = 0, carExplain = 1500},
	[26] = {baseBlood = 900000, towerExplain = 0, carExplain = 2000},
	[27] = {baseBlood = 1000000, towerExplain = 0, carExplain = 2500},
	[28] = {baseBlood = 1100000, towerExplain = 0, carExplain = 3000},
	[29] = {baseBlood = 1200000, towerExplain = 0, carExplain = 3500},
	[30] = {baseBlood = 1300000, towerExplain = 0, carExplain = 4000},
	[31] = {baseBlood = 1400000, towerExplain = 0, carExplain = 4500},
	[32] = {baseBlood = 1500000, towerExplain = 0, carExplain = 5000},
	[33] = {baseBlood = 1600000, towerExplain = 0, carExplain = 5500},
	[34] = {baseBlood = 1700000, towerExplain = 0, carExplain = 6000},
	[35] = {baseBlood = 1800000, towerExplain = 0, carExplain = 6500},
	[36] = {baseBlood = 1900000, towerExplain = 0, carExplain = 7000},
	[37] = {baseBlood = 2000000, towerExplain = 0, carExplain = 7500},
	[38] = {baseBlood = 2100000, towerExplain = 0, carExplain = 8000},
	[39] = {baseBlood = 2200000, towerExplain = 0, carExplain = 8500},
	[40] = {baseBlood = 2300000, towerExplain = 0, carExplain = 9000},
	[41] = {baseBlood = 2400000, towerExplain = 0, carExplain = 9500},
	[42] = {baseBlood = 2500000, towerExplain = 0, carExplain = 10000},
};

i3k_db_defenceWar_minimap_icons = 
{
	flag = {
		[0] = 7020,
		[1] = 7021,
		[2] = 7022,
		[3] = 7023,
	},
	tower = {
		[0] = 7037,
		[1] = 7038,
		[2] = 7039,
		[3] = 7040,
	},
	reborn = {
		[1] = 7025,
		[2] = 7026,
		[3] = 7027,
	},
	mapList = {
		[1] = {name = '防守传送（蓝方）', imageID = 7006},
		[2] = {name = '进攻传送（红方）', imageID = 7007},
		[3] = {name = '进攻传送（黄方）', imageID = 7008},
		[4] = {name = '防守复活点（蓝方）', imageID = 7025},
		[5] = {name = '进攻复活点（红方）', imageID = 7026},
		[6] = {name = '进攻复活点（黄方）', imageID = 7027},
		[7] = {name = '蓝方占领旗子', imageID = 7021},
		[8] = {name = '红方占领旗子', imageID = 7022},
		[9] = {name = '黄方占领旗子', imageID = 7023},
		[10] = {name = '箭塔', imageID = 7038},
	},
};
