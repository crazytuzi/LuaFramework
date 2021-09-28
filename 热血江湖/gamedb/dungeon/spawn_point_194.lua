----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[38801] = {	id = 38801, pos = { x = 134.871, y = -6.399808, z = -65.07868 }, randomPos = 1, randomRadius = 500, monsters = { 87809,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38802] = {	id = 38802, pos = { x = 120.7458, y = 0.7894689, z = 37.06141 }, randomPos = 1, randomRadius = 500, monsters = { 87809,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38803] = {	id = 38803, pos = { x = 5.687137, y = 9.86087, z = 51.03513 }, randomPos = 1, randomRadius = 500, monsters = { 87809,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38804] = {	id = 38804, pos = { x = -39.69893, y = 15.46088, z = 110.5229 }, randomPos = 1, randomRadius = 500, monsters = { 87809,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38805] = {	id = 38805, pos = { x = 96.96294, y = 3.57545352, z = 93.5218658 }, randomPos = 1, randomRadius = 500, monsters = { 87809,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38806] = {	id = 38806, pos = { x = -42.7691269, y = -3.79856086, z = -72.7082748 }, randomPos = 1, randomRadius = 500, monsters = { 87809,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38901] = {	id = 38901, pos = { x = 129.265442, y = 0.4820158, z = 22.3228073 }, randomPos = 1, randomRadius = 100, monsters = { 87810,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38902] = {	id = 38902, pos = { x = -39.08663, y = 15.4608765, z = 111.557449 }, randomPos = 1, randomRadius = 100, monsters = { 87810,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
