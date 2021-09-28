----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[3538201] = {	id = 3538201, pos = { x = -36.65028, y = 11.34099, z = -69.84069 }, randomPos = 0, randomRadius = 150, monsters = { 69930,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538202] = {	id = 3538202, pos = { x = 9.80695, y = 11.34099, z = -81.6651 }, randomPos = 0, randomRadius = 150, monsters = { 69931,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538203] = {	id = 3538203, pos = { x = -11.38232, y = 9.340994, z = -55.7404 }, randomPos = 0, randomRadius = 150, monsters = { 69932,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538204] = {	id = 3538204, pos = { x = -12.23733, y = 9.340994, z = -46.84318 }, randomPos = 0, randomRadius = 150, monsters = { 69933,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538205] = {	id = 3538205, pos = { x = 36.17731, y = 13.84099, z = -8.961752 }, randomPos = 0, randomRadius = 0, monsters = { 69934,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538206] = {	id = 3538206, pos = { x = 40.12617, y = 13.84099, z = -13.47787 }, randomPos = 0, randomRadius = 0, monsters = { 69932,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538207] = {	id = 3538207, pos = { x = 40.18526, y = 13.84099, z = -6.563169 }, randomPos = 0, randomRadius = 0, monsters = { 69932,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538301] = {	id = 3538301, pos = { x = -36.66584, y = 11.34099, z = -69.90749 }, randomPos = 0, randomRadius = 150, monsters = { 69935,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538302] = {	id = 3538302, pos = { x = 10.16543, y = 11.34099, z = -82.50935 }, randomPos = 0, randomRadius = 150, monsters = { 69936,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538303] = {	id = 3538303, pos = { x = -14.1147, y = 9.340994, z = -54.4446 }, randomPos = 0, randomRadius = 150, monsters = { 69937,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538304] = {	id = 3538304, pos = { x = -12.3505, y = 9.340994, z = -44.72585 }, randomPos = 0, randomRadius = 150, monsters = { 69938,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538305] = {	id = 3538305, pos = { x = 35.88287, y = 13.84099, z = -8.898313 }, randomPos = 0, randomRadius = 0, monsters = { 69939,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538306] = {	id = 3538306, pos = { x = 39.4672, y = 13.84099, z = -13.40456 }, randomPos = 0, randomRadius = 0, monsters = { 69937,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538307] = {	id = 3538307, pos = { x = 39.4772, y = 13.84099, z = -7.664046 }, randomPos = 0, randomRadius = 0, monsters = { 69937,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[3538308] = {	id = 3538308, pos = { x = 37.21093, y = 13.7568, z = -1.005064 }, randomPos = 0, randomRadius = 0, monsters = { 69937,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
