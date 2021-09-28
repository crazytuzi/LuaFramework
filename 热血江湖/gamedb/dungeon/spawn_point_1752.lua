----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[350401] = {	id = 350401, pos = { x = 18.083, y = 0.3514502, z = 67.22652 }, randomPos = 0, randomRadius = 0, monsters = { 90321,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350402] = {	id = 350402, pos = { x = 19.34306, y = 0.3588619, z = 73.97018 }, randomPos = 0, randomRadius = 0, monsters = { 90321,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350403] = {	id = 350403, pos = { x = 20.18694, y = 0.4798029, z = 60.93701 }, randomPos = 0, randomRadius = 0, monsters = { 90321,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350404] = {	id = 350404, pos = { x = 21.79616, y = 0.3102961, z = 67.59668 }, randomPos = 0, randomRadius = 0, monsters = { 90321,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350405] = {	id = 350405, pos = { x = 22.68385, y = 0.6097175, z = 62.40481 }, randomPos = 0, randomRadius = 0, monsters = { 90323,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350406] = {	id = 350406, pos = { x = 21.42223, y = 0.3588619, z = 73.36714 }, randomPos = 0, randomRadius = 0, monsters = { 90323,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350407] = {	id = 350407, pos = { x = 24.62795, y = 0.3017537, z = 70.62782 }, randomPos = 0, randomRadius = 0, monsters = { 90323,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350408] = {	id = 350408, pos = { x = 25.14119, y = 0.4201058, z = 64.6349 }, randomPos = 0, randomRadius = 0, monsters = { 90323,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350501] = {	id = 350501, pos = { x = 29.1895, y = 0.2150402, z = 66.73164 }, randomPos = 0, randomRadius = 0, monsters = { 90321,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350502] = {	id = 350502, pos = { x = 26.54206, y = 0.4150374, z = 62.86585 }, randomPos = 0, randomRadius = 0, monsters = { 90321,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350503] = {	id = 350503, pos = { x = 27.17037, y = 0.3217335, z = 75.79974 }, randomPos = 0, randomRadius = 0, monsters = { 90321,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350504] = {	id = 350504, pos = { x = 30.69914, y = 0.2910027, z = 72.37646 }, randomPos = 0, randomRadius = 0, monsters = { 90321,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350505] = {	id = 350505, pos = { x = 25.51992, y = 0.2675895, z = 67.79521 }, randomPos = 0, randomRadius = 0, monsters = { 90322,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350506] = {	id = 350506, pos = { x = 22.6612, y = 0.2906597, z = 66.47366 }, randomPos = 0, randomRadius = 0, monsters = { 90322,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350507] = {	id = 350507, pos = { x = 30.2408, y = 0.2223687, z = 63.21896 }, randomPos = 0, randomRadius = 0, monsters = { 90322,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350508] = {	id = 350508, pos = { x = 33.09012, y = 0.2334304, z = 71.33456 }, randomPos = 0, randomRadius = 0, monsters = { 90322,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[350509] = {	id = 350509, pos = { x = 28.34688, y = 0.257318, z = 70.61137 }, randomPos = 0, randomRadius = 0, monsters = { 90324,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
