----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[38201] = {	id = 38201, pos = { x = 142.5217, y = -6.339142, z = -95.21505 }, randomPos = 1, randomRadius = 500, monsters = { 87803,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38202] = {	id = 38202, pos = { x = 121.143, y = 0.3650345, z = 13.87405 }, randomPos = 1, randomRadius = 500, monsters = { 87803,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38203] = {	id = 38203, pos = { x = 8.268564, y = 9.86087, z = 57.77931 }, randomPos = 1, randomRadius = 500, monsters = { 87803,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38204] = {	id = 38204, pos = { x = -43.07993, y = -3.832644, z = -69.84756 }, randomPos = 1, randomRadius = 500, monsters = { 87803,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38205] = {	id = 38205, pos = { x = 128.7913, y = -6.350286, z = -68.21202 }, randomPos = 1, randomRadius = 500, monsters = { 87803,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38206] = {	id = 38206, pos = { x = -31.94643, y = 14.26086, z = 88.02228 }, randomPos = 1, randomRadius = 500, monsters = { 87803,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38301] = {	id = 38301, pos = { x = 15.87988, y = 9.86087, z = 51.54388 }, randomPos = 1, randomRadius = 200, monsters = { 87804,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38302] = {	id = 38302, pos = { x = -41.17438, y = -3.810528, z = -69.1338 }, randomPos = 1, randomRadius = 200, monsters = { 87804,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38303] = {	id = 38303, pos = { x = 124.9717, y = 0.3149521, z = 21.20529 }, randomPos = 1, randomRadius = 200, monsters = { 87804,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38304] = {	id = 38304, pos = { x = 129.1568, y = -6.339142, z = -74.25673 }, randomPos = 1, randomRadius = 200, monsters = { 87804,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
