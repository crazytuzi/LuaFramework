----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[330601] = {	id = 330601, pos = { x = 11.66348, y = 0.439172, z = 108.342 }, randomPos = 0, randomRadius = 0, monsters = { 90303,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[330602] = {	id = 330602, pos = { x = 6.61854, y = 0.5106384, z = 109.7709 }, randomPos = 0, randomRadius = 0, monsters = { 90303,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[330603] = {	id = 330603, pos = { x = 8.550344, y = 0.4659881, z = 111.2135 }, randomPos = 0, randomRadius = 0, monsters = { 90305,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
