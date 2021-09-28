----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[30601] = {	id = 30601, pos = { x = -24.41386, y = 28.0, z = 29.99808 }, randomPos = 1, randomRadius = 350, monsters = { 99691,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30602] = {	id = 30602, pos = { x = -2.692298, y = 21.0, z = -13.34624 }, randomPos = 1, randomRadius = 350, monsters = { 99691,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30603] = {	id = 30603, pos = { x = 25.78066, y = 18.44285, z = -63.09253 }, randomPos = 1, randomRadius = 350, monsters = { 99691,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30604] = {	id = 30604, pos = { x = 15.67076, y = 18.26267, z = -45.4204 }, randomPos = 1, randomRadius = 350, monsters = { 99692,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30605] = {	id = 30605, pos = { x = 44.675, y = 18.15949, z = -58.21311 }, randomPos = 1, randomRadius = 200, monsters = { 99692,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30606] = {	id = 30606, pos = { x = -10.88411, y = 21.02802, z = -24.21303 }, randomPos = 1, randomRadius = 200, monsters = { 99692,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30607] = {	id = 30607, pos = { x = -30.81743, y = 28.0, z = 23.14866 }, randomPos = 0, randomRadius = 100, monsters = { 99693,  }, spawnType = 3, spawnDTime = 900000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30608] = {	id = 30608, pos = { x = 32.42726, y = 18.0, z = -48.46554 }, randomPos = 0, randomRadius = 100, monsters = { 99694,  }, spawnType = 3, spawnDTime = 900000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30701] = {	id = 30701, pos = { x = -1.125668, y = 51.50901, z = 52.24284 }, randomPos = 1, randomRadius = 350, monsters = { 99695,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30702] = {	id = 30702, pos = { x = 2.958355, y = 51.50901, z = 55.65731 }, randomPos = 1, randomRadius = 350, monsters = { 99695,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30703] = {	id = 30703, pos = { x = -1.436077, y = 37.70901, z = -18.94489 }, randomPos = 1, randomRadius = 350, monsters = { 99695,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30704] = {	id = 30704, pos = { x = -0.4787407, y = 27.90901, z = -120.6817 }, randomPos = 1, randomRadius = 350, monsters = { 99696,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30705] = {	id = 30705, pos = { x = -0.3496894, y = 32.10902, z = -75.15796 }, randomPos = 1, randomRadius = 200, monsters = { 99696,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30706] = {	id = 30706, pos = { x = -0.8170357, y = 32.10902, z = -85.36273 }, randomPos = 1, randomRadius = 200, monsters = { 99696,  }, spawnType = 3, spawnDTime = 3000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30707] = {	id = 30707, pos = { x = -0.4644623, y = 37.70901, z = -28.37023 }, randomPos = 0, randomRadius = 100, monsters = { 99697,  }, spawnType = 3, spawnDTime = 900000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[30708] = {	id = 30708, pos = { x = 0.2802505, y = 27.90901, z = -123.4538 }, randomPos = 0, randomRadius = 100, monsters = { 99698,  }, spawnType = 3, spawnDTime = 900000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
