----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[113401] = {	id = 113401, pos = { x = 70.75948, y = 1.805698, z = -6.863749 }, randomPos = 1, randomRadius = 500, monsters = { 150520,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[113402] = {	id = 113402, pos = { x = 75.21833, y = 2.2057, z = 44.91099 }, randomPos = 1, randomRadius = 500, monsters = { 150521,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[113403] = {	id = 113403, pos = { x = 63.95085, y = 2.544952, z = 97.19308 }, randomPos = 1, randomRadius = 500, monsters = { 150522,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[113404] = {	id = 113404, pos = { x = 66.53209, y = 2.605701, z = 100.6007 }, randomPos = 0, randomRadius = 0, monsters = { 150523,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[113405] = {	id = 113405, pos = { x = 69.11705, y = 2.550242, z = 103.1671 }, randomPos = 0, randomRadius = 0, monsters = { 150524,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[113501] = {	id = 113501, pos = { x = 80.1581, y = 14.63206, z = 3.828178 }, randomPos = 1, randomRadius = 500, monsters = { 150525,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[113502] = {	id = 113502, pos = { x = 121.835, y = 10.54602, z = -10.3216 }, randomPos = 1, randomRadius = 500, monsters = { 150526,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[113503] = {	id = 113503, pos = { x = 110.0486, y = 7.294509, z = -57.62038 }, randomPos = 1, randomRadius = 500, monsters = { 150527,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[113504] = {	id = 113504, pos = { x = 108.2866, y = 7.294509, z = -62.05363 }, randomPos = 0, randomRadius = 0, monsters = { 150528,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
