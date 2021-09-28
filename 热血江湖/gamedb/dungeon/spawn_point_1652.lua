----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[330401] = {	id = 330401, pos = { x = 23.27241, y = 0.2154727, z = 66.55182 }, randomPos = 0, randomRadius = 0, monsters = { 90301,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[330402] = {	id = 330402, pos = { x = 25.6721, y = 0.1588616, z = 64.0 }, randomPos = 0, randomRadius = 0, monsters = { 90301,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[330403] = {	id = 330403, pos = { x = 25.10037, y = 0.3153867, z = 72.94555 }, randomPos = 0, randomRadius = 0, monsters = { 90303,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[330404] = {	id = 330404, pos = { x = 28.96569, y = 0.2310614, z = 68.33876 }, randomPos = 0, randomRadius = 0, monsters = { 90303,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[330501] = {	id = 330501, pos = { x = 26.91828, y = 0.1588621, z = 67.04856 }, randomPos = 0, randomRadius = 0, monsters = { 90301,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[330502] = {	id = 330502, pos = { x = 26.31058, y = 0.236398, z = 72.79086 }, randomPos = 0, randomRadius = 0, monsters = { 90301,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[330503] = {	id = 330503, pos = { x = 31.44744, y = 0.1651794, z = 64.80525 }, randomPos = 0, randomRadius = 0, monsters = { 90302,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[330504] = {	id = 330504, pos = { x = 30.92056, y = 0.1886398, z = 67.67715 }, randomPos = 0, randomRadius = 0, monsters = { 90302,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[330505] = {	id = 330505, pos = { x = 29.91344, y = 0.2164222, z = 69.2067 }, randomPos = 0, randomRadius = 0, monsters = { 90304,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
