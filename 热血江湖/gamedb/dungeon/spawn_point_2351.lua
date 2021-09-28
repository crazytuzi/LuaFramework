----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[470201] = {	id = 470201, pos = { x = -8.065994, y = 6.495802, z = 14.48033 }, randomPos = 0, randomRadius = 0, monsters = { 90423,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[470202] = {	id = 470202, pos = { x = -3.331438, y = 6.130108, z = -2.898878 }, randomPos = 0, randomRadius = 0, monsters = { 90423,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[470203] = {	id = 470203, pos = { x = -1.241735, y = 6.135032, z = -3.622553 }, randomPos = 0, randomRadius = 0, monsters = { 90423,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[470204] = {	id = 470204, pos = { x = 2.112299, y = 6.137606, z = -3.650097 }, randomPos = 0, randomRadius = 0, monsters = { 90423,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[470205] = {	id = 470205, pos = { x = 4.309461, y = 6.144802, z = -2.867487 }, randomPos = 0, randomRadius = 0, monsters = { 90422,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[470206] = {	id = 470206, pos = { x = 7.494692, y = 6.154065, z = -1.860197 }, randomPos = 0, randomRadius = 0, monsters = { 90422,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[470207] = {	id = 470207, pos = { x = 2.685714, y = 6.125247, z = -4.994125 }, randomPos = 0, randomRadius = 0, monsters = { 90422,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[470208] = {	id = 470208, pos = { x = -3.915928, y = 6.183022, z = 19.80494 }, randomPos = 0, randomRadius = 0, monsters = { 90422,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[470301] = {	id = 470301, pos = { x = -5.325354, y = 6.468337, z = 14.11602 }, randomPos = 0, randomRadius = 0, monsters = { 90423,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[470302] = {	id = 470302, pos = { x = -8.138858, y = 6.426457, z = 15.32244 }, randomPos = 0, randomRadius = 0, monsters = { 90423,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[470303] = {	id = 470303, pos = { x = -9.442705, y = 6.440965, z = 10.05651 }, randomPos = 0, randomRadius = 0, monsters = { 90423,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[470304] = {	id = 470304, pos = { x = -7.76008, y = 6.245461, z = 3.631764 }, randomPos = 0, randomRadius = 0, monsters = { 90423,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[470305] = {	id = 470305, pos = { x = 15.67703, y = 6.295254, z = 9.242264 }, randomPos = 0, randomRadius = 0, monsters = { 90424,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[470306] = {	id = 470306, pos = { x = 13.60931, y = 6.343099, z = 3.135116 }, randomPos = 0, randomRadius = 0, monsters = { 90424,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[470307] = {	id = 470307, pos = { x = 12.93717, y = 6.090312, z = 0.0 }, randomPos = 0, randomRadius = 0, monsters = { 90424,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[470308] = {	id = 470308, pos = { x = 3.875566, y = 6.262553, z = 1.834414 }, randomPos = 0, randomRadius = 0, monsters = { 90424,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
