----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[28401] = {	id = 28401, pos = { x = -98.52831, y = 8.102547, z = -100.0617 }, randomPos = 1, randomRadius = 500, monsters = { 87305,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28402] = {	id = 28402, pos = { x = -62.22728, y = 7.599357, z = -107.0145 }, randomPos = 1, randomRadius = 500, monsters = { 87305,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28403] = {	id = 28403, pos = { x = -24.66702, y = 8.000834, z = -95.10049 }, randomPos = 1, randomRadius = 500, monsters = { 87305,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28404] = {	id = 28404, pos = { x = 18.79304, y = 7.926529, z = -96.88794 }, randomPos = 1, randomRadius = 500, monsters = { 87305,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28405] = {	id = 28405, pos = { x = 55.81741, y = 8.551508, z = -91.14207 }, randomPos = 1, randomRadius = 500, monsters = { 87305,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28406] = {	id = 28406, pos = { x = 48.36954, y = 10.92653, z = -23.798 }, randomPos = 1, randomRadius = 500, monsters = { 87305,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28407] = {	id = 28407, pos = { x = 10.13844, y = 11.53965, z = 31.57334 }, randomPos = 1, randomRadius = 500, monsters = { 87305,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28408] = {	id = 28408, pos = { x = 48.40701, y = 11.32653, z = 45.79455 }, randomPos = 1, randomRadius = 500, monsters = { 87305,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28409] = {	id = 28409, pos = { x = 78.14004, y = 11.35023, z = 27.66218 }, randomPos = 1, randomRadius = 500, monsters = { 87305,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28410] = {	id = 28410, pos = { x = -72.81058, y = 12.92653, z = 38.55423 }, randomPos = 1, randomRadius = 500, monsters = { 87305,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28501] = {	id = 28501, pos = { x = -99.1288, y = 8.025538, z = -102.4468 }, randomPos = 1, randomRadius = 500, monsters = { 87306,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28502] = {	id = 28502, pos = { x = -9.557152, y = 12.04599, z = 32.0 }, randomPos = 1, randomRadius = 500, monsters = { 87306,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28503] = {	id = 28503, pos = { x = 45.33363, y = 10.92653, z = -22.07375 }, randomPos = 1, randomRadius = 500, monsters = { 87306,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28504] = {	id = 28504, pos = { x = 19.20001, y = 11.92096, z = 33.46636 }, randomPos = 1, randomRadius = 500, monsters = { 87306,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28505] = {	id = 28505, pos = { x = 80.02905, y = 11.32653, z = 30.52947 }, randomPos = 1, randomRadius = 500, monsters = { 87306,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28506] = {	id = 28506, pos = { x = -72.7238, y = 12.92653, z = 38.8407 }, randomPos = 1, randomRadius = 500, monsters = { 87306,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
