----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[20801] = {	id = 20801, pos = { x = 80.21754, y = 3.163841, z = -128.2582 }, randomPos = 1, randomRadius = 600, monsters = { 89081,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20802] = {	id = 20802, pos = { x = 137.6757, y = 0.1638422, z = -30.43254 }, randomPos = 1, randomRadius = 600, monsters = { 89082,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20803] = {	id = 20803, pos = { x = -73.48383, y = 7.163842, z = -116.8208 }, randomPos = 1, randomRadius = 600, monsters = { 89083,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20804] = {	id = 20804, pos = { x = -98.6009, y = 3.163841, z = 16.65437 }, randomPos = 1, randomRadius = 600, monsters = { 89084,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20805] = {	id = 20805, pos = { x = -108.3635, y = 17.30559, z = 106.3625 }, randomPos = 1, randomRadius = 600, monsters = { 89085,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20806] = {	id = 20806, pos = { x = 137.8827, y = 0.1638422, z = -125.9809 }, randomPos = 0, randomRadius = 0, monsters = { 89086,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20807] = {	id = 20807, pos = { x = -152.1797, y = 4.163841, z = -124.8518 }, randomPos = 0, randomRadius = 0, monsters = { 89087,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
