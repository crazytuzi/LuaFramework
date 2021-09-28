----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[37201] = {	id = 37201, pos = { x = 147.5727, y = 30.08202, z = 96.2318 }, randomPos = 1, randomRadius = 500, monsters = { 87703,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37202] = {	id = 37202, pos = { x = 79.53854, y = 20.08202, z = 26.9606 }, randomPos = 1, randomRadius = 500, monsters = { 87703,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37203] = {	id = 37203, pos = { x = 3.014353, y = 10.08202, z = -15.87737 }, randomPos = 1, randomRadius = 500, monsters = { 87703,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37204] = {	id = 37204, pos = { x = -4.602901, y = 0.0820236, z = -157.9835 }, randomPos = 1, randomRadius = 500, monsters = { 87703,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37205] = {	id = 37205, pos = { x = -102.5199, y = 2.189407, z = -88.70348 }, randomPos = 1, randomRadius = 500, monsters = { 87703,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37206] = {	id = 37206, pos = { x = -55.91936, y = 5.082024, z = -20.05017 }, randomPos = 1, randomRadius = 500, monsters = { 87703,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37301] = {	id = 37301, pos = { x = -16.62751, y = 10.08202, z = -7.574053 }, randomPos = 1, randomRadius = 200, monsters = { 87704,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37302] = {	id = 37302, pos = { x = -20.57562, y = 17.40279, z = 107.0777 }, randomPos = 1, randomRadius = 200, monsters = { 87704,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37303] = {	id = 37303, pos = { x = 149.6105, y = 30.08202, z = 98.29446 }, randomPos = 1, randomRadius = 200, monsters = { 87704,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37304] = {	id = 37304, pos = { x = 4.228863, y = 5.082024, z = -83.73257 }, randomPos = 1, randomRadius = 200, monsters = { 87704,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
