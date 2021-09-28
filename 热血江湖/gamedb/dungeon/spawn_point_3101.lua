----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[620201] = {	id = 620201, pos = { x = 23.15903, y = 6.965291, z = -34.82773 }, randomPos = 0, randomRadius = 0, monsters = { 91001,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[620202] = {	id = 620202, pos = { x = 24.50891, y = 6.965291, z = -41.38996 }, randomPos = 0, randomRadius = 0, monsters = { 91001,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[620203] = {	id = 620203, pos = { x = 28.88553, y = 6.965291, z = -44.61952 }, randomPos = 0, randomRadius = 0, monsters = { 91001,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[620204] = {	id = 620204, pos = { x = 29.01995, y = 6.965291, z = -40.95066 }, randomPos = 0, randomRadius = 0, monsters = { 91001,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[620205] = {	id = 620205, pos = { x = 28.76026, y = 6.965291, z = -35.75755 }, randomPos = 0, randomRadius = 0, monsters = { 91003,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[620206] = {	id = 620206, pos = { x = 31.71771, y = 6.965291, z = -39.26366 }, randomPos = 0, randomRadius = 0, monsters = { 91003,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[620207] = {	id = 620207, pos = { x = 26.52958, y = 6.965291, z = -36.69654 }, randomPos = 0, randomRadius = 0, monsters = { 91003,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[620208] = {	id = 620208, pos = { x = 32.06343, y = 6.965291, z = -43.74229 }, randomPos = 0, randomRadius = 0, monsters = { 91003,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[620301] = {	id = 620301, pos = { x = -8.001448, y = 6.965291, z = -36.4922 }, randomPos = 0, randomRadius = 0, monsters = { 91003,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[620302] = {	id = 620302, pos = { x = -9.997721, y = 6.965291, z = -44.50371 }, randomPos = 0, randomRadius = 0, monsters = { 91003,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[620303] = {	id = 620303, pos = { x = -8.877085, y = 6.965291, z = -42.3529 }, randomPos = 0, randomRadius = 0, monsters = { 91003,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[620304] = {	id = 620304, pos = { x = -7.109116, y = 6.965291, z = -46.85033 }, randomPos = 0, randomRadius = 0, monsters = { 91003,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[620305] = {	id = 620305, pos = { x = -5.111336, y = 6.965291, z = -45.64368 }, randomPos = 0, randomRadius = 0, monsters = { 91002,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[620306] = {	id = 620306, pos = { x = -6.34774, y = 6.965291, z = -41.26923 }, randomPos = 0, randomRadius = 0, monsters = { 91002,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[620307] = {	id = 620307, pos = { x = -7.342661, y = 6.965291, z = -38.04429 }, randomPos = 0, randomRadius = 0, monsters = { 91002,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[620308] = {	id = 620308, pos = { x = -5.777815, y = 6.965291, z = -33.64508 }, randomPos = 0, randomRadius = 0, monsters = { 91002,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
