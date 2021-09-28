----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[28801] = {	id = 28801, pos = { x = -99.1288, y = 8.025538, z = -102.4468 }, randomPos = 1, randomRadius = 500, monsters = { 87309,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28802] = {	id = 28802, pos = { x = 59.38261, y = 12.12653, z = 33.35174 }, randomPos = 1, randomRadius = 500, monsters = { 87309,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28803] = {	id = 28803, pos = { x = 45.33363, y = 10.92653, z = -22.07375 }, randomPos = 1, randomRadius = 500, monsters = { 87309,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28804] = {	id = 28804, pos = { x = 19.20001, y = 11.92096, z = 33.46636 }, randomPos = 1, randomRadius = 500, monsters = { 87309,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28805] = {	id = 28805, pos = { x = 80.02905, y = 11.32653, z = 30.52947 }, randomPos = 1, randomRadius = 500, monsters = { 87309,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28806] = {	id = 28806, pos = { x = -72.7238, y = 12.92653, z = 38.8407 }, randomPos = 1, randomRadius = 500, monsters = { 87309,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28901] = {	id = 28901, pos = { x = 50.47002, y = 10.92653, z = -19.2109 }, randomPos = 1, randomRadius = 100, monsters = { 87310,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28902] = {	id = 28902, pos = { x = -73.18227, y = 12.92653, z = 37.02324 }, randomPos = 1, randomRadius = 100, monsters = { 87310,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
