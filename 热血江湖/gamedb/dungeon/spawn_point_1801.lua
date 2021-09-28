----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[360201] = {	id = 360201, pos = { x = -4.5, y = 0.4288624, z = 30.25 }, randomPos = 0, randomRadius = 0, monsters = { 90331,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[360202] = {	id = 360202, pos = { x = 0.0, y = 0.3588624, z = 30.82275 }, randomPos = 0, randomRadius = 0, monsters = { 90331,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[360203] = {	id = 360203, pos = { x = -9.177044, y = 0.4527539, z = 30.28983 }, randomPos = 0, randomRadius = 0, monsters = { 90331,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[360204] = {	id = 360204, pos = { x = 5.644289, y = 0.3588619, z = 30.86572 }, randomPos = 0, randomRadius = 0, monsters = { 90331,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[360205] = {	id = 360205, pos = { x = -9.355711, y = 0.9263518, z = 34.86572 }, randomPos = 0, randomRadius = 0, monsters = { 90332,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[360206] = {	id = 360206, pos = { x = 5.644289, y = 0.3588616, z = 35.86572 }, randomPos = 0, randomRadius = 0, monsters = { 90332,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[360207] = {	id = 360207, pos = { x = -4.685, y = 0.5112613, z = 35.42815 }, randomPos = 0, randomRadius = 0, monsters = { 90332,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[360208] = {	id = 360208, pos = { x = -0.3795726, y = 0.3622226, z = 35.97353 }, randomPos = 0, randomRadius = 0, monsters = { 90332,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[360301] = {	id = 360301, pos = { x = -12.87757, y = 0.616584, z = 45.52233 }, randomPos = 0, randomRadius = 0, monsters = { 90332,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[360302] = {	id = 360302, pos = { x = -8.607773, y = 0.6797963, z = 47.9416 }, randomPos = 0, randomRadius = 0, monsters = { 90332,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[360303] = {	id = 360303, pos = { x = -5.244192, y = 0.5219338, z = 48.26194 }, randomPos = 0, randomRadius = 0, monsters = { 90332,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[360304] = {	id = 360304, pos = { x = -10.7868, y = 0.7523798, z = 42.9696 }, randomPos = 0, randomRadius = 0, monsters = { 90332,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[360305] = {	id = 360305, pos = { x = -5.900146, y = 0.5895536, z = 44.05955 }, randomPos = 0, randomRadius = 0, monsters = { 90332,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[360306] = {	id = 360306, pos = { x = -12.11639, y = 0.6084643, z = 54.16595 }, randomPos = 0, randomRadius = 0, monsters = { 90333,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[360307] = {	id = 360307, pos = { x = -8.487856, y = 0.5169048, z = 55.64067 }, randomPos = 0, randomRadius = 0, monsters = { 90333,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[360308] = {	id = 360308, pos = { x = -14.05928, y = 0.6045093, z = 51.62899 }, randomPos = 0, randomRadius = 0, monsters = { 90333,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[360309] = {	id = 360309, pos = { x = -4.372823, y = 0.3588623, z = 56.0029 }, randomPos = 0, randomRadius = 0, monsters = { 90333,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[360310] = {	id = 360310, pos = { x = -14.36467, y = 0.3866037, z = 58.97592 }, randomPos = 0, randomRadius = 0, monsters = { 90333,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
