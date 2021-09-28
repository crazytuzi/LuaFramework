----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[21101] = {	id = 21101, pos = { x = -40.48352, y = 0.4573991, z = -30.18163 }, randomPos = 1, randomRadius = 600, monsters = { 89111,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[21102] = {	id = 21102, pos = { x = 15.61019, y = 3.163843, z = 115.2035 }, randomPos = 1, randomRadius = 600, monsters = { 89112,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[21103] = {	id = 21103, pos = { x = 50.40238, y = 0.390969, z = -87.50786 }, randomPos = 1, randomRadius = 600, monsters = { 89113,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[21104] = {	id = 21104, pos = { x = 21.60832, y = 3.074904, z = 61.28095 }, randomPos = 0, randomRadius = 600, monsters = { 89114,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[21105] = {	id = 21105, pos = { x = 95.71555, y = 0.1638422, z = -44.1147 }, randomPos = 1, randomRadius = 600, monsters = { 89115,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[21106] = {	id = 21106, pos = { x = 21.77786, y = 0.1638422, z = -83.56438 }, randomPos = 1, randomRadius = 600, monsters = { 89116,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
