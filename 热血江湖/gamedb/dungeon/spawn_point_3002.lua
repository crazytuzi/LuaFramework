----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[600401] = {	id = 600401, pos = { x = -11.72821, y = 6.965301, z = -6.723637 }, randomPos = 0, randomRadius = 0, monsters = { 90801,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[600402] = {	id = 600402, pos = { x = -8.382687, y = 6.965301, z = -5.11994 }, randomPos = 0, randomRadius = 0, monsters = { 90801,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[600403] = {	id = 600403, pos = { x = -4.87468, y = 6.965301, z = -5.408977 }, randomPos = 0, randomRadius = 0, monsters = { 90803,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[600404] = {	id = 600404, pos = { x = -13.10849, y = 6.965301, z = -3.747396 }, randomPos = 0, randomRadius = 0, monsters = { 90803,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[600501] = {	id = 600501, pos = { x = 9.859069, y = 8.32317, z = 29.78361 }, randomPos = 0, randomRadius = 0, monsters = { 90804,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[600502] = {	id = 600502, pos = { x = 14.70715, y = 8.264089, z = 28.74001 }, randomPos = 0, randomRadius = 0, monsters = { 90804,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[600503] = {	id = 600503, pos = { x = 7.599361, y = 8.42467, z = 28.14639 }, randomPos = 0, randomRadius = 0, monsters = { 90805,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[600504] = {	id = 600504, pos = { x = 11.25, y = 8.365291, z = 24.5 }, randomPos = 0, randomRadius = 0, monsters = { 90805,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[600505] = {	id = 600505, pos = { x = 6.446949, y = 8.557129, z = 24.65625 }, randomPos = 0, randomRadius = 0, monsters = { 90806,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[600506] = {	id = 600506, pos = { x = -5.603724, y = 6.965301, z = -40.25624 }, randomPos = 0, randomRadius = 0, monsters = { 90807,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[600507] = {	id = 600507, pos = { x = -8.0838, y = 6.965301, z = -7.949288 }, randomPos = 0, randomRadius = 0, monsters = { 90808,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[600508] = {	id = 600508, pos = { x = 28.45714, y = 7.072501, z = -40.79475 }, randomPos = 0, randomRadius = 0, monsters = { 90809,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[600509] = {	id = 600509, pos = { x = 40.66114, y = 6.965301, z = -20.25162 }, randomPos = 0, randomRadius = 0, monsters = { 90810,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
