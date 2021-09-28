----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[210201] = {	id = 210201, pos = { x = 71.34823, y = 1.951529, z = -5.735794 }, randomPos = 0, randomRadius = 0, monsters = { 90104,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[210202] = {	id = 210202, pos = { x = 71.31445, y = 1.951529, z = -0.8414631 }, randomPos = 0, randomRadius = 0, monsters = { 90104,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[210203] = {	id = 210203, pos = { x = 66.38068, y = 1.951529, z = -4.126486 }, randomPos = 0, randomRadius = 0, monsters = { 90104,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[210204] = {	id = 210204, pos = { x = 74.52656, y = 1.951529, z = -6.848953 }, randomPos = 0, randomRadius = 0, monsters = { 90104,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[210301] = {	id = 210301, pos = { x = 78.79801, y = 2.387988, z = 37.38511 }, randomPos = 0, randomRadius = 0, monsters = { 90102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[210302] = {	id = 210302, pos = { x = 83.24048, y = 2.413538, z = 36.44903 }, randomPos = 0, randomRadius = 0, monsters = { 90102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[210303] = {	id = 210303, pos = { x = 77.42556, y = 2.418535, z = 41.47647 }, randomPos = 0, randomRadius = 0, monsters = { 90102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[210304] = {	id = 210304, pos = { x = 82.38053, y = 2.457347, z = 40.00407 }, randomPos = 0, randomRadius = 0, monsters = { 90102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
