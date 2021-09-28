----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[210401] = {	id = 210401, pos = { x = 68.55881, y = 2.351528, z = 50.42653 }, randomPos = 0, randomRadius = 0, monsters = { 90107,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[210402] = {	id = 210402, pos = { x = 66.9882, y = 2.351528, z = 54.69167 }, randomPos = 0, randomRadius = 0, monsters = { 90105,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[210403] = {	id = 210403, pos = { x = 65.25079, y = 2.351528, z = 52.07866 }, randomPos = 0, randomRadius = 0, monsters = { 90105,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[210404] = {	id = 210404, pos = { x = 68.24229, y = 2.351528, z = 48.53656 }, randomPos = 0, randomRadius = 0, monsters = { 90102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[210405] = {	id = 210405, pos = { x = 69.92951, y = 2.351528, z = 51.87893 }, randomPos = 0, randomRadius = 0, monsters = { 90102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[210501] = {	id = 210501, pos = { x = 65.09478, y = 2.603404, z = 98.5825 }, randomPos = 0, randomRadius = 0, monsters = { 90108,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[210502] = {	id = 210502, pos = { x = 61.73501, y = 2.551529, z = 102.9844 }, randomPos = 0, randomRadius = 0, monsters = { 90102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[210503] = {	id = 210503, pos = { x = 66.02805, y = 2.646038, z = 100.9392 }, randomPos = 0, randomRadius = 0, monsters = { 90102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[210504] = {	id = 210504, pos = { x = 64.02808, y = 2.552774, z = 104.6306 }, randomPos = 0, randomRadius = 0, monsters = { 90103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[210505] = {	id = 210505, pos = { x = 67.23658, y = 2.717703, z = 102.3808 }, randomPos = 0, randomRadius = 0, monsters = { 90103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
