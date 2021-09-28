----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[35801] = {	id = 35801, pos = { x = -26.07948, y = 0.2000002, z = -124.1166 }, randomPos = 1, randomRadius = 500, monsters = { 87609,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35802] = {	id = 35802, pos = { x = -104.1193, y = 0.2000002, z = -96.01991 }, randomPos = 1, randomRadius = 500, monsters = { 87609,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35803] = {	id = 35803, pos = { x = -57.55246, y = 0.2000002, z = -106.7038 }, randomPos = 1, randomRadius = 500, monsters = { 87609,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35804] = {	id = 35804, pos = { x = -42.58179, y = 5.061088, z = -35.27225 }, randomPos = 1, randomRadius = 500, monsters = { 87609,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35805] = {	id = 35805, pos = { x = -92.85794, y = 7.0, z = 21.6005 }, randomPos = 1, randomRadius = 500, monsters = { 87609,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35806] = {	id = 35806, pos = { x = 11.10398, y = 13.88565, z = 40.86336 }, randomPos = 1, randomRadius = 500, monsters = { 87609,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35901] = {	id = 35901, pos = { x = -32.23615, y = 5.0, z = -55.60547 }, randomPos = 1, randomRadius = 100, monsters = { 87610,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35902] = {	id = 35902, pos = { x = 12.42404, y = 13.95385, z = 37.5062 }, randomPos = 1, randomRadius = 100, monsters = { 87610,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
