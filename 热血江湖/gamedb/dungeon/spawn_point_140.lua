----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[28001] = {	id = 28001, pos = { x = -98.52831, y = 8.102547, z = -100.0617 }, randomPos = 1, randomRadius = 500, monsters = { 87301,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28002] = {	id = 28002, pos = { x = -62.22728, y = 7.599357, z = -107.0145 }, randomPos = 1, randomRadius = 500, monsters = { 87301,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28003] = {	id = 28003, pos = { x = -24.66702, y = 8.000834, z = -95.10049 }, randomPos = 1, randomRadius = 500, monsters = { 87301,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28004] = {	id = 28004, pos = { x = 18.79304, y = 7.926529, z = -96.88794 }, randomPos = 1, randomRadius = 500, monsters = { 87301,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28005] = {	id = 28005, pos = { x = 55.81741, y = 8.551508, z = -91.14207 }, randomPos = 1, randomRadius = 500, monsters = { 87301,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28006] = {	id = 28006, pos = { x = 48.36954, y = 10.92653, z = -23.798 }, randomPos = 1, randomRadius = 500, monsters = { 87301,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28007] = {	id = 28007, pos = { x = 10.13844, y = 11.53965, z = 31.57334 }, randomPos = 1, randomRadius = 500, monsters = { 87301,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28008] = {	id = 28008, pos = { x = 48.40701, y = 11.32653, z = 45.79455 }, randomPos = 1, randomRadius = 500, monsters = { 87301,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28009] = {	id = 28009, pos = { x = 78.14004, y = 11.35023, z = 27.66218 }, randomPos = 1, randomRadius = 500, monsters = { 87301,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28010] = {	id = 28010, pos = { x = -72.81058, y = 12.92653, z = 38.55423 }, randomPos = 1, randomRadius = 500, monsters = { 87301,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28101] = {	id = 28101, pos = { x = -99.1288, y = 8.025538, z = -102.4468 }, randomPos = 1, randomRadius = 500, monsters = { 87302,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28102] = {	id = 28102, pos = { x = -62.03594, y = 7.767822, z = -107.2697 }, randomPos = 1, randomRadius = 500, monsters = { 87302,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28103] = {	id = 28103, pos = { x = 45.33363, y = 10.92653, z = -22.07375 }, randomPos = 1, randomRadius = 500, monsters = { 87302,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28104] = {	id = 28104, pos = { x = 19.20001, y = 11.92096, z = 33.46636 }, randomPos = 1, randomRadius = 500, monsters = { 87302,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28105] = {	id = 28105, pos = { x = 80.02905, y = 11.32653, z = 30.52947 }, randomPos = 1, randomRadius = 500, monsters = { 87302,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28106] = {	id = 28106, pos = { x = -72.7238, y = 12.92653, z = 38.8407 }, randomPos = 1, randomRadius = 500, monsters = { 87302,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
