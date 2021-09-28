----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[220101] = {	id = 220101, pos = { x = 63.92387, y = 1.95153, z = -12.18401 }, randomPos = 0, randomRadius = 0, monsters = { 90111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[220102] = {	id = 220102, pos = { x = 67.91345, y = 1.951529, z = -13.26275 }, randomPos = 0, randomRadius = 0, monsters = { 90111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
