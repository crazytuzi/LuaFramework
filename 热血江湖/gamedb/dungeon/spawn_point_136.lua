----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[27201] = {	id = 27201, pos = { x = 11.00378, y = 11.65138, z = -73.9537 }, randomPos = 1, randomRadius = 500, monsters = { 87203,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27202] = {	id = 27202, pos = { x = 54.77692, y = 13.43072, z = -22.31078 }, randomPos = 1, randomRadius = 500, monsters = { 87203,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27203] = {	id = 27203, pos = { x = 17.83704, y = 13.27988, z = 14.62908 }, randomPos = 1, randomRadius = 500, monsters = { 87203,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27204] = {	id = 27204, pos = { x = 66.72104, y = 20.67212, z = 42.02144 }, randomPos = 1, randomRadius = 500, monsters = { 87203,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27205] = {	id = 27205, pos = { x = 88.75452, y = 2.73953, z = -50.82665 }, randomPos = 1, randomRadius = 500, monsters = { 87203,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27206] = {	id = 27206, pos = { x = -22.98429, y = 13.27988, z = -7.496792 }, randomPos = 1, randomRadius = 500, monsters = { 87203,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27301] = {	id = 27301, pos = { x = -16.67482, y = 13.27988, z = -10.98902 }, randomPos = 1, randomRadius = 200, monsters = { 87204,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27302] = {	id = 27302, pos = { x = 10.20305, y = 11.6214, z = -74.35806 }, randomPos = 1, randomRadius = 200, monsters = { 87204,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27303] = {	id = 27303, pos = { x = 88.62429, y = 2.744729, z = -50.50016 }, randomPos = 1, randomRadius = 200, monsters = { 87204,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27304] = {	id = 27304, pos = { x = 33.9579, y = 19.77996, z = 106.3264 }, randomPos = 1, randomRadius = 200, monsters = { 87204,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
