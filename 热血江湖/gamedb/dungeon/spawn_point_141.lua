----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[28201] = {	id = 28201, pos = { x = -99.1288, y = 8.025538, z = -102.4468 }, randomPos = 1, randomRadius = 500, monsters = { 87303,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28202] = {	id = 28202, pos = { x = -61.78241, y = 7.703619, z = -107.8893 }, randomPos = 1, randomRadius = 500, monsters = { 87303,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28203] = {	id = 28203, pos = { x = 45.33363, y = 10.92653, z = -22.07375 }, randomPos = 1, randomRadius = 500, monsters = { 87303,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28204] = {	id = 28204, pos = { x = 19.20001, y = 11.92096, z = 33.46636 }, randomPos = 1, randomRadius = 500, monsters = { 87303,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28205] = {	id = 28205, pos = { x = 80.02905, y = 11.32653, z = 30.52947 }, randomPos = 1, randomRadius = 500, monsters = { 87303,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28206] = {	id = 28206, pos = { x = -72.7238, y = 12.92653, z = 38.8407 }, randomPos = 1, randomRadius = 500, monsters = { 87303,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28301] = {	id = 28301, pos = { x = -72.5871, y = 12.92653, z = 37.30972 }, randomPos = 1, randomRadius = 200, monsters = { 87304,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28302] = {	id = 28302, pos = { x = 15.8398, y = 12.52357, z = 34.02351 }, randomPos = 1, randomRadius = 200, monsters = { 87304,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28303] = {	id = 28303, pos = { x = 53.60367, y = 10.92653, z = -22.13689 }, randomPos = 1, randomRadius = 200, monsters = { 87304,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28304] = {	id = 28304, pos = { x = -29.03477, y = 7.042256, z = -94.30814 }, randomPos = 1, randomRadius = 200, monsters = { 87304,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
