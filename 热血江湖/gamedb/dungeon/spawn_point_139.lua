----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[27801] = {	id = 27801, pos = { x = 11.00378, y = 11.65138, z = -73.9537 }, randomPos = 1, randomRadius = 500, monsters = { 87209,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27802] = {	id = 27802, pos = { x = 54.77692, y = 13.43072, z = -22.31078 }, randomPos = 1, randomRadius = 500, monsters = { 87209,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27803] = {	id = 27803, pos = { x = 17.83704, y = 13.27988, z = 14.62908 }, randomPos = 1, randomRadius = 500, monsters = { 87209,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27804] = {	id = 27804, pos = { x = 66.72104, y = 20.67212, z = 42.02144 }, randomPos = 1, randomRadius = 500, monsters = { 87209,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27805] = {	id = 27805, pos = { x = 88.75452, y = 2.73953, z = -50.82665 }, randomPos = 1, randomRadius = 500, monsters = { 87209,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27806] = {	id = 27806, pos = { x = -22.98429, y = 13.27988, z = -7.496792 }, randomPos = 1, randomRadius = 500, monsters = { 87209,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27901] = {	id = 27901, pos = { x = 84.47141, y = 2.82669, z = -52.07091 }, randomPos = 1, randomRadius = 100, monsters = { 87210,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[27902] = {	id = 27902, pos = { x = -21.10784, y = 13.27988, z = -8.534794 }, randomPos = 1, randomRadius = 100, monsters = { 87210,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
