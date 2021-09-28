----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[390201] = {	id = 390201, pos = { x = 80.82711, y = 14.7945, z = 7.897295 }, randomPos = 0, randomRadius = 0, monsters = { 90501,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[390202] = {	id = 390202, pos = { x = 84.18198, y = 14.7945, z = 8.297731 }, randomPos = 0, randomRadius = 0, monsters = { 90501,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[390203] = {	id = 390203, pos = { x = 85.39666, y = 14.7945, z = 9.011191 }, randomPos = 0, randomRadius = 0, monsters = { 90502,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[390204] = {	id = 390204, pos = { x = 80.65741, y = 14.7945, z = 7.299379 }, randomPos = 0, randomRadius = 0, monsters = { 90502,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[390205] = {	id = 390205, pos = { x = 82.08078, y = 14.7945, z = 7.988289 }, randomPos = 0, randomRadius = 0, monsters = { 90503,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[390301] = {	id = 390301, pos = { x = 118.934, y = 10.50101, z = -17.59789 }, randomPos = 0, randomRadius = 0, monsters = { 90501,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[390302] = {	id = 390302, pos = { x = 122.145, y = 10.46329, z = -21.3424 }, randomPos = 0, randomRadius = 0, monsters = { 90501,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[390303] = {	id = 390303, pos = { x = 118.0223, y = 10.51052, z = -20.69215 }, randomPos = 0, randomRadius = 0, monsters = { 90504,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[390304] = {	id = 390304, pos = { x = 122.6464, y = 10.4574, z = -17.76442 }, randomPos = 0, randomRadius = 0, monsters = { 90504,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
