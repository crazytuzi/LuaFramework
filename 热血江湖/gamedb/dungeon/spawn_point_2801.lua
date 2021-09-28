----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[560201] = {	id = 560201, pos = { x = -3.592399, y = 8.386065, z = 1.264946 }, randomPos = 0, randomRadius = 0, monsters = { 90701,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[560202] = {	id = 560202, pos = { x = 4.893593, y = 8.605858, z = 2.191628 }, randomPos = 0, randomRadius = 0, monsters = { 90701,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[560203] = {	id = 560203, pos = { x = 1.037706, y = 8.433211, z = -3.585737 }, randomPos = 0, randomRadius = 0, monsters = { 90702,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[560204] = {	id = 560204, pos = { x = 0.7475831, y = 8.750172, z = 0.2509098 }, randomPos = 0, randomRadius = 0, monsters = { 90702,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[560301] = {	id = 560301, pos = { x = 34.95039, y = 3.058674, z = 30.9619 }, randomPos = 0, randomRadius = 0, monsters = { 90702,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[560302] = {	id = 560302, pos = { x = 38.46595, y = 2.981828, z = 38.16315 }, randomPos = 0, randomRadius = 0, monsters = { 90702,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[560303] = {	id = 560303, pos = { x = 41.85783, y = 3.025881, z = 30.84231 }, randomPos = 0, randomRadius = 0, monsters = { 90703,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[560304] = {	id = 560304, pos = { x = 38.39065, y = 2.946501, z = 32.0 }, randomPos = 0, randomRadius = 0, monsters = { 90703,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
