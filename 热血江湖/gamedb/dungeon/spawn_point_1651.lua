----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[330201] = {	id = 330201, pos = { x = -2.486923, y = 0.5157093, z = 35.08295 }, randomPos = 0, randomRadius = 0, monsters = { 90301,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[330202] = {	id = 330202, pos = { x = -3.89155, y = 0.5588623, z = 39.13238 }, randomPos = 0, randomRadius = 0, monsters = { 90301,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[330203] = {	id = 330203, pos = { x = -7.096961, y = 0.5776409, z = 38.28231 }, randomPos = 0, randomRadius = 0, monsters = { 90302,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[330204] = {	id = 330204, pos = { x = 0.0, y = 0.5574475, z = 39.07463 }, randomPos = 0, randomRadius = 0, monsters = { 90302,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[330301] = {	id = 330301, pos = { x = -5.827878, y = 0.5311829, z = 44.17928 }, randomPos = 0, randomRadius = 0, monsters = { 90302,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[330302] = {	id = 330302, pos = { x = -11.18657, y = 0.4751456, z = 49.71645 }, randomPos = 0, randomRadius = 0, monsters = { 90302,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[330303] = {	id = 330303, pos = { x = -5.475724, y = 0.4211354, z = 49.64416 }, randomPos = 0, randomRadius = 0, monsters = { 90303,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[330304] = {	id = 330304, pos = { x = -8.688723, y = 0.7010736, z = 52.4716 }, randomPos = 0, randomRadius = 0, monsters = { 90303,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
