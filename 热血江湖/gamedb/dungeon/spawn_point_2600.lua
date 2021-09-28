----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[520101] = {	id = 520101, pos = { x = -40.1225, y = 11.38163, z = -61.96347 }, randomPos = 0, randomRadius = 0, monsters = { 90621,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520102] = {	id = 520102, pos = { x = -39.60836, y = 11.38163, z = -64.69678 }, randomPos = 0, randomRadius = 0, monsters = { 90621,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520103] = {	id = 520103, pos = { x = -41.37775, y = 11.4505, z = -69.98703 }, randomPos = 0, randomRadius = 0, monsters = { 90621,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520104] = {	id = 520104, pos = { x = -41.9757, y = 11.47253, z = -73.28238 }, randomPos = 0, randomRadius = 0, monsters = { 90622,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520105] = {	id = 520105, pos = { x = -42.6113, y = 11.34142, z = -75.09332 }, randomPos = 0, randomRadius = 0, monsters = { 90622,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520106] = {	id = 520106, pos = { x = -39.68497, y = 11.50885, z = -67.99207 }, randomPos = 0, randomRadius = 0, monsters = { 90622,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520107] = {	id = 520107, pos = { x = 7.823785, y = 11.38163, z = -73.59138 }, randomPos = 0, randomRadius = 0, monsters = { 90623,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520108] = {	id = 520108, pos = { x = 11.08883, y = 11.38163, z = -76.57554 }, randomPos = 0, randomRadius = 0, monsters = { 90623,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520109] = {	id = 520109, pos = { x = 13.09334, y = 11.38163, z = -79.54817 }, randomPos = 0, randomRadius = 0, monsters = { 90623,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520110] = {	id = 520110, pos = { x = 12.62809, y = 11.34713, z = -82.33788 }, randomPos = 0, randomRadius = 0, monsters = { 90623,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520111] = {	id = 520111, pos = { x = 10.67003, y = 11.37664, z = -85.568 }, randomPos = 0, randomRadius = 0, monsters = { 90623,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520112] = {	id = 520112, pos = { x = 7.994687, y = 11.38107, z = -86.83602 }, randomPos = 0, randomRadius = 0, monsters = { 90623,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
