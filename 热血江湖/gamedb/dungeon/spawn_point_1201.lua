----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[240201] = {	id = 240201, pos = { x = 64.89324, y = 2.005699, z = -0.8151455 }, randomPos = 0, randomRadius = 0, monsters = { 90132,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[240202] = {	id = 240202, pos = { x = 66.44243, y = 2.005699, z = -1.087597 }, randomPos = 0, randomRadius = 0, monsters = { 90132,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[240203] = {	id = 240203, pos = { x = 67.34135, y = 2.005699, z = -1.643984 }, randomPos = 0, randomRadius = 0, monsters = { 90132,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[240204] = {	id = 240204, pos = { x = 68.47528, y = 2.005699, z = -1.758387 }, randomPos = 0, randomRadius = 0, monsters = { 90132,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[240205] = {	id = 240205, pos = { x = 69.57784, y = 2.005699, z = -1.646473 }, randomPos = 0, randomRadius = 0, monsters = { 90130,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[240206] = {	id = 240206, pos = { x = 70.62269, y = 2.005699, z = -1.833708 }, randomPos = 0, randomRadius = 0, monsters = { 90130,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[240207] = {	id = 240207, pos = { x = 71.31122, y = 2.005699, z = -2.312258 }, randomPos = 0, randomRadius = 0, monsters = { 90130,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[240208] = {	id = 240208, pos = { x = 72.17791, y = 2.005699, z = -2.645159 }, randomPos = 0, randomRadius = 0, monsters = { 90130,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[240301] = {	id = 240301, pos = { x = 73.96323, y = 2.2057, z = 41.55764 }, randomPos = 0, randomRadius = 0, monsters = { 90130,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[240302] = {	id = 240302, pos = { x = 74.85178, y = 2.2057, z = 41.01062 }, randomPos = 0, randomRadius = 0, monsters = { 90130,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[240303] = {	id = 240303, pos = { x = 75.58704, y = 2.2057, z = 42.35286 }, randomPos = 0, randomRadius = 0, monsters = { 90130,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[240304] = {	id = 240304, pos = { x = 77.29387, y = 2.2057, z = 40.96935 }, randomPos = 0, randomRadius = 0, monsters = { 90130,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[240305] = {	id = 240305, pos = { x = 77.9376, y = 2.2057, z = 42.23676 }, randomPos = 0, randomRadius = 0, monsters = { 90131,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[240306] = {	id = 240306, pos = { x = 79.4379, y = 2.2057, z = 43.15551 }, randomPos = 0, randomRadius = 0, monsters = { 90131,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[240307] = {	id = 240307, pos = { x = 80.64735, y = 2.227242, z = 42.57487 }, randomPos = 0, randomRadius = 0, monsters = { 90131,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[240308] = {	id = 240308, pos = { x = 82.08468, y = 2.275072, z = 42.2348 }, randomPos = 0, randomRadius = 0, monsters = { 90131,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
