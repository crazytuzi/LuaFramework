----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[280601] = {	id = 280601, pos = { x = -32.88154, y = 4.035002, z = 64.45299 }, randomPos = 0, randomRadius = 0, monsters = { 90218,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[280602] = {	id = 280602, pos = { x = -32.43259, y = 4.038127, z = 59.11713 }, randomPos = 0, randomRadius = 0, monsters = { 90218,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
