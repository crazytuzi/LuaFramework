----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[35201] = {	id = 35201, pos = { x = -54.34615, y = 0.2000002, z = -116.6829 }, randomPos = 1, randomRadius = 500, monsters = { 87603,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35202] = {	id = 35202, pos = { x = -77.33292, y = 0.2000002, z = -98.42267 }, randomPos = 1, randomRadius = 500, monsters = { 87603,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35203] = {	id = 35203, pos = { x = -90.03542, y = 7.0, z = 24.26954 }, randomPos = 1, randomRadius = 500, monsters = { 87603,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35204] = {	id = 35204, pos = { x = -15.31511, y = 0.3392574, z = -131.4478 }, randomPos = 1, randomRadius = 500, monsters = { 87603,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35205] = {	id = 35205, pos = { x = 33.07169, y = 5.0, z = -55.78758 }, randomPos = 1, randomRadius = 500, monsters = { 87603,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35206] = {	id = 35206, pos = { x = 57.03467, y = 13.04628, z = 12.70047 }, randomPos = 1, randomRadius = 500, monsters = { 87603,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35301] = {	id = 35301, pos = { x = 10.98357, y = 13.93217, z = 39.58616 }, randomPos = 1, randomRadius = 200, monsters = { 87604,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35302] = {	id = 35302, pos = { x = -38.81474, y = 7.0, z = 31.11603 }, randomPos = 1, randomRadius = 200, monsters = { 87604,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35303] = {	id = 35303, pos = { x = -78.07594, y = 7.0, z = -5.018855 }, randomPos = 1, randomRadius = 200, monsters = { 87604,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35304] = {	id = 35304, pos = { x = -49.67543, y = 0.2000002, z = -106.458 }, randomPos = 1, randomRadius = 200, monsters = { 87604,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
