----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[400401] = {	id = 400401, pos = { x = 138.5343, y = -21.46387, z = -32.02741 }, randomPos = 0, randomRadius = 0, monsters = { 90514,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[400402] = {	id = 400402, pos = { x = 123.857, y = 10.44318, z = -24.58312 }, randomPos = 0, randomRadius = 0, monsters = { 90514,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[400403] = {	id = 400403, pos = { x = 121.0024, y = 10.44425, z = -27.15073 }, randomPos = 0, randomRadius = 0, monsters = { 90514,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[400404] = {	id = 400404, pos = { x = 126.439, y = 10.41284, z = -26.09601 }, randomPos = 0, randomRadius = 0, monsters = { 90515,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[400405] = {	id = 400405, pos = { x = 123.4932, y = 10.44745, z = -26.30139 }, randomPos = 0, randomRadius = 0, monsters = { 90515,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[400406] = {	id = 400406, pos = { x = 123.4836, y = 10.42658, z = -28.87365 }, randomPos = 0, randomRadius = 0, monsters = { 90515,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[400501] = {	id = 400501, pos = { x = 107.2789, y = -22.66387, z = -81.28038 }, randomPos = 0, randomRadius = 0, monsters = { 90514,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[400502] = {	id = 400502, pos = { x = 101.1882, y = 7.394505, z = -60.53703 }, randomPos = 0, randomRadius = 0, monsters = { 90514,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[400503] = {	id = 400503, pos = { x = 102.6505, y = 7.394505, z = -62.99075 }, randomPos = 0, randomRadius = 0, monsters = { 90514,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[400504] = {	id = 400504, pos = { x = 104.5354, y = 7.394502, z = -64.24242 }, randomPos = 0, randomRadius = 0, monsters = { 90515,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[400505] = {	id = 400505, pos = { x = 105.3139, y = 7.394502, z = -66.83025 }, randomPos = 0, randomRadius = 0, monsters = { 90515,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[400506] = {	id = 400506, pos = { x = 107.0366, y = 7.394502, z = -68.37267 }, randomPos = 0, randomRadius = 0, monsters = { 90515,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[400507] = {	id = 400507, pos = { x = 105.1921, y = 7.394502, z = -64.62215 }, randomPos = 0, randomRadius = 0, monsters = { 90516,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
