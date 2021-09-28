----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[23001] = {	id = 23001, pos = { x = -41.34343, y = 4.363843, z = -92.65041 }, randomPos = 1, randomRadius = 600, monsters = { 89301,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23002] = {	id = 23002, pos = { x = -52.90343, y = 3.163843, z = 18.78316 }, randomPos = 1, randomRadius = 600, monsters = { 89302,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23003] = {	id = 23003, pos = { x = 26.1837, y = 0.2811788, z = -85.60957 }, randomPos = 1, randomRadius = 600, monsters = { 89303,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23004] = {	id = 23004, pos = { x = 26.2142, y = -8.836158, z = -25.05421 }, randomPos = 1, randomRadius = 600, monsters = { 89304,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23101] = {	id = 23101, pos = { x = 111.2775, y = 7.294509, z = -59.05798 }, randomPos = 1, randomRadius = 600, monsters = { 89311,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23102] = {	id = 23102, pos = { x = 120.782, y = 10.29451, z = -19.54547 }, randomPos = 1, randomRadius = 600, monsters = { 89312,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23103] = {	id = 23103, pos = { x = 80.34344, y = 14.61905, z = 3.781344 }, randomPos = 1, randomRadius = 600, monsters = { 89313,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[23104] = {	id = 23104, pos = { x = 74.62321, y = 12.93023, z = -17.45134 }, randomPos = 1, randomRadius = 600, monsters = { 89314,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
