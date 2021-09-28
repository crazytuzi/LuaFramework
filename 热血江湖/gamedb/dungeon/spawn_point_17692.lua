----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[3538401] = {	id = 3538401, pos = { x = -36.96347, y = 11.34099, z = -71.67788 }, randomPos = 0, randomRadius = 150, monsters = { 69940,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538402] = {	id = 3538402, pos = { x = 9.195552, y = 11.34099, z = -81.61817 }, randomPos = 0, randomRadius = 150, monsters = { 69941,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538403] = {	id = 3538403, pos = { x = -13.88438, y = 9.340994, z = -54.30053 }, randomPos = 0, randomRadius = 150, monsters = { 69942,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538404] = {	id = 3538404, pos = { x = -11.49189, y = 9.340994, z = -44.79904 }, randomPos = 0, randomRadius = 150, monsters = { 69943,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538405] = {	id = 3538405, pos = { x = 36.04563, y = 13.84099, z = -8.965802 }, randomPos = 0, randomRadius = 0, monsters = { 69944,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538406] = {	id = 3538406, pos = { x = 39.3905, y = 13.84099, z = -12.6289 }, randomPos = 0, randomRadius = 0, monsters = { 69942,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538407] = {	id = 3538407, pos = { x = 39.33213, y = 13.84099, z = -8.002333 }, randomPos = 0, randomRadius = 0, monsters = { 69942,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538408] = {	id = 3538408, pos = { x = 36.80307, y = 13.83643, z = -2.541286 }, randomPos = 0, randomRadius = 0, monsters = { 69942,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538501] = {	id = 3538501, pos = { x = -36.69897, y = 11.34099, z = -70.62529 }, randomPos = 0, randomRadius = 150, monsters = { 69945,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538502] = {	id = 3538502, pos = { x = 8.619288, y = 11.34099, z = -81.42562 }, randomPos = 0, randomRadius = 150, monsters = { 69946,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538503] = {	id = 3538503, pos = { x = -13.07187, y = 9.340994, z = -55.20165 }, randomPos = 0, randomRadius = 150, monsters = { 69947,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538504] = {	id = 3538504, pos = { x = -11.81746, y = 9.340994, z = -45.66568 }, randomPos = 0, randomRadius = 150, monsters = { 69948,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538505] = {	id = 3538505, pos = { x = 35.88325, y = 13.84099, z = -9.073807 }, randomPos = 0, randomRadius = 0, monsters = { 69949,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538506] = {	id = 3538506, pos = { x = 38.66935, y = 13.84099, z = -12.69182 }, randomPos = 0, randomRadius = 0, monsters = { 69947,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538507] = {	id = 3538507, pos = { x = 39.70765, y = 13.84099, z = -8.095234 }, randomPos = 0, randomRadius = 0, monsters = { 69947,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538508] = {	id = 3538508, pos = { x = 38.42525, y = 13.78808, z = -2.520817 }, randomPos = 0, randomRadius = 0, monsters = { 69947,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
