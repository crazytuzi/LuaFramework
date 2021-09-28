----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[650401] = {	id = 650401, pos = { x = -33.66712, y = 28.79218, z = 120.2416 }, randomPos = 0, randomRadius = 0, monsters = { 92103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[650402] = {	id = 650402, pos = { x = -46.16264, y = 28.79218, z = 111.7973 }, randomPos = 0, randomRadius = 0, monsters = { 92103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[650403] = {	id = 650403, pos = { x = -46.21005, y = 28.79218, z = 131.6779 }, randomPos = 0, randomRadius = 0, monsters = { 92101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[650404] = {	id = 650404, pos = { x = -41.96555, y = 28.79218, z = 121.3305 }, randomPos = 0, randomRadius = 0, monsters = { 92101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[650405] = {	id = 650405, pos = { x = -41.12408, y = 28.79218, z = 114.9708 }, randomPos = 0, randomRadius = 0, monsters = { 92101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[650406] = {	id = 650406, pos = { x = -35.22276, y = 28.79218, z = 111.8556 }, randomPos = 0, randomRadius = 0, monsters = { 92105,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[650407] = {	id = 650407, pos = { x = -52.21683, y = 28.79218, z = 131.3664 }, randomPos = 0, randomRadius = 0, monsters = { 92105,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[650408] = {	id = 650408, pos = { x = -47.02446, y = 28.79218, z = 121.6514 }, randomPos = 0, randomRadius = 0, monsters = { 92104,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
