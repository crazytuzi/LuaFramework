----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[35401] = {	id = 35401, pos = { x = -67.34935, y = 0.2000002, z = -124.3958 }, randomPos = 1, randomRadius = 500, monsters = { 87605,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35402] = {	id = 35402, pos = { x = -89.30405, y = 0.2000002, z = -107.9874 }, randomPos = 1, randomRadius = 500, monsters = { 87605,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35403] = {	id = 35403, pos = { x = -32.49469, y = 0.2000002, z = -108.8235 }, randomPos = 1, randomRadius = 500, monsters = { 87605,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35404] = {	id = 35404, pos = { x = -27.15786, y = 5.0, z = -60.78374 }, randomPos = 1, randomRadius = 500, monsters = { 87605,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35405] = {	id = 35405, pos = { x = -45.23987, y = 5.018176, z = -33.05165 }, randomPos = 1, randomRadius = 500, monsters = { 87605,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35406] = {	id = 35406, pos = { x = -78.92635, y = 7.099642, z = 36.48711 }, randomPos = 1, randomRadius = 500, monsters = { 87605,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35407] = {	id = 35407, pos = { x = 40.25465, y = 13.08437, z = 31.77902 }, randomPos = 1, randomRadius = 500, monsters = { 87605,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35408] = {	id = 35408, pos = { x = -5.473045, y = 5.0, z = -33.89063 }, randomPos = 1, randomRadius = 500, monsters = { 87605,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35409] = {	id = 35409, pos = { x = -99.81305, y = 0.2000002, z = -82.6731 }, randomPos = 1, randomRadius = 500, monsters = { 87605,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35410] = {	id = 35410, pos = { x = -85.91849, y = 7.0, z = -1.573593 }, randomPos = 1, randomRadius = 500, monsters = { 87605,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35501] = {	id = 35501, pos = { x = -81.8354, y = 7.014168, z = 31.83595 }, randomPos = 1, randomRadius = 500, monsters = { 87606,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35502] = {	id = 35502, pos = { x = -38.10487, y = 7.0, z = 29.06763 }, randomPos = 1, randomRadius = 500, monsters = { 87606,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35503] = {	id = 35503, pos = { x = -34.10042, y = 5.089096, z = -49.3985 }, randomPos = 1, randomRadius = 500, monsters = { 87606,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35504] = {	id = 35504, pos = { x = -20.09632, y = 5.096087, z = -30.44708 }, randomPos = 1, randomRadius = 500, monsters = { 87606,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35505] = {	id = 35505, pos = { x = -16.86463, y = 0.2000002, z = -106.1814 }, randomPos = 1, randomRadius = 500, monsters = { 87606,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35506] = {	id = 35506, pos = { x = -53.78812, y = 0.2000002, z = -126.4483 }, randomPos = 1, randomRadius = 500, monsters = { 87606,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
