----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[220401] = {	id = 220401, pos = { x = 66.86937, y = 2.351528, z = 51.97364 }, randomPos = 0, randomRadius = 0, monsters = { 90115,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[220402] = {	id = 220402, pos = { x = 66.79874, y = 2.351528, z = 47.77135 }, randomPos = 0, randomRadius = 0, monsters = { 90114,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[220403] = {	id = 220403, pos = { x = 69.21365, y = 2.351528, z = 53.13522 }, randomPos = 0, randomRadius = 0, monsters = { 90114,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[220404] = {	id = 220404, pos = { x = 69.19428, y = 2.351528, z = 47.27787 }, randomPos = 0, randomRadius = 0, monsters = { 90114,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[220405] = {	id = 220405, pos = { x = 71.61644, y = 2.351528, z = 51.41225 }, randomPos = 0, randomRadius = 0, monsters = { 90114,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[220406] = {	id = 220406, pos = { x = 70.5773, y = 2.351528, z = 49.1117 }, randomPos = 0, randomRadius = 0, monsters = { 90111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[220407] = {	id = 220407, pos = { x = 68.1616, y = 2.351528, z = 51.04689 }, randomPos = 0, randomRadius = 0, monsters = { 90111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[220501] = {	id = 220501, pos = { x = 65.37045, y = 2.617527, z = 99.12891 }, randomPos = 0, randomRadius = 0, monsters = { 90116,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[220502] = {	id = 220502, pos = { x = 63.18444, y = 2.551529, z = 102.9486 }, randomPos = 0, randomRadius = 0, monsters = { 90111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[220503] = {	id = 220503, pos = { x = 66.96583, y = 2.706298, z = 101.6028 }, randomPos = 0, randomRadius = 0, monsters = { 90111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[220504] = {	id = 220504, pos = { x = 63.14716, y = 2.551529, z = 105.2542 }, randomPos = 0, randomRadius = 0, monsters = { 90111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[220505] = {	id = 220505, pos = { x = 68.01547, y = 2.75153, z = 102.8549 }, randomPos = 0, randomRadius = 0, monsters = { 90111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[220506] = {	id = 220506, pos = { x = 59.68249, y = 2.551529, z = 102.7511 }, randomPos = 0, randomRadius = 0, monsters = { 90112,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[220507] = {	id = 220507, pos = { x = 69.85726, y = 2.75153, z = 100.5411 }, randomPos = 0, randomRadius = 0, monsters = { 90112,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
