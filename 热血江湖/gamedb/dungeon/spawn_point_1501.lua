----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[300201] = {	id = 300201, pos = { x = -18.49568, y = 4.80625, z = 0.2091713 }, randomPos = 0, randomRadius = 0, monsters = { 90232,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[300202] = {	id = 300202, pos = { x = -19.042, y = 4.85847, z = -5.752593 }, randomPos = 0, randomRadius = 0, monsters = { 90232,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[300203] = {	id = 300203, pos = { x = -17.5464, y = 5.25181, z = -2.324759 }, randomPos = 0, randomRadius = 0, monsters = { 90233,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[300301] = {	id = 300301, pos = { x = -58.57949, y = 5.159242, z = -2.758258 }, randomPos = 0, randomRadius = 0, monsters = { 90239,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[300302] = {	id = 300302, pos = { x = -58.54906, y = 5.293882, z = -7.99001 }, randomPos = 0, randomRadius = 0, monsters = { 90234,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[300303] = {	id = 300303, pos = { x = -58.11489, y = 5.293882, z = 2.796791 }, randomPos = 0, randomRadius = 0, monsters = { 90234,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
