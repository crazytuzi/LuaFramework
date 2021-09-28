----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[33801] = {	id = 33801, pos = { x = 21.56474, y = 16.16542, z = -39.72803 }, randomPos = 1, randomRadius = 500, monsters = { 87509,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33802] = {	id = 33802, pos = { x = -22.35918, y = 13.16542, z = -63.67163 }, randomPos = 1, randomRadius = 500, monsters = { 87509,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33803] = {	id = 33803, pos = { x = 19.89591, y = 11.16542, z = -94.34294 }, randomPos = 1, randomRadius = 500, monsters = { 87509,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33804] = {	id = 33804, pos = { x = -26.97614, y = 15.25428, z = -15.64236 }, randomPos = 1, randomRadius = 500, monsters = { 87509,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33805] = {	id = 33805, pos = { x = 99.78142, y = 22.16542, z = 1.857236 }, randomPos = 1, randomRadius = 500, monsters = { 87509,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33806] = {	id = 33806, pos = { x = 114.7705, y = 25.21199, z = 40.10547 }, randomPos = 1, randomRadius = 500, monsters = { 87509,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33901] = {	id = 33901, pos = { x = 31.37355, y = 28.76542, z = 43.88175 }, randomPos = 1, randomRadius = 100, monsters = { 87510,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33902] = {	id = 33902, pos = { x = 29.22148, y = 32.36542, z = 90.05716 }, randomPos = 1, randomRadius = 100, monsters = { 87510,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
