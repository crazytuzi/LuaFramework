----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[410201] = {	id = 410201, pos = { x = 77.67618, y = -19.48071, z = 8.216753 }, randomPos = 0, randomRadius = 0, monsters = { 90521,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410202] = {	id = 410202, pos = { x = 81.06784, y = 14.7945, z = 9.367432 }, randomPos = 0, randomRadius = 0, monsters = { 90521,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410203] = {	id = 410203, pos = { x = 81.57624, y = 14.7945, z = 11.65289 }, randomPos = 0, randomRadius = 0, monsters = { 90521,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410204] = {	id = 410204, pos = { x = 79.62754, y = 14.7945, z = 11.89192 }, randomPos = 0, randomRadius = 0, monsters = { 90521,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410205] = {	id = 410205, pos = { x = 78.61933, y = 14.7945, z = 9.484919 }, randomPos = 0, randomRadius = 0, monsters = { 90522,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410206] = {	id = 410206, pos = { x = 83.94148, y = 14.7945, z = 8.388784 }, randomPos = 0, randomRadius = 0, monsters = { 90522,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410207] = {	id = 410207, pos = { x = 82.65593, y = 14.7945, z = 8.780672 }, randomPos = 0, randomRadius = 0, monsters = { 90522,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410208] = {	id = 410208, pos = { x = 84.97913, y = -19.43674, z = 9.057213 }, randomPos = 0, randomRadius = 0, monsters = { 90522,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410209] = {	id = 410209, pos = { x = 80.86351, y = 14.7945, z = 9.557184 }, randomPos = 0, randomRadius = 0, monsters = { 90523,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410301] = {	id = 410301, pos = { x = 129.0584, y = -19.33708, z = -24.07459 }, randomPos = 0, randomRadius = 0, monsters = { 90524,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410302] = {	id = 410302, pos = { x = 122.7471, y = 10.45622, z = -22.41032 }, randomPos = 0, randomRadius = 0, monsters = { 90524,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410303] = {	id = 410303, pos = { x = 120.4836, y = 10.46754, z = -24.88161 }, randomPos = 0, randomRadius = 0, monsters = { 90524,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410304] = {	id = 410304, pos = { x = 125.3751, y = 10.42534, z = -22.82152 }, randomPos = 0, randomRadius = 0, monsters = { 90524,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410305] = {	id = 410305, pos = { x = 126.4911, y = 10.41223, z = -21.64746 }, randomPos = 0, randomRadius = 0, monsters = { 90521,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410306] = {	id = 410306, pos = { x = 122.6037, y = 10.4579, z = -23.77642 }, randomPos = 0, randomRadius = 0, monsters = { 90521,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410307] = {	id = 410307, pos = { x = 123.9483, y = 10.4421, z = -23.26703 }, randomPos = 0, randomRadius = 0, monsters = { 90521,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[410308] = {	id = 410308, pos = { x = 131.943, y = -19.30217, z = -9.329424 }, randomPos = 0, randomRadius = 0, monsters = { 90521,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
