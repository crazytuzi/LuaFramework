----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[911001] = {	id = 911001, pos = { x = -101.384773, y = 17.3685169, z = 109.741043 }, randomPos = 0, randomRadius = 500, monsters = { 301001,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911002] = {	id = 911002, pos = { x = -149.22, y = 4.11368465, z = -85.03379 }, randomPos = 0, randomRadius = 500, monsters = { 301002,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911003] = {	id = 911003, pos = { x = 71.27869, y = 3.16384315, z = -135.027924 }, randomPos = 0, randomRadius = 500, monsters = { 301003,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911004] = {	id = 911004, pos = { x = 75.4961243, y = 3.927905, z = 87.2176056 }, randomPos = 0, randomRadius = 500, monsters = { 301004,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911005] = {	id = 911005, pos = { x = 11.5344086, y = 3.155068, z = 72.1788 }, randomPos = 0, randomRadius = 500, monsters = { 301005,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911006] = {	id = 911006, pos = { x = 39.4236946, y = -9.234032, z = -36.7133331 }, randomPos = 0, randomRadius = 500, monsters = { 301006,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911007] = {	id = 911007, pos = { x = -55.9162064, y = 4.076365, z = -163.682816 }, randomPos = 0, randomRadius = 500, monsters = { 301007,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911008] = {	id = 911008, pos = { x = -99.59375, y = 3.16384315, z = 20.4592152 }, randomPos = 0, randomRadius = 500, monsters = { 301008,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911009] = {	id = 911009, pos = { x = -89.01487, y = 11.1872864, z = 101.473572 }, randomPos = 0, randomRadius = 500, monsters = { 301009,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911010] = {	id = 911010, pos = { x = -29.2726631, y = 9.187286, z = 124.75647 }, randomPos = 0, randomRadius = 500, monsters = { 301010,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911011] = {	id = 911011, pos = { x = 33.68907, y = 9.187286, z = 81.6028442 }, randomPos = 0, randomRadius = 500, monsters = { 301011,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911012] = {	id = 911012, pos = { x = 67.9577942, y = 7.18727827, z = 61.005928 }, randomPos = 0, randomRadius = 500, monsters = { 301012,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911013] = {	id = 911013, pos = { x = 4.536003, y = 6.18727875, z = -16.1728439 }, randomPos = 0, randomRadius = 500, monsters = { 301013,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911014] = {	id = 911014, pos = { x = 26.3724747, y = 1.18727875, z = -68.23922 }, randomPos = 0, randomRadius = 500, monsters = { 301014,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911015] = {	id = 911015, pos = { x = -102.916733, y = 8.187279, z = -14.916317 }, randomPos = 0, randomRadius = 500, monsters = { 301015,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911016] = {	id = 911016, pos = { x = -57.39499, y = 8.187279, z = 50.6538773 }, randomPos = 0, randomRadius = 500, monsters = { 301016,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911017] = {	id = 911017, pos = { x = 112.2015, y = 12.0820236, z = -13.863019 }, randomPos = 0, randomRadius = 500, monsters = { 301017,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911018] = {	id = 911018, pos = { x = -60.01852, y = -1.46601737, z = -178.907623 }, randomPos = 0, randomRadius = 500, monsters = { 301018,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911019] = {	id = 911019, pos = { x = -60.31963, y = 0.0820236, z = -118.124847 }, randomPos = 0, randomRadius = 500, monsters = { 301019,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911020] = {	id = 911020, pos = { x = 38.36272, y = 17.0820236, z = 81.25824 }, randomPos = 0, randomRadius = 500, monsters = { 301020,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911021] = {	id = 911021, pos = { x = -44.0183334, y = 17.0820236, z = 62.755455 }, randomPos = 0, randomRadius = 500, monsters = { 301021,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911022] = {	id = 911022, pos = { x = 15.9568892, y = 17.0820236, z = 162.8648 }, randomPos = 0, randomRadius = 500, monsters = { 301022,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911023] = {	id = 911023, pos = { x = 55.0579758, y = 12.0820236, z = 23.2015781 }, randomPos = 0, randomRadius = 500, monsters = { 301023,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911024] = {	id = 911024, pos = { x = 52.4970627, y = 10.0820236, z = -56.55552 }, randomPos = 0, randomRadius = 500, monsters = { 301024,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911025] = {	id = 911025, pos = { x = 8.921643, y = 11.2608643, z = 99.64482 }, randomPos = 0, randomRadius = 500, monsters = { 301025,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911026] = {	id = 911026, pos = { x = 122.907043, y = 0.6628423, z = 58.7301064 }, randomPos = 0, randomRadius = 500, monsters = { 301026,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911027] = {	id = 911027, pos = { x = 171.037537, y = -6.339142, z = -93.57309 }, randomPos = 0, randomRadius = 500, monsters = { 301027,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911028] = {	id = 911028, pos = { x = 151.352112, y = 0.6608609, z = 35.2247467 }, randomPos = 0, randomRadius = 500, monsters = { 301028,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911029] = {	id = 911029, pos = { x = -37.69867, y = -3.79388952, z = -113.214134 }, randomPos = 0, randomRadius = 500, monsters = { 301029,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911030] = {	id = 911030, pos = { x = -15.8990812, y = -2.94951344, z = -40.3167458 }, randomPos = 0, randomRadius = 500, monsters = { 301030,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911031] = {	id = 911031, pos = { x = -19.9585075, y = 12.6608582, z = 23.0378265 }, randomPos = 0, randomRadius = 500, monsters = { 301031,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911032] = {	id = 911032, pos = { x = 46.04559, y = -7.777195, z = -62.4948235 }, randomPos = 0, randomRadius = 500, monsters = { 301032,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911033] = {	id = 911033, pos = { x = -116.579582, y = 5.25521564, z = -48.3611145 }, randomPos = 0, randomRadius = 500, monsters = { 301033,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911034] = {	id = 911034, pos = { x = -91.3236542, y = 15.1046066, z = -147.07724 }, randomPos = 0, randomRadius = 500, monsters = { 301034,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911035] = {	id = 911035, pos = { x = 10.9876709, y = 5.19361, z = -125.748131 }, randomPos = 0, randomRadius = 500, monsters = { 301035,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911036] = {	id = 911036, pos = { x = 106.189758, y = 0.1046066, z = -169.65329 }, randomPos = 0, randomRadius = 500, monsters = { 301036,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911037] = {	id = 911037, pos = { x = 86.44093, y = 10.3715572, z = -54.47197 }, randomPos = 0, randomRadius = 500, monsters = { 301037,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911038] = {	id = 911038, pos = { x = 124.89357, y = 30.1046085, z = 98.57005 }, randomPos = 0, randomRadius = 500, monsters = { 301038,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911039] = {	id = 911039, pos = { x = -33.625145, y = 2.23323464, z = 133.538513 }, randomPos = 0, randomRadius = 500, monsters = { 301039,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911040] = {	id = 911040, pos = { x = 27.1074142, y = 10.1620245, z = -7.597122 }, randomPos = 0, randomRadius = 500, monsters = { 301040,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911101] = {	id = 911101, pos = { x = 140.6361, y = 0.1638422, z = -35.68009 }, randomPos = 0, randomRadius = 500, monsters = { 311001,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911102] = {	id = 911102, pos = { x = -22.6297379, y = 9.187286, z = 44.7644119 }, randomPos = 0, randomRadius = 500, monsters = { 311002,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911103] = {	id = 911103, pos = { x = 165.519623, y = 26.0820236, z = 64.54193 }, randomPos = 0, randomRadius = 500, monsters = { 311003,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911104] = {	id = 911104, pos = { x = 33.5189819, y = -8.924781, z = -103.189522 }, randomPos = 0, randomRadius = 500, monsters = { 311004,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[911105] = {	id = 911105, pos = { x = -152.384689, y = 18.1046066, z = 121.036278 }, randomPos = 0, randomRadius = 500, monsters = { 311005,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
