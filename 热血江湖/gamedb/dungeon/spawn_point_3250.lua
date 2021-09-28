----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[650101] = {	id = 650101, pos = { x = 69.39476, y = 18.99218, z = -61.22455 }, randomPos = 0, randomRadius = 0, monsters = { 92102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[650102] = {	id = 650102, pos = { x = 62.9645, y = 18.95472, z = -65.02735 }, randomPos = 0, randomRadius = 0, monsters = { 92102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[650103] = {	id = 650103, pos = { x = 63.19544, y = 18.92208, z = -55.33933 }, randomPos = 0, randomRadius = 0, monsters = { 92102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[650104] = {	id = 650104, pos = { x = 58.22932, y = 18.89001, z = -56.56459 }, randomPos = 0, randomRadius = 0, monsters = { 92103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[650105] = {	id = 650105, pos = { x = 63.00386, y = 18.92066, z = -59.8969 }, randomPos = 0, randomRadius = 0, monsters = { 92103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
