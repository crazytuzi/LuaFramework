----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[23401] = {	id = 23401, pos = { x = 135.7061, y = 0.3540558, z = -123.4499 }, randomPos = 1, randomRadius = 600, monsters = { 89341,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23402] = {	id = 23402, pos = { x = 93.51294, y = 0.1638422, z = -45.04805 }, randomPos = 1, randomRadius = 600, monsters = { 89342,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23403] = {	id = 23403, pos = { x = 28.48684, y = 0.2866761, z = -87.07304 }, randomPos = 1, randomRadius = 600, monsters = { 89343,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23404] = {	id = 23404, pos = { x = 79.23444, y = 3.163843, z = -123.645 }, randomPos = 1, randomRadius = 600, monsters = { 89344,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23405] = {	id = 23405, pos = { x = 84.39751, y = 4.663842, z = 77.58057 }, randomPos = 1, randomRadius = 600, monsters = { 89345,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23406] = {	id = 23406, pos = { x = 29.10996, y = -8.836158, z = -27.08195 }, randomPos = 1, randomRadius = 600, monsters = { 89346,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23407] = {	id = 23407, pos = { x = -136.338, y = 4.263226, z = -92.12379 }, randomPos = 1, randomRadius = 600, monsters = { 89347,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23501] = {	id = 23501, pos = { x = -24.05108, y = 0.3046828, z = -55.02497 }, randomPos = 1, randomRadius = 600, monsters = { 89351,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23502] = {	id = 23502, pos = { x = 80.24987, y = 3.163843, z = -127.2614 }, randomPos = 1, randomRadius = 600, monsters = { 89352,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23503] = {	id = 23503, pos = { x = 145.4116, y = 3.163843, z = -73.62902 }, randomPos = 1, randomRadius = 600, monsters = { 89353,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23504] = {	id = 23504, pos = { x = 137.9486, y = 0.3149407, z = -127.5215 }, randomPos = 1, randomRadius = 600, monsters = { 89354,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
