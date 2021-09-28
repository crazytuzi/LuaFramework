----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[270601] = {	id = 270601, pos = { x = -29.89867, y = 4.184961, z = 62.56471 }, randomPos = 0, randomRadius = 0, monsters = { 90208,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[270602] = {	id = 270602, pos = { x = -30.69173, y = 4.012983, z = 59.35727 }, randomPos = 0, randomRadius = 0, monsters = { 90208,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
