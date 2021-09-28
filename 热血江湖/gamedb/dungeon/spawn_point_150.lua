----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[30001] = {	id = 30001, pos = { x = 7.414117, y = 6.009643, z = -20.32537 }, randomPos = 1, randomRadius = 350, monsters = { 99611,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30002] = {	id = 30002, pos = { x = -2.735022, y = 6.26349, z = 19.80149 }, randomPos = 1, randomRadius = 350, monsters = { 99611,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30003] = {	id = 30003, pos = { x = -4.545881, y = 5.994563, z = -19.7935 }, randomPos = 1, randomRadius = 350, monsters = { 99611,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30004] = {	id = 30004, pos = { x = 15.40896, y = 6.111522, z = -7.901615 }, randomPos = 1, randomRadius = 350, monsters = { 99611,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30005] = {	id = 30005, pos = { x = 6.02914, y = 6.267793, z = 5.291309 }, randomPos = 1, randomRadius = 350, monsters = { 99611,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30006] = {	id = 30006, pos = { x = -11.90774, y = 6.036408, z = -8.916822 }, randomPos = 1, randomRadius = 350, monsters = { 99612,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30007] = {	id = 30007, pos = { x = 19.84462, y = 6.075055, z = 8.877287 }, randomPos = 1, randomRadius = 350, monsters = { 99612,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30008] = {	id = 30008, pos = { x = -13.63867, y = 6.149318, z = 16.38881 }, randomPos = 1, randomRadius = 350, monsters = { 99612,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30009] = {	id = 30009, pos = { x = -9.021922, y = -3.6347, z = 16.50992 }, randomPos = 1, randomRadius = 350, monsters = { 99612,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30010] = {	id = 30010, pos = { x = -2.646801, y = 6.297496, z = -1.870655 }, randomPos = 1, randomRadius = 350, monsters = { 99612,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30011] = {	id = 30011, pos = { x = -15.46105, y = 6.106462, z = 2.118895 }, randomPos = 1, randomRadius = 350, monsters = { 99613,  }, spawnType = 3, spawnDTime = 900000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30012] = {	id = 30012, pos = { x = 25.50716, y = 6.030071, z = -2.924055 }, randomPos = 1, randomRadius = 350, monsters = { 99614,  }, spawnType = 3, spawnDTime = 900000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30101] = {	id = 30101, pos = { x = -3.929352, y = 11.34099, z = -87.74131 }, randomPos = 1, randomRadius = 200, monsters = { 99621,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30102] = {	id = 30102, pos = { x = 12.37713, y = 11.34099, z = -83.32693 }, randomPos = 1, randomRadius = 200, monsters = { 99621,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30103] = {	id = 30103, pos = { x = -38.63227, y = 11.34099, z = -73.61398 }, randomPos = 1, randomRadius = 200, monsters = { 99621,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30104] = {	id = 30104, pos = { x = -21.96428, y = 5.628606, z = -80.15163 }, randomPos = 1, randomRadius = 200, monsters = { 99621,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30105] = {	id = 30105, pos = { x = -1.643135, y = 11.34099, z = -75.6487 }, randomPos = 1, randomRadius = 200, monsters = { 99621,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30106] = {	id = 30106, pos = { x = 17.34699, y = 13.34099, z = -9.35951 }, randomPos = 1, randomRadius = 200, monsters = { 99622,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30107] = {	id = 30107, pos = { x = 39.1141, y = 13.84099, z = -13.72151 }, randomPos = 1, randomRadius = 200, monsters = { 99622,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30108] = {	id = 30108, pos = { x = -14.63442, y = 9.340994, z = -46.09057 }, randomPos = 1, randomRadius = 200, monsters = { 99622,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30109] = {	id = 30109, pos = { x = 29.31805, y = 13.55653, z = -12.88287 }, randomPos = 1, randomRadius = 200, monsters = { 99622,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30110] = {	id = 30110, pos = { x = -11.65226, y = 9.340994, z = -56.58808 }, randomPos = 1, randomRadius = 200, monsters = { 99622,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30111] = {	id = 30111, pos = { x = 29.92185, y = 13.79823, z = -4.036589 }, randomPos = 0, randomRadius = 100, monsters = { 99623,  }, spawnType = 3, spawnDTime = 900000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30112] = {	id = 30112, pos = { x = 7.29026, y = 11.34099, z = -74.59383 }, randomPos = 0, randomRadius = 100, monsters = { 99624,  }, spawnType = 3, spawnDTime = 900000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
