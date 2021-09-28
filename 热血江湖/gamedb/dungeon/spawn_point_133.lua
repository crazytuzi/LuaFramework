----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[26601] = {	id = 26601, pos = { x = 26.64194, y = 7.853422, z = 34.06084 }, randomPos = 1, randomRadius = 200, monsters = { 87107,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26602] = {	id = 26602, pos = { x = 79.44546, y = 7.717823, z = -2.803486 }, randomPos = 1, randomRadius = 200, monsters = { 87107,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26603] = {	id = 26603, pos = { x = 19.31363, y = 7.832271, z = -42.46278 }, randomPos = 1, randomRadius = 200, monsters = { 87107,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26604] = {	id = 26604, pos = { x = -83.34771, y = 8.117817, z = 53.7471 }, randomPos = 1, randomRadius = 200, monsters = { 87107,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26701] = {	id = 26701, pos = { x = 60.21665, y = 12.71782, z = 68.07194 }, randomPos = 1, randomRadius = 500, monsters = { 87108,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26702] = {	id = 26702, pos = { x = 79.84527, y = 7.717823, z = -2.517002 }, randomPos = 1, randomRadius = 500, monsters = { 87108,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26703] = {	id = 26703, pos = { x = 16.88508, y = 7.717823, z = -49.0743 }, randomPos = 1, randomRadius = 500, monsters = { 87108,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26704] = {	id = 26704, pos = { x = -17.92552, y = 8.517818, z = 66.92421 }, randomPos = 1, randomRadius = 500, monsters = { 87108,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26705] = {	id = 26705, pos = { x = -81.15375, y = 8.117817, z = 53.7758 }, randomPos = 1, randomRadius = 500, monsters = { 87108,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26706] = {	id = 26706, pos = { x = -59.99516, y = 5.517818, z = 12.13472 }, randomPos = 1, randomRadius = 500, monsters = { 87108,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
