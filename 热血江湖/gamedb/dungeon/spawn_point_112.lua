----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[22401] = {	id = 22401, pos = { x = 71.22076, y = 0.1638422, z = -77.47671 }, randomPos = 1, randomRadius = 600, monsters = { 89241,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22402] = {	id = 22402, pos = { x = 79.75419, y = 3.163843, z = -131.0095 }, randomPos = 1, randomRadius = 600, monsters = { 89242,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22403] = {	id = 22403, pos = { x = 6.648874, y = 0.1638422, z = -77.62521 }, randomPos = 0, randomRadius = 0, monsters = { 89243,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22404] = {	id = 22404, pos = { x = 30.92081, y = -8.836158, z = -25.62401 }, randomPos = 1, randomRadius = 600, monsters = { 89244,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22501] = {	id = 22501, pos = { x = -36.64246, y = 7.0, z = 31.51349 }, randomPos = 1, randomRadius = 600, monsters = { 89251,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22502] = {	id = 22502, pos = { x = -89.85524, y = 7.0, z = 2.261791 }, randomPos = 1, randomRadius = 600, monsters = { 89252,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22503] = {	id = 22503, pos = { x = -41.63298, y = 5.088222, z = -37.3307 }, randomPos = 1, randomRadius = 600, monsters = { 89253,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22504] = {	id = 22504, pos = { x = 25.82005, y = 5.0, z = -57.47293 }, randomPos = 1, randomRadius = 600, monsters = { 89254,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
