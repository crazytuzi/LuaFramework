----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[390401] = {	id = 390401, pos = { x = 123.0783, y = 10.45232, z = -24.11434 }, randomPos = 0, randomRadius = 0, monsters = { 90504,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[390402] = {	id = 390402, pos = { x = 118.4183, y = 10.46504, z = -25.12493 }, randomPos = 0, randomRadius = 0, monsters = { 90504,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[390403] = {	id = 390403, pos = { x = 127.1578, y = 10.4044, z = -23.00653 }, randomPos = 0, randomRadius = 0, monsters = { 90505,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[390404] = {	id = 390404, pos = { x = 124.3478, y = 10.43741, z = -27.27586 }, randomPos = 0, randomRadius = 0, monsters = { 90505,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[390501] = {	id = 390501, pos = { x = 98.59222, y = 7.394502, z = -67.21765 }, randomPos = 0, randomRadius = 0, monsters = { 90504,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[390502] = {	id = 390502, pos = { x = 95.18079, y = 7.394504, z = -67.59688 }, randomPos = 0, randomRadius = 0, monsters = { 90504,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[390503] = {	id = 390503, pos = { x = 99.31846, y = 7.394502, z = -69.71487 }, randomPos = 0, randomRadius = 0, monsters = { 90505,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[390504] = {	id = 390504, pos = { x = 93.9123, y = 7.394504, z = -64.80301 }, randomPos = 0, randomRadius = 0, monsters = { 90505,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[390505] = {	id = 390505, pos = { x = 95.56168, y = 7.394504, z = -64.0 }, randomPos = 0, randomRadius = 0, monsters = { 90506,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
