----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[91401] = {	id = 91401, pos = { x = 22.22605, y = 13.83806, z = 0.9286003 }, randomPos = 1, randomRadius = 500, monsters = { 50504,  }, spawnType = 3, spawnDTime = 300000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[91402] = {	id = 91402, pos = { x = -64.60114, y = 13.83806, z = -0.7866592 }, randomPos = 1, randomRadius = 500, monsters = { 50504,  }, spawnType = 3, spawnDTime = 300000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[91403] = {	id = 91403, pos = { x = -20.87061, y = 13.83806, z = 42.70169 }, randomPos = 1, randomRadius = 500, monsters = { 50504,  }, spawnType = 3, spawnDTime = 300000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[91404] = {	id = 91404, pos = { x = -17.88552, y = 13.83806, z = -42.00703 }, randomPos = 1, randomRadius = 500, monsters = { 50504,  }, spawnType = 3, spawnDTime = 300000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[91405] = {	id = 91405, pos = { x = -64.40444, y = 13.90981, z = -43.14201 }, randomPos = 1, randomRadius = 500, monsters = { 50504,  }, spawnType = 3, spawnDTime = 300000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[91406] = {	id = 91406, pos = { x = -65.638, y = 13.83806, z = 44.37423 }, randomPos = 1, randomRadius = 500, monsters = { 50504,  }, spawnType = 3, spawnDTime = 300000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[91407] = {	id = 91407, pos = { x = 23.54523, y = 13.83806, z = 42.93248 }, randomPos = 1, randomRadius = 500, monsters = { 50505,  }, spawnType = 3, spawnDTime = 40000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[91408] = {	id = 91408, pos = { x = 23.158, y = 13.92326, z = -42.8116 }, randomPos = 1, randomRadius = 500, monsters = { 50505,  }, spawnType = 3, spawnDTime = 40000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[91409] = {	id = 91409, pos = { x = -25.43032, y = 21.43806, z = 0.5781898 }, randomPos = 1, randomRadius = 500, monsters = { 50506,  }, spawnType = 3, spawnDTime = 60000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
