----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[23601] = {	id = 23601, pos = { x = -37.5817, y = 7.0, z = 32.39212 }, randomPos = 1, randomRadius = 600, monsters = { 89361,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23602] = {	id = 23602, pos = { x = -72.31445, y = 7.014014, z = 33.22881 }, randomPos = 1, randomRadius = 600, monsters = { 89362,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23603] = {	id = 23603, pos = { x = -84.47673, y = 7.0, z = -0.003582 }, randomPos = 1, randomRadius = 600, monsters = { 89363,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23604] = {	id = 23604, pos = { x = -39.53854, y = 5.110483, z = -40.91208 }, randomPos = 1, randomRadius = 600, monsters = { 89364,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23605] = {	id = 23605, pos = { x = 31.50243, y = 5.0, z = -56.95334 }, randomPos = 1, randomRadius = 600, monsters = { 89365,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23701] = {	id = 23701, pos = { x = 64.07001, y = 2.2057, z = 52.77488 }, randomPos = 1, randomRadius = 600, monsters = { 89371,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23702] = {	id = 23702, pos = { x = 82.08879, y = 2.2057, z = 40.22318 }, randomPos = 1, randomRadius = 600, monsters = { 89372,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23703] = {	id = 23703, pos = { x = 62.48178, y = 1.805698, z = -12.59898 }, randomPos = 1, randomRadius = 600, monsters = { 89373,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
