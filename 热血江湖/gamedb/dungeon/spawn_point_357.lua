----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[71401] = {	id = 71401, pos = { x = 98.41638, y = 7.294509, z = -62.408 }, randomPos = 0, randomRadius = 600, monsters = { 61755,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[71402] = {	id = 71402, pos = { x = 98.41638, y = 7.294509, z = -62.408 }, randomPos = 0, randomRadius = 600, monsters = { 61755,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[71403] = {	id = 71403, pos = { x = 98.41638, y = 7.294509, z = -62.408 }, randomPos = 0, randomRadius = 600, monsters = { 61755,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[71404] = {	id = 71404, pos = { x = 98.41638, y = 7.294509, z = -62.408 }, randomPos = 0, randomRadius = 600, monsters = { 61755,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[71405] = {	id = 71405, pos = { x = 98.41638, y = 7.294509, z = -62.408 }, randomPos = 0, randomRadius = 600, monsters = { 61755,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[71406] = {	id = 71406, pos = { x = 98.41638, y = 7.294509, z = -62.408 }, randomPos = 0, randomRadius = 600, monsters = { 61755,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
