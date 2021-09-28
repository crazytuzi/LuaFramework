----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[560101] = {	id = 560101, pos = { x = -2.30995, y = 0.3458553, z = -34.72316 }, randomPos = 0, randomRadius = 0, monsters = { 90701,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[560102] = {	id = 560102, pos = { x = 5.202447, y = 0.2458097, z = -33.68821 }, randomPos = 0, randomRadius = 0, monsters = { 90701,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
