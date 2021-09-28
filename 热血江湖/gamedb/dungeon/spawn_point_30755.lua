----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[6151100] = {	id = 6151100, pos = { x = -130.5271, y = 19.28095, z = 10.37442 }, randomPos = 0, randomRadius = 0, monsters = { 141003,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 270.0, z = 0.0 } },
	[6151101] = {	id = 6151101, pos = { x = -117.5755, y = 19.13203, z = 11.12442 }, randomPos = 0, randomRadius = 0, monsters = { 141034,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 270.0, z = 0.0 } },
	[6151102] = {	id = 6151102, pos = { x = 5.742405, y = 29.0, z = 9.222066 }, randomPos = 0, randomRadius = 0, monsters = { 141004,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 270.0, z = 0.0 } },
	[6151103] = {	id = 6151103, pos = { x = 31.45423, y = 28.93204, z = 0.2452125 }, randomPos = 0, randomRadius = 0, monsters = { 141035,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 270.0, z = 0.0 } },
	[6151104] = {	id = 6151104, pos = { x = 31.96481, y = 23.70134, z = -69.70079 }, randomPos = 0, randomRadius = 0, monsters = { 141005,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 270.0, z = 0.0 } },
	[6151105] = {	id = 6151105, pos = { x = 30.681, y = 23.53204, z = -82.47881 }, randomPos = 0, randomRadius = 0, monsters = { 141036,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 270.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
