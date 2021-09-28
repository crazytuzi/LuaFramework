----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[720401] = {	id = 720401, pos = { x = -16.21053, y = 22.0, z = -9.653702 }, randomPos = 0, randomRadius = 0, monsters = { 94103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[720402] = {	id = 720402, pos = { x = -17.70745, y = 22.0, z = -11.44246 }, randomPos = 0, randomRadius = 0, monsters = { 94103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[720403] = {	id = 720403, pos = { x = -14.43962, y = 21.0, z = -23.37025 }, randomPos = 0, randomRadius = 0, monsters = { 94104,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[720404] = {	id = 720404, pos = { x = -12.29054, y = 21.0, z = -24.8069 }, randomPos = 0, randomRadius = 0, monsters = { 94104,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[720501] = {	id = 720501, pos = { x = 43.57144, y = 18.44143, z = -47.33701 }, randomPos = 0, randomRadius = 0, monsters = { 94104,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[720502] = {	id = 720502, pos = { x = 33.44061, y = 17.93892, z = -46.12031 }, randomPos = 0, randomRadius = 0, monsters = { 94101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[720503] = {	id = 720503, pos = { x = 34.71526, y = 17.94742, z = -52.0578 }, randomPos = 0, randomRadius = 0, monsters = { 94101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[720504] = {	id = 720504, pos = { x = 41.7292, y = 18.55252, z = -47.33971 }, randomPos = 0, randomRadius = 0, monsters = { 94103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[720505] = {	id = 720505, pos = { x = 40.46103, y = 18.4, z = -41.83376 }, randomPos = 0, randomRadius = 0, monsters = { 94102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[720506] = {	id = 720506, pos = { x = 42.24212, y = 18.31273, z = -52.361 }, randomPos = 0, randomRadius = 0, monsters = { 94102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[720507] = {	id = 720507, pos = { x = 33.44522, y = 17.909, z = -48.74064 }, randomPos = 0, randomRadius = 0, monsters = { 94105,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
