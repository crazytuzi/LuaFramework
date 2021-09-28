----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[280401] = {	id = 280401, pos = { x = -58.70664, y = 5.293882, z = -8.914829 }, randomPos = 0, randomRadius = 0, monsters = { 90211,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[280402] = {	id = 280402, pos = { x = -56.83812, y = 5.293882, z = 2.886276 }, randomPos = 0, randomRadius = 0, monsters = { 90211,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[280403] = {	id = 280403, pos = { x = -59.7094, y = 5.293882, z = -4.145983 }, randomPos = 0, randomRadius = 0, monsters = { 90214,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[280404] = {	id = 280404, pos = { x = -55.76172, y = 5.111483, z = -2.76313 }, randomPos = 0, randomRadius = 0, monsters = { 90214,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[280405] = {	id = 280405, pos = { x = -55.50488, y = 5.293882, z = -5.483771 }, randomPos = 0, randomRadius = 0, monsters = { 90215,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[280501] = {	id = 280501, pos = { x = -33.09626, y = 4.047714, z = 60.74086 }, randomPos = 0, randomRadius = 0, monsters = { 90216,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[280502] = {	id = 280502, pos = { x = -31.50435, y = 4.015732, z = 64.57196 }, randomPos = 0, randomRadius = 0, monsters = { 90216,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[280503] = {	id = 280503, pos = { x = -30.98317, y = 4.017192, z = 58.89252 }, randomPos = 0, randomRadius = 0, monsters = { 90216,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[280504] = {	id = 280504, pos = { x = -29.69726, y = 3.997612, z = 62.08184 }, randomPos = 0, randomRadius = 0, monsters = { 90216,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[280505] = {	id = 280505, pos = { x = -28.78101, y = 3.985382, z = 58.62893 }, randomPos = 0, randomRadius = 0, monsters = { 90217,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[280506] = {	id = 280506, pos = { x = -35.27204, y = 4.293883, z = 58.48366 }, randomPos = 0, randomRadius = 0, monsters = { 90217,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[280507] = {	id = 280507, pos = { x = -35.13257, y = 4.272477, z = 65.02641 }, randomPos = 0, randomRadius = 0, monsters = { 90217,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[280508] = {	id = 280508, pos = { x = -28.68282, y = 3.975435, z = 65.1174 }, randomPos = 0, randomRadius = 0, monsters = { 90217,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
