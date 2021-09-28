----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[360601] = {	id = 360601, pos = { x = 0.7931804, y = 0.1985211, z = 107.3691 }, randomPos = 0, randomRadius = 0, monsters = { 90333,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[360602] = {	id = 360602, pos = { x = 5.291415, y = 0.320488, z = 107.7488 }, randomPos = 0, randomRadius = 0, monsters = { 90333,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[360603] = {	id = 360603, pos = { x = 8.880115, y = 0.2905671, z = 107.9782 }, randomPos = 0, randomRadius = 0, monsters = { 90333,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[360604] = {	id = 360604, pos = { x = 12.50163, y = 0.1588621, z = 108.7831 }, randomPos = 0, randomRadius = 0, monsters = { 90333,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[360605] = {	id = 360605, pos = { x = 16.36572, y = 0.1588621, z = 108.8501 }, randomPos = 0, randomRadius = 0, monsters = { 90333,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[360606] = {	id = 360606, pos = { x = 2.841156, y = 0.2724353, z = 104.0921 }, randomPos = 0, randomRadius = 0, monsters = { 90331,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[360607] = {	id = 360607, pos = { x = 6.902574, y = 0.2396551, z = 104.1138 }, randomPos = 0, randomRadius = 0, monsters = { 90331,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[360608] = {	id = 360608, pos = { x = 11.16784, y = 0.2250253, z = 105.5473 }, randomPos = 0, randomRadius = 0, monsters = { 90331,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[360609] = {	id = 360609, pos = { x = 15.29803, y = 0.2152759, z = 107.1803 }, randomPos = 0, randomRadius = 0, monsters = { 90331,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[360610] = {	id = 360610, pos = { x = 9.213928, y = 0.1880901, z = 102.4704 }, randomPos = 0, randomRadius = 0, monsters = { 90331,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[360611] = {	id = 360611, pos = { x = 7.997026, y = 0.1588621, z = 110.7605 }, randomPos = 0, randomRadius = 0, monsters = { 90335,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
