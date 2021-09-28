----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[26801] = {	id = 26801, pos = { x = 60.21665, y = 12.71782, z = 68.07194 }, randomPos = 1, randomRadius = 500, monsters = { 87109,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26802] = {	id = 26802, pos = { x = 79.84527, y = 7.717823, z = -2.517002 }, randomPos = 1, randomRadius = 500, monsters = { 87109,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26803] = {	id = 26803, pos = { x = 16.88508, y = 7.717823, z = -49.0743 }, randomPos = 1, randomRadius = 500, monsters = { 87109,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26804] = {	id = 26804, pos = { x = -17.92552, y = 8.517818, z = 66.92421 }, randomPos = 1, randomRadius = 500, monsters = { 87109,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26805] = {	id = 26805, pos = { x = -81.15375, y = 8.117817, z = 53.7758 }, randomPos = 1, randomRadius = 500, monsters = { 87109,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26806] = {	id = 26806, pos = { x = -59.99516, y = 5.517818, z = 12.13472 }, randomPos = 1, randomRadius = 500, monsters = { 87109,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26901] = {	id = 26901, pos = { x = 26.25651, y = 7.862374, z = 33.77437 }, randomPos = 1, randomRadius = 100, monsters = { 87110,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26902] = {	id = 26902, pos = { x = 80.21004, y = 7.717823, z = -3.089966 }, randomPos = 1, randomRadius = 100, monsters = { 87110,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
