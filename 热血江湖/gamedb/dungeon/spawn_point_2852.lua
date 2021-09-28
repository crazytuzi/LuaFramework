----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[570401] = {	id = 570401, pos = { x = -34.57533, y = 8.196625, z = -23.89133 }, randomPos = 0, randomRadius = 0, monsters = { 90715,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[570402] = {	id = 570402, pos = { x = -29.63988, y = 8.268406, z = -23.61941 }, randomPos = 0, randomRadius = 0, monsters = { 90712,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[570403] = {	id = 570403, pos = { x = -29.61213, y = 8.301806, z = -19.47366 }, randomPos = 0, randomRadius = 0, monsters = { 90712,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[570404] = {	id = 570404, pos = { x = -34.65391, y = 8.196625, z = -19.11276 }, randomPos = 0, randomRadius = 0, monsters = { 90712,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[570405] = {	id = 570405, pos = { x = -32.0, y = 8.196625, z = -22.05038 }, randomPos = 0, randomRadius = 0, monsters = { 90714,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[570406] = {	id = 570406, pos = { x = -32.01387, y = 8.196625, z = -25.40916 }, randomPos = 0, randomRadius = 0, monsters = { 90714,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[570407] = {	id = 570407, pos = { x = -32.04747, y = 8.196625, z = -17.42827 }, randomPos = 0, randomRadius = 0, monsters = { 90714,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[570501] = {	id = 570501, pos = { x = -1.343121, y = 12.39662, z = 46.41647 }, randomPos = 0, randomRadius = 0, monsters = { 90716,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[570502] = {	id = 570502, pos = { x = 1.00047, y = 12.38265, z = 41.87456 }, randomPos = 0, randomRadius = 0, monsters = { 90714,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[570503] = {	id = 570503, pos = { x = 5.295937, y = 12.39663, z = 43.08369 }, randomPos = 0, randomRadius = 0, monsters = { 90714,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[570504] = {	id = 570504, pos = { x = -3.123833, y = 12.39662, z = 43.14714 }, randomPos = 0, randomRadius = 0, monsters = { 90714,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[570505] = {	id = 570505, pos = { x = 3.904606, y = 12.39663, z = 47.25355 }, randomPos = 0, randomRadius = 0, monsters = { 90713,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[570506] = {	id = 570506, pos = { x = 1.511986, y = 12.40887, z = 47.62518 }, randomPos = 0, randomRadius = 0, monsters = { 90713,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[570507] = {	id = 570507, pos = { x = 0.8910849, y = 12.54057, z = 55.16064 }, randomPos = 0, randomRadius = 0, monsters = { 90713,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
