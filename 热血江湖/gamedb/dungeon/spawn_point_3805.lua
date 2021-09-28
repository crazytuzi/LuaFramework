----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[761101] = {	id = 761101, pos = { x = -0.3543301, y = 0.6713789, z = -96.31799 }, randomPos = 0, randomRadius = 0, monsters = { 61411,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 1, faceDir = { x = 0.0, y = 15.0, z = 0.0 } },
	[761102] = {	id = 761102, pos = { x = 0.5531296, y = 0.1966333, z = -99.18176 }, randomPos = 0, randomRadius = 0, monsters = { 61411,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 1, faceDir = { x = 0.0, y = 15.0, z = 0.0 } },
	[761103] = {	id = 761103, pos = { x = 0.8175139, y = 0.4183498, z = -93.19749 }, randomPos = 0, randomRadius = 0, monsters = { 61411,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 1, faceDir = { x = 0.0, y = 15.0, z = 0.0 } },
	[761104] = {	id = 761104, pos = { x = 3.623938, y = 0.1966333, z = -90.88429 }, randomPos = 0, randomRadius = 0, monsters = { 61411,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 1, faceDir = { x = 0.0, y = 15.0, z = 0.0 } },
	[761105] = {	id = 761105, pos = { x = 12.91884, y = 0.1966333, z = -89.1032 }, randomPos = 0, randomRadius = 0, monsters = { 61411,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 1, faceDir = { x = 0.0, y = 120.0, z = 0.0 } },
	[761106] = {	id = 761106, pos = { x = 15.49026, y = 0.1966333, z = -92.63862 }, randomPos = 0, randomRadius = 0, monsters = { 61411,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 1, faceDir = { x = 0.0, y = 120.0, z = 0.0 } },
	[761107] = {	id = 761107, pos = { x = 8.990305, y = 0.1966333, z = -89.20601 }, randomPos = 0, randomRadius = 0, monsters = { 61411,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 1, faceDir = { x = 0.0, y = 120.0, z = 0.0 } },
	[761108] = {	id = 761108, pos = { x = 10.51051, y = 0.1966333, z = -92.95649 }, randomPos = 0, randomRadius = 0, monsters = { 61411,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 1, faceDir = { x = 0.0, y = 120.0, z = 0.0 } },
	[761109] = {	id = 761109, pos = { x = -19.44295, y = 1.596634, z = -95.33341 }, randomPos = 1, randomRadius = 600, monsters = { 61412,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 8, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 1, faceDir = { x = 0.0, y = -15.0, z = 0.0 } },
	[761110] = {	id = 761110, pos = { x = -13.50158, y = 1.596634, z = -88.99158 }, randomPos = 1, randomRadius = 300, monsters = { 61414,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 1, faceDir = { x = 0.0, y = 105.0, z = 0.0 } },
	[761111] = {	id = 761111, pos = { x = -3.744243, y = 4.196633, z = -68.55118 }, randomPos = 1, randomRadius = 600, monsters = { 61413,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 8, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 1, faceDir = { x = 0.0, y = 105.0, z = 0.0 } },
	[761112] = {	id = 761112, pos = { x = -1.504953, y = 4.196633, z = -59.4409 }, randomPos = 0, randomRadius = 0, monsters = { 61415,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
