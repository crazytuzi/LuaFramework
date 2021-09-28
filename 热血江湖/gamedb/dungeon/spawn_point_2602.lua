----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[520401] = {	id = 520401, pos = { x = 35.41484, y = 13.95815, z = -8.719515 }, randomPos = 0, randomRadius = 0, monsters = { 90629,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520402] = {	id = 520402, pos = { x = 36.58109, y = 13.911, z = -11.33597 }, randomPos = 0, randomRadius = 0, monsters = { 90627,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520403] = {	id = 520403, pos = { x = 36.06679, y = 13.93572, z = -12.23162 }, randomPos = 0, randomRadius = 0, monsters = { 90627,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520404] = {	id = 520404, pos = { x = 36.48803, y = 13.9724, z = -6.370991 }, randomPos = 0, randomRadius = 0, monsters = { 90627,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520405] = {	id = 520405, pos = { x = 36.59684, y = 13.93863, z = -8.751716 }, randomPos = 0, randomRadius = 0, monsters = { 90627,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520406] = {	id = 520406, pos = { x = 38.49199, y = 13.90284, z = -9.516986 }, randomPos = 0, randomRadius = 0, monsters = { 90628,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520407] = {	id = 520407, pos = { x = 38.06025, y = 13.98163, z = -5.98155 }, randomPos = 0, randomRadius = 0, monsters = { 90628,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520408] = {	id = 520408, pos = { x = 37.53743, y = 13.86829, z = -10.66113 }, randomPos = 0, randomRadius = 0, monsters = { 90628,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520409] = {	id = 520409, pos = { x = 38.84755, y = 13.96443, z = -7.021511 }, randomPos = 0, randomRadius = 0, monsters = { 90628,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
