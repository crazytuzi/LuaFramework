----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[580201] = {	id = 580201, pos = { x = -0.4217732, y = 8.907085, z = 2.058876 }, randomPos = 0, randomRadius = 0, monsters = { 90721,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580202] = {	id = 580202, pos = { x = -2.866598, y = 8.648309, z = 1.198821 }, randomPos = 0, randomRadius = 0, monsters = { 90721,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580203] = {	id = 580203, pos = { x = 3.277359, y = 8.628459, z = 2.409399 }, randomPos = 0, randomRadius = 0, monsters = { 90721,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580204] = {	id = 580204, pos = { x = 5.643931, y = 8.438843, z = 1.633031 }, randomPos = 0, randomRadius = 0, monsters = { 90721,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580205] = {	id = 580205, pos = { x = 0.8696826, y = 8.455522, z = -3.36493 }, randomPos = 0, randomRadius = 0, monsters = { 90722,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580206] = {	id = 580206, pos = { x = 3.390465, y = 8.643271, z = -1.459576 }, randomPos = 0, randomRadius = 0, monsters = { 90722,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580207] = {	id = 580207, pos = { x = 1.243229, y = 8.591962, z = -2.023607 }, randomPos = 0, randomRadius = 0, monsters = { 90722,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580208] = {	id = 580208, pos = { x = -0.9211718, y = 8.446309, z = -1.787652 }, randomPos = 0, randomRadius = 0, monsters = { 90722,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580301] = {	id = 580301, pos = { x = 32.6405, y = 2.996625, z = 32.87311 }, randomPos = 0, randomRadius = 0, monsters = { 90722,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580302] = {	id = 580302, pos = { x = 34.88289, y = 2.996625, z = 34.39583 }, randomPos = 0, randomRadius = 0, monsters = { 90722,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580303] = {	id = 580303, pos = { x = 37.81173, y = 3.135021, z = 35.30457 }, randomPos = 0, randomRadius = 0, monsters = { 90722,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580304] = {	id = 580304, pos = { x = 40.21514, y = 2.923793, z = 34.98789 }, randomPos = 0, randomRadius = 0, monsters = { 90722,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580305] = {	id = 580305, pos = { x = 37.4703, y = 3.125645, z = 30.85241 }, randomPos = 0, randomRadius = 0, monsters = { 90723,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580306] = {	id = 580306, pos = { x = 42.31382, y = 2.845634, z = 32.58172 }, randomPos = 0, randomRadius = 0, monsters = { 90723,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580307] = {	id = 580307, pos = { x = 34.77222, y = 2.974222, z = 31.85999 }, randomPos = 0, randomRadius = 0, monsters = { 90723,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[580308] = {	id = 580308, pos = { x = 39.92311, y = 2.932599, z = 31.59984 }, randomPos = 0, randomRadius = 0, monsters = { 90723,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
