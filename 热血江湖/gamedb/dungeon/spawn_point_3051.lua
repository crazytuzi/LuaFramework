----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[610201] = {	id = 610201, pos = { x = -13.27914, y = 6.965301, z = -6.911314 }, randomPos = 0, randomRadius = 0, monsters = { 90901,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[610202] = {	id = 610202, pos = { x = -5.861225, y = 6.965301, z = -4.938256 }, randomPos = 0, randomRadius = 0, monsters = { 90901,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[610203] = {	id = 610203, pos = { x = -6.575807, y = 6.965301, z = -7.466388 }, randomPos = 0, randomRadius = 0, monsters = { 90901,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[610204] = {	id = 610204, pos = { x = -12.68802, y = 6.965301, z = -4.224905 }, randomPos = 0, randomRadius = 0, monsters = { 90903,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[610205] = {	id = 610205, pos = { x = -9.406861, y = 6.965301, z = -2.254099 }, randomPos = 0, randomRadius = 0, monsters = { 90903,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[610206] = {	id = 610206, pos = { x = -10.36542, y = 6.965301, z = -5.372265 }, randomPos = 0, randomRadius = 0, monsters = { 90903,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[610301] = {	id = 610301, pos = { x = 25.12821, y = 6.965291, z = -44.32785 }, randomPos = 0, randomRadius = 0, monsters = { 90903,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[610302] = {	id = 610302, pos = { x = 28.76334, y = 6.965291, z = -40.09745 }, randomPos = 0, randomRadius = 0, monsters = { 90903,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[610303] = {	id = 610303, pos = { x = 23.20079, y = 6.965291, z = -37.8186 }, randomPos = 0, randomRadius = 0, monsters = { 90903,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[610304] = {	id = 610304, pos = { x = 31.31644, y = 6.965291, z = -40.44229 }, randomPos = 0, randomRadius = 0, monsters = { 90902,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[610305] = {	id = 610305, pos = { x = 30.87471, y = 6.965291, z = -45.61926 }, randomPos = 0, randomRadius = 0, monsters = { 90902,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[610306] = {	id = 610306, pos = { x = 31.73776, y = 6.965291, z = -37.1134 }, randomPos = 0, randomRadius = 0, monsters = { 90902,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
