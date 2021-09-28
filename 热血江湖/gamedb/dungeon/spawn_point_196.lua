----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[39221] = {	id = 39221, pos = { x = -4.28517434, y = 0.0323009, z = 2.94558525 }, randomPos = 0, randomRadius = 0, monsters = { 139221,  }, spawnType = 1, spawnDTime = 10000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 90.0, z = 0.0 } },
	[39222] = {	id = 39222, pos = { x = -4.28517434, y = 0.0323009, z = 2.94558525 }, randomPos = 0, randomRadius = 0, monsters = { 139222,  }, spawnType = 1, spawnDTime = 10000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 90.0, z = 0.0 } },
	[39223] = {	id = 39223, pos = { x = -4.28517434, y = 0.0323009, z = 2.94558525 }, randomPos = 0, randomRadius = 0, monsters = { 139223,  }, spawnType = 1, spawnDTime = 10000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 90.0, z = 0.0 } },
	[39224] = {	id = 39224, pos = { x = -4.28517434, y = 0.0323009, z = 2.94558525 }, randomPos = 0, randomRadius = 0, monsters = { 139224,  }, spawnType = 1, spawnDTime = 10000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 90.0, z = 0.0 } },
	[39225] = {	id = 39225, pos = { x = -4.28517434, y = 0.0323009, z = 2.94558525 }, randomPos = 0, randomRadius = 0, monsters = { 139225,  }, spawnType = 1, spawnDTime = 10000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 90.0, z = 0.0 } },
	[39226] = {	id = 39226, pos = { x = -4.28517434, y = 0.0323009, z = 2.94558525 }, randomPos = 0, randomRadius = 0, monsters = { 139226,  }, spawnType = 1, spawnDTime = 10000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 90.0, z = 0.0 } },
	[39227] = {	id = 39227, pos = { x = -4.28517434, y = 0.0323009, z = 2.94558525 }, randomPos = 0, randomRadius = 0, monsters = { 139227,  }, spawnType = 1, spawnDTime = 10000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 90.0, z = 0.0 } },
	[39321] = {	id = 39321, pos = { x = -4.28517434, y = 0.0323009, z = 2.94558525 }, randomPos = 0, randomRadius = 0, monsters = { 139321,  }, spawnType = 1, spawnDTime = 10000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 90.0, z = 0.0 } },
	[39322] = {	id = 39322, pos = { x = -4.28517434, y = 0.0323009, z = 2.94558525 }, randomPos = 0, randomRadius = 0, monsters = { 139322,  }, spawnType = 1, spawnDTime = 10000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 90.0, z = 0.0 } },
	[39323] = {	id = 39323, pos = { x = -4.28517434, y = 0.0323009, z = 2.94558525 }, randomPos = 0, randomRadius = 0, monsters = { 139323,  }, spawnType = 1, spawnDTime = 10000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 90.0, z = 0.0 } },
	[39324] = {	id = 39324, pos = { x = -4.28517434, y = 0.0323009, z = 2.94558525 }, randomPos = 0, randomRadius = 0, monsters = { 139324,  }, spawnType = 1, spawnDTime = 10000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 90.0, z = 0.0 } },
	[39325] = {	id = 39325, pos = { x = -4.28517434, y = 0.0323009, z = 2.94558525 }, randomPos = 0, randomRadius = 0, monsters = { 139325,  }, spawnType = 1, spawnDTime = 10000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 90.0, z = 0.0 } },
	[39326] = {	id = 39326, pos = { x = -4.28517434, y = 0.0323009, z = 2.94558525 }, randomPos = 0, randomRadius = 0, monsters = { 139326,  }, spawnType = 1, spawnDTime = 10000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 90.0, z = 0.0 } },
	[39327] = {	id = 39327, pos = { x = -4.28517434, y = 0.0323009, z = 2.94558525 }, randomPos = 0, randomRadius = 0, monsters = { 139327,  }, spawnType = 1, spawnDTime = 10000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 90.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
