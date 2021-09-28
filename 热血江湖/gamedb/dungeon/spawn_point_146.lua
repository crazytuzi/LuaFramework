----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[29201] = {	id = 29201, pos = { x = 21.87416, y = 9.187286, z = 81.86043 }, randomPos = 1, randomRadius = 500, monsters = { 87403,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29202] = {	id = 29202, pos = { x = -23.02766, y = 9.187286, z = 120.0789 }, randomPos = 1, randomRadius = 500, monsters = { 87403,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29203] = {	id = 29203, pos = { x = 64.44883, y = 9.187286, z = 98.813 }, randomPos = 1, randomRadius = 500, monsters = { 87403,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29204] = {	id = 29204, pos = { x = 36.67313, y = 9.187286, z = 46.25668 }, randomPos = 1, randomRadius = 500, monsters = { 87403,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29205] = {	id = 29205, pos = { x = 40.88976, y = 3.193828, z = -5.617542 }, randomPos = 1, randomRadius = 500, monsters = { 87403,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29206] = {	id = 29206, pos = { x = 21.25537, y = 1.187279, z = -77.25992 }, randomPos = 1, randomRadius = 500, monsters = { 87403,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29301] = {	id = 29301, pos = { x = 63.42816, y = 9.187286, z = 106.7349 }, randomPos = 1, randomRadius = 200, monsters = { 87404,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29302] = {	id = 29302, pos = { x = 24.60103, y = 9.187286, z = 118.812 }, randomPos = 1, randomRadius = 200, monsters = { 87404,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29303] = {	id = 29303, pos = { x = -21.93346, y = 9.187286, z = 78.40019 }, randomPos = 1, randomRadius = 200, monsters = { 87404,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29304] = {	id = 29304, pos = { x = -76.41879, y = 11.18729, z = 99.08524 }, randomPos = 1, randomRadius = 200, monsters = { 87404,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
