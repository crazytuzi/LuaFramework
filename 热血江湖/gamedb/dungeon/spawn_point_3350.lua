----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[670101] = {	id = 670101, pos = { x = 66.74775, y = 18.98119, z = -62.4054 }, randomPos = 0, randomRadius = 0, monsters = { 92122,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[670102] = {	id = 670102, pos = { x = 62.6212, y = 18.95069, z = -64.47446 }, randomPos = 0, randomRadius = 0, monsters = { 92122,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[670103] = {	id = 670103, pos = { x = 60.15578, y = 18.87306, z = -53.65054 }, randomPos = 0, randomRadius = 0, monsters = { 92122,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[670104] = {	id = 670104, pos = { x = 55.77579, y = 18.98566, z = -64.03286 }, randomPos = 0, randomRadius = 0, monsters = { 92122,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[670105] = {	id = 670105, pos = { x = 56.54295, y = 18.8687, z = -53.71026 }, randomPos = 0, randomRadius = 0, monsters = { 92123,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[670106] = {	id = 670106, pos = { x = 63.4405, y = 18.92743, z = -59.3746 }, randomPos = 0, randomRadius = 0, monsters = { 92123,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[670107] = {	id = 670107, pos = { x = 58.0083, y = 18.93001, z = -60.11684 }, randomPos = 0, randomRadius = 0, monsters = { 92123,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
