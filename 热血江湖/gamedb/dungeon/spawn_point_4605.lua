----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[921001] = {	id = 921001, pos = { x = -101.384773, y = 17.3685169, z = 109.741043 }, randomPos = 0, randomRadius = 500, monsters = { 302001,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921002] = {	id = 921002, pos = { x = -149.22, y = 4.11368465, z = -85.03379 }, randomPos = 0, randomRadius = 500, monsters = { 302002,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921003] = {	id = 921003, pos = { x = 71.27869, y = 3.16384315, z = -135.027924 }, randomPos = 0, randomRadius = 500, monsters = { 302003,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921004] = {	id = 921004, pos = { x = 75.4961243, y = 3.927905, z = 87.2176056 }, randomPos = 0, randomRadius = 500, monsters = { 302004,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921005] = {	id = 921005, pos = { x = 11.5344086, y = 3.155068, z = 72.1788 }, randomPos = 0, randomRadius = 500, monsters = { 302005,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921006] = {	id = 921006, pos = { x = 39.4236946, y = -9.234032, z = -36.7133331 }, randomPos = 0, randomRadius = 500, monsters = { 302006,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921007] = {	id = 921007, pos = { x = -55.9162064, y = 4.076365, z = -163.682816 }, randomPos = 0, randomRadius = 500, monsters = { 302007,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921008] = {	id = 921008, pos = { x = -99.59375, y = 3.16384315, z = 20.4592152 }, randomPos = 0, randomRadius = 500, monsters = { 302008,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921009] = {	id = 921009, pos = { x = -89.01487, y = 11.1872864, z = 101.473572 }, randomPos = 0, randomRadius = 500, monsters = { 302009,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921010] = {	id = 921010, pos = { x = -29.2726631, y = 9.187286, z = 124.75647 }, randomPos = 0, randomRadius = 500, monsters = { 302010,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921011] = {	id = 921011, pos = { x = 33.68907, y = 9.187286, z = 81.6028442 }, randomPos = 0, randomRadius = 500, monsters = { 302011,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921012] = {	id = 921012, pos = { x = 67.9577942, y = 7.18727827, z = 61.005928 }, randomPos = 0, randomRadius = 500, monsters = { 302012,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921013] = {	id = 921013, pos = { x = 4.536003, y = 6.18727875, z = -16.1728439 }, randomPos = 0, randomRadius = 500, monsters = { 302013,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921014] = {	id = 921014, pos = { x = 26.3724747, y = 1.18727875, z = -68.23922 }, randomPos = 0, randomRadius = 500, monsters = { 302014,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921015] = {	id = 921015, pos = { x = -102.916733, y = 8.187279, z = -14.916317 }, randomPos = 0, randomRadius = 500, monsters = { 302015,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921016] = {	id = 921016, pos = { x = -57.39499, y = 8.187279, z = 50.6538773 }, randomPos = 0, randomRadius = 500, monsters = { 302016,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921017] = {	id = 921017, pos = { x = 112.2015, y = 12.0820236, z = -13.863019 }, randomPos = 0, randomRadius = 500, monsters = { 302017,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921018] = {	id = 921018, pos = { x = -60.01852, y = -1.46601737, z = -178.907623 }, randomPos = 0, randomRadius = 500, monsters = { 302018,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921019] = {	id = 921019, pos = { x = -60.31963, y = 0.0820236, z = -118.124847 }, randomPos = 0, randomRadius = 500, monsters = { 302019,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921020] = {	id = 921020, pos = { x = 38.36272, y = 17.0820236, z = 81.25824 }, randomPos = 0, randomRadius = 500, monsters = { 302020,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921021] = {	id = 921021, pos = { x = -44.0183334, y = 17.0820236, z = 62.755455 }, randomPos = 0, randomRadius = 500, monsters = { 302021,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921022] = {	id = 921022, pos = { x = 15.9568892, y = 17.0820236, z = 162.8648 }, randomPos = 0, randomRadius = 500, monsters = { 302022,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921023] = {	id = 921023, pos = { x = 55.0579758, y = 12.0820236, z = 23.2015781 }, randomPos = 0, randomRadius = 500, monsters = { 302023,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921024] = {	id = 921024, pos = { x = 52.4970627, y = 10.0820236, z = -56.55552 }, randomPos = 0, randomRadius = 500, monsters = { 302024,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921025] = {	id = 921025, pos = { x = 8.921643, y = 11.2608643, z = 99.64482 }, randomPos = 0, randomRadius = 500, monsters = { 302025,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921026] = {	id = 921026, pos = { x = 122.907043, y = 0.6628423, z = 58.7301064 }, randomPos = 0, randomRadius = 500, monsters = { 302026,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921027] = {	id = 921027, pos = { x = 171.037537, y = -6.339142, z = -93.57309 }, randomPos = 0, randomRadius = 500, monsters = { 302027,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921028] = {	id = 921028, pos = { x = 151.352112, y = 0.6608609, z = 35.2247467 }, randomPos = 0, randomRadius = 500, monsters = { 302028,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921029] = {	id = 921029, pos = { x = -37.69867, y = -3.79388952, z = -113.214134 }, randomPos = 0, randomRadius = 500, monsters = { 302029,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921030] = {	id = 921030, pos = { x = -15.8990812, y = -2.94951344, z = -40.3167458 }, randomPos = 0, randomRadius = 500, monsters = { 302030,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921031] = {	id = 921031, pos = { x = -19.9585075, y = 12.6608582, z = 23.0378265 }, randomPos = 0, randomRadius = 500, monsters = { 302031,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921032] = {	id = 921032, pos = { x = 46.04559, y = -7.777195, z = -62.4948235 }, randomPos = 0, randomRadius = 500, monsters = { 302032,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921033] = {	id = 921033, pos = { x = -116.579582, y = 5.25521564, z = -48.3611145 }, randomPos = 0, randomRadius = 500, monsters = { 302033,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921034] = {	id = 921034, pos = { x = -91.3236542, y = 15.1046066, z = -147.07724 }, randomPos = 0, randomRadius = 500, monsters = { 302034,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921035] = {	id = 921035, pos = { x = 10.9876709, y = 5.19361, z = -125.748131 }, randomPos = 0, randomRadius = 500, monsters = { 302035,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921036] = {	id = 921036, pos = { x = 106.189758, y = 0.1046066, z = -169.65329 }, randomPos = 0, randomRadius = 500, monsters = { 302036,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921037] = {	id = 921037, pos = { x = 86.44093, y = 10.3715572, z = -54.47197 }, randomPos = 0, randomRadius = 500, monsters = { 302037,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921038] = {	id = 921038, pos = { x = 124.89357, y = 30.1046085, z = 98.57005 }, randomPos = 0, randomRadius = 500, monsters = { 302038,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921039] = {	id = 921039, pos = { x = -33.625145, y = 2.23323464, z = 133.538513 }, randomPos = 0, randomRadius = 500, monsters = { 302039,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921040] = {	id = 921040, pos = { x = 27.1074142, y = 10.1620245, z = -7.597122 }, randomPos = 0, randomRadius = 500, monsters = { 302040,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921101] = {	id = 921101, pos = { x = 140.6361, y = 0.1638422, z = -35.68009 }, randomPos = 0, randomRadius = 500, monsters = { 312001,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921102] = {	id = 921102, pos = { x = -22.6297379, y = 9.187286, z = 44.7644119 }, randomPos = 0, randomRadius = 500, monsters = { 312002,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921103] = {	id = 921103, pos = { x = 165.519623, y = 26.0820236, z = 64.54193 }, randomPos = 0, randomRadius = 500, monsters = { 312003,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921104] = {	id = 921104, pos = { x = 33.5189819, y = -8.924781, z = -103.189522 }, randomPos = 0, randomRadius = 500, monsters = { 312004,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[921105] = {	id = 921105, pos = { x = -152.384689, y = 18.1046066, z = 121.036278 }, randomPos = 0, randomRadius = 500, monsters = { 312005,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
