----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[220201] = {	id = 220201, pos = { x = 68.46693, y = 1.951529, z = -2.803144 }, randomPos = 0, randomRadius = 0, monsters = { 90113,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[220202] = {	id = 220202, pos = { x = 75.63985, y = 1.951529, z = -4.853745 }, randomPos = 0, randomRadius = 0, monsters = { 90113,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[220203] = {	id = 220203, pos = { x = 67.85736, y = 1.951529, z = -5.698006 }, randomPos = 0, randomRadius = 0, monsters = { 90111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[220204] = {	id = 220204, pos = { x = 73.57954, y = 1.951529, z = -8.148172 }, randomPos = 0, randomRadius = 0, monsters = { 90111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[220301] = {	id = 220301, pos = { x = 78.33198, y = 2.383992, z = 37.39223 }, randomPos = 0, randomRadius = 0, monsters = { 90111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[220302] = {	id = 220302, pos = { x = 81.75854, y = 2.429406, z = 38.44917 }, randomPos = 0, randomRadius = 0, monsters = { 90111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[220303] = {	id = 220303, pos = { x = 76.38017, y = 2.394592, z = 41.86772 }, randomPos = 0, randomRadius = 0, monsters = { 90112,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[220304] = {	id = 220304, pos = { x = 81.31378, y = 2.468905, z = 41.45319 }, randomPos = 0, randomRadius = 0, monsters = { 90112,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
