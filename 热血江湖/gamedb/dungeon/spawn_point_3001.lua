----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[600201] = {	id = 600201, pos = { x = 25.34258, y = 6.965291, z = -38.32049 }, randomPos = 0, randomRadius = 0, monsters = { 90801,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[600202] = {	id = 600202, pos = { x = 27.70338, y = 6.965291, z = -40.06818 }, randomPos = 0, randomRadius = 0, monsters = { 90801,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[600203] = {	id = 600203, pos = { x = 32.53761, y = 6.965291, z = -35.65936 }, randomPos = 0, randomRadius = 0, monsters = { 90803,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[600204] = {	id = 600204, pos = { x = 31.86193, y = 6.965291, z = -42.43113 }, randomPos = 0, randomRadius = 0, monsters = { 90803,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[600301] = {	id = 600301, pos = { x = 37.87031, y = 6.965291, z = -19.01727 }, randomPos = 0, randomRadius = 0, monsters = { 90803,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[600302] = {	id = 600302, pos = { x = 38.96432, y = 6.965291, z = -21.48221 }, randomPos = 0, randomRadius = 0, monsters = { 90803,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[600303] = {	id = 600303, pos = { x = 39.28077, y = 6.965291, z = -15.75005 }, randomPos = 0, randomRadius = 0, monsters = { 90802,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[600304] = {	id = 600304, pos = { x = 40.82919, y = 6.965291, z = -18.12137 }, randomPos = 0, randomRadius = 0, monsters = { 90802,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
