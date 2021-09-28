----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[400201] = {	id = 400201, pos = { x = 70.41787, y = -20.66388, z = 17.91928 }, randomPos = 0, randomRadius = 0, monsters = { 90511,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[400202] = {	id = 400202, pos = { x = 81.26833, y = 14.7945, z = 9.055576 }, randomPos = 0, randomRadius = 0, monsters = { 90511,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[400203] = {	id = 400203, pos = { x = 84.8577, y = 14.7945, z = 7.58802 }, randomPos = 0, randomRadius = 0, monsters = { 90511,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[400204] = {	id = 400204, pos = { x = 86.15808, y = 14.7945, z = 6.577497 }, randomPos = 0, randomRadius = 0, monsters = { 90512,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[400205] = {	id = 400205, pos = { x = 82.46237, y = 14.7945, z = 7.893149 }, randomPos = 0, randomRadius = 0, monsters = { 90512,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[400206] = {	id = 400206, pos = { x = 78.86852, y = 14.7945, z = 8.966239 }, randomPos = 0, randomRadius = 0, monsters = { 90512,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[400207] = {	id = 400207, pos = { x = 82.98851, y = 14.7945, z = 8.43165 }, randomPos = 0, randomRadius = 0, monsters = { 90513,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[400301] = {	id = 400301, pos = { x = 135.1032, y = -21.46387, z = -21.95219 }, randomPos = 0, randomRadius = 0, monsters = { 90514,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[400302] = {	id = 400302, pos = { x = 121.6755, y = 10.46881, z = -18.64943 }, randomPos = 0, randomRadius = 0, monsters = { 90514,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[400303] = {	id = 400303, pos = { x = 118.9272, y = 10.50041, z = -21.67749 }, randomPos = 0, randomRadius = 0, monsters = { 90514,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[400304] = {	id = 400304, pos = { x = 125.2618, y = 10.42667, z = -19.36773 }, randomPos = 0, randomRadius = 0, monsters = { 90511,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[400305] = {	id = 400305, pos = { x = 123.9539, y = 10.44204, z = -22.48787 }, randomPos = 0, randomRadius = 0, monsters = { 90511,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[400306] = {	id = 400306, pos = { x = 124.7786, y = 10.43235, z = -21.32227 }, randomPos = 0, randomRadius = 0, monsters = { 90511,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
