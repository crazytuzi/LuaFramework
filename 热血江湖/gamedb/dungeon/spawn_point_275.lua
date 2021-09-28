----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[55003] = {	id = 55003, pos = { x = -7.6, y = 6.2, z = -6.0 }, randomPos = 0, randomRadius = 500, monsters = { 55003,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[55002] = {	id = 55002, pos = { x = -20.23409, y = 13.16542, z = -73.17223 }, randomPos = 0, randomRadius = 500, monsters = { 55002,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[55004] = {	id = 55004, pos = { x = -130.0, y = 5.0, z = 8.0 }, randomPos = 0, randomRadius = 500, monsters = { 55004,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[55001] = {	id = 55001, pos = { x = -41.0, y = -3.8, z = -67.0 }, randomPos = 0, randomRadius = 500, monsters = { 55001,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[55005] = {	id = 55005, pos = { x = 61.19071, y = 6.437775, z = 69.23703 }, randomPos = 0, randomRadius = 500, monsters = { 450001,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
