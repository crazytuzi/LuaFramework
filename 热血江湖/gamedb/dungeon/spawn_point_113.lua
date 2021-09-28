----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[22601] = {	id = 22601, pos = { x = -72.63423, y = 3.163843, z = 14.62455 }, randomPos = 1, randomRadius = 600, monsters = { 89261,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22602] = {	id = 22602, pos = { x = 21.38571, y = 0.1638422, z = -82.69058 }, randomPos = 1, randomRadius = 600, monsters = { 89262,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22603] = {	id = 22603, pos = { x = 88.34398, y = 3.163843, z = -131.7283 }, randomPos = 1, randomRadius = 600, monsters = { 89263,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22604] = {	id = 22604, pos = { x = 139.0221, y = 0.3026326, z = -128.0749 }, randomPos = 1, randomRadius = 600, monsters = { 89264,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22701] = {	id = 22701, pos = { x = -57.69905, y = 5.372826, z = 10.43146 }, randomPos = 1, randomRadius = 600, monsters = { 89271,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22702] = {	id = 22702, pos = { x = -73.45741, y = 8.172829, z = 116.0795 }, randomPos = 1, randomRadius = 600, monsters = { 89272,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22703] = {	id = 22703, pos = { x = 65.75636, y = 12.77283, z = 74.12128 }, randomPos = 1, randomRadius = 600, monsters = { 89273,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[22704] = {	id = 22704, pos = { x = 24.49746, y = 7.772827, z = -12.08268 }, randomPos = 1, randomRadius = 600, monsters = { 89274,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
