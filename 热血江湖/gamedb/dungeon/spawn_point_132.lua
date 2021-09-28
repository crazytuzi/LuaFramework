----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[26401] = {	id = 26401, pos = { x = 59.48696, y = 12.71782, z = 52.6192 }, randomPos = 1, randomRadius = 500, monsters = { 87105,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26402] = {	id = 26402, pos = { x = 80.46183, y = 7.717823, z = -2.230522 }, randomPos = 1, randomRadius = 500, monsters = { 87105,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26403] = {	id = 26403, pos = { x = 16.49266, y = 7.717823, z = -52.24583 }, randomPos = 1, randomRadius = 500, monsters = { 87105,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26404] = {	id = 26404, pos = { x = -59.69699, y = 5.517818, z = 12.4212 }, randomPos = 1, randomRadius = 500, monsters = { 87105,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26405] = {	id = 26405, pos = { x = -83.17052, y = 8.117817, z = 54.03358 }, randomPos = 1, randomRadius = 500, monsters = { 87105,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26406] = {	id = 26406, pos = { x = -18.38469, y = 8.517821, z = 67.21068 }, randomPos = 1, randomRadius = 500, monsters = { 87105,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26407] = {	id = 26407, pos = { x = 59.50853, y = 12.71782, z = 84.29011 }, randomPos = 1, randomRadius = 500, monsters = { 87105,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26408] = {	id = 26408, pos = { x = -73.41734, y = 8.117817, z = 119.3838 }, randomPos = 1, randomRadius = 500, monsters = { 87105,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26409] = {	id = 26409, pos = { x = -133.7206, y = 3.117821, z = 4.818222 }, randomPos = 1, randomRadius = 500, monsters = { 87105,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26410] = {	id = 26410, pos = { x = 26.81274, y = 7.844469, z = 34.34732 }, randomPos = 1, randomRadius = 500, monsters = { 87105,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26501] = {	id = 26501, pos = { x = 60.21665, y = 12.71782, z = 68.07194 }, randomPos = 1, randomRadius = 500, monsters = { 87106,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26502] = {	id = 26502, pos = { x = 79.84527, y = 7.717823, z = -2.517002 }, randomPos = 1, randomRadius = 500, monsters = { 87106,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26503] = {	id = 26503, pos = { x = 16.88508, y = 7.717823, z = -49.0743 }, randomPos = 1, randomRadius = 500, monsters = { 87106,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26504] = {	id = 26504, pos = { x = -17.92552, y = 8.517818, z = 66.92421 }, randomPos = 1, randomRadius = 500, monsters = { 87106,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26505] = {	id = 26505, pos = { x = -81.15375, y = 8.117817, z = 53.7758 }, randomPos = 1, randomRadius = 500, monsters = { 87106,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26506] = {	id = 26506, pos = { x = -59.99516, y = 5.517818, z = 12.13472 }, randomPos = 1, randomRadius = 500, monsters = { 87106,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
