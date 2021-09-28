----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[38001] = {	id = 38001, pos = { x = 155.8114, y = -6.339142, z = -66.57272 }, randomPos = 1, randomRadius = 500, monsters = { 87801,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38002] = {	id = 38002, pos = { x = 133.1448, y = 0.3620823, z = 13.42214 }, randomPos = 1, randomRadius = 500, monsters = { 87801,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38003] = {	id = 38003, pos = { x = 13.44497, y = 9.86087, z = 47.91201 }, randomPos = 1, randomRadius = 500, monsters = { 87801,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38004] = {	id = 38004, pos = { x = 99.20882, y = 2.913062, z = 89.68689 }, randomPos = 1, randomRadius = 500, monsters = { 87801,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38005] = {	id = 38005, pos = { x = -18.82113, y = 14.26086, z = 86.06458 }, randomPos = 1, randomRadius = 500, monsters = { 87801,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38006] = {	id = 38006, pos = { x = -37.70558, y = 12.84121, z = 53.76939 }, randomPos = 1, randomRadius = 500, monsters = { 87801,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38007] = {	id = 38007, pos = { x = -43.12782, y = -3.809791, z = -72.12231 }, randomPos = 1, randomRadius = 500, monsters = { 87801,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38008] = {	id = 38008, pos = { x = 78.94543, y = -7.836576, z = -87.42985 }, randomPos = 1, randomRadius = 500, monsters = { 87801,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38009] = {	id = 38009, pos = { x = 52.97669, y = -7.886059, z = -77.82824 }, randomPos = 1, randomRadius = 500, monsters = { 87801,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38010] = {	id = 38010, pos = { x = 40.46952, y = -8.498791, z = -97.11655 }, randomPos = 1, randomRadius = 500, monsters = { 87801,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38101] = {	id = 38101, pos = { x = 133.617, y = -6.438076, z = -62.2854 }, randomPos = 1, randomRadius = 500, monsters = { 87802,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38102] = {	id = 38102, pos = { x = 115.5584, y = 0.4985199, z = 20.25848 }, randomPos = 1, randomRadius = 500, monsters = { 87802,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38103] = {	id = 38103, pos = { x = -27.71929, y = 12.79399, z = 58.41921 }, randomPos = 1, randomRadius = 500, monsters = { 87802,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38104] = {	id = 38104, pos = { x = -31.2262, y = -2.821819, z = -35.51562 }, randomPos = 1, randomRadius = 500, monsters = { 87802,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38105] = {	id = 38105, pos = { x = 33.88725, y = -8.492762, z = -78.12424 }, randomPos = 1, randomRadius = 500, monsters = { 87802,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38106] = {	id = 38106, pos = { x = 80.68314, y = -7.992308, z = -89.73083 }, randomPos = 1, randomRadius = 500, monsters = { 87802,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
