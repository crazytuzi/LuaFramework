----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[70601] = {	id = 70601, pos = { x = 0.053894, y = 5.858229, z = -16.09423 }, randomPos = 1, randomRadius = 500, monsters = { 61116,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[70602] = {	id = 70602, pos = { x = 2.211541, y = 6.389924, z = -0.2856617 }, randomPos = 1, randomRadius = 500, monsters = { 61117,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[70603] = {	id = 70603, pos = { x = 3.031357, y = 6.571169, z = 14.42695 }, randomPos = 1, randomRadius = 500, monsters = { 61118,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[70701] = {	id = 70701, pos = { x = -13.29975, y = 5.079696, z = -10.4602 }, randomPos = 1, randomRadius = 400, monsters = { 61119,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[70702] = {	id = 70702, pos = { x = -23.3293, y = 5.079696, z = -11.20993 }, randomPos = 1, randomRadius = 400, monsters = { 61120,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[70703] = {	id = 70703, pos = { x = -41.30441, y = 5.079696, z = -10.70064 }, randomPos = 1, randomRadius = 400, monsters = { 61121,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
