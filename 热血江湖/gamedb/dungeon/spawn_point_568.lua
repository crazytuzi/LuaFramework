----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[113601] = {	id = 113601, pos = { x = 80.1581, y = 14.63206, z = 3.828178 }, randomPos = 1, randomRadius = 500, monsters = { 150529,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[113602] = {	id = 113602, pos = { x = 121.835, y = 10.54602, z = -10.3216 }, randomPos = 1, randomRadius = 500, monsters = { 150530,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[113603] = {	id = 113603, pos = { x = 110.0486, y = 7.294509, z = -57.62038 }, randomPos = 1, randomRadius = 500, monsters = { 150531,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[113604] = {	id = 113604, pos = { x = 108.2866, y = 7.294509, z = -62.05363 }, randomPos = 0, randomRadius = 0, monsters = { 150532,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[113605] = {	id = 113605, pos = { x = 102.9138, y = 7.294509, z = -63.44401 }, randomPos = 0, randomRadius = 0, monsters = { 150533,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
