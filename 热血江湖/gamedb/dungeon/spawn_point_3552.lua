----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[710401] = {	id = 710401, pos = { x = 32.38941, y = 7.237802, z = -2.425367 }, randomPos = 0, randomRadius = 0, monsters = { 93132,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[710402] = {	id = 710402, pos = { x = 34.35323, y = 7.185715, z = -2.113884 }, randomPos = 0, randomRadius = 0, monsters = { 93132,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[710403] = {	id = 710403, pos = { x = 35.0037, y = 7.185715, z = -5.075104 }, randomPos = 0, randomRadius = 0, monsters = { 93133,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[710404] = {	id = 710404, pos = { x = 36.60319, y = 7.185715, z = 1.21632 }, randomPos = 0, randomRadius = 0, monsters = { 93131,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[710405] = {	id = 710405, pos = { x = 34.7897, y = 7.185715, z = -0.3690376 }, randomPos = 0, randomRadius = 0, monsters = { 93134,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[710406] = {	id = 710406, pos = { x = 31.46938, y = 7.185715, z = 1.488155 }, randomPos = 0, randomRadius = 0, monsters = { 93134,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[710407] = {	id = 710407, pos = { x = 32.20589, y = 7.185715, z = -3.188038 }, randomPos = 0, randomRadius = 0, monsters = { 93134,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[710501] = {	id = 710501, pos = { x = 35.73156, y = 6.237802, z = -37.43109 }, randomPos = 0, randomRadius = 0, monsters = { 93132,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[710502] = {	id = 710502, pos = { x = 36.78133, y = 6.185715, z = -36.12167 }, randomPos = 0, randomRadius = 0, monsters = { 93132,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[710503] = {	id = 710503, pos = { x = 35.22036, y = 6.185715, z = -35.21786 }, randomPos = 0, randomRadius = 0, monsters = { 93133,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[710504] = {	id = 710504, pos = { x = 34.44987, y = 6.185715, z = -35.70181 }, randomPos = 0, randomRadius = 0, monsters = { 93131,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[710505] = {	id = 710505, pos = { x = 32.94065, y = 6.185715, z = -34.58994 }, randomPos = 0, randomRadius = 0, monsters = { 93134,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[710506] = {	id = 710506, pos = { x = 32.06718, y = 6.185715, z = -34.97192 }, randomPos = 0, randomRadius = 0, monsters = { 93134,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[710507] = {	id = 710507, pos = { x = 31.89046, y = 6.185715, z = -35.15511 }, randomPos = 0, randomRadius = 0, monsters = { 93134,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[710508] = {	id = 710508, pos = { x = 39.259, y = 6.185715, z = -37.45658 }, randomPos = 0, randomRadius = 0, monsters = { 93134,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[710509] = {	id = 710509, pos = { x = 34.96633, y = 6.185715, z = -38.44232 }, randomPos = 0, randomRadius = 0, monsters = { 93135,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
