----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[650201] = {	id = 650201, pos = { x = 63.28693, y = 19.02103, z = 41.94324 }, randomPos = 0, randomRadius = 0, monsters = { 92103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[650202] = {	id = 650202, pos = { x = 55.69528, y = 18.99218, z = 52.3964 }, randomPos = 0, randomRadius = 0, monsters = { 92103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[650203] = {	id = 650203, pos = { x = 66.60029, y = 18.99218, z = 49.61553 }, randomPos = 0, randomRadius = 0, monsters = { 92101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[650204] = {	id = 650204, pos = { x = 57.32549, y = 18.99218, z = 58.2767 }, randomPos = 0, randomRadius = 0, monsters = { 92101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[650205] = {	id = 650205, pos = { x = 63.19651, y = 18.99218, z = 55.203 }, randomPos = 0, randomRadius = 0, monsters = { 92101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[650206] = {	id = 650206, pos = { x = 66.90061, y = 19.03789, z = 41.53233 }, randomPos = 0, randomRadius = 0, monsters = { 92105,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[650207] = {	id = 650207, pos = { x = 58.15034, y = 18.99218, z = 65.7421 }, randomPos = 0, randomRadius = 0, monsters = { 92105,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[650301] = {	id = 650301, pos = { x = 70.0079, y = 18.99218, z = 51.2891 }, randomPos = 0, randomRadius = 0, monsters = { 92102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[650302] = {	id = 650302, pos = { x = 73.33154, y = 18.99218, z = 62.33663 }, randomPos = 0, randomRadius = 0, monsters = { 92102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[650303] = {	id = 650303, pos = { x = 64.19637, y = 18.99218, z = 59.43465 }, randomPos = 0, randomRadius = 0, monsters = { 92101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[650304] = {	id = 650304, pos = { x = 62.9417, y = 18.99218, z = 66.72958 }, randomPos = 0, randomRadius = 0, monsters = { 92101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[650305] = {	id = 650305, pos = { x = 58.17233, y = 18.99218, z = 61.04068 }, randomPos = 0, randomRadius = 0, monsters = { 92101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[650306] = {	id = 650306, pos = { x = 86.36903, y = 18.8791, z = 73.07561 }, randomPos = 0, randomRadius = 0, monsters = { 92105,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[650307] = {	id = 650307, pos = { x = 52.92601, y = 27.01252, z = 109.1741 }, randomPos = 0, randomRadius = 0, monsters = { 92105,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
