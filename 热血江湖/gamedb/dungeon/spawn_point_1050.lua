----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[210101] = {	id = 210101, pos = { x = 64.57233, y = 1.951529, z = -12.07419 }, randomPos = 0, randomRadius = 0, monsters = { 90104,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[210102] = {	id = 210102, pos = { x = 69.11394, y = 1.951529, z = -13.9164 }, randomPos = 0, randomRadius = 0, monsters = { 90104,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
