----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[590101] = {	id = 590101, pos = { x = -3.420989, y = 0.1966242, z = -32.75 }, randomPos = 0, randomRadius = 0, monsters = { 90731,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[590102] = {	id = 590102, pos = { x = -1.732322, y = 0.1966242, z = -32.48232 }, randomPos = 0, randomRadius = 0, monsters = { 90731,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[590103] = {	id = 590103, pos = { x = 1.067593, y = 0.1966242, z = -32.5651 }, randomPos = 0, randomRadius = 0, monsters = { 90731,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[590104] = {	id = 590104, pos = { x = 4.054197, y = 0.1966242, z = -32.75 }, randomPos = 0, randomRadius = 0, monsters = { 90731,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[590105] = {	id = 590105, pos = { x = 5.543104, y = 0.1966242, z = -33.2931 }, randomPos = 0, randomRadius = 0, monsters = { 90731,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[590106] = {	id = 590106, pos = { x = -2.662659, y = 0.1966242, z = -33.78558 }, randomPos = 0, randomRadius = 0, monsters = { 90731,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[590107] = {	id = 590107, pos = { x = -0.8888779, y = 0.1966242, z = -33.16827 }, randomPos = 0, randomRadius = 0, monsters = { 90731,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[590108] = {	id = 590108, pos = { x = 2.388624, y = 0.1966242, z = -33.29136 }, randomPos = 0, randomRadius = 0, monsters = { 90731,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
