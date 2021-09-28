----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[37401] = {	id = 37401, pos = { x = 7.260494, y = 3.082024, z = -119.1174 }, randomPos = 1, randomRadius = 500, monsters = { 87705,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37402] = {	id = 37402, pos = { x = 16.84114, y = 5.082024, z = -86.68189 }, randomPos = 1, randomRadius = 500, monsters = { 87705,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37403] = {	id = 37403, pos = { x = -1.087616, y = 9.983038, z = -12.85097 }, randomPos = 1, randomRadius = 500, monsters = { 87705,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37404] = {	id = 37404, pos = { x = 26.44241, y = 17.08202, z = 153.0863 }, randomPos = 1, randomRadius = 500, monsters = { 87705,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37405] = {	id = 37405, pos = { x = 46.70152, y = 17.27751, z = 68.94264 }, randomPos = 1, randomRadius = 500, monsters = { 87705,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37406] = {	id = 37406, pos = { x = 121.2054, y = 22.08202, z = 13.56592 }, randomPos = 1, randomRadius = 500, monsters = { 87705,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37407] = {	id = 37407, pos = { x = 100.6433, y = 10.21025, z = -41.96925 }, randomPos = 1, randomRadius = 500, monsters = { 87705,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37408] = {	id = 37408, pos = { x = 53.1953, y = 10.09317, z = -60.08465 }, randomPos = 1, randomRadius = 500, monsters = { 87705,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37409] = {	id = 37409, pos = { x = -43.16995, y = 3.082025, z = -88.6312 }, randomPos = 1, randomRadius = 500, monsters = { 87705,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37410] = {	id = 37410, pos = { x = -37.21519, y = 3.116246, z = -59.11664 }, randomPos = 1, randomRadius = 500, monsters = { 87705,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37501] = {	id = 37501, pos = { x = 11.27256, y = 5.082024, z = -85.8174 }, randomPos = 1, randomRadius = 500, monsters = { 87706,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37502] = {	id = 37502, pos = { x = -41.6889, y = 3.082024, z = -90.35266 }, randomPos = 1, randomRadius = 500, monsters = { 87706,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37503] = {	id = 37503, pos = { x = -10.55048, y = 10.19122, z = -14.55609 }, randomPos = 1, randomRadius = 500, monsters = { 87706,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37504] = {	id = 37504, pos = { x = 17.66969, y = 17.08202, z = 154.0421 }, randomPos = 1, randomRadius = 500, monsters = { 87706,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37505] = {	id = 37505, pos = { x = -121.9062, y = 2.245599, z = -35.6047 }, randomPos = 1, randomRadius = 500, monsters = { 87706,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37506] = {	id = 37506, pos = { x = -103.7467, y = 2.170534, z = -89.03367 }, randomPos = 1, randomRadius = 500, monsters = { 87706,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
