----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[33401] = {	id = 33401, pos = { x = 76.73932, y = 6.165421, z = -95.84123 }, randomPos = 1, randomRadius = 500, monsters = { 87505,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33402] = {	id = 33402, pos = { x = 24.14656, y = 16.16542, z = -35.78986 }, randomPos = 1, randomRadius = 500, monsters = { 87505,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33403] = {	id = 33403, pos = { x = 16.4743, y = 11.16542, z = -93.98885 }, randomPos = 1, randomRadius = 500, monsters = { 87505,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33404] = {	id = 33404, pos = { x = -28.83232, y = 15.22397, z = -17.35556 }, randomPos = 1, randomRadius = 500, monsters = { 87505,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33405] = {	id = 33405, pos = { x = -27.58724, y = 13.16542, z = -62.83123 }, randomPos = 1, randomRadius = 500, monsters = { 87505,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33406] = {	id = 33406, pos = { x = -32.50372, y = 22.16542, z = 23.61912 }, randomPos = 1, randomRadius = 500, monsters = { 87505,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33407] = {	id = 33407, pos = { x = -30.80477, y = 29.38699, z = 105.9714 }, randomPos = 1, randomRadius = 500, monsters = { 87505,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33408] = {	id = 33408, pos = { x = 2.737328, y = 32.36542, z = 110.2635 }, randomPos = 1, randomRadius = 500, monsters = { 87505,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33409] = {	id = 33409, pos = { x = 55.41621, y = 32.36542, z = 97.09496 }, randomPos = 1, randomRadius = 500, monsters = { 87505,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33410] = {	id = 33410, pos = { x = 110.1016, y = 30.16542, z = 111.0156 }, randomPos = 1, randomRadius = 500, monsters = { 87505,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33501] = {	id = 33501, pos = { x = 54.80587, y = 28.76542, z = 45.23719 }, randomPos = 1, randomRadius = 500, monsters = { 87506,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33502] = {	id = 33502, pos = { x = 3.663386, y = 28.76542, z = 50.46644 }, randomPos = 1, randomRadius = 500, monsters = { 87506,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33503] = {	id = 33503, pos = { x = 57.17113, y = 32.36542, z = 127.4623 }, randomPos = 1, randomRadius = 500, monsters = { 87506,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33504] = {	id = 33504, pos = { x = 0.1445674, y = 32.36542, z = 108.2971 }, randomPos = 1, randomRadius = 500, monsters = { 87506,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33505] = {	id = 33505, pos = { x = 58.80312, y = 32.36542, z = 110.3317 }, randomPos = 1, randomRadius = 500, monsters = { 87506,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33506] = {	id = 33506, pos = { x = 31.55454, y = 28.76542, z = 42.93129 }, randomPos = 1, randomRadius = 500, monsters = { 87506,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
