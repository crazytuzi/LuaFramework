----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[23801] = {	id = 23801, pos = { x = -62.54817, y = 5.372826, z = 9.643635 }, randomPos = 1, randomRadius = 600, monsters = { 89381,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23802] = {	id = 23802, pos = { x = -71.97653, y = 8.172829, z = 116.8487 }, randomPos = 1, randomRadius = 600, monsters = { 89382,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23803] = {	id = 23803, pos = { x = -137.5861, y = 3.089657, z = 2.633394 }, randomPos = 1, randomRadius = 600, monsters = { 89383,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23901] = {	id = 23901, pos = { x = -72.0358658, y = 3.16384315, z = -3.33491325 }, randomPos = 1, randomRadius = 600, monsters = { 89391,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23902] = {	id = 23902, pos = { x = -46.8138428, y = 3.28606, z = 52.1408348 }, randomPos = 1, randomRadius = 600, monsters = { 89392,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23903] = {	id = 23903, pos = { x = -0.4780311, y = 3.13632345, z = 71.27906 }, randomPos = 1, randomRadius = 600, monsters = { 89393,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23904] = {	id = 23904, pos = { x = 45.56453, y = 3.16384315, z = 49.4022522 }, randomPos = 1, randomRadius = 600, monsters = { 89394,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23905] = {	id = 23905, pos = { x = -44.23255, y = 0.2260639, z = -38.68163 }, randomPos = 1, randomRadius = 600, monsters = { 89395,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23906] = {	id = 23906, pos = { x = 15.39809, y = 23.91181, z = -58.4197 }, randomPos = 1, randomRadius = 600, monsters = { 89396,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23907] = {	id = 23907, pos = { x = 51.19707, y = 24.13128, z = -32.55621 }, randomPos = 1, randomRadius = 600, monsters = { 89397,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23908] = {	id = 23908, pos = { x = 13.10678, y = 29.72559, z = 20.0772 }, randomPos = 0, randomRadius = 0, monsters = { 89398,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
