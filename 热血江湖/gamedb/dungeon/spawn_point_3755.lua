----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[751001] = {	id = 751001, pos = { x = -0.0316291, y = 51.50901, z = 58.23781 }, randomPos = 0, randomRadius = 0, monsters = { 94309,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[751101] = {	id = 751101, pos = { x = -3.109486, y = 32.10902, z = -79.49895 }, randomPos = 0, randomRadius = 0, monsters = { 94401,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[751102] = {	id = 751102, pos = { x = -0.1634088, y = 32.10902, z = -78.09902 }, randomPos = 0, randomRadius = 0, monsters = { 94401,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[751103] = {	id = 751103, pos = { x = 3.066339, y = 32.10902, z = -78.33465 }, randomPos = 0, randomRadius = 0, monsters = { 94401,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[751104] = {	id = 751104, pos = { x = -4.545007, y = 32.10902, z = -82.59102 }, randomPos = 0, randomRadius = 0, monsters = { 94401,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[751105] = {	id = 751105, pos = { x = -0.8144717, y = 32.10902, z = -83.45685 }, randomPos = 0, randomRadius = 0, monsters = { 94401,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[751106] = {	id = 751106, pos = { x = 3.632042, y = 32.10902, z = -82.19976 }, randomPos = 0, randomRadius = 0, monsters = { 94401,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
