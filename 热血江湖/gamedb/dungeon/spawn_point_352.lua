----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[70401] = {	id = 70401, pos = { x = 4.627218, y = -11.1838, z = 4.655878 }, randomPos = 1, randomRadius = 500, monsters = { 61110,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[70402] = {	id = 70402, pos = { x = -1.412882, y = -11.67603, z = -0.8697147 }, randomPos = 1, randomRadius = 500, monsters = { 61111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[70403] = {	id = 70403, pos = { x = -6.858434, y = -11.47786, z = 9.048559 }, randomPos = 1, randomRadius = 500, monsters = { 61112,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[70501] = {	id = 70501, pos = { x = 52.23679, y = 7.919979, z = 62.76239 }, randomPos = 1, randomRadius = 500, monsters = { 61113,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[70502] = {	id = 70502, pos = { x = 49.37043, y = 7.940803, z = 62.5099 }, randomPos = 1, randomRadius = 500, monsters = { 61114,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[70503] = {	id = 70503, pos = { x = 50.8034, y = 7.87761, z = 61.178 }, randomPos = 1, randomRadius = 500, monsters = { 61115,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
