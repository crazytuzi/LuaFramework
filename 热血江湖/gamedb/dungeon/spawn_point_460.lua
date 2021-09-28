----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[92001] = {	id = 92001, pos = { x = 14.59083, y = 13.69155, z = 106.9097 }, randomPos = 1, randomRadius = 700, monsters = { 50111,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92002] = {	id = 92002, pos = { x = -119.9032, y = 19.33274, z = 82.00336 }, randomPos = 1, randomRadius = 700, monsters = { 50111,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92003] = {	id = 92003, pos = { x = -66.16013, y = 13.71193, z = -102.5724 }, randomPos = 1, randomRadius = 700, monsters = { 50111,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92004] = {	id = 92004, pos = { x = 73.39226, y = 13.83806, z = 129.8034 }, randomPos = 1, randomRadius = 700, monsters = { 50112,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92005] = {	id = 92005, pos = { x = -137.7705, y = 14.57993, z = 145.7264 }, randomPos = 1, randomRadius = 700, monsters = { 50112,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92006] = {	id = 92006, pos = { x = 77.30022, y = 19.36755, z = -78.41634 }, randomPos = 1, randomRadius = 700, monsters = { 50112,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92007] = {	id = 92007, pos = { x = 74.54312, y = 13.79198, z = 74.64601 }, randomPos = 1, randomRadius = 700, monsters = { 50113,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92008] = {	id = 92008, pos = { x = -116.3936, y = 13.74303, z = -76.20339 }, randomPos = 1, randomRadius = 700, monsters = { 50113,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92009] = {	id = 92009, pos = { x = 87.66095, y = 14.757, z = -142.5877 }, randomPos = 1, randomRadius = 700, monsters = { 50113,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92010] = {	id = 92010, pos = { x = -188.1513, y = 27.15626, z = 79.81042 }, randomPos = 1, randomRadius = 700, monsters = { 50114,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92011] = {	id = 92011, pos = { x = -117.1419, y = 13.83806, z = -127.3481 }, randomPos = 1, randomRadius = 700, monsters = { 50114,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92012] = {	id = 92012, pos = { x = 143.2227, y = 27.23806, z = -77.18236 }, randomPos = 1, randomRadius = 700, monsters = { 50114,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92013] = {	id = 92013, pos = { x = 90.44385, y = 19.2857, z = -65.00755 }, randomPos = 1, randomRadius = 500, monsters = { 50115,  }, spawnType = 3, spawnDTime = 20000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92014] = {	id = 92014, pos = { x = 85.61058, y = 19.23806, z = -100.129 }, randomPos = 1, randomRadius = 500, monsters = { 50115,  }, spawnType = 3, spawnDTime = 20000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92015] = {	id = 92015, pos = { x = 121.0279, y = 16.7456, z = -133.747 }, randomPos = 1, randomRadius = 500, monsters = { 50115,  }, spawnType = 3, spawnDTime = 20000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92016] = {	id = 92016, pos = { x = 144.4475, y = 14.57413, z = -141.643 }, randomPos = 1, randomRadius = 500, monsters = { 50115,  }, spawnType = 3, spawnDTime = 20000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92017] = {	id = 92017, pos = { x = 15.02812, y = 14.03806, z = -36.2887 }, randomPos = 1, randomRadius = 500, monsters = { 50115,  }, spawnType = 3, spawnDTime = 20000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92018] = {	id = 92018, pos = { x = -55.96702, y = 14.00665, z = -35.57194 }, randomPos = 1, randomRadius = 500, monsters = { 50115,  }, spawnType = 3, spawnDTime = 20000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92019] = {	id = 92019, pos = { x = -63.05105, y = 13.83806, z = 37.41968 }, randomPos = 1, randomRadius = 500, monsters = { 50115,  }, spawnType = 3, spawnDTime = 20000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92020] = {	id = 92020, pos = { x = 18.03196, y = 13.83806, z = 35.18315 }, randomPos = 1, randomRadius = 500, monsters = { 50115,  }, spawnType = 3, spawnDTime = 20000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92021] = {	id = 92021, pos = { x = 102.3237, y = 13.43806, z = 70.75916 }, randomPos = 1, randomRadius = 500, monsters = { 50115,  }, spawnType = 3, spawnDTime = 20000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92022] = {	id = 92022, pos = { x = 105.0625, y = 13.6773, z = 128.804 }, randomPos = 1, randomRadius = 500, monsters = { 50115,  }, spawnType = 3, spawnDTime = 20000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92023] = {	id = 92023, pos = { x = 38.63107, y = 13.58626, z = 108.1077 }, randomPos = 1, randomRadius = 500, monsters = { 50115,  }, spawnType = 3, spawnDTime = 20000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92024] = {	id = 92024, pos = { x = -2.63224, y = 13.77324, z = 123.9054 }, randomPos = 1, randomRadius = 500, monsters = { 50115,  }, spawnType = 3, spawnDTime = 20000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92025] = {	id = 92025, pos = { x = -126.3992, y = 19.23806, z = 106.072 }, randomPos = 1, randomRadius = 500, monsters = { 50115,  }, spawnType = 3, spawnDTime = 20000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92026] = {	id = 92026, pos = { x = -182.219, y = 14.45846, z = 146.4617 }, randomPos = 1, randomRadius = 500, monsters = { 50115,  }, spawnType = 3, spawnDTime = 20000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92027] = {	id = 92027, pos = { x = -185.5707, y = 27.01276, z = 97.05129 }, randomPos = 1, randomRadius = 500, monsters = { 50115,  }, spawnType = 3, spawnDTime = 20000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92028] = {	id = 92028, pos = { x = -132.513, y = 19.23806, z = 62.47282 }, randomPos = 1, randomRadius = 500, monsters = { 50115,  }, spawnType = 3, spawnDTime = 20000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92029] = {	id = 92029, pos = { x = -149.4353, y = 13.44102, z = -68.43977 }, randomPos = 1, randomRadius = 500, monsters = { 50115,  }, spawnType = 3, spawnDTime = 20000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92030] = {	id = 92030, pos = { x = -148.7317, y = 13.63806, z = -130.1521 }, randomPos = 1, randomRadius = 500, monsters = { 50115,  }, spawnType = 3, spawnDTime = 20000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92031] = {	id = 92031, pos = { x = -83.43758, y = 13.81523, z = -111.2636 }, randomPos = 1, randomRadius = 500, monsters = { 50115,  }, spawnType = 3, spawnDTime = 20000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92032] = {	id = 92032, pos = { x = -42.26519, y = 13.75059, z = -119.6141 }, randomPos = 1, randomRadius = 500, monsters = { 50115,  }, spawnType = 3, spawnDTime = 20000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92101] = {	id = 92101, pos = { x = 16.09551, y = 13.67348, z = 114.6534 }, randomPos = 1, randomRadius = 700, monsters = { 50215,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92102] = {	id = 92102, pos = { x = 77.13193, y = 19.25267, z = -90.9522 }, randomPos = 1, randomRadius = 700, monsters = { 50215,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92103] = {	id = 92103, pos = { x = 123.6498, y = 27.23806, z = -76.68491 }, randomPos = 1, randomRadius = 700, monsters = { 50215,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92104] = {	id = 92104, pos = { x = 73.05426, y = 13.83806, z = 129.0787 }, randomPos = 1, randomRadius = 700, monsters = { 50216,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92105] = {	id = 92105, pos = { x = -62.97689, y = 13.71483, z = -115.5921 }, randomPos = 1, randomRadius = 700, monsters = { 50216,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92106] = {	id = 92106, pos = { x = -121.6919, y = 19.36382, z = 77.15813 }, randomPos = 1, randomRadius = 700, monsters = { 50216,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92107] = {	id = 92107, pos = { x = 140.4712, y = 14.49494, z = -144.6662 }, randomPos = 1, randomRadius = 700, monsters = { 50217,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92108] = {	id = 92108, pos = { x = -118.0949, y = 13.83806, z = -125.8699 }, randomPos = 1, randomRadius = 700, monsters = { 50217,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92109] = {	id = 92109, pos = { x = -187.8082, y = 27.02648, z = 98.89175 }, randomPos = 1, randomRadius = 700, monsters = { 50217,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92110] = {	id = 92110, pos = { x = 76.54606, y = 13.82135, z = 73.78779 }, randomPos = 1, randomRadius = 700, monsters = { 50218,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92111] = {	id = 92111, pos = { x = -118.9547, y = 13.68799, z = -72.08458 }, randomPos = 1, randomRadius = 700, monsters = { 50218,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92112] = {	id = 92112, pos = { x = -158.2045, y = 14.43806, z = 147.6133 }, randomPos = 1, randomRadius = 700, monsters = { 50218,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92113] = {	id = 92113, pos = { x = -181.6516, y = 14.46609, z = 145.5022 }, randomPos = 1, randomRadius = 500, monsters = { 50219,  }, spawnType = 3, spawnDTime = 25000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92114] = {	id = 92114, pos = { x = -131.5185, y = 14.63806, z = 145.4519 }, randomPos = 1, randomRadius = 500, monsters = { 50219,  }, spawnType = 3, spawnDTime = 25000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92115] = {	id = 92115, pos = { x = -186.1867, y = 27.14412, z = 78.26025 }, randomPos = 1, randomRadius = 500, monsters = { 50219,  }, spawnType = 3, spawnDTime = 25000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92116] = {	id = 92116, pos = { x = -132.0693, y = 19.23806, z = 99.00955 }, randomPos = 1, randomRadius = 500, monsters = { 50219,  }, spawnType = 3, spawnDTime = 25000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92117] = {	id = 92117, pos = { x = -148.3579, y = 13.44193, z = -67.65547 }, randomPos = 1, randomRadius = 500, monsters = { 50219,  }, spawnType = 3, spawnDTime = 25000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92118] = {	id = 92118, pos = { x = -150.238, y = 13.63806, z = -128.2385 }, randomPos = 1, randomRadius = 500, monsters = { 50219,  }, spawnType = 3, spawnDTime = 25000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92119] = {	id = 92119, pos = { x = -86.071, y = 13.78586, z = -99.71357 }, randomPos = 1, randomRadius = 500, monsters = { 50219,  }, spawnType = 3, spawnDTime = 25000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92120] = {	id = 92120, pos = { x = -43.47185, y = 13.78919, z = -121.7074 }, randomPos = 1, randomRadius = 500, monsters = { 50219,  }, spawnType = 3, spawnDTime = 25000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92121] = {	id = 92121, pos = { x = 99.7576, y = 19.23806, z = -99.95261 }, randomPos = 1, randomRadius = 500, monsters = { 50219,  }, spawnType = 3, spawnDTime = 25000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92122] = {	id = 92122, pos = { x = 88.73369, y = 19.23806, z = -62.41748 }, randomPos = 1, randomRadius = 500, monsters = { 50219,  }, spawnType = 3, spawnDTime = 25000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92123] = {	id = 92123, pos = { x = 143.6657, y = 26.75678, z = -88.94821 }, randomPos = 1, randomRadius = 500, monsters = { 50219,  }, spawnType = 3, spawnDTime = 25000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92124] = {	id = 92124, pos = { x = 92.3018, y = 14.7302, z = -148.7941 }, randomPos = 1, randomRadius = 500, monsters = { 50219,  }, spawnType = 3, spawnDTime = 25000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92125] = {	id = 92125, pos = { x = 39.09684, y = 13.65142, z = 110.7969 }, randomPos = 1, randomRadius = 500, monsters = { 50219,  }, spawnType = 3, spawnDTime = 25000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92126] = {	id = 92126, pos = { x = -2.627794, y = 13.80824, z = 125.9982 }, randomPos = 1, randomRadius = 500, monsters = { 50219,  }, spawnType = 3, spawnDTime = 25000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92127] = {	id = 92127, pos = { x = 103.8093, y = 13.43806, z = 71.14011 }, randomPos = 1, randomRadius = 500, monsters = { 50219,  }, spawnType = 3, spawnDTime = 25000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92128] = {	id = 92128, pos = { x = 105.5332, y = 13.68901, z = 127.8947 }, randomPos = 1, randomRadius = 500, monsters = { 50219,  }, spawnType = 3, spawnDTime = 25000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92129] = {	id = 92129, pos = { x = 22.41705, y = 13.83806, z = 42.05211 }, randomPos = 1, randomRadius = 500, monsters = { 50219,  }, spawnType = 3, spawnDTime = 25000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92130] = {	id = 92130, pos = { x = 18.46214, y = 13.99047, z = -36.47338 }, randomPos = 1, randomRadius = 500, monsters = { 50219,  }, spawnType = 3, spawnDTime = 25000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92131] = {	id = 92131, pos = { x = -55.395, y = 13.95535, z = -39.9086 }, randomPos = 1, randomRadius = 500, monsters = { 50219,  }, spawnType = 3, spawnDTime = 25000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92132] = {	id = 92132, pos = { x = -87.28539, y = 13.91569, z = 46.01235 }, randomPos = 1, randomRadius = 500, monsters = { 50219,  }, spawnType = 3, spawnDTime = 25000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92133] = {	id = 92133, pos = { x = -205.4888, y = 27.10582, z = 78.84857 }, randomPos = 1, randomRadius = 500, monsters = { 50220,  }, spawnType = 3, spawnDTime = 120000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92134] = {	id = 92134, pos = { x = -118.1378, y = 13.63806, z = -99.52196 }, randomPos = 1, randomRadius = 500, monsters = { 50220,  }, spawnType = 3, spawnDTime = 120000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92135] = {	id = 92135, pos = { x = 159.8031, y = 27.23806, z = -76.76149 }, randomPos = 1, randomRadius = 500, monsters = { 50220,  }, spawnType = 3, spawnDTime = 120000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92136] = {	id = 92136, pos = { x = 73.37891, y = 13.5227, z = 101.0011 }, randomPos = 1, randomRadius = 500, monsters = { 50220,  }, spawnType = 3, spawnDTime = 120000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92137] = {	id = 92137, pos = { x = 22.47307, y = 13.59042, z = 80.55212 }, randomPos = 1, randomRadius = 500, monsters = { 50221,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92138] = {	id = 92138, pos = { x = -23.26423, y = 21.43806, z = 0.4530258 }, randomPos = 1, randomRadius = 500, monsters = { 50221,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92139] = {	id = 92139, pos = { x = 120.4507, y = 16.80107, z = -135.2234 }, randomPos = 1, randomRadius = 500, monsters = { 50221,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92140] = {	id = 92140, pos = { x = 64.60084, y = 13.7231, z = -42.49988 }, randomPos = 1, randomRadius = 500, monsters = { 50221,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
