----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[730101] = {	id = 730101, pos = { x = 15.54819, y = 25.23781, z = 23.01151 }, randomPos = 0, randomRadius = 0, monsters = { 94111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[730102] = {	id = 730102, pos = { x = 14.76656, y = 25.28944, z = 19.16254 }, randomPos = 0, randomRadius = 0, monsters = { 94111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[730103] = {	id = 730103, pos = { x = 19.52136, y = 25.21271, z = 22.69879 }, randomPos = 0, randomRadius = 0, monsters = { 94114,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[730104] = {	id = 730104, pos = { x = 18.6657, y = 25.22877, z = 20.80282 }, randomPos = 0, randomRadius = 0, monsters = { 94112,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[730105] = {	id = 730105, pos = { x = 18.71788, y = 25.23323, z = 17.87227 }, randomPos = 0, randomRadius = 0, monsters = { 94112,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
