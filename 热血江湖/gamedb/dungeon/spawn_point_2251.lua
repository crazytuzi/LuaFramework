----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[450201] = {	id = 450201, pos = { x = 0.4832573, y = 6.12879, z = -5.15468 }, randomPos = 0, randomRadius = 0, monsters = { 90403,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[450202] = {	id = 450202, pos = { x = 8.940291, y = 6.144663, z = -2.882627 }, randomPos = 0, randomRadius = 0, monsters = { 90403,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[450203] = {	id = 450203, pos = { x = 13.6403, y = 6.34109, z = 3.113354 }, randomPos = 0, randomRadius = 0, monsters = { 90402,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[450204] = {	id = 450204, pos = { x = 14.88052, y = 6.337579, z = 7.601436 }, randomPos = 0, randomRadius = 0, monsters = { 90402,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[450301] = {	id = 450301, pos = { x = -8.646791, y = 6.450637, z = 10.85027 }, randomPos = 0, randomRadius = 0, monsters = { 90403,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[450302] = {	id = 450302, pos = { x = 4.013134, y = 6.43128, z = 19.03534 }, randomPos = 0, randomRadius = 0, monsters = { 90403,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[450303] = {	id = 450303, pos = { x = 5.591589, y = 6.148222, z = -2.495543 }, randomPos = 0, randomRadius = 0, monsters = { 90404,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[450304] = {	id = 450304, pos = { x = 13.97777, y = 6.334616, z = 1.982095 }, randomPos = 0, randomRadius = 0, monsters = { 90404,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
