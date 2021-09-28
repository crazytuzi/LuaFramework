----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[121001] = {	id = 121001, pos = { x = 5.438787, y = 0.407484, z = -0.2597522 }, randomPos = 1, randomRadius = 600, monsters = { 111001,  }, spawnType = 4, spawnDTime = 10000, spawnTimes = -1, spawnNum = { { 12, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[121002] = {	id = 121002, pos = { x = 5.438787, y = 0.407484, z = -0.2597522 }, randomPos = 1, randomRadius = 600, monsters = { 111013,  }, spawnType = 4, spawnDTime = 10000, spawnTimes = -1, spawnNum = { { 12, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[121003] = {	id = 121003, pos = { x = 5.438787, y = 0.407484, z = -0.2597522 }, randomPos = 1, randomRadius = 600, monsters = { 111025,  }, spawnType = 4, spawnDTime = 10000, spawnTimes = -1, spawnNum = { { 12, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[121004] = {	id = 121004, pos = { x = 5.438787, y = 0.407484, z = -0.2597522 }, randomPos = 1, randomRadius = 600, monsters = { 111037,  }, spawnType = 4, spawnDTime = 10000, spawnTimes = -1, spawnNum = { { 12, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[121005] = {	id = 121005, pos = { x = 5.438787, y = 0.407484, z = -0.2597522 }, randomPos = 1, randomRadius = 600, monsters = { 111049,  }, spawnType = 4, spawnDTime = 10000, spawnTimes = -1, spawnNum = { { 12, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[121006] = {	id = 121006, pos = { x = 5.438787, y = 0.407484, z = -0.2597522 }, randomPos = 1, randomRadius = 600, monsters = { 111061,  }, spawnType = 4, spawnDTime = 10000, spawnTimes = -1, spawnNum = { { 12, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[121007] = {	id = 121007, pos = { x = 5.438787, y = 0.407484, z = -0.2597522 }, randomPos = 1, randomRadius = 600, monsters = { 111073,  }, spawnType = 4, spawnDTime = 10000, spawnTimes = -1, spawnNum = { { 12, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[121008] = {	id = 121008, pos = { x = 5.438787, y = 0.407484, z = -0.2597522 }, randomPos = 1, randomRadius = 600, monsters = { 111085,  }, spawnType = 4, spawnDTime = 10000, spawnTimes = -1, spawnNum = { { 12, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[121009] = {	id = 121009, pos = { x = 5.438787, y = 0.407484, z = -0.2597522 }, randomPos = 1, randomRadius = 600, monsters = { 111097,  }, spawnType = 4, spawnDTime = 10000, spawnTimes = -1, spawnNum = { { 12, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
