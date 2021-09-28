----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[750101] = {	id = 750101, pos = { x = -3.109486, y = 32.10902, z = -79.49895 }, randomPos = 0, randomRadius = 0, monsters = { 94201,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[750102] = {	id = 750102, pos = { x = -0.1634088, y = 32.10902, z = -78.09902 }, randomPos = 0, randomRadius = 0, monsters = { 94201,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[750103] = {	id = 750103, pos = { x = 3.066339, y = 32.10902, z = -78.33465 }, randomPos = 0, randomRadius = 0, monsters = { 94201,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[750104] = {	id = 750104, pos = { x = -4.545007, y = 32.10902, z = -82.59102 }, randomPos = 0, randomRadius = 0, monsters = { 94201,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[750105] = {	id = 750105, pos = { x = -0.8144717, y = 32.10902, z = -83.45685 }, randomPos = 0, randomRadius = 0, monsters = { 94201,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[750106] = {	id = 750106, pos = { x = 3.632042, y = 32.10902, z = -82.19976 }, randomPos = 0, randomRadius = 0, monsters = { 94201,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
