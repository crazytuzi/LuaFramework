----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[29801] = {	id = 29801, pos = { x = 47.23935, y = 3.187279, z = -53.36229 }, randomPos = 1, randomRadius = 500, monsters = { 87409,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29802] = {	id = 29802, pos = { x = 50.39731, y = 3.187279, z = -16.86614 }, randomPos = 1, randomRadius = 500, monsters = { 87409,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29803] = {	id = 29803, pos = { x = 58.68311, y = 4.987282, z = 30.18581 }, randomPos = 1, randomRadius = 500, monsters = { 87409,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29804] = {	id = 29804, pos = { x = 72.89101, y = 7.187278, z = 65.48737 }, randomPos = 1, randomRadius = 500, monsters = { 87409,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29805] = {	id = 29805, pos = { x = 36.68753, y = 9.187286, z = 48.52119 }, randomPos = 1, randomRadius = 500, monsters = { 87409,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29806] = {	id = 29806, pos = { x = 0.6808014, y = 6.187279, z = -18.6718 }, randomPos = 1, randomRadius = 500, monsters = { 87409,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29901] = {	id = 29901, pos = { x = -4.226059, y = 6.187279, z = -5.27005 }, randomPos = 1, randomRadius = 100, monsters = { 87410,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29902] = {	id = 29902, pos = { x = 0.4712438, y = 9.187286, z = 49.244 }, randomPos = 1, randomRadius = 100, monsters = { 87410,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
