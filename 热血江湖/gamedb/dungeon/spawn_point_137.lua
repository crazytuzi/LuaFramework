----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[27401] = {	id = 27401, pos = { x = 18.30225, y = 13.28413, z = 14.59604 }, randomPos = 1, randomRadius = 500, monsters = { 87205,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27402] = {	id = 27402, pos = { x = -17.29714, y = 13.27988, z = -10.70255 }, randomPos = 1, randomRadius = 500, monsters = { 87205,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27403] = {	id = 27403, pos = { x = 10.18629, y = 11.65004, z = -73.66724 }, randomPos = 1, randomRadius = 500, monsters = { 87205,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27404] = {	id = 27404, pos = { x = 53.09053, y = 13.39318, z = -22.0243 }, randomPos = 1, randomRadius = 500, monsters = { 87205,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27405] = {	id = 27405, pos = { x = 65.15579, y = 20.67988, z = 42.30792 }, randomPos = 1, randomRadius = 500, monsters = { 87205,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27406] = {	id = 27406, pos = { x = 34.76817, y = 19.85254, z = 106.6129 }, randomPos = 1, randomRadius = 500, monsters = { 87205,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27407] = {	id = 27407, pos = { x = 88.6665, y = 2.743764, z = -50.54017 }, randomPos = 1, randomRadius = 500, monsters = { 87205,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27408] = {	id = 27408, pos = { x = 62.60606, y = 2.079878, z = -62.85814 }, randomPos = 1, randomRadius = 500, monsters = { 87205,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27409] = {	id = 27409, pos = { x = 69.65979, y = 12.12079, z = 2.045345 }, randomPos = 1, randomRadius = 500, monsters = { 87205,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27410] = {	id = 27410, pos = { x = -27.11249, y = 5.866393, z = -57.60371 }, randomPos = 1, randomRadius = 500, monsters = { 87205,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27501] = {	id = 27501, pos = { x = 11.00378, y = 11.65138, z = -73.9537 }, randomPos = 1, randomRadius = 500, monsters = { 87206,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27502] = {	id = 27502, pos = { x = 54.77692, y = 13.43072, z = -22.31078 }, randomPos = 1, randomRadius = 500, monsters = { 87206,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27503] = {	id = 27503, pos = { x = 17.83704, y = 13.27988, z = 14.62908 }, randomPos = 1, randomRadius = 500, monsters = { 87206,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27504] = {	id = 27504, pos = { x = 66.72104, y = 20.67212, z = 42.02144 }, randomPos = 1, randomRadius = 500, monsters = { 87206,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27505] = {	id = 27505, pos = { x = 88.75452, y = 2.73953, z = -50.82665 }, randomPos = 1, randomRadius = 500, monsters = { 87206,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27506] = {	id = 27506, pos = { x = -22.98429, y = 13.27988, z = -7.496792 }, randomPos = 1, randomRadius = 500, monsters = { 87206,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
