----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[270101] = {	id = 270101, pos = { x = -12.97759, y = 4.998282, z = -4.973912 }, randomPos = 0, randomRadius = 0, monsters = { 90201,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[270102] = {	id = 270102, pos = { x = -13.23057, y = 4.709192, z = -0.383625 }, randomPos = 0, randomRadius = 0, monsters = { 90201,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
