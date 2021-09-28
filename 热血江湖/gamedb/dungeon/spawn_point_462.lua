----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[92401] = {	id = 92401, pos = { x = 22.22605, y = 13.83806, z = 0.9286003 }, randomPos = 1, randomRadius = 500, monsters = { 50507,  }, spawnType = 3, spawnDTime = 300000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92402] = {	id = 92402, pos = { x = -64.60114, y = 13.83806, z = -0.7866592 }, randomPos = 1, randomRadius = 500, monsters = { 50507,  }, spawnType = 3, spawnDTime = 300000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92403] = {	id = 92403, pos = { x = -20.87061, y = 13.83806, z = 42.70169 }, randomPos = 1, randomRadius = 500, monsters = { 50507,  }, spawnType = 3, spawnDTime = 300000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92404] = {	id = 92404, pos = { x = -17.88552, y = 13.83806, z = -42.00703 }, randomPos = 1, randomRadius = 500, monsters = { 50507,  }, spawnType = 3, spawnDTime = 300000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92405] = {	id = 92405, pos = { x = -64.40444, y = 13.90981, z = -43.14201 }, randomPos = 1, randomRadius = 500, monsters = { 50507,  }, spawnType = 3, spawnDTime = 300000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92406] = {	id = 92406, pos = { x = -65.638, y = 13.83806, z = 44.37423 }, randomPos = 1, randomRadius = 500, monsters = { 50507,  }, spawnType = 3, spawnDTime = 300000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92407] = {	id = 92407, pos = { x = 23.54523, y = 13.83806, z = 42.93248 }, randomPos = 1, randomRadius = 500, monsters = { 50508,  }, spawnType = 3, spawnDTime = 40000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92408] = {	id = 92408, pos = { x = 23.158, y = 13.92326, z = -42.8116 }, randomPos = 1, randomRadius = 500, monsters = { 50508,  }, spawnType = 3, spawnDTime = 40000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[92409] = {	id = 92409, pos = { x = -25.43032, y = 21.43806, z = 0.5781898 }, randomPos = 1, randomRadius = 500, monsters = { 50509,  }, spawnType = 3, spawnDTime = 60000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
