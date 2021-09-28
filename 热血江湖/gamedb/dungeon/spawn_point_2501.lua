----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[500201] = {	id = 500201, pos = { x = -17.30554, y = 9.381627, z = -52.00759 }, randomPos = 0, randomRadius = 0, monsters = { 90603,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[500202] = {	id = 500202, pos = { x = -12.83209, y = 9.522109, z = -52.20308 }, randomPos = 0, randomRadius = 0, monsters = { 90603,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[500203] = {	id = 500203, pos = { x = -9.701036, y = 9.637915, z = -49.98682 }, randomPos = 0, randomRadius = 0, monsters = { 90604,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[500204] = {	id = 500204, pos = { x = -17.51141, y = 9.346416, z = -46.32756 }, randomPos = 0, randomRadius = 0, monsters = { 90604,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[500301] = {	id = 500301, pos = { x = -15.77306, y = 9.268519, z = -42.64809 }, randomPos = 0, randomRadius = 0, monsters = { 90605,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[500302] = {	id = 500302, pos = { x = -12.77918, y = 9.381625, z = -43.59319 }, randomPos = 0, randomRadius = 0, monsters = { 90606,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[500303] = {	id = 500303, pos = { x = -10.91552, y = 9.381625, z = -44.85519 }, randomPos = 0, randomRadius = 0, monsters = { 90603,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[500304] = {	id = 500304, pos = { x = -10.76653, y = 9.600856, z = -50.15298 }, randomPos = 0, randomRadius = 0, monsters = { 90603,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[500305] = {	id = 500305, pos = { x = -8.744627, y = 9.548513, z = -46.76003 }, randomPos = 0, randomRadius = 0, monsters = { 90604,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[500306] = {	id = 500306, pos = { x = -13.78235, y = 9.384266, z = -46.89087 }, randomPos = 0, randomRadius = 0, monsters = { 90604,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
