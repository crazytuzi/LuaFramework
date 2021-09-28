----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[90401] = {	id = 90401, pos = { x = 22.22605, y = 13.83806, z = 0.9286003 }, randomPos = 1, randomRadius = 500, monsters = { 50501,  }, spawnType = 3, spawnDTime = 300000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[90402] = {	id = 90402, pos = { x = -64.60114, y = 13.83806, z = -0.7866592 }, randomPos = 1, randomRadius = 500, monsters = { 50501,  }, spawnType = 3, spawnDTime = 300000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[90403] = {	id = 90403, pos = { x = -20.87061, y = 13.83806, z = 42.70169 }, randomPos = 1, randomRadius = 500, monsters = { 50501,  }, spawnType = 3, spawnDTime = 300000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[90404] = {	id = 90404, pos = { x = -17.88552, y = 13.83806, z = -42.00703 }, randomPos = 1, randomRadius = 500, monsters = { 50501,  }, spawnType = 3, spawnDTime = 300000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[90405] = {	id = 90405, pos = { x = -64.40444, y = 13.90981, z = -43.14201 }, randomPos = 1, randomRadius = 500, monsters = { 50501,  }, spawnType = 3, spawnDTime = 300000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[90406] = {	id = 90406, pos = { x = -65.638, y = 13.83806, z = 44.37423 }, randomPos = 1, randomRadius = 500, monsters = { 50501,  }, spawnType = 3, spawnDTime = 300000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[90407] = {	id = 90407, pos = { x = 23.54523, y = 13.83806, z = 42.93248 }, randomPos = 1, randomRadius = 500, monsters = { 50502,  }, spawnType = 3, spawnDTime = 40000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[90408] = {	id = 90408, pos = { x = 23.158, y = 13.92326, z = -42.8116 }, randomPos = 1, randomRadius = 500, monsters = { 50502,  }, spawnType = 3, spawnDTime = 40000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[90409] = {	id = 90409, pos = { x = -25.43032, y = 21.43806, z = 0.5781898 }, randomPos = 1, randomRadius = 500, monsters = { 50503,  }, spawnType = 3, spawnDTime = 60000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
