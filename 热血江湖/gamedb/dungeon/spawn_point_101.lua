----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[20201] = {	id = 20201, pos = { x = 61.89171, y = 2.405701, z = 96.10349 }, randomPos = 1, randomRadius = 400, monsters = { 89021,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20202] = {	id = 20202, pos = { x = 62.9068, y = 2.2057, z = 51.65958 }, randomPos = 1, randomRadius = 600, monsters = { 89022,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20203] = {	id = 20203, pos = { x = 80.31969, y = 2.2057, z = 39.11715 }, randomPos = 1, randomRadius = 600, monsters = { 89023,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20204] = {	id = 20204, pos = { x = 70.43875, y = 2.005699, z = -5.777278 }, randomPos = 0, randomRadius = 0, monsters = { 89024,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20301] = {	id = 20301, pos = { x = 91.75652, y = 9.636188, z = -15.5294 }, randomPos = 1, randomRadius = 600, monsters = { 89031,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20302] = {	id = 20302, pos = { x = 105.5752, y = 9.436705, z = -4.843443 }, randomPos = 1, randomRadius = 600, monsters = { 89032,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20303] = {	id = 20303, pos = { x = 92.75913, y = 9.449107, z = 8.979904 }, randomPos = 0, randomRadius = 0, monsters = { 89033,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20304] = {	id = 20304, pos = { x = 35.52542, y = 9.436188, z = -1.775312 }, randomPos = 1, randomRadius = 600, monsters = { 89034,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20305] = {	id = 20305, pos = { x = 0.1167888, y = 3.036194, z = -56.53671 }, randomPos = 0, randomRadius = 0, monsters = { 89035,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20306] = {	id = 20306, pos = { x = -26.65626, y = 3.03929, z = -86.52122 }, randomPos = 0, randomRadius = 0, monsters = { 89037,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20307] = {	id = 20307, pos = { x = -21.1609, y = 3.036194, z = -64.7606 }, randomPos = 1, randomRadius = 600, monsters = { 89039,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
