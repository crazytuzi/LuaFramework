----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[22801] = {	id = 22801, pos = { x = 122.9664, y = 10.29451, z = -15.33317 }, randomPos = 1, randomRadius = 600, monsters = { 89281,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22802] = {	id = 22802, pos = { x = 81.23296, y = 14.73398, z = 4.318544 }, randomPos = 1, randomRadius = 600, monsters = { 89282,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22803] = {	id = 22803, pos = { x = 75.175, y = 12.94759, z = -17.98926 }, randomPos = 1, randomRadius = 600, monsters = { 89283,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22804] = {	id = 22804, pos = { x = 112.0324, y = 7.294509, z = -57.67727 }, randomPos = 1, randomRadius = 600, monsters = { 89284,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22901] = {	id = 22901, pos = { x = 65.487, y = 2.2057, z = 50.44133 }, randomPos = 1, randomRadius = 600, monsters = { 89291,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22902] = {	id = 22902, pos = { x = 80.62442, y = 2.2057, z = 42.73444 }, randomPos = 1, randomRadius = 600, monsters = { 89292,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22903] = {	id = 22903, pos = { x = 73.8774, y = 1.805698, z = -2.938965 }, randomPos = 1, randomRadius = 600, monsters = { 89293,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22904] = {	id = 22904, pos = { x = 64.55431, y = 1.605698, z = -45.07465 }, randomPos = 0, randomRadius = 600, monsters = { 89294,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
