----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[290401] = {	id = 290401, pos = { x = -58.9132, y = 5.164898, z = -2.865259 }, randomPos = 0, randomRadius = 0, monsters = { 90229,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[290402] = {	id = 290402, pos = { x = -59.89487, y = 5.293882, z = 1.871101 }, randomPos = 0, randomRadius = 0, monsters = { 90224,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[290403] = {	id = 290403, pos = { x = -58.62999, y = 5.293882, z = -9.246622 }, randomPos = 0, randomRadius = 0, monsters = { 90224,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[290501] = {	id = 290501, pos = { x = -59.26937, y = 5.293882, z = -8.936243 }, randomPos = 0, randomRadius = 0, monsters = { 90221,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[290502] = {	id = 290502, pos = { x = -60.5915, y = 5.293882, z = 4.729404 }, randomPos = 0, randomRadius = 0, monsters = { 90221,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[290503] = {	id = 290503, pos = { x = -58.55202, y = 5.263766, z = -1.807671 }, randomPos = 0, randomRadius = 0, monsters = { 90224,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[290504] = {	id = 290504, pos = { x = -55.39446, y = 5.105258, z = -3.319988 }, randomPos = 0, randomRadius = 0, monsters = { 90224,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[290505] = {	id = 290505, pos = { x = -59.49044, y = 5.174681, z = -3.635969 }, randomPos = 0, randomRadius = 0, monsters = { 90225,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
