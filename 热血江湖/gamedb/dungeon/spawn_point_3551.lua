----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[710201] = {	id = 710201, pos = { x = -20.43666, y = 0.4378013, z = 7.91564 }, randomPos = 0, randomRadius = 0, monsters = { 93132,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[710202] = {	id = 710202, pos = { x = -19.69577, y = 0.3857151, z = 9.043772 }, randomPos = 0, randomRadius = 0, monsters = { 93132,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[710203] = {	id = 710203, pos = { x = -19.94249, y = 0.3857151, z = 6.719347 }, randomPos = 0, randomRadius = 0, monsters = { 93133,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[710204] = {	id = 710204, pos = { x = -19.42794, y = 0.3857151, z = 3.974728 }, randomPos = 0, randomRadius = 0, monsters = { 93133,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[710205] = {	id = 710205, pos = { x = -18.28904, y = 0.3857151, z = 8.191574 }, randomPos = 0, randomRadius = 0, monsters = { 93134,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[710206] = {	id = 710206, pos = { x = -19.69247, y = 0.3857151, z = 4.158745 }, randomPos = 0, randomRadius = 0, monsters = { 93134,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[710301] = {	id = 710301, pos = { x = 0.8850756, y = 6.237802, z = 6.921418 }, randomPos = 0, randomRadius = 0, monsters = { 93131,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[710302] = {	id = 710302, pos = { x = -2.503923, y = 6.185715, z = 8.233152 }, randomPos = 0, randomRadius = 0, monsters = { 93131,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[710303] = {	id = 710303, pos = { x = -2.557874, y = 6.185715, z = 5.185101 }, randomPos = 0, randomRadius = 0, monsters = { 93133,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[710304] = {	id = 710304, pos = { x = -0.4850473, y = 6.185715, z = 3.123577 }, randomPos = 0, randomRadius = 0, monsters = { 93133,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[710305] = {	id = 710305, pos = { x = 2.064619, y = 6.185715, z = 10.33745 }, randomPos = 0, randomRadius = 0, monsters = { 93134,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[710306] = {	id = 710306, pos = { x = 1.868707, y = 6.185715, z = 8.224579 }, randomPos = 0, randomRadius = 0, monsters = { 93134,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[710307] = {	id = 710307, pos = { x = 1.388982, y = 6.185715, z = 4.222942 }, randomPos = 0, randomRadius = 0, monsters = { 93134,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
