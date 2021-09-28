----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[120401] = {	id = 120401, pos = { x = 63.12199, y = 13.0, z = 8.56324 }, randomPos = 1, randomRadius = 600, monsters = { 160017,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[120402] = {	id = 120402, pos = { x = 46.63659, y = 13.01454, z = 29.73122 }, randomPos = 1, randomRadius = 600, monsters = { 160018,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[120403] = {	id = 120403, pos = { x = -44.51308, y = 5.003913, z = -30.87401 }, randomPos = 1, randomRadius = 400, monsters = { 160019,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[120404] = {	id = 120404, pos = { x = -39.02768, y = 5.118612, z = -43.19123 }, randomPos = 1, randomRadius = 600, monsters = { 160020,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[120405] = {	id = 120405, pos = { x = -86.36784, y = 7.0, z = 1.266651 }, randomPos = 1, randomRadius = 400, monsters = { 160021,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[120406] = {	id = 120406, pos = { x = -60.89331, y = 7.0, z = 26.79877 }, randomPos = 1, randomRadius = 400, monsters = { 160022,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[120501] = {	id = 120501, pos = { x = 82.24585, y = 0.3042052, z = 4.148019 }, randomPos = 1, randomRadius = 600, monsters = { 160023,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[120502] = {	id = 120502, pos = { x = -35.16279, y = 3.163843, z = 34.26233 }, randomPos = 1, randomRadius = 600, monsters = { 160024,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[120503] = {	id = 120503, pos = { x = -46.80666, y = 0.4189898, z = -33.35884 }, randomPos = 1, randomRadius = 600, monsters = { 160025,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[120504] = {	id = 120504, pos = { x = 31.25091, y = -8.836158, z = -30.16941 }, randomPos = 1, randomRadius = 600, monsters = { 160026,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[120505] = {	id = 120505, pos = { x = 90.348, y = 0.1638422, z = -46.64404 }, randomPos = 1, randomRadius = 600, monsters = { 160027,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[120506] = {	id = 120506, pos = { x = 56.5384, y = 0.3220883, z = -92.34895 }, randomPos = 1, randomRadius = 600, monsters = { 160028,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
