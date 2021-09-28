----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[330101] = {	id = 330101, pos = { x = -0.2743721, y = 0.3588624, z = 10.48706 }, randomPos = 0, randomRadius = 0, monsters = { 90301,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[330102] = {	id = 330102, pos = { x = -0.904006, y = 0.3588624, z = 13.25271 }, randomPos = 0, randomRadius = 0, monsters = { 90301,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
