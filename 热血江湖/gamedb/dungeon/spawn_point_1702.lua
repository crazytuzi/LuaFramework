----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[340401] = {	id = 340401, pos = { x = 27.57668, y = 0.3766698, z = 63.30301 }, randomPos = 0, randomRadius = 0, monsters = { 90311,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[340402] = {	id = 340402, pos = { x = 22.19078, y = 0.3103816, z = 65.59341 }, randomPos = 0, randomRadius = 0, monsters = { 90311,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[340403] = {	id = 340403, pos = { x = 27.81554, y = 0.2648113, z = 70.75145 }, randomPos = 0, randomRadius = 0, monsters = { 90311,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[340404] = {	id = 340404, pos = { x = 31.07802, y = 0.2583909, z = 70.28274 }, randomPos = 0, randomRadius = 0, monsters = { 90313,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[340405] = {	id = 340405, pos = { x = 31.6036, y = 0.1812825, z = 64.0141 }, randomPos = 0, randomRadius = 0, monsters = { 90313,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[340406] = {	id = 340406, pos = { x = 28.30321, y = 0.2625192, z = 71.17466 }, randomPos = 0, randomRadius = 0, monsters = { 90313,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[340501] = {	id = 340501, pos = { x = 20.54655, y = 0.3588619, z = 71.77847 }, randomPos = 0, randomRadius = 0, monsters = { 90311,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[340502] = {	id = 340502, pos = { x = 22.99657, y = 0.2949317, z = 67.46848 }, randomPos = 0, randomRadius = 0, monsters = { 90311,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[340503] = {	id = 340503, pos = { x = 25.05961, y = 0.2565063, z = 65.8017 }, randomPos = 0, randomRadius = 0, monsters = { 90311,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[340504] = {	id = 340504, pos = { x = 26.33104, y = 0.2961522, z = 72.39499 }, randomPos = 0, randomRadius = 0, monsters = { 90312,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[340505] = {	id = 340505, pos = { x = 30.4959, y = 0.1849643, z = 64.98505 }, randomPos = 0, randomRadius = 0, monsters = { 90312,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[340506] = {	id = 340506, pos = { x = 28.82484, y = 0.269116, z = 71.94463 }, randomPos = 0, randomRadius = 0, monsters = { 90312,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[340507] = {	id = 340507, pos = { x = 25.89398, y = 0.2632041, z = 67.80367 }, randomPos = 0, randomRadius = 0, monsters = { 90314,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
