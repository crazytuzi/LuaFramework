----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[600101] = {	id = 600101, pos = { x = -9.337533, y = 6.965291, z = -39.89089 }, randomPos = 0, randomRadius = 0, monsters = { 90801,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[600102] = {	id = 600102, pos = { x = -8.135074, y = 6.965291, z = -33.91533 }, randomPos = 0, randomRadius = 0, monsters = { 90801,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[600103] = {	id = 600103, pos = { x = -5.735048, y = 6.965291, z = -44.18605 }, randomPos = 0, randomRadius = 0, monsters = { 90802,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[600104] = {	id = 600104, pos = { x = -3.369151, y = 6.965291, z = -37.25358 }, randomPos = 0, randomRadius = 0, monsters = { 90802,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
