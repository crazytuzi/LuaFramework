----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[27001] = {	id = 27001, pos = { x = 18.30225, y = 13.28413, z = 14.59604 }, randomPos = 1, randomRadius = 500, monsters = { 87201,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27002] = {	id = 27002, pos = { x = -17.29714, y = 13.27988, z = -10.70255 }, randomPos = 1, randomRadius = 500, monsters = { 87201,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27003] = {	id = 27003, pos = { x = 10.18629, y = 11.65004, z = -73.66724 }, randomPos = 1, randomRadius = 500, monsters = { 87201,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27004] = {	id = 27004, pos = { x = 53.09053, y = 13.39318, z = -22.0243 }, randomPos = 1, randomRadius = 500, monsters = { 87201,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27005] = {	id = 27005, pos = { x = 65.15579, y = 20.67988, z = 42.30792 }, randomPos = 1, randomRadius = 500, monsters = { 87201,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27006] = {	id = 27006, pos = { x = 34.76817, y = 19.85254, z = 106.6129 }, randomPos = 1, randomRadius = 500, monsters = { 87201,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27007] = {	id = 27007, pos = { x = 88.6665, y = 2.743764, z = -50.54017 }, randomPos = 1, randomRadius = 500, monsters = { 87201,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27008] = {	id = 27008, pos = { x = 62.60606, y = 2.079878, z = -62.85814 }, randomPos = 1, randomRadius = 500, monsters = { 87201,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27009] = {	id = 27009, pos = { x = 69.65979, y = 12.12079, z = 2.045345 }, randomPos = 1, randomRadius = 500, monsters = { 87201,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27010] = {	id = 27010, pos = { x = -27.11249, y = 5.866393, z = -57.60371 }, randomPos = 1, randomRadius = 500, monsters = { 87201,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27101] = {	id = 27101, pos = { x = 11.00378, y = 11.65138, z = -73.9537 }, randomPos = 1, randomRadius = 500, monsters = { 87202,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27102] = {	id = 27102, pos = { x = 54.77692, y = 13.43072, z = -22.31078 }, randomPos = 1, randomRadius = 500, monsters = { 87202,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27103] = {	id = 27103, pos = { x = 17.83704, y = 13.27988, z = 14.62908 }, randomPos = 1, randomRadius = 500, monsters = { 87202,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27104] = {	id = 27104, pos = { x = 66.72104, y = 20.67212, z = 42.02144 }, randomPos = 1, randomRadius = 500, monsters = { 87202,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27105] = {	id = 27105, pos = { x = 88.75452, y = 2.73953, z = -50.82665 }, randomPos = 1, randomRadius = 500, monsters = { 87202,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27106] = {	id = 27106, pos = { x = -22.98429, y = 13.27988, z = -7.496792 }, randomPos = 1, randomRadius = 500, monsters = { 87202,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
