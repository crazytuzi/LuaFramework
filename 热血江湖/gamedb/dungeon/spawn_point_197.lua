----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[39421] = {	id = 39421, pos = { x = -4.28517434, y = 0.0323009, z = 2.94558525 }, randomPos = 0, randomRadius = 0, monsters = { 139421,  }, spawnType = 1, spawnDTime = 10000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 90.0, z = 0.0 } },
	[39422] = {	id = 39422, pos = { x = -4.28517434, y = 0.0323009, z = 2.94558525 }, randomPos = 0, randomRadius = 0, monsters = { 139422,  }, spawnType = 1, spawnDTime = 10000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 90.0, z = 0.0 } },
	[39423] = {	id = 39423, pos = { x = -4.28517434, y = 0.0323009, z = 2.94558525 }, randomPos = 0, randomRadius = 0, monsters = { 139423,  }, spawnType = 1, spawnDTime = 10000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 90.0, z = 0.0 } },
	[39424] = {	id = 39424, pos = { x = -4.28517434, y = 0.0323009, z = 2.94558525 }, randomPos = 0, randomRadius = 0, monsters = { 139424,  }, spawnType = 1, spawnDTime = 10000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 90.0, z = 0.0 } },
	[39425] = {	id = 39425, pos = { x = -4.28517434, y = 0.0323009, z = 2.94558525 }, randomPos = 0, randomRadius = 0, monsters = { 139425,  }, spawnType = 1, spawnDTime = 10000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 90.0, z = 0.0 } },
	[39426] = {	id = 39426, pos = { x = -4.28517434, y = 0.0323009, z = 2.94558525 }, randomPos = 0, randomRadius = 0, monsters = { 139426,  }, spawnType = 1, spawnDTime = 10000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 90.0, z = 0.0 } },
	[39427] = {	id = 39427, pos = { x = -4.28517434, y = 0.0323009, z = 2.94558525 }, randomPos = 0, randomRadius = 0, monsters = { 139427,  }, spawnType = 1, spawnDTime = 10000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 90.0, z = 0.0 } },
	[39521] = {	id = 39521, pos = { x = -4.28517434, y = 0.0323009, z = 2.94558525 }, randomPos = 0, randomRadius = 0, monsters = { 139521,  }, spawnType = 1, spawnDTime = 10000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 90.0, z = 0.0 } },
	[39522] = {	id = 39522, pos = { x = -4.28517434, y = 0.0323009, z = 2.94558525 }, randomPos = 0, randomRadius = 0, monsters = { 139522,  }, spawnType = 1, spawnDTime = 10000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 90.0, z = 0.0 } },
	[39523] = {	id = 39523, pos = { x = -4.28517434, y = 0.0323009, z = 2.94558525 }, randomPos = 0, randomRadius = 0, monsters = { 139523,  }, spawnType = 1, spawnDTime = 10000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 90.0, z = 0.0 } },
	[39524] = {	id = 39524, pos = { x = -4.28517434, y = 0.0323009, z = 2.94558525 }, randomPos = 0, randomRadius = 0, monsters = { 139524,  }, spawnType = 1, spawnDTime = 10000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 90.0, z = 0.0 } },
	[39525] = {	id = 39525, pos = { x = -4.28517434, y = 0.0323009, z = 2.94558525 }, randomPos = 0, randomRadius = 0, monsters = { 139525,  }, spawnType = 1, spawnDTime = 10000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 90.0, z = 0.0 } },
	[39526] = {	id = 39526, pos = { x = -4.28517434, y = 0.0323009, z = 2.94558525 }, randomPos = 0, randomRadius = 0, monsters = { 139526,  }, spawnType = 1, spawnDTime = 10000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 90.0, z = 0.0 } },
	[39527] = {	id = 39527, pos = { x = -4.28517434, y = 0.0323009, z = 2.94558525 }, randomPos = 0, randomRadius = 0, monsters = { 139527,  }, spawnType = 1, spawnDTime = 10000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 90.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
