----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[26001] = {	id = 26001, pos = { x = 59.48696, y = 12.71782, z = 52.6192 }, randomPos = 1, randomRadius = 500, monsters = { 87101,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26002] = {	id = 26002, pos = { x = 80.46183, y = 7.717823, z = -2.230522 }, randomPos = 1, randomRadius = 500, monsters = { 87101,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26003] = {	id = 26003, pos = { x = 16.49266, y = 7.717823, z = -52.24583 }, randomPos = 1, randomRadius = 500, monsters = { 87101,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26004] = {	id = 26004, pos = { x = -59.69699, y = 5.517818, z = 12.4212 }, randomPos = 1, randomRadius = 500, monsters = { 87101,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26005] = {	id = 26005, pos = { x = -83.17052, y = 8.117817, z = 54.03358 }, randomPos = 1, randomRadius = 500, monsters = { 87101,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26006] = {	id = 26006, pos = { x = -18.38469, y = 8.517821, z = 67.21068 }, randomPos = 1, randomRadius = 500, monsters = { 87101,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26007] = {	id = 26007, pos = { x = 59.50853, y = 12.71782, z = 84.29011 }, randomPos = 1, randomRadius = 500, monsters = { 87101,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26008] = {	id = 26008, pos = { x = -73.41734, y = 8.117817, z = 119.3838 }, randomPos = 1, randomRadius = 500, monsters = { 87101,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26009] = {	id = 26009, pos = { x = -133.7206, y = 3.117821, z = 4.818222 }, randomPos = 1, randomRadius = 500, monsters = { 87101,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26010] = {	id = 26010, pos = { x = 26.81274, y = 7.844469, z = 34.34732 }, randomPos = 1, randomRadius = 500, monsters = { 87101,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26101] = {	id = 26101, pos = { x = 60.21665, y = 12.71782, z = 68.07194 }, randomPos = 1, randomRadius = 500, monsters = { 87102,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26102] = {	id = 26102, pos = { x = 79.84527, y = 7.717823, z = -2.517002 }, randomPos = 1, randomRadius = 500, monsters = { 87102,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26103] = {	id = 26103, pos = { x = 16.88508, y = 7.717823, z = -49.0743 }, randomPos = 1, randomRadius = 500, monsters = { 87102,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26104] = {	id = 26104, pos = { x = -17.92552, y = 8.517818, z = 66.92421 }, randomPos = 1, randomRadius = 500, monsters = { 87102,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26105] = {	id = 26105, pos = { x = -81.15375, y = 8.117817, z = 53.7758 }, randomPos = 1, randomRadius = 500, monsters = { 87102,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[26106] = {	id = 26106, pos = { x = -59.99516, y = 5.517818, z = 12.13472 }, randomPos = 1, randomRadius = 500, monsters = { 87102,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
