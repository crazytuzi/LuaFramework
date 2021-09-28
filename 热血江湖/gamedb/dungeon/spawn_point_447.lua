----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[89404] = {	id = 89404, pos = { x = 101.3786, y = 29.77525, z = -106.845 }, randomPos = 1, randomRadius = 500, monsters = { 89404,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[89405] = {	id = 89405, pos = { x = 136.3168, y = 29.66409, z = -138.7474 }, randomPos = 1, randomRadius = 500, monsters = { 89405,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[89406] = {	id = 89406, pos = { x = 169.6422, y = 29.6, z = -147.0048 }, randomPos = 1, randomRadius = 500, monsters = { 89406,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[89407] = {	id = 89407, pos = { x = -62.54817, y = 5.372826, z = 9.643635 }, randomPos = 1, randomRadius = 600, monsters = { 89407,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[89408] = {	id = 89408, pos = { x = -71.97653, y = 8.172829, z = 116.8487 }, randomPos = 1, randomRadius = 600, monsters = { 89408,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[89409] = {	id = 89409, pos = { x = -137.5861, y = 3.089657, z = 2.633394 }, randomPos = 1, randomRadius = 600, monsters = { 89409,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
