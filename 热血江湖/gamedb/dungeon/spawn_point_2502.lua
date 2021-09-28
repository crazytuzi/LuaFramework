----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[500401] = {	id = 500401, pos = { x = 35.51321, y = 13.96042, z = -8.444727 }, randomPos = 0, randomRadius = 0, monsters = { 90609,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[500402] = {	id = 500402, pos = { x = 35.15428, y = 13.96287, z = -10.9722 }, randomPos = 0, randomRadius = 0, monsters = { 90607,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[500403] = {	id = 500403, pos = { x = 37.05938, y = 13.8789, z = -11.32247 }, randomPos = 0, randomRadius = 0, monsters = { 90607,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[500404] = {	id = 500404, pos = { x = 37.10925, y = 13.95854, z = -6.682499 }, randomPos = 0, randomRadius = 0, monsters = { 90608,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[500405] = {	id = 500405, pos = { x = 37.12051, y = 13.90281, z = -9.053425 }, randomPos = 0, randomRadius = 0, monsters = { 90608,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
