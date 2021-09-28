----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[27601] = {	id = 27601, pos = { x = -16.67482, y = 13.27988, z = -10.98902 }, randomPos = 1, randomRadius = 200, monsters = { 87207,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27602] = {	id = 27602, pos = { x = 10.20305, y = 11.6214, z = -74.35806 }, randomPos = 1, randomRadius = 200, monsters = { 87207,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27603] = {	id = 27603, pos = { x = 88.62429, y = 2.744729, z = -50.50016 }, randomPos = 1, randomRadius = 200, monsters = { 87207,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27604] = {	id = 27604, pos = { x = 33.9579, y = 19.77996, z = 106.3264 }, randomPos = 1, randomRadius = 200, monsters = { 87207,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27701] = {	id = 27701, pos = { x = 11.00378, y = 11.65138, z = -73.9537 }, randomPos = 1, randomRadius = 500, monsters = { 87208,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27702] = {	id = 27702, pos = { x = 54.77692, y = 13.43072, z = -22.31078 }, randomPos = 1, randomRadius = 500, monsters = { 87208,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27703] = {	id = 27703, pos = { x = 17.83704, y = 13.27988, z = 14.62908 }, randomPos = 1, randomRadius = 500, monsters = { 87208,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27704] = {	id = 27704, pos = { x = 66.72104, y = 20.67212, z = 42.02144 }, randomPos = 1, randomRadius = 500, monsters = { 87208,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27705] = {	id = 27705, pos = { x = 88.75452, y = 2.73953, z = -50.82665 }, randomPos = 1, randomRadius = 500, monsters = { 87208,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27706] = {	id = 27706, pos = { x = -22.98429, y = 13.27988, z = -7.496792 }, randomPos = 1, randomRadius = 500, monsters = { 87208,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
