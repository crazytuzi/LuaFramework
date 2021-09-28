----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[26201] = {	id = 26201, pos = { x = 60.21665, y = 12.71782, z = 68.07194 }, randomPos = 1, randomRadius = 500, monsters = { 87103,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26202] = {	id = 26202, pos = { x = 79.84527, y = 7.717823, z = -2.517002 }, randomPos = 1, randomRadius = 500, monsters = { 87103,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26203] = {	id = 26203, pos = { x = 16.88508, y = 7.717823, z = -49.0743 }, randomPos = 1, randomRadius = 500, monsters = { 87103,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26204] = {	id = 26204, pos = { x = -17.92552, y = 8.517818, z = 66.92421 }, randomPos = 1, randomRadius = 500, monsters = { 87103,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26205] = {	id = 26205, pos = { x = -81.15375, y = 8.117817, z = 53.7758 }, randomPos = 1, randomRadius = 500, monsters = { 87103,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26206] = {	id = 26206, pos = { x = -59.99516, y = 5.517818, z = 12.13472 }, randomPos = 1, randomRadius = 500, monsters = { 87103,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26301] = {	id = 26301, pos = { x = 26.64194, y = 7.853422, z = 34.06084 }, randomPos = 1, randomRadius = 200, monsters = { 87104,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26302] = {	id = 26302, pos = { x = 79.44546, y = 7.717823, z = -2.803486 }, randomPos = 1, randomRadius = 200, monsters = { 87104,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26303] = {	id = 26303, pos = { x = 19.31363, y = 7.832271, z = -42.46278 }, randomPos = 1, randomRadius = 200, monsters = { 87104,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26304] = {	id = 26304, pos = { x = -83.34771, y = 8.117817, z = 53.7471 }, randomPos = 1, randomRadius = 200, monsters = { 87104,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
