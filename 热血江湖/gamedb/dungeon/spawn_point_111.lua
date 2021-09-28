----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[22201] = {	id = 22201, pos = { x = 83.98619, y = 15.01499, z = 0.0892448 }, randomPos = 1, randomRadius = 600, monsters = { 89221,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22202] = {	id = 22202, pos = { x = 106.5012, y = 7.294509, z = -58.71569 }, randomPos = 1, randomRadius = 600, monsters = { 89222,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22203] = {	id = 22203, pos = { x = 92.04003, y = 7.294509, z = -66.2343 }, randomPos = 0, randomRadius = 0, monsters = { 89223,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22301] = {	id = 22301, pos = { x = -71.13884, y = 8.172829, z = 116.1397 }, randomPos = 1, randomRadius = 600, monsters = { 89231,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22302] = {	id = 22302, pos = { x = -16.9488, y = 8.372826, z = 65.46329 }, randomPos = 1, randomRadius = 600, monsters = { 89232,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22303] = {	id = 22303, pos = { x = -60.32456, y = 5.372826, z = 8.495521 }, randomPos = 1, randomRadius = 600, monsters = { 89233,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22304] = {	id = 22304, pos = { x = -132.8039, y = 3.167206, z = 7.551202 }, randomPos = 0, randomRadius = 0, monsters = { 89234,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
