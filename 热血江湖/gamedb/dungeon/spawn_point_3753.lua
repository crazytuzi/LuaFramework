----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[750601] = {	id = 750601, pos = { x = -3.109486, y = 32.10902, z = -79.49895 }, randomPos = 0, randomRadius = 0, monsters = { 94301,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[750602] = {	id = 750602, pos = { x = -0.1634088, y = 32.10902, z = -78.09902 }, randomPos = 0, randomRadius = 0, monsters = { 94301,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[750603] = {	id = 750603, pos = { x = 3.066339, y = 32.10902, z = -78.33465 }, randomPos = 0, randomRadius = 0, monsters = { 94301,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[750604] = {	id = 750604, pos = { x = -4.545007, y = 32.10902, z = -82.59102 }, randomPos = 0, randomRadius = 0, monsters = { 94301,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[750605] = {	id = 750605, pos = { x = -0.8144717, y = 32.10902, z = -83.45685 }, randomPos = 0, randomRadius = 0, monsters = { 94301,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[750606] = {	id = 750606, pos = { x = 3.632042, y = 32.10902, z = -82.19976 }, randomPos = 0, randomRadius = 0, monsters = { 94301,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[750701] = {	id = 750701, pos = { x = -5.063188, y = 32.10902, z = -76.84724 }, randomPos = 0, randomRadius = 0, monsters = { 94302,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[750702] = {	id = 750702, pos = { x = -2.809321, y = 32.10902, z = -74.65067 }, randomPos = 0, randomRadius = 0, monsters = { 94302,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[750703] = {	id = 750703, pos = { x = 1.245964, y = 32.10902, z = -74.97948 }, randomPos = 0, randomRadius = 0, monsters = { 94302,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[750704] = {	id = 750704, pos = { x = -2.116209, y = 32.10902, z = -76.3325 }, randomPos = 0, randomRadius = 0, monsters = { 94304,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
