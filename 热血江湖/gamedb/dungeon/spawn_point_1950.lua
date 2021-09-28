----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[390101] = {	id = 390101, pos = { x = 74.70454, y = 12.89338, z = -14.7267 }, randomPos = 0, randomRadius = 0, monsters = { 90501,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[390102] = {	id = 390102, pos = { x = 77.80011, y = 12.92602, z = -13.97653 }, randomPos = 0, randomRadius = 0, monsters = { 90501,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
