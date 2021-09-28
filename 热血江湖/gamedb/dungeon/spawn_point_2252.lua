----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[450401] = {	id = 450401, pos = { x = -7.960431, y = 6.475816, z = 5.796075 }, randomPos = 0, randomRadius = 0, monsters = { 90401,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[450402] = {	id = 450402, pos = { x = -4.042883, y = 6.137549, z = -0.1177213 }, randomPos = 0, randomRadius = 0, monsters = { 90401,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[450403] = {	id = 450403, pos = { x = -0.1219425, y = 6.146743, z = -2.521851 }, randomPos = 0, randomRadius = 0, monsters = { 90402,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[450404] = {	id = 450404, pos = { x = 12.40426, y = 6.224805, z = 18.41552 }, randomPos = 0, randomRadius = 0, monsters = { 90402,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[450405] = {	id = 450405, pos = { x = 14.45672, y = 6.311427, z = 13.26424 }, randomPos = 0, randomRadius = 0, monsters = { 90404,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[450406] = {	id = 450406, pos = { x = 12.24695, y = 6.296371, z = 16.75149 }, randomPos = 0, randomRadius = 0, monsters = { 90404,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[450501] = {	id = 450501, pos = { x = 4.144393, y = 6.57117, z = 9.908512 }, randomPos = 0, randomRadius = 0, monsters = { 90401,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[450502] = {	id = 450502, pos = { x = 3.852897, y = 6.57117, z = 7.243869 }, randomPos = 0, randomRadius = 0, monsters = { 90401,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[450503] = {	id = 450503, pos = { x = 3.281607, y = 6.509946, z = 6.032088 }, randomPos = 0, randomRadius = 0, monsters = { 90404,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[450504] = {	id = 450504, pos = { x = 3.337073, y = 6.540892, z = 7.234569 }, randomPos = 0, randomRadius = 0, monsters = { 90404,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[450505] = {	id = 450505, pos = { x = 4.839161, y = 6.57117, z = 8.865074 }, randomPos = 0, randomRadius = 0, monsters = { 90403,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[450506] = {	id = 450506, pos = { x = 4.304891, y = 6.57117, z = 8.518234 }, randomPos = 0, randomRadius = 0, monsters = { 90403,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[450507] = {	id = 450507, pos = { x = 5.401841, y = 6.57117, z = 6.109744 }, randomPos = 0, randomRadius = 0, monsters = { 90405,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
