----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[21901] = {	id = 21901, pos = { x = -136.925461, y = 19.1577663, z = -3.89237046 }, randomPos = 1, randomRadius = 600, monsters = { 89191,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[21902] = {	id = 21902, pos = { x = -113.9515, y = 19.02833, z = -3.582018 }, randomPos = 1, randomRadius = 300, monsters = { 89192,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[21903] = {	id = 21903, pos = { x = -99.82172, y = 17.78062, z = -17.53477 }, randomPos = 1, randomRadius = 600, monsters = { 89193,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[21904] = {	id = 21904, pos = { x = -91.31078, y = 14.91813, z = -31.57063 }, randomPos = 1, randomRadius = 600, monsters = { 89194,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[21905] = {	id = 21905, pos = { x = -54.59631, y = 14.72098, z = -62.44442 }, randomPos = 1, randomRadius = 600, monsters = { 89195,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[21906] = {	id = 21906, pos = { x = -22.45517, y = 14.82833, z = -58.54503 }, randomPos = 1, randomRadius = 600, monsters = { 89196,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
