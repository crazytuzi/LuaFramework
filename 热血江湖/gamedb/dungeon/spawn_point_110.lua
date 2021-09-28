----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[22001] = {	id = 22001, pos = { x = -58.76669, y = 5.517818, z = 9.321932 }, randomPos = 1, randomRadius = 600, monsters = { 89201,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22002] = {	id = 22002, pos = { x = -75.78055, y = 8.117817, z = 121.2807 }, randomPos = 1, randomRadius = 600, monsters = { 89202,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22003] = {	id = 22003, pos = { x = 58.26075, y = 12.71782, z = 51.47617 }, randomPos = 1, randomRadius = 600, monsters = { 89203,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22004] = {	id = 22004, pos = { x = 24.23328, y = 7.91782, z = -2.56691 }, randomPos = 1, randomRadius = 600, monsters = { 89204,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22101] = {	id = 22101, pos = { x = -91.41425, y = 3.163843, z = 22.23435 }, randomPos = 1, randomRadius = 600, monsters = { 89211,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22102] = {	id = 22102, pos = { x = -85.20828, y = 17.26384, z = 106.4882 }, randomPos = 0, randomRadius = 0, monsters = { 89212,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22103] = {	id = 22103, pos = { x = 17.00671, y = 3.047048, z = 66.75765 }, randomPos = 1, randomRadius = 600, monsters = { 89213,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22104] = {	id = 22104, pos = { x = -40.13931, y = 0.2285054, z = -37.16257 }, randomPos = 0, randomRadius = 0, monsters = { 89214,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22105] = {	id = 22105, pos = { x = -73.37281, y = 7.18609, z = -120.4009 }, randomPos = 1, randomRadius = 600, monsters = { 89215,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22106] = {	id = 22106, pos = { x = -135.6965, y = 4.201069, z = -86.17261 }, randomPos = 1, randomRadius = 600, monsters = { 89216,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
