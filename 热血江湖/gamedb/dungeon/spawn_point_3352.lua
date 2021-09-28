----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[670401] = {	id = 670401, pos = { x = -36.36425, y = 28.79218, z = 121.7311 }, randomPos = 0, randomRadius = 0, monsters = { 92123,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[670402] = {	id = 670402, pos = { x = -40.96764, y = 28.79218, z = 115.9258 }, randomPos = 0, randomRadius = 0, monsters = { 92123,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[670403] = {	id = 670403, pos = { x = -51.61086, y = 28.79218, z = 117.4348 }, randomPos = 0, randomRadius = 0, monsters = { 92123,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[670404] = {	id = 670404, pos = { x = -52.91969, y = 28.79218, z = 125.9969 }, randomPos = 0, randomRadius = 0, monsters = { 92123,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[670405] = {	id = 670405, pos = { x = -41.92664, y = 28.79218, z = 125.862 }, randomPos = 0, randomRadius = 0, monsters = { 92121,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[670406] = {	id = 670406, pos = { x = -46.85437, y = 28.79218, z = 126.6216 }, randomPos = 0, randomRadius = 0, monsters = { 92121,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[670407] = {	id = 670407, pos = { x = -46.97224, y = 28.79218, z = 115.9436 }, randomPos = 0, randomRadius = 0, monsters = { 92121,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[670408] = {	id = 670408, pos = { x = -42.19579, y = 28.79218, z = 121.6428 }, randomPos = 0, randomRadius = 0, monsters = { 92121,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[670409] = {	id = 670409, pos = { x = -37.88623, y = 28.79218, z = 112.9652 }, randomPos = 0, randomRadius = 0, monsters = { 92125,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[670410] = {	id = 670410, pos = { x = -55.00243, y = 28.79218, z = 112.8177 }, randomPos = 0, randomRadius = 0, monsters = { 92125,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[670411] = {	id = 670411, pos = { x = -54.86874, y = 28.79218, z = 130.4911 }, randomPos = 0, randomRadius = 0, monsters = { 92125,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[670412] = {	id = 670412, pos = { x = -39.13459, y = 28.79218, z = 129.1594 }, randomPos = 0, randomRadius = 0, monsters = { 92125,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[670413] = {	id = 670413, pos = { x = -46.6594, y = 28.79218, z = 121.5173 }, randomPos = 0, randomRadius = 0, monsters = { 92124,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
