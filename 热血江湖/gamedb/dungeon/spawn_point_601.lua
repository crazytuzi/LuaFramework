----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[120201] = {	id = 120201, pos = { x = 61.89171, y = 2.405701, z = 96.10349 }, randomPos = 1, randomRadius = 400, monsters = { 160006,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[120202] = {	id = 120202, pos = { x = 62.9068, y = 2.2057, z = 51.65958 }, randomPos = 1, randomRadius = 600, monsters = { 160007,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[120203] = {	id = 120203, pos = { x = 80.31969, y = 2.2057, z = 39.11715 }, randomPos = 1, randomRadius = 600, monsters = { 160008,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[120204] = {	id = 120204, pos = { x = 70.43875, y = 2.005699, z = -5.777278 }, randomPos = 0, randomRadius = 0, monsters = { 160009,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[120301] = {	id = 120301, pos = { x = 91.75652, y = 9.636188, z = -15.5294 }, randomPos = 1, randomRadius = 600, monsters = { 160010,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[120302] = {	id = 120302, pos = { x = 105.5752, y = 9.436705, z = -4.843443 }, randomPos = 1, randomRadius = 600, monsters = { 160011,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[120303] = {	id = 120303, pos = { x = 92.75913, y = 9.449107, z = 8.979904 }, randomPos = 0, randomRadius = 0, monsters = { 160012,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[120304] = {	id = 120304, pos = { x = 35.52542, y = 9.436188, z = -1.775312 }, randomPos = 1, randomRadius = 600, monsters = { 160013,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[120305] = {	id = 120305, pos = { x = 0.1167888, y = 3.036194, z = -56.53671 }, randomPos = 0, randomRadius = 0, monsters = { 160014,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[120306] = {	id = 120306, pos = { x = -26.65626, y = 3.03929, z = -86.52122 }, randomPos = 0, randomRadius = 0, monsters = { 160015,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[120307] = {	id = 120307, pos = { x = -21.1609, y = 3.036194, z = -64.7606 }, randomPos = 1, randomRadius = 600, monsters = { 160016,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
