----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[340601] = {	id = 340601, pos = { x = 3.342088, y = 0.305059, z = 106.4165 }, randomPos = 0, randomRadius = 0, monsters = { 90313,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[340602] = {	id = 340602, pos = { x = 10.38551, y = 0.408381, z = 107.6045 }, randomPos = 0, randomRadius = 0, monsters = { 90313,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[340603] = {	id = 340603, pos = { x = 5.32468, y = 0.4513084, z = 107.4421 }, randomPos = 0, randomRadius = 0, monsters = { 90313,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[340604] = {	id = 340604, pos = { x = 10.90543, y = 0.4095282, z = 113.1127 }, randomPos = 0, randomRadius = 0, monsters = { 90311,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[340605] = {	id = 340605, pos = { x = 4.559237, y = 0.4036932, z = 113.4568 }, randomPos = 0, randomRadius = 0, monsters = { 90311,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[340606] = {	id = 340606, pos = { x = 5.199911, y = 0.1721506, z = 99.47379 }, randomPos = 0, randomRadius = 0, monsters = { 90311,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[340607] = {	id = 340607, pos = { x = 7.796062, y = 0.4541434, z = 110.1681 }, randomPos = 0, randomRadius = 0, monsters = { 90315,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
