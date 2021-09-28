----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[690401] = {	id = 690401, pos = { x = 34.86124, y = 7.237802, z = -3.327324 }, randomPos = 0, randomRadius = 0, monsters = { 93102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[690402] = {	id = 690402, pos = { x = 37.0503, y = 7.185715, z = -2.699619 }, randomPos = 0, randomRadius = 0, monsters = { 93102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[690403] = {	id = 690403, pos = { x = 37.43741, y = 7.185715, z = -6.372953 }, randomPos = 0, randomRadius = 0, monsters = { 93103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[690404] = {	id = 690404, pos = { x = 34.72882, y = 7.185715, z = -6.493456 }, randomPos = 0, randomRadius = 0, monsters = { 93103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[690405] = {	id = 690405, pos = { x = 32.65772, y = 7.185715, z = 2.001585 }, randomPos = 0, randomRadius = 0, monsters = { 93101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[690406] = {	id = 690406, pos = { x = 35.10732, y = 7.185715, z = -2.397561 }, randomPos = 0, randomRadius = 0, monsters = { 93104,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[690501] = {	id = 690501, pos = { x = 33.6763, y = 6.237802, z = -36.89359 }, randomPos = 0, randomRadius = 0, monsters = { 93103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[690502] = {	id = 690502, pos = { x = 34.45637, y = 6.185715, z = -33.57975 }, randomPos = 0, randomRadius = 0, monsters = { 93103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[690503] = {	id = 690503, pos = { x = 31.67035, y = 6.185715, z = -33.29207 }, randomPos = 0, randomRadius = 0, monsters = { 93101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[690504] = {	id = 690504, pos = { x = 30.34394, y = 6.185715, z = -34.60482 }, randomPos = 0, randomRadius = 0, monsters = { 93101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[690505] = {	id = 690505, pos = { x = 39.67734, y = 6.185715, z = -36.85841 }, randomPos = 0, randomRadius = 0, monsters = { 93102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[690506] = {	id = 690506, pos = { x = 34.31851, y = 6.185715, z = -37.1852 }, randomPos = 0, randomRadius = 0, monsters = { 93105,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
