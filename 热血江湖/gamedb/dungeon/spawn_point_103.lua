----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[20601] = {	id = 20601, pos = { x = -36.05917, y = 0.2000002, z = -112.2159 }, randomPos = 1, randomRadius = 600, monsters = { 89061,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20602] = {	id = 20602, pos = { x = 15.46992, y = 5.0, z = -59.34975 }, randomPos = 1, randomRadius = 600, monsters = { 89062,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20603] = {	id = 20603, pos = { x = -71.82692, y = 0.2000002, z = -96.02091 }, randomPos = 1, randomRadius = 600, monsters = { 89063,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20604] = {	id = 20604, pos = { x = -83.21307, y = 7.0, z = -2.262499 }, randomPos = 1, randomRadius = 400, monsters = { 89064,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20701] = {	id = 20701, pos = { x = 69.91258, y = 9.277247, z = 52.82018 }, randomPos = 1, randomRadius = 600, monsters = { 89071,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20702] = {	id = 20702, pos = { x = 79.64719, y = 3.036194, z = -66.75927 }, randomPos = 1, randomRadius = 600, monsters = { 89072,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20703] = {	id = 20703, pos = { x = 0.5851211, y = 3.036194, z = -53.12169 }, randomPos = 1, randomRadius = 600, monsters = { 89073,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20704] = {	id = 20704, pos = { x = 38.08131, y = 9.236191, z = 42.72461 }, randomPos = 1, randomRadius = 600, monsters = { 89074,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20705] = {	id = 20705, pos = { x = -24.12, y = 3.036194, z = -76.86723 }, randomPos = 1, randomRadius = 400, monsters = { 89075,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20706] = {	id = 20706, pos = { x = -46.2333, y = 10.34241, z = -3.737194 }, randomPos = 1, randomRadius = 600, monsters = { 89076,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
