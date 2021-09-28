----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[70201] = {	id = 70201, pos = { x = -3.796806, y = 1.334284, z = -13.30473 }, randomPos = 1, randomRadius = 500, monsters = { 61104,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[70202] = {	id = 70202, pos = { x = -3.733222, y = 1.559574, z = -2.946686 }, randomPos = 1, randomRadius = 500, monsters = { 61105,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[70203] = {	id = 70203, pos = { x = 5.381933, y = 1.381977, z = -1.13722 }, randomPos = 1, randomRadius = 500, monsters = { 61106,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[70301] = {	id = 70301, pos = { x = -21.50337, y = 8.789295, z = 47.86298 }, randomPos = 1, randomRadius = 500, monsters = { 61107,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[70302] = {	id = 70302, pos = { x = -21.34852, y = 8.789295, z = 53.11605 }, randomPos = 1, randomRadius = 500, monsters = { 61108,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[70303] = {	id = 70303, pos = { x = -16.71346, y = 8.936326, z = 49.94202 }, randomPos = 1, randomRadius = 500, monsters = { 61109,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
