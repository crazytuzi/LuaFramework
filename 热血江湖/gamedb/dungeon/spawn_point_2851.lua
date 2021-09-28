----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[570201] = {	id = 570201, pos = { x = -3.872702, y = 8.250731, z = -1.387947 }, randomPos = 0, randomRadius = 0, monsters = { 90711,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[570202] = {	id = 570202, pos = { x = 0.7529495, y = 8.627146, z = -1.673955 }, randomPos = 0, randomRadius = 0, monsters = { 90711,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[570203] = {	id = 570203, pos = { x = 4.763494, y = 8.563156, z = -1.838882 }, randomPos = 0, randomRadius = 0, monsters = { 90711,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[570204] = {	id = 570204, pos = { x = -3.377045, y = 8.193416, z = 4.915325 }, randomPos = 0, randomRadius = 0, monsters = { 90712,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[570205] = {	id = 570205, pos = { x = 0.8975111, y = 8.892256, z = 3.382736 }, randomPos = 0, randomRadius = 0, monsters = { 90712,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[570206] = {	id = 570206, pos = { x = 4.058847, y = 8.598445, z = 4.605002 }, randomPos = 0, randomRadius = 0, monsters = { 90712,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[570301] = {	id = 570301, pos = { x = 33.91296, y = 2.981166, z = 31.90339 }, randomPos = 0, randomRadius = 0, monsters = { 90712,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[570302] = {	id = 570302, pos = { x = 40.73627, y = 2.841313, z = 32.0 }, randomPos = 0, randomRadius = 0, monsters = { 90712,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[570303] = {	id = 570303, pos = { x = 39.42726, y = 2.958933, z = 35.15857 }, randomPos = 0, randomRadius = 0, monsters = { 90712,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[570304] = {	id = 570304, pos = { x = 37.75584, y = 3.024993, z = 36.07541 }, randomPos = 0, randomRadius = 0, monsters = { 90713,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[570305] = {	id = 570305, pos = { x = 37.41403, y = 3.129582, z = 30.85557 }, randomPos = 0, randomRadius = 0, monsters = { 90713,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[570306] = {	id = 570306, pos = { x = 35.37679, y = 2.996625, z = 35.07541 }, randomPos = 0, randomRadius = 0, monsters = { 90713,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
