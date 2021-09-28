----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[23201] = {	id = 23201, pos = { x = 56.3052, y = 12.82616, z = 94.06715 }, randomPos = 1, randomRadius = 600, monsters = { 89321,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23202] = {	id = 23202, pos = { x = 22.72044, y = 7.772827, z = 60.16637 }, randomPos = 1, randomRadius = 600, monsters = { 89322,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23301] = {	id = 23301, pos = { x = 67.3373, y = 2.2057, z = 49.56418 }, randomPos = 1, randomRadius = 300, monsters = { 89331,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23302] = {	id = 23302, pos = { x = 79.75198, y = 2.2057, z = 38.1354 }, randomPos = 1, randomRadius = 300, monsters = { 89332,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23303] = {	id = 23303, pos = { x = 74.46986, y = 1.805698, z = 0.0160064 }, randomPos = 1, randomRadius = 300, monsters = { 89333,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23304] = {	id = 23304, pos = { x = 64.9858, y = 1.805698, z = -10.62062 }, randomPos = 1, randomRadius = 300, monsters = { 89334,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23305] = {	id = 23305, pos = { x = 62.32401, y = 1.605698, z = -47.53673 }, randomPos = 1, randomRadius = 300, monsters = { 89335,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
