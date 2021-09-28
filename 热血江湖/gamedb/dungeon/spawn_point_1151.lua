----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[230201] = {	id = 230201, pos = { x = 65.87302, y = 2.005699, z = 1.946255 }, randomPos = 0, randomRadius = 0, monsters = { 90122,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[230202] = {	id = 230202, pos = { x = 67.91106, y = 2.005699, z = 1.621372 }, randomPos = 0, randomRadius = 0, monsters = { 90122,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[230203] = {	id = 230203, pos = { x = 69.8623, y = 2.005699, z = 0.853878 }, randomPos = 0, randomRadius = 0, monsters = { 90120,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[230204] = {	id = 230204, pos = { x = 71.08931, y = 2.005699, z = 0.9998436 }, randomPos = 0, randomRadius = 0, monsters = { 90120,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[230205] = {	id = 230205, pos = { x = 72.36577, y = 2.005699, z = 0.8050461 }, randomPos = 0, randomRadius = 0, monsters = { 90120,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[230206] = {	id = 230206, pos = { x = 73.03558, y = 2.005699, z = 0.2580223 }, randomPos = 0, randomRadius = 0, monsters = { 90120,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[230301] = {	id = 230301, pos = { x = 80.04729, y = 2.207795, z = 39.84054 }, randomPos = 0, randomRadius = 0, monsters = { 90120,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[230302] = {	id = 230302, pos = { x = 78.40523, y = 2.2057, z = 39.29352 }, randomPos = 0, randomRadius = 0, monsters = { 90120,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[230303] = {	id = 230303, pos = { x = 76.8578, y = 2.2057, z = 38.74649 }, randomPos = 0, randomRadius = 0, monsters = { 90121,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[230304] = {	id = 230304, pos = { x = 81.0528, y = 2.205702, z = 39.99996 }, randomPos = 0, randomRadius = 0, monsters = { 90121,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[230305] = {	id = 230305, pos = { x = 81.0528, y = 2.217669, z = 40.26906 }, randomPos = 0, randomRadius = 0, monsters = { 90121,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[230306] = {	id = 230306, pos = { x = 82.49013, y = 2.210732, z = 40.11312 }, randomPos = 0, randomRadius = 0, monsters = { 90121,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
