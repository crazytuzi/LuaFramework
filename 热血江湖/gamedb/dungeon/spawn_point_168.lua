----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[33601] = {	id = 33601, pos = { x = 104.7825, y = 22.2676, z = -20.52267 }, randomPos = 1, randomRadius = 200, monsters = { 87507,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33602] = {	id = 33602, pos = { x = 25.33816, y = 16.16542, z = -30.96966 }, randomPos = 1, randomRadius = 200, monsters = { 87507,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33603] = {	id = 33603, pos = { x = 20.78003, y = 11.16542, z = -91.83228 }, randomPos = 1, randomRadius = 200, monsters = { 87507,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33604] = {	id = 33604, pos = { x = 74.82048, y = 6.165421, z = -95.41901 }, randomPos = 1, randomRadius = 200, monsters = { 87507,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33701] = {	id = 33701, pos = { x = 105.5858, y = 22.26099, z = -23.9244 }, randomPos = 1, randomRadius = 500, monsters = { 87508,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33702] = {	id = 33702, pos = { x = 113.3029, y = 22.34307, z = 13.17173 }, randomPos = 1, randomRadius = 500, monsters = { 87508,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33703] = {	id = 33703, pos = { x = 113.8125, y = 30.16542, z = 84.01088 }, randomPos = 1, randomRadius = 500, monsters = { 87508,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33704] = {	id = 33704, pos = { x = 88.35606, y = 30.16542, z = 109.6904 }, randomPos = 1, randomRadius = 500, monsters = { 87508,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33705] = {	id = 33705, pos = { x = 55.62558, y = 32.36542, z = 99.62706 }, randomPos = 1, randomRadius = 500, monsters = { 87508,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33706] = {	id = 33706, pos = { x = 0.4359741, y = 32.36542, z = 103.4719 }, randomPos = 1, randomRadius = 500, monsters = { 87508,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
