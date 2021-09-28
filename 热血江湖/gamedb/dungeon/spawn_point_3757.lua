----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[751401] = {	id = 751401, pos = { x = -4.113502, y = 51.50901, z = 60.47458 }, randomPos = 0, randomRadius = 0, monsters = { 94406,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[751402] = {	id = 751402, pos = { x = 3.424713, y = 51.50901, z = 59.74678 }, randomPos = 0, randomRadius = 0, monsters = { 94407,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[751403] = {	id = 751403, pos = { x = -0.2450171, y = 51.50901, z = 52.93994 }, randomPos = 0, randomRadius = 0, monsters = { 94408,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[751501] = {	id = 751501, pos = { x = -0.0316291, y = 51.50901, z = 58.23781 }, randomPos = 0, randomRadius = 0, monsters = { 94409,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
