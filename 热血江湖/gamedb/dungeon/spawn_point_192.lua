----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[38401] = {	id = 38401, pos = { x = 128.8992, y = -6.339142, z = -78.87357 }, randomPos = 1, randomRadius = 500, monsters = { 87805,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38402] = {	id = 38402, pos = { x = 115.9249, y = 0.8494304, z = 30.73273 }, randomPos = 1, randomRadius = 500, monsters = { 87805,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38403] = {	id = 38403, pos = { x = -63.02896, y = 14.26086, z = 53.84262 }, randomPos = 1, randomRadius = 500, monsters = { 87805,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38404] = {	id = 38404, pos = { x = 6.680889, y = 9.86087, z = 42.37285 }, randomPos = 1, randomRadius = 500, monsters = { 87805,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38405] = {	id = 38405, pos = { x = -41.05957, y = -3.810677, z = -68.89485 }, randomPos = 1, randomRadius = 500, monsters = { 87805,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38406] = {	id = 38406, pos = { x = 99.9715, y = 2.441551, z = 81.47224 }, randomPos = 1, randomRadius = 500, monsters = { 87805,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38407] = {	id = 38407, pos = { x = 21.46905, y = -8.550347, z = -76.26143 }, randomPos = 1, randomRadius = 500, monsters = { 87805,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38408] = {	id = 38408, pos = { x = 80.23241, y = -8.244884, z = -96.89998 }, randomPos = 1, randomRadius = 500, monsters = { 87805,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38409] = {	id = 38409, pos = { x = 144.0067, y = 0.7937464, z = 21.41413 }, randomPos = 1, randomRadius = 500, monsters = { 87805,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38410] = {	id = 38410, pos = { x = 11.01624, y = 11.26086, z = 94.17355 }, randomPos = 1, randomRadius = 500, monsters = { 87805,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38501] = {	id = 38501, pos = { x = 134.2589, y = 0.7593897, z = 30.35471 }, randomPos = 1, randomRadius = 500, monsters = { 87806,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38502] = {	id = 38502, pos = { x = -19.08686, y = 14.26086, z = 91.34335 }, randomPos = 1, randomRadius = 500, monsters = { 87806,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38503] = {	id = 38503, pos = { x = 98.55598, y = 3.407556, z = 92.51215 }, randomPos = 1, randomRadius = 500, monsters = { 87806,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38504] = {	id = 38504, pos = { x = 133.5286, y = -6.339142, z = -85.11638 }, randomPos = 1, randomRadius = 500, monsters = { 87806,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38505] = {	id = 38505, pos = { x = 42.6225, y = -7.821142, z = -66.51965 }, randomPos = 1, randomRadius = 500, monsters = { 87806,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38506] = {	id = 38506, pos = { x = -41.09508, y = -3.821411, z = -68.04691 }, randomPos = 1, randomRadius = 500, monsters = { 87806,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
