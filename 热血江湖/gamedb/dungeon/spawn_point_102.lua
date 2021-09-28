----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[20401] = {	id = 20401, pos = { x = 60.77443, y = 23.01751, z = -45.96297 }, randomPos = 1, randomRadius = 600, monsters = { 89041,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20402] = {	id = 20402, pos = { x = 13.23853, y = 32.22342, z = 6.88011 }, randomPos = 1, randomRadius = 600, monsters = { 89042,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20403] = {	id = 20403, pos = { x = -48.74086, y = 36.19457, z = -19.71451 }, randomPos = 1, randomRadius = 400, monsters = { 89043,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20404] = {	id = 20404, pos = { x = -57.60886, y = 37.0743, z = 12.00423 }, randomPos = 1, randomRadius = 600, monsters = { 89044,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20405] = {	id = 20405, pos = { x = -37.6489, y = 37.21071, z = 45.17905 }, randomPos = 1, randomRadius = 400, monsters = { 89045,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20406] = {	id = 20406, pos = { x = 4.126169, y = 40.58962, z = 98.50735 }, randomPos = 1, randomRadius = 400, monsters = { 89046,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20501] = {	id = 20501, pos = { x = 82.24585, y = 0.3042052, z = 4.148019 }, randomPos = 1, randomRadius = 600, monsters = { 89051,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20502] = {	id = 20502, pos = { x = -35.16279, y = 3.163843, z = 34.26233 }, randomPos = 1, randomRadius = 600, monsters = { 89052,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20503] = {	id = 20503, pos = { x = -46.80666, y = 0.4189898, z = -33.35884 }, randomPos = 1, randomRadius = 600, monsters = { 89053,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20504] = {	id = 20504, pos = { x = 31.25091, y = -8.836158, z = -30.16941 }, randomPos = 1, randomRadius = 600, monsters = { 89054,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20505] = {	id = 20505, pos = { x = 90.348, y = 0.1638422, z = -46.64404 }, randomPos = 1, randomRadius = 600, monsters = { 89055,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[20506] = {	id = 20506, pos = { x = 56.5384, y = 0.3220883, z = -92.34895 }, randomPos = 1, randomRadius = 600, monsters = { 89056,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
