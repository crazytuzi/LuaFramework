----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[610401] = {	id = 610401, pos = { x = 38.27998, y = 6.965291, z = -15.65126 }, randomPos = 0, randomRadius = 0, monsters = { 90901,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[610402] = {	id = 610402, pos = { x = 39.01212, y = 6.965291, z = -21.17502 }, randomPos = 0, randomRadius = 0, monsters = { 90901,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[610403] = {	id = 610403, pos = { x = 40.36929, y = 6.965291, z = -17.3427 }, randomPos = 0, randomRadius = 0, monsters = { 90901,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[610404] = {	id = 610404, pos = { x = 39.47027, y = 6.965291, z = -18.96345 }, randomPos = 0, randomRadius = 0, monsters = { 90903,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[610405] = {	id = 610405, pos = { x = 39.54669, y = 6.965291, z = -23.75093 }, randomPos = 0, randomRadius = 0, monsters = { 90903,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[610406] = {	id = 610406, pos = { x = 41.00945, y = 6.965291, z = -14.60328 }, randomPos = 0, randomRadius = 0, monsters = { 90903,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[610501] = {	id = 610501, pos = { x = 10.33509, y = 8.204928, z = 31.24585 }, randomPos = 0, randomRadius = 0, monsters = { 90904,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[610502] = {	id = 610502, pos = { x = 16.69663, y = 8.217489, z = 27.60575 }, randomPos = 0, randomRadius = 0, monsters = { 90904,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[610503] = {	id = 610503, pos = { x = 7.946038, y = 8.365291, z = 20.94366 }, randomPos = 0, randomRadius = 0, monsters = { 90904,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[610504] = {	id = 610504, pos = { x = 3.973091, y = 8.282578, z = 27.79576 }, randomPos = 0, randomRadius = 0, monsters = { 90905,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[610505] = {	id = 610505, pos = { x = 4.367834, y = 8.173887, z = 30.85895 }, randomPos = 0, randomRadius = 0, monsters = { 90905,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[610506] = {	id = 610506, pos = { x = 13.4124, y = 8.225017, z = 30.33282 }, randomPos = 0, randomRadius = 0, monsters = { 90905,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[610507] = {	id = 610507, pos = { x = 15.08226, y = 8.315973, z = 25.05074 }, randomPos = 0, randomRadius = 0, monsters = { 90906,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[610508] = {	id = 610508, pos = { x = -5.603724, y = 6.965301, z = -40.25624 }, randomPos = 0, randomRadius = 0, monsters = { 90907,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[610509] = {	id = 610509, pos = { x = -8.0838, y = 6.965301, z = -7.949288 }, randomPos = 0, randomRadius = 0, monsters = { 90908,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[610510] = {	id = 610510, pos = { x = 28.45714, y = 7.072501, z = -40.79475 }, randomPos = 0, randomRadius = 0, monsters = { 90909,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[610511] = {	id = 610511, pos = { x = 40.66114, y = 6.965301, z = -20.25162 }, randomPos = 0, randomRadius = 0, monsters = { 90910,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
