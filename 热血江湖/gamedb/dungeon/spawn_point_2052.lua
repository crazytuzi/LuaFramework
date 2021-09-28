----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[410401] = {	id = 410401, pos = { x = 122.211, y = -19.34989, z = -22.44685 }, randomPos = 0, randomRadius = 0, monsters = { 90524,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410402] = {	id = 410402, pos = { x = 123.2894, y = 10.40953, z = -30.53495 }, randomPos = 0, randomRadius = 0, monsters = { 90524,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410403] = {	id = 410403, pos = { x = 120.5103, y = 10.39562, z = -31.89122 }, randomPos = 0, randomRadius = 0, monsters = { 90524,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410404] = {	id = 410404, pos = { x = 124.7619, y = 10.4011, z = -31.3569 }, randomPos = 0, randomRadius = 0, monsters = { 90524,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410405] = {	id = 410405, pos = { x = 121.0456, y = 10.3945, z = -32.47978 }, randomPos = 0, randomRadius = 0, monsters = { 90525,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410406] = {	id = 410406, pos = { x = 125.0062, y = 10.3976, z = -31.69835 }, randomPos = 0, randomRadius = 0, monsters = { 90525,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410407] = {	id = 410407, pos = { x = 123.1468, y = 10.3945, z = -32.73369 }, randomPos = 0, randomRadius = 0, monsters = { 90525,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410408] = {	id = 410408, pos = { x = 125.0806, y = 10.3945, z = -32.70147 }, randomPos = 0, randomRadius = 0, monsters = { 90525,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410501] = {	id = 410501, pos = { x = 112.6249, y = -22.66387, z = -80.87328 }, randomPos = 0, randomRadius = 0, monsters = { 90524,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410502] = {	id = 410502, pos = { x = 95.25192, y = 7.394504, z = -67.55878 }, randomPos = 0, randomRadius = 0, monsters = { 90524,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410503] = {	id = 410503, pos = { x = 98.57541, y = 7.394502, z = -69.93085 }, randomPos = 0, randomRadius = 0, monsters = { 90524,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410504] = {	id = 410504, pos = { x = 101.1128, y = 7.394502, z = -70.67684 }, randomPos = 0, randomRadius = 0, monsters = { 90524,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410505] = {	id = 410505, pos = { x = 93.54063, y = 7.394504, z = -64.15606 }, randomPos = 0, randomRadius = 0, monsters = { 90525,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410506] = {	id = 410506, pos = { x = 96.30824, y = 7.394502, z = -66.81108 }, randomPos = 0, randomRadius = 0, monsters = { 90525,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410507] = {	id = 410507, pos = { x = 97.91003, y = 7.394502, z = -67.98111 }, randomPos = 0, randomRadius = 0, monsters = { 90525,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410508] = {	id = 410508, pos = { x = 98.83051, y = 7.394502, z = -70.61584 }, randomPos = 0, randomRadius = 0, monsters = { 90525,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410509] = {	id = 410509, pos = { x = 95.54354, y = 7.394504, z = -68.35028 }, randomPos = 0, randomRadius = 0, monsters = { 90526,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
