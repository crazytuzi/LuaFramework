----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[350201] = {	id = 350201, pos = { x = -5.5, y = 0.3588623, z = 32.25 }, randomPos = 0, randomRadius = 0, monsters = { 90321,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350202] = {	id = 350202, pos = { x = 4.759285, y = 0.3588616, z = 32.82275 }, randomPos = 0, randomRadius = 0, monsters = { 90321,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350203] = {	id = 350203, pos = { x = -0.1770439, y = 0.3717567, z = 32.28983 }, randomPos = 0, randomRadius = 0, monsters = { 90321,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350204] = {	id = 350204, pos = { x = -2.355711, y = 0.5308455, z = 35.86572 }, randomPos = 0, randomRadius = 0, monsters = { 90322,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350205] = {	id = 350205, pos = { x = 2.644289, y = 0.3588616, z = 35.86572 }, randomPos = 0, randomRadius = 0, monsters = { 90322,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350206] = {	id = 350206, pos = { x = -0.3557105, y = 0.3778336, z = 28.86572 }, randomPos = 0, randomRadius = 0, monsters = { 90322,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350301] = {	id = 350301, pos = { x = -12.51539, y = 0.5267023, z = 39.79625 }, randomPos = 0, randomRadius = 0, monsters = { 90322,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350302] = {	id = 350302, pos = { x = -4.342221, y = 0.500258, z = 40.12325 }, randomPos = 0, randomRadius = 0, monsters = { 90322,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350303] = {	id = 350303, pos = { x = -8.25, y = 0.667696, z = 39.37316 }, randomPos = 0, randomRadius = 0, monsters = { 90322,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350304] = {	id = 350304, pos = { x = -8.025333, y = 0.6603788, z = 44.29529 }, randomPos = 0, randomRadius = 0, monsters = { 90322,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350305] = {	id = 350305, pos = { x = -13.02533, y = 0.6294936, z = 48.29529 }, randomPos = 0, randomRadius = 0, monsters = { 90323,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350306] = {	id = 350306, pos = { x = -8.25, y = 0.6482932, z = 49.25 }, randomPos = 0, randomRadius = 0, monsters = { 90323,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350307] = {	id = 350307, pos = { x = -3.18543, y = 0.4132808, z = 49.5 }, randomPos = 0, randomRadius = 0, monsters = { 90323,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350308] = {	id = 350308, pos = { x = -8.25, y = 0.5184578, z = 55.25 }, randomPos = 0, randomRadius = 0, monsters = { 90323,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
