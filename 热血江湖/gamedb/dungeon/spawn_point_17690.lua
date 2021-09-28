----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[3538001] = {	id = 3538001, pos = { x = -35.41925, y = 11.34099, z = -68.90533 }, randomPos = 0, randomRadius = 150, monsters = { 69920,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538002] = {	id = 3538002, pos = { x = 8.23056, y = 11.34099, z = -79.08944 }, randomPos = 0, randomRadius = 150, monsters = { 69921,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538003] = {	id = 3538003, pos = { x = -12.89792, y = 9.340994, z = -54.88122 }, randomPos = 0, randomRadius = 150, monsters = { 69922,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538004] = {	id = 3538004, pos = { x = -12.74219, y = 9.340994, z = -46.27796 }, randomPos = 0, randomRadius = 150, monsters = { 69923,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538005] = {	id = 3538005, pos = { x = 35.72233, y = 13.84099, z = -8.975058 }, randomPos = 0, randomRadius = 0, monsters = { 69924,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538006] = {	id = 3538006, pos = { x = 38.35455, y = 13.84099, z = -13.29247 }, randomPos = 0, randomRadius = 0, monsters = { 69922,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538007] = {	id = 3538007, pos = { x = 39.10944, y = 13.82728, z = -3.864262 }, randomPos = 0, randomRadius = 0, monsters = { 69922,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538101] = {	id = 3538101, pos = { x = -37.88836, y = 11.34099, z = -69.97999 }, randomPos = 0, randomRadius = 150, monsters = { 69925,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538102] = {	id = 3538102, pos = { x = 8.329605, y = 11.34099, z = -80.88184 }, randomPos = 0, randomRadius = 150, monsters = { 69926,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538103] = {	id = 3538103, pos = { x = -13.88833, y = 9.340994, z = -56.24282 }, randomPos = 0, randomRadius = 150, monsters = { 69927,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538104] = {	id = 3538104, pos = { x = -12.22069, y = 9.340994, z = -45.61184 }, randomPos = 0, randomRadius = 150, monsters = { 69928,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538105] = {	id = 3538105, pos = { x = 35.99003, y = 13.84099, z = -8.887712 }, randomPos = 0, randomRadius = 0, monsters = { 69929,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538106] = {	id = 3538106, pos = { x = 39.59077, y = 13.84099, z = -13.64015 }, randomPos = 0, randomRadius = 0, monsters = { 69927,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538107] = {	id = 3538107, pos = { x = 41.15112, y = 13.84099, z = -7.333902 }, randomPos = 0, randomRadius = 0, monsters = { 69927,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
