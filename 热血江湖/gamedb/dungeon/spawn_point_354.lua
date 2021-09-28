----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[70801] = {	id = 70801, pos = { x = -13.29975, y = 5.079696, z = -10.4602 }, randomPos = 1, randomRadius = 400, monsters = { 61122,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[70802] = {	id = 70802, pos = { x = -23.3293, y = 5.079696, z = -11.20993 }, randomPos = 1, randomRadius = 400, monsters = { 61123,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[70803] = {	id = 70803, pos = { x = -41.30441, y = 5.079696, z = -10.70064 }, randomPos = 1, randomRadius = 400, monsters = { 61124,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
