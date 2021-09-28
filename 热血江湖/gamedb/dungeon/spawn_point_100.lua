----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[20101] = {	id = 20101, pos = { x = -85.3643, y = 7.0, z = 0.2783146 }, randomPos = 1, randomRadius = 600, monsters = { 89011,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20102] = {	id = 20102, pos = { x = -34.80856, y = 5.099265, z = -47.39109 }, randomPos = 1, randomRadius = 400, monsters = { 89012,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20103] = {	id = 20103, pos = { x = -71.50581, y = 0.2000002, z = -125.3781 }, randomPos = 1, randomRadius = 600, monsters = { 89013,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20104] = {	id = 20104, pos = { x = -17.67086, y = 0.2000001, z = -132.7376 }, randomPos = 1, randomRadius = 400, monsters = { 89014,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20105] = {	id = 20105, pos = { x = -1.330567, y = 0.2000002, z = -112.3678 }, randomPos = 1, randomRadius = 600, monsters = { 89015,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
