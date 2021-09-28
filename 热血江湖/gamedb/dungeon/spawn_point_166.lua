----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[33201] = {	id = 33201, pos = { x = 51.4919, y = 28.76542, z = 44.95152 }, randomPos = 1, randomRadius = 500, monsters = { 87503,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33202] = {	id = 33202, pos = { x = 115.992, y = 30.16542, z = 106.5947 }, randomPos = 1, randomRadius = 500, monsters = { 87503,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33203] = {	id = 33203, pos = { x = 57.5556, y = 32.36542, z = 115.5467 }, randomPos = 1, randomRadius = 500, monsters = { 87503,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33204] = {	id = 33204, pos = { x = -0.3341484, y = 32.36542, z = 121.3383 }, randomPos = 1, randomRadius = 500, monsters = { 87503,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33205] = {	id = 33205, pos = { x = 27.67218, y = 28.76542, z = 45.88494 }, randomPos = 1, randomRadius = 500, monsters = { 87503,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33206] = {	id = 33206, pos = { x = 26.84586, y = 24.36542, z = 13.2393 }, randomPos = 1, randomRadius = 500, monsters = { 87503,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33301] = {	id = 33301, pos = { x = -24.3407, y = 13.16542, z = -68.35733 }, randomPos = 1, randomRadius = 200, monsters = { 87504,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33302] = {	id = 33302, pos = { x = 18.52706, y = 11.16542, z = -94.25862 }, randomPos = 1, randomRadius = 200, monsters = { 87504,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33303] = {	id = 33303, pos = { x = 24.87584, y = 16.16542, z = -33.48511 }, randomPos = 1, randomRadius = 200, monsters = { 87504,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33304] = {	id = 33304, pos = { x = 94.37318, y = 22.46402, z = -41.31122 }, randomPos = 1, randomRadius = 200, monsters = { 87504,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
