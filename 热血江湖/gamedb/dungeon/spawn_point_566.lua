----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[113201] = {	id = 113201, pos = { x = 3.781727, y = 6.382332, z = -13.48037 }, randomPos = 1, randomRadius = 500, monsters = { 150511,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[113202] = {	id = 113202, pos = { x = 3.781727, y = 6.382332, z = -13.48037 }, randomPos = 1, randomRadius = 500, monsters = { 150512,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[113203] = {	id = 113203, pos = { x = 3.781727, y = 6.382332, z = -13.48037 }, randomPos = 1, randomRadius = 500, monsters = { 150513,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[113204] = {	id = 113204, pos = { x = 3.781727, y = 6.382332, z = -13.48037 }, randomPos = 0, randomRadius = 0, monsters = { 150514,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[113205] = {	id = 113205, pos = { x = 3.781727, y = 6.382332, z = -13.48037 }, randomPos = 0, randomRadius = 0, monsters = { 150515,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[113301] = {	id = 113301, pos = { x = 70.75948, y = 1.805698, z = -6.863749 }, randomPos = 1, randomRadius = 500, monsters = { 150516,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[113302] = {	id = 113302, pos = { x = 75.21833, y = 2.2057, z = 44.91099 }, randomPos = 1, randomRadius = 500, monsters = { 150517,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[113303] = {	id = 113303, pos = { x = 63.95085, y = 2.544952, z = 97.19308 }, randomPos = 1, randomRadius = 500, monsters = { 150518,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[113304] = {	id = 113304, pos = { x = 66.53209, y = 2.605701, z = 100.6007 }, randomPos = 0, randomRadius = 0, monsters = { 150519,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
