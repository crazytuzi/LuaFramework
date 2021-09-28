----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[510201] = {	id = 510201, pos = { x = -19.65163, y = 9.409905, z = -47.29394 }, randomPos = 0, randomRadius = 0, monsters = { 90613,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[510202] = {	id = 510202, pos = { x = -15.64494, y = 9.397374, z = -49.45289 }, randomPos = 0, randomRadius = 0, monsters = { 90613,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[510203] = {	id = 510203, pos = { x = -12.90805, y = 9.51874, z = -49.99489 }, randomPos = 0, randomRadius = 0, monsters = { 90613,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[510204] = {	id = 510204, pos = { x = -9.241899, y = 9.681313, z = -52.63168 }, randomPos = 0, randomRadius = 0, monsters = { 90614,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[510205] = {	id = 510205, pos = { x = -14.99155, y = 9.426349, z = -51.17995 }, randomPos = 0, randomRadius = 0, monsters = { 90614,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[510206] = {	id = 510206, pos = { x = -11.85323, y = 9.565516, z = -53.118 }, randomPos = 0, randomRadius = 0, monsters = { 90614,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[510301] = {	id = 510301, pos = { x = -16.58884, y = 9.316567, z = -44.90977 }, randomPos = 0, randomRadius = 0, monsters = { 90615,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[510302] = {	id = 510302, pos = { x = -13.49046, y = 9.381625, z = -44.77201 }, randomPos = 0, randomRadius = 0, monsters = { 90616,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[510303] = {	id = 510303, pos = { x = -10.01661, y = 9.421505, z = -45.39666 }, randomPos = 0, randomRadius = 0, monsters = { 90613,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[510304] = {	id = 510304, pos = { x = -7.376977, y = 9.474952, z = -47.30659 }, randomPos = 0, randomRadius = 0, monsters = { 90613,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[510305] = {	id = 510305, pos = { x = -5.465198, y = 9.736094, z = -49.68735 }, randomPos = 0, randomRadius = 0, monsters = { 90613,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[510306] = {	id = 510306, pos = { x = -13.08862, y = 9.408463, z = -46.82159 }, randomPos = 0, randomRadius = 0, monsters = { 90614,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[510307] = {	id = 510307, pos = { x = -10.27839, y = 9.411388, z = -47.77886 }, randomPos = 0, randomRadius = 0, monsters = { 90614,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[510308] = {	id = 510308, pos = { x = -8.754342, y = 9.659872, z = -48.96373 }, randomPos = 0, randomRadius = 0, monsters = { 90614,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
