----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[290601] = {	id = 290601, pos = { x = -33.67613, y = 4.045194, z = 64.72662 }, randomPos = 0, randomRadius = 0, monsters = { 90226,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[290602] = {	id = 290602, pos = { x = -32.43031, y = 4.038074, z = 61.02581 }, randomPos = 0, randomRadius = 0, monsters = { 90226,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[290603] = {	id = 290603, pos = { x = -30.23185, y = 4.006339, z = 61.26689 }, randomPos = 0, randomRadius = 0, monsters = { 90226,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[290604] = {	id = 290604, pos = { x = -30.48619, y = 4.002359, z = 64.33745 }, randomPos = 0, randomRadius = 0, monsters = { 90226,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[290605] = {	id = 290605, pos = { x = -34.98566, y = 4.075005, z = 58.58262 }, randomPos = 0, randomRadius = 0, monsters = { 90227,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[290606] = {	id = 290606, pos = { x = -36.40965, y = 4.080432, z = 65.60188 }, randomPos = 0, randomRadius = 0, monsters = { 90227,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[290607] = {	id = 290607, pos = { x = -28.19119, y = 3.967533, z = 65.53783 }, randomPos = 0, randomRadius = 0, monsters = { 90227,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[290608] = {	id = 290608, pos = { x = -28.83439, y = 3.986155, z = 58.9118 }, randomPos = 0, randomRadius = 0, monsters = { 90227,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[290701] = {	id = 290701, pos = { x = -32.19552, y = 4.034704, z = 59.16355 }, randomPos = 0, randomRadius = 0, monsters = { 90228,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[290702] = {	id = 290702, pos = { x = -32.30404, y = 4.024704, z = 65.32182 }, randomPos = 0, randomRadius = 0, monsters = { 90228,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
