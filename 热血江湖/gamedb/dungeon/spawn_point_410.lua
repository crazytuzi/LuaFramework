----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[82001] = {	id = 82001, pos = { x = -47.00756, y = 0.2000007, z = -0.0001357 }, randomPos = 1, randomRadius = 500, monsters = { 61552,  }, spawnType = 1, spawnDTime = 30000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[82002] = {	id = 82002, pos = { x = 47.00259, y = 0.2000007, z = -0.0005967 }, randomPos = 1, randomRadius = 500, monsters = { 61553,  }, spawnType = 1, spawnDTime = 30000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[82021] = {	id = 82021, pos = { x = -47.00756, y = 0.2000007, z = -0.0001357 }, randomPos = 1, randomRadius = 500, monsters = { 61552,  }, spawnType = 1, spawnDTime = 30000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[82022] = {	id = 82022, pos = { x = 47.00259, y = 0.2000007, z = -0.0005967 }, randomPos = 1, randomRadius = 500, monsters = { 61553,  }, spawnType = 1, spawnDTime = 30000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
