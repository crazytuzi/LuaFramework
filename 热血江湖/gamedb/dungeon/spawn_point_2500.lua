----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[500101] = {	id = 500101, pos = { x = -37.58847, y = 11.58903, z = -66.91361 }, randomPos = 0, randomRadius = 0, monsters = { 90601,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[500102] = {	id = 500102, pos = { x = -40.6572, y = 11.48979, z = -69.83304 }, randomPos = 0, randomRadius = 0, monsters = { 90601,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[500103] = {	id = 500103, pos = { x = -40.62629, y = 11.47584, z = -73.83395 }, randomPos = 0, randomRadius = 0, monsters = { 90602,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[500104] = {	id = 500104, pos = { x = -40.13, y = 11.32239, z = -76.41428 }, randomPos = 0, randomRadius = 0, monsters = { 90602,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[500105] = {	id = 500105, pos = { x = 9.720469, y = 11.38163, z = -76.32088 }, randomPos = 0, randomRadius = 0, monsters = { 90603,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[500106] = {	id = 500106, pos = { x = 11.51996, y = 11.25362, z = -80.0 }, randomPos = 0, randomRadius = 0, monsters = { 90603,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[500107] = {	id = 500107, pos = { x = 9.051322, y = 11.27421, z = -82.92768 }, randomPos = 0, randomRadius = 0, monsters = { 90603,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[500108] = {	id = 500108, pos = { x = 9.592464, y = 11.37069, z = -86.30331 }, randomPos = 0, randomRadius = 0, monsters = { 90603,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
