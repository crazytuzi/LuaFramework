----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[420101] = {	id = 420101, pos = { x = 71.12454, y = 12.92208, z = -11.83778 }, randomPos = 0, randomRadius = 0, monsters = { 90531,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[420102] = {	id = 420102, pos = { x = 74.39334, y = 12.95845, z = -12.11489 }, randomPos = 0, randomRadius = 0, monsters = { 90531,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[420103] = {	id = 420103, pos = { x = 75.9313, y = 12.95107, z = -11.87803 }, randomPos = 0, randomRadius = 0, monsters = { 90531,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[420104] = {	id = 420104, pos = { x = 77.52156, y = 12.90413, z = -11.698 }, randomPos = 0, randomRadius = 0, monsters = { 90531,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[420105] = {	id = 420105, pos = { x = 80.22726, y = 12.82421, z = -11.50933 }, randomPos = 0, randomRadius = 0, monsters = { 90531,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
