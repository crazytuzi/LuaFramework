----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[630201] = {	id = 630201, pos = { x = 25.1856, y = 6.965291, z = -44.45224 }, randomPos = 0, randomRadius = 0, monsters = { 91101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[630202] = {	id = 630202, pos = { x = 24.01901, y = 6.965291, z = -37.26029 }, randomPos = 0, randomRadius = 0, monsters = { 91101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[630203] = {	id = 630203, pos = { x = 26.0975, y = 6.965291, z = -41.61243 }, randomPos = 0, randomRadius = 0, monsters = { 91101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[630204] = {	id = 630204, pos = { x = 30.57718, y = 6.965291, z = -46.75577 }, randomPos = 0, randomRadius = 0, monsters = { 91101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[630205] = {	id = 630205, pos = { x = 31.75613, y = 6.965291, z = -42.12849 }, randomPos = 0, randomRadius = 0, monsters = { 91101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[630206] = {	id = 630206, pos = { x = 29.50331, y = 6.965291, z = -37.49622 }, randomPos = 0, randomRadius = 0, monsters = { 91103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[630207] = {	id = 630207, pos = { x = 27.25884, y = 6.965291, z = -33.53084 }, randomPos = 0, randomRadius = 0, monsters = { 91103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[630208] = {	id = 630208, pos = { x = 32.18833, y = 6.965291, z = -36.07787 }, randomPos = 0, randomRadius = 0, monsters = { 91103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[630209] = {	id = 630209, pos = { x = 33.65768, y = 6.965291, z = -39.53952 }, randomPos = 0, randomRadius = 0, monsters = { 91103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[630210] = {	id = 630210, pos = { x = 29.83263, y = 6.965291, z = -43.271 }, randomPos = 0, randomRadius = 0, monsters = { 91103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[630301] = {	id = 630301, pos = { x = -14.16347, y = 6.965301, z = -2.208828 }, randomPos = 0, randomRadius = 0, monsters = { 91103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[630302] = {	id = 630302, pos = { x = -10.21655, y = 6.965301, z = -1.883607 }, randomPos = 0, randomRadius = 0, monsters = { 91103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[630303] = {	id = 630303, pos = { x = -6.472768, y = 6.965301, z = -1.892925 }, randomPos = 0, randomRadius = 0, monsters = { 91103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[630304] = {	id = 630304, pos = { x = -4.727572, y = 6.965301, z = -4.087289 }, randomPos = 0, randomRadius = 0, monsters = { 91103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[630305] = {	id = 630305, pos = { x = -15.78498, y = 6.965301, z = -5.489544 }, randomPos = 0, randomRadius = 0, monsters = { 91103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[630306] = {	id = 630306, pos = { x = -11.97749, y = 6.965301, z = -5.074493 }, randomPos = 0, randomRadius = 0, monsters = { 91102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[630307] = {	id = 630307, pos = { x = -8.615026, y = 6.965301, z = -4.762887 }, randomPos = 0, randomRadius = 0, monsters = { 91102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[630308] = {	id = 630308, pos = { x = -12.66393, y = 6.965301, z = -7.330542 }, randomPos = 0, randomRadius = 0, monsters = { 91102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[630309] = {	id = 630309, pos = { x = -7.347981, y = 6.965301, z = -6.010416 }, randomPos = 0, randomRadius = 0, monsters = { 91102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[630310] = {	id = 630310, pos = { x = -10.69725, y = 6.965301, z = -6.419795 }, randomPos = 0, randomRadius = 0, monsters = { 91102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
