----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[660101] = {	id = 660101, pos = { x = 65.78743, y = 18.96508, z = -60.13654 }, randomPos = 0, randomRadius = 0, monsters = { 92112,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[660102] = {	id = 660102, pos = { x = 57.29946, y = 18.84671, z = -52.09647 }, randomPos = 0, randomRadius = 0, monsters = { 92112,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[660103] = {	id = 660103, pos = { x = 57.86369, y = 18.96514, z = -63.26352 }, randomPos = 0, randomRadius = 0, monsters = { 92112,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[660104] = {	id = 660104, pos = { x = 57.4176, y = 18.90806, z = -57.78828 }, randomPos = 0, randomRadius = 0, monsters = { 92112,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[660105] = {	id = 660105, pos = { x = 61.51764, y = 18.92715, z = -61.72626 }, randomPos = 0, randomRadius = 0, monsters = { 92113,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[660106] = {	id = 660106, pos = { x = 61.49447, y = 18.89491, z = -55.13992 }, randomPos = 0, randomRadius = 0, monsters = { 92113,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
