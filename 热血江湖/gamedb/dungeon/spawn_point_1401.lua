----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[280201] = {	id = 280201, pos = { x = -13.68891, y = 4.743409, z = 0.7391596 }, randomPos = 0, randomRadius = 0, monsters = { 90212,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[280202] = {	id = 280202, pos = { x = -17.95621, y = 4.735055, z = -6.432546 }, randomPos = 0, randomRadius = 0, monsters = { 90212,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[280203] = {	id = 280203, pos = { x = -17.91725, y = 5.017481, z = -3.027995 }, randomPos = 0, randomRadius = 0, monsters = { 90213,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[280301] = {	id = 280301, pos = { x = -58.82481, y = 5.163399, z = -3.340631 }, randomPos = 0, randomRadius = 0, monsters = { 90219,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[280302] = {	id = 280302, pos = { x = -59.06656, y = 5.293882, z = -6.710267 }, randomPos = 0, randomRadius = 0, monsters = { 90214,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[280303] = {	id = 280303, pos = { x = -59.4573, y = 5.293882, z = 2.97394 }, randomPos = 0, randomRadius = 0, monsters = { 90214,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
