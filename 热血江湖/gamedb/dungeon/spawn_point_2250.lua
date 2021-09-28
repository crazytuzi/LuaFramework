----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[450101] = {	id = 450101, pos = { x = 3.093846, y = 6.508111, z = 17.49626 }, randomPos = 0, randomRadius = 0, monsters = { 90401,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[450102] = {	id = 450102, pos = { x = 8.14128, y = 6.511759, z = 14.765 }, randomPos = 0, randomRadius = 0, monsters = { 90401,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[450103] = {	id = 450103, pos = { x = -2.6588, y = 6.527854, z = 16.2408 }, randomPos = 0, randomRadius = 0, monsters = { 90402,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[450104] = {	id = 450104, pos = { x = 1.688141, y = 6.534448, z = 17.53813 }, randomPos = 0, randomRadius = 0, monsters = { 90402,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[450002] = {	id = 450002, pos = { x = -106.3891, y = 50.47525, z = 62.35673 }, randomPos = 1, randomRadius = 350, monsters = { 450002,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[450004] = {	id = 450004, pos = { x = -82.01904, y = 44.97719, z = 9.227322 }, randomPos = 0, randomRadius = 350, monsters = { 450004,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[450003] = {	id = 450003, pos = { x = -104.0, y = 50.0, z = 22.0 }, randomPos = 1, randomRadius = 350, monsters = { 450003,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[450005] = {	id = 450005, pos = { x = 102.0, y = 30.0, z = 120.0 }, randomPos = 0, randomRadius = 500, monsters = { 450005,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
