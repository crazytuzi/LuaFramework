----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[30401] = {	id = 30401, pos = { x = 65.83992, y = 18.99218, z = 45.63958 }, randomPos = 1, randomRadius = 350, monsters = { 99651,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30402] = {	id = 30402, pos = { x = 55.26614, y = 18.99218, z = 44.64419 }, randomPos = 1, randomRadius = 350, monsters = { 99651,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30403] = {	id = 30403, pos = { x = 73.77048, y = 18.99218, z = -61.20718 }, randomPos = 1, randomRadius = 350, monsters = { 99651,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30404] = {	id = 30404, pos = { x = 58.96242, y = 18.99189, z = -66.30335 }, randomPos = 1, randomRadius = 350, monsters = { 99652,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30405] = {	id = 30405, pos = { x = 101.61, y = 16.71205, z = -72.51159 }, randomPos = 1, randomRadius = 350, monsters = { 99652,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30406] = {	id = 30406, pos = { x = 53.54122, y = 18.99218, z = 56.66982 }, randomPos = 1, randomRadius = 350, monsters = { 99652,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30407] = {	id = 30407, pos = { x = 69.91515, y = 18.99218, z = 57.11818 }, randomPos = 0, randomRadius = 100, monsters = { 99653,  }, spawnType = 3, spawnDTime = 900000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30408] = {	id = 30408, pos = { x = 107.271, y = 16.3377, z = -69.73572 }, randomPos = 0, randomRadius = 100, monsters = { 99654,  }, spawnType = 3, spawnDTime = 900000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30501] = {	id = 30501, pos = { x = 36.1056, y = 6.237802, z = -24.16765 }, randomPos = 1, randomRadius = 350, monsters = { 99671,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30502] = {	id = 30502, pos = { x = -5.573811, y = 6.237802, z = 9.532677 }, randomPos = 1, randomRadius = 350, monsters = { 99671,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30503] = {	id = 30503, pos = { x = -29.65754, y = 0.4378013, z = 1.298393 }, randomPos = 1, randomRadius = 350, monsters = { 99671,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30504] = {	id = 30504, pos = { x = 28.74255, y = 6.237802, z = -32.43359 }, randomPos = 1, randomRadius = 350, monsters = { 99672,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30505] = {	id = 30505, pos = { x = 4.452976, y = 6.237802, z = 6.255869 }, randomPos = 1, randomRadius = 200, monsters = { 99672,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30506] = {	id = 30506, pos = { x = -27.31686, y = 0.4378013, z = 9.854626 }, randomPos = 1, randomRadius = 200, monsters = { 99672,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30507] = {	id = 30507, pos = { x = -2.637516, y = 6.237802, z = 0.6692657 }, randomPos = 0, randomRadius = 100, monsters = { 99673,  }, spawnType = 3, spawnDTime = 900000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30508] = {	id = 30508, pos = { x = 30.88058, y = 7.237802, z = -2.568611 }, randomPos = 0, randomRadius = 100, monsters = { 99674,  }, spawnType = 3, spawnDTime = 900000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
