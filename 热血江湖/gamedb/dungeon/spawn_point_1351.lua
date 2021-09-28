----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[270201] = {	id = 270201, pos = { x = -16.86868, y = 4.789661, z = -6.363953 }, randomPos = 0, randomRadius = 0, monsters = { 90202,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[270202] = {	id = 270202, pos = { x = -17.29702, y = 4.694529, z = -0.0162115 }, randomPos = 0, randomRadius = 0, monsters = { 90202,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[270203] = {	id = 270203, pos = { x = -17.65552, y = 4.850455, z = -2.666009 }, randomPos = 0, randomRadius = 0, monsters = { 90203,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[270301] = {	id = 270301, pos = { x = -59.34722, y = 5.214399, z = -3.193266 }, randomPos = 0, randomRadius = 0, monsters = { 90209,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[270302] = {	id = 270302, pos = { x = -57.81163, y = 5.137385, z = -8.633673 }, randomPos = 0, randomRadius = 0, monsters = { 90204,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[270303] = {	id = 270303, pos = { x = -56.03214, y = 5.151016, z = 2.825626 }, randomPos = 0, randomRadius = 0, monsters = { 90204,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
