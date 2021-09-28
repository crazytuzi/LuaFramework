----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[740101] = {	id = 740101, pos = { x = 15.54444, y = 25.22471, z = 23.67361 }, randomPos = 0, randomRadius = 0, monsters = { 94124,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[740102] = {	id = 740102, pos = { x = 14.78234, y = 25.29069, z = 18.33435 }, randomPos = 0, randomRadius = 0, monsters = { 94123,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[740103] = {	id = 740103, pos = { x = 21.4633, y = 25.2, z = 21.55778 }, randomPos = 0, randomRadius = 0, monsters = { 94123,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[740104] = {	id = 740104, pos = { x = 18.00588, y = 25.24751, z = 15.78487 }, randomPos = 0, randomRadius = 0, monsters = { 94121,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[740105] = {	id = 740105, pos = { x = 24.44946, y = 25.11867, z = 24.26157 }, randomPos = 0, randomRadius = 0, monsters = { 94121,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[740106] = {	id = 740106, pos = { x = 21.18799, y = 25.2, z = 17.32024 }, randomPos = 0, randomRadius = 0, monsters = { 94122,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[740107] = {	id = 740107, pos = { x = 15.67182, y = 25.28489, z = 14.20768 }, randomPos = 0, randomRadius = 0, monsters = { 94122,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
