----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[37801] = {	id = 37801, pos = { x = -8.59626, y = 0.0820236, z = -151.684 }, randomPos = 1, randomRadius = 500, monsters = { 87709,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37802] = {	id = 37802, pos = { x = -16.42593, y = 3.014866, z = -111.4079 }, randomPos = 1, randomRadius = 500, monsters = { 87709,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37803] = {	id = 37803, pos = { x = -37.62877, y = 3.149582, z = -57.52565 }, randomPos = 1, randomRadius = 500, monsters = { 87709,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37804] = {	id = 37804, pos = { x = 35.99957, y = 17.08202, z = 152.2837 }, randomPos = 1, randomRadius = 500, monsters = { 87709,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37805] = {	id = 37805, pos = { x = 80.89746, y = 20.08202, z = 27.27396 }, randomPos = 1, randomRadius = 500, monsters = { 87709,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37806] = {	id = 37806, pos = { x = -122.5154, y = 2.204174, z = -34.49265 }, randomPos = 1, randomRadius = 500, monsters = { 87709,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37901] = {	id = 37901, pos = { x = 60.72278, y = 17.17327, z = 124.046 }, randomPos = 1, randomRadius = 100, monsters = { 87710,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37902] = {	id = 37902, pos = { x = -7.914661, y = 0.0820236, z = -158.3585 }, randomPos = 1, randomRadius = 100, monsters = { 87710,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
